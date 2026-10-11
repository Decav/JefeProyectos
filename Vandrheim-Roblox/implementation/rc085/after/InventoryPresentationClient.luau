--[[
rc042 - HU-ESTETICA-21
Presentation-only client for InventoryUI and EquipmentUI.
Keeps existing InventoryClient callbacks and remotes intact.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UITheme = require(ReplicatedStorage.Config:WaitForChild("UITheme"))
local CharacterPanelUIConfig = require(ReplicatedStorage.Config:WaitForChild("CharacterPanelUIConfig"))
local TooltipData = require(ReplicatedStorage.Shared:WaitForChild("TooltipData"))
local TooltipSystem = require(ReplicatedStorage.Shared:WaitForChild("TooltipSystem"))
local ClassConfig = require(ReplicatedStorage.Config:WaitForChild("ClassConfig"))
local C = UITheme.Colors
local BLACK_CELL = C.Shadow

local InventoryData = Remotes:WaitForChild("InventoryData")
local VendorResult = Remotes:WaitForChild("VendorResult")
local ItemUseSlotState = Remotes:WaitForChild("ItemUseSlotState")
local SpellbookData = Remotes:WaitForChild("SpellbookData")
local RequestSpellbook = Remotes:WaitForChild("RequestSpellbook")
local RequestUseConsumable = Remotes:WaitForChild("RequestUseConsumable")
local RequestEquipItem = Remotes:WaitForChild("RequestEquipItem")
local RequestUnequipItem = Remotes:WaitForChild("RequestUnequipItem")
local RequestDeleteItem = Remotes:WaitForChild("RequestDeleteItem")

local inventoryGui = playerGui:WaitForChild("InventoryUI")
local inventoryMain = inventoryGui:WaitForChild("MainFrame")
local bagPanel = inventoryMain:WaitForChild("BagPanel")
local bagScroll = bagPanel:WaitForChild("BagScroll")

local equipmentGui = playerGui:WaitForChild("EquipmentUI")
local equipmentMain = equipmentGui:WaitForChild("MainFrame")
local equipmentPanel = equipmentMain:WaitForChild("EquipmentPanel")
local statsPanel = equipmentMain:WaitForChild("StatsPanel")

local sharedGui = playerGui:WaitForChild("SharedUI")
local tooltip = sharedGui:WaitForChild("Tooltip")
local deleteConfirmationRequest = sharedGui:WaitForChild("RequestItemDeleteConfirmation")

local currentInventory = nil
local activeSpellbookData = nil
local useSlotState = { slots = {}, quantities = {} }
local statBreakdown = nil
local highlightedStat = nil
local highlightedItem = nil
local statLabels = {}
local equipmentBound = {}
local bagBound = {}
local statAttributeConnections = {}
-- rc084: no buttons in informational tooltips.
local selectedItemId = nil

local EQUIPMENT_SLOTS = { "Helmet", "Chest", "Shoulders", "Legs", "Gloves", "Ring", "Necklace", "MainHand", "OffHand" }
local STAT_INFO = {
	hp = { label = "MaxHP", accent = Color3.fromRGB(196, 83, 69) },
	mp = { label = "MaxMP", accent = Color3.fromRGB(92, 156, 200) },
	atk = { label = "ATK", accent = Color3.fromRGB(200, 148, 69) },
	matk = { label = "MATK", accent = Color3.fromRGB(200, 148, 69) },
	def = { label = "DEF", accent = Color3.fromRGB(143, 183, 214) },
	mdef = { label = "MDEF", accent = Color3.fromRGB(143, 183, 214) },
	crit = { label = "CRIT", accent = Color3.fromRGB(200, 148, 69), percentage = true },
	cdr = { label = "CDR", accent = Color3.fromRGB(200, 148, 69), percentage = true },
}
local STAT_ORDER = { "hp", "mp", "atk", "matk", "crit", "cdr", "def", "mdef" }
local RARITY_COLORS = {
	Common = Color3.fromRGB(244, 237, 224),
	Uncommon = Color3.fromRGB(112, 196, 138),
	Rare = Color3.fromRGB(117, 168, 224),
	Epic = Color3.fromRGB(180, 138, 222),
}
local EQUIPMENT_STAT_ORDER = {
	Helmet = { "def", "mdef" },
	Chest = { "hp", "def" },
	Shoulders = { "def", "mdef" },
	Legs = { "def" },
	Gloves = { "atk", "matk" },
	Ring = { "crit", "atk", "matk" },
	Necklace = { "hp", "mp" },
	MainHand = { "atk", "matk", "crit" },
	OffHand = { "def", "mdef", "atk" },
}
local STAT_KEY_MAP = {
	MaxHP = "hp",
	MaxMP = "mp",
	HP = "hp",
	MP = "mp",
	ATK = "atk",
	MATK = "matk",
	DEF = "def",
	MDEF = "mdef",
	CRIT = "crit",
	CDR = "cdr",
	CooldownReduction = "cdr",
}

local function ensureCorner(parent, radius)
	local corner = parent:FindFirstChild("EST21Corner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Name = "EST21Corner"
		corner.Parent = parent
	end
	corner.CornerRadius = radius or UITheme.SmallCornerRadius
end

local function ensureStroke(parent, color, transparency, thickness)
	local stroke = parent:FindFirstChild("EST21Stroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Name = "EST21Stroke"
		stroke.Parent = parent
	end
	stroke.Color = color or C.Brass
	stroke.Transparency = transparency or 0.25
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return stroke
end

local function setCellStrokeHover(slot, hovered)
	slot:SetAttribute("HearthboundCellHovered", hovered == true)
	local cellStroke = slot:FindFirstChild("EST21Stroke")
	if not cellStroke then return end
	local baseColor = slot:GetAttribute("HearthboundCellBaseStrokeColor")
	if typeof(baseColor) ~= "Color3" then baseColor = C.Brass end
	local baseThickness = tonumber(slot:GetAttribute("HearthboundCellBaseStrokeThickness")) or 1
	local baseTransparency = tonumber(slot:GetAttribute("HearthboundCellBaseStrokeTransparency")) or 0
	local selected = slot:GetAttribute("HearthboundCellSelected") == true
	cellStroke.Color = hovered and baseColor:Lerp(C.Parchment, 0.28) or (selected and C.BrassBright or baseColor)
	cellStroke.Thickness = hovered and math.max(2, baseThickness + 0.5) or (selected and math.max(2, baseThickness) or baseThickness)
	cellStroke.Transparency = hovered and 0 or baseTransparency
end

local function bindCellStrokeInput(slot)
	if slot:GetAttribute("HearthboundCellStrokeBound") then return end
	slot:SetAttribute("HearthboundCellStrokeBound", true)
	slot:GetAttributeChangedSignal("HearthboundCellSelected"):Connect(function()
		setCellStrokeHover(slot, slot:GetAttribute("HearthboundCellHovered") == true)
	end)
	slot.MouseEnter:Connect(function() setCellStrokeHover(slot, true) end)
	slot.MouseLeave:Connect(function() setCellStrokeHover(slot, false) end)
	slot.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then setCellStrokeHover(slot, true) end
	end)
	slot.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then setCellStrokeHover(slot, false) end
	end)
end

local function ensureAspect(parent, ratio)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("UIAspectRatioConstraint") and child.Name ~= "EST21Aspect" then
			child:Destroy()
		end
	end
	local constraint = parent:FindFirstChild("EST21Aspect")
	if not constraint then
		constraint = Instance.new("UIAspectRatioConstraint")
		constraint.Name = "EST21Aspect"
		constraint.Parent = parent
	end
	constraint.AspectRatio = ratio
	constraint.AspectType = Enum.AspectType.FitWithinMaxSize
	constraint.DominantAxis = Enum.DominantAxis.Width
	return constraint
end

local function ensureScale(parent)
	local scale = parent:FindFirstChild("EST21Scale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "EST21Scale"
		scale.Parent = parent
	end
	return scale
end

local function ensureLabel(parent, name, text)
	local label = parent:FindFirstChild(name)
	if not label then
		label = Instance.new("TextLabel")
		label.Name = name
		label.Parent = parent
	end
	label.Text = text or ""
	return label
end

local function configureText(label, font, color, size)
	if not label or not label:IsA("TextLabel") and not label:IsA("TextButton") then
		return
	end
	label.Font = font or UITheme.GetFont("Body")
	label.TextColor3 = color or C.Text
	label.TextSize = size or 12
	label.TextScaled = false
	label.TextWrapped = false
	label.TextStrokeTransparency = 1
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
end

local function configureButton(button, text, variant)
	local normal, hover, textColor = UITheme.GetButtonColors(variant or "Secondary")
	button.Text = text
	button.Font = UITheme.GetFont("BodyMedium")
	button.TextSize = 11
	button.TextColor3 = textColor
	button.TextStrokeTransparency = 1
	button.TextScaled = false
	button.AutoButtonColor = false
	button.BackgroundColor3 = normal
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	ensureCorner(button, UDim.new(0, 4))
	ensureStroke(button, variant == "Primary" and C.BrassBright or C.Brass, 0.2, 1)
	if not button:GetAttribute("EST21Bound") then
		button:SetAttribute("EST21Bound", true)
		button.MouseEnter:Connect(function()
			if button.Active then
				TweenService:Create(button, UITheme.HoverTween, { BackgroundColor3 = hover }):Play()
			end
		end)
		button.MouseLeave:Connect(function()
			if button.Active then
				TweenService:Create(button, UITheme.HoverTween, { BackgroundColor3 = normal }):Play()
			end
		end)
	end
end

local function formatNumber(value)
	return tostring(math.floor((tonumber(value) or 0) + 0.5))
end

local function formatCritPercent(value)
	local percent = (tonumber(value) or 0) * 100
	local rounded = string.format("%.1f", percent):gsub("%.0$", "")
	return rounded .. "%"
end

local function formatStatValue(statKey, value)
	return STAT_INFO[statKey] and STAT_INFO[statKey].percentage and formatCritPercent(value) or formatNumber(value)
end

local function formatItemStat(statName, value)
	if string.upper(tostring(statName)) == "CRIT" then
		local numeric = tonumber(value) or 0
		return "+" .. formatCritPercent(numeric >= 1 and numeric / 100 or numeric) .. " CRIT"
	end
	return "+" .. formatNumber(value) .. " " .. tostring(statName)
end

local function formatItemAffix(affix)
	local label = tostring(affix)
	local stat, value = label:match("^%+(%a+)%s+([%d]*%.?[%d]+)$")
	if not stat then value, stat = label:match("^%+([%d]*%.?[%d]+)%s+(%a+)$") end
	if stat and string.upper(stat) == "CRIT" then
		return formatItemStat(stat, value)
	end
	return label
end

local currentGold = tonumber(player:GetAttribute("Gold")) or 0
local function updateGold(value)
	currentGold = tonumber(value) or 0
	local label = inventoryMain:FindFirstChild("GoldLabel")
	if label then
		local digits = tostring(math.max(0, math.floor(currentGold)))
		label.Text = "◈ " .. digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end
end

local function getCharacter()
	return player.Character
end

local function getStatValue(statKey)
	local character = getCharacter()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if statKey == "hp" then
		return humanoid and humanoid.MaxHealth
	end
	local attributes = {
		mp = "MaxMP",
		atk = "ATK",
		matk = "MATK",
		def = "DEF",
		mdef = "MDEF",
		crit = "CRIT",
		cdr = "CooldownReduction",
	}
	if statKey == "cdr" then return character and (character:GetAttribute(attributes.cdr) or 0) end
	return character and attributes[statKey] and character:GetAttribute(attributes[statKey])
end

local function mapStatKey(statName)
	return STAT_KEY_MAP[statName] or STAT_KEY_MAP[string.upper(tostring(statName or ""))]
end

local function getItemStatKeys(item)
	local result = {}
	local seen = {}
	local function add(statName)
		local key = mapStatKey(statName)
		if key and not seen[key] then
			seen[key] = true
			table.insert(result, key)
		end
	end
	for statName in pairs(item and item.stats or {}) do
		add(statName)
	end
	for _, affix in ipairs(item and item.affixes or {}) do
		for token in string.gmatch(string.upper(tostring(affix)), "MAXHP|MAXMP|MATK|MDEF|ATK|DEF|CRIT|HP|MP") do
			add(token)
		end
	end
	return result
end

local function findItem(instanceId)
	if not currentInventory or type(instanceId) ~= "string" or instanceId == "" then
		return nil
	end
	for _, item in ipairs(currentInventory.bag or {}) do
		if item and item.instanceId == instanceId then
			return item
		end
	end
	for _, item in pairs(currentInventory.equipment or {}) do
		if item and item.instanceId == instanceId then
			return item
		end
	end
	return nil
end

local function findEquippedSlot(instanceId)
	for _, slotName in ipairs(EQUIPMENT_SLOTS) do
		local item = currentInventory and currentInventory.equipment and currentInventory.equipment[slotName]
		if item and item.instanceId == instanceId then
			return slotName
		end
	end
	return nil
end

local function getEquipmentSourceNames(statKey)
	local names = {}
	local seen = {}
	for _, item in pairs(currentInventory and currentInventory.equipment or {}) do
		if item then
			local contributes = table.find(getItemStatKeys(item), statKey) ~= nil
			if contributes and not seen[item.instanceId or item.name] then
				seen[item.instanceId or item.name] = true
				table.insert(names, item.name or item.templateId or "Equipo")
			end
		end
	end
	return names
end

local highlightedKeys = {}
local renderStats

local function renderBreakdown(_statKey)
	if renderStats then renderStats() end
end

local function setHighlightedStats(keys)
	table.clear(highlightedKeys)
	for _, key in ipairs(keys or {}) do
		highlightedKeys[key] = true
	end
	if renderStats then renderStats() end
end

renderStats = function()
	local config = CharacterPanelUIConfig
	local colors = config.Colors
	local headerSpecs = config.Groups
	local headerNames = {"resources", "attack", "defense"}
	for _, key in ipairs(headerNames) do
		local spec = headerSpecs[key]
		local name = "EST45" .. string.upper(string.sub(key,1,1)) .. string.sub(key,2) .. "Header"
		local header = ensureLabel(statsPanel, name, spec.label)
		header.Position = UDim2.fromScale(spec.x / config.Stats.width, spec.y / config.Stats.height)
		header.Size = UDim2.fromScale(spec.width / config.Stats.width, spec.height / config.Stats.height)
		header.BackgroundColor3 = colors.Group
		header.BackgroundTransparency = 0
		header.TextColor3 = colors.Parchment
		header.TextXAlignment = Enum.TextXAlignment.Center
		header.TextYAlignment = Enum.TextYAlignment.Center
		header.ZIndex = statsPanel.ZIndex + 2
		configureText(header, Enum.Font.BuilderSansBold, colors.Parchment, math.floor(spec.fontSize + 0.5))
		header.BackgroundTransparency = 0
	end
	local statsTitle = statsPanel:FindFirstChild("StatsTitle")
	if statsTitle then
		statsTitle.Text = "ATRIBUTOS DEL PERSONAJE"
		statsTitle.Position = UDim2.fromScale(12 / config.Stats.width, 7 / config.Stats.height)
		statsTitle.Size = UDim2.fromScale(256 / config.Stats.width, 16 / config.Stats.height)
		statsTitle.TextXAlignment = Enum.TextXAlignment.Center
		statsTitle.TextYAlignment = Enum.TextYAlignment.Center
		statsTitle.ZIndex = statsPanel.ZIndex + 3
		configureText(statsTitle, Enum.Font.BuilderSansBold, colors.Parchment, 12)
	end
	local rowIndex = 0
	for _, key in ipairs(STAT_ORDER) do
		local row = statLabels[key]
		local spec = config.StatRows[key]
		if row and spec then
			rowIndex += 1
			row.Position = UDim2.fromScale(10 / config.Stats.width, spec.y / config.Stats.height)
			row.Size = UDim2.fromScale(260 / config.Stats.width, config.StatRowHeight / config.Stats.height)
			row.Active = true
			row.Text = ""
			row.TextTransparency = 1
			row.BackgroundColor3 = rowIndex % 2 == 1 and colors.RowA or colors.RowB
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			row.ZIndex = statsPanel.ZIndex + 1
			for _, child in ipairs(row:GetChildren()) do
				if child:IsA("UICorner") then child:Destroy() end
				if child:IsA("UIStroke") then child.Enabled = false end
				if child.Name == "EST21Glyph" or child.Name == "EST21Detail" then child.Visible = false end
			end
			local statName = ensureLabel(row, "EST21Name", spec.label)
			statName.Position = UDim2.fromScale(8 / 260, 0)
			statName.Size = UDim2.fromScale(150 / 260, 1)
			statName.TextXAlignment = Enum.TextXAlignment.Left
			statName.TextYAlignment = Enum.TextYAlignment.Center
			statName.ZIndex = row.ZIndex + 1
			configureText(statName, Enum.Font.BuilderSans, colors.Gold, 11)
			local value = ensureLabel(row, "EST21Value", "")
			value.Position = UDim2.fromScale(200 / 260, 0)
			value.Size = UDim2.fromScale(50 / 260, 1)
			value.TextXAlignment = Enum.TextXAlignment.Right
			value.TextYAlignment = Enum.TextYAlignment.Center
			value.ZIndex = row.ZIndex + 1
			local numericValue = tonumber(getStatValue(key)) or 0
			value.TextColor3 = (key == "mp" or (key == "cdr" and numericValue == 0)) and colors.Parchment or colors.Green
			configureText(value, Enum.Font.BuilderSansBold, value.TextColor3, 12)
			value.Text = formatStatValue(key, getStatValue(key))
		end
	end
	local obsoleteHint = statsPanel:FindFirstChild("EST21StatsHint")
	if obsoleteHint then obsoleteHint.Visible = false end
	for _, key in ipairs(STAT_ORDER) do
		local label = statLabels[key]
		if label then
			local value = label:FindFirstChild("EST21Value")
			if value then value.Text = formatStatValue(key, getStatValue(key)) end
		end
	end
end

local function bindStatHover()
	for key, row in pairs(statLabels) do
		if row and not row:GetAttribute("EST45TooltipBound") then
			row:SetAttribute("EST45TooltipBound", true)
			TooltipSystem.Bind(row, function()
				local value = getStatValue(key)
				if value == nil then return nil end
				return TooltipData.Stat(key, statBreakdown and statBreakdown[key], value)
			end)
		end
	end
end

local function updateHeader()
	local config = CharacterPanelUIConfig
	local title = equipmentMain:FindFirstChild("Title")
	if title then
		local name = player:GetAttribute("CharacterName") or player.Name
		title.Visible = true
		title.Position = UDim2.fromScale(18 / config.DesignWidth, 11 / config.DesignHeight)
		title.Size = UDim2.fromScale(444 / config.DesignWidth, 19 / config.DesignHeight)
		title.Text = tostring(name)
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.TextYAlignment = Enum.TextYAlignment.Center
		title.ZIndex = equipmentMain.ZIndex + 5
		configureText(title, Enum.Font.BuilderSansBold, config.Colors.Parchment, 15)
	end
	local legacyTitle = equipmentMain:FindFirstChild("EST21WindowTitle")
	if legacyTitle then legacyTitle.Visible = false end
	local header = equipmentMain:FindFirstChild("EST21Header")
	if not header then
		header = Instance.new("Frame")
		header.Name = "EST21Header"
		header.Parent = equipmentMain
	end
	header.Position = UDim2.fromScale(18 / config.DesignWidth, 39 / config.DesignHeight)
	header.Size = UDim2.fromScale(444 / config.DesignWidth, 13 / config.DesignHeight)
	header.BackgroundTransparency = 1
	header.ZIndex = equipmentMain.ZIndex + 4
	local identity = ensureLabel(header, "Identity", "")
	identity.Position = UDim2.fromScale(0, 0)
	identity.Size = UDim2.fromScale(1, 1)
	identity.TextXAlignment = Enum.TextXAlignment.Center
	identity.TextYAlignment = Enum.TextYAlignment.Center
	identity.ZIndex = header.ZIndex + 1
	configureText(identity, Enum.Font.BuilderSansBold, config.Colors.Gold, 9)
	local character = getCharacter()
	local function normalizeIdentity(value)
		return string.lower(tostring(value or "")):gsub("[%s_%-]", "")
	end
	local classData, classId
	local classCandidates = {}
	local playerClassId = player:GetAttribute("ClassId")
	local playerCharacterClass = player:GetAttribute("CharacterClass")
	local spellbookClassId = activeSpellbookData and activeSpellbookData.classId
	local characterClassId = character and character:GetAttribute("ClassId")
	if playerClassId ~= nil then table.insert(classCandidates, playerClassId) end
	if spellbookClassId ~= nil then table.insert(classCandidates, spellbookClassId) end
	if playerCharacterClass ~= nil then table.insert(classCandidates, playerCharacterClass) end
	if characterClassId ~= nil then table.insert(classCandidates, characterClassId) end
	for _, candidate in ipairs(classCandidates) do
		local candidateText = tostring(candidate or "")
		local candidates = { candidateText }
		local root = candidateText:match("^([^_%-]+)")
		local suffix = candidateText:match("([^_%-]+)$")
		if root then table.insert(candidates, root) end
		if suffix then table.insert(candidates, suffix) end
		for _, classCandidate in ipairs(candidates) do
			local normalizedCandidate = normalizeIdentity(classCandidate)
			if normalizedCandidate ~= "" then
				for configuredClassId, data in pairs(ClassConfig) do
					if normalizedCandidate == normalizeIdentity(configuredClassId)
						or normalizedCandidate == normalizeIdentity(data.DisplayName) then
						classId, classData = configuredClassId, data
						break
					end
				end
			end
			if classData then break end
		end
		if classData then break end
	end
	local className = classData and classData.DisplayName
		or tostring((activeSpellbookData and activeSpellbookData.classId) or player:GetAttribute("CharacterClass") or player:GetAttribute("ClassId") or "Clase")
	local rawSpec = (activeSpellbookData and activeSpellbookData.specId) or player:GetAttribute("SpecId")
		or (character and character:GetAttribute("SpecId"))
		or player:GetAttribute("CharacterSpec")
		or (character and character:GetAttribute("CharacterSpec"))
	local specName = "Especialización"
	if rawSpec ~= nil then
		local rawSpecText = tostring(rawSpec)
		local specSuffix = rawSpecText:match("([^_%-]+)$") or rawSpecText
		for key, spec in pairs(classData and classData.Specs or {}) do
			if normalizeIdentity(rawSpecText) == normalizeIdentity(key)
				or normalizeIdentity(rawSpecText) == normalizeIdentity(spec.Name)
				or normalizeIdentity(specSuffix) == normalizeIdentity(key)
				or normalizeIdentity(specSuffix) == normalizeIdentity(spec.Name) then
				specName = spec.Name
				break
			end
		end
		if specName == "Especialización" then
			specName = specSuffix:gsub("_", " "):gsub("%-", " ")
			specName = string.upper(string.sub(specName, 1, 1)) .. string.sub(specName, 2)
		end
	end
	local level = player:GetAttribute("CharacterLevel") or 1
	identity.Text = string.upper(className .. " · " .. specName .. " · NIVEL " .. tostring(level))
	identity.TextTruncate = Enum.TextTruncate.AtEnd
	for _, name in ipairs({"XPTrack", "XPText"}) do
		local obsolete = header:FindFirstChild(name)
		if obsolete then obsolete.Visible = false end
	end
end

local function styleEquipmentSlot(slot, index)
	local config = CharacterPanelUIConfig
	local spec = config.Slots[slot.Name]
	if not spec then return end
	slot.Position = UDim2.fromScale(spec.x / config.DesignWidth, spec.y / config.DesignHeight)
	slot.Size = UDim2.fromScale(config.SlotSize / config.DesignWidth, config.SlotSize / config.DesignHeight)
	slot.AnchorPoint = Vector2.zero
	ensureAspect(slot, 1)
	local item = currentInventory and currentInventory.equipment and currentInventory.equipment[slot.Name]
	local blocked = slot:GetAttribute("blockedByTwoHand") == true
	local hasItem = item ~= nil and not blocked
	local rarityColor = hasItem and RARITY_COLORS[item.rarity] or config.Colors.EmptyStroke
	slot:SetAttribute("HearthboundBlackCell", true)
	slot:SetAttribute("HearthboundCellBaseStrokeColor", rarityColor)
	slot:SetAttribute("HearthboundCellBaseStrokeThickness", hasItem and 1.5 or 1)
	slot:SetAttribute("HearthboundCellBaseStrokeTransparency", hasItem and 0 or 0.25)
	slot.BackgroundColor3 = config.Colors.Slot
	slot.BackgroundTransparency = 0
	slot.BorderSizePixel = 0
	slot.Active = true
	slot.ZIndex = equipmentMain.ZIndex + 1
	ensureCorner(slot, UDim.new(0, 4))
	local stroke = ensureStroke(slot, rarityColor, hasItem and 0 or 0.25, hasItem and 1.5 or 1)
	for _, child in ipairs(slot:GetChildren()) do
		if child:IsA("UIStroke") and child ~= stroke then child.Enabled = false end
	end
	if not slot:GetAttribute("EST21StrokeBound") then
		slot:SetAttribute("EST21StrokeBound", true)
		slot.ChildAdded:Connect(function(child)
			if child:IsA("UIStroke") and child.Name ~= "EST21Stroke" then child.Enabled = false end
		end)
	end
	local label = slot:FindFirstChild("SlotLabel")
	if label then
		label.Text = UserInputService.TouchEnabled
			and (blocked and (spec.blockedTextMobile or spec.mobileText) or spec.mobileText)
			or (blocked and spec.blockedText or spec.emptyText)
		label.Position = UDim2.fromScale(0.08, 0.28)
		label.Size = UDim2.fromScale(0.84, 0.44)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.TextWrapped = true
		label.ZIndex = slot.ZIndex + 2
		configureText(label, Enum.Font.BuilderSansBold, config.Colors.EmptyText, 9)
		label.Visible = not hasItem
	end
	local separator = slot:FindFirstChild("SlotSeparator")
	if separator then separator.Visible = false end
	local icon = slot:FindFirstChild("ItemIcon")
	if icon then
		icon.Position = UDim2.fromScale(5 / config.SlotSize, 5 / config.SlotSize)
		icon.Size = UDim2.fromScale(64 / config.SlotSize, 64 / config.SlotSize)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.BackgroundTransparency = 1
		icon.ZIndex = slot.ZIndex + 1
		for _, child in ipairs(icon:GetChildren()) do
			if child:IsA("UIStroke") then child.Enabled = false end
		end
		if not icon:GetAttribute("EST21StrokeBound") then
			icon:SetAttribute("EST21StrokeBound", true)
			icon.ChildAdded:Connect(function(child)
				if child:IsA("UIStroke") then child.Enabled = false end
			end)
		end
	end
	local itemName = slot:FindFirstChild("ItemName")
	if itemName then itemName.Visible = false end
	bindCellStrokeInput(slot)
	if not equipmentBound[slot] then
		equipmentBound[slot] = true
		slot.MouseEnter:Connect(function()
			local equipped = currentInventory and currentInventory.equipment and currentInventory.equipment[slot.Name]
			highlightedItem = equipped
			local keys = equipped and getItemStatKeys(equipped) or EQUIPMENT_STAT_ORDER[slot.Name] or {}
			setHighlightedStats(keys)
			local key = keys[1]
			if key then highlightedStat = key; renderBreakdown(key) end
		end)
		slot.MouseLeave:Connect(function()
			highlightedItem = nil
			highlightedStat = nil
			setHighlightedStats({})
			renderBreakdown(nil)
		end)
	end
end

local function styleEquipmentWindow()
	local config = CharacterPanelUIConfig
	equipmentMain.AnchorPoint = Vector2.new(0.5, 0.5)
	equipmentMain.Position = UDim2.fromScale(UserInputService.TouchEnabled and 0.5 or 0.25, 0.51)
	equipmentMain.BackgroundColor3 = config.Colors.Canvas
	equipmentMain.BackgroundTransparency = 0
	equipmentMain.BorderSizePixel = 0
	equipmentMain.ClipsDescendants = false
	ensureAspect(equipmentMain, config.DesignWidth / config.DesignHeight)
	ensureCorner(equipmentMain, UDim.new(0, 10))
	local mainStroke = ensureStroke(equipmentMain, config.Colors.Wood, 0, 1)
	for _, child in ipairs(equipmentMain:GetChildren()) do
		if child:IsA("UIStroke") and child ~= mainStroke then child.Enabled = false end
	end
	local title = equipmentMain:FindFirstChild("Title")
	if title then title.Visible = true end
	local close = equipmentMain:FindFirstChild("CloseButton")
	if close then
		close.Text = ""
		close.BackgroundTransparency = 1
		close.ZIndex = equipmentMain.ZIndex + 10
	end
	local legacyTitle = equipmentPanel:FindFirstChild("EquipTitle")
	if legacyTitle then legacyTitle.Visible = false end
	equipmentPanel.Position = UDim2.fromScale(0, 0)
	equipmentPanel.Size = UDim2.fromScale(1, 1)
	equipmentPanel.BackgroundTransparency = 1
	equipmentPanel.BorderSizePixel = 0
	equipmentPanel.ClipsDescendants = false
	for _, child in ipairs(equipmentPanel:GetChildren()) do
		if child:IsA("UIStroke") then child.Enabled = false end
	end
	for _, slotName in ipairs(EQUIPMENT_SLOTS) do
		local slot = equipmentPanel:FindFirstChild(slotName)
		if slot then styleEquipmentSlot(slot) end
	end
	statsPanel.AnchorPoint = Vector2.zero
	statsPanel.Position = UDim2.fromScale(config.Stats.x / config.DesignWidth, config.Stats.y / config.DesignHeight)
	statsPanel.Size = UDim2.fromScale(config.Stats.width / config.DesignWidth, config.Stats.height / config.DesignHeight)
	statsPanel.BackgroundColor3 = config.Colors.Stats
	statsPanel.BackgroundTransparency = 0
	statsPanel.BorderSizePixel = 0
	statsPanel.ZIndex = equipmentMain.ZIndex + 2
	ensureCorner(statsPanel, UDim.new(0, 8))
	local statsStroke = ensureStroke(statsPanel, config.Colors.Wood, 0, 1)
	for _, child in ipairs(statsPanel:GetChildren()) do
		if child:IsA("UIStroke") and child ~= statsStroke then child.Enabled = false end
	end
	statLabels = {
		hp = statsPanel:FindFirstChild("HealthStat"),
		mp = statsPanel:FindFirstChild("ManaStat"),
		atk = statsPanel:FindFirstChild("AttackStat"),
		matk = statsPanel:FindFirstChild("MagicAttackStat"),
		crit = statsPanel:FindFirstChild("CritStat"),
		cdr = statsPanel:FindFirstChild("CooldownReductionStat"),
		def = statsPanel:FindFirstChild("DefenseStat"),
		mdef = statsPanel:FindFirstChild("MagicDefenseStat"),
	}
	for _, label in pairs(statLabels) do if label then label.Visible = true end end
	bindStatHover()
	renderStats()
	local breakdown = equipmentMain:FindFirstChild("BreakdownPanel")
	if breakdown then breakdown.Visible = false end
	updateHeader()
end

local function bindCharacterDisplaySignals(character)
	for _, connection in ipairs(statAttributeConnections) do connection:Disconnect() end
	table.clear(statAttributeConnections)
	if not character then
		renderStats()
		return
	end
	for _, attributeName in ipairs({"ClassId", "SpecId", "MaxMP", "ATK", "MATK", "DEF", "MDEF", "CRIT", "CooldownReduction"}) do
		table.insert(statAttributeConnections, character:GetAttributeChangedSignal(attributeName):Connect(function()
			if attributeName == "ClassId" or attributeName == "SpecId" then updateHeader() end
			renderStats()
			TooltipSystem.Refresh()
		end))
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(statAttributeConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			renderStats()
			TooltipSystem.Refresh()
		end))
	end
	renderStats()
	updateHeader()
end

local function styleBagSlot(slot)
	local index = tonumber(string.match(slot.Name, "%d+")) or 0
	local item = currentInventory and currentInventory.bag and currentInventory.bag[index]
	local rarityColor = item and RARITY_COLORS[item.rarity] or Color3.fromRGB(58, 48, 42)
	slot:SetAttribute("HearthboundBlackCell", true)
	slot:SetAttribute("HearthboundCellBaseStrokeColor", rarityColor)
	slot:SetAttribute("HearthboundCellBaseStrokeThickness", item and 1.5 or 1)
	slot:SetAttribute("HearthboundCellBaseStrokeTransparency", item and 0 or 0.25)
	slot:SetAttribute("HearthboundCellSelected", item ~= nil and item.instanceId == selectedItemId)
	slot.BackgroundColor3 = BLACK_CELL
	slot.BackgroundTransparency = 0
	slot.BorderSizePixel = 0
	slot.LayoutOrder = index
	slot.Active = true
	ensureCorner(slot, UDim.new(0, 4))
	local isSelected = slot:GetAttribute("HearthboundCellSelected") == true
	local stroke = ensureStroke(slot, isSelected and C.BrassBright or rarityColor, item and 0 or 0.25, isSelected and 2 or (item and 1.5 or 1))
	for _, child in ipairs(slot:GetChildren()) do
		if child:IsA("UIStroke") and child ~= stroke then child.Enabled = false end
	end
	local rarityBar = slot:FindFirstChild("RarityBar")
	if rarityBar then rarityBar.Visible = false end
	local icon = slot:FindFirstChild("ItemIcon")
	if icon then
		icon.Position = UDim2.fromScale(0.08, 0.09)
		icon.Size = UDim2.fromScale(0.84, 0.79)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.BackgroundTransparency = 1
		for _, child in ipairs(icon:GetChildren()) do
			if child:IsA("UIStroke") then child.Enabled = false end
		end
	end
	local quantity = slot:FindFirstChild("Quantity")
	if quantity then
		quantity.Position = UDim2.fromScale(0.51, 0.76)
		quantity.Size = UDim2.fromScale(0.43, 0.2)
		quantity.TextColor3 = C.Parchment
		quantity.Font = UITheme.GetFont("Mono")
		quantity.TextSize = 11
		quantity.ZIndex = 4
	end
	local marker = slot:FindFirstChild("UseMarker")
	if not marker then
		marker = Instance.new("TextLabel")
		marker.Name = "UseMarker"
		marker.Parent = slot
	end
	marker.Position = UDim2.fromScale(0.04, 0.74)
	marker.Size = UDim2.fromScale(0.22, 0.22)
	marker.BackgroundColor3 = C.BrassDark
	marker.BackgroundTransparency = 0.05
	marker.TextColor3 = C.Parchment
	marker.Font = UITheme.GetFont("Mono")
	marker.TextSize = 9
	marker.Text = ""
	marker.Visible = false
	marker.ZIndex = 4
	marker.TextXAlignment = Enum.TextXAlignment.Center
	marker.TextYAlignment = Enum.TextYAlignment.Center
	ensureCorner(marker, UDim.new(0, 3))
	ensureStroke(marker, C.BrassBright, 0.15, 1)
	bindCellStrokeInput(slot)
	if not bagBound[slot] then
		bagBound[slot] = true
		slot.MouseEnter:Connect(function()
			local item = findItem(slot:GetAttribute("ItemInstanceId"))
			if item then
				local key = getItemStatKeys(item)[1]
				if key then renderBreakdown(key) end
			end
		end)
	end
end

local function renderUseMarkers()
	for index = 1, 20 do
		local slot = bagScroll:FindFirstChild("BagSlot" .. tostring(index))
		if slot then
			styleBagSlot(slot)
			local marker = slot:FindFirstChild("UseMarker")
			local templateId = slot:GetAttribute("ItemTemplateId")
			local markerText = ""
			if templateId and templateId ~= "" then
				if useSlotState.slots and useSlotState.slots[1] == templateId then
					markerText = "Z"
				elseif useSlotState.slots and useSlotState.slots[2] == templateId then
					markerText = "X"
				end
			end
			marker.Text = markerText
			marker.Visible = markerText ~= ""
		end
	end
end

local deleteDialogGui = playerGui:FindFirstChild("ItemDeleteConfirmationUI")
if not deleteDialogGui then
	deleteDialogGui = Instance.new("ScreenGui")
	deleteDialogGui.Name = "ItemDeleteConfirmationUI"
	deleteDialogGui.ResetOnSpawn = false
	deleteDialogGui.IgnoreGuiInset = false
	deleteDialogGui.DisplayOrder = 1100
	deleteDialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	deleteDialogGui.Parent = playerGui
end

local deleteShade = deleteDialogGui:FindFirstChild("Shade") or Instance.new("Frame")
deleteShade.Name = "Shade"
deleteShade.Parent = deleteDialogGui
deleteShade.Position = UDim2.fromScale(0, 0)
deleteShade.Size = UDim2.fromScale(1, 1)
deleteShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
deleteShade.BackgroundTransparency = 0.42
deleteShade.BorderSizePixel = 0
deleteShade.Active = true
deleteShade.Visible = false
deleteShade.ZIndex = 100

local deleteDialog = deleteShade:FindFirstChild("Dialog") or Instance.new("Frame")
deleteDialog.Name = "Dialog"
deleteDialog.Parent = deleteShade
deleteDialog.AnchorPoint = Vector2.new(0.5, 0.5)
deleteDialog.Position = UDim2.fromScale(0.5, 0.5)
deleteDialog.BackgroundColor3 = C.Surface
deleteDialog.BorderSizePixel = 0
deleteDialog.Active = true
deleteDialog.ZIndex = 101
ensureCorner(deleteDialog, UDim.new(0, 8))
ensureStroke(deleteDialog, C.BrassDark, 0, 2)

local deleteTitle = deleteDialog:FindFirstChild("Title") or Instance.new("TextLabel")
deleteTitle.Name = "Title"
deleteTitle.Parent = deleteDialog
deleteTitle.BackgroundTransparency = 1
deleteTitle.Position = UDim2.fromScale(0.07, 0.07)
deleteTitle.Size = UDim2.fromScale(0.86, 0.14)
deleteTitle.Text = "ELIMINAR OBJETO"
deleteTitle.TextXAlignment = Enum.TextXAlignment.Left
deleteTitle.ZIndex = 102
configureText(deleteTitle, UITheme.GetFont("Mono"), C.BrassBright, 14)

local deleteIcon = deleteDialog:FindFirstChild("ItemIcon") or Instance.new("ImageLabel")
deleteIcon.Name = "ItemIcon"
deleteIcon.Parent = deleteDialog
deleteIcon.Position = UDim2.fromScale(0.08, 0.25)
deleteIcon.Size = UDim2.fromScale(0.18, 0.30)
deleteIcon.BackgroundColor3 = C.Slot
deleteIcon.BackgroundTransparency = 0.05
deleteIcon.BorderSizePixel = 0
deleteIcon.ScaleType = Enum.ScaleType.Fit
deleteIcon.ZIndex = 102
ensureCorner(deleteIcon, UDim.new(0, 5))
ensureStroke(deleteIcon, C.BrassDark, 0, 1)
local deleteIconAspect = deleteIcon:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint")
deleteIconAspect.AspectRatio = 1
deleteIconAspect.Parent = deleteIcon
local deleteIconPlaceholder = deleteIcon:FindFirstChild("IconPlaceholder") or Instance.new("TextLabel")
deleteIconPlaceholder.Name = "IconPlaceholder"
deleteIconPlaceholder.Parent = deleteIcon
deleteIconPlaceholder.BackgroundTransparency = 1
deleteIconPlaceholder.Size = UDim2.fromScale(1, 1)
deleteIconPlaceholder.Text = "✦"
deleteIconPlaceholder.TextScaled = true
deleteIconPlaceholder.TextColor3 = C.BrassBright
deleteIconPlaceholder.ZIndex = 103

local deleteItemLabel = deleteDialog:FindFirstChild("ItemSummary") or Instance.new("TextLabel")
deleteItemLabel.Name = "ItemSummary"
deleteItemLabel.Parent = deleteDialog
deleteItemLabel.BackgroundTransparency = 1
deleteItemLabel.Position = UDim2.fromScale(0.31, 0.25)
deleteItemLabel.Size = UDim2.fromScale(0.61, 0.30)
deleteItemLabel.TextWrapped = true
deleteItemLabel.TextXAlignment = Enum.TextXAlignment.Left
deleteItemLabel.TextYAlignment = Enum.TextYAlignment.Center
deleteItemLabel.ZIndex = 102
configureText(deleteItemLabel, UITheme.GetFont("BodyBold"), C.Parchment, 15)

local deleteWarning = deleteDialog:FindFirstChild("Warning") or Instance.new("TextLabel")
deleteWarning.Name = "Warning"
deleteWarning.Parent = deleteDialog
deleteWarning.BackgroundTransparency = 1
deleteWarning.Position = UDim2.fromScale(0.08, 0.61)
deleteWarning.Size = UDim2.fromScale(0.84, 0.11)
deleteWarning.Text = "No se puede recuperar."
deleteWarning.TextWrapped = true
deleteWarning.TextXAlignment = Enum.TextXAlignment.Left
deleteWarning.ZIndex = 102
configureText(deleteWarning, UITheme.GetFont("Mono"), C.Error, 12)

local deleteActions = deleteDialog:FindFirstChild("Actions") or Instance.new("Frame")
deleteActions.Name = "Actions"
deleteActions.Parent = deleteDialog
deleteActions.BackgroundTransparency = 1
deleteActions.Position = UDim2.fromScale(0.08, 0.78)
deleteActions.Size = UDim2.fromScale(0.84, 0.15)
deleteActions.ZIndex = 102

local confirmDeleteButton = deleteActions:FindFirstChild("Confirm") or Instance.new("TextButton")
confirmDeleteButton.Name = "Confirm"
confirmDeleteButton.Parent = deleteActions
confirmDeleteButton.Position = UDim2.fromScale(0, 0)
confirmDeleteButton.Size = UDim2.fromScale(0.48, 1)
confirmDeleteButton.ZIndex = 103
configureButton(confirmDeleteButton, "CONFIRMAR", "Primary")

local cancelDeleteButton = deleteActions:FindFirstChild("Cancel") or Instance.new("TextButton")
cancelDeleteButton.Name = "Cancel"
cancelDeleteButton.Parent = deleteActions
cancelDeleteButton.Position = UDim2.fromScale(0.52, 0)
cancelDeleteButton.Size = UDim2.fromScale(0.48, 1)
cancelDeleteButton.ZIndex = 103
configureButton(cancelDeleteButton, "CANCELAR", "Secondary")

local pendingDeleteItem = nil
local function resizeDeleteDialog()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize
	local touch = UserInputService.TouchEnabled
	local landscape = viewport and viewport.X >= viewport.Y
	if touch then
		deleteDialog.Size = UDim2.fromScale(landscape and 0.74 or 0.88, landscape and 0.62 or 0.40)
	else
		deleteDialog.Size = UDim2.fromScale(0.40, 0.36)
	end
end

local function showDeleteConfirmation(item)
	if type(item) ~= "table" or type(item.instanceId) ~= "string" then return end
	if findEquippedSlot(item.instanceId) then return end
	pendingDeleteItem = item
	deleteIcon.Image = item.iconId or ""
	deleteIcon.Visible = true
	deleteIconPlaceholder.Visible = deleteIcon.Image == ""
	local quantity = math.max(1, math.floor(tonumber(item.quantity) or 1))
	local suffix = quantity > 1 and ("  x" .. tostring(quantity)) or ""
	deleteItemLabel.Text = tostring(item.name or item.templateId or "Objeto") .. suffix
	resizeDeleteDialog()
	deleteShade.Visible = true
end

local function closeDeleteConfirmation()
	pendingDeleteItem = nil
	deleteShade.Visible = false
end

deleteConfirmationRequest.Event:Connect(showDeleteConfirmation)
confirmDeleteButton.Activated:Connect(function()
	local item = pendingDeleteItem
	if not item then return end
	closeDeleteConfirmation()
	RequestDeleteItem:FireServer({ instanceId = item.instanceId })
end)
cancelDeleteButton.Activated:Connect(closeDeleteConfirmation)
local deleteViewportConnection
local function bindDeleteViewport()
	if deleteViewportConnection then deleteViewportConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then
		deleteViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeDeleteDialog)
	end
	resizeDeleteDialog()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindDeleteViewport)
bindDeleteViewport()

local function styleBagWindow()
	inventoryMain.AnchorPoint = Vector2.new(0.5, 0.5)
	inventoryMain.Position = UDim2.fromScale(0.5, 0.5)
	inventoryMain.Size = UDim2.fromScale(0.64, 0.80)
	inventoryMain.BackgroundColor3 = C.Surface
	inventoryMain.BackgroundTransparency = 0
	inventoryMain.BorderSizePixel = 0
	ensureAspect(inventoryMain, 1.45)
	ensureCorner(inventoryMain, UDim.new(0, 8))
	ensureStroke(inventoryMain, C.Brass, 0.05, 1)
	local title = inventoryMain:FindFirstChild("Title")
	if title then title.Visible = false end
	local close = inventoryMain:FindFirstChild("CloseButton")
	if close then
		close.Text = "X"
	end
	local header = ensureLabel(inventoryMain, "EST21Title", "MOCHILA  ·  B")
	header.Position = UDim2.fromScale(0.035, 0.035)
	header.Size = UDim2.fromScale(0.5, 0.07)
	header.TextXAlignment = Enum.TextXAlignment.Left
	configureText(header, UITheme.GetFont("Title"), C.Parchment, 18)
	local capacity = ensureLabel(inventoryMain, "CapacityLabel", "20 / 20 CASILLAS")
	capacity.Position = UDim2.fromScale(0.54, 0.04)
	capacity.Size = UDim2.fromScale(0.19, 0.05)
	capacity.TextXAlignment = Enum.TextXAlignment.Right
	configureText(capacity, UITheme.GetFont("Mono"), C.Muted, 10)
	local goldLabel = ensureLabel(inventoryMain, "GoldLabel", "")
	goldLabel.Position = UDim2.fromScale(0.75, 0.04)
	goldLabel.Size = UDim2.fromScale(0.16, 0.05)
	goldLabel.TextXAlignment = Enum.TextXAlignment.Right
	configureText(goldLabel, UITheme.GetFont("Mono"), C.BrassBright, 12)
	updateGold(player:GetAttribute("Gold"))
	bagPanel.Position = UDim2.fromScale(0.03, 0.15)
	bagPanel.Size = UDim2.fromScale(0.53, 0.79)
	bagPanel.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	bagPanel.BorderSizePixel = 0
	ensureCorner(bagPanel, UDim.new(0, 5))
	ensureStroke(bagPanel, C.BrassDark, 0.35, 1)
	local bagTitle = bagPanel:FindFirstChild("BagTitle")
	if bagTitle then
		bagTitle.Position = UDim2.fromScale(0.05, 0.035)
		bagTitle.Size = UDim2.fromScale(0.9, 0.09)
		bagTitle.Text = "INVENTARIO · PILAS"
		bagTitle.TextXAlignment = Enum.TextXAlignment.Left
		configureText(bagTitle, UITheme.GetFont("Mono"), C.BrassBright, 11)
	end
	bagScroll.Position = UDim2.fromScale(0.05, 0.16)
	bagScroll.Size = UDim2.fromScale(0.90, 0.82)
	bagScroll.BackgroundColor3 = C.BarBackground
	bagScroll.BackgroundTransparency = 0.35
	bagScroll.BorderSizePixel = 0
	bagScroll.ScrollBarThickness = 4
	bagScroll.ScrollBarImageColor3 = C.Brass
	local gridPadding = bagScroll:FindFirstChild("EST21GridPadding") or Instance.new("UIPadding")
	gridPadding.Name = "EST21GridPadding"
	gridPadding.Parent = bagScroll
	gridPadding.PaddingLeft = UDim.new(0, 6)
	gridPadding.PaddingTop = UDim.new(0, 6)
	gridPadding.PaddingRight = UDim.new(0, 4)
	gridPadding.PaddingBottom = UDim.new(0, 4)
	bagScroll.CanvasSize = UDim2.fromScale(0, 1)
	bagScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	ensureCorner(bagScroll, UDim.new(0, 4))
	local grid = bagScroll:FindFirstChildWhichIsA("UIGridLayout")
	if grid then
		grid.CellSize = UDim2.fromScale(0.17, 0.18)
		grid.CellPadding = UDim2.fromScale(0.025, 0.015)
		grid.FillDirectionMaxCells = 5
		grid.SortOrder = Enum.SortOrder.LayoutOrder
	end
	for index = 1, 20 do
		local slot = bagScroll:FindFirstChild("BagSlot" .. tostring(index))
		if slot then styleBagSlot(slot) end
	end
	local infoPanel = inventoryMain:FindFirstChild("ItemInfoPanel")
	if not infoPanel then
		infoPanel = Instance.new("Frame")
		infoPanel.Name = "ItemInfoPanel"
		infoPanel.Parent = inventoryMain
	end
	infoPanel.Position = UDim2.fromScale(0.59, 0.15)
	infoPanel.Size = UDim2.fromScale(0.38, 0.79)
	infoPanel.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	infoPanel.BorderSizePixel = 0
	ensureCorner(infoPanel, UDim.new(0, 5))
	ensureStroke(infoPanel, C.BrassDark, 0.35, 1)
	local infoTitle = ensureLabel(infoPanel, "InfoTitle", "DETALLE DEL OBJETO")
	infoTitle.Position = UDim2.fromScale(0.08, 0.07)
	infoTitle.Size = UDim2.fromScale(0.84, 0.08)
	infoTitle.TextXAlignment = Enum.TextXAlignment.Left
	configureText(infoTitle, UITheme.GetFont("Mono"), C.BrassBright, 12)
	local infoIcon = infoPanel:FindFirstChild("InfoIcon") or Instance.new("ImageLabel")
	infoIcon.Name = "InfoIcon"
	infoIcon.Parent = infoPanel
	infoIcon.Position = UDim2.fromScale(0.84, 0.055)
	infoIcon.Size = UDim2.fromScale(0.09, 0.08)
	infoIcon.BackgroundTransparency = 1
	infoIcon.ScaleType = Enum.ScaleType.Fit
	infoIcon.Visible = false
	local function suppressIconStroke(child)
		if child:IsA("UIStroke") then child.Enabled = false end
	end
	for _, child in ipairs(infoIcon:GetChildren()) do suppressIconStroke(child) end
	infoIcon.ChildAdded:Connect(suppressIconStroke)
	local infoName = ensureLabel(infoPanel, "InfoName", "Selecciona un objeto")
	infoName.Position = UDim2.fromScale(0.08, 0.18)
	infoName.Size = UDim2.fromScale(0.84, 0.09)
	infoName.TextXAlignment = Enum.TextXAlignment.Left
	configureText(infoName, UITheme.GetFont("BodyBold"), C.Parchment, 16)
	infoName.TextTruncate = Enum.TextTruncate.AtEnd
	local infoRarity = ensureLabel(infoPanel, "InfoRarity", "")
	infoRarity.Position = UDim2.fromScale(0.08, 0.28)
	infoRarity.Size = UDim2.fromScale(0.84, 0.06)
	infoRarity.TextXAlignment = Enum.TextXAlignment.Left
	configureText(infoRarity, UITheme.GetFont("Mono"), C.BrassBright, 11)
	local divider = infoPanel:FindFirstChild("InfoDivider") or Instance.new("Frame")
	divider.Name = "InfoDivider"
	divider.Parent = infoPanel
	divider.Position = UDim2.fromScale(0.08, 0.36)
	divider.Size = UDim2.fromScale(0.84, 0.003)
	divider.BackgroundColor3 = C.BrassDark
	divider.BorderSizePixel = 0
	local bodyScroll = infoPanel:FindFirstChild("InfoBodyScroll") or Instance.new("ScrollingFrame")
	bodyScroll.Name = "InfoBodyScroll"
	bodyScroll.Parent = infoPanel
	bodyScroll.Position = UDim2.fromScale(0.08, 0.39)
	bodyScroll.Size = UDim2.fromScale(0.84, 0.33)
	bodyScroll.BackgroundTransparency = 1
	bodyScroll.BorderSizePixel = 0
	bodyScroll.ClipsDescendants = true
	bodyScroll.ScrollBarThickness = 4
	bodyScroll.ScrollBarImageColor3 = C.Brass
	bodyScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	bodyScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	bodyScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	bodyScroll.CanvasSize = UDim2.fromScale(0, 0)
	local infoBody = infoPanel:FindFirstChild("InfoBody", true) or ensureLabel(infoPanel, "InfoBody", "Selecciona un objeto para inspeccionar sus detalles.")
	infoBody.Parent = bodyScroll
	infoBody.Position = UDim2.fromScale(0, 0)
	infoBody.Size = UDim2.fromScale(0.97, 0)
	infoBody.AutomaticSize = Enum.AutomaticSize.None
	infoBody.TextXAlignment = Enum.TextXAlignment.Left
	infoBody.TextYAlignment = Enum.TextYAlignment.Top
	configureText(infoBody, UITheme.GetFont("Body"), C.Text, 15)
	infoBody.TextWrapped = true
	if not infoBody:GetAttribute("EST21BodySizeBound") then
		infoBody:SetAttribute("EST21BodySizeBound", true)
		local pending = false
		local function updateBodySize()
			if pending then return end
			pending = true
			task.defer(function()
				pending = false
				local width = math.max(1, bodyScroll.AbsoluteWindowSize.X * 0.97)
				local measured = TextService:GetTextSize(infoBody.Text, infoBody.TextSize, infoBody.Font, Vector2.new(width, 100000))
				local height = math.ceil(measured.Y) + 4
				-- Altura intrínseca medida: evita que el canvas limite el auto-size del texto.
				infoBody.Size = UDim2.new(0.97, 0, 0, height)
				if infoPanel.AbsoluteSize.Y > 0 then
					bodyScroll.CanvasSize = UDim2.fromScale(0, height / infoPanel.AbsoluteSize.Y)
				end
			end)
		end
		for _, property in ipairs({"Text", "TextSize", "Font"}) do
			infoBody:GetPropertyChangedSignal(property):Connect(updateBodySize)
		end
		bodyScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateBodySize)
		updateBodySize()
	end
	local infoHelp = ensureLabel(infoPanel, "InfoHelp", "Selecciona un objeto para ver sus acciones")
	infoHelp.Position = UDim2.fromScale(0.08, 0.74)
	infoHelp.Size = UDim2.fromScale(0.84, 0.09)
	infoHelp.TextWrapped = true
	infoHelp.TextYAlignment = Enum.TextYAlignment.Top
	infoHelp.TextXAlignment = Enum.TextXAlignment.Left
	configureText(infoHelp, UITheme.GetFont("Mono"), C.Muted, 11)
	infoHelp.TextWrapped = true
	local actions = infoPanel:FindFirstChild("InfoActions") or Instance.new("Frame")
	actions.Name = "InfoActions"
	actions.Parent = infoPanel
	actions.Position = UDim2.fromScale(0.08, 0.85)
	actions.Size = UDim2.fromScale(0.84, 0.1)
	actions.BackgroundTransparency = 1
	for index, spec in ipairs({ { "UseButton", "USAR", "Primary" }, { "EquipButton", "EQUIPAR", "Secondary" }, { "DeleteButton", "ELIMINAR", "Secondary" } }) do
		local button = actions:FindFirstChild(spec[1]) or Instance.new("TextButton")
		button.Name = spec[1]
		button.Parent = actions
		button.Position = UDim2.fromScale((index - 1) * 0.34, 0)
		button.Size = UDim2.fromScale(0.32, 1)
		configureButton(button, spec[2], spec[3])
	end
	actions.UseButton.Activated:Connect(function()
		local item = findItem(selectedItemId)
		if item and item.usable then RequestUseConsumable:FireServer({ instanceId = item.instanceId }) end
	end)
	actions.EquipButton.Activated:Connect(function()
		local item = findItem(selectedItemId)
		if item and not item.usable and item.slot and item.slot ~= "Unknown" then RequestEquipItem:FireServer({ instanceId = item.instanceId }) end
	end)
	actions.DeleteButton.Activated:Connect(function()
		local item = findItem(selectedItemId)
		if item and not findEquippedSlot(item.instanceId) then showDeleteConfirmation(item) end
	end)
end

local function renderItemInfo(item)
	local panel = inventoryMain:FindFirstChild("ItemInfoPanel")
	local body = panel and panel:FindFirstChild("InfoBody", true)
	local name = panel and panel:FindFirstChild("InfoName")
	local rarity = panel and panel:FindFirstChild("InfoRarity")
	local actions = panel and panel:FindFirstChild("InfoActions")
	local icon = panel and panel:FindFirstChild("InfoIcon")
	local divider = panel and panel:FindFirstChild("InfoDivider")
	local panelStroke = panel and panel:FindFirstChild("EST21Stroke")
	if not body or not name or not rarity or not actions then return end
	item = item or findItem(selectedItemId)
	local scroll = panel:FindFirstChild("InfoBodyScroll")
	if scroll then scroll.CanvasPosition = Vector2.zero end
	if not item then
		name.Text = "Selecciona un objeto"
		name.TextColor3 = C.Parchment
		rarity.Text = ""
		body.Text = "Selecciona un objeto para inspeccionar sus detalles."
		if icon then icon.Visible = false end
		if panelStroke then panelStroke.Color = C.BrassDark end
		if divider then divider.BackgroundColor3 = C.BrassDark end
		actions.Visible = false
		return
	end
	local rarityColor = RARITY_COLORS[item.rarity] or C.BrassBright
	name.Text = item.name or item.templateId or "Objeto"
	name.TextColor3 = rarityColor
	rarity.Text = getRarityLabel(item.rarity)
	rarity.TextColor3 = rarityColor
	if icon then
		icon.Image = item.iconId or ""
		icon.Visible = icon.Image ~= ""
		for _, child in ipairs(icon:GetChildren()) do
			if child:IsA("UIStroke") then child.Enabled = false end
		end
	end
	if panelStroke then panelStroke.Color = rarityColor end
	if divider then divider.BackgroundColor3 = rarityColor end
	local lines = {}
	for statName, value in pairs(item.stats or {}) do
		table.insert(lines, formatItemStat(statName, value))
	end
	for _, affix in ipairs(item.affixes or {}) do
		table.insert(lines, formatItemAffix(affix))
	end
	table.insert(lines, "Req. nivel " .. tostring(item.levelReq or 1))
	table.insert(lines, item.bindState == "Bound" and "VINCULADO" or "VINCULADO AL EQUIPAR")
	table.insert(lines, "Eliminar descarta el objeto o la pila completa.")
	if item.description and item.description ~= "" then
		table.insert(lines, "")
		table.insert(lines, tostring(item.description))
	end
	body.Text = table.concat(lines, "\n")
	actions.Visible = true
	actions.UseButton.Visible = item.usable == true
	actions.EquipButton.Visible = item.usable ~= true and item.slot ~= nil and item.slot ~= "Unknown"
	actions.DeleteButton.Visible = findEquippedSlot(item.instanceId) == nil
end

local RARITY_NAMES = { Common = "COMÚN", Uncommon = "POCO COMÚN", Rare = "RARA", Epic = "ÉPICA" }
function getRarityLabel(rarity)
	return RARITY_NAMES[rarity] or tostring(rarity or "SIN RAREZA")
end

local function bumpTooltipCloseVersion()
	local version = (tonumber(tooltip:GetAttribute("TooltipCloseVersion")) or 0) + 1
	tooltip:SetAttribute("TooltipCloseVersion", version)
	return version
end

local tooltipLayoutQueued = false
local function positionTooltipNearMouse()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local viewport = tooltip.Parent.AbsoluteSize
	if viewport.X <= 0 or viewport.Y <= 0 then return end
	local tipSize = tooltip.AbsoluteSize
	local mouse = UserInputService:GetMouseLocation() - tooltip.Parent.AbsolutePosition
	local px = math.clamp(mouse.X + 14, 4, math.max(4, viewport.X - tipSize.X - 4))
	local py = math.clamp(mouse.Y + 14, 4, math.max(4, viewport.Y - tipSize.Y - 4))
	tooltip.Position = UDim2.fromScale(px / viewport.X, py / viewport.Y)
end

local function layoutTooltipContent()
	if not tooltip.Parent then return end

	local width = 260
	local contentWidth = width - 20
	local y = 10
	local fields = {
		{ name = "ItemName", minimum = 20, wrapped = false },
		{ name = "Rarity", minimum = 15, wrapped = false },
		{ name = "Stats", minimum = 16, wrapped = true },
		{ name = "Affixes", minimum = 15, wrapped = true },
		{ name = "Bind", minimum = 15, wrapped = false },
		{ name = "LevelReq", minimum = 16, wrapped = false },
		{ name = "Description", minimum = 15, wrapped = true },
	}

	for _, spec in ipairs(fields) do
		local label = tooltip:FindFirstChild(spec.name)
		if label and label:IsA("TextLabel") then
			local visible = spec.name == "ItemName" or string.match(label.Text or "", "%S") ~= nil
			label.Visible = visible
			label.TextWrapped = spec.wrapped
			if visible then
				local height = spec.minimum
				if spec.wrapped then
					local bounds = TextService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(contentWidth, 1000))
					height = math.max(height, math.ceil(bounds.Y) + 2)
				end
				label.Position = UDim2.fromOffset(10, y)
				label.Size = UDim2.new(1, -20, 0, height)
				label.ZIndex = 31
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextYAlignment = Enum.TextYAlignment.Top
				y += height + 3
			end
		end
	end

	local actionBar = tooltip:FindFirstChild("ActionBar")
	if actionBar then
		local hasVisibleButton = false
		for _, child in ipairs(actionBar:GetChildren()) do
			if child:IsA("GuiButton") and child.Visible then
				hasVisibleButton = true
				break
			end
		end
		local owner = tooltip:GetAttribute("TooltipOwner")
		actionBar.Visible = hasVisibleButton and (owner == "Inventory" or owner == "Equipment")
		if actionBar.Visible then
			actionBar.Position = UDim2.fromOffset(10, y)
			actionBar.Size = UDim2.new(1, -20, 0, 28)
			actionBar.ZIndex = 31
			y += 32
		end
	end

	tooltip.Size = UDim2.fromOffset(width, math.max(84, y + 8))
	task.defer(positionTooltipNearMouse)
end

local function queueTooltipLayout()
	if tooltipLayoutQueued then return end
	tooltipLayoutQueued = true
	task.defer(function()
		tooltipLayoutQueued = false
		if tooltip.Parent then
			layoutTooltipContent()
		end
	end)
end

local function styleTooltipWindow()
	tooltip.BackgroundColor3 = C.Surface
	tooltip.BackgroundTransparency = 0
	tooltip.BorderSizePixel = 0
	tooltip.ZIndex = 30
	tooltip.Active = true
	tooltip.AutomaticSize = Enum.AutomaticSize.None
	ensureCorner(tooltip, UDim.new(0, 5))
	ensureStroke(tooltip, C.Brass, 0.05, 1)

	local layouts = {
		ItemName = { color = C.Parchment, textSize = 15, font = "BodyBold", wrapped = false },
		Rarity = { color = C.BrassBright, textSize = 11, font = "Mono", wrapped = false },
		Stats = { color = C.Text, textSize = 12, font = "Mono", wrapped = true },
		Affixes = { color = C.Muted, textSize = 11, font = "Mono", wrapped = true },
		Bind = { color = C.Muted, textSize = 11, font = "Mono", wrapped = false },
		LevelReq = { color = C.Muted, textSize = 12, font = "Mono", wrapped = false },
		Description = { color = C.Muted, textSize = 11, font = "Body", wrapped = true },
	}
	for name, spec in pairs(layouts) do
		local label = tooltip:FindFirstChild(name)
		if label and label:IsA("TextLabel") then
			label.Size = UDim2.new(1, -20, 0, 14)
			label.ZIndex = 31
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Top
			configureText(label, UITheme.GetFont(spec.font), spec.color, spec.textSize)
			label.TextWrapped = spec.wrapped
		end
	end

	local actionBar = tooltip:FindFirstChild("ActionBar")
	if actionBar then
		actionBar.BackgroundTransparency = 1
		actionBar.ZIndex = 31
	end
	layoutTooltipContent()
end

local function renderTooltipActions()
	local owner = tooltip:GetAttribute("TooltipOwner")
	local hasInventoryOwner = owner == "Inventory" or owner == "Equipment"
	local instanceId = tooltip:GetAttribute("ItemInstanceId")
	local item = hasInventoryOwner and findItem(instanceId) or nil
	if owner == "Inventory" and inventoryGui.Enabled and item then
		selectedItemId = item.instanceId
		for index = 1, 20 do
			local slot = bagScroll:FindFirstChild("BagSlot" .. tostring(index))
			if slot then
				local bagItem = currentInventory and currentInventory.bag and currentInventory.bag[index]
				local selected = bagItem ~= nil and bagItem.instanceId == selectedItemId
				slot:SetAttribute("HearthboundCellSelected", selected)
				setCellStrokeHover(slot, slot:GetAttribute("HearthboundCellHovered") == true)
			end
		end
	end

	-- User correction: remove tooltip buttons; do not relocate them.
    local actionBar = tooltip:FindFirstChild("ActionBar")
    if actionBar then actionBar:Destroy() end

	if hasInventoryOwner then
		renderItemInfo(item)
	end
	layoutTooltipContent()
end

local function bindTooltipActions()
	tooltip.Active = true
	tooltip.MouseEnter:Connect(function()
		bumpTooltipCloseVersion()
		tooltip:SetAttribute("TooltipHovering", true)
	end)
	tooltip.MouseLeave:Connect(function()
		tooltip:SetAttribute("TooltipHovering", false)
		local version = bumpTooltipCloseVersion()
		task.delay(0.28, function()
			if tooltip:GetAttribute("TooltipCloseVersion") ~= version
				or tooltip:GetAttribute("TooltipHovering") == true
				or not tooltip.Visible then
				return
			end
			tooltip:SetAttribute("TooltipOwner", "")
			tooltip:SetAttribute("ItemInstanceId", "")
			tooltip.Visible = false
		end)
	end)
	tooltip:GetAttributeChangedSignal("ItemInstanceId"):Connect(renderTooltipActions)
	tooltip:GetAttributeChangedSignal("TooltipOwner"):Connect(renderTooltipActions)
	tooltip:GetPropertyChangedSignal("Visible"):Connect(renderTooltipActions)
	for _, name in ipairs({ "ItemName", "Rarity", "Stats", "Affixes", "Bind", "LevelReq", "Description" }) do
		local label = tooltip:FindFirstChild(name)
		if label and label:IsA("TextLabel") then
			label:GetPropertyChangedSignal("Text"):Connect(queueTooltipLayout)
		end
	end
end

local function handleInventoryData(data)
	currentInventory = data
	statBreakdown = data and data.statsBreakdown or nil
	TooltipSystem.Refresh()
	renderUseMarkers()
	local capacity = inventoryMain:FindFirstChild("CapacityLabel")
	if capacity then
		capacity.Text = string.format("%d / 20 CASILLAS", #(data and data.bag or {}))
	end
	local hoveredItem = nil
	for _, bagItem in ipairs(data and data.bag or {}) do
		if bagItem and bagItem.instanceId == selectedItemId then
			hoveredItem = bagItem
			break
		end
	end
	if not hoveredItem then selectedItemId = nil end
	renderItemInfo(hoveredItem)
	task.defer(function()
		for index, slotName in ipairs(EQUIPMENT_SLOTS) do
			local slot = equipmentPanel:FindFirstChild(slotName)
			if slot then styleEquipmentSlot(slot, index) end
		end
	end)
	renderStats()
	updateHeader()
end

InventoryData.OnClientEvent:Connect(handleInventoryData)
VendorResult.OnClientEvent:Connect(function(data)
	if data and data.gold ~= nil then updateGold(data.gold) end
end)
player:GetAttributeChangedSignal("Gold"):Connect(function()
	updateGold(player:GetAttribute("Gold"))
end)
ItemUseSlotState.OnClientEvent:Connect(function(data)
	useSlotState = data or { slots = {}, quantities = {} }
	renderUseMarkers()
end)

for _, attributeName in ipairs({ "CharacterName", "CharacterClass", "CharacterSpec", "ClassId", "SpecId", "CharacterLevel", "CharacterXP", "CharacterXPReq" }) do
	player:GetAttributeChangedSignal(attributeName):Connect(function()
		updateHeader()
		renderStats()
	end)
end

SpellbookData.OnClientEvent:Connect(function(data)
	activeSpellbookData = data
	updateHeader()
end)
RequestSpellbook:FireServer()

bindCharacterDisplaySignals(player.Character)
player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid", 5)
	task.defer(function() bindCharacterDisplaySignals(character) end)
	task.delay(0.5, function() RequestSpellbook:FireServer() end)
end)

local function applyResponsive()
	local touch = UserInputService.TouchEnabled
	if touch then
		inventoryMain.Size = UDim2.fromScale(0.90, 0.86)
	else
		inventoryMain.Size = UDim2.fromScale(0.46, 0.70)
	end
	ensureAspect(inventoryMain, touch and 1.90 or 1.45)
	local equipmentCamera = workspace.CurrentCamera
	local viewport = equipmentCamera and equipmentCamera.ViewportSize or Vector2.new(1280, 720)
	local panelRatio = CharacterPanelUIConfig.DesignWidth / CharacterPanelUIConfig.DesignHeight
	local maxWidthFraction = touch and 0.85 or 0.44
	local maxHeightFraction = touch and 0.85 or 0.82
	local targetWidth = math.min(viewport.X * maxWidthFraction, viewport.Y * maxHeightFraction * panelRatio)
	local targetHeight = targetWidth / panelRatio
	equipmentMain.Size = UDim2.fromScale(targetWidth / viewport.X, targetHeight / viewport.Y)
	ensureAspect(equipmentMain, panelRatio)
	bagPanel.Position = UDim2.fromScale(0.03, 0.15)
	bagPanel.Size = UDim2.fromScale(touch and 0.49 or 0.54, 0.79)
	local info = inventoryMain:FindFirstChild("ItemInfoPanel")
	if info then
		info.Position = UDim2.fromScale(touch and 0.54 or 0.59, 0.15)
		info.Size = UDim2.fromScale(touch and 0.43 or 0.38, 0.79)
		local body = info:FindFirstChild("InfoBody", true)
		if body then body.TextSize = touch and 13 or 15 end
		local help = info:FindFirstChild("InfoHelp")
		if help then
			help.Text = touch and "Toca un objeto para ver sus acciones." or "Selecciona un objeto para ver sus acciones"
		end
		local actions = info:FindFirstChild("InfoActions")
		if actions and info.AbsoluteSize.Y > 0 then
			local actionHeight = touch and 44 / info.AbsoluteSize.Y or 0.1
			actions.Position = UDim2.fromScale(0.08, 0.97 - actionHeight)
			actions.Size = UDim2.fromScale(0.84, actionHeight)
			if help then help.Position = UDim2.fromScale(0.08, 0.95 - actionHeight - 0.11); help.Size = UDim2.fromScale(0.84, 0.11) end
			local scroll = info:FindFirstChild("InfoBodyScroll")
			if scroll then scroll.Size = UDim2.fromScale(0.84, math.max(0.1, 0.95 - actionHeight - 0.13 - 0.39)) end
		end
	end
	local grid = bagScroll:FindFirstChildWhichIsA("UIGridLayout")
	if grid then
		grid.FillDirectionMaxCells = touch and 4 or 5
		grid.CellSize = UDim2.fromScale(touch and 0.23 or 0.17, touch and 0.25 or 0.18)
		grid.CellPadding = UDim2.fromScale(0.025, 0.015)
		bagScroll.AutomaticCanvasSize = touch and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
		bagScroll.CanvasSize = UDim2.fromScale(0, touch and 0 or 1)
	end
	-- Contain by aspect/available area instead of shrinking every compact screen.
	local header = inventoryMain:FindFirstChild("EST21Title")
	local capacity = inventoryMain:FindFirstChild("CapacityLabel")
	local gold = inventoryMain:FindFirstChild("GoldLabel")
	if header then header.Size = UDim2.fromScale(touch and 0.45 or 0.5, 0.07) end
	if capacity then
		capacity.Position = UDim2.fromScale(touch and 0.50 or 0.54, 0.04)
		capacity.Size = UDim2.fromScale(touch and 0.18 or 0.19, 0.05)
	end
	if gold then
		gold.Position = UDim2.fromScale(touch and 0.72 or 0.75, 0.04)
		gold.Size = UDim2.fromScale(touch and 0.14 or 0.16, 0.05)
	end
	local factor = 1
	-- rc085: character panel keeps the Pencil 480:455 ratio while fitting both axes.
	task.defer(function()
		if equipmentMain.Parent and equipmentMain.AbsoluteSize.X > 0 then
			local scaleFactor = math.min(equipmentMain.AbsoluteSize.X / CharacterPanelUIConfig.DesignWidth,
				equipmentMain.AbsoluteSize.Y / CharacterPanelUIConfig.DesignHeight)
			local function scaled(base, minimum) return math.max(minimum, math.floor(base * scaleFactor + 0.5)) end
			local title = equipmentMain:FindFirstChild("Title")
			if title then title.TextSize = scaled(15, 12) end
			local identity = equipmentMain:FindFirstChild("EST21Header") and equipmentMain.EST21Header:FindFirstChild("Identity")
			if identity then identity.TextSize = scaled(9, 9) end
			if statsPanel:FindFirstChild("StatsTitle") then statsPanel.StatsTitle.TextSize = scaled(12, 9) end
			for _, headerName in ipairs({"EST45ResourcesHeader", "EST45AttackHeader", "EST45DefenseHeader"}) do
				local header = statsPanel:FindFirstChild(headerName)
				if header then header.TextSize = scaled(9.5, 9) end
			end
			for key, row in pairs(statLabels) do
				local spec = CharacterPanelUIConfig.StatRows[key]
				if row and spec then
					local name = row:FindFirstChild("EST21Name")
					local value = row:FindFirstChild("EST21Value")
					if name then name.TextSize = scaled(11, 11) end
					if value then value.TextSize = scaled(12, 12) end
				end
			end
			for _, slotSpec in pairs(CharacterPanelUIConfig.Slots) do
				local slot = equipmentPanel:FindFirstChild(slotSpec.name)
				local label = slot and slot:FindFirstChild("SlotLabel")
				if label then
					local blocked = slot:GetAttribute("blockedByTwoHand") == true
					label.Text = UserInputService.TouchEnabled
						and (blocked and (slotSpec.blockedTextMobile or slotSpec.mobileText) or slotSpec.mobileText)
						or (blocked and slotSpec.blockedText or slotSpec.emptyText)
					label.TextSize = scaled(6.5, UserInputService.TouchEnabled and 9 or 7)
				end
			end
		end
	end)
	-- rc075: EST21 is the sole responsive scale owner for bag/equipment.
	for _, frame in ipairs({inventoryMain, equipmentMain}) do
		local legacy = frame:FindFirstChild("HearthboundResponsiveScale")
		if legacy then legacy:Destroy() end
	end
	ensureScale(inventoryMain).Scale = factor
	ensureScale(equipmentMain).Scale = factor
	ensureScale(tooltip).Scale = factor
	renderStats()
end

local function styleAll()
	styleBagWindow()
	styleEquipmentWindow()
	styleTooltipWindow()
	bindTooltipActions()
	applyResponsive()
	renderUseMarkers()
end

styleAll()

for _, child in ipairs(bagScroll:GetChildren()) do
	if child:IsA("GuiObject") and string.match(child.Name, "^BagSlot%d+$") then
		styleBagSlot(child)
	end
end
bagScroll.ChildAdded:Connect(function(child)
	if child:IsA("GuiObject") and string.match(child.Name, "^BagSlot%d+$") then
		task.defer(function()
			if child.Parent then
				styleBagSlot(child)
				renderUseMarkers()
			end
		end)
	end
end)

local viewportConnection
local function bindViewport()
	if viewportConnection then viewportConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive) end
	applyResponsive()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
inventoryMain:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(applyResponsive) end)
equipmentMain:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(applyResponsive) end)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(applyResponsive)
bindViewport()

print("[Vandrheim] InventoryPresentationClient rc042 activo")

