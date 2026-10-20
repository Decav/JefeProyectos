# HU-R2.1: Activar el 3er slot de personaje (desbloqueo con Robux)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Personaje / Monetización de conveniencia
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Activación de flujo (dev) — vía token de HU-ECONOMIA-04 (sin Game Pass)
**Fase GDD:** R2.1 (el stub de R2 nunca se activó; el desbloqueo va por token, decisión PO 2026-10-12)
**Depende de:** HU-R2 (slots: 2 gratis + 3.º locked), HU-ECONOMIA-04 (token `token_slot3`: compra con Robux, canje, venta), HU-ESTETICA-25/32 (selección/creación PJ), HU-R6.28 (patrón de compra Robux validada)
**Componentes observados:** pantalla de slots (2 vacíos + 3.º locked), `maxSlots: 2 | 3`, flag de test en Studio

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** poder desbloquear el **3er slot de personaje con Robux**,
**para** tener un tercer PJ sin depender del stub de test.

**Como** equipo,
**quiero** reemplazar el stub por el flujo real de compra,
**para** que el slot 3 funcione en producción (compra → ownership → crear).

---

### **Descripción del Requerimiento / Contexto**

Hoy el slot 3 existe bloqueado con CTA "Desbloquear", pero el desbloqueo era un **stub** (solo detectaba gamepass o flag de test). Nunca se activó el flujo real. Con el modelo de tokens (decisión PO 2026-10-12, HU-ECONOMIA-04) **no hay Game Pass**: se compra el Dev Product → token `token_slot3` → se canjea (o se vende por oro).

**Criterio de hecho global:** el jugador obtiene el token (compra con Robux o compra con oro a otro jugador), lo canjea, `maxSlots` pasa a 3 y puede crear su tercer personaje — sin flags de test ni Game Pass.

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Producto (decisión PO: todo Dev Product, sin Game Pass)**

* **Token `token_slot3` — "Pase: Tercer Personaje"** (HU-ECONOMIA-04): Developer Product repetible `Vandrheim Token - Tercer slot de personaje`, **ProductId `3718622291`**, **149 Robux**.
* Vías de obtención: **compra con Robux** (el recibo crea un grant pendiente en el buzón de cuenta) o **compra con oro** a otro jugador (tradeo/subasta).
* El jugador reclama el token del buzón en el inventario de un personaje existente y lo canjea desde ese PJ; el flag `perks.slot3` desbloquea el slot para toda la cuenta.
* El Developer Product ya fue creado por el PO en el Dashboard; el ProductId numérico `3718622291` se usa en la configuración de `token_slot3`.

#### **2. Flujo (server-authoritative, vía token)**

1. Slot 3 bloqueado muestra CTA "Desbloquear (ficha o 149 R$)".
2. El jugador reclama `token_slot3` del buzón de cuenta al inventario de un PJ existente (compra Robux), o lo recibe como ítem por trade/subasta.
3. **Canje:** usar el token → el servidor valida (token en posesión + `perks.slot3` no poseído) → `perks.slot3 = true` → `maxSlots = 3` → el slot se desbloquea y permite crear el 3er PJ (el token se consume).
4. Sin token canjeado: el slot sigue locked (rechazo de 3er PJ, como ya hace R2).

#### **3. Reglas**

* Nunca confiar en el cliente: solo el servidor canjea (valida token + flag no poseído) y fija `maxSlots = 3`.
* El flag de test de Studio se **retira** (o queda solo tras flag de debug explícito, sin efecto en producción).
* Si ya posee `perks.slot3`, el canje se rechaza (el token sigue vendible) — regla de ECON-04.
* UI: estados locked/desbloqueado del slot 3 + feedback de compra/canje (TooltipSystem R6.27; sin "Próximamente").
* Copy vigente: el juego se completa con 2 PJs (el 3.º es conveniencia).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Compra y desbloqueo**

* **GIVEN** un jugador con 2 PJs y slot 3 bloqueado
* **WHEN** compra el Developer Product `3718622291`, reclama el token a un PJ existente y lo canjea
* **THEN** `maxSlots = 3` y puede crear su tercer personaje

#### **Escenario 2: Ya lo posee**

* **GIVEN** un jugador que ya canjeó `token_slot3` y tiene `perks.slot3 = true`
* **WHEN** entra (rejoin)
* **THEN** el slot 3 aparece desbloqueado sin recomprar

#### **Escenario 3: Sin compra**

* **GIVEN** un jugador sin `perks.slot3` y sin una ficha `token_slot3` canjeable
* **WHEN** intenta crear un tercer PJ
* **THEN** el servidor lo rechaza y el slot sigue locked con su CTA

#### **Escenario 4: Compra cancelada**

* **GIVEN** el checkout abierto
* **WHEN** el jugador cancela o falla el pago
* **THEN** nada cambia (slot locked, feedback claro, sin errores)

#### **Escenario 5: Anti-exploit**

* **GIVEN** un cliente manipulado
* **WHEN** intenta forzar `maxSlots = 3` sin canje válido
* **THEN** el servidor lo rechaza (solo el servidor activa `perks.slot3` tras canjear el token)

#### **Escenario 6: Regresión**

* **GIVEN** el flujo activo
* **WHEN** se crean/seleccionan/borran PJs (PC y móvil, publicado)
* **THEN** los 2 slots gratis funcionan igual y no hay errores rojos

---

### **Alcance**

#### Incluye

* Developer Product `3718622291` (149 Robux) + grant idempotente en el buzón de cuenta, reclamo por personaje y canje server-side.
* Retiro del flag de test; UI del slot 3 (locked/desbloqueado/feedback).

#### No incluye

* Cambios a creación/selección de PJ (R2 intacto salvo el unlock); ni más slots.

---

### **Definition of Done (DoD)**

* [ ] Dev Product creado (ID en config) y token `token_slot3` otorgado por compra (idempotente).
* [ ] Canje validado por el servidor (`perks.slot3` + consumo); `maxSlots = 3` solo tras canje.
* [ ] Flag de test retirado de producción; 2 slots gratis intactos.
* [ ] Sin errores rojos (crear/seleccionar/rejoin, publicado).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Decisiones confirmadas por el PO**

| Tema | Default |
|------|---------|
| Producto | **Dev Product + token `token_slot3`** (sin Game Pass — decisión PO 2026-10-12) |
| Precio | **149 Robux** (confirmado por el PO el 2026-10-19) |
| ID | **`3718622291`** — `Vandrheim Token - Tercer slot de personaje` |
| Grant y canje | Recibo idempotente crea el grant en el buzón de cuenta; se reclama en un PJ existente; el servidor activa `perks.slot3` para toda la cuenta al canjearlo |
| Copy | El juego se completa con 2 PJs; el 3.º es conveniencia |

---

### **Estimación (orientativa)**

1 sesión del dev: producto + checkout + validación + UI del slot + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-10-12 | Creación de HU-R2.1: activar el 3er slot (nunca se activó — era stub con flag de test) → **Game Pass** real (default 299 Robux, a confirmar + GamePassId pendiente del PO), checkout con `PromptGamePassPurchase`, ownership server-side, retiro del flag de test (decisión PO) |
| 2026-10-12 | **Cambio de modelo (decisión PO: todo Dev Product, sin Game Passes):** el desbloqueo va por **token `token_slot3`** (HU-ECONOMIA-04) — compra Robux o compra con oro → canje validado → `maxSlots = 3`; Game Pass descartado |
| 2026-10-19 | El PO confirma Developer Product `Vandrheim Token - Tercer slot de personaje`, ProductId `3718622291`, precio 149 Robux; se actualizan los criterios vigentes de compra → token → canje. Las decisiones Game Pass/299 Robux de 2026-10-12 quedan como historial reemplazado |
