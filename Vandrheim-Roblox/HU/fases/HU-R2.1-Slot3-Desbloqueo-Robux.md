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

* **Token `token_slot3` — "Pase: Tercer Personaje"** (HU-ECONOMIA-04): Dev Product repetible, **299 Robux** (a confirmar por el PO; configurable sin tocar lógica).
* Vías de obtención: **compra con Robux** (recibe el token) o **compra con oro** a otro jugador (tradeo/subasta) — ambas terminan en canje.
* El PO crea el Dev Product en el Dashboard (Monetización del universo) y pasa su **ID numérico** (mismo flujo que el ProductId de R6.28).

#### **2. Flujo (server-authoritative, vía token)**

1. Slot 3 bloqueado muestra CTA "Desbloquear (token o 299 R$)".
2. El jugador obtiene `token_slot3` (compra Robux → inventario, o compra con oro a otro jugador).
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
* **WHEN** compra el Game Pass (299 R$) y se confirma
* **THEN** `maxSlots = 3` y puede crear su tercer personaje

#### **Escenario 2: Ya lo posee**

* **GIVEN** un jugador que ya compró el pase
* **WHEN** entra (rejoin)
* **THEN** el slot 3 aparece desbloqueado sin recomprar

#### **Escenario 3: Sin compra**

* **GIVEN** un jugador sin el pase
* **WHEN** intenta crear un tercer PJ
* **THEN** el servidor lo rechaza y el slot sigue locked con su CTA

#### **Escenario 4: Compra cancelada**

* **GIVEN** el checkout abierto
* **WHEN** el jugador cancela o falla el pago
* **THEN** nada cambia (slot locked, feedback claro, sin errores)

#### **Escenario 5: Anti-exploit**

* **GIVEN** un cliente manipulado
* **WHEN** intenta forzar `maxSlots = 3` sin ownership
* **THEN** el servidor lo rechaza (solo ownership confirmado desbloquea)

#### **Escenario 6: Regresión**

* **GIVEN** el flujo activo
* **WHEN** se crean/seleccionan/borran PJs (PC y móvil, publicado)
* **THEN** los 2 slots gratis funcionan igual y no hay errores rojos

---

### **Alcance**

#### Incluye

* Game Pass real (precio configurable) + checkout + verificación server-side de ownership.
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

### **Decisiones por defecto (PO: confirmar precio e ID)**

| Tema | Default |
|------|---------|
| Producto | **Dev Product + token `token_slot3`** (sin Game Pass — decisión PO 2026-10-12) |
| Precio | **299 Robux** (a confirmar por el PO) |
| ID | **Pendiente PO:** ID del Dev Product en el Dashboard (Monetización del universo) |
| Ownership | Verificado por servidor en compra y en cada join (sin campo en perfil) |
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