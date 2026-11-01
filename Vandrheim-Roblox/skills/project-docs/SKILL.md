---
name: project-docs
description: Crea, mantiene y revisa la documentación técnica de Vandrheim en Roblox Studio con navegación por dominio, contexto dirigido y RCs organizados. Se usa al preparar documentación, actualizar contratos después de un desarrollo o auditar su cumplimiento; no implementa gameplay por sí sola.
---

# Documentación de proyecto y navegación SDD

Mantener una referencia del estado vigente que permita localizar la tarea, su
implementación y sus contratos sin reconstruirlos a partir de reportes. Aplicar
el formato acordado en rc120 y las instrucciones actuales del proyecto.

## Alcance de la invocación

- Si se pide una revisión, inspeccionar y entregar hallazgos con evidencia. La
  revisión por sí sola no autoriza modificar documentación ni código del juego.
- Si se pide mantener o corregir documentación, actualizar los documentos
  afectados dentro del alcance autorizado. Preservar la tarea asignada y el
  trabajo de otros agentes.
- Crear un scaffold únicamente cuando se solicite y falte esa estructura.
  Invocar esta skill para leerla no es una orden de regenerar documentos.
- Trabajar la documentación técnica y los RCs en Studio. Esta skill no autoriza
  generar archivos LUA/RC locales, implementar una HU, guardar o publicar places.

## Entrada y contexto dirigido

Leer DEV_PROMPT y la HU/especificación asignada. Usar PROJECT_ARCHITECTURE y
DEVELOPER_GUIDE como índices; consultar después solo las páginas Architecture y
Schemas relacionadas. Ampliar la lectura al descubrir una dependencia concreta.
Consultar PROJECT_STANDARD para las reglas técnicas y RC-TEMPLATE para un RC.

GDD define intención y reglas de producto; SKILL_CATALOG contiene el catálogo de
skills; ASSETS_POLICY corresponde a assets. Consultarlos cuando la tarea los
requiera. History y los RCs históricos no son lectura inicial obligatoria.

DEV_PROMPT debe indicar la fuente y ruta exacta de la tarea, el trabajo solicitado
(análisis, emisión de RC o implementación), el RC aprobado cuando corresponda,
restricciones y resultado esperado. No sustituir su asignación al editar el
protocolo general. No interpretar una consulta como aprobación de implementación.

## Responsabilidad de cada documento

Raíz canónica: `Workspace.DevelopmentStandard`.

| Documento | Contenido y motivo de actualización |
|---|---|
| DEV_PROMPT | Asignación vigente y cómo tomarla; cambia al asignar tarea o ajustar el procedimiento. |
| DEVELOPER_GUIDE | Tipo de tarea → dominio → puntos de entrada; cambia con el recorrido de trabajo. |
| PROJECT_ARCHITECTURE | Jerarquía, responsabilidades y dependencias principales; cambia con la estructura. |
| DATA_SCHEMA | Reglas e índice de contratos; dirige a Schemas sin copiar todos los campos. |
| PROJECT_STANDARD | Políticas técnicas aprobadas; no alterarlas por conveniencia editorial. |
| RC-TEMPLATE | Formato técnico, estados, aprobación y emisión de RCs. |
| Architecture/dominio | Propósito, rutas reales, responsables, dependencias, configuración, invariantes y puntos de extensión del sistema. |
| Schemas/dominio | Campos, tipos, unidades, defaults, payloads, autoridad, persistencia y compatibilidad del contrato. |

Usar dominios estables y crear páginas solo si contienen información útil. En
Vandrheim, Architecture contiene PersonajesProgresion, CombateHabilidades,
MundoDungeon, InventarioEquipo, Interfaz, Social, Economia, Assets y Publicacion.
Schemas agrupa PerfilPersistencia, ItemsYEquipo, ProgresionYCombate, DungeonYGrupo,
RemotesYEstadoSesion y EconomiaYTransacciones. Verificar su existencia actual.

Actualizar una descripción en su ubicación canónica. No añadir una sección por
HU/RC, cronologías, transcripciones, aprobaciones duplicadas, capturas de QA o
reportes rutinarios a los mapas. Un cambio de color, texto o padding no requiere
otra entrada arquitectónica. Un nuevo parámetro de configuración sí puede
requerir actualizar el esquema del dominio, aunque no cambie el mapa general.

## Contratos verificables

- Contrastar rutas, nombres y mayúsculas con las instancias y fuentes actuales.
  Distinguir rutas de instancias, claves de tablas, atributos y nombres
  conceptuales de contratos. No describir una agrupación conceptual como un
  campo real ni una función local como API exportada.
- Distinguir plantillas de Edit de UI o remotes creados en runtime; su ausencia
  en Edit no justifica duplicarlos. Identificar el productor y consumidor.
- Documentar tipos, opcionalidad, unidades, defaults y reglas de cada contrato
  afectado. Para valores exactos de balance, remitir a la configuración vigente
  en vez de mantener otra tabla completa en el mapa.
- Separar configuración compartida, perfil durable, estado de sesión y payloads.
  Un objeto visual o un snapshot del cliente no es autoridad de persistencia.
- Preservar invariantes relevantes al condensar: propietario/lease, CAS,
  idempotencia, reservas, puntos de compromiso, reconciliación y migraciones.
  Aclarar cuándo un getter devuelve copia y cuándo entrega el draft transaccional.
- Si el código y la especificación aprobada discrepan, explicar el conflicto.
  No modificar gameplay para hacerlo coincidir dentro de una tarea documental.
- Si una decisión de producto no está cerrada en HU/GDD, identificarla como
  pendiente; no inventar alcance ni defaults.

## Organización de RCs

Cada RC tiene un único destino principal bajo `Requirement`, en una carpeta
funcional estable. Categorías actuales: Documentacion, PersonajesProgresion,
CombateHabilidades, MundoDungeon, InventarioEquipo, Interfaz, Social, Economia,
Assets y Publicacion. Evitar carpetas por fecha, agente o sprint.

Ejemplo: `Requirement.MundoDungeon.rc-mejora-variantes-dungeon`.

- El Name es `rc-titulo-descriptivo`: minúsculas, sin tildes ni espacios y con
  guiones; no incluye el ID numérico.
- Conservar el ID `rcNNN` en el encabezado y en el atributo `RCId`. No renumerar
  ni reciclar IDs. Para emitir el siguiente, revisar atributos/encabezados de
  todo el árbol y el índice, no solo los hijos de la raíz.
- Todo RC e índice es `Script` con `Disabled=true` y Source compuesto solo por
  comentarios Luau válidos. Nunca ModuleScript, StringValue o lógica ejecutable.
- `Requirement.INDEX` contiene ID, sección, título corto, Name y ruta exacta.
  Cada RC aparece una vez; el índice no duplica estado, aprobación ni aceptación.
- Conservar contenido y aprobaciones al mover/renombrar; comprobar consumidores
  antes de convertir tipos y actualizar referencias afectadas. No ejecutar RCs.

Conservar los diez apartados de RC-TEMPLATE:

1. Descripción.
2. Alcance.
3. Fuera de alcance.
4. Criterios de aceptación.
5. Implementación técnica.
6. Integración.
7. Optimización.
8. Definición de hecho y verificación.
9. Estimación.
10. Dependencias.

Usar N/A donde corresponda. Estados: ABIERTO → EN IMPLEMENTACIÓN → COMPLETO
(verificado el día indicado). Anotar implementación parcial, QA o derivación
pendientes aparte, sin inventar otro estado. Marcar solo comprobaciones realmente
realizadas y no declarar completo mientras falte validación o aceptación requerida.

La HU/especificación define el objetivo; el RC concreta qué, dónde y cómo. Emitir
el RC cuando se solicite o corresponda al flujo asignado. Implementar después de
la aprobación explícita, sin volver a pedir una aprobación ya otorgada. Resolver
ampliaciones materiales de alcance antes de ejecutarlas.

## Escritura y comprobación

Mantener la documentación como Scripts deshabilitados con Source de comentarios;
escoger delimitadores de bloque que no se cierren accidentalmente con ejemplos
incluidos. En scripts abiertos, usar ScriptEditorService.UpdateSourceAsync y
GetEditorSource para respetar la fuente actual del editor. Comprobar tras el
refresco que editor y DataModel contienen el resultado esperado; no sobrescribir
una edición concurrente.

Verificar rutas de navegación, correspondencia entre RCId/encabezado/índice,
unicidad y los contratos modificados contra código/configuración. Compilar las
fuentes documentales sin ejecutar las funciones compiladas cuando esté disponible
esa comprobación; verificar además que no haya tokens ejecutables fuera de los
comentarios. No hace falta iniciar Play para una validación puramente documental.

Comunicar resultados y límites en la entrega. La QA técnica queda en el chat y
en el checklist pertinente del RC; GDD se actualiza por decisiones de producto.
No crear otro reporte rutinario para demostrar que se mantuvo la documentación.

## Respaldo y places en Vandrheim

Para una migración documental que lo necesite, conservar una única copia íntegra
y recuperable antes de sustituir/mover fuentes. Los datos de respaldo viven en
`ServerStorage.DevelopmentStandardHistory`; `Workspace.DevelopmentStandard.History`
es su entrada de navegación. No almacenar chunks StringValue de fuentes en
Workspace, donde se replicarían a los clientes. Preservar procedencia y verificar
reconstrucción exacta si se fragmentan por límites técnicos. No ejecutar el
respaldo ni convertirlo en otra especificación vigente. No crear un snapshot por
cada tarea ordinaria.

El Hub es la fuente de trabajo y Dungeon_Helada su copia derivada según rc048 y
Architecture.Publicacion. Para cambios compartidos, el RC identifica módulos,
consumidores y verificación requerida. El PO guarda, deriva y publica; esta skill
no autoriza hacerlo desde MCP ni declarar QA publicada sin evidencia.
