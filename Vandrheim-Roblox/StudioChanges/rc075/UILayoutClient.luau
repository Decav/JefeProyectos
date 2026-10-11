--[[
	UILayoutClient — HU-R6.20 / rc062
	Editor de posición y escala del HUD. El servidor guarda el layout por personaje.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local requestSave = remotes:WaitForChild("RequestSaveUILayout")
local saveResult = remotes:WaitForChild("SaveUILayoutResult")
local MIN_SCALE, MAX_SCALE = 0.6, 2.0
local elementIds = { "PlayerFrame", "TargetFrame", "SkillBar", "ConsumableBar", "MicroMenu", "DungeonStatus", "BossBar", "PartyFrame" }
local labels = { PlayerFrame = "JUGADOR", TargetFrame = "OBJETIVO", SkillBar = "HABILIDADES",
	ConsumableBar = "CONSUMIBLES", MicroMenu = "MICRO MENÚ",
	DungeonStatus = "ESTADO MAZMORRA", BossBar = "VIDA DEL JEFE", PartyFrame = "PARTY" }
local targets = {}
local handles = {}
local scaleObjects = {}
local defaultPositions = {}
local defaultScales = {}
local savedLayout = {}
local snapshots = {}
local editing = false
local pending = false
local snapEnabled = false
local dragId = nil
local dragInput = nil
local dragStart = nil
local dragAnchor = nil
local dragMode = nil
local dragScaleStart = nil
local dragSizeStart = nil
local renderConnection = nil
local previousMouseBehavior = nil
local previousMouseIconEnabled = nil
local previousConsumableOverride = false
local dungeonHud = nil
local previousDungeonEnabled = false
local previousDungeonChildren = {}
local previousBossVisible = false
local previousFloorText = nil

local editGui = Instance.new("ScreenGui")
editGui.Name = "EditLayoutUI"
editGui.ResetOnSpawn = false
editGui.IgnoreGuiInset = true
editGui.DisplayOrder = 1000
editGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
editGui.Enabled = false
editGui.Parent = playerGui

local function createFrame(name, x, y, width, height, color, transparency, zIndex)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = UDim2.fromScale(x, y)
	frame.Size = UDim2.fromScale(width, height)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = transparency
	frame.BorderSizePixel = 0
	frame.Active = false
	frame.ZIndex = zIndex
	frame.Parent = editGui
	return frame
end

createFrame("Dimmer", 0, 0, 1, 1, Color3.fromRGB(7, 5, 4), 0.55, 1)
local gridColor = Color3.fromRGB(200, 148, 69)
createFrame("CenterVertical", 0.4995, 0, 0.001, 1, gridColor, 0.25, 2)
createFrame("CenterHorizontal", 0, 0.499, 1, 0.002, gridColor, 0.25, 2)
for _, value in ipairs({ 1/3, 2/3 }) do
	createFrame("ThirdVertical", value, 0, 0.0007, 1, gridColor, 0.72, 2)
	createFrame("ThirdHorizontal", 0, value, 1, 0.001, gridColor, 0.72, 2)
end

local function textButton(name, text, position, size, parent)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	button.TextColor3 = Color3.fromRGB(244, 237, 224)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.BorderSizePixel = 0
	button.ZIndex = 12
	button.Parent = parent or editGui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button
	local stroke = Instance.new("UIStroke")
	stroke.Color = gridColor
	stroke.Thickness = 1
	stroke.Parent = button
	return button
end

local title = Instance.new("TextLabel")
title.Name = "EditTitle"
title.Position = UDim2.fromScale(0.02, 0.015)
title.Size = UDim2.fromScale(0.38, 0.045)
title.BackgroundTransparency = 1
title.Text = "ORDENAR UI  ·  MOVER Y ESCALAR"
title.TextColor3 = Color3.fromRGB(244, 237, 224)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12
title.Parent = editGui

local guide = Instance.new("TextLabel")
guide.Name = "Guide"
guide.Position = UDim2.fromScale(0.02, 0.955)
guide.Size = UDim2.fromScale(0.78, 0.03)
guide.BackgroundTransparency = 1
guide.Text = "ARRASTRA: MOVER  ·  ESQUINA ↘: ESCALAR  ·  ESC: SALIR"
guide.TextColor3 = Color3.fromRGB(200, 148, 69)
guide.Font = Enum.Font.Code
guide.TextScaled = true
guide.TextXAlignment = Enum.TextXAlignment.Left
guide.ZIndex = 12
guide.Parent = editGui

local restoreButton = textButton("RestoreButton", "RESTAURAR", UDim2.fromScale(0.42, 0.02), UDim2.fromScale(0.18, 0.055))
local snapButton = textButton("SnapButton", "SNAP: NO", UDim2.fromScale(0.62, 0.02), UDim2.fromScale(0.12, 0.055))
local doneButton = textButton("DoneButton", "LISTO", UDim2.fromScale(0.76, 0.02), UDim2.fromScale(0.10, 0.055))
local cancelButton = textButton("CancelButton", "SALIR", UDim2.fromScale(0.87, 0.02), UDim2.fromScale(0.09, 0.055))

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromScale(0.48, 0.085)
status.Size = UDim2.fromScale(0.5, 0.04)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(244, 237, 224)
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.TextXAlignment = Enum.TextXAlignment.Right
status.ZIndex = 12
status.Parent = editGui

local confirmation = createFrame("ExitConfirmation", 0.35, 0.39, 0.30, 0.20,
	Color3.fromRGB(23, 19, 17), 0, 20)
confirmation.Visible = false
local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.fromScale(0.9, 0.38)
confirmText.Position = UDim2.fromScale(0.05, 0.08)
confirmText.BackgroundTransparency = 1
confirmText.Text = "¿Guardar cambios antes de salir?"
confirmText.TextColor3 = Color3.fromRGB(244, 237, 224)
confirmText.Font = Enum.Font.GothamBold
confirmText.TextScaled = true
confirmText.ZIndex = 21
confirmText.Parent = confirmation
local saveExit = textButton("SaveExit", "GUARDAR", UDim2.fromScale(0.04, 0.56), UDim2.fromScale(0.29, 0.29), confirmation)
local discardExit = textButton("DiscardExit", "DESCARTAR", UDim2.fromScale(0.355, 0.56), UDim2.fromScale(0.29, 0.29), confirmation)
local keepEditing = textButton("KeepEditing", "VOLVER", UDim2.fromScale(0.67, 0.56), UDim2.fromScale(0.29, 0.29), confirmation)
for _, button in ipairs({ saveExit, discardExit, keepEditing }) do button.ZIndex = 22 end

local function applyEditorResponsive()
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local compact = UserInputService.TouchEnabled or viewport.X < 900
	if compact then
		title.Position = UDim2.fromScale(0.04, 0.025)
		title.Size = UDim2.fromScale(0.92, 0.045)
		restoreButton.Position = UDim2.fromScale(0.04, 0.085)
		restoreButton.Size = UDim2.fromScale(0.20, 0.065)
		snapButton.Position = UDim2.fromScale(0.28, 0.085)
		snapButton.Size = UDim2.fromScale(0.20, 0.065)
		doneButton.Position = UDim2.fromScale(0.52, 0.085)
		doneButton.Size = UDim2.fromScale(0.20, 0.065)
		cancelButton.Position = UDim2.fromScale(0.76, 0.085)
		cancelButton.Size = UDim2.fromScale(0.20, 0.065)
		status.Position = UDim2.fromScale(0.04, 0.16)
		status.Size = UDim2.fromScale(0.92, 0.04)
		confirmation.Position = UDim2.fromScale(0.08, 0.37)
		confirmation.Size = UDim2.fromScale(0.84, 0.26)
	else
		title.Position = UDim2.fromScale(0.02, 0.015)
		title.Size = UDim2.fromScale(0.38, 0.045)
		restoreButton.Position = UDim2.fromScale(0.42, 0.02)
		restoreButton.Size = UDim2.fromScale(0.18, 0.055)
		snapButton.Position = UDim2.fromScale(0.62, 0.02)
		snapButton.Size = UDim2.fromScale(0.12, 0.055)
		doneButton.Position = UDim2.fromScale(0.76, 0.02)
		doneButton.Size = UDim2.fromScale(0.10, 0.055)
		cancelButton.Position = UDim2.fromScale(0.87, 0.02)
		cancelButton.Size = UDim2.fromScale(0.09, 0.055)
		status.Position = UDim2.fromScale(0.48, 0.085)
		status.Size = UDim2.fromScale(0.5, 0.04)
		confirmation.Position = UDim2.fromScale(0.35, 0.39)
		confirmation.Size = UDim2.fromScale(0.30, 0.20)
	end
end
applyEditorResponsive()

local function viewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function normalizeScale(value)
	if type(value) ~= "number" or value ~= value
		or value == math.huge or value == -math.huge then
		return 1
	end
	return math.clamp(value, MIN_SCALE, MAX_SCALE)
end

local function ensureScaleObject(target)
	local scaleObject = target:FindFirstChild("UILayoutUserScale")
	if not scaleObject or not scaleObject:IsA("UIScale") then
		scaleObject = Instance.new("UIScale")
		scaleObject.Name = "UILayoutUserScale"
		scaleObject.Scale = 1
		scaleObject.Parent = target
	end
	return scaleObject
end

local function fitScale(target, desiredScale, baseSize)
	if not baseSize then
		local scaleObject = target:FindFirstChild("UILayoutUserScale")
		local currentScale = scaleObject and math.max(scaleObject.Scale, 0.001) or 1
		baseSize = target.AbsoluteSize / currentScale
	end
	local viewport = viewportSize()
	local topLeft, bottomRight = GuiService:GetGuiInset()
	topLeft = topLeft or Vector2.zero
	bottomRight = bottomRight or Vector2.zero
	local margin = 8
	local availableWidth = math.max(1, viewport.X - topLeft.X - bottomRight.X - margin * 2)
	local availableHeight = math.max(1, viewport.Y - topLeft.Y - bottomRight.Y - margin * 2)
	local fitLimit = math.min(availableWidth / math.max(1, baseSize.X),
		availableHeight / math.max(1, baseSize.Y))
	local upperBound = math.max(MIN_SCALE, math.min(MAX_SCALE, fitLimit))
	return math.clamp(normalizeScale(desiredScale), MIN_SCALE, upperBound)
end

local function clampPosition(target, x, y)
	local viewport = viewportSize()
	local topLeft, bottomRight = GuiService:GetGuiInset()
	topLeft = topLeft or Vector2.zero
	bottomRight = bottomRight or Vector2.zero
	local margin = 8
	-- AbsolutePosition de HUD/SkillBar ya está relativo al área bajo el inset
	-- superior. Sumarlo arriba desplazaría los bloques dos veces.
	local left = (margin + target.AbsoluteSize.X * target.AnchorPoint.X) / viewport.X
	local right = 1 - (topLeft.X + bottomRight.X + margin
		+ target.AbsoluteSize.X * (1-target.AnchorPoint.X)) / viewport.X
	local top = (margin + target.AbsoluteSize.Y * target.AnchorPoint.Y) / viewport.Y
	local bottom = 1 - (topLeft.Y + bottomRight.Y + margin
		+ target.AbsoluteSize.Y * (1-target.AnchorPoint.Y)) / viewport.Y
	return math.clamp(x, math.min(left,right), math.max(left,right)),
		math.clamp(y, math.min(top,bottom), math.max(top,bottom))
end

local function actualAnchor(target)
	local viewport = viewportSize()
	return Vector2.new(
		(target.AbsolutePosition.X + target.AbsoluteSize.X * target.AnchorPoint.X) / viewport.X,
		(target.AbsolutePosition.Y + target.AbsoluteSize.Y * target.AnchorPoint.Y) / viewport.Y
	)
end

local function screenToScale(target, x, y)
	local viewport = viewportSize()
	local currentAnchor = actualAnchor(target)
	local originX = currentAnchor.X * viewport.X
		- target.Position.X.Scale * viewport.X - target.Position.X.Offset
	local originY = currentAnchor.Y * viewport.Y
		- target.Position.Y.Scale * viewport.Y - target.Position.Y.Offset
	return (x * viewport.X - originX) / viewport.X,
		(y * viewport.Y - originY) / viewport.Y
end

local function setAnchor(target, x, y)
	local safeX, safeY = clampPosition(target, x, y)
	local scaleX, scaleY = screenToScale(target, safeX, safeY)
	target.Position = UDim2.fromScale(scaleX, scaleY)
end

local function syncHandles()
	local viewport = viewportSize()
	local overlayOrigin = editGui.Dimmer.AbsolutePosition
	for id, target in pairs(targets) do
		local handle = handles[id]
		if handle and target.Parent then
			handle.Position = UDim2.fromScale(
				(target.AbsolutePosition.X - overlayOrigin.X) / viewport.X,
				(target.AbsolutePosition.Y - overlayOrigin.Y) / viewport.Y)
			handle.Size = UDim2.fromScale(target.AbsoluteSize.X / viewport.X,
				target.AbsoluteSize.Y / viewport.Y)
			handle.Visible = editing and (id ~= "PartyFrame" or target.Visible)
		end
	end
end

local function makeHandle(id, target)
	local handle = Instance.new("Frame")
	handle.Name = id .. "Handle"
	handle.Position = UDim2.fromScale(0, 0)
	handle.Size = UDim2.fromScale(0.1, 0.1)
	handle.BackgroundColor3 = Color3.fromRGB(200, 148, 69)
	handle.BackgroundTransparency = (id == "DungeonStatus" or id == "BossBar") and 0.68 or 0.88
	handle.BorderSizePixel = 0
	handle.Active = true
	handle.ZIndex = 5
	handle.Visible = false
	handle.Parent = editGui
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(226, 174, 83)
	border.Thickness = 2
	border.Parent = handle
	local label = Instance.new("TextLabel")
	label.Name = "DragCaption"
	label.Position = UDim2.fromScale(0.02, 0.03)
	label.Size = (id == "DungeonStatus" or id == "BossBar")
		and UDim2.fromScale(0.96, 0.42) or UDim2.fromScale(0.72, 0.28)
	label.BackgroundColor3 = Color3.fromRGB(23, 19, 17)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Text = labels[id]
	label.TextColor3 = Color3.fromRGB(244, 237, 224)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextScaled = false
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Active = false
	label.ZIndex = 6
	label.Parent = handle

	local resizeGrip = Instance.new("TextButton")
	resizeGrip.Name = "ResizeGrip"
	resizeGrip.AnchorPoint = Vector2.new(1, 1)
	resizeGrip.Position = UDim2.fromScale(1, 1)
	resizeGrip.Size = UDim2.fromScale(0.22, 0.28)
	resizeGrip.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	resizeGrip.BackgroundTransparency = 0.05
	resizeGrip.Text = "↘"
	resizeGrip.TextColor3 = Color3.fromRGB(244, 237, 224)
	resizeGrip.Font = Enum.Font.GothamBold
	resizeGrip.TextScaled = true
	resizeGrip.AutoButtonColor = false
	resizeGrip.Selectable = false
	resizeGrip.ZIndex = 8
	resizeGrip.Parent = handle
	local gripConstraint = Instance.new("UISizeConstraint")
	gripConstraint.MinSize = Vector2.new(32, 32)
	gripConstraint.MaxSize = Vector2.new(54, 54)
	gripConstraint.Parent = resizeGrip
	local gripCorner = Instance.new("UICorner")
	gripCorner.CornerRadius = UDim.new(0.2, 0)
	gripCorner.Parent = resizeGrip
	local gripStroke = Instance.new("UIStroke")
	gripStroke.Color = Color3.fromRGB(226, 174, 83)
	gripStroke.Thickness = 1
	gripStroke.Parent = resizeGrip
	handles[id] = handle

	local function beginDrag(input, mode)
		if not editing or pending or confirmation.Visible then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragId = id
		dragInput = input
		dragMode = mode
		dragStart = Vector2.new(input.Position.X, input.Position.Y)
		dragAnchor = actualAnchor(target)
		dragScaleStart = scaleObjects[id] and scaleObjects[id].Scale or 1
		dragSizeStart = target.AbsoluteSize
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local point = Vector2.new(input.Position.X, input.Position.Y)
		local gripPosition = resizeGrip.AbsolutePosition
		local gripSize = resizeGrip.AbsoluteSize
		local overGrip = point.X >= gripPosition.X and point.X <= gripPosition.X + gripSize.X
			and point.Y >= gripPosition.Y and point.Y <= gripPosition.Y + gripSize.Y
		beginDrag(input, overGrip and "scale" or "move")
	end)
	resizeGrip.InputBegan:Connect(function(input)
		beginDrag(input, "scale")
	end)
end

local function bindTargets()
	local hud = playerGui:WaitForChild("HUD")
	local skillGui = playerGui:WaitForChild("SkillBar")
	targets.PlayerFrame = hud:WaitForChild("PlayerFrame")
	targets.TargetFrame = hud:WaitForChild("TargetFrame")
	targets.SkillBar = skillGui:WaitForChild("BarContainer")
	targets.ConsumableBar = hud:WaitForChild("ItemUseSlotsFrame")
	dungeonHud = playerGui:WaitForChild("DungeonHUD")
	targets.DungeonStatus = dungeonHud:WaitForChild("TopBar")
	targets.BossBar = hud:WaitForChild("BossBar")
	targets.PartyFrame = playerGui:WaitForChild("PartyUI"):WaitForChild("PartyHUD")
	if UserInputService.TouchEnabled then
		targets.MicroMenu = playerGui:WaitForChild("MobileAccessUI"):WaitForChild("MobileAccessStack")
	else
		targets.MicroMenu = playerGui:WaitForChild("MicroMenuUI"):WaitForChild("MicroMenuBar")
	end
	task.wait(0.3)
	for _, id in ipairs(elementIds) do
		local target = targets[id]
		if target then
			scaleObjects[id] = ensureScaleObject(target)
			defaultPositions[id] = target.Position
			defaultScales[id] = 1
			makeHandle(id, target)
		end
	end
end

local function applySaved()
	if editing then return end
	player:SetAttribute("UILayoutConsumableOverride", savedLayout.ConsumableBar ~= nil)
	player:SetAttribute("UILayoutPartyFrameManaged", savedLayout.PartyFrame ~= nil)
	for _, id in ipairs(elementIds) do
		local target = targets[id]
		if target then
			local baseSize
			if scaleObjects[id] then
				local currentScale = math.max(scaleObjects[id].Scale, 0.001)
				baseSize = target.AbsoluteSize / currentScale
				scaleObjects[id].Scale = 1
			end
			if defaultPositions[id] then target.Position = defaultPositions[id] end
			local point = savedLayout[id]
			if type(point) == "table" then
				if scaleObjects[id] then scaleObjects[id].Scale = fitScale(target, point.scale, baseSize) end
				if type(point.x) == "number" and type(point.y) == "number" then
					-- El perfil almacena UDim2.Scale. Reaplicarlo como ancla de pantalla
					-- sumaba el inset en cada guardado y desplazaba el HUD.
					target.Position = UDim2.fromScale(point.x, point.y)
					local anchor = actualAnchor(target)
					setAnchor(target, anchor.X, anchor.Y)
				end
			end
		end
	end
end

local function readLayoutAttribute()
	local raw = player:GetAttribute("UILayoutData")
	local decoded = {}
	if type(raw) == "string" then
		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok and type(data) == "table" then decoded = data end
	end
	savedLayout = decoded
	player:SetAttribute("UILayoutManaged", next(savedLayout) ~= nil)
	player:SetAttribute("UILayoutPartyFrameManaged", savedLayout.PartyFrame ~= nil)
	task.defer(applySaved)
end

local function restoreConditionalPreviews()
	if dungeonHud then
		for child, wasVisible in pairs(previousDungeonChildren) do
			if child.Parent then child.Visible = wasVisible end
		end
		dungeonHud.Enabled = previousDungeonEnabled
	end
	previousDungeonChildren = {}
	local floorLabel = targets.DungeonStatus and targets.DungeonStatus:FindFirstChild("FloorLabel")
	if floorLabel and previousFloorText ~= nil then floorLabel.Text = previousFloorText end
	previousFloorText = nil
	if targets.BossBar then targets.BossBar.Visible = previousBossVisible end
end

local function exitEditor(discard)
	if not editing then return end
	if discard then
		for id, snapshot in pairs(snapshots) do
			if targets[id] then
				targets[id].Position = snapshot.position
				if scaleObjects[id] then scaleObjects[id].Scale = snapshot.scale end
			end
		end
		player:SetAttribute("UILayoutConsumableOverride", previousConsumableOverride)
	end
	editing = false
	pending = false
	dragId = nil
	dragInput = nil
	dragMode = nil
	dragScaleStart = nil
	dragSizeStart = nil
	restoreConditionalPreviews()
	confirmation.Visible = false
	editGui.Enabled = false
	if renderConnection then renderConnection:Disconnect(); renderConnection = nil end
	ContextActionService:UnbindAction("R611ExitLayout")
	player:SetAttribute("UILayoutEditMode", false)
	player:SetAttribute("UILayoutManaged", next(savedLayout) ~= nil)
	player:SetAttribute("UILayoutPartyFrameManaged", savedLayout.PartyFrame ~= nil)
	player:SetAttribute("UIWindowOpen", false)
	UserInputService.MouseBehavior = previousMouseBehavior or Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = previousMouseIconEnabled ~= false
end

local function requestExit()
	if not editing or pending then return end
	confirmation.Visible = true
end

local function buildCurrentLayout()
	local layout = {}
	for _, id in ipairs(elementIds) do
		local target = targets[id]
		local shouldSaveParty = id ~= "PartyFrame" or (target and target.Visible)
			or savedLayout.PartyFrame ~= nil
		if target and shouldSaveParty then
			local point = actualAnchor(target)
			local x, y = clampPosition(target, point.X, point.Y)
			local scaleX, scaleY = screenToScale(target, x, y)
			layout[id] = {
				x = math.clamp(scaleX, 0, 1),
				y = math.clamp(scaleY, 0, 1),
				scale = normalizeScale(scaleObjects[id] and scaleObjects[id].Scale or 1),
			}
		end
	end
	return layout
end

local function saveAndExit()
	if not editing or pending then return end
	pending = true
	status.Text = "Guardando layout..."
	confirmation.Visible = false
	requestSave:FireServer({ layout = buildCurrentLayout() })
end

local function enterEditor()
	if editing or not targets.PlayerFrame or player:GetAttribute("CharacterName") == nil then return end
	editing = true
	pending = false
	snapEnabled = false
	snapButton.Text = "SNAP: NO"
	status.Text = ""
	confirmation.Visible = false
	snapshots = {}
	for id, target in pairs(targets) do
		snapshots[id] = {
			position = target.Position,
			scale = scaleObjects[id] and scaleObjects[id].Scale or 1,
		}
	end
	previousDungeonEnabled = dungeonHud.Enabled
	previousDungeonChildren = {}
	if not previousDungeonEnabled then
		for _, child in ipairs(dungeonHud:GetChildren()) do
			if child:IsA("GuiObject") and child ~= targets.DungeonStatus then
				previousDungeonChildren[child] = child.Visible
				child.Visible = false
			end
		end
		dungeonHud.Enabled = true
	end
	local floorLabel = targets.DungeonStatus:FindFirstChild("FloorLabel")
	previousFloorText = floorLabel and floorLabel.Text or nil
	if floorLabel and (floorLabel.Text == "" or not previousDungeonEnabled) then
		floorLabel.Text = "PISO 1/5 · MAZMORRA"
	end
	previousBossVisible = targets.BossBar.Visible
	targets.BossBar.Visible = true
	previousConsumableOverride = player:GetAttribute("UILayoutConsumableOverride") == true
	player:SetAttribute("UILayoutConsumableOverride", true)
	player:SetAttribute("UILayoutEditMode", true)
	player:SetAttribute("UILayoutManaged", true)
	player:SetAttribute("UILayoutPartyFrameManaged", savedLayout.PartyFrame ~= nil
		or (targets.PartyFrame and targets.PartyFrame.Visible == true))
	player:SetAttribute("UIWindowOpen", true)
	if remotes:FindFirstChild("SetTarget") then remotes.SetTarget:FireServer(nil) end
	previousMouseBehavior = UserInputService.MouseBehavior
	previousMouseIconEnabled = UserInputService.MouseIconEnabled
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	editGui.Enabled = true
	-- Los HUD condicionales se previsualizan por separado y dentro del área
	-- visible aun cuando todavía no hay una run ni un encuentro de jefe.
	if not previousDungeonEnabled and not savedLayout.DungeonStatus then
		targets.DungeonStatus.Position = UDim2.fromScale(0.375, 0.18)
	end
	if not previousBossVisible and not savedLayout.BossBar then
		targets.BossBar.Position = UDim2.fromScale(0.5, 0.29)
	end
	ContextActionService:BindActionAtPriority("R611ExitLayout", function(_, state)
		if state == Enum.UserInputState.Begin then requestExit() end
		return Enum.ContextActionResult.Sink
	end, false, 3000, Enum.KeyCode.Escape)
	renderConnection = RunService.RenderStepped:Connect(syncHandles)
	syncHandles()
end

restoreButton.Activated:Connect(function()
	if not editing or pending or confirmation.Visible then return end
	dragId = nil
	dragInput = nil
	dragMode = nil
	for _, id in ipairs(elementIds) do
		local target = targets[id]
		if target then
			if defaultPositions[id] then target.Position = defaultPositions[id] end
			if scaleObjects[id] then
				scaleObjects[id].Scale = fitScale(target, defaultScales[id] or 1)
			end
		end
	end
	status.Text = "Posición y escala restauradas; pulsa LISTO para guardar."
end)
snapButton.Activated:Connect(function()
	snapEnabled = not snapEnabled
	snapButton.Text = snapEnabled and "SNAP: SÍ" or "SNAP: NO"
end)
doneButton.Activated:Connect(saveAndExit)
cancelButton.Activated:Connect(requestExit)
saveExit.Activated:Connect(saveAndExit)
discardExit.Activated:Connect(function() exitEditor(true) end)
keepEditing.Activated:Connect(function() confirmation.Visible = false end)

UserInputService.InputChanged:Connect(function(input)
	if not editing or not dragId or not dragStart or not dragAnchor then return end
	if dragInput.UserInputType == Enum.UserInputType.Touch then
		if input ~= dragInput then return end
	elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end
	local viewport = viewportSize()
	local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
	local target = targets[dragId]
	if dragMode == "scale" then
		local diagonal = math.max(1, dragSizeStart.X + dragSizeStart.Y)
		local nextScale = fitScale(target,
			dragScaleStart * (1 + (delta.X + delta.Y) / diagonal))
		local point = actualAnchor(target)
		scaleObjects[dragId].Scale = nextScale
		setAnchor(target, point.X, point.Y)
		status.Text = string.format("%s  ESCALA %.0f%%  (%.0f–%.0f%%)",
			labels[dragId], nextScale * 100, MIN_SCALE * 100, MAX_SCALE * 100)
	else
		setAnchor(target, dragAnchor.X + delta.X / viewport.X,
			dragAnchor.Y + delta.Y / viewport.Y)
		local point = actualAnchor(target)
		status.Text = string.format("%s  X %.0f%%  Y %.0f%%  ESCALA %.0f%%",
			labels[dragId], point.X * 100, point.Y * 100,
			scaleObjects[dragId].Scale * 100)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if not dragId then return end
	if input ~= dragInput and not (dragInput.UserInputType == Enum.UserInputType.MouseButton1
		and input.UserInputType == Enum.UserInputType.MouseButton1) then return end
	if dragMode == "move" and snapEnabled and targets[dragId] then
		local point = actualAnchor(targets[dragId])
		local viewport = viewportSize()
		local overlayOrigin = editGui.Dimmer.AbsolutePosition
		local function snap(value)
			for _, guideValue in ipairs({ 1/3, 0.5, 2/3 }) do
				if math.abs(value - guideValue) <= 0.025 then return guideValue end
			end
			return value
		end
		local overlayX = point.X - overlayOrigin.X / viewport.X
		local overlayY = point.Y - overlayOrigin.Y / viewport.Y
		setAnchor(targets[dragId],
			snap(overlayX) + overlayOrigin.X / viewport.X,
			snap(overlayY) + overlayOrigin.Y / viewport.Y)
	end
	dragId = nil
	dragInput = nil
	dragMode = nil
	dragScaleStart = nil
	dragSizeStart = nil
end)

saveResult.OnClientEvent:Connect(function(result)
	if not pending then return end
	pending = false
	if type(result) == "table" and result.success == true then
		savedLayout = type(result.layout) == "table" and result.layout or buildCurrentLayout()
		player:SetAttribute("UILayoutConsumableOverride", true)
		player:SetAttribute("UILayoutPartyFrameManaged", savedLayout.PartyFrame ~= nil)
		status.Text = "Layout guardado"
		exitEditor(false)
	else
		status.Text = tostring(type(result) == "table" and result.error or "No se pudo guardar")
	end
end)

player:GetAttributeChangedSignal("UILayoutEditRequest"):Connect(enterEditor)
player:GetAttributeChangedSignal("UILayoutData"):Connect(readLayoutAttribute)
player:GetAttributeChangedSignal("CharacterSelectionMode"):Connect(function()
	if player:GetAttribute("CharacterSelectionMode") == true and editing then exitEditor(true) end
end)
local viewportConnection
local function refreshViewport()
		applyEditorResponsive()
		task.delay(0.15, applySaved)
end
local function bindViewport()
	if viewportConnection then viewportConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshViewport) end
	refreshViewport()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()
task.spawn(function()
	bindTargets()
	readLayoutAttribute()
end)
print("[Vandrheim] UILayoutClient R6.20 activo")
