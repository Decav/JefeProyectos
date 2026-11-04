# HU-ITEMS-08: Joyería Helada y Toque de la Helada (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Items / Progresión / Combate
**Prioridad:** Media — identidad del tier Helada
**Estado:** Implementada (reporte del dev 2026-11-03; QA/verificación pendiente)
**Tipo:** Contenido de joyería + bono de tier con efecto de combate (dev)
**Fase GDD:** Itemización (complemento de ITEMS-03/04/05/07)
**Depende de:** HU-ITEMS-03 (bonos y `setId`), HU-ITEMS-04 (templates/tier), HU-ITEMS-05 (balance), HU-ITEMS-07 (joyería y conteo de tier), HU-R3/R8 (skills, daño y eventos de impacto), HU-R6.8 (VFX de combate), `InventoryService`, `CombatService`
**No modifica:** stats base existentes, economía, loot de armas ni los bonos de 3/4 piezas de armadura.

---

### Narrativa (INVEST)

**Como** jugador que consigue la joyería Helada,
**quiero** que llevar ambas piezas active un efecto propio del tier,
**para** que la joyería épica se sienta única y recompense encadenar habilidades.

**Como** equipo,
**quiero** un bono de 2 piezas con daño adicional y feedback visual claro,
**para** dar identidad al tier Helada sin romper el balance de combate.

---

### Descripción / Contexto

La armadura Helada tiene identidad por stats y por el bono de habilidad de 4 piezas. La joyería Helada, en cambio, quedaría como simples mejoras numéricas.

Esta HU le da un **bono de tier propio**: al equipar **ambas piezas** (collar Helada + anillo Helada), cada habilidad lanzada acumula cargas de **Escarcha Eterna**. Al llegar a 4 cargas se activa **Toque de la Helada**: un aura visible y, mientras dure, cada impacto de ataque básico o habilidad suma daño adicional.

**Criterio de hecho global:** con ambas piezas Helada equipadas, lanzar 4 habilidades activa el aura; durante su duración cada impacto suma daño extra calculado en servidor; al terminar, las cargas vuelven a cero y el ciclo puede repetirse.

---

### Especificaciones Técnicas / Contratos

#### 1. Piezas de joyería Helada

| Template | Slot | Rareza | levelReq | Stats | Icono |
|---|---|---|---|---|---|
| `collar_frost` — **Collar Glacial** | Collar | Epic | 16 | MaxHP 25 (±5), DEF 4 (±1), MDEF 3 (±1) | `Icon_Item_collar_frost` · `122632130926824` |
| `ring_frost_atk` — **Anillo de Filo Glacial** | Anillo | Epic | 16 | ATK 8 (±2), CRIT +4% | `Icon_Item_ring_frost` · `125276837628603` |
| `ring_frost_matk` — **Anillo Rúnico Glacial** | Anillo | Epic | 16 | MATK 8 (±2), CRIT +4% | `Icon_Item_ring_frost` · `125276837628603` |

* El anillo Helada también existe en variante ATK y MATK, igual que el resto de rarezas.
* Nombres: **Anillo de Filo Glacial** (ATK) y **Anillo Rúnico Glacial** (MATK).
* Sin modelo 3D: dato + icono, como la joyería existente.
* Iconos: PNG con fondo transparente; la rareza la pinta la casilla.
* Loot aprobado: **tirada extra e independiente** en el cofre del boss final, que no reemplaza el premio principal ni reduce su probabilidad.
* Reparto: collar 4%, `ring_frost_atk` 2%, `ring_frost_matk` 2% (8% total por cofre). Una sola tirada por apertura, idempotente por cofre.
* Porcentajes configurables; ITEMS-05 los ajusta con datos reales si la joyería tarda demasiado en aparecer.

#### 2. Escarcha Eterna (cargas)

* Requiere **ambas piezas Helada equipadas**: un collar `collar_frost` y un anillo `ring_frost_*` (cualquiera de las dos variantes).
* **+1 carga por habilidad lanzada** (skill de la barra que se ejecuta de verdad). No generan cargas los ataques básicos, consumibles, objetos ni casteos cancelados/sin maná.
* Máximo: **4 cargas**. El contador es server-authoritative.
* Sin ambas piezas, no se acumulan cargas; si se quita una, las cargas se pierden de inmediato.

#### 3. Toque de la Helada (activación)

* Al alcanzar **4 cargas**, se consumen y se activa **Toque de la Helada** durante `frostTouchDuration` (default **8 s**).
* Durante el efecto:
  * El personaje muestra un **aura de escarcha visible** (partículas/VFX) que destaque la activación.
  * Cada **impacto** de ataque básico o habilidad inflige daño adicional:
    `extraDamage = (ATK + MATK) × frostTouchPercent`, default **8%**.
  * En habilidades de área, el daño extra se aplica **por enemigo impactado**. Los ticks de DoT no lo reciben: solo el impacto.
  * El daño extra se calcula en servidor con las stats reales del atacante; nunca desde el cliente.
* Al expirar: el aura desaparece, el contador queda en 0 y las cargas vuelven a acumularse.
* **Mientras el aura está activa no se acumulan cargas** (evita cadenas infinitas).
* Si se desequipa una pieza, se cancela el aura y se resetean las cargas.
* Muerte, respawn, cambio de personaje o salida de la run: resetea cargas y aura.

#### 4. Interfaz

* Indicador de cargas de Escarcha Eterna junto al player frame o sobre la barra de skills: `Escarcha Eterna 2/4`.
* Durante el aura: indicador activo con el nombre **Toque de la Helada** y su tiempo restante.
* El aura visual no debe tapar el personaje ni la UI; legible en PC y móvil.
* Tokens de UI existentes; sin iconos nuevos obligatorios (placeholder si falta).

#### 5. Guardas de balance

* `frostTouchPercent` y `frostTouchDuration` son configurables; ITEMS-05 valida que el DPS extra no supere la banda del tier Helada frente a azul.
* Sin acumulación de auras: una activa a la vez.
* El daño extra no puede críticar de forma independiente ni aplicar efectos de set; es daño plano adicional.
* Anti-exploit: el servidor valida el casteo real y las stats; el cliente solo muestra el estado.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Cargas por habilidad

* **GIVEN** ambas piezas Helada equipadas
* **WHEN** el jugador lanza 3 habilidades válidas
* **THEN** el indicador muestra 3/4 cargas y el aura aún no se activa

#### Escenario 2: Activación

* **GIVEN** 3 cargas acumuladas
* **WHEN** lanza la cuarta habilidad válida
* **THEN** se consumen las 4 cargas y se activa Toque de la Helada con aura visible

#### Escenario 3: Daño adicional por impacto

* **GIVEN** Toque de la Helada activo
* **WHEN** el jugador golpea con ataque básico o habilidad
* **THEN** cada enemigo impactado recibe daño extra de `(ATK + MATK) × 8%`
* **AND** los ticks de DoT no reciben ese extra

#### Escenario 4: Fin del efecto

* **GIVEN** el aura activa
* **WHEN** pasa la duración configurada
* **THEN** el aura desaparece, el contador queda en 0 y las cargas vuelven a acumularse

#### Escenario 5: Sin acumulación durante el aura

* **GIVEN** Toque de la Helada activo
* **WHEN** el jugador lanza habilidades
* **THEN** no se acumulan cargas hasta que el aura termine

#### Escenario 6: Pieza retirada

* **GIVEN** cargas acumuladas o aura activa
* **WHEN** se desequipa el collar o el anillo Helada
* **THEN** las cargas se resetean y el aura se cancela

#### Escenario 7: Sin ambas piezas

* **GIVEN** solo una pieza Helada equipada
* **WHEN** el jugador lanza habilidades
* **THEN** no acumula cargas ni activa el efecto

#### Escenario 8: Anti-exploit

* **GIVEN** un cliente que intenta forzar cargas o daño
* **WHEN** el servidor valida el casteo y las stats
* **THEN** rechaza el estado falso y el daño extra solo sale de impactos server-validados

---

### Alcance

#### Incluye

* Templates `collar_frost`, `ring_frost_atk` y `ring_frost_matk` con stats, levelReq, icono y loot.
* Sistema de cargas de Escarcha Eterna y activación de Toque de la Helada (server-authoritative).
* Daño adicional por impacto y VFX de aura.
* Indicadores de cargas y de efecto activo.

#### No incluye

* Cambios a stats base, economía o bonos de armadura.
* Variantes adicionales de joyería ni nuevos iconos obligatorios.
* Efectos nuevos sobre otras habilidades o sets.

---

### Definition of Done (DoD)

* [ ] Joyería Helada creada (collar + anillo ATK/MATK) con stats, levelReq, icono y loot.
* [ ] Cargas de Escarcha Eterna por habilidad lanzada, máximo 4, server-authoritative.
* [ ] Toque de la Helada activa a 4 cargas, dura el tiempo configurado y muestra aura visible.
* [ ] Daño extra por impacto `(ATK + MATK) × %` en básicos y skills, por enemigo en AoE, sin DoT.
* [ ] Sin acumulación durante el aura; desequipar cancela y resetea.
* [ ] Indicadores de cargas/aura en PC y móvil; sin errores rojos.
* [ ] ITEMS-05 valida que el DPS extra no rompe la banda del tier Helada.

---

### Estimación (orientativa)

2–3 sesiones del dev: templates y loot, sistema de cargas, daño extra, VFX/UI y QA de balance.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-03 | Nombres de la joyería Helada: Anillo de Filo Glacial (ATK) y Anillo Rúnico Glacial (MATK). |
| 2026-11-03 | Decisiones PO: collar llamado **Collar Glacial**; loot del cofre = tirada extra de 8% (collar 4%, 2% por variante de anillo), independiente del premio principal. |
| 2026-11-03 | Creación de HU-ITEMS-08: joyería Helada con bono de tier propio — Escarcha Eterna (cargas por habilidad) y Toque de la Helada (aura + daño extra por impacto). |
| 2026-11-03 | Implementada según reporte del dev. Pendiente: QA en Studio/móvil y verificación de balance. |
