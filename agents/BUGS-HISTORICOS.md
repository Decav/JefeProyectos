# Registro de Fallas Históricas (memoria de los revisores)

Este archivo es la memoria del proyecto. Cada entrada es una falla que **llegó al usuario o se detectó tarde**. Los revisores lo leen antes de cada revisión y deben buscar activamente cada clase de falla de su área (regla R10 del [`REVIEW-PROTOCOL.md`](./REVIEW-PROTOCOL.md)).

## Cómo se mantiene

- Cuando el usuario encuentre una falla **después de una aprobación**, se agrega una entrada. La registra el `ApproverAgent` o quien reciba el reporte.
- Se describe la **clase de falla** de forma independiente del proyecto y de la tecnología, para que sirva en cualquier repositorio.
- Cada entrada indica qué revisor debió detectarla y qué prueba la habría revelado.
- Nunca se borran entradas. Si una deja de aplicar, se marca como `OBSOLETA` con el motivo.

## Plantilla

```markdown
### BH-NNN — [Título corto de la clase de falla]
- **Origen:** [proyecto, fecha]
- **Qué pasó:** [síntoma observado]
- **Causa raíz:** [por qué ocurrió]
- **Revisor responsable:** [CR | SEC | REL | UI | UX]
- **Cómo se habría detectado:** [prueba concreta]
- **Cómo buscarla:** [pasos genéricos para cualquier proyecto]
```

---

## Entradas

### BH-001 — Identificador no definido que detiene la inicialización en cascada
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** una pantalla usaba una variable que nunca se declaró. Al crearse falló y, como las demás pantallas se creaban en secuencia, **todas las posteriores dejaron de existir**. El resto del código parecía correcto.
- **Causa raíz:** el identificador solo se resolvía al ejecutar esa ruta. Nadie ejecutó el arranque completo mirando la salida de errores.
- **Revisor responsable:** CR.
- **Cómo se habría detectado:** arrancar el producto completo y leer el registro de errores; análisis estático en modo estricto que marque identificadores no definidos.
- **Cómo buscarla:** ejecutar el punto de entrada real, revisar la consola o el log desde el primer segundo, y verificar que cada módulo nuevo se inicialice. Un error en una pantalla o módulo nunca debe pasar por "solo afecta a uno".

### BH-002 — Interfaz que choca o desborda al cambiar la escala o la resolución
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un menú se superponía con el banner del jugador en pantallas grandes; botones de compra se salían de su panel y un panel se veía apretado.
- **Causa raíz:** posiciones y tamaños calculados para una sola resolución, con medidas fijas en el contenedor y textos de ejemplo cortos.
- **Revisor responsable:** UI.
- **Cómo se habría detectado:** renderizar en la matriz de resoluciones y escalas, y comparar las cajas de los elementos para detectar intersecciones.
- **Cómo buscarla:** medir, no mirar. Calcular solapamientos entre elementos hermanos y entre un elemento y su contenedor en cada resolución y escala.

### BH-003 — Glifos o emojis que la fuente no soporta
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un símbolo decorativo se mostró como un cuadro vacío.
- **Causa raíz:** se usó un carácter que la fuente de la interfaz no incluye. Nadie lo renderizó.
- **Revisor responsable:** UI.
- **Cómo se habría detectado:** renderizar la pantalla real y revisar cada carácter no alfanumérico.
- **Cómo buscarla:** listar todos los símbolos y emojis nuevos y comprobarlos renderizados, en cada plataforma objetivo.

### BH-004 — Cambios que no persisten por escribir desde una copia obsoleta
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** una edición hecha sobre un archivo se perdió porque una vista abierta del mismo archivo, con contenido anterior, lo sobrescribió.
- **Causa raíz:** dos copias del mismo artefacto y la antigua ganó.
- **Revisor responsable:** CR.
- **Cómo se habría detectado:** releer el artefacto **final** desde su fuente real tras el cambio y comprobar que contiene lo esperado.
- **Cómo buscarla:** no confiar en que una escritura "se aplicó"; verificar leyendo el estado final y la longitud o hash del contenido.

### BH-005 — Las pruebas modifican datos reales
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** al probar funcionalidades de recompensa y compra, los datos de la cuenta real del usuario (monedas, giros, máquinas) cambiaron y hubo que revertirlos a mano.
- **Causa raíz:** el único entorno disponible usaba el perfil real y las pruebas no se aislaron.
- **Revisor responsable:** REL (y todos, por el protocolo de seguridad de pruebas).
- **Cómo se habría detectado:** declarar antes de probar qué datos se tocarán y registrar el estado inicial.
- **Cómo buscarla:** anotar el estado antes y después de cada prueba; revertir y declarar todo cambio.

### BH-006 — Lo que la interfaz muestra no coincide con lo que el sistema hace
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** los precios de unos productos de pago que mostraba el juego (39, 145 y 359) no coincidían con los que el equipo había definido en la documentación y en los comentarios del código (49, 199 y 499).
- **Causa raíz:** el valor mostrado venía de la plataforma de ventas y el valor documentado vivía en otro lugar; nadie los contrastó.
- **Revisor responsable:** UX.
- **Cómo se habría detectado:** comparar, para cada cifra visible, el valor mostrado con el valor realmente aplicado por el sistema.
- **Cómo buscarla:** listar toda cifra, precio, probabilidad o recompensa visible y contrastarla con la fuente real. Si hay dinero o probabilidades, es `[BLOQUEANTE]`.

### BH-007 — Camino de usuario nuevo leído pero nunca ejecutado
- **Origen:** Physics Lab, noviembre de 2026.
- **Qué pasó:** un regalo de bienvenida y otros pasos del primer uso se verificaron solo leyendo el código; el usuario que ya tenía cuenta antigua nunca recorrió ese camino.
- **Causa raíz:** el entorno de prueba tenía datos de un usuario veterano, que ocultan los caminos de primer uso.
- **Revisor responsable:** UX y REL.
- **Cómo se habría detectado:** ejecutar con una cuenta completamente vacía.
- **Cómo buscarla:** exigir siempre una prueba de primer uso con estado vacío, y otra con el estado más cargado posible.
