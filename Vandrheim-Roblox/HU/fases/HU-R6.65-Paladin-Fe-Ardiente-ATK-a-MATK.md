# HU-R6.65: Paladín Castigo — Fe ardiente, alas de valquiria y conversión ATK→MATK (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Combate / Balance de clases — Paladín
**Prioridad:** Alta — Castigo es el DPS más débil de las cuatro specs de daño
**Estado:** Lista para RC
**Tipo:** Ajuste de mecánica y balance (dev)
**Fase GDD:** Combate / skills (corrección sobre R8a y R8d)
**Depende de:** HU-R3 (framework de skills), HU-R5.1 (especialización de talentos activa), HU-R8a (Paladín), HU-R8d (bandas de balance), HU-R6.38 (crítico en habilidades), HU-R6.46 (estado actual de skills del Paladín), HU-R6.37 (tooltip y desglose de stats), HU-VFX-02 (lenguaje visual y presupuesto de partículas), `ClassConfig`, `SkillConfig`, `TalentConfig`, `ItemConfig`
**No modifica:** daño base de las skills, coeficientes, costes de maná, cooldowns, rangos, crítico, mitigación DEF/MDEF, equipo, talentos ni la economía.

---

### Narrativa (INVEST)

**Como** jugador de Paladín Castigo,
**quiero** que mis habilidades mágicas aprovechen el ATK que ya acumulo con mi equipo y talentos,
**para** que la spec deje de ser la opción de DPS más débil y tenga una rotación con identidad propia.

**Como** equipo,
**quiero** una conversión acotada de ATK a MATK mediante una mecánica de acumulación,
**para** corregir el balance sin reescribir las fórmulas de daño ni regalar estadísticas permanentes.

---

### Descripción / Contexto

El kit del Paladín Castigo es híbrido: **Golpe sagrado** y **Filo sagrado** escalan con ATK; **Veredicto de luz**, **Llamas divinas**, **Sentencia** y **Anillo de luz sagrada** escalan con MATK. El problema no es que todas las skills escalen MATK, sino que **el grueso del burst y del daño de área escala MATK**, mientras el equipo, las armas de dos manos y los talentos favorecen ATK.

Los valores reales de `ClassConfig` confirman la brecha a nivel 20: el Paladín tiene **ATK base 50** y **MATK base 29**. El reporte del PO sobre una build prácticamente completa confirma que el problema es mayor de lo estimado inicialmente: **192 ATK y 50 MATK**. Con esa relación, las skills de MATK parten de una estadística muy baja y sus coeficientes no compensan la diferencia frente a los ataques básicos y las skills de ATK. El 8% por carga planteado en el primer borrador solo aportaba ~46 MATK y un aumento de DPS cercano al 9%, insuficiente para una brecha de esta magnitud.

La propuesta es que **Golpe sagrado** (`paladin_holy_strike`, básica compartida por Protector y Castigo) acumule **Fe ardiente** en tres impactos. Al completar la tercera carga, el Paladín se potencia: durante **15 s**, sus efectos que escalan con MATK reciben una conversión del ATK final, y le brotan **alas de luz de valquiria** como señal visible del estado. Cada Golpe sagrado posterior renueva esos 15 s, de modo que el buff puede mantenerse indefinidamente mientras el jugador siga conectando la habilidad. La mejora solo existe si el personaje tiene una **especialización de talentos activa** (Protector o Castigo); sin spec, Golpe sagrado no acumula Fe ardiente.

**Criterio de hecho global:** con la spec activa y Fe ardiente en su tercera carga, las skills de MATK del Paladín reciben un aumento de daño/curación/escudo basado en su ATK, el personaje muestra alas de luz y el estado puede renovarse con Golpe sagrado cada 15 s; sin spec, sin tercera carga o tras expirar, no hay conversión ni alas. Protector obtiene un beneficio menor y controlado; el resto de clases y el daño de las skills de ATK no cambian.

---

### Objetivo de balance

* **Castigo:** pasar de la peor spec de DPS a una posición competitiva, apuntando a **0.95-1.05×** del promedio de Asalto, Puntería y Cólera con build equivalente a nivel 20, sin superar **1.10×**.
* **Protector:** mantener su rol de tanque. El daño puede subir hasta **10-15%** y la curación/absorción hasta **35%** con Fe ardiente activa; la supervivencia base no cambia y no debe volverse inmortal en contenido actual.
* **Ninguna spec** debe matar al jefe del piso 5 en menos de 45 s con build completa (regla R8d).
* La mejora debe ser relevante a nivel 20 y casi despreciable a niveles bajos, para no distorsionar el early game.
* **Sostenibilidad:** como el buff puede mantenerse de forma indefinida con Golpe sagrado cada ≤15 s, el QA debe medir DPS sostenido de 120 s, no solo el burst de la activación. Si Castigo supera 1.10× del promedio, bajar la conversión al mínimo de la banda.

---

### Diseño propuesto: Fe ardiente

#### 1. Obtención, desbloqueo y acumulación

* **Requisito de desbloqueo:** el personaje debe tener una **especialización de talentos activa**, Protector o Castigo. Se usa la fuente autoritativa existente de R5.1/R5 (`spec` o `activeSpec`); no se infiere de los puntos invertidos ni de las skills en la barra. Sin spec activa, Golpe sagrado funciona normal pero **no acumula Fe ardiente**.
* Solo el Paladín con spec activa puede acumular, y solo mediante **Golpe sagrado** (`paladin_holy_strike`).
* Cada Golpe sagrado que **impacta a un enemigo válido** otorga **1 carga**.
* Las cargas 1 y 2 son de preparación: muestran pips en el HUD, pero **no otorgan conversión ni alas**.
* La **tercera carga activa Fe ardiente**: aparece el buff, se aplica la conversión y se despliegan las alas durante 15 s.
* Al impactar con el buff ya activo, no se agrega una cuarta carga: se **renueva la duración** a 15 s.
* El daño del tercer Golpe sagrado que activa el buff se resuelve **antes** de la activación, para que ese impacto no se beneficie de la conversión. Los Golpes sagrados posteriores que renuevan sí se resuelven con el buff vigente.
* Un lanzamiento rechazado por rango, objetivo inválido, falta de maná o cooldown no otorga carga. Si el golpe no llega a aplicarse, tampoco.
* No se obtienen cargas por ataques básicos, otras skills, ítems ni por acciones de otros jugadores.

#### 2. Duración y mantenimiento

* **Duración: 15 s** desde la activación (tercer impacto) o desde la última renovación.
* Cada Golpe sagrado que impacta mientras Fe ardiente está activa renueva la duración a **15 s**.
* **Mantenimiento indefinido:** si el jugador vuelve a conectar Golpe sagrado antes de que expire, el buff y las alas se mantienen sin límite de renovaciones. No hay un máximo de tiempo acumulable; el reloj siempre vuelve a 15 s.
* Si pasan 15 s sin un nuevo Golpe sagrado, el buff termina: se pierden las **3 cargas**, la conversión se desactiva y las alas se desvanecen. Para volver a activarlo hay que acumular 3 cargas desde cero.
* Las cargas no se consumen al lanzar skills de MATK: son un estado del Paladín, no cargas de uso.
* Se puede pre-acumular antes de entrar en combate si hay un enemigo válido para los tres impactos; sin objetivo no se puede renovar y el buff expira.
* Cambiar de spec, morir, salir de la dungeon o desconectarse termina el estado; no se conserva entre contextos.

#### 3. Conversión ATK a MATK

La conversión solo existe mientras **Fe ardiente está activa** (3 cargas):

```text
MATK efectivo = MATK final + (ATK final × factorActivo)

factorActivo = 0.75 en Castigo  -- 3 cargas × 25% por carga
factorActivo = 0.15 en Protector -- 3 cargas × 5% por carga
```

El factor activo se calcula como `perStack × activationStacks`. Con los defaults, Castigo usa 0.75 y Protector 0.15; no se debe aplicar solo el valor por carga.

Donde:

* `MATK final` ya incluye base, equipo, talentos y buffs permanentes, con sus multiplicadores aplicados.
* `ATK final` incluye base, equipo, talentos, afinidad de arma y buffs temporales de ATK.
* La conversión se suma **después** de los multiplicadores de MATK. Así, un multiplicador de MATK no multiplica también la parte convertida desde ATK y se evita el doble beneficio.
* El factor por spec existe porque Castigo necesita competir como DPS y Protector no debe duplicar su sostenibilidad: con el mismo estado activo, Castigo canaliza la Fe hacia el daño y Protector hacia una mejora defensiva más contenida.
* Las cargas 1 y 2 no otorgan conversión. La fórmula se aplica únicamente cuando el buff está activo con 3 cargas.
* La conversión **no** modifica el ATK, el daño de ataques básicos, las skills que escalan con ATK ni las estadísticas persistentes del perfil.
* La conversión aplica a **todo efecto del Paladín que use MATK**: daño, curación y absorción de escudo. Esto incluye Voto protector, Muro sagrado y Consagración en Protector, y Veredicto de luz, Llamas divinas, Sentencia y Anillo de luz sagrada en Castigo.
* No aplica a pociones, curación por porcentaje, daño físico, DoT de otras clases ni efectos planos como el daño extra de FrostTouch.

#### 4. Porcentaje recomendado

**Recomendación revisada con la build real (192 ATK / 50 MATK):**

* **Castigo: 25% del ATK por carga; 75% con 3 cargas.**
* **Protector: 5% del ATK por carga; 15% con 3 cargas.**

El 25% parece alto en abstracto, pero es la consecuencia de que el Paladín tenga 50 de MATK frente a 192 de ATK. Lo que importa es el MATK efectivo resultante y el daño por skill.

**Castigo con Fe ardiente activa (25% por carga):**

| Concepto | Sin buff | Con Fe ardiente activa |
|---|---:|---:|
| ATK final | 192 | 192 |
| MATK efectivo | 50 | 194 |
| Veredicto de luz (15 + 1.1×MATK) | 70 | 228 |
| Llamas divinas (16 + 1.2×MATK) | 76 | 249 |
| Sentencia (24 + 1.3×MATK) | 89 | 276 |
| Anillo de luz sagrada (35 + 1.8×MATK) | 125 | 384 |
| Filo sagrado (14 + 1.1×ATK, sin cambio) | 225 | 225 |
| Golpe sagrado (12 + 1.0×ATK, sin cambio) | 204 | 204 |

Comparación por cooldown, sin contar crítico:

| Skill | DPS sin buff | DPS con Fe ardiente activa |
|---|---:|---:|
| Llamas divinas (CD 6) | 12,7 | 41,5 |
| Sentencia (CD 8) | 11,1 | 34,5 |
| Anillo de luz sagrada (CD 10) | 12,5 | 38,4 |
| **Total skills MATK** | **36,3** | **114,4** |

Las skills de MATK pasan de aportar ~36 DPS a ~114 DPS: **+78 DPS** sobre un DPS total estimado de ~260, es decir, **~30% más**. Eso es lo que hace falta para que Castigo deje de perder "enormemente" contra Cazador y Clérigo. Con 3 cargas, sus nukes mágicos quedan en el rango de Filo sagrado (225) o por encima en el caso del Anillo (384, AoE con CD 10), pero su DPS por cooldown sigue por debajo de Golpe sagrado (51); las skills de ATK no quedan obsoletas.

**Protector con Fe ardiente activa (5% por carga):**

| Concepto | Sin buff | Con Fe ardiente activa (ATK ~130) |
|---|---:|---:|
| MATK efectivo | 50 | ~69,5 |
| Voto protector (30 + 1.7×MATK) | ~115 | ~148 |
| Muro sagrado (30 + 1.5×MATK) | ~105 | ~134 |
| Consagración por tick (3.8 + 0.27×MATK) | ~17,3 | ~22,6 |

El beneficio defensivo ronda **+28-33%** en cura/absorción y **+30%** en el daño de Consagración. Es tangible, pero no convierte al tanque en inmortal y mantiene el coste de sostener tres Golpes sagrados.

**Bandas de ajuste autorizadas en QA:**

* Castigo: **22-28%** por carga. Si con 28% sigue por debajo de 0.90× del promedio, el problema está en los coeficientes o en el equipo; no seguir subiendo la conversión.
* Protector: **4-7%** por carga. Si la supervivencia se sale de la banda, bajar a 4% antes de tocar las curas base.

#### 5. Configuración

```lua
PaladinFervor = {
    activationStacks = 3,
    maxStacks = 3,
    duration = 15,
    requiresActiveSpec = true,
    castigoAtkToMatkPerStack = 0.25, -- factor activo = 0.75 con 3 cargas
    protectorAtkToMatkPerStack = 0.05, -- factor activo = 0.15 con 3 cargas
    castigoQaRange = { min = 0.22, max = 0.28 },
    protectorQaRange = { min = 0.04, max = 0.07 },
    wingVfx = "paladin_fervor_wings",
}
```

La fuente de verdad es la configuración del servidor. El cliente solo presenta el estado replicado.

#### 6. Estados y ciclo de vida

* **Sin spec activa:** Golpe sagrado no acumula; no hay chip de Fe ardiente, alas ni conversión. El resto de la skill funciona normal.
* **Spec activa, 0 cargas:** sin estados; chip oculto.
* **Spec activa, cargas 1-2:** chip con 1-2 pips; sin alas y sin conversión. Es preparación, no potencia.
* **Tercera carga:** activación de Fe ardiente; aparecen las alas, se aplica la conversión y comienza el temporizador de 15 s. El chip pasa a estado activo 3/3.
* **Renovación:** cada Golpe sagrado que impacta mientras el buff está activo reinicia el temporizador a 15 s y produce un pulso breve en las alas; no vuelve a desplegarlas desde cero.
* **Expiración:** se pierden las 3 cargas, la conversión y las alas se desvanecen; el chip vuelve a oculto.
* **Muerte, respawn, cambio de personaje, cambio de spec/respec, salida de la dungeon, teleport entre places o desconexión:** se limpian todas las cargas, el buff, las alas y el estado temporal.
* **Cambio de equipo o de stats durante el buff:** la conversión se recalcula con el ATK/MATK vigentes en el siguiente efecto; no se guarda un snapshot viejo.

#### 7. Interacciones

* **Crítico (R6.38):** la tirada de crítico se aplica al daño ya buffeado; el multiplicador ×1,5 no se aplica dos veces. La conversión no cambia la probabilidad de crítico.
* **Talento Ardor sagrado / multiplicadores de MATK:** se aplican antes de la conversión; la parte convertida desde ATK no recibe un segundo multiplicador de MATK.
* **Talento Fervor / afinidad de arma / set Helada:** aumentan el ATK final y, por tanto, aumentan la conversión de forma natural. Es la sinergia buscada con la build de ATK.
* **Especialización activa:** sin Protector o Castigo elegida, Golpe sagrado no acumula cargas. Al elegir spec, la mecánica se habilita; al hacer respec o cambiar de spec, se limpian cargas, buff y alas.
* **Bono de 4 piezas de Castigo:** el reinicio del cooldown del Anillo de luz sagrada no otorga cargas ni renueva Fe ardiente; solo afecta al cooldown de la skill.
* **Renovación:** solo Golpe sagrado renueva el buff. Otras skills, ataques básicos, ítems o acciones de aliados no reinician los 15 s.
* **Protector:** el taunt de Embate de escudo no otorga cargas ni renueva; Voto y Muro se benefician de la conversión porque escalan con MATK.
* **Otras clases:** no pueden obtener ni recibir Fe ardiente; sus stats, daño y VFX no cambian.
* **Multijugador:** el buff es por personaje y por caster; no se comparte con la party ni se transfiere por trade. Las alas se replican a los demás clientes para que la party vea el estado, pero no otorgan ningún efecto a otros jugadores.

---

### Presentación y UI

* Añadir un chip compacto de estado en el HUD del jugador (junto al `PlayerFrame`):
  * Icono: reutilizar el icono de Golpe sagrado (`Icon_Skill_paladin_holy_strike`), sin generar un asset nuevo.
  * Sin spec activa: el chip no existe.
  * Con spec y 0 cargas: chip oculto, sin hueco fantasma.
  * Con 1-2 cargas: chip visible con pips `1/3` o `2/3`, sin alas.
  * Con Fe ardiente activa: chip en estado dorado `3/3`, contador de 15 s y tooltip con la conversión vigente.
  * Tooltip o long-press: nombre **Fe ardiente**, bonificación actual de MATK, porcentaje por carga de la spec activa y tiempo restante; indicar que se renueva con Golpe sagrado.
* El panel de personaje (R6.37) muestra el MATK efectivo mientras el buff está activo y añade una línea de desglose **Fe ardiente +X**. Esa línea es temporal: no debe pintar el stat de verde ni contarse como bonus permanente de equipo/talentos.
* El icono de la skill Golpe sagrado puede mostrar el contador de cargas como refuerzo, pero el chip del HUD es la fuente principal.
* Layout con `Scale`, `UIAspectRatioConstraint` y `UISizeConstraint`; sin `Offset` rígido. Debe funcionar en PC y móvil y no tapar la barra de habilidades, el minimapa ni los frames de party.

#### Alas de luz de valquiria

* **VFX de estado, no de casteo:** las alas aparecen al activar la tercera carga y permanecen mientras Fe ardiente esté activa; no se muestran con 1-2 cargas ni sin spec.
* **Diseño:** dos alas de luz estilizadas, compuestas por plumas luminosas (partes/Beams/ParticleEmitters). Deben leerse como alas de valquiria, no como un aura genérica. Sin malla externa nueva si el dev puede resolverlas con geometría ligera y partículas.
* **Paleta por spec:** Protector en marfil/oro cálido con plumas más anchas y sensación de escudo; Castigo en blanco-oro con plumas más afiladas y brasas tenues en los bordes. La silueta y el color deben distinguir la spec sin romper la identidad sagrada del Paladín.
* **Activación:** despliegue breve con destello dorado y pulso de luz; sin screen shake ni flash que tape el combate.
* **Renovación:** pulso suave que recorre las alas y confirma que los 15 s se reiniciaron; no volver a desplegarlas desde cero.
* **Expiración:** desvanecimiento en motas de luz; no cortar en seco.
* **Anclaje:** unidas a la espalda/`UpperTorso` del personaje, escalan con el avatar y lo siguen al moverse, saltar y girar. Sin colisión, sin `CanTouch`, sin afectar la cámara ni la hitbox.
* **Legibilidad:** no deben tapar nameplates, telegraphs, barras de vida ni la vista del jugador; en cámara cercana se reduce su opacidad o se ocultan las plumas más cercanas.
* **Multijugador:** el servidor replica el estado activo y la spec; los demás clientes ven las alas del Paladín. El VFX no otorga efectos de gameplay a terceros.
* **Rendimiento:** límite de plumas/partículas por ala y LOD móvil; con cuatro Paladines potenciados en party no debe haber caída notable de frames.
* **Audio:** sin SFX nuevos. Si se usa audio existente en la activación, debe ser breve y no reproducirse en cada renovación ni por tick.

---

### Criterios de aceptación (Gherkin)

#### Escenario 1: Sin spec no hay Fe ardiente

* **GIVEN** un Paladín sin especialización de talentos activa
* **WHEN** usa Golpe sagrado repetidamente sobre enemigos válidos
* **THEN** la skill hace su daño normal, pero no acumula cargas, no muestra chip, no aparecen alas y el MATK no cambia

#### Escenario 2: Cargas 1 y 2 son preparación

* **GIVEN** un Paladín con spec activa y 0 cargas
* **WHEN** Golpe sagrado impacta por primera y segunda vez
* **THEN** el chip muestra 1/3 y 2/3, sin alas y sin conversión de MATK

#### Escenario 3: La tercera carga activa el buff

* **GIVEN** un Paladín con spec activa y 2 cargas
* **WHEN** el tercer Golpe sagrado impacta
* **THEN** se activa Fe ardiente durante 15 s, aparece el chip 3/3, se despliegan las alas y las skills de MATK usan la conversión

#### Escenario 4: Renovación y mantenimiento indefinido

* **GIVEN** un Paladín con Fe ardiente activa
* **WHEN** vuelve a impactar Golpe sagrado antes de que expiren los 15 s, repetidamente
* **THEN** el temporizador vuelve a 15 s en cada impacto, las alas se mantienen y el buff puede durar indefinidamente sin volver a acumular desde cero

#### Escenario 5: Expiración

* **GIVEN** un Paladín con Fe ardiente activa
* **WHEN** pasan 15 s sin un nuevo Golpe sagrado que impacte
* **THEN** pierde las 3 cargas, la conversión se desactiva, las alas se desvanecen y el chip se oculta

#### Escenario 6: Conversión en Castigo

* **GIVEN** un Paladín Castigo con spec activa y Fe ardiente activa
* **WHEN** usa Veredicto de luz, Llamas divinas, Sentencia o Anillo de luz sagrada
* **THEN** el daño usa `MATK final + ATK final × 0.75`, con el redondeo y la mitigación existentes

#### Escenario 7: Conversión en Protector

* **GIVEN** un Paladín Protector con spec activa y Fe ardiente activa
* **WHEN** usa Voto protector, Muro sagrado o Consagración
* **THEN** la curación, la absorción y el daño por tick usan `MATK final + ATK final × 0.15`, dentro de las bandas de balance

#### Escenario 8: Skills de ATK y ataques básicos sin cambios

* **GIVEN** un Paladín con Fe ardiente activa
* **WHEN** usa Golpe sagrado, Filo sagrado o un ataque básico
* **THEN** el daño sigue usando solo ATK y no recibe la conversión

#### Escenario 9: Sin impacto en otras clases

* **GIVEN** un Cazador o un Clérigo
* **WHEN** usa sus skills con cualquier estado
* **THEN** no obtiene Fe ardiente, no ve alas y no cambia su MATK ni su daño

#### Escenario 10: Limpieza de estado

* **GIVEN** un Paladín con cargas o con Fe ardiente activa
* **WHEN** muere, respawnea, cambia de PJ/spec, sale de la dungeon, se teletransporta o se desconecta
* **THEN** las cargas, el buff y las alas se limpian y no reaparecen al volver

#### Escenario 11: Crítico y orden de cálculo

* **GIVEN** un Paladín con Fe ardiente activa y una skill de MATK
* **WHEN** el impacto hace crítico
* **THEN** el daño buffeado se multiplica por ×1,5 una sola vez y la probabilidad de crítico no cambia

#### Escenario 12: UI, tooltip y panel

* **GIVEN** un Paladín sin spec, con 0, 1, 2 o 3 cargas
* **WHEN** mira el HUD y el panel de personaje
* **THEN** el chip refleja el estado real; el MATK muestra la línea temporal de Fe ardiente solo mientras está activa, sin marcarlo como bonus permanente

#### Escenario 13: Alas de valquiria

* **GIVEN** un Paladín que activa Fe ardiente
* **WHEN** se observa el personaje en PC y móvil, por el propio jugador y por la party
* **THEN** aparecen dos alas de luz de valquiria acordes a su spec, se mantienen durante el buff, pulsan al renovarse y se desvanecen al expirar, sin tapar telegraphs, nameplates ni barras

#### Escenario 14: Regresión

* **GIVEN** el sistema implementado
* **WHEN** se juega en solo y party, PC y móvil
* **THEN** no hay errores rojos, el rendimiento se mantiene y el resto de skills, cooldowns, maná y críticos funcionan igual

---

### Alcance

#### Incluye

* Buff **Fe ardiente**: 3 impactos de Golpe sagrado activan la potencia, con 15 s renovables indefinidamente y conversión del 25% del ATK en Castigo y 5% en Protector.
* Requisito de especialización de talentos activa; sin spec no hay acumulación.
* Obtención exclusiva mediante Golpe sagrado y renovación al impactar; las cargas 1-2 no convierten.
* Aplicación a daño, curación y escudo que escalen con MATK.
* Alas de luz de valquiria como VFX de estado, replicadas a la party, con variantes visuales por spec.
* Estado replicado, chip de HUD, tooltip y desglose temporal en el panel.
* Limpieza en muerte, respawn, cambio de PJ/spec, salida de dungeon, teleport y desconexión.
* QA de balance sostenido de Castigo y Protector contra las bandas de R8d.

#### No incluye

* Cambiar coeficientes, daño base, maná, cooldowns, rangos o tipos de skill.
* Convertir ATK en MATK de forma permanente o afectar el perfil guardado.
* Añadir cargas a otras skills, otras clases o a la party.
* Nuevos sets, talentos, ítems o cambios al equipo.
* SFX nuevos; el audio existente se conserva.

---

### Plan de verificación y datos de prueba

* **Sin spec:** Paladín sin especialización activa; tres Golpes sagrados no deben generar cargas, alas ni conversión.
* **Jugador nuevo con spec (nivel 1):** el aumento absoluto de MATK es pequeño (±2-4) y no altera el TTK del dummy.
* **Activación:** con spec activa, 1-2 impactos no convierten; el tercero activa 15 s, alas y conversión.
* **Castigo nivel 20 con build completa:** comparar DPS sostenido durante **120 s** con y sin Fe ardiente, renovando con Golpe sagrado cada ≤14 s; medir por separado skills de ATK, skills de MATK y ataques básicos. Repetir con uptime 0%, 50% y 100%.
* **Expiración:** dejar pasar 15 s sin Golpe sagrado; confirmar pérdida de cargas, alas y conversión; volver a acumular desde cero.
* **Protector nivel 20:** medir curación de Voto, absorción de Muro y daño total de Consagración con Fe ardiente activa; comparar contra la build sin buff y verificar que no se vuelve inmortal.
* **Casos hostiles:** morir con buff, cambiar de PJ/spec, salir de la dungeon, teletransportarse, desconectarse y rejoin; castear Golpe sagrado sin objetivo, fuera de rango, sin maná y en cooldown; confirmar que ningún caso deja alas huérfanas ni buff persistente.
* **Multijugador:** dos Paladines con Fe ardiente simultánea; confirmar que cada uno solo aplica la suya y que la party ve las alas correctas.
* **Rendimiento:** party de 4 con varias skills y 2-4 Paladines con alas activas en PC y móvil; sin errores rojos ni caída notable de frames.
* **Datos de referencia:** `ClassConfig` (ATK 50 / MATK 29 a nivel 20), build real reportada por el PO (**192 ATK / 50 MATK**), `SkillConfig` (coeficientes actuales), `ItemConfig` (2H única, anillos), `TalentConfig` (Fervor/Ardor).

---

### Definition of Done (DoD)

* [ ] Sin especialización activa, Golpe sagrado no acumula cargas ni activa alas o conversión.
* [ ] Con spec activa, 1-2 impactos de Golpe sagrado solo preparan; el tercero activa Fe ardiente durante 15 s.
* [ ] Cada Golpe sagrado que impacta mientras el buff está activo renueva los 15 s; el mantenimiento puede ser indefinido.
* [ ] La conversión `MATK + ATK × factorActivo` (0.75 Castigo / 0.15 Protector, equivalentes a 3 × 25% / 3 × 5%) se aplica solo con Fe ardiente activa, a daño, curación y escudo que escalan con MATK, después de los multiplicadores de MATK.
* [ ] Skills de ATK, ataques básicos, otras clases, pociones y efectos planos no reciben la conversión.
* [ ] El crítico de R6.38 sigue aplicando ×1,5 una sola vez sobre el daño buffeado.
* [ ] El estado se replica y se limpia correctamente en muerte, respawn, cambio de PJ/spec, salida de dungeon, teleport y desconexión.
* [ ] HUD: chip con 1-3 cargas, estado activo 3/3, tooltip con bonificación y tiempo restante; sin hueco cuando no hay cargas.
* [ ] Panel de personaje: MATK efectivo y línea temporal de Fe ardiente en el desglose, sin marcarlo como bonus permanente.
* [ ] Alas de luz de valquiria visibles al activar, renovadas con pulso, desvanecidas al expirar; variantes Protector/Castigo; replicadas a la party; sin tapar telegraphs/nameplates/barras.
* [ ] QA de balance sostenido: Castigo 0.95-1.05× del promedio de DPS (máximo 1.10×) con uptime 100%, Protector +≤15% daño y +≤35% cura/escudo, jefe del piso 5 ≥45 s.
* [ ] `SKILLS_CATALOG` actualizado a v2.7 con la mecánica de Golpe sagrado y la nota de conversión; `GDD` y `ROADMAP` sincronizados.
* [ ] Sin errores rojos; pruebas PC/móvil, solo/party y jugador nuevo/máximo.

---

### Estimación orientativa

3-4 sesiones del dev: servicio de estado y conversión, integración en las rutas de MATK, alas y partículas, UI/tooltip, replicación a la party y QA de balance sostenido.

---

### Cambios de catálogo propuestos (v2.7, al aprobar el RC)

* **Golpe sagrado (`paladin_holy_strike`):** además de su daño `12 + 1.0×ATK`, acumula **Fe ardiente** (máx. 3 cargas). Con especialización activa, el tercer impacto activa el estado durante **15 s**; cada impacto posterior lo renueva. El estado convierte **25% del ATK final en MATK en Castigo** y **5% en Protector** para las skills del Paladín que escalan con MATK, y muestra alas de luz de valquiria. Las cargas 1-2 no convierten; el tercer golpe que activa no se beneficia de la conversión.
* Registrar las bandas de ajuste (Castigo 22-28%, Protector 4-7% por carga), el requisito de spec activa y la regla de que la conversión se suma después de los multiplicadores de MATK.
* No cambian los coeficientes, costes ni cooldowns del catálogo.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-11-21 | HU creada a partir del reporte del PO: Castigo es el DPS más débil porque su burst escala MATK mientras la build viable prioriza ATK. Se propone Fe ardiente en Golpe sagrado y se corrigen los supuestos del kit híbrido. |
| 2026-11-21 | Recalibración con la build real del PO (**192 ATK / 50 MATK**): el 8% inicial solo aportaba ~9% de DPS total. Se sube a **25% por carga en Castigo** (75% con 3) y se deja **5% en Protector** (15% con 3) para no duplicar su sostenibilidad. Bandas de QA: Castigo 22-28%, Protector 4-7%. |
| 2026-11-21 | Ajuste PO: la mejora se desbloquea solo con especialización de talentos activa, se activa al **tercer Golpe sagrado**, dura **15 s** renovables indefinidamente y añade **alas de luz de valquiria** como VFX de estado. Las cargas 1-2 no convierten. |
