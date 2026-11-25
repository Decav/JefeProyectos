# Capas NDK — Arquitectura en 4 Capas

La arquitectura NDK React divide el codigo en 4 capas con dependencias estrictamente unidireccionales:

```
modules  →  library  →  global  →  resources
```

Cada capa solo puede importar de capas situadas a su derecha (capas inferiores).

---

## Capa 1: resources

### Definicion
Capa base del sistema. Define contratos, modelos y tipos puros. Es la fuente de verdad de la forma de los datos. No contiene logica de ningun tipo.

### Ruta en el proyecto
`src/resources/`

### Alias de path
`@resources` → `src/resources/`

### Contenido

| Subcarpeta | Proposito |
|------------|-----------|
| `entities/` | Interfaces de entidades de dominio (p. ej. `User`) |
| `requests/` | Tipos de request HTTP (p. ej. `UpdateProfileRequest`) |
| `responses/` | Tipos de response HTTP (p. ej. `ProfileResponse`) |
| `enums/` | Constantes `as const` y enums (`AppRole` en `permission.enum.ts`) |
| `contracts/` | Contratos con sistemas externos (`OidcUser`, `GroupRoleMapping`, `AUTHENTIK_GROUPS_TO_ROLES` en `oidc.contract.ts`) |
| `utils/` | Funciones puras sin dependencias (`hasPermission` en `has-permission.ts`) |
| `errors/` | Tipos de error personalizados de dominio |
| `schemas/` | Schemas Zod base muy puros (reutilizables entre capas) |
| `types/` | Tipos utilitarios de TypeScript |

En la semilla, `entities/`, `requests/`, `responses/`, `errors/`, `schemas/` y `types/` existen vacías (solo `index.ts`); cada proyecto las llena con sus dominios.

### Reglas de importacion

- **Puede importar de:** nada (cero dependencias externas al proyecto)
- **No puede importar de:** `@global`, `@library`, `@modules`, ni ninguna libreria con efectos de lado
- Solo TypeScript puro y Zod permitidos

### Ejemplo real

```ts
// src/resources/enums/permission.enum.ts (incluido en la semilla; roles de ejemplo)
export const AppRole = {
  ADMIN: 'ADMIN',
  EDITOR: 'EDITOR',
  VIEWER: 'VIEWER',
} as const;
export type AppRole = typeof AppRole[keyof typeof AppRole];

// src/resources/contracts/oidc.contract.ts (incluido en la semilla, extracto)
export interface OidcUser {
  readonly sub: string;
  readonly email: string;
  readonly name: string;
  readonly groups?: string[];
  readonly application?: OidcApplicationClaim;
  // ...email_verified, given_name, family_name
}
export type GroupRoleMapping<TRole extends string> = Record<string, TRole>;
```

### Ejemplo de dominio nuevo (genérico)

```ts
// src/resources/requests/profile.request.ts
export interface UpdateProfileRequest {
  name: string;
  email: string;
}

// src/resources/responses/profile.response.ts
export interface ProfileResponse {
  id: string;
  name: string;
  email: string;
}
```

---

## Capa 2: global

### Definicion
Componentes UI, hooks, utilidades y estado global reutilizables en toda la aplicacion. No conoce la logica de ningun modulo de negocio ni la API.

### Ruta en el proyecto
`src/global/`

### Alias de path
`@global` → `src/global/`

### Contenido

| Subcarpeta | Proposito |
|------------|-----------|
| `components/` | Componentes UI clasificados por nivel atomic (q1-q5) |
| `store/` | Stores Zustand globales (auth, ui) |
| `hooks/` | Hooks utilitarios reutilizables sin logica de dominio |
| `utils/` | Funciones puras utilitarias |
| `validators/` | Validadores reutilizables |
| `constants/` | Constantes globales de la aplicacion |

### Reglas de importacion

- **Puede importar de:** `@resources`
- **No puede importar de:** `@library`, `@modules`
- **Única excepción documentada — sesión OIDC:** `global/hooks/use-auth-status.ts` y `global/hooks/use-logout-mutation.ts` re-exportan `useAuthStatus` y `useLogoutMutation` desde `@library/oidc`. Las guardas y el layout (`Q5ProtectedRoute`, `Q5Authorized`, `Q3AppShell`) necesitan el estado de sesión, y este se concentra en esos dos re-exports para que el resto de `global/` no importe `@library` directamente. No agregar otras importaciones de `@library` en `global/` sin ADR.
- Los componentes en `global/` no deben mencionar dominios de negocio ("autenticacion", "home") en su implementacion

### Ejemplo real

```ts
// src/global/store/auth.store.ts
import { create } from 'zustand';
import type { OidcUser } from '@resources/contracts/oidc.contract';

interface AuthState {
  user: OidcUser | null;
  setUser: (user: OidcUser | null) => void;
}

// Store delgado: los tokens y el estado de sesión los gestiona oidc-spa, no Zustand.
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));
```

Otros contenidos reales de `global/`: `store/ui.store.ts` (`useUiStore`: tema, sidebar, toasts, navegación), `hooks/use-permissions.ts` (`usePermissions`), `utils/get-http-status.ts` (`getHttpStatus`) y los componentes q1–q5 de `components/`.

---

## Capa 3: library

### Definicion
Integracion con servicios externos: API HTTP, repositorios de datos, mocking, observabilidad. No contiene UI. Es el puente entre la aplicacion y el mundo exterior.

### Ruta en el proyecto
`src/library/`

### Alias de path
`@library` → `src/library/`

### Contenido

| Subcarpeta | Proposito |
|------------|-----------|
| `api/client/` | `createApiClient(baseURL)`: factory de instancias Axios (timeout, headers JSON), sin interceptores |
| `api/interceptors/` | `token` (Bearer desde oidc-spa), `refresh-retry` (reintento único en 401) y `error` (logout en 401 final) |
| `api/backend-api.ts` | `backendApi`: instancia del backend propio (`VITE_API_URL`) con los tres interceptores. Único cliente que usan los repositorios |
| `oidc/` | Integración con `oidc-spa`: `bootstrapOidc`, `useOidc`, `getOidc`, `OidcInitializationGate`, `oidcConfig`, `useAuthStatus`, `useLogoutMutation` |
| `query/` | TanStack QueryClient configurado y query keys centralizadas |
| `repositories/` | Llamadas HTTP directas vía `backendApi`, sin lógica de negocio |
| `services/` | Opcional: solo si hay lógica de negocio real (combinar repositorios, aplicar reglas). Un service que solo delega viola YAGNI |
| `mocks/` | MSW: browser.ts, server.ts, y handlers por dominio |
| `integrations/sentry/` | Inicialización y configuración de Sentry |

En la semilla, `repositories/` y `services/` existen vacías (solo `index.ts`).

### Reglas de importacion

- **Puede importar de:** `@global`, `@resources`
- **No puede importar de:** `@modules`
- **No puede contener:** JSX, imports de React, componentes
- **Excepción documentada:** `library/oidc/` re-exporta `OidcInitializationGate` y hooks de `oidc-spa` porque forman parte de la API de la librería; esos archivos no renderizan JSX propio.

### Ejemplo real

```ts
// src/library/api/backend-api.ts
import { createApiClient } from './client/api-instance';
import { registerTokenInterceptor } from './interceptors/token.interceptor';
import { registerRefreshRetryInterceptor } from './interceptors/refresh-retry.interceptor';
import { registerErrorInterceptor } from './interceptors/error.interceptor';

export const backendApi = createApiClient(import.meta.env.VITE_API_URL);
registerTokenInterceptor(backendApi);
registerRefreshRetryInterceptor(backendApi);
registerErrorInterceptor(backendApi);
```

### Ejemplo de repositorio (dominio genérico)

```ts
// src/library/repositories/profile.repository.ts
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

---

## Capa 4: modules

### Definicion
Contiene la logica de negocio, pantallas y rutas organizadas por dominio. Orquesta `library + global + resources` para implementar features completos. Es la capa de composicion final.

### Ruta en el proyecto
`src/modules/`

### Alias de path
`@modules` → `src/modules/`

### Contenido

Cada modulo sigue esta estructura interna fija:

| Subcarpeta | Proposito |
|------------|-----------|
| `components/` | Componentes UI del modulo: q2, q3, q4, q5, pa |
| `core/hooks/` | Hooks especificos del modulo (useQuery, useMutation) |
| `core/schemas/` | Schemas Zod del modulo (fuente de verdad de tipos de formulario) |
| `core/state/` | Stores Zustand locales al modulo (si aplica) |
| `routes/` | Definicion de rutas React Router del modulo |
| `index.ts` | Barrel export del modulo (expone rutas y componentes pa-) |

### Reglas de importacion

- **Puede importar de:** `@library`, `@global`, `@resources`
- **No puede importar de:** otros modulos en `@modules` (modulos son aislados entre si)
- **Solo exporta hacia:** `app/router` (rutas) y `app/providers`

### Módulos reales de la semilla

- `src/modules/login/` — `PaLogin` (`/login`): inicia el flujo OIDC con `oidc.login()`.
- `src/modules/callback/` — `PaCallback` (`/callback`): muestra los claims del usuario y permite cerrar sesión con `useLogoutMutation()`.

### Ejemplo de hook de módulo (dominio genérico)

```ts
// src/modules/profile/core/hooks/use-update-profile-mutation.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ProfileRepository } from '@library/repositories/profile.repository';
import { queryKeys } from '@library/query/query-keys';

export function useUpdateProfileMutation() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ProfileRepository.updateProfile, // sin Service: no hay lógica de negocio
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: queryKeys.profile.detail });
    },
  });
}
```

---

## Resumen de Dependencias

```
resources  ← sin imports de otras capas
global     ← solo @resources
library    ← @global, @resources  (NO @modules)
modules    ← @library, @global, @resources
```

### Prohibiciones absolutas

```
resources → cualquier capa      ❌
global    → @library, @modules  ❌
library   → @modules            ❌
modules   → otros @modules      ❌
```
