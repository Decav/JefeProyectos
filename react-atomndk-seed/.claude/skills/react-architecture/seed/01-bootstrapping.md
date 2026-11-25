# 01 — Bootstrapping: De cero a `npm run dev`

## Prerequisitos

| Herramienta | Versión mínima | Verificar |
|-------------|---------------|-----------|
| Node.js | 22.x | `node --version` |
| npm | 10.x | `npm --version` |

---

## Paso 1: Crear el proyecto con Vite

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
```

Esto genera la estructura base con React + TypeScript usando Vite.

---

## Paso 2: Instalar dependencias de producción

Instala las dependencias con versiones exactas para garantizar reproducibilidad:

```bash
npm install \
  react@19.2.4 \
  react-dom@19.2.4 \
  react-router-dom@7.13.1 \
  zustand@5.0.12 \
  @tanstack/react-query@5.91.2 \
  primereact@10.9.7 \
  primeicons@7.0.0 \
  axios@1.13.6 \
  zod@4.3.6 \
  react-hook-form@7.71.2 \
  @hookform/resolvers@5.2.2 \
  @sentry/react@10.44.0 \
  oidc-spa@^10.2.1
```

---

## Paso 3: Instalar dependencias de desarrollo

```bash
npm install -D \
  typescript@5.9.3 \
  vite@8.0.1 \
  @vitejs/plugin-react@6.0.1 \
  vitest@4.1.0 \
  @vitest/coverage-v8 \
  @testing-library/react@16.3.2 \
  @testing-library/jest-dom@6.9.1 \
  @testing-library/user-event@14.6.1 \
  jsdom@29.0.0 \
  msw@2.12.13 \
  @playwright/test@1.58.2 \
  storybook@10.3.0 \
  @storybook/react-vite@10.3.0 \
  tailwindcss@4.2.2 \
  @tailwindcss/vite@4.2.2 \
  @types/react@19.2.14 \
  @types/react-dom@19.2.3
```

---

## Paso 4: Configurar `vite.config.ts`

Reemplaza el contenido de `vite.config.ts` con lo siguiente (versión mínima; la configuración completa de la semilla, con el plugin `oidcSpa()`, el puerto 5151 y el proxy `/api`, está en `../architecture/10-config.md`):

```typescript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@global': resolve(__dirname, 'src/global'),
      '@library': resolve(__dirname, 'src/library'),
      '@modules': resolve(__dirname, 'src/modules'),
      '@resources': resolve(__dirname, 'src/resources'),
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      thresholds: {
        lines: 90,
        functions: 90,
        branches: 90,
        statements: 90,
      },
    },
  },
});
```

---

## Paso 5: Configurar `tsconfig.app.json`

Agrega los `paths` correspondientes a los aliases de Vite:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@global/*": ["src/global/*"],
      "@library/*": ["src/library/*"],
      "@modules/*": ["src/modules/*"],
      "@resources/*": ["src/resources/*"]
    }
  },
  "include": ["src"]
}
```

---

## Paso 5b: Configurar estilos — Design System ACL

### Copiar theme.css de la semilla

El archivo `src/styles/theme.css` de la semilla es el corazón del design system. Copiarlo al nuevo proyecto:

```bash
cp <ruta-a-la-semilla>/src/styles/theme.css src/styles/theme.css
```

La estructura de `theme.css` (tokens `--acl-*`, clases `.acl-*`, overrides de PrimeReact, dark mode) es fija; los valores de marca (por defecto `#E31D4A`, `#5135A1`, Poppins) se reemplazan con los de `PROJECT.md` (sección Marca).

Este archivo (~600 lineas) contiene:
- Variables CSS `--acl-*` para todos los tokens (colores, spacing, radios, sombras)
- Overrides de PrimeReact (`--p-primary-color`, `--p-surface-*`, `--p-text-color`)
- Dark mode bajo `[data-theme="dark"]` y `@media (prefers-color-scheme: dark)`
- Clases utility `acl-card`, `acl-btn-*`, `acl-badge-*`, `acl-kpi-card`, `acl-sidebar-item`, etc.

### Crear main.css (entry point de Tailwind)

```css
/* src/styles/main.css (extracto; ver el archivo completo) */
@layer primereact, theme, base, components, utilities;

@import "tailwindcss/theme" layer(theme);
@import "tailwindcss/utilities";

@layer base {
  /* reset mínimo de <button>, <ol>/<ul>, <dl>/<dd> nativos, excluyendo PrimeReact */
}
```

> **Orden real de capas:** PrimeReact se importa en `main.tsx` antes que `main.css` y define su capa primero, así que `primereact` queda con la **menor** prioridad (una capa ya definida no se puede reordenar). La declaración solo documenta ese orden. Consecuencias: las utilidades de Tailwind pueden ajustar componentes PrimeReact y `theme.css` (sin capa) sobrescribe a todos.
>
> **Sin preflight de Tailwind:** la semilla no lo importa para no alterar PrimeReact. Por eso `main.css` incluye un reset mínimo en `@layer base` para `<button>`, `<ol>`/`<ul>` y `<dl>`/`<dd>` nativos, que excluye los elementos de PrimeReact (`.p-component`, `.p-link`, clases `p-*`). Sin ese reset, los botones nativos usados como enlaces se ven con el borde y el fondo del navegador.

`theme.css` no se importa desde `main.css`: lo importa `main.tsx` (ver abajo).

### Configurar main.tsx con el orden correcto de imports

```tsx
// src/app/main.tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { AppProviders } from './providers/app-providers';

// (antes: validación de REQUIRED_ENV_VARS — ver 08-environments.md)

// ORDEN CRÍTICO — no reordenar
import 'primereact/resources/themes/lara-light-indigo/theme.css'; // tema base de PrimeReact
import 'primereact/resources/primereact.min.css';                 // estilos estructurales
import 'primeicons/primeicons.css';                                // íconos PrimeIcons
import '@/styles/theme.css';                                       // tokens --acl-* + overrides PrimeReact
import '@/styles/main.css';                                        // Tailwind utilities

// theme.css va DESPUÉS del tema base para que sus overrides (colores de marca del
// proyecto, dark mode) ganen. No importar otro tema de PrimeReact sin ADR.

// (después: initSentry() y bootstrapOidc({...}) ANTES de montar — ver 06-auth-integration.md)

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Root element not found');

createRoot(rootElement).render(
  <StrictMode>
    <AppProviders />
  </StrictMode>
);
```

### Configurar AppProviders

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
        {/* Sin props — los colores vienen de theme.css */}
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

---

## Paso 6: Crear estructura de carpetas

```bash
mkdir -p src/app
mkdir -p src/global/components
mkdir -p src/global/hooks
mkdir -p src/global/store
mkdir -p src/library/api
mkdir -p src/library/oidc
mkdir -p src/library/query
mkdir -p src/library/repositories
mkdir -p src/library/services   # opcional: solo para lógica de negocio real
mkdir -p src/library/mocks/handlers
mkdir -p src/modules
mkdir -p src/resources/entities
mkdir -p src/resources/schemas
mkdir -p src/resources/types
mkdir -p src/test
```

---

## Paso 7: Archivo de setup para tests

Crea `src/test/setup.ts`:

```typescript
import '@testing-library/jest-dom';
```

En la semilla el setup global solo carga `jest-dom`. El server MSW (`@library/mocks/server`) se levanta en cada archivo de test de integración que lo necesite (`beforeAll(() => server.listen())`, `afterEach(() => server.resetHandlers())`, `afterAll(() => server.close())`).

---

## Paso 8: Configurar MSW

```bash
npx msw init public/
```

Agrega al `package.json`:

```json
{
  "msw": {
    "workerDirectory": ["public"]
  }
}
```

---

## Paso 9: Crear `.env.example`

Crea `.env.example` en la raíz del proyecto:

```bash
# OIDC (requeridas — validadas en main.tsx)
VITE_OIDC_ISSUER_URI=https://<idp>/application/o/<app>/
VITE_OIDC_CLIENT_ID=<client-id>
VITE_OIDC_PUBLIC_URL=http://localhost:5151

# Backend (usada por backendApi)
VITE_API_URL=http://localhost:3000

# Sentry (opcional)
VITE_SENTRY_DSN=
```

Los valores reales del proyecto se registran en `PROJECT.md`.

Copia el archivo:

```bash
cp .env.example .env.local
```

---

## Paso 10: Verificar arranque

```bash
npm run dev
```

Deberías ver:

```
  VITE v8.x.x  ready in XXX ms

  ➜  Local:   http://localhost:5151/
  ➜  Network: use --host to expose
```

---

## Scripts disponibles

| Comando | Descripción |
|---------|-------------|
| `npm run dev` | Servidor de desarrollo con HMR |
| `npm run build` | Build de producción |
| `npm run preview` | Preview del build de producción |
| `npm run lint` | ESLint sobre `src/` |
| `npm run test` | Tests unitarios con Vitest (watch mode) |
| `npm run test:coverage` | Tests con reporte de cobertura |
| `npm run test:e2e` | Tests e2e con Playwright |
| `npm run storybook` | Storybook en puerto 6006 |
