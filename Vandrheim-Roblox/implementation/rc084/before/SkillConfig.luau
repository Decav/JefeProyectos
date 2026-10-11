--[[
	SkillConfig v2 - Vandrheim Fase R5.1 (HU-R5.1)
	Data-driven skill definitions for SKILL_CATALOG v2.4; R8e DoT is preserved:
	2 basicas por clase + 4 por spec (2 nivel + 2 talento) = 3 clases x 10.
	Nuevos tipos: Heal, Shield (framework). threatMod desde dia 1.
]]

local SkillConfig = {}

-- ========================================================================
-- PALADÍN — Básicas (2)
-- ========================================================================
SkillConfig["paladin_holy_strike"] = {
	animationKey = "melee_slash",
	name = "Golpe sagrado", classId = "Paladin",
	iconId = "rbxassetid://74931676750146", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 4, manaCost = 10,
	damageBase = 12, coefficient = 1.0, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Golpe sagrado que daña al objetivo.",
}
SkillConfig["paladin_light_verdict"] = {
	animationKey = "cast_magic",
	name = "Veredicto de luz", classId = "Paladin",
	iconId = "rbxassetid://138002817525839", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 6, manaCost = 15,
	damageBase = 15, coefficient = 1.1, range = 15,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Veredicto divino que daña al objetivo.",
}

-- ========================================================================
-- PALADÍN — Protector (tank 1H+escudo) — 4 skills
-- ========================================================================
SkillConfig["paladin_prot_shield_bash"] = {
	animationKey = "melee_slash",
	name = "Embate de escudo", classId = "Paladin", specId = "Paladin_Protector",
	iconId = "rbxassetid://98151713661950", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 6, manaCost = 15,
	damageBase = 14, coefficient = 1.0, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 3, description = "Embate con el escudo. Alta amenaza.",
}
SkillConfig["paladin_prot_vow"] = {
	animationKey = "heal",
	name = "Voto protector", classId = "Paladin", specId = "Paladin_Protector",
	iconId = "rbxassetid://126790689823737", animationId = "rbxassetid://507768238",
	type = "Heal", targetType = "self_only", stat = "MATK", cooldown = 15, manaCost = 20,
	damageBase = 30, coefficient = 1.7, range = nil,
	aoeRadius = nil, maxCastRange = nil, levelReq = 5,
	threatMod = 2, description = "Cura al portador. Escala con MATK.",
}
SkillConfig["paladin_prot_sacred_wall"] = {
	animationKey = "shield_buff",
	name = "Muro sagrado", classId = "Paladin", specId = "Paladin_Protector",
	iconId = "rbxassetid://80409890668858", animationId = "rbxassetid://507768238",
	type = "Shield", targetType = "self_only", stat = "MATK", cooldown = 15, manaCost = 20,
	damageBase = 30, coefficient = 1.5, range = nil,
	aoeRadius = nil, maxCastRange = nil, shieldDuration = 8, levelReq = 8,
	threatMod = 2, description = "Escudo absorbente. Talento rama Vida/Defensa.",
}
SkillConfig["paladin_prot_consecration"] = {
	animationKey = "cast_aoe",
	name = "Consagración", classId = "Paladin", specId = "Paladin_Protector",
	iconId = "rbxassetid://81172966733457", animationId = "rbxassetid://507768375",
	type = "GroundAoE", stat = "MATK", cooldown = 12, manaCost = 20,
	damageBase = 3.8, coefficient = 0.27, range = nil,
	aoeRadius = 8, maxCastRange = 20, zoneDuration = 4, tickInterval = 0.5, levelReq = 16,
	threatMod = 3, setBonus = { aoeRadiusMultiplier = 1.30, maxCastRangeMultiplier = 1.30 }, description = "Consagra el suelo. Talento rama Amenaza.",
}

-- ========================================================================
-- PALADÍN — Castigo (2H/1H melee mágico) — 4 skills
-- ========================================================================
SkillConfig["paladin_ret_holy_edge"] = {
	animationKey = "melee_slash",
	name = "Filo sagrado", classId = "Paladin", specId = "Paladin_Castigo",
	iconId = "rbxassetid://71196814200593", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 5, manaCost = 15,
	damageBase = 14, coefficient = 1.1, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Filo sagrado cuerpo a cuerpo.",
}
SkillConfig["paladin_ret_divine_flames"] = {
	animationKey = "cast_magic",
	name = "Llamas divinas", classId = "Paladin", specId = "Paladin_Castigo",
	iconId = "rbxassetid://118703437617145", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 6, manaCost = 15,
	damageBase = 16, coefficient = 1.2, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 5,
	threatMod = 1, description = "Llamas divinas a distancia.",
}
SkillConfig["paladin_ret_sentence"] = {
	animationKey = "cast_magic",
	name = "Sentencia", classId = "Paladin", specId = "Paladin_Castigo",
	iconId = "rbxassetid://73285002823820", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 8, manaCost = 20,
	damageBase = 24, coefficient = 1.3, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 8,
	threatMod = 1, description = "Sentencia divina. Talento rama Ataque.",
}
SkillConfig["paladin_ret_holy_ring"] = {
	animationKey = "cast_aoe",
	name = "Anillo de luz sagrada", classId = "Paladin", specId = "Paladin_Castigo",
	iconId = "rbxassetid://114182267492763", animationId = "rbxassetid://507768375",
	type = "SelfAoE", stat = "MATK", cooldown = 10, manaCost = 25,
	damageBase = 35, coefficient = 1.8, range = nil,
	aoeRadius = 6, maxCastRange = nil, levelReq = 16,
	threatMod = 1, setBonus = { basicProcChance = 0.20, internalCooldown = 5 }, description = "Onda expansiva de luz sagrada alrededor del Paladín.",
}

-- ========================================================================
-- HUNTER — Básicas (2)
-- ========================================================================
SkillConfig["hunter_savage_cut"] = {
	animationKey = "melee_slash",
	name = "Corte salvaje", classId = "Hunter",
	iconId = "rbxassetid://133853672537945", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 4, manaCost = 10,
	damageBase = 12, coefficient = 1.0, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Corte salvaje cuerpo a cuerpo.",
}
SkillConfig["hunter_piercing_shot"] = {
	animationKey = "ranged_shot",
	name = "Disparo perforante", classId = "Hunter",
	iconId = "rbxassetid://105353426781988", animationId = "rbxassetid://522636726",
	type = "Instant", stat = "ATK", cooldown = 6, manaCost = 15,
	damageBase = 15, coefficient = 1.1, range = 25,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Disparo a distancia que perfora al objetivo.",
}

-- ========================================================================
-- HUNTER — Asalto (melee físico) — 4 skills
-- ========================================================================
SkillConfig["hunter_asm_ambush"] = {
	animationKey = "melee_slash",
	name = "Emboscada", classId = "Hunter", specId = "Hunter_Assault",
	iconId = "rbxassetid://72579907464721", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 5, manaCost = 15,
	damageBase = 14, coefficient = 1.1, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Emboscada cuerpo a cuerpo.",
}
SkillConfig["hunter_asm_crimson"] = {
	animationKey = "melee_slash",
	name = "Filo carmesí", classId = "Hunter", specId = "Hunter_Assault",
	iconId = "rbxassetid://112023081882554", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 8, manaCost = 20,
	damageBase = 26, coefficient = 1.3, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 5,
	threatMod = 1, setBonus = { lifestealPercent = 0.20, maxHealthCap = 0.15 }, description = "Filo carmesí. Alto daño.",
}
SkillConfig["hunter_asm_twin"] = {
	animationKey = "melee_slash",
	name = "Cortes gemelos", classId = "Hunter", specId = "Hunter_Assault",
	iconId = "rbxassetid://129935257885531", animationId = "rbxassetid://522635514",
	type = "Instant", stat = "ATK", cooldown = 4, manaCost = 15,
	damageBase = 10, coefficient = 0.9, range = 12,
	aoeRadius = nil, maxCastRange = nil, levelReq = 8,
	threatMod = 1, description = "Cortes gemelos. Talento rama Ataque.",
}
SkillConfig["hunter_asm_whirlwind"] = {
	animationKey = "cast_aoe",
	name = "Torbellino", classId = "Hunter", specId = "Hunter_Assault",
	iconId = "rbxassetid://111695373944228", animationId = "rbxassetid://507768375",
	type = "SelfAoE", stat = "ATK", cooldown = 15, manaCost = 30,
	damageBase = 30, coefficient = 1.35, range = nil,
	aoeRadius = 8, maxCastRange = nil, levelReq = 16,
	threatMod = 1, description = "Torbellino AoE. Talento rama Ataque profundo.",
}

-- ========================================================================
-- HUNTER — Puntería (ranged físico) — 4 skills
-- ========================================================================
SkillConfig["hunter_mm_venom"] = {
	animationKey = "ranged_shot",
	name = "Flecha venenosa", classId = "Hunter", specId = "Hunter_Punteria",
	iconId = "rbxassetid://89348168546122", animationId = "rbxassetid://522636726",
	type = "DoT", stat = "ATK", cooldown = 10, manaCost = 15,
	damageBase = 4, coefficient = 0.35, range = 25,
	duration = 6, tickInterval = 1, levelReq = 1,
	threatMod = 1, description = "Flecha venenosa: 6 pulsos de daño en 6 s. Relanzar refresca el veneno.",
}
SkillConfig["hunter_mm_trueshot"] = {
	animationKey = "ranged_shot",
	name = "Tiro certero", classId = "Hunter", specId = "Hunter_Punteria",
	iconId = "rbxassetid://106968060985407", animationId = "rbxassetid://522636726",
	type = "Instant", stat = "ATK", cooldown = 8, manaCost = 20,
	damageBase = 28, coefficient = 1.3, range = 30,
	aoeRadius = nil, maxCastRange = nil, levelReq = 5,
	threatMod = 1, description = "Tiro certero de largo alcance.",
}
SkillConfig["hunter_mm_chain"] = {
	animationKey = "ranged_shot",
	name = "Tiro en cadena", classId = "Hunter", specId = "Hunter_Punteria",
	iconId = "rbxassetid://88842607246577", animationId = "rbxassetid://522636726",
	type = "Instant", stat = "ATK", cooldown = 4, manaCost = 12,
	damageBase = 10, coefficient = 0.9, range = 20,
	aoeRadius = nil, maxCastRange = nil, levelReq = 8,
	threatMod = 1, setBonus = { extraTargets = 1, extraDamageMultiplier = 1.0 }, description = "Tiro en cadena. Talento rama Precisión.",
}
SkillConfig["hunter_mm_death"] = {
	animationKey = "ranged_shot",
	name = "Disparo mortal", classId = "Hunter", specId = "Hunter_Punteria",
	iconId = "rbxassetid://136194118620261", animationId = "rbxassetid://522636726",
	type = "Instant", stat = "ATK", cooldown = 12, manaCost = 30,
	damageBase = 50, coefficient = 1.9, range = 30,
	aoeRadius = nil, maxCastRange = nil, levelReq = 16,
	threatMod = 1, description = "Disparo mortal. Talento rama Precisión profundo.",
}

-- ========================================================================
-- CLERIC — Básicas (2)
-- ========================================================================
SkillConfig["cleric_smite"] = {
	animationKey = "cast_magic",
	name = "Golpe de fe", classId = "Cleric",
	iconId = "rbxassetid://72217538452904", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 4, manaCost = 10,
	damageBase = 12, coefficient = 1.0, range = 15,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Golpe de luz sagrada contra el objetivo.",
}
SkillConfig["cleric_burning_light"] = {
	animationKey = "cast_magic",
	name = "Luz ardiente", classId = "Cleric",
	iconId = "rbxassetid://79112758016501", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 6, manaCost = 15,
	damageBase = 15, coefficient = 1.1, range = 20,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Descarga de luz ardiente contra el objetivo.",
}

-- ========================================================================
-- CLERIC — Misericordia (healer) — 4 skills
-- ========================================================================
SkillConfig["cleric_hol_heal"] = {
	animationKey = "heal",
	name = "Sanación", classId = "Cleric", specId = "Cleric_Misericordia",
	iconId = "rbxassetid://116128971658824", animationId = "rbxassetid://507785098",
	type = "Heal", targetType = "ally_or_self", stat = "MATK", cooldown = 4, manaCost = 12,
	damageBase = 12, coefficient = 0.85, range = nil,
	aoeRadius = nil, maxCastRange = nil, allyRange = 25, levelReq = 1,
	threatMod = 0, description = "Restaura vida al aliado seleccionado o al propio Clérigo. Escala con MATK.",
}
SkillConfig["cleric_hol_word"] = {
	animationKey = "heal",
	name = "Palabra de luz", classId = "Cleric", specId = "Cleric_Misericordia",
	iconId = "rbxassetid://129700150034740", animationId = "rbxassetid://507785098",
	type = "Heal", targetType = "ally_or_self", stat = "MATK", cooldown = 8, manaCost = 18,
	damageBase = 28, coefficient = 1.2, range = nil,
	aoeRadius = nil, maxCastRange = nil, allyRange = 25, levelReq = 5,
	threatMod = 0, description = "Palabra de luz que restaura vida y escala con MATK.",
}
SkillConfig["cleric_hol_shield"] = {
	animationKey = "shield_buff",
	name = "Escudo de fe", classId = "Cleric", specId = "Cleric_Misericordia",
	iconId = "rbxassetid://134211902325948", animationId = "rbxassetid://507785427",
	type = "Shield", targetType = "ally_or_self", stat = "MATK", cooldown = 15, manaCost = 20,
	damageBase = 20, coefficient = 0.6, range = nil,
	aoeRadius = nil, maxCastRange = nil, allyRange = 25, shieldDuration = 8, levelReq = 8,
	threatMod = 0, description = "Barrera absorbente para el aliado seleccionado o el propio Clérigo. Talento de Vida.",
}
SkillConfig["cleric_hol_miracle"] = {
	animationKey = "heal",
	name = "Milagro", classId = "Cleric", specId = "Cleric_Misericordia",
	iconId = "rbxassetid://110507315302848", animationId = "rbxassetid://507785098",
	type = "Heal", targetType = "ally_or_self", stat = "MATK", cooldown = 20, manaCost = 30,
	damageBase = 80, coefficient = 2.0, range = nil,
	aoeRadius = nil, maxCastRange = nil, allyRange = 25, levelReq = 16,
	threatMod = 0, setBonus = { aoeRadius = 10 }, description = "Gran sanación que escala con MATK. Talento profundo de Vida.",
}

-- ========================================================================
-- CLERIC — Cólera (ranged mágico) — 4 skills
-- ========================================================================
SkillConfig["cleric_wrath_spear"] = {
	animationKey = "cast_magic",
	name = "Lanza de luz", classId = "Cleric", specId = "Cleric_Colera",
	iconId = "rbxassetid://94759186302292", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 5, manaCost = 15,
	damageBase = 14, coefficient = 1.1, range = 20,
	aoeRadius = nil, maxCastRange = nil, levelReq = 1,
	threatMod = 1, description = "Proyectil de luz que daña a distancia.",
}
SkillConfig["cleric_wrath_mark"] = {
	animationKey = "cast_magic",
	name = "Marca de castigo", classId = "Cleric", specId = "Cleric_Colera",
	iconId = "rbxassetid://115934611387255", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 8, manaCost = 20,
	damageBase = 26, coefficient = 1.3, range = 25,
	aoeRadius = nil, maxCastRange = nil, levelReq = 5,
	threatMod = 1, description = "Marca de luz concentrada contra el objetivo.",
}
SkillConfig["cleric_wrath_divine_ire"] = {
	animationKey = "cast_aoe",
	name = "Ira divina", classId = "Cleric", specId = "Cleric_Colera",
	iconId = "rbxassetid://118249956584857", animationId = "rbxassetid://507768375",
	type = "GroundAoE", stat = "MATK", cooldown = 12, manaCost = 20,
	damageBase = 2.1, coefficient = 0.22, range = nil,
	aoeRadius = 8, maxCastRange = 20, zoneDuration = 4, tickInterval = 0.5, levelReq = 8,
	threatMod = 1, description = "Zona persistente de castigo sagrado. Talento de Ira.",
}
SkillConfig["cleric_wrath_annihilation"] = {
	animationKey = "cast_magic",
	name = "Aniquilación", classId = "Cleric", specId = "Cleric_Colera",
	iconId = "rbxassetid://102408612312733", animationId = "rbxassetid://507768238",
	type = "Instant", stat = "MATK", cooldown = 12, manaCost = 30,
	damageBase = 50, coefficient = 1.9, range = 25,
	aoeRadius = nil, maxCastRange = nil, levelReq = 16,
	threatMod = 1, setBonus = { dotDamagePerTickPercent = 0.10, dotDuration = 4, dotTickInterval = 1 }, description = "Explosión de luz devastadora. Talento profundo de Ira.",
}

-- ========================================================================
-- HELPER FUNCTIONS
-- ========================================================================

--- Returns the skill definition for a given skillId.
--- @param skillId string  The unique key in the catalog (e.g. "paladin_holy_strike")
--- @return table|nil  The skill table or nil if not found.
function SkillConfig.Get(skillId)
	return SkillConfig[skillId]
end

--- Returns all skill IDs that belong to a given class (includes basic + all specs).
--- @param classId string  "Paladin", "Hunter", or "Cleric"
--- @return table  Array of skillId strings.
function SkillConfig.GetByClass(classId)
	local result = {}
	for skillId, data in pairs(SkillConfig) do
		if type(data) == "table" and data.classId == classId then
			table.insert(result, skillId)
		end
	end
	return result
end

--- Returns all skill IDs that belong to a given spec.
--- @param specId string  e.g. "Paladin_Protector", "Hunter_Punteria"
--- @return table  Array of skillId strings.
function SkillConfig.GetBySpec(specId)
	local result = {}
	for skillId, data in pairs(SkillConfig) do
		if type(data) == "table" and data.specId == specId then
			table.insert(result, skillId)
		end
	end
	return result
end

--- Returns the basic (non-spec) skills for a class.
--- @param classId string  "Paladin", "Hunter", or "Cleric"
--- @return table  Array of skillId strings.
function SkillConfig.GetBasics(classId)
	local result = {}
	for skillId, data in pairs(SkillConfig) do
		if type(data) == "table" and data.classId == classId and data.specId == nil then
			table.insert(result, skillId)
		end
	end
	return result
end

--- Returns all skill IDs currently present in the catalog.
--- @return table  Array of skillId strings.
function SkillConfig.GetAll()
	local result = {}
	for skillId, data in pairs(SkillConfig) do
		if type(data) == "table" and data.name ~= nil then
			table.insert(result, skillId)
		end
	end
	return result
end

--- Returns the total count of skills in the catalog.
--- @return number
function SkillConfig.Count()
	local n = 0
	for skillId, data in pairs(SkillConfig) do
		if type(data) == "table" and data.name ~= nil then
			n = n + 1
		end
	end
	return n
end


-- ========================================================================
-- COMPATIBILITY FUNCTIONS (v1 API aliases)
-- ========================================================================

--- Alias for GetByClass (v1 compatibility)
--- @return table  Array of skillId strings.
function SkillConfig.GetSkillsForClass(classId)
	return SkillConfig.GetByClass(classId)
end

--- Alias for GetBySpec (v1 compatibility)
--- @return table  Array of skillId strings.
function SkillConfig.GetSkillsForSpec(specId)
	return SkillConfig.GetBySpec(specId)
end

--- Returns the default loadout for a class (first 4 basic skills, padded)
--- @param classId string
--- @return table  Array of up to 4 skillId strings.
function SkillConfig.GetDefaultLoadout(classId)
	local basics = SkillConfig.GetBasics(classId)
	local loadout = {}
	for i = 1, math.min(4, #basics) do
		loadout[i] = basics[i]
	end
	while #loadout < 4 do
		loadout[#loadout + 1] = ""
	end
	return loadout
end

--- Returns all skills available to a character (basics + spec skills + talent skills)
--- @param classId string
--- @param specId string|nil
--- @param talentSkillIds table|nil  Array of skillIds unlocked via talents
--- @return table  Array of skillId strings.
function SkillConfig.GetAvailableSkills(classId, specId, talentSkillIds)
	local result = {}
	local seen = {}
	
	-- Add basic skills (always available, auto-learned at level 1)
	for _, skillId in ipairs(SkillConfig.GetBasics(classId)) do
		if not seen[skillId] then
			seen[skillId] = true
			table.insert(result, skillId)
		end
	end
	
	-- Add spec skills with levelReq <= 5 (auto-learned, never revoked on respec)
	if specId then
		for _, skillId in ipairs(SkillConfig.GetBySpec(specId)) do
			if not seen[skillId] then
				local skill = SkillConfig[skillId]
				if skill and (skill.levelReq or 1) <= 5 then
					seen[skillId] = true
					table.insert(result, skillId)
				end
			end
		end
	end
	
	-- Add talent-unlocked skills (level 8 and 16, only if unlocked via talents)
	if talentSkillIds then
		for _, skillId in ipairs(talentSkillIds) do
			if not seen[skillId] then
				seen[skillId] = true
				table.insert(result, skillId)
			end
		end
	end
	
	return result
end

return SkillConfig

