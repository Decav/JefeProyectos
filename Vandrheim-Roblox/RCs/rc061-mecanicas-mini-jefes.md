--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc061 — FASE R6.18 (HU-R6.18)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU-R6.18 (HU/HU-R6.18-Mecanicas-Mini-Jefes.md) + GDD §§8, 14, 17
  + PROJECT_ARCHITECTURE + DATA_SCHEMA + ASSETS_POLICY.
Estado: ABIERTO (pendiente de implementación).
Requisitos previos: HU-R6a/rc009 (EnemyService y mini-jefes), HU-R6.7
  (EnemyAnimationService), HU-R6.8/R6.9 (VFX/zonas), HU-R7/rc021
  (BossSpecialTelegraph) y HU-ESTETICA-31 (patrón de mecánicas del boss final).

================================================================================
1. DESCRIPCIÓN
================================================================================
Dar mecánicas propias y esquivables a dos mini-jefes de Helada: golpe fuerte e
invocación para miniboss_frost_lord (piso 4), y tifón frontal para
miniboss_blizzard_wraith (piso 3). Las áreas de impacto se muestran en suelo
durante la carga; daño y decisiones permanecen bajo autoridad del servidor.

Objetivo de la fase: extender de forma data-driven EnemyConfig/EnemyService y
reutilizar los contratos visuales de telegraph/VFX sin alterar otros enemigos.
Criterio de hecho global: ambos mini-jefes usan mecánicas telegrafiadas,
esquivables y configurables, con QA solo/party según HU-R6.18 y bandas R8d.

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Añadir en ReplicatedStorage.Config.EnemyConfig la configuración de habilidades
  de miniboss_frost_lord y miniboss_blizzard_wraith, incluyendo skillId, cooldown
  fijo, duración de carga, geometría/daño y VFX ID. Dejar el slot de animación como
  plantilla `rbxassetid://` para completar cuando el usuario entregue los IDs.
* En ServerScriptService.Services.EnemyService, ejecutar mecánicas de mini-jefes
  sin cambiar la especial GroundAoE del boss final ni la IA de enemigos regulares.
  El servidor fija la dirección/área del cast, espera la carga y vuelve a medir
  posiciones al impacto; evade quien salga del área. Aplicar daño con damagePlayer
  y el escalado/mitigación existentes.
* Señor de la Escarcha: golpe frontal con carga 1.2 s, rectángulo de 8 studs de
  ancho × 14 de profundidad centrado frente al mini-jefe y daño objetivo 1.5× de su
  golpe normal (actualmente 40; objetivo bruto ≈60); telegraph tenue rojo. Cooldown
  fijo del golpe: 9 s. Invocar un helada_frost_knight por cast, máximo 2 vivos;
  cooldown fijo: 22 s; XP del invocado: 25% de su valor XP normal; sin loot.
* Espectro de Ventisca: tifón frontal en cono, carga 1.5 s, daño objetivo 2× su
  golpe normal (actualmente 30; objetivo bruto ≈60); alcanzar a todos los
  participantes elegibles del mismo DungeonRunId que estén en el cono al impacto.
  Rango 25 studs, ángulo 75°, cooldown fijo 10 s.
* Extender el payload visual existente BossSpecialTelegraph S→C para comunicar
  shape/dirección/dimensiones/carga y phase=warning/impact con un castId efímero.
  DungeonClient presenta el cono o rectángulo rojo translúcido en suelo y limpia
  el marcador al impacto; la geometría visual nunca decide el daño.
  Reutilizar el remote, sin añadir uno nuevo salvo necesidad técnica demostrada.
* Configurar VFX de impacto mediante el pipeline existente (VFXConfig/VFXClient o
  equivalente ya integrado). La creación/integración de animaciones queda diferida:
  conservar solo la plantilla `rbxassetid://`, sin crear ni publicar animaciones.
* Mantener metadatos de DungeonRunId/PartySize y ciclo de vida normal del invocado,
  sin alterar la progresión del piso; XP al 25% del valor normal y loot deshabilitado.
* Actualizar DATA_SCHEMA y PROJECT_ARCHITECTURE tras implementación.
* Hub (PlaceId 84186294312317) es fuente única de verdad. Los módulos compartidos
  modificados deben propagarse a Dungeon_Helada mediante el release derivado rc048;
  este RC no publica ni modifica el place destino.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
* Cambiar mecánicas, stats, loot o IA de otros enemigos, mini-jefes o boss final.
* Cambiar el daño básico, mitigación, fórmulas de combate, party scaling global,
  presupuestos de piso, distribución/variantes de dungeon o reglas de solo.
* Crear habilidades de jugador, remotes nuevos sin necesidad, persistencia,
  campos de Profile/DataStore, assets de terceros sin licencia ni audio/SFX.
* Crear, publicar o integrar animaciones. El usuario completará los IDs
  posteriormente. También quedan fuera assets de terceros sin licencia y audio/SFX.
* Publicar/guardar en Roblox ni completar el sync a Dungeon como parte del RC.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. El golpe del Señor de la Escarcha muestra durante 1.2 s un rectángulo frontal
   rojo tenue; al concluir, impacta solo a personajes aún dentro del rectángulo.
2. El golpe aplica el factor 1.5× respecto del golpe normal del template
   (base actual 40; bruto objetivo ≈60), conserva mitigación/party scaling y es
   evadible desplazándose fuera del área.
3. El Señor de la Escarcha invoca un helada_frost_knight por activación y nunca
   supera 2 invocados vivos; con el límite alcanzado, no invoca otro.
4. El Espectro de Ventisca muestra durante 1.5 s un cono rojo tenue; al concluir,
   daña a todos y solo a los jugadores del mismo run que sigan dentro del rango y
   ángulo configurados. Salir durante la carga evita el impacto.
5. El tifón aplica el factor 2× respecto del golpe normal del template
   (base actual 30; bruto objetivo ≈60), usando mitigación/party scaling existentes.
6. Cooldowns, dimensiones, carga, daño, summon y VFX viven en configuración; no se
   agregan números de gameplay hardcodeados en IA/client. El slot de animación queda
   como `rbxassetid://` y no se carga hasta que el usuario comparta los IDs reales.
7. Invocados no dan loot. XP respeta el valor configurado. Sin cambio de puertas,
   contadores ni cierre de piso no aprobado por HU.
8. El golpe usa exactamente 8×14 studs y cooldown fijo 9 s; tifón usa 25 studs,
   ángulo 75° y cooldown fijo 10 s; invocación tiene cooldown fijo 22 s.
9. Solo y party en pisos 3–4: no one-shot; contrastar daño recibido y TTK con HU-R6.18
   y bandas R8d disponibles en rc051 (mini-boss piso 3: 30–45 s; piso 4: 45–60 s).
10. Output sin errores atribuibles; configuración y remotes inválidos se validan en
   servidor, y el cliente solo dibuja telegraph/VFX.
11. PC y Mobile muestran la misma zona/ventana de esquiva; no se cambia input/UI.
12. Actualizar DATA_SCHEMA/PROJECT_ARCHITECTURE y verificar Source/versión de los
    módulos del Hub y Dungeon_Helada antes de release.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
* Fuente de datos actual: EnemyConfig ya define miniboss_frost_lord con damage=40
  y miniboss_blizzard_wraith con damage=30; ambos tienen isBoss=true. EnemyService
  ejecuta la ruta isBoss y BossSpecialTelegraph existente. El telegraph actual es
  un cilindro azul radial, por lo que DungeonClient requiere forma parametrizada.
* Separar el scheduler de minibossSkills de template.special del boss final. Cada
  skill debe guardar su cooldown/configuración y VFX por key, y usar
  task.wait/task.spawn/task.delay (prohibido wait()). No cargar ni reproducir el
  template de animación. No duplicar loops activos ni invocar daño desde cliente.
* Hit-test server-side en XZ con base fijada al comenzar la carga:
  - cono: distancia <= range y dirección dentro de angle configurado;
  - rectángulo: proyecciones forward/right dentro de depth/width configurados.
  Volver a validar Character/Humanoid vivo y membresía de run al impacto. Para party,
  no limitarse al target inicial; evaluar todos los miembros del run. No aceptar
  geometría ni daño enviado por cliente.
* Summon: llamar al flujo EnemyService existente con templateId helada_frost_knight,
  heredar owner/run/party metadata, contar vivos atribuidos a ese miniboss, evitar
  duplicar el límite tras carreras concurrentes, suprimir loot y tomar XP desde config.
* Reusar BossSpecialTelegraph y DungeonClient para shape visual local, con CanCollide,
  CanTouch y CanQuery deshabilitados. phase=warning/impact coordina la carga y limpia
  el marcador al impacto; rojo/transparencia son presentación, jamás autoridad.
  Reusar VFXService/VFXClient para el VFX de impacto; no crear remotes.
* Animación: no crear, editar, publicar ni integrar animaciones en esta HU. Dejar
  únicamente el template `rbxassetid://` para que el usuario lo reemplace cuando
  entregue los IDs; no intentar cargar/reproducir ese template.
* Actualizar DATA_SCHEMA con minibossSkills/summonConfig/coneAttack y el payload
  telegraph; PROJECT_ARCHITECTURE con flujo servidor, cliente y sync derivado.
* Decisiones cerradas por PM (2026-09-27): cooldowns determinísticos 9/10/22 s;
  cono 25 studs/75°; rectángulo 8×14 studs; summon XP 25% del valor normal y sin
  loot. Configurar y probar transparencia del marker en QA visual; no afecta
  gameplay ni queda como bloqueo de implementación. Animaciones quedan diferidas;
  solo se conserva `rbxassetid://` hasta recibir IDs del usuario.
* La referencia R8d de balance está documentada en GDD §14; rc051 concreta TTK de
  miniboss por piso (30–45 s P3, 45–60 s P4) y TTD. No cambiar el balance global.
  La verificación final debe informar medidas observadas y cualquier divergencia;
  no declarar R8d cerrado por esta HU.

================================================================================
6. INTEGRACIÓN
================================================================================
Depende de EnemyConfig, EnemyService, EnemyAnimationService/EnemyAnimationConfig,
VFXConfig/VFXService/VFXClient, BossSpecialTelegraph, DungeonClient, XPService,
DungeonRunId/PartySize y FloorService. HU-R6.18 crea mecánicas para mini-jefes de
pisos 3–4, y deja intacto el encounter de R7 en piso 5. Reutiliza el patrón de
telegraph de HU-R7/rc021. Hub es fuente; Dungeon_Helada es consumidor derivado.

================================================================================
7. OPTIMIZACIÓN
================================================================================
Usar el loop ya existente del mini-jefe y scheduler acotado por enemigo; cancelar
callbacks si el modelo muere o se desparenta. Sin polling nuevo continuo, sin
scans globales por frame, sin duplicar IA común, ni límites de efectos no acotados.
El telegraph vive solo durante la carga/impacto y se limpia por lifetime incluso si
el jugador se desconecta o el enemigo muere.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] HU local y DEV_PROMPT de Studio revisados; contexto técnico y políticas consultados.
[x] RC061 creado antes de codificar; estado ABIERTO.
[x] Decisiones PM de cooldown, geometría y XP/loot cerradas; animaciones diferidas
    con template `rbxassetid://` hasta recibir IDs del usuario.
[ ] QA del golpe del piso 4: carga, rectángulo, evade, daño mitigado, cooldown.
[ ] QA invocación: máximo 2, sin loot, XP configurada y progresión de piso intacta.
[ ] QA tifón piso 3: cono, rango/ángulo, todos los miembros, evade y daño mitigado.
[ ] Solo + party; medir TTK/TTD contra bandas R8d y revisar ausencia de one-shot.
[ ] PC + Device Simulator/mobile; telegraph claro, visible y sin errores rojos.
[ ] Regresión R7 boss piso 5, IA regular, puerta/progreso y VFX existentes.
[ ] Actualizar DATA_SCHEMA/PROJECT_ARCHITECTURE; sincronizar módulos a Dungeon_Helada,
    verificar identidad/Source y registrar QA de ambos places antes de publicar.
[ ] Actualizar GDD tras QA; no tocarlo antes de completar la definición de hecho.
[ ] Sin publicación ni guardado desde MCP.

================================================================================
9. ESTIMACIÓN
================================================================================
2–3 sesiones orientativas según HU-R6.18: configuración, IA/mecánicas, telegraph,
VFX y balance. No incluye creación/integración de animaciones ni publicación.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-R6a/rc009, HU-R6.7, HU-R6.8/R6.9, HU-R7/rc021, HU-ESTETICA-31, EnemyConfig,
EnemyService, EnemyAnimationService, VFXConfig/VFXService/VFXClient,
BossSpecialTelegraph/DungeonClient, PartyService/GetRunMembers, XPService,
FloorService, GDD §14 y ASSETS_POLICY.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
