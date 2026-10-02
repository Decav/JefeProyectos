# HU-R9b: Polish — SFX de combate, feedback de hits y ajustes del menú (Volumen/Gráficos)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9 — Demo estable / Polish (segunda parte)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Polish de feel + ajustes reales en el menú (dev; SFX desde Roblox Library)
**Fase GDD:** R9 (posterior a R8d; el juego ya es jugable)
**Depende de:** HU-R8d (balance), HU-R6.10 (placeholders Volumen/Gráficos del menú), HU-R6.11 (Ordenar UI ya real), HU-R6.6/6.7/6.8 (animaciones/VFX base), ASSETS_POLICY (SFX pendiente de confirmar; registro obligatorio)
**No modifica:** gameplay, balance ni reglas

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que el combate se sienta: golpes con sonido y feedback, skills con su audio, y poder ajustar **volumen** y **gráficos** desde el menú,
**para** que la demo se sienta pulida y no como un placeholder.

**Como** equipo,
**quiero** confirmar la capacidad de SFX del dev e implementar el polish acotado,
**para** cerrar los placeholders de ajustes y elevar el feel sin meter scope-creep.

---

### **Descripción del Requerimiento / Contexto**

El menú in-game (R6.10) tiene placeholders de **Volumen** y **Gráficos** ("Próximamente"); R6.11 ya implementó Ordenar UI. El combate tiene VFX (R8) y animaciones, pero **sin sonidos** ni feedback de impacto adicional (R6.6 lo excluyó explícitamente). Esta HU:

1. **SFX de combate y UI** (Roblox Library gratuita): hits melee/mágico, cast por familia, cura/escudo, AoE, muerte de enemigo, muerte del jugador, nivel up, clicks de UI, boss. **Confirmar capacidad del dev** (ASSSETS_POLICY lo deja pendiente de confirmar).
2. **Feedback de hits:** screen shake **sutil** al recibir/golpear (opcional, bajo) — R6.6 lo excluyó para R9; se suma acá con límite claro.
3. **Ajustes reales del menú:** **Volumen** (slider que controla el volumen del juego) y **Gráficos** (calidad gráfica simple).

**Criterio de hecho global:** el combate tiene sonido y feedback coherentes (sin spam), el menú permite ajustar volumen y gráficos de verdad (se persisten), y nada de gameplay cambia.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SFX (Roblox Library, data-driven)**

* **Confirmar capacidad:** el dev confirma que puede buscar/registrar sonidos de la Library (gratis). Si NO puede, esta parte se limita a reusar los existentes (`FootstepSystem`) y queda documentado (decisión).
* **Catálogo acotado (anti-scope-creep, máximo 1–2 por categoría):**

| Categoría | Sonido (Library) | Uso |
|-----------|------------------|-----|
| Hit melee | Impacto de arma | Golpe cuerpo a cuerpo (player → enemigo) |
| Hit mágico | Impacto de magia/energía | Skills Instant MATK y proyectiles |
| Cast | Cast genérico (varita/recarga) | Cast de skills (una base por familia: instant/aoe/heal/shield) |
| Cura | Heal positivo | Heal del Clérigo |
| Escudo | Barrera | Muro sagrado / Escudo de fe |
| AoE | Explosión/zona | GroundAoE/SelfAoE |
| Muerte enemigo | Muerte/desaparición | Enemy death |
| Muerte jugador | Muerte del jugador | Player death |
| Nivel up | Aviso positivo | Level up (R6a) |
| UI | Click estándar | Botones/ventanas (un sonido global) |
| Boss | Roar/impacto | Guardián de la Escarcha (ataques) |

* **Integración:** ids en **config** (reutilizar el patrón `VFXConfig` → `SFXConfig` nuevo o campo en configs existentes), reproducidos client-side con **autoridad del evento server** (quién puede oír qué: los hits propios y los del party); volumen relativo y sin spam (cooldown de reproducción, máx N por segundo).
* **Registro:** cada sonido en `ASSETS_REGISTRY` (rbxassetid, autor, licencia).

#### **2. Feedback de hits**

* **Screen shake sutil:** al **recibir** daño (breve, amplitud baja, 0.1–0.15 s) y opcionalmente al golpear con crítico (más leve). Configurable por intensidad en config (0 = off).
* No tocar: hit-stop, zoom, cámara de targeting (R3.1 intacta).

#### **3. Ajustes del menú (implementar placeholders de R6.10)**

* **Volumen:** slider en el menú → controla el volumen de audio del juego (MasterVolume del juego; no cambia el volumen de la app). Persiste por dispositivo (UserSettings/PlayerModule o config local cliente).
* **Gráficos:** selector simple (Automático / Baja / Media / Alta) → `UserSettings():GetService("UserGameSettings").QualityLevel` (o `GraphicsMode`). Persiste por dispositivo.
* Ambos reemplazan el feedback "Próximamente" de esos botones (Ordenar UI ya es real desde R6.11).
* UI: controles con el estilo Hearthbound Gold (EST-13; slider/tab como componentes existentes).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Sonidos presentes**

* **GIVEN** el combate
* **WHEN** se golpea, castea, cura, muere un enemigo, sube nivel, etc.
* **THEN** se escuchan los sonidos de sus categorías (sin spam ni superposición molesta)
* **AND** cada sonido está registrado en `ASSETS_REGISTRY`

#### **Escenario 2: Sin romper gameplay**

* **GIVEN** los SFX implementados
* **WHEN** se juega el flujo completo
* **THEN** el gameplay, targeting y cámara funcionan igual (los sonidos son solo audio)

#### **Escenario 3: Feedback de hits**

* **GIVEN** un golpe recibido (o crítico dado)
* **WHEN** ocurre el daño
* **THEN** hay un screen shake sutil configurable (0 = off)
* **AND** no interfiere con la cámara de targeting

#### **Escenario 4: Volumen funcional**

* **GIVEN** el menú in-game
* **WHEN** el jugador mueve el slider de volumen
* **THEN** el volumen del juego cambia en vivo y se persiste entre sesiones (por dispositivo)

#### **Escenario 5: Gráficos funcionales**

* **GIVEN** el menú in-game
* **WHEN** el jugador cambia la calidad gráfica
* **THEN** la calidad cambia y se persiste entre sesiones

#### **Escenario 6: Regresión**

* **GIVEN** el polish implementado
* **WHEN** se revisa menú + combate + dungeon
* **THEN** no hay errores rojos y los placeholders de Volumen/Gráficos ya no muestran "Próximamente"

---

### **Comportamiento Visual / Reglas de Negocio**

* Polish puro: no cambia daño, balance ni mecánicas.
* Los sonidos usan la Library (gratis) con registro y licencias claras; límite 1–2 por categoría.
* Volumen/Gráficos persisten por dispositivo (no por personaje — es config de máquina).

---

### **Alcance**

#### Incluye

* SFX por categoría (Library, data-driven, registro).
* Screen shake sutil configurable (feedback de hits).
* Slider de Volumen y selector de Gráficos funcionales en el menú (persisten por dispositivo).

#### No incluye

* Paquetes de sonido comprados/creados (salvo decisión explícita).
* Hit-stop, zoom de impacto ni cambios de cámara.
* Otros ajustes del menú (solo los 2 placeholders pendientes + Orden UI ya implementado).
* Cambios a gameplay, balance o reglas.

---

### **Definition of Done (DoD)**

* [ ] Capacidad de SFX confirmada; sonidos de las categorías integrados por config y registrados.
* [ ] Sin spam de audio (cooldown/límite por segundo).
* [ ] Screen shake sutil al recibir daño (y crítico) configurable (0 = off).
* [ ] Slider de Volumen funcional y persistente; selector de Gráficos funcional y persistente.
* [ ] Placeholders del menú (Volumen/Gráficos) ya no muestran "Próximamente".
* [ ] Sin errores rojos en menú → combate → dungeon.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Al cerrar: PROJECT_ARCHITECTURE, ASSETS_POLICY (SFX confirmado) y registro HU/RC actualizados; nota en GDD después de QA.

---

### **Decisiones por defecto R9b**

| Tema | Default |
|------|---------|
| SFX | Roblox Library gratuita; 1–2 por categoría; config data-driven; registro obligatorio |
| Screen shake | Sutil, 0.1–0.15 s, al recibir daño (+crítico leve); intensidad configurable, 0 = off |
| Volumen | MasterVolume del juego; persiste por dispositivo |
| Gráficos | QualityLevel (Auto/Baja/Media/Alta); persiste por dispositivo |
| Límite | Sin hit-stop ni cambios de cámara |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: SFX + feedback + ajustes del menú + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R9b: polish — SFX por categoría (Library, registro), screen shake sutil configurable, y placeholders del menú (Volumen/Gráficos) funcionales y persistentes por dispositivo |