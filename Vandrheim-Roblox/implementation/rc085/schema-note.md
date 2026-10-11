

HU-ESTETICA-45 / rc085 — sin cambio de schema persistido.
El tooltip local agrega entityType "stat" para proyectar InventoryData.statsBreakdown
(base, equipment, talents, consumables, total) en HP/MP/ATK/MATK/DEF/MDEF/CRIT.
No se almacena ni transmite un TooltipView. CDR sigue viniendo de
Character:GetAttribute("CooldownReduction"); el snapshot actual no define un
desglose CDR, por lo que su tooltip informa el total/uso sin inventar fuentes.

