# HU-R9b: Polish — SFX de combate, feedback de hits y ajustes del menú (Volumen/Gráficos)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R9 — Demo estable / Polish (segunda parte)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Polish de feel + ajustes reales en el menú (dev; SFX y música con assets del PO o placeholders intercambiables por config)
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

1. **SFX de combate y UI** (assets del PO —toolbox/externos— o placeholders): hits melee/mágico, cast por familia, cura/escudo, AoE, muerte de enemigo, muerte del jugador, nivel up, clicks de UI, boss. **Mismo contrato que la PoC HU-SFX-02** (la PoC valida el flujo que esta HU usa para todo el catálogo).
2. **Música** (assets del PO): tracks por contexto con crossfade suave (nuevo §4).
3. **Feedback de hits:** screen shake **sutil** al recibir/golpear (opcional, bajo) — R6.6 lo excluyó para R9; se suma acá con límite claro.
4. **Ajustes reales del menú:** **Volumen** (slider que controla el volumen del juego) y **Gráficos** (calidad gráfica simple).

**Criterio de hecho global:** el combate tiene sonido y feedback coherentes (sin spam), el menú permite ajustar volumen y gráficos de verdad (se persisten), y nada de gameplay cambia.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. SFX (data-driven, con placeholders)**

* **Fuentes:** sonidos aportados por el PO (toolbox de Roblox o archivos externos); donde no haya asset, la entrada queda con **placeholder** (genérico o silencio) **marcado PENDIENTE** en `SFXConfig`/`ASSETS_REGISTRY` — se completa después **solo cambiando el assetId por config, sin tocar código**.
* **Catálogo acotado (anti-scope-creep, máximo 1–2 por categoría):**

| Categoría | Sonido(s) (subidos — `Workspace.Sounds` / PO) | Uso |
|-----------|------------------|-----|
| Hit melee | `sfx_sword_hit` (140462043853173) · `sfx_normal_hit` (80809123525734) · `sfx_normal_hit_2` (136755951725689) | Golpe cuerpo a cuerpo y básicos sin armas (player, ácaro, lobo) |
| Hit mágico | `sfx_magic_hit` (81276928984693) | Skills Instant MATK y proyectiles |
| Cast | `sfx_sword_skill` (138293953015099) · `sfx_magic_skill` (9116385056) · `sfx_magic_skill_2` (137545490038565) · `sfx_bow_shoot` (90951132448816) | Cast de skills (por familia: espada/magia/arco) |
| Cura | `sfx_magic_heal` (138498992667102) | Heal del Clérigo |
| Escudo | `sfx_magic_shield` (9116384757) | Muro sagrado / Escudo de fe |
| AoE | `sfx_skill_selfAOE` (140728595235867) · `sfx_boss_AOE` (99963459517796) | GroundAoE/SelfAoE + AoE del jefe |
| Muerte enemigo | `sfx_die` (138867344936809) | Enemy death |
| Muerte jugador | `sfx_die` (138867344936809, reutilizado — temporal, decisión PO) | Player death |
| Nivel up | `sfx_lvl_up` (140602821561280) | Level up (R6a) |
| UI | PENDIENTE (PoC SFX-02 con sonido del PO) | Click estándar botones/ventanas |
| Boss | `sfx_boss_skill` (9125640290) · `sfx_boss_AOE` (99963459517796) | Jotunn, Guardián de la Escarcha (ataques) |
| Moneda | Sonido de transacciones (140395633128797, aportado por el PO) | Compras/ventas vendor, subasta, oro |

* **Integración:** ids en **config** (reutilizar el patrón `VFXConfig` → `SFXConfig` nuevo o campo en configs existentes — **el mismo contrato validado por la PoC HU-SFX-02**), reproducidos client-side con **autoridad del evento server** (quién puede oír qué: los hits propios y los del party); volumen relativo y sin spam (cooldown de reproducción, máx N por segundo).
* **Registro:** cada sonido en `ASSETS_REGISTRY` (rbxassetid, autor, licencia; los placeholders marcados **PENDIENTE**).

#### **2. Feedback de hits**

* **Screen shake sutil:** al **recibir** daño (breve, amplitud baja, 0.1–0.15 s) y opcionalmente al golpear con crítico (más leve). Configurable por intensidad en config (0 = off).
* No tocar: hit-stop, zoom, cámara de targeting (R3.1 intacta).

#### **3. Ajustes del menú (implementar placeholders de R6.10)**

* **Volumen:** slider en el menú → controla el volumen de audio del juego (MasterVolume del juego; no cambia el volumen de la app). Persiste por dispositivo (UserSettings/PlayerModule o config local cliente).
* **Gráficos:** selector simple (Automático / Baja / Media / Alta) → `UserSettings():GetService("UserGameSettings").QualityLevel` (o `GraphicsMode`). Persiste por dispositivo.
* Ambos reemplazan el feedback "Próximamente" de esos botones (Ordenar UI ya es real desde R6.11).
* UI: controles con el estilo Hearthbound Gold (EST-13; slider/tab como componentes existentes).

#### **4. Música (tracks del PO — mapeo cerrado 2026-10-12)**

* **Tracks por contexto**, data-driven en `MusicConfig` (los 4 aportados por el PO, ya subidos):

| Contexto | Track | Asset |
|----------|-------|-------|
| Hub/pueblo | Vandrheim | `rbxassetid://77363443690081` |
| Dungeon pisos 1–2 | Vandrheim-Frost-Dungeon1-2 | `rbxassetid://112917722141522` |
| Dungeon pisos 3–5 (más intenso) | Vandrheim-Frost-Dungeon3-5 | `rbxassetid://70388794256162` |
| Batalla del Jotunn (jefe final) | Vandrheim-Frost-JotunnBossFight | `rbxassetid://126551601593677` |
| Victoria/muerte | PENDIENTE | — |

* **Reglas de reproducción (decisión PO):**
  * **Exclusividad: UNA sola música a la vez — nunca se solapan** (al cambiar de contexto, crossfade: baja la actual y entra la nueva; esta regla aplica **solo a la música**, los SFX suenan libremente encima).
  * **Boss theme solo durante la batalla del Jotunn** (arena piso 5, boss con aggro/vivo); al morir, vuelve el tema de pisos 3–5.
  * **Bucle por área + delay ≥10 s entre repeticiones** (config `loopDelay = 10`): el track suena en loop mientras el jugador está en su área, con al menos 10 s de silencio entre vuelta y vuelta para que no parezca disco rayado.
* La música **respeta el slider de Volumen** del menú y no interfiere con los SFX (canales separados).
* Registro en `ASSETS_REGISTRY` (los 4 tracks aportados por el PO, uso propio).

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
* Los sonidos y la música usan los assets del PO (toolbox/externos) o placeholders marcados PENDIENTE, con registro y licencias claras; límite 1–2 SFX por categoría; la música completa después solo cambia assets por config.
* Volumen/Gráficos persisten por dispositivo (no por personaje — es config de máquina).

---

### **Alcance**

#### Incluye

* SFX por categoría (data-driven, con placeholders PENDIENTE intercambiables por config; mismo contrato que la PoC SFX-02).
* Música por contexto (`MusicConfig`: pueblo/dungeon/combate/jefe/victoria-muerte) con crossfade; tracks del PO, resto placeholder.
* Screen shake sutil configurable (feedback de hits).
* Slider de Volumen y selector de Gráficos funcionales en el menú (persisten por dispositivo).

#### No incluye

* Paquetes de sonido comprados/creados (salvo decisión explícita).
* Hit-stop, zoom de impacto ni cambios de cámara.
* Otros ajustes del menú (solo los 2 placeholders pendientes + Orden UI ya implementado).
* Cambios a gameplay, balance o reglas.

---

### **Definition of Done (DoD)**

* [ ] Capacidad de SFX confirmada; sonidos de las categorías integrados por config y registrados (placeholders marcados PENDIENTE donde no haya asset).
* [ ] Sin spam de audio (cooldown/límite por segundo).
* [ ] Música por contexto con crossfade (4 tracks del PO mapeados; victoria/muerte PENDIENTE); respeta el slider de Volumen; **una sola música a la vez** + loop con delay ≥10 s.
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
| SFX | Assets del PO (toolbox/externos) o placeholders PENDIENTE; 1–2 por categoría; config data-driven (`SFXConfig` = mismo contrato que la PoC); registro obligatorio |
| Música | 4 tracks del PO mapeados (`MusicConfig`: pueblo/dungeon 1–2/dungeon 3–5/jefe; victoria-muerte PENDIENTE) + crossfade; **una sola a la vez** (nunca se solapan; no aplica a SFX); loop por área con delay ≥10 s; respeta Volumen |
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
| 2026-10-12 | **R9b directo con placeholders + música (decisión PO):** SFX con assets del PO o placeholders PENDIENTE (mismo contrato que la PoC SFX-02 — ambas van de la mano); **nueva sección de música** (`MusicConfig` por contexto + crossfade, tracks del PO); completar después = solo cambiar assets por config |
| 2026-10-12 | **Sonidos reales del PO (15 en `Workspace.Sounds` + transacciones):** catálogo mapeado con IDs subidos (melee/magia/cast/cura/escudo/AoE/muerte/lvlup/boss) + **nueva categoría Moneda** (transacciones, `140395633128797`); pendientes: **muerte del jugador** y **click UI** (PoC SFX-02); registrados en ASSETS_REGISTRY |
| 2026-10-12 | **Música mapeada (4 tracks del PO, subidos):** hub `77363443690081` · pisos 1–2 `112917722141522` · pisos 3–5 `70388794256162` (más intenso) · Jotunn `126551601593677` (solo durante la batalla); victoria/muerte PENDIENTE. **Reglas PO:** una sola música a la vez (nunca se solapan; SFX exentos) + loop por área con **delay ≥10 s** |
| 2026-10-12 | **Muerte del jugador = `sfx_die` reutilizado** (temporal, decisión PO); pendiente solo el **click UI** (PoC SFX-02) |