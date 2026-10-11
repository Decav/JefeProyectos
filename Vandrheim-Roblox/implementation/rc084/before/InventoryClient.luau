--[[
	InventoryClient - Vandrheim Fase R4
	Cliente del inventario: toggle (B / botón mobile), render bolsa + equipo,
	tooltips, equip/unequip (click izq/der PC, tap mobile), feedback, loot popup.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ItemRarity = require(ReplicatedStorage.Config:WaitForChild("ItemRarity"))
local UITheme = require(ReplicatedStorage.Config:WaitForChild("UITheme"))
local BLACK_CELL = UITheme.Colors.Shadow

local RequestInventory = Remotes:WaitForChild("RequestInventory")
local RequestEquipItem = Remotes:WaitForChild("RequestEquipItem")
local RequestUnequipItem = Remotes:WaitForChild("RequestUnequipItem")
local RequestUseConsumable = Remotes:WaitForChild("RequestUseConsumable")
local RequestAssignItemUseSlot = Remotes:WaitForChild("RequestAssignItemUseSlot")
local InventoryData = Remotes:WaitForChild("InventoryData")
local InventoryResult = Remotes:WaitForChild("InventoryResult")
local VendorResult = Remotes:WaitForChild("VendorResult")
local LootReward = Remotes:WaitForChild("LootReward")
local RewardPopup = Remotes:WaitForChild("RewardPopup")
local GrantItem = Remotes:WaitForChild("GrantItem")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local isTouch = UserInputService.TouchEnabled

-- ----------------------------------------------------------------------------
-- Rarity mapping (ItemConfig usa Common/Uncommon/Rare/Epic → ItemRarity keys)
-- ----------------------------------------------------------------------------
local RARITY_MAP = {
	Common = ItemRarity.White,
	Uncommon = ItemRarity.Green,
	Rare = ItemRarity.Blue,
	Epic = ItemRarity.Purple,
}

local function getRarityColor(rarityName)
	local r = RARITY_MAP[rarityName]
	return r and r.Color or Color3.fromRGB(200, 200, 200)
end

local function getRarityLabel(rarityName)
	local r = RARITY_MAP[rarityName]
	return r and r.Name or rarityName
end

-- ----------------------------------------------------------------------------
-- UI refs
-- ----------------------------------------------------------------------------
local inventoryGui = playerGui:WaitForChild("InventoryUI")
local mainFrame = inventoryGui:WaitForChild("MainFrame")
local closeBtn = mainFrame:WaitForChild("CloseButton")
local bagPanel = mainFrame:WaitForChild("BagPanel")
local bagScroll = bagPanel:WaitForChild("BagScroll")

local equipmentGui = playerGui:WaitForChild("EquipmentUI")
local equipmentMainFrame = equipmentGui:WaitForChild("MainFrame")
local equipmentCloseBtn = equipmentMainFrame:WaitForChild("CloseButton")
local equipmentPanel = equipmentMainFrame:WaitForChild("EquipmentPanel")
local statsPanel = equipmentMainFrame:WaitForChild("StatsPanel")

local sharedGui = playerGui:WaitForChild("SharedUI")
local tooltip = sharedGui:WaitForChild("Tooltip")
local feedbackLabel = sharedGui:WaitForChild("FeedbackLabel")
local deleteConfirmationRequest = sharedGui:FindFirstChild("RequestItemDeleteConfirmation")
if not deleteConfirmationRequest then
	deleteConfirmationRequest = Instance.new("BindableEvent")
	deleteConfirmationRequest.Name = "RequestItemDeleteConfirmation"
	deleteConfirmationRequest.Parent = sharedGui
end

-- Tooltip sub-labels
local tipName = tooltip:WaitForChild("ItemName")
local tipRarity = tooltip:WaitForChild("Rarity")
local tipStats = tooltip:WaitForChild("Stats")
local tipAffixes = tooltip:WaitForChild("Affixes")
local tipBind = tooltip:WaitForChild("Bind")
local tipLevelReq = tooltip:WaitForChild("LevelReq")
local tipDesc = tooltip:WaitForChild("Description")

-- ----------------------------------------------------------------------------
-- State
-- ----------------------------------------------------------------------------
local inventoryOpen = false
local equipmentOpen = false
local currentInventory = nil  -- { bag = {...}, equipment = {...} }
local preferredEquipSlot = nil -- destino manual para armas de una mano
local bagSlotButtons = {}     -- array of frames in BagScroll
local EQUIP_SLOT_NAMES = { "Helmet", "Chest", "Shoulders", "Legs", "Gloves", "Ring", "Necklace", "MainHand", "OffHand" }
local equipSlotFrames = {}    -- [slotName] = Frame
local previousMouseBehavior = nil
local statConnections = {}
local cancelInventoryDrag
local MOBILE_DOUBLE_TAP_EQUIP_WINDOW_SECONDS = 0.35
local lastMobileItemTap = nil

local function bumpTooltipCloseVersion()
	local version = (tonumber(tooltip:GetAttribute("TooltipCloseVersion")) or 0) + 1
	tooltip:SetAttribute("TooltipCloseVersion", version)
	return version
end

local statLabels = {
	health = statsPanel:FindFirstChild("HealthStat"),
	mana = statsPanel:FindFirstChild("ManaStat"),
	attack = statsPanel:FindFirstChild("AttackStat"),
	magicAttack = statsPanel:FindFirstChild("MagicAttackStat"),
	defense = statsPanel:FindFirstChild("DefenseStat"),
	magicDefense = statsPanel:FindFirstChild("MagicDefenseStat"),
	crit = statsPanel:FindFirstChild("CritStat"),
}

local function formatCritPercent(value)
	local percent = (tonumber(value) or 0) * 100
	local rounded = string.format("%.1f", percent):gsub("%.0$", "")
	return rounded .. "%"
end

local function formatItemStat(statName, value)
	if string.upper(tostring(statName)) == "CRIT" then
		local numeric = tonumber(value) or 0
		return "+" .. formatCritPercent(numeric >= 1 and numeric / 100 or numeric) .. " CRIT"
	end
	return "+" .. tostring(math.floor(tonumber(value) or 0)) .. " " .. tostring(statName)
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

local function updateStatsPanel()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	local function setStat(label, caption, value)
		if not label then return end
		if value == nil then
			label.Visible = false
			return
		end
		label.Visible = true
		label.Text = caption .. ": " .. tostring(math.floor(tonumber(value) or 0))
	end

	setStat(statLabels.health, "Vida", humanoid and humanoid.MaxHealth)
	setStat(statLabels.mana, "Maná", character and character:GetAttribute("MaxMP"))
	setStat(statLabels.attack, "Ataque", character and character:GetAttribute("ATK"))
	setStat(statLabels.magicAttack, "Ataque mágico", character and character:GetAttribute("MATK"))
	setStat(statLabels.defense, "Defensa", character and character:GetAttribute("DEF"))
	setStat(statLabels.magicDefense, "Defensa mágica", character and character:GetAttribute("MDEF"))
	if statLabels.crit then
		local crit = character and character:GetAttribute("CRIT")
		statLabels.crit.Visible = crit ~= nil
		if crit ~= nil then statLabels.crit.Text = "Crítico: " .. formatCritPercent(crit) end
	end
end

local function bindStatsUpdates(character)
	for _, connection in ipairs(statConnections) do
		connection:Disconnect()
	end
	table.clear(statConnections)

	if not character then
		updateStatsPanel()
		return
	end

	for _, attributeName in ipairs({"MaxMP", "ATK", "MATK", "DEF", "MDEF", "CRIT"}) do
		table.insert(statConnections, character:GetAttributeChangedSignal(attributeName):Connect(updateStatsPanel))
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(statConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateStatsPanel))
	end
	updateStatsPanel()
end

local function syncCameraWithUi()
	local uiOpen = inventoryOpen or equipmentOpen
	if uiOpen then
		if previousMouseBehavior == nil then
			previousMouseBehavior = UserInputService.MouseBehavior
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	else
		if previousMouseBehavior ~= nil then
			UserInputService.MouseBehavior = previousMouseBehavior
			previousMouseBehavior = nil
		end
	end
	localPlayer:SetAttribute("UIWindowOpen", uiOpen)
end

-- ----------------------------------------------------------------------------
-- Feedback
-- ----------------------------------------------------------------------------
local feedbackTween = nil

local function showFeedback(text, isError)
	feedbackLabel.Text = text
	feedbackLabel.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(180, 255, 180)
	feedbackLabel.Visible = true
	feedbackLabel.BackgroundTransparency = 0.3

	if feedbackTween then feedbackTween:Cancel() end

	task.delay(2.5, function()
		feedbackTween = TweenService:Create(feedbackLabel, TweenInfo.new(0.5), {BackgroundTransparency = 1})
		feedbackTween:Play()
		feedbackTween.Completed:Connect(function()
			feedbackLabel.Visible = false
		end)
	end)
end

-- ----------------------------------------------------------------------------
-- Tooltip
-- ----------------------------------------------------------------------------
local function showTooltip(itemData, mousePos)
	if not itemData then
		bumpTooltipCloseVersion()
		tooltip:SetAttribute("TooltipOwner", "")
		tooltip:SetAttribute("ItemInstanceId", "")
		tooltip.Visible = false
		return
	end

	bumpTooltipCloseVersion()
	local color = getRarityColor(itemData.rarity)
	tooltip:SetAttribute("ItemInstanceId", itemData.instanceId or "")
	tooltip:SetAttribute("ItemTemplateId", itemData.templateId or "")
	tooltip:SetAttribute("ItemUsable", itemData.usable == true)
	tooltip:SetAttribute("ItemLevelReq", tonumber(itemData.levelReq) or 1)
	tooltip:SetAttribute("TooltipOwner", equipmentGui.Enabled and "Equipment" or "Inventory")

	tipName.Text = itemData.name or "???"
	tipName.TextColor3 = color

	tipRarity.Text = getRarityLabel(itemData.rarity) .. (itemData.slot and ("  ·  " .. itemData.slot) or "")
	tipRarity.TextColor3 = color

	-- Stats
	local statLines = {}
	if itemData.stats then
		for statName, value in pairs(itemData.stats) do
			table.insert(statLines, "  " .. formatItemStat(statName, value))
		end
	end
	tipStats.Text = #statLines > 0 and table.concat(statLines, "\n") or ""

	-- Affixes
	local affixLines = {}
	if itemData.affixes then
		for _, aff in ipairs(itemData.affixes) do
			table.insert(affixLines, "  " .. formatItemAffix(aff))
		end
	end
	tipAffixes.Text = #affixLines > 0 and table.concat(affixLines, "\n") or ""

	-- Bind
	if itemData.bindState == "Bound" then
		tipBind.Text = "Vinculado al equipar"
		tipBind.TextColor3 = Color3.fromRGB(255, 200, 100)
	elseif itemData.bindState == "Free" then
		tipBind.Text = "Sin vincular"
		tipBind.TextColor3 = Color3.fromRGB(150, 150, 150)
	else
		tipBind.Text = itemData.bindState or ""
	end

	-- Level req
	tipLevelReq.Text = "Requiere nivel " .. tostring(itemData.levelReq or 1)

	-- Description
	tipDesc.Text = itemData.description or ""

	-- rc042: la mochila muestra el detalle y las acciones en su panel derecho.
	if inventoryGui.Enabled and not equipmentGui.Enabled then
		tooltip.Visible = false
		return
	end
	tooltip.Visible = true

	-- Position tooltip near mouse, clamped to screen
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local tipSize = tooltip.AbsoluteSize
	local px = mousePos.X + 15
	local py = mousePos.Y + 15
	if px + tipSize.X > viewportSize.X then px = mousePos.X - tipSize.X - 15 end
	if py + tipSize.Y > viewportSize.Y then py = mousePos.Y - tipSize.Y - 15 end
	tooltip.Position = UDim2.new(0, px, 0, py)
end

local function hideTooltip()
	bumpTooltipCloseVersion()
	tooltip:SetAttribute("TooltipOwner", "")
	tooltip:SetAttribute("ItemInstanceId", "")
	tooltip:SetAttribute("TooltipHovering", false)
	tooltip.Visible = false
end

local function hideTooltipSoon()
	local version = bumpTooltipCloseVersion()
	task.delay(0.28, function()
		if tooltip:GetAttribute("TooltipCloseVersion") ~= version then
			return
		end
		if tooltip:GetAttribute("TooltipHovering") == true then
			return
		end
		local owner = tooltip:GetAttribute("TooltipOwner")
		if owner == "Inventory" or owner == "Equipment" then
			hideTooltip()
		end
	end)
end

-- ----------------------------------------------------------------------------
-- Bag slot creation
-- ----------------------------------------------------------------------------
local function createBagSlot(index)
	local slot = Instance.new("Frame")
	slot.Name = "BagSlot" .. tostring(index)
	slot.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	slot.BackgroundTransparency = 0.2

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = slot

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 70)
	stroke.Thickness = 1.5
	stroke.Parent = slot

	local rarityBar = Instance.new("Frame")
	rarityBar.Name = "RarityBar"
	rarityBar.Size = UDim2.new(1, -4, 0.06, 0)
	rarityBar.Position = UDim2.new(0, 2, 0, 2)
	rarityBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	local rbCorner = Instance.new("UICorner")
	rbCorner.CornerRadius = UDim.new(0, 3)
	rbCorner.Parent = rarityBar
	rarityBar.Parent = slot

	local icon = Instance.new("ImageLabel")
	icon.Name = "ItemIcon"
	icon.Size = UDim2.new(0.8, 0, 0.7, 0)
	icon.Position = UDim2.new(0.1, 0, 0.15, 0)
	icon.BackgroundTransparency = 1
	icon.Image = ""
	icon.Parent = slot

	local quantityLabel = Instance.new("TextLabel")
	quantityLabel.Name = "Quantity"
	quantityLabel.Size = UDim2.new(0.42, 0, 0.28, 0)
	quantityLabel.Position = UDim2.new(0.54, 0, 0.68, 0)
	quantityLabel.BackgroundTransparency = 1
	quantityLabel.Font = Enum.Font.BuilderSansBold
	quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	quantityLabel.TextScaled = true
	quantityLabel.TextXAlignment = Enum.TextXAlignment.Right
	quantityLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	quantityLabel.Text = ""
	quantityLabel.Visible = false
	quantityLabel.ZIndex = 2
	quantityLabel.Parent = slot

	slot.Parent = bagScroll
	return slot, rarityBar, icon, quantityLabel
end

-- Pre-create 20 bag slots
for i = 1, 20 do
	local slot, rarityBar, icon, quantityLabel = createBagSlot(i)
	bagSlotButtons[i] = { frame = slot, rarityBar = rarityBar, icon = icon, quantityLabel = quantityLabel, itemData = nil }
end

-- ----------------------------------------------------------------------------
-- Equipment slot refs
-- ----------------------------------------------------------------------------
for _, slotName in ipairs(EQUIP_SLOT_NAMES) do
	local frame = equipmentPanel:FindFirstChild(slotName)
	if frame then
		-- Equipment cards show only the item icon; empty slots keep their slot-type label.
		local nameLabel = frame:FindFirstChild("ItemName")
		if nameLabel then
			nameLabel.Visible = true
		end

		-- Add icon ImageLabel if not already present
		local icon = frame:FindFirstChild("ItemIcon")
		if not icon then
			icon = Instance.new("ImageLabel")
			icon.Name = "ItemIcon"
			icon.Size = UDim2.new(0.82, 0, 0.52, 0)
			icon.Position = UDim2.new(0.09, 0, 0.27, 0)
			icon.BackgroundTransparency = 1
			icon.ScaleType = Enum.ScaleType.Fit
			icon.ZIndex = 2
			icon.Image = ""
			icon.Parent = frame
		end
		equipSlotFrames[slotName] = frame
	end
end

-- ----------------------------------------------------------------------------
-- Render inventory
-- ----------------------------------------------------------------------------
local function renderBag(bag)
	for i = 1, 20 do
		local slotData = bagSlotButtons[i]
		local item = bag and bag[i]

		if item then
			slotData.itemData = item
			slotData.frame:SetAttribute("ItemInstanceId", item.instanceId or "")
			slotData.frame:SetAttribute("ItemTemplateId", item.templateId or "")
			slotData.frame:SetAttribute("ItemUsable", item.usable == true)
			slotData.rarityBar.BackgroundColor3 = getRarityColor(item.rarity)
			slotData.frame.BackgroundColor3 = BLACK_CELL
			if slotData.icon then
				slotData.icon.Image = item.iconId or ""
			end
			local quantity = tonumber(item.quantity) or 1
			if slotData.quantityLabel then
				slotData.quantityLabel.Text = quantity > 1 and ("x" .. tostring(quantity)) or ""
				slotData.quantityLabel.Visible = quantity > 1
			end
		else
			slotData.itemData = nil
			slotData.frame:SetAttribute("ItemInstanceId", "")
			slotData.frame:SetAttribute("ItemTemplateId", "")
			slotData.frame:SetAttribute("ItemUsable", false)
			slotData.rarityBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
			slotData.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			if slotData.icon then
				slotData.icon.Image = ""
			end
			if slotData.quantityLabel then
				slotData.quantityLabel.Text = ""
				slotData.quantityLabel.Visible = false
			end
		end
	end
end

local function renderEquipment(equipment)
	local mainHand = equipment and equipment.MainHand
	local offHand = equipment and equipment.OffHand
	local offHandBlocked = mainHand ~= nil
		and mainHand.wieldType == "TwoHand"
		and offHand ~= nil
		and offHand.instanceId == mainHand.instanceId

	for slotName, frame in pairs(equipSlotFrames) do
		frame:SetAttribute("HearthboundCellSelected", preferredEquipSlot == slotName)
		local nameLabel = frame:FindFirstChild("ItemName")
		local item = equipment and equipment[slotName]
		local icon = frame:FindFirstChild("ItemIcon")
		local blocked = slotName == "OffHand" and offHandBlocked

		frame:SetAttribute("blockedByTwoHand", blocked)
		if blocked then
			if icon then
				icon.Image = ""
				icon.Visible = false
			end
			if nameLabel then
				nameLabel.Text = "Bloqueado (2M)"
				nameLabel.Visible = true
			end
			frame.BackgroundColor3 = BLACK_CELL
			frame:SetAttribute("instanceId", "")
			frame:SetAttribute("hasItem", false)
		elseif item then
			if icon then
				icon.Image = item.iconId or ""
				icon.Visible = true
			end
			if nameLabel then
				nameLabel.Text = item.name or item.templateId or "Equipado"
				nameLabel.Visible = true
			end
			frame.BackgroundColor3 = BLACK_CELL
			frame:SetAttribute("instanceId", item.instanceId or "")
			frame:SetAttribute("hasItem", true)
		else
			if icon then
				icon.Image = ""
				icon.Visible = true
			end
			if nameLabel then
				if preferredEquipSlot == slotName then
					nameLabel.Text = slotName == "MainHand" and "Destino: mano principal" or "Destino: mano secundaria"
				else
					nameLabel.Text = "Vacío"
				end
				nameLabel.Visible = true
			end
			frame.BackgroundColor3 = BLACK_CELL
			frame:SetAttribute("hasItem", false)
			frame:SetAttribute("instanceId", "")
		end
	end
end

local function renderInventory(data)
	currentInventory = data
	if data then
		renderBag(data.bag)
		renderEquipment(data.equipment)
	end
end

-- ----------------------------------------------------------------------------
-- Toggle windows
-- ----------------------------------------------------------------------------
local function setInventoryOpen(open)
	if not open and cancelInventoryDrag then cancelInventoryDrag() end
	lastMobileItemTap = nil
	inventoryOpen = open
	if not open then
		preferredEquipSlot = nil
	end
	inventoryGui.Enabled = open
	if open then
		RequestInventory:FireServer()
	end
	hideTooltip()
	syncCameraWithUi()
end

local function setEquipmentOpen(open)
	if not open and cancelInventoryDrag then cancelInventoryDrag() end
	lastMobileItemTap = nil
	equipmentOpen = open
	if not open then
		preferredEquipSlot = nil
	end
	equipmentGui.Enabled = open
	if open then
		RequestInventory:FireServer()
	end
	hideTooltip()
	syncCameraWithUi()
end

local function toggleInventory()
	setInventoryOpen(not inventoryOpen)
end

local function toggleEquipment()
	setEquipmentOpen(not equipmentOpen)
end

-- MicroMenuUI solicita acciones sin acoplar directamente los LocalScripts.
local lastMicroMenuRequestId = nil
local lastMicroMenuCloseRequestId = nil

localPlayer:GetAttributeChangedSignal("MicroMenuCloseRequestId"):Connect(function()
	local requestId = localPlayer:GetAttribute("MicroMenuCloseRequestId")
	if requestId == lastMicroMenuCloseRequestId then
		return
	end
	lastMicroMenuCloseRequestId = requestId

	setInventoryOpen(false)
	setEquipmentOpen(false)
end)

localPlayer:GetAttributeChangedSignal("MicroMenuRequestId"):Connect(function()
	local requestId = localPlayer:GetAttribute("MicroMenuRequestId")
	if requestId == lastMicroMenuRequestId then
		return
	end
	lastMicroMenuRequestId = requestId

	local action = localPlayer:GetAttribute("MicroMenuAction")
	if action == "Inventory" then
		toggleInventory()
	elseif action == "Equipment" then
		toggleEquipment()
	end
end)

-- R6.10: sincronizar el estado interno cuando MenuClient cierra ventanas.
localPlayer:GetAttributeChangedSignal("MenuUIOpen"):Connect(function()
	if localPlayer:GetAttribute("MenuUIOpen") ~= true then
		return
	end
	inventoryOpen = false
	equipmentOpen = false
	preferredEquipSlot = nil
	inventoryGui.Enabled = false
	equipmentGui.Enabled = false
	hideTooltip()
	syncCameraWithUi()
	-- MenuUI sigue siendo una ventana activa aunque InventoryClient ya cerró
	-- sus propias ventanas.
	localPlayer:SetAttribute("UIWindowOpen", true)
end)

localPlayer:GetAttributeChangedSignal("MenuCloseWindowsRequest"):Connect(function()
	if localPlayer:GetAttribute("MenuCloseWindowsRequest") == nil then
		return
	end
	setInventoryOpen(false)
	setEquipmentOpen(false)
	localPlayer:SetAttribute("MenuCloseWindowsRequest", nil)
end)

-- ----------------------------------------------------------------------------
-- Click handling
-- ----------------------------------------------------------------------------
local function getInputScreenPosition(input)
	local position = input and input.Position
	if position then
		return Vector2.new(position.X, position.Y)
	end
	return UserInputService:GetMouseLocation()
end

local function onBagSlotClick(slotIndex, isRightClick, input, touchStartedAt)
	local slotData = bagSlotButtons[slotIndex]
	if not slotData or not slotData.itemData then return end

	local item = slotData.itemData
	local isTouchTap = input and input.UserInputType == Enum.UserInputType.Touch
		and type(touchStartedAt) == "number"
	if not isTouchTap then
		lastMobileItemTap = nil
	end
	local assignSlot = localPlayer:GetAttribute("ItemUseAssignSlot")
	if not isRightClick and type(assignSlot) == "number" and assignSlot >= 1 and assignSlot <= 2 then
		lastMobileItemTap = nil
		if item.usable == true then
			RequestAssignItemUseSlot:FireServer({ slotIndex = assignSlot, templateId = item.templateId })
			localPlayer:SetAttribute("ItemUseAssignSlot", nil)
			showFeedback("Asignando " .. tostring(item.name or item.templateId) .. " al slot " .. tostring(assignSlot), false)
		else
			showFeedback("Ese ítem no es usable", true)
		end
		return
	end

	if isTouchTap then
		local equipable = item.usable ~= true and item.slot ~= nil and item.slot ~= "Unknown"
		local previousTap = lastMobileItemTap
		local sincePreviousTap = previousTap and (touchStartedAt - previousTap.releasedAt) or math.huge
		if equipable and previousTap and previousTap.instanceId == item.instanceId
			and sincePreviousTap >= 0 and sincePreviousTap <= MOBILE_DOUBLE_TAP_EQUIP_WINDOW_SECONDS then
			lastMobileItemTap = nil
			hideTooltip()
			RequestEquipItem:FireServer({ instanceId = item.instanceId })
			return
		end
		if equipable then
			lastMobileItemTap = { instanceId = item.instanceId, releasedAt = os.clock() }
		else
			lastMobileItemTap = nil
		end
	end

	if isRightClick then
		-- En PC, el clic secundario ejecuta la acción primaria del objeto.
		if item.usable == true then
			RequestUseConsumable:FireServer({ instanceId = item.instanceId })
		elseif item.slot and item.slot ~= "Unknown" then
			RequestEquipItem:FireServer({ instanceId = item.instanceId })
		else
			showFeedback("Este objeto no se puede usar ni equipar", true)
		end
		return
	end

	-- Clic o toque normal: seleccionar para inspeccionar; las acciones se ejecutan
	-- desde los botones del panel de detalle.
	showTooltip(item, getInputScreenPosition(input))
end

local function onEquipSlotClick(slotName, input)
	local frame = equipSlotFrames[slotName]
	if not frame then return end

	local item = currentInventory and currentInventory.equipment and currentInventory.equipment[slotName]
	if item then
		-- Las casillas ocupadas solo muestran el detalle; desequipar requiere
		-- pulsar la acción explícita del tooltip.
		showTooltip(item, getInputScreenPosition(input))
		return
	end
	if frame:GetAttribute("blockedByTwoHand") then
		return
	end
	if input and input.UserInputType == Enum.UserInputType.MouseButton2 then
		return
	end

	if slotName == "MainHand" or slotName == "OffHand" then
		preferredEquipSlot = preferredEquipSlot == slotName and nil or slotName
		if currentInventory then
			renderEquipment(currentInventory.equipment)
		end
		if preferredEquipSlot then
			local label = slotName == "MainHand" and "mano principal" or "mano secundaria"
			showFeedback("Destino de equipamiento: " .. label, false)
		else
			showFeedback("Destino de equipamiento cancelado", false)
		end
	end
end

-- ----------------------------------------------------------------------------
-- Input connections for bag slots
-- ----------------------------------------------------------------------------
local TOUCH_DRAG_HOLD_SECONDS = 0.30
local DRAG_START_DISTANCE_PX = 8
local pendingBagDrag = nil
local activeBagDrag = nil
local pendingEquipmentDrag = nil
local activeEquipmentDrag = nil
local dragScrollWasEnabled = nil

local dragOverlayGui = playerGui:FindFirstChild("InventoryDragOverlayUI")
if not dragOverlayGui then
	dragOverlayGui = Instance.new("ScreenGui")
	dragOverlayGui.Name = "InventoryDragOverlayUI"
	dragOverlayGui.ResetOnSpawn = false
	dragOverlayGui.IgnoreGuiInset = true
	dragOverlayGui.DisplayOrder = 1000
	dragOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	dragOverlayGui.Parent = playerGui
end

local dragGhost = dragOverlayGui:FindFirstChild("ItemDragGhost")
if not dragGhost then
	dragGhost = Instance.new("ImageLabel")
	dragGhost.Name = "ItemDragGhost"
	dragGhost.Size = UDim2.fromOffset(52, 52)
	dragGhost.AnchorPoint = Vector2.new(0.5, 0.5)
	dragGhost.BackgroundColor3 = Color3.fromRGB(25, 22, 20)
	dragGhost.BackgroundTransparency = 0.12
	dragGhost.BorderSizePixel = 0
	dragGhost.ImageTransparency = 0.08
	dragGhost.ScaleType = Enum.ScaleType.Fit
	dragGhost.Visible = false
	dragGhost.ZIndex = 100
	dragGhost.Parent = dragOverlayGui
	local ghostCorner = Instance.new("UICorner")
	ghostCorner.CornerRadius = UDim.new(0, 7)
	ghostCorner.Parent = dragGhost
	local ghostStroke = Instance.new("UIStroke")
	ghostStroke.Color = Color3.fromRGB(210, 177, 100)
	ghostStroke.Thickness = 2
	ghostStroke.Parent = dragGhost
	local ghostAspect = Instance.new("UIAspectRatioConstraint")
	ghostAspect.AspectRatio = 1
	ghostAspect.Parent = dragGhost
end

local bagDropHighlight = bagPanel:FindFirstChild("R6_32UnequipDropHighlight")
if not bagDropHighlight then
	bagDropHighlight = Instance.new("UIStroke")
	bagDropHighlight.Name = "R6_32UnequipDropHighlight"
	bagDropHighlight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bagDropHighlight.Thickness = 3
	bagDropHighlight.Color = Color3.fromRGB(87, 205, 126)
	bagDropHighlight.Enabled = false
	bagDropHighlight.Parent = bagPanel
end

local function pointInsideGuiObject(guiObject, point)
	if not guiObject or not guiObject.Visible then return false end
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize
	return size.X > 0 and size.Y > 0
		and point.X >= position.X and point.Y >= position.Y
		and point.X <= position.X + size.X and point.Y <= position.Y + size.Y
end

local function canEquipItemToSlot(item, slotName)
	if not item or item.usable == true or not item.slot or item.slot == "Unknown" then
		return false
	end
	if slotName == "OffHand" and equipSlotFrames.OffHand
		and equipSlotFrames.OffHand:GetAttribute("blockedByTwoHand") == true then
		return false
	end
	local equipment = currentInventory and currentInventory.equipment or {}
	for _, equipped in pairs(equipment) do
		if equipped and equipped.wieldType == "TwoHand" then
			return false
		end
	end
	if item.wieldType == "TwoHand" and (equipment.MainHand or equipment.OffHand) then
		return false
	end
	if item.slot == slotName then
		return true
	end
	return item.slot == "MainHand" and slotName == "OffHand" and item.wieldType == "OneHand"
end

local function findEquipSlotAtPosition(point)
	if not equipmentGui.Enabled or not equipmentMainFrame.Visible then return nil end
	for _, slotName in ipairs(EQUIP_SLOT_NAMES) do
		local frame = equipSlotFrames[slotName]
		if pointInsideGuiObject(frame, point) then
			return slotName
		end
	end
	return nil
end

local function isInsideOpenWindow(point)
	return (inventoryGui.Enabled and pointInsideGuiObject(mainFrame, point))
		or (equipmentGui.Enabled and pointInsideGuiObject(equipmentMainFrame, point))
end

local function isInsideBagDropArea(point)
	return inventoryGui.Enabled
		and mainFrame.Visible
		and pointInsideGuiObject(bagPanel, point)
end

local function resetDragHighlights()
	for _, frame in pairs(equipSlotFrames) do
		local stroke = frame:FindFirstChild("R6_32DragHighlight")
		if stroke then stroke.Enabled = false end
	end
	bagDropHighlight.Enabled = false
end

local function updateDragPresentation(point)
	local candidate = activeBagDrag or activeEquipmentDrag
	if not candidate then return end
	dragGhost.Image = candidate.item.iconId or ""
	dragGhost.Position = UDim2.fromOffset(point.X, point.Y)
	dragGhost.Visible = true

	if activeEquipmentDrag == candidate then
		for _, frame in pairs(equipSlotFrames) do
			local stroke = frame:FindFirstChild("R6_32DragHighlight")
			if stroke then stroke.Enabled = false end
		end
		bagDropHighlight.Enabled = isInsideBagDropArea(point)
		return
	end

	bagDropHighlight.Enabled = false
	local hoveredSlot = findEquipSlotAtPosition(point)
	for slotName, frame in pairs(equipSlotFrames) do
		local stroke = frame:FindFirstChild("R6_32DragHighlight")
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Name = "R6_32DragHighlight"
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Thickness = 2
			stroke.Enabled = false
			stroke.Parent = frame
		end
		local valid = canEquipItemToSlot(candidate.item, slotName)
		if slotName == hoveredSlot then
			stroke.Color = valid and Color3.fromRGB(87, 205, 126) or Color3.fromRGB(224, 82, 78)
			stroke.Thickness = 3
			stroke.Enabled = true
		elseif valid then
			stroke.Color = Color3.fromRGB(87, 205, 126)
			stroke.Thickness = 2
			stroke.Enabled = true
		else
			stroke.Enabled = false
		end
	end
end

local function pointerMatchesChanged(candidate, input)
	if candidate.inputType == Enum.UserInputType.Touch then
		return input.UserInputType == Enum.UserInputType.Touch
			and (candidate.touchId == nil or input.TouchId == candidate.touchId)
	end
	return input.UserInputType == Enum.UserInputType.MouseMovement
end

local function pointerMatchesEnded(candidate, input)
	if candidate.inputType == Enum.UserInputType.Touch then
		return input.UserInputType == Enum.UserInputType.Touch
			and (candidate.touchId == nil or input.TouchId == candidate.touchId)
	end
	return input.UserInputType == Enum.UserInputType.MouseButton1
end

local function startBagDrag(candidate)
	if pendingBagDrag ~= candidate then return end
	lastMobileItemTap = nil
	local slotData = bagSlotButtons[candidate.slotIndex]
	local liveItem = slotData and slotData.itemData
	if not liveItem or liveItem.instanceId ~= candidate.item.instanceId then
		cancelInventoryDrag()
		return
	end
	pendingBagDrag = nil
	activeBagDrag = candidate
	dragScrollWasEnabled = bagScroll.ScrollingEnabled
	bagScroll.ScrollingEnabled = false
	hideTooltip()
	updateDragPresentation(candidate.lastPosition)
end

local function startEquipmentDrag(candidate)
	if pendingEquipmentDrag ~= candidate then return end
	local equipment = currentInventory and currentInventory.equipment
	local liveItem = equipment and equipment[candidate.slotName]
	if not liveItem or liveItem.instanceId ~= candidate.item.instanceId then
		cancelInventoryDrag()
		return
	end
	pendingEquipmentDrag = nil
	activeEquipmentDrag = candidate
	dragScrollWasEnabled = bagScroll.ScrollingEnabled
	bagScroll.ScrollingEnabled = false
	hideTooltip()
	updateDragPresentation(candidate.lastPosition)
end

cancelInventoryDrag = function()
	pendingBagDrag = nil
	activeBagDrag = nil
	pendingEquipmentDrag = nil
	activeEquipmentDrag = nil
	dragGhost.Visible = false
	resetDragHighlights()
	if dragScrollWasEnabled ~= nil then
		bagScroll.ScrollingEnabled = dragScrollWasEnabled
		dragScrollWasEnabled = nil
	end
end

local function beginBagDragCandidate(slotIndex, input)
	local slotData = bagSlotButtons[slotIndex]
	if not slotData or not slotData.itemData or pendingBagDrag or activeBagDrag
		or pendingEquipmentDrag or activeEquipmentDrag then return end
	local startPosition = getInputScreenPosition(input)
	local candidate = {
		slotIndex = slotIndex,
		item = slotData.itemData,
		input = input,
		inputType = input.UserInputType,
		touchId = input.UserInputType == Enum.UserInputType.Touch and input.TouchId or nil,
		startPosition = startPosition,
		lastPosition = startPosition,
		startedAt = os.clock(),
		cancelled = false,
	}
	pendingBagDrag = candidate
	if candidate.inputType == Enum.UserInputType.Touch then
		task.delay(TOUCH_DRAG_HOLD_SECONDS, function()
			if pendingBagDrag == candidate and not candidate.cancelled then
				startBagDrag(candidate)
			end
		end)
	end
end

local function beginEquipmentDragCandidate(slotName, item, input)
	if not item or pendingBagDrag or activeBagDrag or pendingEquipmentDrag or activeEquipmentDrag then return end
	lastMobileItemTap = nil
	local startPosition = getInputScreenPosition(input)
	local candidate = {
		slotName = slotName,
		item = item,
		input = input,
		inputType = input.UserInputType,
		touchId = input.UserInputType == Enum.UserInputType.Touch and input.TouchId or nil,
		startPosition = startPosition,
		lastPosition = startPosition,
		startedAt = os.clock(),
		cancelled = false,
	}
	pendingEquipmentDrag = candidate
	if candidate.inputType == Enum.UserInputType.Touch then
		task.delay(TOUCH_DRAG_HOLD_SECONDS, function()
			if pendingEquipmentDrag == candidate and not candidate.cancelled then
				startEquipmentDrag(candidate)
			end
		end)
	end
end

UserInputService.InputChanged:Connect(function(input)
	local candidate = activeBagDrag or activeEquipmentDrag or pendingBagDrag or pendingEquipmentDrag
	if not candidate or not pointerMatchesChanged(candidate, input) then return end
	local point = Vector2.new(input.Position.X, input.Position.Y)
	candidate.lastPosition = point
	if activeBagDrag == candidate or activeEquipmentDrag == candidate then
		updateDragPresentation(point)
		return
	end
	local distance = (point - candidate.startPosition).Magnitude
	if candidate.inputType == Enum.UserInputType.Touch then
		if distance > DRAG_START_DISTANCE_PX then
			lastMobileItemTap = nil
			candidate.cancelled = true
			if pendingBagDrag == candidate then
				pendingBagDrag = nil
			else
				pendingEquipmentDrag = nil
			end
		end
	elseif distance >= DRAG_START_DISTANCE_PX then
		if pendingBagDrag == candidate then
			startBagDrag(candidate)
		else
			startEquipmentDrag(candidate)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	local candidate = activeBagDrag or activeEquipmentDrag
	if candidate and pointerMatchesEnded(candidate, input) then
		local point = Vector2.new(input.Position.X, input.Position.Y)
		local bagSource = activeBagDrag == candidate
		local targetSlot = bagSource and findEquipSlotAtPosition(point) or nil
		local inOpenWindow = isInsideOpenWindow(point)
		local droppedInBag = not bagSource and isInsideBagDropArea(point)
		cancelInventoryDrag()

		if bagSource then
			if targetSlot then
				if canEquipItemToSlot(candidate.item, targetSlot) then
					local payload = { instanceId = candidate.item.instanceId }
					if targetSlot == "MainHand" or targetSlot == "OffHand" then
						payload.preferredSlot = targetSlot
					end
					RequestEquipItem:FireServer(payload)
				else
					showFeedback("No puedes equipar este objeto en ese slot", true)
				end
			elseif not inOpenWindow then
				deleteConfirmationRequest:Fire(candidate.item)
			end
		else
			if droppedInBag then
				local liveItem = currentInventory and currentInventory.equipment
					and currentInventory.equipment[candidate.slotName]
				if liveItem and liveItem.instanceId == candidate.item.instanceId then
					RequestUnequipItem:FireServer({
						slotName = candidate.slotName,
						instanceId = candidate.item.instanceId,
					})
				else
					showFeedback("El equipo cambió durante el arrastre", true)
				end
			end
		end
		return
	end

	candidate = pendingBagDrag or pendingEquipmentDrag
	if not candidate or not pointerMatchesEnded(candidate, input) then return end
	local bagSource = pendingBagDrag == candidate
	if bagSource then
		pendingBagDrag = nil
	else
		pendingEquipmentDrag = nil
	end
	if candidate.cancelled then return end
	local elapsed = os.clock() - candidate.startedAt
	local moved = (candidate.lastPosition - candidate.startPosition).Magnitude
	if candidate.inputType ~= Enum.UserInputType.Touch
		or (elapsed < TOUCH_DRAG_HOLD_SECONDS and moved <= DRAG_START_DISTANCE_PX) then
		if bagSource then
			onBagSlotClick(candidate.slotIndex, false, candidate.input, candidate.startedAt)
		else
			onEquipSlotClick(candidate.slotName, candidate.input)
		end
	end
end)

for i, slotData in ipairs(bagSlotButtons) do
	local slotFrame = slotData.frame
	slotFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			beginBagDragCandidate(i, input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			onBagSlotClick(i, true, input)
		end
	end)
	slotFrame.MouseEnter:Connect(function()
		if activeBagDrag or activeEquipmentDrag then return end
		local mouseLoc = UserInputService:GetMouseLocation()
		showTooltip(slotData.itemData, mouseLoc)
	end)
	slotFrame.MouseLeave:Connect(hideTooltipSoon)
end

-- ----------------------------------------------------------------------------
-- Input connections for equipment slots
-- ----------------------------------------------------------------------------
for slotName, frame in pairs(equipSlotFrames) do
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			local item = currentInventory and currentInventory.equipment
				and currentInventory.equipment[slotName] or nil
			if item then
				beginEquipmentDragCandidate(slotName, item, input)
			else
				onEquipSlotClick(slotName, input)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			onEquipSlotClick(slotName, input)
		end
	end)

	frame.MouseEnter:Connect(function()
		if activeBagDrag or activeEquipmentDrag then return end
		local item = frame:GetAttribute("hasItem") and currentInventory and currentInventory.equipment
			and currentInventory.equipment[slotName] or nil
		local mouseLoc = UserInputService:GetMouseLocation()
		showTooltip(item, mouseLoc)
	end)

	frame.MouseLeave:Connect(hideTooltipSoon)
end

-- ----------------------------------------------------------------------------
-- Close buttons
-- ----------------------------------------------------------------------------
closeBtn.MouseButton1Click:Connect(function()
	setInventoryOpen(false)
end)

equipmentCloseBtn.MouseButton1Click:Connect(function()
	setEquipmentOpen(false)
end)

-- ----------------------------------------------------------------------------
-- Keyboard input (PC)
-- ----------------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.B then
		toggleInventory()
	elseif input.KeyCode == Enum.KeyCode.C then
		toggleEquipment()
	elseif input.KeyCode == Enum.KeyCode.Escape then
		if cancelInventoryDrag and (pendingBagDrag or activeBagDrag or pendingEquipmentDrag or activeEquipmentDrag) then
			cancelInventoryDrag()
			return
		end
		if inventoryOpen or equipmentOpen then
			setInventoryOpen(false)
			setEquipmentOpen(false)
		end
	end
end)

-- R6.10: los accesos de bolsa/equipo viven en el micro menú compartido;
-- se eliminan los botones independientes para evitar duplicados y solapamientos.

-- ----------------------------------------------------------------------------
-- Remote handlers
-- ----------------------------------------------------------------------------
InventoryData.OnClientEvent:Connect(function(data)
	renderInventory(data)
end)

InventoryResult.OnClientEvent:Connect(function(result)
	if result.success then
		showFeedback("✓ Acción completada", false)
	else
		showFeedback("✗ " .. (result.error or "Error desconocido"), true)
	end
end)

-- R5: VendorResult se usa también para feedback de consumibles
VendorResult.OnClientEvent:Connect(function(result)
	if result.success then
		showFeedback("✓ Consumible usado", false)
	else
		showFeedback("✗ " .. (result.error or "Error"), true)
	end
end)

-- ----------------------------------------------------------------------------
-- Loot reward popup
-- ----------------------------------------------------------------------------
local lootPopup = nil
local lootContent = nil
local lootPopupTween = nil
local lootToastVersion = 0
local lootToastHeight = 88

local function layoutLootToast()
	if not lootPopup or not lootPopup.Parent then return end
	local area = sharedGui.AbsoluteSize
	if area.X <= 0 or area.Y <= 0 then return end
	local width = math.min(300, area.X * 0.92)
	local height = math.min(lootToastHeight, area.Y * 0.42)
	local margin = Vector2.new(area.X * 0.02, area.Y * 0.02)
	local obstacles = {}
	for _, path in ipairs({{"MicroMenuUI", "MicroMenuBar"}, {"MobileAccessUI", "MobileAccessStack"},
		{"HUD", "ItemUseSlotsFrame"}, {"SkillBar", "BarContainer"}, {"HUD", "PlayerFrame"},
		{"HUD", "TargetFrame"}, {"PartyUI", "PartyHUD"}}) do
		local gui = playerGui:FindFirstChild(path[1])
		local frame = gui and gui:FindFirstChild(path[2])
		if gui and gui.Enabled and frame and frame.Visible then
			table.insert(obstacles, {position = frame.AbsolutePosition - sharedGui.AbsolutePosition, size = frame.AbsoluteSize})
		end
	end
	local right = area.X - margin.X - width
	local bottom = area.Y - margin.Y - height
	local candidates = {Vector2.new(right, bottom)}
	for _, obstacle in ipairs(obstacles) do
		table.insert(candidates, Vector2.new(right, obstacle.position.Y - height - margin.Y))
	end
	table.insert(candidates, Vector2.new((area.X - width) / 2, margin.Y))
	table.insert(candidates, Vector2.new(right, margin.Y))
	table.insert(candidates, Vector2.new(margin.X, bottom))
	table.insert(candidates, margin)
	local chosen = Vector2.new(math.max(margin.X, right), math.max(margin.Y, bottom))
	for _, position in ipairs(candidates) do
		local fits = position.X >= margin.X and position.Y >= margin.Y
			and position.X + width <= area.X - margin.X + 0.5
			and position.Y + height <= area.Y - margin.Y + 0.5
		if fits then
			for _, obstacle in ipairs(obstacles) do
				local origin, size = obstacle.position, obstacle.size
				if position.X < origin.X + size.X and position.X + width > origin.X
					and position.Y < origin.Y + size.Y and position.Y + height > origin.Y then
					fits = false
					break
				end
			end
		end
		if fits then chosen = position; break end
	end
	lootPopup.Size = UDim2.fromScale(width / area.X, height / area.Y)
	if localPlayer:GetAttribute("UILayoutLootPopupManaged") ~= true then
		lootPopup.Position = UDim2.fromScale((chosen.X + width) / area.X, (chosen.Y + height) / area.Y)
	end
end

local function createLootPopup()
	local popup = Instance.new("Frame")
	popup.Name = "LootPopup"
	popup.Size = UDim2.fromScale(0.24, 0.12)
	-- En escritorio queda por encima del micro menú; móvil conserva su posición.
	popup.Position = UDim2.fromScale(0.98, 0.88)
	popup.AnchorPoint = Vector2.new(1, 1)
	popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	popup.BackgroundTransparency = 0.08
	popup.Visible = false
	popup.ZIndex = 20
	popup.ClipsDescendants = true

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.Name = "ToastSizeConstraint"
	sizeConstraint.MinSize = Vector2.new(0, 0)
	sizeConstraint.MaxSize = Vector2.new(320, 180)
	sizeConstraint.Parent = popup

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = popup

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(180, 150, 60)
	stroke.Thickness = 1.5
	stroke.Parent = popup

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromScale(0.92, 0.22)
	title.Position = UDim2.fromScale(0.04, 0.08)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.BuilderSansBold
	title.TextSize = 15
	title.TextColor3 = Color3.fromRGB(255, 220, 100)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Botín obtenido"
	title.ZIndex = 21
	title.Parent = popup

	local content = Instance.new("TextLabel")
	content.Name = "Content"
	content.Size = UDim2.fromScale(0.92, 0.61)
	content.Position = UDim2.fromScale(0.04, 0.32)
	content.BackgroundTransparency = 1
	content.Font = Enum.Font.BuilderSansBold
	content.TextSize = 13
	content.TextColor3 = Color3.fromRGB(255, 255, 255)
	content.TextWrapped = true
	content.TextXAlignment = Enum.TextXAlignment.Left
	content.TextYAlignment = Enum.TextYAlignment.Top
	content.ZIndex = 21
	content.Parent = popup

	popup.Parent = sharedGui
	return popup, content
end

lootPopup, lootContent = createLootPopup()
sharedGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutLootToast)
localPlayer:GetAttributeChangedSignal("UILayoutLootPopupManaged"):Connect(layoutLootToast)
local watchedToastObstacles = setmetatable({}, {__mode = "k"})
local function watchToastObstacle(instance)
	if watchedToastObstacles[instance] or not instance:IsA("GuiObject") then return end
	if not table.find({"MicroMenuBar", "MobileAccessStack", "ItemUseSlotsFrame", "BarContainer", "PlayerFrame", "TargetFrame", "PartyHUD"}, instance.Name) then return end
	watchedToastObstacles[instance] = true
	instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(layoutLootToast)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutLootToast)
	instance:GetPropertyChangedSignal("Visible"):Connect(layoutLootToast)
end
for _, instance in ipairs(playerGui:GetDescendants()) do watchToastObstacle(instance) end
playerGui.DescendantAdded:Connect(watchToastObstacle)
layoutLootToast()

local function showLootReward(data)
	if not lootPopup or type(data) ~= "table" then return end

	local lines = {}
	if data.items and #data.items > 0 then
		for _, item in ipairs(data.items) do
			local quantity = tonumber(item.quantity) or 1
			local itemLabel = item.name or "???"
			if item.unique == true then
				itemLabel = "★ " .. itemLabel
			end
			if item.rarity then
				itemLabel = itemLabel .. " [" .. getRarityLabel(item.rarity) .. "]"
			end
			if quantity > 1 then
				itemLabel = itemLabel .. " x" .. tostring(quantity)
			end
			table.insert(lines, itemLabel)
			-- Stats/affixes remain in item details; the toast summarizes actual loot.
		end
	end
	if data.unique == true then
		table.insert(lines, "★ Recompensa única")
	end
	if tonumber(data.gold) and data.gold > 0 then
		table.insert(lines, tostring(data.gold) .. " oro")
	end

	if #lines == 0 then return end

	local maxLines = 4
	local displayedLines = lines
	if #lines > maxLines then
		displayedLines = {}
		for index = 1, maxLines do
			table.insert(displayedLines, lines[index])
		end
		table.insert(displayedLines, "… +" .. tostring(#lines - maxLines) .. " más")
	end

	lootToastVersion += 1
	local toastVersion = lootToastVersion

	if lootPopupTween then
		lootPopupTween:Cancel()
		lootPopupTween = nil
	end

	lootContent.Text = table.concat(displayedLines, "\n")
	local textBounds = game:GetService("TextService"):GetTextSize(lootContent.Text, lootContent.TextSize,
		lootContent.Font, Vector2.new(math.min(300, sharedGui.AbsoluteSize.X * 0.92) * 0.92, 1000))
	lootToastHeight = math.clamp(math.ceil(textBounds.Y / 0.61) + 8, 88, 180)
	layoutLootToast()
	lootPopup.BackgroundTransparency = 0.08
	lootPopup.Visible = true

	-- Auto-hide with a short fade, without interrupting a newer loot toast.
	task.delay(4, function()
		if not lootPopup or toastVersion ~= lootToastVersion then return end

		local fadeTween = TweenService:Create(
			lootPopup,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)
		lootPopupTween = fadeTween
		fadeTween:Play()
		fadeTween.Completed:Wait()

		if lootPopup and toastVersion == lootToastVersion then
			lootPopup.Visible = false
			lootPopup.BackgroundTransparency = 0.08
			lootPopupTween = nil
		end
	end)
end

LootReward.OnClientEvent:Connect(showLootReward)
RewardPopup.OnClientEvent:Connect(showLootReward)

-- ----------------------------------------------------------------------------
-- Debug: Grant item command (Studio only)
-- ----------------------------------------------------------------------------
local debugItems = { "sword_apprentice", "sword_iron", "sword_knight", "sword_champion", "shield_guard", "hunter_bow", "chest_leather", "potion_hp", "potion_mp" }
local debugIndex = 1

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	-- G key: grant debug item (Studio only)
	if input.KeyCode == Enum.KeyCode.G then
		local templateId = debugItems[debugIndex]
		debugIndex = debugIndex + 1
		if debugIndex > #debugItems then debugIndex = 1 end
		GrantItem:FireServer({ templateId = templateId })
		showFeedback("Debug: otorgando " .. templateId, false)
	end
end)

-- ----------------------------------------------------------------------------
-- Request inventory on character spawn
-- ----------------------------------------------------------------------------
local function onCharacterAdded(character)
	-- Wait a moment for server to set up the character
	task.wait(1)
	RequestInventory:FireServer()
end

localPlayer.CharacterAdded:Connect(function(character)
	bindStatsUpdates(character)
	onCharacterAdded(character)
end)
if localPlayer.Character then
	bindStatsUpdates(localPlayer.Character)
	task.spawn(onCharacterAdded, localPlayer.Character)
end
syncCameraWithUi()

print("[Vandrheim] InventoryClient R6.5 activo")


