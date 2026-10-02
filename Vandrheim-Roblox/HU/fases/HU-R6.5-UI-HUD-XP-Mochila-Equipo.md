## HU-R6.5: UI — Barra de XP en HUD, mochila (B) y equipo (C) separados + panel de stats

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** UI / HUD / Inventario  
**Prioridad:** Alta  
**Estado:** Completada (implementada; reporte equipo 2026-08-26)  
**Tipo:** Mejora de interfaz (posterior a R6.4; no amplía reglas de juego)  
**Fase GDD:** R6.5 (mejora de UI; puede ejecutarse en paralelo con EST-01/R7)  
**Depende de:** HU-R4 (InventoryUI), HU-R5.2 (stacking/cantidades), HU-R6a (XP/leveling), HU-R6.2 (slots de uso Z/X)  
**Componentes observados:** `StarterGui.HUD.PlayerFrame` (PlayerName, PlayerHPBar, PlayerMPBar, GoldFrame), `StarterGui.InventoryUI.MainFrame` (EquipmentPanel con slots Helmet..OffHand + BagPanel/BagScroll), `StarterPlayer.StarterPlayerScripts.InventoryClient`, `StarterGui.HUD.HUDClient`, `ServerScriptService.Services.XPService`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** ver mi progreso de experiencia del nivel actual en el frame del jugador,  
**para** saber cuánto falta para el siguiente nivel.

**Como** jugador,  
**quiero** abrir la mochila y el equipo por separado, con casillas de equipo más grandes, etiquetas claras y mis estadísticas visibles,  
**para** revisar mi build sin que la ventana se vea apretada ni confusa.

---

### **Descripción del Requerimiento / Contexto**

Estado actual verificado en Studio:

* `PlayerFrame` muestra nombre+clase+nivel, HP, MP y oro, pero **no hay barra de XP**. La XP vive solo en el profile del server (`activeChar.xp`) y **no se expone al cliente**.
* `InventoryUI.MainFrame` combina `EquipmentPanel` (9 slots con `SlotLabel` + `ItemName`) y `BagPanel` (20 casillas) en una sola ventana con la tecla `B`.
* En el `EquipmentPanel` los iconos son pequeños y quedan apretados; el texto `ItemName` queda debajo del slot y no hay un separador visual que vincule la etiqueta con su casilla.
* No existe una vista de estadísticas del personaje en ninguna ventana.

Esta HU reordena la UI sin cambiar ninguna regla de juego: los remotes, la autoridad del server, el inventario y las stats siguen igual.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Barra de XP en el PlayerFrame**

**Server (exposición de datos):**

* `XPService.GrantXP`: al finalizar, actualizar los atributos del jugador:
  ```luau
  player:SetAttribute("CharacterXP", activeChar.xp)
  player:SetAttribute("CharacterXPReq", getXpReq(activeChar.level))
  ```
* `CharacterService.spawnActiveCharacter` y el respawn (`onCharacterAdded`): setear los mismos atributos al cargar el personaje (XP actual + requerida del nivel).
* La fórmula sigue siendo `xpReq(nivel) = nivel * 100` (constante de `XPService`); el cliente **no** la calcula ni la decide.
* Los atributos se actualizan cada vez que cambia la XP o el nivel; no se agregan remotes nuevos.

**Client (HUD):**

* Agregar a `StarterGui.HUD.PlayerFrame` un `PlayerXPBar` con la misma familia visual que `PlayerHPBar`/`PlayerMPBar`:
  * `PlayerXPFill` (Frame) — ancho proporcional `XP / XPReq`.
  * `PlayerXPText` (TextLabel) — texto `"XP: actual / requerida"`.
  * Colores diferenciados (sugerido: ámbar/gris azulado) y `UIAspectRatioConstraint` coherente con el frame.
* `HUDClient`: bindear a `GetAttributeChangedSignal("CharacterXP")` y `"CharacterXPReq"`; recalcular ratio con clamp 0–1.
* Ajustar la altura/layout del `PlayerFrame` para no superponer XP, HP, MP ni oro.
* El nivel sigue mostrándose en `PlayerName` como hasta ahora.

#### **2. Separar mochila y equipo**

Se divide en **dos ventanas independientes**:

| Ventana | Contenido | Apertura |
|---------|-----------|----------|
| `InventoryUI` (existente, simplificada) | Solo `BagPanel` (20 casillas + cantidades `xN` de R5.2) | Tecla `B` / botón móvil "BOLSA" |
| `EquipmentUI` (nueva ScreenGui) | `EquipmentPanel` (9 slots) + `StatsPanel` + `CloseButton` | Tecla `C` / botón móvil "EQUIPO" |

Decisiones de implementación:

* Se recomienda crear `EquipmentUI` como ScreenGui nueva y reducir `InventoryUI` a la bolsa; el `InventoryClient` refactoriza sus refs (mochila y equipo apuntan a ventanas distintas) pero **conserva todos los remotes y handlers existentes** (`RequestInventory`, `RequestEquipItem`, `RequestUnequipItem`, `RequestDropItem`, `RequestUseConsumable`, `RequestAssignItemUseSlot`, `InventoryData`, `LootReward`, `RewardPopup`).
* `InventoryData` sigue alimentando ambas ventanas; `renderBag` y `renderEquipment` siguen existiendo, cada una con su propia ventana.
* `Tooltip` y `FeedbackLabel`: si quedan dentro de `InventoryUI`, moverlos a un ScreenGui compartido (`SharedUI`/`TooltipUI`) o duplicarlos para `EquipmentUI`; **no** romper las referencias de `InventoryClient` al tooltip.
* Escenarios de apertura:
  * `B` abre/cierra la mochila.
  * `C` abre/cierra el equipo.
  * `Escape` cierra las dos si están abiertas.
  * Abrir una no cierra la otra obligatoriamente; ambas ventanas pausan el drag de cámara (R3.1) como la actual.
* Móvil: botones `BOLSA` y `EQUIPO` en el HUD (mismo estilo que el botón actual de inventario).

#### **3. Rediseño del EquipmentPanel**

* **Iconos más grandes:** cada slot muestra el icono del ítem ocupando la mayor parte de la casilla (ej. `UDim2.new(0.9, 0, 0.75, 0)` centrado), manteniendo `ZIndex` y sin pisar la cantidad ni el estado.
* **Etiqueta con separador:** cada casilla conserva su `SlotLabel` ("Casco", "Pecho", "Hombros", "Piernas", "Guantes", "Anillo", "Collar", "Mano principal", "Mano secundaria"), pero ahora se estructura como cabecera:
  * Área superior: `SlotLabel` con fondo sutil.
  * **Separador visual** (Frame delgado `UIStroke`/línea) entre la cabecera y el contenido.
  * Zona de icono debajo del separador.
  * El `ItemName` (oculto hoy en `renderEquipment`) puede volver como pie de casilla con el nombre del ítem equipado, dentro de un área delimitada (no flotando).
* El layout del panel debe permitir 9 casillas legibles (se puede hacer 3 columnas × 3 filas u otra distribución aprobada) con espacio para las cabeceras.
* Mantener los nombres de instancias (`Helmet`, `Chest`, …, `OffHand`, `ItemIcon`, `SlotLabel`, `ItemName`) para no romper `InventoryClient` y los clicks de equipar/desequipar.

#### **4. Panel de estadísticas (StatsPanel)**

Ubicación: dentro de `EquipmentUI`, sección `StatsPanel`.

* Muestra las stats actuales del personaje desde atributos del character:
  * Vida (`MaxHP` del Humanoid)
  * Maná (`MaxMP`)
  * Ataque (`ATK`)
  * Ataque mágico (`MATK`)
  * Defensa (`DEF`)
  * Defensa mágica (`MDEF`)
  * Crítico (`CRIT`)
* `InventoryClient` (o un LocalScript dedicado `StatsPanelClient`) refresca las líneas con `GetAttributeChangedSignal` para `MaxMP/ATK/MATK/DEF/MDEF/CRIT` y `GetPropertyChangedSignal("MaxHealth")` del Humanoid; no usar polling pesado.
* Formato por línea sugerido: `"Ataque: 12"`, `"Defensa: 8"`, etc., con la misma paleta de la UI (dark warm + dorado).
* Es solo lectura: no se editan stats desde la UI.

#### **5. Reglas de negocio y compatibilidad**

* Ninguna regla de juego cambia: equipar/desequipar/usar/vender siguen igual (server-authoritative).
* `RequestUseItemSlot` (Z/X de R6.2) y el cast de skills no dependen de estas ventanas; no modificar `SkillBar`, `SpellbookUI`, `VendorUI` ni `TalentUI`.
* La ventana de recompensa (loot popup) y los feedbacks se conservan.
* PC primero; móvil con `Scale` + `UIAspectRatioConstraint` y sin romper `TouchEnabled`.
* Abrir ventanas pausa el drag de cámara (R3.1) y restaura el `MouseBehavior` al cerrar.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Barra de XP visible**

* **GIVEN** un personaje activo con XP
* **WHEN** carga el HUD
* **THEN** `PlayerFrame` muestra una barra de XP
* **AND** el ancho del fill refleja `XP / XPReq` del nivel actual

#### **Escenario 2: XP avanza**

* **GIVEN** el jugador mata enemigos
* **WHEN** `XPService` otorga XP
* **THEN** el fill y el texto de XP se actualizan sin reiniciar la sesión
* **AND** al subir de nivel, la barra se resetea al progreso del nivel nuevo

#### **Escenario 3: Rejoin con XP persistida**

* **GIVEN** un personaje con XP guardada
* **WHEN** el jugador vuelve a entrar o respawnea
* **THEN** la barra muestra la XP y requerida correctas desde el profile

#### **Escenario 4: B abre solo la mochila**

* **GIVEN** el jugador presiona `B`
* **WHEN** se abre la ventana
* **THEN** solo se ve la mochila con las 20 casillas
* **AND** no se ve el panel de equipo

#### **Escenario 5: C abre el equipo**

* **GIVEN** el jugador presiona `C`
* **WHEN** se abre la ventana
* **THEN** se ven los 9 slots de equipo
* **AND** se ve el `StatsPanel` con las stats del personaje

#### **Escenario 6: Cerrar con Escape**

* **GIVEN** mochila y/o equipo abiertos
* **WHEN** el jugador presiona `Escape`
* **THEN** ambas ventanas se cierran
* **AND** el drag de cámara se restaura

#### **Escenario 7: Iconos de equipo legibles**

* **GIVEN** el equipo tiene ítems equipados
* **WHEN** se abre `EquipmentUI`
* **THEN** cada icono ocupa una proporción clara de su casilla
* **AND** no se ve apretado ni cortado

#### **Escenario 8: Etiquetas con separador**

* **GIVEN** el `EquipmentPanel`
* **WHEN** se inspecciona una casilla
* **THEN** el `SlotLabel` está en la cabecera
* **AND** existe un separador visual entre cabecera y contenido
* **AND** el nombre del ítem (si aplica) está en un área delimitada, no flotando

#### **Escenario 9: Stats correctas y vivas**

* **GIVEN** el jugador equipa/desequipa un ítem
* **WHEN** cambian sus stats
* **THEN** `StatsPanel` refleja los nuevos valores
* **AND** los valores coinciden con los del server (atributos)

#### **Escenario 10: Equipar/desequipar desde equipo**

* **GIVEN** la ventana de equipo abierta
* **WHEN** el jugador hace click en una casilla ocupada o derecha para desequipar
* **THEN** la acción funciona igual que antes de esta HU
* **AND** no hay errores rojos en el flujo

#### **Escenario 11: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** se usan los botones `BOLSA` y `EQUIPO`
* **THEN** cada uno abre su ventana
* **AND** la UI se ve proporcionada sin romper joystick ni cámara

#### **Escenario 12: Regresión**

* **GIVEN** las ventanas refactorizadas
* **WHEN** se revisa el output tras abrir/cerrar, equipar, usar ítems y matar enemigos
* **THEN** no hay errores rojos
* **AND** vendor, spellbook, talentos, skillbar y dungeon siguen funcionando

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* `PlayerXPBar` debe distinguirse de HP/MP (ej. color ámbar/azulado) y no tapar `PlayerName` ni `GoldFrame`.
* Mochila y equipo son ventanas distintas: títulos claros ("Mochila" / "Equipo") y botón de cerrar en ambas.
* La casilla de equipo tiene tres zonas visuales: cabecera con etiqueta, separador y contenido (icono + nombre del ítem).
* El `StatsPanel` es solo lectura y usa la paleta Vandrheim; si una stat no tiene atributo, se omite sin error.
* Los valores XP se leen de atributos del jugador; el cliente nunca calcula la fórmula ni la modifica.
* No se agregan remotes nuevos; no se cambian contratos de inventario.

---

### **Alcance**

#### Incluye

* Atributos server `CharacterXP` / `CharacterXPReq` (en `XPService` y `CharacterService`).
* `PlayerXPBar` + bind en `HUDClient`.
* Separación de `InventoryUI` (solo bolsa, tecla `B`) y `EquipmentUI` (equipo + stats, tecla `C`).
* Refactor de `InventoryClient` manteniendo remotes y handlers actuales.
* Rediseño de casillas de equipo: iconos grandes, `SlotLabel` en cabecera, separador y `ItemName` delimitado.
* `StatsPanel` con HP, MP, ATK, MATK, DEF, MDEF y CRIT desde atributos.
* Botones móviles `BOLSA` y `EQUIPO`.
* Escape cierra ambas; drag de cámara pausado/restaurado (R3.1).
* Tooltip/feedback disponibles en ambas ventanas sin romper referencias.

#### No incluye

* Cambios a reglas de inventario, stats, XP, loot, economía ni equipamiento.
* Remotes nuevos o cambios de autoridad server.
* Modificar `VendorUI`, `TalentUI`, `SpellbookUI`, `SkillBar`, `DungeonHUD` o `CharacterSelect/Create`.
* Sistema de gearscore, comparación de ítems o recomendación de build.
* Drag & drop de ítems entre bolsa y equipo.
* Persistencia de posición/tamaño de ventanas en DataStore.
* Edición de stats desde la UI.

---

### **Definition of Done (DoD)**

* [ ] `PlayerFrame` muestra barra de XP con fill y texto `XP/XPReq`.
* [ ] XP y requerida se exponen como atributos del jugador y se actualizan al ganar XP y al subir de nivel.
* [ ] La barra es correcta tras spawn, respawn y rejoin.
* [ ] `B` abre solo la mochila.
* [ ] `C` abre el equipo con los 9 slots + `StatsPanel`.
* [ ] `Escape` cierra ambas y restaura la cámara.
* [ ] Botones móviles `BOLSA`/`EQUIPO` funcionan.
* [ ] Los iconos de equipo se ven grandes y sin apretar.
* [ ] Cada casilla tiene cabecera con etiqueta + separador visual.
* [ ] `ItemName` no queda flotando: tiene zona propia.
* [ ] `StatsPanel` muestra valores correctos y se actualiza al equipar/desequipar.
* [ ] Equipar/desequipar/usar ítems siguen funcionando desde sus ventanas.
* [ ] Sin errores rojos en output (abrir/cerrar, equipar, matar, rejoin).
* [ ] Vendor, spellbook, talentos, skillbar y dungeon sin regresiones.
* [ ] Nota `R6.5 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

2–3 sesiones: atributos de XP + barra, separación de ventanas, refactor del cliente de inventario, rediseño de casillas, StatsPanel y regresión PC/móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-R6.5: barra de XP, mochila (B) y equipo (C) separados, casillas rediseñadas y panel de stats |
| 2026-08-26 | Marcada completada según reporte del equipo |