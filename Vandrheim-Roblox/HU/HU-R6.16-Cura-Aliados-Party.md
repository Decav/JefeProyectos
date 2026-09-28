# HU-R6.16: Cura a aliados del party — targeting de aliados por party frame y heals dirigidos

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9a / Party — Mejora (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mejora de targeting/healing en party (dev)
**Fase GDD:** R9a (complementa el party de amigos)
**Depende de:** HU-R9a (party, frames EST-22), HU-R3.2/R3.3 (targeting), SKILLS_CATALOG (heals del Clérigo y Voto protector del Protector)
**Componentes observados:** `TargetingSystem`, party frames (EST-22/R9a), `SkillConfig` (heals), `SkillService`

---

### **Narrativa (INVEST)**

**Como** jugador Clérigo,
**quiero** poder **curar a un aliado del party** además de a mí mismo,
**para** cumplir mi rol de sanador en grupo.

**Como** jugador Paladín Protector,
**quiero** que mi cura siga siendo **solo para mí**,
**para** que el rol del tanque no se mezcle con el del healer.

---

### **Descripción del Requerimiento / Contexto**

Con las partys (R9a), el Clérigo tiene rol de sanador pero **solo puede curarse a sí mismo**. Se agrega el **targeting de aliados**:

* **Seleccionar aliado:** se puede targetear a un jugador del party **desde el party frame** (clic/toque en su fila) — **sin posibilidad de atacarlo** (es solo selección de cura/apoyo).
* **Regla de cura:** con aliado seleccionado → la skill de heal cura al **aliado**; sin aliado seleccionado **o** con target enemigo → te curas **a ti mismo**.
* **Excepción:** el **Voto protector** del Paladín Protector es **EXCLUSIVAMENTE self** — nunca cura aliados con este sistema (flag por skill).

**Criterio de hecho global:** el Clérigo cura a sí mismo o al aliado seleccionado (party frame) según la regla; el Voto protector sigue siendo self-only; nada de atacar aliados.

---

### **Especificaciones Técnicas / Contratos de API**

* **Targeting de aliado:** nuevo estado de target "aliado" (separado del target enemigo): se setea desde el party frame (clic/touch en la fila del miembro); se limpia al deseleccionar/cambiar. Sin daño posible hacia aliados (el server nunca acepta skills de daño contra aliados).
* **Targeting separado (decisión PM 2026-09-22):** el target **aliado** y el target **enemigo** son **estados independientes** y pueden coexistir (fila resaltada en el party frame + indicador en el enemigo). **Seleccionar un aliado NO bloquea las skills ofensivas**: las ofensivas siguen usando el target enemigo (o el más cercano si no hay — ver HU-R6.21); solo los heals/escudos usan el target aliado cuando está seteado. El server rechaza cualquier intento de daño hacia aliados.
* **SkillConfig:** heals/escudos dirigibles (**Sanación, Palabra de luz, Milagro, Escudo de fe**) con `targetType = "ally_or_self"`; **Voto protector** con `targetType = "self_only"` (regla dura: no dirige a aliados).
* **SkillService:** al castear una skill `ally_or_self`: si hay **aliado seleccionado** → aplica al aliado; si no (o hay enemigo seleccionado) → **self**. `self_only` siempre self.
* **Rango de heals a aliado (decisión PM):** **25 studs** (config `allyRange` por skill en `SkillConfig`, default 25); si el aliado está fuera de rango → **self-heal con aviso** ("Aliado fuera de rango") — el flujo nunca se queda sin efecto.
* **Deselección (decisión PM):** **toggle** — re-clic/tap en la misma fila deselecciona al aliado; clic en otra fila cambia de aliado; el propio jugador también es seleccionable (self). No se deselecciona al abrir/cerrar ventanas.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Curar aliado**

* **GIVEN** un Clérigo en party con un aliado herido
* **WHEN** selecciona al aliado en el party frame y castea Sanación
* **THEN** el aliado recibe la cura (y no el Clérigo)

#### **Escenario 2: Self por defecto**

* **GIVEN** un Clérigo sin aliado seleccionado (o con enemigo seleccionado)
* **WHEN** castea un heal
* **THEN** se cura a sí mismo

#### **Escenario 3: Voto protector self-only**

* **GIVEN** un Paladín Protector con un aliado seleccionado
* **WHEN** castea Voto protector
* **THEN** se cura a sí mismo (nunca al aliado)

#### **Escenario 4: Fuera de rango**

* **GIVEN** un aliado seleccionado fuera de rango
* **WHEN** se castea el heal
* **THEN** se cura self con aviso "Aliado fuera de rango"

#### **Escenario 5: Sin ataque a aliados**

* **GIVEN** un aliado seleccionado
* **WHEN** se intenta lanzar una skill de daño
* **THEN** el server rechaza (no se puede atacar aliados)

#### **Escenario 6: Regresión**

* **GIVEN** el sistema implementado
* **WHEN** se juega en party (solo y en grupo, PC y móvil)
* **THEN** no hay errores rojos y el targeting enemigo sigue igual

---

### **Alcance**

#### Incluye

* Targeting de aliados desde el party frame (sin ataque).
* Regla de heal self/aliado + excepción self-only (Voto protector).
* Rango de heals a aliado con fallback a self.

#### No incluye

* Buffs/escudos a aliados más allá de los heals definidos.
* Revivir aliados caídos.
* Cambios al targeting enemigo ni a otros sistemas.

---

### **Definition of Done (DoD)**

* [ ] Aliado seleccionable desde el party frame (resaltado visual).
* [ ] Heals dirigen a aliado/self según regla; Voto protector self-only.
* [ ] Fuera de rango → self + aviso; sin ataque a aliados (server).
* [ ] Sin errores rojos en party (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: targeting aliado + reglas de heal + rango + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.16: cura a aliados del party — targeting por party frame (sin ataque), heals self/aliado por regla y Voto protector self-only (reportado por PO) |
| 2026-09-22 | **Decisiones PM (feedback dev):** rango de heal a aliado = **25 studs** (config `allyRange`); **Escudo de fe dirigible** a aliados (con Sanación/Palabra/Milagro); **targeting separado** (aliado y enemigo son estados independientes — las ofensivas no se bloquean y usan el target enemigo, ver R6.21); deselección por **toggle** (re-clic en la fila) |