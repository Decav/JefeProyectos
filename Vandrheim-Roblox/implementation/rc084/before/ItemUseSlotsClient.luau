--[[
	ItemUseSlotsClient - HU-R6.2
	HUD de dos slots genéricos (Z/X), estado server-authoritative y asignación
	por modo de selección compatible con PC y móvil.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("HUD")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ItemConfig = require(ReplicatedStorage.Config:WaitForChild("ItemConfig"))
local isTouch = UserInputService.TouchEnabled

local RequestUseItemSlot = Remotes:WaitForChild("RequestUseItemSlot")
local ItemUseSlotState = Remotes:WaitForChild("ItemUseSlotState")
local InventoryResult = Remotes:WaitForChild("InventoryResult")

local COOLDOWN_SECONDS = 30
local slotState = {
	slots = { [1] = "", [2] = "" },
	quantities = { [1] = 0, [2] = 0 },
	cooldownRemaining = 0,
}
local slotViews = {}
local cooldownEndsAt = 0
local feedbackLabel = nil

local function getTemplate(templateId)
	if type(templateId) ~= "string" or templateId == "" then return nil end
	return ItemConfig.GetTemplate(templateId)
end

local function showFeedback(text, isError)
	if not feedbackLabel then return end
	feedbackLabel.Text = text
	feedbackLabel.TextColor3 = isError and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(180, 255, 180)
	feedbackLabel.Visible = true
	task.delay(2.5, function()
		if feedbackLabel and feedbackLabel.Text == text then
			feedbackLabel.Visible = false
		end
	end)
end

local function updateSlot(index)
	local view = slotViews[index]
	if not view then return end
	local templateId = slotState.slots[index] or ""
	local template = getTemplate(templateId)
	local quantity = tonumber(slotState.quantities[index]) or 0
	view.icon.Image = template and template.iconId or ""
	view.quantity.Text = quantity > 0 and ("x" .. tostring(quantity)) or ""
	view.quantity.Visible = quantity > 0
	view.keyLabel.Text = index == 1 and "Z" or "X"
	view.assignButton.Visible = isTouch
end

local function updateCooldown()
	local remaining = math.max(0, cooldownEndsAt - os.clock())
	for _, view in pairs(slotViews) do
		view.cooldown.Visible = remaining > 0
		view.cooldownLabel.Text = remaining > 0 and (tostring(math.ceil(remaining)) .. "s") or ""
	end
end

local function beginCooldown(seconds)
	cooldownEndsAt = os.clock() + math.max(0, tonumber(seconds) or COOLDOWN_SECONDS)
	if cooldownEndsAt <= os.clock() then
		updateCooldown()
		return
	end
	task.spawn(function()
		while os.clock() < cooldownEndsAt do
			updateCooldown()
			task.wait(0.25)
		end
		updateCooldown()
	end)
end

local function setAssignMode(index)
	if localPlayer:GetAttribute("UILayoutEditMode") == true then return end
	localPlayer:SetAttribute("ItemUseAssignSlot", index)
	showFeedback("Selecciona un ítem usable para asignarlo a " .. (index == 1 and "Z" or "X"), false)
	for slotIndex, view in pairs(slotViews) do
		view.assignButton.Text = slotIndex == index and "Seleccionado" or "Asignar"
	end
end

local function requestUse(index)
	if localPlayer:GetAttribute("UILayoutEditMode") == true or UserInputService:GetFocusedTextBox() then return end
	local templateId = slotState.slots[index] or ""
	if templateId == "" then
		-- Un slot vacío entra directamente en modo de asignación al hacer clic.
		setAssignMode(index)
		return
	end
	RequestUseItemSlot:FireServer({ slotIndex = index })
end

local function createSlot(index)
	local frame = Instance.new("Frame")
	frame.Name = index == 1 and "UseSlotZ" or "UseSlotX"
	frame.Size = UDim2.fromOffset(54, 54)
	frame.BackgroundColor3 = Color3.fromRGB(23, 19, 17)
	frame.BackgroundTransparency = 0
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.LayoutOrder = index

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(58, 44, 37)
	stroke.Thickness = 1
	stroke.Parent = frame

	local button = Instance.new("ImageButton")
	button.Name = "UseButton"
	button.Size = UDim2.new(1, -2, 1, -2)
	button.Position = UDim2.fromScale(0.5, 0.5)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Image = ""
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.ZIndex = 2
	button.Parent = frame
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 4)
	buttonCorner.Parent = button

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.fromScale(1, 1)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.BackgroundTransparency = 1
	icon.ScaleType = Enum.ScaleType.Crop
	icon.ZIndex = 3
	icon.Parent = button
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 4)
	iconCorner.Parent = icon

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "Key"
	keyLabel.Size = UDim2.fromOffset(14, 13)
	keyLabel.Position = UDim2.fromOffset(7, 5)
	keyLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	keyLabel.BackgroundTransparency = 0.35
	keyLabel.ZIndex = 8
	keyLabel.Font = Enum.Font.BuilderSansBold
	keyLabel.TextColor3 = Color3.fromRGB(235, 220, 190)
	keyLabel.TextStrokeTransparency = 1
	keyLabel.TextSize = 11
	keyLabel.Parent = button
	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 2)
	keyCorner.Parent = keyLabel

	local quantity = Instance.new("TextLabel")
	quantity.Name = "Quantity"
	quantity.Size = UDim2.fromOffset(25, 13)
	quantity.Position = UDim2.new(1, -4, 1, -3)
	quantity.AnchorPoint = Vector2.new(1, 1)
	quantity.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	quantity.BackgroundTransparency = 0.35
	quantity.ZIndex = 8
	quantity.Font = Enum.Font.BuilderSansBold
	quantity.TextColor3 = Color3.fromRGB(235, 220, 190)
	quantity.TextStrokeTransparency = 1
	quantity.TextSize = 10
	quantity.TextXAlignment = Enum.TextXAlignment.Right
	local quantityCorner = Instance.new("UICorner")
	quantityCorner.CornerRadius = UDim.new(0, 2)
	quantityCorner.Parent = quantity
	quantity.Parent = button

	local assignButton = Instance.new("TextButton")
	assignButton.Name = "AssignButton"
	assignButton.Size = UDim2.new(0.24, 0, 0.25, 0)
	assignButton.Position = UDim2.new(0.72, 0, 0.69, 0)
	assignButton.BackgroundColor3 = Color3.fromRGB(23, 19, 17)
	assignButton.BackgroundTransparency = 1
	assignButton.Font = Enum.Font.BuilderSansBold
	assignButton.Text = "+"
	assignButton.TextColor3 = Color3.fromRGB(235, 220, 190)
	assignButton.TextStrokeTransparency = 0.5
	assignButton.TextScaled = true
	assignButton.Visible = isTouch
	assignButton.ZIndex = 9
	assignButton.Parent = frame

	local assignCorner = Instance.new("UICorner")
	assignCorner.CornerRadius = UDim.new(0.15, 0)
	assignCorner.Parent = assignButton

	local cooldown = Instance.new("Frame")
	cooldown.Name = "Cooldown"
	cooldown.Size = UDim2.new(1, -2, 1, -2)
	cooldown.Position = UDim2.fromOffset(1, 1)
	cooldown.AnchorPoint = Vector2.new(0, 0)
	cooldown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cooldown.BackgroundTransparency = 0.35
	cooldown.ZIndex = 5
	cooldown.Visible = false
	cooldown.Parent = frame

	local cooldownLabel = Instance.new("TextLabel")
	cooldownLabel.Name = "CooldownLabel"
	cooldownLabel.Size = UDim2.new(1, 0, 0.3, 0)
	cooldownLabel.Position = UDim2.new(0, 0, 0.35, 0)
	cooldownLabel.BackgroundTransparency = 1
	cooldownLabel.Font = Enum.Font.BuilderSans
	cooldownLabel.TextColor3 = Color3.fromRGB(235, 220, 190)
	cooldownLabel.TextStrokeTransparency = 0.5
	cooldownLabel.TextScaled = true
	cooldownLabel.ZIndex = 6
	cooldownLabel.Parent = frame

	button.Activated:Connect(function()
		requestUse(index)
	end)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			setAssignMode(index)
		end
	end)
	assignButton.Activated:Connect(function()
		setAssignMode(index)
	end)

	frame.Parent = nil
	return {
		frame = frame,
		button = button,
		assignButton = assignButton,
		icon = icon,
		keyLabel = keyLabel,
		quantity = quantity,
		cooldown = cooldown,
		cooldownLabel = cooldownLabel,
	}
end

local container = hud:FindFirstChild("ItemUseSlotsFrame")
if not container then
	container = Instance.new("Frame")
	container.Name = "ItemUseSlotsFrame"
	container.BackgroundColor3 = Color3.fromRGB(15, 13, 11)
	container.BackgroundTransparency = 0.2
	container.BorderSizePixel = 0
	container.ClipsDescendants = false
	container.Parent = hud

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 11)
	layout.Parent = container
end

container.Size = UDim2.fromOffset(144, 76)
container.AnchorPoint = Vector2.new(0, 0.5) -- R6.11: estable también al restaurar layout manual.
container.ClipsDescendants = false

local skillBarGui = playerGui:WaitForChild("SkillBar")
local barContainer = skillBarGui:WaitForChild("BarContainer")

local function positionItemUseSlots()
	if localPlayer:GetAttribute("UILayoutEditMode") == true then return end
	if not container.Parent or barContainer.AbsoluteSize.X <= 0 then return end
	local parentSize = hud.AbsoluteSize
	if parentSize.X <= 0 or parentSize.Y <= 0 then return end
	if localPlayer:GetAttribute("UILayoutConsumableOverride") == true then
		local a, b = barContainer.AbsolutePosition, container.AbsolutePosition
		local sa, sb = barContainer.AbsoluteSize, container.AbsoluteSize
		local overlaps = a.X < b.X + sb.X and b.X < a.X + sa.X
			and a.Y < b.Y + sb.Y and b.Y < a.Y + sa.Y
		-- Conservar ubicaciones manuales válidas; reparar únicamente el solapamiento.
		if not overlaps then return end
	end
	-- Seguir el borde del contenedor, no el cuarto slot: así ambos paneles viajan juntos.
	local gap = barContainer:GetAttribute("HearthboundCombatGap") or 14
	container.AnchorPoint = Vector2.new(0, 0.5)
	container.Position = UDim2.fromScale(
		(barContainer.AbsolutePosition.X + barContainer.AbsoluteSize.X + gap - hud.AbsolutePosition.X) / parentSize.X,
		(barContainer.AbsolutePosition.Y + barContainer.AbsoluteSize.Y * 0.5 - hud.AbsolutePosition.Y) / parentSize.Y
	)
end

local anchorQueued = false
local function queueAnchor()
	if anchorQueued then return end
	anchorQueued = true
	task.defer(function()
		anchorQueued = false
		positionItemUseSlots()
	end)
end
barContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(queueAnchor)
barContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueAnchor)
container:GetPropertyChangedSignal("AbsolutePosition"):Connect(queueAnchor)
container:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueAnchor)
hud:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueAnchor)
barContainer:GetAttributeChangedSignal("HearthboundCombatGap"):Connect(positionItemUseSlots)
localPlayer:GetAttributeChangedSignal("UILayoutConsumableOverride"):Connect(positionItemUseSlots)
localPlayer:GetAttributeChangedSignal("UILayoutEditMode"):Connect(queueAnchor)
task.defer(positionItemUseSlots)

local slotLayout = container:FindFirstChildOfClass("UIListLayout")
if slotLayout then
	slotLayout.SortOrder = Enum.SortOrder.LayoutOrder
	slotLayout.Padding = UDim.new(0, 11)
end

for index = 1, 2 do
	slotViews[index] = createSlot(index)
	slotViews[index].frame.LayoutOrder = index
	slotViews[index].frame.Parent = container
end

local oldHelp = container:FindFirstChild("ItemUseHelp")
if oldHelp then oldHelp:Destroy() end

feedbackLabel = hud:FindFirstChild("ItemUseFeedback")
if not feedbackLabel then
	feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "ItemUseFeedback"
	feedbackLabel.Size = UDim2.new(0.3, 0, 0.04, 0)
	feedbackLabel.Position = UDim2.new(0.68, 0, 0.72, 0)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Font = Enum.Font.BuilderSans
	feedbackLabel.TextColor3 = Color3.fromRGB(235, 220, 190)
	feedbackLabel.TextStrokeTransparency = 0.5
	feedbackLabel.TextScaled = true
	feedbackLabel.Visible = false
	feedbackLabel.Parent = hud
end

ItemUseSlotState.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then return end
	slotState = data
	for index = 1, 2 do updateSlot(index) end
	if tonumber(data.cooldownRemaining) and data.cooldownRemaining > 0 then
		beginCooldown(data.cooldownRemaining)
	else
		cooldownEndsAt = 0
		updateCooldown()
	end
end)

InventoryResult.OnClientEvent:Connect(function(result)
	if type(result) ~= "table" or result.success then return end
	showFeedback("✗ " .. tostring(result.error or "No se pudo usar el ítem"), true)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.Z then
		requestUse(1)
	elseif input.KeyCode == Enum.KeyCode.X then
		requestUse(2)
	end
end)

for index, view in pairs(slotViews) do updateSlot(index) end
print("[Vandrheim] ItemUseSlotsClient R6.2 activo")


