# Patrones Canónicos

8 patrones canónicos (1–8) más 4 patrones complementarios (9–12). Los patrones que la semilla ya incluye citan su archivo real en `src/`; los que se aplican al crear un módulo nuevo usan el dominio genérico de ejemplo `profile` (el mismo de `SKILL.md`). Cada patrón incluye snippet, reglas y ubicación.

Flujo de datos canónico:

```
Componente → Hook (React Query) → Repository → backendApi
                                  ↑
                     Service (OPCIONAL, solo con lógica de negocio real)
```

> La semilla trae `src/library/repositories/` y `src/library/services/` vacíos (solo `index.ts`) y `queryKeys` vacío: cada módulo agrega sus propios archivos y keys.

---

## 1. Repository Pattern

**Dónde vive:** `src/library/repositories/{dominio}.repository.ts`

**Reglas:**
- Solo llama a `backendApi` (import desde `'@library/api'`). Es el único cliente HTTP que usan los repositorios; ya incluye los interceptores de token, refresh y error.
- Nunca crea instancias propias de Axios ni importa `axios` directamente.
- Siempre tipa la llamada con el genérico `<T>` y retorna `r.data`, nunca el response completo.
- Sin try/catch (los errores se manejan en interceptores o en el hook/componente).
- Sin lógica de negocio, transformaciones ni combinaciones de llamadas.
- Sin JSX ni imports de React.

**Ejemplo (módulo nuevo):** `src/library/repositories/profile.repository.ts`

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

> `backendApi` se define en `src/library/api/backend-api.ts` usando la factory `createApiClient(baseURL)` de `src/library/api/client/api-instance.ts` con `baseURL = VITE_API_URL`.

---

## 2. Service Pattern (OPCIONAL)

**Dónde vive:** `src/library/services/{dominio}.service.ts`

**Cuándo crearlo:** solo si existe lógica de negocio real: combinar varios repositorios, aplicar reglas, normalizar o enriquecer datos. Si el service solo delega al repository, **no se crea** (YAGNI): el hook llama directo al repository. Un service passthrough agrega una capa sin valor y confunde al equipo sobre cuándo usar Service vs Repository.

**Reglas (cuando existe):**
- Capa de abstracción sobre uno o más repositorios.
- Puede combinar llamadas y transformar datos antes de retornarlos.
- Sin JSX ni hooks de React.
- Es la `mutationFn` / `queryFn` que consumen los hooks en lugar del repository.

**Ejemplo (con lógica real):** `src/library/services/profile.service.ts`

```ts
import { ProfileRepository } from '@library/repositories/profile.repository';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';

export const ProfileService = {
  // Regla de negocio: el email se guarda normalizado
  updateProfile: (data: UpdateProfileRequest) =>
    ProfileRepository.updateProfile({ ...data, email: data.email.trim().toLowerCase() }),
};
```

```ts
// ❌ Service passthrough — no crear
export const ProfileService = {
  getProfile: () => ProfileRepository.getProfile(),
};
```

---

## 3. Query Hook

**Dónde vive:** `src/modules/{modulo}/core/hooks/use-{nombre}-query.ts`

**Reglas:**
- Usa `useQuery` de TanStack Query.
- `queryKey` siempre desde el registry central `queryKeys` (`src/library/query/query-keys.ts`), nunca un literal inline.
- `queryFn` llama al repository (o al service, si existe).
- Sin side effects dentro de `queryFn` (sincronizar estado con `useEffect` sobre `query.data`).
- El componente consume el objeto retornado (`data`, `isLoading`, `error`).

**Registro de keys:** `src/library/query/query-keys.ts` (en la semilla es `export const queryKeys = {} as const;`; cada módulo agrega las suyas)

```ts
export const queryKeys = {
  profile: { detail: ['profile', 'detail'] as const },
} as const;
```

**Ejemplo (módulo nuevo):** `src/modules/profile/core/hooks/use-profile-query.ts`

```ts
import { useQuery } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useProfileQuery() {
  return useQuery({
    queryKey: queryKeys.profile.detail, // registry central — nunca strings literales
    queryFn: ProfileRepository.getProfile,
    staleTime: 30_000,
  });
}
```

> Los tipos de respuesta viven en `@resources/responses/`, nunca inline en el hook. Los defaults globales (`retry: 1`, `staleTime: 60_000`, `refetchOnWindowFocus: false`) están en `src/library/query/query-client.ts`.

---

## 4. Mutation Hook

**Dónde vive:** `src/modules/{modulo}/core/hooks/use-{nombre}-mutation.ts`

**Reglas:**
- Usa `useMutation` de TanStack Query.
- `mutationFn` apunta al repository (o al service, si existe).
- `onSuccess` invalida las queries afectadas con `queryKeys` y, si corresponde, actualiza stores o navega.
- Es el único punto donde se conectan datos + estado + navegación.
- No puede importar de otros módulos.

**Ejemplo (módulo nuevo):** `src/modules/profile/core/hooks/use-update-profile-mutation.ts`

```ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useUpdateProfileMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ProfileRepository.updateProfile,
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.profile.detail });
    },
  });
}
```

**Mutation real de la semilla:** `useLogoutMutation` (`src/library/oidc/use-logout-mutation.ts`, re-exportado en `@global/hooks`). No llama al backend: en `onSuccess` ejecuta `queryClient.clear()` y luego `oidc.logout({ redirectTo: 'specific url', url: origin + '/login' })`. El orden importa: primero se limpia la caché para evitar re-fetches con un token ya inválido.

---

## 5. Componente q4 — Organismo con Formulario

**Dónde vive:** `src/modules/{modulo}/components/q4-{nombre}/q4-{nombre}.tsx`

**Reglas:**
- Usa React Hook Form con `zodResolver` para validación; el schema vive en `core/schemas/`.
- Llama hooks de dominio del módulo (`useUpdateProfileMutation`, etc.).
- No llama services ni repositories directamente.
- Usa componentes PrimeReact (vía `Controller`), q2 del módulo o `Q1Button`; nunca inputs HTML primitivos sin estilo.
- Colores solo con tokens `--acl-*`.
- Export nombrado (no default).

**Schema (módulo nuevo):** `src/modules/profile/core/schemas/profile.schema.ts`

```ts
import { z } from 'zod';

export const profileSchema = z.object({
  name: z.string().trim().min(1, 'El nombre es obligatorio'),
  email: z.email('Ingresa un correo válido'),
});

export type ProfileFormValues = z.infer<typeof profileSchema>;
```

**Componente (módulo nuevo):** `src/modules/profile/components/q4-profile-form/q4-profile-form.tsx`

```tsx
import { Controller, useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { InputText } from 'primereact/inputtext';
import { Q1Button } from '@global/components';
import { profileSchema, type ProfileFormValues } from '../../core/schemas/profile.schema';
import { useUpdateProfileMutation } from '../../core/hooks/use-update-profile-mutation';

export function Q4ProfileForm() {
  const { mutate: updateProfile, isPending, isError } = useUpdateProfileMutation();
  const { control, handleSubmit, formState: { errors } } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: { name: '', email: '' },
  });

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

> `Q1Button` envuelve el `Button` de PrimeReact: acepta sus props (salvo `severity`) más `variant?: 'primary' | 'secondary' | 'danger' | 'ghost'`.

---

## 6. Componente pa — Página Ensambladora

**Dónde vive:** `src/modules/{modulo}/components/pa-{nombre}/pa-{nombre}.tsx`

**Reglas:**
- Renderiza q4/q5 sin lógica de negocio inline; puede contener guardas de ruta simples (ver `PaLogin`/`PaCallback`).
- Define el layout de la página (fondo, centrado, padding).
- Es el componente asignado al `element` en las rutas (`{modulo}.routes.tsx`).
- Export nombrado (no default).

**Ejemplo (módulo nuevo):** `src/modules/profile/components/pa-profile/pa-profile.tsx`

```tsx
import { Q4ProfileForm } from '../q4-profile-form/q4-profile-form';

export function PaProfile() {
  return (
    <main className="p-6">
      <div className="acl-card max-w-lg">
        <Q4ProfileForm />
      </div>
    </main>
  );
}
```

**Páginas reales de la semilla:**
- `src/modules/login/components/pa-login/pa-login.tsx` — `PaLogin`: si `oidc.isUserLoggedIn` → `<Navigate to="/callback" />`; si no, un botón llama a `oidc.login({ doesCurrentHrefRequiresAuth: false })`, que redirige al proveedor OIDC (por defecto Authentik). No hay formulario de usuario/contraseña.
- `src/modules/callback/components/pa-callback/pa-callback.tsx` — `PaCallback`: si no está autenticado (`useAuthStatus`) → `<Navigate to="/login" />`; si lo está, muestra los claims del usuario y un botón de logout (`useLogoutMutation`).

---

## 7. Zustand Store

**Dónde vive:** `src/global/store/{dominio}.store.ts` o `src/modules/{modulo}/core/state/{nombre}.store.ts`

**Reglas:**
- Interfaz de estado tipada (`interface AuthState`, `interface UiState`).
- Acciones definidas dentro del mismo `create()`.
- Export nombrado del hook (`useAuthStore`, `useUiStore`), no del store raw.
- Solo para client state (usuario derivado del token, UI). Nunca para datos del servidor (eso es React Query).
- **Nunca** guardar tokens ni estado de sesión: los gestiona `oidc-spa`. Para saber si hay sesión, usar `useAuthStatus()` (`@global/hooks`).
- En memoria por defecto; persistir solo preferencias de UI (ej.: `theme` en `ui.store`).
- Consumir con selectores: `useUiStore((s) => s.theme)`.

**Código real:** `src/global/store/auth.store.ts` (store delgado)

```ts
import { create } from 'zustand';
import type { OidcUser } from '@resources/contracts/oidc.contract';

interface AuthState {
  user: OidcUser | null;
  setUser: (user: OidcUser | null) => void;
}

// Store delgado: los tokens y el estado de sesión los gestiona oidc-spa.
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
```

**Código real:** `src/global/store/ui.store.ts` (extracto)

```ts
type Theme = 'system' | 'light' | 'dark';

interface UiState {
  sidebarOpen: boolean;
  setSidebarOpen: (value: boolean) => void;
  theme: Theme;
  setTheme: (theme: Theme) => void;          // aplica data-theme en <html> y persiste en localStorage ('acl-theme')
  toastRef: RefObject<Toast | null> | null;
  setToastRef: (ref: RefObject<Toast | null>) => void;
  showError: (summary: string, detail: string) => void;
  showSuccess: (summary: string, detail: string) => void;
}
```

Uso típico:

```tsx
const theme = useUiStore((s) => s.theme);
const setTheme = useUiStore((s) => s.setTheme);
const showError = useUiStore((s) => s.showError); // toast global (Q1GlobalToast registra el ref)
```

> Dark mode: no existe theme provider ni contexto de tema. Se usa `useUiStore` (`theme` / `setTheme`).

---

## 8. MSW Handler

**Dónde vive:** `src/library/mocks/handlers/{dominio}.handlers.ts`

**Reglas:**
- Usa `http.{method}` de MSW para interceptar requests por ruta, con prefijo `*/` para que coincida con cualquier `baseURL`.
- Se define una vez y se comparte entre Node (tests, `server.ts`) y navegador (`browser.ts`).
- Retorna respuestas tipadas con los tipos de `@resources/responses/`.
- Para errores, usa el segundo argumento: `HttpResponse.json({ detail }, { status: N })`.
- Se registra en `src/library/mocks/handlers/index.ts` (en la semilla, `handlers: RequestHandler[] = []`).

**Ejemplo (módulo nuevo):** `src/library/mocks/handlers/profile.handlers.ts`

```ts
import { http, HttpResponse } from 'msw';
import type { ProfileResponse } from '@resources/responses/profile.response';
import type { UpdateProfileRequest } from '@resources/requests/profile.request';

const demoProfile: ProfileResponse = { id: '1', name: 'Usuario Demo', email: 'demo@example.com' };

export const profileHandlers = [
  http.get('*/api/profile', () => HttpResponse.json(demoProfile)),
  http.put('*/api/profile', async ({ request }) => {
    const body = (await request.json()) as UpdateProfileRequest;
    const response: ProfileResponse = { ...demoProfile, ...body };
    return HttpResponse.json(response);
  }),
];
```

**Registro:** `src/library/mocks/handlers/index.ts`

```ts
import type { RequestHandler } from 'msw';
import { profileHandlers } from './profile.handlers';

export const handlers: RequestHandler[] = [...profileHandlers];
```

> `browser.ts` exporta el `worker`, pero la semilla no lo arranca en `main.tsx`. Para usar mocks en desarrollo hay que ejecutar `npm run msw:init` y arrancar el worker explícitamente.

---

## 9. Skeleton en Estados de Carga

**Dónde vive:** Dentro del componente que ejecuta la query, inmediatamente antes del render normal.

**Reglas:**
- Usar `<Skeleton>` de PrimeReact mientras `isLoading === true`. Nunca spinners custom ni componentes vacíos.
- Las dimensiones del `<Skeleton>` deben aproximar el tamaño del contenido real para evitar layout shift.
- Para listas: renderizar N instancias de `<Skeleton>` que emulen los ítems esperados.

**Ejemplo:**

```tsx
import { Skeleton } from 'primereact/skeleton';
import { useProfileQuery } from '../../core/hooks/use-profile-query';

export function Q4ProfileSummary() {
  const { data: profile, isLoading } = useProfileQuery();

  if (isLoading) {
    return (
      <div className="flex flex-col gap-2">
        <Skeleton height="1.5rem" width="60%" />
        <Skeleton height="1rem" width="40%" />
      </div>
    );
  }

  return (
    <div className="acl-card">
      <p className="font-semibold">{profile?.name}</p>
      <p>{profile?.email}</p>
    </div>
  );
}
```

> La semilla también usa `<Skeleton height="100vh" />` como fallback de `OidcInitializationGate` en `app-providers.tsx`.

Ver detalle completo: [11-http-error-handling.md](11-http-error-handling.md#regla-1-skeleton-en-estados-de-carga)

---

## 10. Interceptores 401 — Manejo Global

**Dónde vive:** `src/library/api/interceptors/` (registrados sobre `backendApi` en `src/library/api/backend-api.ts`)

**Reglas:**
- `token.interceptor.ts` (request): si `oidc.isUserLoggedIn`, agrega `Authorization: Bearer ${await oidc.getAccessToken()}`. El token de acceso vive en `oidc-spa`, nunca en un store.
- `refresh-retry.interceptor.ts` (response): ante un 401, si hay sesión, ejecuta `oidc.renewTokens()` y reintenta la request **una sola vez** (marca `_retry`). Si la renovación falla, propaga el error.
- `error.interceptor.ts` (response): si el 401 persiste, ejecuta `oidc.logout({ redirectTo: 'home' })` solo si `oidc.isUserLoggedIn` (evita loops). Los 403 se propagan al componente.
- Orden de registro: token → refresh-retry → error.
- Los componentes NO manejan 401 individualmente.

**Código real:** `src/library/api/interceptors/error.interceptor.ts`

```ts
import type { AxiosInstance, AxiosError } from 'axios';
import { getOidc } from '@library/oidc';

export function registerErrorInterceptor(instance: AxiosInstance): void {
  instance.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
      if (error.response?.status === 401) {
        try {
          const oidc = await getOidc();
          if (oidc.isUserLoggedIn) {
            await oidc.logout({ redirectTo: 'home' });
          }
        } catch {
          // getOidc falló — propagar el error original
        }
      }
      return Promise.reject(error);
    }
  );
}
```

Ver detalle completo: [11-http-error-handling.md](11-http-error-handling.md#regla-2-error-401--manejo-global-via-interceptores)

---

## 11. Error 403 — Componente Q2Forbidden Inline

**Dónde vive:** Componente consumidor + `src/global/components/q2-forbidden/` + `src/global/utils/get-http-status.ts`

**Reglas:**
- Un 403 no redirige ni bloquea la pantalla completa: el usuario sigue autenticado pero sin permiso para ese recurso.
- Usar `getHttpStatus(error)` (`@global/utils`), que retorna `number | null` usando `isAxiosError`.
- Cuando `getHttpStatus(error) === 403`, renderizar `<Q2Forbidden />` en lugar del contenido normal.
- `Q2Forbidden` es un componente q2 en `src/global/components/q2-forbidden/` (mensaje + botón "Volver" que hace `navigate(-1)`).

**Ejemplo:**

```tsx
import { Skeleton } from 'primereact/skeleton';
import { Q2Forbidden } from '@global/components';
import { getHttpStatus } from '@global/utils';
import { useProfileQuery } from '../../core/hooks/use-profile-query';

export function Q4ProfileDetail() {
  const { data, isLoading, error } = useProfileQuery();

  if (isLoading) return <Skeleton width="100%" height="10rem" />;
  if (getHttpStatus(error) === 403) return <Q2Forbidden />;

  return (
    <div className="acl-card">
      <p>{data?.name}</p>
    </div>
  );
}
```

> Para ocultar UI según el rol del usuario (sin llamar al backend) usar `<Q5Authorized requiredRole={AppRole.ADMIN} fallback={...}>` o `usePermissions().hasRole(...)`.

Ver detalle completo: [11-http-error-handling.md](11-http-error-handling.md#regla-3-error-403--componente-q2forbidden-nivel-componente-no-pantalla)

---

## 12. AppShell Pattern — Layout Estándar

**Dónde vive:** `src/global/components/q3-app-shell/q3-app-shell.tsx`

**Reglas:**
- Es q3 (Célula) porque tiene estado local de layout (sidebar móvil, iniciales del avatar).
- Vive en `global/` y se configura por props: `appName`, `navItems`, `logoSrc?` y `topbarActions?`. No trae enlaces externos ni categorías fijas: todo lo específico del proyecto entra por props.
- Lee el usuario con `useAuthStatus()` y el estado del sidebar (`sidebarOpen`) desde `useUiStore`.
- El sidebar usa `--acl-sidebar-bg` y no cambia con el tema light/dark.
- En desktop: sidebar fijo a la izquierda (`--acl-sidebar-width`). En mobile: drawer `Sidebar` de PrimeReact que se abre con el botón hamburguesa.
- Usa `useAuthStatus` y `useLogoutMutation` (`@global/hooks`), que re-exportan `@library/oidc`: excepción de capas documentada para autenticación (ver `01-layers.md`).
- La semilla no lo monta en el router actual (solo existen `/login` y `/callback`); se incorpora cuando el proyecto agrega rutas autenticadas.

**Interface NavItem** (exportada desde `@global/components`):

```typescript
export interface NavItem {
  path: string;   // ruta exacta para NavLink — ej: '/profile'
  icon: string;   // clase PrimeIcons — ej: 'pi pi-user'
  label: string;  // texto visible en el sidebar — ej: 'Perfil'
}
```

**Props:**

```typescript
interface Props {
  appName: string;          // PROJECT.md → Identidad
  navItems: NavItem[];
  logoSrc?: string;         // ruta en public/ (PROJECT.md → Marca); sin logo si se omite
  topbarActions?: ReactNode;
}
```

**Cómo registrarlo en el router (cuando el proyecto agregue rutas autenticadas):**

```tsx
// src/app/router/app-router.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Q3AppShell, Q5ProtectedRoute, type NavItem } from '@global/components';
import { loginRoutes } from '@modules/login';
import { callbackRoutes } from '@modules/callback';
import { profileRoutes } from '@modules/profile';

const NAV_ITEMS: NavItem[] = [
  { path: '/profile', icon: 'pi pi-user', label: 'Perfil' },
];

export const router = createBrowserRouter([
  ...loginRoutes,
  ...callbackRoutes,
  {
    element: <Q5ProtectedRoute />, // sin sesión → <Navigate to="/login" />
    children: [
      {
        element: <Q3AppShell appName="Mi App" navItems={NAV_ITEMS} logoSrc="/logo.svg" />,
        children: profileRoutes, // se renderizan en el <Outlet> del shell
      },
    ],
  },
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
```

> `Q5ProtectedRoute` es la guarda de sesión: sin sesión OIDC redirige a `/login`. `OidcInitializationGate` solo espera la inicialización y no fuerza login, así que **toda ruta de negocio debe ir como hija de `Q5ProtectedRoute`**. Para restringir por rol dentro de la ruta, usar `<Q5Authorized requiredRole={...} fallback={<Q2Forbidden />}>`.

Ver el código completo en `src/global/components/q3-app-shell/q3-app-shell.tsx` y la guía visual en [12-design-system.md](12-design-system.md).
