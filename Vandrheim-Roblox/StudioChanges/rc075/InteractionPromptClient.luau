-- InteractionPromptClient
-- Custom, legible Hearthbound Gold prompt for ProximityPrompt interactions.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local COLORS = {
	Canvas = Color3.fromRGB(15, 13, 11),
	Slot = Color3.fromRGB(23, 19, 17),
	Stroke = Color3.fromRGB(107, 74, 43),
	Parchment = Color3.fromRGB(244, 237, 224),
	Muted = Color3.fromRGB(181, 167, 154),
	Brass = Color3.fromRGB(200, 148, 69),
}

local existing = playerGui:FindFirstChild("InteractionPromptUI")
if existing then
	existing:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InteractionPromptUI"
screenGui.DisplayOrder = 80
screenGui.IgnoreGuiInset = true
pcall(function() screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)
screenGui.ResetOnSpawn = false
screenGui.Enabled = true
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "PromptPanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UserInputService.TouchEnabled and UDim2.fromScale(0.5, 0.69) or UDim2.fromScale(0.5, 0.88)
panel.Size = UDim2.fromScale(0.30, 0.085)
panel.BackgroundColor3 = COLORS.Canvas
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 10
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Name = "PromptStroke"
stroke.Color = COLORS.Stroke
stroke.Transparency = 0
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = panel

local key = Instance.new("TextButton")
key.Name = "KeyLabel"
key.Position = UDim2.fromScale(0.033, 0.16)
key.Size = UDim2.fromScale(0.15, 0.68)
key.BackgroundColor3 = COLORS.Brass
key.BackgroundTransparency = 0
key.BorderSizePixel = 0
key.TextColor3 = COLORS.Canvas
key.Font = Enum.Font.BuilderSansBold
key.TextSize = 16
key.Text = "E"
key.Active = UserInputService.TouchEnabled
key.AutoButtonColor = UserInputService.TouchEnabled
key.TextXAlignment = Enum.TextXAlignment.Center
key.TextYAlignment = Enum.TextYAlignment.Center
key.ZIndex = 11
key.Parent = panel

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 4)
keyCorner.Parent = key

local objectText = Instance.new("TextLabel")
objectText.Name = "ObjectText"
objectText.Position = UDim2.fromScale(0.22, 0.13)
objectText.Size = UDim2.fromScale(0.74, 0.34)
objectText.BackgroundTransparency = 1
objectText.BorderSizePixel = 0
objectText.TextColor3 = COLORS.Parchment
objectText.Font = Enum.Font.BuilderSansBold
objectText.TextSize = 15
objectText.TextXAlignment = Enum.TextXAlignment.Left
objectText.TextYAlignment = Enum.TextYAlignment.Center
objectText.TextTruncate = Enum.TextTruncate.AtEnd
objectText.ZIndex = 11
objectText.Parent = panel

local actionText = Instance.new("TextLabel")
actionText.Name = "ActionText"
actionText.Position = UDim2.fromScale(0.22, 0.51)
actionText.Size = UDim2.fromScale(0.74, 0.30)
actionText.BackgroundTransparency = 1
actionText.BorderSizePixel = 0
actionText.TextColor3 = COLORS.Muted
actionText.Font = Enum.Font.BuilderSans
actionText.TextSize = 13
actionText.TextXAlignment = Enum.TextXAlignment.Left
actionText.TextYAlignment = Enum.TextYAlignment.Center
actionText.TextTruncate = Enum.TextTruncate.AtEnd
actionText.ZIndex = 11
actionText.Parent = panel

local activePrompt = nil
local holdingPrompt = nil

local viewportConnection
local function adaptPrompt()
	local size = screenGui.AbsoluteSize
	if size.X <= 0 or size.Y <= 0 then return end
	local touch = UserInputService.TouchEnabled
	local width = math.min(touch and 320 or 360, size.X * 0.92)
	local height = math.min(touch and 68 or 60, size.Y * 0.22)
	panel.Size = UDim2.fromScale(width / size.X, height / size.Y)
	panel.Position = UDim2.fromScale(0.5, touch and 0.69 or 0.88)
	key.Size = UDim2.fromScale(touch and 0.17 or 0.13, 0.68)
end
local function bindViewport()
	if viewportConnection then viewportConnection:Disconnect() end
	local camera = Workspace.CurrentCamera
	if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptPrompt) end
	adaptPrompt()
end
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(adaptPrompt)
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()

local function hasOpenInteractionWindow()
	if player:GetAttribute("UIWindowOpen") == true then return true end

	local matchmaking = playerGui:FindFirstChild("MatchmakingUI")
	local portalWindow = matchmaking and matchmaking:FindFirstChild("PortalWindow")
	if matchmaking and matchmaking:IsA("ScreenGui") and matchmaking.Enabled
		and portalWindow and portalWindow.Visible then
		return true
	end

	local dungeonHud = playerGui:FindFirstChild("DungeonHUD")
	local confirmDialog = dungeonHud and dungeonHud:FindFirstChild("ConfirmDialog", true)
	local runEndedNotice = dungeonHud and dungeonHud:FindFirstChild("RunEndedNotice", true)
	if dungeonHud and dungeonHud:IsA("ScreenGui") and dungeonHud.Enabled
		and ((confirmDialog and confirmDialog.Visible) or (runEndedNotice and runEndedNotice.Visible)) then
		return true
	end

	return false
end

local function refreshPromptVisibility()
	local shouldShow = activePrompt ~= nil and activePrompt.Parent ~= nil
		and activePrompt.Enabled and not hasOpenInteractionWindow()
	panel.Visible = shouldShow
	if not shouldShow and holdingPrompt then
		holdingPrompt:InputHoldEnd()
		holdingPrompt = nil
	end
end

local function watchInteractionGui(gui)
	if not gui:IsA("ScreenGui") then return end
	if gui.Name == "VendorUI" or gui.Name == "MenuUI" then
		gui:GetPropertyChangedSignal("Enabled"):Connect(refreshPromptVisibility)
	elseif gui.Name == "MatchmakingUI" then
		local window = gui:WaitForChild("PortalWindow", 10)
		if window then window:GetPropertyChangedSignal("Visible"):Connect(refreshPromptVisibility) end
	elseif gui.Name == "DungeonHUD" then
		for _, name in ipairs({"ConfirmDialog", "RunEndedNotice"}) do
			local modal = gui:FindFirstChild(name, true)
			if modal and modal:IsA("GuiObject") then
				modal:GetPropertyChangedSignal("Visible"):Connect(refreshPromptVisibility)
			end
		end
	end
end

player:GetAttributeChangedSignal("UIWindowOpen"):Connect(refreshPromptVisibility)
playerGui.ChildAdded:Connect(watchInteractionGui)
for _, child in ipairs(playerGui:GetChildren()) do watchInteractionGui(child) end

if UserInputService.TouchEnabled then
	key.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if activePrompt and activePrompt.Enabled and not holdingPrompt then
			holdingPrompt = activePrompt
			holdingPrompt:InputHoldBegin()
		end
	end)
	key.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if holdingPrompt then
			holdingPrompt:InputHoldEnd()
			holdingPrompt = nil
		end
	end)
end

local function getKeyText(prompt)
	local keyCode = prompt.KeyboardKeyCode
	if keyCode and keyCode ~= Enum.KeyCode.Unknown then
		return keyCode.Name
	end
	if prompt.GamepadKeyCode and prompt.GamepadKeyCode ~= Enum.KeyCode.Unknown then
		return prompt.GamepadKeyCode.Name
	end
	return "E"
end

local function showPrompt(prompt)
	activePrompt = prompt
	key.Text = UserInputService.TouchEnabled and "TOCAR" or getKeyText(prompt)
	objectText.Text = prompt.ObjectText ~= "" and prompt.ObjectText or "Interacción"
	actionText.Text = prompt.ActionText ~= "" and prompt.ActionText or "Interactuar"
	refreshPromptVisibility()
end

local function hidePrompt(prompt)
	if activePrompt == prompt then
		activePrompt = nil
		if holdingPrompt then holdingPrompt:InputHoldEnd(); holdingPrompt = nil end
		refreshPromptVisibility()
	end
end

local function configurePrompt(prompt)
	if prompt:IsA("ProximityPrompt") then
		prompt.Style = Enum.ProximityPromptStyle.Custom
	end
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	configurePrompt(descendant)
end

Workspace.DescendantAdded:Connect(configurePrompt)
ProximityPromptService.PromptShown:Connect(showPrompt)
ProximityPromptService.PromptHidden:Connect(hidePrompt)

print("[Vandrheim] InteractionPromptClient Hearthbound Gold activo")
