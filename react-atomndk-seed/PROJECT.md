# PROJECT.md — Ficha del proyecto

Ficha que se rellena al crear un proyecto desde la semilla React Atomic NDK. Es la **única fuente de datos específicos del proyecto**: los agentes la leen para personalizar el código, los textos y los RCs. Las reglas de arquitectura NO van aquí (viven en `AGENTS.md` y en la skill `react-architecture`).

> Mientras haya valores `{{...}}` sin reemplazar, la semilla no está personalizada. Para crear un proyecto nuevo, seguir la skill `.claude/skills/project-bootstrap/SKILL.md`.

## 1. Identidad

| Campo | Valor |
|-------|-------|
| Nombre del proyecto | `{{PROJECT_NAME}}` |
| Slug del paquete (`package.json` → `name`) | `{{PROJECT_SLUG}}` |
| Cliente | `{{CLIENT_NAME}}` |
| Descripción (1-2 oraciones) | `{{PROJECT_DESCRIPTION}}` |
| Líder técnico (aprueba RCs y ADRs) | `{{TECH_LEAD}}` |
| Repositorio | `{{REPO_URL}}` |

## 2. Alcance funcional

- Usuarios objetivo: `{{TARGET_USERS}}`
- Módulos iniciales previstos (`src/modules/`): `{{INITIAL_MODULES}}`
- Documentos de referencia (DAD, PRD, HUs, prototipos): `{{REFERENCE_DOCS}}`

## 3. Autenticación (OIDC)

La semilla usa `oidc-spa` (Authorization Code + PKCE) con cualquier proveedor OIDC.

| Campo | Valor |
|-------|-------|
| Proveedor de identidad | `{{IDP_NAME}}` (por defecto Authentik; alternativas: Entra ID, Keycloak, etc.) |
| Issuer URI (`VITE_OIDC_ISSUER_URI`) | `{{OIDC_ISSUER_URI}}` |
| Client ID (`VITE_OIDC_CLIENT_ID`) | `{{OIDC_CLIENT_ID}}` |
| URL pública (`VITE_OIDC_PUBLIC_URL`) | `{{OIDC_PUBLIC_URL}}` |
| Scopes | `{{OIDC_SCOPES}}` (semilla: `openid profile email groups permissions`) |
| Claim de grupos/roles | `{{ROLES_CLAIM}}` |

Roles de la aplicación (`src/resources/enums/permission.enum.ts`) y su mapeo desde grupos del IdP (`src/resources/contracts/oidc.contract.ts`):

| Grupo / claim en el IdP | Rol en la app |
|-------------------------|---------------|
| `{{IDP_GROUP_1}}` | `{{ROLE_1}}` |

## 4. Backend e integraciones

| Campo | Valor |
|-------|-------|
| API principal (`VITE_API_URL`) | `{{API_URL}}` |
| Formato de errores | `{{ERROR_FORMAT}}` (recomendado: RFC 7807) |
| Repo backend con flujo de RCs (`{{BACKEND_REPO_PATH}}`) | `{{BACKEND_REPO_PATH}}` (o "N/A") |
| Integraciones externas | `{{INTEGRATIONS}}` |
| Sentry DSN (`VITE_SENTRY_DSN`) | `{{SENTRY_DSN}}` (vacío = deshabilitado) |

## 5. Marca y design system

La estructura de tokens (`--acl-*` en `src/styles/theme.css`) es fija; aquí van solo los valores.

| Token | Valor |
|-------|-------|
| `--acl-brand-primary` | `{{BRAND_PRIMARY}}` |
| `--acl-brand-secondary` | `{{BRAND_SECONDARY}}` |
| `--acl-brand-gradient` | `{{BRAND_GRADIENT}}` |
| `--acl-font-family` | `{{FONT_FAMILY}}` |
| Logo / favicon (`public/`) | `{{LOGO_FILES}}` |
| Guía de look & feel | `{{BRAND_GUIDE}}` |

## 6. Entornos

| Entorno | URL | Notas |
|---------|-----|-------|
| local | `http://localhost:5151` | `npm run dev` |
| `{{ENV_NAME}}` | `{{ENV_URL}}` | |

## 7. Restricciones y no funcionales

- Navegadores / dispositivos soportados: `{{SUPPORTED_BROWSERS}}`
- Accesibilidad: `{{A11Y_LEVEL}}` (recomendado: WCAG 2.1 AA)
- Idioma de la UI: `{{UI_LANGUAGE}}` (semilla: español)
- Normativa o seguridad específica del cliente: `{{COMPLIANCE}}`

## 8. Decisiones propias del proyecto (ADRs)

Desviaciones aprobadas respecto de la semilla. Cada una con su ADR en `.claude/skills/react-architecture/architecture/09-adrs.md` o en `docs/adr/`.

| Fecha | Decisión | ADR |
|-------|----------|-----|
| | | |
