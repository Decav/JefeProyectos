
--[[
================================================================================
rc084 — contratos informativos CLIENTE (2026-10-10)
================================================================================
Sin cambios de perfil/DataStore ni payloads/remotos del servidor.

TooltipData:
- SetInventory(snapshot): bag/equipment/statsBreakdown existentes; equipo
  deduplicado por instanceId para piezas de set.
- SetSpellbook(snapshot): classId/specId/skills/loadout existentes.
- Item(itemSnapshot) -> TooltipView | nil; requiere templateId válido.
- Skill(skillId) -> TooltipView | nil; requiere SkillConfig.Get válido.
- Reset(): descarta contexto en cambio de personaje.

TooltipView = {
 entityType: "item_equipable" | "item_consumible" | "skill",
 border: Color3,
 rows: { TooltipRow }
}
TooltipRow = { text: string, color: Color3, bold: boolean, size: number,
 gap: number? } | { progress: number } -- 0..1, solo progreso de conjunto.
Datos de presentación locales; no guardarlos ni enviar como fuente de verdad.

TooltipSystem:
Show(entityType, view, origin: GuiObject, point: Vector2?, isTouch: boolean?)
Hide(origin: GuiObject?) / Refresh()
Bind(origin, provider -> TooltipView?, {externalTouch: boolean?}) -> cleanup
Unbind(origin)
CanActivate(origin, input: InputObject?) -> boolean
externalTouch=true: InventoryClient/SpellbookClient son dueños del candidato
drag/hold. false: el módulo arbitra hold/movimiento/release y suprime Activated.
Ninguna consulta invoca un remoto de gameplay.
Tarjetas sin GuiButtons/ActionBar por corrección explícita del usuario.
================================================================================
]]

