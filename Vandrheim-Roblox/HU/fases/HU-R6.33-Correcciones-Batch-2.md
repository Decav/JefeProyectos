# HU-R6.33: Correcciones batch 2 — números de combate, AoE en móvil, frames grandes, micromenú y precasts de bosses (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Fixes — Batch 2 (reportado por PO 2026-10-12)
**Prioridad:** Alta
**Estado:** Implementada (confirmación del PO 2026-10-22; RC cerrado)
**Tipo:** Bugfixes/mejoras (dev)
**Fase GDD:** R6.33 (no cambia reglas de juego)
**Depende de:** HU-R6.20 (OrdenUI/escala), HU-R6.12 (nameplates), HU-R6.18/R7.1 (telegraphs/precats), HU-R6.27 (fuentes), HU-R3 (GroundAoE/precats), HU-ESTETICA-47 (frames de combate), HU-ESTETICA-19/20 (micromenú), ASSETS_LIST (icono `Icon_Menu_nameplates`)
**Componentes observados:** números de daño flotantes, precast circular GroundAoE (móvil), player/target frames, micromenú (+ botón nameplates), precasts de espectro y Jotunn (escombro, rugido), slow "Congelado"

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** números de combate legibles, AoEs que se casteen bien en móvil, frames que no tapen la pantalla, un micromenú íntegro y precasts de jefes que avisen con claridad (progreso, sin círculos de más, con efecto de slow visible),
**para** jugar cómodo en PC y móvil.

---

### **Descripción del Requerimiento / Contexto**

Batch de 5 correcciones (PO 2026-10-12):

1. **Números de combate poco visibles** — se mejoran (más grandes + más duración + negrita).
2. **AoE ground en móvil no se castea** (Consagración del Paladín, AoE del Clérigo): el precast circular se mueve pero **al soltar no se lanza** la habilidad.
3. **Player/target frames muy grandes en móvil** — al 60 % con el OrdenUI siguen tapando.
4. **Micromenú roto por el botón de nameplates** — el contorno dorado no se adaptó al orden UI y el botón **no tiene icono** (ID aportado por el PO: `Icon_Menu_nameplates` `121076782362772`).
5. **Precasts de bosses** (espectro y Jotunn, excepto avalancha): solo círculos sin progreso; el **escombro muestra un círculo celeste de más** (solo debe salir el rojo); el **rugido** no muestra nada en el jugador con slow.

**Criterio de hecho global:** las 5 correcciones aplicadas, sin errores rojos, en PC y móvil.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Números de combate legibles**

* Más **grandes**, con **más duración en pantalla** y **negrita** (las 3 mejoras — decisión PO).
* **Valores cerrados (PO 2026-10-12, para rc093):** tamaño **20–26 px** (base 22 px), duración visible **1.0–1.5 s** (base 1.2 s), **bold siempre**. El dev ajusta dentro de esos rangos durante QA sin nueva aprobación.
* Config-driven: tamaño, tiempo visible y peso (sin tocar lógica de daño).

#### **2. AoE ground en móvil (fix)**

* Al **soltar** el precast circular se **confirma y castea** la habilidad en esa posición (mismo contrato que PC con click) — hoy el soltar no dispara nada.
* Aplica a GroundAoE (Consagración, AoE del Clérigo y cualquier otro): arrastrar mueve el precast, soltar lanza (`RequestCast` con la posición validada por el server).

#### **3. Frames de jugador/target en móvil**

* Ampliar el rango de escala del OrdenUI para estos frames (default: **mínimo 40 %** en vez de 60 %) **y/o** reducir su tamaño base en móvil — el 60 % actual sigue tapando pantalla.
* Sin romper el layout del HUD (regresión PC intacta).

#### **4. Micromenú + botón nameplates**

* El **contorno dorado del frame se adapta** al orden UI con el botón nuevo (el botón de toggle de nameplates R6.12 no debe romper el contorno).
* El botón usa el icono **`Icon_Menu_nameplates`** (`rbxassetid://121076782362772`, aportado por el PO, uso propio — registrado en ASSETS_REGISTRY).

#### **5. Precasts de bosses**

* **Espectro y Jotunn (excepto avalancha frontal):** el precast lleva **relleno interno radial que muestra el progreso del casteo** (se completa al impactar) y el **rojo interno se suaviza** (decisión PO 2026-10-12, para rc093): fill interno al **40–60 % de opacidad** (base 50 %), **borde siempre al 100 %** para legibilidad; el dev ajusta dentro del rango en QA sin nueva aprobación.
* **Escombro (Jotunn):** se **elimina el círculo celeste** del precast — **solo sale el rojo** (el celeste se ve mal).
* **Rugido/slow:** mientras el jugador tenga **"Congelado"** (slow del rugido), muestra **escarcha alrededor del personaje** (efecto visual de estado, client-side, atado a la duración del debuff).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Números legibles**

* **GIVEN** el combate
* **WHEN** hay daño/cura/críticos
* **THEN** los números se ven grandes, en negrita y duran más en pantalla

#### **Escenario 2: AoE en móvil**

* **GIVEN** un GroundAoE en móvil (Consagración, AoE del Clérigo)
* **WHEN** se arrastra el precast y se suelta
* **THEN** la habilidad se castea en esa posición (igual que en PC)

#### **Escenario 3: Frames en móvil**

* **GIVEN** player/target frames en móvil
* **WHEN** se baja la escala (mínimo 40 %)
* **THEN** dejan de tapar la pantalla sin romper el HUD

#### **Escenario 4: Micromenú íntegro**

* **GIVEN** el micromenú con el botón de nameplates
* **WHEN** se revisa (PC y móvil, con orden UI)
* **THEN** el contorno dorado se adapta y el botón muestra su icono (`Icon_Menu_nameplates`)

#### **Escenario 5: Precasts con progreso**

* **GIVEN** precasts del espectro y del Jotunn (no avalancha)
* **WHEN** castean
* **THEN** el círculo tiene relleno radial de progreso y el rojo interno suavizado

#### **Escenario 6: Escombro sin celeste**

* **GIVEN** el Escombro del Jotunn
* **WHEN** aparece el precast
* **THEN** sale **solo el círculo rojo** (sin celeste)

#### **Escenario 7: Escarcha del slow**

* **GIVEN** un jugador con "Congelado" del rugido
* **WHEN** dura el debuff
* **THEN** se ve escarcha alrededor del personaje (desaparece al terminar)

#### **Escenario 8: Regresión**

* **GIVEN** las 5 correcciones
* **WHEN** se juega completo (PC y móvil, publicado)
* **THEN** no hay errores rojos y PC queda intacto

---

### **Alcance**

#### Incluye

* Las 5 correcciones (números, AoE móvil, escala de frames, micromenú + icono, precasts + slow visual).

#### No incluye

* Cambios de daño, reglas, telegraphs nuevos ni balance.

---

### **Definition of Done (DoD)**

* [ ] Números grandes + negrita + más duración (config).
* [ ] AoE ground se castea al soltar en móvil.
* [ ] Player/target frames escalables hasta 40 % (o base menor en móvil) sin tapar.
* [ ] Micromenú con contorno adaptado e icono `Icon_Menu_nameplates`.
* [ ] Precasts con relleno de progreso (rojo suavizado); escombro sin celeste; escarcha visible con "Congelado".
* [ ] PC intacto; sin errores rojos (PC y móvil, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2–3 sesiones del dev: números + AoE móvil + escala + micromenú + precasts/slow.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-R6.33 (batch 2): números de combate (tamaño+duración+negrita) · AoE ground en móvil (soltar = castear) · frames player/target hasta 40 % en móvil · micromenú (contorno adaptado + icono `Icon_Menu_nameplates` `121076782362772`) · precasts de espectro/Jotunn con relleno de progreso (rojo suavizado), escombro sin círculo celeste y escarcha visible con el slow del rugido (reportado por PO) |
| 2026-10-12 | **rc093 APROBADO + valores cerrados (respuestas al dev):** números **20–26 px / 1.0–1.5 s / bold** (bases 22 px y 1.2 s) · rojo interno de precasts al **40–60 % de opacidad** (base 50 %, borde al 100 %); **ajuste visual autorizado dentro de esos rangos durante QA** sin nueva aprobación |
