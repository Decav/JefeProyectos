# HU-PUBLICAR-04: Unificación de places — DungeonConfig, copia derivada (sin Hub) y arranque ramificado

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Publicación / Ops (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Refactor de configuración + proceso de publicación (dev) — **elimina el sync manual entre places**
**Fase GDD:** Publicación (transversal)
**Depende de:** HU-PUBLICAR-02 (teleport cross-place), HU-PUBLICAR-03 (estrategia de sincronización), HU-R6b (DungeonService), Place ID real `125210265978348`
**No modifica:** gameplay, balance ni mecánicas

---

### **Narrativa (INVEST)**

**Como** equipo de desarrollo,
**quiero** dejar de hacer cambios manuales de un lado a otro entre el hub y `Dungeon_Helada`,
**para** que la dungeon sea una **compilación derivada del hub** (mismos sistemas, sin el contenido del pueblo) y nunca vuelva a haber bugs por desincronización (ej. la Flecha venenosa).

**Como** desarrollador,
**quiero** implementar el `DungeonConfig` con `placeType` **derivado del Place ID**, el arranque ramificado y la **copia de publicación que excluye `Workspace.Hub`**,
**para** que la dungeon funcione con el mismo código que el hub pero sin el pueblo adentro, sin editar módulos a mano.

---

### **Descripción del Requerimiento / Contexto**

El dev validó la dirección pero corrigió un punto clave: **no se quiere el pueblo dentro de la dungeon**. No se publica una copia idéntica de todo el place: se genera una **copia de publicación (compilación derivada)** que conserva el código y los sistemas compartidos pero **excluye el contenido exclusivo del hub** (`Workspace.Hub`: pueblo, portales, vendors — y controla la UI exclusiva del hub para que no se muestre).

Estado actual verificado en Studio (dev): `DungeonConfig` ya existe en ambos places con los IDs correctos, pero **falta** `IsDungeonPlace()`/`IsHubPlace()`. `Workspace.Hub` hoy está solo en el hub (la dungeon actual no lo tiene) — por eso la copia debe excluirlo explícitamente para no llevarlo.

**Criterio de hecho global:** publicar el hub **no cambia el hub**; la copia publicada en la dungeon **no contiene el pueblo/portales/vendors**; el piso (generado en runtime) y el HUD de dungeon funcionan; el flujo hub → dungeon → hub sigue pasando; sin errores rojos.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. `DungeonConfig` (completar — ya existe con IDs)**

```luau
local DungeonConfig = {
    hubPlaceId = 84186294312317,                    -- Vandrheim-RPG (hub)
    dungeonPlaceId = 125210265978348,              -- Dungeon_Helada (PO 2026-09-18)
}

function DungeonConfig.IsDungeonPlace()
    return game.PlaceId == DungeonConfig.dungeonPlaceId
end

function DungeonConfig.IsHubPlace()
    return game.PlaceId == DungeonConfig.hubPlaceId
end
```

* **Falta agregar los helpers** `IsDungeonPlace()`/`IsHubPlace()` (el config con los IDs ya está).
* `placeType` se **deriva** de `game.PlaceId`; sin flags manuales.
* Reemplazar cualquier Place ID hardcodeado en `DungeonService`/scripts por `DungeonConfig`.

#### **2. Copia de publicación derivada (sin Hub)**

* **Fuente de verdad:** el Hub. La dungeon es una **compilación derivada**:
  1. Guardar el hub (`File → Save As`) — el archivo original del hub **nunca se modifica** por esta copia.
  2. En la copia, **excluir el contenido exclusivo del hub**: **`Workspace.Hub` únicamente** (pueblo, portales, vendors y sus props). No hay otras carpetas de mundo del hub que excluir en esta HU; si en el futuro aparecen, se agregan a esta lista en una revisión.
  3. **NO vaciar `Workspace`**: el piso de la dungeon se genera **durante la partida** (FloorService); **todo lo demás del Workspace se conserva tal cual** (lo que el arranque y FloorService necesitan).
  4. Publicar la copia al **Place ID correcto de `Dungeon_Helada`** (`Publish to existing place` → `125210265978348`), **verificando el ID antes de sobrescribir**.
  5. **Backup:** **explícito solo en la primera publicación derivada** (migración). En los releases siguientes, la recuperación se apoya en el **historial de versiones del place** (Creator Dashboard permite rollback); si un release necesita rollback y el historial no alcanza, se decide caso a caso.
* La transformación afecta **solo a la copia**, jamás al hub original.

#### **3. Control de UI exclusiva del hub (por `placeType`)**

* La UI exclusiva del hub — **Selección/Creación de PJ, ventanas de vendors y otros flujos del pueblo** — **no se muestra en la dungeon**:
  * El arranque ramificado (server) marca el contexto; el cliente solo muestra las GUIs permitidas según `IsDungeonPlace()` (o según el contexto que el server comunica).
  * Los **scripts y dependencias compartidas se conservan** (no se borran scripts por no mostrar su GUI): el gate es de **muestra/flujo**, no de presencia.
* En la dungeon: se muestra el **HUD de dungeon** (piso, Abandonar), el HUD base y las ventanas que el jugador usa dentro de la run (mochila/equipo/grimorio si aplica) — todo ya contemplado por los reskins existentes.

#### **4. Flujo de la dungeon intacto (reglas duras)**

* **Validación server-side** del `TeleportData` (`{runId, floorSeed, dungeonDef, partyId}`) y del acceso: entrar a la dungeon solo por teleport del hub con runId válido; sin runId → vuelta al hub con aviso.
* Arranque con **`JoinRun`** (piso 1 con el seed) y pisos 1–5 en secuencia.
* **Retorno al hub** al completar/abandonar (config `hubPlaceId`), conservando lo ganado (DataStore).
* **Permisos del place** (Creator Dashboard): dungeon en *Secure within universe only*; experiencia con el acceso decidido por el PO — sin cambios en esta HU.

#### **5. Publicación (decisión PM — explícita)**

* **Publicación MANUAL acotada para el MVP (decisión 2026-09-22):** el proceso del punto 2 se ejecuta a mano en Studio (guardar copia → excluir `Workspace.Hub` → publicar al Place ID correcto). Se **acepta explícitamente que no está automatizada** (ni la eliminación ni la publicación); el checklist de verificación la cubre.
* **Open Cloud API (opcional, futuro):** automatizar la publicación con la API de places de Roblox (requiere API key + permisos). Se documenta como mejora futura y **no** es requisito de esta HU; si el equipo lo quiere antes, se crea una HU aparte.

#### **6. Documentación**

* Actualizar el `DEV_PROMPT` y docs de la dungeon: hoy referencian HUs viejas (ej. **HU-R6.11** ya no es el nombre correcto de nada en el contexto actual — se revisa el contenido del place de la dungeon y se deja al día).
* Actualizar `PROJECT_ARCHITECTURE` / `DATA_SCHEMA` con el proceso de compilación derivada.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Publicar el hub no cambia el hub**

* **GIVEN** el proceso de publicación derivada
* **WHEN** se publica el hub
* **THEN** el hub queda igual (el pueblo, portales y vendors intactos)

#### **Escenario 2: La dungeon no tiene el pueblo**

* **GIVEN** la copia derivada publicada en `Dungeon_Helada`
* **WHEN** se inspecciona el place publicado
* **THEN** `Workspace.Hub` NO existe (ni portales ni vendors)
* **AND** el Workspace conserva lo necesario para la generación del piso en runtime

#### **Escenario 3: La dungeon funciona**

* **GIVEN** la copia derivada publicada
* **WHEN** un jugador entra por el portal
* **THEN** la dungeon valida el TeleportData, arranca con `JoinRun` (piso 1, seed) y avanza pisos 1–5
* **AND** el HUD de dungeon (piso, Abandonar) funciona y la UI del hub (selección de PJ, vendors) NO se muestra

#### **Escenario 4: Flujo cruzado**

* **GIVEN** la compilación derivada
* **WHEN** se juega hub → dungeon → hub (publicado)
* **THEN** completar/abandonar vuelve al hub con lo ganado (DataStore)
* **AND** no hay errores rojos

#### **Escenario 5: Sin regresión por sync**

* **GIVEN** un cambio nuevo en el hub (ej. una skill/config)
* **WHEN** se regenera y publica la copia derivada
* **THEN** el cambio llega a la dungeon **sin edición manual de módulos**
* **AND** el bug de la Flecha venenosa no reaparece

#### **Escenario 6: Backup y Place ID**

* **GIVEN** la primera publicación derivada
* **WHEN** se va a sobrescribir la dungeon
* **THEN** se verificó el Place ID correcto (`125210265978348`) y existe un backup del place anterior

---

### **Comportamiento Visual / Reglas de Negocio**

* Infraestructura/proceso: no cambia gameplay, balance ni contenido.
* La fuente de verdad es el **hub**; la dungeon es una **compilación derivada** (sin mundo del hub).
* `placeType` derivado; no hay flags manuales que configurar.
* La UI del hub se **gatea por contexto**, no se borran scripts compartidos.

---

### **Alcance**

#### Incluye

* `DungeonConfig` completado (`IsDungeonPlace`/`IsHubPlace`; IDs ya presentes) y Place IDs sin hardcodes.
* Proceso de **copia derivada** documentado (excluir `Workspace.Hub`; nunca tocar el hub original; no vaciar Workspace).
* Arranque ramificado hub/dungeon (server + cliente) con gate de UI por contexto.
* Backup del place de dungeon + verificación de Place ID antes de sobrescribir.
* Actualización de docs del place de dungeon (DEV_PROMPT/PROJECT_ARCHITECTURE/DATA_SCHEMA — quitar referencias viejas como HU-R6.11).
* Verificación publicada del flujo cruzado.

#### No incluye

* Cambios de gameplay, balance ni contenido.
* Migración a Rojo (opcional a futuro).
* Automatización con Open Cloud API (opcional a futuro; documentado).
* Cambios de permisos en Creator Dashboard (ya configurados).

---

### **Definition of Done (DoD)**

* [ ] `DungeonConfig` con IDs reales + `IsDungeonPlace()`/`IsHubPlace()`; sin Place IDs hardcodeados.
* [ ] Proceso de copia derivada definido y documentado (excluye `Workspace.Hub`; el hub original no se modifica).
* [ ] Copia derivada publicada en `125210265978348` **verificando el ID** y con **backup** del place anterior.
* [ ] La dungeon publicada NO tiene pueblo/portales/vendors; el piso se genera en runtime y el HUD de dungeon funciona.
* [ ] UI del hub (selección/creación, vendors) no se muestra en la dungeon; scripts compartidos conservados.
* [ ] Validación de TeleportData, `JoinRun`, pisos 1–5 y retorno al hub intactos.
* [ ] Publicar el hub no cambia el hub; flujo hub → dungeon → hub sin errores rojos.
* [ ] Bug de la Flecha venenosa verificado como no reaparece (publicado).
* [ ] Docs del place de dungeon actualizados (DEV_PROMPT/PROJECT_ARCHITECTURE/DATA_SCHEMA; sin referencias viejas).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto PUBLICAR-04**

| Tema | Default |
|------|---------|
| Fuente de verdad | El hub; la dungeon = **compilación derivada** (sin `Workspace.Hub`) |
| Exclusión | **Solo `Workspace.Hub`** (único contenido de mundo del hub); el resto del Workspace se conserva |
| `placeType` | Derivado de `game.PlaceId` (sin flag manual) |
| Publicación MVP | **Manual acotada** (aceptada explícitamente; no automatizada) — Save As → excluir Hub → publicar al Place ID correcto |
| Automatización | Open Cloud API = opcional futuro (requiere API key); NO en esta HU |
| Backup | Explícito solo en la 1.ª publicación; releases siguientes por **historial de versiones** del place (rollback) |
| UI del hub | Gateada por contexto (no se borran scripts compartidos) |
| Regla dev | No editar módulos dentro del place dungeon (todo vive en el hub) |

---

### **Estimación (orientativa)**

1–2 sesiones del dev: helpers de DungeonConfig + arranque ramificado + proceso de copia derivada (con backup) + docs + verificación publicada.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-PUBLICAR-04: unificación de places — DungeonConfig, copia derivada y arranque ramificado (sin sync manual) |
| 2026-09-22 | **Revisión del dev + ajuste de estrategia:** la dungeon es una **compilación derivada** que **excluye `Workspace.Hub`** (nada de copia idéntica con el pueblo adentro); UI del hub gateada por contexto; backup + verificación de Place ID antes de sobrescribir; `DungeonConfig` ya tiene los IDs, faltan los helpers; docs del place de dungeon a actualizar (referencias viejas) |
| 2026-09-22 | **Decisiones PM cerradas (feedback dev):** publicación **manual acotada aceptada para MVP** (no automatizada; Open Cloud = futuro opcional); exclusión = **solo `Workspace.Hub`** (resto del Workspace conservado para FloorService); `hubPlaceId = 84186294312317` completado; backup **explícito solo en la 1.ª publicación** y releases siguientes por **historial de versiones** del place |