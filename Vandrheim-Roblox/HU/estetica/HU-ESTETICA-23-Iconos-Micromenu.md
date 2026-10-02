## HU-ESTETICA-23: Iconos minimalistas del micromenú del HUD

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Iconos
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Producción de iconos (diseñador) — el dev los enlaza por `iconId` en config
**Fase GDD:** EST (transversal; complementa HU-ESTETICA-19 — micromenú del HUD)
**Depende de:** HU-ESTETICA-19 (micromenú del HUD), ASSETS_POLICY.md (estándar y registro), `ASSETS_LIST.md`
**No modifica:** lógica del juego, HUD, micromenú ni gameplay

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los botones del micromenú del HUD tengan iconos claros y minimalistas que se lean al instante en tamaño chico,
**para** identificar mochila, equipo, talentos, grimorio, menú y nameplates sin leer texto.

**Como** equipo de desarrollo,
**quiero** los iconos del micromenú listos y registrados,
**para** enlazarlos por `iconId` en config sin tocar la UI ni el código.

---

### **Descripción del Requerimiento / Contexto**

El micromenú del HUD (HU-ESTETICA-19) necesita iconos personalizados para sus botones. A diferencia de los iconos de ítems/skills de `ASSETS_LIST` (pintados y detallados), estos son **minimalistas**: el tamaño final dentro del micromenú es pequeño (~24–32 px), por lo que el diseño debe priorizar **silueta y contraste** sobre detalle.

Se mantiene el estándar técnico del proyecto: **512×512 con fondo negro sólido `#000000`**, objeto centrado, sin texto ni marco. La diferencia es el nivel de detalle y la paleta acotada.

**Criterio de hecho global:** existen los 6 iconos minimalistas del micromenú, legibles en tamaño pequeño, subidos a Roblox y registrados para que el dev los enlace por `iconId`.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **Estilo minimalista (obligatorio)**

* **512×512, fondo negro sólido `#000000`**, sin gradiente de fondo, sin marco, borde ni texto.
* Objeto centrado, ~85% del encuadre, silueta simple y cerrada (se lee incluso a 24 px).
* **Paleta acotada (2–3 colores por icono, sin degradados complejos):**
  * Latón `#C89445` (elemento principal / dorado).
  * Pergamino `#F4EDE0` (detalles secundarios).
  * Acento frío `#8FB7D6` (un solo acento por icono, opcional).
* Formas geométricas simples, grosor de línea consistente, sin texturas, sin sombras ni brillos internos.
* No cartoon: silueta nórdica clara (similar al estilo Hearthbound Gold).

#### **Iconos (uno por imagen, naming `Icon_Menu_<accion>`)**

| # | Archivo | Acción | Descripción minimalista |
|---|---------|--------|--------------------------|
| 1 | `Icon_Menu_bag` | Mochila (B) | Bolsa de cuero con silueta redondeada, una hebilla de latón al frente |
| 2 | `Icon_Menu_equipment` | Equipo (C) | Coraza simple de perfil con una gema fría `#8FB7D6` al centro |
| 3 | `Icon_Menu_talents` | Talentos | Rama/árbol minimalista con 3 runas de latón en línea |
| 4 | `Icon_Menu_spellbook` | Grimorio | Libro cerrado con una runa de latón en la tapa |
| 5 | `Icon_Menu_escape` | Menú (ESC) | Escudo nórdico con doble línea vertical grabada (pausa) |
| 6 | `Icon_Menu_nameplates` | Toggle nameplates (N) | Ojo estilizado con una barra de vida corta encima (latón + frío) |

#### **Entrega**

* Generar las 6 imágenes con el estilo minimalista.
* Subirlas a Roblox (Asset Server) y devolver los `rbxassetid`.
* Registrar en `ASSETS_REGISTRY` (id, tipo, uso: botón del micromenú, fuente, licencia, fecha).
* Actualizar `ASSETS_LIST.md` con las 6 entradas si corresponde.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Iconos legibles en tamaño chico**

* **GIVEN** los 6 iconos generados.
* **WHEN** se reducen a ~24–32 px (tamaño del micromenú).
* **THEN** cada icono se distingue sin ambigüedad de los demás.
* **AND** no se pierde la silueta por exceso de detalle.

#### **Escenario 2: Estilo consistente**

* **GIVEN** los 6 iconos juntos.
* **WHEN** se comparan.
* **THEN** comparten paleta (latón/pergamino + un acento frío), grosor de línea y estilo de silueta.
* **AND** se ven como un set, no como imágenes sueltas.

#### **Escenario 3: Fondo negro y sin texto**

* **GIVEN** cada icono.
* **WHEN** se revisa el archivo.
* **THEN** el fondo es negro sólido `#000000`, sin marco ni texto.
* **AND** el objeto ocupa ~85% centrado.

#### **Escenario 4: Enlace por config**

* **GIVEN** los assets subidos y registrados.
* **WHEN** el dev coloca los `rbxassetid` en el `iconId` de cada botón del micromenú.
* **THEN** los botones muestran los iconos en el juego.

---

### **Comportamiento Visual / Reglas de Negocio**

* Minimalistas: silueta simple y alto contraste (latón sobre negro), pensados para tamaño chico.
* El micromenú mantiene su diseño de EST-19; estos iconos solo se enlazan por `iconId`.
* No se cambia la lógica del micromenú ni las acciones de los botones.

---

### **Alcance**

#### Incluye

* 6 iconos minimalistas (`Icon_Menu_bag`, `Icon_Menu_equipment`, `Icon_Menu_talents`, `Icon_Menu_spellbook`, `Icon_Menu_escape`, `Icon_Menu_nameplates`).
* Estilo minimalista con paleta acotada (latón/pergamino + acento frío).
* Subida a Roblox, `rbxassetid` y registro en `ASSETS_REGISTRY`.
* Actualización de `ASSETS_LIST.md`.

#### No incluye

* Rediseño del micromenú ni de sus estados (eso es de EST-19).
* Iconos de ítems, skills o del HUD base (estándar detallado de `ASSETS_LIST`).
* Código, UI o cambios de gameplay.

---

### **Definition of Done (DoD)**

* [ ] Los 6 iconos existen con estilo minimalista y fondo negro.
* [ ] Legibles a ~24–32 px y distinguibles entre sí.
* [ ] Paleta y grosor de línea consistentes entre los 6.
* [ ] Subidos a Roblox con `rbxassetid` devuelto.
* [ ] Registrados en `ASSETS_REGISTRY` (fuente/licencia).
* [ ] `ASSETS_LIST.md` actualizado.
* [ ] El dev puede enlazarlos por `iconId` en el micromenú (EST-19).

---

### **Decisiones por defecto EST-23**

| Tema | Default |
|------|---------|
| Tamaño de origen | 512×512 |
| Fondo | Negro sólido `#000000` |
| Estilo | Minimalista, silueta simple, sin texturas |
| Paleta | Latón `#C89445` + pergamino `#F4EDE0` + 1 acento frío `#8FB7D6` por icono |
| Cantidad | 6 iconos (`bag`, `equipment`, `talents`, `spellbook`, `escape`, `nameplates`) |
| Entrega | Asset Server + `ASSETS_REGISTRY` + `ASSETS_LIST.md` |

---

### **Estimación (orientativa)**

1 sesión del diseñador: 6 iconos minimalistas + subida + registro.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-20 | Creación de HU-ESTETICA-23: 6 iconos minimalistas del micromenú (fondo negro, silueta simple, paleta acotada) para el HUD de combate |