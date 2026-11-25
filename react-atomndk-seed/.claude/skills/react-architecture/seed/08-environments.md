# 08 — Variables de entorno

## Cómo Vite maneja los archivos `.env`

Vite carga automáticamente los archivos de entorno según el modo activo:

| Archivo | Cuándo se carga |
|---------|----------------|
| `.env` | Siempre |
| `.env.local` | Siempre (ignorado por git) |
| `.env.development` | En modo `development` |
| `.env.development.local` | En modo `development` (ignorado por git) |
| `.env.production` | En modo `production` |
| `.env.production.local` | En modo `production` (ignorado por git) |
| `.env.staging` | Con `--mode staging` |

**Orden de precedencia**: `.local` sobreescribe el archivo base. Los archivos más específicos tienen prioridad.

---

## Regla del prefijo `VITE_`

**Solo las variables con prefijo `VITE_` son accesibles en el código del cliente.**

Las variables sin prefijo están disponibles solo en `vite.config.ts` (proceso de build), nunca en el bundle final.

```bash
# ✅ Accesible en el cliente (bundle)
VITE_API_URL=http://localhost:3000

# ❌ Solo disponible en vite.config.ts
DATABASE_URL=postgresql://...  # NUNCA en el bundle
SECRET_KEY=my-secret           # NUNCA en el bundle
```

> **Seguridad**: nunca pongas secretos, passwords o tokens privados en variables `VITE_*`. Todo lo que comience con `VITE_` va al bundle JavaScript y es visible en el navegador.

---

## Template `.env.example`

Variables de la semilla (los valores reales de cada proyecto se registran en `PROJECT.md`):

```bash
# =============================================================================
# React App — Variables de entorno
# Copia este archivo: cp .env.example .env.local
# =============================================================================

# ---------------------------------------------------------------------------
# OIDC — proveedor de identidad (por defecto Authentik). Requeridas.
# ---------------------------------------------------------------------------
# Issuer del IdP (debe terminar en '/')
VITE_OIDC_ISSUER_URI=https://<idp>/application/o/<app>/
# Client ID de la aplicación registrada en el IdP (cliente público con PKCE)
VITE_OIDC_CLIENT_ID=<client-id>
# URL pública de la app (base de las redirect URIs registradas en el IdP)
VITE_OIDC_PUBLIC_URL=http://localhost:5151

# ---------------------------------------------------------------------------
# API backend (usada por backendApi y por el proxy /api del dev server)
# ---------------------------------------------------------------------------
VITE_API_URL=http://localhost:3000

# ---------------------------------------------------------------------------
# Mocks (opcional): 'true' arranca MSW en el navegador, solo en desarrollo
# ---------------------------------------------------------------------------
VITE_ENABLE_MOCKS=false

# ---------------------------------------------------------------------------
# Monitoreo / Sentry (opcional — dejar vacío para deshabilitar)
# ---------------------------------------------------------------------------
VITE_SENTRY_DSN=
```

### Validación en startup

`src/app/main.tsx` aborta el arranque con un error claro si falta alguna variable crítica:

```typescript
const REQUIRED_ENV_VARS = [
  'VITE_OIDC_ISSUER_URI',
  'VITE_OIDC_CLIENT_ID',
  'VITE_OIDC_PUBLIC_URL',
] as const;
```

Si el proyecto vuelve crítica otra variable, agregarla aquí.

---

## Tipado de `import.meta.env` con TypeScript

`src/vite-env.d.ts` de la semilla:

```typescript
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_OIDC_ISSUER_URI: string;
  readonly VITE_OIDC_CLIENT_ID: string;
  readonly VITE_OIDC_PUBLIC_URL: string;
  readonly VITE_API_URL: string;
  readonly VITE_SENTRY_DSN?: string;
  readonly VITE_ENABLE_MOCKS?: string;
  // agregar aquí cada variable nueva del proyecto
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

Uso en código TypeScript:

```typescript
// TypeScript sabe el tipo exacto
const apiUrl = import.meta.env.VITE_API_URL;        // string
const sentryDsn = import.meta.env.VITE_SENTRY_DSN;  // string | undefined

// Acceso al modo de Vite (no requiere prefijo VITE_)
const isProduction = import.meta.env.PROD;  // boolean
const isDevelopment = import.meta.env.DEV;  // boolean
const mode = import.meta.env.MODE;          // 'development' | 'production' | custom
```

---

## Variables por ambiente

### Development (`.env.development`)

```bash
VITE_OIDC_PUBLIC_URL=http://localhost:5151
VITE_API_URL=http://localhost:3000
VITE_SENTRY_DSN=
```

### Staging (`.env.staging`)

```bash
VITE_OIDC_PUBLIC_URL=https://staging.myapp.com
VITE_API_URL=https://api.staging.myapp.com
VITE_SENTRY_DSN=https://xxx@sentry.io/yyy
```

Para arrancar en modo staging:

```bash
npm run dev -- --mode staging
npm run build -- --mode staging
```

### Production (`.env.production`)

```bash
VITE_OIDC_PUBLIC_URL=https://myapp.com
VITE_API_URL=https://api.myapp.com
VITE_SENTRY_DSN=https://xxx@sentry.io/yyy
```

---

## Agregar una nueva variable de entorno

1. Agregar al `.env.example` con un comentario descriptivo
2. Agregar a todos los archivos `.env.*` relevantes
3. Extender la interfaz `ImportMetaEnv` en `src/vite-env.d.ts` (y, si es crítica, agregarla a `REQUIRED_ENV_VARS` en `src/app/main.tsx`)
4. Usar en el código con `import.meta.env.VITE_MI_VARIABLE`

```typescript
// Ejemplo: nueva variable para URL de un servicio externo
// 1. En .env.example:
// VITE_ANALYTICS_URL=https://analytics.example.com

// 2. En src/vite-env.d.ts:
interface ImportMetaEnv {
  // ... existing vars
  readonly VITE_ANALYTICS_URL: string;
}

// 3. Uso:
const analyticsUrl = import.meta.env.VITE_ANALYTICS_URL;
```

---

## `.gitignore` — qué ignorar

Asegúrate de que tu `.gitignore` incluya:

```gitignore
# Variables de entorno locales (contienen valores reales)
.env.local
.env.*.local

# Commitear estos archivos (son templates, sin valores reales):
# .env.example       ← siempre commitear
# .env.development   ← commitear si no tiene secretos
# .env.staging       ← commitear si no tiene secretos
# .env.production    ← commitear si no tiene secretos
```
