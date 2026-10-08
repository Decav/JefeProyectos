# HU-ESTETICA-37 · Reporte de entrega para PM

**Proyecto:** Vandrheim · Roblox MVP  
**Estado:** Diseño visual completado en Pencil  
**Archivo principal:** `Vandrheim-design.pen`  
**Alcance realizado:** diseño solamente; no se modificó matchmaking, party, teleport ni gameplay.

## Entregables

- Frame de escritorio **`HU-ESTETICA-37 — Matchmaking Lobby`** con las cinco vistas conectadas visualmente por tabs:
  1. Elección **Ir solo / Ir en grupo** y acceso a la Guía de la Helada.
  2. Creación de sala, nombre opcional, toggle pública/privada y botón Crear.
  3. Lista de salas públicas con tres tarjetas, líder/clase/nivel, ocupación, cobertura Tank/Heal/DPS, Unirse y muestra de estado vacío.
  4. Sala incompleta con cuatro slots, rol esperado, jugador/clase/spec/nivel, estado Listo/Esperando y party existente autocargado (sin reinvitar). La composición 1/1/2 es informativa; Empezar está deshabilitado solo porque Saga aún no marcó Listo, con tooltip que explica ese motivo.
  5. Sala privada con todos los presentes Listos, composición 1/1/2 marcada como objetivo informativo, y Empezar Run habilitado. Se especifica visualmente que puede iniciar con 2–4 jugadores presentes y listos; 1 jugador corresponde al modo solo.
- Pestaña/panel de información: resumen de la Helada, niveles aproximados, cinco pisos y enemigos ilustrativos, Señor de la Escarcha, Jotunn y loot de ambos. Los porcentajes del cofre final se marcan como ilustrativos/de configuración.
- Frame **`HU-ESTETICA-37 — Variante móvil`** con flujo vertical, lista, cuatro slots apilados, party autocargado y el mismo criterio de composición informativa / ready de los presentes.
- Frame **`EST-37 — Runas de rol · set vectorial`** con glifos identificados para Tank, Heal y DPS.
- Frame separado **`HU-ESTETICA-37 — Invitación a dungeon`** con el contexto atenuado del pueblo, identidad del invitador/líder, sala y dungeon, ocupación, party actual y acciones **Aceptar invitación / Rechazar**.
- Actualización de `ASSETS_LIST.md` con el registro `Icon_UI_role_tank`, `Icon_UI_role_heal` y `Icon_UI_role_dps`.

## Lenguaje visual y handoff

Se aplicó Hearthbound Gold existente: fondos `#15100D / #211916`, slots negros `#0E0D0C`, latón `#C89445`, pergamino `#F4EDE0`, frío `#8FB7D6`, borde de madera `#6B4A2B`; Playfair Display, Inter y Geist Mono. Se incluyeron estados de hover/foco, deshabilitado, vacío, privado y listo. Los glifos se muestran como iconos vectoriales de Pencil con correspondencia documentada a `shield`, `heart-pulse` y `swords`; no se crearon imágenes raster ni se implementó lógica.

## Verificación

- Tras el ajuste PO se revisaron capturas de escritorio (sala incompleta y privada lista), móvil, set de runas e invitación entrante.
- La inspección de bounds no reportó elementos parcial ni totalmente recortados en los frames de escritorio, móvil, runas ni invitación.
- Composición objetivo no bloqueante; el estado disabled de la sala incompleta se atribuye únicamente a un miembro presente sin Listo.
- La jerarquía queda editable en Pencil y mantiene el vocabulario visual de EST-13, EST-19, EST-22 y R6.27.

## Pendientes de implementación / validación

- Confirmar nombres definitivos de enemigos por piso y valores de loot contra la configuración de R9a.2; el contenido del mockup está rotulado como ilustrativo.
- Si Roblox requiere PNG en vez de SVG/vector, exportar los tres pictogramas a 24/48 px transparente y validar tamaños de toque/escala con UIScale.
- Conectar los tabs, toggles, acciones, tooltip y estados a la lógica de R9a.2 durante implementación; este entregable no agrega ni define comportamiento.
