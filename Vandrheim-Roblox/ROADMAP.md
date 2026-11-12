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

**Base jugable:** R0–R9 con combate, progresión, inventario, dungeon de 5 pisos, jefes, loot, party/matchmaking y UI. R9 en cierre; **R9c diferida** (no bloqueante, decisión PO 2026-11-04).

**Implementado y validado funcionalmente (PO 2026-11-04):** R6.44, R6.45, R6.46, R6.10, R2.2, onboarding, quests, prólogo/TUTORIAL-02, ITEMS-07 e ITEMS-08. R8d confirmado 2026-10-23. R6.48 PoC aprobada; R6.47 con fix reportado y QA de audio pendiente. QA/performance pendiente.

**Implementado (reporte PO 2026-11-06), QA pendiente:** R6.49 (mapa/Hub), R6.50 (diaria), R6.51 (tienda rotativa) y R6.52 (NPCs ambientales). La decisión del mapa queda resuelta: el mapa nuevo es el Hub activo.

**Pendiente antes de beta:**

* R6.47 — QA de audio de Jotunn (fix reportado; confirmar en build).
* QA de R6.49–R6.52: mapa/Hub, diaria, tienda rotativa y NPCs ambientales.
* Performance móvil y pruebas de carga.
* QA/verificación final de lo implementado.
* Aprobación final del copy beta (`BETA_COPY.md`), thumbnail/icono y links.

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
| R6.44 | Geometría, reintento de jefes, muerto inerte | Implementado y validado funcionalmente (2026-11-04); QA pendiente |
| R6.45 | Pools del Jotunn, salto y reset de arena en party | Implementado y validado funcionalmente (2026-11-04); QA pendiente |
| R6.46 | Ajustes de skills por clase | Implementado (reporte PO 2026-11-04); QA pendiente |
| R6.47 | Música de Jotunn | Fix reportado; QA de audio pendiente |
| R8d | Balance nivel 20 | Completo (confirmación PO 2026-10-23) |
| R9c | Balance fino | Diferida; no bloqueante (decisión PO 2026-11-04) |
| R6.10 | Menú in-game ESC | Implementado y validado funcionalmente (2026-11-04); QA pendiente |
| R2.2 | Avatar starter + cabeza del jugador | Implementado y validado funcionalmente (2026-11-04); QA pendiente |
| — | Prólogo + onboarding + quests | Implementado y validado funcionalmente (2026-11-04); QA/performance pendiente |
| — | Performance móvil | Pendiente |

**P1 — deseable en beta, no bloqueante:**

* EST-02/03/05 si el diseñador entrega a tiempo.
* QoL de UI, sonidos y feedback.
* **Sistema de misiones (adelanto de R10+):** `QUEST-01` framework + `QUEST-02` onboarding; implementado y validado funcionalmente (2026-11-04). Ver `QUEST_SYSTEM.md` y `HU/quest/`.
* **Mapa/Hub (HU-R6.49):** implementado (reporte PO 2026-11-06); QA pendiente. El mapa nuevo es el Hub activo y la decisión del mapa queda resuelta.
* **Misiones diarias del Guía (HU-R6.50):** implementada (reporte PO 2026-11-06); QA pendiente. Polvo de escarcha (9 drops al 80 %) y cacería (6 enemigos normales, bandas por nivel; 12+ azul); 2 recompensas/día por personaje; abandonar permite reintentar, sin tablón. La racha de inicio de sesión queda como propuesta separada.
* **Tienda rotativa (HU-R6.51):** implementada (reporte PO 2026-11-06); QA pendiente. Mercader Errante con hasta 10 ítems/día por servidor compartido, 1 azul garantizado, azul extra 20 %, morado 3 % (máx. 1); pool morado limitado a joyería y armas del Jotunn; verdes de armadura/joyería, sin blancos; precios 700/1500/3000.
* **NPCs ambientales (HU-R6.52):** implementada (reporte PO 2026-11-06); QA pendiente. 8 aldeanos caminando en Valgard + 3 viajeros en los caminos; rutas server-side, sin interacción, sin target ni loot.
* **Valgard vivo (HU-R6.53 creada):** 9 NPCs nuevos + perro, 5 microescenas, props/audio, 6 POIs en caminos y 8 coleccionables de lore con persistencia por personaje; usa placeholders hasta la aprobación de EST-52.
* **Revisión de modelos nuevos (HU-ESTETICA-52 aprobada y entregada):** paquete de 6 NPCs R15 100% body skin, 14 props y 6 POIs en Workspace.TestPlace; niños y perro descartados por PO; fauna pasiva diferida a P1; arte aprobado para integración directa en R6.53.
* **Bonos del tier azul (2/4 piezas) y joyería:** implementados en ITEMS-07/08 (reporte PO 2026-11-04); QA pendiente. Ver `HU-ITEMS-07` y `HU-ITEMS-08`.
* **R6.48 PoC de mapa aprobada (2026-11-04):** el mapa de terreno pueblo + Helada ya es el Hub activo mediante HU-R6.49; el pipeline sirve como base de v2. QA de mapa pendiente.
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

* [ ] R6.44 verificada/QA (implementada y validada funcionalmente).
* [ ] R6.45 verificada/QA (implementada y validada funcionalmente).
* [ ] R6.46 verificada/QA (implementada según PO).
* [ ] R6.47 verificada/QA de audio (fix reportado).
* [ ] R8d completo; R9c diferida; monitoreo de balance en beta.
* [ ] R6.10, prólogo, onboarding y quests verificados (validados funcionalmente).
* [ ] R6.49–R6.52 verificadas/QA (mapa/Hub, diaria, tienda y NPCs ambientales).
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

### 3.2.1 Programa aprobado — Dopamina y mundo (post-beta/1.0)

**Aprobación PO:** 2026-11-12. No bloquea la beta actual; se implementa por sprints. Regla fija: **maestría de clase solo cosmética, sin daño ni stats**.

| Orden | HU | Contenido | Estado |
|---:|---|---|---|
| 1 | **R6.54** | Juice visual: level up dorado y loot con partículas; usa SFX existentes | Creada — lista para RC |
| 2 | **R6.55** | Mina Helada pública, enemigos existentes, vetas y diaria `mine` | Creada — lista para RC |
| 3 | **R6.56** | Red de piedras rúnicas, naufragio y viaje por 100 de oro | Creada — lista para RC |
| 4 | **R6.57** | Endless de la Helada, oleadas infinitas, récord y leaderboard semanal | Creada — lista para RC |
| 5 | **R6.58** | Logros y títulos visibles, solo cosméticos | Creada — lista para RC |
| 6 | **R6.59** | Bestiario/Codex con enemigos, lore y lugares | Creada — lista para RC |
| 7 | **R6.60** | Maestría de clase cosmética, sin poder | Creada — lista para RC |
| 8 | **R6.61** | Caravanas atacadas y campamentos enemigos | Creada — lista para RC |
| — | **EST-53** | Revisión de modelos de mina, runas, naufragio, eventos y maestría | Creada — lista para revisión |

**Secuencia:** R6.53 (POIs/coleccionables) y R6.54 primero; R6.55/R6.56 en paralelo; R6.57/R6.58 después; R6.59/R6.60 y R6.61 al final. R6.53 es dependencia de R6.55/R6.56/R6.59/R6.61. EST-53 corre en paralelo y no bloquea la lógica.

**Reglas:** sin pay-to-win; leaderboard con recompensas cosméticas; el Endless reemplaza la Cámara semanal; el teleport va a la entrada de la dungeon, nunca dentro de una run; los minerales de la mina no se acumulan fuera de la diaria.

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
| P2 | **Dificultades de dungeon** | Modos normal/heroico o escalado configurable | Balance R8d + datos de beta |
| P2 | **Oleadas PvE infinitas** | Aprobado: HU-R6.57 (Endless con récord y leaderboard semanal) | Beta estable |
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
| 2026-11-04 | **Validación funcional del PO:** tutorial, quests y prólogo funcionan; R9c se difiere por balance suficiente; R6.48 PoC de mapa aprobada; único bug abierto R6.47 (música de Jotunn). |
| 2026-11-04 | **HUs R6.49/R6.50/R6.51 creadas:** integración del mapa como Hub activo con zonas/banners; ácaros + misiones diarias del Guía (polvo de escarcha/cacería, 2 recompensas/día por personaje; abandonar permite reintentar); Mercader Errante con tienda rotativa diaria compartida por servidor. |
| 2026-11-05 | **HU-R6.52 creada:** NPCs ambientales caminando (8 aldeanos en Valgard + 3 viajeros en caminos), server-side, sin interacción, sin target ni loot; rutas con waypoints, pausas y recuperación, sin aparecer en dungeon. |
| 2026-11-06 | **R6.49–R6.52 implementadas (reporte PO 2026-11-06):** mapa/Hub integrado, diaria, tienda rotativa y NPCs ambientales; decisión de mapa resuelta. QA de las cuatro pendiente; R6.47 con fix reportado y QA de audio pendiente. |
| 2026-11-06 | **HU-R6.53 y HU-ESTETICA-52 creadas:** Valgard vivo (NPCs con rutinas, microescenas, props/audio, POIs y coleccionables) y compuerta de revisión de modelos nuevos para integrar arte final. |
| 2026-11-12 | **Programa Dopamina y mundo aprobado:** HUs R6.54–R6.61 + EST-53 creadas. Incluye juice, mina/diaria, piedras rúnicas, Endless semanal, logros/títulos, Codex, maestría cosmética y eventos de caravana/campamento. Maestría sin stats por decisión PO. |
| 2026-11-06 | **HU-ESTETICA-52 aprobada y entregada:** staging completo en Studio (6 NPCs R15, 14 props, 6 POIs); niños y perro descartados por PO; fauna diferida a P1; arte listo para HU-R6.53. |
