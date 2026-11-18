---
name: studio-simulation-review
description: Revisión adversarial en Roblox Studio sin iniciar Play. Los revisores leen el código real y simulan la lógica en el DataModel Edit con Luau puro (loadstring sobre módulos de config, geometría y reglas reconstruidas), sin interferir con la sesión de Play del PO. Se usa por defecto al revisar cambios de Vandrheim; Play, Server y Client se reservan para lo que no se pueda simular.
---

# Revisión por simulación en Edit (sin Play)

Objetivo: encontrar fallas reales ejecutando la lógica, sin tocar el Play del PO ni el estado del juego. Cumple con `REVIEW-PROTOCOL.md`: se asume que el código está roto, se ejecuta y se registra cada ataque.

## Cuándo usarla

- Por defecto, como primera opción de ejecución en `CodeReviewAgent` y `UIReviewAgent` de Vandrheim.
- Obligatoria si el PO está probando en Play o si `get_studio_state` indica que Studio está en Play: no iniciar ni detener Play.
- Se puede pasar a Play, Server o Client solo para lo que la simulación no cubre (ver "Límites").

## Reglas

1. Usar `execute_luau` con `datamodel_type: "Edit"`. Todo el código es de solo lectura y se descarta al terminar.
2. No crear instancias ni carpetas, no modificar scripts, no guardar ni publicar. Si se necesitan partes de prueba, simularlas como tablas Luau.
3. No iniciar ni detener Play con `start_stop_play` si el PO tiene Play activo.
4. No tocar perfiles ni DataStore reales.
5. Declarar en el dictamen que la prueba fue simulada en Edit y qué quedó `[NO VERIFICADO]`.

## Método

1. Leer el código real antes del manifiesto: `script_grep` para ubicar y `script_read` por rangos.
2. Cargar módulos puros con `loadstring(modulo.Source)()` (por ejemplo `EndlessConfig`) para usar los valores reales y no copias.
3. Reconstruir en Luau puro la lógica que importa:
   - Geometría: constantes de construcción de la arena como cajas (pilares, columnas, muros) y comprobar puntos de respawn, orbes y reubicaciones contra ellas.
   - Reglas numéricas: fórmulas de XP, topes, probabilidades por tramo, acumulación de mejoras.
   - Máquinas de estado: fases, temporizadores, idempotencia, reintentos, orden de eventos y repeticiones.
   - Condiciones de borde: tablas vacías, valores nil, máximos, entradas repetidas o fuera de orden.
4. Para cada ataque registrar: intento, resultado esperado, resultado observado y veredicto, como exige el protocolo. Cubrir el mínimo de ataques del nivel S/M/L.
5. Contrastar los resultados con el código real: si la simulación y el código difieren, la simulación está mal o hay un hallazgo; resolverlo antes de reportar.

## Límites (qué no se puede simular)

- Física real, colisiones del motor, `GetPartBoundsInRadius`, raycasts contra el mapa y replicación cliente-servidor.
- Aspecto visual, solapes y legibilidad de interfaz, tamaños en móvil.
- Rendimiento y fugas reales.

Eso se marca `[NO VERIFICADO]` y se deriva al PO para que lo compruebe en su Play, o se ejecuta en Play/Server/Client solo si el PO no está usando Studio y lo autoriza.

## Salida

En el dictamen, una sección "Simulación en Edit" con: módulos cargados, ataques ejecutados, hallazgos y lista de lo derivado a Play.
