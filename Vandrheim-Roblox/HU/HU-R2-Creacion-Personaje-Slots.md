## HU-R2: Creación de personaje, slots y persistencia

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Progresión / Identidad de PJ / R2  
**Prioridad:** Crítica  
**Estado:** Completada (implementada; reporte equipo 2026-08-12)  
**Fase GDD:** R2  
**Depende de:** HU-R0 (hub estable); HU-R1 no bloquea UI de creación pero el hub de prueba debe coexistir

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** crear un personaje (nombre + clase), elegirlo entre mis slots y que se guarde al salir,  
**para** tener identidad de PJ y base de progresión antes de skills e inventario completo.

---

### **Descripción del Requerimiento / Contexto**

Fase R2 del GDD (§9, §11, §14): modelo de **2 slots gratis por UserId**, selección/creación de PJ, stats base por clase, y **DataStore** real del perfil.

**Criterio de hecho global GDD:** "Rejoin elige/mantiene PJ; stub slot 3 Robux".

Sin esto no hay progresión confiable ni multi-alt; R3+ asume un personaje activo con clase.

---

### **Especificaciones Técnicas / Contratos de API**

#### **Data model (server / DataStore)**

```text
PlayerProfile (key: UserId)
  maxSlots: 2 | 3          -- 3 solo si owns gamepass/devproduct (stub OK)
  activeCharacterId: string?
  characters: {
    [characterId]: {
      slotIndex: 1..maxSlots
      name: string
      classId: "Paladin" | "Hunter" | "Cleric"
      level: number          -- default 1
      xp: number             -- default 0
      gold: number           -- default 0
      -- placeholders R3+: talents, inventory, bind flags
      createdAt: number
    }
  }
```

* **1 UserId → hasta 2 PJs gratis**; 3.º solo si `maxSlots == 3`.
* Cada slot = perfil propio (clase, nombre, nivel, …).
* Apariencia = avatar R15 de Roblox (no se guarda pelo/piel custom).

#### **Remotes / intenciones (nombres sugeridos)**

| Remote | Dir | Payload | Validación server |
|--------|-----|---------|-------------------|
| `RequestCharacterList` | C→S | — | Devuelve slots + resumen PJs |
| `RequestCreateCharacter` | C→S | `{ slotIndex, name, classId }` | Slot vacío, nombre válido, clase MVP, no exceder maxSlots |
| `RequestSelectCharacter` | C→S | `{ characterId }` | Pertenece al UserId |
| `RequestDeleteCharacter` | C→S | `{ characterId }` | Confirmación ya hecha en UI; borra y libera slot |
| (stub) `RequestUnlockSlot3` | C→S o Marketplace | — | Stub: detectar gamepass o flag de studio test |

#### **Servicios**

| Servicio | Rol R2 |
|----------|--------|
| DataService | Load/save profile; session lock; defaults; migrate-safe |
| ClassService (mínimo) | Stats base por `classId` al spawnear PJ activo |
| (UI) CharacterSelect / Create | Flujo pre-hub o gate al hub |

#### **Flujo al join**

```text
Player joins Place_Hub
  → DataService carga profile (o crea vacío)
  → Si no hay activeCharacter válido:
       UI: selección de slots / creación
  → Si hay active o elige uno:
       Aplica clase/stats base; spawnea en hub
  → Combate R1 (dummy) sigue disponible con el PJ activo
```

#### **Validación de nombre (defaults R2)**

| Regla | Default |
|-------|---------|
| Longitud | 3–16 caracteres |
| Charset | Alfanumérico + espacios internos limitados; trim |
| Único global | **No** requerido en MVP (único por cuenta sí implícito por slot) |
| Profanity | Filtro Roblox TextService si aplica a display |
| Vacío / solo espacios | Rechazar |

#### **Clases MVP (crear)**

| classId | Display | Specs (solo data; spec activa en R5) |
|---------|---------|-------------------------------------|
| Paladin | Paladín | Protector / Castigo |
| Hunter | Cazador | Asalto / Puntería |
| Cleric | Clérigo | Misericordia / Cólera |

Stats base: usar `ClassConfig` (seed R0). En R2 al menos MaxHP/MaxMP/ATK/MATK/DEF/MDEF/CRIT leídos del config y aplicados al humanoid/attrs del PJ activo.

#### **Slot 3 Robux (stub)**

* `maxSlots = 2` por defecto.
* Si ownership de gamepass/dev product (o flag de test en Studio): `maxSlots = 3`.
* UI: slot 3 visible bloqueado con CTA “Desbloquear” (no hace falta checkout pulido; stub que lea ownership).
* **No** pay-to-win: solo convenience de alt.

#### **Persistencia**

* Guardar en: leave, shutdown, y autosave periódico (ej. 60–120 s) + tras create/select/delete.
* Session locking / prevención de data loss estándar DataStore.
* Fallo de DataStore: mensaje claro; no corromper profile (reintentos con backoff).

#### **Integración con R1**

* HP del jugador en combate debe alinearse a MaxHP de la clase del PJ activo (o mantener 100 si aún no hay daño entrante; preferible leer MaxHP del config).
* Si no hay PJ seleccionado, no procesar combate / no spawnear en mundo hasta completar select/create (gate).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Primera vez — profile vacío**

* **GIVEN** un UserId sin datos guardados
* **WHEN** entra al hub
* **THEN** ve pantalla de slots (2 slots gratis vacíos; 3.º locked o stub)
* **AND** no spawnea en el mundo de juego hasta crear/seleccionar un PJ

#### **Escenario 2: Crear personaje**

* **GIVEN** un slot vacío y maxSlots permite crearlo
* **WHEN** elige clase (Paladín / Cazador / Clérigo), ingresa nombre válido y confirma
* **THEN** se crea el PJ en ese slot
* **AND** queda como personaje activo
* **AND** spawnea en el hub con avatar R15 del usuario
* **AND** stats base corresponden a la clase (ClassConfig)

#### **Escenario 3: Nombre inválido**

* **GIVEN** el jugador está en creación
* **WHEN** envía nombre vacío, demasiado corto/largo o charset inválido
* **THEN** el server rechaza
* **AND** la UI muestra error; no se crea el PJ

#### **Escenario 4: Límite de slots gratis**

* **GIVEN** el jugador ya tiene 2 PJs y maxSlots = 2
* **WHEN** intenta crear un tercero
* **THEN** el server rechaza
* **AND** la UI indica slot lleno / desbloquear 3.º

#### **Escenario 5: Selección de personaje**

* **GIVEN** el jugador tiene uno o más PJs
* **WHEN** elige uno en la pantalla de selección
* **THEN** ese PJ queda activo
* **AND** spawnea en hub con los datos de ese slot (nombre, clase, level)

#### **Escenario 6: Persistencia en rejoin**

* **GIVEN** el jugador creó o seleccionó un PJ
* **WHEN** sale y vuelve a entrar (nuevo join)
* **THEN** el profile se carga desde DataStore
* **AND** puede elegir el mismo PJ (nombre, clase, level intactos)
* **AND** si había activeCharacter, el flujo permite continuar con él o re-elegir

#### **Escenario 7: Borrar personaje**

* **GIVEN** un PJ existente
* **WHEN** el jugador confirma borrado (confirmación fuerte en UI)
* **THEN** el slot se libera
* **AND** ese characterId ya no aparece ni se puede seleccionar
* **AND** el save persiste el borrado

#### **Escenario 8: Stub slot 3**

* **GIVEN** el jugador no posee el unlock
* **WHEN** ve los slots
* **THEN** el 3.er slot está bloqueado (no crea PJ ahí)
* **GIVEN** el jugador posee el unlock (o flag de test)
* **WHEN** carga el profile
* **THEN** maxSlots = 3 y puede crear en el 3.er slot

#### **Escenario 9: Coexistencia con dummy R1**

* **GIVEN** un PJ activo en el hub
* **WHEN** usa TAB/auto-attack del R1
* **THEN** el combate base sigue funcionando
* **AND** el HP del jugador respeta MaxHP de clase (o el default documentado si aún no hay damage-in)

#### **Escenario 10: Fallo / seguridad**

* **GIVEN** un cliente envía create/select de un slot ajeno o classId inválido
* **WHEN** el server valida
* **THEN** rechaza sin corromper data
* **AND** no hay errores rojos en el flujo feliz create → play → leave → rejoin

---

### **Comportamiento Visual e Interfaz (UI/UX) / Reglas de Negocio**

* **Pantalla de selección:** lista/cards de slots; vacíos con CTA “Crear”; ocupados con nombre, clase, level.
* **Creación:** solo **nombre + clase**; preview = avatar R15 actual del jugador (sin editor de cuerpo).
* **Borrado:** doble confirmación (ej. escribir nombre o modal “¿Seguro?”).
* **Slot 3:** candado + indicación Robux/convenience; copy: el juego se completa con 2 PJs.
* **Gate:** hasta tener PJ activo, no mostrar HUD de combate completo ni procesar SetTarget (o ignorar en server).
* **Display name in-world (mínimo):** nombre del PJ visible al menos en UI local (billboard opcional post-R2).
* **PC primero;** layout con Scale para no romper móvil básico.

---

### **Alcance**

#### Incluye

* DataService real (load/save profile por UserId)
* 2 slots gratis; modelo maxSlots 2|3
* Crear: nombre + clase (3 clases MVP)
* Seleccionar PJ activo; rejoin mantiene data
* Borrar PJ con confirmación
* Stats base por clase al entrar al mundo
* Stub unlock 3.er slot (gamepass/flag test)
* UI Character Select / Create
* Gate al mundo hasta tener PJ activo
* Compatibilidad con hub + dummy R1

#### No incluye

* Spec activa / talentos / respec (R5)
* Skills barra 4 / maná/CD (R3)
* Inventario, equip, BoE rolls (R4)
* Vendors, oro usable en tienda (R5; gold field puede existir en 0)
* Dungeon teleport / reserved server (R6)
* Editor de apariencia, sexo, pelo custom
* Trade, party, matchmaking
* Monetización cosmética full
* Nivel-up loop completo / curva a 20 (solo campos level/xp listos)

---

### **Definition of Done (DoD)**

* [ ] Play Solo: crear PJ → spawnear hub → leave → rejoin → mismo PJ disponible
* [ ] Crear 2 PJs en slots distintos; cambiar entre ellos
* [ ] Rechazo de 3.er PJ sin unlock; con stub unlock se puede el 3.º
* [ ] Borrar un PJ libera slot y persiste
* [ ] Nombres inválidos rechazados
* [ ] classId inválido / slot ajeno rechazados en server
* [ ] Dummy R1 sigue matable con PJ activo
* [ ] Sin errores rojos en flujo feliz
* [ ] Nota “R2 completo” en GDD cuando cierre QA
* [ ] HU guardada y alineada a GDD §9 / §11 / §14

---

### **Checklist Studio (referencia dev)**

* [ ] DataService: profile schema, GetAsync/SetAsync, autosave, bind-to-close
* [ ] ClassConfig consumido al aplicar PJ activo
* [ ] Remotes: list / create / select / delete (+ stub slot3)
* [ ] UI: CharacterSelect + CharacterCreate
* [ ] Gate de spawn hasta PJ activo
* [ ] Integrar MaxHP (y attrs) con Humanoid / réplica usada por HUD R1
* [ ] Studio test flag para maxSlots = 3
* [ ] Probar data loss: leave rápido, dos clients mismo user (si aplica session lock)

---

### **Decisiones por defecto R2 (si no se cambian)**

| Tema | Default |
|------|---------|
| Slots gratis | 2 |
| Slot 3 | Stub ownership; no hace falta store UX final |
| Creación | Solo nombre + clase |
| Nombre | 3–16, charset simple, TextService si aplica |
| Unicidad nombre | Solo por cuenta/slot; no global |
| Level/XP/Gold iniciales | 1 / 0 / 0 |
| Spec al crear | Ninguna elegida aún (o default data-only); respec/spec playable en R5 |
| Gate | Obligatorio: sin PJ activo no hay mundo/combate |
| Autosave | ~60–120 s + eventos críticos + BindToClose |
| Fallo DataStore | Reintento + mensaje; no sobrescribir con profile vacío sin confirmación de “nuevo” |

---

### **Estimación (orientativa)**

2–4 sesiones (DataStore + UI de slots suele ser el cuello de botella).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Alta HU-R2 al cerrar documentación R0/R1 y pasar producción a R2 |
| 2026-08-12 | Marcada completada según reporte del equipo; producción pasa a R3 |
