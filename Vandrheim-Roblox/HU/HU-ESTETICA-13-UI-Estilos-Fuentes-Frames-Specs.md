# HU-ESTETICA-13: Especificación de implementación de la UI — estilos, fuentes, frames y assets (handoff al dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / EST-04 (handoff de implementación)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Specs + exportación de assets para implementación (diseñador; **sin desarrollo** — el dev implementa después)
**Fase GDD:** EST (transversal; habilita la implementación del reskin de toda la UI)
**Depende de:** HU-ESTETICA-04 (sistema de diseño Hearthbound Gold), HU-ESTETICA-06 (revisión UI), HU-ESTETICA-08/09/10/11/12 (pantallas a fondo), ASSETS_POLICY (fuentes/licencias/registro)
**No modifica:** lógica del juego, ni ninguna ventana existente

---

### **Narrativa (INVEST)**

**Como** desarrollador,
**quiero** un paquete de especificación completo: tokens (colores, radios, bordes, espaciados), fuentes con su mapeo a las disponibles en Roblox, frames/componentes exportables (9-slice, botones por estado, iconos) y notas de adaptación (responsive, zona segura móvil, animaciones),
**para** reconstruir la nueva UI en Roblox (ScreenGui/Frame/ImageLabel/TextLabel/UIStroke/UIGradient/TweenService) sin reinterpretar el diseño ni adivinar valores.

**Como** equipo de desarrollo,
**quiero** saber de antemano qué partes del diseño son directas, cuáles requieren adaptación y cuáles pueden dar problemas en Roblox,
**para** estimar y ejecutar el reskin sin sorpresas, manteniendo intacta la lógica existente (inventario, talentos, skills, menú).

---

### **Descripción del Requerimiento / Contexto**

El dev confirmó que el diseño de Pencil es implementable pero **no se importa directamente**: hay que reconstruirlo en Roblox (ScreenGui, Frame, ImageLabel, TextLabel, UIStroke, UIGradient, TweenService), y hay que adaptar **fuentes disponibles**, **escalado responsive**, **zona segura del móvil** y **animaciones propias de CSS/web**.

Esta HU entrega el **paquete de handoff** que resuelve esos puntos: la documentación y los assets que el dev necesita para implementar **toda la nueva interfaz** (HUD, barras, mochila, equipo/stats, talentos, grimorio, vendor, menús, mobile), usando el diseño de Pencil como **referencia visual** y reemplazando progresivamente la UI actual **sin tocar la lógica** (regla de EST-04: se conservan nombres de instancias y jerarquía que los scripts usan).

**Criterio de hecho global:** existe un documento de specs + un set de assets exportados (PNG/9-slice/estados) + el mapeo de fuentes + las notas de adaptación, suficientes para que el dev implemente el reskin completo sin reinterpretar nada.

---

### **Especificaciones Técnicas / Contratos de API (handoff)**

#### **1. Documento de specs (tokens, con valores exactos)**

* **Paleta completa** (ya definida en EST-04): todos los colores con hex, agrupados por rol (fondos, paneles, barras, texto, acentos, rarezas, estados) — incluyendo los tokens de EST-04 (pergamino `#F4EDE0`, latón `#C89445`, madera `#6B4A2B`, frío `#8FB7D6`, fondos `#15100D`/`#241B16`/`#211916`/`#0E0D0C`, barras HP/MP/XP/target, rarezas blanco/verde/azul/morado).
* **Radios y bordes:** esquinas (6–10px en paneles, menor en casillas), borde de madera 1px, grosor de separadores/divisores.
* **Espaciados:** padding estándar de ventanas y paneles, gaps de grids (casillas de mochila/equipo/skills), márgenes mínimos del HUD.
* **Escala tipográfica:** tamaños por rol (título de ventana, header, label, valor, tooltip) con peso y color de texto.
* **Sombra/resaltado:** glow o stroke por estado (hover, seleccionado, bloqueado) expresado como UIStroke/UIGradient (o nota si se descarta).

#### **2. Mapeo de fuentes a Roblox (tabla)**

Las fuentes del diseño no se importan; se mapean a las **nativas de Roblox** (decisión de producto; el dev confirma los nombres exactos del `Font` enum en Studio):

| Fuente del diseño | Uso | Fuente Roblox (default) | Alternativa |
|-------------------|-----|-------------------------|-------------|
| Playfair Display | Títulos/dirección | `PlayfairDisplay` | — |
| Inter | Texto/labels/cuerpo | `Inter` | `GothamSSM` |
| Geist Mono | Valores/números/HUD | `RobotoMono` | `Inconsolata` |

* Regla: si una fuente alternativa no convence en un elemento concreto, el dev la cambia **dentro de esta tabla** y lo reporta; no se inventan fuentes por elemento.
* Las notas de estilo (mayúsculas en headers, tracking) se documentan por rol.

#### **3. Frames y componentes exportables (assets)**

* **Paneles 9-slice:** los paneles de ventana/panel/casilla se exportan como PNG con las **márgenes de corte** documentadas (esquinas + bordes) para `ImageLabel` con `ScaleType.Slice`.
* **Botones 3 estados:** por botón (o por variante de botón): imagen normal / hover / disabled — para `ImageButton` (ImageStates o imágenes separadas).
* **Barras (HP/MP/XP/target):** fondo + fill por separado (el fill se escala por ancho, como hoy).
* **Iconos:** los iconos de ítems/skills/UI con el estándar ASSETS_LIST (512×512, fondo negro = finales para ítems/skills; transparencia solo donde el asset lo exija) y sus `rbxassetid` al subirse (dev) con registro en ASSETS_REGISTRY.
* **Estructura de entrega:** carpeta por pantalla o por tipo (panels/, buttons/, bars/, icons/) con nombres claros y tamaños documentados; los archivos se suben al Asset Server (dev) y se referencian por config/nombre (patrón actual).

#### **4. Notas de adaptación (por pantalla / por tema)**

* **Directo (sin cambios):** paleta, radios/bordes, espaciados, escala tipográfica, estructura de grids, estados de botones/casillas, 9-slice.
* **Adaptación:** fuentes (tabla del punto 2); **escalado responsive** = `UIScale` + `UIAspectRatioConstraint` (patrón actual, sin layout absoluto por píxel); **zona segura móvil** = márgenes mínimos documentados + `GuiService:GetSafeAreaInsets()` aplicado a ventanas/HUD móvil (el diseño móvil ya contempla botones táctiles).
* **Animaciones:** cada transición del diseño se documenta como **TweenService** (propiedad, duración, easing — ej. fade/scale de ventanas 0.15–0.25 s, hover 0.1 s, Back para popups); las animaciones CSS-only sin equivalente útil se **descartan explícitamente** (no se implementan).
* **Problemas potenciales (avisar al PM/dev):** texto más ancho/largo con la fuente mapeada (reflow de labels), sombras/glow si no tienen equivalente directo, y cualquier layout del diseño que dependa de un ancho fijo (se marca para corregir en el `.pen` antes de implementar).

#### **5. Cobertura**

* El paquete cubre **todas las pantallas del reskin**: HUD (PC y mobile), barras, mochila, equipo/stats, talentos, grimorio, vendors (3), menú ESC, selección/creación de PJ, recompensa y tooltips.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Specs completos**

* **GIVEN** el documento de specs
* **WHEN** el dev lo usa para reconstruir una ventana
* **THEN** encuentra cada color, radio, borde, espaciado y tamaño de fuente con valor exacto
* **AND** no tiene que adivinar ningún valor del diseño

#### **Escenario 2: Fuentes mapeadas**

* **GIVEN** las fuentes del diseño (Playfair Display, Inter, Geist Mono)
* **WHEN** el dev revisa la tabla de mapeo
* **THEN** cada una tiene su fuente nativa de Roblox asignada (y alternativa)
* **AND** los nombres del `Font` enum se confirman en Studio durante la implementación

#### **Escenario 3: Assets listos**

* **GIVEN** los assets exportados
* **WHEN** el dev los sube a Roblox
* **THEN** los paneles 9-slice tienen márgenes de corte documentados, los botones tienen 3 estados, y las barras tienen fondo + fill separados
* **AND** los iconos siguen el estándar aprobado y quedan registrados en ASSETS_REGISTRY

#### **Escenario 4: Adaptación documentada**

* **GIVEN** el documento de notas
* **WHEN** el dev implementa
* **THEN** sabe qué es directo, qué se adapta (responsive, safe area, fuentes) y qué se descarta (animaciones CSS-only)
* **AND** las animaciones se expresan como TweenService (propiedad, duración, easing)

#### **Escenario 5: Sin tocar la lógica**

* **GIVEN** la implementación del reskin
* **WHEN** se conservan los nombres de instancias y jerarquía que los scripts usan
* **THEN** inventario, talentos, skills, vendors y menú siguen funcionando sin cambios de lógica

---

### **Comportamiento Visual / Reglas de Negocio**

* Es un paquete de especificación y assets: no define lógica, balance ni cambios al juego.
* El `.pen` sigue siendo la **referencia visual**; el documento de specs es la **verdad de implementación** (valores exactos).
* Los assets se registran (ASSETS_REGISTRY) y los iconos en ASSETS_LIST; fuentes nativas de Roblox (sin subir archivos de fuente).

---

### **Alcance**

#### Incluye

* Documento de specs (paleta, radios, bordes, espaciados, escala tipográfica, estados) con valores exactos.
* Tabla de mapeo de fuentes del diseño → fuentes nativas de Roblox (con alternativas).
* Exportación de assets: paneles 9-slice (con márgenes), botones 3 estados, barras (fondo+fill), iconos.
* Notas de adaptación: responsive (UIScale + UIAspectRatioConstraint), zona segura móvil, animaciones como TweenService, problemas potenciales.
* Cobertura de todas las pantallas del reskin (HUD, barras, mochila, equipo/stats, talentos, grimorio, vendors, menú ESC, selección/creación, recompensa, tooltips).

#### No incluye

* Implementación en Roblox (dev — cada pantalla tendrá su RC cuando el paquete esté listo).
* Cambios de lógica, balance o reglas del juego.
* Subida de assets al Asset Server (tarea del dev al implementar).
* Cambios a las pantallas del `.pen` salvo los ajustes marcados como "problemas potenciales" (se corrigen en el diseño antes de implementar).

---

### **Definition of Done (DoD)**

* [ ] Documento de specs con valores exactos (paleta, radios, bordes, espaciados, tipografía, estados).
* [ ] Tabla de mapeo de fuentes a Roblox con alternativas.
* [ ] Assets exportados: 9-slice con márgenes, botones 3 estados, barras fondo+fill, iconos (registrados).
* [ ] Notas de adaptación: responsive, zona segura móvil, animaciones TweenService, problemas potenciales por pantalla.
* [ ] El dev puede tomar el paquete e implementar el reskin sin reinterpretar el diseño.
* [ ] Sin tocar la lógica existente (nombres de instancias y jerarquía conservados).
* [ ] Reporte al PM con el detalle de la entrega y pendientes.

---

### **Estimación (orientativa)**

1–2 sesiones del diseñador: documentar specs + exportar assets + notas de adaptación.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-15 | Creación de HU-ESTETICA-13: paquete de handoff para implementar la nueva UI (specs con valores exactos, mapeo de fuentes a Roblox, assets 9-slice/botones/barras, notas de adaptación responsive/safe area/Tween) — solo diseñador, sin desarrollo |