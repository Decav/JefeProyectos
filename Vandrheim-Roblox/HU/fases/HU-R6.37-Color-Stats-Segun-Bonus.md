# HU-R6.37: Tooltips de estadísticas, desglose de bonus y descripciones de skills (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** R6.x / UI / Tooltips de estadísticas y habilidades
**Prioridad:** Alta
**Estado:** Cerrada — implementada (confirmación del PO 2026-10-22)
**Tipo:** Mejora de presentación y explicación de estadísticas/habilidades (dev)
**Depende de:** HU-ESTETICA-45 (panel C, variante B), HU-ESTETICA-09/48 (tooltip y contenido del grimorio), HU-R6.27 (tokens de UI/TooltipSystem), HU-R6.38 (semántica de CRIT en skills), HU-R4 (stats de equipo), HU-R5.1 (bonos de talentos), `InventoryData.statsBreakdown`, `SKILLS_CATALOG`/`SkillConfig`
**No modifica:** fórmulas, valores, balance ni autoridad server-side de estadísticas; tampoco altera las mecánicas de las skills.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** entender qué efecto tiene cada estadística, de dónde vienen sus aumentos y qué hace cada habilidad,
**para** reconocer el aporte de mi build y entender la identidad y función de mis habilidades.

---

### Descripción / Contexto

El panel de personaje muestra el valor total autoritativo del servidor. El color del valor indica si ese total incluye una contribución positiva de equipo o talentos:

* **Verde `#70C08B`:** existe bonus positivo desde equipo o talentos.
* **Pergamino `#F4EDE0`:** la estadística no tiene un bonus positivo de equipo o talentos.

El color no se debe deducir únicamente de que el total sea mayor que cero. `MaxMP` puede recibir equipo/talento y debe poder verse verde; los efectos únicamente de consumibles no activan el verde. Para CDR, que no tiene aporte de equipo en los templates actuales, el verde indica el bonus de talento.

Además, cada tooltip de estadística debe explicar en lenguaje directo qué efecto tiene en el personaje y mostrar el desglose de sus aportes por origen y fuente identificable. Cada tooltip de habilidad debe incluir una descripción breve, coherente con su mecánica real y con una identidad propia; no basta con una frase genérica que podría aplicarse a cualquier skill.

**Criterio de hecho global:** el panel presenta el total autoritativo, el color cambia según el origen vigente, el tooltip permite entender cada stat y sus aportes, y cada skill explica su función real con copy distintivo y consistente.

---

### Especificaciones técnicas / Contratos de UI

#### Color según origen

* Leer `InventoryData.statsBreakdown[stat]` (o fuente autoritativa equivalente) para decidir el color y construir el desglose. Asegurar que incluya todos los orígenes activos que pueden modificar la estadística.
* Si hay un aporte positivo de equipo o talentos, pintar el valor total en verde. Un bono de set se identifica como tal y cuenta como origen de equipo si así está registrado en el cálculo autoritativo. Si no hay aportes positivos de esos orígenes, usar pergamino.
* No usar el valor base ni el total `> 0` como condición de verde. Un consumible/buff temporal por sí solo no activa el verde bajo esta HU.

#### Tooltips y desglose de estadísticas

* Todas las estadísticas visibles en el panel tienen tooltip explicativo: HP/MaxHP, MP/MaxMP, ATK, MATK, DEF, MDEF, CRIT y CDR (y cualquier estadística adicional que aparezca en el panel al implementarse).
* El tooltip explica en una frase clara **qué hace la estadística en el personaje**, sin limitarse a repetir su nombre o valor. Ejemplo de estilo: **CDR:** “Reduce el tiempo de reutilización de tus habilidades”. La definición debe coincidir con el comportamiento implementado.
* El desglose muestra el total y cada contribución positiva o negativa bajo su origen, con el nombre de la fuente cuando exista: base/progresión, cada pieza de equipo, bono de set, cada talento/rank, consumible, buff u otro modificador que realmente participe en el cálculo. Agrupar por origen sin perder la atribución a la fuente concreta.
* Los valores, unidades, signo y redondeo del desglose deben corresponder al cálculo real y permitir entender cómo se forma el total. No inventar aportes ni mostrar una suma engañosa cuando intervengan porcentajes, orden de aplicación o redondeos; en esos casos mostrar la operación/bonos por separado junto al total autoritativo.
* Si una fuente no aporta a una estadística, no mostrar una línea vacía o un origen ficticio. Los cambios de equipo/talento/buff/consumible y de personaje refrescan el tooltip y el desglose.

#### Copy de tooltips de estadísticas (texto para implementar)

| Estadística | Descripción visible |
|---|---|
| HP | Vida que te queda en este momento. Si llega a cero, caes en combate. |
| MaxHP | Cantidad máxima de vida que puede tener tu personaje. |
| MP | Maná que tienes disponible para usar habilidades. |
| MaxMP | Cantidad máxima de maná que puede tener tu personaje. |
| ATK | Aumenta el daño de tus ataques y habilidades que escalan con ATK. |
| MATK | Aumenta el daño, la curación o la absorción de escudos de habilidades que escalan con MATK. |
| DEF | Reduce el daño físico que recibes, según la fórmula de mitigación vigente. |
| MDEF | Reduce el daño mágico que recibes, según la fórmula de mitigación vigente. |
| CRIT | Aumenta la probabilidad de que cada impacto de daño elegible sea crítico. Un crítico inflige ×1,5 de daño. |
| CDR | Reduce el tiempo de reutilización de tus habilidades: cuanto mayor sea, antes podrás volver a usarlas. |

El texto de CRIT describe el comportamiento previsto al integrar R6.38; no se implementa la lógica de críticos dentro de R6.37.

#### Descripciones de habilidades

* Todas las skills disponibles tienen descripción en su tooltip, obtenida de `SkillConfig`/catálogo canónico y no de un texto genérico compartido.
* Cada descripción es breve (1–2 frases), en español claro y con identidad propia de la habilidad/clase. Debe comunicar su efecto práctico, objetivo/área y condición o duración cuando sea relevante, de acuerdo con la mecánica implementada.
* El texto no sustituye campos estructurados del tooltip (coste, cooldown, rango, daño/curación, duración); puede referenciarlos solo si mejora la comprensión. Los datos numéricos dinámicos siguen viniendo de la configuración vigente.
* No añadir fantasía como si fuera mecánica, prometer efectos que no existan, ni cambiar el funcionamiento para que coincida con el copy. Corregir descripciones genéricas o ambiguas para diferenciarlas entre sí sin inventar reglas.

#### Copy propuesto para las 30 skills del catálogo

Implementar estas descripciones en cada tooltip. Los campos de daño/cura, coste, cooldown, rango, duración y otros valores permanecen en sus filas estructuradas y deben leerse de la configuración vigente.

| ID | Skill | Descripción visible |
|---|---|---|
| `paladin_holy_strike` | Golpe sagrado | Concentra tu fuerza en un golpe sagrado contra un enemigo cercano. |
| `paladin_light_verdict` | Veredicto de luz | Descarga un veredicto de luz que golpea a un enemigo a distancia con poder mágico. |
| `paladin_prot_shield_bash` | Embate de escudo | Golpea a un enemigo cercano con tu escudo y atrae más su atención. |
| `paladin_prot_vow` | Voto protector | Una plegaria de protección restaura parte de tu propia salud. |
| `paladin_prot_sacred_wall` | Muro sagrado | Te protege con un escudo sagrado que absorbe el daño recibido mientras está activo. |
| `paladin_prot_consecration` | Consagración | Consagra una zona del suelo; sus pulsos dañan a los enemigos que están dentro, incluso a quienes entran después. Con el bono de 4 piezas de Protector, aumenta el alcance de la zona. |
| `paladin_ret_holy_edge` | Filo sagrado | Envuelve tu ataque en energía sagrada y corta a un enemigo cercano. |
| `paladin_ret_divine_flames` | Llamas divinas | Desata llamas divinas que estallan contra un enemigo cercano. |
| `paladin_ret_sentence` | Sentencia | Pronuncia una sentencia de luz que descarga un poderoso impacto mágico sobre un enemigo cercano. |
| `paladin_ret_holy_ring` | Anillo de luz sagrada | Libera un anillo de luz a tu alrededor que golpea a los enemigos cercanos. Con el bono de 4 piezas de Castigo, tus ataques básicos pueden reiniciar su cooldown. |
| `hunter_savage_cut` | Corte salvaje | Lanza un tajo feroz contra un enemigo cercano. |
| `hunter_piercing_shot` | Disparo perforante | Concentra un disparo potente en un enemigo a distancia. |
| `hunter_asm_ambush` | Emboscada | Sorprende a un enemigo cercano con un ataque rápido y contundente. |
| `hunter_asm_crimson` | Filo carmesí | Descarga un corte carmesí de gran potencia contra un enemigo cercano. Con el bono de 4 piezas de Asalto, parte del daño infligido te devuelve salud. |
| `hunter_asm_twin` | Cortes gemelos | Desata tu técnica de dos cortes rápidos contra un enemigo cercano. |
| `hunter_asm_whirlwind` | Torbellino | Gira con tu arma y golpea a los enemigos que te rodean. |
| `hunter_mm_venom` | Flecha venenosa | Envenena a un enemigo a distancia; el veneno le inflige daño repetido mientras dura el efecto. |
| `hunter_mm_trueshot` | Tiro certero | Alinea un disparo de precisión contra un enemigo a distancia. |
| `hunter_mm_chain` | Tiro en cadena | Lanza un disparo contra un enemigo; con el bono de 4 piezas de Puntería, alcanza también a un objetivo cercano al original. |
| `hunter_mm_death` | Disparo mortal | Concentra tu puntería en un disparo devastador contra un enemigo a distancia. |
| `cleric_smite` | Golpe de fe | Descarga un golpe de fe, reforzado por tu poder mágico, contra un enemigo cercano. |
| `cleric_burning_light` | Luz ardiente | Desata una ráfaga de luz ardiente contra un enemigo a distancia. |
| `cleric_hol_heal` | Sanación | Una sanación rápida restaura parte de tu propia salud. |
| `cleric_hol_word` | Palabra de luz | Pronuncia una palabra sagrada para restaurar una cantidad importante de tu salud. |
| `cleric_hol_shield` | Escudo de fe | Te protege con un escudo de fe que absorbe el daño recibido mientras está activo. |
| `cleric_hol_miracle` | Milagro | Invoca un milagro que restaura una gran cantidad de tu salud. Con el bono de 4 piezas de Misericordia, también cura a los aliados en un área centrada en el aliado seleccionado; si no hay un aliado válido, te cura a ti. |
| `cleric_wrath_spear` | Lanza de luz | Lanza una saeta de luz contra un enemigo a distancia. |
| `cleric_wrath_mark` | Marca de castigo | Descarga un impacto de castigo mágico sobre un enemigo a distancia. |
| `cleric_wrath_divine_ire` | Ira divina | Desata una zona de ira divina en el suelo; sus pulsos dañan repetidamente a los enemigos que la ocupan. |
| `cleric_wrath_annihilation` | Aniquilación | Descarga un impacto mágico devastador. Con el bono de 4 piezas de Cólera, aplica además daño periódico. |

**Reglas para los bonos condicionales:** mostrar las frases de mejora únicamente cuando el bono correspondiente esté activo; no presentarlas como efectos base de la skill. Esto aplica a Consagración, Anillo de luz sagrada, Filo carmesí, Tiro en cadena, Milagro y Aniquilación. Para Tiro en cadena, indicar que alcanza un objetivo adicional; para Consagración, el aumento de alcance; para Anillo, el reinicio de cooldown por ataques básicos; para Filo carmesí, la curación por parte del daño; para Milagro, la curación en área con el fallback indicado; para Aniquilación, el daño periódico adicional. Leer valores/condiciones variables de la configuración y el estado real del bono.

#### Valores y actualización

* No alterar el valor que se muestra: HP/MaxHP, MP/MaxMP, ATK, MATK, DEF, MDEF, CRIT y CDR siguen las conversiones y formatos actuales.
* Refrescar total, tooltip y desglose ante cambios en cualquiera de sus fuentes, cambio de personaje y respuesta nueva de `InventoryData`; actualizar el color con la regla de origen vigente y no dejar datos del personaje anterior.
* CDR se muestra verde solo cuando hay bonus positivo de talento; con `0 %`/sin bonus, pergamino. No inferir la fuente solo de un total distinto de cero si no existe breakdown de origen.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Solo valor base

* **GIVEN** un stat sin aportes positivos de equipo ni talentos
* **WHEN** se muestra el panel de personaje
* **THEN** el valor total usa pergamino, aunque el stat base sea mayor que cero

#### Escenario 2: Bonus de equipo

* **GIVEN** una pieza equipada que añade un stat
* **WHEN** llega el nuevo breakdown al panel
* **THEN** el total se conserva y se muestra verde

#### Escenario 3: Bonus de talento

* **GIVEN** un talento que añade un stat o CDR
* **WHEN** se aplica/recalcula el talento
* **THEN** el stat correspondiente se muestra verde; el resto conserva el color según sus propias fuentes

#### Escenario 4: Retirar el bonus

* **GIVEN** un stat mostrado en verde por equipo/talento
* **WHEN** se desequipa la fuente o se elimina el talento y llega el nuevo breakdown
* **THEN** el valor y su color se actualizan; si no quedan aportes, vuelve a pergamino

#### Escenario 5: Consumible solamente

* **GIVEN** un consumible modifica temporalmente un stat sin bonus de equipo/talento
* **WHEN** se presenta el panel
* **THEN** el color no se vuelve verde solo por el consumible

#### Escenario 6: Sin regresión

* **GIVEN** stats con distintos orígenes
* **WHEN** se prueba el panel en PC y móvil
* **THEN** los valores, desglose TooltipSystem, interacción y layout siguen funcionando sin errores rojos

#### Escenario 7: Descripción de cada estadística

* **GIVEN** cualquier estadística visible en el panel de personaje
* **WHEN** el jugador abre su tooltip
* **THEN** encuentra una explicación breve y correcta del efecto de esa estadística en el personaje

#### Escenario 8: Desglose por origen y fuente

* **GIVEN** una estadística recibe aportes de varias fuentes (por ejemplo, equipo, bono de set y talentos)
* **WHEN** el jugador abre el desglose
* **THEN** ve el total y las contribuciones atribuidas a cada origen y a cada fuente identificable, sin datos inventados ni una suma que contradiga el total

#### Escenario 9: Fuentes temporales

* **GIVEN** una estadística cambia por un consumible, buff u otro modificador temporal
* **WHEN** se abre o actualiza el tooltip
* **THEN** el aporte aparece bajo su origen si participa en el total, pero por sí solo no cambia la regla de color de equipo/talentos

#### Escenario 10: Descripción individual de skills

* **GIVEN** una skill disponible en el grimorio o barra
* **WHEN** el jugador abre su tooltip
* **THEN** ve una descripción concisa y diferenciada que refleja exactamente el efecto, objetivo/área y condición/duración relevantes de esa skill

#### Escenario 11: Copy alineado con mecánicas y configuración

* **GIVEN** una skill con valores o comportamiento definido en `SkillConfig`/`SKILLS_CATALOG`
* **WHEN** se muestra su descripción junto a los datos estructurados
* **THEN** el texto no contradice la configuración ni implica efectos no implementados; los valores variables se leen de la fuente de datos vigente

---

### Alcance

#### Incluye

* Color dinámico de valores de estadísticas según el desglose de equipo/talentos.
* Tooltips con explicación del efecto de todas las estadísticas visibles y breakdown por origen/fuente.
* Descripciones individuales para todas las skills en el tooltip, normalizadas en tono/estructura y fieles a su mecánica e identidad.
* Actualización de valores, colores y breakdown en respuesta a cambios de inventario, talentos, efectos temporales o personaje.
* QA de valores base, todas las fuentes relevantes, tooltips de stats y descripciones del catálogo completo de skills.

#### No incluye

* Cambiar fórmulas, hacer cálculos autoritativos en cliente o modificar el balance.
* Cambiar el diseño del panel más allá del contenido del tooltip/desglose y la semántica de color establecida en HU-ESTETICA-45.
* Cambiar mecánicas, coste, cooldown, targeting, balance o progresión de las habilidades.

---

### Definition of Done (DoD)

* [x] Base sin equipo/talentos = pergamino; bonus positivo de equipo/talentos = verde, conservando la regla para consumibles/buffs.
* [x] Todas las estadísticas visibles tienen una explicación clara de su efecto y un desglose completo por origen/fuente identificable.
* [x] Los valores mostrados en el desglose concuerdan con el cálculo y total autoritativos, incluidas unidades, porcentajes y redondeo.
* [x] Las 10 descripciones de stats de esta HU están integradas y concuerdan con las fórmulas vigentes (CRIT según R6.38).
* [x] Las 30 skills del catálogo tienen el copy especificado aquí; las menciones a mejoras de set aparecen solo cuando el bono correspondiente está activo.
* [x] Valores, colores, desglose y copy se refrescan correctamente al cambiar equipo, talentos, efectos temporales o PJ.
* [x] No se modifican fórmulas ni balance; pruebas PC/móvil de stats y catálogo de skills sin errores rojos.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-21 | HU creada para el follow-up PO de color de stats según fuentes de equipo/talentos en el panel de personaje. |
| 2026-10-22 | Ampliación PO: tooltips para explicar cada estadística y desglosar todos sus orígenes; descripción breve, distintiva y mecánicamente fiel para cada skill. Se conserva el alcance original de color y no se cambian fórmulas ni balance. |
| 2026-10-22 | Copy redactado para implementar: diez descripciones de stats y las treinta descripciones de skills; las mejoras de set de seis skills quedan condicionadas a que el bono correspondiente esté activo. |
| 2026-10-22 | HU cerrada por confirmación del PO: implementación completada. |
