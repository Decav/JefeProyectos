--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc087 — FASE ÍTEMS (HU-ITEMS-04/06)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: solicitud PO (este chat); ITEMS_DESCRIPTIONS.md (propuesta PO,
  mapeo templateId → description); HU/items/HU-ITEMS-04-Itemizacion-Contenido-Loot.md;
  HU/items/HU-ITEMS-06-Armas-Templates-Loot.md; GDD §7 y §19 (historial
  de descripciones de ítems, 2026-09-22).
Estado: COMPLETO (implementado y verificado en Studio Hub el 2026-10-11).
Requisitos previos: templates canónicos de ITEMS-04/06 disponibles en ItemConfig.
Fecha de emisión: 2026-10-11.

================================================================================
1. DESCRIPCIÓN
================================================================================
Como jugador, quiero que los objetos tengan descripciones acordes al mundo,
su tier y su origen, para que el equipo y los consumibles no presenten textos
de prueba o genéricos fuera del tono de Vandrheim.

Objetivo de la fase: reemplazar el contenido del campo `description` de los
templates canónicos cubiertos por ITEMS_DESCRIPTIONS.md, sin cambiar sus datos
de gameplay ni el comportamiento de los sistemas que muestran esos textos.
Criterio de hecho global: los 93 templateId del mapeo tienen la descripción
correspondiente, sin placeholders ni descripciones vacías.

================================================================================
2. ALCANCE (SÍ)
================================================================================
- Actualizar únicamente `description` en ReplicatedStorage.Config.ItemConfig
  para los 93 templateId canónicos listados en ITEMS_DESCRIPTIONS.md:
  - 60 piezas de armadura: 3 clases × 5 slots × 4 tiers.
  - 24 armas: 5 familias × 4 tiers (20) y 4 armas épicas únicas.
  - 2 joyas y 7 pociones.
- Copiar los textos de la fuente respetando acentos, puntuación y tono. En las
  cuatro armas épicas únicas, guardar el texto visible sin los marcadores `**`
  de formato Markdown que envuelven sus títulos (confirmado por PO).
- Conservar las descripciones largas de lore de esas cuatro armas; no resumirlas.
- Mantener un único texto por template canónico. Los IDs legacy de armas que
  ItemConfig resuelve mediante alias no requieren entradas duplicadas.
- Reflejar el mismo contenido en cualquier copia derivada de ItemConfig que
  consuma el juego, de acuerdo con la integración de configs establecida por
  ITEMS-04/PUBLICAR-04.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
- Cambios en nombres visibles, templateId, rareza, stats, levelReq, slot,
  setId, bonos de set, afinidad, iconos, modelos o cualquier otro campo.
- Cambios a loot, economía, inventario, persistencia, remotos o lógica de uso,
  equipamiento, vendor, tooltip, stack o combate.
- Rediseñar o migrar tooltips, vendors u otras interfaces. Se conserva cómo
  cada vista consume y presenta actualmente el campo `description`.
- Crear descripciones para IDs que no figuran en el mapeo ni añadir templates.
  Si se encuentra un template canónico adicional en uso, reportarlo al PO para
  definir su texto antes de ampliar este RC.
- Modificar HU-ITEMS-04/06, el GDD u otros documentos canónicos de producto.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Cada uno de los 93 templateId del mapeo tiene `description` no vacía en
   ItemConfig y coincide con el texto de ITEMS_DESCRIPTIONS.md.
2. No queda ninguna descripción de prueba del catálogo cubierto, incluyendo
   textos como “Yelmo visual de prueba”, “Hombreras visuales de prueba” o
   “Variante temporal para validar el modelo y el equipamiento”.
3. Los tiers blanco/verde/azul conservan frases breves; las épicas frost de
   armadura conservan 1–2 frases; las cuatro armas épicas únicas conservan su
   lore largo. No se reescribe el contenido listado en la fuente.
4. Las descripciones guardadas no muestran marcadores Markdown `**`.
5. Se verifican muestras de armadura de las tres clases y cuatro tiers, armas
   de las cinco familias, las cuatro armas épicas únicas, las dos joyas y las
   siete pociones en las vistas existentes que presentan descripciones.
6. Los items siguen teniendo el mismo nombre, stats, nivel, rareza, slot,
   modelo, icono, loot y comportamiento de uso/equipamiento que antes.
7. No hay errores rojos en Output al iniciar y recorrer inventario, tooltip y
   vendor con muestras de equipo y consumibles.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
- Archivo/propietario: `ReplicatedStorage.Config.ItemConfig`; modificar los
  campos `description` de los templateId canónicos del mapeo.
- Fuente única de contenido: `ITEMS_DESCRIPTIONS.md`. No reconstruir textos a
  partir de nombres, rarezas o stats, ni inventar entradas faltantes.
- Conteo auditado del mapeo: 93 IDs únicos (60 armaduras + 24 armas + 2 joyas
  + 7 pociones). El control debe comparar IDs, no solo contar filas.
- Para los IDs legacy de armas, conservar el alias existente hacia el
  templateId canónico; no reintroducir IDs al catálogo ni duplicar templates.
- Cambiar solo el valor de `description`; el diff no debe modificar otros
  campos de los templates.
- No se crean scripts, remotes, estados persistidos ni interfaces. No aplica
  server-authoritative, `task.wait()`/`task.spawn()` ni UI con Scale porque no
  se agrega lógica, concurrencia ni UI.

================================================================================
6. INTEGRACIÓN
================================================================================
- ITEMS-04 define las 60 piezas de armadura y el contexto de ItemConfig.
- ITEMS-06 define las familias y templates genéricos de armas, incluidos los
  IDs canónicos y sus aliases legacy.
- El campo se mantiene en la config canónica existente y sus copias derivadas;
  no se altera el contrato de inventario ni los payloads de UI.
- Los consumidores actuales pueden mostrar el texto actualizado al leer la
  descripción del template. Cambiar consumidores que no la presenten queda
  fuera de este RC.

================================================================================
7. OPTIMIZACIÓN
================================================================================
- Cambio de datos estáticos únicamente; sin ciclos, conexiones, instancias,
  remotes ni carga adicional en runtime.
- No agregar lógica para inferir descripciones por tier o clase; mantener cada
  texto explícito en su template para que el contenido sea inspeccionable.
- Validar el mapeo con una comprobación puntual de IDs cubiertos y placeholders.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[x] Los 93 IDs únicos están cubiertos, sin IDs duplicados o ausentes.
[x] Las 93 descripciones coinciden con ITEMS_DESCRIPTIONS.md; `**` se elimina
    de las cuatro descripciones únicas al almacenar el texto.
[x] No queda ningún placeholder de prueba en los templates cubiertos.
[x] Muestras de cada categoría/tier muestran la descripción correcta en las
    vistas existentes que ya presentan este campo.
[x] Equipar, usar, comprar/vender y recibir loot mantienen su comportamiento.
[x] No hay errores rojos en Output.
[x] Se registra el resultado de QA en el RC; cualquier diferencia de cobertura
    se devuelve al PO, sin inventar descripción ni alcance.

Resultado QA (2026-10-11):
- Place verificado: Vandrheim-RPG [ALFA], placeId 84186294312317.
- ItemConfig cargó en Edit y Play; comparación runtime: 93/93 IDs, descripciones exactas, sin faltantes, Markdown ni placeholders.
- TooltipData.Item en Client incluyó la descripción correcta como fila para los 93 templates.
- VendorService lee y serializa template.description; no se modificó su consumidor.
- Output al iniciar Play no reportó errores; Studio quedó en modo Edit.
- Diff limitado a valores de description y asignaciones explícitas de description; no se tocaron stats, loot, inventario ni UI.
- Solo estaba conectado el Hub; no se revisó ni modificó una copia de otro place.
================================================================================
9. ESTIMACIÓN
================================================================================
1 sesión orientativa: aplicar 93 textos y revisar cobertura/contenido en
ItemConfig; supone que el mapeo corresponde a los templates canónicos actuales.
No incluye una migración o rediseño de interfaces.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-ITEMS-04 y HU-ITEMS-06 para los templates canónicos; ITEMS_DESCRIPTIONS.md
como catálogo exacto de textos; GDD §7 y §19 como contexto de itemización.
Sin cambios funcionales a servicios de loot o inventario.

Nota de reconciliación: la entrada histórica del GDD §19 menciona 90 ítems y
21 armas, mientras que ITEMS_DESCRIPTIONS.md contiene 93 IDs únicos (incluye
24 armas: 20 por tier y cuatro épicas únicas). Este RC toma como alcance los
93 IDs explícitos del mapeo entregado por el PO. No corregir el GDD dentro de
esta implementación; reportar la discrepancia para su actualización canónica.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
