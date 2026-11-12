# HU-MARKETING-01: Trailer de 30 s para ads (Google Flow + gameplay real)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Marketing / Adquisición
**Prioridad:** Alta — creativo nuevo para test de ads
**Estado:** Abierta — producción pendiente (guion y shot list aprobables)
**Tipo:** Material de marketing (video). No modifica el juego.
**Fase GDD:** Publicación / Marketing
**Depende de:** build beta jugable, logo de Vandrheim, capturas de gameplay, música/SFX con licencia, ASSETS_POLICY (uso de material propio)
**No modifica:** código, configs ni assets del juego.

---

### Narrativa (INVEST)

**Como** equipo,
**quiero** un trailer de 30 s que muestre el mundo, las clases y al jefe de Vandrheim,
**para** conseguir clics baratos y jugadores que se queden, no solo impresiones.

---

### Descripción / Contexto

Los creativos actuales rinden con CTR ~1.9 % y CPR ~$0.069, pero el tiempo por play ronda 1.2 min. El trailer debe vender **la fantasía del juego** y mostrar gameplay real, porque el tráfico frío castiga lo que parece falso.

La apertura y el cierre se generan con **Google Flow**; el núcleo es **captura real del juego**. Nada de UI inventada por IA.

**Criterio de hecho global:** existen los entregables (30 s 16:9, 15 s 9:16, 6 s 9:16), con subtítulos, CTA claro y solo material real del juego en las secciones de gameplay.

---

### Entregables

| Pieza | Formato | Duración | Uso |
|---|---|---|---|
| Master | 16:9 · 1920×1080 · 30 fps | 30 s | YouTube, ficha del juego |
| Vertical | 9:16 · 1080×1920 | 15 s | TikTok, Shorts, Reels |
| Hook | 9:16 · 1080×1920 | 6 s | Creativo de prueba |
| Miniatura | 16:9 · 1920×1080 | — | Thumbnail del video |
| Subtítulos | ES (y EN si aplica) | — | Todas las piezas |

---

### Guion y shot list

| # | Tiempo | Plano | Fuente | Contenido |
|---|---|---|---|---|
| 1 | 0:00–0:03 | Silueta colosal entre la ventisca; hielo quebrándose | **Flow** | Gancho: Jotunn aparece entre nieve, contraluz |
| 2 | 0:03–0:06 | Aéreo del valle nevado y el pueblo con antorchas | Flow o cámara de Studio | Mundo y escala |
| 3 | 0:06–0:08 | Paladín: escudo y espadón, impacto | **Gameplay** | Clase 1 |
| 4 | 0:08–0:09 | Cazador: arco, flecha y impacto | **Gameplay** | Clase 2 |
| 5 | 0:09–0:11 | Clérigo: meteorito/Ira divina | **Gameplay** | Clase 3 |
| 6 | 0:11–0:16 | Pasillo helado, pack de caballeros, loot, level up | **Gameplay** | Loop de dungeon |
| 7 | 0:16–0:22 | Jotunn: pisotón, rugido, party de 4, revive | **Gameplay** | Jefe |
| 8 | 0:22–0:26 | Cofre, recompensa y regreso al pueblo | **Gameplay** | Progresión |
| 9 | 0:26–0:30 | Logo + CTA | Editor | “Gratis en Roblox” |

**Texto en pantalla**

| Tiempo | Texto |
|---|---|
| 0:00–0:03 | “Vandrheim está cayendo.” |
| 0:03–0:06 | “Un mundo congelado.” |
| 0:06–0:11 | “Elige tu clase.” |
| 0:11–0:16 | “Desciende a la Helada.” |
| 0:16–0:22 | “Enfréntate al Guardián.” |
| 0:22–0:26 | “Vuelve más fuerte.” |
| 0:26–0:30 | “Vandrheim · Gratis en Roblox” |

**Audio:** tema épico con golpe de percusión en 0:11 (entrada a la dungeon) y silencio breve antes del rugido en 0:16. Música con licencia o de la librería de Roblox; nada de audio de terceros sin permiso.

---

### Producción con Google Flow

Reglas para los planos de IA:

* Clips de **4–5 s** máximo; se recortan a 2–3 s en el montaje.
* Usar **image-to-video**: partir de una captura real (Jotunn, paisaje) como referencia para mantener la identidad.
* Sin texto en el plano: la IA lo deforma; el texto se añade en el editor.
* Evitar primeros planos de caras y manos; planos de espaldas, siluetas y cámara lenta.
* Movimiento de cámara lento (push-in/pan) para ocultar artefactos.
* Nada de UI ni HUD inventados; si aparece interfaz, debe ser gameplay real.
* Exportar a 1080p y revisar que no haya manos, armas o texto deformados.

**Prompts de referencia (en inglés, funcionan mejor):**

1. `Cinematic dark fantasy, colossal ice giant silhouette emerging from a blizzard, backlit, drifting snow, slow push-in, cold blue palette, no text`
2. `Aerial shot of a snowy nordic valley with a small torch-lit village, frozen river, mountains in the distance, slow drone forward, cinematic`

Los demás planos son gameplay capturado, no generados.

---

### Captura de gameplay

* Grabar en el build beta, en PC, a 1080p y 60 fps.
* Ocultar elementos que ensucien el plano (nameplates, chat, notificaciones de sistema); conservar barra de skills y HUD de combate si aporta.
* Evitar bugs, texto de depuración y nombres de prueba.
* Tomar cada plano 2–3 veces para elegir el mejor momento (golpe, loot, rugido).
* No falsificar escenas ni inventar mecánicas que no existan.

---

### Reglas de edición

* Los primeros **3 s** deben contener el gancho; el logo va al final.
* Ritmo rápido: cortes de 1–3 s, sin planos muertos.
* Subtítulos siempre; la mayoría ve sin sonido.
* Zona segura en 9:16: no poner texto en los bordes superior/inferior.
* Legibilidad: texto ≥ 48 px en 1080p, contraste alto, sin fuentes finas.
* El CTA debe leerse en 1 segundo.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Master 16:9

* **GIVEN** el master exportado
* **WHEN** se reproduce
* **THEN** dura ≤30 s, es 1920×1080 y el CTA final es legible

#### Escenario 2: Variantes verticales

* **GIVEN** el corte 9:16
* **WHEN** se revisa
* **THEN** dura 15 s (y el hook 6 s), respeta zona segura y mantiene el texto legible

#### Escenario 3: Honestidad del material

* **GIVEN** las secciones de gameplay
* **WHEN** se comparan con el juego real
* **THEN** no hay UI inventada, mecánicas falsas ni escenas que el jugador no pueda vivir

#### Escenario 4: Marca

* **GIVEN** los planos de IA
* **WHEN** se revisan
* **THEN** mantienen la paleta de Vandrheim (latón, pergamino, azul de hielo) y no muestran texto deformado

#### Escenario 5: Subtítulos

* **GIVEN** cualquier pieza
* **WHEN** se reproduce sin sonido
* **THEN** el mensaje se entiende por subtítulos y texto en pantalla

#### Escenario 6: Medición

* **GIVEN** el creativo subido a ads
* **WHEN** se compara con la base (CTR 1.9 %, CPR $0.069)
* **THEN** se registran CTR, CPR y tiempo por play tras 48 h y ~200 plays

---

### Alcance

#### Incluye

* Guion, shot list y prompts de Flow.
* Captura de gameplay y montaje.
* Master 16:9 de 30 s, vertical de 15 s, hook de 6 s, miniatura.
* Subtítulos y CTA.

#### No incluye

* Cambios al juego ni a su UI para el trailer.
* Locución profesional, actores ni captura en vivo con jugadores reales.
* Campaña de medios, presupuesto de ads ni publicación.

---

### Decisiones abiertas

1. **Voz en off:** sin voz (solo texto y música) o una línea final en español.
2. **Música:** pista de la librería de Roblox o licencia externa.
3. **Miniatura:** rostro de Jotunn o collage de las 3 clases.

---

### Definition of Done (DoD)

* [ ] Master 16:9 de ≤30 s con gancho en los primeros 3 s y CTA final.
* [ ] Vertical 9:16 de 15 s y hook de 6 s con zona segura respetada.
* [ ] Subtítulos en todas las piezas.
* [ ] Planos de IA sin texto deformado y coherentes con la paleta del juego.
* [ ] Gameplay real sin UI inventada ni bugs visibles.
* [ ] Miniatura entregada.
* [ ] Archivos nombrados y organizados en la carpeta de marketing.
* [ ] Creativo subido y métricas registradas a las 48 h.

---

### Estimación (orientativa)

2–3 sesiones: guion y referencias, captura de gameplay, generación en Flow, montaje y variantes.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-04 | Creación de HU-MARKETING-01: trailer de 30 s con Flow para apertura/cierre y gameplay real al centro; entregables 16:9, 9:16 y hook de 6 s, con reglas de producción, honestidad del material y medición contra la base de ads. |
