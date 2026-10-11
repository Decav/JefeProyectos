--[[
	WindowLayoutClient — HU-R6.11 / rc043
	Posiciones de apertura y arrastre temporal de ventanas; no persiste en perfil.
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BackpackUIConfig = require(ReplicatedStorage.Config:WaitForChild("BackpackUIConfig"))local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local windowSpecs = {
	{ gui = "InventoryUI", x = 0.5, y = 0.5 }, -- rc086: presentation owns the 500:484 responsive size.
	-- rc085: InventoryPresentationClient sizes HUMWS to its 480:455 ratio.
	{ gui = "EquipmentUI" },
	{ gui = "TalentUI", x = 0.5, y = 0.5 },
	{ gui = "SpellbookUI", x = 0.5, y = 0.5 },
	{ gui = "VendorUI", x = 0.5, y = 0.5 },
}
local focused = {}
local trackedFrames = {}
local queued = false
local cameraConnection

local function focusWindow(gui)
	local previous = table.find(focused, gui)
	if previous then table.remove(focused, previous) end
	table.insert(focused, gui)
	for index, window in ipairs(focused) do
		if window.Parent then window.DisplayOrder = 60 + index end
	end
end

local function setPosition(frame, x, y)
	local parent = frame.Parent
	if not parent or parent.AbsoluteSize.X <= 0 or parent.AbsoluteSize.Y <= 0 then return end
	local fraction = frame.AbsoluteSize / parent.AbsoluteSize
	local left = 0.015 + fraction.X * frame.AnchorPoint.X
	local right = 0.985 - fraction.X * (1 - frame.AnchorPoint.X)
	local top = 0.015 + fraction.Y * frame.AnchorPoint.Y
	local bottom = 0.985 - fraction.Y * (1 - frame.AnchorPoint.Y)
	frame.Position = UDim2.fromScale(
		left <= right and math.clamp(x, left, right) or 0.5,
		top <= bottom and math.clamp(y, top, bottom) or 0.5)
end

local function syncUiFlag()
	if queued then return end
	queued = true
	task.defer(function()
		queued = false
		local anyOpen = player:GetAttribute("UILayoutEditMode") == true
		for _, spec in ipairs(windowSpecs) do
			local gui = playerGui:FindFirstChild(spec.gui)
			local frame = gui and gui:FindFirstChild("MainFrame")
			if gui and gui.Enabled and frame and frame.Visible then anyOpen = true end
		end
		local menu = playerGui:FindFirstChild("MenuUI")
		if menu and menu.Enabled then anyOpen = true end
		local matchmaking = playerGui:FindFirstChild("MatchmakingUI")
		local portal = matchmaking and matchmaking:FindFirstChild("PortalWindow")
		if matchmaking then matchmaking.DisplayOrder = portal and portal.Visible and 75 or 5 end
		for guiName, names in pairs({
			PartyUI = { "PartyWindow", "InvitePopup" },
			MatchmakingUI = { "PortalWindow" },
			DungeonHUD = { "ConfirmDialog", "RunEndedNotice" },
		}) do
			local gui = playerGui:FindFirstChild(guiName)
			if gui and gui.Enabled then
				for _, name in ipairs(names) do
					local frame = gui:FindFirstChild(name)
					if frame and frame.Visible then anyOpen = true end
				end
			end
		end
		local party = playerGui:FindFirstChild("PartyUI")
		if party then
			local invite = party:FindFirstChild("InvitePopup")
			local window = party:FindFirstChild("PartyWindow")
			party.DisplayOrder = invite and invite.Visible and 130
				or (window and window.Visible and 85 or 6)
		end
		player:SetAttribute("UIWindowOpen", anyOpen)
	end)
end

local function containWindows()
	task.defer(function()
		for frame, gui in pairs(trackedFrames) do
			if frame.Parent and gui.Enabled then
				local close = frame:FindFirstChild("CloseButton")
				if close and frame.AbsoluteSize.X > 0 and frame.AbsoluteSize.Y > 0 then
					if gui.Name == "InventoryUI" then
						local touch = UserInputService.TouchEnabled
						local scaleFactor = math.min(frame.AbsoluteSize.X / BackpackUIConfig.DesignWidth, frame.AbsoluteSize.Y / BackpackUIConfig.DesignHeight)
						local faceWidth = BackpackUIConfig.Close.FaceWidth * scaleFactor
						local faceHeight = BackpackUIConfig.Close.FaceHeight * scaleFactor
						local hitWidth = touch and math.max(BackpackUIConfig.Close.MinimumTouchTarget, faceWidth) or faceWidth
						local hitHeight = touch and math.max(BackpackUIConfig.Close.MinimumTouchTarget, faceHeight) or faceHeight
						close.AnchorPoint = Vector2.new(0.5, 0.5)
						close.Size = UDim2.fromOffset(hitWidth, hitHeight)
						close.Position = UDim2.fromScale(BackpackUIConfig.Close.CenterX / BackpackUIConfig.DesignWidth, BackpackUIConfig.Close.CenterY / BackpackUIConfig.DesignHeight)
						close.BackgroundTransparency = 1
						close.Text = ""
						close.ZIndex = frame.ZIndex + 10
						local face = close:FindFirstChild("EST43CloseFace")
						if not face then
							face = Instance.new("Frame")
							face.Name = "EST43CloseFace"
							face.Parent = close
							local corner = Instance.new("UICorner")
							corner.CornerRadius = UDim.new(BackpackUIConfig.Close.FaceCornerRadius / BackpackUIConfig.Close.FaceHeight, 0)
							corner.Parent = face
							local stroke = Instance.new("UIStroke")
							stroke.Name = "EST43Stroke"
							stroke.Parent = face
							local glyph = Instance.new("TextLabel")
							glyph.Name = "Glyph"
							glyph.BackgroundTransparency = 1
							glyph.Size = UDim2.fromScale(1, 1)
							glyph.Text = BackpackUIConfig.Text.CloseGlyph
							glyph.TextColor3 = BackpackUIConfig.Colors.Parchment
							glyph.Font = BackpackUIConfig.Fonts.Bold
							glyph.Parent = face
						end
						face.AnchorPoint = Vector2.new(0.5, 0.5)
						face.Position = UDim2.fromScale(0.5, 0.5)
						face.Size = UDim2.new(faceWidth / hitWidth, 0, faceHeight / hitHeight, 0)
						face.BackgroundColor3 = BackpackUIConfig.Colors.Close
						face.BorderSizePixel = 0
						face.ZIndex = close.ZIndex + 1
						local stroke = face:FindFirstChild("EST43Stroke")
						if stroke then stroke.Color = BackpackUIConfig.Colors.FrameStroke; stroke.Thickness = math.max(1, scaleFactor) end
						local glyph = face:FindFirstChild("Glyph")
						if glyph then glyph.TextSize = math.max(9, math.floor(BackpackUIConfig.TextSizes.Close * scaleFactor + 0.5)); glyph.ZIndex = face.ZIndex + 1 end
						local handle = frame:FindFirstChild("R611DragHandle")
						if handle then handle.Position = UDim2.fromScale(BackpackUIConfig.Close.DragHandleX, BackpackUIConfig.Close.DragHandleY); handle.Size = UDim2.fromScale(BackpackUIConfig.Close.DragHandleWidth, BackpackUIConfig.Close.DragHandleHeight); handle.ZIndex = frame.ZIndex + 8 end
					elseif gui.Name == "EquipmentUI" then
						local touch = UserInputService.TouchEnabled
						local scaleFactor = frame.AbsoluteSize.X / 480
						local faceWidth = 22 * scaleFactor
						local faceHeight = 22 * scaleFactor
						local hitWidth = touch and math.max(44, faceWidth) or faceWidth
						local hitHeight = touch and math.max(44, faceHeight) or faceHeight
						close.AnchorPoint = Vector2.new(0.5, 0.5)
						close.Size = UDim2.fromOffset(hitWidth, hitHeight)
						close.Position = UDim2.fromScale((448 + 11) / 480, (10 + 11) / 455)
						close.ZIndex = frame.ZIndex + 10
						local face = close:FindFirstChild("EST45CloseFace")
						if face then
							face.AnchorPoint = Vector2.new(0.5, 0.5)
							face.Position = UDim2.fromScale(0.5, 0.5)
							face.Size = UDim2.fromScale(faceWidth / hitWidth, faceHeight / hitHeight)
							local glyph = face:FindFirstChild("Glyph")
							if glyph then glyph.TextSize = math.max(9, math.floor(12 * scaleFactor + 0.5)) end
						end
						local handle = frame:FindFirstChild("R611DragHandle")
						if handle then
							handle.Position = UDim2.fromScale(0.02, 0.008)
							handle.Size = UDim2.fromScale(0.89, 0.075)
							handle.ZIndex = frame.ZIndex + 8
						end
					elseif gui.Name == "TalentUI" then
					elseif gui.Name == "SpellbookUI" then
						local closeSize = 32
						local width = closeSize / frame.AbsoluteSize.X
						local height = closeSize / frame.AbsoluteSize.Y
						close.AnchorPoint = Vector2.zero
						close.Size = UDim2.fromScale(width, height)
						close.Position = UDim2.fromScale(0.976 - width, 0.016)
						local handle = frame:FindFirstChild("R611DragHandle")
						if handle then handle.Size = UDim2.fromScale(math.max(0.1, math.min(0.85, close.Position.X.Scale - 0.04)), 0.115) end
					else
						local minimum = UserInputService.TouchEnabled and 44 or 30
						local width = minimum / frame.AbsoluteSize.X
						local height = minimum / frame.AbsoluteSize.Y
						close.AnchorPoint = Vector2.zero
						close.Size = UDim2.fromScale(width, height)
						close.Position = UDim2.fromScale(0.97 - width, 0.03)
						local handle = frame:FindFirstChild("R611DragHandle")
						if handle then handle.Size = UDim2.fromScale(math.max(0.1, math.min(0.85, close.Position.X.Scale - 0.04)), 0.11) end
					end
				end
				setPosition(frame, frame.Position.X.Scale, frame.Position.Y.Scale)
			end
		end
	end)
end

local function attachWindow(spec)
	local gui = playerGui:WaitForChild(spec.gui)
	local frame = gui:WaitForChild("MainFrame")
	trackedFrames[frame] = gui
	frame:GetPropertyChangedSignal("Visible"):Connect(syncUiFlag)
	local handle = frame:FindFirstChild("R611DragHandle")
	if not handle then
		handle = Instance.new("Frame")
		handle.Name = "R611DragHandle"
		handle.BackgroundTransparency = 1
		handle.BorderSizePixel = 0
		handle.Position = UDim2.fromScale(0.03, 0.01)
		handle.Size = UDim2.fromScale(0.85, 0.11)
		handle.ZIndex = 30
		handle.Parent = frame
	end
	handle.Active = true
	local dragging = false
	local startedInput = nil
	local startPoint = nil
	local startCenter = nil

	local function applyDefault()
		if not gui.Enabled then return end
		focusWindow(gui)
		if not spec.width then containWindows(); return end
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		if not UserInputService.TouchEnabled then
			frame.Size = UDim2.fromScale(spec.width, spec.height)
		end
		local x = UserInputService.TouchEnabled and 0.5 or spec.x
		frame.Position = UDim2.fromScale(x, spec.y)
		task.defer(function()
			if not gui.Enabled then return end
			setPosition(frame, frame.Position.X.Scale, frame.Position.Y.Scale)
		end)
	end

	gui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if gui.Enabled then task.defer(applyDefault); containWindows() end
		syncUiFlag()
	end)
	if gui.Enabled then task.defer(applyDefault) end
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(containWindows)
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(containWindows)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then focusWindow(gui) end
	end)

	handle.InputBegan:Connect(function(input)
		local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
		local isTouch = input.UserInputType == Enum.UserInputType.Touch
		if not gui.Enabled or (not isMouse and not isTouch) then return end
		focusWindow(gui)
		dragging = true
		startedInput = input
		startPoint = input.Position
		startCenter = Vector2.new(
			frame.Position.X.Scale,
			frame.Position.Y.Scale
		)
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not startPoint or not startCenter then return end
		if startedInput.UserInputType == Enum.UserInputType.Touch then
			if input ~= startedInput then return end
		elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local viewport = gui.AbsoluteSize
		local delta = input.Position - startPoint
		setPosition(frame, startCenter.X + delta.X / viewport.X, startCenter.Y + delta.Y / viewport.Y)
	end)
	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input == startedInput
			or (startedInput and startedInput.UserInputType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseButton1)) then
			dragging = false
			startedInput = nil
		end
	end)
end

for _, spec in ipairs(windowSpecs) do
	task.spawn(attachWindow, spec)
end
task.spawn(function()
	local menu = playerGui:WaitForChild("MenuUI")
	menu:GetPropertyChangedSignal("Enabled"):Connect(syncUiFlag)
end)
print("[Vandrheim] WindowLayoutClient R6.11 activo")

-- rc075: runtime windows and legacy input hints share one reconciled state.
local watched = setmetatable({}, {__mode = "k"})
local function watch(instance)
	if watched[instance] then return end
	if instance:IsA("ScreenGui") then
		watched[instance] = true
		instance:GetPropertyChangedSignal("Enabled"):Connect(syncUiFlag)
		if instance.Name == "SharedUI" then instance.DisplayOrder = 100 end
		if instance.Name == "MenuUI" then instance.DisplayOrder = 120 end
		if instance.Name == "MatchmakingUI" then instance.DisplayOrder = 75 end
	elseif instance:IsA("GuiObject") and table.find({
		"PartyWindow", "InvitePopup", "PortalWindow", "ConfirmDialog", "RunEndedNotice",
	}, instance.Name) then
		watched[instance] = true
		instance:GetPropertyChangedSignal("Visible"):Connect(syncUiFlag)
	end
	syncUiFlag()
end
for _, instance in ipairs(playerGui:GetDescendants()) do watch(instance) end
playerGui.DescendantAdded:Connect(watch)
playerGui.DescendantRemoving:Connect(syncUiFlag)
player:GetAttributeChangedSignal("UILayoutEditMode"):Connect(syncUiFlag)
player:GetAttributeChangedSignal("UIWindowOpen"):Connect(syncUiFlag)
local function bindCamera()
	if cameraConnection then cameraConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(containWindows) end
	containWindows()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()


