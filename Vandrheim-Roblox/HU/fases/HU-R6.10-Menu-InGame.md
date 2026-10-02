## HU-R6.10: Menú in-game (ESC) — volver a selección de personaje + placeholders de ajustes

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** UI / Menú / R6.10  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Menú de pausa in-game (funcional parcial + placeholders)  
**Fase GDD:** R6.10 (posterior a R6.9; no modifica reglas de juego)  
**Depende de:** HU-R2 (CharacterSelect/CharacterCreate, DataService, spawnActiveCharacter), HU-R3.1 (cámara/drag), HU-R6.5 (ventanas UI)  
**Componentes observados:** `StarterGui.CharacterSelect`, `StarterGui.CharacterCreate`, `StarterGui.HUD`, `StarterPlayer.StarterPlayerScripts.CharacterClient`, `DataService` (perfil/PJ activo), `Remotes.RequestCharacterList`

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** abrir un menú in-game con la tecla `ESC`,  
**para** volver a la selección de personajes (y así crear/probar otra clase) o cerrar el menú y seguir jugando.

**Como** equipo,  
**quiero** dejar el esqueleto del menú con botones de **volumen, gráficos y orden de UI** como placeholders,  
**para** implementarlos después sin rehacer la ventana.

---

### **Descripción del Requerimiento / Contexto**

Hoy no existe menú in-game: `ESC` solo cierra el inventario si está abierto, y la única forma de cambiar de personaje es salir y volver a entrar al juego.

Esta HU agrega un **menú de pausa**:

* **Funcional ahora:** "Volver a la selección de personaje" — permite deseleccionar el PJ activo, volver a la pantalla de selección y elegir/crear otro personaje (útil para probar clases).
* **Placeholders (no funcionales):** "Configurar volumen", "Configurar gráficos", "Orden de UI" — botones visibles que muestran un aviso "Próximamente" y no abren ningún panel.
* Botón "Continuar" para cerrar el menú y seguir jugando.

El menú sigue el estándar de las ventanas del juego: pausa el drag de cámara, muestra el cursor normal y usa `Scale` + `UIAspectRatioConstraint`.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Menú in-game (`MenuUI`)**

* Nueva ScreenGui `StarterGui.MenuUI` (o `InGameMenu`), `Enabled=false` por defecto.
* Apertura:
  * PC: tecla `ESC` (toggle).
  * Móvil: botón visible en el HUD (ej. junto a BOLSA/EQUIPO) con ícono de menú/engranaje.
* Al abrir: pausar drag de cámara (`MouseBehavior = Default`) como las demás ventanas (R3.1); cerrar las ventanas abiertas (inventario/equipo si están abiertas) para evitar superposición; al cerrar, restaurar.
* Botones del menú:

| Botón | Comportamiento |
|-------|----------------|
| **Continuar** | Cierra el menú y reanuda el juego (funcional) |
| **Volver a la selección de personaje** | Funcional: flujo del punto 2 |
| Configurar volumen | **Placeholder**: feedback "Próximamente" |
| Configurar gráficos | **Placeholder**: feedback "Próximamente" |
| Orden de UI | **Placeholder**: feedback "Próximamente" |

* Los placeholders no guardan nada ni abren paneles; solo muestran el aviso y siguen visibles para el futuro.
* El menú no se abre en pantallas de creación/selección de PJ ni en el CharacterCreate.

#### **2. Volver a la selección de personaje (funcional)**

Flujo:

```text
Menu → "Volver a la selección de personaje"
  → cliente: RequestReturnToCharacterSelect (C→S)
  → server: guarda perfil, deselecciona PJ activo (activeCharacterId = nil)
  → server: confirma (ReturnToCharacterSelectResult)
  → cliente: oculta HUD/gui de juego, muestra CharacterSelect
  → cliente: RequestCharacterList (flujo R2) para refrescar slots
```

* **Remote nuevo:** `RequestReturnToCharacterSelect` (C→S) + `ReturnToCharacterSelectResult` (S→C `{ success, error? }`).
* Server (`DataService` o `CharacterService`):
  * Validar que el jugador tenga PJ activo y perfil cargado.
  * `SavePlayerProfile(player)` **antes** de deseleccionar (no perder nada).
  * `activeCharacterId = nil` en el perfil (los personajes creados **se conservan**; solo se deselecciona el activo).
  * Limpiar estado de sesión del PJ activo (`CharacterService.activePlayers[player] = nil`) para que el gate de spawn no interfiera.
  * Rechazar la operación si hay una run de dungeon activa (se debe abandonar primero) o si no hay PJ activo.
* Cliente (`CharacterClient`/nuevo `MenuClient`):
  * Al recibir éxito: desactivar HUD/gui de juego (inventario, skillbar, dungeon HUD, etc.), mostrar `CharacterSelect`, y disparar `RequestCharacterList` (R2).
  * El personaje en el mundo se desactiva/limpia según el flujo actual de selección (misma mecánica que el arranque: la pantalla de selección gobierna el spawn).
* **Regla anti-pérdida:** la selección/creación de un PJ nuevo no borra ni sobrescribe a los existentes (R2 ya lo garantiza con slots).

#### **3. Placeholders de ajustes**

* Botones visibles con estilo consistente; al pulsarlos, feedback breve "Próximamente" (reutilizar el patrón de `FeedbackLabel`).
* No crean paneles, sliders ni guardan valores.
* Volumen/Gráficos/Orden de UI quedarán marcados en la HU como **pendientes de diseño** (R9/polish o HU futura).

#### **4. Compatibilidad**

* `ESC` sigue cerrando inventario/equipo si están abiertos (comportamiento actual); si no hay ventanas abiertas, `ESC` abre el menú.
* No romper: CharacterSelect/CharacterCreate, HUD, skillbar, dungeon HUD, vendor, talentos.
* El menú no se puede abrir durante el teleport a la dungeon ni en la pantalla de "run terminada" (comportamiento actual de esas ventanas se mantiene).
* Móvil: botón de menú con `Scale` + `UIAspectRatioConstraint`.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: ESC abre el menú**

* **GIVEN** el jugador está en el juego con PJ activo
* **WHEN** presiona `ESC`
* **THEN** se abre `MenuUI`
* **AND** el cursor queda visible y la cámara pausa el drag

#### **Escenario 2: Continuar**

* **GIVEN** el menú abierto
* **WHEN** el jugador pulsa "Continuar" o `ESC` de nuevo
* **THEN** el menú se cierra
* **AND** el juego reanuda con el PJ intacto

#### **Escenario 3: Volver a selección**

* **GIVEN** el menú abierto con PJ activo (no en run)
* **WHEN** el jugador pulsa "Volver a la selección de personaje"
* **THEN** el server deselecciona el PJ activo (sin borrarlo)
* **AND** la pantalla de selección se muestra con los slots actualizados

#### **Escenario 4: Crear otro PJ**

* **GIVEN** la pantalla de selección tras volver
* **WHEN** el jugador crea/elige otro personaje
* **THEN** spawnea con ese PJ
* **AND** el PJ anterior sigue guardado en su slot (sin pérdida)

#### **Escenario 5: No en run**

* **GIVEN** el jugador está en una run de dungeon
* **WHEN** intenta volver a la selección
* **THEN** el server rechaza la operación con feedback claro ("abandona la run primero")
* **AND** no se deselecciona el PJ

#### **Escenario 6: Placeholders**

* **GIVEN** el menú abierto
* **WHEN** el jugador pulsa Volumen, Gráficos u Orden de UI
* **THEN** se muestra el aviso "Próximamente"
* **AND** no se abre ningún panel ni se guarda nada

#### **Escenario 7: Móvil**

* **GIVEN** un dispositivo táctil
* **WHEN** el jugador pulsa el botón de menú del HUD
* **THEN** el menú funciona igual que con `ESC`
* **AND** no rompe joystick ni la UI móvil

#### **Escenario 8: Regresión**

* **GIVEN** el menú implementado
* **WHEN** se revisa el flujo completo (jugar → menú → volver → crear PJ → jugar)
* **THEN** no hay errores rojos
* **AND** inventario, skills, dungeon, vendor y talentos siguen funcionando

---

### **Comportamiento Visual / Reglas de Negocio**

* Menú modal con título, botones y fondo consistente con la paleta Vandrheim.
* "Volver a la selección de personaje" debe sentirse seguro: nunca borra nada, solo deselecciona.
* Los placeholders están claramente visibles pero no confunden (aviso "Próximamente").
* El menú es solo UI: no cambia stats, inventario, oro ni progresión.

---

### **Alcance**

#### Incluye

* `MenuUI` (ScreenGui) con botones Continuar, Volver a selección, y placeholders Volumen/Gráficos/Orden de UI.
* Toggle con `ESC` (PC) y botón móvil.
* Remote `RequestReturnToCharacterSelect` + resultado (C→S/S→C).
* Deselección segura del PJ activo (save previo, sin borrado) y vuelta a `CharacterSelect`.
* Cierre de ventanas abiertas al abrir el menú; pausa/restauración de cámara.
* Feedback "Próximamente" para placeholders.

#### No incluye

* Implementación de volumen, gráficos u orden de UI (placeholders únicamente).
* Persistencia de ajustes en DataStore.
* Borrado de personajes (R2 ya lo cubre en CharacterSelect).
* Cambios a CharacterSelect/CharacterCreate existentes.
* Menú en la pantalla de selección/creación.

---

### **Definition of Done (DoD)**

* [ ] `ESC` abre/cierra el menú con cámara pausada y cursor visible.
* [ ] "Continuar" reanuda el juego.
* [ ] "Volver a la selección de personaje" deselecciona el PJ (guardado, sin borrar) y muestra CharacterSelect.
* [ ] Se puede crear/ elegir otro PJ y jugar con él; el anterior persiste.
* [ ] En run de dungeon, la operación se rechaza con feedback.
* [ ] Placeholders muestran "Próximamente" sin abrir paneles.
* [ ] Botón móvil de menú funciona sin romper la UI.
* [ ] Ventanas abiertas se cierran al abrir el menú.
* [ ] Sin errores rojos en jugar → menú → volver → crear → jugar.
* [ ] Nota `R6.10 completo` en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

1–2 sesiones: MenuUI + ESC/móvil + deselección segura del PJ + placeholders.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-R6.10: menú in-game con "volver a selección de personaje" funcional y placeholders de volumen/gráficos/orden de UI |