# HU-PUBLICAR-01: Publicación de Vandrheim — configuración de la experiencia y acceso (PO)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Publicación / Ops
**Prioridad:** Alta
**Estado:** Lista para ejecutar
**Tipo:** Publicación y configuración en Roblox (PO/publicador — **sin código**; el dev hace la integración en HU-PUBLICAR-02)
**Fase GDD:** Publicación (transversal)
**Depende de:** HU-R6b (flujo dungeon con ReservedServer + teleport data), HU-PUBLICAR-02 (integración del dev), juego funcional publicado de forma limitada

---

### **Narrativa (INVEST)**

**Como** publicador,
**quiero** publicar la experiencia completa (pueblo + dungeon como place aparte) y abrirla a mis amigos,
**para** probar el flujo real pueblo → portal → dungeon → recompensa → pueblo en un entorno publicado, no solo en Studio.

**Como** equipo,
**quiero** dejar los places y accesos configurados correctamente,
**para** que nadie entre a la dungeon saltándose el portal y las pruebas sean limpias.

---

### **Descripción del Requerimiento / Contexto**

El juego ya está publicado de forma limitada (solo amigos) con el pueblo. El flujo de dungeon **nunca se probó publicado**: falta crear el place de la dungeon dentro de la misma experiencia y conectar el portal (integración del dev, HU-PUBLICAR-02). Esta HU cubre **la parte de publicación/configuración** que hace el publicador (PO):

1. Publicar el **pueblo** como la experiencia Vandrheim (ya hecho, se mantiene el acceso de amigos).
2. Crear el place **Dungeon_Helada** dentro de la misma experiencia.
3. Tomar los **Place IDs** y pasárselos al dev para la integración.
4. Configurar **accesos**: experiencia solo amigos; dungeon **Secure within universe only** (solo accesible por teleport iniciado por el servidor).
5. **Probar desde el cliente de Roblox** (no Play Solo): pueblo → portal → dungeon → volver, primero solo y luego con amigos.

**Criterio de hecho global:** la experiencia publicada tiene 2 places (pueblo + dungeon), el dungeon es inaccesible directamente, el portal funciona publicado y los amigos pueden entrar a la run completa.

---

### **Especificaciones Técnicas / Contratos de API (procedimiento)**

#### **1. Publicar el pueblo (ya hecho — verificar)**

* El place publicado del pueblo es la experiencia Vandrheim con acceso limitado a amigos (mantener).
* Verificar en el Creator Dashboard que la experiencia existe y el place del pueblo está publicado con su versión actual.

#### **2. Crear el place de la dungeon**

En Roblox Studio (pasos del dev, pero los ejecuta el publicador con su cuenta o el dev con permiso):

1. Abrir el place publicado del pueblo.
2. `File → Publish to Roblox As…`.
3. Seleccionar la experiencia Vandrheim existente.
4. `Add as a new place` y nombrarlo, ej. **Dungeon_Helada**.
5. Publicar (el contenido inicial lo estructura el dev en HU-PUBLICAR-02).
6. **Obtener el Place ID** del Creator Dashboard (menú de la experiencia → Configuración del place) y pasárselo al dev para configurar el portal.

#### **3. Accesos (Creator Dashboard)**

| Ámbito | Configuración |
|--------|---------------|
| Experiencia Vandrheim | Acceso limitado: **solo amigos** (como está) — o el círculo que el PO decida |
| Place Dungeon_Helada | `Audience → Access Settings → Access Control for Places →` **Secure within universe only** — la entrada ocurre solo por teleports iniciados por el servidor dentro de Vandrheim (evita saltarse el portal) |

#### **4. Prueba publicada (checklist)**

* **Importante:** el teleport entre places **no se prueba en Play Solo**; se prueba desde el **cliente de Roblox** (app del juego publicada).
* **Solo (PO):**
  * Entrar al pueblo → hablar con NPCs (opcional) → **portal** → dungeon (piso 1) → avanzar pisos → completar run o abandonar → volver al pueblo con lo ganado (XP/loot/oro).
  * Rejoin con el mismo PJ: el perfil y lo ganado persisten.
* **Con amigos (2+):**
  * Cada uno en su propia run (instancia propia).
  * Uno en la dungeon mientras el otro está en el pueblo: sin interferencias.
  * Salir a mitad de run y reingresar: run no se reanuda, lo ganado persiste.
* **Errores esperados a reportar al dev:** fallos de teleport, dungeon vacía/sin servicios, perfil no cargado en la dungeon, HUD de dungeon ausente.

#### **5. Post-pruebas**

* Reportar al PM/dev los resultados (funcionó / falló + qué).
* Si todo pasa, se puede ampliar el acceso (público) en una decisión posterior del PO (NO en esta HU).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Place de dungeon creado**

* **GIVEN** la experiencia Vandrheim publicada
* **WHEN** se revisa el Creator Dashboard
* **THEN** existen 2 places (pueblo + `Dungeon_Helada`) en la misma experiencia
* **AND** el Place ID de la dungeon está disponible para la integración (HU-PUBLICAR-02)

#### **Escenario 2: Acceso controlado**

* **GIVEN** la experiencia con acceso de amigos
* **WHEN** se intenta entrar directo al place de la dungeon desde Roblox
* **THEN** no se puede (Secure within universe only)
* **AND** solo el teleport del portal (server) permite entrar

#### **Escenario 3: Flujo publicado (solo)**

* **GIVEN** el juego publicado con amigos
* **WHEN** el PO entra por el cliente de Roblox y usa el portal
* **THEN** llega a la dungeon (piso 1), avanza pisos y completa/abandona la run
* **AND** vuelve al pueblo con lo ganado persistido (rejoin OK)

#### **Escenario 4: Flujo con amigos**

* **GIVEN** 2+ amigos en la experiencia
* **WHEN** entran al portal
* **THEN** cada uno tiene su propia run (instancias separadas)
* **AND** no se interfieren entre sí (pueblo/dungeon simultáneos OK)

#### **Escenario 5: Reporte de resultados**

* **GIVEN** las pruebas publicadas
* **WHEN** hay fallos o dudas
* **THEN** se reportan al PM/dev con detalle (qué, dónde, mensajes)
* **AND** no se amplía el acceso a público sin decisión del PO

---

### **Comportamiento Visual / Reglas de Negocio**

* No cambia gameplay, lógica ni reglas: es publicación/configuración.
* El place de dungeon es **parte de la misma experiencia** (DataStores compartidos: el perfil carga en la dungeon con el DataService existente).
* Acceso público es decisión posterior del PO (fuera de esta HU).

---

### **Alcance**

#### Incluye

* Verificación de la experiencia publicada con acceso de amigos.
* Creación del place `Dungeon_Helada` (Add as a new place) + obtención del Place ID.
* Configuración de accesos (experiencia amigos; dungeon secure within universe).
* Prueba publicada desde el cliente (solo y con amigos) con checklist.
* Reporte de resultados al PM/dev.

#### No incluye

* Código, integración del portal, bootstrap del place de dungeon (dev — HU-PUBLICAR-02).
* Ampliar el acceso a público.
* Cambios de gameplay, balance o contenido.

---

### **Definition of Done (DoD)**

* [ ] 2 places en la experiencia: pueblo + `Dungeon_Helada` (Place ID obtenido y entregado al dev).
* [ ] Dungeon configurada como *Secure within universe only*; experiencia en acceso de amigos.
* [ ] Prueba publicada desde el cliente: portal → dungeon → pisos → completar/abandonar → vuelta al pueblo (solo).
* [ ] Prueba con amigos: runs independientes sin interferencias.
* [ ] Rejoin: perfil y lo ganado persisten.
* [ ] Resultados reportados al PM/dev (éxitos y fallos).

---

### **Estimación (orientativa)**

1–2 sesiones del PO: publicación del place + accesos + pruebas desde el cliente (solo y con amigos).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-18 | Creación de HU-PUBLICAR-01: publicación/configuración de Vandrheim para probar el flujo de dungeon publicado — crear el place `Dungeon_Helada`, accesos (amigos + secure within universe), Place ID para el dev y pruebas desde el cliente |
| 2026-09-18 | Place `Dungeon_Helada` **publicado**; **Place ID = `125210265978348`** entregado al dev (HU-PUBLICAR-02); pendiente: secure within universe + pruebas desde el cliente |