# HU-VFX-02: Rediseño completo de VFX de habilidades de clase (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** VFX / Polish de clases
**Prioridad:** Alta
**Estado:** Borrador para RC del dev
**Tipo:** Rediseño visual de combate (dev)
**Fase GDD:** Polish de VFX para las 30 habilidades del catálogo MVP
**Depende de:** HU-VFX-01 (PoC exitosa: Anillo de luz sagrada), HU-R6.8/R6.9 (VFX base y AoE), HU-R8a/R8b/R8c (skills por clase), `SKILLS_CATALOG`, `VFXConfig`
**No modifica:** daño, curación, objetivos, alcance, radio, coste, cooldown, duración, ticks, amenaza, estados ni reglas de combate. Sin SFX nuevos.

---

### Narrativa (INVEST)

**Como** jugador,
**quiero** que cada habilidad se vea potente, clara y reconocible,
**para** sentir el impacto de mis acciones y distinguir las skills de mi clase en medio del combate.

**Como** equipo de desarrollo,
**quiero** extender a las 30 skills el estándar validado con Anillo de luz,
**para** reemplazar los efectos actuales, demasiado simples, por una presentación coherente, espectacular, legible y eficiente.

---

### Descripción / Contexto

La PoC HU-VFX-01 mejoró con éxito el VFX del Anillo de luz sagrada del Paladín. El PO reporta que el resultado elevó notablemente el impacto visual de la habilidad y quiere extender una mejora de esa magnitud a todas las habilidades.

El rediseño debe combinar una gramática visual compartida por tipo de efecto con una silueta, color y motivo propios para cada habilidad. No se busca poner más partículas indiscriminadamente: cada cast debe comunicar preparación, trayectoria o zona, impacto y duración cuando aplique, sin ocultar telegraphs, objetivos, barras de vida ni lectura del combate.

**Criterio de hecho global:** las 30 habilidades de `SKILLS_CATALOG` tienen VFX renovados, identificables por clase/spec y por mecánica, con impacto visual muy superior al actual, efectos coherentes con el radio/duración reales, rendimiento estable en PC y móvil y ninguna modificación del gameplay.

---

### Dirección visual general

#### Gramática común por tipo de habilidad

* **Instant melee:** preparación breve en arma/brazo → arco o rastro de golpe → destello de impacto localizado en el objetivo. El impacto debe leerse claramente sin simular golpes adicionales.
* **Instant ranged/proyectil:** señal de lanzamiento en el caster/arma → proyectil con trail legible → impacto con flash, chispas o fragmentos temáticos en el objetivo. El trayecto no debe ocultar la trayectoria de otras skills.
* **SelfAoE:** destello de origen en el caster → onda/ring expandiéndose desde su posición → impactos breves sobre cada enemigo afectado. La onda respeta el radio de gameplay y no se queda como zona activa.
* **GroundAoE persistente:** telegraph de pre-cast existente permanece bajo R6.13; tras el cast aparece la zona activa con borde y textura propios de la skill. Cada tick produce un pulso breve sincronizado, no una explosión completa repetida. El área visual sigue el radio/duración reales.
* **DoT:** impacto de aplicación claramente distinguible → marca/aura pequeña que sigue al objetivo → pulso tenue por tick y desvanecimiento al expirar. No debe parecer una nueva zona GroundAoE.
* **Heal:** luz cálida ascendente o pulso que converge al receptor; color/composición claramente distintos del daño.
* **Shield:** formación visible alrededor del protegido y material estable mientras dura; si se visualiza absorción, usar una respuesta corta al recibir daño, sin crear una nueva regla de gameplay.

#### Identidad de clase/spec

* **Paladín Protector:** oro/blanco, sellos geométricos, runas y formas sólidas de defensa; fuerte sensación de impacto y protección.
* **Paladín Castigo:** oro/blanco más brasas cálidas; cortes sagrados, círculos radiantes y ráfagas ofensivas.
* **Cazador Asalto:** ámbar/rojo cuero y metal, trazos rápidos, cortes angulares y movimiento circular; el VFX acompaña el combate cercano.
* **Cazador Puntería:** verde veneno para DoT y tonos ámbar/acero para disparos; líneas finas, trayectorias precisas y rebotes visibles solo cuando haya un segundo objetivo real.
* **Clérigo Misericordia:** blanco, jade/verde suave y oro tenue; formas redondeadas, partículas ascendentes y lectura reconfortante de sanación/protección.
* **Clérigo Cólera:** blanco frío, violeta y azul profundo; runas de juicio, rayos concentrados y zonas arcanas persistentes.
* Mantener paletas y siluetas consistentes dentro de cada spec, pero dar a cada skill un motivo o combinación de fases propia; no reutilizar el mismo VFX cambiando solo el color.

---

### Propuesta de VFX por habilidad

Los conceptos siguientes son la dirección visual concreta de implementación. El dev puede ajustar geometría, timing, textura y composición durante el RC/QA, conservando la identidad, legibilidad y contratos funcionales aquí definidos.

| ID | Skill | Propuesta de VFX renovado |
|---|---|---|
| `paladin_holy_strike` | Golpe sagrado | Un filo dorado se enciende sobre el arma y deja un arco corto de luz; al impactar, aparece una cruz/sello pequeño que se fragmenta en motas blancas. |
| `paladin_light_verdict` | Veredicto de luz | Un sigilo de juicio se forma brevemente frente al Paladín y dispara una descarga lineal de luz hacia el objetivo; impacto con destello radial compacto. |
| `paladin_prot_shield_bash` | Embate de escudo | El borde del escudo se ilumina y avanza con una estela frontal; el impacto genera una onda corta con forma de escudo y un flash dorado sobre el enemigo. |
| `paladin_prot_vow` | Voto protector | Un sello protector aparece bajo el Paladín; un aro cálido asciende desde los pies y converge en el torso al aplicarse la curación. |
| `paladin_prot_sacred_wall` | Muro sagrado | Placas geométricas de luz ensamblan un escudo alrededor del Paladín; queda un contorno rúnico tenue mientras la protección siga activa y se disipa al terminar. |
| `paladin_prot_consecration` | Consagración | La zona se abre como un sello circular grabado en el suelo; cada tick activa runas y un pilar de luz breve bajo los enemigos dentro. Con el bono de 4 piezas, el borde se expande al alcance efectivo ampliado. |
| `paladin_ret_holy_edge` | Filo sagrado | El arma traza una media luna blanco-dorada; el impacto deja una línea luminosa que se apaga desde el centro hacia los extremos. |
| `paladin_ret_divine_flames` | Llamas divinas | Llamas doradas se reúnen alrededor del arma/mano y estallan en una llamarada compacta al alcanzar al objetivo; el fuego desaparece inmediatamente, sin indicar DoT. |
| `paladin_ret_sentence` | Sentencia | Un sello de juicio aparece sobre el objetivo y cae una columna de luz concentrada; cierre con fractura radial dorada y fragmentos que se desvanecen. |
| `paladin_ret_holy_ring` | Anillo de luz sagrada | Conservar y extender el lenguaje validado por HU-VFX-01: destello central, anillo expansivo blanco-dorado a radio real, impactos localizados en enemigos y partículas de salida. Cuando un básico reinicia su cooldown por el bono de 4 piezas, mostrar un destello/sello breve de disponibilidad, no otro estallido de daño. |
| `hunter_savage_cut` | Corte salvaje | Un tajo rápido color acero/ámbar cruza el objetivo; el impacto deja dos chispas angulares y una estela corta de movimiento. |
| `hunter_piercing_shot` | Disparo perforante | El arco se tensa con un brillo compacto; una flecha con trail fino atraviesa visualmente el espacio hacia el objetivo y produce una marca de impacto penetrante, sin sugerir que golpea objetivos adicionales. |
| `hunter_asm_ambush` | Emboscada | El Cazador realiza un amague/entrada rápida enfatizada por una estela baja; el golpe termina con un flash rojo-ámbar concentrado. Sin teletransporte ni invisibilidad nuevos. |
| `hunter_asm_crimson` | Filo carmesí | Un corte carmesí amplio deja una estela roja que se rompe en fragmentos al impactar. Con lifesteal activo, un hilo verde tenue devuelve la curación al Cazador; no duplicar el número de daño. |
| `hunter_asm_twin` | Cortes gemelos | Dos arcos cruzados, uno tras otro, con distinto ángulo y color acero/ámbar; deben leerse como una misma activación y no generar impactos o números de daño extra. |
| `hunter_asm_whirlwind` | Torbellino | El Cazador gira dentro de una espiral baja de trazos de arma; un anillo de impacto recorre su radio real y destellos separados marcan a cada enemigo alcanzado. |
| `hunter_mm_venom` | Flecha venenosa | Flecha verde ácida con trail de partículas finas; al impactar deja una marca pequeña en el objetivo y un pulso verde oscuro por tick. La marca sigue al objetivo, no se convierte en una zona de suelo. |
| `hunter_mm_trueshot` | Tiro certero | Línea de apuntado/energía breve y estable en el eje del disparo; la flecha deja un trail estrecho y el impacto produce un destello ámbar nítido en un único objetivo. |
| `hunter_mm_chain` | Tiro en cadena | El disparo inicial impacta con un marcador ámbar; con el bono de 4 piezas, un arco/ricochet visible salta al objetivo adicional real y termina en un segundo destello más pequeño. |
| `hunter_mm_death` | Disparo mortal | El arco concentra energía en la punta de la flecha con un pulso de tensión; release de alta velocidad con trail brillante y un impacto más potente, enmarcado por fragmentos que se alejan del objetivo. |
| `cleric_smite` | Golpe de fe | Un impacto blanco-dorado con forma de sello de fe se forma en el enemigo; destello breve y motas ascendentes, distinto de los impactos de luz a distancia. |
| `cleric_burning_light` | Luz ardiente | Una esfera/descarga de luz cálida se comprime en las manos y viaja al enemigo; al llegar, florece en una llamarada clara que se disipa sin dejar DoT. |
| `cleric_hol_heal` | Sanación | Un pulso jade suave rodea al Clérigo y se eleva hacia su cuerpo; el cierre es una pequeña floración de luz, breve y claramente identificable como curación. |
| `cleric_hol_word` | Palabra de luz | Un glifo de luz se abre frente al Clérigo y sus partículas convergen en el receptor; el pulso final es más amplio/intenso que Sanación, sin tapar el modelo. |
| `cleric_hol_shield` | Escudo de fe | Un sello jade-blanco sube desde el suelo y se cierra como una barrera hexagonal translúcida alrededor del Clérigo; permanece tenue mientras dure y se disuelve al expirar. |
| `cleric_hol_miracle` | Milagro | Una columna suave de luz cae sobre el receptor y libera anillos de sanación. Con el bono de 4 piezas, los anillos abarcan el área real centrada en el aliado seleccionado (o en el Clérigo con el fallback vigente). |
| `cleric_wrath_spear` | Lanza de luz | Una lanza de energía blanca-violeta se materializa frente al Clérigo, cruza el espacio con trail cristalino y se quiebra en fragmentos luminosos al impactar. |
| `cleric_wrath_mark` | Marca de castigo | Un glifo violeta de juicio se cierra brevemente sobre el objetivo y detona en un rayo/flash concentrado; no dejar una marca persistente que sugiera un debuff. |
| `cleric_wrath_divine_ire` | Ira divina | Una zona violeta-azul se dibuja en el suelo con runas angulares; cada tick pulsa desde el centro hacia el borde y golpea visualmente solo a enemigos afectados. Telegraph/pre-cast permanece bajo R6.13. |
| `cleric_wrath_annihilation` | Aniquilación | Un sello de cólera violeta se comprime y estalla sobre un único objetivo. Con el bono de 4 piezas, después del impacto queda una marca de DoT pequeña con pulsos periódicos hasta expirar. |

---

### Especificaciones técnicas / Contratos

* Implementar los efectos **client-side, data-driven por `skillId`**, reutilizando el patrón/estructura que dejó HU-VFX-01. El servidor mantiene autoridad sobre cast válido, objetivos, impacto, daño, curación y activación del bono; los clientes solo presentan el evento confirmado.
* Componer los efectos con las herramientas permitidas: `ParticleEmitter`, `Beam`, `Trail`, `Attachment` y Tween de color/tamaño/transparencia/velocidad/duración. Preferir emisores efímeros, sin generar geometría persistente innecesaria.
* Un VFX debe usar el centro, trayectoria, radio y receptor reales del evento de gameplay; no presentar daño a un objetivo que no fue afectado ni proyectar una zona distinta de la real.
* Las mejoras de bono de set se activan solo ante el evento/estado real del bono. Los VFX de Tiro en cadena, Filo carmesí, Anillo de luz, Consagración, Milagro y Aniquilación no deben sugerir el efecto condicional cuando el bono está inactivo.
* Mantener los telegraphs y pre-casts actuales de R6.13/R6.18/R7.1; no confundir pre-cast, impacto, zona persistente, DoT, cura o escudo.
* Asegurar limpieza al completar, interrumpir, destruir el objetivo, abandonar la zona o hacer respawn. Los loops de GroundAoE/DoT terminan exactamente con la duración autoritativa.
* Evitar instancias/tweens/conexiones huérfanas, acumulación de partículas y raycasts por frame; efectos concurrentes deben respetar límites configurables.
* Escalar automáticamente emisión y detalle en móvil y escenas con varios jugadores. Los colores no son el único indicador: la forma y timing deben diferenciar daño, curación y protección.
* No crear SFX nuevos ni reemplazar los existentes en esta HU; sincronizar visuales con los eventos actuales y conservar audio sin cambios.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: VFX completo por skill

* **GIVEN** cualquiera de las 30 skills del catálogo
* **WHEN** se ejecuta de manera válida
* **THEN** presenta una secuencia VFX renovada, reconocible y propia según la tabla de esta HU, con lanzamiento/trayectoria/impacto/zona según aplique

#### Escenario 2: Respeto de mecánicas

* **GIVEN** un VFX nuevo
* **WHEN** la skill se lanza, falla, golpea, cura o termina
* **THEN** daño, curación, objetivo, radio, alcance, coste, cooldown, threat, duración y frecuencia de ticks permanecen idénticos a los valores autoritativos

#### Escenario 3: SelfAoE y GroundAoE

* **GIVEN** una habilidad SelfAoE o GroundAoE activa
* **WHEN** se representa su efecto
* **THEN** el centro, radio y duración coinciden con gameplay; SelfAoE no deja zona persistente y GroundAoE conserva el pre-cast actual y muestra pulsos por tick sin repetir una explosión completa

#### Escenario 4: Heal, Shield y DoT distinguibles

* **GIVEN** skills de curación, escudo, daño instantáneo o daño periódico
* **WHEN** se observan simultáneamente en combate
* **THEN** silueta, ritmo y paleta permiten distinguir cura/protección de daño, y DoT de GroundAoE

#### Escenario 5: Mejoras por bono de set

* **GIVEN** una de las skills con mejora de set de la HU
* **WHEN** el bono está activo y se dispara su efecto
* **THEN** aparece la capa visual correspondiente a su mejora real; si el bono no está activo, esa capa no aparece

#### Escenario 6: Legibilidad y convivencia

* **GIVEN** telegraphs, nameplates, barras de vida y VFX de varias skills en una pelea
* **WHEN** se juega en solo o party
* **THEN** se pueden identificar peligro, objetivo y resultado de cada habilidad; los VFX no tapan telegraphs ni información de combate

#### Escenario 7: Party y móvil

* **GIVEN** cuatro jugadores usan skills en una pelea con varios enemigos
* **WHEN** se juega en PC y móvil
* **THEN** los efectos siguen siendo visibles, la emisión se degrada de forma controlada si hace falta y no hay caída notable de rendimiento

#### Escenario 8: Limpieza y regresión

* **GIVEN** efectos instantáneos, zonas, DoT, respawn, muerte/interrupción o salida del área
* **WHEN** concluye su duración o desaparece su fuente
* **THEN** los efectos, conexiones e instancias temporales se limpian; no quedan loops ni errores rojos

---

### Alcance

#### Incluye

* Rediseñar los VFX de las 30 skills de `SKILLS_CATALOG` con implementación concreta según la tabla.
* Preparación/cast, proyectil/trayectoria cuando aplique, impacto, SelfAoE, GroundAoE, DoT, heal y shield.
* VFX condicionados a las seis mejoras de skill por bono de set, solo cuando el efecto real se activa.
* Mantener el VFX exitoso de Anillo de luz como referencia y elevar/armonizar el resto para que tenga igual cuidado visual, no necesariamente la misma composición.
* QA en PC, móvil, solo y party con telegraphs/UI presentes.

#### No incluye

* Cambios al sistema de combate, números, condiciones de impacto, animaciones o reglas de set.
* Rediseño de VFX de enemigos/bosses, HUD, números de daño, precasts ni death effects globales.
* Creación o sustitución de SFX.
* Crear/riggear animaciones de personajes ni depender de assets externos de pago.

---

### Definition of Done (DoD)

* [ ] Cada una de las 30 skills tiene el VFX de identidad definido en la tabla y está enlazada por `skillId`.
* [ ] Cada tipo (Instant melee, Instant ranged, SelfAoE, GroundAoE, DoT, Heal, Shield) tiene lanzamiento/trayectoria/impacto/zona adecuados.
* [ ] Las seis mejoras por bono de set se visualizan solo al activarse y no agregan impactos o feedback de gameplay ficticios.
* [ ] El Anillo de luz conserva la PoC exitosa como referencia de calidad y no pierde su radio/lectura/sincronía.
* [ ] VFX sigue el centro, objetivos, radio y duración reales; no cambia gameplay ni tapa telegraphs/nameplates/barras.
* [ ] QA de las 30 skills en PC y móvil, solo y party; performance estable con hasta cuatro jugadores y varios efectos concurrentes.
* [ ] Efectos temporales y conexiones se limpian correctamente; sin fugas, loops huérfanos ni errores rojos.
* [ ] Reporte de implementación incluye capturas/video de cada clase/spec y evidencia de performance/legibilidad.
* [ ] Nota en GDD tras cierre de QA.

---

### Estimación orientativa

Trabajo grande, recomendado en entregas por clase (10 skills por clase), con un checkpoint de legibilidad/performance después del primer bloque y regresión integrada al final.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-22 | HU global creada tras el éxito reportado de HU-VFX-01; abarca las 30 skills y propone una firma visual por habilidad con estándares compartidos por tipo. |
