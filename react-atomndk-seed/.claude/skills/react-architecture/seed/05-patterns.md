# 05 — Patrones de desarrollo

Patrones genéricos listos para copiar y renombrar. Ningún snippet importa desde paths específicos de un proyecto derivado.

Flujo canónico: `Component → Hook (React Query) → Repository → backendApi`. La capa Service es **opcional**: solo existe si hay lógica de negocio real (combinar repositorios, aplicar reglas); un service que solo delega viola YAGNI.

---

## Repository Pattern

Los repositorios encapsulan la lógica de acceso a datos. Viven en `src/library/repositories/`.

```typescript
// src/library/repositories/items.repository.ts
import { backendApi } from '@library/api';
import type { Item, CreateItemDto, UpdateItemDto } from '@resources/entities/item.entity';

export const itemsRepository = {
  async findAll(): Promise<Item[]> {
    const { data } = await backendApi.get<Item[]>('/items');
    return data;
  },

  async findById(id: string): Promise<Item> {
    const { data } = await backendApi.get<Item>(`/items/${id}`);
    return data;
  },

  async create(dto: CreateItemDto): Promise<Item> {
    const { data } = await backendApi.post<Item>('/items', dto);
    return data;
  },

  async update(id: string, dto: UpdateItemDto): Promise<Item> {
    const { data } = await backendApi.patch<Item>(`/items/${id}`, dto);
    return data;
  },

  async remove(id: string): Promise<void> {
    await backendApi.delete<void>(`/items/${id}`);
  },
};
```

Si hubiera lógica de negocio (p. ej. combinar `itemsRepository` con otro repositorio), se crea `src/library/services/items.service.ts` y los hooks llaman al service; si no, los hooks llaman directo al repository.

---

## useQuery Hook Pattern

Los hooks de TanStack Query viven en `src/modules/{feature}/core/hooks/`.

```typescript
// src/modules/items/core/hooks/use-items-query.ts
import { useQuery } from '@tanstack/react-query';
import { itemsRepository } from '@library/repositories/items.repository';
import { queryKeys } from '@library/query/query-keys';

// Las keys viven en el registry central src/library/query/query-keys.ts:
// export const queryKeys = {
//   items: {
//     all: ['items'] as const,
//     detail: (id: string) => ['items', id] as const,
//   },
// } as const;

export function useItemsQuery() {
  return useQuery({
    queryKey: queryKeys.items.all,
    queryFn: () => itemsRepository.findAll(),
    staleTime: 5 * 60 * 1000,
  });
}

export function useItemQuery(id: string) {
  return useQuery({
    queryKey: queryKeys.items.detail(id),
    queryFn: () => itemsRepository.findById(id),
    enabled: Boolean(id),
  });
}
```

---

## useMutation Hook Pattern

```typescript
// src/modules/items/core/hooks/use-create-item.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { itemsRepository } from '@library/repositories/items.repository';
import { queryKeys } from '@library/query/query-keys';
import type { CreateItemDto } from '@resources/entities/item.entity';

export function useCreateItem() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (dto: CreateItemDto) => itemsRepository.create(dto),
    onSuccess: () => {
      // Invalida y refetch la lista
      void queryClient.invalidateQueries({ queryKey: queryKeys.items.all });
    },
    // onError: no usar console.error. Los errores los captura el interceptor Axios
    // o Sentry automáticamente. El componente consume isError para mostrar feedback.
  });
}
```

---

## Zustand Store Pattern

Los stores globales viven en `src/global/store/`. Los locales de módulo en `src/modules/{feature}/core/state/`. Zustand guarda estado de UI y datos de sesión derivados; los datos del servidor viven en React Query y los tokens los gestiona `oidc-spa`.

```typescript
// src/global/store/auth.store.ts (incluido en la semilla)
import { create } from 'zustand';
import type { OidcUser } from '@resources/contracts/oidc.contract';

interface AuthState {
  user: OidcUser | null;
  setUser: (user: OidcUser | null) => void;
}

// Store delgado: NO gestiona tokens ni isAuthenticated (eso lo provee oidc-spa).
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
```

El otro store global de la semilla es `useUiStore` (`src/global/store/ui.store.ts`): sidebar, tema (`theme` / `setTheme`), toast global (`showError` / `showSuccess`) y grupos de navegación. Consumir siempre con selectores: `useUiStore((s) => s.theme)`.

---

## Protected Route Pattern

`Q5ProtectedRoute` (`src/global/components/q5-protected-route/`) es la guarda de sesión de la semilla. Lee la sesión con `useAuthStatus()` (OIDC) y, sin sesión, redirige a `/login`. Toda ruta de negocio se registra como hija suya:

```typescript
// src/global/components/q5-protected-route/q5-protected-route.tsx
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuthStatus } from '@global/hooks/use-auth-status';

export function Q5ProtectedRoute() {
  const { isAuthenticated } = useAuthStatus();
  const location = useLocation();
  if (!isAuthenticated) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }
  return <Outlet />;
}
```

Para restringir por rol dentro de una página, usar `<Q5Authorized requiredRole={AppRole.ADMIN} fallback={<Q2Forbidden />}>…</Q5Authorized>` (roles en `src/resources/enums/permission.enum.ts`, mapeo grupo IdP → rol en `src/resources/contracts/oidc.contract.ts`).

---

## HTTP Error Interceptor Pattern

`backendApi` (`src/library/api/backend-api.ts`) registra tres interceptores, en este orden:

```typescript
export const backendApi = createApiClient(import.meta.env.VITE_API_URL);
registerTokenInterceptor(backendApi);        // request: Authorization: Bearer <access token OIDC>
registerRefreshRetryInterceptor(backendApi); // 401: oidc.renewTokens() + 1 reintento (_retry)
registerErrorInterceptor(backendApi);        // 401 final: oidc.logout({ redirectTo: 'home' }) si hay sesión
```

```typescript
// src/library/api/interceptors/error.interceptor.ts (extracto)
async (error: AxiosError) => {
  if (error.response?.status === 401) {
    const oidc = await getOidc();
    if (oidc.isUserLoggedIn) await oidc.logout({ redirectTo: 'home' });
  }
  // 403 NO redirige — el usuario sigue autenticado pero sin permiso para ese recurso.
  // El componente consumidor usa getHttpStatus(error) === 403 + <Q2Forbidden /> inline.
  // Ver: architecture/11-http-error-handling.md
  return Promise.reject(error);
}
```

---

## MSW Handler Pattern

Los handlers viven en `src/library/mocks/handlers/`.

```typescript
// src/library/mocks/handlers/items.handlers.ts
import { http, HttpResponse } from 'msw';
import type { Item } from '@resources/entities/item.entity';

const mockItems: Item[] = [
  { id: '1', name: 'Item One', status: 'active' },
  { id: '2', name: 'Item Two', status: 'inactive' },
];

export const itemHandlers = [
  http.get('/api/items', () => {
    return HttpResponse.json(mockItems);
  }),

  http.get('/api/items/:id', ({ params }) => {
    const item = mockItems.find((i) => i.id === params.id);
    if (!item) {
      return HttpResponse.json({ message: 'Item not found' }, { status: 404 });
    }
    return HttpResponse.json(item);
  }),

  http.post('/api/items', async ({ request }) => {
    const body = await request.json() as Omit<Item, 'id'>;
    const newItem: Item = { id: String(Date.now()), ...body };
    mockItems.push(newItem);
    return HttpResponse.json(newItem, { status: 201 });
  }),
];
```

---

## Axios Instance Factory Pattern

La semilla expone una factory sin interceptores; quien crea la instancia decide qué interceptores registra:

```typescript
// src/library/api/client/api-instance.ts
import axios from 'axios';
import type { AxiosInstance } from 'axios';

export function createApiClient(baseURL: string): AxiosInstance {
  return axios.create({
    baseURL,
    timeout: 15_000,
    headers: { 'Content-Type': 'application/json' },
  });
}
```

`backendApi` es el único cliente que usan los repositorios. Si un proyecto necesita otra API, crea otra instancia en `src/library/api/` con `createApiClient` y registra los interceptores que correspondan (sin `console.*`: los errores van a Sentry o al interceptor).

---

## Zod Schema + React Hook Form Pattern

```typescript
// src/modules/items/core/schemas/create-item.schema.ts
import { z } from 'zod';

export const createItemSchema = z.object({
  name: z
    .string()
    .min(1, 'El nombre es requerido')
    .max(100, 'Máximo 100 caracteres'),
  description: z.string().optional(),
  quantity: z
    .number({ error: 'Debe ser un número' })
    .int()
    .min(0, 'Debe ser 0 o mayor'),
  category: z.enum(['type-a', 'type-b', 'type-c'], { error: 'Categoría inválida' }),
});

export type CreateItemFormData = z.infer<typeof createItemSchema>;
```

```typescript
// Uso en componente
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { createItemSchema, type CreateItemFormData } from '../core/schemas/create-item.schema';

export function CreateItemForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<CreateItemFormData>({
    resolver: zodResolver(createItemSchema),
    defaultValues: {
      quantity: 0,
    },
  });

  const { mutateAsync: createItem } = useCreateItem();

  const onSubmit = async (data: CreateItemFormData) => {
    await createItem(data);
    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} placeholder="Nombre" />
      {errors.name && <p>{errors.name.message}</p>}

      <input
        type="number"
        {...register('quantity', { valueAsNumber: true })}
      />
      {errors.quantity && <p>{errors.quantity.message}</p>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Guardando...' : 'Crear'}
      </button>
    </form>
  );
}
```
