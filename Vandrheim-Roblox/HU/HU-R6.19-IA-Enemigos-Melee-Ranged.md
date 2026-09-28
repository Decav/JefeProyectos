# HU-R6.19: Mejora de IA de enemigos — melee ataca en rango y ranged con retroceso acotado

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Mejora de IA (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Mejora de comportamiento de enemigos (dev)
**Fase GDD:** R6.19 (no cambia reglas de juego ni balance)
**Depende de:** HU-R6a (IA melee/ranged en `EnemyService`), HU-R6.7 (animaciones por familia)
**Componentes observados:** `EnemyService` (IA melee/ranged), `EnemyConfig` (rangos/velocidades)

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** que los enemigos se comporten con lógica:
* los **melee** ataquen apenas entren en rango (sin poder darles vueltas infinitas),
* los **ranged** no se alejen hasta quedar pillados contra paredes o en rincones,
**para** que el combate se sienta justo y los enemigos no se vean tontos.

---

### **Descripción del Requerimiento / Contexto**

**Problemas reportados (PO 2026-09-22):**

1. **Melee:** se les puede dar **vueltas eternamente** sin que ataquen — parecen querer "tocarte" en vez de atacar al estar en rango. Deberían **atacar apenas entren en rango** de su ataque.
2. **Ranged:** se alejan demasiado — chocan contra paredes, se esconden en rincones o quedan **pillados**; mantener la idea de alejarse pero de forma inteligente (sin verse tontos).

**Criterio de hecho global:** los melee atacan en cuanto el jugador entra en su rango (aunque el jugador rote alrededor); los ranged mantienen distancia de forma acotada e inteligente (sin quedar pillados contra estructuras).

---

### **Especificaciones Técnicas / Contratos de API**

#### **1. Melee: atacar en rango**

* La IA melee actual persigue hasta "tocar"; se cambia a: **si el jugador está dentro de `attackRange` → atacar de inmediato** (sin requerir contacto físico).
* Al atacar, el enemigo se **orienta hacia el jugador** (facing) y ejecuta el ataque (animación + daño) — el jugador que rodea sigue recibiendo el golpe si está en rango.
* **Desafío:** que el giro no sea instantáneo/tracking perfecto: el enemigo gira con una velocidad acotada (config) para que rodear al enemigo sea viable pero castigado (algunos golpes conectan), no la explotación actual de nunca atacar.
* **Defaults PM (rc059, 2026-09-22):**
  * **Giro melee:** velocidad **común = 240°/s** en config global (`turnSpeedDegPerSec`), con **override por template** si un enemigo específico lo necesita.
  * **Conexión del golpe:** el ataque melee **conecta por distancia** (si el jugador está dentro de `attackRange` al momento del golpe, recibe el daño) — **sin arco frontal** (no se penaliza por ángulo). El giro acotado es lo que hace que rodear sea viable pero castigado.

#### **2. Ranged: retroceso acotado e inteligente**

* **Límite de distancia:** el enemigo ranged deja de alejarse cuando el jugador está fuera de su rango de ataque + margen (**default PM: margen común = 8 studs** sobre `attackRange`, config con override por template), o cuando está detrás de él una **estructura/pared**.
* **Detección de obstáculos:** raycast hacia atrás antes de moverse; si hay pared, **no retrocede** (se queda en su posición y sigue atacando).
* **Salida de rincones:** si quedó pillado (sin camino atrás), prioriza **volver a línea de visión** del jugador (si es posible) o simplemente se queda atacando (nunca eternamente contra la pared).
* **Alternativa si no alcanza:** se puede simplificar a "no retroceder nunca" (decisión del dev con PM si el fix complejo no vale la pena) — pero el default es el retroceso acotado con raycast.

#### **2.1 LOS + sincronización visual del proyectil (decisión final PO 2026-09-22)**

* **LOS al disparar (se mantiene):** antes de disparar, raycast estructural al jugador (solo estructuras — enemigos/jugadores no bloquean); sin visión → **no dispara** y se reposiciona para ganar visión. Esconderse detrás de una columna evita que el enemigo te dispare.
* **Flujo del daño (decisión final):** se **conserva el flujo actual** — daño **instantáneo** al disparar (server) + proyectil visual. **No** es esquivable (una vez disparado, el daño aplica sí o sí), **no** hay bloqueo por estructuras ni misses por movimiento.
* **Sincronización visual (el cambio):** el proyectil debe viajar **rápido** para que el visual llegue (casi) al mismo tiempo que el daño — así se siente que el proyectil es lo que pega y no "daño por bluetooth". **Default PM: ~110 studs/s** (config `projectileSpeed`, por template) — si aún se ve desincronizado, se ajusta la velocidad en config.
* **Implementación:** LOS = raycast filtrado antes de disparar; velocidad del proyectil en config; sin simulación de daño en vuelo (daño server al disparar, como hoy).

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Melee ataca en rango**

* **GIVEN** un enemigo melee y un jugador rodeándolo
* **WHEN** el jugador entra en `attackRange`
* **THEN** el enemigo ataca de inmediato (orientándose hacia el jugador)
* **AND** rodear deja de ser gratis (algunos golpes conectan, giro acotado)

#### **Escenario 2: Ranged no se pilla**

* **GIVEN** un enemigo ranged cerca de una pared
* **WHEN** el jugador se acerca
* **THEN** el enemigo se aleja hasta el límite configurado **sin atravesar/quedar pillado** contra la estructura (raycast) y sigue atacando

#### **Escenario 3: Sin rincones eternos**

* **GIVEN** un ranged en un rincón
* **WHEN** no puede alejarse
* **THEN** se queda y ataca (nunca se queda eternamente pegado a la pared sin pelear)

#### **Escenario 4: LOS**

* **GIVEN** un enemigo ranged detrás de una estructura (pilar/pared) con el jugador al otro lado
* **WHEN** intenta atacar
* **THEN** no dispara (sin LOS) y **se reposiciona** para ganar visión
* **AND** una vez disparado, el daño aplica sí o sí (no esquivable) y el **proyectil visual llega rápido** (sincronizado con el daño)

#### **Escenario 5: Config y regresión**

* **GIVEN** la IA mejorada
* **WHEN** se revisan configs y se juega la dungeon completa
* **THEN** los parámetros viven en config y no hay errores rojos (solo y party)

---

### **Alcance**

#### Incluye

* Melee: ataque inmediato en rango con orientación y giro acotado.
* Ranged: límite de retroceso + raycast de obstáculos + comportamiento en rincones.
* **LOS:** los ranged no disparan sin línea de visión (raycast filtrado: solo estructuras) y se reposicionan para ganar visión.
* **Sincronización visual:** proyectil rápido (~110 studs/s, config) para que el visual coincida con el daño instantáneo (sin esquiva ni bloqueo — daño sí o sí al disparar).
* Parámetros en config.

#### No incluye

* Cambios de balance/daño (mismas bandas R8d).
* Nuevos tipos de IA ni cambios a mini-jefes/boss (sus mecánicas van en HU-R6.18/EST-31).

---

### **Definition of Done (DoD)**

* [ ] Melee ataca apenas entra en rango (rodear ya no es explotable).
* [ ] Ranged con retroceso acotado y sin quedar pillado contra estructuras.
* [ ] **LOS:** no disparan sin visión (se reposicionan); el daño instantáneo no cambia y el proyectil visual viaja rápido (sincronizado, sin esquiva).
* [ ] Parámetros en config; bandas R8d intactas; sin errores rojos en la dungeon (solo y party).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### **Estimación (orientativa)**

2 sesiones del dev: ajuste de IA melee/ranged + parámetros + regresión.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-R6.19: mejora de IA de enemigos — melee ataca al entrar en rango (giro acotado, sin vueltas infinitas) y ranged con retroceso limitado por raycast (sin quedar pillados); parámetros en config |
| 2026-09-22 | **LOS agregado (decisión PO):** los ranged no atacan a través de estructuras (raycast filtrado: solo obstáculos estructurales; enemigos/jugadores no bloquean), se reposicionan para ganar visión, los proyectiles en vuelo llegan igual y el ataque en carga se interrumpe si pierden visión |
| 2026-09-22 | **Defaults PM (rc059):** giro melee común **240°/s** (override por template); golpe melee **conecta por distancia** (sin arco frontal); margen ranged común **8 studs** sobre `attackRange` (override por template); **flujo ranged conservado** (daño inmediato + proyectil) con **LOS justo antes del daño** (sin wind-up en esta HU); **R6.7 satisfecha** (framework implementado) |
| 2026-09-22 | **Corrección PO (proyectil = daño):** se elimina el "daño instantáneo + proyectil decorativo" de los ranged — el **proyectil viaja y aplica el daño al impactar** (estructuras lo bloquean, moverse lo esquiva, velocidad ~50 studs/s config); aplica a enemigos ranged; las skills ranged del jugador quedan como están (decisión aparte, no rompe balance R8d) |
| 2026-09-22 | **Decisión final PO (reversa):** se mantiene el flujo actual (daño instantáneo al disparar, no esquivable, sin bloqueo) — el proyectil solo viaja **más rápido (~110 studs/s, config)** para que el visual llegue sincronizado con el daño; el LOS (no disparar sin visión) se mantiene |