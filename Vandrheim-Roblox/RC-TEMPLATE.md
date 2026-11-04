# RC-TEMPLATE — Requerimiento Técnico

## Reglas
1. Un RC por HU/especificación asignada. Derivar alcance de la HU y GDD citado (`Vandrheim-Roblox/GDD_ROBLOX_MVP.md` en el proyecto local); no inventar decisiones de producto.
2. Un RC concreta qué, dónde y cómo técnico; no incluye el código de implementación.
3. Conservar estos estados en el propio RC: ABIERTO (pendiente de implementación) -> EN IMPLEMENTACIÓN -> COMPLETO (verificado el <fecha>).
4. Conservar los diez apartados. Si uno no aplica, escribir N/A.
5. Todo RC es una instancia Script con Disabled=true y Source compuesto únicamente por comentario Luau válido. No usar ModuleScript/StringValue ni agregar lógica ejecutable.
6. Nombre de instancia: rc-titulo-descriptivo, minúsculas, sin tildes/espacios, palabras separadas por guion.
7. Ubicación: Workspace.DevelopmentStandard.Requirement/<Seccion>/<Name>. Crear carpeta funcional estable solo cuando tenga RCs.
8. ID estable: rcNNN en el encabezado y atributo RCId. El Name no lleva el número. No renumerar ni reciclar IDs.
9. Actualizar Requirement.INDEX con ID, sección, título corto y ruta exacta. El índice no replica estado, aceptación ni aprobación; cada RC es la fuente autoritativa.
10. Obtener el siguiente ID revisando IDs/encabezados de todo Requirement y el índice.
11. Antes de mover o convertir un RC, comprobar referencias/consumidores; preservar Source, estado, ID y aprobaciones. Corregir solo errores que impidan el contrato Script documental.
12. La revisión/aprobación del PO antecede a implementación. Mantener el procedimiento de places de rc048.
13. Si faltan decisiones/defaults de producto en HU/GDD, registrarlos como pendientes y resolverlos antes de implementar la parte dependiente.
14. Si hay código compartido, §8 enumera módulos y places consumidores y exige comprobar identidad/versiones y el flujo afectado. El PO deriva/publica desde Hub según rc048. Si no aplica, declarar sin sync — solo [place] y justificarlo.

## Categorías estables
Documentacion, PersonajesProgresion, CombateHabilidades, MundoDungeon, InventarioEquipo, Interfaz, Social, Economia, Assets y Publicacion. Añadir categoría solo si el volumen/función justifica un dominio estable. Cada RC tiene una carpeta principal; usar referencias cruzadas para los temas transversales.

## Mapeo HU -> RC
| Apartado | Fuente |
|---|---|
| 1. Descripción | Narrativa y objetivo de la HU |
| 2. Alcance | Incluye de la HU |
| 3. Fuera de alcance | No incluye y fases posteriores |
| 4. Criterios | Escenarios verificables |
| 5. Implementación técnica | Especificaciones, contratos y defaults aprobados |
| 6. Integración | Dependencias y consumidores afectados |
| 7. Optimización | Presupuestos/patrones indicados por la HU |
| 8. Definición de hecho | DoD y verificación, incluido sync cuando corresponda |
| 9. Estimación | Estimación de HU o N/A |
| 10. Dependencias | HU/RC previo o Ninguna |

## Plantilla
Crear el Script, asignar Disabled=true, Source y atributo RCId antes de parentarlo. El Source debe contener únicamente un comentario como este:

```luau
--[[
REQUERIMIENTO TÉCNICO: rcNNN — <título descriptivo> (HU-...)
Proyecto: Vandrheim RPG (Roblox).
Fuente: HU/especificación y secciones pertinentes del GDD.
ID estable: rcNNN
Estado: ABIERTO (pendiente de implementación).
Requisitos previos: [...]

1. DESCRIPCIÓN
Objetivo y criterio global verificable.

2. ALCANCE (SÍ)
Servicios, configuración, remotes, pantallas y places incluidos.

3. FUERA DE ALCANCE
Exclusiones explícitas y fases posteriores.

4. CRITERIOS DE ACEPTACIÓN
Lista numerada, concreta y verificable.

5. IMPLEMENTACIÓN TÉCNICA
Rutas, autoridad, payloads, datos, defaults y límites.

6. INTEGRACIÓN
Dependencias y consumidores; coordinación entre sistemas/places.

7. OPTIMIZACIÓN
Restricciones de rendimiento y patrones requeridos.

8. DEFINICIÓN DE HECHO
Checklist de validación y sync; declarar sin sync y justificar si aplica.

9. ESTIMACIÓN
Sesiones/supuesto o N/A.

10. DEPENDENCIAS
HUs/RCs previos o Ninguna.

FIN DEL REQUERIMIENTO
]]
```
