## HU-ESTETICA-01: Equipamiento visual del avatar y modelos iniciales del Paladín

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Estética MVP / Equipamiento visual  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Fase GDD:** Épica transversal `EST-01` (previa a R8; puede ejecutarse en paralelo con R6.2/R7)  
**Depende de:** HU-R4 (inventario/equip), HU-ASSETS (estructura y política de assets), R15 del jugador  
**No modifica:** stats, daño, loot, economía ni reglas de equipamiento de R4

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** que las armas y piezas de armadura equipadas aparezcan correctamente en mi personaje,  
**para** que mi progreso de equipo sea visible y el juego se sienta como un RPG/MMORPG real.

**Como** equipo de desarrollo,  
**quiero** contar con un pipeline visual data-driven y un primer set de modelos del Paladín,  
**para** poder agregar nuevos ítems sin rehacer el sistema de equipamiento.

---

### **Descripción del Requerimiento / Contexto**

R4 implementa el equipamiento como dato: el ítem pasa de la bolsa al slot, aplica stats y persiste. Actualmente `ItemConfig` tiene `slot` e `iconId`, pero no referencia un modelo 3D, y `InventoryService` no crea ni adjunta una representación visual al avatar.

Esta HU crea el sistema de representación visual y un vertical slice completo del Paladín. Cada ítem visual se crea como asset propio, se registra en `ReplicatedStorage.Assets.Models.Equipment`, se referencia desde configuración y se aplica al avatar R15 al equipar.

Los modelos iniciales deben ser estilizados, coherentes con Vandrheim y suficientemente ajustados para MVP. No se pretende alcanzar calidad AAA ni crear todos los sets del juego en esta HU.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Modelos que deben crearse**

El dev debe crear y ajustar estos modelos 3D iniciales del Paladín:

| ID visual | Modelo | Tipo de attachment |
|-----------|--------|--------------------|
| `paladin_sword_1h` | Espada de una mano de acero azulado, guarda dorada y cuero oscuro | Mano derecha |
| `paladin_shield` | Escudo de acero con cruz dorada y remaches | Mano izquierda |
| `paladin_sword_2h` | Espadón de dos manos con hoja ancha azulada y detalles dorados | Mano derecha, visual 2H |
| `paladin_helmet` | Yelmo de placas con visor, cresta dorada y gema azul | Cabeza |
| `paladin_chest` | Coraza de placas con pectorales y detalles dorados | Torso |
| `paladin_shoulders` | Hombreras de placas con ribetes dorados | Hombros |
| `paladin_legs` | Pantalón/grebas de placas con rodilleras y cuero oscuro | Piernas/cintura |
| `paladin_gloves` | Guantes de placas articulados con dorado en nudillos | Manos |

Reglas visuales:

* Paleta consistente: acero frío azulado, cuero oscuro, dorado cálido y acentos de hielo.
* Silueta legible desde la cámara 3D del juego; no crear detalles que desaparezcan a distancia.
* Modelos propios creados con las capacidades disponibles del proyecto (primitivas, MeshParts o generación procedural); no depende de rigging de animaciones.
* Las piezas deben ser livianas y sin colisión para no afectar la física del personaje.
* Cada modelo debe tener un nombre estable, ser clonable y quedar dentro de la carpeta de assets; no dejar el único ejemplar en `Workspace.GFX`.
* Las pociones e iconos 2D no forman parte de esta HU.

#### **Estructura de assets**

```text
ReplicatedStorage/
  Assets/
    Models/
      Equipment/
        Paladin/
          paladin_sword_1h
          paladin_shield
          paladin_sword_2h
          paladin_helmet
          paladin_chest
          paladin_shoulders
          paladin_legs
          paladin_gloves
```

Cada modelo debe quedar preparado para el tipo de attachment que corresponda:

* Armadura: `Accessory` rígido con `Handle` y `Attachment` compatible con R15.
* Espada y escudo: modelo visual con `Handle`/attachment o estructura equivalente para unirse a la mano.
* Las piezas deben tener `Anchored=false`, `CanCollide=false`, `Massless=true` cuando corresponda y no interferir con el `Humanoid`.

#### **ItemConfig visual**

Agregar la referencia visual sin mezclarla con stats:

```luau
{
  templateId = "paladin_sword_1h",
  slot = "MainHand",
  visualModelId = "paladin_sword_1h",
  visualType = "HandModel",
  attachTo = "RightHand",
  offset = CFrame.new(0, 0, 0),
}
```

Para armadura:

```luau
{
  templateId = "paladin_chest",
  slot = "Chest",
  visualModelId = "paladin_chest",
  visualType = "Accessory",
  attachmentName = "BodyFrontAttachment",
  offset = CFrame.new(0, 0, 0),
}
```

* Los nombres exactos de attachments y offsets se ajustan al modelo final, pero deben vivir en config o metadata del asset, no hardcodeados dentro de múltiples servicios.
* Si se agregan templates de prueba para casco, hombreras, piernas o guantes, deben tener stats mínimos y estar claramente marcados como seed/QA; el balance y loot final quedan fuera.
* Un ítem sin `visualModelId` conserva el comportamiento actual de equipamiento y usa fallback sin error.

#### **EquipmentVisualService**

Crear un servicio separado de `InventoryService` con responsabilidades limitadas a representación:

| Función | Responsabilidad |
|---------|-----------------|
| `ApplyEquipmentVisuals(player)` | Reconstruir todos los visuales desde el equipo persistido |
| `ApplyItemVisual(player, item, slotName)` | Adjuntar el modelo del ítem al slot |
| `RemoveItemVisual(player, slotName)` | Eliminar el visual del slot sin tocar el dato del ítem |
| `RefreshItemVisual(player, slotName)` | Reemplazar de forma segura el visual anterior |
| `ClearEquipmentVisuals(character)` | Limpiar visuales gestionados por el servicio |

Reglas:

* Al equipar, `InventoryService` mantiene la autoridad del dato y solicita/ejecuta la actualización visual sin duplicar la lógica de inventario.
* Al desequipar o reemplazar, se elimina el modelo visual anterior antes de agregar el nuevo.
* Al spawn, respawn, selección de personaje y rejoin se reconstruyen los visuales desde `equipment`.
* Cada visual gestionado debe identificarse con atributos, por ejemplo `EquipmentVisual=true` y `EquipmentSlot=MainHand`, para limpiar solo lo que pertenece al sistema.
* El estado persistido del ítem sigue siendo la fuente de verdad; el modelo del avatar es una proyección recreable.
* Si falta un modelo o attachment, mostrar warning controlado/fallback y no romper spawn ni inventario.

#### **Armas y escudo**

* No convertir las armas en `Tool` en esta HU: el combate actual sigue siendo controlado por `CombatService`/`SkillService`.
* La espada 1H y el espadón se unen a `RightHand` mediante attachment o `Motor6D` visual.
* El escudo se une a `LeftHand` y debe conservar orientación estable durante idle, caminar, correr, saltar y las animaciones actuales.
* La espada 2H es una representación visual; no se implementa IK de dos manos ni una pose exclusiva en esta HU.
* Las armas visuales no crean hitboxes ni aplican daño.

#### **Armadura**

* Usar accesorios rígidos y attachments R15 para casco, pecho, hombreras, piernas y guantes.
* No reemplazar partes corporales ni modificar proporciones del avatar en esta HU.
* No eliminar automáticamente cabello, accesorios del jugador o ropa de Roblox salvo una incompatibilidad explícita del asset; reportar el conflicto.
* Una pieza visual por slot de armadura; al reemplazar, el visual anterior desaparece.

#### **Animaciones y compatibilidad**

* Reutilizar las animaciones actuales de movimiento y combate; esta HU no crea ni selecciona nuevas animaciones de combate.
* Verificar que los attachments no se separen ni atraviesen el avatar durante Idle, Walk, Run, Jump y las animaciones de combate existentes.
* Las futuras animaciones de combate tendrán una HU propia; aquí solo se valida compatibilidad del modelo.

#### **Remotes**

No crear un remote público nuevo si el equipamiento ya se confirma mediante `RequestEquipItem`/`RequestUnequipItem`.

| Flujo | Contrato |
|-------|----------|
| Equipar | `RequestEquipItem { instanceId }` → servidor actualiza dato + visual |
| Desequipar | `RequestUnequipItem { slotName }` → servidor actualiza dato + elimina visual |
| Spawn/rejoin | `CharacterService` → `EquipmentVisualService.ApplyEquipmentVisuals(player)` |

El cliente no puede elegir `visualModelId`, attachment, offset ni modelo. Los datos vienen de `ItemConfig` y el server valida el ítem.

#### **Registro de assets**

Registrar los 8 modelos en `ASSETS_REGISTRY` con:

* Nombre/ID del modelo.
* Tipo de asset.
* Uso y slot.
* Fuente: producción propia o fuente autorizada.
* Autor/licencia cuando aplique.
* Fecha de incorporación.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Modelos creados y organizados**

* **GIVEN** los 8 modelos iniciales del Paladín
* **WHEN** se inspecciona `ReplicatedStorage.Assets.Models.Equipment.Paladin`
* **THEN** cada modelo existe con un ID estable
* **AND** no depende de una copia suelta en `Workspace.GFX`

#### **Escenario 2: Espada de una mano**

* **GIVEN** el jugador tiene equipada la espada 1H
* **WHEN** aparece o actualiza su personaje
* **THEN** la espada aparece en la mano derecha
* **AND** sigue la mano durante movimiento y animaciones existentes

#### **Escenario 3: Escudo**

* **GIVEN** el jugador tiene equipado el escudo
* **WHEN** aparece o actualiza su personaje
* **THEN** el escudo aparece en la mano izquierda
* **AND** no queda flotando, invertido ni separado del avatar

#### **Escenario 4: Espadón**

* **GIVEN** el jugador tiene equipado el espadón 2H
* **WHEN** aparece o actualiza su personaje
* **THEN** se muestra el modelo grande de dos manos en la mano derecha
* **AND** no crea hitbox ni cambia el daño

#### **Escenario 5: Armadura R15**

* **GIVEN** el jugador equipa casco, pecho, hombreras, piernas y guantes
* **WHEN** se aplican los visuales
* **THEN** cada pieza encaja en su zona R15
* **AND** no deforma ni reemplaza las partes corporales del personaje

#### **Escenario 6: Reemplazo de slot**

* **GIVEN** el jugador tiene un arma o pieza visual equipada
* **WHEN** equipa otra del mismo slot
* **THEN** el visual anterior se elimina
* **AND** solo queda un visual activo para ese slot

#### **Escenario 7: Desequipar**

* **GIVEN** el jugador tiene un visual aplicado
* **WHEN** desequipa el ítem
* **THEN** el modelo desaparece del personaje
* **AND** el ítem vuelve a la bolsa según R4
* **AND** sus stats se comportan igual que antes de esta HU

#### **Escenario 8: Persistencia y respawn**

* **GIVEN** el personaje tiene equipo visual guardado
* **WHEN** respawnea, cambia de personaje o vuelve a entrar
* **THEN** los visuales se reconstruyen desde el profile
* **AND** no se duplican modelos ni conexiones

#### **Escenario 9: Animaciones actuales**

* **GIVEN** el personaje lleva el set del Paladín
* **WHEN** reproduce Idle, Walk, Run, Jump y una animación de combate existente
* **THEN** armas y armadura siguen unidas correctamente
* **AND** no bloquean el controlador de animaciones

#### **Escenario 10: Fallback seguro**

* **GIVEN** un ítem no tiene modelo o su modelo no puede adjuntarse
* **WHEN** se equipa
* **THEN** el dato de equipamiento no se corrompe
* **AND** el inventario sigue funcionando
* **AND** se usa fallback visual o se registra un warning controlado

#### **Escenario 11: Server-authoritative**

* **GIVEN** un cliente intenta elegir un modelo, offset o attachment distinto
* **WHEN** envía datos manipulados
* **THEN** el server ignora esos valores
* **AND** aplica exclusivamente la configuración del ítem

#### **Escenario 12: Física y regresión**

* **GIVEN** el jugador lleva equipamiento visual
* **WHEN** camina, corre, salta, combate y entra a dungeon
* **THEN** las piezas no generan colisiones, empujes ni caídas
* **AND** cámara, targeting, skills, respawn y teleport continúan funcionando

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* El jugador debe ver claramente la diferencia entre no tener equipo y tener el set equipado.
* Los modelos respetan la paleta Vandrheim y la silueta legible desde tercera persona.
* El equipamiento visual no altera stats, rareza, afinidad, daño ni reglas de loot.
* La UI de inventario sigue mostrando iconos y stats; esta HU agrega la proyección 3D en el avatar, no reemplaza los iconos.
* Si un modelo falta, el juego conserva el funcionamiento y muestra el feedback técnico correspondiente.
* No reemplazar automáticamente accesorios personales del avatar sin una regla explícita.

---

### **Alcance**

#### Incluye

* Creación de 8 modelos 3D iniciales del Paladín.
* Organización de modelos en `ReplicatedStorage.Assets.Models.Equipment.Paladin`.
* Configuración visual de los templates iniciales.
* `EquipmentVisualService` o equivalente separado de `InventoryService`.
* Aplicación visual al equipar, desequipar, reemplazar, spawn, respawn, cambio de PJ y rejoin.
* Espada 1H, escudo, espadón 2H, casco, pecho, hombreras, piernas y guantes.
* Ajuste R15, attachments, offsets, orientación y física visual.
* Registro de assets y fallback seguro.
* Prueba con las animaciones actuales de movimiento y combate.

#### No incluye

* Modelos finales de Cazador, Clérigo u otras clases.
* Todos los ítems del catálogo, sets completos por rareza o transmog.
* Modelo final del boss, enemigos o estructuras del dungeon.
* Kit definitivo del hub/dungeon.
* Creación o rigging de animaciones de combate.
* IK de dos manos, poses exclusivas ni sistema de combate basado en `Tool`.
* Hitboxes, daño, stats, loot, economía o cambios a reglas de R4.
* VFX, SFX o efectos de rareza sobre los modelos.
* Modelos 3D de pociones; solo son utilizables/mostradas como ítems de inventario.

---

### **Definition of Done (DoD)**

* [ ] Los 8 modelos del Paladín fueron creados y están organizados en Assets.
* [ ] Cada template visual tiene referencia data-driven y no depende de código hardcodeado.
* [ ] Espada 1H aparece en la mano derecha.
* [ ] Escudo aparece en la mano izquierda.
* [ ] Espadón 2H aparece correctamente sin modificar combate.
* [ ] Las cinco piezas de armadura encajan en el R15.
* [ ] Equipar, desequipar y reemplazar no dejan duplicados.
* [ ] Visuales se reconstruyen en spawn, respawn, cambio de PJ y rejoin.
* [ ] Modelos no tienen colisión ni afectan física, stats o daño.
* [ ] Animaciones actuales de movimiento y combate no separan las piezas.
* [ ] Falta de asset produce fallback/warning controlado, no error fatal.
* [ ] Cliente no puede elegir modelos, offsets ni attachments.
* [ ] Assets registrados con fuente/licencia.
* [ ] Prueba PC y móvil sin regresiones de UI/inventario.
* [ ] Sin errores rojos en el flujo inventario → equip → movimiento → combate → respawn.
* [ ] Nota `EST-01` completa en GDD al verificar la implementación.

---

### **Estimación (orientativa)**

4–6 sesiones: creación y ajuste de 8 modelos, integración R15, servicio visual, persistencia/rebuild y pruebas de regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-25 | Creación de HU-ESTETICA-01: modelos iniciales del Paladín + pipeline de equipamiento visual |
