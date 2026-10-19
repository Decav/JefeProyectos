# HU-ESTETICA-46: Reskin de la Guía de la Helada (panel independiente, dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Dungeon — Reskin (dev)
**Prioridad:** Alta
**Estado:** Lista para implementar (RC obligatorio del dev antes de programar)
**Tipo:** Reskin de UI (dev) — solo visual, sin tocar lógica
**Fase GDD:** UI (sustituye la guía embebida en EST-37 y la referencia de EST-04)
**Depende de:** frame del `.pen`: **`y9v2HJ` — "HU-ESTETICA-46 — Guía de la Helada"** (aprobado por PO), HU-ESTETICA-13 (tokens/handoff), HU-R9a.2 (lobby/matchmaking — de donde se separa), HU-R9a (party), HU-ESTETICA-37 (iconos del micromenú), ASSETS_LIST (retratos y armas), HU-R7/R7.1 (jefes y loot)
**No modifica:** lobby, matchmaking, matchmaking UI (EST-37 queda intacto salvo la guía), loot ni reglas

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** abrir una guía independiente de la Helada desde el micromenú,
**para** revisar pisos, enemigos y loot sin entrar al lobby de matchmaking.

---

### Descripción / Contexto

El diseñador entregó el rediseño de la guía como panel propio (`y9v2HJ` — "HU-ESTETICA-46 — Guía de la Helada", **680×500**): un libro de **dos páginas** con **tabs compactos de pisos**, columna izquierda de información del piso seleccionado (overview, enemigos, encuentro, mini-jefe) y columna derecha con **retratos de enemigos**, separador y **botín por rareza** (iconos de armas blancas/verdes). Se abre desde el micromenú con `Icon_Menu_dungeon_guide` (R6.35) y **ya no está embebida en EST-37**.

**Criterio de hecho global:** la guía se ve como el frame (libro de dos páginas, tabs de piso, overview/enemigos/encuentro/minijefe a la izquierda, retratos+botín a la derecha) con datos reales y sin romper el lobby ni matchmaking.

---

### Especificaciones técnicas

#### 1. Áreas a reskinear (referencia: `y9v2HJ`)

1. **Encabezado:** título "GUÍA DE LA HELADA" (fs 20 bold pergamino), subtítulo "5 pisos · niveles aprox. 4–16" (fs 8 muted), etiqueta "GUÍA" (fs 9 bold pergamino), botón cerrar × (`#3A2525` + pergamino).
2. **Pie de página:** "DUNGEON DE LA HELADA · GUÍA POR PISO" (fs 7 muted).
3. **Tabs de pisos** (compactos, `#15100D`): 5 tabs "PISO 1…5" (fs 7); el activo destacado (`#8F713F` con texto `#F1E4C9`), el resto `#211914` con texto `#B8A98F`. Al cambiar de tab, se actualiza el contenido de las dos páginas.
4. **Página izquierda** (`#241B16`): título del piso seleccionado (fs 12 bold pergamino, ej. "PISO 1 · NIVEL ~4") + overview (fs 9, pergamino suave) + secciones con heading dorado `#C89445` (fs 8): **ENEMIGOS** (detalle fs 10 pergamino), **ENCUENTRO** (fs 9), **MINI-JEFE · SALA FINAL** (morado `#B48ADE`, fs 9).
5. **Página derecha** (`#241B16`): **retratos de enemigos** (iconos de enemigo + retrato en fondo negro; fs 10 nombre bold pergamino, fs 7.5 descripción muted) y **BOTÍN** (heading fs 12 bold pergamino) con etiquetas de rareza (COMÚN `#C89445`, POCO COMÚN `#C89445`) y **iconos de armas** (fondo negro + icono de arma, por rareza blanca/verde).
6. **Separador de sección** (`#6B4A2B`) entre botín y retratos.

#### 2. Reglas

* **Conservar los nombres de instancias/jerarquía que los scripts usan** (contrato EST-13).
* **Los datos son reales** (pisos, niveles, enemigos, mini-jefes, loot) — config-driven (R6a/R7/R9a.2), nunca hardcodeados.
* **No se incluye el lobby/matchmaking** (EST-37 queda intacto salvo la eliminación de la guía embebida).
* **Iconos/retratos** usan assets existentes: retratos `Portrait_Enemy_Generic`/`Portrait_Boss_FrostLord`/`Portrait_Boss_Jotunn` (ASSETS_LIST, ya subidos) y armas `Icon_Item_*` (ASSETS_LIST). Fallback si falta un asset (no rompe).
* Fuentes legibles (R6.27): títulos ≥12, nombres ≥10, detalles ≥9; en móvil escala (máx 85 % viewport).
* Tooltips: hover en iconos de armas → tooltip de ítem (plantilla `item_equipable` de R6.27/EST-44).

#### 3. Contenido por piso — textos de referencia (PO 2026-10-17; datos REALES de `EnemyConfig`)

> El frame actual solo tiene el contenido de **Piso 1** construido (los tabs 2–5 son labels). **Fuentes reales:** `EnemyConfig.FLOOR_TEMPLATES`, `EnemyConfig.MINIBOSS_TEMPLATES`, `EnemyConfig` (niveles/AI) y GDD §dungeon. Nombres inventados NO van (no existen "warg/draugr/tejedor/guardia glacial").

| Piso | Nivel | Enemigos | Mini-jefe / Boss | Botín |
|---|---|---|---|---|
| 1 | ~4 | Ácaro de escarcha · Lobo helado | Trol de escarcha (melee) | blanco/verde |
| 2 | ~7 | Ácaro de escarcha elite · Arquera helada (ranged) | Gólem de hielo (melee) | verde/azul |
| 3 | ~10 | Lobo helado elite · Arquera helada elite | Espectro de ventisca (tifón en cono, carga 1,5 s) | azul |
| 4 | ~13 | Elemental de hielo (ranged) · Caballero helado (melee) | Señor de la Escarcha (golpe en área + invoca caballeros) → **4 Épicas Únicas** (armas) | azul |
| 5 | ~16 | Elemental de hielo elite · Caballero helado elite | **Jotunn, Guardián de la Escarcha** (charcos · avalancha · rugido) | cofre: 35 % épica de tu clase (50 % arma / 50 % armadura) + 25 % oro (40–80) |

Textos por piso (propuesta del dev 2026-10-17, alineados a los datos reales; se muestran en **Overview** y **Encuentro** respectivamente):

| Piso | Debajo de «Piso · Nivel» (Overview) | Encuentro |
|---|---|---|
| 1 | "Primer tramo de la Helada. Ácaros y lobos acechan de cerca: avanza sin atraer varios grupos a la vez." | "El trol de escarcha custodia la sala final. Reserva recursos para sostener el combate cuerpo a cuerpo." |
| 2 | "Las arqueras heladas añaden presión a distancia mientras los ácaros élite se acercan. Identifica ambas amenazas antes de atacar." | "El gólem de hielo ofrece un combate de desgaste. Dosifica tus recursos y utiliza la curación antes de quedar en peligro." |
| 3 | "Lobos y arqueras de élite endurecen el recorrido. Evita que perseguir a una arquera te lleve hasta otro grupo." | "El espectro de ventisca combate a distancia. Cuando prepare su ataque en cono, desplázate hacia un costado para salir de la zona marcada." |
| 4 | "Caballeros y elementales combinan ataques cercanos con proyectiles. Controla el grupo antes de sumar más enemigos al combate." | "El señor de la escarcha invoca caballeros de apoyo. Vigila los refuerzos y abandona la franja marcada frente a él." |
| 5 | "Último tramo de la Helada, defendido por caballeros y elementales de élite. Llega a Jotunn con vida y consumibles disponibles." | "Abandona las zonas de hielo persistentes, esquiva la avalancha frontal y aléjate cuando Jotunn prepare su rugido." |

- Botín por rareza: "COMÚN — armas blancas" · "POCO COMÚN — armas verdes" (iconos de arma existentes).
- Pie: "Los valores son ilustrativos; la config define los reales."

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Reskin fiel

* **GIVEN** la guía reskineada
* **WHEN** se compara con el frame `y9v2HJ`
* **THEN** replica tabs de piso, libro de dos páginas, overview/enemigos/encuentro/minijefe a la izquierda, retratos+botín a la derecha, encabezado/pie (colores/fuentes)

#### Escenario 2: Datos reales

* **GIVEN** la guía
* **WHEN** se cambia de piso (tabs)
* **THEN** las dos páginas reflejan los datos reales de ese piso (enemigos, mini-jefe, botín)

#### Escenario 3: Apertura desde el micromenú

* **GIVEN** el botón Guía en el micromenú (R6.35, icono `Icon_Menu_dungeon_guide`)
* **WHEN** se pulsa
* **THEN** se abre el panel independiente (no el lobby de matchmaking)

#### Escenario 4: Separada del lobby

* **GIVEN** la guía y el lobby de matchmaking (EST-37)
* **WHEN** se revisan
* **THEN** son pantallas distintas; EST-37 deja de tener la guía embebida (se retira la Vista 5 o se redirige al nuevo panel)

#### Escenario 5: Lógica intacta

* **GIVEN** el reskin aplicado
* **WHEN** se abre/cierra y cambia de piso
* **THEN** no hay errores rojos; lobby/matchmaking intactos

#### Escenario 6: Móvil

* **GIVEN** la guía en móvil
* **WHEN** se revisa
* **THEN** se adapta (escale/touch) sin romper y con fuentes legibles (R6.27)

---

### Alcance

#### Incluye

* Reskin de la guía según `y9v2HJ` (tabs, libro de 2 páginas, retratos, botín, encabezado/pie) + apertura independiente desde el micromenú.

#### No incluye

* Lógica de matchmaking/lobby (EST-37 intacto salvo la guía); ni los iconos de enemigos finales (placeholders hasta sus assets).

---

### Definition of Done (DoD)

* [ ] Guía replica el frame `y9v2HJ` (tabs de piso, libro de 2 páginas, overview/enemigos/encuentro/minijefe, retratos+botín, encabezado/pie).
* [ ] Datos reales por piso (enemigos, mini-jefes, botín) desde config.
* [ ] Abre desde el micromenú (R6.35) y ya no está embebida en el lobby (EST-37).
* [ ] Nombres de instancias conservados; lobby/matchmaking intactos (sin errores rojos).
* [ ] Móvil OK y fuentes legibles (R6.27).
* [ ] El dev prepara el RC desde esta HU antes de programar (DEV_PROMPT).
* [ ] Nota en GDD después de QA.

---

### Estimación (orientativa)

2 sesiones del dev: reskin + integración de apertura desde el micromenú + regresión.

---

### Historial

| Fecha | Cambio |
|-------|--------|
| 2026-10-17 | Creación de HU-ESTETICA-46: reskin de la Guía de la Helada (frame `y9v2HJ` aprobado) — tabs de piso, libro de 2 páginas (overview/enemigos/encuentro/minijefe a la izquierda, retratos+botín a la derecha), encabezado/pie; abre independiente desde el micromenú (R6.35, `Icon_Menu_dungeon_guide`); se separa del lobby (EST-37) |