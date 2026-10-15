# HU-R6.26: Fix UI — party frame: actualización en tiempo real, línea CLASE·NIV y vida verde

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI — Fix (reportado por PO 2026-09-22)
**Prioridad:** Alta
**Estado:** Implementada (reporte PO 2026-09-22; verificación/QA pendiente)
**Tipo:** Bugfix de UI/estado (dev)
**Fase GDD:** R6.26 (no cambia reglas de juego)
**Depende de:** HU-R9a (party, PartyStateUpdate), HU-ESTETICA-22 (party frames), HU-R6a (XP/leveling), HU-R2 (ClassConfig display names)
**Componentes observados:** party frame (R9a/EST-22), `PartyStateUpdate`, `XPService` (nivel), `ClassConfig` (display names)

---

### **Narrativa (INVEST)**

**Como** jugador en party,
**quiero** que el party frame muestre **información real y al día**: nivel actualizado en vivo, línea "CLASE · NIV X" (sin spec — diseño aprobado) y **vida en verde**,
**para** saber el estado real de mis aliados sin ambigüedades.

---

### **Descripción del Requerimiento / Contexto**

**Bugs reportados (PO 2026-09-22) en el party frame:**

1. **No se actualiza en tiempo real:** si un miembro **sube de nivel**, el frame se queda con el nivel de cuando fue invitado (los datos no refrescan).
2. **Spec con id crudo:** muestra `cleric_colera` — **resuelto por diseño (enmienda PO 2026-09-22):** el party simplificado **NO muestra la spec** (línea "CLASE · NIV X" como el frame aprobado `cGcxE`); el requisito de formato "Clase - Spec" queda eliminado.
3. **Vida en rojo:** la barra de vida de los miembros debe ser **verde** (decisión PO — la vida de aliados se distingue así del HP propio/enemigos).

**Criterio de hecho global:** el party frame refleja el estado real de los miembros en todo momento (nivel/HP/estado), muestra la línea "CLASE · NIV X" sin spec y la vida en verde.

---

### **Especificaciones Técnicas / Contratos de API**

* **Actualización en tiempo real:** el party frame se refresca con eventos de cambio del server:
  * **Nivel:** `XPService` (subida de nivel) → `PartyStateUpdate` al party (o el cliente escucha el cambio del miembro) → la fila actualiza nivel.
  * **HP/MP:** cambios de vida/maná de los miembros se reflejan (delta/estado periódico o evento).
  * **Estado:** caída/respawn de un miembro actualizan la fila (la spec no se muestra en el diseño aprobado).
  * Sin polling pesado: event-driven (el patrón de `PartyStateUpdate` existente se extiende con los datos nuevos).
* **Sin spec en la fila (enmienda PO 2026-09-22):** el diseño aprobado muestra "CLASE · NIV X" (ej. "PALADÍN · NIV 16") — el requisito de formato "Clase - Spec" queda eliminado; nunca ids crudos visibles.
* **Vida verde:** la barra de HP de los miembros usa **verde** (ej. `#7BC47F`, patrón de cura del HUD) en vez del rojo; el MP se mantiene con su color.
* Coherente con el diseño de EST-22 y los tokens de EST-13.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Nivel en vivo**

* **GIVEN** un party con un miembro cerca de subir de nivel
* **WHEN** sube de nivel
* **THEN** el party frame muestra el nuevo nivel al momento (sin reinvitar)

#### **Escenario 2: Sin spec (diseño aprobado)**

* **GIVEN** el party frame
* **WHEN** se revisa la fila de un miembro
* **THEN** la línea muestra "CLASE · NIV X" (ej. "PALADÍN · NIV 16") — **sin spec**, nunca como `cleric_colera`

#### **Escenario 3: Vida verde**

* **GIVEN** el party frame
* **WHEN** se revisa la barra de vida de los miembros
* **THEN** es **verde** (y se distingue del HP propio/enemigos)

#### **Escenario 4: HP/estado en vivo**

* **GIVEN** un party en la dungeon
* **WHEN** un miembro pierde vida, muere/respawnea
* **THEN** el frame refleja el estado real al momento

#### **Escenario 5: Regresión**

* **GIVEN** el fix aplicado
* **WHEN** se juega en party (PC y móvil, publicado)
* **THEN** no hay errores rojos y el resto del frame funciona

---

### **Alcance**

#### Incluye

* Actualización en vivo del party frame (nivel, HP, estado) event-driven.
* Línea "CLASE · NIV X" sin spec (diseño aprobado `cGcxE`).
* Vida de miembros en verde.

#### No incluye

* Cambios al diseño del frame (EST-22 intacto) ni a la lógica del party (R9a).

---

### **Definition of Done (DoD)**

* [ ] Party frame actualiza nivel/HP/estado en tiempo real (event-driven).
* [ ] Línea "CLASE · NIV X" sin spec (diseño aprobado).
* [ ] Vida de miembros en verde.
* [ ] Sin errores rojos en party (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1–2 sesiones del dev: extensión de `PartyStateUpdate` + formato + colores.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.26: fix del party frame — actualización en tiempo real (nivel/HP/MP/spec/estado), spec en formato "Clase - Spec" y vida de miembros en verde (reportado por PO) |
| 2026-09-22 | **Enmienda PO (diseño aprobado `cGcxE`):** fuera el requisito de spec — la fila muestra "CLASE · NIV X" sin spec (nunca ids crudos); la actualización en vivo cubre nivel/HP/estado |