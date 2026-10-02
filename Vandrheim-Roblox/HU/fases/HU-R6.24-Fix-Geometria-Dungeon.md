# HU-R6.24: Fix de geometría de la dungeon — escombros de esfera en Caverna Helada y pasillos del Corredor Helado

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Dungeon — Fix de layout (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Bugfix de geometría/kit de la dungeon (dev)
**Fase GDD:** R6.24 (no cambia reglas de juego ni seeds)
**Depende de:** HU-R6a (kit Helada/FloorService), HU-R6.3 (variantes de layout — variante "Caverna"), HU-R6.4 (topología — corredores)
**Componentes observados:** kit de la dungeon (escombros, pasillos del corredor helado), `FloorService`/`DungeonVariantConfig`

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una dungeon sin obstáculos que arruinen el flujo:
* que la **Caverna Helada** no tenga esferas de hielo que tapen entradas ni permitan subirse y glitchear,
* que los **pasillos del Corredor Helado** sean más anchos para andar cómodo en grupo,
**para** que las variantes se sientan limpias y jugables en party.

---

### **Descripción del Requerimiento / Contexto**

**Bugs reportados (PO 2026-09-22):**

1. **Caverna Helada (variante):** la estructura de **escombros tipo esfera de hielo** puede **tapar entradas** y permite **subirse y glitchear** el entorno (además de verse mal). Hay que reemplazarla por algo mejor: **estalagmita, pilar o escombro de hielo**.
2. **Corredor Helado:** los **pasillos son muy delgados** — en grupo (party 2–4) es molesto; deben ser **un poco más grandes**.

**Criterio de hecho global:** la variante Caverna no tiene esferas de hielo (reemplazadas por escombros/pilares de hielo sin bloquear entradas ni permitir glitches de escalada) y los pasillos del Corredor son más anchos — sin romper la generación por seed ni la topología.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Caverna Helada — reemplazo de la esfera de hielo**

* Eliminar la **esfera de hielo** del kit de la variante Caverna.
* Reemplazarla por **estalagmitas, pilares o escombros de hielo** (props del kit):
  * **Sin bloquear entradas:** los props no deben tapar pasillos/entradas (raycast/path-check del kit o posición de spawn correcta).
  * **Sin glitches de escalada:** formas **no apilables/no escalables** (altura acotada, sin superficies planas para pararse encima, `CanCollide` solo donde aporta) — el jugador no puede subirse.
* **Auditoría de la variante:** revisar el resto de props de Caverna con el mismo criterio (nada escalable ni bloqueante).

#### **2. Corredor Helado — pasillos más anchos**

* Aumentar el **ancho de los pasillos/segmentos** del kit del Corredor Helado (valor sugerido: ~+25–30% de ancho; el dev ajusta para que 4 jugadores pasen cómodos).
* **Sin romper la generación:** el cambio es de las piezas del kit (no de los seeds): los layouts generados por seed siguen funcionando (R6.3/R6.4 intactos); verificar que las salas/boss rooms conectan igual.
* **Regresión:** varias runs con seeds distintos (solo y party) sin errores ni atascos.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Sin esferas**

* **GIVEN** la variante Caverna Helada
* **WHEN** se generan pisos
* **THEN** no aparecen esferas de hielo; en su lugar hay estalagmitas/pilares/escombros de hielo
* **AND** las entradas quedan despejadas y no se puede subir a los props (sin glitches)

#### **Escenario 2: Pasillos cómodos**

* **GIVEN** el Corredor Helado
* **WHEN** se recorre en party (2–4)
* **THEN** los pasillos son más anchos y el grupo avanza sin amontonarse

#### **Escenario 3: Generación intacta**

* **GIVEN** el fix de geometría
* **WHEN** se corren runs con seeds distintos (solo y party)
* **THEN** los layouts se generan igual (variantes y topología intactas) y no hay errores rojos

---

### **Alcance**

#### Incluye

* Reemplazo de la esfera de hielo en la variante Caverna (estalagmitas/pilares/escombros, sin bloquear ni escalar).
* Auditoría de props de la variante.
* Ancho de pasillos del Corredor Helado (+25–30% sugerido).

#### No incluye

* Cambios a seeds, topología, reglas ni balance.

---

### **Definition of Done (DoD)**

* [ ] Sin esferas de hielo en la Caverna (props nuevos, no bloquean entradas, no escalables).
* [ ] Pasillos del Corredor más anchos (party cómodo).
* [ ] Generación por seed intacta (solo y party); sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

1–2 sesiones del dev: props del kit + ancho de pasillos + regresión de generación.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.24: fix de geometría de la dungeon — esfera de hielo de la Caverna Helada reemplazada (estalagmitas/pilares, sin bloquear ni escalar) y pasillos del Corredor Helado más anchos (party cómodo); generación por seed intacta (reportado por PO) |