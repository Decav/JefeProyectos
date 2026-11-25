# Configuracion Tecnica del Proyecto

Toda la configuracion critica del proyecto en un solo lugar.

---

## TypeScript — tsconfig.json / tsconfig.app.json

`tsconfig.json` no compila nada por sí mismo: solo referencia a `tsconfig.app.json` (`"files": []`, `"references": [{ "path": "./tsconfig.app.json" }]`). No existe `tsconfig.node.json`.

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": true,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "types": ["vite/client", "vitest/globals"],
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
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
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

### Opciones Clave

| Opcion | Valor | Razon |
|--------|-------|-------|
| `strict` | `true` | Habilita todas las verificaciones estrictas de TypeScript |
| `noUnusedLocals` | `true` | Falla si hay variables locales no usadas |
| `noUnusedParameters` | `true` | Falla si hay parametros de funcion no usados |
| `noUncheckedIndexedAccess` | `true` | `arr[i]` y `obj[key]` se tipan como `T \| undefined`; obliga a hacer guard |
| `exactOptionalPropertyTypes` | `true` | Una prop opcional `x?: string` no acepta `undefined` explícito |
| `noImplicitReturns` | `true` | Todas las ramas de una función deben retornar |
| `moduleResolution` | `"bundler"` | Compatible con Vite y sus reglas de resolucion |
| `types` | `["vite/client", "vitest/globals"]` | `vite/client` para `import.meta.env`; `vitest/globals` para `describe`, `it`, `expect` sin imports |
| `noEmit` | `true` | TypeScript solo verifica tipos; Vite hace el build |

Las variables `import.meta.env.VITE_*` se tipan en `src/vite-env.d.ts` (ver sección Variables de Entorno).

---

## Vite — vite.config.ts

```ts
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { oidcSpa } from 'oidc-spa/vite-plugin';
import path from 'node:path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  const apiProxyTarget = env.VITE_API_URL;

  return {
    plugins: [react(), tailwindcss(), oidcSpa()],
    optimizeDeps: {
      include: ['@sentry/react', '@sentry/core', '@sentry/browser'],
    },
    server: {
      port: 5151,
      // Proxy /api → VITE_API_URL en dev (solo si la variable está definida)
      ...(apiProxyTarget
        ? {
            proxy: {
              '/api': {
                target: apiProxyTarget,
                changeOrigin: true,
                secure: true,
                cookieDomainRewrite: 'localhost',
              },
            },
          }
        : {}),
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@global': path.resolve(__dirname, './src/global'),
        '@library': path.resolve(__dirname, './src/library'),
        '@modules': path.resolve(__dirname, './src/modules'),
        '@resources': path.resolve(__dirname, './src/resources'),
      },
    },
    test: {
      globals: true,
      environment: 'jsdom',
      passWithNoTests: true,
      setupFiles: ['./src/test/setup.ts'],
      exclude: ['**/node_modules/**', '**/dist/**', 'e2e/**'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'json', 'html'],
        include: ['src/**/*.{ts,tsx}'],
        exclude: [
          'src/test/**',
          'src/**/*.stories.tsx',
          'src/app/main.tsx',
        ],
      },
    },
  };
});
```

### Plugins

| Plugin | Proposito |
|--------|-----------|
| `@vitejs/plugin-react` | React Fast Refresh en dev, JSX transform |
| `@tailwindcss/vite` | Tailwind v4 via plugin oficial (sin postcss.config.js) |
| `oidc-spa/vite-plugin` (`oidcSpa()`) | Plugin de Vite que provee `oidc-spa` para integrar la librería en el build |

### Servidor de desarrollo

| Opcion | Valor | Proposito |
|--------|-------|-----------|
| `server.port` | `5151` | Puerto del dev server (`http://localhost:5151`) |
| `server.proxy['/api']` | `VITE_API_URL` | Proxy de `/api` al backend en dev; solo se registra si `VITE_API_URL` está definida |

### Configuracion de Tests (bloque `test`)

| Opcion | Valor | Proposito |
|--------|-------|-----------|
| `globals` | `true` | `describe`, `it`, `expect`, `vi` disponibles sin imports |
| `environment` | `jsdom` | DOM virtual para tests de componentes |
| `passWithNoTests` | `true` | No falla si no hay archivos de test |
| `setupFiles` | `['./src/test/setup.ts']` | Carga `@testing-library/jest-dom`. El server MSW (`@library/mocks/server`) se levanta en cada archivo de test que lo necesite |
| `exclude` | incluye `e2e/**` | Playwright tests no se ejecutan con Vitest |
| `coverage.provider` | `v8` | Cobertura nativa de Node.js, rapida |

---

## Variables de Entorno — .env.example

```bash
# OIDC — proveedor de identidad (por defecto Authentik)
VITE_OIDC_ISSUER_URI=https://<idp>/application/o/<app>/   # debe terminar en '/'
VITE_OIDC_CLIENT_ID=<client-id>
VITE_OIDC_PUBLIC_URL=http://localhost:5151

# Base URL del backend propio (usada por backendApi)
VITE_API_URL=http://localhost:3000

# MSW en el navegador (opcional, solo desarrollo)
VITE_ENABLE_MOCKS=false

# Sentry (opcional — dejar vacío para desactivar)
VITE_SENTRY_DSN=
```

Los valores reales de cada proyecto se registran en `PROJECT.md` (secciones Autenticación y Backend).

### Descripcion de Variables

| Variable | Requerida | Ejemplo | Descripcion |
|----------|-----------|---------|-------------|
| `VITE_OIDC_ISSUER_URI` | Sí | `https://idp.example.com/application/o/app/` | Issuer del proveedor OIDC. Debe terminar en `/`. Usada en `oidc-config.ts` → `bootstrapOidc`. |
| `VITE_OIDC_CLIENT_ID` | Sí | `my-spa-client` | Client ID de la aplicación registrada en el IdP (cliente público con PKCE). |
| `VITE_OIDC_PUBLIC_URL` | Sí | `http://localhost:5151` | URL pública de la app, base para las redirect URIs registradas en el IdP. |
| `VITE_API_URL` | No (validada por tipo, no en startup) | `http://localhost:3000` | `baseURL` de `backendApi` y destino del proxy `/api` en dev. |
| `VITE_SENTRY_DSN` | No | `https://xxx@sentry.io/123` | DSN de Sentry. Vacío = Sentry deshabilitado (`initSentry` retorna sin inicializar). |
| `VITE_ENABLE_MOCKS` | No | `true` | Arranca MSW en el navegador antes del render (solo con `import.meta.env.DEV`). |

### Validacion en startup — `src/app/main.tsx`

```ts
const REQUIRED_ENV_VARS = [
  'VITE_OIDC_ISSUER_URI',
  'VITE_OIDC_CLIENT_ID',
  'VITE_OIDC_PUBLIC_URL',
] as const;

const missing = REQUIRED_ENV_VARS.filter((key) => !import.meta.env[key]);
if (missing.length > 0) {
  throw new Error(`Variables de entorno faltantes: ${missing.join(', ')}`);
}
```

Si un proyecto vuelve crítica otra variable (p. ej. `VITE_API_URL`), debe agregarla a `REQUIRED_ENV_VARS`.

### Tipado — `src/vite-env.d.ts`

```ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_OIDC_ISSUER_URI: string;
  readonly VITE_OIDC_CLIENT_ID: string;
  readonly VITE_OIDC_PUBLIC_URL: string;
  readonly VITE_API_URL: string;
  readonly VITE_SENTRY_DSN?: string;
  readonly VITE_ENABLE_MOCKS?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

### Uso en Codigo

```ts
// src/library/api/client/api-instance.ts — factory, sin interceptores
export function createApiClient(baseURL: string): AxiosInstance {
  return axios.create({
    baseURL,
    timeout: 15_000,
    headers: { 'Content-Type': 'application/json' },
  });
}

// src/library/api/backend-api.ts — cliente canónico que usan los repositorios
export const backendApi = createApiClient(import.meta.env.VITE_API_URL);
registerTokenInterceptor(backendApi);
registerRefreshRetryInterceptor(backendApi);
registerErrorInterceptor(backendApi);

// src/library/oidc/oidc-config.ts
export const oidcConfig = {
  issuerUri: import.meta.env.VITE_OIDC_ISSUER_URI,
  clientId: import.meta.env.VITE_OIDC_CLIENT_ID,
  publicUrl: import.meta.env.VITE_OIDC_PUBLIC_URL,
  scopes: ['openid', 'profile', 'email', 'groups', 'permissions'] as string[],
} as const;

// src/library/integrations/sentry/sentry.client.ts
export function initSentry(): void {
  const dsn = import.meta.env.VITE_SENTRY_DSN;
  if (!dsn) return;
  Sentry.init({ dsn, integrations: [], tracesSampleRate: 0.1, environment: import.meta.env.MODE });
}
```

Los repositorios importan siempre `backendApi` desde `@library/api`; nunca crean instancias propias con `createApiClient`.

**Convencion:** todas las variables de entorno expuestas al cliente deben empezar con `VITE_`. Las que no tienen el prefijo no son accesibles desde el codigo del navegador.

---

## Scripts NPM — package.json

| Script | Comando | Descripcion |
|--------|---------|-------------|
| `dev` | `vite` | Servidor de desarrollo con HMR en el puerto 5151 |
| `build` | `tsc -b && vite build` | Verifica tipos con TypeScript y genera bundle de produccion |
| `preview` | `vite preview` | Sirve el build de produccion localmente para verificar |
| `lint` | `eslint src` | Lint de `src/` con ESLint 9 (flat config). `no-undef` está desactivado para `*.ts(x)`: `tsc` valida identificadores y globales del DOM |
| `test` | `vitest` | Ejecuta tests en modo watch (re-ejecuta al guardar) |
| `test:ui` | `vitest --ui` | Vitest con interfaz grafica en el navegador |
| `test:coverage` | `vitest run --coverage` | Ejecuta todos los tests y genera reporte de cobertura en `coverage/` (proveedor `@vitest/coverage-v8`, misma versión que `vitest`) |
| `test:e2e` | `playwright test` | Ejecuta tests e2e con Playwright (levanta `npm run dev` si no está activo) |
| `test:e2e:ui` | `playwright test --ui` | Playwright con interfaz grafica de Playwright |
| `storybook` | `storybook dev -p 6006` | Servidor de desarrollo de Storybook en puerto 6006 |
| `build-storybook` | `storybook build` | Genera build estatico de Storybook en `storybook-static/` |
| `msw:init` | `msw init public/ --save` | Genera el Service Worker de MSW en `public/mockServiceWorker.js` |

Requiere Node `>= 22` (`engines.node` en `package.json`). El `name` del paquete se reemplaza por el slug del proyecto (`PROJECT.md` → Identidad).

---

## Playwright — playwright.config.ts

```ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL ?? 'http://localhost:5151',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: [
    {
      command: 'npm run dev',
      url: 'http://localhost:5151',
      reuseExistingServer: !process.env.CI,
    },
  ],
});
```

### Opciones Clave

| Opcion | Valor | Descripcion |
|--------|-------|-------------|
| `testDir` | `./e2e` | Directorio de tests e2e |
| `fullyParallel` | `true` | Tests corren en paralelo |
| `forbidOnly` | `!!process.env.CI` | En CI, falla si hay `test.only` |
| `retries` | `2` en CI, `0` local | Reintentos en CI para tests flaky |
| `baseURL` | `http://localhost:5151` | URL base para `page.goto('/')` |
| `trace` | `on-first-retry` | Captura trace en el primer reintento para debugging |
| `webServer` | `npm run dev` en `http://localhost:5151` | Arranca el servidor de dev antes de los tests si no esta activo |

### Variable de Entorno para Override

```bash
PLAYWRIGHT_BASE_URL=https://staging.example.com npm run test:e2e
```

---

## MSW — Configuracion

**`package.json`:**
```json
{
  "msw": {
    "workerDirectory": ["public"]
  }
}
```

El Service Worker se sirve desde `public/mockServiceWorker.js`. Se genera con `npm run msw:init` y se commitea al repositorio.

**Archivos:**
- `src/library/mocks/handlers/index.ts` — `export const handlers: RequestHandler[] = [];` (cada módulo registra aquí sus `{dominio}.handlers.ts`).
- `src/library/mocks/browser.ts` — `export const worker = setupWorker(...handlers);`
- `src/library/mocks/server.ts` — `export const server = setupServer(...handlers);` para Vitest.

**Inicialización en dev:** `src/app/main.tsx` arranca el `worker` antes de montar la app solo si `import.meta.env.DEV` y `VITE_ENABLE_MOCKS=true` (import dinámico, `onUnhandledRequest: 'bypass'`). En producción MSW no entra al bundle.
