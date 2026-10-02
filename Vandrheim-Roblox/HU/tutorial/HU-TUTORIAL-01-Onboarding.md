# HU-TUTORIAL-01: Onboarding para nuevos jugadores — pasos guiados + panel de ayuda

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Tutorial / Onboarding (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Sistema nuevo (dev)
**Fase GDD:** Tutorial 1 (decisión PO 2026-09-22)
**Depende de:** HUD (R8c/EST-19/20), R2 (controles), HU-R9a (party), HU-ECONOMIA-01/02 (comercio/subasta), HU-ESTETICA-13 (tokens)
**Componentes observados:** HUD, controles PC/móvil, cámara (R6.15/23), sistema de skills, dungeon, party, vendors

---

### **Narrativa (INVEST)**

**Como** jugador nuevo,
**quiero** que al empezar me **expliquen cómo se juega** (pasos guiados) y poder **consultar la ayuda** en cualquier momento,
**para** entender el juego sin frustrarme: controles, combate, la dungeon y el party — que no es intuitivo para quien no conoce el formato.

---

### **Descripción del Requerimiento / Contexto**

El PO detectó que **los jugadores nuevos se pierden**: el juego asume que sabes qué es una dungeon, un party, los tiers, etc. Se añade un **onboarding guiado** (primera vez por personaje) + un **panel de ayuda** permanente (reabrible).

**Criterio de hecho global:** un jugador nuevo recibe una secuencia corta de pasos con **destacados visuales sobre el HUD** (qué es cada cosa) y puede **reabrir el panel de ayuda** cuando quiera; sin bloquear el juego.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Onboarding guiado (primera vez por personaje)**

* Se muestra al **primer spawn del personaje** (flag guardado por personaje en su perfil; `tutorialDone = true` tras completarlo o saltarlo).
* **No bloqueante:** tarjetas que avanzan con "Siguiente", botón "Omitir", y **highlight del HUD** (marco brillante sobre el elemento explicado: barra de skills, mini-mapa, party frame, vida/maná…).
* **Contenido (8 tarjetas máx., cortas, con título + 1–2 frases):**
  1. **Movimiento y cámara** — PC (WASD + ratón/rueda) y móvil (joystick + drag + pinza) — "ajusta tu cámara".
  2. **Combatir** — click/ataque básico, **skills** (barra inferior, maná), **targeting** (enemigo seleccionado).
  3. **Pociones y vida** — pociones (R8d: 25%/50% HP/MP), buffs.
  4. **La dungeon** — pisos progresivos, cofres al final, **jefes de piso y mini-jefes**; morir = reiniciar el piso.
  5. **El party** — qué es, cómo invitar (invitación 60 s, R9a), roles (tanque/daño/soporte), party frame (nivel/HP en verde).
  6. **Ítems y equipo** — tiers (blanco→morado/único), set bonuses, equipar (tecla C), vendedores y **respec**.
  7. **Economía** — comercio con jugadores (Hub) y **subasta global** (compra/venta cross-server, fees).
  8. **Fin** — "El panel de ayuda está siempre disponible (tecla `?`)".
* Texto y estructura en un **ModuleScript `TutorialContent`** (editable sin tocar código).

#### **2. Panel de ayuda permanente**

* Abrir: **tecla `?`** (PC) y **botón en el HUD** (móvil, ícono `?`).
* **Secciones** (acordeón/scroll): Controles · Cámara · Combate y skills · Pociones · Dungeon · Party · Ítems y tiers · Vendedores · Economía (comercio y subasta) · Muerte/respawn · Preguntas frecuentes.
* Cada sección = título + 2–5 frases + (opcional) icono/ilustración del sistema (ASSETS_LIST si aplica).
* Misma fuente de contenido (`TutorialContent`) que el onboarding — el panel muestra las secciones completas.

#### **3. Reglas**

* El onboarding **no bloquea** el juego (se puede omitir y se puede reabrir).
* No se repite tras completarse/saltarse (flag por personaje), pero el **panel de ayuda siempre está**.
* PC y móvil (mismo contenido, layout responsive).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Primera vez**

* **GIVEN** un personaje nuevo
* **WHEN** spawnea por primera vez
* **THEN** se muestra el onboarding (tarjetas con highlights del HUD) sin bloquear el juego

#### **Escenario 2: Omitir y reabrir**

* **GIVEN** el onboarding activo
* **WHEN** el jugador omite (o lo completa)
* **THEN** no vuelve a aparecer en ese personaje, y el **panel de ayuda** se abre con `?` / botón HUD

#### **Escenario 3: Contenido**

* **GIVEN** el panel de ayuda
* **WHEN** se abren las secciones
* **THEN** explican controles (PC y móvil), combate, dungeon, party, ítems/tiers, vendedores y economía

#### **Escenario 4: Regresión**

* **GIVEN** el tutorial implementado
* **WHEN** se juega el flujo completo (nuevo personaje → dungeon → party → subasta)
* **THEN** no hay errores rojos y el HUD sigue funcionando igual

---

### **Alcance**

#### Incluye

* Onboarding de 8 tarjetas con highlights (primera vez por personaje, no bloqueante).
* Panel de ayuda permanente (tecla `?` / botón HUD) con secciones.
* Contenido en `TutorialContent` (editable).

#### No incluye

* Arte de ilustraciones (se reutilizan iconos existentes; el diseñador puede pulir en fase posterior — HU estética pendiente).

---

### **Definition of Done (DoD)**

* [ ] Onboarding guiado (8 tarjetas + highlights) en primera vez por personaje, omisible.
* [ ] Panel de ayuda completo y reabrible (PC `?` / botón móvil).
* [ ] PC y móvil OK; sin errores rojos.
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones por defecto (para confirmar con PO)**

| Tema | Default |
|------|---------|
| Cuándo se muestra | Primera vez por personaje (flag `tutorialDone`) |
| Formato | 8 tarjetas no bloqueantes con highlight del HUD + botón Omitir |
| Panel de ayuda | Tecla `?` (PC) + botón HUD (móvil), secciones completas |
| Contenido | ModuleScript `TutorialContent` editable |
| Diseño visual | Tokens EST-13 (pulido visual del diseñador en fase posterior) |

---

### **Estimación (orientativa)**

2–3 sesiones del dev: flujo de onboarding + highlights + panel de ayuda + contenido.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-TUTORIAL-01: onboarding guiado (8 tarjetas no bloqueantes con highlights del HUD, primera vez por personaje) + panel de ayuda permanente (tecla `?`/botón HUD) con contenido en ModuleScript editable (decisión PO — jugadores nuevos se pierden) |