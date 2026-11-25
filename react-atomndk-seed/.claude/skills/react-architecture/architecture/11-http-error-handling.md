# Manejo de Estados de Carga y Errores HTTP

Tres reglas obligatorias para el tratamiento de loading states y errores HTTP en componentes que consumen APIs.

---

## Regla 1: Skeleton en Estados de Carga

**Aplica a:** Todo componente que ejecute una query o mutation a una API.

**Reglas:**
- Mientras `isLoading === true`, el componente DEBE renderizar `<Skeleton>` de PrimeReact.
- El `<Skeleton>` debe tener dimensiones aproximadas al contenido que reemplaza (evitar layout shift).
- NUNCA mostrar un componente vacio ni un spinner custom en lugar del contenido — usar `<Skeleton>` de PrimeReact siempre.
- Para listas o grids, renderizar multiples instancias de `<Skeleton>` que emulen el numero esperado de items.

**Ejemplo:**

```tsx
import { Skeleton } from 'primereact/skeleton';

export function Q4ItemList() {
  const { data: items, isLoading } = useItemsQuery();

  if (isLoading) {
    return (
      <div className="flex flex-col gap-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <Skeleton key={i} height="3rem" borderRadius="8px" />
        ))}
      </div>
    );
  }

  return (
    <ul>
      {items?.map((item) => <li key={item.id}>{item.name}</li>)}
    </ul>
  );
}
```

**Para cards o bloques de contenido:**

```tsx
if (isLoading) {
  return <Skeleton width="100%" height="12rem" borderRadius="12px" />;
}
```

---

## Regla 2: Error 401 → Manejo Global via Interceptores

**Aplica a:** `backendApi` (`src/library/api/backend-api.ts`), el único cliente HTTP que usan los repositorios. Tiene registrados, en este orden, `token.interceptor` (request), `refresh-retry.interceptor` (response) y `error.interceptor` (response).

**Reglas:**
- Primero actúa `refresh-retry.interceptor.ts`: ante un 401, si el usuario está logueado, llama a `oidc.renewTokens()` (si falla, propaga el error) y reintenta la request **una sola vez** (marca `_retry` en la config para evitar bucles). El reintento vuelve a pasar por `token.interceptor`, que inyecta el nuevo access token.
- Si no hay refresh token, la renovación falla o el reintento vuelve a dar 401, el error llega a `error.interceptor.ts`, que ejecuta `oidc.logout({ redirectTo: 'home' })` **solo si** `oidc.isUserLoggedIn` (evita loops de logout cuando ya no hay sesión). El usuario vuelve al proveedor OIDC (por defecto Authentik).
- El interceptor siempre propaga el error (`Promise.reject(error)`); no muestra toasts ni navega con React Router.
- Esta lógica NO debe duplicarse en componentes individuales ni en hooks de dominio.
- Los componentes no necesitan manejar el caso 401 — los interceptores lo resuelven antes.

**Código real:** `src/library/api/interceptors/refresh-retry.interceptor.ts` (resumen)

```ts
type RetryableConfig = InternalAxiosRequestConfig & { _retry?: boolean };

export function registerRefreshRetryInterceptor(instance: AxiosInstance): void {
  instance.interceptors.response.use(
    (response) => response,
    async (error: AxiosError) => {
      if (error.response?.status !== 401 || !error.config) return Promise.reject(error);
      const config = error.config as RetryableConfig;
      if (config._retry) return Promise.reject(error);

      // getOidc() → si no está logueado o no hay refresh token → propaga el 401
      // si hay refresh token → await oidc.renewTokens()
      config._retry = true;
      return instance.request(config);
    },
  );
}
```

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

**Registro de los interceptores** (solo en `backendApi`; `createApiClient` es una factory sin interceptores):

```ts
// src/library/api/backend-api.ts
export const backendApi = createApiClient(import.meta.env.VITE_API_URL);
registerTokenInterceptor(backendApi);        // 1. request: Authorization: Bearer <access token>
registerRefreshRetryInterceptor(backendApi); // 2. response: 401 → renewTokens + 1 reintento
registerErrorInterceptor(backendApi);        // 3. response: 401 final → oidc.logout()
```

`refresh-retry` DEBE registrarse antes que `error` para tener la primera oportunidad de recuperarse del 401.

**Anti-patrón — NO hacer esto en componentes:**

```tsx
// MAL: duplica la lógica de los interceptores
const { error } = useItemsQuery();
if (getHttpStatus(error) === 401) {
  navigate('/login'); // NO — los interceptores ya lo manejan
}
```

---

## Regla 3: Error 403 → Componente Q2Forbidden (nivel componente, no pantalla)

**Aplica a:** Todo componente o página que pueda recibir un 403 de su endpoint.

**Reglas:**
- Un 403 NO redirige ni bloquea la pantalla completa — el usuario sigue autenticado pero sin permiso para ese recurso específico. Los interceptores lo propagan sin tocarlo.
- Cada componente que puede recibir 403 usa `getHttpStatus(error)` (`@global/utils`) y compara con `403`.
- Cuando el status es `403`, el componente renderiza `<Q2Forbidden />` inline en lugar de su contenido normal.
- `Q2Forbidden` es una molécula (q2) ubicada en `src/global/components/q2-forbidden/`.
- NUNCA usar `navigate('/forbidden')` ni mostrar una página de error completa por un 403.

**Utilidad:** `getHttpStatus` — `src/global/utils/get-http-status.ts`. Es una función pura (no un hook), retorna el status o `null` si el error no es de Axios o no tiene respuesta.

```ts
import { isAxiosError } from 'axios';

export function getHttpStatus(error: unknown): number | null {
  if (!isAxiosError(error)) return null;
  return error.response?.status ?? null;
}
```

> `getHttpStatus` retorna `number | null` (no un objeto). Es una función pura, no un hook: puede usarse en cualquier parte del render.

**Componente:** `Q2Forbidden` — `src/global/components/q2-forbidden/q2-forbidden.tsx`. Muestra un ícono `pi-lock`, el mensaje "No tienes permisos para ver este contenido." y un botón "Volver" (`navigate(-1)`). No recibe props. Importar desde el barrel: `import { Q2Forbidden } from '@global/components';`.

**Patrón de uso en un organismo (q4):**

```tsx
import { Skeleton } from 'primereact/skeleton';
import { Q2Forbidden } from '@global/components';
import { getHttpStatus } from '@global/utils';
import { useItemsQuery } from '../../core/hooks/use-items-query';

export function Q4ItemList() {
  const { data, isLoading, error } = useItemsQuery();

  if (isLoading) return <Skeleton width="100%" height="20rem" />;
  if (getHttpStatus(error) === 403) return <Q2Forbidden />;

  return (
    <ul>
      {data?.map((item) => <li key={item.id}>{item.name}</li>)}
    </ul>
  );
}
```

**Patrón completo con los tres estados (loading, 403, render normal):**

```tsx
const { data, isLoading, error } = useAlgunaQuery();

if (isLoading) return <Skeleton height="10rem" />;
if (getHttpStatus(error) === 403) return <Q2Forbidden />;
// render normal con data
```

---

## Resumen de Responsabilidades por Capa

| Error HTTP | Quién lo maneja | Acción |
|------------|-----------------|--------|
| (request) | `token.interceptor.ts` (library) | Si hay sesión, agrega `Authorization: Bearer ${await oidc.getAccessToken()}`; si falla, no bloquea la request |
| 401 (primer intento) | `refresh-retry.interceptor.ts` (library) | Si hay sesión y refresh token: `oidc.renewTokens()` + 1 reintento (`_retry`) |
| 401 (final) | `error.interceptor.ts` (library) | `oidc.logout({ redirectTo: 'home' })` solo si `oidc.isUserLoggedIn`; propaga el error |
| 403 | Componente consumidor (modules/global) | `getHttpStatus(error) === 403` → `<Q2Forbidden />` inline |
| 4xx/5xx otros | Componente consumidor | Mostrar mensaje de error según contexto (p. ej. `useUiStore.getState().showError(...)` o mensaje inline) |

**Regla invariante:** El manejo de 401 vive exclusivamente en `src/library/api/interceptors/`. Los componentes en `src/modules/` o `src/global/` jamás replican esa lógica.
