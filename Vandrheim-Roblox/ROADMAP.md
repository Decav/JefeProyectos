# Vandrheim — Roadmap de producto

**Proyecto:** Vandrheim (Roblox)
**Dueño:** PM / PO
**Última actualización:** 2026-10-27
**Fuente de alcance:** `GDD_ROBLOX_MVP.md` §3, §14 y §20
**Estado:** preparación de beta abierta (decisión PO 2026-10-27)

> Este roadmap ordena el futuro del producto; **no reemplaza el GDD**. Las HUs se crean solo cuando el alcance se aprueba. Las fechas son orientativas y no comprometidas: primero capacidad, después calendario.

---

## 1. Decisiones cerradas

| Tema | Decisión |
|---|---|
| IP / juego | **Vandrheim** |
| Juego base | **La Helada** |
| Lanzamiento | **Beta abierta**, no 1.0 |
| Expansiones | **Gratis**, dentro del mismo experience |
| Primera expansión | **v2 — bioma de fuego/lava** |
| Monetización | Cosmética/conveniencia; sin pay-to-win ni acceso pago a expansiones |
| Contenido base | 5 pisos, 3 clases, 6 especializaciones, 30 habilidades, nivel 20 |
| Modelo de actualizaciones | Expansión con nombre + mini-actualizaciones con contenido acotado |

---

## 2. Estado actual (resumen)

**Base jugable:** R0–R9 con combate, progresión, inventario, dungeon de 5 pisos, jefes, loot, party/matchmaking y UI. R9 en cierre (R9c pendiente).

**Implementado (reporte PO 2026-10-27; QA/verificación pendiente):** R6.44, R6.10, R2.2 y onboarding. R8d confirmado 2026-10-23.

**Pendiente antes de beta:**

* R6.45 — pools del Jotunn, salto tras revivir y reset de arena en party.
* R9c — balance fino.
* Performance móvil y pruebas de carga.
* QA/verificación de R6.44, R6.10, R2.2 y onboarding.
* Copy de lanzamiento en modo **beta**.

**Pendiente para 1.0:**

* EST-02/03/05 (enemigos, pueblo, arco) y pulido visual restante.
* Localización (decisión ES/EN).
* Métricas, soporte, moderación y política de datos.
* Criterios de salida de beta.

---

## 3. Fases

### 3.1 Beta abierta (ahora)

**Objetivo:** validar el loop completo con jugadores reales, encontrar bloqueantes y medir retención antes de comprometer un 1.0.

**Incluye:**

* Loop completo: crear PJ → hub → 5 pisos → jefe → cofre → recompensa → hub.
* Solo y party de 1–4; PC y móvil.
* 3 clases, 6 specs, 30 habilidades, loot, sets y nivel 20.
* Monetización de conveniencia existente, con copy claro y sin pay-to-win.
* Canales de feedback: `#reportar-bugs` e `#ideas-y-feedback`.

**P0 — bloqueantes de beta:**

| ID | Tema | Estado |
|---|---|---|
| R6.44 | Geometría, reintento de jefes, muerto inerte | Implementado (reporte PO 2026-10-27; QA pendiente) |
| R6.45 | Pools del Jotunn, salto y reset de arena en party | Abierta; implementación pendiente |
| R8d | Balance nivel 20 | Completo (confirmación PO 2026-10-23) |
| R9c | Balance fino | Pendiente |
| R6.10 | Menú in-game ESC | Implementado (reporte PO 2026-10-27; QA pendiente) |
| R2.2 | Avatar starter + cabeza del jugador | Implementado (reporte PO 2026-10-27; QA pendiente) |
| — | Onboarding/tutorial | Implementado (reporte PO 2026-10-27; QA pendiente) |
| — | Performance móvil | Pendiente |

**P1 — deseable en beta, no bloqueante:**

* EST-02/03/05 si el diseñador entrega a tiempo.
* QoL de UI, sonidos y feedback.
* **Sistema de misiones (adelanto de R10+):** `QUEST-01` framework + `QUEST-02` onboarding; ver `QUEST_SYSTEM.md` y `HU/quest/`. Objetivo: retención de primera sesión.
* **Quest diaria + racha de inicio de sesión (propuesta PO 2026-10-27):** reutiliza `QUEST-01` para dar un motivo de retorno diario con recompensa creciente. HU a crear cuando se apruebe el alcance.
* **Bonos del tier azul (2/4 piezas) y joyería (propuesta):** bonos de solo estadísticas al armar 2 y 4 piezas azules (armadura + joyería azul), con collares y anillos por tier. La joyería Helada se define aparte. Ver `HU-ITEMS-07`.
* Dificultades de dungeon y oleadas (si no retrasan P0).

**Criterios de salida de beta (para pasar a 1.0):**

* Cero bugs P0 abiertos durante 7 días consecutivos.
* Run completa sin softlocks en solo y party, PC y móvil.
* 6 specs viables a nivel 20; sin spec dominante.
* R6.10 y onboarding completos; controles claros.
* Performance estable en móvil de gama baja; sin caídas críticas.
* Compras idempotentes y sin grants perdidos.
* Sin pérdida de datos; backup/restore probado.
* D1/D7 con baseline de beta y objetivo acordado antes de 1.0.
* Canales de soporte y parches con cadencia definida.

**Checklist de apertura:**

* [ ] R6.44 verificada/QA (implementada según PO).
* [ ] R6.45 implementada y QA.
* [ ] R8d completo; R9c cerrado o con riesgo aceptado por el PO.
* [ ] R6.10 y onboarding verificados (implementados según PO).
* [ ] R2.2 verificada (implementada según PO).
* [ ] Copy de Roblox y Discord en modo beta.
* [ ] Analítica de Roblox activada (funnel, retención, crashes).
* [ ] Moderación y soporte cubiertos.
* [ ] Política de datos y compras publicada.
* [ ] Known issues y plan de rollback.
* [ ] Anuncios de beta programados.

### 3.2 1.0 — lanzamiento estable

**Objetivo:** convertir la beta en el lanzamiento oficial de la Helada.

**Criterios:**

* Todos los criterios de salida de beta cumplidos.
* Contenido base completo y pulido (incluye assets pendientes).
* Balance validado con datos de beta.
* Copy, tienda y experiencia de Roblox listos para release.
* Campaña de lanzamiento y anuncios de 1.0.

**No incluye:** contenido de la expansión de fuego; eso es v2.

### 3.3 v2.0 — Fuego/Lava (primera expansión gratuita)

**Objetivo:** abrir un bioma nuevo con identidad propia y una razón para volver.

**Hero feature:** bioma de fuego/lava con dungeon, enemigos, jefe y loot propios.

**Incluye (propuesta):**

* Nuevo bioma y ambientación (fuego/lava).
* Dungeon nueva o variante mayor con jefe propio.
* Enemigos, élite y mini-jefes del bioma.
* Loot, sets y cosméticos temáticos.
* Subida de nivel máximo (a definir: 25/30).
* Mini-actualizaciones v2.x con contenido acotado.

**No incluye:** clase nueva, PvP ni mundo abierto; eso va después.

### 3.4 Post-1.0 — backlog priorizado

> Orden propuesto, sujeto a capacidad y a datos de beta. No son HUs comprometidas.

| Prioridad | Tema | Qué implica | Depende de |
|---|---|---|---|
| P2 | **v2.0 Fuego/Lava** | Bioma, dungeon, jefe, loot, nivel máximo | 1.0 estable |
| P2 | **Profesiones** | Sistema horizontal de recolección/crafting o equivalente; no reemplaza combate | Economía e inventario estables |
| P2 | **Dificultades de dungeon** | Modos normal/heroico o escalado configurable | Balance R8d/R9c |
| P2 | **Oleadas PvE infinitas** | Modo repeatable con recompensas y ranking simple | Combate y balance estables |
| P2 | **Clase nueva: Templario** | Clase + specs + skills + talentos + assets | 1.0 y pipeline de clases |
| P2 | **Subidas de nivel** | Nuevo cap y contenido por expansión | Cada expansión |
| P3 | **PvP** | Modo, mapas, balance aparte, anti-abuse | Balance PvE y clase nueva |
| P3 | **Clase nueva: Cambiaformas** | Clase + specs + skills + talentos + assets | Templario y capacidad |
| P3 | **Semi-mundo abierto** | Nuevos biomas, enemigos/bosses de mundo, misiones | 1.0 + v2 |
| P3 | **Personalización de PJ** | Más opciones cosméticas sin romper el equipo | Sistema de avatar estable |
| P3 | **Cosméticos y efectos** | Skins, auras, títulos, VFX/SFX | Monetización estable |
| P3 | **Localización** | ES/EN u otros idiomas | Copy y UI estables |

**Notas de secuencia:**

* **Profesiones** es un sistema; no debe competir con la expansión de fuego por capacidad.
* **PvP** requiere balance separado y no debe lanzarse antes de estabilizar PvE.
* **Semi-mundo abierto** es el ítem más grande del backlog; no se compromete hasta después de v2.
* Las **clases nuevas** (Templario, Cambiaformas) están en GDD §3 como post-MVP; cada una necesita su propia épica.

---

## 4. Reglas de priorización

1. **P0 primero:** nada de contenido nuevo mientras haya bloqueantes de beta.
2. **Beta = validar, no prometer:** el feedback y las métricas mandan sobre el roadmap.
3. **Una hero feature por actualización:** evita expansiones infladas.
4. **Sin fechas sin capacidad:** primero alcance y dependencias, después calendario.
5. **Gratis no significa sin costo:** cada expansión debe justificar su producción con retención/monetización cosmética.
6. **No romper el loop base:** loot, XP, economía, party y guardado son no negociables.

---

## 5. Gobernanza del roadmap

* Una idea entra como **propuesta** (problema, propuesta, impacto, dependencias).
* El PO decide si pasa a **backlog priorizado** o se descarta.
* Solo cuando se aprueba el alcance se crea la **HU** (y su RC, si aplica).
* Al cerrar cada fase se actualiza este roadmap y el historial del GDD.
* Los cambios de alcance se registran; no se sobrescribe el pasado.

---

## 6. Enlaces

* GDD: `GDD_ROBLOX_MVP.md` (§3 clases post-MVP, §14 fases, §16 métricas, §20 próximo paso).
* HUs: `HU/fases/`, `HU/estetica/`, `HU/items/`, `HU/assets/`, `HU/publicacion/`, `HU/tutorial/`.
* Anuncios de beta: `bots/DCVStudioOrganizer/HU/HU-BOT-01-Anuncios-Lanzamiento.md`.
* Beta y copy: `BETA_COPY.md` (a crear) y `HU-BOT-01` Anexo A (a actualizar a beta).

---

## 7. Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación del roadmap: decisión de beta abierta, ruta beta → 1.0 → v2 Fuego/Lava, backlog post-1.0 con profesiones, clases, niveles, biomas, PvP, mundo abierto y sistemas de retención. |
| 2026-10-27 | Se anotan dos propuestas: quest diaria + racha (retención) y afinidad de clase del tier azul (`HU-ITEMS-07`). |
