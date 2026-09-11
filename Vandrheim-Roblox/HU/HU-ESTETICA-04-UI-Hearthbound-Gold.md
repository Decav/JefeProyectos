## HU-ESTETICA-04: Diseño completo de la UI — Dirección aprobada "Hearthbound Gold"

**Proyecto:** Vandrheim (Roblox MVP)  
**Épica:** Assets / UI / EST-04  
**Prioridad:** Alta  
**Estado:** Lista para implementar  
**Tipo:** Producción de diseño de interfaz (diseñador) + assets de UI  
**Fase GDD:** Épica transversal `EST-04` (puede correr en paralelo con R8; la implementación en Roblox la hace el dev después)  
**Rol responsable:** Diseñador de UI/assets — diseña el sistema visual completo y entrega los assets; **el dev implementa la UI en Roblox**  
**Fuente del diseño:** `Vandrheim-design.pen` — **Direction I — Hearthbound Gold (aprobada)**  
**Depende de:** HU-R6.5 (ventanas actuales: mochila/equipo/stats), HU-R6.10 (menú ESC), HU-ASSETS (política de assets), listado de pantallas existentes

---

### **Narrativa (INVEST)**

**Como** jugador,  
**quiero** una interfaz coherente con la fantasía nórdica cálida de Vandrheim, legible en combate y cómoda en móvil,  
**para** que el juego se sienta pulido y con identidad.

**Como** equipo,  
**quiero** el sistema de diseño completo de la UI aprobada (dirección *Hearthbound Gold*), con todas las pantallas y los assets listos,  
**para** que el dev los implemente en Roblox sin reinterpretar la estética.

---

### **Descripción del Requerimiento / Contexto**

Se seleccionó la propuesta **Direction I — Hearthbound Gold** (del archivo de diseño `Vandrheim-design.pen`). Su identidad: *madera tallada, reglas de latón cálido, texto pergamino — calor del pueblo vikingo y UI de combate legible*.

Esta HU expande esa dirección a un **sistema de diseño completo** y produce los **assets de UI** para que el dev implemente el reskin de todas las ventanas del juego (sin cambiar la lógica: se conservan nombres de instancias y jerarquía que los scripts usan).

La implementación en Roblox (Frame/ImageLabel/ImageButton, Scale, móvil) es del dev, en una HU posterior (o en la fase de UI de R8). El diseñador entrega **diseño + assets + specs**.

---

### **Especificaciones Técnicas / Contratos**

#### **1. Sistema de diseño (diseñador)**

**Paleta (aprobada):**

| Token | Color | Uso |
|-------|-------|-----|
| `panel` | `#15100D` | Fondo general/carbón |
| `panel-hud` | `#241B16` | Frame del jugador/objetivo |
| `panel-window` | `#211916` | Ventanas (mochila, equipo, etc.) |
| `panel-slot` | `#0E0D0C` | Casillas de skills/ítems |
| `text` | `#F4EDE0` | Texto principal (pergamino) |
| `accent` | `#C89445` | Acentos/latón (oro, XP, bordes destacados) |
| `cold` | `#8FB7D6` | Acentos fríos (maná/estado) |
| `wood` | `#6B4A2B` | Bordes secundarios/madera |
| `text-muted` | `#B5A79A` | Notas/descripciones |
| `mana-cost` | `#8EA6B6` | Coste de maná |

**Barras:** HP `#7C2D2D`/fill `#C45345` · MP `#234B68`/fill `#5C9CC8` · XP `#3F3328`/fill `#C89445` · Target HP `#402126`/fill `#B84E5B` · Estado élite `#D68A78`.

**Rarezas:** blanco `#F4EDE0` / verde `#70C48A` / azul `#75A8E0` / morado `#B48ADE`.

**Tipografía:** Geist Mono (datos/etiquetas), Playfair Display (títulos), Inter (cuerpo). Nota Roblox: las fuentes se suben como assets custom; si alguna no está disponible, el dev usa el equivalente más cercano aprobado — el diseñador define usos y tamaños.

**Estilo:** esquinas `6–10 px`, bordes finos (1–2 px), fondos oscuros cálidos, acentos latón, sin sombras pesadas ni gradientes excesivos.

#### **2. Componentes a diseñar (design system)**

* Botones: estados **normal / hover / disabled** (primario latón y secundario madera).
* Paneles: borde de madera + variante con borde latón (destacada), **9-slice** para estirar sin deformar.
* Barras: HP / MP / XP / target (con fill, texto interno, esquinas).
* Casillas: skills (con tecla y coste), ítems (con cantidad `xN`), equipo (con etiqueta y separador), slots Z/X.
* Tabs (vendor), tooltip, popup de recompensa, scroll, estado "Próximamente" (placeholders de ajustes).
* Iconos de UI: engranaje/ajustes, mochila, equipar, oro, cierre, botones móviles.

#### **3. Pantallas a diseñar (mockups completos)**

| # | Pantalla | Contenido clave |
|---|----------|-----------------|
| 1 | **HUD** | Frame jugador (nombre+nivel, HP, MP, **XP**, **oro**), frame target (nombre+nivel, HP, estado élite), **crosshair**, barra 4 skills (tecla+coste+CD), **slots Z/X**, **botones móviles (BOLSA/EQUIPO/MENÚ)** |
| 2 | **Mochila (B)** | Título + 20 casillas con cantidades y rarezas; pie de nota de rareza |
| 3 | **Equipo (C)** | 9 slots con etiquetas + separador + **panel de stats** (HP, MP, ATK, MATK, DEF, MDEF, CRIT) |
| 4 | **Spellbook** | Lista de habilidades aprendidas + vista previa de barra |
| 5 | **Talentos** | Árbol de 3 ramas con nodos conectados + **contador de puntos** + **leyenda de estados (aprendido/disponible/bloqueado)** + botón respec |
| 6 | **Vendor** | Pestañas comprar/vender, ítems con precios, oro del jugador |
| 7 | **Menú ESC** | Continuar, volver a selección de PJ, placeholders (volumen/gráficos/orden UI) + **estados hover/disabled** |
| 8 | **Selección de PJ** | 3 slots (vacío/ocupado/bloqueado) con info y acciones |
| 9 | **Creación de PJ** | Nombre + 3 clases |
| 10 | **Dungeon HUD** | Piso actual, abandonar run, avisos |
| 11 | **Recompensa / tooltips** | Popup de loot y tooltip de ítem (stats/afijos/rareza) |
| 12 | **Mobile HUD (variante)** | Player card (HP/MP), 4 skills táctiles, menú táctil — layout móvil |

**Componentes exportables (adicionales):** panel 9-slice, botón normal/hover/disabled (estados separados para `ImageButton`), barras, tabs, tooltip, popup, iconos UI — con nota: borde madera 1px, esquinas 6–10px.

#### **4. Entregables del diseñador**

* Mockups de todas las pantallas (continuar en `Vandrheim-design.pen` con la dirección aprobada).
* **Assets exportados:** paneles 9-slice, botones por estado, íconos de UI, marcos — en PNG con transparencia donde aplique, tamaños claros por asset.
* **Specs por pantalla:** tamaño, posición sugerida, fuentes/tamaños, estados.
* Notas de integración para el dev (qué reemplaza cada asset, sin tocar nombres de instancias).

#### **5. Reglas**

* No se cambia lógica: los scripts referencian instancias por nombre (HUD, MainFrame, slots, etc.) — el reskin respeta la jerarquía existente (R6.5/R6.10).
* Móvil: todos los diseños funcionan con `Scale` + `UIAspectRatioConstraint`; sin elementos fuera de pantalla.
* Los assets se registran según `ASSETS_POLICY` (fuente, licencia).
* El diseñador no escribe código ni integra en Roblox (eso es del dev).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Sistema de diseño completo**

* **GIVEN** la dirección aprobada
* **WHEN** se revisa la entrega
* **THEN** existen paleta, tipografía, componentes y estados definidos
* **AND** son consistentes con *Hearthbound Gold*

#### **Escenario 2: Todas las pantallas**

* **GIVEN** la lista de 11 pantallas
* **WHEN** se inspeccionan los mockups
* **THEN** cada pantalla tiene su diseño completo
* **AND** refleja los elementos reales del juego (XP, stats, 20 casillas, 9 slots, rarezas, placeholders)

#### **Escenario 3: HUD legible en combate**

* **GIVEN** el HUD diseñado
* **WHEN** se revisa en contexto de combate
* **THEN** HP/MP/XP/oro, target, skills y slots se leen sin esfuerzo
* **AND** el crosshair y los estados de CD son claros

#### **Escenario 4: Assets exportados**

* **GIVEN** los assets de UI
* **WHEN** se validan
* **THEN** paneles 9-slice, botones (3 estados) e iconos existen en PNG
* **AND** están listos para subir a Roblox (rbxassetid)

#### **Escenario 5: Móvil**

* **GIVEN** los mockups
* **WHEN** se revisa el layout en formato móvil
* **THEN** nada queda fuera de pantalla
* **AND** los controles táctiles (BOLSA/EQUIPO/MENÚ, barra) son accesibles

#### **Escenario 6: Compatibilidad con la lógica**

* **GIVEN** los diseños
* **WHEN** se comparan con las ventanas actuales
* **THEN** los elementos mapean a las instancias existentes (nombres conservados)
* **AND** no se exige cambios de scripts

#### **Escenario 7: Registro**

* **GIVEN** los assets finales
* **WHEN** se revisa el registro
* **THEN** cada asset tiene fuente/autor/licencia (ASSETS_POLICY)

---

### **Alcance**

#### Incluye

* Sistema de diseño (paleta, tipografía, componentes, estados) basado en *Hearthbound Gold*.
* Mockups de las **12 pantallas** (incl. variante móvil).
* Componentes exportables (9-slice, botones con estados, barras, tabs, tooltip, popup, iconos UI).
* Assets exportados (9-slice, botones por estado, iconos UI).
* Specs de integración para el dev.

#### No incluye

* Implementación en Roblox (lo hace el dev, HU de implementación UI posterior).
* Cambios a scripts, jerarquía o nombres de instancias.
* Iconos de skills/ítems (Gemini, fondo negro — ya definidos).
* Modelos 3D (EST-01/02/03).
* SFX/VFX (R8/R9).

---

### **Definition of Done (DoD)**

* [ ] Sistema de diseño documentado con la paleta aprobada (tokens, barras, rarezas, tipografía).
* [ ] Componentes con estados (botones, paneles, casillas, barras, tabs, tooltip, popup).
* [ ] Las **12 pantallas** diseñadas en `Vandrheim-design.pen` bajo *Hearthbound Gold* (incl. variante móvil y estados).
* [ ] Assets exportados en PNG (9-slice y botones por estado) listos para Roblox.
* [ ] Specs por pantalla para el dev (posiciones, fuentes, tamaños).
* [ ] Diseños válidos en móvil (Scale) y PC.
* [ ] Mapeo a instancias existentes sin requerir cambios de scripts.
* [ ] Assets con fuente/licencia registrada.
* [ ] Nota `EST-04 completo` en GDD tras la verificación.

---

### **Estimación (orientativa)**

4–6 sesiones de diseño: systema visual + componentes + 11 pantallas + exportación de assets.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-08-26 | Creación de HU-ESTETICA-04: diseño completo de UI con la dirección aprobada "Hearthbound Gold" (paleta/tipografía extraídas del .pen); entrega = diseño + assets + specs |