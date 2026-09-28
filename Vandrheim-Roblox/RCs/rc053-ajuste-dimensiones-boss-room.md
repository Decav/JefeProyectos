--[[
================================================================================
 REQUERIMIENTO TÉCNICO: rc053 — FASE DUNGEON (Extensión transversal HU-R6.3)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: Solicitud PM aprobada en conversación + HU-R6.3 (baseline de variantes,
  sala final y decoración) + GDD §12, “Generación de layout (piso)”.
Estado: EN IMPLEMENTACIÓN (código editado en Hub; QA dinámica pendiente).
Requisitos previos: HU-R6a/rc009 y HU-R6.3/rc019 completadas.
Nota de trazabilidad: DEV_PROMPT no contiene una HU formal nueva para este
  cambio. Este RC documenta la solicitud aprobada y extiende HU-R6.3; reemplaza
  únicamente su regla de que las salas de mini-boss de pisos 1–4 usan el mismo
  tamaño que las salas normales.

================================================================================
1. DESCRIPCIÓN
================================================================================
Aumentar el ancho, profundidad y altura libre de la sala final/de jefe, solo
para dicha sala y en las tres variantes de dungeon (Corredor, Caverna y Salon).
El objetivo es que los jefes, en especial los modelos grandes, puedan combatir
sin chocar con el techo o con geometría decorativa sobre el área de combate.

Objetivo de la fase: aplicar dimensiones especiales a la sala marcada como final
sin cambiar salas normales, pasillos ni el resto del contenido de la variante.
Criterio global: cada boss room conserva su acceso y su composición visual, pero
ofrece el espacio horizontal y vertical definido en este RC.
También se cierra la franja superior de los accesos entre el pasillo y la boss
room, sin elevar el pasillo ni reducir el ancho útil del paso.

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Añadir overrides de tamaño de boss room por variante, en la configuración
  data-driven existente:
  - Corredor: X×Z = 50×50 studs; wallHeight = 20 studs.
  - Caverna: X×Z = 100×100 studs; wallHeight = 24 studs.
  - Salon: X×Z = 88×88 studs; wallHeight = 22 studs.
  Se conserva el componente Y actual de roomSize; la altura libre se gobierna
  con wallHeight.
* Aplicar el override únicamente al generar la sala final/de jefe. Mantener las
  dimensiones normales de cada variante para las demás salas.
* Usar las dimensiones efectivas de la boss room para su piso, límites,
  paredes/techo, conexión de entrada y BossRoomTrigger.
* Sellar la franja superior de cada apertura de la boss room cuando su altura
  supera la del pasillo: desde la cara superior del techo del pasillo hasta la
  cara inferior del dintel, manteniendo libre el paso normal.
* Mantener el espacio de combate central libre de geometría colisionable que
  invada la altura libre. En Caverna, evitar que formaciones del techo
  colisionables invadan el volumen de combate; limitar pilares al techo efectivo.
* Conservar la plataforma central, la iluminación roja y el flujo de encuentro
  ya existentes.
* Verificar las tres variantes, incluidos los accesos y el espacio de combate.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
* Salas normales, pasillos, densidad de packs, distribución general del layout
  y selección/semilla de variante.
* Cambios a modelos, escala, atributos, estadísticas, IA, daño o balance de
  jefes y mini-bosses.
* Rediseñar o escalar la plataforma central, cambiar luces, materiales o paletas.
* Nuevas decoraciones, assets, variantes, pisos, encuentros o reglas de combate.
* Cambios a teleport, Places, UI, remotes, persistencia o publicación/sync.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. La boss room de Corredor se genera con huella X×Z de 50×50 studs y
   wallHeight de 20 studs.
2. La boss room de Caverna se genera con huella X×Z de 100×100 studs y
   wallHeight de 24 studs.
3. La boss room de Salon se genera con huella X×Z de 88×88 studs y
   wallHeight de 22 studs.
4. Las salas que no son finales conservan las dimensiones actuales de cada
   variante: Corredor 40×40/12, Caverna 80×80/16 y Salon 70×70/14.
5. La geometría de piso, paredes/techo, entrada y BossRoomTrigger coincide con
   las nuevas dimensiones; la franja sobre el pasillo queda sellada, sin huecos
   hacia el exterior, bloqueos del paso normal ni solapamientos problemáticos con
   el conector o las salas adyacentes.
6. El modelo de mini-boss más alto actualmente configurado (Señor de la
   Escarcha, bounding box aproximado de 11,5 studs) puede combatir en la sala
   sin quedar bloqueado por el techo. El área central queda libre de obstáculos
   colisionables superiores; las decoraciones perimetrales no bloquean el combate.
7. Las formaciones colisionables del techo de Caverna y los pilares de las salas
   de jefe no reducen la altura libre definida ni sobresalen dentro del techo.
8. La plataforma central, la iluminación roja y el disparo/flujo del encuentro
   se conservan.
9. La generación mantiene el mismo resultado para un mismo seed; ampliar la
   boss room no modifica el tamaño ni la decoración de las demás salas.
10. La revisión en Studio de las tres variantes no produce errores rojos ni
    fallos de generación.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
* Configuración: extender ReplicatedStorage.Config.DungeonVariantConfig con
  dimensiones específicas de boss room para Corredor, Caverna y Salon. No
  modificar roomSize/wallHeight globales de cada variante.
* Generación: en ServerScriptService.Services.FloorService, resolver una copia
  local de las dimensiones efectivas al generar la sala final (roomData.isBoss).
  No mutar la tabla compartida de configuración, para que el override no alcance
  las siguientes salas ni pisos.
* Dimensiones cerradas (studs):
  Variante | bossRoom X×Z | bossWallHeight
  Corredor | 50×50 | 20
  Caverna  | 100×100 | 24
  Salon    | 88×88 | 22
  roomSize.Y conserva el valor existente; wallHeight determina la altura de
  paredes/techo y la altura libre.
* Recalcular la geometría y el punto de conexión usando los límites efectivos de
  la boss room, preservando la continuidad del corredor y el acceso existente.
  Dimensionar BossRoomTrigger desde esos mismos valores efectivos.
* En FloorService, crear un panel colisionable por cada intervalo de apertura de
  la boss room, usando el mismo mergeOpeningIntervals que las paredes. El panel
  va desde el techo normal del pasillo hasta la cara inferior del dintel y se
  solapa 0.1 studs con ambos para cerrar juntas; no cambia la altura del pasillo.
* Decoración: mantener el tema/flags de la variante, pero excluir o recolocar
  cualquier pieza superior colisionable que interseque el volumen central de
  combate. Asegurar que pilares y piezas perimetrales terminen bajo el techo.
* Mantener plataforma y luz roja con sus valores actuales. No crear remotes,
  atributos persistentes ni estado de run nuevo. El servidor sigue siendo la
  autoridad del layout y del encuentro.
* No hay cambios de UI; no aplica lógica específica de PC o Mobile.

================================================================================
6. INTEGRACIÓN
================================================================================
Se apoya en FloorService, DungeonVariantConfig y la generación por seed de
HU-R6a/rc009 y HU-R6.3/rc019. La variante activa se conserva durante la run.
El ajuste se aplica al nodo final marcado como boss room y deja intactos los
pasillos y salas regulares. Este RC actualiza el tamaño de las salas de
mini-boss de pisos 1–4 respecto de la regla original de HU-R6.3; no altera su
flujo de encuentro.

================================================================================
7. OPTIMIZACIÓN
================================================================================
Mantener el cambio data-driven y limitado a una sola sala final por piso. Reusar
el generador, decoradores y trigger existentes; no duplicar la construcción de
salas ni crear bucles de actualización. La selección del seed, el número de
instancias y el contenido de las otras salas no cambian. La estimación no incluye
publicación ni sincronización de Places.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] DungeonVariantConfig define el tamaño/altura aprobados para las tres boss rooms;
    comprobación de valores y preservación de dimensiones regulares ejecutada en Edit.
[x] FloorService usa la geometría efectiva del nodo final para sala, conexiones,
    puerta y trigger; verificación estática de las llamadas modificadas.
[x] FloorService sella con paneles colisionables la franja superior de las
    aperturas de la boss room, siguiendo los intervalos reales y sin elevar los
    pasillos; revisión estática del origen y los límites del panel.
[x] Las masas colisionables del techo de Caverna no colisionan en boss room; los
    pilares de boss room quedan debajo del techo efectivo.
[x] La decoración del nodo final usa un RNG determinista separado para no desplazar
    la secuencia aleatoria de los conectores.
[x] PROJECT_ARCHITECTURE y DATA_SCHEMA registran el override rc053.
[ ] QA runtime: generar las tres variantes y comprobar combate del mini-boss más alto,
    entrada, puerta y ausencia de bloqueos.
[ ] Output limpio respecto de esta HU. Prueba en Edit no pudo cargar FloorService
    por dependencias de EnemyService/SkillService; no se inició Play ni se guardó/
    publicó el place desde MCP.
[ ] Actualizar el GDD/registro final después de completar QA, según el DoD.

================================================================================
9. ESTIMACIÓN
================================================================================
1 sesión orientativa para los overrides, ajuste de dimensiones dependientes y
verificación de las tres variantes. No incluye QA de publicación.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-R6a/rc009 (FloorService y generación por seed), HU-R6.3/rc019
(variantes, dimensiones y decoración) y la configuración actual
DungeonVariantConfig. No hay una HU formal nueva asociada; requiere conservar
la aprobación del PM de estas dimensiones.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
