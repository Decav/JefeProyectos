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
local BackpackUIConfig = require(ReplicatedStorage.Config:WaitForChild("BackpackUIConfig"))
local TooltipData = require(ReplicatedStorage.Shared:WaitForChild("TooltipData"))
local TooltipSystem = require(ReplicatedStorage.Shared:WaitForChild("TooltipSystem"))
local ClassConfig = require(ReplicatedStorage.Config:WaitForChild("ClassConfig"))
local C = UITheme.Colors
local BLACK_CELL = C.Shadow

local InventoryData = Remotes:WaitForChild("InventoryData")
local VendorResult = Remotes:WaitForChild("VendorResult")
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
local function formatGold(value)
	local digits = tostring(math.max(0, math.floor(tonumber(value) or 0)))
	return digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function updateBackpackTitle()
	local title = inventoryMain:FindFirstChild("Title")
	if not title then return end
	local name = player:GetAttribute("CharacterName")
	if type(name) ~= "string" or name == "" then name = player.Name end
	title.Text = BackpackUIConfig.Text.TitlePrefix .. string.upper(name)
end

local function updateGold(value)
	currentGold = tonumber(value) or 0
	local label = inventoryMain:FindFirstChild("BackpackFooter")
	if not label then return end
	local occupied = 0
	local bag = currentInventory and currentInventory.bag
	if type(bag) == "table" then
		for index = 1, 20 do
			if bag[index] ~= nil then occupied += 1 end
		end
	end
	label.Text = string.format(BackpackUIConfig.Text.Footer, occupied, formatGold(currentGold))
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

local function getBackpackTextSize(base, minimum)
	if inventoryMain.AbsoluteSize.X <= 0 or inventoryMain.AbsoluteSize.Y <= 0 then return math.max(base, minimum) end
	local scaleFactor = math.min(inventoryMain.AbsoluteSize.X / BackpackUIConfig.DesignWidth, inventoryMain.AbsoluteSize.Y / BackpackUIConfig.DesignHeight)
	return math.max(minimum, math.floor(base * scaleFactor + 0.5))
end

local function styleBagSlot(slot)
	local index = tonumber(string.match(slot.Name, "%d+")) or 0
	local item = currentInventory and currentInventory.bag and currentInventory.bag[index]
	local rarityColor = item and (BackpackUIConfig.RarityColors[item.rarity] or C.BrassBright)
		or BackpackUIConfig.Colors.EmptyStroke
	local hasItem = item ~= nil
	local quantityValue = hasItem and math.max(1, math.floor(tonumber(item.quantity) or 1)) or 1

	slot.Visible = true
	slot:SetAttribute("HearthboundBlackCell", true)
	slot:SetAttribute("HearthboundCellBaseStrokeColor", rarityColor)
	slot:SetAttribute("HearthboundCellBaseStrokeThickness", 1)
	slot:SetAttribute("HearthboundCellBaseStrokeTransparency", 0)
	slot:SetAttribute("HearthboundCellSelected", hasItem and item.instanceId == selectedItemId)
	slot.BackgroundColor3 = BackpackUIConfig.Colors.Slot
	slot.BackgroundTransparency = 0
	slot.BorderSizePixel = 0
	slot.LayoutOrder = index
	slot.Active = true
	slot.ClipsDescendants = true
	for _, child in ipairs(slot:GetChildren()) do
		if child:IsA("UIAspectRatioConstraint") then child:Destroy() end
	end
	ensureCorner(slot, UDim.new(0, 5))
	local selected = slot:GetAttribute("HearthboundCellSelected") == true
	local stroke = ensureStroke(slot, selected and C.BrassBright or rarityColor, 0, selected and 2 or 1)
	for _, child in ipairs(slot:GetChildren()) do
		if child:IsA("UIStroke") and child ~= stroke then child.Enabled = false end
		if child:IsA("UICorner") and child.Name ~= "EST21Corner" then child:Destroy() end
	end
	local rarityBar = slot:FindFirstChild("RarityBar")
	if rarityBar then rarityBar.Visible = false end

	local icon = slot:FindFirstChild("ItemIcon")
	if icon then
		icon.AnchorPoint = Vector2.zero
		icon.Position = UDim2.fromOffset(4, 4)
		icon.Size = UDim2.new(1, -8, 1, -8)
		icon.ScaleType = Enum.ScaleType.Crop
		icon.BackgroundTransparency = 1
		icon.Visible = hasItem
		icon.ZIndex = slot.ZIndex + 1
		for _, child in ipairs(icon:GetChildren()) do
			if child:IsA("UIStroke") or child:IsA("UIAspectRatioConstraint") then child:Destroy() end
		end
	end
	local itemName = slot:FindFirstChild("ItemName")
	if itemName then itemName:Destroy() end

	local emptyLabel = ensureLabel(slot, "EmptyLabel", BackpackUIConfig.Text.EmptyLabel)
	emptyLabel.Position = UDim2.fromScale(BackpackUIConfig.Slot.EmptyX, BackpackUIConfig.Slot.EmptyY)
	emptyLabel.Size = UDim2.fromScale(BackpackUIConfig.Slot.EmptyWidth, BackpackUIConfig.Slot.EmptyHeight)
	emptyLabel.Visible = not hasItem
	emptyLabel.ZIndex = slot.ZIndex + 2
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
	emptyLabel.TextYAlignment = Enum.TextYAlignment.Center
	configureText(emptyLabel, BackpackUIConfig.Fonts.Bold, BackpackUIConfig.Colors.EmptyText,
		getBackpackTextSize(BackpackUIConfig.TextSizes.Empty, BackpackUIConfig.TextSizes.MinimumSlotText))

	local placeholder = ensureLabel(slot, "ItemPlaceholder", BackpackUIConfig.Text.PlaceholderGlyph)
	local hasImage = icon ~= nil and hasItem and type(item.iconId) == "string" and item.iconId ~= ""
	placeholder.Position = UDim2.fromScale(BackpackUIConfig.Slot.PlaceholderX, BackpackUIConfig.Slot.PlaceholderY)
	placeholder.Size = UDim2.fromScale(BackpackUIConfig.Slot.PlaceholderWidth, BackpackUIConfig.Slot.PlaceholderHeight)
	placeholder.Visible = hasItem and not hasImage
	placeholder.ZIndex = slot.ZIndex + 2
	placeholder.TextXAlignment = Enum.TextXAlignment.Center
	placeholder.TextYAlignment = Enum.TextYAlignment.Center
	configureText(placeholder, BackpackUIConfig.Fonts.Bold, BackpackUIConfig.Colors.Placeholder,
		getBackpackTextSize(18, BackpackUIConfig.TextSizes.MinimumSlotText))

	local backing = slot:FindFirstChild("QuantityBacking") or Instance.new("Frame")
	backing.Name = "QuantityBacking"
	backing.Parent = slot
	backing.Position = UDim2.fromScale(BackpackUIConfig.Slot.QuantityX / BackpackUIConfig.Grid.CellWidth, BackpackUIConfig.Slot.QuantityY / BackpackUIConfig.Grid.CellHeight)
	backing.Size = UDim2.fromScale(BackpackUIConfig.Slot.QuantityWidth / BackpackUIConfig.Grid.CellWidth, BackpackUIConfig.Slot.QuantityHeight / BackpackUIConfig.Grid.CellHeight)
	backing.BackgroundColor3 = BackpackUIConfig.Colors.QuantityBacking
	backing.BackgroundTransparency = BackpackUIConfig.Slot.QuantityBackingTransparency
	backing.BorderSizePixel = 0
	backing.ZIndex = slot.ZIndex + 4
	backing.Active = false
	ensureCorner(backing, UDim.new(0.2, 0))
	local quantity = slot:FindFirstChild("Quantity")
	if quantity then
		quantity.Position = backing.Position
		quantity.Size = backing.Size
		quantity.BackgroundTransparency = 1
		quantity.Text = hasItem and quantityValue > 1 and tostring(quantityValue) or ""
		quantity.TextColor3 = Color3.fromRGB(255, 255, 255)
		quantity.TextTransparency = 0
		quantity.Font = BackpackUIConfig.Fonts.Bold
		quantity.TextScaled = false
		local desktopQuantityBonus = UserInputService.TouchEnabled and 0 or 3
		quantity.TextSize = getBackpackTextSize(BackpackUIConfig.TextSizes.Quantity, BackpackUIConfig.TextSizes.MinimumSlotText) + desktopQuantityBonus
		quantity.TextXAlignment = Enum.TextXAlignment.Center
		quantity.TextYAlignment = Enum.TextYAlignment.Center
		quantity.ZIndex = backing.ZIndex + 1
		quantity.Visible = hasItem and quantityValue > 1
		quantity.Active = false
	end
	backing.Visible = hasItem and quantityValue > 1

	local marker = slot:FindFirstChild("UseMarker")
	if marker then marker:Destroy() end
	bindCellStrokeInput(slot)
	if not bagBound[slot] then
		bagBound[slot] = true
		slot.MouseEnter:Connect(function()
			local hovered = findItem(slot:GetAttribute("ItemInstanceId"))
			if hovered then
				local key = getItemStatKeys(hovered)[1]
				if key then renderBreakdown(key) end
			end
		end)
	end
end

local function renderUseMarkers()
	for index = 1, 20 do
		local slot = bagScroll:FindFirstChild("BagSlot" .. tostring(index))
		if slot then styleBagSlot(slot) end
		local marker = slot and slot:FindFirstChild("UseMarker")
		if marker then marker:Destroy() end
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
	local config = BackpackUIConfig
	local ratio = config.DesignWidth / config.DesignHeight
	inventoryMain.AnchorPoint = Vector2.new(0.5, 0.5)
	inventoryMain.Position = UDim2.fromScale(0.5, 0.5)
	inventoryMain.BackgroundColor3 = config.Colors.Frame
	inventoryMain.BackgroundTransparency = 0
	inventoryMain.BorderSizePixel = 0
	ensureAspect(inventoryMain, ratio)
	ensureCorner(inventoryMain, UDim.new(config.Layout.FrameCornerRadius / config.DesignWidth, 0))
	ensureStroke(inventoryMain, config.Colors.FrameStroke, 0, 1)
	for _, child in ipairs(inventoryMain:GetChildren()) do
		if child:IsA("UICorner") and child.Name ~= "EST21Corner" then child:Destroy() end
		if child:IsA("UIStroke") and child.Name ~= "EST21Stroke" then child.Enabled = false end
	end
	local title = inventoryMain:FindFirstChild("Title")
	if title then
		title.Visible = true
		title.Position = UDim2.fromScale(config.Layout.TitleX / config.DesignWidth, config.Layout.TitleY / config.DesignHeight)
		title.Size = UDim2.fromScale(config.Layout.TitleWidth / config.DesignWidth, config.Layout.TitleHeight / config.DesignHeight)
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.TextYAlignment = Enum.TextYAlignment.Center
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.TextWrapped = false
		title.ZIndex = inventoryMain.ZIndex + 4
		configureText(title, config.Fonts.Bold, config.Colors.Parchment, config.TextSizes.Title)
	end
	updateBackpackTitle()
	local close = inventoryMain:FindFirstChild("CloseButton")
	if close then
		close.Text = ""
		close.BackgroundTransparency = 1
		close.BorderSizePixel = 0
		close.AutoButtonColor = false
		for _, child in ipairs(close:GetChildren()) do
			if child:IsA("UIStroke") then child.Enabled = false end
		end
	end
	local oldTitle = inventoryMain:FindFirstChild("EST21Title")
	if oldTitle then oldTitle:Destroy() end
	for _, name in ipairs({"CapacityLabel", "GoldLabel", "ItemInfoPanel"}) do
		local old = inventoryMain:FindFirstChild(name)
		if old then old:Destroy() end
	end
	bagPanel.Position = UDim2.fromScale(0, 0)
	bagPanel.Size = UDim2.fromScale(1, 1)
	bagPanel.BackgroundTransparency = 1
	bagPanel.BorderSizePixel = 0
	local panelCorner = bagPanel:FindFirstChild("EST21Corner") or bagPanel:FindFirstChildOfClass("UICorner")
	if panelCorner then panelCorner:Destroy() end
	local panelStroke = bagPanel:FindFirstChild("EST21Stroke") or bagPanel:FindFirstChildOfClass("UIStroke")
	if panelStroke then panelStroke.Enabled = false end
	local bagTitle = bagPanel:FindFirstChild("BagTitle")
	if bagTitle then bagTitle.Visible = false end
	bagScroll.Position = UDim2.fromScale(config.Layout.GridX / config.DesignWidth, config.Grid.Top / config.DesignHeight)
	bagScroll.Size = UDim2.fromScale(config.Grid.AreaWidth / config.DesignWidth, config.Grid.AreaHeight / config.DesignHeight)
	bagScroll.BackgroundTransparency = 1
	bagScroll.BorderSizePixel = 0
	bagScroll.Active = true
	bagScroll.ClipsDescendants = true
	bagScroll.ZIndex = inventoryMain.ZIndex + 1
	bagScroll.ScrollingEnabled = true
	bagScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	bagScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	bagScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	bagScroll.ScrollBarImageColor3 = config.Colors.Gold
	bagScroll.ScrollBarImageTransparency = 0
	bagScroll.ScrollBarThickness = 6
	bagScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	bagScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

	local grid = bagScroll:FindFirstChild("EST43Grid") or bagScroll:FindFirstChildWhichIsA("UIGridLayout")
	if not grid then
		grid = Instance.new("UIGridLayout")
		grid.Name = "EST43Grid"
		grid.Parent = bagScroll
	end
	grid.Name = "EST43Grid"
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.VerticalAlignment = Enum.VerticalAlignment.Top
	local listPadding = bagScroll:FindFirstChild("EST43ListMargin") or Instance.new("UIPadding")
	listPadding.Name = "EST43ListMargin"
	listPadding.Parent = bagScroll

	local verticalGap = 8
	local listMargin = 12
	local function updateBagCanvas()
		if not bagScroll.Parent or not grid.Parent then return end
		local contentHeight = grid.AbsoluteContentSize.Y + listMargin
		bagScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(bagScroll.AbsoluteSize.Y, contentHeight))
	end
	local function resizeBagGrid()
		if not bagScroll.Parent or bagScroll.AbsoluteSize.X <= 0 then return end
		local scaleFactor = inventoryMain.AbsoluteSize.X > 0 and inventoryMain.AbsoluteSize.X / config.DesignWidth or 1
		listMargin = math.max(8, math.floor(config.Grid.ListMargin * scaleFactor + 0.5))
		local horizontalGap = math.max(5, math.floor(config.Grid.HorizontalGap * scaleFactor + 0.5))
		verticalGap = math.max(5, math.floor(config.Grid.VerticalGap * scaleFactor + 0.5))
		listPadding.PaddingLeft = UDim.new(0, listMargin)
		listPadding.PaddingRight = UDim.new(0, listMargin)
		listPadding.PaddingTop = UDim.new(0, listMargin)
		listPadding.PaddingBottom = UDim.new(0, listMargin)
		local innerWidth = math.max(1, bagScroll.AbsoluteSize.X - listMargin * 2)
		local minCell = math.max(48, math.floor(config.Grid.MinColumnWidth * scaleFactor + 0.5))
		local columns = math.max(1, math.min(config.Grid.MaxColumns, math.floor((innerWidth + horizontalGap) / (minCell + horizontalGap))))
		local availableCell = math.floor((innerWidth - horizontalGap * (columns - 1)) / columns)
		local maxCell = math.max(48, math.floor(config.Grid.MaxCellSize * scaleFactor + 0.5))
		local cellSize = math.max(44, math.min(availableCell, maxCell))
		grid.FillDirectionMaxCells = columns
		grid.CellSize = UDim2.fromOffset(cellSize, cellSize)
		grid.CellPadding = UDim2.fromOffset(horizontalGap, verticalGap)
		bagScroll.ScrollBarThickness = math.max(4, math.floor(6 * scaleFactor + 0.5))
		updateBagCanvas()
	end
	resizeBagGrid()
	if bagScroll:GetAttribute("EST43ScrollSignalsBound") ~= true then
		bagScroll:SetAttribute("EST43ScrollSignalsBound", true)
		bagScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeBagGrid)
		grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateBagCanvas)
	end
	local oldEmptyState = inventoryMain:FindFirstChild("BackpackEmptyState")
	if oldEmptyState then oldEmptyState:Destroy() end

	local footer = ensureLabel(inventoryMain, "BackpackFooter", "")
	footer.Position = UDim2.fromScale(config.Layout.FooterX / config.DesignWidth, config.Layout.FooterY / config.DesignHeight)
	footer.Size = UDim2.fromScale(config.Layout.FooterWidth / config.DesignWidth, config.Layout.FooterHeight / config.DesignHeight)
	footer.BackgroundColor3 = config.Colors.Footer
	footer.BackgroundTransparency = 0
	footer.BorderSizePixel = 0
	footer.TextColor3 = config.Colors.Gold
	footer.Font = config.Fonts.Bold
	footer.TextScaled = false
	footer.TextSize = config.TextSizes.Footer
	footer.TextXAlignment = Enum.TextXAlignment.Center
	footer.TextYAlignment = Enum.TextYAlignment.Center
	footer.TextTruncate = Enum.TextTruncate.AtEnd
	footer.ZIndex = inventoryMain.ZIndex + 5
	ensureCorner(footer, UDim.new(config.Layout.FooterCornerRadius / config.Layout.FooterHeight, 0))
	local footerStroke = ensureStroke(footer, config.Colors.FrameStroke, 0, 1)
	for _, child in ipairs(footer:GetChildren()) do
		if child:IsA("UIStroke") and child ~= footerStroke then child.Enabled = false end
		if child:IsA("UICorner") and child.Name ~= "EST21Corner" then child:Destroy() end
	end
	updateGold(player:GetAttribute("Gold"))
end

local function renderItemInfo(_item)
	local panel = inventoryMain:FindFirstChild("ItemInfoPanel")
	if panel then panel:Destroy() end
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
	updateGold(currentGold)	
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

player:GetAttributeChangedSignal("CharacterName"):Connect(updateBackpackTitle)
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
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local config = BackpackUIConfig
	local ratio = config.DesignWidth / config.DesignHeight
	local maxWidth = touch and config.Viewport.MobileMaxWidth or config.Viewport.DesktopMaxWidth
	local maxHeight = touch and config.Viewport.MobileMaxHeight or config.Viewport.DesktopMaxHeight
	local targetWidth = math.min(viewport.X * maxWidth, viewport.Y * maxHeight * ratio)
	local targetHeight = targetWidth / ratio
	inventoryMain.AnchorPoint = Vector2.new(0.5, 0.5)
	inventoryMain.Size = UDim2.fromScale(targetWidth / viewport.X, targetHeight / viewport.Y)
	ensureAspect(inventoryMain, ratio)
	local backpackTitle = inventoryMain:FindFirstChild("Title")
	local footer = inventoryMain:FindFirstChild("BackpackFooter")
	local function updateBackpackTextSizes()
		if not inventoryMain.Parent or inventoryMain.AbsoluteSize.X <= 0 or inventoryMain.AbsoluteSize.Y <= 0 then return end
		local scaleFactor = math.min(inventoryMain.AbsoluteSize.X / config.DesignWidth, inventoryMain.AbsoluteSize.Y / config.DesignHeight)
		local function scaled(base, minimum)
			return math.max(minimum, math.floor(base * scaleFactor + 0.5))
		end
		if backpackTitle then backpackTitle.TextSize = scaled(config.TextSizes.Title, config.TextSizes.MinimumTitle) end
		if footer then footer.TextSize = scaled(config.TextSizes.Footer, config.TextSizes.MinimumFooter) end
		for _, slot in ipairs(bagScroll:GetChildren()) do
			if slot:IsA("GuiObject") and string.match(slot.Name, "^BagSlot%d+$") then
				local quantity = slot:FindFirstChild("Quantity")
				local empty = slot:FindFirstChild("EmptyLabel")
				local placeholder = slot:FindFirstChild("ItemPlaceholder")
				if quantity then
					local desktopQuantityBonus = touch and 0 or 3
					quantity.TextSize = scaled(config.TextSizes.Quantity, config.TextSizes.MinimumSlotText) + desktopQuantityBonus
				end
				if empty then empty.TextSize = scaled(config.TextSizes.Empty, config.TextSizes.MinimumSlotText) end
				if placeholder then placeholder.TextSize = scaled(18, config.TextSizes.MinimumSlotText) end
			end
		end
	end
	task.defer(updateBackpackTextSizes)

	local panelRatio = CharacterPanelUIConfig.DesignWidth / CharacterPanelUIConfig.DesignHeight
	local maxWidthFraction = touch and 0.85 or 0.44
	local maxHeightFraction = touch and 0.85 or 0.82
	local equipmentWidth = math.min(viewport.X * maxWidthFraction, viewport.Y * maxHeightFraction * panelRatio)
	local equipmentHeight = equipmentWidth / panelRatio
	equipmentMain.Size = UDim2.fromScale(equipmentWidth / viewport.X, equipmentHeight / viewport.Y)
	ensureAspect(equipmentMain, panelRatio)
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

