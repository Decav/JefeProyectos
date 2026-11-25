# Semilla React Atomic NDK — Mapa General del Proyecto

**Semilla:** `react-atomndk-seed` (nombre de `package.json` de la semilla; cada proyecto lo reemplaza)
**Datos del proyecto:** nombre, cliente, IdP, marca y backend viven en `PROJECT.md` (raíz del repo). Esta documentación describe solo la arquitectura, que no cambia entre proyectos.
**Stack:** React 19.2 · TypeScript 5.9 · Vite 8 · React Router 7 · TanStack Query 5 · Zustand 5 · Axios 1.13 · React Hook Form 7 · Zod 4 · PrimeReact 10 + PrimeIcons 7 · Tailwind 4 · oidc-spa 10 · Sentry 10 · Vitest 4 · Playwright 1.58 · MSW 2 · Storybook 10 (Node ≥ 22, dev server en el puerto 5151)
**Autenticación:** OIDC (Authorization Code + PKCE) con `oidc-spa` contra un proveedor OIDC (por defecto Authentik). No hay login propio con usuario/contraseña.
**Versión:** 0.1.0

---

## 5 Reglas Inviolables NDK

1. **UI no llama APIs directamente.** Toda llamada HTTP pasa por: `component → hook (React Query) → repository → backendApi`. La capa `service` es opcional y solo existe si hay lógica de negocio real. Ningún componente importa axios, `backendApi`, repositorios ni usa `fetch`.
2. **`global` no tiene lógica de negocio.** Los componentes en `global/` son configurables vía props; no conocen dominios de negocio.
3. **`library` no tiene JSX.** Ningún archivo en `library/` renderiza componentes (excepción documentada: `oidc-instance.ts` re-exporta `OidcInitializationGate` de `oidc-spa`).
4. **`resources` es completamente agnóstico.** No importa React, Axios ni ninguna librería. Solo TypeScript puro y Zod.
5. **`modules` orquesta todo.** Es la única capa que puede combinar `library + global + resources` para implementar una feature completa.

---

## Tabla de Archivos de Documentacion

| Archivo | Descripcion |
|---------|-------------|
| [01-layers.md](01-layers.md) | Las 4 capas NDK: definicion, rutas, aliases, reglas de importacion |
| [02-atomic-design.md](02-atomic-design.md) | Los 6 niveles de componentes q1-q5 y pa con reglas de composicion |
| [03-stack.md](03-stack.md) | Tabla completa de tecnologias con versiones, capas y aliases |
| [04-patterns.md](04-patterns.md) | 8 patrones canónicos (+4 complementarios) con snippets |
| [05-conventions.md](05-conventions.md) | Tabla de nomenclatura para cada tipo de archivo |
| [06-data-flows.md](06-data-flows.md) | 4 flujos end-to-end con diagramas ASCII |
| [07-new-module-guide.md](07-new-module-guide.md) | Guia ejecutable de 14 pasos para crear un modulo nuevo |
| [08-testing.md](08-testing.md) | Estrategia de testing con snippets por tipo de test |
| [09-adrs.md](09-adrs.md) | 7 ADRs del proyecto con contexto, decision y consecuencias |
| [10-config.md](10-config.md) | Configuracion tecnica: tsconfig, vite, env vars, scripts npm |
| [11-http-error-handling.md](11-http-error-handling.md) | Skeleton en carga, interceptores 401, componente Q2Forbidden para 403 |
| [12-design-system.md](12-design-system.md) | Estándar de diseño: tokens, tipografía, dark mode, PrimeReact overrides, patrones UI (valores de marca por proyecto) |

---

## Árbol de Directorios `src/`

Refleja la semilla tal como se entrega. Las carpetas marcadas "vacía" solo contienen `index.ts` y se llenan al crear módulos.

```
src/
├── app/                              # Bootstrap — punto de entrada
│   ├── main.tsx                      # Valida REQUIRED_ENV_VARS, importa CSS, initSentry, bootstrapOidc, createRoot
│   ├── providers/
│   │   └── app-providers.tsx         # Sentry.ErrorBoundary > OidcInitializationGate > PrimeReactProvider
│   │                                 #   > QueryClientProvider > Q1GlobalToast + RouterProvider
│   └── router/
│       └── app-router.tsx            # createBrowserRouter: loginRoutes + callbackRoutes, '/' y '*' → /login
│
├── resources/                        # CAPA 1 — contratos puros (sin React, sin HTTP)
│   ├── contracts/
│   │   └── oidc.contract.ts          # OidcUser, OidcApplicationClaim, GroupRoleMapping, AUTHENTIK_GROUPS_TO_ROLES
│   ├── enums/
│   │   ├── auth-status.enum.ts       # AuthStatus (as const) — hoy sin uso en el store
│   │   └── permission.enum.ts        # AppRole { ADMIN, EDITOR, VIEWER } (roles de ejemplo)
│   ├── utils/
│   │   └── has-permission.ts         # hasPermission(groups, requiredRole, mapping)
│   ├── entities/                     # vacía — {nombre}.entity.ts
│   ├── requests/                     # vacía — {dominio}.request.ts
│   ├── responses/                    # vacía — {dominio}.response.ts
│   ├── errors/                       # vacía — tipos de error de dominio
│   ├── schemas/                      # vacía — schemas Zod base compartidos
│   ├── types/                        # vacía — tipos utilitarios
│   └── index.ts                      # Barrel export
│
├── global/                           # CAPA 2 — reutilizable en toda la app
│   ├── components/
│   │   ├── q1-button/                # Átomo: envuelve Button de PrimeReact (variant)
│   │   ├── q1-loading-spinner/       # Átomo: spinner
│   │   ├── q1-global-toast/          # Átomo: Toast global (registra el ref en ui.store)
│   │   ├── q2-badge/                 # Molécula: badge con label/color
│   │   ├── q2-forbidden/             # Molécula: mensaje inline para 403
│   │   ├── q2-error-fallback/        # Molécula: fallback del Sentry.ErrorBoundary
│   │   ├── q3-stat-card/             # Célula: tarjeta de estadística
│   │   ├── q3-app-shell/             # Célula: layout con sidebar + topbar (exporta NavItem)
│   │   ├── q5-protected-route/       # Ecosistema: guarda de sesión (sin sesión → /login)
│   │   ├── q5-authorized/            # Ecosistema: render condicional por rol (requiredRole, fallback)
│   │   └── index.ts
│   ├── store/
│   │   ├── auth.store.ts             # Zustand delgado: { user, setUser } (sin tokens)
│   │   └── ui.store.ts               # Zustand: sidebar, theme (dark mode), toast
│   ├── hooks/
│   │   ├── use-auth-status.ts        # Re-export de @library/oidc
│   │   ├── use-logout-mutation.ts    # Re-export de @library/oidc
│   │   ├── use-permissions.ts        # usePermissions(mapping?) → { roles, hasRole }
│   ├── utils/
│   │   ├── get-http-status.ts        # getHttpStatus(error): number | null
│   ├── validators/                   # vacía — validadores reutilizables
│   ├── constants/                    # vacía — constantes globales
│   └── index.ts                      # Barrel export
│
├── library/                          # CAPA 3 — integración con servicios externos
│   ├── api/
│   │   ├── backend-api.ts            # backendApi: cliente canónico del backend (VITE_API_URL + interceptores)
│   │   ├── client/
│   │   │   └── api-instance.ts       # createApiClient(baseURL): factory axios sin interceptores
│   │   ├── interceptors/
│   │   │   ├── token.interceptor.ts          # Request: Bearer desde oidc.getAccessToken()
│   │   │   ├── refresh-retry.interceptor.ts  # Response: 401 → renewTokens() y un reintento
│   │   │   └── error.interceptor.ts          # Response: 401 final → oidc.logout(); 403 se propaga
│   │   └── index.ts                  # Exporta backendApi, client e interceptores
│   ├── oidc/
│   │   ├── oidc-instance.ts          # useOidc, getOidc, bootstrapOidc, OidcInitializationGate (oidcSpa.createUtils)
│   │   ├── oidc-config.ts            # issuerUri, clientId, publicUrl, scopes
│   │   ├── use-auth-status.ts        # useAuthStatus(): { isAuthenticated, user }
│   │   ├── use-logout-mutation.ts    # queryClient.clear() + oidc.logout()
│   │   └── index.ts
│   ├── query/
│   │   ├── query-client.ts           # QueryClient (retry 1, staleTime 60s, sin refetch on focus)
│   │   └── query-keys.ts             # Registry central de keys (vacío: cada módulo agrega las suyas)
│   ├── repositories/                 # vacía — {dominio}.repository.ts (usan backendApi)
│   ├── services/                     # vacía — OPCIONAL: {dominio}.service.ts solo con lógica de negocio real
│   ├── mocks/
│   │   ├── browser.ts                # worker MSW para navegador (no se arranca por defecto)
│   │   ├── server.ts                 # server MSW para Node (tests)
│   │   └── handlers/
│   │       └── index.ts              # handlers: RequestHandler[] = [] — registrar aquí {dominio}.handlers.ts
│   ├── integrations/
│   │   └── sentry/
│   │       └── sentry.client.ts      # initSentry() (no-op si falta VITE_SENTRY_DSN)
│   └── index.ts                      # Barrel (sub-exports comentados; importar por subpath)
│
├── modules/                          # CAPA 4 — features por dominio
│   ├── login/
│   │   ├── components/
│   │   │   └── pa-login/             # Página: redirige al proveedor OIDC con oidc.login()
│   │   ├── routes/
│   │   │   └── login.routes.tsx      # /login
│   │   └── index.ts
│   ├── callback/
│   │   ├── components/
│   │   │   └── pa-callback/          # Página: claims del usuario + logout
│   │   ├── routes/
│   │   │   └── callback.routes.tsx   # /callback
│   │   └── index.ts
│   └── index.ts
│
├── styles/
│   ├── theme.css                     # Tokens --acl-*, clases .acl-*, overrides PrimeReact, dark mode
│   └── main.css                      # Tailwind entry point
├── test/
│   └── setup.ts                      # Vitest setup: @testing-library/jest-dom
└── vite-env.d.ts                     # Tipado de import.meta.env (VITE_OIDC_*, VITE_API_URL, VITE_SENTRY_DSN)
```

Fuera de `src/`: `e2e/` (tests Playwright), `public/` (assets estáticos), `PROJECT.md` (ficha del proyecto) y `AGENTS.md` (reglas para asistentes).

Un módulo nuevo (ej.: `profile`) sigue la estructura `components/{q2,q4,pa}-*/`, `core/{hooks,schemas,state}/`, `routes/{modulo}.routes.tsx` e `index.ts`. Ver [07-new-module-guide.md](07-new-module-guide.md).
