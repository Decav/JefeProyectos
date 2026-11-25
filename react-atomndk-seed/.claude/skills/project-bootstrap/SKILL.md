---
name: project-bootstrap
description: Crea un proyecto frontend nuevo a partir de la semilla React Atomic NDK, rellenando PROJECT.md y personalizando nombre, OIDC, roles, marca y entorno sin tocar la arquitectura. Úsala cuando el usuario pida crear, inicializar o personalizar un proyecto desde la semilla.
---

# Project Bootstrap — Crear un proyecto desde la semilla

Procedimiento para que un agente cree un proyecto nuevo basado en esta semilla. La arquitectura **React Atomic NDK** se copia tal cual y es obligatoria; solo se personalizan los datos del proyecto.

## Qué se copia sin cambios (arquitectura)

- Capas `src/resources`, `src/global`, `src/library`, `src/modules`, `src/app` y sus reglas.
- Atomic Design (`q1`–`q5`, `pa`) y componentes base de `src/global/components/`.
- Cliente `backendApi` + interceptores, integración OIDC (`src/library/oidc/`), React Query, Zustand, MSW, Sentry.
- Módulos `login` y `callback`.
- Tooling: Vite, TypeScript strict, ESLint, Prettier, Vitest, Playwright, Storybook.
- `.claude/` completo (skills, agentes y flujo de RCs), `AGENTS.md` y `CLAUDE.md`.

## Qué se personaliza (datos del proyecto)

Todo lo que está en `PROJECT.md` como `{{...}}`.

## Procedimiento

### Paso 1 — Reunir datos

Pedir al usuario (o leer de los documentos que entregue: DAD, PRD, guía de marca) los valores de `PROJECT.md`. Como mínimo: nombre, slug, cliente, descripción, líder técnico, proveedor OIDC (issuer y client ID si ya existen), roles y colores de marca. Si un dato no está disponible, dejar el placeholder y listarlo como pendiente. **No inventar valores** (URLs, client IDs, colores).

### Paso 2 — Copiar la semilla

1. Copiar la carpeta de la semilla al destino que indique el usuario, **excluyendo** `node_modules/`, `dist/`, `coverage/`, `.git/` y archivos `.env` reales.
2. Inicializar git en el destino solo si el usuario lo pide.

### Paso 3 — Rellenar `PROJECT.md`

Reemplazar cada `{{...}}` con los datos del Paso 1.

### Paso 4 — Aplicar los datos al código

| Dato | Archivo(s) |
|------|------------|
| `{{PROJECT_NAME}}` | `AGENTS.md` (saludo y alerta arquitectónica), `index.html` (`<title>`), `README.md` |
| `{{PROJECT_SLUG}}` | `package.json` → `name` |
| OIDC (issuer, client ID, URL pública) | `.env.example` (valores de ejemplo, nunca secretos reales) |
| Scopes OIDC | `src/library/oidc/oidc-config.ts` |
| Roles | `src/resources/enums/permission.enum.ts` |
| Mapeo grupos → roles | `src/resources/contracts/oidc.contract.ts` |
| Colores y tipografía de marca | `src/styles/theme.css` (tokens `--acl-brand-*`, `--acl-font-family`) y la fuente en `index.html` |
| Logo y favicon | `public/` y referencias en `q3-app-shell` / `index.html` |
| API | `.env.example` → `VITE_API_URL` |

Reglas al aplicar:

- No renombrar tokens `--acl-*`, aliases, capas ni prefijos de componentes.
- No agregar librerías ni cambiar el stack. Si el proyecto lo necesita, proponer un ADR.
- Si el IdP no es Authentik, revisar los comentarios específicos de Authentik en `.env.example`, `oidc-config.ts` y `oidc.contract.ts` y adaptarlos al proveedor, sin cambiar la librería `oidc-spa`.

### Paso 5 — Validar

```bash
npm install
npx tsc --noEmit
npm run lint
npm run test -- --run
npm run build
```

Reportar cualquier fallo; no darlo por terminado con errores.

### Paso 6 — Entregar

Informar:

1. Ruta del proyecto creado.
2. Valores aplicados y placeholders `{{...}}` que siguen pendientes (buscar con `grep -rn "{{" --include="*.md" --include="*.ts" --include="*.json" .`).
3. Resultado de las validaciones.
4. Siguiente paso: crear el primer RC con `.claude/requirements/PROMPT.create.md`.
