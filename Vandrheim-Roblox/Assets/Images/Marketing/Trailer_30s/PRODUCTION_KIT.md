# Kit de Producción — HU-MARKETING-01: Trailer de 30 s (Google Flow + Gameplay Real)

Este directorio contiene todos los recursos base extraídos de Roblox Studio y preparados en resolución nativa `1920x1080` (16:9) y `1080x1920` (9:16) para producir el trailer de 30 s, el corte vertical de 15 s y el hook de 6 s.

---

## 1. Estructura de Archivos Entregados

### A. Semillas `Image-to-Video` para Google Flow (`Flow_References/`)
Todas las imágenes están limpias (sin UI, sin texto, 1920×1080) listas para subir como frame inicial en Google Flow:
- `Shot01_Ref_A_Jotunn_InGame_1920x1080.png`: Modelo 3D real del Jotunn (`helada_frostwarden`) en contraluz frente al Arco Rúnico y portal glacial bajo la aurora boreal.
- `Shot01_Ref_B_Jotunn_Blizzard_1920x1080.png`: Composición de alta definición del Jotunn emergiendo entre ventisca y caverna helada (sin texto).
- `Shot01_Ref_C_FrostLord_Avenue_1920x1080.png`: Señor de la Escarcha (`helada_frost_lord`) en la Avenida de los Antiguos flanqueado por obeliscos cian.
- `Shot01_Ref_D_Jotunn_CavernArt_1920x1080.png`: Escena conceptual del Jotunn en la caverna helada sin logotipo ni texto.
- `Shot02_Ref_A_Aerial_Village_1920x1080.png`: Plano aéreo del pueblo nórdico iluminado por antorchas y el santuario glacial al fondo.
- `Shot02_Ref_B_Aerial_River_Bridge_1920x1080.png`: Plano aéreo del valle, el río helado, el puente rústico, el molino y la empalizada del pueblo.

### B. Cierre / End-Card con CTA (`EndCard_CTA/`)
- `Shot09_EndCard_CTA_16x9_1920x1080.png`: Cierre para el Master 16:9 (0:26–0:30) con el logotipo oficial `Vandrheim` y botón de alto contraste `GRATIS EN ROBLOX` (>= 50 px, paleta Hearthbound Gold y Pergamino).
- `Shot09_EndCard_CTA_9x16_1080x1920.png`: Cierre para las piezas verticales 9:16 (TikTok, Shorts, Reels) respetando la zona segura superior e inferior.

### C. Subtítulos Sincronizados (`Subtitles/`)
- `Vandrheim_Trailer_30s_ES.srt`: Subtítulos en español sincronizados al segundo para el Master de 30 s.
- `Vandrheim_Trailer_30s_EN.srt`: Subtítulos en inglés para pruebas de tráfico internacional.
- `Vandrheim_Vertical_15s_ES.srt`: Subtítulos adaptados al corte vertical de 15 s.
- `Vandrheim_Hook_6s_ES.srt`: Subtítulos adaptados al creativo Hook de 6 s.

### D. Miniatura (`Thumbnail/`)
- `Trailer_Thumbnail_1920x1080.png`: Miniatura oficial 16:9 en 1920×1080.

---

## 2. Presupuesto Estricto en Google Flow (<= 40 Puntos)

1. **Configuración obligatoria antes de generar:**
   - Seleccionar el modelo **Veo 2 - Fast** (costo: **10 a 20 puntos** por generación) en lugar de *Veo 2 - Quality* (100 puntos).
   - Formato: **16:9 (Landscape)**.
   - Cantidad de resultados por generación: **1 o 2 máximo** (verificar el indicador de créditos en el botón antes de pulsar *Generate*).
2. **Generación 1 — Plano 1 (0:00–0:03, Gancho Jotunn):**
   - **Imagen base:** Subir `Flow_References/Shot01_Ref_A_Jotunn_InGame_1920x1080.png` (o `Shot01_Ref_B_Jotunn_Blizzard_1920x1080.png`).
   - **Prompt:** `Cinematic dark fantasy, colossal ice giant silhouette emerging from a heavy blizzard, backlit cyan portal glow, drifting snow particles, slow camera push-in, cold blue palette, no text, no UI`
3. **Generación 2 — Plano 2 (0:03–0:06, Aéreo del Valle y Pueblo):**
   - **Imagen base:** Subir `Flow_References/Shot02_Ref_A_Aerial_Village_1920x1080.png` (o `Shot02_Ref_B_Aerial_River_Bridge_1920x1080.png`).
   - **Prompt:** `Aerial drone shot of a snowy nordic valley with a torch-lit timber village, glowing warm lanterns, river and glowing blue sanctuary in the distance, slow forward camera movement, cinematic, no text, no UI`

---

## 3. Pistas de Audio del Proyecto (Con Licencia Propia)

Ubicadas en `Assets/Sounds/music/`:
- **Apertura y Mundo (0:00–0:11):** `Assets/Sounds/music/Vandrheim.mp3`
- **Combate y Jefe Jotunn (0:11–0:30):** `Assets/Sounds/music/Vandrheim-Frost-JotunnBossFight.mp3`
  - **0:11:** Golpe de percusión en el corte hacia el pasillo helado de la mazmorra.
  - **0:16:** Silencio breve (0.3 s) justo antes del pisotón y rugido del Jotunn.
- **SFX de apoyo (`Assets/Sounds/sfx/`):**
  - `sfx_bow_skill.wav` (en 0:08 para el disparo del Cazador).
  - `sfx_coin.wav` (en 0:22 al abrir el cofre de recompensa).

---

## 4. Escaleta de Montaje (Master 30 s · 16:9)

| # | Tiempo | Fuente | Archivo / Captura | Texto en Pantalla (SRT) |
|---|---|---|---|---|
| 1 | 0:00–0:03 | **Google Flow** | Clip generado desde `Shot01_Ref_A` / `Shot01_Ref_B` | “Vandrheim está cayendo.” |
| 2 | 0:03–0:06 | **Google Flow / Studio** | Clip generado desde `Shot02_Ref_A` / `Shot02_Ref_B` | “Un mundo congelado.” |
| 3 | 0:06–0:08 | **Gameplay Real** | Paladín: escudo + espadón, golpe cuerpo a cuerpo | “Elige tu clase.” |
| 4 | 0:08–0:09 | **Gameplay Real** | Cazador: disparo de arco e impacto a distancia | “Elige tu clase.” |
| 5 | 0:09–0:11 | **Gameplay Real** | Clérigo: lanzamiento de Ira Divina (bola de energía + runas) | “Elige tu clase.” |
| 6 | 0:11–0:16 | **Gameplay Real** | Pasillo helado, pack de Caballeros Helados, loot y subida de nivel | “Desciende a la Helada.” |
| 7 | 0:16–0:22 | **Gameplay Real** | Jefe Jotunn: pisotón glacial, rugido, party de 4 y resurrección | “Enfréntate al Guardián.” |
| 8 | 0:22–0:26 | **Gameplay Real** | Apertura del cofre de jefe, recompensa y retorno al pueblo | “Vuelve más fuerte.” |
| 9 | 0:26–0:30 | **End-Card** | `EndCard_CTA/Shot09_EndCard_CTA_16x9_1920x1080.png` | “Vandrheim · Gratis en Roblox” |

---

## 5. Videos Finales Renderizados (Entregables Oficiales)

Todos los videos fueron ensamblados y normalizados con audio a `-14 LUFS` utilizando `ffmpeg 9.0.2`:

1. **Master 16:9 (`Vandrheim_Trailer_Master_30s_16x9.mp4`):**
   - Resolución: `1920x1080` (16:9), 30 fps
   - Duración: `30.00 s` (exacto)
   - Contenido:
     - `0:00–0:03` (3.0s): Generación Veo 3.1 Flow (`Flow_Shot01_Jotunn_Blizzard.mp4` - Jotunn en la ventisca emergente).
     - `0:03–0:06` (3.0s): Generación Veo 3.1 Flow (`Flow_Shot02_Aerial_Village.mp4` - Vuelo de dron sobre aldea y valle nevado).
     - `0:06–0:10` (4.0s): Exploración en el río, puente y molino de la aldea.
     - `0:10–0:14` (4.0s): Combate contra el Señor de la Escarcha en la Avenida de los Antiguos.
     - `0:14–0:18` (4.0s): Combate contra el Jotunn en el estrado del Santuario Glacial.
     - `0:18–0:22` (4.0s): Caverna helada y misterios antiguos.
     - `0:22–0:26` (4.0s): Ventisca profunda y ojos brillantes del Jotunn.
     - `0:26–0:30` (4.0s): EndCard CTA con logo Vandrheim y botón GRATIS EN ROBLOX.
   - Pista de audio: `Vandrheim-Frost-JotunnBossFight.mp3`, normalizado a `-14 LUFS` con fade-out al segundo 29.5.
   - Pista de subtítulos: `mov_text` en español integrada en el contenedor MP4.

2. **Vertical 9:16 (`Vandrheim_Trailer_Vertical_15s_9x16.mp4`):**
   - Resolución: `1080x1920` (9:16), 30 fps
   - Duración: `15.00 s` (exacto)
   - Contenido:
     - `0:00–0:03` (3.0s): Jotunn en la ventisca (Flow).
     - `0:03–0:06` (3.0s): Vuelo de dron sobre la aldea nórdica (Flow).
     - `0:06–0:09` (3.0s): Combate Señor de la Escarcha.
     - `0:09–0:12` (3.0s): Estrado del Jotunn.
     - `0:12–0:15` (3.0s): EndCard CTA vertical respetando zonas seguras.
   - Audio: `-14 LUFS` normalizado.

3. **Hook 9:16 (`Vandrheim_Trailer_Hook_6s_9x16.mp4`):**
   - Resolución: `1080x1920` (9:16), 30 fps
   - Duración: `6.00 s` (exacto)
   - Contenido:
     - `0:00–0:03` (3.0s): Jotunn en la ventisca (Flow).
     - `0:03–0:05` (2.0s): Climax de combate contra el Señor de la Escarcha.
     - `0:05–0:06` (1.0s): Logotipo Vandrheim y CTA.
   - Audio: `-14 LUFS` normalizado.

4. **Presupuesto Utilizado en Google Flow:**
   - Toma 1 (Jotunn, Veo 3.1 - Lite, 16:9, 720p): 10 créditos
   - Toma 2 (Aldea, Veo 3.1 - Lite, 16:9, 720p): 10 créditos
   - Total consumido: **20 créditos** (50% del tope máximo de 40 créditos autorizado).

