-- rc084 / EST-44. Read-only projections of server snapshots and canonical configs.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemConfig = require(ReplicatedStorage.Config:WaitForChild("ItemConfig"))
local SkillConfig = require(ReplicatedStorage.Config:WaitForChild("SkillConfig"))
local Config = require(ReplicatedStorage.Config:WaitForChild("TooltipConfig"))
local C = Config.Colors
local Data = {}
local inventory, spellbook = nil, nil

local function number(value)
 return string.format("%.2f", tonumber(value) or 0):gsub("0+$",""):gsub("%.$","")
end
local function row(text, color, bold, size, gap)
 return {text=text, color=color or C.Parchment, bold=bold ~= false, size=size or Config.DetailSize, gap=gap or 0}
end
local function character()
 return Players.LocalPlayer and Players.LocalPlayer.Character
end
function Data.SetInventory(value) inventory=value end
function Data.SetSpellbook(value) spellbook=value end
function Data.Reset() inventory=nil; spellbook=nil end

local STAT_INFO = {
 hp = {label="MaxHP", percent=false},
 mp = {label="MaxMP", percent=false},
 atk = {label="ATK", percent=false},
 matk = {label="MATK", percent=false},
 def = {label="DEF", percent=false},
 mdef = {label="MDEF", percent=false},
 crit = {label="CRIT", percent=true},
 cdr = {label="CDR", percent=true},
}
local function statValueText(key,value)
 local info=STAT_INFO[key]
 local numeric=tonumber(value) or 0
 if info.percent then return number(numeric*100).." %" end
 return number(numeric)
end
function Data.Stat(statKey,breakdown,total)
 local info=STAT_INFO[statKey]
 if not info or tonumber(total)==nil then return nil end
 local result={entityType="stat",border=C.Gold,rows={}}
 local rows=result.rows
 table.insert(rows,row(info.label,C.Gold,true,Config.NameSize))
 table.insert(rows,row("TOTAL · "..statValueText(statKey,total),C.Green,true,Config.StatSize))
 if type(breakdown)=="table" then
  for _,entry in ipairs({{"Base","base"},{"Equipo","equipment"},{"Talentos","talents"},{"Consumibles","consumables"}}) do
   local value=breakdown[entry[2]]
   if value~=nil then
    table.insert(rows,row(entry[1].." · "..statValueText(statKey,value),C.Parchment,true,Config.DetailSize))
   end
  end
 elseif statKey=="cdr" then
  table.insert(rows,row("Reducción de reutilización aplicada a las habilidades.",C.Muted,false,Config.DetailSize))
 else
  table.insert(rows,row("Desglose no disponible.",C.Muted,false,Config.DetailSize))
 end
 return result
end


local function setState(setId)
 local rule = ItemConfig.GetSetBonus(setId)
 if not rule then return nil end
 local count, seen, example = 0, {}, nil
 for _,item in pairs(inventory and inventory.equipment or {}) do
  local cfg = ItemConfig.GetTemplate(item.templateId)
  if cfg and cfg.setId==setId and item.instanceId and not seen[item.instanceId] then
   seen[item.instanceId]=true; count+=1; example=item
  end
 end
 local char=character()
 local classId=spellbook and spellbook.classId or (char and char:GetAttribute("ClassId"))
 local eligible=rule.bonusesEnabled==true and classId==rule.classId
 local effect
 local specId=spellbook and spellbook.specId
 if specId then effect=rule.fourPieceBySpec[specId] end
 -- Inventory descriptions already carry authoritative spec-sensitive set status.
 -- Until a SpellbookData snapshot arrives, use that serialized status to identify
 -- the active rule instead of guessing the player's specialization.
 if not effect and example and count>=4 and eligible then
  local description=example.description or ""
  for _,candidate in pairs(rule.fourPieceBySpec or {}) do
   if string.find(description,"Bono 4 piezas: ACTIVO — "..candidate.description,1,true) then effect=candidate; break end
  end
 end
 return {rule=rule,count=math.clamp(count,0,5),eligible=eligible,effect=effect}
end

local function activeEffect(skillId)
 for setId in pairs(ItemConfig.SET_BONUSES) do
  local state=setState(setId)
  if state and state.eligible and state.count>=4 and state.effect and state.effect.skillId==skillId then
   return state.effect
  end
 end
 return nil
end

local function statText(key,value)
 if string.upper(tostring(key))=="CRIT" then
  -- Static item stats may store whole percentage points (1 = 1%); rolled stats use fractions (0.05 = 5%).
  local fraction=value>=1 and value/100 or value
  return (value>=0 and "+" or "")..number(fraction*100).." % CRIT"
 end
 return (value>=0 and "+" or "")..number(value).." "..key
end

function Data.Item(item)
 if type(item)~="table" then return nil end
 local cfg=ItemConfig.GetTemplate(item.templateId)
 if not cfg then return nil end
 local consumable=cfg.usable==true
 local rarity=item.rarity or cfg.rarity
 local border=rarity=="Epic" and C.Purple or rarity=="Rare" and C.Blue or rarity=="Uncommon" and C.Green or C.Parchment
 local result={entityType=consumable and "item_consumible" or "item_equipable",border=border,rows={}}
 local rows=result.rows
 local description=cfg.description
 if type(description)~="string" or description=="" then description=item.description end
 local function appendDescription()
  if type(description)=="string" and description~="" then
   table.insert(rows,row(description,C.Muted,false,Config.DetailSize,Config.SectionGap))
  end
 end
 table.insert(rows,row(item.name or cfg.name,border,true,Config.NameSize))
 if not consumable then
  if item.bindState=="Bound" then table.insert(rows,row("Vinculado",C.Muted,false))
  elseif item.bindState=="Free" then table.insert(rows,row("Se liga al equipar",C.Muted,false)) end
 end
 table.insert(rows,row((Config.Rarity[rarity] or tostring(rarity)).." · "..(consumable and "CONSUMIBLE" or Config.Slots[item.slot or cfg.slot] or tostring(item.slot or cfg.slot)),consumable and C.Muted or border,true,Config.DetailSize))
 if consumable then
  table.insert(rows,row("EFECTO",C.Gold,true,Config.DetailSize,Config.SectionGap))
  local effect
  if cfg.useAction=="HealHP" then effect="Restaura "..number((cfg.healPercent or 0)*100).." % de HP"
  elseif cfg.useAction=="RestoreMP" then effect="Restaura "..number((cfg.manaPercent or 0)*100).." % de MP"
  elseif cfg.useAction=="ApplyBuff" then effect="Aumenta "..tostring(cfg.buffStat).." un "..number((cfg.buffPercent or 0)*100).." % durante "..number(cfg.buffDuration).." segundos"
  else effect=cfg.description end
  if effect and effect~="" then table.insert(rows,row(effect,C.Green,true,Config.StatSize)) end
  appendDescription()
  return result
 end
 local values=item.stats or {}
 local seen={}
 for _,key in ipairs(Config.StatOrder) do
  if type(values[key])=="number" then table.insert(rows,row(statText(key,values[key]),C.Parchment,true,Config.StatSize));seen[key]=true end
 end
 local extra={}
 for key,value in pairs(values) do if not seen[key] and type(value)=="number" then table.insert(extra,key) end end
 table.sort(extra)
 for _,key in ipairs(extra) do table.insert(rows,row(statText(key,values[key]),C.Parchment,true,Config.StatSize)) end
 for _,affix in ipairs(item.affixes or {}) do
  if type(affix)=="table" and type(affix.value)=="number" and affix.stat then
   table.insert(rows,row(statText(affix.stat,affix.value),C.Parchment,true,Config.StatSize))
  elseif type(affix)=="string" then
   local key,value=affix:match("^%+(%a+)%s+([%d]*%.?[%d]+)$")
   if not key then value,key=affix:match("^%+([%d]*%.?[%d]+)%s+(%a+)$") end
   local numeric=tonumber(value)
   if key and numeric then
    
    table.insert(rows,row(statText(key,numeric),C.Parchment,true,Config.StatSize))
   else table.insert(rows,row(affix,C.Parchment,true,Config.StatSize)) end
  end
 end
 local level=item.levelReq or cfg.levelReq
 if level~=nil then table.insert(rows,row("Requiere nivel "..number(level),C.Parchment,true,Config.DetailSize,3)) end
 local state=cfg.setId and setState(cfg.setId)
 if state then
  table.insert(rows,row(string.upper(state.rule.setName):gsub("^SET ","CONJUNTO "):gsub("í","Í"):gsub("é","É").." · "..state.count.."/5 PIEZAS",C.Gold,true,Config.DetailSize,Config.SectionGap))
  table.insert(rows,{progress=state.count/5})
  local three=state.rule.threePiece
  if three then table.insert(rows,row("3 piezas · "..three.description,state.eligible and state.count>=3 and C.Green or C.Parchment)) end
  local effect=state.effect
  if not effect and spellbook and spellbook.specId then effect=state.rule.fourPieceBySpec[spellbook.specId] end
  local text=effect and effect.description or "Bono según tu especialización"
  table.insert(rows,row("4 piezas · "..text,state.eligible and state.count>=4 and effect and C.Green or C.Parchment))
  if not state.rule.bonusesEnabled then table.insert(rows,row("Bonos de clase solo en el conjunto épico de Helada.",C.Muted,false))
  elseif not state.eligible then table.insert(rows,row("Requiere clase "..tostring(state.rule.classId),C.Muted,false)) end
 end
 appendDescription()
 return result
end

function Data.Skill(skillId)
 local cfg=type(skillId)=="string" and SkillConfig.Get(skillId)
 if not cfg then return nil end
 local rows={}
 local result={entityType="skill",border=C.Purple,rows=rows}
 table.insert(rows,row(cfg.name,C.Parchment,true,Config.NameSize))
 local role=cfg.type=="Heal" and "Curación" or cfg.type=="Shield" and "Absorción" or cfg.stat=="MATK" and "Daño mágico" or "Daño físico"
 table.insert(rows,row((Config.SkillKinds[cfg.type] or cfg.type).." · "..role,C.Purple))
 local char=character()
 local cdr=char and tonumber(char:GetAttribute("CooldownReduction")) or 0
 local cooldown=(cfg.cooldown or 0)*(1-math.clamp(cdr,0,0.5))
 local effect=activeEffect(skillId)
 local radius,castRange=cfg.aoeRadius,cfg.maxCastRange
 if effect and skillId=="paladin_prot_consecration" then
  radius=radius*(cfg.setBonus.aoeRadiusMultiplier or 1)
  castRange=castRange*(cfg.setBonus.maxCastRangeMultiplier or 1)
 elseif effect and skillId=="cleric_hol_miracle" then radius=cfg.setBonus.aoeRadius end
 local metrics={"Coste de maná: "..number(cfg.manaCost).." MP","Reutilización: "..number(cooldown).." segundos"}
 if radius then table.insert(metrics,"Radio de efecto: "..number(radius).." studs") end
 if castRange then table.insert(metrics,"Rango de lanzamiento: "..number(castRange).." studs")
 elseif cfg.range then table.insert(metrics,"Rango: "..number(cfg.range).." studs")
 elseif cfg.allyRange then table.insert(metrics,"Rango aliado: "..number(cfg.allyRange).." studs")
 elseif cfg.targetType=="self_only" or cfg.type=="SelfAoE" then table.insert(metrics,"Objetivo: tú mismo") end
 if cfg.zoneDuration or cfg.duration then table.insert(metrics,"Duración: "..number(cfg.zoneDuration or cfg.duration).." segundos") end
 if cfg.tickInterval then table.insert(metrics,"Pulsos cada "..number(cfg.tickInterval).." segundos") end
 if cfg.shieldDuration then table.insert(metrics,"Duración del escudo: "..number(cfg.shieldDuration).." segundos") end
 table.insert(rows,row(table.concat(metrics,"\n"),C.Parchment,true,Config.DetailSize,Config.SectionGap))
 table.insert(rows,row(cfg.description or "",C.Gold,true,Config.StatSize,Config.SectionGap))
 if cfg.damageBase~=nil and cfg.coefficient~=nil then
  local stat=cfg.stat or "ATK"
  local perTick=cfg.type=="DoT" or cfg.type=="GroundAoE"
  local label=cfg.type=="Heal" and "Curación" or cfg.type=="Shield" and "Absorción" or perTick and "Daño por pulso" or "Daño"
  local scale=stat=="MATK" and "ataque mágico (MATK)" or "ataque físico (ATK)"
  local formula=label..": "..number(cfg.damageBase).." + "..number(cfg.coefficient).." × "..stat
  table.insert(rows,row(formula.."\nAumenta con tu "..scale..".",C.Blue))
 end
 return result
end
return Data
