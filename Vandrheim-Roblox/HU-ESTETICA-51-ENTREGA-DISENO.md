# Entrega de Diseño — HU-ESTETICA-51: Sistema de Misiones (Pencil UI)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Retención
**Diseñador:** Diseñador / Productor de assets visuales
**Archivo canónico:** `Vandrheim-design.pen`
**Tablero Maestro en Pencil:** `HU-ESTETICA-51 — Sistema de Misiones (Hearthbound Gold)` (ID: `C3BmQ`)
**Estado:** Diseño aprobado por el PO (2026-10-31)

> **Regla de oro:** los diseños son **orientativos**. Lo que diga el juego, `QuestConfig`, `ItemConfig` y el detalle técnico de las HUs es lo que aplica. El dev no copia stats, nombres, oro, cantidad de pasos ni opciones de clase del mock si difieren del juego.

---

## 1. Frames aprobados (implementar)

| Frame | Node ID | Uso |
|---|---|---|
| `HU-ESTETICA-51 — Sistema de Misiones` | `C3BmQ` | Tablero maestro de referencia. |
| `FRAME_QUEST_TRACKER_PC_ACTIVE` | `U2DrUw` | Tracker en pantalla, **solo misión activa**; tarjetas secundarias **sin misiones** (si se conservan) y sin recompensas. |
| `FRAME_QUEST_TRACKER_PC_EMPTY` | `aWOwA` | Tracker sin misión activa: “Ver misiones [L]”. |
| `FRAME_QUEST_TRACKER_MOBILE` | `QEGTx` | Tracker móvil, **solo misión activa**; sin tarjetas secundarias con misiones. |
| `FRAME_QUEST_PANEL_CUADERNO_ACTIVE` | `S0b7Dv` | Panel completo de misiones (Cuaderno): activas, pendientes, completadas, detalle, pasos y recompensas. |
| `FRAME_QUEST_NPC_GUIA_STATE_STEP1_OFFER` | `XfaqE` | Guía, estado 1: ofrecimiento de la misión. |
| `FRAME_QUEST_NPC_GUIA_STATE_STEP2_WEAPON_CHOICE` | `CRR6f` | Guía, estado 2: **elección de arma dentro del mismo panel**; no hay modal aparte. |
| `FRAME_QUEST_NPC_GUIA_STATE_STEP6_TURN_IN` | `W9kgu` | Guía, estado 6: entrega/reclamo final. |
| `FRAME_QUEST_BADGES_DIFFICULTY_KIT` | `Acbwt` | Recurso de iconos/badges para el dev. |
| `FRAME_QUEST_WORLD_MARKERS_REFERENCE_3D` | `rjx7B` | Referencia de marcadores 3D. **No hay minimapa**; usar haz/icono/flecha de borde. |
| `FRAME_QUEST_SPECS_HANDOFF` | `kysdI` | Especificaciones y tokens para el dev. |

---

## 2. Frames descartados (no implementar)

Pueden seguir en el `.pen` como histórico, pero el dev no debe conectarlos:

- `d30mW` / `gZBNQ` — Quest Log simple.
- `BU1p8` / `qp9QI` — estados dedicados de mochila llena / límite.
- `eXLeb` / `Po3pN` — modales de selección de arma.
- `zAoa5` / `c1frb9` / `o0U3Y` — estados del modal de arma.
- `Vi0tu` — ejemplos de notificaciones nuevas.

Las notificaciones de misión usan el sistema centralizado existente, con sus títulos y colores de código.

---

## 3. Decisiones finales de UI

1. **Tracker:** solo la misión activa; tarjetas secundarias sin misiones (si se conservan), sin quest log y sin recompensas en el tracker.
2. **Detalle de misiones:** todo vive en el **Cuaderno** (`S0b7Dv`).
3. **Guía:** el panel `CRR6f` incluye la **elección de arma**; no se abre otro modal.
4. **Notificaciones:** reutilizar el sistema centralizado del juego.
5. **Contenido orientativo:** stats, nombres, oro, cantidad de pasos y opciones de clase salen del juego/config.

---

## 4. Handoff al dev

- Implementar `U2DrUw`/`QEGTx` (tracker solo activa) y `S0b7Dv` (panel).
- El Guía usa `XfaqE`, `CRR6f` y `W9kgu`; la elección de arma se renderiza en `CRR6f`.
- Reutilizar las notificaciones existentes para pasos, recompensa, mochila llena y límite.
- Usar `Acbwt`, `rjx7B` y `kysdI` como recursos; sin minimapa.
- Icono oficial para Micromenú HUD: `Assets/Icons/UI/Menu/Icon_Menu_quest.png` (512×512 RGBA, fondo transparente, coherente con `Icon_Menu_dungeon_guide.png` y la familia Hearthbound Gold).
- El detalle canónico de la quest (6 pasos, armas por clase, recompensa XP nivel 2 + 10 pociones) está en `HU/quest/HU-QUEST-02-Onboarding-Quest.md`.

---

## 5. Nota de sincronización

El `Vandrheim-design.pen` del repo todavía contiene las secciones de log, estados, modal de arma y notificaciones (20:31). Si en Pencil ya las quitaste, guardá/exportá el `.pen` para que el repo refleje solo lo aprobado. Si se conservan como histórico, la tabla de §1 sigue siendo la fuente de lo que se implementa.
