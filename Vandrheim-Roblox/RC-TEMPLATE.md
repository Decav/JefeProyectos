# RC-TEMPLATE — Requerimiento Técnico (RC)

> Uso: un **RC por HU**. Se deriva 100% de la HU + GDD. Lo consume el agente/dev
> de implementación. Se entrega como comentario Luau (`--[[ ... --]]`) en el
> código o como archivo en `RCs/`. Numeración secuencial: `rc001`, `rc002`, …

## Reglas

1. **Fuente:** HU formal (plantilla) + GDD (secciones citadas). No inventar alcance.
2. **Solo “qué + dónde + cómo técnico”, no el código en sí.**
3. **Estado:** `ABIERTO (pendiente de implementación)` → `EN IMPLEMENTACIÓN` → `COMPLETO (verificado el <fecha>)`.
4. **Secciones obligatorias:** 1–10. Si una no aplica, escribir “N/A” (no borrarla).
5. **Convenciones fijas del proyecto:** `task.wait()`/`task.spawn()` (prohibido `wait()`); UI con `Scale` + `UIAspectRatioConstraint`; server-authoritative.

## Mapeo HU → RC

| Sección RC | De dónde sale |
|------------|---------------|
| Header (Fuente) | “Depende de” + fases previas de la HU; secciones GDD citadas |
| 1. Descripción | Narrativa INVEST + objetivo de la fase |
| 2. Alcance (SÍ) | “Incluye” de la HU, concreto a servicios/places/remotes |
| 3. Fuera de alcance | “No incluye” de la HU + fases siguientes |
| 4. Criterios aceptación | Escenarios Gherkin → lista numerada verificable |
| 5. Implementación técnica | “Especificaciones Técnicas / Contratos” + defaults cerrados |
| 6. Integración | Dependencias de la HU + qué deja listo para la siguiente fase |
| 7. Optimización | Presupuesto de sesiones, anti-overengineering, patrones (señales) |
| 8. Definición de hecho | DoD de la HU + nota de estado en GDD/README |
| 9. Estimación | Estimación de la HU (orientativo) |
| 10. Dependencias | “Depende de” de la HU o “Ninguna” |

---

## Copiar desde aquí

```luau
--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc[NUM] — FASE R[N] (HU-R[N])
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU-R[N] ([archivo]) + GDD (secciones [x, y, z]).
Estado: ABIERTO (pendiente de implementación).
Requisitos previos: [HU-R[N-1] completa / "Ninguna"].

================================================================================
1. DESCRIPCIÓN
================================================================================
[Comportamiento a lograr en lenguaje de producto (narrativa de la HU).]

Objetivo de la fase: [1–2 frases del objetivo técnico concreto].
Criterio de hecho global: "[frase verificable del GDD §14 o de la HU]".

================================================================================
2. ALCANCE (SÍ)
================================================================================
[Bullets concretos de lo que SÍ se implementa: servicios, places, remotes,
 carpetas, UI. Derivado del "Incluye" de la HU.]

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
[Bullets sistema por sistema: del "No incluye" de la HU + fases siguientes.
 Un bullet por sistema (skills, inventario, dungeon, ...).]

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. [Un criterio verificable por línea (de los escenarios Gherkin de la HU).]
2. [...]
3. [...]

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
[Qué se crea, dónde (servicio/carpeta/place), contratos de red (remotes +
 payload), defaults numéricos, convenciones obligatorias:
   - Server-authoritative: [qué valida el server y qué nunca el cliente].
   - Remotes: nombre, dirección C→S / S→C, payload.
   - Data/estado: [schema, replicación, defaults].
   - task.wait()/task.spawn() (PROHIBIDO wait()).
   - UI con Scale y UIAspectRatioConstraint.]

================================================================================
6. INTEGRACIÓN
================================================================================
[Qué espera de las fases previas; qué debe dejar listo para las siguientes;
 qué comparte entre Places/sistemas.]

================================================================================
7. OPTIMIZACIÓN
================================================================================
[Presupuesto de sesiones; qué NO sobrediseñar; patrones:
 - Evitar bucles while true; priorizar señales (GetPropertyChangedSignal).
 - No cargar lógica de fases posteriores.]

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[ ] [Prueba manual en Studio (Play Solo): ...]
[ ] [Prueba multiplayer — opcional/recomendada si aplica.]
[ ] [Nota en GDD/README: "R[N] completo".]
[ ] [Sin errores rojos en output.]
[ ] [Criterio anti-exploit / seguridad si aplica a la fase.]

================================================================================
9. ESTIMACIÓN
================================================================================
[N sesiones, con supuesto. Orientativo.]

================================================================================
10. DEPENDENCIAS
================================================================================
[HU-R[N-1] + RCs previos / "Ninguna. Primera fase".]

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
```

---

## Checklist de emisión (PM)

- [ ] HU formal existe y está alineada con GDD
- [ ] Defaults de la HU cerrados y citados en §5
- [ ] Nada en “Alcance SÍ” sin respaldo en HU/GDD
- [ ] Criterios §4 = Gherkin de la HU, verificables
- [ ] Estado y numeración (rcNNN) actualizados
- [ ] Guardado en `RCs/rc[NUM]-*.md` y/o entregado como comentario Luau
