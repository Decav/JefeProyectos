# HU-ESTETICA-24: Iconos de las 3 clases — Paladín, Cazador, Clérigo

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Iconos
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de iconos (diseñador) — el dev los enlaza por id en config/UI
**Fase GDD:** EST (transversal; habilita selección/creación de PJ, party frames y HUD)
**Depende de:** HU-ESTETICA-25 (selección/creación de PJ — los usa), HU-ESTETICA-22 (party frames — clase por icono), HU-ESTETICA-19/20 (HUD), ASSETS_POLICY (estándar y registro), `ASSETS_LIST.md`
**No modifica:** lógica del juego, clases ni balance

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** reconocer la clase de un personaje de un vistazo (en la selección de PJ, en el party y en mi HUD),
**para** elegir, identificar y coordinar sin leer texto.

**Como** equipo de desarrollo,
**quiero** los iconos de clase listos y registrados,
**para** que el dev los enlace por `iconId` en la UI sin crear assets.

---

### **Descripción del Requerimiento / Contexto**

La UI usa la clase como texto hoy. Se agregan **3 iconos de clase** (decisión PM 2026-09-22: solo clases, no specs por ahora) que se usarán en:

* **Selección y Creación de PJ** (HU-ESTETICA-25): identificar cada slot/opción.
* **Party frames** (EST-22): "clase (icono/texto)" pasa a icono real.
* **Player frame del HUD** (opcional): identidad del jugador.

**Criterio de hecho global:** existen los 3 iconos de clase con el estándar aprobado (512×512, fondo negro = finales), registrados y referenciados por la UI (EST-25/22), listos para el dev.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Iconos a crear**

| ID | Clase | Prompt/estilo (Gemini — ASSETS_LIST) |
|----|-------|---------------------------------------|
| `Icon_Class_paladin` | Paladín | Escudo y espada cruzados en latón dorado sobre fondo negro, acentos de luz sagrada, estilo pintado digital, detalle medio, iluminación de fantasía, gama acero/dorado |
| `Icon_Class_hunter` | Cazador | Arco de cuero y madera nórdico con flecha, silueta de lobo o garra sutil, acentos verdes/gris bosque, fondo negro, estilo pintado digital |
| `Icon_Class_cleric` | Clérigo | Cruz de luz / varita con gema azul y halo radiante, acentos crema/marfil y dorado cálido, fondo negro, estilo pintado digital |

* Estándar: **512×512, fondo negro #000000, objeto ~85% centrado, perspectiva frontal/3/4, paleta Vandrheim** (mismo estándar que los ítems/skills — ASSETS_LIST).
* **Reconocibles de un vistazo** a tamaño pequeño (casilla de slot ~44–64 px) y con icono de clase.
* Coherentes con la identidad visual de cada clase (Placas/luz del Paladín, cuero/bosque del Cazador, tela/luz del Clérigo).

#### **2. Entrega y registro**

* Se agregan a `ASSETS_LIST.md` (con sus prompts).
* Se suben al Asset Server (dev) y se registran en `ASSETS_REGISTRY` (id, tipo, uso, fuente, licencia).
* El dev los enlaza por id en: selección/creación de PJ (EST-25), party frames (EST-22) y player frame del HUD (opcional).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Iconos creados**

* **GIVEN** los 3 iconos entregados
* **WHEN** se revisan
* **THEN** existen `Icon_Class_paladin/hunter/cleric` con el estándar (512×512, fondo negro, paleta Vandrheim)
* **AND** son reconocibles a tamaño de slot (44–64 px)

#### **Escenario 2: Identidad por clase**

* **GIVEN** los iconos
* **WHEN** se comparan entre sí
* **THEN** cada uno refleja su clase (paladín: luz/escudo; cazador: cuero/arco; clérigo: luz/varita)
* **AND** no se confunden entre sí ni con iconos de ítems/skills

#### **Escenario 3: Registro y uso**

* **GIVEN** los iconos
* **WHEN** se revisa ASSETS_LIST y ASSETS_REGISTRY
* **THEN** están documentados, registrados y listos para enlazar en la UI (EST-25/22)

---

### **Comportamiento Visual / Reglas de Negocio**

* Solo assets: no cambia clases, stats ni gameplay.
* El estándar de fondo negro se mantiene (decisión R8).

---

### **Alcance**

#### Incluye

* 3 iconos de clase (ASSETS_LIST + prompts).
* Registro en ASSETS_REGISTRY.
* Referencia de uso en EST-25 (selección/creación de PJ) y EST-22 (party frames).

#### No incluye

* Iconos de specs (6) — decisión posterior si el PO los pide.
* Modelos 3D, cambios a clases ni a la UI existente (los reskins de ventanas son de sus propias HUs).

---

### **Definition of Done (DoD)**

* [ ] Los 3 iconos existen con el estándar aprobado y son reconocibles a tamaño de slot.
* [ ] `ASSETS_LIST.md` y `ASSETS_REGISTRY` actualizados.
* [ ] Referenciados en EST-25 (selección/creación) y EST-22 (party frames).
* [ ] Sin cambios a gameplay ni balance.
* [ ] Reporte al PM con el detalle de la entrega.

---

### **Estimación (orientativa)**

1 sesión del diseñador: 3 iconos + registro.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-24: iconos de las 3 clases (Paladín/Cazador/Clérigo) con estándar ASSETS_LIST — usados en selección/creación de PJ (EST-25), party frames (EST-22) y HUD |