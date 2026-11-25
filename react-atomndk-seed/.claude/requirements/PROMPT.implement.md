# PROMPT — Implementar RC (frontend)

Flujo operativo para el agente `implementer` cuando el usuario pide ejecutar un Requirement Contract del frontend previamente aprobado.

## Contrato de comportamiento

- No implementar nada que no se mencione en el RC y nunca aplicar cambios sin preguntar primero. Si tienes algo que proponer, consúltalo para que se apruebe o se descarte.
- Limitarse a seguir el RC, `AGENTS.md`, `PROJECT.md` y las skills. No modificar archivos fuera del alcance del RC salvo que sea estrictamente necesario (y avisar antes).
- **No renombrar el RC, ni cambiarle el filename, ni moverlo de directorio.**

## Paso 1 — Localizar y validar el RC

- El RC vive plano en `.claude/requirements/rc-YYYYMMDD-HHmm-<slug>.md`.
- El usuario pasa el path o el `id`. Si solo pasa un slug, buscar con `ls .claude/requirements/rc-*.md`.
- Leer el frontmatter YAML:
  - **`type` debe ser `frontend`.** Si no lo es, abortar y sugerir el repo correcto.
  - **`status` debe ser `approved`.** Si es `draft`, abortar y pedir aprobación al LT. Si es `in-progress`, confirmar con el usuario si se retoma un trabajo pausado. Si es `implemented` o `archived`, abortar.
  - Anotar `related_rc` si existe: hay que mantener consistencia con el RC pareja del backend (mismos endpoints, mismos tipos).

## Paso 2 — Marcar el RC como en progreso

- Editar el frontmatter: `status: in-progress`.
- Commit: `chore(rc): mark rc-YYYYMMDD-HHmm-<slug> as in-progress`.

## Paso 3 — Ejecutar la checklist del RC

Trabajar sección por sección siguiendo la lista de archivos del RC y la skill `react-architecture` (React Atomic NDK):

- Capas NDK: `resources/` → `global/` → `library/` → `modules/`.
- Flujo de datos: `Component → Hook (React Query) → Repository → backendApi`. Service solo si hay lógica de negocio real.
- Atomic Design: `q1` átomo, `q2` molécula, `q3` célula, `q4` organismo, `q5` ecosistema (guard/layout/flujo), `pa` página.
- Reutilizar componentes existentes de `src/global/components/` antes de crear nuevos; si aparece un patrón repetido, extraerlo a un componente reutilizable.
- PrimeReact como librería base de UI (formularios, tablas, diálogos) envuelta en componentes `q*`.
- Tailwind + tokens `--acl-*` de `src/styles/theme.css`. Nada de estilos inline ni colores hardcodeados.
- React Query para server state (query keys centralizadas) y Zustand para estado UI.
- Código en inglés (naming); textos visibles al usuario en español.
- Sin `console.log`.

## Paso 4 — Tests

- Unitarios, integración (MSW) y e2e (Playwright) según la sección de Testing del RC.
- Todos los tests en verde antes de considerar terminado.

## Paso 5 — Definition of Done

- [ ] `npx tsc --noEmit` sin errores.
- [ ] `npm run lint` sin errores.
- [ ] `npm run test -- --run` en verde.
- [ ] `npm run test:e2e` en verde si el RC tiene criterios e2e.
- [ ] `npm run build` exitoso.
- [ ] Checklist de responsive verificada (mobile, tablet, desktop) si el RC tiene UI.
- [ ] Screenshots adjuntos al PR si el cambio es visual.
- [ ] Si el RC es cross-stack, verificar que el backend ya expone el contrato o coordinar con el dev de backend.
- [ ] Skill `sdd-verify` ejecutada con veredicto PASS o PASS CON WARNINGS.

## Paso 6 — Cerrar el RC

- Editar el frontmatter: `status: implemented`.
- Actualizar la sección "Historial" con la fecha y la acción.
- Commit final: `feat(<modulo>): implement rc-YYYYMMDD-HHmm-<slug>` incluyendo el cambio de estado.

## Errores comunes a evitar

- Crear archivos que no estén en la checklist del RC sin consultar.
- Duplicar componentes: revisar `src/global/components/` antes de crear.
- Usar `<select>` o `<input>` HTML nativo cuando existe un wrapper PrimeReact equivalente.
- Mezclar refactors no relacionados en el mismo commit.
- Dejar el RC en `in-progress` si el trabajo se pausa: volver a `approved` si se libera o pasar a `archived` si se descarta.
