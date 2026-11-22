# Recetas de emisores por tipo de efecto

Valores de partida derivados del análisis del pack (`pack-technique-analysis.md`). Están expresados en función del radio de gameplay `R` (en studs) para que no dependan de la escala. Son puntos de partida: se calibran en el laboratorio de captura (`validation-lab.md`).

## Cronograma base de un efecto

| Momento | Qué ocurre | Duración |
| :--- | :--- | :--- |
| t = -0,12 a 0 | Anticipación: implosión corta (`ShapeInOut = Inward`, `Shape = Sphere`) y pre-destello | 0,04 a 0,12 s |
| t = 0 | Destello + impacto + núcleo animado | 0,02 a 0,08 s el destello |
| t = 0 a 0,12 | Onda principal y líneas de velocidad | 0,2 a 0,5 s |
| t = 0,1 a 0,3 | Segunda oleada (eco, chispas, escombros) con `EmitDelay` | 0,3 a 0,8 s |
| t = 0,3 a 0,8 | Humo oscuro de base y partículas que caen | hasta 2,4 s |
| 60 a 75 % de la vida | Cierre estelar: destello corto, chispas finas, luz | 0,2 a 0,4 s |
| cola | Solo marca en suelo y brillo residual (1 partícula cada uno) | hasta 2,5 s |

Regla: todo lo que no sea marca o brillo residual debe terminar antes de 1 s.

## Roles de capa y parámetros típicos

| Rol | Cantidad por cast | Vida | Tamaño (relativo a `R`) | `LightEmission` / `Brightness` | Detalles |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Destello | 2 a 3 | 0,02 a 0,08 s | 0 a 0,5 `R` a 0 | 1 / 40 a 100 | propagación 360, transparencia 0 plana, `ZOffset` +1 |
| Núcleo animado | 1 a 3 | 0,3 a 0,7 s | 0,6 a 1,2 `R` fijo | 1 / 8 a 12 | flipbook 4x4 `OneShot`, transparencia 1 a 0 a 1 |
| Onda de suelo | 1 a 2 | 0,2 a 0,5 s | 0 a 2 `R` (diámetro final) | 1 / 5 a 10 | `Shape = Disc`, `Outward`, al ras (0,04 a 0,1 studs) |
| Humo oscuro | 8 a 20 | 0,6 a 2,4 s | 0,1 a 1,2 `R` creciendo | -1 a 0 / 3 a 9 | flipbook 8x8 `OneShot`, `Drag` 6, aceleración baja hacia arriba |
| Líneas de velocidad | 12 a 25 | 0,03 a 0,11 s | 0,3 a 1 `R` de largo | 0,6 a 1 / 15 a 25 | `VelocityParallel`, velocidad 10 a 35 `R`/s, `Drag` 12 a 15 |
| Chispas | 12 a 32 | 0,13 a 0,7 s | 0,02 a 0,06 `R` | 1 / 12 a 55 | `VelocityParallel`, `Squash` 0,8, `Drag` 5 a 22 |
| Escombros | 6 a 10 | 0,5 a 0,8 s | 0,05 a 0,15 `R` | 0 / 8 a 10 | aceleración de gravedad, `RotSpeed` hasta 700 |
| Marca en suelo | 1 | 1,5 a 2,5 s | 1 `R` | -1 / 0 | oscurece el suelo, `ZOffset` mínimo |
| Brillo residual | 1 | 1 a 2 s | 1,2 `R` | 1 / 1 | transparencia 0 a 0,9 a 1 |
| Luz | 1 `PointLight` | 0,1 a 0,45 s | rango 1,5 a 3 `R` | brillo 3 a 25 | sin sombras, se apaga con `Tween` |

## Recetas por tipo

### Impacto sobre un enemigo (nivel S o M)
- Capas: destello (2), núcleo animado (1), chispas (12 a 20), líneas de velocidad (8 a 12), luz breve.
- Escala al `GetBoundingBox()` del objetivo. Máximo `maxImpacts` por cast.
- Lectura inmediata: añade una cruz estelar de 2 planos (`EnemyImpactStar`) al 60 % de la vida.

### Onda desde el lanzador (SelfAoE)
- Capas: implosión breve, destello en el origen, onda de suelo con eco a +0,06 a 0,12 s, ráfaga de chispas en disco, humo oscuro bajo, líneas rasantes dentro del radio (`<= 0,96 R`).
- Respeta el radio de gameplay: el borde visible no supera `2 R`.

### Zona persistente (GroundAoE, por ejemplo Consagración)
- Aparición: igual que la onda, de 0,5 s.
- Mantenimiento: anillo de suelo con `fillTransparency` 0,9, grietas o runas, motas ascendentes de baja tasa y pulsos breves por tick (no una explosión por tick).
- Altura: añade columnas o haces verticales finos en el borde y chispas que suben, para que no sea solo un disco plano.
- Cierre: apaga en 0,3 a 0,5 s con una última onda.

### Corte cuerpo a cuerpo (slash)
- Capas: arco con `Beam` curvo ancho (textura de corte, `TextureSpeed` positivo) más un beam fino de núcleo, destello en el arma, chispas siguiendo el arco, destello de impacto en el objetivo.
- Entrada y salida de transparencia en el beam; el ancho cae a 0 en 0,2 a 0,35 s.

### Proyectil e impacto
- Proyectil: `Trail` de 0,2 a 0,5 s, núcleo brillante, emisor de estela con `Drag` alto y pocas partículas, luz pequeña.
- Impacto: receta de impacto sobre enemigo más un anillo corto. Las capas oscuras dan peso a flechas y bolas.

### Aura o escudo (buff persistente)
- Capas: anillo o domo con flipbook en `Loop` de baja opacidad, motas ascendentes lentas, destello al activar y respuesta corta cuando absorbe daño.
- Persistente: pocas partículas (tasa baja) y `LockedToPart = true`; destruye al expirar el efecto.

### Curación
- Luz cálida ascendente que converge al receptor; paleta claramente distinta del daño (blanco, verde suave, dorado).
- Capas: pilar fino, motas que suben con curva, anillo corto al ras, destello suave.

### Definitiva o proc raro (nivel L)
- Combina las recetas anteriores con un cronograma más largo (hasta 1,5 s de ráfaga principal), una segunda oleada a +0,15 a 0,3 s, un cierre estelar marcado y una luz más fuerte.
- Solo uno activo por jugador y con presupuesto propio medido en móvil.

## Reglas de legibilidad

- Cada skill tiene silueta y motivo propios dentro de la paleta de su clase o spec; no reutilices el mismo efecto con otro color.
- Skills del jugador en tonos de su paleta; avisos de enemigos en rojo o naranja con borde claro; no los mezcles.
- El efecto no debe tapar al personaje ni a los enemigos: menos de la mitad del encuadre a 1080p, y transparencia alta en capas grandes.
- Contraste de luminancia sobre nieve, piedra y cielo: capa oscura bajo la capa brillante.
