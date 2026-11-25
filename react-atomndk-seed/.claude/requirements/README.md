# RCs — Frontend

Los **Requirement Contracts (RCs)** son el paso obligatorio antes de escribir código de negocio en el frontend. Este README documenta el flujo SDD (Spec-Driven Development), la estructura y las convenciones que rigen los RCs.

> Todas las rutas de este documento son relativas a la raíz del repositorio frontend. Si el proyecto tiene un backend con su propio flujo de RCs, su ubicación se define en `PROJECT.md` (`{{BACKEND_REPO_PATH}}`).

## Estructura del directorio (plano, sin subcarpetas)

```
.claude/requirements/
├── README.md                        # este archivo
├── TEMPLATE.frontend.md             # plantilla única para RCs del frontend
├── PROMPT.create.md                 # flujo para crear un RC
├── PROMPT.implement.md              # flujo para implementar un RC (agente implementer)
└── rc-YYYYMMDD-HHmm-<slug>.md       # RCs (todos al mismo nivel)
```

## Naming invariable

- **Formato**: `rc-YYYYMMDD-HHmm-<slug>.md`
- **Ejemplo**: `rc-20260115-0930-user-profile.md`
- El timestamp se fija al crear el RC (`draft`) y **nunca cambia**. Cero renumeraciones al aprobar, cero renames al implementar.
- El `<slug>` es kebab-case en inglés (política English-first del código).
- Ordenamiento cronológico natural en cualquier `ls`.
- Colisiones prácticamente imposibles: precisión de minuto + slug distinto.

## Estados (solo en el frontmatter YAML)

- `draft`: recién creado, en revisión con el LT.
- `approved`: el LT lo aprobó y quedó firmado (`approver` + `approved_at`).
- `in-progress`: el agente `implementer` lo está ejecutando.
- `implemented`: código mergeado, tests verdes, DoD cumplido.
- `archived`: descartado o reemplazado por otro RC (documentar en el cuerpo).

El filename NO refleja el estado. La transición `draft → approved` es un edit del frontmatter, no un rename.

## Frontmatter obligatorio

Ver `TEMPLATE.frontend.md` para el bloque completo. Campos mínimos:

```yaml
---
id: rc-YYYYMMDD-HHmm-<slug>
title: "Título del feature"
type: frontend
status: draft
module: src/modules/<nombre>
author: "Nombre del dev"
created: YYYY-MM-DD
approver: null
approved_at: null
---
```

## Cross-stack (features con backend + frontend)

Si el proyecto tiene backend propio con flujo de RCs y el feature toca ambos stacks, se crean **dos RCs con el mismo filename literal**, uno en cada repo (`type: frontend` y `type: backend`). Cada uno declara al otro:

```yaml
related_rc:
  - id: rc-YYYYMMDD-HHmm-<slug>
    type: backend
    path: {{BACKEND_REPO_PATH}}/.claude/requirements/rc-YYYYMMDD-HHmm-<slug>.md
```

Reglas operativas:

- El timestamp se obtiene UNA sola vez y se reutiliza para ambos filenames.
- La sección de contrato HTTP queda espejada entre ambos RCs.
- El cuerpo específico de cada stack vive solo en su repo.

Si el proyecto no tiene backend propio (consume APIs de terceros), omitir `related_rc` y documentar el contrato del proveedor en la sección de contrato HTTP.

## Flujo mínimo SDD

1. **Crear**: seguir `PROMPT.create.md`. Se copia `TEMPLATE.frontend.md` a `rc-YYYYMMDD-HHmm-<slug>.md` y se completa con `status: draft`.
2. **Aprobar**: el LT edita el frontmatter (`status: approved`, `approver`, `approved_at`). **No renombra el archivo.**
3. **Implementar**: el agente `implementer` sigue `PROMPT.implement.md`, verifica `type: frontend` y `status: approved`, y marca `status: in-progress` mientras trabaja.
4. **Verificar**: ejecutar la skill `sdd-verify` sobre el RC.
5. **Cerrar**: al mergear se marca `status: implemented`. El RC queda como registro histórico en el repo.

## Trabajo paralelo seguro

Antes de crear un RC nuevo:

```bash
git fetch --all
ls .claude/requirements/rc-*.md
```

Si en el mismo minuto se crean dos RCs con el mismo slug, el segundo detecta el conflicto en el `ls` y elige otro slug.

## Cuándo NO se necesita RC

- Infraestructura de la semilla (layout base, tema visual, CI/CD, refactors internos sin cambio de contrato).
- Fixes de bugs sin cambio de contrato ni de dominio.
- Documentación pura.

Regla operativa: si el cambio introduce lógica de negocio nueva, cambia rutas o componentes de negocio, cambia el consumo de la API, expone textos nuevos al usuario o afecta un dominio con reglas de negocio, **requiere RC**.
