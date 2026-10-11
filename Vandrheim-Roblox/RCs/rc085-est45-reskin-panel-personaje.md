--[[
================================================================================
 REQUERIMIENTO TÉCNICO: rc085 — FASE EST-45 (HU-ESTETICA-45)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/estetica/HU-ESTETICA-45-Reskin-Panel-Personaje-Dev.md;
Pencil HUMWS, variante B, dentro de MqBFE;
GDD §§7, 12, 14 (R6.5), 17.1; EST-13, R6.27, R6.32 e ITEMS-01.
Estado: EN IMPLEMENTACIÓN (rc085 aprobado por el PO el 2026-10-10).
Fecha de emisión: 2026-10-10.
Requisitos previos: panel C existente, equipamiento R4/R6.5/ITEMS-01,
drag & drop rc083 y TooltipSystem rc084 disponible en Hub.
Aprobación: explícita del PO el 2026-10-10; decisiones de §10 cerradas.

================================================================================
1. DESCRIPCIÓN
================================================================================
Reskinear la ventana C de personaje según HUMWS, variante B: nombre e
identidad arriba, atributos agrupados al centro y nueve casillas de equipo
alrededor, con datos reales y el comportamiento de equipo existente.

Objetivo de la fase: reconstruir la presentación compacta de 480×455 del
Pencil conservando contratos de instancias, apertura, arrastre y servidor.
Criterio de hecho global: "El panel C replica la variante B con datos reales
del servidor, incluido CDR, sin romper equipamiento ni cálculo de stats".

Se consultaron DEV_PROMPT, DEVELOPER_GUIDE, PROJECT_STANDARD,
PROJECT_ARCHITECTURE, DATA_SCHEMA, RC-TEMPLATE y ASSETS_POLICY.
Se inspeccionaron el nodo HUMWS y su captura, StarterGui.EquipmentUI y
los clientes actuales. Solo se emite el RC en esta etapa.

================================================================================
2. ALCANCE (SÍ)
================================================================================
- Reskin de StarterGui.EquipmentUI.MainFrame: encabezado, StatsPanel,
  EquipmentPanel y CloseButton, preservando nombres y padres consumidos.
- Datos reales de nombre, clase, especialización, nivel y ocho atributos.
- Grupos RECURSOS (MaxHP/MaxMP), ATAQUE (ATK/MATK/CRIT/CDR) y
  DEFENSA (DEF/MDEF), con filas alternadas y valores alineados.
- Iconos reales de los nueve slots y texto de vacío; hover por borde.
- Integración del tooltip de ítem existente y tipo stat en TooltipSystem.
  Tooltips exclusivamente informativos, sin botones, según decisión del PO.
- Adaptación PC/mobile, ventana desplazable y cierre proporcional.
- Coordinación entre los clientes que hoy escriben estilos y dimensiones.
- Documentación técnica y registro de propagación entre places.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Cálculo/balance de atributos, cooldowns, talentos, inventario y equipo.
- Cambios de ItemConfig.SLOTS, reglas dual/2H, afinidades, BoE o validaciones.
- Nuevos remotos, profile, persistencia o servidor de estadísticas.
- Variantes A/C/D, otras ventanas o rediseño de bolsa.
- Producción de iconos, modelos o assets de panel.
- Botones en tooltips y nuevas acciones del personaje.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. El panel muestra la composición HUMWS: nombre, identidad, grupo central,
   nueve slots y X; paleta, proporciones y espaciados reproducen variante B.
2. Nombre/clase/spec/nivel y valores proceden de datos replicados reales;
   los ejemplos de Pencil no se usan como contenido.
3. CDR aparece siempre, incluido 0 %, y CRIT/CDR se formatean como porcentaje.
4. Recursos, ataque y defensa contienen las filas en el orden de §5.
5. Cada slot muestra su icono real o label vacío; mapping por nombre estable,
   conforme a la resolución propuesta en §10.
6. Equipar/desequipar y arrastrar desde bolsa conservan remotos, validación,
   highlight de destino válido/inválido y estados dual/2H.
7. Hover PC y mantener presionado móvil muestran tooltip de ítem o stat
   mediante el sistema único, sin ejecutar acciones de equipo.
8. Los nombres y jerarquías existentes se mantienen; C y cerrar conservan
   sus contratos, y el encabezado permite mover la ventana en PC/mobile.
9. En móvil ocupa como máximo 85 % de ancho y alto de la región disponible,
   sin textos solapados ni X sobredimensionada; labels ≥8.5 y valores ≥9.
10. No hay regresiones ni errores rojos en los flujos verificados. La
    implementación no se declara completa sin evidencia y estado de sync.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
5.1 Archivos y responsabilidades
Crear:
- ReplicatedStorage.Config.CharacterPanelUIConfig: medidas normalizadas,
  tokens de HUMWS, posiciones por slot, grupos, etiquetas y mínimos de texto.
  Sin lógica de equipo ni números de atributos.

Modificar:
- StarterGui.EquipmentUI: conservar MainFrame, Title, CloseButton,
  EquipmentPanel y StatsPanel; slots y sus SlotLabel/ItemName/SlotSeparator;
  siete filas de stat actuales. Añadir CooldownReductionStat y tres headers.
- StarterPlayer.StarterPlayerScripts.InventoryPresentationClient:
  presentación HUMWS, identidad, filas agrupadas y binding de stat tooltips.
  Eliminar de la vista C la expansión inline, glifos, hint y XP no presentes
  en Pencil; preservar instancias existentes ocultándolas cuando corresponda.
- StarterPlayer.StarterPlayerScripts.InventoryClient:
  integrar la fila CDR y señales de atributos si lo exige su render actual;
  conservar handlers, selección, drag, tooltip de ítem y apertura/cierre.
- StarterPlayer.StarterPlayerScripts.WindowLayoutClient:
  entregar dimensionado de EquipmentUI al layout específico; conservar focus,
  clamp y drag; configurar handle y CloseButton para el header de HUMWS.
- StarterPlayer.StarterPlayerScripts.UIReskinClient:
  evitar que el estilo genérico sobrescriba el layout específico de EquipmentUI,
  conservando fuentes BuilderSans y safe insets. Acotar exclusiones a este panel.
- ReplicatedStorage.Config.TooltipConfig y Shared.TooltipData/TooltipSystem:
  incorporar tipo stat y su proveedor en el sistema actual, conservando los
  tres tipos de rc084 y toda la gestión de hover/touch/lifecycle.
- PROJECT_ARCHITECTURE y DATA_SCHEMA al documentar la implementación.

5.2 Geometría y tokens
Referencia lógica 480×455; ratio 480/455. Convertir coordenadas a Scale,
con UIAspectRatioConstraint; no aplicar el viejo ratio móvil 1.70.
MainFrame #211916, radio10, borde #6B4A2B de1.
Nombre centrado x18/y11/ancho444, tamaño15 bold pergamino #F4EDE0.
Identidad x18/y39/ancho444, tamaño9 bold dorado #C89445.
Mantener BuilderSans/BuilderSansBold para todo por instrucción previa del PO,
aunque Pencil use varias familias. Medir texto y reservar espacio para X.

StatsPanel x100/y110/280×210, fondo #171311, radio8, borde madera.
Título ATRIBUTOS DEL PERSONAJE x12/y7/ancho256, tamaño12 bold.
Headers x10/ancho260/alto14: RECURSOS y29, ATAQUE y74, DEFENSA y145;
fondo #3A2C25, texto pergamino9.5 bold.
Filas alto13, y44/57/89/102/115/128/160/173:
MaxHP, MaxMP, ATK, MATK, CRIT, CDR, DEF, MDEF.
Alternancia #171311/#211916; labels dorados x18, tamaño8.5;
valores alineados a derecha x210/ancho50, tamaño9 bold.
En móvil preservar mínimos de texto y ajustar cajas/padding si lo requieren;
no reducir letras por debajo del mínimo al escalar.

EquipmentPanel conserva su padre y slots; su superficie puede ser transparente
y cubrir el área de composición para colocar cada hijo por coordenada.
Casillas74×74 con fondo #0E0D0C:
Helmet(14,96), Shoulders(14,178), Gloves(14,260), Legs(14,342);
Chest(392,96), Necklace(392,178), Ring(392,260), OffHand(392,342);
MainHand(203,342). Mapping propuesto en §10.
Icono de ítem inset5,64×64; imagen desde iconId/template existente,
sin reutilizar fotos de Pencil ni tratar visualModelId como imagen.
Borde según rareza real y feedback existente por borde; vacío #3A302A.
Vacíos descriptivos gris #8B8178, sin inventar ítems. Subir texto de6.5 del
Pencil al mínimo móvil8.5 y permitir dos líneas si es necesario.
Preservar offhand bloqueado por2H; nunca presentarlo como libre.

CloseButton x448/y10/22×22, fondo #3A2525, radio5, borde madera,
X pergamino. Mantener proporción y espacio de header; para touch puede
ampliarse el área transparente de interacción sin agrandar el dibujo ni
invadir nombre/identidad. DragHandle ocupa header excepto la zona de cerrar.

5.3 Datos y contratos
Consumir CharacterName/CharacterClass/CharacterSpec/CharacterLevel y
ClassConfig para labels reales; no quemar "Eirik", "Paladín" ni "Nivel16".
Mantener fuentes vigentes de HP/MP/ATK/MATK/DEF/MDEF/CRIT y señales de
Humanoid/Character. CDR desde Character:GetAttribute("CooldownReduction").
CRIT/CDR son fracciones y se muestran multiplicadas por100 únicamente al
formatear; no alterar valores replicados ni recalcular estadísticas.

InventoryData (S→C) conserva bag, equipment y statsBreakdown.
Para hp/mp/atk/matk/def/mdef/crit, el tooltip consume el desglose real:
base, equipment, talents, consumables, total. Mostrar categorías existentes
y total; no derivar aportes sumando iconos ni duplicar una instancia2H.
Añadir TooltipData.Stat con datos de stat y tipo stat admitido por
TooltipSystem.Show; reutilizar rows, posicionamiento, pointer, clamp y Bind.
CDR no tiene desglose en statsBreakdown actual: propuesta limitada en §10.
Cambios de equipo/atributos actualizan el proveedor y el tooltip visible;
desconectar señales del personaje anterior al respawn y limpiar bindings.

Remotos existentes:
- RequestEquipItem C→S: instanceId, preferredSlot opcional validado.
- RequestUnequipItem C→S: contrato vigente; conservar payload actual.
- InventoryData S→C: snapshot vigente.
Consultar un tooltip no emite estos remotos.
Server-authoritative: servidor conserva propiedad, nivel, slots,2H/dual,
BoE y cálculo. El cliente presenta datos y envía intenciones existentes.

5.4 PC/mobile y ownership
InventoryPresentationClient controla composición interna del personaje.
WindowLayoutClient conserva posición/focus/arrastre/clamp; sus defaults de
tamaño y cierre no deben competir con CharacterPanelUIConfig.
UIReskinClient aplica contratos globales sin recolorear o reposicionar
elementos específicos ya estilizados. No cambiar bolsa ni otras ventanas.

Dimensionar usando región disponible y ratio480/455; tope móvil85 % en
ambos ejes, con ScreenInsets seguros existentes. Conservar colocación PC
compatible con bolsa abierta y posibilidad de arrastrar.
Responder a AbsoluteSize/cámara/viewport por señales; recalcular tamaño
sin perder la posición arrastrada. Close y header no se solapan.

Hover PC muestra stats; touch-hold reutiliza umbral/cancelación del sistema.
Mover el dedo por encima del umbral cancela consulta; el arrastre de ítems
conserva prioridad y cancelación de rc083/rc084. No añadir controles al tooltip.
Usar task.defer/task.spawn/task.wait cuando corresponda; prohibido wait().

================================================================================
6. INTEGRACIÓN
================================================================================
- R2/R4/R6.5 e ITEMS-01 proveen identidad, snapshots y reglas de equipo.
- EST-13 conserva contratos de instancias y tokens; instrucción del PO
  mantiene BuilderSans en lugar de las familias antiguas.
- R6.27 aporta casillas/hover y tooltips; la HU45 específica fija #0E0D0C
  para estas casillas frente al negro puro del estándar anterior.
- R6.32/rc083 aporta drag & drop; rc084 aporta TooltipSystem informativo.
  Extender stat aquí porque HU45 lo pide expresamente, sin ampliar otros tipos.
- No recrear un tooltip independiente ni restaurar el ActionBar eliminado.
- Fallback nativo UICorner/UIStroke permitido por GDD17.1; usar assets
  registrados solo si existen, sin generar IDs ni sustituir iconos finales.

================================================================================
7. OPTIMIZACIÓN
================================================================================
Dos sesiones orientativas. Reutilizar ventana, filas y tooltip existentes.
Una config de presentación y señales de datos/viewport; evitar polls,
while true y reconstrucción completa por cada hover.
Crear headers/bindings una vez, actualizar propiedades con cambios reales.
Sin duplicar motor de atributos ni lógica server/client de equipo.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] Aprobación explícita del RC y resoluciones de §10 antes de código.
[ ] Comparación visual con captura HUMWS: composición, filas, slots y cierre.
[ ] Identidad y ocho valores reales; CDR0 visible y porcentaje correcto.
[ ] Tooltip stat con desglose real disponible, sin botones.
[ ] Flujos manuales PC/mobile: C, cerrar, drag de ventana, bolsa→equipo,
    equip/desequip, hover/hold cancelable, dual y arma2H.
[ ] Mobile retrato/paisaje: tope85 %, mínimos tipográficos y sin solapamientos.
[ ] Respawn/cambios de stats: valores y bindings actuales; sin errores rojos.
[ ] Registrar evidencia cuando se autorice QA; no ejecutar tests en emisión.
[ ] Actualizar PROJECT_ARCHITECTURE y DATA_SCHEMA, estado RC y reporte técnico.
    Nota en GDD corresponde al PM después de QA; DevAgent no edita GDD/HU.
[ ] Sync requerido por componentes compartidos: Hub84186294312317 y
    Dungeon_Helada125210265978348. Propagar CharacterPanelUIConfig,
    TooltipConfig, TooltipData, TooltipSystem; InventoryPresentationClient,
    InventoryClient, WindowLayoutClient, UIReskinClient y EquipmentUI
    a cada consumidor; verificar igualdad de Source/config/jerarquía y
    registrar revisión del panel tras teleport.
[ ] Solo Hub está conectado. PO rechazó abrir Dungeon en el trabajo previo.
    Mantener paquete de cambios para propagación posterior, sin volver a
    solicitar apertura ahora. No declarar sync completado ni HU íntegramente
    verificada mientras Dungeon permanezca pendiente.

================================================================================
9. ESTIMACIÓN
================================================================================
2 sesiones del dev, orientativo: composición/slots y adaptación;
datos/tooltips e integración. Supone aprobación de §10 y disponibilidad
del Hub. Sync y QA de Dungeon dependen de acceso posterior.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-ESTETICA-13, HU-R6.27, HU-R6.32/rc083, HU-ITEMS-01, R2/R4/R6.5,
HUMWS variante B, módulos rc084 instalados en Hub.
rc084 conserva pendientes de QA móvil y propagación; no se da por cerrado.

Decisiones aprobadas con rc085:
1. Slots: el listado escrito de HU45 difiere del ItemConfig.SLOTS real y de
   la distribución espacial de Pencil. ITEMS-01 confirma el orden real
   Helmet,Chest,Shoulders,Legs,Gloves,Ring,Necklace,MainHand,OffHand.
   Propuesta: conservar ese array y reglas, posicionando por nombre según
   HUMWS (§5.2). Priorizar la composición visual aprobada sin renombrar slots.
2. CDR: la HU afirma que ya existe en el panel, pero falta la fila.
   Añadir CooldownReductionStat usando el atributo replicado existente.
   Su tooltip mostrará total real y explicación del atributo; no inventar
   breakdown base/equipo/talentos que el snapshot no contiene. Los otros siete
   usan el desglose server real. Si se exige desgloseCDR completo, requerir
   definición del contrato por PM antes de ampliar al servidor.
3. Colores: reproducir énfasis de HUMWS: MaxHP/ATK/MATK/CRIT/DEF/MDEF verde
   #70C08B, MaxMP pergamino; CDR0 pergamino y CDRpositivo verde.
   Son reglas de presentación, sin modificar valores.
4. Conservar BuilderSans, ventana desplazable y tooltips sin botones según
   instrucciones previas del PO. Únicas adaptaciones visuales respecto al
   Pencil: tipografía y mínimos móviles/área touch descritos en §5.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]

