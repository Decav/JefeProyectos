# Guía: Crear un Módulo Nuevo (14 Pasos)

Guía ejecutable para agregar un módulo completo. Ejemplo: módulo `profile` con entidad `Profile` (mismo ejemplo que `SKILL.md`, sección 7).

Flujo de datos canónico: `Component → Hook (React Query) → Repository → backendApi`. La capa Service es **opcional** (ver Paso 6).

---

## Paso 1: Crear la Estructura de Carpetas

```bash
mkdir -p src/modules/profile/{components,core/hooks,core/schemas,core/state,routes}
```

**Resultado esperado:**
```
src/modules/profile/
├── components/
├── core/
│   ├── hooks/
│   ├── schemas/
│   └── state/
└── routes/
```

---

## Paso 2: Definir la Entidad en resources

**Ruta:** `src/resources/entities/profile.entity.ts`

```ts
export interface Profile {
  id: string;
  name: string;
  email: string;
}
```

Re-exportar desde `src/resources/entities/index.ts`:

```ts
export type { Profile } from './profile.entity';
```

---

## Paso 3: Definir Request y Response en resources

**Ruta:** `src/resources/requests/profile.request.ts`

```ts
export interface UpdateProfileRequest {
  name: string;
  email: string;
}
```

**Ruta:** `src/resources/responses/profile.response.ts`

```ts
import type { Profile } from '../entities/profile.entity';

export type ProfileResponse = Profile;
```

Re-exportar ambos desde `src/resources/requests/index.ts` y `src/resources/responses/index.ts`.

**Resultado esperado:** tipos disponibles en toda la app vía `@resources`.

---

## Paso 4: Crear Schema Zod

**Ruta:** `src/modules/profile/core/schemas/profile.schema.ts`

```ts
import { z } from 'zod';

export const profileSchema = z.object({
  name: z.string().min(1, 'El nombre es obligatorio').max(50, 'Máximo 50 caracteres'),
  email: z.email('Correo inválido'),
});

export type ProfileFormValues = z.infer<typeof profileSchema>;
```

**Barrel:** `src/modules/profile/core/schemas/index.ts`

```ts
export { profileSchema, type ProfileFormValues } from './profile.schema';
```

---

## Paso 5: Crear Repository

**Ruta:** `src/library/repositories/profile.repository.ts`

Los repositorios usan siempre `backendApi` (cliente canónico con token Bearer OIDC, refresh-retry y manejo de 401). Nunca crean instancias propias con `createApiClient` ni importan axios directamente.

```ts
import { backendApi } from '@library/api';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';
import type { ProfileResponse } from '@resources/responses/profile.response';

export const ProfileRepository = {
  getProfile: (): Promise<ProfileResponse> =>
    backendApi.get<ProfileResponse>('/api/profile').then((r) => r.data),
  updateProfile: (data: UpdateProfileRequest): Promise<ProfileResponse> =>
    backendApi.put<ProfileResponse>('/api/profile', data).then((r) => r.data),
};
```

Re-exportar desde `src/library/repositories/index.ts` (hoy vacío: `export {};`).

---

## Paso 6: Registrar Query Keys (y Service solo si hay lógica de negocio)

**Ruta:** `src/library/query/query-keys.ts` (la semilla lo trae vacío: `export const queryKeys = {} as const;`)

```ts
export const queryKeys = {
  profile: { detail: ['profile', 'detail'] as const },
} as const;
```

Las query keys **nunca** se escriben como literales en los hooks; siempre se leen de este registry.

**Service (opcional):** crear `src/library/services/profile.service.ts` **solo** si hay lógica de negocio real (combinar repositorios, normalizar datos, aplicar reglas). Un service que solo delega al repository viola YAGNI: en ese caso los hooks llaman directo al repository.

```ts
// src/library/services/profile.service.ts — solo si hay lógica real
import { ProfileRepository } from '@library/repositories/profile.repository';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';

export const ProfileService = {
  updateProfile: (data: UpdateProfileRequest) =>
    ProfileRepository.updateProfile({ ...data, email: data.email.trim().toLowerCase() }),
};
```

---

## Paso 7: Crear Query Hook

**Ruta:** `src/modules/profile/core/hooks/use-profile-query.ts`

```ts
import { useQuery } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useProfileQuery() {
  return useQuery({
    queryKey: queryKeys.profile.detail,
    queryFn: ProfileRepository.getProfile,
    staleTime: 30_000, // default global: 60_000 (src/library/query/query-client.ts)
  });
}
```

---

## Paso 8: Crear Mutation Hook

**Ruta:** `src/modules/profile/core/hooks/use-update-profile-mutation.ts`

```ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useUpdateProfileMutation() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ProfileRepository.updateProfile, // o ProfileService.updateProfile si existe
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.profile.detail });
    },
  });
}
```

**Barrel:** `src/modules/profile/core/hooks/index.ts`

```ts
export { useProfileQuery } from './use-profile-query';
export { useUpdateProfileMutation } from './use-update-profile-mutation';
```

---

## Paso 9: Crear Componentes q2/q3 del Módulo (si aplica)

Los q1-q3 reutilizables entre módulos van en `src/global/components/`. Los q2-q3 específicos del módulo van en `src/modules/profile/components/`.

**Ruta:** `src/modules/profile/components/q2-profile-summary/q2-profile-summary.tsx`

```tsx
import type { Profile } from '@resources/entities/profile.entity';

interface Q2ProfileSummaryProps {
  readonly profile: Profile;
}

export function Q2ProfileSummary({ profile }: Q2ProfileSummaryProps) {
  return (
    <div className="flex flex-col gap-1">
      <span className="font-semibold text-[var(--acl-text-primary)]">{profile.name}</span>
      <span className="text-sm text-[var(--acl-text-secondary)]">{profile.email}</span>
    </div>
  );
}
```

**Barrel:** `src/modules/profile/components/q2-profile-summary/index.ts`

```ts
export { Q2ProfileSummary } from './q2-profile-summary';
```

---

## Paso 10: Crear Componente q4 (con Lógica y Formulario)

**Ruta:** `src/modules/profile/components/q4-profile-form/q4-profile-form.tsx`

```tsx
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { InputText } from 'primereact/inputtext';
import { Skeleton } from 'primereact/skeleton';
import { Q1Button, Q2Forbidden } from '@global/components';
import { getHttpStatus } from '@global/utils';
import { profileSchema, type ProfileFormValues } from '../../core/schemas/profile.schema';
import { useProfileQuery } from '../../core/hooks/use-profile-query';
import { useUpdateProfileMutation } from '../../core/hooks/use-update-profile-mutation';

export function Q4ProfileForm() {
  const { data: profile, isLoading, error } = useProfileQuery();
  const { mutate: updateProfile, isPending, isError } = useUpdateProfileMutation();

  const { control, handleSubmit, formState: { errors } } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    values: profile ? { name: profile.name, email: profile.email } : { name: '', email: '' },
  });

  if (isLoading) return <Skeleton height="12rem" />;
  if (getHttpStatus(error) === 403) return <Q2Forbidden />;

  return (
    <form onSubmit={handleSubmit((data) => updateProfile(data))} className="flex flex-col gap-4">
      <Controller
        name="name"
        control={control}
        render={({ field }) => <InputText {...field} aria-label="Nombre" />}
      />
      {errors.name && <p className="text-[var(--acl-danger)]">{errors.name.message}</p>}
      <Controller
        name="email"
        control={control}
        render={({ field }) => <InputText {...field} aria-label="Correo" />}
      />
      {errors.email && <p className="text-[var(--acl-danger)]">{errors.email.message}</p>}
      {isError && <p className="text-[var(--acl-danger)]">No pudimos guardar los cambios.</p>}
      <Q1Button type="submit" label="Guardar" loading={isPending} />
    </form>
  );
}
```

> `Q1Button` envuelve el `Button` de PrimeReact (acepta sus props salvo `severity`) y agrega `variant?: 'primary' | 'secondary' | 'danger' | 'ghost'`. Loading con `<Skeleton>` y 403 con `<Q2Forbidden />` según `11-http-error-handling.md`.

---

## Paso 11: Crear Página pa (Ensambladora)

**Ruta:** `src/modules/profile/components/pa-profile/pa-profile.tsx`

```tsx
import { Q4ProfileForm } from '../q4-profile-form/q4-profile-form';

export function PaProfile() {
  return (
    <main className="p-6">
      <h1 className="text-2xl font-bold mb-6">Mi perfil</h1>
      <div className="acl-card max-w-lg">
        <Q4ProfileForm />
      </div>
    </main>
  );
}
```

**Barrel:** `src/modules/profile/components/pa-profile/index.ts`

```ts
export { PaProfile } from './pa-profile';
```

---

## Paso 12: Crear Store Zustand del Módulo (si aplica)

Solo si el módulo necesita estado local de UI (wizard, tabs, diálogo abierto). Los datos del servidor viven en React Query, no en Zustand.

**Ruta:** `src/modules/profile/core/state/profile-ui.store.ts`

```ts
import { create } from 'zustand';

interface ProfileUiState {
  editMode: boolean;
  setEditMode: (value: boolean) => void;
}

export const useProfileUiStore = create<ProfileUiState>((set) => ({
  editMode: false,
  setEditMode: (value) => set({ editMode: value }),
}));
```

---

## Paso 13: Crear MSW Handlers y Registrarlos

**Ruta:** `src/library/mocks/handlers/profile.handlers.ts`

```ts
import { http, HttpResponse } from 'msw';
import type { ProfileResponse } from '@resources/responses/profile.response';

const mockProfile: ProfileResponse = {
  id: '1',
  name: 'Usuario Demo',
  email: 'demo@example.com',
};

export const profileHandlers = [
  http.get('*/api/profile', () => HttpResponse.json(mockProfile)),
  http.put('*/api/profile', async ({ request }) => {
    const body = (await request.json()) as Partial<ProfileResponse>;
    return HttpResponse.json({ ...mockProfile, ...body });
  }),
];
```

**Registrar en** `src/library/mocks/handlers/index.ts` (la semilla lo trae vacío: `export const handlers: RequestHandler[] = [];`):

```ts
import type { RequestHandler } from 'msw';
import { profileHandlers } from './profile.handlers';

export const handlers: RequestHandler[] = [...profileHandlers];
```

`browser.ts` (`setupWorker`) y `server.ts` (`setupServer`, usado en Vitest) consumen este mismo array.

---

## Paso 14: Rutas, Registro en el Router y Barrel del Módulo

**Ruta:** `src/modules/profile/routes/profile.routes.tsx`

```tsx
import type { RouteObject } from 'react-router-dom';
import { PaProfile } from '../components/pa-profile/pa-profile';

export const profileRoutes: RouteObject[] = [
  { path: '/profile', element: <PaProfile /> },
];
```

**Barrel del módulo:** `src/modules/profile/index.ts`

```ts
export { profileRoutes } from './routes/profile.routes';
export { PaProfile } from './components/pa-profile/pa-profile';
```

Agregar `export * from './profile';` en `src/modules/index.ts`.

**Registrar en** `src/app/router/app-router.tsx`:

```tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { loginRoutes } from '@modules/login';
import { callbackRoutes } from '@modules/callback';
import { profileRoutes } from '@modules/profile';
import { Q5ProtectedRoute } from '@global/components';

export const router = createBrowserRouter([
  ...loginRoutes,
  ...callbackRoutes,
  {
    element: <Q5ProtectedRoute />,
    children: [...profileRoutes],
  },
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
```

> **Importante:** `OidcInitializationGate` solo espera a que OIDC termine de inicializar; no fuerza login. Las rutas del módulo deben registrarse como hijas de `Q5ProtectedRoute`, que redirige a `/login` si no hay sesión. Para restringir por rol, envolver el contenido con `<Q5Authorized requiredRole={...} fallback={<Q2Forbidden />}>`.

---

## Verificación Final (incluye test e2e obligatorio)

Cada flujo visible requiere un test Playwright en `e2e/` (regla crítica 6 de `SKILL.md`).

**Ruta:** `e2e/profile.spec.ts`

```ts
import { test, expect } from '@playwright/test';

test('la página de perfil muestra el formulario', async ({ page }) => {
  await page.goto('/profile');
  await expect(page.getByRole('heading', { name: 'Mi perfil' })).toBeVisible();
});
```

Si la ruta exige sesión, el test debe preparar la autenticación contra el IdP de pruebas del proyecto o mockear la sesión; documentar el enfoque elegido en el propio spec.

```bash
# TypeScript + build
npm run build

# Lint
npm run lint

# Tests unitarios / integración
npm run test

# Tests e2e (levanta npm run dev en http://localhost:5151 si no está activo)
npm run test:e2e

# Verificación manual
npm run dev
# Navegar a http://localhost:5151/profile
```

---

## Resumen de Archivos Creados

| Paso | Archivo | Capa |
|------|---------|------|
| 1 | Estructura de carpetas | modules |
| 2 | `resources/entities/profile.entity.ts` | resources |
| 3 | `resources/requests/profile.request.ts` | resources |
| 3 | `resources/responses/profile.response.ts` | resources |
| 4 | `modules/profile/core/schemas/profile.schema.ts` | modules |
| 5 | `library/repositories/profile.repository.ts` | library |
| 6 | `library/query/query-keys.ts` (modificado) | library |
| 6 | `library/services/profile.service.ts` (opcional) | library |
| 7 | `modules/profile/core/hooks/use-profile-query.ts` | modules |
| 8 | `modules/profile/core/hooks/use-update-profile-mutation.ts` | modules |
| 9 | `modules/profile/components/q2-profile-summary/q2-profile-summary.tsx` (si aplica) | modules |
| 10 | `modules/profile/components/q4-profile-form/q4-profile-form.tsx` | modules |
| 11 | `modules/profile/components/pa-profile/pa-profile.tsx` | modules |
| 12 | `modules/profile/core/state/profile-ui.store.ts` (si aplica) | modules |
| 13 | `library/mocks/handlers/profile.handlers.ts` + `handlers/index.ts` (modificado) | library |
| 14 | `modules/profile/routes/profile.routes.tsx`, `modules/profile/index.ts`, `modules/index.ts` y `app/router/app-router.tsx` (modificados) | modules / app |
| — | `e2e/profile.spec.ts` | e2e |
