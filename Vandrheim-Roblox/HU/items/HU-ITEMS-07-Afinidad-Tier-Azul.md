# HU-ITEMS-07: Bonos del tier azul (3/5 piezas) y joyería (dev)

**Proyecto:** Vandrheim (Roblox MVP)
**Épica:** Items / Progresión
**Prioridad:** Media — valor percibido del tier intermedio
**Estado:** Implementada (reporte del dev 2026-11-03; QA/verificación pendiente)
**Tipo:** Extensión del sistema de bonos + contenido de joyería (dev)
**Fase GDD:** Itemización (complemento de ITEMS-03/04/05)
**Depende de:** HU-ITEMS-03 (sistema de bonos y `setId`), HU-ITEMS-04 (templates por tier), HU-ITEMS-05 (balance), HU-R8d (bandas de poder), `InventoryService`
**No modifica:** stats base existentes, loot de armas, economía ni los bonos genéricos de 3/4 piezas.

---

### Narrativa (INVEST)

**Como** jugador que arma su set azul,
**quiero** dos hitos de bonus (3 y 5 piezas) y joyería azul que cuente para ellos,
**para** sentir que completar el tier intermedio me da algo propio, sin competir con el Helada.

**Como** equipo,
**quiero** bonos de solo estadísticas y joyería por tier con su propio loot,
**para** añadir profundidad de build sin introducir efectos nuevos que compliquen el balance.

---

### Descripción / Contexto

El tier azul (nivel 12) hoy solo se diferencia del verde por stats. El Helada (2.5×) sí tiene identidad fuerte con el bono de habilidad de 4 piezas.

Esta HU agrega:
1. **Bonos del tier azul en 3 y 5 piezas**, solo estadísticas (sin modificadores de habilidad).
2. **Joyería nueva por tier** (collar y anillo), incluida la azul, que **cuenta** para esos bonos.
3. **Loot propio** para la joyería verde y azul.

La joyería Helada/morada queda **fuera** de este bono: el PO definirá su comportamiento aparte.

**Criterio de hecho global:** con 3 y 5 piezas azules (armadura de la clase + joyería azul) el jugador recibe los bonos de estadística correspondientes, visibles en tooltip y panel; el Helada completo sigue siendo estrictamente superior y la joyería morada no participa.

---

### Especificaciones Técnicas / Contratos

#### 1. Bonos del tier azul (solo estadísticas)

| Hito | Paladín (DEF · MATK) | Cazador (ATK · CRIT) | Clérigo (MATK · MaxMP) |
|---|---|---|---|
| **3 piezas** | +2% DEF · +2% MATK | +2% ATK · +0.8% CRIT | +2% MATK · +2% MaxMP |
| **5 piezas** | +3% DEF · +3% MATK | +3% ATK · +1.2% CRIT | +3% MATK · +3% MaxMP |
| **Total a 5 piezas** | **+5% DEF · +5% MATK** | **+5% ATK · +2.0% CRIT** | **+5% MATK · +5% MaxMP** |

* Los dos hitos **se acumulan**: a 5 piezas aplica el de 3 y el de 5.
* Cada clase recibe **dos estadísticas** para no atar el bono a una sola especialización: Paladín cubre tanque y Castigo (DEF + MATK), Cazador cubre Asalto y Puntería (ATK + CRIT) y Clérigo cubre curación y Cólera (MATK + MaxMP).
* Solo estadísticas: nada de procs, cooldowns, rangos ni modificadores de skill.
* CRIT en fracción (0.008 y 0.012), como el resto del sistema. MaxMP se aplica como porcentaje sobre el valor del personaje.
* Valores configurables; el balance final lo valida ITEMS-05.

#### 2. Qué piezas cuentan

* **Armadura azul del set de la propia clase** (`paladin_blue`, `hunter_blue`, `cleric_blue`): 5 piezas.
* **Joyería azul equipada** (`tier = "blue"`): collar y anillo. Cuentan aunque la joyería no tenga clase.
* Total posible: **7 piezas** (5 armadura + 2 joyería), suficiente para llegar al hito de 5.
* **No cuentan:** armadura azul de otra clase, tiers blanco/verde/Helada ni **joyería Helada**.
* Cada pieza cuenta una sola vez.
* Para la joyería, el tier se resuelve con el campo `tier` del template (no todos los templates tienen `setId`).

#### 3. Joyería nueva por tier

Actualmente solo existe collar y anillo comunes. Se agregan variantes.

**Collares (defensivos):**

| Template | Tier | Rareza | levelReq | Stats | Icono | Obtención |
|---|---|---|---|---|---|---|
| `collar_white` (actual) | white | Common | 1 | MaxHP 10 (±5), DEF 1 | `Icon_Item_collar` · `88383256424732` | Inicial / vendor |
| `collar_green` | green | Uncommon | 5 | MaxHP 15 (±5), DEF 2 (±1), MDEF 1 | reutiliza `Icon_Item_collar` | Loot piso 1–2 (2%) + vendor |
| `collar_blue` | blue | Rare | 12 | MaxHP 20 (±5), DEF 3 (±1), MDEF 2 (±1) | `Icon_Item_collar_blue` · `80822592106770` | Loot piso 3–5 (1.5%) |

**Anillos (ofensivos, con variante ATK o MATK):**

| Template | Tier | Rareza | levelReq | Stats | Icono | Obtención |
|---|---|---|---|---|---|---|
| `ring_white_atk` — **Anillo de Filo** (renombra al actual) | white | Common | 1 | ATK 2 (±1), CRIT +1% | `Icon_Item_ring` · `125055600901549` | Inicial / vendor |
| `ring_white_matk` — **Anillo Rúnico** | white | Common | 1 | MATK 2 (±1), CRIT +1% | reutiliza `Icon_Item_ring` | Inicial / vendor |
| `ring_green_atk` — **Anillo de Filo Esmeralda** | green | Uncommon | 5 | ATK 4 (±1), CRIT +2% | reutiliza `Icon_Item_ring` | Loot piso 1–2 (1% por variante) |
| `ring_green_matk` — **Anillo Rúnico Esmeralda** | green | Uncommon | 5 | MATK 4 (±1), CRIT +2% | reutiliza `Icon_Item_ring` | Loot piso 1–2 (1% por variante) |
| `ring_blue_atk` — **Anillo de Filo Azul** | blue | Rare | 12 | ATK 6 (±2), CRIT +3% | `Icon_Item_ring_blue` · `76040067823433` | Loot piso 3–5 (0.75% por variante) |
| `ring_blue_matk` — **Anillo Rúnico Azul** | blue | Rare | 12 | MATK 6 (±2), CRIT +3% | `Icon_Item_ring_blue` · `76040067823433` | Loot piso 3–5 (0.75% por variante) |

* Cada anillo sale en **una sola variante** (ATK o MATK), no en ambas a la vez. Así el Cazador/Paladín físico y el Clérigo encuentran algo útil.
* Nombres por variante: **Anillo de Filo** para ATK y **Anillo Rúnico** para MATK, con sufijo de tier (Esmeralda / Azul / Glacial). El anillo blanco actual pasa de “Anillo sencillo” a “Anillo de Filo”.
* Los collares conservan por ahora “Collar sencillo”; si se quiere una familia de nombres por tier, se define aparte.
* La variante **MATK existe en todas las rarezas** (blanco, verde y azul), no solo en el tier azul. Lo mismo aplica a la variante ATK.
* El peso total del anillo por tier se mantiene: verde 2% repartido (1% + 1%) y azul 1.5% (0.75% + 0.75%). Configurable y validado en ITEMS-05.
* Ambas variantes de anillo cuentan como **joyería azul** para los bonos de tier cuando son `tier = "blue"`.
* Los porcentajes son defaults configurables; ITEMS-05 valida que no inunden la bolsa ni rompan la economía de rareza.
* Los ítems verdes reutilizan el `iconId` del collar/anillo común; la rareza se distingue por el marco/borde de la casilla, no por el icono.
* Los azules usan su icono propio ya entregado (`Icon_Item_collar_blue`, `Icon_Item_ring_blue`).
* Los iconos nuevos de Común **sustituyen a los anteriores**. Todos son PNG con **fondo transparente**, sin fondo incrustado; la rareza se representa con el borde de la casilla, no con la imagen.
* Además existen `Icon_Item_collar_frost` (`122632130926824`) e `Icon_Item_ring_frost` (`125276837628603`), reservados para la joyería Helada, definida en **HU-ITEMS-08** (bonos propios de tier, fuera de este bono azul).
* CRIT expresado en puntos porcentuales como el collar/anillo actuales (1 = 1%). El `roll` es la variación aleatoria ya usada por R4 (base ± roll).
* La joyería es sin clase; se resuelve la cobertura de MATK con la variante arcana del anillo.
* Sin modelo 3D: solo dato + icono, igual que la joyería actual.
* La joyería **Helada** no se incluye en esta HU.

#### 4. Interfaz

* Tooltip del ítem azul: línea informativa de pertenencia al tier, por ejemplo
  `Tier azul · cuenta para bonos 3/5`.
* Panel de personaje: bloque de bonos con los dos hitos y su estado:
  `3 piezas: ACTIVO · 5 piezas: faltan 2`.
* Sin iconos nuevos obligatorios; texto con los tokens existentes.

#### 5. Guardas de balance

* Cada estadística del bono a 5 piezas queda por debajo del bono genérico de 3 piezas de su clase (Paladín +8% DEF, Cazador +5% CRIT, Clérigo +8% MATK). ATK y MaxMP no tienen bono genérico equivalente: ITEMS-05 valida que el total no rompa la banda de poder entre tiers.
* ITEMS-05 debe verificar que un set azul completo (incluida joyería) sigue siendo **inferior** a un set Helada completo del mismo nivel.
* Sin acumulación por mezclar sets: solo cuentan piezas azules válidas.

---

### Criterios de Aceptación (Gherkin)

#### Escenario 1: Hito de 3 piezas

* **GIVEN** un Paladín con 3 piezas azules válidas equipadas
* **WHEN** se recalculan sus stats
* **THEN** recibe +2% DEF y +2% MATK de afinidad azul

#### Escenario 2: Hito de 5 piezas acumulado

* **GIVEN** 5 piezas azules válidas equipadas
* **WHEN** se revisan los stats
* **THEN** recibe el total de +5% DEF y +5% MATK (2 + 3), sin superar el bono genérico de 3 piezas

#### Escenario 2a: Dos estadísticas por clase

* **GIVEN** un Cazador con 5 piezas azules válidas
* **WHEN** se revisan sus stats
* **THEN** recibe +5% ATK y +2% CRIT
* **AND** un Clérigo con las mismas piezas recibe +5% MATK y +5% MaxMP

#### Escenario 3: Joyería azul cuenta

* **GIVEN** 3 piezas de armadura azul y el anillo azul equipados
* **WHEN** se cuentan las piezas del tier
* **THEN** el total es 4 y solo el hito de 3 está activo
* **AND** al equipar también el collar azul llega a 5 y activa el hito de 5

#### Escenario 4: Joyería Helada no cuenta

* **GIVEN** armadura azul y un anillo Helada equipados
* **WHEN** se cuentan las piezas del tier azul
* **THEN** el anillo Helada no aporta al conteo ni a la afinidad

#### Escenario 5: Piezas inválidas

* **GIVEN** piezas azules de otra clase o piezas verdes
* **WHEN** se revisan los bonos
* **THEN** no aportan a la afinidad azul del personaje

#### Escenario 6: Joyería nueva y su loot

* **GIVEN** el catálogo y las LootTables
* **WHEN** se revisan los tiers
* **THEN** existen collar y anillo verdes (nivel 5) y azules (nivel 12) con sus stats
* **AND** los anillos existen en variante ATK y MATK, y cada drop entrega solo una
* **AND** los verdes caen en pisos 1–2 y los azules en pisos 3–5 con los porcentajes configurados
* **AND** los verdes usan el icono del collar/anillo actual

#### Escenario 6a: Anillo arcano

* **GIVEN** un Clérigo con un `ring_blue_matk` equipado
* **WHEN** se revisan sus stats
* **THEN** recibe MATK y CRIT, sin ATK
* **AND** el anillo cuenta para el tier azul igual que la variante ATK

#### Escenario 7: Helada sigue siendo superior

* **GIVEN** un set azul completo con joyería y un set Helada completo del mismo nivel
* **WHEN** se comparan
* **THEN** el Helada sigue siendo estrictamente mejor en poder total

#### Escenario 8: Regresión

* **GIVEN** el sistema con los bonos azules activos
* **WHEN** se equipa/desequipa, cambia de spec o respawnea
* **THEN** los bonos genéricos de 3/4 piezas siguen funcionando y no hay errores rojos

---

### Alcance

#### Incluye

* Bonos de tier azul en 3 y 5 piezas, solo estadísticas.
* Conteo de armadura azul de la clase + collar y anillo azules (máx. 7).
* Nuevos collares y anillos verde y azul (anillos con variante ATK y MATK) con stats, levelReq, icono y loot (%). 
* Tooltip y panel con estado de los dos hitos.
* Validación de jerarquía frente a Helada.

#### No incluye

* Modificadores de habilidad o efectos con proc.
* Joyería Helada/morada (se define aparte).
* Cambios a stats base, economía o rarezas existentes.
* Modelos 3D de joyería (sigue siendo dato + icono).

---

### Definition of Done (DoD)

* [ ] Bonos azules de 3 y 5 piezas calculados en servidor, acumulativos y sin persistencia.
* [ ] Cuentan armadura azul de la clase + collar y anillo azules; nada más.
* [ ] Joyería Helada excluida del conteo y de la afinidad.
* [ ] Collares y anillos verde/azul con stats, levelReq, icono y loot (%) en LootTables, con anillos en variante ATK y MATK.
* [ ] Los verdes reutilizan el icono actual; los azules tienen icono o placeholder.
* [ ] Tooltip y panel muestran hitos y estado; sin errores rojos en PC/móvil.
* [ ] ITEMS-05 valida que Helada sigue siendo superior y que no se rompen las bandas.

---

### Estimación (orientativa)

2 sesiones del dev: bonos y conteo, templates de joyería, loot, tooltip/panel y QA de balance.

---

### Historial

| Fecha | Cambio |
|---|---|
| 2026-10-27 | Creación de HU-ITEMS-07: afinidad de clase del tier azul. |
| 2026-10-27 | Revisión PO: pasa a **bonos de 2 y 4 piezas, solo estadísticas**; se agrega joyería nueva (collar y anillo) y la **joyería azul cuenta** para el tier. La joyería Helada queda fuera y se definirá aparte. |
| 2026-10-27 | Revisión PO: cada clase recibe **dos estadísticas** para no casar el bono a una sola spec — Paladín DEF + MATK, Cazador ATK + CRIT, Clérigo MATK + MaxMP. |
| 2026-10-27 | Revisión PO: hitos pasan a **3 y 5 piezas**; joyería verde reutiliza los iconos actuales y ambas joyas tienen loot con % en dungeon. |
| 2026-11-03 | El anillo pasa a tener **variante ATK y variante MATK en todas las rarezas** (una por drop) para que el Clérigo no lo vea como peso muerto; el peso total del anillo por tier se mantiene. |
| 2026-11-03 | Nombres de anillo por stat: Anillo de Filo (ATK) y Anillo Rúnico (MATK); el blanco actual se renombra a Anillo de Filo. El Helada usa el sufijo Glacial. |
| 2026-11-03 | Iconos entregados y registrados en `ASSETS_LIST`: `Icon_Item_collar` 88383256424732, `collar_blue` 80822592106770, `ring` 125055600901549, `ring_blue` 76040067823433 (los de Común reemplazan a los anteriores); `collar_frost` 122632130926824 y `ring_frost` 125276837628603 quedan reservados. |
| 2026-11-03 | Implementada según reporte del dev. Pendiente: QA en Studio/móvil y verificación de balance. |
