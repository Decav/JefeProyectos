# HU-ESTETICA-37: Matchmaking / Prelobby de la dungeon — diseño de UI en Pencil

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Predungeon
**Prioridad:** Alta
**Estado:** Lista para implementar
**Tipo:** Diseño de UI en Pencil (solo diseñador; **sin desarrollo, sin código**)
**Fase GDD:** EST (transversal; complementa la HU dev `HU-R9a.2-Matchmaking-Dungeon-Lobby`)
**Depende de:** HU-R9a.2 (funcionalidad del prelobby), HU-ESTETICA-22 (party frames y ventana de party — referencias de sala), HU-ESTETICA-10/11/12 (ventanas de equipo/mochila/vendor: patrón de panel), HU-ESTETICA-13 (tokens y paquete de UI), HU-ESTETICA-19 (HUD de combate — coherencia visual), HU-R6.27 (casillas con fondo negro + hover de borde)
**No modifica:** la lógica de R9a.2, party, teleport ni gameplay

---

### **Narrativa (INVEST)**

**Como** jugador,
**quiero** una pantalla clara y nórdica para decidir cómo entrar a la dungeon — ir solo o en grupo, crear o unirme a una sala, ver los roles, el ready-check y la información de la Helada (enemigos, jefes, loot),
**para** armar la composición 1 tank / 1 heal / 2 dps y entrar con todo lo necesario a la vista.

**Como** equipo de desarrollo,
**quiero** el diseño completo del matchmaking listo en Pencil,
**para** implementar la ventana sin reinterpretar nada.

---

### **Descripción del Requerimiento / Contexto**

`HU-R9a.2` implementa el prelobby de la dungeon: elección Solo/Grupo, salas públicas/privadas, lista de salas, sala con roles y Listo, inicio automático con composición 1/1/2 y una pestaña de información de la dungeon. Esta HU produce el **diseño visual completo** de esa interfaz en `Vandrheim-design.pen`, coherente con Hearthbound Gold (tokens EST-13) y con el estilo de casillas de R6.27.

**Criterio de hecho global:** existe en el `.pen` un frame completo de la pantalla de matchmaking (flujo solo/grupo + sala + lista + info de dungeon, con estados y variante móvil) listo para que el dev lo implemente en R9a.2.

---

### **Especificaciones Técnicas / Contratos de API (visual)**

#### **Pantallas / vistas a diseñar (frame propio: `HU-ESTETICA-37 — Matchmaking Lobby`)**

1. **Vista inicial — Solo / Grupo:**
   * Título nórdico (ej. "El portal de la Helada").
   * Dos tarjetas grandes: **Ir solo** (runa de espada simple) y **Grupo** (runa de 4 figuras/escudos) — permite ver ambas opciones de un vistazo.
   * Acceso secundario a la **info de la dungeon** (botón/libro "🧭 Guía de la Helada" o similar, sin emoji: icono de pergamino).

2. **Vista Crear sala:**
   * Campo de **nombre de sala** (opcional, placeholder "Sala de <nombre>").
   * **Toggle Pública / Privada** (con micro-labels: "Pública — cualquiera del pueblo puede unirse" / "Privada — solo invitados").
   * Botón **Crear sala**.

3. **Vista Lista de salas (públicas):**
   * Tarjetas de sala: **nombre**, **líder** (clase+nivel), **ocupación X/4**, **roles cubiertos** (3 mini-runas Tank/Heal/DPS encendidas/apagadas).
   * Botón **Unirse**. Estado vacío: "No hay salas abiertas — crea una".

4. **Vista Sala (el corazón de la pantalla):**
   * **4 casillas** en fila/grid, cada una con: **rol esperado** (runa Tank/Heal/DPS marcada), **jugador** (nombre + clase + spec + nivel), estado **Listo** (check nórdico) y estado vacío ("Esperando…").
   * **Autocompletado del party:** si el jugador llegó con un party armado, las casillas ya vienen ocupadas por sus miembros (sin invitarlos de nuevo).
   * Cabecera: nombre de sala, **pública/privada**, líder marcado (corona/runas), ocupación X/4.
   * Mensajes de composición (bajo las casillas) **informativos**: "Falta tanque", "Falta curador", "Falta dps" u objetivo "Composición objetivo 1/1/2" — **nunca bloquean el inicio**.
   * Botones: **Salir de sala** (miembro) y **Empezar run** (solo líder; habilitado cuando todos los presentes están Listo — funciona con 2, 3 o 4 jugadores; con 1 se indica "Modo solo").
   * Botón **Invitar** (abre la lista del lobby, patrón EST-22/R9a.1).

5. **Pestaña Info de la dungeon (misma ventana):**
   * Sección general: Helada, 5 pisos, niveles (P1 ~4 … P5 ~16), nota "run individual o de sala".
   * **Enemigos por piso**: 5 filas (Piso 1..5) con los enemigos de cada uno (miniaturas/runas + nombre + nivel).
   * **Jefes**: mini-jefe del piso 4 (Señor de la Escarcha) y **boss final (Jotunn)** — presentación con icono/runas + nombre + descripción breve.
   * **Loot de los últimos 2 jefes**: 2 secciones:
     * Señor de la Escarcha → uniques (4 ítems: espadón 2H + espada/arco/varita de escarcha), con mini-iconos y rareza.
     * Jotunn (boss final) → cofre: 35% épica de tu clase (50% arma / 50% armadura) + 25% oro (40–80).
   * Los datos visuales son ilustrativos; los valores reales vienen de config (R9a.2).

6. **Estados obligatorios (en el frame):**
   * Sala incompleta (falta tank / falta heal / falta dps).
   * Sala completa con todos **Listo** (pre-inicio).
   * Sala **privada** (marcada, sin aparecer en la lista).
   * Lista de salas con 2–3 tarjetas + estado vacío.
   * Vista **móvil** (vertical, misma info, casillas apiladas).

#### **Reglas de diseño**

* Tokens Hearthbound Gold (EST-13): fondos oscuros cálidos, latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`, casillas **fondo negro + hover de borde** (R6.27).
* **Runas de rol**: 3 mini-iconos propios — **Tank** (escudo), **Heal** (cruz/runa de vida), **DPS** (espada cruzada) — minimalistas, legibles a 24 px (patrón EST-23 iconos del micromenú).
* Tipografías Geist Mono / Playfair Display / Inter (mapeo EST-13); Scale + concentración móvil.
* No inventar mecánicas: solo los elementos de R9a.2.

---

### **Criterios de Aceptación (Gherkin)**

#### **Escenario 1: Pantalla completa**

* **GIVEN** el frame del matchmaking en el `.pen`.
* **WHEN** se recorren las vistas.
* **THEN** existen: Solo/Grupo, crear sala, lista de salas, sala (4 casillas + roles + Listo) e info de dungeon.
* **AND** todas comparten el mismo lenguaje visual (tokens EST-13).

#### **Escenario 2: Sala legible**

* **GIVEN** la vista de sala.
* **WHEN** se observa.
* **THEN** se distingue rol esperado vs cubierto, jugador, nivel y estado Listo en cada casilla.
* **AND** los mensajes de composición (falta tank/heal/dps) son claros.

#### **Escenario 3: Info de dungeon**

* **GIVEN** la pestaña de información.
* **WHEN** se revisa.
* **THEN** se ven pisos con sus enemigos, los 2 jefes finales y el loot de ambos.
* **AND** los datos son ilustrativos (los reales vienen de config).

#### **Escenario 4: Estados**

* **GIVEN** los estados del flujo.
* **WHEN** se comparan.
* **THEN** sala incompleta, sala lista (todos Listo), sala privada, lista vacía y móvil están representados.

#### **Escenario 5: Coherencia**

* **GIVEN** el diseño del matchmaking.
* **WHEN** se compara con party (EST-22), HUD (EST-19) y casillas (R6.27).
* **THEN** el resultado es coherente y el dev puede implementar sin reinterpretar.

---

### **Comportamiento Visual / Reglas de Negocio**

* Diseño puro: no define lógica de sala, roles, ready ni teleport (eso es R9a.2).
* Las runas de rol Tank/Heal/DPS son un set propio (entregable de iconos, patrón EST-23).
* La info de la dungeon es ilustrativa; los valores finales salen de config.
* Las casillas de sala usan el estándar R6.27 (fondo negro + borde hover).

---

### **Alcance**

#### Incluye

* Frame `HU-ESTETICA-37 — Matchmaking Lobby` con las 5 vistas (Solo/Grupo, Crear sala, Lista, Sala, Info).
* Estados: sala incompleta, completa-lista, privada, lista vacía y móvil.
* Runas de rol Tank/Heal/DPS (mini iconos).
* Actualización de `ASSETS_LIST.md` con los iconos nuevos del matchmaking si corresponde.

#### No incluye

* Implementación en Roblox (el dev usa la HU-R9a.2).
* Cambios a party frames (EST-22), HUD (EST-19) ni al resto de pantallas.
* Iconos tipo ítem/skill detallados; solo los minimalistas del flujo de sala.

---

### **Definition of Done (DoD)**

* [x] Existe el frame `HU-ESTETICA-37 — Matchmaking Lobby` en el `.pen` (`Nkt7w`).
* [x] Las 5 vistas están diseñadas y conectadas (tabs SOLO/GRUPO · CREAR SALA · SALAS ABIERTAS · TU SALA · GUÍA).
* [x] Las casillas de sala muestran rol, jugador, nivel y Listo (vistas 4A incompleta y 4B completa/privada).
* [x] Los mensajes de composición (falta tank/heal/dps) están representados como informativos; nunca deshabilitan Empezar. El estado incompleto deshabilita solo mientras falta el Listo de un miembro presente; la vista lista y nota de 2/4 muestran el inicio habilitado con 2–4 presentes listos y 1 jugador como modo solo.
* [x] La pestaña de info muestra pisos/enemigos/jefes y loot de los 2 últimos jefes (con disclaimer "datos ilustrativos").
* [x] Estados: incompleta, completa-lista, privada, lista vacía y móvil (verificado en `Nkt7w` + variante móvil `NcFgD`).
* [x] Runas de rol Tank/Heal/DPS entregadas (set vectorial `daQ4B`; `ASSETS_LIST.md` con `Icon_UI_role_tank/heal/dps`).
* [x] Coherente con EST-13/EST-22/R6.27 y sin recortes: capturas de escritorio, móvil y estados revisadas; bounds de escritorio/móvil/set de runas sin clipping.
* [ ] El dev puede implementar R9a.2 con el diseño sin reinterpretar: pendiente de aprobación PM del render.
* [x] Reporte al PM entregado (`HU-ESTETICA-37-REPORTE-PM.md`).
* [x] Estado de invitación entrante a una sala de dungeon diseñado en el frame `HU-ESTETICA-37 — Invitación a dungeon` (`UbZiA`): líder, sala/mazmorra, ocupación, integrantes y acciones Aceptar/Rechazar.

---

### **Decisiones por defecto EST-37**

| Tema | Default |
|------|---------|
| Vistas | Solo/Grupo · Crear sala · Lista de salas · Sala · Info de dungeon |
| Sala | 4 casillas con rol esperado/cubierto + Listo |
| Roles | Runas propias Tank (escudo) / Heal (vida) / DPS (espadas) |
| Composición | Mensajes claros de rol faltante |
| Info | General + enemigos por piso + 2 jefes + loot (ilustrativo) |
| Estilo | Tokens EST-13 + casillas R6.27 + coherencia EST-22/19 |
| Móvil | Variante vertical apilada |

---

### **Estimación (orientativa)**

2–3 sesiones del diseñador: 5 vistas + estados + runas de rol + revisión móvil.

---

### **Historial**

| Fecha | Cambio |
|-------|--------|
| 2026-09-22 | Creación de HU-ESTETICA-37: diseño en Pencil de la pantalla de matchmaking/prelobby de la dungeon (Solo/Grupo, crear/lista de salas, sala con roles y Listo, info de dungeon) — complementa la HU dev R9a.2 |
| 2026-09-22 | **Diseño entregado y verificado por PM (estructura):** frames `Nkt7w` (lobby escritorio, 5 vistas), `NcFgD` (variante móvil) y `daQ4B` (runas Tank/Heal/DPS); `ASSETS_LIST.md` actualizado; reporte `HU-ESTETICA-37-REPORTE-PM.md`. Pendiente: verificación visual del render y aprobación final del PM |
| 2026-09-22 | **Ajuste PO aplicado al diseño:** party existente autocargado sin reinvitar; composición 1/1/2 marcada informativa y no bloqueante; Empezar depende del Listo de los presentes (2–4 pueden iniciar; 1 = modo solo). Capturas y bounds revisados; tooltips/estados reflejados en escritorio y móvil |
| 2026-09-22 | Se añade el frame `UbZiA` para la invitación entrante a una sala de dungeon: contexto del pueblo atenuado, quién invita, información de sala/Helada, ocupación, integrantes y acciones Aceptar/Rechazar. Captura revisada; bounds sin clipping |