# HU-ESTETICA-50: Rediseño e integración del panel de matchmaking de dungeon (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Estética / UI / Predungeon
**Prioridad:** Alta
**Estado:** Corrección requerida: el dev integró frames equivocados; reemplazar esa UI con `o0nxs`, `B3yoQT` y `FRPZ6`. No cerrar RC sin verificación contra Pencil.
**Tipo:** Integración/rediseño visual de UI existente (dev)
**Fase GDD:** R9a.2 — nueva presentación del matchmaking de dungeon
**Depende de:** HU-R9a.2 (lógica de salas/matchmaking), HU-R9a/R9a.1 (party e invitaciones), HU-ESTETICA-37 (diseño anterior y lenguaje visual), HU-ESTETICA-46 (Guía de la Helada separada), HU-R6.27 (casillas y tooltips), `ASSETS_LIST.md` (iconos de Tank/Heal/DPS), `Vandrheim-design.pen`
**Componentes observados:** `MatchmakingUI`, `MatchmakingClient`, `PartyClient`, `PartyService`, `RoomConfig.RoleIcons` y `RoomConfig.RoleIconsUncovered`
**No modifica:** reglas de matchmaking, composición, roles, party, ready-check, teleport ni contenido de la dungeon.

---

### Narrativa (INVEST)

**Como** jugador en el hub,
**quiero** un buscador de dungeon claro, atractivo y fácil de recorrer,
**para** encontrar o crear una sala, entender su composición y entrar a la Helada con mi party.

**Como** desarrollador,
**quiero** integrar los nuevos paneles de Pencil sin recrear la lógica de R9a.2,
**para** modernizar la presentación manteniendo intactos party, ready-check y teleport.

---

### Descripción / Contexto

La HU-R9a.2 define el sistema de prelobby y HU-ESTETICA-37 entregó un diseño anterior. El PO seleccionó en Pencil los frames Cuaderno `o0nxs` (Salas), `B3yoQT` (Crear sala) y `FRPZ6` (Tu sala), todos de 680×485. La primera integración referenció frames anteriores y no coincide con la selección; esta HU deja los IDs elegidos como única fuente visual y requiere corregir esa integración. Los seis IDs Roblox de roles ya están registrados.

Esta HU reemplaza la presentación anterior del matchmaking por los frames seleccionados por el PO, integra los iconos activos/inactivos de roles y conecta los controles a la lógica ya definida por R9a.2. La UI existente basada en otros frames debe sustituirse completa por esta referencia; no se resuelve cambiando colores ni creando un segundo buscador.

**Criterio de hecho global:** el jugador completa desde el nuevo panel el flujo funcional ya existente de entrada Solo/Grupo, salas disponibles, creación y sala propia; cada estado muestra la información autoritativa, usa los iconos de roles finales y funciona en PC y móvil sin cambiar reglas ni regresionar party/dungeon.

---

### Referencias de diseño en Pencil

Archivo: `Vandrheim-design.pen`.

| ID de frame | Nombre en Pencil | Uso previsto |
|---|---|---|
| `o0nxs` | `EST-37 Cuaderno · Salas` (680×485) | **Selección más reciente del PO:** salas disponibles; reemplaza la referencia anterior. |
| `B3yoQT` | `EST-37 Cuaderno · Crear sala` (680×485) | **Selección más reciente del PO:** crear sala; reemplaza la referencia anterior. |
| `FRPZ6` | `EST-37 Cuaderno · Tu sala` (680×485) | **Selección más reciente del PO:** party, roles y ready-check; reemplaza la referencia anterior. |
| `vp61U`, `hsuJW`, `pokG5` | `EST-37 — Dungeon Finder · Cuaderno` (1000×620) | Selección anterior; conservar como referencia histórica, no usar para esta implementación. |
| `YpPzy`, `Y3Rw1`, `RCQsy` | `EST-37 — Dungeon Finder · Salas disponibles/Crear sala/Tu sala` | Variantes Dungeon Finder no seleccionadas; referencia histórica, no combinar con Cuaderno. |
| `nGRiT`, `Jh4wN` | `HU-ESTETICA-37 — Matchmaking · Reskin simple / Crear sala · Estado alternativo` | Bocetos previos; no son el set de implementación final. |
| `NcFgD` | `HU-ESTETICA-37 — Variante móvil` | Diseño móvil anterior; no usar como arte final. Adaptar las vistas seleccionadas a móvil y validar el resultado con el PO. |

**Set visual final:** usar exclusivamente los tres frames seleccionados más recientemente por el PO (`o0nxs`, `B3yoQT`, `FRPZ6`) para el flujo de Grupo. Sus dimensiones de referencia son 680×485, con spread de 636×380, dos páginas de 308×380 y lomo de 20 px. Esta selección supersede las referencias anteriores `vp61U`, `hsuJW` y `pokG5`. No mezclar componentes de las variantes Dungeon Finder, Reskin simple ni crear sala alternativo. La ruta Solo/Grupo y el acceso inicial conservan la lógica de R9a.2; adaptar esa entrada al lenguaje visual Cuaderno durante la integración.

El acceso a la Guía debe abrir HU-ESTETICA-46 como panel independiente; no reinsertar la guía completa dentro del buscador.

---

### Iconos de roles — IDs pendientes del PO

Los PNG simplificados aprobados están en `Assets/Icons/UI/PartyRoles/`. Se recibieron los IDs nuevos del PO el 2026-10-23; utilizar estos y no los IDs anteriores.

| Estado | Rol | Asset | ID Roblox final |
|---|---|---|---|
| Cubierto/activo | Tank | `Icon_UI_role_tank.png` — escudo con chevron defensivo | `rbxassetid://99345927547899` |
| Cubierto/activo | Heal | `Icon_UI_role_heal.png` — cruz de sanación simplificada | `rbxassetid://128865686691543` |
| Cubierto/activo | DPS | `Icon_UI_role_dps.png` — espadas cruzadas simplificadas | `rbxassetid://111799977902329` |
| Vacante/inactivo | Tank | `Icon_UI_role_tank_uncovered.png` | `rbxassetid://95037433065246` |
| Vacante/inactivo | Heal | `Icon_UI_role_heal_uncovered.png` | `rbxassetid://115978652940412` |
| Vacante/inactivo | DPS | `Icon_UI_role_dps_uncovered.png` | `rbxassetid://109267135109201` |

Integrar los tres primeros en `RoomConfig.RoleIcons` y los tres últimos en `RoomConfig.RoleIconsUncovered`. El icono comunica visualmente el rol; conservar nombre accesible/tooltip Tank, Heal o DPS y no depender solo del color.

---

### Contrato visual y funcional

#### Vistas e interacción

* **Entrada Solo/Grupo:** conservar ambas rutas de R9a.2. Solo inicia el flujo individual actual; Grupo abre el buscador. La elección no debe perderse al cambiar de pestaña.
* **Dungeon seleccionada:** mostrar nombre y datos breves procedentes de configuración; el acceso **Abrir guía** abre el panel independiente de EST-46. No hardcodear pisos, dificultad, enemigos ni loot del mockup.
* **Salas disponibles:** lista con nombre de sala, líder, dungeon/dificultad si aplica, ocupación X/4, cobertura de roles con iconos activos/inactivos y acción Unirse. Mostrar estado vacío, carga, error, sala llena y refresco según estados ya soportados por R9a.2.
* **Crear sala:** seguir exactamente el frame seleccionado `B3yoQT`: nombre opcional, visibilidad pública/privada y feedback claro de creación correcta o error. No reutilizar formularios de diseños anteriores.
* **Tu sala:** party existente precargado, líder, miembros, clase/spec/nivel, rol derivado, estado Listo/Esperando, invitación, salir y estado de inicio automático. Los slots vacíos muestran rol esperado y variante `uncovered` cuando el diseño/modelo de estado los utilice. No mostrar un botón accionable de inicio manual.
* Mantener navegación/tabs y controles de cerrar/volver conectados a las vistas existentes; no crear ventanas duplicadas ni duplicar solicitudes/remotes.

#### Reglas de negocio preservadas (HU-R9a.2)

* Roles calculados server-side a partir de clase/spec: Protector = Tank, Misericordia = Heal, resto = DPS. El cliente solo presenta el rol recibido.
* Party ya armado se precarga en la sala; no vuelve a invitar a los mismos miembros.
* Objetivo 1 Tank / 1 Heal / 2 DPS se presenta como información en matchmaking, no bloquea el inicio; party prearmado no valida composición.
* El grupo inicia con 2–4 miembros presentes y listos; si queda un solo jugador, usa la ruta Solo. Las salas privadas no aparecen en la lista pública y el acceso sigue siendo por invitación.
* Reutilizar PartyService, remotes, ready, invitaciones y teleport existentes de R9a.2/R9a.1/R9a; no crear una implementación de matchmaking paralela.
* **Inicio automático confirmado por el PO 2026-10-23:** cuando todos los miembros presentes están Listos y se cumplen las condiciones vigentes de R9a.2, el servidor inicia la run y todos se teleportan. No hay confirmación manual adicional del líder. Si un frame anterior muestra “Empezar/Iniciar”, eliminar ese control o reemplazarlo por estado informativo de espera/inicio; no emitir una solicitud de start manual.

#### Responsive y presentación

* Aplicar tokens Hearthbound Gold y componentes actuales; escalar proporcionalmente la referencia de 680×485, sin fijar el tamaño de runtime.
* PC y móvil horizontal: conservar la doble página, las pestañas y las proporciones exactas de los frames seleccionados. Móvil vertical: usar una sola página refluida, con scroll cuando sea necesario y targets táctiles legibles; no estirar el spread.
* Estados seleccionado, hover/foco, deshabilitado, carga, vacío, listo, no listo, público/privado y sala llena deben ser distinguibles sin depender únicamente del color.
* Respetar safe areas, escala de UI, foco/cierre, navegación por teclado y touch según los componentes comunes existentes.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Entrada Solo/Grupo

* **GIVEN** un jugador activa el portal de dungeon en el hub
* **WHEN** abre el buscador rediseñado
* **THEN** puede continuar por Solo o por Grupo usando los flujos existentes, sin duplicar runs ni parties

#### Escenario 1.1: Integración del diseño seleccionado

* **GIVEN** la implementación del buscador en Roblox
* **WHEN** se compara con `Vandrheim-design.pen`
* **THEN** las vistas Salas disponibles, Crear sala y Tu sala corresponden respectivamente a `o0nxs`, `B3yoQT` y `FRPZ6`
* **AND** no queda activa ninguna pantalla heredada de `vp61U`/`hsuJW`/`pokG5`, `YpPzy`/`Y3Rw1`/`RCQsy` ni `nGRiT`/`Jh4wN`

#### Escenario 2: Encontrar una sala

* **GIVEN** hay salas públicas disponibles en el servidor
* **WHEN** el jugador abre Salas disponibles
* **THEN** cada tarjeta refleja datos actuales, ocupación y roles con los iconos activos/vacantes correctos; Unirse respeta las validaciones de R9a.2

#### Escenario 3: Crear sala

* **GIVEN** el jugador elige Crear sala
* **WHEN** define nombre opcional y visibilidad y confirma
* **THEN** la UI envía la acción existente y presenta Tu sala o un error recuperable según la respuesta del servidor

#### Escenario 4: Party existente

* **GIVEN** el jugador ya pertenece a un party válido
* **WHEN** abre Tu sala / entra al modo Grupo
* **THEN** se ven los miembros actuales, roles y estados sin volver a invitarlos

#### Escenario 5: Roles y composición

* **GIVEN** una sala con miembros y plazas libres
* **WHEN** se muestra la cobertura
* **THEN** los roles provienen del servidor; los iconos activos y uncovered coinciden con roles ocupados/faltantes y la meta 1/1/2 es informativa

#### Escenario 6: Inicio de run

* **GIVEN** una sala con los miembros presentes listos
* **WHEN** todos los miembros presentes marcan Listo y se cumplen las condiciones de R9a.2
* **THEN** el servidor inicia automáticamente la run, la UI refleja el estado de inicio y se reutiliza el teleport grupal existente, sin pedir otro click al líder

#### Escenario 7: Guía independiente

* **GIVEN** el jugador solicita información ampliada de la Helada
* **WHEN** pulsa Abrir guía
* **THEN** abre HU-ESTETICA-46 en su propio panel y el buscador conserva su estado al regresar

#### Escenario 8: Estados responsive y regresión

* **GIVEN** el buscador se usa en PC y móvil con lista vacía, larga, sala llena, privada o party listo/no listo
* **WHEN** se navega por todas las vistas
* **THEN** no hay recortes ni acciones inaccesibles; party, invitaciones, Solo, teleport y gameplay se comportan como antes

---

### Alcance

#### Incluye

* Rediseño e integración de la UI de matchmaking con el set visual aprobado de Pencil.
* Vistas Solo/Grupo, salas disponibles, crear sala, Tu sala, cobertura/estado de roles, accesos a guía e invitación.
* Integración de iconos activos e inactivos de Tank/Heal/DPS con los seis IDs finales proporcionados por el PO.
* Datos en runtime conectados a R9a.2 y QA PC/móvil.

#### No incluye

* Nueva lógica de matchmaking, cambios de roles/composición/ready/invitaciones o teleport.
* Un nuevo sistema de búsqueda cross-server/MMR, party frames de dungeon, cambios a la guía EST-46 o reintroducir la guía embebida.
* Botón/confirmación manual de inicio por líder; el servidor inicia automáticamente al quedar listos todos los presentes.

---

### Definition of Done (DoD)

* [x] El PO confirma los frames Cuaderno seleccionados (`o0nxs`, `B3yoQT`, `FRPZ6`, 680×485) como referencia vigente y el inicio automático al quedar todos listos.
* [ ] Se corrige la integración existente y las vistas de grupo usan exactamente `o0nxs`, `B3yoQT` y `FRPZ6`; las referencias anteriores se retiran, no se combinan.
* [ ] Los seis iconos aprobados están subidos a Roblox, los IDs entregados por el PO están registrados y activos/uncovered se muestran correctamente.
* [ ] Lista, formularios, party precargado, estados de rol/ready, sala llena/vacía/privada, errores e invitaciones usan datos reales y acciones existentes.
* [ ] La meta 1/1/2 es informativa y no se introduce bloqueo de composición ni otro cambio de reglas.
* [ ] Al quedar todos los miembros presentes listos, la sala inicia sin click adicional del líder; no queda botón manual de inicio.
* [ ] Guía abre como panel separado de EST-46; volver al buscador conserva estado apropiado.
* [ ] Adaptación PC/móvil verificada: sin clipping, targets táctiles adecuados, safe area y textos legibles.
* [ ] Regresión de R9a/R9a.1/R9a.2, solo, invitaciones y teleport sin errores rojos.
* [ ] El dev prepara RC desde esta HU; capturas de los estados clave y nota de cierre en GDD.

---

### Pendientes para cerrar antes del RC

1. Integrar en `RoomConfig.RoleIcons` y `RoomConfig.RoleIconsUncovered` los seis IDs finales registrados arriba y en `ASSETS_LIST.md`.
2. Adaptar la variante móvil de `NcFgD` al diseño Cuaderno; no se encontró un set Cuaderno específico para móvil en Pencil.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-23 | Primera redacción de HU-ESTETICA-50 apuntó a marcos antiguos; esa referencia quedó supersedida por la selección final del PO. |
| 2026-10-23 | PO entrega los seis IDs Roblox de roles activos/inactivos; se registran en la HU y `ASSETS_LIST.md`. |
| 2026-10-23 | Interpretación inicial incorrecta de la selección visual: se habían anotado `vp61U`, `hsuJW`, `pokG5`; no eran los frames seleccionados para implementar. |
| 2026-10-23 | El PO selecciona en Pencil `o0nxs`, `B3yoQT` y `FRPZ6` (680×485); estos IDs sustituyen las referencias anteriores. La implementación del dev todavía requiere el rework indicado en esta HU. |
| 2026-10-23 | Corrección PO: la integración previa usó frames antiguos. Se reitera que el dev debe sustituirla y verificar visualmente solo contra `o0nxs`, `B3yoQT` y `FRPZ6`; el set Cuaderno anterior no es el seleccionado. |
