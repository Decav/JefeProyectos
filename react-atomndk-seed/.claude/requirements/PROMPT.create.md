# PROMPT — Crear RC (frontend)

Flujo operativo para crear un Requirement Contract del frontend cuando el usuario lo pide. Lo ejecuta el asistente principal (o el agente `supervisor` lo indica).

## Contrato de comportamiento

- No implementar nada que no se mencione y nunca aplicar cambios sin preguntar primero. Si tienes algo que proponer, consúltalo para que se apruebe o se descarte.
- Limitarse a seguir `AGENTS.md`, `PROJECT.md`, las skills, este prompt y `TEMPLATE.frontend.md`. No modificar archivos que no se mencionen en el requerimiento.
- No renombrar archivos ni escribir RCs en subcarpetas. Los RCs viven planos en `.claude/requirements/`.

## Paso 1 — Elegir el filename (seguro en paralelo)

- Formato invariable: `rc-YYYYMMDD-HHmm-<slug>.md`.
  - Ejemplo: `rc-20260115-0930-user-profile.md`.
- Generar el timestamp UNA sola vez con `date +%Y%m%d-%H%M` (zona horaria local del dev).
- El `<slug>` es kebab-case ASCII en inglés: minúsculas, dígitos y guiones, máximo 40 caracteres.

Antes de crear el archivo:

1. `git fetch --all`.
2. Listar los RCs existentes:
   - Local: `ls .claude/requirements/rc-*.md 2>/dev/null`.
   - Remoto (recomendado): `git ls-tree -r --name-only origin/main -- .claude/requirements/`.
3. Si el filename ya existe, elegir otro slug o esperar un minuto. **Nunca sobrescribir un `rc-*.md` existente.**

Si el feature es cross-stack y el proyecto tiene backend con flujo de RCs, reutilizar EL MISMO timestamp y EL MISMO slug para el RC pareja en `{{BACKEND_REPO_PATH}}/.claude/requirements/` y verificar disponibilidad en ambos repos.

## Paso 2 — Copiar el template

- Copiar `.claude/requirements/TEMPLATE.frontend.md` como `.claude/requirements/rc-YYYYMMDD-HHmm-<slug>.md`.
- Ajustar el frontmatter YAML:
  - `id`: mismo valor que el filename sin `.md`.
  - `title`: título humano del feature.
  - `type: frontend` (fijo).
  - `status: draft` (fijo al crear).
  - `module`: path del módulo dentro de `src/modules/`.
  - `author`: nombre del dev que pide el RC.
  - `created`: `YYYY-MM-DD` de hoy.
  - `approver`: `null`.
  - `approved_at`: `null`.
- Si el RC es cross-stack, activar el bloque `related_rc`.
- El header del cuerpo (`# RC: [Título]`) lleva el título humano. **Sin numeración NNN.**

## Paso 3 — Completar el cuerpo del RC

Rellenar cada sección del template con la información del usuario y el contexto del proyecto (`PROJECT.md`), respetando la arquitectura React Atomic NDK:

1. Contexto y problema.
2. Objetivo (medible, concreto).
3. Contratos (`src/resources/`): entidades, enums, requests, responses.
4. Contrato HTTP: endpoints consumidos, status y errores esperados.
5. Repositorios (`src/library/repositories/`) y mocks MSW.
6. Hooks React Query y query keys.
7. Componentes y páginas (Atomic Design `q1`–`q5`, `pa`).
8. Rutas y permisos (guardas, roles).
9. Estado UI (Zustand), si aplica.
10. Estados de UI y manejo de errores (loading, vacío, 401, 403, error).
11. Testing (unitario, integración con MSW, e2e Playwright).
12. Criterios de aceptación y DoD.
13. Responsive.
14. Archivos a crear (checklist plana).
15. Notas adicionales.
16. Historial.

Si el RC es cross-stack, la sección de contrato HTTP debe quedar espejada con el RC pareja del backend.

## Paso 4 — Entregar el RC al usuario

- Confirmar el path exacto del archivo creado.
- Advertir explícitamente que el LT debe editar el frontmatter para aprobar (`status: approved`, `approver`, `approved_at`) **sin renombrar el archivo**.

## Escenarios cruzados

- Si el RC no corresponde al frontend (solo cambia dominio de backend), sugerir crearlo en el repo backend con su propio template.
- Si el usuario dice "no necesito RC" para un cambio de negocio real, negarse y explicar la política: RC obligatorio para lógica de negocio, rutas de negocio, consumo de API, textos nuevos visibles al usuario o cambios de dominio.
- Si el cambio es infraestructura de la semilla (layout base, tema visual, CI/CD), refactor interno sin cambio de contrato o documentación, indicar que **no requiere RC** y no crear archivo.
