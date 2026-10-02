# HU-SFX-01: Listado completo de sonidos (SFX) del juego — producción con IA generativa

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** SFX / Producción de sonido (IA generativa)
**Prioridad:** Alta
**Estado:** Lista para generar
**Tipo:** Producción de SFX con IA generativa + integración mínima del dev (por config)
**Fase GDD:** R9b (polish — la fuente cambia de "Roblox Library" a **IA generativa**, decisión PO 2026-09-22)
**Depende de:** HU-R9b (polish/SFX), HU-ITEMS-02 (pociones/buffs), HU-R6.14 (batch 1: feedback móvil), HU-ESTETICA-31 (boss: VFX/animaciones — sus sonidos), ASSETS_POLICY (registro)
**No modifica:** gameplay, balance ni mecánicas (sonidos solo audio, config-driven)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el juego tenga sonido: UI, combate, boss, ambiente y sistema,
**para** que la demo se sienta completa y pulida (sin silencios ni placeholders).

**Como** equipo de desarrollo,
**quiero** el **listado completo de SFX** listo para generar con IA,
**para** producirlos en lotes, subirlos y enlazarlos por config sin tocar código.

---

### **Descripción del Requerimiento / Contexto**

El PO confirmó acceso a una **IA generativa de sonido**: los SFX del juego se **crean con IA** (producción propia, sin licencias de terceros). Esto reemplaza la fuente "Roblox Library" que R9b contemplaba.

**Esta HU es el catálogo de sonidos**: la IA recibe el listado, genera los archivos con el formato especificado, y el dev los integra por config (patrón del proyecto: data-driven + ASSETS_REGISTRY).

**Criterio de hecho global:** existen los SFX del listado (formato/naming correctos), integrados por config en el juego (UI, combate, boss, ambiente), registrados, y suenan coherentes sin romper nada.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Formato y entrega (para la IA)**

| Parámetro | Especificación |
|-----------|----------------|
| Formato | **WAV 44.1 kHz, 16-bit** (estéreo para ambiente; mono para SFX cortos) |
| Duración | SFX cortos: 0.2–2 s; ticks: 0.2–0.4 s; loops: 8–15 s |
| Nivel | Normalizado (~−14 LUFS o pico ≤ −1 dB); sin clipping; sin silencio inicial/final excesivo |
| Naming | `Sfx_<sistema>_<nombre>` en snake_case (ej. `Sfx_ui_click`, `Sfx_combat_hit_melee`) |
| Carpeta | `Assets/SFX/` por sistema (`UI/`, `Combat/`, `Boss/`, `Enemy/`, `Amb/`, `Sys/`) |
| Reglas | **Sin voces ni diálogos** (por ahora); **sin música** (se separa); sin emojis/efectos tipo meme; temática nórdica/fría (menos "cartoon") |

#### **2. Listado completo de SFX**

El listado completo vive en **`Vandrheim-Roblox/SFX_LIST.md`** (52 sonidos, **estilo MUSIC_STYLES**: cada sonido con su contexto de uso, material sonoro, carácter y reglas) — es lo que se le pasa a la IA. Resumen por sistema: **UI (12)** · **Combate (18)** · **Boss (6)** · **Enemigos (5)** · **Ambiente (8)** · **Sistema (3)**. Incluye una **paleta sonora compartida** (madera, metal frío, hielo, cristal, viento, fuego; sin voces ni imitaciones).

#### **3. Integración (dev)**

* Subir los SFX al Asset Server; crear `ReplicatedStorage.Config.SFXConfig` (data-driven: `id → rbxassetid`, volumen relativo, `loop`/duración por entrada).
* Reproducción: client-side con autoridad del evento server (quién puede oír qué: propios + party); sin spam (cooldown por categoría).
* **No usar** sonidos del jugador default de Roblox donde el reemplazo esté activo (desactivar/ignorar, patrón R6.1).
* Registrar todo en `ASSETS_REGISTRY` (fuente: IA generativa, producción propia).
* **Sync places (PUBLICAR-04):** configs compartidos; la dungeon se actualiza por copia derivada.

#### **4. Reglas**

* Sin voces/diálogos ni música (se separa a futuro si el PO quiere).
* Los sonidos de pisadas ya existen (R6.1) — no se generan nuevos.
* Volumen coherente entre categorías (normalizados); sin superponerse con VFX/animaciones.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Listado completo generado**

* **GIVEN** el listado entregado a la IA
* **WHEN** se reciben los archivos
* **THEN** existen todos los SFX del listado con el formato/naming especificado (WAV 44.1 kHz, `Sfx_<sistema>_<nombre>`)

#### **Escenario 2: Integrados por config**

* **GIVEN** los SFX subidos
* **WHEN** se revisa el juego
* **THEN** `SFXConfig` enlaza cada id → rbxassetid y los sonidos suenan en su contexto (UI, combate, boss, ambiente, sistema)

#### **Escenario 3: Sin spam**

* **GIVEN** el juego con SFX
* **WHEN** se combate (múltiples golpes/ticks)
* **THEN** los sonidos no se saturan (cooldown por categoría) y el volumen es coherente

#### **Escenario 4: Boss sonoro**

* **GIVEN** la pelea del boss
* **WHEN** carga/impacta glacial_impact, ataca y muere
* **THEN** se escuchan sus sonidos (rugido, carga, impacto, muerte) con la aura de fondo

#### **Escenario 5: Registro y regresión**

* **GIVEN** la integración completa
* **WHEN** se juega el flujo completo (publicado, PC y móvil)
* **THEN** no hay errores rojos, los sonidos están registrados y nada del gameplay cambia

---

### **Alcance**

#### Incluye

* Listado completo de SFX (48) para generar con IA (formato, duraciones, loops, naming).
* Integración por config (`SFXConfig` + ASSETS_REGISTRY) y reproducción sin spam.

#### No incluye

* Música (BGM) — separada a futuro.
* Voces/diálogos.
* Sonidos de pisadas (ya existen, R6.1).
* Cambios a gameplay, balance ni mecánicas.

---

### **Definition of Done (DoD)**

* [ ] Los 48 SFX del listado generados con el formato/naming especificado.
* [ ] Subidos al Asset Server y enlazados en `SFXConfig` (id → rbxassetid).
* [ ] Suenan en su contexto sin spam y con volumen coherente.
* [ ] Boss con sus sonidos (carga/impacto/aura/muerte).
* [ ] ASSETS_REGISTRY actualizado (fuente: IA generativa).
* [ ] Sin errores rojos en el flujo completo publicado (PC y móvil).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto SFX-01**

| Tema | Default |
|------|---------|
| Fuente | IA generativa (producción propia; sin licencias de terceros) |
| Formato | WAV 44.1 kHz 16-bit; cortos 0.2–2 s; loops 8–15 s; normalizados |
| Naming | `Sfx_<sistema>_<nombre>` en `Assets/SFX/<sistema>/` |
| Integración | `SFXConfig` data-driven; reproducción client-side con autoridad server; sin spam |
| Excluidos | Música, voces, pisadas (ya existen) |

---

### **Estimación (orientativa)**

IA: 2–3 lotes de generación (48 sonidos). Dev: 1–2 sesiones de integración (subir + config + QA de contexto).

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-SFX-01: listado de SFX para producir con IA — el listado vive en `SFX_LIST.md` (52 sonidos, un prompt por línea); formato/naming/duraciones especificados; integración por config (SFXConfig + ASSETS_REGISTRY) |
| 2026-09-22 | El listado pasa a `SFX_LIST.md` (estilo ASSETS_LIST, un prompt por línea) a pedido del PO — la HU queda como especificación de formato/integración |
| 2026-09-22 | `SFX_LIST.md` reescrito **estilo MUSIC_STYLES**: cada sonido con contexto de uso, material sonoro, carácter, duración/loop y reglas; paleta sonora compartida de Vandrheim al inicio |
| 2026-09-22 | `SFX_LIST.md` al grano: cada sonido es un **style prompt** directo (párrafo compacto en inglés, como MUSIC_STYLES) + header técnico mínimo |
| 2026-09-22 | `SFX_LIST.md` reescrito **al calibre de MUSIC_STYLES**: cada sonido tiene escena/contexto, capas sonoras concretas (materiales, texturas), carácter y guardarraíles (sin voces, sin sci-fi, sin imitación) — prompts con de dónde agarrarse |