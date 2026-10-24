# HU-R6.40: Normalizar el rango del Cazador — Puntería y ataques de arco (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / Combate / Cazador
**Prioridad:** Alta
**Estado:** Lista para RC
**Tipo:** Bugfix de alcance de ataques/habilidades (dev)
**Depende de:** HU-R8b (contenido Cazador), HU-R8e (Flecha venenosa), HU-R3 (combate y habilidades), HU-R6.19 (ataques ranged), `SKILLS_CATALOG`, `SkillConfig`/config de ataques básicos
**No modifica:** daño, cooldown, coste de maná, número de objetivos, set bonuses ni las habilidades de Asalto.

---

### Narrativa (INVEST)

**Como** jugador del Cazador de Puntería,
**quiero** un rango consistente para mis ataques de arco y habilidades,
**para** jugar la spec a distancia sin que sus acciones se sientan arbitrariamente cortas.

---

### Descripción / Contexto

El rango actual de Puntería varía sin una razón consistente: Flecha venenosa 25, Tiro en cadena 20 y Tiro certero/Disparo mortal 30; también se debe alinear el ataque básico de arco. El PO establece un estándar de **30 studs para todo Puntería, salvo Disparo mortal a 35 studs**.

**Criterio de hecho global:** el ataque básico de arco y las skills de Puntería validan y comunican 30 studs, excepto Disparo mortal, que valida y comunica 35 studs, tanto en cliente como en servidor.

---

### Tabla de rangos cerrados por el PO

| Acción | Alcance final |
|---|---:|
| Ataque básico automático de arco | 30 studs |
| Disparo perforante (`hunter_piercing_shot`) | 30 studs |
| Flecha venenosa (`hunter_mm_venom`) | 30 studs |
| Tiro certero (`hunter_mm_trueshot`) | 30 studs |
| Tiro en cadena (`hunter_mm_chain`) | 30 studs al objetivo inicial; el objetivo adicional sigue la regla de cercanía existente |
| Disparo mortal (`hunter_mm_death`) | 35 studs |

---

### Especificaciones técnicas / Contratos

* Mantener una sola fuente de verdad por acción: config del ataque básico de arco y rango de `SkillConfig` para skills. Actualizar también `SKILLS_CATALOG`.
* El servidor valida rango con el mismo valor que la UI/cursor de selección; el cliente no puede extenderlo.
* Actualizar los indicadores de rango/cast y textos que expongan el alcance, si existen; evitar que el feedback de “fuera de rango” contradiga el valor real.
* `Tiro en cadena`: 30 studs aplica al primer objetivo; no ampliar la búsqueda del objetivo secundario más allá de su regla existente de “cercano al original”.
* `Disparo mortal`: 35 studs es exclusivo de esta skill; el resto de Puntería y el básico de arco se quedan en 30.
* No cambiar cooldown, coste, stat, daño, cooldown interno ni bonuses de set.
* Las habilidades melee de Asalto y Golpe salvaje quedan intactas; el ataque automático de arco y Disparo perforante quedan a 30.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Ataque básico de arco

* **GIVEN** un Cazador con un enemigo válido a 30 studs
* **WHEN** realiza el ataque automático de arco o usa Disparo perforante
* **THEN** el servidor lo acepta dentro del rango y lo rechaza fuera de 30 studs

#### Escenario 2: Habilidades estándar de Puntería

* **GIVEN** Flecha venenosa, Tiro certero o Tiro en cadena y un objetivo válido
* **WHEN** el objetivo está a 30 studs o menos
* **THEN** el cast se acepta; a más de 30 studs se rechaza por rango

#### Escenario 3: Disparo mortal

* **GIVEN** Disparo mortal y un objetivo válido
* **WHEN** el objetivo está a 35 studs o menos
* **THEN** el cast se acepta; a más de 35 studs se rechaza por rango

#### Escenario 4: Cliente y servidor coinciden

* **GIVEN** los indicadores de selección/rango de Puntería
* **WHEN** el jugador apunta desde 29, 31, 34 o 36 studs
* **THEN** la indicación visual coincide con la validación server-side (30 para estándar, 35 para Disparo mortal)

#### Escenario 5: Sin cambios colaterales

* **GIVEN** un Cazador de Asalto o una clase distinta
* **WHEN** usa sus ataques/habilidades
* **THEN** sus rangos, daño, coste y cooldown permanecen sin cambios

---

### Definition of Done (DoD)

* [ ] Ataque automático de arco, Disparo perforante y Flecha venenosa/Tiro certero/Tiro en cadena usan 30 studs en config, servidor, UI y catálogo.
* [ ] Disparo mortal usa 35 studs en config, servidor, UI y catálogo.
* [ ] Los objetivos fuera del rango correspondiente se rechazan server-side con el feedback existente.
* [ ] Se comprueba Tiro en cadena: rango inicial 30; objetivo secundario conserva el alcance de cadena.
* [ ] Asalto y otras clases no presentan regresiones; sin errores rojos.
* [ ] `SKILLS_CATALOG` queda actualizado y el dev adjunta evidencia en el RC.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | HU nueva: estandarizar a 30 studs el rango del ataque automático de arco, Disparo perforante y Puntería; Disparo mortal queda a 35. |
