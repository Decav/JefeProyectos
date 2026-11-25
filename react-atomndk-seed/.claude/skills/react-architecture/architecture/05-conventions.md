# Convenciones de Nomenclatura

Reglas de nombrado para todos los tipos de archivo del proyecto. La nomenclatura es consistente, predecible y auditable.

Los ejemplos usan archivos que ya existen en la semilla o, para módulos nuevos, el dominio genérico `profile` (el mismo de `SKILL.md` y `04-patterns.md`).

---

## Tabla Completa de Nomenclatura

| Tipo de Archivo | Patrón de Nombre | Ejemplo | Dónde Vive | Export Esperado |
|----------------|-----------------|--------------|------------|-----------------|
| Componente q1 | `q1-{nombre}.tsx` | `q1-button.tsx` | `src/global/components/q1-{nombre}/` | `export function Q1Button` |
| Componente q2 | `q2-{nombre}.tsx` | `q2-badge.tsx` | `src/global/components/q2-{nombre}/` o `src/modules/{mod}/components/q2-{nombre}/` | `export function Q2Badge` |
| Componente q3 | `q3-{nombre}.tsx` | `q3-stat-card.tsx` | `src/global/components/q3-{nombre}/` | `export function Q3StatCard` |
| Componente q4 | `q4-{nombre}.tsx` | `q4-profile-form.tsx` | `src/modules/{modulo}/components/q4-{nombre}/` | `export function Q4ProfileForm` |
| Componente q5 | `q5-{nombre}.tsx` | `q5-protected-route.tsx` | `src/global/components/q5-{nombre}/` | `export function Q5ProtectedRoute` |
| Página (pa) | `pa-{nombre}.tsx` | `pa-login.tsx` | `src/modules/{modulo}/components/pa-{nombre}/` | `export function PaLogin` |
| Carpeta componente | `{nivel}-{nombre}/` | `q1-button/` | Misma ubicación que el archivo | — |
| Hook (query) | `use-{nombre}-query.ts` | `use-profile-query.ts` | `src/modules/{modulo}/core/hooks/` | `export function useProfileQuery` |
| Hook (mutation) | `use-{nombre}-mutation.ts` | `use-update-profile-mutation.ts` | `src/modules/{modulo}/core/hooks/` | `export function useUpdateProfileMutation` |
| Hook (genérico) | `use-{nombre}.ts` | `use-permissions.ts` | `src/global/hooks/` | `export function usePermissions` |
| Repository | `{dominio}.repository.ts` | `profile.repository.ts` | `src/library/repositories/` | `export const ProfileRepository` |
| Service (opcional, solo con lógica de negocio real) | `{dominio}.service.ts` | `profile.service.ts` | `src/library/services/` | `export const ProfileService` |
| Query keys | `query-keys.ts` (registry único) | `queryKeys.profile.detail` | `src/library/query/` | `export const queryKeys` |
| Store Zustand | `{dominio}.store.ts` | `auth.store.ts`, `ui.store.ts` | `src/global/store/` o `src/modules/{mod}/core/state/` | `export const useAuthStore` |
| Schema Zod | `{nombre}.schema.ts` | `profile.schema.ts` | `src/modules/{modulo}/core/schemas/` | `export const profileSchema`, `export type ProfileFormValues` |
| Entidad | `{nombre}.entity.ts` | `profile.entity.ts` | `src/resources/entities/` | `export interface Profile` |
| Contrato externo | `{nombre}.contract.ts` | `oidc.contract.ts` | `src/resources/contracts/` | `export interface OidcUser` |
| Request type | `{dominio}.request.ts` | `profile.request.ts` | `src/resources/requests/` | `export interface UpdateProfileRequest` |
| Response type | `{dominio}.response.ts` | `profile.response.ts` | `src/resources/responses/` | `export interface ProfileResponse` |
| Enum (`as const`) | `{nombre}.enum.ts` | `permission.enum.ts` | `src/resources/enums/` | `export const AppRole = {...} as const` + `export type AppRole` |
| Utilidad pura | `{nombre}.ts` | `get-http-status.ts` | `src/global/utils/` o `src/resources/utils/` | `export function getHttpStatus` |
| Handler MSW | `{dominio}.handlers.ts` | `profile.handlers.ts` | `src/library/mocks/handlers/` | `export const profileHandlers` |
| Rutas de módulo | `{modulo}.routes.tsx` | `login.routes.tsx` | `src/modules/{modulo}/routes/` | `export const loginRoutes` |
| Barrel index | `index.ts` | `index.ts` | En cada carpeta pública | Re-exports de los archivos del directorio |
| Test componente | `{nombre}.test.tsx` | `q1-button.test.tsx` | Junto al componente | — |
| Test lógica | `{nombre}.test.ts` | `use-permissions.test.ts` | Junto al archivo testeado | — |
| Test e2e | `{flujo}.spec.ts` | `auth.spec.ts` | `e2e/` | — |
| Storybook | `{nombre}.stories.tsx` | `q1-button.stories.tsx` | Junto al componente | `export default { ... }` |

---

## Regla de Exports Nombrados

**No se usan default exports en componentes, hooks, stores ni servicios.**

Razón: los exports nombrados son refactorizables automáticamente por TypeScript, son más fáciles de importar (el IDE autocompleta) y evitan inconsistencias de nombrado al importar.

```ts
// CORRECTO
export function Q1Button() { ... }
export const ProfileRepository = { ... };
export const useAuthStore = create<AuthState>(...);

// INCORRECTO
export default function Button() { ... }
export default ProfileRepository;
```

Excepción: los archivos de configuración (vite.config.ts, playwright.config.ts, storybook meta) usan `export default` porque sus herramientas lo requieren.

---

## Convención de Barrel index.ts

Cada carpeta "pública" tiene un `index.ts` que re-exporta sus elementos:

```ts
// src/global/components/q1-button/index.ts
export { Q1Button } from './q1-button';

// src/modules/login/index.ts (real)
export { loginRoutes } from './routes/login.routes';

// src/modules/index.ts (real)
export * from './login';
export * from './callback';
```

**Regla:** el barrel index de un módulo solo exporta lo que el resto de la app necesita ver: sus rutas (y, si otra capa lo requiere, sus componentes pa-). Los internos (q4, hooks, schemas) no se exponen en el barrel raíz del módulo.

---

## Convención de Nombres de Funciones/Clases

El nombre del export nombrado es la versión PascalCase (componentes, objetos) o camelCase (hooks, funciones, schemas) del nombre del archivo:

| Archivo | Export |
|---------|--------|
| `q1-button.tsx` | `Q1Button` |
| `q2-badge.tsx` | `Q2Badge` |
| `q3-stat-card.tsx` | `Q3StatCard` |
| `q4-profile-form.tsx` | `Q4ProfileForm` |
| `q5-protected-route.tsx` | `Q5ProtectedRoute` |
| `pa-login.tsx` | `PaLogin` |
| `pa-callback.tsx` | `PaCallback` |
| `profile.repository.ts` | `ProfileRepository` |
| `profile.service.ts` (opcional) | `ProfileService` |
| `auth.store.ts` | `useAuthStore` |
| `ui.store.ts` | `useUiStore` |
| `use-update-profile-mutation.ts` | `useUpdateProfileMutation` |
| `use-profile-query.ts` | `useProfileQuery` |
| `use-logout-mutation.ts` | `useLogoutMutation` |
| `profile.schema.ts` | `profileSchema` + `ProfileFormValues` |
| `profile.handlers.ts` | `profileHandlers` |
| `login.routes.tsx` | `loginRoutes` |

---

## Casing en Rutas de Archivo

- Archivos: `kebab-case` siempre (`q1-loading-spinner.tsx`, `auth-status.enum.ts`)
- Carpetas: `kebab-case` siempre (`q1-loading-spinner/`, `q5-protected-route/`)
- Variables y funciones: `camelCase` o `PascalCase` según sea componente/objeto o función/variable
- Constantes de objeto: `PascalCase` (ej.: `ProfileRepository`, `AppRole`)
- Hooks: `camelCase` con prefijo `use` (ej.: `useUpdateProfileMutation`)
