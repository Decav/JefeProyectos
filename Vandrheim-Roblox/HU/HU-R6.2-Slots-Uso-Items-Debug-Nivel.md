## HU-R6.2: Slots rápidos de uso de ítems y reset de nivel debug

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Inventario / Input / Herramientas de QA  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Fase GDD:** R6.2 (pulido posterior a R6.1 y previo a R7)  
**Depende de:** HU-R5 (uso de ítems y pociones), HU-R5.1 (HUD/loadout), HU-R5.2 (stacking), HU-R6.1 (input/UI de movimiento)  
**Alcance debug:** solo Studio/test; nunca producción

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** asignar hasta dos ítems utilizables a botones rápidos y activarlos con `Z` y `X`,  
**para** usar pociones u otros ítems compatibles sin abrir el inventario durante el combate.

**Como** desarrollador/QA,  
**quiero** un botón de debug que restablezca el personaje al nivel 1,  
**para** probar nuevamente la progresión natural de XP, talentos, skills y estadísticas.

---

### **Descripción del Requerimiento / Contexto**

El sistema actual permite usar consumibles mediante el flujo de R5, pero no tiene slots rápidos en el HUD. Esta HU agrega **dos slots genéricos de uso de ítems**, no limitados por nombre o tipo a pociones. Solo los ítems que `ItemConfig` marque como utilizables pueden asignarse.

Los slots deben trabajar con stacking: un slot apunta al `templateId` del ítem y el servidor consume una unidad de una pila disponible. Si la cantidad llega a cero, el slot permanece asignado pero se muestra vacío/no disponible hasta que el jugador obtenga otra unidad.

También agrega un control de debug para restablecer la progresión del personaje activo al nivel 1. El reset no borra inventario ni equipo y no existe en servidores de producción.

---

### **Especificaciones Técnicas / Contratos de API**

#### **ItemConfig: capacidad de uso**

Los ítems utilizables deben declarar su comportamiento en configuración:

```luau
{
  templateId = "potion_health",
  type = "Consumable",
  usable = true,
  useAction = "RestoreHealth",
}
```

* `usable = true` habilita el ítem para los slots rápidos.
* `useAction` identifica el efecto que ejecuta el servicio de uso; el cliente nunca define el efecto.
* Las pociones actuales conservan sus reglas de R5: cura/maná y cooldown compartido de 30 s.
* Armas, armaduras y cualquier ítem sin `usable=true` no pueden asignarse.
* El flujo debe generalizar el servicio existente a `UseItem`; no duplicar una lógica separada para cada tipo de ítem.

#### **Slots rápidos de uso**

```luau
itemUseSlots = {
  [1] = "potion_health", -- tecla Z
  [2] = "potion_mana",   -- tecla X
}
```

* Hay exactamente 2 slots: slot 1 = `Z`, slot 2 = `X`.
* El slot guarda `templateId`, no `instanceId`, para que funcione con varias pilas del mismo ítem.
* La configuración se guarda por personaje junto al profile/loadout existente.
* Profiles anteriores reciben ambos slots vacíos.
* Si no hay ninguna unidad disponible, el slot permanece asignado, muestra `x0`/vacío y no ejecuta el uso.
* Asignar un nuevo ítem reemplaza el contenido del slot seleccionado.
* Desasignar deja el slot vacío; no elimina ni vende el ítem.

#### **Asignación desde inventario**

* La ventana de inventario permite arrastrar un ítem utilizable a slot 1 o slot 2.
* Si el drag no está disponible en un dispositivo, un control equivalente permite elegir “Asignar a Z” o “Asignar a X”.
* El server valida propiedad, `usable=true` y `templateId` válido antes de guardar la asignación.
* No se asigna una copia del ítem: el slot referencia el template y usa las pilas reales de la bolsa.

#### **Uso de ítems**

El flujo canónico debe ser compartido por uso directo y slot rápido:

```text
RequestUseItem / RequestUseItemSlot
  → server resuelve item usable
  → valida propietario, bolsa, cantidad, cooldown y useAction
  → aplica efecto server-side
  → descuenta 1 unidad
  → persiste/replica inventario y slot
```

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestAssignItemUseSlot` | C→S | `{ slotIndex, templateId? }` | Slot 1/2; ítem perteneciente y `usable=true` |
| `RequestUseItemSlot` | C→S | `{ slotIndex }` | Slot válido, template asignado, pila disponible, cooldown y efecto |
| `RequestUseItem` | C→S | `{ instanceId }` | Uso directo genérico; ítem usable, propietario, bolsa, cantidad y cooldown |
| `ItemUseSlotState` | S→C | `{ slots, quantities }` | Estado del personaje activo |

* El `RequestUseConsumable` existente, si todavía tiene consumidores, debe delegar al mismo `UseItem` server-side; no mantener dos implementaciones de efectos.
* `RequestUseItemSlot` no recibe `templateId`, `instanceId`, cantidad ni efecto desde el cliente: resuelve el slot guardado en server.
* El cliente no puede fabricar ítems, elegir `useAction`, saltar cooldowns ni consumir cantidades negativas.
* No enviar un RemoteEvent por cada actualización visual de cantidad; replicar el estado de inventario existente.

#### **HUD y controles**

* Mostrar dos slots de uso en el HUD, identificados como `Z` y `X`.
* Mostrar icono, nombre corto, cantidad disponible y overlay de cooldown cuando aplique.
* PC: `Z` y `X` activan el slot correspondiente.
* Móvil: dos botones táctiles equivalentes, visibles y escalables.
* No activar el hotkey mientras el usuario escribe en un TextBox.
* Los slots siguen funcionando durante combate y movimiento; abrir otras ventanas no debe duplicar las acciones.
* Un ítem no disponible muestra feedback breve (“Ítem no disponible”, “En recarga”, etc.) sin errores rojos.

#### **Debug: restablecer nivel 1**

El control se agrega a la UI de debug existente o a una pequeña `DebugPanel` de Studio/test.

```luau
{
  debugEnabled = true,
  action = "ResetActiveCharacterToLevelOne",
}
```

* Botón: **“Resetear nivel a 1”**.
* No recibe un nivel arbitrario: siempre solicita nivel 1.
* Solo visible en Studio/test y solo aceptado por el server en ese entorno (`RunService:IsStudio()` o flag de test autorizado).
* En producción el botón no se muestra y el server rechaza el Remote aunque un cliente lo intente.
* Afecta únicamente al personaje activo.

#### **Resultado exacto del reset**

Al confirmar el reset, el server debe:

* Establecer `level = 1`.
* Establecer `xp = 0`.
* Recalcular puntos disponibles: `floor(1 / 2) = 0`.
* Vaciar todos los ranks/puntos gastados del árbol de talentos.
* Eliminar los efectos de talentos del cálculo de estadísticas.
* Conservar `classId`, `specId`, inventario, equipo y slots rápidos; el reset es de progresión, no de identidad ni de inventario.
* Reconstruir el spellbook según el nivel 1: conservar básicas y skills legítimamente disponibles a nivel 1; retirar skills desbloqueadas en niveles superiores y skills aprendidas mediante talentos.
* Recalcular stats con el nivel 1, sin modificadores de talentos; aplicar las reglas existentes de equipamiento/level requirement sin crear una regla nueva de borrado.
* Actualizar MaxHP/MaxMP y restaurar HP/MP al máximo resultante.
* Persistir el resultado y replicar el profile actualizado.
* Mantener las asignaciones de ítems; si no hay cantidad, quedan vacías hasta obtener el ítem.

Remote de debug:

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestDebugResetLevel` | C→S | `{}` | Solo Studio/test autorizado; personaje activo |
| `DebugProgressReset` | S→C | `{ level, xp, talentPoints, removedSkills }` | Solo respuesta del reset confirmado |

* El reset debe ser idempotente: repetirlo deja el personaje en el mismo estado y no duplica ni elimina datos adicionales.
* No crear en esta HU comandos de subir nivel, dar XP, elegir nivel o modificar oro/inventario.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Slots visibles**

* **GIVEN** un personaje activo
* **WHEN** carga el HUD
* **THEN** ve dos slots de uso identificados como `Z` y `X`
* **AND** cada slot muestra su icono y cantidad cuando tiene un ítem asignado

#### **Escenario 2: Asignar ítem utilizable**

* **GIVEN** el jugador tiene un ítem con `usable=true`
* **WHEN** lo arrastra al slot `Z` o `X`
* **THEN** el slot queda asignado a su `templateId`
* **AND** la asignación persiste en el personaje

#### **Escenario 3: Rechazar ítem no utilizable**

* **GIVEN** el jugador selecciona un arma, armadura o ítem sin `usable=true`
* **WHEN** intenta asignarlo a un slot
* **THEN** el server rechaza la asignación
* **AND** el ítem no se elimina, equipa ni modifica

#### **Escenario 4: Usar con Z**

* **GIVEN** el slot `Z` tiene una poción disponible
* **WHEN** el jugador pulsa `Z`
* **THEN** el server valida y aplica el efecto de la poción
* **AND** descuenta exactamente una unidad
* **AND** actualiza la cantidad visible

#### **Escenario 5: Usar con X**

* **GIVEN** el slot `X` tiene otro ítem utilizable disponible
* **WHEN** el jugador pulsa `X`
* **THEN** se ejecuta el mismo flujo genérico de `UseItem`
* **AND** no depende de que el ítem sea una poción

#### **Escenario 6: Stacking y múltiples pilas**

* **GIVEN** el slot apunta a un template con varias pilas en la bolsa
* **WHEN** el jugador usa el slot repetidamente con cooldown válido
* **THEN** el server consume una unidad de una pila disponible cada vez
* **AND** nunca supera ni crea cantidades inválidas

#### **Escenario 7: Ítem agotado**

* **GIVEN** el slot asignado no tiene unidades disponibles
* **WHEN** el jugador pulsa su tecla o botón
* **THEN** no se ejecuta ningún efecto
* **AND** se muestra feedback de ítem no disponible
* **AND** la asignación permanece guardada

#### **Escenario 8: Cooldown existente**

* **GIVEN** una poción está en cooldown
* **WHEN** el jugador pulsa `Z` o `X`
* **THEN** el server rechaza el segundo uso
* **AND** no descuenta otra unidad
* **AND** la UI muestra el cooldown restante

#### **Escenario 9: Botones móviles**

* **GIVEN** el jugador usa un dispositivo táctil
* **WHEN** pulsa el botón equivalente a `Z` o `X`
* **THEN** ejecuta el mismo `RequestUseItemSlot`
* **AND** no interfiere con el joystick ni con la UI escalable

#### **Escenario 10: Persistencia de slots**

* **GIVEN** el jugador asignó dos ítems
* **WHEN** sale y vuelve a entrar con el mismo personaje
* **THEN** las asignaciones `Z`/`X` se mantienen
* **AND** las cantidades reflejan el inventario real

#### **Escenario 11: Debug solo en Studio**

* **GIVEN** el juego corre en Studio/test autorizado
* **WHEN** el desarrollador abre la DebugPanel
* **THEN** ve el botón “Resetear nivel a 1”
* **AND** puede solicitar el reset del personaje activo

#### **Escenario 12: Reset de progresión**

* **GIVEN** el personaje está en un nivel mayor, tiene XP, talentos y skills de nivel
* **WHEN** se confirma “Resetear nivel a 1”
* **THEN** queda en nivel 1 con XP 0 y 0 puntos disponibles
* **AND** los ranks/efectos de talentos se eliminan
* **AND** las skills de niveles superiores y las de talento desaparecen
* **AND** se conservan clase, spec, inventario, equipo y slots rápidos

#### **Escenario 13: Stats recalculadas**

* **GIVEN** el personaje tenía stats derivados de nivel y talentos
* **WHEN** termina el reset
* **THEN** sus stats se recalculan con nivel 1 y sin talentos
* **AND** HP/MP actuales se ajustan al máximo nuevo
* **AND** no quedan modificadores acumulados del nivel anterior

#### **Escenario 14: Debug rechazado en producción**

* **GIVEN** un cliente intenta enviar `RequestDebugResetLevel` fuera de Studio/test
* **WHEN** el server recibe la solicitud
* **THEN** la rechaza
* **AND** no modifica nivel, XP, talentos, skills ni stats

#### **Escenario 15: Idempotencia y seguridad**

* **GIVEN** el jugador pulsa varias veces el reset o el cliente falsifica payloads
* **WHEN** el server procesa las solicitudes
* **THEN** el resultado siempre es un personaje válido de nivel 1
* **AND** no se duplican recompensas ni se borran inventario/equipo
* **AND** no aparecen errores rojos

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* Los slots `Z` y `X` forman parte del HUD, separados visualmente de la barra de skills.
* Mostrar icono, cantidad y cooldown; un slot vacío permanece utilizable para asignación.
* El botón de debug debe estar claramente marcado como **DEBUG / SOLO STUDIO**.
* El reset requiere confirmación para evitar activarlo accidentalmente.
* Los mensajes de error deben ser breves: “Ítem no disponible”, “En recarga”, “Ítem no utilizable”, “Solo disponible en Studio”.
* La UI no debe pausar la cámara para usar Z/X; la DebugPanel sí puede usar el comportamiento normal de ventanas.
* Mantener compatibilidad PC/móvil y no ocupar ni bloquear el input del joystick.

---

### **Alcance**

#### Incluye

* Dos slots rápidos genéricos de uso de ítems.
* Teclas `Z` y `X` en PC.
* Dos botones equivalentes para móvil.
* Asignación desde inventario y persistencia por personaje.
* Generalización del flujo `UseItem` para ítems con `usable=true`.
* Integración con stacking, cantidades y cooldown existente.
* HUD con icono, cantidad y cooldown.
* DebugPanel con reset del personaje activo a nivel 1.
* Reset de XP, puntos/ranks/efectos de talentos, skills desbloqueadas por niveles superiores y stats derivados.
* Validación server y bloqueo fuera de Studio/test.

#### No incluye

* Más de dos slots rápidos.
* Nuevos efectos de ítems o nuevos tipos de consumibles.
* Cambios a precios, cooldowns o reglas de vendors.
* Sistema de equipamiento rápido de armas/armaduras.
* Botón de setear niveles arbitrarios, otorgar XP/oro o editar perfiles completos.
* Reset de inventario, equipo, clase o spec.
* Cambios a la barra de skills, talentos, cámara o movimiento fuera de la integración necesaria.

---

### **Definition of Done (DoD)**

* [ ] Existen dos slots de uso visibles y asignables.
* [ ] `Z` y `X` ejecutan el slot correcto.
* [ ] Los ítems utilizables se identifican por configuración, no por nombre hardcodeado.
* [ ] Armas/armaduras no utilizables son rechazadas.
* [ ] El uso consume una unidad y respeta stacking/cooldown.
* [ ] El slot resuelve correctamente múltiples pilas del mismo template.
* [ ] Cantidad y cooldown se reflejan en HUD.
* [ ] Las asignaciones persisten tras rejoin y cambio de personaje activo.
* [ ] Existe botón móvil equivalente sin romper el joystick.
* [ ] Debug reset deja nivel 1, XP 0, 0 puntos, talentos vacíos y skills recalculadas.
* [ ] Stats/HP/MP se recalculan correctamente.
* [ ] Inventario, equipo, clase, spec y slots rápidos no se borran.
* [ ] Reset rechazado fuera de Studio/test.
* [ ] Reset repetido es idempotente y no duplica ni pierde datos.
* [ ] Sin errores rojos en uso, respawn, rejoin y reset.
* [ ] Nota “R6.2 completo” en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

2–3 sesiones: slots/input/UI, generalización de `UseItem`, integración con stacking y debug reset con recalculo de progresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-23 | Creación de HU-R6.2: dos slots genéricos de uso con Z/X y reset debug a nivel 1 |
