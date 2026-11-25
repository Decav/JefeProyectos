# Flujos de Datos End-to-End

5 flujos principales con diagramas ASCII y descripción por paso. Los flujos 1, 3 y 4 describen código que ya existe en la semilla; el flujo 2 usa el dominio genérico `profile` como ejemplo de módulo nuevo (ver `SKILL.md` Sección 7).

---

## Flujo 1: Autenticación OIDC (login, vuelta del IdP y logout)

La semilla no tiene login propio (sin usuario/contraseña ni endpoint de login). La autenticación se delega a un proveedor OIDC (por defecto Authentik; el IdP de cada proyecto se define en `PROJECT.md`) mediante `oidc-spa` con Authorization Code + PKCE.

```
[Usuario]
   │  abre /login (o cualquier ruta: '/' y '*' redirigen a /login)
   ▼
[PaLogin]  (modules/login/components/pa-login/pa-login.tsx)
   │  const oidc = useOidc()
   │
   ├─ oidc.isUserLoggedIn === true  →  <Navigate to="/callback" replace />
   │
   └─ oidc.isUserLoggedIn === false →  botón "Ingresar"
         │  onClick: oidc.login({ doesCurrentHrefRequiresAuth: false })
         ▼
[oidc-spa]
   │  genera code_verifier/code_challenge (PKCE) + state
   │  redirige el navegador al authorization endpoint del IdP
   ▼
[Proveedor OIDC (IdP)]
   │  el usuario se autentica en el IdP (fuera de la SPA)
   │  redirige de vuelta a la app con ?code=...&state=...
   ▼
[main.tsx → bootstrapOidc(...)]   (la app se recarga completa)
   │  oidc-spa detecta la respuesta de autorización,
   │  intercambia el code por tokens (token endpoint + code_verifier)
   │  tokens quedan EN MEMORIA (no localStorage / sessionStorage)
   ▼
[OidcInitializationGate]  (app-providers.tsx)
   │  muestra <Skeleton height="100vh" /> hasta que bootstrapOidc termina
   │  luego renderiza PrimeReactProvider > QueryClientProvider > RouterProvider
   ▼
[React Router]
   │  /login → PaLogin → oidc.isUserLoggedIn === true → <Navigate to="/callback" />
   ▼
[PaCallback]  (modules/callback/components/pa-callback/pa-callback.tsx)
   │  const { isAuthenticated, user } = useAuthStatus()
   │  !isAuthenticated || user === null → <Navigate to="/login" replace />
   │  autenticado → muestra claims del ID token (sub, email, name,
   │                application.slug, application.role)
   └─ botón "Cerrar sesión" → useLogoutMutation()
```

**Pasos detallados:**

1. `main.tsx` ya llamó `bootstrapOidc({ implementation: 'real', issuerUri, clientId, scopes })` antes de montar React (ver Flujo 3).
2. `PaLogin` usa `useOidc()` (discriminated union): si ya hay sesión redirige a `/callback`; si no, muestra el botón de ingreso.
3. Al hacer clic, `oidc.login({ doesCurrentHrefRequiresAuth: false })` redirige al IdP. No hay formulario, schema ni mutation de login en la SPA.
4. El IdP autentica y redirige de vuelta a la app. Al recargar, `bootstrapOidc` procesa la respuesta e intercambia el `code` por tokens (PKCE).
5. `OidcInitializationGate` bloquea el render (Skeleton a pantalla completa) hasta que la inicialización termina.
6. `PaLogin` detecta `isUserLoggedIn === true` y navega a `/callback`.
7. `PaCallback` obtiene el usuario con `useAuthStatus()`, que deriva un `OidcUser` desde `oidc.decodedIdToken` con type narrowing explícito.
8. Los tokens nunca pasan por Zustand: `useAuthStore` solo expone `{ user, setUser }`; la sesión y los tokens los gestiona `oidc-spa`.

**Flujo de logout:**

```
[Usuario hace clic en "Cerrar sesión"]  (PaCallback)
   │
   ▼
[useLogoutMutation().mutate()]  (library/oidc/use-logout-mutation.ts)
   │  mutationFn: Promise.resolve()  (no hay endpoint de logout propio)
   ▼
[onSuccess]
   │  1. queryClient.clear()       ← PRIMERO: evita refetch con token inválido
   │  2. const oidc = await getOidc()
   │  3. oidc.isUserLoggedIn → oidc.logout({ redirectTo: 'specific url',
   │                                        url: `${origin}/login` })
   ▼
[Proveedor OIDC]
   │  end-session: cierra la sesión en el IdP
   │  redirige al post-logout redirect URI (/login)
   ▼
[PaLogin]
   └─ oidc.isUserLoggedIn === false → botón "Ingresar"
```

> El post-logout redirect URI (`{origin}/login`) debe estar registrado en el cliente OIDC del IdP.

---

## Flujo 2: Query de Datos (ejemplo genérico `profile`)

Desde que un componente monta hasta que los datos del servidor se renderizan. Cadena canónica: `Component → Hook (React Query) → Repository → backendApi`. La capa Service es opcional y no aparece aquí porque no hay lógica de negocio que la justifique.

```
[Componente del módulo profile]  (p. ej. un q4 que muestra el perfil)
   │  monta el componente
   ▼
[useProfileQuery]  (modules/profile/core/hooks/use-profile-query.ts)
   │  useQuery({ queryKey: queryKeys.profile.detail,
   │             queryFn: ProfileRepository.getProfile, staleTime: 30_000 })
   │  TanStack Query verifica el cache
   │  Si cache fresh (< 30s): retorna data sin llamada HTTP
   │  Si cache stale o vacío: ejecuta queryFn
   ▼
[ProfileRepository.getProfile]  (library/repositories/profile.repository.ts)
   │  backendApi.get<ProfileResponse>('/api/profile').then((r) => r.data)
   ▼
[backendApi]  (library/api/backend-api.ts = createApiClient(VITE_API_URL))
   │  request interceptor: token.interceptor
   │    const oidc = await getOidc()
   │    oidc.isUserLoggedIn → Authorization: Bearer ${await oidc.getAccessToken()}
   │    (getAccessToken renueva el token si está por expirar)
   ▼
[Backend / MSW]
   │  GET {VITE_API_URL}/api/profile
   │  En tests: MSW (server.ts) intercepta con profileHandlers
   │  Retorna ProfileResponse
   ▼
[TanStack Query cache]
   │  Almacena resultado, marca como fresh
   │  Notifica a todos los suscriptores
   ▼
[Componente]
   │  { data, isLoading, error } disponibles
   │  isLoading                     → <Skeleton height="..." />
   │  getHttpStatus(error) === 403  → <Q2Forbidden />
   │  data: ProfileResponse         → render normal
   └─ (un 401 nunca llega aquí como caso a manejar: ver Flujo 5)
```

**Pasos detallados:**

1. El componente llama `useProfileQuery()` (hook del módulo, nunca axios ni `backendApi` directo).
2. TanStack Query busca `queryKeys.profile.detail` en el cache (las keys viven en el registry central `library/query/query-keys.ts`, que la semilla trae vacío).
3. Si es fresh (< `staleTime`), retorna `data` sin llamada HTTP. Si no, ejecuta `queryFn`.
4. `ProfileRepository.getProfile` llama `backendApi.get<ProfileResponse>(...)` con genérico explícito.
5. `token.interceptor` inyecta `Authorization: Bearer ...` obtenido de `oidc-spa`. Si no hay sesión o `getOidc()` falla, la request sale sin header (no se bloquea).
6. La respuesta llega, TanStack Query actualiza el cache y el estado del hook.
7. Mientras `isLoading === true`, se renderiza `<Skeleton>` de PrimeReact. Un 403 se resuelve inline con `<Q2Forbidden />` usando `getHttpStatus(error)` de `@global/utils`.

```tsx
const { data, isLoading, error } = useProfileQuery();

if (isLoading) return <Skeleton height="10rem" />;
if (getHttpStatus(error) === 403) return <Q2Forbidden />;
// render normal con data
```

---

## Flujo 3: Inicialización de la App

Desde que el navegador carga `index.html` hasta que el usuario ve la primera pantalla.

```
[index.html]
   │  <script type="module" src="/src/app/main.tsx">
   ▼
[main.tsx]
   │  1. Valida REQUIRED_ENV_VARS = ['VITE_OIDC_ISSUER_URI',
   │     'VITE_OIDC_CLIENT_ID', 'VITE_OIDC_PUBLIC_URL']
   │     → throw new Error('Variables de entorno faltantes: ...') si falta alguna
   │  2. Importa CSS: tema PrimeReact + primereact.min.css + primeicons
   │     + styles/theme.css + styles/main.css
   │  3. initSentry()
   │  4. bootstrapOidc({ implementation: 'real', issuerUri, clientId, scopes })
   │     ← ANTES de montar React (discovery, chequeo de sesión, vuelta del IdP)
   │  5. document.getElementById('root') → throw si no existe
   ▼
[createRoot(rootElement).render()]
   │  <StrictMode>
   │    <AppProviders />
   │  </StrictMode>
   ▼
[AppProviders]  (app/providers/app-providers.tsx)
   │  <Sentry.ErrorBoundary fallback={<Q2ErrorFallback />}>
   │    <OidcInitializationGate fallback={<Skeleton height="100vh" />}>
   │      <PrimeReactProvider>
   │        <QueryClientProvider client={queryClient}>
   │          <Q1GlobalToast />
   │          <RouterProvider router={router} />
   │        </QueryClientProvider>
   │      </PrimeReactProvider>
   │    </OidcInitializationGate>
   │  </Sentry.ErrorBoundary>
   ▼
[OidcInitializationGate]
   │  espera a que bootstrapOidc complete; mientras tanto, Skeleton 100vh
   ▼
[router]  (app/router/app-router.tsx)
   │  createBrowserRouter([
   │    ...loginRoutes,       // /login    → PaLogin
   │    ...callbackRoutes,    // /callback → PaCallback
   │    { path: '/', element: <Navigate to="/login" replace /> },
   │    { path: '*', element: <Navigate to="/login" replace /> },
   │  ])
   ▼
[React Router]
   │  Evalúa la URL actual
   │  /          → redirect a /login
   │  /login     → PaLogin    (guarda: logueado → /callback)
   │  /callback  → PaCallback (guarda: no logueado → /login)
   │  otra ruta  → redirect a /login
   ▼
[Componente de página]
   └─ Vista visible para el usuario
```

**Notas:**

- `queryClient` (`library/query/query-client.ts`): queries con `retry: 1`, `staleTime: 60_000`, `refetchOnWindowFocus: false`; mutations con `retry: 0`.
- `/login` y `/callback` son rutas top-level, sin `Q3AppShell` ni layout.
- MSW: en tests se usa `library/mocks/server.ts`. En el navegador, `main.tsx` arranca `library/mocks/browser.ts` antes del render **solo** si `import.meta.env.DEV` y `VITE_ENABLE_MOCKS=true` (import dinámico: MSW no entra al bundle de producción; usa `public/mockServiceWorker.js`).

---

## Flujo 4: Guard de Rutas y Permisos

La protección de rutas se compone de cuatro piezas: el gate de inicialización OIDC, la guarda de sesión `Q5ProtectedRoute` para las rutas de negocio, las guardas propias de `PaLogin`/`PaCallback` y el control por rol a nivel de componente.

```
[Usuario navega a cualquier URL]
   │
   ▼
[OidcInitializationGate]  (app-providers.tsx)
   │  nada se renderiza hasta que oidc-spa termina de inicializar
   │  (no redirige al IdP por sí solo: la semilla NO usa auto-login)
   ▼
[React Router]
   │
   ├─ /login → [PaLogin]
   │     useOidc().isUserLoggedIn === true  → <Navigate to="/callback" replace />
   │     isUserLoggedIn === false           → botón que inicia oidc.login()
   │
   ├─ /callback → [PaCallback]
   │     useAuthStatus().isAuthenticated === false → <Navigate to="/login" replace />
   │     autenticado                                → contenido
   │
   ├─ rutas de negocio → [Q5ProtectedRoute]  (hijas en el router)
   │     useAuthStatus().isAuthenticated === false → <Navigate to="/login" replace />
   │     autenticado                                → <Outlet /> (rutas hijas)
   │
   └─ '/' o '*' → <Navigate to="/login" replace />
   ▼
[Dentro de una página autenticada: control por rol]
   │
   ▼
[Q5Authorized requiredRole={AppRole.ADMIN} fallback={...}]
   │  (global/components/q5-authorized/q5-authorized.tsx)
   │  const { hasRole } = usePermissions(mapping)
   ▼
[usePermissions]  (global/hooks/use-permissions.ts)
   │  user = useAuthStatus().user
   │  groups = user?.groups ?? []          ← claim 'groups' del ID token
   │  roles = groups mapeados con AUTHENTIK_GROUPS_TO_ROLES (o mapping propio)
   │  hasRole(role) = hasPermission(groups, role, mapping)
   │
   ├─ hasRole(requiredRole) === true  → children
   └─ hasRole(requiredRole) === false → fallback (null por defecto)
```

**Código real:** `src/global/components/q5-authorized/q5-authorized.tsx`

```tsx
export function Q5Authorized({
  requiredRole,
  children,
  fallback = null,
  mapping,
}: Q5AuthorizedProps) {
  const { hasRole } = usePermissions(mapping);
  return hasRole(requiredRole) ? <>{children}</> : <>{fallback}</>;
}
```

`AppRole` (`resources/enums/permission.enum.ts`) trae roles de ejemplo (`ADMIN`, `EDITOR`, `VIEWER`) y `AUTHENTIK_GROUPS_TO_ROLES` (`resources/contracts/oidc.contract.ts`) el mapeo grupo del IdP → rol. Cada proyecto define sus roles y su mapeo; también puede pasar un `mapping` propio a `usePermissions()` o a `Q5Authorized`.

**Código real:** `src/global/components/q5-protected-route/q5-protected-route.tsx`

```tsx
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

Toda ruta de negocio se registra como hija de `Q5ProtectedRoute` (y, si usa el layout con sidebar, de `Q3AppShell`). La semilla aún no tiene rutas de negocio, por eso el router actual no lo usa.

**Código real del router:** `src/app/router/app-router.tsx`

```tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { loginRoutes } from '@modules/login';
import { callbackRoutes } from '@modules/callback';

export const router = createBrowserRouter([
  ...loginRoutes,
  ...callbackRoutes,
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
```

> Nota: la semilla solo trae `/login` y `/callback`. Cuando un proyecto agregue rutas privadas, debe agruparlas bajo `{ element: <Q5ProtectedRoute />, children: [...] }` y darle a `Q5ProtectedRoute` la lógica de guard (por ejemplo, `useAuthStatus().isAuthenticated === false → <Navigate to="/login" replace />`), o bien replicar la guarda dentro de cada `pa-*`, como hacen hoy `PaLogin` y `PaCallback`.

---

## Flujo 5: Respuesta 401 (refresh-retry → error.interceptor)

Un 401 se resuelve de forma global en los interceptores de `backendApi`; los componentes no lo manejan.

```
[backendApi recibe una respuesta 401]
   ▼
[refresh-retry.interceptor]  (library/api/interceptors/refresh-retry.interceptor.ts)
   │  ¿status !== 401 o sin config?          → rechaza (pasa al siguiente)
   │  ¿config._retry === true?                → rechaza (ya se reintentó)
   │  const oidc = await getOidc()
   │  ¿!oidc.isUserLoggedIn?                  → rechaza
   │  await oidc.renewTokens()   (si falla    → rechaza)
   │  config._retry = true
   │  return backendApi.request(config)
   │     └─ token.interceptor inyecta el NUEVO access token
   │
   ├─ reintento exitoso → la respuesta vuelve al hook como si nada
   │
   └─ rechazo / el reintento vuelve a dar 401
         ▼
[error.interceptor]  (library/api/interceptors/error.interceptor.ts)
   │  status === 401:
   │    const oidc = await getOidc()
   │    oidc.isUserLoggedIn → await oidc.logout({ redirectTo: 'home' })
   │    (solo con sesión activa: evita loops de logout)
   │  status === 403 u otro: no hace nada
   │  return Promise.reject(error)
   ▼
[Hook / componente]
   └─ 403 → getHttpStatus(error) === 403 → <Q2Forbidden /> inline (sin redirect)
```

**Orden de registro** (`library/api/backend-api.ts`): `registerTokenInterceptor` → `registerRefreshRetryInterceptor` → `registerErrorInterceptor`. El refresh-retry debe registrarse antes que el de error para tener la primera oportunidad de recuperarse del 401.

Ver detalle en [11-http-error-handling.md](11-http-error-handling.md).
