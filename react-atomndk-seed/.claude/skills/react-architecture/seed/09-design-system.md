# Seed 09 — Guia Minima: App ACL desde Cero

Guía ejecutable para crear una app desde la semilla con: login OIDC (`oidc-spa`), AppShell con sidebar dark y una página protegida. El nombre real del proyecto y sus valores de marca van en `PROJECT.md`.

> **Estructura fija, valores por proyecto:** la estructura del design system (tokens `--acl-*`, clases `.acl-*`, overrides de PrimeReact, dark mode) no cambia; los valores de marca de la semilla (`#E31D4A`, `#5135A1`, Poppins, logos) son defaults y se reemplazan según `PROJECT.md` (sección Marca).

---

## Objetivo

Con los archivos de esta guia, tenes una app funcional con:
- `/` — redirige a `/login`
- `/login` — `PaLogin`: botón que inicia el flujo OIDC contra el IdP (`oidc.login()`)
- `/callback` — `PaCallback`: muestra los claims del usuario autenticado y permite cerrar sesión
- `/{ruta-del-proyecto}` — página protegida dentro del AppShell (sidebar + topbar)

---

## Estructura minima de archivos

```
src/
├── styles/
│   ├── theme.css              ← de la semilla (estructura fija; valores de marca según PROJECT.md)
│   └── main.css               ← Tailwind entry point
├── app/
│   ├── main.tsx               ← imports en el orden correcto
│   ├── providers/
│   │   └── app-providers.tsx  ← Sentry + OidcInitializationGate + PrimeReactProvider + QueryClient + Router
│   └── router/
│       └── app-router.tsx     ← 4 rutas minimas con AppShell pattern
└── global/
    └── components/
        └── q3-app-shell/
            └── q3-app-shell.tsx  ← incluido en la semilla
```

Todo lo demas es especifico de la aplicacion.

---

## Paso 1 — Instalar dependencias

```bash
npm install \
  react@19.2.4 react-dom@19.2.4 \
  react-router-dom@7.13.1 \
  zustand@5.0.12 \
  @tanstack/react-query@5.91.2 \
  primereact@10.9.7 primeicons@7.0.0 \
  axios@1.13.6 \
  zod@4.3.6 \
  react-hook-form@7.71.2 @hookform/resolvers@5.2.2 \
  oidc-spa@^10.2.1 \
  @sentry/react@10.44.0

npm install -D \
  tailwindcss@4.2.2 @tailwindcss/vite@4.2.2 \
  @vitejs/plugin-react@6.0.1 vite@8.0.1 \
  typescript@5.9.3 \
  @types/react@19.2.14 @types/react-dom@19.2.3
```

---

## Paso 2 — Los 5 archivos de configuracion (copiar tal cual)

### 2.1 `src/styles/theme.css`

**Viene en la semilla.** Este archivo contiene:
- CSS custom properties `--acl-*` para todos los tokens (colores, spacing, radios)
- Variables dark mode bajo `[data-theme="dark"]` y `@media (prefers-color-scheme: dark)`
- Overrides de variables CSS de PrimeReact (`--p-primary-color`, `--p-surface-*`, etc.)
- Clases utility `acl-card`, `acl-badge-*`, `acl-btn-primary`, `acl-kpi-card`, `acl-sidebar-item`, `acl-app-shell`, etc.
- Animaciones `acl-animate-*`

Al personalizar el proyecto, reemplazar los valores de marca (por defecto `#E31D4A`, `#5135A1`, gradiente, Poppins) por los de `PROJECT.md`, en todas sus apariciones dentro de `theme.css` (ver `../architecture/12-design-system.md`, sección 2.1).

### 2.2 `src/styles/main.css`

```css
/* src/styles/main.css */
@layer theme, base, components, utilities, primereact;

@import "tailwindcss/theme" layer(theme);
@import "tailwindcss/utilities";
```

`theme.css` no se importa aquí: lo importa `main.tsx`, después del tema base de PrimeReact.

### 2.3 `src/app/main.tsx`

```tsx
// src/app/main.tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { AppProviders } from './providers/app-providers';

// (antes: validación de REQUIRED_ENV_VARS — ver 08-environments.md)

// ORDEN CRÍTICO — no cambiar
import 'primereact/resources/themes/lara-light-indigo/theme.css'; // tema base
import 'primereact/resources/primereact.min.css';
import 'primeicons/primeicons.css';
import '@/styles/theme.css';   // sobrescribe las variables de PrimeReact con la marca del proyecto
import '@/styles/main.css';

// (después: initSentry() y bootstrapOidc({...}) ANTES de montar — ver 06-auth-integration.md)

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Root element not found');

createRoot(rootElement).render(
  <StrictMode>
    <AppProviders />
  </StrictMode>
);
```

### 2.4 `src/app/providers/app-providers.tsx`

```tsx
// src/app/providers/app-providers.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from 'react-router-dom';
import { PrimeReactProvider } from 'primereact/api';
import * as Sentry from '@sentry/react';
import { Skeleton } from 'primereact/skeleton';
import { queryClient } from '@library/query/query-client';
import { OidcInitializationGate } from '@library/oidc';
import { router } from '../router/app-router';
import { Q1GlobalToast } from '@global/components/q1-global-toast';
import { Q2ErrorFallback } from '@global/components/q2-error-fallback';

export function AppProviders() {
  return (
    <Sentry.ErrorBoundary fallback={<Q2ErrorFallback />}>
      <OidcInitializationGate fallback={<Skeleton height="100vh" />}>
        {/* PrimeReactProvider sin props: los colores vienen de theme.css */}
        <PrimeReactProvider>
          <QueryClientProvider client={queryClient}>
            <Q1GlobalToast />
            <RouterProvider router={router} />
          </QueryClientProvider>
        </PrimeReactProvider>
      </OidcInitializationGate>
    </Sentry.ErrorBoundary>
  );
}
```

No hay provider de tema: el dark mode se controla con `useUiStore((s) => s.theme)` / `setTheme('light' | 'dark' | 'system')`.

### 2.5 `vite.config.ts`

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { oidcSpa } from 'oidc-spa/vite-plugin';
import { resolve } from 'path';

// Versión mínima. La de la semilla además define server.port = 5151 y el proxy /api
// (ver ../architecture/10-config.md).
export default defineConfig({
  plugins: [react(), tailwindcss(), oidcSpa()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@global': resolve(__dirname, './src/global'),
      '@library': resolve(__dirname, './src/library'),
      '@modules': resolve(__dirname, './src/modules'),
      '@resources': resolve(__dirname, './src/resources'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
});
```

---

## Paso 3 — AppShell listo para usar

`Q3AppShell` viene incluido en la semilla (`src/global/components/q3-app-shell/q3-app-shell.tsx`); no hace falta copiarlo. Props: `appName`, `navItems: NavItem[]` y `topbarActions?: ReactNode`. Usa `useAuthStatus()` para el usuario, `useLogoutMutation()` para cerrar sesión y `useUiStore` para el drawer mobile.

Estructura, dependencias y qué personalizar por proyecto (logo, links del topbar, sección de categorías): ver [12-design-system.md, sección 13](../architecture/12-design-system.md#13-appshell-pattern-q3appshell--layout-estándar).

---

## Paso 4 — Router minimo con 4 rutas

```typescript
// src/app/router/app-router.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Q5ProtectedRoute } from '@global/components/q5-protected-route/q5-protected-route';
import { Q3AppShell } from '@global/components/q3-app-shell/q3-app-shell';
import type { NavItem } from '@global/components/q3-app-shell/q3-app-shell';

// Importar rutas de modulos
import { loginRoutes } from '@modules/login';          // /login
import { callbackRoutes } from '@modules/callback';    // /callback
import { dashboardRoutes } from '@modules/dashboard';  // /dashboard (del proyecto derivado)

const NAV_ITEMS: NavItem[] = [
  { path: '/dashboard', icon: 'pi pi-home', label: 'Dashboard' },
  // Agregar items adicionales aqui a medida que se agreguen modulos:
  // { path: '/users', icon: 'pi pi-users', label: 'Usuarios' },
];

export const router = createBrowserRouter([
  // Rutas OIDC publicas
  ...loginRoutes,
  ...callbackRoutes,

  // Rutas protegidas — envueltas en Q5ProtectedRoute + Q3AppShell
  {
    element: <Q5ProtectedRoute />,
    children: [
      {
        element: <Q3AppShell appName="Mi App" navItems={NAV_ITEMS} />,
        children: dashboardRoutes,
      },
    ],
  },

  // Redirects base
  { path: '/', element: <Navigate to="/login" replace /> },
  { path: '*', element: <Navigate to="/login" replace /> },
]);
```

**Estructura de rutas resultante (seed base, sin módulos del proyecto):**

| Ruta | Componente | Protegida |
|------|-----------|-----------|
| `/` | Redirect a `/login` | — |
| `/login` | `PaLogin` | No — inicia flujo OIDC |
| `/callback` | `PaCallback` | No — recibe token |
| `/dashboard` | `PaDashboard` del proyecto derivado (ejemplo) | Sí — dentro de `Q5ProtectedRoute` (guarda de sesión: sin sesión redirige a `/login`) |

---

## Paso 5 — Agregar un nuevo modulo

Para cada nueva feature, solo se necesitan 3 archivos:

### 5.1 Las rutas del modulo

```typescript
// src/modules/mi-modulo/routes/mi-modulo.routes.tsx
import { PaMiPagina } from '../components/pa-mi-pagina/pa-mi-pagina';

export const miModuloRoutes = [
  { path: '/mi-ruta', element: <PaMiPagina /> },
];
```

### 5.2 La pagina del modulo

```tsx
// src/modules/mi-modulo/components/pa-mi-pagina/pa-mi-pagina.tsx
export function PaMiPagina() {
  return (
    <div className="flex flex-col gap-6 acl-animate-slide-up">
      <div className="acl-page-header">
        <h1 className="acl-page-header__title">Mi Pagina</h1>
        <p className="acl-page-header__subtitle">Descripcion de la pagina</p>
      </div>
      {/* Contenido */}
    </div>
  );
}
```

### 5.3 El barrel del modulo

```typescript
// src/modules/mi-modulo/index.ts
export { miModuloRoutes } from './routes/mi-modulo.routes';
```

### 5.4 Registrar en el router

```typescript
// En app-router.tsx, agregar las rutas dentro del children del Q3AppShell:
import { miModuloRoutes } from '@modules/mi-modulo';

const NAV_ITEMS: NavItem[] = [
  { path: '/dashboard', icon: 'pi pi-home', label: 'Dashboard' },
  { path: '/mi-ruta',   icon: 'pi pi-star', label: 'Mi Modulo' },  // nuevo
];

// En el children del AppShell:
children: [
  ...dashboardRoutes,
  ...miModuloRoutes,  // nuevo
],
```

---

## Checklist — De git clone a app funcional (10 pasos)

- [ ] **1. Clonar** el seed: `git clone <repo> mi-app && cd mi-app`
- [ ] **2. Instalar**: `npm install`
- [ ] **3. Variables de entorno**: `cp .env.example .env.local` y editar `VITE_OIDC_ISSUER_URI`, `VITE_OIDC_CLIENT_ID`, `VITE_OIDC_PUBLIC_URL` y `VITE_API_URL` (valores de `PROJECT.md`)
- [ ] **4. Verificar** que `src/styles/theme.css` existe (variables `--acl-*`) y tiene los valores de marca de `PROJECT.md`
- [ ] **5. Verificar** que `src/app/main.tsx` importa en el orden correcto: `lara-light-indigo/theme.css` → `primereact.min.css` → `primeicons.css` → `theme.css` → `main.css`
- [ ] **6. Verificar** que `AppProviders` NO pasa props al `PrimeReactProvider`
- [ ] **7. Personalizar** `appName` en `Q3AppShell` dentro de `app-router.tsx`
- [ ] **8. Ejecutar** `npm run dev` — debería ver la página de login (`PaLogin`) en `http://localhost:5151`
- [ ] **9. Verificar dark mode**: `useUiStore.getState().setTheme('dark')` (o `document.documentElement.setAttribute('data-theme', 'dark')` en consola)
- [ ] **10. Verificar AppShell**: loguear y confirmar sidebar dark (280px) + topbar + Outlet

---

## Referencia Completa

- [12-design-system.md](../architecture/12-design-system.md) — tokens completos, dark mode, clases `acl-*`
- [12-design-system.md#13](../architecture/12-design-system.md#13-appshell-pattern-q3appshell--layout-estándar) — AppShell pattern completo
- [12-design-system.md#14](../architecture/12-design-system.md#14-primereact-setup--tema-base--overrides-acl) — PrimeReact setup: tema base + overrides
- [04-patterns.md](../architecture/04-patterns.md#12-appshell-pattern--layout-estándar) — Patron AppShell en patrones canonicos
- [07-new-module-guide.md](../architecture/07-new-module-guide.md) — Guia de 14 pasos para un modulo completo con API
