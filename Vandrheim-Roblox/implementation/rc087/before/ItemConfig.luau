--[[
	ItemConfig - Vandrheim Fase R4
	Templates data-driven de ítems: stats base + roll, rareza, levelReq,
	slot, weaponAffinity, bindOnEquip, unique, iconId, description.
]]

local ItemConfig = {
	-- Common (Blanco) - stats base solos
	sword_apprentice = {
		name = "Espada del aprendiz",
		slot = "MainHand",
		wieldType = "OneHand",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { ATK = { base = 6, roll = 2 } },
		affixes = {},
		weaponAffinity = { "Paladin_Protector", "Hunter_Assault" },
		unique = false,
		iconId = "rbxassetid://110968716979543",
		description = "Espada de práctica para el nuevo aventurero.",		visualModelId = "paladin_sword_1h_mesh",
		visualType = "HandModel",
		attachTo = "RightHand",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
	},

	-- Uncommon (Verde) - roll ligeramente mejor + 1 afijo menor
	sword_iron = {
		name = "Espada de hierro",
		slot = "MainHand",
		wieldType = "OneHand",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 1,
		stats = { ATK = { base = 8, roll = 3 } },
		affixes = { "+MaxHP 10", "+CRIT 5", "+DEF 3", "+MaxMP 10" },
		weaponAffinity = { "Paladin_Protector", "Hunter_Assault" },
		unique = false,
		iconId = "rbxassetid://114335041413535",
		description = "Una espada de hierro resistente con espacio para mejoras.",		visualModelId = "paladin_sword_1h_mesh",
		visualType = "HandModel",
		attachTo = "RightHand",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
	},

	-- Rare (Azul) - +1 afijo menor
	sword_knight = {
		name = "Espada del caballero",
		slot = "MainHand",
		wieldType = "OneHand",
		stackable = false,
		maxStack = 1,
		rarity = "Rare",
		levelReq = 1,
		stats = { ATK = { base = 10, roll = 4 } },
		affixes = { "+MaxHP 10", "+CRIT 5", "+DEF 3", "+MaxMP 10" },
		weaponAffinity = { "Paladin_Protector", "Hunter_Assault", "Paladin_Castigo" },
		unique = false,
		iconId = "rbxassetid://77771945368188",
		description = "Forjada para un caballero de renombre.",		visualModelId = "paladin_sword_1h_mesh",
		visualType = "HandModel",
		attachTo = "RightHand",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
	},

	-- Epic (Morado) - +1 afijo mayor
	sword_champion = {
		name = "Espada del campeón",
		slot = "MainHand",
		wieldType = "OneHand",
		stackable = false,
		maxStack = 1,
		rarity = "Epic",
		levelReq = 1,
		stats = { ATK = { base = 12, roll = 5 } },
		affixes = { "+ATK 10", "+MATK 10", "+DEF 8", "+MaxHP 30" },
		weaponAffinity = { "Paladin_Protector", "Paladin_Castigo", "Hunter_Assault" },
		unique = false,
		iconId = "rbxassetid://107774517079954",
		description = "Una espada legendaria que solo los más grandes pueden empuñar.",		visualModelId = "paladin_sword_1h_mesh",
		visualType = "HandModel",
		attachTo = "RightHand",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
	},

	-- OffHand test item (escudo)
	shield_guard = {
		name = "Escudo del guardián",
		slot = "OffHand",
		wieldType = "OffHand",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 1,
		stats = { DEF = { base = 5, roll = 2 } },
		affixes = { "+MaxHP 10", "+DEF 3", "+MaxMP 10", "+CRIT 5" },
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://95427121671562",
		description = "Escudo de hierro para protección en combate.",		visualModelId = "paladin_shield_mesh",
		visualType = "HandModel",
		attachTo = "LeftHand",
		offset = CFrame.new(-0.35, -0.30, -0.16) * CFrame.Angles(0, math.rad(250), 0),
	},
	shield_guard_blue = {
		name = "Escudo azul del guardián (prueba)",
		slot = "OffHand",
		wieldType = "OffHand",
		stackable = false,
		maxStack = 1,
		rarity = "Rare",
		levelReq = 1,
		stats = { DEF = { base = 5, roll = 2 } },
		affixes = { "+MaxHP 10", "+DEF 3", "+MaxMP 10", "+CRIT 5" },
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://72048213918363",
		description = "Escudo azul del guardián. Variante temporal para validar el modelo y el equipamiento.",
		visualModelId = "shield_guard_blue_segmented",
		visualType = "HandModel",
		attachTo = "LeftHand",
		offset = CFrame.new(-0.35, -0.30, -0.16) * CFrame.Angles(0, math.rad(250), 0),
	},

	-- Hunter visual seed (EST-05)
	hunter_bow = {
		name = "Arco del cazador",
		slot = "MainHand",
		wieldType = "TwoHand",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { ATK = { base = 7, roll = 2 } },
		affixes = {},
		weaponAffinity = { "Hunter_Assault", "Hunter_Punteria" },
		unique = false,
		iconId = "rbxassetid://83138154761130",
		description = "Un arco de madera y cuero para el cazador.",
		visualModelId = "hunter_bow",
		visualType = "HandModel",
		attachTo = "RightHand",
		basicAttackType = "ranged",
		basicAttackRange = 30,
		basicAttackVfx = "hunter_basic_ranged",
		basicAttackAnimation = "ranged_shot",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(90, math.rad(125), 0)
	},

	-- Chest test item
	paladin_chest = {
		name = "Coraza de paladin",
		slot = "Chest",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 15,
		stats = { DEF = { base = 4, roll = 1 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://122170169381444",
		description = "Coraza de placas de paladin.",		visualModelId = "paladin_r15_body_skin_new",
		visualType = "BodySkin",
		bodySkinParts = { "UpperTorso", "LowerTorso" },
		offset = CFrame.new(),
	},
	-- Paladin visual seed (EST-01 / QA)
	paladin_helmet = {
		name = "Yelmo del Paladin",
		slot = "Helmet",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { DEF = { base = 2, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://79286108617089",
		description = "Yelmo visual de prueba del set del Paladin.",
		visualModelId = "paladin_helmet_model",
		visualType = "ModelAccessory",
		visualScale = 0.75, -- 1.00 = original; ajustar aquí para probar el tamaño del casco.
		attachmentName = "HatAttachment",
		offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, math.rad(180), 0),
	},
	paladin_shoulders = {
		name = "Hombreras del Paladin",
		slot = "Shoulders",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 10,
		stats = { DEF = { base = 2, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://75277265090314",
		description = "Hombreras visuales de prueba del set del Paladin.",
		visualModelId = "paladin_shoulders_model",
		visualType = "ModelAccessory",
		attachmentName = "BodyFrontAttachment",
		offset = CFrame.new(0, 0.5, 0.6) * CFrame.Angles(0, math.rad(180), 0),
		shoulderSpread = 1.55, -- distancia lateral de cada hombrera desde el Handle.
		shoulderOpenAngle = -25, -- grados de apertura; el servicio espeja izquierda/derecha.
	},
	paladin_legs = {
		name = "Grebas del Paladin",
		slot = "Legs",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 10,
		stats = { DEF = { base = 2, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://101475987065543",
		description = "Grebas visuales de prueba del set del Paladin.",
		visualModelId = "paladin_r15_body_skin_new",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot" },
		offset = CFrame.new(),
	},
	paladin_gloves = {
		name = "Guantes del Paladin",
		slot = "Gloves",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 5,
		stats = { DEF = { base = 1, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://100121089705060",
		description = "Guantes visuales de prueba del set del Paladin.",
		visualModelId = "paladin_r15_body_skin_new",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand" },
		offset = CFrame.new(),
	},

	-- R8: sets Cazador y Clerigo + joyeria aprobada por PM (HU-ITEMS-01)
	hunter_helmet = {
		name = "Yelmo del Cazador",
		slot = "Helmet",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 1,
		stats = { DEF = { base = 2, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://127425883052588",
		description = "Casco ligero del set del Cazador.",
		visualModelId = "hunter_helmet",
		visualType = "ModelAccessory",
		attachmentName = "HatAttachment",
		visualScale = 1.2, -- 1.00 = original; ajustar aquí para probar el tamaño del casco.
		offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, math.rad(180), 0),
	},
	hunter_gloves = {
		name = "Guantes del Cazador",
		slot = "Gloves",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 5,
		stats = { DEF = { base = 1, roll = 0 }, CRIT = { base = 1, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://70585306629406",
		description = "Guantes de cuero del set del Cazador.",
		visualModelId = "hunter_gloves",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand" },
		offset = CFrame.new(),
	},
	hunter_legs = {
		name = "Grebas del Cazador",
		slot = "Legs",
		stackable = false,
		maxStack = 1,
		rarity = "Rare",
		levelReq = 10,
		stats = { DEF = { base = 3, roll = 1 }, CRIT = { base = 2, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://118785538085884",
		description = "Grebas reforzadas del set del Cazador.",
		visualModelId = "hunter_legs",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot" },
		offset = CFrame.new(),
	},
	hunter_shoulders = {
		name = "Hombreras del Cazador",
		slot = "Shoulders",
		stackable = false,
		maxStack = 1,
		rarity = "Rare",
		levelReq = 10,
		stats = { DEF = { base = 2, roll = 0 }, ATK = { base = 2, roll = 1 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://80193037650273",
		description = "Hombreras reforzadas del set del Cazador.",
		visualModelId = "hunter_shoulders",
		visualType = "ModelAccessory",
		attachmentName = "BodyFrontAttachment",
		offset = CFrame.new(0, 0.6, 0.6) * CFrame.Angles(0, math.rad(180), 0),
		shoulderSpread = 1.6, -- distancia lateral de cada hombrera desde el Handle.
		shoulderOpenAngle = -15, -- grados de apertura; el servicio espeja izquierda/derecha.
		shoulderLayoutParts = {
			left = "right pauldron_visual_geom",
			right = "left pauldron_visual_geom",
		}, -- mallas visibles específicas de este modelo (sus nombres vienen cruzados).
	},
	hunter_chest = {
		name = "Coraza del Cazador",
		slot = "Chest",
		stackable = false,
		maxStack = 1,
		rarity = "Rare",
		levelReq = 15,
		stats = { DEF = { base = 4, roll = 1 }, MDEF = { base = 2, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://135959349804211",
		description = "Coraza de cuero y tejido del set del Cazador.",
		visualModelId = "hunter_chest",
		visualType = "BodySkin",
		bodySkinParts = { "UpperTorso", "LowerTorso" },
		offset = CFrame.new(),
	},
	cleric_helmet = {
		name = "Yelmo del Clerigo",
		slot = "Helmet",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { MDEF = { base = 2, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://86608448294588",
		description = "Yelmo ceremonial del set del Clerigo.",
		visualModelId = "cleric_helmet",
		visualType = "ModelAccessory",
		attachmentName = "HatAttachment",
		visualScale = 1.4, -- 1.00 = original; ajustar aquí para probar el tamaño del casco.
		offset = CFrame.new(0, -0.8, 0.08) * CFrame.Angles(0, math.rad(180), 0),
	},
	cleric_gloves = {
		name = "Guantes del Clerigo",
		slot = "Gloves",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 5,
		stats = { MDEF = { base = 1, roll = 0 }, MaxMP = { base = 5, roll = 0 }, MaxHP = { base = 10, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://130443757644460",
		description = "Guantes tejidos del set del Clerigo.",
		visualModelId = "cleric_gloves",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand" },
		offset = CFrame.new(),
	},
	cleric_legs = {
		name = "Grebas del Clerigo",
		slot = "Legs",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 10,
		stats = { MDEF = { base = 3, roll = 1 }, MATK = { base = 1, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://75028002628549",
		description = "Grebas ligeras del set del Clerigo.",
		visualModelId = "cleric_legs",
		visualType = "BodySkin",
		bodySkinParts = { "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot" },
		offset = CFrame.new(),
	},
	cleric_shoulders = {
		name = "Hombreras del Clerigo",
		slot = "Shoulders",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 10,
		stats = { MDEF = { base = 2, roll = 0 }, MaxMP = { base = 10, roll = 0 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://127941142355489",
		description = "Hombreras ceremoniales del set del Clerigo.",
		visualModelId = "cleric_shoulders",
		visualType = "ModelAccessory",
		attachmentName = "BodyFrontAttachment",
		offset = CFrame.new(0, 0.5, 0.6) * CFrame.Angles(0, math.rad(180), 0),
		shoulderSpread = 1.6, -- distancia lateral de cada hombrera desde el Handle.
		shoulderOpenAngle = -25, -- grados de apertura; el servicio espeja izquierda/derecha.
	},
	cleric_chest = {
		name = "Toga del Clerigo",
		slot = "Chest",
		stackable = false,
		maxStack = 1,
		rarity = "Uncommon",
		levelReq = 15,
		stats = { MDEF = { base = 4, roll = 1 }, MATK = { base = 2, roll = 1 }, MaxHP = { base = 15, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://92588046874783",
		description = "Toga reforzada del set del Clerigo.",
		visualModelId = "cleric_chest",
		visualType = "BodySkin",
		bodySkinParts = { "UpperTorso", "LowerTorso" },
		offset = CFrame.new(),
	},
	cleric_wand = {
		name = "Varita del Clerigo",
		slot = "MainHand",
		wieldType = "MainHandOnly",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { MATK = { base = 6, roll = 2 } },
		affixes = {},
		weaponAffinity = { "Cleric_Misericordia", "Cleric_Colera" },
		unique = false,
		iconId = "rbxassetid://90590172652441",
		description = "Varita de madera y cristal sagrado para el Clerigo.",
		visualModelId = "cleric_wand",
		visualType = "HandModel",
		attachTo = "RightHand",
		basicAttackType = "ranged",
		basicAttackRange = 30,
		basicAttackStat = "MATK",
		basicAttackVfx = "cleric_basic_ranged",
		basicAttackAnimation = "autoattack",
		offset = CFrame.new(0, -0.83, -0.10)  * CFrame.Angles(100, math.rad(180), 0),
	},
	item_collar = {
		name = "Collar sencillo",
		slot = "Necklace",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { MaxHP = { base = 10, roll = 5 }, DEF = { base = 1, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://91124723281032",
		description = "Un collar que aporta vitalidad y proteccion.",
	},
	item_ring = {
		name = "Anillo sencillo",
		slot = "Ring",
		stackable = false,
		maxStack = 1,
		rarity = "Common",
		levelReq = 1,
		stats = { ATK = { base = 2, roll = 1 }, CRIT = { base = 1, roll = 0 } },
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://118292911522186",
		description = "Un anillo que refuerza el ataque y la precision.",
	},

	-- Consumibles del Alquimista (HU-ITEMS-02)
	potion_hp = {
		name = "Poción de vida (chica)",
		type = "Consumable",
		usable = true,
		useAction = "HealHP",
		healPercent = 0.25,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://91446513498693",
		description = "Restaura un 25% de la vida máxima.",
	},
	potion_hp_large = {
		name = "Poción de vida grande",
		type = "Consumable",
		usable = true,
		useAction = "HealHP",
		healPercent = 0.50,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://98404600833724",
		description = "Restaura un 50% de la vida máxima.",
	},
	potion_mp = {
		name = "Poción de maná (chica)",
		type = "Consumable",
		usable = true,
		useAction = "RestoreMP",
		manaPercent = 0.25,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://78824649956641",
		description = "Restaura un 25% del maná máximo.",
	},
	potion_mp_large = {
		name = "Poción de maná grande",
		type = "Consumable",
		usable = true,
		useAction = "RestoreMP",
		manaPercent = 0.50,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://81576021465559",
		description = "Restaura un 50% del maná máximo.",
	},
	potion_buff_atk = {
		name = "Poción de furia",
		type = "Consumable",
		usable = true,
		useAction = "ApplyBuff",
		buffStat = "ATK",
		buffPercent = 0.10,
		buffDuration = 60,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://80274605100953",
		description = "Aumenta un 10% el ataque durante 60 s.",
	},
	potion_buff_def = {
		name = "Poción de hierro",
		type = "Consumable",
		usable = true,
		useAction = "ApplyBuff",
		buffStat = "DEF",
		buffPercent = 0.10,
		buffDuration = 60,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://133847057281343",
		description = "Aumenta un 10% la defensa durante 60 s.",
	},
	potion_buff_hp = {
		name = "Poción de vitalidad",
		type = "Consumable",
		usable = true,
		useAction = "ApplyBuff",
		buffStat = "MaxHP",
		buffPercent = 0.10,
		buffDuration = 60,
		slot = nil,
		stackable = true,
		maxStack = 20,
		rarity = "Common",
		levelReq = 1,
		stats = {},
		affixes = {},
		weaponAffinity = {},
		unique = false,
		iconId = "rbxassetid://127241747285397",
		description = "Aumenta un 10% la vida máxima durante 60 s.",
	},

	-- R7: uniques del boss del piso 5
	unique_frost_edge = {
		name = "Filo de la Escarcha",
		slot = "MainHand",
		wieldType = "OneHand",
		stackable = false,
		maxStack = 1,
		rarity = "Epic",
		levelReq = 14,
		stats = { ATK = { base = 25, roll = 0 } },
		affixes = { "+10 ATK", "+5 CRIT" },
		weaponAffinity = {},
		unique = true,
		bindState = "Free",
		iconId = "rbxassetid://75106693708328",
		visualModelId = "unique_frost_edge",
		visualType = "HandModel",
		attachTo = "RightHand",
		description = "Arma única de Jotunn, Guardián de la Escarcha.",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
	},
	unique_frostbow = {
		name = "Arco del Vendaval Helado",
		slot = "MainHand",
		wieldType = "TwoHand",
		stackable = false,
		maxStack = 1,
		rarity = "Epic",
		levelReq = 14,
		stats = { ATK = { base = 25, roll = 0 } },
		affixes = { "+10 ATK", "+5 CRIT" },
		weaponAffinity = {},
		unique = true,
		bindState = "Free",
		iconId = "rbxassetid://70555624196221",
		visualModelId = "unique_frostbow",
		visualType = "HandModel",
		attachTo = "RightHand",
		basicAttackType = "ranged",
		basicAttackRange = 30,
		basicAttackVfx = "hunter_basic_ranged",
		basicAttackAnimation = "ranged_shot",
		description = "Arco único de Jotunn, Guardián de la Escarcha.",
		offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-11, math.rad(-250), 0),
	},
	unique_glacial_wand = {
		name = "Vara del Invierno",
		slot = "MainHand",
		wieldType = "MainHandOnly",
		stackable = false,
		maxStack = 1,
		rarity = "Epic",
		levelReq = 14,
		stats = { MATK = { base = 25, roll = 0 } },
		affixes = { "+10 MATK", "+5 CRIT" },
		weaponAffinity = {},
		unique = true,
		bindState = "Free",
		iconId = "rbxassetid://84914613516649",
		visualModelId = "unique_glacial_wand",
		visualType = "HandModel",
		attachTo = "RightHand",
		description = "Vara única de Jotunn, Guardián de la Escarcha.",
		basicAttackType = "ranged",
		basicAttackRange = 30,
		basicAttackStat = "MATK",
		basicAttackVfx = "cleric_basic_ranged",
		basicAttackAnimation = "autoattack",
		offset = CFrame.new(0, -0.83, -0.10)  * CFrame.Angles(100, math.rad(180), 0),
	},
}

-- HU-ITEMS-06: templates canónicos genéricos de armas.
local weaponOffsets = {
    OneHand = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
    TwoHand = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(-5, math.rad(-250), 0),
    OffHand = CFrame.new(-0.35, -0.30, -0.16) * CFrame.Angles(0, math.rad(250), 0),
    MainHandOnly = CFrame.new(0, -0.83, -0.10) * CFrame.Angles(100, math.rad(180), 0),
}
local swordAffinity = { "Paladin_Protector", "Paladin_Castigo", "Hunter_Assault" }
local greatswordAffinity = { "Paladin_Protector", "Paladin_Castigo" }
local bowAffinity = { "Hunter_Assault", "Hunter_Punteria" }
local wandAffinity = { "Cleric_Misericordia", "Cleric_Colera" }

local function addWeaponTemplate(templateId, spec)
    local template = {
        name = spec.name,
        slot = spec.slot,
        wieldType = spec.wieldType,
        weaponFamily = spec.weaponFamily,
        stackable = false,
        maxStack = 1,
        rarity = spec.rarity,
        levelReq = spec.levelReq,
        stats = { [spec.stat] = { base = spec.base, roll = spec.roll } },
        affixes = table.clone(spec.affixes or {}),
        weaponAffinity = table.clone(spec.weaponAffinity or {}),
        unique = spec.unique == true,
        iconId = "rbxassetid://",
        description = spec.description,
        visualModelId = spec.visualModelId,
        visualType = "HandModel",
        attachTo = spec.attachTo or (spec.slot == "OffHand" and "LeftHand" or "RightHand"),
        offset = spec.offset or weaponOffsets[spec.wieldType],
    }
    if spec.unique == true then
        template.bindState = "Free"
    end
    for key, value in pairs(spec.attack or {}) do
        template[key] = value
    end
    ItemConfig[templateId] = template
end

-- Espada 1H: blanco / verde / azul / épica frost.
addWeaponTemplate("sword_white", {
    name = "Espada del aprendiz", slot = "MainHand", wieldType = "OneHand",
    rarity = "Common", levelReq = 1, stat = "ATK", base = 8, roll = 2,
    weaponAffinity = swordAffinity, visualModelId = "paladin_sword_white_segmented",
    description = "Espada básica para comenzar la aventura.",
})
addWeaponTemplate("sword_green", {
    name = "Espada de hierro", slot = "MainHand", wieldType = "OneHand",
    rarity = "Uncommon", levelReq = 5, stat = "ATK", base = 11, roll = 3,
    weaponAffinity = swordAffinity, visualModelId = "paladin_sword_green_segmented",
    description = "Espada de hierro reforzada.",
})
addWeaponTemplate("sword_blue", {
    name = "Espada del caballero", slot = "MainHand", wieldType = "OneHand",
    rarity = "Rare", levelReq = 9, stat = "ATK", base = 15, roll = 4,
    weaponAffinity = swordAffinity, visualModelId = "sword_knight_segmented",
    description = "Espada azul forjada para un caballero.",
})
addWeaponTemplate("sword_frost", {
    name = "Espada del campeón", slot = "MainHand", wieldType = "OneHand",
    rarity = "Epic", levelReq = 16, stat = "ATK", base = 20, roll = 5,
    weaponAffinity = swordAffinity, visualModelId = "paladin_sword_frost_segmented",
    description = "Espada épica de la Helada.",
})

-- Espadón 2H del Paladín. La animación se completa por el PO en AnimationRegistry.
local greatswordAttack = { basicAttackAnimation = "greatsword_autoattack" }
addWeaponTemplate("greatsword_white", {
    name = "Espadón del aprendiz", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Common", levelReq = 1, stat = "ATK", base = 12, roll = 3,
    weaponAffinity = greatswordAffinity, weaponFamily = "greatsword", visualModelId = "paladin_greatsword_segmented",
    description = "Espadón de dos manos para comenzar la aventura.",
    attack = greatswordAttack,
})
addWeaponTemplate("greatsword_green", {
    name = "Espadón esmeralda", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Uncommon", levelReq = 5, stat = "ATK", base = 17, roll = 4,
    weaponAffinity = greatswordAffinity, weaponFamily = "greatsword", visualModelId = "paladin_greatsword_green_segmented",
    description = "Espadón de dos manos reforzado con detalles esmeralda.",
    attack = greatswordAttack,
})
addWeaponTemplate("greatsword_blue", {
    name = "Espadón del caballero", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Rare", levelReq = 9, stat = "ATK", base = 23, roll = 5,
    weaponAffinity = greatswordAffinity, weaponFamily = "greatsword", visualModelId = "paladin_greatsword_blue_segmented",
    description = "Espadón azul de dos manos.",
    attack = greatswordAttack,
})
addWeaponTemplate("greatsword_frost", {
    name = "Espadón de la Helada", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Epic", levelReq = 16, stat = "ATK", base = 28, roll = 6,
    weaponAffinity = greatswordAffinity, weaponFamily = "greatsword", visualModelId = "paladin_greatsword_frost_segmented",
    description = "Espadón épico de dos manos forjado en la Helada.",
    attack = greatswordAttack,
})
addWeaponTemplate("unique_frost_greatsword", {
    name = "Espadón de Jotunn", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Epic", levelReq = 14, stat = "ATK", base = 32, roll = 0,
    unique = true, weaponFamily = "greatsword", weaponAffinity = greatswordAffinity,
    affixes = { "+10 ATK", "+5 CRIT" },
    visualModelId = "unique_frost_greatsword_segmented",
    description = "Arma única de dos manos de Jotunn, Guardián de la Escarcha.",
    attack = greatswordAttack,
})

-- Arco: blanco reusa el modelo existente; los otros tiers usan EST-34.
local bowAttack = {
    basicAttackType = "ranged", basicAttackRange = 30, basicAttackStat = "ATK",
    basicAttackVfx = "hunter_basic_ranged", basicAttackAnimation = "ranged_shot",
}
addWeaponTemplate("bow_white", {
    name = "Arco del cazador", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Common", levelReq = 1, stat = "ATK", base = 7, roll = 2,
    weaponAffinity = bowAffinity, visualModelId = "hunter_bow",
    description = "Arco de madera y cuero para el cazador.",
    offset = CFrame.new(0, -0.05, -0.10) * CFrame.Angles(90, math.rad(125), 0),
    attack = bowAttack,
})
addWeaponTemplate("bow_green", {
    name = "Arco esmeralda", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Uncommon", levelReq = 5, stat = "ATK", base = 10, roll = 3,
    weaponAffinity = bowAffinity, visualModelId = "hunter_bow_green_segmented",
    description = "Arco reforzado con detalles esmeralda.", attack = bowAttack,
})
addWeaponTemplate("bow_blue", {
    name = "Arco azul", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Rare", levelReq = 9, stat = "ATK", base = 13, roll = 4,
    weaponAffinity = bowAffinity, visualModelId = "hunter_bow_blue_segmented",
    description = "Arco azul de largo alcance.", attack = bowAttack,
})
addWeaponTemplate("bow_frost", {
    name = "Arco de la Helada", slot = "MainHand", wieldType = "TwoHand",
    rarity = "Epic", levelReq = 16, stat = "ATK", base = 18, roll = 5,
    weaponAffinity = bowAffinity, visualModelId = "hunter_bow_frost_segmented",
    description = "Arco épico de la Helada.", attack = bowAttack,
})

-- Varita: blanco reusa el modelo existente; los otros tiers usan EST-34.
local wandAttack = {
    basicAttackType = "ranged", basicAttackRange = 30, basicAttackStat = "MATK",
    basicAttackVfx = "cleric_basic_ranged", basicAttackAnimation = "autoattack",
}
addWeaponTemplate("wand_white", {
    name = "Varita del Clerigo", slot = "MainHand", wieldType = "MainHandOnly",
    rarity = "Common", levelReq = 1, stat = "MATK", base = 6, roll = 2,
    weaponAffinity = wandAffinity, visualModelId = "cleric_wand",
    description = "Varita de madera y cristal sagrado para el Clerigo.",
    offset = weaponOffsets.MainHandOnly, attack = wandAttack,
})
addWeaponTemplate("wand_green", {
    name = "Varita esmeralda", slot = "MainHand", wieldType = "MainHandOnly",
    rarity = "Uncommon", levelReq = 5, stat = "MATK", base = 8, roll = 3,
    weaponAffinity = wandAffinity, visualModelId = "cleric_wand_green_segmented",
    description = "Varita reforzada con cristal esmeralda.",
    offset = weaponOffsets.MainHandOnly, attack = wandAttack,
})
addWeaponTemplate("wand_blue", {
    name = "Varita azul", slot = "MainHand", wieldType = "MainHandOnly",
    rarity = "Rare", levelReq = 9, stat = "MATK", base = 11, roll = 4,
    weaponAffinity = wandAffinity, visualModelId = "cleric_wand_blue_segmented",
    description = "Varita azul para canalizar magia.",
    offset = weaponOffsets.MainHandOnly, attack = wandAttack,
})
addWeaponTemplate("wand_frost", {
    name = "Varita de la Helada", slot = "MainHand", wieldType = "MainHandOnly",
    rarity = "Epic", levelReq = 16, stat = "MATK", base = 15, roll = 5,
    weaponAffinity = wandAffinity, visualModelId = "cleric_wand_frost_segmented",
    description = "Varita épica de la Helada.",
    offset = weaponOffsets.MainHandOnly, attack = wandAttack,
})

-- Los modelos blanco/verde tienen el frente invertido respecto a azul/frost.
local correctedShieldOffset = weaponOffsets.OffHand * CFrame.Angles(0, math.rad(180), 0)
-- Escudo: OffHand, con modelos entregados para cada tier.
addWeaponTemplate("shield_white", {
    name = "Escudo del guardián", slot = "OffHand", wieldType = "OffHand",
    rarity = "Common", levelReq = 1, stat = "DEF", base = 5, roll = 2,
    visualModelId = "shield_guard_white_segmented",
    offset = correctedShieldOffset,
    description = "Escudo básico para protegerse en combate.",
})
addWeaponTemplate("shield_green", {
    name = "Escudo esmeralda", slot = "OffHand", wieldType = "OffHand",
    rarity = "Uncommon", levelReq = 5, stat = "DEF", base = 7, roll = 3,
    visualModelId = "shield_guard_green_segmented",
    offset = correctedShieldOffset,
    description = "Escudo reforzado con detalles esmeralda.",
})
addWeaponTemplate("shield_blue", {
    name = "Escudo azul del guardián", slot = "OffHand", wieldType = "OffHand",
    rarity = "Rare", levelReq = 9, stat = "DEF", base = 10, roll = 4,
    visualModelId = "shield_guard_blue_segmented",
    description = "Escudo azul del guardián.",
})
addWeaponTemplate("shield_frost", {
    name = "Escudo de la Helada", slot = "OffHand", wieldType = "OffHand",
    rarity = "Epic", levelReq = 16, stat = "DEF", base = 13, roll = 5,
    visualModelId = "shield_guard_frost_segmented",
    description = "Escudo épico de la Helada.",
})

-- Iconos de armas entregados por el diseñador (EST-35).
local weaponIconAssetIds = {
	sword_white = "110968716979543",
	sword_green = "114335041413535",
	sword_blue = "77771945368188",
	sword_frost = "107774517079954",
	greatsword_white = "77853522790094",
	greatsword_green = "112519480746137",
	greatsword_blue = "84789792340912",
	greatsword_frost = "89642314728136",
	unique_frost_greatsword = "75162936208141",
	bow_white = "128128096054824",
	bow_green = "94092266339166",
	bow_blue = "102901030602633",
	bow_frost = "78239239128650",
	wand_white = "112682399313409",
	wand_green = "87078722376019",
	wand_blue = "76122908004709",
	wand_frost = "107740305961644",
	shield_white = "95427121671562",
	shield_green = "113326084795693",
	shield_blue = "72048213918363",
	shield_frost = "71109419177986",
}
for templateId, assetId in pairs(weaponIconAssetIds) do
	local template = ItemConfig[templateId]
	if template then
		template.iconId = "rbxassetid://" .. assetId
	end
end

-- HU-ITEMS-04 / rc065: progresión real de armadura; conserva los seeds QA de ITEMS-03.
local seedArmor = {
	Paladin = { "paladin_helmet", "paladin_chest", "paladin_shoulders", "paladin_legs", "paladin_gloves" },
	Hunter = { "hunter_helmet", "hunter_chest", "hunter_shoulders", "hunter_legs", "hunter_gloves" },
	Cleric = { "cleric_helmet", "cleric_chest", "cleric_shoulders", "cleric_legs", "cleric_gloves" },
}
local tierLabels = { white = "Blanco", green = "Verde", blue = "Azul", frost = "Helada" }
local tierRarity = { green = "Uncommon", blue = "Rare", frost = "Epic" }
local tierMultipliers = { green = 1.4, blue = 1.9, frost = 2.5 }
local whiteLevelReq = { Helmet = 5, Shoulders = 5, Chest = 3, Gloves = 3, Legs = 3 }
local tierLevelReq = {
	green = { Helmet = 10, Shoulders = 10, Chest = 8, Gloves = 8, Legs = 8 },
	blue = { Helmet = 12, Shoulders = 12, Chest = 12, Gloves = 12, Legs = 12 },
	frost = { Helmet = 16, Shoulders = 16, Chest = 16, Gloves = 16, Legs = 16 },
}
local WHITE_ARMOR_STATS = {
	paladin_helmet = { DEF = { base = 2, roll = 0 } },
	paladin_chest = { DEF = { base = 4, roll = 1 } },
	paladin_shoulders = { DEF = { base = 2, roll = 0 } },
	paladin_legs = { DEF = { base = 2, roll = 0 } },
	paladin_gloves = { DEF = { base = 1, roll = 0 } },
	hunter_helmet = { DEF = { base = 2, roll = 0 } },
	hunter_chest = { DEF = { base = 4, roll = 1 }, MDEF = { base = 2, roll = 0 } },
	hunter_shoulders = { DEF = { base = 2, roll = 0 }, ATK = { base = 2, roll = 1 } },
	hunter_legs = { DEF = { base = 3, roll = 1 }, CRIT = { base = 0.02, roll = 0 } },
	hunter_gloves = { DEF = { base = 1, roll = 0 }, CRIT = { base = 0.01, roll = 0 } },
	cleric_helmet = { MDEF = { base = 2, roll = 0 } },
	cleric_chest = { MDEF = { base = 4, roll = 1 }, MATK = { base = 2, roll = 1 } },
	cleric_shoulders = { MDEF = { base = 2, roll = 0 }, MaxMP = { base = 10, roll = 0 } },
	cleric_legs = { MDEF = { base = 3, roll = 1 }, MATK = { base = 1, roll = 0 } },
	cleric_gloves = { MDEF = { base = 1, roll = 0 }, MaxMP = { base = 5, roll = 0 } },
}

local function cloneArmorStats(stats)
	local copy = {}
	for statName, statData in pairs(stats or {}) do
		copy[statName] = { base = statData.base, roll = statData.roll }
	end
	return copy
end

local function roundTierStat(statName, value)
	if statName == "CRIT" then
		return math.floor(value * 100 + 0.5) / 100
	end
	return math.floor(value + 0.5)
end

local TIER_ICON_OVERRIDES = {
	-- Paladín azul / Epic (frost)
	paladin_chest_blue = "rbxassetid://134271189770510",
	paladin_chest_frost = "rbxassetid://132105272114044",
	paladin_gloves_blue = "rbxassetid://82309968852691",
	paladin_gloves_frost = "rbxassetid://106235512784632",
	paladin_helmet_blue = "rbxassetid://125342863659018",
	paladin_helmet_frost = "rbxassetid://84222618927363",
	paladin_legs_blue = "rbxassetid://129042665353724",
	paladin_legs_frost = "rbxassetid://86379394662216",
	paladin_shoulders_blue = "rbxassetid://139924007305684",
	paladin_shoulders_frost = "rbxassetid://119128898339387",

	-- Cazador azul / Epic (frost)
	hunter_chest_blue = "rbxassetid://82191643047466",
	hunter_chest_frost = "rbxassetid://100073389192799",
	hunter_gloves_blue = "rbxassetid://87091991915128",
	hunter_gloves_frost = "rbxassetid://87292310959306",
	hunter_helmet_blue = "rbxassetid://74369897357833",
	hunter_helmet_frost = "rbxassetid://114445625944966",
	hunter_legs_blue = "rbxassetid://134446633198106",
	hunter_legs_frost = "rbxassetid://113168138944830",
	hunter_shoulders_blue = "rbxassetid://137054778221131",
	hunter_shoulders_frost = "rbxassetid://85957881694946",

	-- Clérigo azul / Epic (frost)
	cleric_chest_blue = "rbxassetid://111161956448008",
	cleric_chest_frost = "rbxassetid://109954741809499",
	cleric_gloves_blue = "rbxassetid://115374721962149",
	cleric_gloves_frost = "rbxassetid://98365738204862",
	cleric_helmet_blue = "rbxassetid://71432862554507",
	cleric_helmet_frost = "rbxassetid://72951498003318",
	cleric_legs_blue = "rbxassetid://73055802244770",
	cleric_legs_frost = "rbxassetid://133921780328127",
	cleric_shoulders_blue = "rbxassetid://127453089725089",
	cleric_shoulders_frost = "rbxassetid://135249942580438",
}

local TIER_MODEL_OVERRIDES = {
	-- Set azul de Paladín; tres piezas comparten el body skin por segmentos.
	paladin_chest_blue = "paladin_r15_body_skin_blue",
	paladin_gloves_blue = "paladin_r15_body_skin_blue",
	paladin_helmet_blue = "paladin_helmet_blue_model",
	paladin_legs_blue = "paladin_r15_body_skin_blue",
	paladin_shoulders_blue = "paladin_shoulders_blue_model",

	-- Set frost/Epic de Paladín; comparte el body skin segmentado para pecho, guantes y piernas.
	paladin_chest_frost = "paladin_r15_body_skin_frost",
	paladin_gloves_frost = "paladin_r15_body_skin_frost",
	paladin_helmet_frost = "paladin_helmet_frost_model",
	paladin_legs_frost = "paladin_r15_body_skin_frost",
	paladin_shoulders_frost = "paladin_shoulders_frost_model",

	-- Set azul de Cazador: BodySkin segmentado y accesorios visuales independientes.
	hunter_chest_blue = "hunter_r15_body_skin_blue",
	hunter_gloves_blue = "hunter_r15_body_skin_blue",
	hunter_legs_blue = "hunter_r15_body_skin_blue",
	hunter_helmet_blue = "hunter_helmet_blue",
	hunter_shoulders_blue = "hunter_shoulders_blue",

	-- Set frost/Epic de Cazador; BodySkin segmentado y accesorios independientes.
	hunter_chest_frost = "hunter_r15_body_skin_frost",
	hunter_gloves_frost = "hunter_r15_body_skin_frost",
	hunter_legs_frost = "hunter_r15_body_skin_frost",
	hunter_helmet_frost = "hunter_helmet_frost",
	hunter_shoulders_frost = "hunter_shoulders_frost",

	-- Set azul de Clérigo: body skin segmentado y accesorios independientes.
	cleric_chest_blue = "cleric_r15_body_skin_blue",
	cleric_gloves_blue = "cleric_r15_body_skin_blue",
	cleric_legs_blue = "cleric_r15_body_skin_blue",
	cleric_helmet_blue = "cleric_helmet_blue",
	cleric_shoulders_blue = "cleric_shoulders_blue",

	-- Set frost/Epic de Clérigo: BodySkin segmentado y accesorios independientes.
	cleric_chest_frost = "cleric_r15_body_skin_frost",
	cleric_gloves_frost = "cleric_r15_body_skin_frost",
	cleric_legs_frost = "cleric_r15_body_skin_frost",
	cleric_helmet_frost = "cleric_helmet_frost",
	cleric_shoulders_frost = "cleric_shoulders_frost",
}

local TIER_VISUAL_OVERRIDES = {
	hunter_helmet_blue = {
		visualScale = 0.7,
		offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, math.rad(180), 0),
	},
	hunter_shoulders_blue = {
		offset = CFrame.new(0, 0.5, 0.75) * CFrame.Angles(0, math.rad(180), 0),
		shoulderSpread = 1.6,
		shoulderOpenAngle = 20,
		shoulderYawAngles = { left = 180, right = 180 },
		shoulderLayoutParts = {
			left = "left pauldron_geom",
			right = "right pauldron_geom",
		},
	},
	hunter_helmet_frost = {
		visualScale = 0.7,
		offset = CFrame.new(0, -0.35, 0) * CFrame.Angles(0, math.rad(180), 0),
	},
	hunter_shoulders_frost = {
		offset = CFrame.new(0, 0.5, 0.75) * CFrame.Angles(0, math.rad(180), 0),
		shoulderSpread = 1.6,
		shoulderOpenAngle = 20,
		shoulderYawAngles = { left = 180, right = 180 },
		shoulderLayoutParts = {
			left = "left pauldron_geom",
			right = "right pauldron_geom",
		},
	},
	cleric_helmet_blue = {
		visualScale = 1.3,
		-- La malla queda desplazada hacia atrás tras el giro de 180 grados; acercarla a la frente.
		offset = CFrame.new(0, -0.65, 0.2) * CFrame.Angles(0, math.rad(0), 0),
		hideHairWhenEquipped = false,
	},
	cleric_shoulders_blue = {
		shoulderLayoutParts = {
			left = "left pauldron_geom",
			right = "right pauldron_geom",
		},
	},
	cleric_helmet_frost = {
		visualScale = 1.3,
		-- Mantener pelo visible y el mismo ajuste visual de la diadema azul.
		offset = CFrame.new(0, -0.65, 0.2) * CFrame.Angles(0, math.rad(0), 0),
		hideHairWhenEquipped = false,
	},
	cleric_shoulders_frost = {
		offset = CFrame.new(0, 0.9, 0.75) * CFrame.Angles(0, math.rad(0), 0),
		shoulderLayoutParts = {
			left = "left pauldron_geom",
			right = "right pauldron_geom",
		},
	},
}

for classId, templateIds in pairs(seedArmor) do
	local classKey = string.lower(classId)
	for _, templateId in ipairs(templateIds) do
		local base = ItemConfig[templateId]
		local whiteStats = WHITE_ARMOR_STATS[templateId]
		if base and whiteStats then
			base.stats = cloneArmorStats(whiteStats)
			base.rarity = "Common"
			base.levelReq = whiteLevelReq[base.slot] or base.levelReq
			base.setId = classKey .. "_white"
			base.seedOnly = nil

			for tier, multiplier in pairs(tierMultipliers) do
				local variant = table.clone(base)
				variant.stats = {}
				for statName, statData in pairs(base.stats) do
					variant.stats[statName] = {
						base = roundTierStat(statName, statData.base * multiplier),
						roll = roundTierStat(statName, statData.roll * multiplier),
					}
				end
				variant.affixes = table.clone(base.affixes or {})
				variant.weaponAffinity = table.clone(base.weaponAffinity or {})
				if base.bodySkinParts then
					variant.bodySkinParts = table.clone(base.bodySkinParts)
				end
				if base.shoulderLayoutParts then
					variant.shoulderLayoutParts = table.clone(base.shoulderLayoutParts)
				end
				variant.setId = classKey .. "_" .. tier
				variant.seedOnly = nil
				variant.rarity = tierRarity[tier]
				variant.levelReq = tierLevelReq[tier][base.slot]
				variant.name = base.name .. " (" .. tierLabels[tier] .. ")"
				variant.description = (base.description or "") .. " Tier " .. tierLabels[tier] .. " del set."
				-- Los tiers sin override conservan el iconId y el modelo de la pieza base.
				local variantId = templateId .. "_" .. tier
				local visualOverride = TIER_VISUAL_OVERRIDES[variantId]
				if visualOverride then
					for property, value in pairs(visualOverride) do
						variant[property] = type(value) == "table" and table.clone(value) or value
					end
				end
				variant.iconId = TIER_ICON_OVERRIDES[variantId] or base.iconId
				variant.visualModelId = TIER_MODEL_OVERRIDES[variantId] or base.visualModelId
				ItemConfig[templateId .. "_" .. tier] = variant
			end
		end
	end

	-- Seeds solo para pruebas de bonos de set (ITEMS-03); no pertenecen al loot real.
	for tier, rarity in pairs(tierRarity) do
		local setId = classKey .. "_" .. tier
		for _, templateId in ipairs(templateIds) do
			local base = ItemConfig[templateId]
			if base then
				local slotKey = string.lower(base.slot)
				local seed = table.clone(base)
				seed.stats = cloneArmorStats(base.stats)
				seed.affixes = table.clone(base.affixes or {})
				seed.weaponAffinity = table.clone(base.weaponAffinity or {})
				seed.setId = setId
				seed.seedOnly = true
				seed.rarity = rarity
				seed.name = "[QA " .. tierLabels[tier] .. "] " .. base.name
				seed.description = "Template seed de prueba de set. No pertenece a loot ni vendor."
				local seedId = "seed_" .. classKey .. "_" .. tier .. "_" .. slotKey
				ItemConfig[seedId] = seed
			end
		end
	end
end

local classSetRules = {
	paladin = {
		classId = "Paladin",
		threePiece = { multipliers = { atk = 0.08, def = 0.08 }, description = "+8% ATK y +8% DEF" },
		fourPieceBySpec = {
			Paladin_Protector = { skillId = "paladin_prot_consecration", description = "Consagración: +30% a radio y rango de lanzamiento" },
			Paladin_Castigo = { skillId = "paladin_ret_holy_ring", description = "Anillo de luz sagrada: 20% de reset por básico; 5 s de cooldown interno" },
		},
	},
	hunter = {
		classId = "Hunter",
		threePiece = { multipliers = { critBonus = 0.05 }, description = "+0.05 CRIT" },
		fourPieceBySpec = {
			Hunter_Assault = { skillId = "hunter_asm_crimson", description = "Filo carmesí: robo de vida de 20%, con límite de 15% del MaxHP por uso" },
			Hunter_Punteria = { skillId = "hunter_mm_chain", description = "Tiro en cadena: golpea 1 enemigo adicional con daño base normal" },
		},
	},
	cleric = {
		classId = "Cleric",
		threePiece = { multipliers = { matk = 0.08 }, description = "+8% MATK" },
		fourPieceBySpec = {
			Cleric_Colera = { skillId = "cleric_wrath_annihilation", description = "Aniquilación: inflige DoT de 10% del daño original por segundo durante 4 s (40% total)" },
			Cleric_Misericordia = { skillId = "cleric_hol_miracle", description = "Milagro: cura en área de radio 10 alrededor del aliado seleccionado" },
		},
	},
}

local classDisplayNames = { paladin = "Paladín", hunter = "Cazador", cleric = "Clérigo" }
ItemConfig.SET_BONUSES = {}
for classKey, rule in pairs(classSetRules) do
	for tier, tierLabel in pairs(tierLabels) do
		local setId = classKey .. "_" .. tier
		local specRules = {}
		for specId, specRule in pairs(rule.fourPieceBySpec) do
			specRules[specId] = {
				pieces = 4,
				skillId = specRule.skillId,
				description = specRule.description,
			}
		end
		ItemConfig.SET_BONUSES[setId] = {
			setId = setId,
			setName = "Set " .. classDisplayNames[classKey] .. " " .. tierLabel,
			classId = rule.classId,
			tier = tier,
			-- Las bonificaciones de clase solo existen en el set Epic (morado) Helada.
			bonusesEnabled = tier == "frost",
			threePiece = { pieces = 3, multipliers = table.clone(rule.threePiece.multipliers), description = rule.threePiece.description },
			fourPieceBySpec = specRules,
		}
	end
end

-- Slots válidos (9 total)
ItemConfig.SLOTS = {
	"Helmet", "Chest", "Shoulders", "Legs", "Gloves",
	"Ring", "Necklace", "MainHand", "OffHand",
}

-- Afijos menores y mayores (para roll de affixes)
ItemConfig.MINOR_AFFIXES = {
	{ stat = "MaxHP", value = 10, label = "+MaxHP 10" },
	{ stat = "CRIT", value = 0.05, label = "+CRIT 0.05" },
	{ stat = "DEF", value = 3, label = "+DEF 3" },
	{ stat = "MaxMP", value = 10, label = "+MaxMP 10" },
}

ItemConfig.MAJOR_AFFIXES = {
	{ stat = "ATK", value = 10, label = "+ATK 10" },
	{ stat = "MATK", value = 10, label = "+MATK 10" },
	{ stat = "DEF", value = 8, label = "+DEF 8" },
	{ stat = "MaxHP", value = 30, label = "+MaxHP 30" },
}

-- Rareza → regla de afijos
ItemConfig.RARITY_AFFIX_RULES = {
	Common = { minorAffixes = 0, majorAffixes = 0 },
	Uncommon = { minorAffixes = 0, majorAffixes = 0 }, -- roll mejor, sin afijos extra
	Rare = { minorAffixes = 1, majorAffixes = 0 },
	Epic = { minorAffixes = 0, majorAffixes = 1 },
}

local legacyWeaponTemplateAliases = {
	sword_apprentice = "sword_white",
	sword_iron = "sword_green",
	sword_knight = "sword_blue",
	sword_champion = "sword_frost",
	shield_guard = "shield_white",
	shield_guard_blue = "shield_blue",
	hunter_bow = "bow_white",
	cleric_wand = "wand_white",
}

-- Quitar los IDs antiguos del catálogo enumerable; los perfiles guardados se
-- resuelven por alias sin duplicar opciones en loot, vendors o selectores.
for legacyId in pairs(legacyWeaponTemplateAliases) do
	ItemConfig[legacyId] = nil
end

function ItemConfig.GetTemplate(templateId)
	local canonicalId = legacyWeaponTemplateAliases[templateId] or templateId
	return ItemConfig[canonicalId]
end

function ItemConfig.GetSetBonus(setId)
	return ItemConfig.SET_BONUSES[setId]
end

function ItemConfig.IsSeedTemplate(templateId)
	local template = ItemConfig.GetTemplate(templateId)
	return template ~= nil and template.seedOnly == true
end

function ItemConfig.GetSlots()
	return ItemConfig.SLOTS
end

return ItemConfig