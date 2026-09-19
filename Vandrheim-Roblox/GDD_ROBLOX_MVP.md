# Vandrheim — GDD MVP (Roblox Studio)

> Documento vivo. **Fuente de verdad** para desarrollo en Roblox Studio.
> Última actualización: 2026-08-26  
> Decisiones del cuestionario de arquitectura/diseño **integradas y cerradas**.

---

## 1. Visión

RPG/MMO-like en **3ª persona** dentro de Roblox: se prioriza que **se sienta como un MMORPG tradicional** (tab-target, specs, talentos, gear, roles), no como un tycoon o simulator típico de la plataforma.

**Loop:**
pueblo hub → portal → mazmorra (instancia propia) → pisos → boss + cofre → pueblo (vender, equipar, talentos) → repetir.

**Principio de alcance:** vertical slice divertido primero; se permiten **pequeñas mejoras** si suben mucho la experiencia, sin inflar el MVP.

**Progresión:** media (varias horas hasta nivel 20, no un sprint de una sesión).

---

## 2. Plataforma y arquitectura

| Tema | Decisión |
|------|----------|
| Motor | Roblox Studio |
| Lenguaje | Luau (Server + Client) |
| Autoridad | **Server-authoritative** (daño, loot, oro, progresión) |
| Persistencia | DataStoreService (perfil, inventario, talentos, oro, clase) |
| Clientes | PC + móvil (UI escalable) |
| Avatar | **R15** del jugador (skin de Roblox) + overrides de equipo/clase |
| Monetización MVP | Cosmética + **3.er slot de personaje** (Robux); 2 slots gratis; gameplay completable sin Robux |
| Slots de personaje | **2 por UserId** (MVP gratis); **3.º** desbloqueable con Robux |
| Seguridad | Nunca confiar en el cliente |

### 2.1 Modelo de mundo (cerrado)

| # | Decisión |
|---|----------|
| **1** | **Servidor público** en el pueblo: varios jugadores se ven e interactúan (chat, presencia). Coop de mazmorra **no** es obligatorio en el MVP. |
| **2** | Cada entrada a mazmorra = **instancia independiente** (run propia del jugador o de su party). |
| **3** | Futuro multiplayer: **ambas** (party de amigos + matchmaking), pero **primero solo party de amigos**. |
| **4** | Sistemas diseñados **multiplayer-ready** desde el inicio, aunque el MVP sea run individual. |
| **5** | **Pueblo y Dungeon = Places separados** (teleport entre Place hub y Place dungeon). |
| **6** | Pueblo **persistente** en sesión (comprar/vender/talento → portal). Zonas/áreas extra del mundo = **después**. |
| **7** | **Abandonar dungeon = terminar la run** (no se reanuda en el piso 3). |

#### Diagrama de instancias

```text
Place: Pueblo (servidor público)
├── Jugador A, B, C (se ven / interactúan)
│
└── Al entrar al portal → Teleport a Place: Dungeon
    ├── ReservedServer / instancia Run A → Jugador A (o party de A)
    └── ReservedServer / instancia Run B → Jugador B (o party de B)
```

> Implementación típica: **TeleportService + ReservedServer** por run. El Place de dungeon puede ser uno solo reutilizado por instancia.

---

## 3. Decisiones de juego (tabla maestra)

| Tema | Decisión cerrada |
|------|------------------|
| Prioridad de sensación | MMORPG/RPG tradicional en Roblox |
| Cámara / movimiento | WASD + 3ª persona tipo MMORPG; **correr por defecto**, tecla `U`/botón móvil alterna caminar |
| Velocidades | Correr `20` / caminar `10` studs/s (defaults iniciales, configurables) |
| Pisadas | Sonido por material (`Ice`, `Sand`, `Grass` + fallback); sincronizado con animación; `FootstepSystem` existente |
| Equipamiento visual | Los ítems equipados se reflejan en el avatar R15; pipeline + set inicial del Paladín en `HU-ESTETICA-01` |
| Atacar en movimiento | **Sí** |
| Auto-attack | **Sí** (con target seleccionado) |
| TAB | Enemigo válido **más cercano**; TAB cicla al siguiente |
| Click target | **Opcional** (además de TAB) |
| Skills de suelo (AoE) | Permitidas |
| Clases MVP | Paladín, Cazador, Clérigo |
| Clases post-MVP | Templario, Cambiaformas |
| Specs | 2 árboles por clase; **elegís una spec** (no mezclar skills de ambas) |
| Skills en barra | **4**, totalmente configurables por el jugador |
| Slots de uso de ítems | **2**, asignables desde inventario; teclas `Z` y `X` + botones móviles |
| Talentos / árbol | **3 ramas × ~3 nodos** por spec; prerequisitos directos + gates por puntos (4/8) y nivel (8/16); nodos `Passive` y `Skill` (enseñan habilidades); respec en pueblo con oro |
| Spec / respec | Solo pueblo, **cuesta oro** (no gratis, no permanente sin cambio) |
| Nivel máx. MVP | ~20 |
| Ritmo a lvl 20 | **Medio** (varias horas) |
| Puntos talento | 1 cada 2 niveles → ~10 a lvl 20 |
| Mazmorra MVP | Helada, 5 pisos |
| Layout pisos | Mismo **kit**, layout **generado/variado** |
| Enemigos por run | **Combinación** (plantilla + variación) |
| Dificultad | **Nivel fijo por piso** (no adaptativa al PJ) |
| Abandonar run | Termina la run |
| Packs solo | 1–3 (diseño) |
| Packs grupo (futuro) | 5+ |
| Loot solo vs grupo | Solo = base; grupo = más difícil + mejor loot |
| Loot delivery | **Automático al inventario** |
| UI de recompensa | Ventana/recompensa (no loot físico en el suelo) |
| Cofre | **Solo boss piso 5** |
| Stats de ítems | Base fija + **pequeñas variaciones aleatorias** |
| Ítems únicos | **Sí** (ej. armas/nombres de boss) |
| Bind | **Bind on Equip** |
| Trade entre jugadores | **Sí en el futuro** (no prioritario MVP) |
| Armadura | Cualquier clase puede equipar cualquier armadura |
| Slots | Casco, Pecho, Hombreras, Pantalón, Guantes + Anillo + Collar (+ arma/offhand) |
| Armas | Melee 1H/2H, ranged, varita; escudos |
| Rareza | Blanco, Verde, Azul, Morado |
| Inventario / stacking | `maxStack` configurable por ítem; pociones hasta 20; equipo 1; **20 slots = 20 pilas ocupadas**; uso/venta descuentan 1 unidad |
| Req. nivel ítem | Sí |
| Creación PJ | **Solo nombre + clase**; skin = avatar Roblox del jugador |
| Slots de PJ | **2 gratis** por UserId; **3.º** con Robux |
| Sexo / pelo / piel custom | **No** en MVP (lo trae el avatar) |
| Monetización | Cosmética + slot extra; **juego completable sin Robux** (2 PJs bastan) |
| Flexibilidad de alcance | Mantener GDD; **pequeñas mejoras** OK |

---

## 4. Clases y specs

| Clase | Spec A (única activa) | Spec B (única activa) | Rol |
|-------|----------------------|----------------------|-----|
| **Paladín** | Protector | Castigo | Tank / melee mágico |
| **Cazador** | Asalto | Puntería | Melee físico / ranged físico |
| **Clérigo** | Misericordia | Cólera | Heal / ranged mágico |

### Reglas de build (cerradas)

1. El jugador **elige una spec** (vía puntos de talento en un árbol).
2. **No** se usan skills activas de la otra spec a la vez (27-B).
3. Barra de **4 skills** = loadout **100% elegible** desde la **ventana de habilidades (spellbook)**, entre las aprendidas de **su spec** (+ basicas de clase si aplica). Skills de talento se aprenden en el árbol (R5.1).
4. Respec de talentos/spec: **solo en pueblo, con oro**.
5. Afinidad de armas = bonus, no hard-lock total (salvo que el balance lo pida después).

| Spec | Arma preferida |
|------|----------------|
| Protector | 1H + escudo |
| Castigo | 2H / 1H melee mágico |
| Asalto | 1H o 2H melee físico |
| Puntería | Arco / ballesta |
| Misericordia | Varita (+ escudo opcional) |
| Cólera | Varita |

**Catálogo de skills:** `SKILLS_CATALOG.md` (diseño canónico v2). 2 básicas/clase + 4/spec (2 por nivel + 2 por talento) = 30 skills; tipos MVP: `Instant`, `GroundAoE`, `Heal`, `Shield` en contenido (`HealAoE`/`Buff` en framework). Árbol WoW (3 ramas) y spellbook: HU-R5.1. Assets visuales: §17.

### Post-MVP

| Clase | Spec A | Spec B |
|-------|--------|--------|
| Templario | Filo | Runas |
| Cambiaformas | Bestia | Espíritu |

---

## 5. Combate

- Movimiento MMORPG + **auto-attack** con target.
- Correr por defecto; `U`/botón móvil alterna caminar, con animación y velocidad configurables (HU-R6.1).
- Pisadas locales sincronizadas con los apoyos de la animación y el material del suelo (HU-R6.1).
- **TAB**: más cercano válido → siguientes en ciclo.
- **Click** sobre enemigo: opcional.
- Cast / skills **mientras te movés** (salvo skills que por diseño pidan root más adelante).
- Cada skill: **maná + cooldown**. Skills data-driven desde `SKILLS_CATALOG.md` (ver §4).
- Server calcula daño, curas, threat, muerte.
- Muerte en dungeon: respawn en checkpoint del piso o entrada del piso (detalle fino en implementación); **salir del place = fin de run**.

### Escalado mazmorra

- Cada piso tiene **nivel de contenido fijo**.
- Pisos 1–4: élite/mini-boss al final (recomendado).
- Piso 5: boss + **cofre** (única fuente de cofre del MVP).

---

## 6. Progresión

| | |
|--|--|
| Cap | ~20 |
| Ritmo | Medio |
| Talentos | 1 punto cada 2 niveles (~10 puntos) |
| Skills | Desbloqueo: **básicas lvl 1; por spec: 2 por nivel (lvl 1 y 5) + 2 por talento**; 4 slots de barra + **ventana de habilidades** (spellbook) |
| Spec | Una activa; cambio vía respec en pueblo |

### Stats base

MaxHP, MaxMP, ATK, MATK, DEF, MDEF, CRIT.

---

## 7. Ítems y economía

### Generación de stats

- Cada ítem tiene **stats base fijos** de su template.
- Al dropear/craft (si hubiera): **roll menor** dentro de rangos (ej. ATK 8–10, a veces affix chico).
- **Ítems únicos** de boss con nombre propio (ej. “Espada de la Escarcha”) además del loot genérico.

### Stacking y capacidad de inventario

- `ItemConfig` define `stackable` y `maxStack`; no hay un máximo global hardcodeado.
- Default MVP: pociones `stackable=true`, `maxStack=20`; armas y armaduras `maxStack=1`.
- Los **20 slots representan 20 pilas ocupadas**, no 20 unidades. Una pila `x20` ocupa un slot.
- Comprar `qty` completa pilas existentes antes de crear otras; si no hay espacio para todas las unidades, la operación se rechaza completa.
- Usar o vender descuenta **1 unidad por acción**; la entrada se elimina al llegar a cero.
- La UI muestra la cantidad (`xN`) y `quantity` persiste; una entrada antigua sin cantidad se interpreta como `1`.
- Detalle técnico y criterios: `HU/HU-R5.2-Inventario-Stacking.md`; implementación en nuevo `rc011`. No modifica `rc010`.

### Bind

- **Bind on Equip**: al equipar queda ligado al personaje.
- Prepara el camino a trade futuro sin free-for-all de RMT fácil.
- Trade jugador-jugador = **post-MVP**, pero el flag de bind debe existir en data desde el día 1.

### Loot flow

```text
Kill mob / abrir cofre boss
  → servidor tira tabla
  → ítems + oro van al inventario
  → UI de recompensa / log (no pickups en el suelo)
```

- Cofre: **solo boss piso 5**.
- En grupo (futuro): reglas de need/greed o personal loot — definir en fase de party; data debe soportar “owner” del drop.

---

## 8. Mundo

### Place: Pueblo

- Servidor público, persistente en la sesión de juego.
- NPCs: consumibles, armas/armaduras, trainer/respec (+ opcional tutorial).
- Portal → teleporta al Place Dungeon (nueva instancia/run).
- Más zonas del “mundo” = expansión posterior.

### Place: Dungeon (Helada MVP)

- 5 pisos, **kit** común, **layouts variados/generados**.
- Enemigos: plantilla por piso + variación entre runs.
- Nivel de piso fijo (no escala al nivel del jugador).
- Salir / desconectar de la run = **run terminada** (progreso de piso no se guarda a medias).
- Progreso de personaje (XP, loot ya entregado, oro) **sí** persiste vía DataStore.

### Post-MVP mazmorras

Volcánica, Viento (mismo Place dungeon con bioma distinto o Places extra).

---

## 9. Creación de personaje

### Slots

| Slot | Acceso |
|------|--------|
| 1 y 2 | **Gratis** (MVP) |
| 3 | **Gamepass / Dev Product Robux** |

- **1 cuenta (UserId) → hasta 2 personajes** sin pagar; opcionalmente 3 con Robux.
- Cada slot = perfil propio (clase, nombre, nivel, inventario, talentos, oro).
- Pantalla de selección de personaje al join si ya hay slots ocupados.
- Borrar un PJ libera el slot (confirmación fuerte).

### Flujo de creación (por slot vacío)

1. Elegir **clase** (Paladín / Cazador / Clérigo).
2. Elegir **nombre** in-game (display del personaje en Vandrheim).
3. **Apariencia** = avatar R15 del jugador en Roblox (sin editor de pelo/piel propio).

No hay selección de sexo/cuerpo custom en MVP: lo define el avatar del usuario.

---

## 10. Multiplayer roadmap

| Fase | Qué |
|------|-----|
| **MVP** | Pueblo compartido; dungeon **solo** (1 jugador por run); sistemas listos para N jugadores |
| **v1 party** | Invitar **amigos**, reserved server compartido, packs 5+, loot/dificultad de grupo |
| **v1.x** | Matchmaking con desconocidos (mismas reglas de instancia) |
| **Luego** | Trade entre jugadores (respetando Bind on Equip) |

Diseño de bosses y roles asume party **2–4** aunque el MVP se juegue solo.

---

## 11. Monetización

| | |
|--|--|
| Permitido | Cosméticos (skins de arma, auras, títulos visuales, etc.) |
| Permitido (convenience) | **3.er slot de personaje** (Robux) |
| Gratis siempre | **2 slots** de personaje + todo el contenido PvE |
| Prohibido en diseño | Pay-to-win / power / loot mejor de pago |
| Principio | **El juego se completa bien con 0 Robux** (2 PJs bastan) |

- El 3.er slot es **convenience** (alt/reroll), no poder.
- DataService debe modelar `characters[1..maxSlots]` con `maxSlots = 2 o 3` según ownership del gamepass.
- Cosméticos pueden ir después; el flag de slot 3 conviene dejarlo desde R2.

---

## 12. Arquitectura técnica Roblox

### Places

```text
Experience
├── Place_Hub      (Pueblo — servidores públicos)
└── Place_Dungeon  (Mazmorra — reserved servers por run)
```

### Carpetas sugeridas (por Place o en paquetes compartidos)

```text
ReplicatedStorage/
  Shared/     -- enums, net contracts, utils
  Config/     -- Class, Skill, Talent, Item, DungeonFloor, LootTables
ServerScriptService/
  Services/   -- Data, Combat, Skill, Inventory, Talent, Dungeon, Loot, Vendor, Party
  Data/       -- profile load/save, bind flags
StarterPlayerScripts/
  -- input MMORPG, cámara, targeting (TAB+click), auto-attack client predict opcional
StarterGui/
  -- HUD, skill bar 4, target frame, inventory, reward popup, class create
```

### Servicios core

| Servicio | Rol |
|----------|-----|
| DataService | DataStore: lista de personajes (2–3 slots), activo, clase, nombre, nivel, talentos, inv, oro, bind |
| ClassService | Spec activa, stats |
| CombatService | Auto-attack ticks, daño, threat (server) |
| SkillService | Cast validate, CD, maná, AoE |
| InventoryService | Equip, BoE bind, req nivel, rolls de stats |
| TalentService | Puntos, una spec, respec oro |
| DungeonService | Start run, reserved server, pisos, exit=abandon |
| LootService | Tablas, uniques, auto-grant, reward UI payload |
| VendorService | Compra/venta |
| PartyService | Stub en MVP; invite amigos post-MVP |

### Networking

- Cliente envía **intenciones** (RequestCast, RequestEquip, RequestEnterDungeon…).
- Servidor valida y replica estado.
- Teleport a dungeon con **teleport data** (runId, partyId, floor seed).

### Generación de layout (piso)

- Seed por run → elige salas/conectores del **kit Helada**.
- Spawns de packs según presupuesto del piso (nivel fijo).
- Boss room fija al final del grafo del piso 5 (o de cada piso si hay mini-boss).

---

## 13. Alcance MVP

### Incluye

- Place Hub público + Place Dungeon instanciado  
- Creación: nombre + clase; avatar R15 del jugador  
- **2 slots de PJ gratis**; 3.º desbloqueable con Robux  

- 3 clases × 2 specs (una activa) × árbol de talentos de 3 ramas  
- Skills aprendidas por nivel/talento, 4 skills configurables, auto-attack, TAB + click opcional  
- Inventario, **stacking configurable**, BoE, rarezas, rolls menores, uniques de boss  
- Movimiento correr/caminar + pisadas por material (HU-R6.1)  
- 2 slots rápidos genéricos para usar ítems (`Z`/`X`) (HU-R6.2)  
- Loot auto + UI recompensa; cofre solo boss 5  
- Helada 5 pisos, kit + layout variado, nivel fijo por piso  
- NPCs hub (vendor + respec mínimo)  
- DataStore  
- UI usable en PC (móvil básico)  
- Código listo para party de amigos (aunque no shippee coop completo si falta tiempo)

### No incluye (explícito)

- Matchmaking aleatorio  
- Reanudar run a mitad  
- Loot en el suelo  
- Editor de apariencia propio  
- Mezclar skills de las dos specs  
- Trade en vivo  
- Pay-to-progress  
- Templario / Cambiaformas / Volcán / Viento  
- Mundo abierto con muchas zonas  

---

## 14. Plan de desarrollo

| Fase | Estado | Entrega | Criterio hecho |
|------|--------|---------|----------------|
| **R0** | **Completo** (2026-08-12) | 2 Places, carpetas, DataService stub, spawn hub, cámara 3ª MMORPG | Caminás por el pueblo |
| **R1** | **Completo** (2026-08-12) | Targeting TAB+click, auto-attack, 1 dummy, HP server | Matás dummy |
| **R2** | **Completo** (2026-08-12) | Creación nombre+clase, **2 slots**, select PJ, persistencia, stats por clase | Rejoin elige/mantiene PJ; stub slot 3 Robux |
| **R3** | **Completo** (2026-08-12) | Skill framework 4 slots, maná/CD, 1 AoE suelo | Skills data-driven |
| **R3.1** | **Completo** (2026-08-12) | Fix cámara WoW-like (LockCenter+GetMouseDelta, pitch 1:1, crosshair) | Cámara sin teleport de cursor |
| **R3.2** | **Completo** (2026-08-26) | Fix targeting TAB (sin PlayerList) + colisión/distancia de cámara | TAB cicla enemigos y la cámara no atraviesa paredes |
| **R3.3** | **Completo** (2026-08-26) | Indicador visual de target (contorno + flecha) | El target se identifica al instante entre enemigos iguales |
| **R4** | **Completo** (2026-08-12) | Inventario + equip + BoE + rolls + rareza | Equip cambia stats |
| **R5** | **Completo** (2026-08-12) | Vendors + oro + respec | Loop económico mínimo |
| **R5.1** | **Completo** (2026-08-22) | Árbol de talentos WoW + spellbook + skills por nivel/talento | Build con progresión y loadout configurable |
| **R5.2** | **Completo** (2026-08-22) | Stacking configurable: 20 pilas, cantidades visibles, uso/venta unitarios | Inventario agrupa unidades sin duplicar ni perder datos |
| **R6** | **Completo** (2026-08-22) | Teleport dungeon, reserved server, 5 pisos kit+seed, exit=abandon | Run completa solo |
| **R6.1** | **Completo** (2026-08-23) | Correr por defecto, toggle caminar U/botón móvil, animaciones y pisadas sincronizadas por material | Movimiento y audio calzan con cada apoyo |
| **R6.2** | **Completo** (2026-08-26) | 2 slots de uso de ítems Z/X + reset de nivel debug en Studio | Ítems utilizables accesibles sin abrir inventario; QA puede repetir progresión desde nivel 1 |
| **R6.3** | **Completo** (2026-08-26) | Variantes de layout del dungeon (corredor/caverna/salón) | Cada run puede tener morfología distinta |
| **R6.4** | **Completo** (2026-08-26) | Topología ramificada + puertas selladas | Los pisos se exploran, no se corren en línea recta |
| **R6.5** | **Completo** (2026-08-26) | UI: barra de XP, mochila (B) y equipo (C) separados + stats | El jugador ve su progreso y su build sin ventanas apretadas |
| **R6.6** | **Completo** (2026-08-26) | Animaciones de combate del jugador (auto-attack y skills) | Cada golpe/cast tiene su animación; base para pruebas |
| **R6.7** | Pendiente | Sistema de animaciones de enemigos por familia (idle/walk/attack/special) | Cada tipo de enemigo se anima según su cuerpo; reemplazo por config |
| **R6.8** | **Completo** (2026-08-26) | VFX básico de combate: proyectiles ranged, hits, números de daño y muerte de enemigos | El combate se siente contundente sin assets externos |
| **R6.9** | **Completo** (2026-08-26) | AoE: zonas de suelo persistentes (daño en el tiempo) + SelfAoE alrededor del jugador | Consagración/Ira divina vs Torbellino se sienten distintas |
| **R6.10** | Pendiente | Menú in-game (ESC): volver a selección de PJ funcional + placeholders volumen/gráficos/UI | Probar varias clases sin salir del juego |
| **EST-01** | **Completo** (2026-08-26) | Equipamiento visible en avatar + 8 modelos iniciales del Paladín | Equipar cambia también la apariencia del personaje |
| **EST-02** | Pendiente | Modelos 3D de los enemigos de la Helada (7 bases + 5 elites) | Cada piso tiene enemigos y mini-bosses reconocibles |
| **EST-03** | Pendiente | Estructuras del pueblo nórdico: casas, caminos, límites, entradas y decoraciones | El hub se ve como un asentamiento nórdico coherente |
| **EST-04** | Pendiente | Diseño completo de UI (dirección "Hearthbound Gold"): sistema visual + 12 pantallas (incl. móvil) + componentes/assets | La interfaz tiene identidad nórdica cálida y es implementable por el dev |
| **EST-05** | Pendiente | Arco del Cazador: modelo 3D (diseñador) + integración como ítem (dev, pipeline EST-01) | Cazador equipa arco visible y funcional para pruebas |
| **R7** | **Completo** (2026-08-26) | Boss piso 5 + cofre + uniques + reward UI | Loop de botín cierra |
| **R8** | Pendiente | 3 clases jugables (skills/talentos MVP) | Builds distintas |
| **R8a** | **Completo** (2026-09-11) | Paladín completo: 10 skills + árboles finales (Protector/Castigo) + soporte MATKMult + **VFX únicos client-side por skillId** | Paladín jugable de punta a punta con 2 builds |
| **R8b** | **Completo** (2026-09-11) | Cazador completo (Asalto + Puntería) + VFX por skillId | Cazador jugable con builds melee y ranged; iconos finales pendientes de carga/registro |
| **R8c** | **Completo** (2026-09-18) | Clérigo completo (Misericordia + Cólera) + VFX por skillId | Clérigo jugable con builds heal y dps; QA cerrado según reporte |
| **R8d** | Pendiente | Balance de números + assets (iconos 30) + QA a nivel 20 — **HU-R8d no creada aún** | Las 6 specs se sienten distintas y el arco a 20 funciona |
| **R9** | Pendiente | Party amigos (si entra), polish UI, balance medio a 20 | Demo estable |
| **R10+** | Pendiente | Matchmaking, trade, más biomas/clases, cosméticos | Expansión |

> **R6 se ejecuta en 2 HUs:** `HU/HU-R6a-Dungeon-Preparacion.md` (enemigos, pisos, layout por seed, XP/leveling, respawn + arena de prueba) → `HU/HU-R6b-Dungeon-Core.md` (teleport + ReservedServer, run lifecycle, exit). Criterio R6: *run completa solo*.
> **R8 se ejecuta en 4 HUs:** R8a (Paladín) → R8b (Cazador) → R8c (Clérigo) → R8d (balance + assets + QA). Criterio R8: *builds distintas*.

HUs formales: `Vandrheim-Roblox/HU/` (`HU-R0`, `HU-R1`, `HU-R2`, …). Plantilla: `HU-TEMPLATE.md`.
RCs (requerimientos técnicos por HU): plantilla en `RC-TEMPLATE.md`; numeración `rc001`, `rc002`, … (formato comentario Luau).
Prompt de implementación (dev): `DEV_PROMPT.md` — obliga a generar el RC desde la HU antes de codificar.
  
### Defaults cerrados R1 (registro)

| Tema | Default |
|------|---------|
| Rango melee | 12 studs |
| Intervalo auto-attack | ~1.5 s |
| Daño R1 | Plano (ej. 10); sin stats de clase |
| HP dummy / jugador | 100 / 100 |
| Fuera de rango | Deja de atacar (sin chase player) |
| Dummy pega | No en R1 |
| Respawn dummy | ~5 s mismo sitio |  
  
### Defaults cerrados R2 (registro)

Ver `HU/HU-R2-Creacion-Personaje-Slots.md`. Resumen: 2 slots gratis; 3.º stub Robux; create = nombre + clase; gate sin PJ activo; DataStore por UserId.  
  
**Nota producción:** R0 completo. R1 completo. Siguiente: **R2**.  
  

---

## 15. Riesgos

1. Reserved servers + teleport mal hechos → runs rotas.  
2. Layout procedural sin buenas piezas de kit → pisos vacíos o unfair.  
3. Auto-attack + lag → debe ser server-tick claro.  
4. BoE + futuro trade: definir bien el flag desde día 1.  
5. Spec única + 4 skills flexibles: contenido de skills debe bastar por spec.  
6. Scope creep de party/matchmaking antes de que el solo divierta.

---

## 16. Métricas de éxito MVP

- Entrá al pueblo, creás PJ, completás una Helada y volvés con loot sin tutorial largo.  
- Auto-attack + TAB se sienten de MMO, no de clicker.  
- Al menos 2 specs (entre clases) se sienten distintas.  
- Abandonar run es claro y no corrompe el save.  
- Llegar a ~20 es un arco de varias sesiones, no un día ni un mes.

---

## 17. Assets: animaciones e iconos

> Política completa: `ASSETS_POLICY.md`. Resumen operativo:

- **Placeholders hasta R8/R9:** animaciones default de Roblox + iconos "color + inicial" (sin assets reales). Reemplazables solo cambiando `iconId`/`animationId` en config (nunca código).
- **Fuentes:** Marketplace gratuito (con crédito/licencia) + **desarrollo propio** (Animation Editor, rig R15); compra solo con decisión explícita de producto.
- **Regla de oro:** todo asset con fuente clara y licencia respetada; registro obligatorio (`ASSETS_REGISTRY` en ASSETS_POLICY.md). Prohibido material sin licencia.
- **Estructura:** `ReplicatedStorage/Assets/` (Animations/ Icons/ VFX/ SFX) con naming `Anims_<tipo>_<clase>_<spec>_<skill>` / `Icon_<skill|item>_<id>`.
- **SFX movimiento:** `FootstepSystem` reutiliza sonidos existentes por material; R6.1 sincroniza su reproducción con las animaciones sin enviar un evento por cada pisada.
- **Equipamiento visual:** `HU-ESTETICA-01` crea espada 1H, escudo, espadón 2H, casco, pecho, hombreras, piernas y guantes del Paladín, y los integra al avatar R15 desde `ItemConfig`.
- **Cantidad R8:** límite 1 animación por skillType + variantes por spec solo si sobran sesiones (evitar 1 anim por skill).
- **VFX:** básico sin assets (R6.8, R6.9 completas) + **partículas reales confirmadas** (dev); **VFX únicos por skill en cada HU de clase** (R8a/b/c); SFX en R9.
- **Criterio de aceptación de assets:** incluidos en DoD de R8/R9 con registro y sin licencias pendientes.

---

## 18. Respuestas del cuestionario (registro)

| # | Respuesta | Resolución |
|---|-----------|------------|
| 1 | C | Hub público con presencia/interacción |
| 2 | A | Dungeon en instancia independiente |
| 3 | C (ambas; amigos primero) | Party amigos → luego matchmaking |
| 4 | A | Multiplayer-ready desde el diseño |
| 5 | B | Places separados Hub / Dungeon |
| 6 | A ahora; B después | Pueblo persistente; más zonas luego |
| 7 | B | Salir = fin de run |
| 8 | A | WASD + 3ª MMORPG |
| 9 | A | Atacar en movimiento |
| 10 | A | Auto-attack |
| 11 | A | TAB = más cercano + ciclo |
| 12 | C | Click target opcional |
| 13 | A | Avatar R15 Roblox |
| 14–15 | C | Solo nombre + clase; skin del jugador |
| 16 | C | Base fija + roll menor |
| 17 | A | Ítems únicos de boss |
| 18 | C | Bind on Equip |
| 19 | A | Trade futuro sí |
| 20 | A | Loot auto a inventario |
| 21 | A | Cofre solo boss 5 |
| 22 | B | UI recompensa, no loot físico |
| 23 | B | Kit fijo, layout variado |
| 24 | C | Enemigos plantilla + variación |
| 25 | B | Nivel fijo por piso |
| 26 | A | Respec pueblo + oro |
| 27 | B | Una spec; no mezclar skills |
| 28 | A | 4 skills configurables |
| 29 | A | Prioridad sensación MMORPG |
| 30 | B | Progresión media |
| 31 | A (+ slot 3) | Cosmética + 3.er slot Robux; 2 gratis |
| 32 | A | Completable sin Robux (2 PJs) |
| — | Decisión posterior | **2 slots MVP; 3.º con Robux** |
| 33 | B | Alcance GDD + pequeñas mejoras |

---

## 19. Historial

| Fecha | Cambio |
|-------|--------|
| 2026-08-12 | Creación GDD Roblox |
| 2026-08-12 | Integración completa del cuestionario (33 decisiones) |
| 2026-08-12 | Slots PJ: 2 gratis MVP; 3.º desbloqueable con Robux |
| 2026-08-12 | **R0 completo** — documentado en `HU/HU-R0-Bootstrap-Experience.md` |
| 2026-08-12 | **R1 completo** — documentado en `HU/HU-R1-Combate-Base-Dummy.md` (defaults combate base) |
| 2026-08-12 | Producción pasa a **R2**; HU en `HU/HU-R2-Creacion-Personaje-Slots.md` |
| 2026-08-12 | **R2 completo** — creación/slots/persistencia implementadas |
| 2026-08-12 | Producción pasa a **R3**; HU en `HU/HU-R3-Skill-Framework.md` |
| 2026-08-12 | Catálogo de skills por clase/spec: `SKILLS_CATALOG.md` (42 skills, 6 tipos) |
| 2026-08-12 | Fix cámara detectado en desarrollo: HU-R3.1 (decisión A: LockCenter + GetMouseDelta) |
| 2026-08-12 | **R3 completo** — skill framework implementado (desde `SKILLS_CATALOG.md`) |
| 2026-08-12 | **R3.1 completo** — fix cámara WoW-like implementado |
| 2026-08-12 | Producción pasa a **R4**; HU en `HU/HU-R4-Inventario-Equip.md` |
| 2026-08-12 | **Política de assets** creada: `ASSETS_POLICY.md` + sección §17 en GDD (placeholders hasta R8, gratis + desarrollo propio) |
| 2026-08-12 | **R4 completo** — inventario/equip/BoE/rolls implementados |
| 2026-08-12 | Producción pasa a **R5**; HU en `HU/HU-R5-Vendors-Talentos.md` |
| 2026-08-12 | **Épica de assets** en evaluación: consultar al dev si produce assets; si confirma → HU dedicada |
| 2026-08-12 | Capacidad dev confirmada (modelos/materiales/UI/iluminación sí; animaciones solo librería) → **HU-ASSETS creada** |
| 2026-08-12 | **R5 completo** — vendors/economía/talentos implementados |
| 2026-08-12 | **HU-ASSETS completa** — producción estética (modelos/UI/iluminación + anims de librería) |
| 2026-08-12 | Producción pasa a **R6**; HU en `HU/HU-R6a-Dungeon-Preparacion.md` + `HU/HU-R6b-Dungeon-Core.md` (split en 2; XP/respawn en R6a) |
| 2026-08-12 | **Talentos v2** (árbol WoW + spellbook): SKILLS_CATALOG v2 (30 skills, 2 básicas + 2 nivel + 2 talento) + HU-R5.1 — reemplaza el sistema de talentos de R5 |
| 2026-08-22 | **HU-R5.1 completa** — árbol de talentos v2, skills aprendidas y spellbook implementados según reporte del equipo |
| 2026-08-22 | **HU-R5.2 completa**: stacking configurable (pociones maxStack 20, 20 slots = 20 pilas, uso/venta de 1 unidad); `rc011` implementado, sin modificar `rc010` |
| 2026-08-22 | **HU-R6a + HU-R6b completas** — preparación, XP/respawn, teleport, run de 5 pisos y exit/abandon implementados según reporte del equipo |
| 2026-08-22 | **HU-R7 creada** — boss del piso 5, cofre, uniques y UI de recompensa; depende de reclamar el cofre para completar la run |
| 2026-08-23 | **HU-R6.1 creada** — correr por defecto, toggle caminar con `U`/botón móvil y pisadas sincronizadas por material; se prioriza antes de R7 |
| 2026-08-23 | **HU-R6.1 completa** — movimiento correr/caminar y pisadas por material implementados según reporte del equipo |
| 2026-08-23 | **HU-R6.2 creada** — 2 slots genéricos de uso con `Z`/`X` y reset debug a nivel 1; se prioriza antes de R7 |
| 2026-08-25 | **HU-ESTETICA-01 creada** — equipamiento visual R15 + creación de 8 modelos iniciales del Paladín; se prioriza antes de ampliar el contenido de R8 |
| 2026-08-25 | **HU-R6.5 creada** — barra de XP en HUD, mochila (B) y equipo (C) separados + panel de stats |
| 2026-08-25 | **HU-ESTETICA-02 creada** — modelos de enemigos de la Helada (diseñador, solo modelos); dev enlaza `modelId` en `EnemyConfig` |
| 2026-08-25 | **HU-R6.6 creada** — animaciones de combate del jugador sobre el `AnimationRegistry` existente (auto-attack + casts); habilita fase de pruebas de animación |
| 2026-08-25 | **HU-ESTETICA-03 creada** — estructuras del pueblo nórdico antiguo (diseñador, solo modelos); dev integra conservando NPCs/portal/dummy |
| 2026-08-26 | **Implementadas según reporte del equipo:** R3.2, R3.3, R6.2, R6.3, R6.4, R6.5, R6.6, EST-01 y R7 |
| 2026-08-26 | **Pendientes:** EST-02 (modelos de enemigos de la Helada) y EST-03 (estructuras del pueblo nórdico) |
| 2026-08-26 | **HU-R6.7 creada** — animaciones de enemigos por familia (idle/walk/attack/special); framework data-driven para reemplazar modelos/animaciones por config |
| 2026-08-26 | **HU-R6.8 creada** — VFX básico de combate (proyectiles ranged, hits, números de daño, muerte de enemigos); sin assets externos |
| 2026-08-26 | **HU-R6.9 creada + SKILLS_CATALOG v2.1** — GroundAoE como zona persistente con daño por tick; SelfAoE alrededor del jugador; Torbellino → Self, Consagración/Ira divina → zona |
| 2026-08-26 | **Decisiones R8:** R8 se divide en R8a (Paladín) / R8b (Cazador) / R8c (Clérigo) / R8d (balance + assets + QA); iconos Gemini de fondo negro = finales; balance R8 = números coherentes/funcionando, fino en R9; no se espera a R6.7–6.9 ni EST-02/03 para crear las HUs |
| 2026-08-26 | **SKILLS_CATALOG v2.2 + árboles finales:** 6 specs aprobadas spec por spec (Castigo con Anillo de luz sagrada SelfAoE); HU-R8a creada |
| 2026-08-26 | **HU-R8b y HU-R8c creadas** — Cazador (Asalto + Puntería) y Clérigo (Misericordia + Cólera) con árboles finales y VFX por skill; R8 completo en 4 HUs |
| 2026-08-26 | **HU-R6.10 creada** — menú in-game (ESC) con "volver a selección de personaje" funcional; placeholders de volumen/gráficos/orden de UI |
| 2026-08-26 | **HU-ESTETICA-04 creada** — dirección de UI aprobada "Hearthbound Gold" (desde `Vandrheim-design.pen`); diseñador entrega sistema visual + 11 pantallas + assets; dev implementa después |
| 2026-08-26 | **EST-04 completada (diseño):** 12 pantallas (incl. Mobile HUD), estados de nodos/botones, componentes exportables 9-slice y checklist de assets — verificado en `Vandrheim-design.pen` |
| 2026-08-26 | **HU-ESTETICA-05 creada** — arco del Cazador (modelo diseñador + integración dev con EST-01); `Icon_Item_bow` agregado a ASSETS_LIST |
| 2026-08-26 | **R6.8 + R6.9 completas** (VFX básico y AoE zonas/Self) según reporte; **VFX con partículas confirmado** (dev: ParticleEmitter/Beam/Trail, client-side con autoridad server) → **VFX únicos por skill se integran en cada HU de clase (R8a/b/c)**; SFX/sonido en **R9** |
| 2026-09-11 | **R8a completa** — Paladín: 10 skills, árboles finales Protector/Castigo, MATKMult, SelfAoE, zona persistente y VFX únicos client-side por skillId; QA local OK; familias de VFX sagrados reutilizables para R8c |
| 2026-09-11 | **R8b completa** — Cazador: 10 skills, árboles finales Asalto/Puntería, Torbellino SelfAoE y VFX por skillId; iconos finales pendientes de carga/registro |
| 2026-09-17 | **R8c en QA** — Clérigo: 10 skills, Misericordia/Cólera, árboles finales, MATKMult, Ira divina GroundAoE y VFX por skillId; pendiente QA manual de builds/respec/rejoin; iconos del Clérigo como placeholders reemplazables hasta assets finales |
| 2026-09-18 | **R8c completa** — QA cerrado según reporte (builds/respec/rejoin OK); iconos de skills e ítems completos; quedan pendientes los **modelos e iconos de los 3 uniques del boss final** (frost_edge, frostbow, glacial_wand) y la **HU-R8d** |
| 2026-09-18 | **HU-ESTETICA-18 creada** — modelos e iconos de los 3 uniques del boss final (Filo de la Escarcha, Arco del Vendaval Helado, Vara del Invierno): diseñador produce assets, dev enlaza `visualModelId`/iconos por config — sin tocar loot ni gameplay |
| 2026-09-18 | **HU-ESTETICA-19 creada** — diseño a fondo del HUD de combate (números de daño/cura, indicador de target R3.3, AoE pre/activa R6.9, barra del boss R7, cooldowns, nivel, feedback de golpes) — solo diseñador, sin desarrollo |
| 2026-08-26 | **HU-ESTETICA-06 creada** — revisión del diseño de UI sobre EST-04 (solapamientos corregidos, iconos de mini-menú, rediseño del panel de stats, modernización general de las 12 pantallas); diseñador ejecuta, PM verifica |
| 2026-09-15 | **HU-ESTETICA-08/09/10 creadas** — diseño a fondo por panel en Pencil (solo diseñador, sin desarrollo, HUs independientes): 08 Panel de Talentos (árbol WoW con contenido real), 09 Grimorio (spellbook con estados y barra), 10 Ventana de Equipo y Stats (tecla C: 9 slots con equipo activo + desglose base/ítems/talentos + XP) |
| 2026-09-15 | **HU-ESTETICA-11/12 creadas** — diseño a fondo de Mochila (20 slots, pilas xN, rarezas, tooltips, atajos Z/X, estados) y Vendor (3 NPCs reales de VendorConfig, precios por rareza, compra/venta por unidad, respec del instructor) — solo diseñador, sin desarrollo |
| 2026-09-15 | **HU-ESTETICA-13 creada** — paquete de handoff de la UI para el dev: specs con valores exactos, mapeo de fuentes a Roblox (PlayfairDisplay/Inter/RobotoMono), assets exportables (9-slice, botones 3 estados, barras, iconos) y notas de adaptación (responsive, zona segura móvil, animaciones TweenService) |
| 2026-09-15 | **HU-ESTETICA-14 creada (dev)** — implementación del reskin de UI en Roblox desde el diseño de Pencil + paquete EST-13: 10 áreas (HUD, mochila, equipo/stats, talentos, grimorio, vendors, menú, selección/creación, recompensa, mobile), fuentes mapeadas, assets, animaciones Tween y regresión — sin tocar la lógica |
| 2026-09-15 | **HU-ESTETICA-15 creada (dev)** — reskin de las ventanas de vendor (subconjunto de EST-14): 3 ventanas independientes (consumibles/armero/instructor), referenciando el frame `BFPNI` del diseño de Pencil; precios y lógica intactos |
| 2026-09-15 | **EST-15 completa** — reskin de vendors implementado según reporte del dev (3 ventanas, similar al diseño) |
| 2026-09-15 | **HU-ESTETICA-16 creada (dev)** — reskin de la ventana de talentos, referenciando el frame `v1eO9E` del diseño (EST-08) y el paquete EST-13; árbol conectado, estados de nodo, tooltips y respec — sin tocar la lógica |
| 2026-09-15 | **EST-16 completa** — reskin de la ventana de talentos implementado según reporte del dev (árbol conectado y estados, similar al diseño) |
| 2026-09-15 | **HU-ESTETICA-17 creada (dev)** — reskin del grimorio, referenciando el frame `NXCBS` del diseño (EST-09) y el paquete EST-13; estados de skill, vista previa del loadout y tooltips — sin tocar la lógica |

---

## 20. Próximo paso de producción

1. **R0–R7 + R6.x + EST-01 cerrados** (gameplay completo: combate, progresión, inventario, dungeon con variantes/topología, boss, UI y animaciones de combate).  
2. Implementar **HU-R6.7**: framework de animaciones de enemigos por familia (deja el código listo para los modelos de EST-02).  
3. Implementar **HU-R6.8**: VFX básico de combate (hits, números de daño, proyectiles ranged, muerte).  
4. Implementar **HU-R6.9**: AoE — zonas persistentes de suelo (DoT) + SelfAoE (SKILLS_CATALOG v2.1).  
5. Implementar **EST-02 / HU-ESTETICA-02**: modelos de enemigos de la Helada (diseñador; dev enlaza `modelId`).  
6. Implementar **EST-03 / HU-ESTETICA-03**: estructuras del pueblo nórdico (diseñador; dev integra en el hub).  
7. Criterio de hecho EST: *cada piso tiene enemigos reconocibles y el hub se ve como un asentamiento nórdico*.  
8. **R8 puede planificarse/crearse en paralelo** (R8a Paladín ya creada); la implementación de R8 comienza cuando el loop base esté estable, sin esperar a EST-02/03 para avanzar con las HUs.

---

## 21. Épica de assets (confirmada)

> Estado: **CONFIRMADA** — HU-ASSETS (`HU/HU-ASSETS-Produccion-Estetica.md`). Capacidad del dev: modelos, materiales, colores, UI e iluminación **sí**; animaciones **solo de la Roblox Library** (no crea/riggea).

- **Foco:** modelos, materiales, colores/paletas, UI (HUD/ventanas/iconos), iluminación por Place + selección/registro de animaciones de la Library (~6 por skillType).
- **Fuente:** `ASSETS_POLICY.md` (§17). Placeholders hasta que existan los assets reales; reemplazo solo cambiando ids en config.
- **Transversal:** corre en paralelo con R5–R7; no bloquea gameplay.
- **Fuera:** crear/riggear animaciones, edición fina de meshes y crear paquetes nuevos de SFX; **VFX con partículas SÍ** (confirmado — ASSETS_POLICY §2/§6); R6.1 integra los sonidos de pisadas ya existentes en `FootstepSystem`.
