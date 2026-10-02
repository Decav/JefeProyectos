--[[
================================================================================
          REQUERIMIENTO TÉCNICO: rc055 — FASE R6.16 (HU-R6.16)
================================================================================
Proyecto: Vandrheim — RPG/MMO-like en 3ª persona (Roblox).
Fuente: HU-R6.16 (HU/fases/HU-R6.16-Cura-Aliados-Party.md) + GDD §§4, 5, 10 y 12
  + SKILL_CATALOG §§1, 3.2 y 3.8 (skills y roles).
Estado: ABIERTO (pendiente de implementación).
Requisitos previos: HU-R9a/rc046 (party y party frames), HU-R3.2/R3.3
  (targeting existente) y R3 (SkillService/SkillConfig).

================================================================================
1. DESCRIPCIÓN
================================================================================
Permitir que un Clérigo seleccione a un miembro del party desde su fila del
party frame y dirija a ese aliado las skills de curación definidas por la HU.
Sin aliado seleccionado —o si el target enemigo es el único target— la cura
continúa aplicándose al propio jugador. Voto protector permanece self-only.

Objetivo de la fase: añadir selección de aliado separada del target enemigo,
resolver la cura de forma server-authoritative y preservar el targeting hostil.
Criterio de hecho global: el Clérigo cura a sí mismo o al aliado seleccionado
según la regla; Voto protector sigue siendo self-only y ningún aliado puede
recibir daño de una skill ofensiva.

================================================================================
2. ALCANCE (SÍ)
================================================================================
* Hacer seleccionables por clic/toque las filas de miembros en el party frame,
  incluido el jugador propio, con realce visual coherente con EST-22. Cambiar o
  deseleccionar reemplaza/limpia el estado de aliado sin alterar el target enemigo.
* Mantener el target de aliado como estado distinto del modelo enemigo de
  ReplicatedStorage.Shared.TargetState; conectarlo a PartyClient y SkillBarClient.
* Configurar en ReplicatedStorage.Config.SkillConfig el targetType descrito por
  la HU para Sanación, Palabra de luz, Milagro, Escudo de fe y Voto protector.
  Escudo de fe queda sujeto a la confirmación indicada en §5.
* En ServerScriptService.Services.SkillService, aplicar heal al miembro elegido
  cuando la skill y el target lo permitan; sin target aliado o con enemigo
  seleccionado, conservar self-heal. Voto protector siempre cura al caster.
* Validar en servidor que un target de aliado pertenece al mismo party/instancia
  activa; resolver rango y fallback a self con el aviso “Aliado fuera de rango”.
* Impedir que una skill ofensiva aplique daño a un jugador aliado; el servidor
  no confía en la selección ni en el UserId enviados por el cliente.
* Reutilizar RequestCastSkill (C→S) para la intención de cast; no crear remotes
  nuevos salvo que el canal de feedback existente no pueda mostrar el aviso sin
  rechazar el cast que ya aplicó el fallback a self.

================================================================================
3. FUERA DE ALCANCE (NO en esta HU)
================================================================================
* Revivir jugadores caídos.
* Dirigir buffs/escudos a aliados fuera de las skills explícitamente incluidas
  por la HU; la elegibilidad de Escudo de fe requiere confirmación del PM.
* Rediseñar el targeting enemigo, el ciclo TAB/click/tap, combate, party,
  invitaciones, composición/tamaño de grupo o balance de las skills.
* Añadir estado persistente, modificar perfiles/DataStore o cambiar fórmulas,
  coste, cooldown, amenaza, desbloqueo y loadout de skills.
* Cambiar controles de PC para introducir comportamiento exclusivo de móvil;
  los botones deben funcionar con ratón y touch.

================================================================================
4. CRITERIOS DE ACEPTACIÓN (DEFINICIÓN DE HECHO)
================================================================================
1. Un Clérigo en party selecciona una fila del party frame por clic/toque,
   incluida su propia fila; la selección se realza y puede cambiarse/limpiarse.
2. Con un aliado elegible seleccionado, Sanación aplica la cura al aliado y no
   al Clérigo.
3. Sin aliado seleccionado, o con solo un target enemigo, una skill de heal
   aplica la cura al propio jugador.
4. Voto protector del Paladín Protector cura únicamente al caster incluso si
   hay un aliado seleccionado.
5. Si el aliado seleccionado está fuera del rango configurado, el cast aplica
   self-heal y muestra “Aliado fuera de rango”; el cast no queda sin efecto.
6. El servidor no aplica daño de skills ofensivas a aliados; payloads que
   pretendan dirigir una skill ofensiva a un jugador son rechazados.
7. En party/solo y en PC/móvil, el targeting enemigo mantiene su comportamiento
   y no hay errores rojos; selección de aliado no rompe HUD ni party frames.

================================================================================
5. IMPLEMENTACIÓN TÉCNICA
================================================================================
* PartyClient (StarterPlayer.StarterPlayerScripts) crea actualmente filas HUD
  como Frame y la lista de ventana como TextButton; la fila HUD debe aceptar
  Activated en PC/touch y reflejar el aliado activo sin perder su visual de
  HP/estado. La selección administrativa de la ventana (p. ej. expulsar) no debe
  confundirse con la selección de cura.
* Mantener estado de ally target separado del enemigo en
  ReplicatedStorage.Shared.TargetState (o módulo compartido equivalente). La
  selección pertenece al cliente; SkillBarClient adjunta el UserId seleccionado
  solo a casts con targetType compatible. No se guarda ni se replica como perfil.
* SkillConfig debe reconocer los targetType de la HU: “self”, “ally_or_self” y
  “self_only”. Las skills de daño no reciben targetType de aliado. El rango de
  aliado debe vivir en configuración y validarse en servidor; el nombre/campo y
  valor exactos quedan pendientes de cierre del PM (25 studs es ejemplo, no un
  default aprobado).
* SkillService conserva RequestCastSkill y sus validaciones de skill/loadout,
  clase/spec, nivel, maná y cooldown. Para un allyTargetUserId valida tipo/rango,
  existencia del Player/Character/Humanoid vivo, pertenencia a PartyService y
  misma instancia actual; nunca acepta como target ofensivo un Player/Character.
  Un target inválido/no autorizado no se convierte en daño a otro jugador.
* Para ally_or_self, sin UserId elegible el destino es self; fuera de rango aplica
  el heal completo al caster y emite aviso sin marcar como fallido el cast. Para
  self_only el servidor ignora cualquier aliado enviado y resuelve self.
* Escudo de fe es SkillConfig.type="Shield" en SKILL_CATALOG; la HU lo enumera
  como dirigible, pero no define explícitamente el efecto de escudo en ally ni su
  fallback fuera de rango. Mantenerlo pendiente hasta confirmar esa regla.
* Actualizar DATA_SCHEMA solo para documentar targetType y el dato de rango si
  cambia el esquema de SkillConfig; no cambiar el perfil persistente. Mantener
  lógica server-authoritative, task.wait()/task.spawn() (nunca wait()), UI con
  Scale y UIAspectRatioConstraint donde aplique.
* La HU pide rechazo ofensivo si hay aliado seleccionado, mientras que también
  separa ambos estados de target. Confirmar si el cast ofensivo se rechaza siempre
  mientras haya aliado seleccionado o si debe seguir usando el target enemigo;
  en ambos casos el servidor jamás daña al aliado.
* Confirmar cómo se deselecciona: repetir clic/toque en la fila activa, acción
  explícita u otro gesto existente. No asumir un atajo nuevo.

================================================================================
6. INTEGRACIÓN
================================================================================
Depende de PartyService/PartyStateUpdate y los party frames R9a/EST-22, del
TargetState y targeting de R3.2/R3.3, y del cast data-driven de SkillService/
SkillConfig. Hub es fuente única de verdad; los módulos compartidos consumidos
por Dungeon_Helada se propagan mediante el release derivado de rc048. Sin cambio
de API de party previsto; si los helpers actuales no permiten validar el mismo
party en la instancia, documentar y limitar cualquier ajuste necesario.

================================================================================
7. OPTIMIZACIÓN
================================================================================
Estimación HU: 2 sesiones orientativas. Reusar PartyStateUpdate, filas y
RequestCastSkill; no crear polling, un sistema general de targeting amistoso,
estado persistente, party nuevo ni soporte genérico de buffs. Usar señales y
eventos Activated; no modificar el camino de input hostil salvo integración
mínima para preservar sus invariantes.

================================================================================
8. DEFINICIÓN DE HECHO (VERIFICACIÓN)
================================================================================
[ ] Seleccionar/cambiar/limpiar aliado en el party HUD con ratón y touch;
    incluir self y revisar realce, HP/estado y ventana de party.
[ ] Verificar en multiplayer: Sanación a ally y a self por defecto; target
    enemigo no altera el self-heal; Voto protector nunca afecta ally.
[ ] Verificar dentro/fuera del rango: destino correcto, fallback self efectivo y
    aviso exacto “Aliado fuera de rango”.
[ ] Probar payloads falsificados: target fuera del party, target de otra
    instancia/no miembro y UserId de aliado en skill ofensiva; el server no
    modifica HP/Shield del aliado.
[ ] Regresión solo + party, PC + Device Simulator/móvil, pueblo + dungeon;
    targeting enemigo intacto y Output sin errores rojos.
[ ] Sin cambio de perfil; actualizar DATA_SCHEMA si cambia SkillConfig.
[ ] Actualizar PROJECT_ARCHITECTURE al terminar implementación.
[ ] Sincronizar la copia derivada Dungeon_Helada desde el Hub y verificar
    identidad/Source de los módulos compartidos antes de cerrar release.
[ ] Añadir nota “R6.16 completo” al GDD solo después de QA correspondiente.

================================================================================
9. ESTIMACIÓN
================================================================================
2 sesiones orientativas según HU-R6.16: selección de aliado, reglas de target,
rango/fallback y regresión.

================================================================================
10. DEPENDENCIAS
================================================================================
HU-R9a/rc046 (party/PartyClient/PartyService y party frames EST-22), HU-R3.2/R3.3
(TargetingSystem/TargetState) y R3 (SkillService/SkillConfig/RequestCastSkill).
SKILL_CATALOG v2.4 para IDs/tipos actuales de skills. No modificar GDD antes de
QA; el rango y las decisiones marcadas en §5 requieren cierre del PM.

================================================================================
FIN DEL REQUERIMIENTO
================================================================================
--]]
