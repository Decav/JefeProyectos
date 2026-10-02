--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc066 — FASE R6.22 (HU-R6.22)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU/fases/HU-R6.22-Fix-Escala-Critico.md + GDD §5 (combate),
§4 (clases/specs) y §6 (progresión).
Estado: ABIERTO (pendiente de implementación).
Requisitos previos: HU-R4, HU-R2, HU-R5.1 y HU-R8d.

================================================================================
1. DESCRIPCIÓN
================================================================================
Como jugador, quiero que 5% de crítico represente una probabilidad real por
golpe, y no que todos los ataques sean críticos. Como equipo, queremos una
sola unidad interna para clase, talentos y equipo, con presentación en %.

Objetivo de la fase: normalizar el CRIT de equipo/afijos antes de sumar,
limitar el total a [0, 1] y corregir la visualización sin rebalancear daño.
Criterio de hecho global: "CRIT es una fracción 0–1 en todo el pipeline;
cada ataque hace un sorteo independiente y la UI muestra el porcentaje".

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Normalizar CRIT de stats y afijos de ítems en InventoryService, en un único
  punto de aplicación compatible con instancias persistidas.
* Sumar clase, talentos, equipo y bono de set en la misma unidad; aplicar clamp
  [0, 1] al atributo CRIT final del personaje.
* Verificar el sorteo por ataque básico en CombatService, sin modificar el
  multiplicador de daño crítico.
* Mostrar CRIT como porcentaje en InventoryClient y
  InventoryPresentationClient, incluidos total y desglose visible.
* Auditar otras stats porcentuales por mezclas de puntos/fracciones, sin
  cambiar balance ni reglas ajenas a esta HU.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
* No cambiar el multiplicador de daño crítico ni el daño normal.
* No rebalancear porcentajes base por clase, progresión por nivel, talentos,
  ítems, afijos o bono de set; el tope fino queda para R9c si se requiere.
* No crear remotes, controles, layouts ni mecánicas nuevas para PC o Mobile.
* No alterar la lógica de habilidades que no use el atributo CRIT; auditarla
  para verificar el alcance real del fix.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. CRIT 0.50 produce aproximadamente 50% de críticos en muchas tiradas
   independientes; CRIT 0.05, aproximadamente 5%, nunca todos por escala.
2. Un ítem/afijo legado "+5 CRIT" aporta 0.05 al total con clase y talentos;
   los valores ya fraccionarios no se dividen otra vez.
3. CRIT final siempre permanece en [0, 1] aunque la suma exceda 1.
4. CRIT 0.05 aparece como "5%" en el panel de estadísticas.
5. El comportamiento es consistente entre Paladín, Cazador y Clérigo y entre
   armas básicas melee, ranged y mágicas que usan el flujo de auto-attack.
6. Equipar → combatir → dungeon → rejoin no produce errores rojos; daño
   normal, multiplicador crítico y demás stats permanecen intactos.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
* Contrato interno: CRIT de clase/talentos/bonos ya es fracción; puntos enteros
  de ítem o afijo (+N) se convierten a N/100 al aplicar su contribución.
  Los CRIT ya fraccionarios (p. ej. 0.01/0.02/0.05) se conservan.
* InventoryService.recalculateStats suma contribuciones normalizadas una sola
  vez, conserva la deduplicación de ítems de dos manos y limita CRIT total
  después de todos los bonos. El atributo Character.CRIT es fracción [0, 1].
* CombatService lee Character.CRIT y mantiene math.random() < critChance por
  golpe; el multiplicador actual 1.5 permanece idéntico.
* InventoryClient e InventoryPresentationClient convierten fracción ×100 solo
  para el texto (total y desglose), nunca para cálculos del servidor.
* Server-authoritative: el servidor calcula stats y daño; el cliente solo
  presenta atributos/estado. No se aceptan probabilidades enviadas por cliente.
* Remotes: ninguno nuevo; se reutilizan atributos y payloads de inventario.
* Data/estado: no se añade campo persistente ni migración destructiva; la
  normalización al aplicar cubre ítems ya guardados.
* Compatibilidad: no tocar posiciones, tamaños ni input; panel compartido por
  PC/Mobile. Si se ajusta UI, conservar Scale y UIAspectRatioConstraint.
* Hilos: usar task.wait()/task.spawn() si hicieran falta; prohibido wait().

================================================================================
6. INTEGRACIÓN
================================================================================
* Depende de HU-R4 (rolls/afijos), HU-R2 (ClassConfig), HU-R5.1 (talentos) y
  HU-R8d (balance). ItemConfig mezcla templates legados en puntos y tiers
  recientes en fracción; el cálculo debe aceptar ambos sin duplicar conversión.
* Hub es fuente de verdad. InventoryService, CombatService, configs y clientes
  compartidos deben propagarse de Hub a Dungeon_Helada antes de QA publicada.
* Mantiene el contrato de Character.CRIT para auto-attack y presenta la cifra
  correcta a ambos dispositivos.

================================================================================
7. OPTIMIZACIÓN
================================================================================
* 1–2 sesiones orientativas; corrección localizada, sin nuevo sistema de stats.
* Reutilizar recalculado existente al equipar/reequipar/rejoin; no añadir
  polling ni bucles while true para el fix.
* Auditar otras unidades porcentuales sin ampliar el alcance de balance.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[ ] RC creado antes de modificar código; aprobación para tocar cálculo core.
[ ] Pruebas de contribución +5 → 0.05 y 0.02 → 0.02; suma y clamp [0, 1].
[ ] Muestreo de tiradas a 5% y 50%; comprobar sorteo por golpe en clases/armas.
[ ] UI total/desglose muestra % en escritorio y móvil sin alterar layouts.
[ ] Equipar, combate, dungeon y rejoin sin errores rojos ni regresión de stats.
[ ] Auditoría documentada de otras stats porcentuales; multiplicador intacto.
[ ] Actualizar PROJECT_ARCHITECTURE y DATA_SCHEMA si corresponde; nota GDD
    posterior a QA, como exige la HU.
[ ] Sync places: InventoryService, CombatService y clientes/UI modificados del
    Hub → Dungeon_Helada; verificar Source/versión idénticos y QA cross-place.
[ ] El usuario guarda/publica los places; el dev no los guarda ni publica.

================================================================================
9. ESTIMACIÓN
================================================================================
1–2 sesiones: normalización, clamp, UI, auditoría y regresión (orientativo).

================================================================================
10. DEPENDENCIAS
================================================================================
HU-R4 (rolls/afijos), HU-R2 (clases), HU-R5.1 (talentos), HU-R8d (balance).

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
