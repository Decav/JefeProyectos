

HU-ESTETICA-45 / rc085 — EN IMPLEMENTACIÓN (2026-10-10)
StarterGui.EquipmentUI conserva MainFrame, EquipmentPanel, StatsPanel, nueve slots
y remotos/handlers existentes. HUMWS reubica slots por nombre y centra atributos.
CharacterPanelUIConfig define geometría 480:455, posiciones y tokens; InventoryPresentationClient
es dueño de la presentación, datos CDR y tooltips stat. InventoryClient mantiene
equip/unequip, arrastre, snapshot y cierre. WindowLayoutClient conserva focus,
clamp y drag; UIReskinClient cede el estilo de EquipmentUI al reskin específico.
CDR consume Character:GetAttribute("CooldownReduction"); no se agregó lógica de
servidor ni persistencia. TooltipData.Stat y TooltipSystem tipo stat presentan
el statsBreakdown existente, sin acciones. Responsive: máximo 85% en mobile,
0.44 viewport ancho máximo en desktop; BuilderSans y mín. texto9 px.
Hub 84186294312317 aplicado. Dungeon_Helada 125210265978348 pendiente de sync,
porque no está conectado. QA Play/visual y cierre rc085 pendientes.

