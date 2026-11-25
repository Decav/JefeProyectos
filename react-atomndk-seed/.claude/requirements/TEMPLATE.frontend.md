---
# Frontmatter YAML — SIEMPRE al inicio del RC. Los agentes lo leen para saber
# el tipo, el estado y la pareja cross-stack sin abrir el cuerpo.
# El filename (rc-YYYYMMDD-HHmm-<slug>.md) es invariable durante toda la vida
# del RC. El LT NO renombra el archivo al aprobar; solo actualiza `status`,
# `approver` y `approved_at`.

id: rc-YYYYMMDD-HHmm-<slug>       # mismo valor que el filename (sin `.md`)
title: "[Título del feature]"
type: frontend                    # fijo en este repo
status: draft                     # draft | approved | in-progress | implemented | archived
module: src/modules/{modulo}
author: "[Nombre del desarrollador]"
created: YYYY-MM-DD
approver: null                    # "[Nombre del LT]" al aprobar
approved_at: null                 # YYYY-MM-DD al aprobar
# related_rc:                     # solo si es cross-stack (impacto en back Y front)
#   - id: rc-YYYYMMDD-HHmm-<slug> # MISMO filename literal en el otro repo
#     type: backend
#     path: {{BACKEND_REPO_PATH}}/.claude/requirements/rc-YYYYMMDD-HHmm-<slug>.md
---

# RC: [Título del feature]

---

## 1. Contexto y problema

<!-- Situación actual y por qué este feature es necesario. Máximo 1 párrafo;
si necesitas más, el feature es demasiado grande y hay que dividirlo. -->

## 2. Objetivo

<!-- 1-3 oraciones. Qué se logra, medible y concreto. -->

---

## 3. Contratos (`src/resources/`)

<!-- Solo tipos NUEVOS o MODIFICADOS. Sin React ni HTTP. -->

| Tipo | Archivo | Descripción |
|------|---------|-------------|
| Entidad | `src/resources/entities/{nombre}.entity.ts` | |
| Request | `src/resources/requests/{dominio}.request.ts` | |
| Response | `src/resources/responses/{dominio}.response.ts` | |
| Enum (`as const`) | `src/resources/enums/{nombre}.enum.ts` | |

## 4. Contrato HTTP

<!-- Endpoints consumidos vía backendApi. Si es cross-stack, espejado con el RC de backend. -->

| Método | Ruta | Request | Response | Status esperados | Rol requerido |
|--------|------|---------|----------|------------------|---------------|
| | | | | | |

---

## 5. Repositorios y mocks (`src/library/`)

| Repositorio | Métodos | Handler MSW |
|-------------|---------|-------------|
| `src/library/repositories/{modulo}.repository.ts` | | `src/library/mocks/handlers/{modulo}.handlers.ts` |

<!-- Si se requiere Service (solo con lógica de negocio real), justificarlo aquí. -->

## 6. Hooks y query keys

| Hook | Tipo | Query key (`query-keys.ts`) | Invalida |
|------|------|-----------------------------|----------|
| `use-{nombre}-query.ts` | query | `queryKeys.{modulo}.{nombre}` | — |
| `use-{nombre}-mutation.ts` | mutation | — | `queryKeys.{modulo}.*` |

## 7. Componentes y páginas (Atomic Design)

| Componente | Nivel | Ubicación | Responsabilidad |
|------------|-------|-----------|-----------------|
| | q1–q5 / pa | `src/modules/{modulo}/components/...` o `src/global/components/...` | |

## 8. Rutas y permisos

| Ruta | Página | Guarda | Roles |
|------|--------|--------|-------|
| | `pa-{nombre}` | `q5-protected-route` / `q5-authorized` | |

## 9. Estado UI (si aplica)

<!-- Store Zustand: global (`src/global/store/`) o del módulo (`core/state/`).
Eliminar la sección si no aplica. -->

## 10. Estados de UI y errores

| Estado | Comportamiento esperado |
|--------|-------------------------|
| Cargando | Skeleton PrimeReact con dimensiones aproximadas al contenido |
| Vacío | |
| 401 | Manejado globalmente por el interceptor (no duplicar) |
| 403 | `Q2Forbidden` inline |
| Error 4xx/5xx | |

---

## 11. Testing

| Archivo | Tipo | Casos a cubrir |
|---------|------|----------------|
| | unitario / integración (MSW) / e2e (Playwright) | |

---

## 12. Criterios de aceptación

<!-- Cada criterio es un test. Si no se puede testear, no es un criterio. -->

### Tests unitarios
- [ ] Criterio 1

### Tests e2e / Playwright
- [ ] Criterio 1

### Definition of Done
- [ ] `npx tsc --noEmit` sin errores
- [ ] `npm run lint` sin errores
- [ ] `npm run test -- --run` en verde
- [ ] `npm run test:e2e` en verde (si aplica)
- [ ] `npm run build` exitoso
- [ ] Cobertura ≥ 80% en archivos nuevos

---

## 13. Responsive

Comportamiento esperado por breakpoint (mobile-first):

| Breakpoint | Layout / comportamiento | Notas |
| --- | --- | --- |
| `< sm` (0-639, mobile) | (describir) | (touch targets ≥ 44px, drawer si aplica) |
| `sm-md` (640-1023, tablet) | (describir) | (describir solo si cambia) |
| `md+` (1024+, desktop) | (describir) | (columnas, sidebar, densidad) |

Verificaciones manuales antes de PR (adjuntar screenshots si el cambio es visual):

- [ ] 375 × 667 (mobile): sin scroll horizontal, botones ≥ 44px, texto legible
- [ ] 768 × 1024 (tablet): layout intermedio correcto
- [ ] 1366 × 768 (desktop): layout completo

Si el RC NO introduce cambios visuales, escribir explícitamente "N/A: este RC no expone UI al usuario final".

---

## 14. Archivos a crear

| Capa | Archivo | Estado |
|------|---------|--------|
| resources | `src/resources/entities/{nombre}.entity.ts` | ⬜ |
| resources | `src/resources/responses/{dominio}.response.ts` | ⬜ |
| library | `src/library/repositories/{modulo}.repository.ts` | ⬜ |
| library | `src/library/mocks/handlers/{modulo}.handlers.ts` | ⬜ |
| library | `src/library/query/query-keys.ts` (agregar keys) | ⬜ |
| modules | `src/modules/{modulo}/core/hooks/use-{nombre}-query.ts` | ⬜ |
| modules | `src/modules/{modulo}/core/schemas/{nombre}.schema.ts` | ⬜ |
| modules | `src/modules/{modulo}/components/q4-{nombre}/q4-{nombre}.tsx` | ⬜ |
| modules | `src/modules/{modulo}/components/pa-{nombre}/pa-{nombre}.tsx` | ⬜ |
| modules | `src/modules/{modulo}/routes/{modulo}.routes.tsx` | ⬜ |
| modules | `src/modules/{modulo}/index.ts` | ⬜ |
| app | `src/app/router/app-router.tsx` (registrar rutas) | ⬜ |
| e2e | `e2e/{flujo}.spec.ts` | ⬜ |

---

## 15. Notas adicionales

<!-- Decisiones técnicas, trade-offs, dependencias con otros módulos, advertencias. -->

---

## 16. Historial

| Fecha | Acción | Autor |
|-------|--------|-------|
| YYYY-MM-DD | Creación del RC | [Nombre] |
