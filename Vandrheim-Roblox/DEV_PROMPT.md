--[[ DEV_PROMPT
================================================================================
PLANTILLA MAESTRA DE PROMPT TÉCNICO - PROYECTO
================================================================================

Actúa como un **Senior Software Engineer** especializado en Roblox Studio para
este proyecto.

### 1. NUEVA TAREA A IMPLEMENTAR:

[

]

---

=== 2. GENERACIÓN DE RC OBLIGATORIA (ANTES DE CODIFICAR): Antes de escribir una
sola línea de código, **DEBES** crear el Requerimiento Técnico (RC) de la HU del
punto 1 (dentro de la carpeta RCs), siguiendo el formato de
`RC-TEMPLATE`:

1. Leer `RC-TEMPLATE` y seguir su estructura **exactamente** (comentario Luau,
   secciones 1 a 10).
2. Numerar secuencialmente: `rc001`, `rc002`, `rc003`, … (revisar los RC
   existentes para no repetir).
3. Derivar el contenido **solo** de la HU del punto 1 + GDD (secciones citadas).
   Prohibido inventar alcance, features o defaults no respaldados.
4. Header del RC:
   - `REQUERIMIENTO TÉCNICO: rc[NUM] — FASE R[N] (HU-R[N])`
   - Fuente: HU-R[N] (archivo) + GDD (secciones).
   - Estado: `ABIERTO (pendiente de implementación)`.
5. Mapeo obligatorio HU → RC según `RC-TEMPLATE` (Descripción ← Narrativa
   INVEST, Alcance ← "Incluye", Fuera de alcance ← "No incluye", Criterios ←
   Gherkin, Implementación ← Contratos/defaults, Integración ← Dependencias, DoD
   ← DoD de la HU).
6. Guardar el RC en `RCs/rc[NUM]-[slug].md` y/o como comentario al
   inicio del código de la tarea.
7. Si la HU tiene ambigüedades o faltan defaults: usar los defaults cerrados
   documentados en la HU/GDD; si no existen, listarlos como pendientes y NO
   asumir en silencio.

---

=== 3. PROTOCOLO DE CONTEXTO OBLIGATORIO: Antes de escribir una sola línea de
código, **DEBES** leer, memorizar y aplicar los siguientes documentos del
proyecto para garantizar la coherencia:

- **`DEVELOPER_GUIDE`**: Para identificar los archivos correctos en el **Mapa de
  Responsabilidades**.
- **`PROJECT_STANDARD`**: Para cumplir con el estándar de hilos (`task.wait`),
  UI (`Scale`) y `Naming`.
- **`DATA_SCHEMA`**: Para validar esquemas de datos (clases, skills, talentos,
  ítems, mazmorra, loot) si la tarea involucra objetos o inventario.
- **`PROJECT_ARCHITECTURE`**: Para ubicar la jerarquía actual, evitar duplicados
  y entender la arquitectura.

### 3.1 DOCUMENTOS DE PRODUCTO (CONSULTA BAJO DEMANDA — NO CARGAR SIEMPRE):

Estos documentos **NO** se cargan de forma automática en el contexto.
Consultalos **solo si la tarea está relacionada**, para no sobrecargar el
contexto del agente:

- **`GDD`** (fuente de verdad de producto): consultalo ante dudas de **alcance o
  reglas de negocio** de la HU, decisiones cerradas, fases/roadmap, o si la HU
  no define algo. Si el GDD tampoco responde la duda → **preguntá al PM** (no
  asumas en silencio).
- **`SKILLS_CATALOG`**: consultalo **solo si la tarea toca skills** (config de
  skills, IDs, tipos, curva de unlock, balance, loadout). Prohibido inventar
  skills o parámetros fuera del catálogo.
- **`ASSETS_POLICY`**: consultalo **solo si la tarea toca assets** (animaciones,
  iconos, VFX, SFX, UI con imágenes). Reglas: placeholders, naming, licencias,
  registro.

Regla general: si la tarea **no** involucra skills ni assets, **no** los leas.
Solo GDD bajo duda de alcance.

---

=== 4. REGLAS DE NEGOCIO Y PROTECCIÓN DE DATOS:

1.  **Mantenimiento Post-Desarrollo:** Al finalizar la tarea, es **OBLIGATORIO**
    actualizar el archivo `PROJECT_ARCHITECTURE` (y `DATA_SCHEMA` si se
    añadieron datos).
2.  **Integridad Multiplataforma:** Los cambios para dispositivos móviles **NO**
    deben sobreescribir la lógica de PC. Se debe priorizar el uso de
    `UserInputService.TouchEnabled` o scripts espejo específicos para Mobile.
3.  **Eficiencia de Motor:** Usa `Attributes` en lugar de `ObjectValues` y evita
    bucles `while true` priorizando señales como `GetAttributeChangedSignal`.

### 5. PREGUNTA DE CONTROL (Responde antes de programar):

Basado en el **Mapa de Responsabilidades**, ¿qué archivos vas a crear o
modificar específicamente para esta tarea y cómo vas a asegurar que la interfaz
o el sistema no se rompa al cambiar entre PC y Mobile?

--]]
