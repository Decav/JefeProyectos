-- UIReskinClient
-- Presentation-only implementation of HU-ESTETICA-14.
-- It discovers existing UI and dynamic descendants without changing gameplay logic,
-- remotes, names, hierarchy, or interaction callbacks.

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local UITheme = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("UITheme"))
local ClassConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ClassConfig"))
local AllyTargetState = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AllyTargetState"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = UITheme.Colors
local styled = {}
local boundScreens = {}
local boundButtons = {}
local menuDesktopLayout
local menuDesktopSize
local menuDesktopRatio
local menuTouchApplied = false
local scaleTargets = {
	VendorUI = true,
	TalentUI = true,
	MenuUI = true,
	CharacterCreate = true,
	CharacterSelect = true,
}

local function lower(value)
	return string.lower(tostring(value or ""))
end

local function has(value, fragment)
	return string.find(lower(value), fragment, 1, true) ~= nil
end

local function ensureCorner(obj, radius)
	local corner = obj:FindFirstChildWhichIsA("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Name = "HearthboundCorner"
		corner.Parent = obj
	end
	corner.CornerRadius = radius or UITheme.CornerRadius
	return corner
end

local function ensureStroke(obj, color, transparency, thickness)
	local stroke = obj:FindFirstChildWhichIsA("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Name = "HearthboundStroke"
		stroke.Parent = obj
	end
	stroke.Color = color or COLORS.Brass
	stroke.Transparency = transparency or 0.25
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return stroke
end

local function styleBlackCell(obj)
	obj.BackgroundColor3 = COLORS.Shadow
	obj.BackgroundTransparency = 0
	obj.BorderSizePixel = 0
	local gradient = obj:FindFirstChild("HearthboundGradient")
	if gradient then gradient:Destroy() end
	ensureCorner(obj, UITheme.SmallCornerRadius)

	local cellStroke = obj:FindFirstChildWhichIsA("UIStroke")
	if not cellStroke then cellStroke = ensureStroke(obj, COLORS.Brass, 0.2, 1) end
	local baseColor = obj:GetAttribute("HearthboundCellBaseStrokeColor")
	if typeof(baseColor) ~= "Color3" then
		baseColor = cellStroke.Color
		obj:SetAttribute("HearthboundCellBaseStrokeColor", baseColor)
	end
	local baseThickness = tonumber(obj:GetAttribute("HearthboundCellBaseStrokeThickness")) or cellStroke.Thickness
	local baseTransparency = tonumber(obj:GetAttribute("HearthboundCellBaseStrokeTransparency")) or cellStroke.Transparency
	local function refreshCellStroke()
		if not cellStroke.Parent then return end
		local active = obj:GetAttribute("HearthboundHovered") == true or obj:GetAttribute("HearthboundPressed") == true
		local selected = obj:GetAttribute("HearthboundCellSelected") == true
		cellStroke.Color = active and baseColor:Lerp(COLORS.Parchment, 0.28) or (selected and COLORS.BrassBright or baseColor)
		cellStroke.Thickness = active and math.max(2, baseThickness + 0.5) or (selected and math.max(2, baseThickness) or baseThickness)
		cellStroke.Transparency = active and 0 or baseTransparency
	end
	refreshCellStroke()
	if not boundButtons[obj] then
		boundButtons[obj] = true
		obj.MouseEnter:Connect(function()
			obj:SetAttribute("HearthboundHovered", true)
			refreshCellStroke()
		end)
		obj.MouseLeave:Connect(function()
			obj:SetAttribute("HearthboundHovered", false)
			obj:SetAttribute("HearthboundPressed", false)
			refreshCellStroke()
		end)
		if obj:IsA("GuiButton") then
			obj.MouseButton1Down:Connect(function()
				obj:SetAttribute("HearthboundPressed", true)
				refreshCellStroke()
			end)
			obj.MouseButton1Up:Connect(function()
				obj:SetAttribute("HearthboundPressed", false)
				refreshCellStroke()
			end)
		else
			obj.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					obj:SetAttribute("HearthboundPressed", true)
					refreshCellStroke()
				end
			end)
			obj.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					obj:SetAttribute("HearthboundPressed", false)
					refreshCellStroke()
				end
			end)
		end
	end
end

local function ensureGradient(obj, topColor, bottomColor)
	local gradient = obj:FindFirstChild("HearthboundGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Name = "HearthboundGradient"
		gradient.Parent = obj
	end
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, topColor or COLORS.SurfaceRaised),
		ColorSequenceKeypoint.new(1, bottomColor or COLORS.Surface),
	})
	gradient.Rotation = 90
	return gradient
end

local function isTextObject(obj)
	return obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")
end

local function isBar(obj)
	local name = lower(obj.Name)
	return has(name, "bar") and not has(name, "container") and not has(name, "button")
end

local function isFill(obj)
	local name = lower(obj.Name)
	return has(name, "fill") or has(name, "progress")
end

local function isSlot(obj)
	local name = lower(obj.Name)
	if has(name, "slot") or has(name, "card") or has(name, "itemicon") then
		return true
	end
	if obj.Parent and obj.Parent.Name == "EquipmentPanel" then
		return true
	end
	if has(name, "helmet") or has(name, "shoulders") or has(name, "chest")
		or name == "legs" or name == "gloves" or name == "ring"
		or name == "necklace" or name == "mainhand" or name == "offhand" then
		return true
	end
	return false
end

local function isTransparentContainer(obj)
	local name = lower(obj.Name)
	return name == "buttons"
		or name == "classcontainer"
		or name == "slotscontainer"
		or name == "nodescontainer"
		or name == "skilllist"
		or name == "bagsScroll"
		or name == "bagscroll"
		or name == "infoarea"
end

local function isSurface(obj)
	local name = lower(obj.Name)
	return name == "mainframe"
		or name == "panel"
		or name == "tooltip"
		or name == "playerframe"
		or name == "targetframe"
		or name == "debugframe"
		or name == "loadoutpanel"
		or name == "confirmdialog"
		or name == "runendednotice"
		or name == "deletedialog"
		or name == "micromenubar"
		or name == "mobileaccessstack"
		or name == "itemuseslotsframe"
		or name == "levelupframe"
		or name == "lootpopup"
		or name == "bossnotice"
		or name == "topbar"
		or name == "barcontainer"
		or has(name, "panel")
		or has(name, "dialog")
		or has(name, "notice")
end

local function getButtonVariant(obj)
	local name = lower(obj.Name)
	if name == "closebutton" or name == "canceldelete" or name == "cancelabandon" then
		return "Close"
	end
	if has(name, "delete") or has(name, "abandon") or has(name, "reset") then
		return "Danger"
	end
	if has(name, "buyitem") or has(name, "sellitem") or has(name, "sellequip") then
		return "Secondary"
	end
	if has(name, "confirm") or has(name, "action") or has(name, "buy")
		or has(name, "equip") or has(name, "continue") or has(name, "return")
		or has(name, "respec") or has(name, "create") then
		return "Primary"
	end
	return "Secondary"
end

local function styleText(obj)
	if obj:GetAttribute("HearthboundCustomTextStyle") == true then
		return
	end
	local name = lower(obj.Name)
	local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
	if screenGui and screenGui.Name == "ProximityPrompts" then
		-- Roblox recrea estos labels al entrar/salir del radio del prompt.
		-- Restablecemos explícitamente la legibilidad después del reskin.
		obj.Font = Enum.Font.BuilderSansBold
		obj.TextColor3 = COLORS.Parchment
		obj.TextTransparency = 0
		obj.TextStrokeTransparency = 1
		return
	end
	local role = "Body"
	if UITheme.IsTitle(obj.Name) or name == "title" then
		role = "Title"
	elseif name == "keybind" or name == "keylabel" or name == "cdtext"
		or name == "manacost" or has(name, "value") then
		role = "Mono"
	elseif UITheme.IsMuted(obj.Name) then
		role = "Body"
	elseif has(name, "button") then
		role = "BodyMedium"
	end

	obj.Font = UITheme.GetFont(role)
	obj.TextStrokeTransparency = 1

	if name == "rarity" or name == "itemname" then
		-- Preserve runtime rarity/item colors supplied by the inventory system.
	elseif has(name, "error") or has(name, "warning") then
		obj.TextColor3 = COLORS.CrimsonBright
	elseif has(name, "feedback") then
		obj.TextColor3 = COLORS.BrassBright
	elseif has(name, "gold") or has(name, "points") then
		obj.TextColor3 = COLORS.BrassBright
	elseif UITheme.IsTitle(obj.Name) then
		obj.TextColor3 = COLORS.Parchment
	elseif UITheme.IsMuted(obj.Name) then
		obj.TextColor3 = COLORS.Muted
	else
		obj.TextColor3 = COLORS.Text
	end

	if name == "description" or name == "infolabel" or name == "subtitle"
		or name == "stats" or name == "affixes" or name == "endedlabel"
		or name == "confirmlabel" then
		obj.TextWrapped = true
	end
end

local function styleButton(button)
	if button:GetAttribute("HearthboundBlackCell") == true then
		styleBlackCell(button)
		return
	end
	local microMenu = button:FindFirstAncestor("MicroMenuBar")
	if microMenu then
		local selected = button.Name == "MenuButton"
		local hovered = button:GetAttribute("HearthboundHovered") == true
		local pressed = button:GetAttribute("HearthboundPressed") == true
		local normalColor = selected and Color3.fromRGB(200, 148, 69) or Color3.fromRGB(23, 19, 17)
		local hoverColor = selected and Color3.fromRGB(218, 165, 78) or Color3.fromRGB(42, 32, 26)
		local pressedColor = selected and Color3.fromRGB(169, 118, 48) or Color3.fromRGB(58, 42, 31)
		button.AutoButtonColor = false
		button.BackgroundColor3 = pressed and pressedColor or (hovered and hoverColor or normalColor)
		button.BackgroundTransparency = 0
		button.BorderSizePixel = 0
		button.ClipsDescendants = true
		button.TextColor3 = selected and Color3.fromRGB(21, 16, 13) or Color3.fromRGB(244, 237, 224)
		button.Font = UITheme.GetFont("BodyMedium")
		ensureCorner(button, UDim.new(0, 4))
		local hoverScale = button:FindFirstChild("HearthboundHoverScale")
		if not hoverScale then
			hoverScale = Instance.new("UIScale")
			hoverScale.Name = "HearthboundHoverScale"
			hoverScale.Parent = button
		end
		hoverScale.Scale = pressed and 0.96 or (hovered and 1.04 or 1)
		local strokeColor = hovered and Color3.fromRGB(226, 174, 83)
			or (selected and Color3.fromRGB(226, 174, 83) or Color3.fromRGB(107, 74, 43))
		ensureStroke(button, strokeColor, 0, (hovered or selected) and 2 or 1)
		local icon = button:FindFirstChild("Icon")
		if icon and icon:IsA("ImageLabel") then
			icon.ImageColor3 = hovered and Color3.fromRGB(255, 210, 112) or Color3.fromRGB(244, 237, 224)
		end
		if not boundButtons[button] then
			boundButtons[button] = true
			button.MouseEnter:Connect(function()
				button:SetAttribute("HearthboundHovered", true)
				if button.Parent then styleButton(button) end
			end)
			button.MouseLeave:Connect(function()
				button:SetAttribute("HearthboundHovered", false)
				button:SetAttribute("HearthboundPressed", false)
				if button.Parent then styleButton(button) end
			end)
			button.MouseButton1Down:Connect(function()
				button:SetAttribute("HearthboundPressed", true)
				if button.Parent then styleButton(button) end
			end)
			button.MouseButton1Up:Connect(function()
				button:SetAttribute("HearthboundPressed", false)
				if button.Parent then styleButton(button) end
			end)
		end
		return
	end
	if button.Parent and button.Parent.Name == "ClassContainer" and string.match(button.Name, "^Class_") then
		local function paintClassButton()
			local selected = button.BorderSizePixel > 0
			local hovered = button:GetAttribute("HearthboundHovered") == true
			local normalColor = selected and Color3.fromRGB(58, 44, 37) or Color3.fromRGB(23, 19, 17)
			local hoverColor = selected and Color3.fromRGB(76, 56, 43) or Color3.fromRGB(42, 32, 26)
			button.AutoButtonColor = false
			button.BackgroundColor3 = hovered and hoverColor or normalColor
			button.BackgroundTransparency = 0
			button.BorderSizePixel = selected and 2 or 0
			button.BorderColor3 = Color3.fromRGB(226, 174, 83)
			button.TextColor3 = Color3.fromRGB(244, 237, 224)
			ensureCorner(button, UDim.new(0, 6))
			ensureStroke(button, selected and Color3.fromRGB(226, 174, 83) or Color3.fromRGB(107, 74, 43), 0, selected and 2 or 1)
		end
		paintClassButton()
		if not boundButtons[button] then
			boundButtons[button] = true
			button.MouseEnter:Connect(function()
				button:SetAttribute("HearthboundHovered", true)
				paintClassButton()
			end)
			button.MouseLeave:Connect(function()
				button:SetAttribute("HearthboundHovered", false)
				paintClassButton()
			end)
			button.MouseButton1Down:Connect(function()
				button:SetAttribute("HearthboundHovered", true)
				paintClassButton()
			end)
			button.MouseButton1Up:Connect(paintClassButton)
		end
		return
	end
	local variant = getButtonVariant(button)
	local normalColor, hoverColor, textColor = UITheme.GetButtonColors(variant)
	local isWindowClose = button.Name == "CloseButton"
	if isWindowClose then
		-- Referencia común: cierre de talentos (EST-16).
		normalColor = Color3.fromRGB(58, 44, 37)
		hoverColor = Color3.fromRGB(80, 59, 44)
		textColor = Color3.fromRGB(244, 237, 224)
		button.Text = "X"
		button.TextSize = 18
		button.TextScaled = false
		button.TextTransparency = 0
		button.TextStrokeTransparency = 1
	end
	local vendorDisabled = button:GetAttribute("HearthboundVendorDisabled") == true
	if vendorDisabled then
		normalColor = COLORS.Surface
		hoverColor = COLORS.SurfaceRaised
		button.Active = false
		button.TextTransparency = 0.45
	end

	button.AutoButtonColor = false
	button.BackgroundColor3 = normalColor
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	if not has(button.Name, "buyitem") and not has(button.Name, "sellitem") and not has(button.Name, "sellequip") then
		button.TextColor3 = textColor
	end
	button.Font = UITheme.GetFont("BodyMedium")
	ensureCorner(button, UITheme.SmallCornerRadius)
	ensureStroke(button, variant == "Primary" and COLORS.BrassBright or COLORS.Brass, 0.3, 1)
	if isWindowClose then
		button.Font = Enum.Font.BuilderSansBold
		ensureCorner(button, UDim.new(0, 7))
		ensureStroke(button, Color3.fromRGB(107, 74, 43), 0, 1)
	end

	if not boundButtons[button] then
		boundButtons[button] = true
		button.MouseEnter:Connect(function()
			if button.Parent then
				TweenService:Create(button, UITheme.HoverTween, {
					BackgroundColor3 = hoverColor,
				}):Play()
			end
		end)
		button.MouseLeave:Connect(function()
			if button.Parent then
				TweenService:Create(button, UITheme.HoverTween, {
					BackgroundColor3 = normalColor,
				}):Play()
			end
		end)
		button.MouseButton1Down:Connect(function()
			if button.Parent then
				TweenService:Create(button, UITheme.HoverTween, {
					BackgroundColor3 = COLORS.BrassDark,
				}):Play()
			end
		end)
		button.MouseButton1Up:Connect(function()
			if button.Parent then
				TweenService:Create(button, UITheme.HoverTween, {
					BackgroundColor3 = hoverColor,
				}):Play()
			end
		end)
	end
end

local function styleFrame(obj)
	if obj.Name == "InfoBodyScroll" then
		obj.BackgroundTransparency = 1
		obj.BorderSizePixel = 0
		return
	end
	if obj:GetAttribute("HearthboundBlackCell") == true then
		styleBlackCell(obj)
		return
	end
	local name = lower(obj.Name)
	local screenGui = obj:FindFirstAncestorOfClass("ScreenGui")
	if screenGui and screenGui.Name == "ProximityPrompts"
		and (name == "promptframe" or name == "containerframe" or name == "inputframe") then
		obj.BackgroundColor3 = COLORS.CombatPanel
		obj.BackgroundTransparency = 0.08
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		ensureStroke(obj, COLORS.BrassDark, 0, 1)
		return
	end

	if name == "dimmer" then
		obj.BackgroundColor3 = COLORS.Shadow
		obj.BackgroundTransparency = 0.42
		obj.BorderSizePixel = 0
		return
	end

	if name == "background" and obj.Parent and obj.Parent:IsA("ScreenGui") then
		obj.BackgroundColor3 = COLORS.Canvas
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		return
	end

	if name == "topaccent" or name == "slotseparator" then
		obj.BackgroundColor3 = COLORS.Brass
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		return
	end

	if isFill(obj) then
		obj.BackgroundColor3 = UITheme.GetBarColor(obj.Name .. " " .. (obj.Parent and obj.Parent.Name or ""))
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		return
	end

	if isBar(obj) then
		obj.BackgroundColor3 = COLORS.BarBackground
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		return
	end

	if name == "cdoverlay" then
		obj.BackgroundColor3 = COLORS.Shadow
		obj.BackgroundTransparency = 0.35
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		return
	end

	if isTransparentContainer(obj) then
		obj.BackgroundTransparency = 1
		obj.BorderSizePixel = 0
		return
	end

	if isSlot(obj) then
		obj.BackgroundColor3 = COLORS.Slot
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.SmallCornerRadius)
		ensureStroke(obj, COLORS.Brass, 0.42, 1)
		return
	end

	if isSurface(obj) then
		obj.BackgroundColor3 = COLORS.Surface
		obj.BackgroundTransparency = 0
		obj.BorderSizePixel = 0
		ensureCorner(obj, UITheme.CornerRadius)
		ensureStroke(obj, COLORS.Brass, 0.22, 1)
		ensureGradient(obj, COLORS.SurfaceRaised, COLORS.Surface)
		return
	end

	if obj:IsA("ScrollingFrame") then
		obj.BackgroundColor3 = COLORS.SurfaceAlt
		obj.BackgroundTransparency = 0.06
		obj.BorderSizePixel = 0
		obj.ScrollBarImageColor3 = COLORS.Brass
		obj.ScrollBarImageTransparency = 0.15
		ensureCorner(obj, UITheme.SmallCornerRadius)
	end
end

local function styleImage(obj)
	if has(obj.Name, "skillicon") or has(obj.Name, "itemicon") or has(obj.Name, "icon") then
		ensureCorner(obj, UITheme.SmallCornerRadius)
		ensureStroke(obj, COLORS.Brass, 0.45, 1)
	end
end

local function styleObject(obj)
 local screenGui=obj:FindFirstAncestorOfClass("ScreenGui")
 if screenGui and (screenGui.Name=="TalentUI" or screenGui.Name=="SpellbookUI") then return end
 if screenGui and (screenGui.Name=="MatchmakingUI"
  or (screenGui.Name=="PartyUI" and (obj.Name=="InvitePopup" or obj.Name=="InviteScrim" or obj:FindFirstAncestor("InvitePopup")))) then return end
	if styled[obj] then
		return
	end
	styled[obj] = true

	if isTextObject(obj) then
		if obj:IsA("TextButton") and obj.Name ~= "Dimmer" then
			styleButton(obj)
		else
			styleText(obj)
		end
	elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
		styleFrame(obj)
	elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
		styleImage(obj)
	end
end

local function applyResponsive(screenGui)
 if screenGui.Name=="TalentUI" then
  pcall(function() screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
  pcall(function() screenGui.ClipToDeviceSafeArea = true end)
  return
 end
 if screenGui.Name=="MatchmakingUI" then return end
	if screenGui.Name == "MenuUI" then
		local panel = screenGui:FindFirstChild("Panel")
		local buttons = panel and panel:FindFirstChild("Buttons")
		local aspect = panel and panel:FindFirstChildWhichIsA("UIAspectRatioConstraint")
		if panel and buttons then
			if not menuDesktopSize then
				menuDesktopSize = panel.Size
				menuDesktopRatio = aspect and aspect.AspectRatio
				local list = buttons:FindFirstChildWhichIsA("UIListLayout")
				if list then menuDesktopLayout = list:Clone() end
			end
			if menuTouchApplied and not UserInputService.TouchEnabled then
				panel.Size = menuDesktopSize
				if aspect and menuDesktopRatio then aspect.AspectRatio = menuDesktopRatio end
				local grid = buttons:FindFirstChild("RC075TouchMenuGrid")
				if grid then grid:Destroy() end
				if not buttons:FindFirstChildWhichIsA("UIListLayout") and menuDesktopLayout then menuDesktopLayout:Clone().Parent = buttons end
				menuTouchApplied = false
			end
		end
	end
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local isCompact = viewport.X < 900 or viewport.Y < 600

	for _, obj in ipairs(screenGui:GetDescendants()) do
		if obj:IsA("GuiObject") then
			local name = lower(obj.Name)
			if scaleTargets[screenGui.Name] and (name == "mainframe" or name == "panel" or name == "tooltip") then
				local scale = obj:FindFirstChild("HearthboundResponsiveScale")
				if not scale then
					scale = Instance.new("UIScale")
					scale.Name = "HearthboundResponsiveScale"
					scale.Parent = obj
				end
				local touchWindow = UserInputService.TouchEnabled and table.find({"VendorUI", "TalentUI", "SpellbookUI", "MenuUI"}, screenGui.Name) ~= nil
				scale.Scale = touchWindow and 1 or (isCompact and 0.86 or 1)
			end
		end
	end
	if UserInputService.TouchEnabled then
		local main = screenGui:FindFirstChild("MainFrame")
		if main and table.find({"VendorUI", "TalentUI"}, screenGui.Name) then
			main.Size = UDim2.fromScale(0.92, 0.90)
		end
		if screenGui.Name == "MenuUI" then
			local panel = screenGui:FindFirstChild("Panel")
			local buttons = panel and panel:FindFirstChild("Buttons")
			if panel and buttons then
				menuTouchApplied = true
				panel.Size = UDim2.fromScale(0.60, 0.90)
				local aspect = panel:FindFirstChildWhichIsA("UIAspectRatioConstraint")
				if aspect then aspect.AspectRatio = 1.45 end
				local list = buttons:FindFirstChildWhichIsA("UIListLayout")
				if list then list:Destroy() end
				local grid = buttons:FindFirstChild("RC075TouchMenuGrid")
				if not grid then
					grid = Instance.new("UIGridLayout")
					grid.Name = "RC075TouchMenuGrid"
					grid.Parent = buttons
				end
				grid.FillDirectionMaxCells = 2
				grid.SortOrder = Enum.SortOrder.LayoutOrder
				grid.CellSize = UDim2.fromScale(0.485, 0.28)
				grid.CellPadding = UDim2.fromScale(0.025, 0.025)
				for _, button in ipairs(buttons:GetChildren()) do
					if button:IsA("TextButton") then
						local limit = button:FindFirstChildWhichIsA("UITextSizeConstraint") or Instance.new("UITextSizeConstraint")
						limit.MinTextSize = 12
						limit.MaxTextSize = 18
						limit.Parent = button
					end
				end
			end
		end
	end
	if screenGui.Name == "MenuUI" then
		local hint = screenGui:FindFirstChild("HintLabel", true)
		if hint then hint.Text = UserInputService.TouchEnabled and "Usa Continuar para cerrar" or "Pulsa M para cerrar" end
	end

	-- Keep screen content inside the device-safe region where supported.
	pcall(function()
		local isWindow = table.find({"InventoryUI", "EquipmentUI", "VendorUI", "TalentUI",
			"SpellbookUI", "MenuUI", "PartyUI", "SharedUI"}, screenGui.Name) ~= nil
		screenGui.ScreenInsets = isWindow and Enum.ScreenInsets.CoreUISafeInsets or Enum.ScreenInsets.DeviceSafeInsets
	end)
	pcall(function()
		screenGui.ClipToDeviceSafeArea = true
	end)
end

local CHARACTER_CLASS_ACCENTS = {
	Paladin = Color3.fromRGB(200, 148, 69),
	Hunter = Color3.fromRGB(143, 183, 214),
	Cleric = Color3.fromRGB(180, 138, 222),
}

local CHARACTER_CLASS_INITIALS = {
	Paladin = "P",
	Hunter = "H",
	Cleric = "C",
}

local CHARACTER_ROLE_LABELS = {
	Tank = "Tanque",
	MeleeMagico = "Melee mágico",
	MeleeFisico = "Melee físico",
	RangedFisico = "A distancia · físico",
	Healer = "Sanador",
	RangedMagico = "A distancia · mágico",
}

local function characterFont(role)
	return UITheme.GetFont(role)
end

local function setCharacterText(label, text, size, color, role, xAlign, yAlign)
	label.Text = text or ""
	label.Font = characterFont(role or "Body")
	label.TextSize = size or 12
	label.TextScaled = false
	label.TextWrapped = false
	label.TextStrokeTransparency = 1
	label.TextColor3 = color or Color3.fromRGB(244, 237, 224)
	label.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	label.TextYAlignment = yAlign or Enum.TextYAlignment.Center
	label.BackgroundTransparency = 1
end

local function ensureCharacterLabel(parent, name)
	local label = parent:FindFirstChild(name)
	if not label or not label:IsA("TextLabel") then
		label = Instance.new("TextLabel")
		label.Name = name
		label.Parent = parent
	end
	label.Visible = true
	return label
end

local function validCharacterIconId(iconId)
	if type(iconId) ~= "string" then return false end
	local digits = string.match(iconId, "^rbxassetid://(%d+)$")
	return digits ~= nil and tonumber(digits) ~= nil and tonumber(digits) > 0
end

local function ensureCharacterIcon(parent, position, size, classId, emptyFallback)
	local holder = parent:FindFirstChild("HearthboundClassIcon")
	if not holder or not holder:IsA("Frame") then
		holder = Instance.new("Frame")
		holder.Name = "HearthboundClassIcon"
		holder.Parent = parent
	end
	holder.Position = position
	holder.Size = size
	holder.BackgroundColor3 = Color3.fromRGB(14, 13, 12)
	holder.BackgroundTransparency = 0
	holder.BorderSizePixel = 0
	holder.ZIndex = parent.ZIndex + 1
	local aspect = holder:FindFirstChildWhichIsA("UIAspectRatioConstraint")
	if not aspect then
		aspect = Instance.new("UIAspectRatioConstraint")
		aspect.Name = "HearthboundIconAspect"
		aspect.Parent = holder
	end
	aspect.AspectRatio = 1
	ensureCorner(holder, UDim.new(0, 5))
	ensureStroke(holder, CHARACTER_CLASS_ACCENTS[classId] or Color3.fromRGB(107, 74, 43), 0, 1)

	local image = holder:FindFirstChild("HearthboundImage")
	if not image or not image:IsA("ImageLabel") then
		image = Instance.new("ImageLabel")
		image.Name = "HearthboundImage"
		image.Parent = holder
	end
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.new(1, -4, 1, -4)
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.ScaleType = Enum.ScaleType.Fit
	image.ZIndex = holder.ZIndex + 1

	local fallback = ensureCharacterLabel(holder, "HearthboundFallback")
	fallback.Position = UDim2.fromScale(0, 0)
	fallback.Size = UDim2.fromScale(1, 1)
	fallback.ZIndex = holder.ZIndex + 2
	fallback.Font = characterFont("Mono")
	fallback.TextSize = math.max(10, math.floor(size.Y.Offset * 0.42))
	fallback.TextColor3 = CHARACTER_CLASS_ACCENTS[classId] or Color3.fromRGB(200, 148, 69)
	fallback.TextXAlignment = Enum.TextXAlignment.Center
	fallback.TextYAlignment = Enum.TextYAlignment.Center

	local classData = classId and ClassConfig[classId]
	local iconId = classData and classData.iconId
	local hasIcon = validCharacterIconId(iconId)
	image.Image = hasIcon and iconId or ""
	image.Visible = hasIcon
	fallback.Visible = not hasIcon
	fallback.Text = classData and CHARACTER_CLASS_INITIALS[classId] or (emptyFallback or "+")
	return holder
end

local function updateCharacterSlotVisual(card)
	local state = card:GetAttribute("HearthboundSlotState") or "empty"
	local classId = card:GetAttribute("HearthboundClassId")
	card.BackgroundColor3 = state == "occupied" and Color3.fromRGB(58, 44, 37) or Color3.fromRGB(23, 19, 17)
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0

	local slotIndex = tonumber(string.match(card.Name, "%d+")) or 1
	local slotLabel = card:FindFirstChild("SlotLabel")
	if slotLabel and slotLabel:IsA("TextLabel") then
		slotLabel.Text = state == "locked" and ("SLOT " .. slotIndex .. " · BLOQUEADO") or ("SLOT " .. slotIndex)
	end

	local fallback = state == "locked" and "III" or (state == "empty" and "+" or nil)
	local icon = card:FindFirstChild("HearthboundClassIcon")
	if icon then
		ensureCharacterIcon(card, icon.Position, icon.Size, classId, fallback)
	end
end

local function ensureCharacterButtonLayout(parent, fillDirection, gap)
	local layout = parent:FindFirstChildOfClass("UIListLayout")
	if not layout then
		layout = Instance.new("UIListLayout")
		layout.Name = "HearthboundCharacterLayout"
		layout.Parent = parent
	end
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = fillDirection
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, gap or 0)
	return layout
end

local function setupClassOption(button, classId, compactCard)
	local classData = ClassConfig[classId]
	if not classData then return end

	local accent = CHARACTER_CLASS_ACCENTS[classId] or Color3.fromRGB(200, 148, 69)
	button.Text = classData.DisplayName
	button.TextTransparency = 1
	button.TextScaled = false
	button.TextWrapped = false
	button.AutoButtonColor = false
	button.BackgroundColor3 = button.BorderSizePixel > 0 and Color3.fromRGB(58, 44, 37) or Color3.fromRGB(23, 19, 17)
	button.BackgroundTransparency = 0
	button.BorderSizePixel = button.BorderSizePixel > 0 and 2 or 0
	button.BorderColor3 = accent
	button.ClipsDescendants = true
	button.ZIndex = 4
	ensureCorner(button, UDim.new(0, 6))
	ensureStroke(button, button.BorderSizePixel > 0 and Color3.fromRGB(226, 174, 83) or Color3.fromRGB(107, 74, 43), 0, button.BorderSizePixel > 0 and 2 or 1)

	local width = button.Size.X.Offset
	local height = button.Size.Y.Offset
	local iconSize = compactCard and 30 or 38
	local iconX = compactCard and math.floor((width - iconSize) / 2) or 12
	local iconY = compactCard and 7 or math.max(8, math.floor((height - iconSize) / 2))
	ensureCharacterIcon(button, UDim2.fromOffset(iconX, iconY), UDim2.fromOffset(iconSize, iconSize), classId)

	local className = ensureCharacterLabel(button, "HearthboundClassName")
	local classSpecs = ensureCharacterLabel(button, "HearthboundClassSpecs")
	local classRoles = ensureCharacterLabel(button, "HearthboundClassRoles")
	className.ZIndex = button.ZIndex + 2
	classSpecs.ZIndex = button.ZIndex + 2
	classRoles.ZIndex = button.ZIndex + 2
	local specA = classData.Specs and classData.Specs.A
	local specB = classData.Specs and classData.Specs.B
	local specsText = specA and specB and (specA.Name .. " / " .. specB.Name) or ""
	local roleA = specA and CHARACTER_ROLE_LABELS[specA.Role] or ""
	local roleB = specB and CHARACTER_ROLE_LABELS[specB.Role] or ""
	local rolesText = roleA ~= "" and roleB ~= "" and (roleA .. " / " .. roleB) or ""

	if compactCard then
		className.Position = UDim2.fromOffset(4, 42)
		className.Size = UDim2.new(1, -8, 0, 18)
		classSpecs.Position = UDim2.fromOffset(4, 61)
		classSpecs.Size = UDim2.new(1, -8, 0, 17)
		classRoles.Position = UDim2.fromOffset(4, 79)
		classRoles.Size = UDim2.new(1, -8, 0, 17)
		setCharacterText(className, classData.DisplayName, 11, Color3.fromRGB(244, 237, 224), "BodyMedium", Enum.TextXAlignment.Center)
		setCharacterText(classSpecs, specsText, 8, accent, "Mono", Enum.TextXAlignment.Center)
		setCharacterText(classRoles, rolesText, 8, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Center)
	else
		className.Position = UDim2.fromOffset(60, math.max(7, math.floor(height / 2) - 23))
		className.Size = UDim2.new(0.48, -60, 0, 21)
		classSpecs.Position = UDim2.fromOffset(60, math.max(29, math.floor(height / 2) - 2))
		classSpecs.Size = UDim2.new(0.52, -66, 0, 18)
		classRoles.Position = UDim2.new(0.62, 0, 0, math.max(25, math.floor(height / 2) - 5))
		classRoles.Size = UDim2.new(0.35, -10, 0, 26)
		setCharacterText(className, classData.DisplayName, 13, Color3.fromRGB(244, 237, 224), "BodyMedium")
		setCharacterText(classSpecs, specsText, 9, accent, "Mono")
		setCharacterText(classRoles, rolesText, 8, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Right)
		classRoles.TextWrapped = true
	end
end

local function styleCharacterScreens(screenGui)
	if screenGui.Name ~= "CharacterSelect" and screenGui.Name ~= "CharacterCreate" then
		return
	end

	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local isCompact = UserInputService.TouchEnabled or viewport.X < 900 or viewport.Y < 600
	local isPortrait = viewport.Y > viewport.X
	local background = screenGui:FindFirstChild("Background")
	if not background then return end

	background.Position = UDim2.fromScale(0, 0)
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
	background.BackgroundTransparency = 0
	background.BorderSizePixel = 0
	background.ZIndex = 1

	if screenGui.Name == "CharacterSelect" then
		local panel = background:FindFirstChild("HearthboundSelectPanel")
		if not panel then
			panel = Instance.new("Frame")
			panel.Name = "HearthboundSelectPanel"
			panel.Parent = background
		end
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
		panel.BackgroundTransparency = 0
		panel.BorderSizePixel = 0
		panel.ZIndex = 2
		panel.ClipsDescendants = false
		ensureCorner(panel, UDim.new(0, 10))
		ensureStroke(panel, Color3.fromRGB(107, 74, 43), 0, 1)

		local title = background:FindFirstChild("Title")
		local slotsContainer = background:FindFirstChild("SlotsContainer")
		if not title or not slotsContainer then return end
		title.ZIndex = 3
		title.Font = characterFont("Title")
		title.Text = "ELIGE TU PERSONAJE"
		title.TextSize = isCompact and 18 or 20
		title.TextScaled = false
		title.TextWrapped = false
		title.TextColor3 = Color3.fromRGB(244, 237, 224)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextYAlignment = Enum.TextYAlignment.Center
		title.BackgroundTransparency = 1

		local account = ensureCharacterLabel(background, "HearthboundAccountLabel")
		account.ZIndex = 3
		account.BackgroundTransparency = 1
		account.BorderSizePixel = 0
		account.Font = characterFont("Mono")
		account.TextSize = 9
		account.TextColor3 = Color3.fromRGB(181, 167, 154)
		account.TextXAlignment = Enum.TextXAlignment.Left
		account.TextYAlignment = Enum.TextYAlignment.Center
		account.Text = "CUENTA · " .. string.upper(player.DisplayName)

		slotsContainer.BackgroundTransparency = 1
		slotsContainer.BorderSizePixel = 0
		slotsContainer.AnchorPoint = Vector2.new(0, 0)
		slotsContainer.ClipsDescendants = false
		slotsContainer.ZIndex = 3

		local slots = {}
		for index = 1, 3 do
			local card = slotsContainer:FindFirstChild("Slot" .. index)
			if card and card:IsA("Frame") then
				table.insert(slots, card)
				card.LayoutOrder = index
				card.ZIndex = 4
				card.ClipsDescendants = false
				local info = card:FindFirstChild("InfoArea")
				local slotLabel = card:FindFirstChild("SlotLabel")
				local charName = info and info:FindFirstChild("CharName")
				local charClass = info and info:FindFirstChild("CharClass")
				local charLevel = info and info:FindFirstChild("CharLevel")
				local action = card:FindFirstChild("ActionButton")
				local delete = card:FindFirstChild("DeleteButton")
				local lock = card:FindFirstChild("LockOverlay")
				local lockText = lock and lock:FindFirstChild("LockText")

				if not card:GetAttribute("HearthboundSlotVisualBound") then
					card:SetAttribute("HearthboundSlotVisualBound", true)
					card:GetAttributeChangedSignal("HearthboundSlotState"):Connect(function()
						updateCharacterSlotVisual(card)
					end)
					card:GetAttributeChangedSignal("HearthboundClassId"):Connect(function()
						updateCharacterSlotVisual(card)
					end)
				end
				updateCharacterSlotVisual(card)

				if info then
					info.BackgroundTransparency = 1
					info.Position = UDim2.fromOffset(12, 0)
					info.Size = UDim2.new(1, -24, 0, 90)
					info.ZIndex = 5
				end
				if slotLabel then
					slotLabel.ZIndex = 6
					setCharacterText(slotLabel, slotLabel.Text, 9, Color3.fromRGB(200, 148, 69), "Mono", Enum.TextXAlignment.Center)
				end
				if charName then
					charName.ZIndex = 6
					charName.TextScaled = false
					charName.TextWrapped = false
					setCharacterText(charName, charName.Text, 15, Color3.fromRGB(244, 237, 224), "Title", Enum.TextXAlignment.Center)
				end
				if charClass then
					charClass.ZIndex = 6
					charClass.TextScaled = false
					charClass.TextWrapped = false
					setCharacterText(charClass, charClass.Text, 10, Color3.fromRGB(200, 148, 69), "Mono", Enum.TextXAlignment.Center)
				end
				if charLevel then
					charLevel.ZIndex = 6
					charLevel.TextScaled = false
					charLevel.TextWrapped = false
					setCharacterText(charLevel, string.upper(charLevel.Text), 9, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Center)
				end
				if action and action:IsA("TextButton") then
					action.ZIndex = 7
					action.AutoButtonColor = true
					action.Font = characterFont("Mono")
					action.TextSize = 11
					action.TextColor3 = Color3.fromRGB(21, 16, 13)
					action.TextScaled = false
					action.TextWrapped = false
					action.BorderSizePixel = 0
					ensureCorner(action, UDim.new(0, 5))
				end
				if delete and delete:IsA("TextButton") then
					delete.ZIndex = 7
					delete.Text = "BORRAR"
					delete.Font = characterFont("Mono")
					delete.TextSize = 9
					delete.TextColor3 = Color3.fromRGB(244, 237, 224)
					delete.TextScaled = false
					delete.BorderSizePixel = 0
					ensureCorner(delete, UDim.new(0, 5))
					delete.BackgroundColor3 = Color3.fromRGB(115, 49, 49)
				end
				if lock then
					lock.ZIndex = 10
					lock.Active = true
					lock.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
					lock.BackgroundTransparency = 0.12
					lock.BorderSizePixel = 0
					ensureCorner(lock, UDim.new(0, 8))
					if lockText then
						lockText.ZIndex = 11
						lockText.Position = UDim2.new(0.08, 0, 0.4, 0)
						lockText.Size = UDim2.new(0.84, 0, 0.25, 0)
						setCharacterText(lockText, "SLOT 3 BLOQUEADO\nDESBLOQUEAR · ROBUX", 11, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Center)
						lockText.TextWrapped = true
					end
				end
			end
		end

		local layout = ensureCharacterButtonLayout(slotsContainer, isCompact and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal, isCompact and 8 or 14)
		local note = ensureCharacterLabel(background, "HearthboundSelectNote")
		note.ZIndex = 3
		note.Text = "Dos espacios gratuitos · el tercer espacio se desbloquea con Robux"
		setCharacterText(note, note.Text, 9, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Center)

		local panelWidth
		local panelHeight
		if isCompact then
			panelWidth = math.max(280, math.min(viewport.X - 24, 960))
			panelHeight = math.max(260, math.min(viewport.Y - 24, 820))
		else
			panelWidth = math.min(640, viewport.X - 48)
			panelHeight = math.min(560, viewport.Y - 48)
		end
		panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
		panel.Position = UDim2.new(0.5, 0, 0.5, 0)

		if isCompact then
			title.AnchorPoint = Vector2.new(0, 0)
			title.Position = UDim2.fromOffset((viewport.X - panelWidth) / 2 + 18, (viewport.Y - panelHeight) / 2 + 14)
			title.Size = UDim2.new(1, -36, 0, 26)
			account.AnchorPoint = Vector2.new(0, 0)
			account.Position = UDim2.fromOffset((viewport.X - panelWidth) / 2 + 18, (viewport.Y - panelHeight) / 2 + 39)
			account.Size = UDim2.new(1, -36, 0, 14)
			account.Visible = panelHeight > 330
			local rowHeight = math.max(80, math.min(136, (panelHeight - 112) / 3))
			local gap = 8
			local listHeight = rowHeight * 3 + gap * 2
			local listX = (viewport.X - panelWidth) / 2 + 16
			local listY = (viewport.Y - panelHeight) / 2 + math.max(58, (panelHeight - listHeight) / 2)
			slotsContainer.Position = UDim2.fromOffset(listX, listY)
			slotsContainer.Size = UDim2.fromOffset(panelWidth - 32, listHeight)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			layout.VerticalAlignment = Enum.VerticalAlignment.Top

			local cardWidth = panelWidth - 32
			local portraitActions = isPortrait
			for _, card in ipairs(slots) do
				card.Size = UDim2.fromOffset(cardWidth, rowHeight)
				local info = card:FindFirstChild("InfoArea")
				local slotLabel = card:FindFirstChild("SlotLabel")
				local charName = info and info:FindFirstChild("CharName")
				local charClass = info and info:FindFirstChild("CharClass")
				local charLevel = info and info:FindFirstChild("CharLevel")
				local action = card:FindFirstChild("ActionButton")
				local delete = card:FindFirstChild("DeleteButton")
				local icon = card:FindFirstChild("HearthboundClassIcon")
				if icon then
					local iconSize = math.min(42, rowHeight - 18)
					ensureCharacterIcon(card, UDim2.fromOffset(12, (rowHeight - iconSize) / 2), UDim2.fromOffset(iconSize, iconSize), card:GetAttribute("HearthboundClassId"), card:GetAttribute("HearthboundSlotState") == "empty" and "+" or nil)
				end
				if info then
					info.Position = UDim2.fromOffset(62, 0)
					info.Size = portraitActions and UDim2.new(1, -74, 1, 0) or UDim2.new(1, -220, 1, 0)
				end
				if slotLabel then
					slotLabel.Position = UDim2.fromOffset(62, 5)
					slotLabel.Size = UDim2.new(0.5, -62, 0, 13)
					setCharacterText(slotLabel, slotLabel.Text, 8, Color3.fromRGB(200, 148, 69), "Mono")
				end
				if charName then
					charName.Position = UDim2.fromOffset(0, 18)
					charName.Size = UDim2.new(1, 0, 0, 19)
					setCharacterText(charName, charName.Text, 13, Color3.fromRGB(244, 237, 224), "Title")
				end
				if charClass then
					charClass.Position = UDim2.fromOffset(0, 37)
					charClass.Size = UDim2.new(1, 0, 0, 15)
					setCharacterText(charClass, charClass.Text, 10, Color3.fromRGB(200, 148, 69), "Mono")
				end
				if charLevel then
					charLevel.Position = UDim2.fromOffset(0, 52)
					charLevel.Size = UDim2.new(1, 0, 0, 13)
					setCharacterText(charLevel, string.upper(charLevel.Text), 8, Color3.fromRGB(181, 167, 154), "Mono")
				end
				if action then
					action.AnchorPoint = portraitActions and Vector2.new(0, 1) or Vector2.new(1, 0.5)
					if portraitActions then
						local deleteWidth = 62
						local buttonGap = 7
						local actionWidth = math.max(76, cardWidth - 62 - deleteWidth - buttonGap - 20)
						action.Position = UDim2.new(0, 62, 1, -7)
						action.Size = UDim2.fromOffset(actionWidth, math.min(40, math.max(34, rowHeight - 32)))
					else
						action.Position = UDim2.new(1, -78, 0.5, 0)
						action.Size = UDim2.fromOffset(68, math.min(40, math.max(34, rowHeight - 20)))
					end
					action.TextSize = 10
				end
				if delete then
					delete.AnchorPoint = portraitActions and Vector2.new(1, 1) or Vector2.new(1, 0.5)
					if portraitActions then
						delete.Position = UDim2.new(1, -10, 1, -7)
						delete.Size = UDim2.fromOffset(62, math.min(40, math.max(34, rowHeight - 32)))
					else
						delete.Position = UDim2.new(1, -8, 0.5, 0)
						delete.Size = UDim2.fromOffset(62, math.min(40, math.max(34, rowHeight - 20)))
					end
					delete.TextSize = 8
				end
				local lock = card:FindFirstChild("LockOverlay")
				if lock then
					lock.Position = UDim2.fromScale(0, 0)
					lock.Size = UDim2.fromScale(1, 1)
				end
			end
			note.AnchorPoint = Vector2.new(0.5, 1)
			note.Position = UDim2.new(0.5, 0, 1, -8)
			note.Size = UDim2.new(1, -24, 0, 18)
			note.Visible = panelHeight > 420
		else
			local left = (viewport.X - panelWidth) / 2
			local top = (viewport.Y - panelHeight) / 2
			title.AnchorPoint = Vector2.new(0, 0)
			title.Position = UDim2.fromOffset(left + 20, top + 16)
			title.Size = UDim2.fromOffset(panelWidth - 40, 28)
			account.AnchorPoint = Vector2.new(0, 0)
			account.Position = UDim2.fromOffset(left + 20, top + 46)
			account.Size = UDim2.fromOffset(panelWidth - 40, 16)
			account.Visible = true
			slotsContainer.Position = UDim2.fromOffset(left + 20, top + 78)
			slotsContainer.Size = UDim2.fromOffset(panelWidth - 40, 356)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Top
			local cardWidth = (panelWidth - 40 - 28) / 3
			for _, card in ipairs(slots) do
				card.Size = UDim2.fromOffset(cardWidth, 356)
				local info = card:FindFirstChild("InfoArea")
				local slotLabel = card:FindFirstChild("SlotLabel")
				local charName = info and info:FindFirstChild("CharName")
				local charClass = info and info:FindFirstChild("CharClass")
				local charLevel = info and info:FindFirstChild("CharLevel")
				local action = card:FindFirstChild("ActionButton")
				local delete = card:FindFirstChild("DeleteButton")
				ensureCharacterIcon(card, UDim2.new(0.5, -24, 0, 34), UDim2.fromOffset(48, 48), card:GetAttribute("HearthboundClassId"), card:GetAttribute("HearthboundSlotState") == "empty" and "+" or nil)
				if slotLabel then
					slotLabel.AnchorPoint = Vector2.new(0.5, 0)
					slotLabel.Position = UDim2.new(0.5, 0, 0, 10)
					slotLabel.Size = UDim2.new(1, -20, 0, 16)
					setCharacterText(slotLabel, slotLabel.Text, 9, Color3.fromRGB(200, 148, 69), "Mono", Enum.TextXAlignment.Center)
				end
				if info then
					info.AnchorPoint = Vector2.new(0, 0)
					info.Position = UDim2.new(0, 8, 0, 92)
					info.Size = UDim2.new(1, -16, 0, 84)
				end
				if charName then
					charName.Position = UDim2.fromOffset(0, 0)
					charName.Size = UDim2.new(1, 0, 0, 26)
					setCharacterText(charName, charName.Text, 15, Color3.fromRGB(244, 237, 224), "Title", Enum.TextXAlignment.Center)
				end
				if charClass then
					charClass.Position = UDim2.fromOffset(0, 28)
					charClass.Size = UDim2.new(1, 0, 0, 22)
					setCharacterText(charClass, charClass.Text, 10, Color3.fromRGB(200, 148, 69), "Mono", Enum.TextXAlignment.Center)
				end
				if charLevel then
					charLevel.Position = UDim2.fromOffset(0, 52)
					charLevel.Size = UDim2.new(1, 0, 0, 18)
					setCharacterText(charLevel, string.upper(charLevel.Text), 9, Color3.fromRGB(181, 167, 154), "Mono", Enum.TextXAlignment.Center)
				end
				if action then
					action.AnchorPoint = Vector2.new(0.5, 0)
					action.Position = UDim2.new(0.5, 0, 0, 210)
					action.Size = UDim2.new(1, -32, 0, 40)
					action.TextSize = 11
				end
				if delete then
					delete.AnchorPoint = Vector2.new(0.5, 0)
					delete.Position = UDim2.new(0.5, 0, 0, 260)
					delete.Size = UDim2.new(1, -32, 0, 34)
					delete.TextSize = 9
				end
				local lock = card:FindFirstChild("LockOverlay")
				if lock then
					lock.Position = UDim2.fromScale(0, 0)
					lock.Size = UDim2.fromScale(1, 1)
				end
			end
			note.AnchorPoint = Vector2.new(0, 0)
			note.Position = UDim2.fromOffset(left + 20, top + 462)
			note.Size = UDim2.fromOffset(panelWidth - 40, 30)
			note.Visible = true
		end

		local dialog = background:FindFirstChild("DeleteDialog")
		if dialog then
			dialog.AnchorPoint = Vector2.new(0.5, 0.5)
			dialog.Position = UDim2.fromScale(0.5, 0.5)
			dialog.Size = UDim2.fromOffset(math.min(360, viewport.X - 32), math.min(210, viewport.Y - 32))
			dialog.ZIndex = 12
			dialog.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
			dialog.BackgroundTransparency = 0
			dialog.BorderSizePixel = 0
			ensureCorner(dialog, UDim.new(0, 9))
			ensureStroke(dialog, Color3.fromRGB(184, 78, 91), 0, 1)
			local textLabel = dialog:FindFirstChild("DialogText")
			local confirm = dialog:FindFirstChild("ConfirmDelete")
			local cancel = dialog:FindFirstChild("CancelDelete")
			if textLabel then
				textLabel.ZIndex = 13
				textLabel.Position = UDim2.new(0, 16, 0, 18)
				textLabel.Size = UDim2.new(1, -32, 0, 105)
				setCharacterText(textLabel, textLabel.Text, 14, Color3.fromRGB(244, 237, 224), "BodyMedium", Enum.TextXAlignment.Center)
				textLabel.TextWrapped = true
			end
			if confirm then
				confirm.ZIndex = 13
				confirm.Position = UDim2.new(0, 16, 1, -58)
				confirm.Size = UDim2.new(0.5, -22, 0, 40)
				confirm.TextSize = 10
			end
			if cancel then
				cancel.ZIndex = 13
				cancel.Position = UDim2.new(0.5, 6, 1, -58)
				cancel.Size = UDim2.new(0.5, -22, 0, 40)
				cancel.TextSize = 10
			end
		end
		return
	end

	local panel = background:FindFirstChild("Panel")
	if not panel then return end
	local responsiveScale = panel:FindFirstChild("HearthboundResponsiveScale")
	if responsiveScale and responsiveScale:IsA("UIScale") then
		responsiveScale.Scale = 1
	end
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	panel.BackgroundTransparency = 0
	panel.BorderSizePixel = 0
	panel.ZIndex = 2
	panel.ClipsDescendants = false
	ensureCorner(panel, UDim.new(0, 10))
	ensureStroke(panel, Color3.fromRGB(200, 148, 69), 0, 1)

	local panelWidth
	local panelHeight
	if not isCompact then
		panelWidth = math.min(616, viewport.X - 48)
		panelHeight = math.min(560, viewport.Y - 48)
	else
		panelWidth = math.max(280, math.min(viewport.X - 24, 760))
		panelHeight = isPortrait and math.max(520, math.min(viewport.Y - 24, 660)) or math.max(300, math.min(viewport.Y - 24, 380))
	end
	panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
	local panelAspect = panel:FindFirstChildOfClass("UIAspectRatioConstraint")
	if panelAspect then
		-- El panel usa dimensiones calculadas para el viewport actual; mantener
		-- una proporción fija hace que el ancho visual no coincida con el layout.
		panelAspect.AspectRatio = panelWidth / panelHeight
	end
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)

	local title = panel:FindFirstChild("Title")
	local nameLabel = panel:FindFirstChild("NameLabel")
	local nameBox = panel:FindFirstChild("NameBox")
	local classLabel = panel:FindFirstChild("ClassLabel")
	local classContainer = panel:FindFirstChild("ClassContainer")
	local errorLabel = panel:FindFirstChild("ErrorLabel")
	local confirm = panel:FindFirstChild("ConfirmButton")
	local back = panel:FindFirstChild("BackButton")
	if not (title and nameLabel and nameBox and classLabel and classContainer and errorLabel and confirm and back) then return end

	title.ZIndex = 3
	title.Position = UDim2.fromOffset(20, 14)
	title.Size = UDim2.new(1, -40, 0, 28)
	setCharacterText(title, "CREAR PERSONAJE", isCompact and 18 or 20, Color3.fromRGB(244, 237, 224), "Title")
	local step = ensureCharacterLabel(panel, "HearthboundCreateStep")
	step.ZIndex = 3
	step.Position = UDim2.fromOffset(20, 42)
	step.Size = UDim2.new(1, -40, 0, 16)
	setCharacterText(step, "PASO 1 · NOMBRE Y CLASE", 9, Color3.fromRGB(200, 148, 69), "Mono")

	nameLabel.ZIndex = 3
	setCharacterText(nameLabel, "NOMBRE (3–16 CARACTERES)", 9, Color3.fromRGB(181, 167, 154), "Mono")

	nameBox.ZIndex = 4
	nameBox.BackgroundColor3 = Color3.fromRGB(14, 13, 12)
	nameBox.BackgroundTransparency = 0
	nameBox.BorderSizePixel = 0
	nameBox.TextColor3 = Color3.fromRGB(244, 237, 224)
	nameBox.PlaceholderText = "Escribe el nombre de tu personaje"
	nameBox.PlaceholderColor3 = Color3.fromRGB(139, 129, 120)
	nameBox.ClearTextOnFocus = false
	nameBox.TextSize = 16
	nameBox.TextScaled = false
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.TextYAlignment = Enum.TextYAlignment.Center
	nameBox.Font = characterFont("Body")
	ensureCorner(nameBox, UDim.new(0, 5))
	ensureStroke(nameBox, Color3.fromRGB(107, 74, 43), 0, 1)

	classLabel.ZIndex = 3
	setCharacterText(classLabel, "ELIGE UNA CLASE", 9, Color3.fromRGB(181, 167, 154), "Mono")
	classContainer.BackgroundTransparency = 1
	classContainer.BorderSizePixel = 0
	classContainer.ZIndex = 3
	classContainer.ClipsDescendants = false
	-- CharacterCreate ya trae un UIGridLayout horizontal del layout base.
	-- No debe competir con el UIListLayout responsive de estas opciones.
	local oldGridLayout = classContainer:FindFirstChildOfClass("UIGridLayout")
	if oldGridLayout then oldGridLayout:Destroy() end
	local classButtons = {}
	for _, classId in ipairs({"Paladin", "Hunter", "Cleric"}) do
		local button = classContainer:FindFirstChild("Class_" .. classId)
		if button and button:IsA("TextButton") then
			table.insert(classButtons, button)
		end
	end

	local compactCard = isCompact and not isPortrait
	local optionLayout = ensureCharacterButtonLayout(classContainer, compactCard and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical, compactCard and 8 or 8)
	local optionWidth
	local optionHeight
	if not isCompact then
		nameLabel.Position = UDim2.fromOffset(20, 76)
		nameLabel.Size = UDim2.fromOffset(panelWidth - 40, 18)
		nameBox.Position = UDim2.fromOffset(20, 96)
		nameBox.Size = UDim2.fromOffset(panelWidth - 40, 42)
		classLabel.Position = UDim2.fromOffset(20, 150)
		classLabel.Size = UDim2.fromOffset(panelWidth - 40, 18)
		classContainer.Position = UDim2.fromOffset(20, 174)
		classContainer.Size = UDim2.fromOffset(panelWidth - 40, 228)
		optionWidth = panelWidth - 40
		optionHeight = 68
		optionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		optionLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	elseif isPortrait then
		nameLabel.Position = UDim2.fromOffset(20, 58)
		nameLabel.Size = UDim2.fromOffset(panelWidth - 40, 16)
		nameBox.Position = UDim2.fromOffset(20, 78)
		nameBox.Size = UDim2.fromOffset(panelWidth - 40, 42)
		classLabel.Position = UDim2.fromOffset(20, 136)
		classLabel.Size = UDim2.fromOffset(panelWidth - 40, 16)
		optionHeight = math.clamp((panelHeight - 370) / 3, 76, 108)
		local contentHeight = optionHeight * 3 + 16
		classContainer.Position = UDim2.fromOffset(20, 158)
		classContainer.Size = UDim2.fromOffset(panelWidth - 40, contentHeight)
		optionWidth = panelWidth - 40
		optionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		optionLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	else
		nameLabel.Position = UDim2.fromOffset(20, 52)
		nameLabel.Size = UDim2.fromOffset(66, 40)
		nameLabel.TextYAlignment = Enum.TextYAlignment.Center
		nameBox.Position = UDim2.fromOffset(92, 52)
		nameBox.Size = UDim2.fromOffset(panelWidth - 112, 40)
		classLabel.Position = UDim2.fromOffset(20, 100)
		classLabel.Size = UDim2.fromOffset(panelWidth - 40, 16)
		classContainer.Position = UDim2.fromOffset(20, 122)
		local availableOptionHeight = math.max(90, panelHeight - 232)
		classContainer.Size = UDim2.fromOffset(panelWidth - 40, availableOptionHeight)
		optionWidth = (panelWidth - 40 - 16) / 3
		optionHeight = availableOptionHeight
		optionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		optionLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	end

	for index, button in ipairs(classButtons) do
		local classId = string.gsub(button.Name, "^Class_", "")
		button.LayoutOrder = index
		button.Size = UDim2.fromOffset(optionWidth, optionHeight)
		setupClassOption(button, classId, compactCard)
	end

	errorLabel.ZIndex = 4
	if isCompact and isPortrait then
		errorLabel.Position = UDim2.fromOffset(20, classContainer.Position.Y.Offset + classContainer.Size.Y.Offset + 10)
	else
		errorLabel.Position = UDim2.new(0, 20, 1, -88)
	end
	errorLabel.Size = UDim2.new(1, -40, 0, 22)
	errorLabel.TextWrapped = true
	setCharacterText(errorLabel, errorLabel.Text, 10, Color3.fromRGB(214, 138, 120), "Body")

	back.ZIndex = 4
	back.AnchorPoint = Vector2.new(0, 1)
	back.Position = UDim2.new(0, 20, 1, -16)
	back.Size = UDim2.new(isCompact and 0.34 or 0.20, -8, 0, isCompact and 42 or 40)
	back.Text = "VOLVER"
	back.TextSize = 10
	back.Font = characterFont("Mono")
	back.TextScaled = false
	back.TextColor3 = Color3.fromRGB(244, 237, 224)
	back.BorderSizePixel = 0
	ensureCorner(back, UDim.new(0, 5))

	confirm.ZIndex = 4
	confirm.AnchorPoint = Vector2.new(1, 1)
	confirm.Position = UDim2.new(1, -20, 1, -16)
	confirm.Size = UDim2.new(isCompact and 0.60 or 0.38, -8, 0, isCompact and 42 or 40)
	confirm.Text = "CREAR PERSONAJE"
	local createReady = confirm:GetAttribute("HearthboundCreateReady") == true
	confirm.Active = createReady
	confirm.AutoButtonColor = createReady
	confirm.BackgroundColor3 = createReady and Color3.fromRGB(200, 148, 69) or Color3.fromRGB(76, 62, 48)
	confirm.TextColor3 = createReady and Color3.fromRGB(21, 16, 13) or Color3.fromRGB(181, 167, 154)
	confirm.TextSize = 10
	confirm.Font = characterFont("Mono")
	confirm.TextScaled = false
	confirm.BorderSizePixel = 0
	ensureCorner(confirm, UDim.new(0, 5))
end

local function setAccent(parent, name, position, size, color)
	local accent = parent:FindFirstChild(name)
	if not accent then
		accent = Instance.new("Frame")
		accent.Name = name
		accent.Parent = parent
	end
	accent.Position = position
	accent.Size = size
	accent.BackgroundColor3 = color
	accent.BackgroundTransparency = 0
	accent.BorderSizePixel = 0
	accent.ZIndex = math.max(parent.ZIndex + 1, 2)
	ensureCorner(accent, UITheme.SmallCornerRadius)
	return accent
end

local function findFill(bar)
	for _, child in ipairs(bar:GetChildren()) do
		if child:IsA("Frame") and (has(child.Name, "fill") or has(child.Name, "progress")) then
			return child
		end
	end
	return nil
end

local function styleCombatBar(bar, fillColor)
	if not bar or not bar:IsA("GuiObject") then
		return
	end
	bar.BackgroundColor3 = COLORS.BarBackground
	bar.BackgroundTransparency = 0
	bar.BorderSizePixel = 0
	ensureCorner(bar, UITheme.SmallCornerRadius)
	local fill = findFill(bar)
	if fill then
		fill.BackgroundColor3 = fillColor
		fill.BackgroundTransparency = 0
		fill.BorderSizePixel = 0
		ensureCorner(fill, UITheme.SmallCornerRadius)
	end
	for _, child in ipairs(bar:GetChildren()) do
		if isTextObject(child) then
			child.Font = UITheme.GetFont("Mono")
			child.TextColor3 = COLORS.Parchment
			child.TextStrokeTransparency = 1
			child.TextXAlignment = Enum.TextXAlignment.Center
			child.TextYAlignment = Enum.TextYAlignment.Center
		end
	end
end

local function combatBarScale()
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	return math.min(1, math.max(0.65, (viewport.X - 24) / 428))
end

local function combatPixels(value, scale)
	return math.floor(value * scale + 0.5)
end

local function styleCombatSlot(slot)
	if not slot or not slot:IsA("GuiObject") then
		return
	end
	local scale = combatBarScale()
	local slotAspect = slot:FindFirstChildWhichIsA("UIAspectRatioConstraint")
	if slotAspect then slotAspect:Destroy() end
	local selected = slot:GetAttribute("Selected") == true
		or slot:GetAttribute("Active") == true
		or slot:GetAttribute("Equipped") == true
	slot.BackgroundColor3 = selected and COLORS.CombatSlotSelected or COLORS.CombatSlot
	slot.BackgroundTransparency = 0
	slot.BorderSizePixel = 0
	slot.ClipsDescendants = true
	ensureCorner(slot, UDim.new(0, combatPixels(5, scale)))
	ensureStroke(slot, selected and COLORS.Brass or COLORS.CombatStroke, 0, selected and 2 or 1)

	local icon = slot:FindFirstChild("SkillIcon") or slot:FindFirstChild("UseButton")
	if icon and icon:IsA("GuiObject") then
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		-- Imagen casi a sangre; queda 1 px libre para que el borde del slot siga visible.
		icon.Size = UDim2.new(1, -2, 1, -2)
		icon.BackgroundTransparency = 1
		icon.BorderSizePixel = 0
		icon.ClipsDescendants = true
		icon.ZIndex = slot.ZIndex + 1
		if icon:IsA("ImageButton") or icon:IsA("ImageLabel") then
			icon.ScaleType = Enum.ScaleType.Crop
		end
		ensureCorner(icon, UDim.new(0, combatPixels(4, scale)))
		local iconStroke = icon:FindFirstChildWhichIsA("UIStroke")
		if iconStroke then iconStroke.Transparency = 1 end
		local itemIcon = icon:FindFirstChild("Icon")
		if itemIcon and itemIcon:IsA("ImageLabel") then
			itemIcon.Position = UDim2.fromScale(0.5, 0.5)
			itemIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			itemIcon.Size = UDim2.fromScale(1, 1)
			itemIcon.BackgroundTransparency = 1
			itemIcon.ScaleType = Enum.ScaleType.Crop
			itemIcon.ZIndex = icon.ZIndex + 1
			ensureCorner(itemIcon, UDim.new(0, combatPixels(4, scale)))
			local itemIconStroke = itemIcon:FindFirstChildWhichIsA("UIStroke")
			if itemIconStroke then itemIconStroke.Transparency = 1 end
		end
	end

	local key = slot:FindFirstChild("Keybind", true) or slot:FindFirstChild("Key", true)
	if key and isTextObject(key) then
		key.AnchorPoint = Vector2.new(0, 0)
		key.Position = UDim2.fromOffset(combatPixels(7, scale), combatPixels(5, scale))
		key.Size = UDim2.fromOffset(combatPixels(14, scale), combatPixels(13, scale))
		key.BackgroundColor3 = COLORS.Shadow
		key.BackgroundTransparency = 0.35
		key.TextColor3 = selected and COLORS.BrassBright or COLORS.Parchment
		key.ZIndex = slot.ZIndex + 7
		ensureCorner(key, UDim.new(0, combatPixels(2, scale)))
		key.Font = Enum.Font.BuilderSansBold
		key.TextScaled = false
		key.TextStrokeTransparency = 1
		key.TextSize = combatPixels(11, scale)
	end

	local mana = slot:FindFirstChild("ManaCost", true)
	if mana then mana:Destroy() end
	local quantity = slot:FindFirstChild("Quantity", true)
	if quantity and isTextObject(quantity) then
		quantity.AnchorPoint = Vector2.new(1, 1)
		quantity.Position = UDim2.new(1, -combatPixels(4, scale), 1, -combatPixels(3, scale))
		quantity.Size = UDim2.fromOffset(combatPixels(25, scale), combatPixels(13, scale))
		quantity.BackgroundColor3 = COLORS.Shadow
		quantity.BackgroundTransparency = 0.35
		quantity.TextColor3 = COLORS.Parchment
		quantity.ZIndex = slot.ZIndex + 7
		ensureCorner(quantity, UDim.new(0, combatPixels(2, scale)))
		quantity.Font = Enum.Font.BuilderSansBold
		quantity.TextScaled = false
		quantity.TextXAlignment = Enum.TextXAlignment.Right
		quantity.TextStrokeTransparency = 1
		quantity.TextSize = combatPixels(10, scale)
	end

	local cd = slot:FindFirstChild("CDOverlay", true) or slot:FindFirstChild("Cooldown", true)
	if cd and cd:IsA("GuiObject") then
		cd.AnchorPoint = Vector2.new(0, 0)
		cd.Position = UDim2.fromOffset(1, 1)
		cd.Size = UDim2.new(1, -2, 1, -2)
		cd.ZIndex = slot.ZIndex + 4
		cd.BackgroundColor3 = COLORS.Shadow
		cd.BackgroundTransparency = 0.35
		ensureCorner(cd, UDim.new(0, combatPixels(4, scale)))
		local cdText = cd:FindFirstChild("CDText", true) or slot:FindFirstChild("CooldownLabel", true)
		if cdText and isTextObject(cdText) then
			cdText.Font = Enum.Font.BuilderSansBold
			cdText.TextColor3 = COLORS.Parchment
			cdText.TextScaled = false
			cdText.TextSize = combatPixels(18, scale)
			cdText.TextStrokeTransparency = 1
			cdText.ZIndex = cd.ZIndex + 1
		end
	end
	local assign = slot:FindFirstChild("AssignButton")
	if assign and assign:IsA("GuiObject") then assign.ZIndex = slot.ZIndex + 8 end
	if slot.Name:match("^Slot%d+$") then
		local rail = slot:FindFirstChild("HearthboundCooldownRail")
		if not rail then
			rail = Instance.new("Frame")
			rail.Name = "HearthboundCooldownRail"
			rail.BackgroundColor3 = COLORS.Brass
			rail.BorderSizePixel = 0
			rail.Size = UDim2.fromOffset(0, combatPixels(3, scale))
			rail.Visible = false
			rail.Parent = slot
		end
		rail.Position = UDim2.new(0, combatPixels(7, scale), 1, -combatPixels(7, scale))
		rail.ZIndex = (cd and cd.ZIndex or slot.ZIndex) + 1
		ensureCorner(rail, UDim.new(0, combatPixels(2, scale)))
	end
end

local function styleCombatElements(screenGui)
	if not screenGui then
		return
	end

	if screenGui.Name == "HUD" then
		-- Player Frame: composición de Pencil ampliada para lectura en juego.
		local playerFrame = screenGui:FindFirstChild("PlayerFrame")
		if playerFrame then
			local playerPanel = Color3.fromRGB(36, 27, 22)
			local brassStroke = Color3.fromRGB(107, 74, 43)
			local parchment = Color3.fromRGB(244, 237, 224)
			local playerAspect = playerFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
			if playerAspect then playerAspect:Destroy() end
			playerFrame.Size = UDim2.fromOffset(240, 88)
			playerFrame.BackgroundColor3 = playerPanel
			playerFrame.BackgroundTransparency = 0
			playerFrame.BorderSizePixel = 0
			playerFrame.ClipsDescendants = true
			ensureCorner(playerFrame, UDim.new(0, 8))
			ensureStroke(playerFrame, brassStroke, 0, 1)
			local playerGradient = playerFrame:FindFirstChild("HearthboundGradient")
			if playerGradient then
				playerGradient:Destroy()
			end

			local playerName = playerFrame:FindFirstChild("PlayerName")
			if playerName and isTextObject(playerName) then
				playerName.Position = UDim2.fromOffset(16, 10)
				playerName.Size = UDim2.fromOffset(208, 15)
				playerName.Font = UITheme.GetFont("Mono")
				playerName.TextSize = 11
				playerName.TextScaled = false
				playerName.TextWrapped = false
				playerName.TextColor3 = parchment
				playerName.TextXAlignment = Enum.TextXAlignment.Left
				playerName.TextYAlignment = Enum.TextYAlignment.Center
				playerName.TextStrokeTransparency = 1
			end

			local function configurePlayerBar(barName, y, trackColor, fillColor, height, textSize)
				local bar = playerFrame:FindFirstChild(barName)
				if not bar then
					return
				end
				bar.Position = UDim2.fromOffset(16, y)
				bar.Size = UDim2.fromOffset(208, height or 10)
				bar.AnchorPoint = Vector2.new(0, 0)
				bar.BackgroundColor3 = trackColor
				bar.BackgroundTransparency = 0
				bar.BorderSizePixel = 0
				ensureCorner(bar, UDim.new(0, 3))
				local fill = findFill(bar)
				if fill then
					fill.AnchorPoint = Vector2.new(0, 0)
					fill.Position = UDim2.fromScale(0, 0)
					fill.BackgroundColor3 = fillColor
					fill.BackgroundTransparency = 0
					fill.BorderSizePixel = 0
					ensureCorner(fill, UDim.new(0, 3))
				end
				local value = bar:FindFirstChildWhichIsA("TextLabel", true)
				if value then
					value.AnchorPoint = Vector2.new(0, 0)
					value.Position = UDim2.fromScale(0, 0)
					value.Size = UDim2.fromScale(1, 1)
					value.Font = UITheme.GetFont("Mono")
					value.TextSize = textSize or 8
					value.TextScaled = false
					value.TextWrapped = false
					value.TextColor3 = parchment
					value.TextXAlignment = Enum.TextXAlignment.Center
					value.TextYAlignment = Enum.TextYAlignment.Center
					value.TextStrokeTransparency = 1
				end
			end

			configurePlayerBar("PlayerHPBar", 35, Color3.fromRGB(49, 90, 58), Color3.fromRGB(108, 192, 139), 10, 8)
			configurePlayerBar("PlayerMPBar", 50, Color3.fromRGB(35, 75, 104), Color3.fromRGB(92, 156, 200), 10, 8)
			configurePlayerBar("PlayerXPBar", 65, Color3.fromRGB(63, 51, 40), Color3.fromRGB(200, 148, 69), 10, 8)

			-- El oro se mantiene actualizado por el sistema existente, pero no invade
			-- el card de Pencil; su presentación global se resolverá fuera de este frame.
			local goldFrame = playerFrame:FindFirstChild("GoldFrame")
			if goldFrame then
				goldFrame.Visible = false
			end
		end

		-- Target Frame: replica directa del frame esPal de Pencil (236x68).
		local targetFrame = screenGui:FindFirstChild("TargetFrame")
		if targetFrame then
			local targetPanel = Color3.fromRGB(33, 25, 22)
			local targetColor = Color3.fromRGB(184, 78, 91)
			local targetStatusColor = Color3.fromRGB(214, 138, 120)
			local selectedAllyUserId = AllyTargetState.GetUserId()
			local selectedAlly = selectedAllyUserId and Players:GetPlayerByUserId(selectedAllyUserId)
			if selectedAlly then
				local allyCharacter = selectedAlly.Character
				local allyHumanoid = allyCharacter and allyCharacter:FindFirstChildOfClass("Humanoid")
				targetColor = allyHumanoid and allyHumanoid.Health > 0
					and UITheme.Colors.LifeGreen or UITheme.Colors.CrimsonBright
				targetStatusColor = targetColor
			end
			local targetStroke = targetColor
			local parchment = Color3.fromRGB(244, 237, 224)
			local targetAspect = targetFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
			if targetAspect then targetAspect:Destroy() end
			local topLeftInset = GuiService:GetGuiInset()
			if player:GetAttribute("UILayoutManaged") ~= true then
				targetFrame.Position = UDim2.new(0.37, 0, 0, topLeftInset.Y + 20)
			end
			targetFrame.Size = UDim2.fromOffset(236, 68)
			targetFrame.BackgroundColor3 = targetPanel
			targetFrame.BackgroundTransparency = 0
			targetFrame.BorderSizePixel = 0
			targetFrame.ClipsDescendants = true
			ensureCorner(targetFrame, UDim.new(0, 8))
			ensureStroke(targetFrame, targetStroke, 0, 1)
			local targetGradient = targetFrame:FindFirstChild("HearthboundGradient")
			if targetGradient then
				targetGradient:Destroy()
			end

			local targetName = targetFrame:FindFirstChild("TargetName")
			if targetName and isTextObject(targetName) then
				targetName.Position = UDim2.fromOffset(12, 9)
				targetName.Size = UDim2.fromOffset(210, 12)
				targetName.Font = UITheme.GetFont("Mono")
				targetName.TextSize = 10
				targetName.TextScaled = false
				targetName.TextWrapped = false
				targetName.TextColor3 = parchment
				targetName.TextXAlignment = Enum.TextXAlignment.Left
				targetName.TextYAlignment = Enum.TextYAlignment.Center
				targetName.TextStrokeTransparency = 1
			end

			local status = targetFrame:FindFirstChild("TargetStatus")
			if status and isTextObject(status) then
				status.Position = UDim2.fromOffset(12, 25)
				status.Size = UDim2.fromOffset(150, 10)
				status.Font = UITheme.GetFont("Mono")
				status.TextSize = 8
				status.TextScaled = false
				status.TextWrapped = false
				status.TextColor3 = targetStatusColor
				status.TextXAlignment = Enum.TextXAlignment.Left
				status.TextYAlignment = Enum.TextYAlignment.Center
				status.TextStrokeTransparency = 1
				status.Visible = status.Text ~= ""
			end

			local targetBar = targetFrame:FindFirstChild("TargetHPBar")
			if targetBar then
				targetBar.Position = UDim2.fromOffset(12, 42)
				targetBar.Size = UDim2.fromOffset(204, 8)
				targetBar.AnchorPoint = Vector2.new(0, 0)
				targetBar.BackgroundColor3 = Color3.fromRGB(64, 33, 38)
				targetBar.BackgroundTransparency = 0
				targetBar.BorderSizePixel = 0
				ensureCorner(targetBar, UDim.new(0, 3))
				local targetFill = findFill(targetBar)
				if targetFill then
					targetFill.Position = UDim2.fromScale(0, 0)
					targetFill.BackgroundColor3 = targetStroke
					targetFill.BackgroundTransparency = 0
					targetFill.BorderSizePixel = 0
					ensureCorner(targetFill, UDim.new(0, 3))
				end
			end

			local targetText = targetFrame:FindFirstChild("TargetHPText", true)
			if targetText and isTextObject(targetText) then
				targetText.AnchorPoint = Vector2.new(0, 0)
				targetText.Position = UDim2.fromOffset(0, 11)
				targetText.Size = UDim2.fromOffset(180, 9)
				targetText.Font = UITheme.GetFont("Mono")
				targetText.TextSize = 7
				targetText.TextScaled = false
				targetText.TextWrapped = false
				targetText.TextColor3 = parchment
				targetText.TextXAlignment = Enum.TextXAlignment.Left
				targetText.TextYAlignment = Enum.TextYAlignment.Center
				targetText.TextStrokeTransparency = 1
			end
		end

		-- PlayerFrame y TargetFrame conservan en touch la misma base que en PC.
		-- El tamaño queda bajo control del usuario mediante UILayoutUserScale.

		local itemFrame = screenGui:FindFirstChild("ItemUseSlotsFrame", true)
		if itemFrame then
			local scale = combatBarScale()
			local slotSize = combatPixels(54, scale)
			local itemAspect = itemFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
			if itemAspect then itemAspect:Destroy() end
			itemFrame.Size = UDim2.fromOffset(combatPixels(144, scale), combatPixels(76, scale))
			itemFrame.BackgroundColor3 = COLORS.CombatPanel
			itemFrame.BackgroundTransparency = 0.20
			itemFrame.BorderSizePixel = 0
			ensureCorner(itemFrame, UDim.new(0, combatPixels(7, scale)))
			ensureStroke(itemFrame, COLORS.BrassDark, 0, 1)
			local itemLayout = itemFrame:FindFirstChildOfClass("UIListLayout")
			if itemLayout then
				itemLayout.FillDirection = Enum.FillDirection.Horizontal
				itemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				itemLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
				itemLayout.Padding = UDim.new(0, combatPixels(11, scale))
			end
			local itemPadding = itemFrame:FindFirstChild("HearthboundConsumablePadding")
			if not itemPadding then
				itemPadding = Instance.new("UIPadding")
				itemPadding.Name = "HearthboundConsumablePadding"
				itemPadding.Parent = itemFrame
			end
			itemPadding.PaddingLeft = UDim.new(0, combatPixels(10, scale))
			itemPadding.PaddingRight = UDim.new(0, combatPixels(10, scale))
			itemPadding.PaddingTop = UDim.new(0, combatPixels(11, scale))
			itemPadding.PaddingBottom = UDim.new(0, combatPixels(11, scale))
			for _, child in ipairs(itemFrame:GetChildren()) do
				if child.Name == "UseSlotZ" or child.Name == "UseSlotX" then
					child.Size = UDim2.fromOffset(slotSize, slotSize)
					styleCombatSlot(child)
				end
			end
		end
	elseif screenGui.Name == "SkillBar" then
		local bar = screenGui:FindFirstChild("BarContainer")
		if bar then
			local scale = combatBarScale()
			local skillWidth = combatPixels(270, scale)
			local consumableWidth = combatPixels(144, scale)
			local gap = combatPixels(14, scale)
			local slotSize = combatPixels(54, scale)
			local barAspect = bar:FindFirstChildWhichIsA("UIAspectRatioConstraint")
			if barAspect then barAspect:Destroy() end
			bar.AnchorPoint = Vector2.new(0.5, 1)
			if player:GetAttribute("UILayoutManaged") ~= true then
				bar.Position = UDim2.new(0.5, -math.floor((consumableWidth + gap) / 2), 1, -24)
			end
			bar.Size = UDim2.fromOffset(skillWidth, combatPixels(76, scale))
			bar:SetAttribute("HearthboundCombatGap", gap)
			bar.BackgroundColor3 = COLORS.CombatPanel
			bar.BackgroundTransparency = 0.20
			bar.BorderSizePixel = 0
			ensureCorner(bar, UDim.new(0, combatPixels(7, scale)))
			ensureStroke(bar, COLORS.BrassDark, 0, 1)
			local gradient = bar:FindFirstChild("HearthboundGradient")
			if gradient then gradient:Destroy() end
			local grid = bar:FindFirstChildOfClass("UIGridLayout")
			if grid then
				grid.FillDirection = Enum.FillDirection.Horizontal
				grid.FillDirectionMaxCells = 4
				grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
				grid.VerticalAlignment = Enum.VerticalAlignment.Center
				grid.CellSize = UDim2.fromOffset(slotSize, slotSize)
				grid.CellPadding = UDim2.fromOffset(combatPixels(11, scale), 0)
			end
			local padding = bar:FindFirstChild("HearthboundCombatPadding")
			if not padding then
				padding = Instance.new("UIPadding")
				padding.Name = "HearthboundCombatPadding"
				padding.Parent = bar
			end
			padding.PaddingLeft = UDim.new(0, combatPixels(10, scale))
			padding.PaddingRight = UDim.new(0, combatPixels(10, scale))
			padding.PaddingTop = UDim.new(0, combatPixels(11, scale))
			padding.PaddingBottom = UDim.new(0, combatPixels(11, scale))
			for _, child in ipairs(bar:GetChildren()) do
				if string.match(child.Name, "^Slot%d+$") then
					styleCombatSlot(child)
				end
			end
		end
	elseif screenGui.Name == "MicroMenuUI" or screenGui.Name == "MobileAccessUI" then
		local menu = screenGui:FindFirstChild("MicroMenuBar", true) or screenGui:FindFirstChild("MobileAccessStack", true)
		if menu then
			local isMobileMenu = menu.Name == "MobileAccessStack"
			menu.BackgroundColor3 = isMobileMenu and COLORS.CombatPanel or Color3.fromRGB(33, 25, 22)
			menu.BackgroundTransparency = isMobileMenu and 1 or 0
			menu.BorderSizePixel = 0
			ensureCorner(menu, UDim.new(0, isMobileMenu and 6 or 5))
			local menuGradient = menu:FindFirstChild("HearthboundGradient")
			if menuGradient then menuGradient:Destroy() end
			local menuStroke = menu:FindFirstChildWhichIsA("UIStroke")
			if isMobileMenu then
				if menuStroke then menuStroke.Transparency = 1 end
			else
				ensureStroke(menu, Color3.fromRGB(107, 74, 43), 0, 1)
				menu.Size = UDim2.fromOffset(280, 52)
				local constraint = menu:FindFirstChild("ResponsiveSize")
				if constraint and constraint:IsA("UISizeConstraint") then
					constraint.MinSize = Vector2.new(280, 52)
					constraint.MaxSize = Vector2.new(280, 52)
				end
				local padding = menu:FindFirstChild("PencilPadding")
				if not padding then
					padding = Instance.new("UIPadding")
					padding.Name = "PencilPadding"
					padding.Parent = menu
				end
				padding.PaddingLeft = UDim.new(0, 13)
				padding.PaddingRight = UDim.new(0, 13)
				padding.PaddingTop = UDim.new(0, 5)
				padding.PaddingBottom = UDim.new(0, 5)
				local layout = menu:FindFirstChildOfClass("UIListLayout")
				if layout then
					layout.FillDirection = Enum.FillDirection.Horizontal
					layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
					layout.VerticalAlignment = Enum.VerticalAlignment.Center
					layout.Padding = UDim.new(0, 6)
				end
			end
			for _, child in ipairs(menu:GetChildren()) do
				if child:IsA("TextButton") then
					styleButton(child)
					local selected = child.Name == "MenuButton"
					if isMobileMenu then
						child.BackgroundColor3 = selected and Color3.fromRGB(200, 148, 69) or Color3.fromRGB(23, 19, 17)
						child.BackgroundTransparency = 0
						child.TextColor3 = selected and Color3.fromRGB(21, 16, 13) or Color3.fromRGB(244, 237, 224)
						child.Font = UITheme.GetFont("BodyMedium")
						ensureCorner(child, UDim.new(0, 5))
						ensureStroke(child, selected and Color3.fromRGB(226, 174, 83) or Color3.fromRGB(107, 74, 43), 0, selected and 2 or 1)
					end
					child.TextScaled = isMobileMenu
					child.TextWrapped = false
					if isMobileMenu then
						child.Size = UDim2.fromOffset(44, 44)
					else
						child.Size = UDim2.fromOffset(46, 42)
						child.TextSize = 15
						local icon = child:FindFirstChild("Icon")
						if icon and icon:IsA("ImageLabel") then
							icon.AnchorPoint = Vector2.new(0.5, 0.5)
							icon.Position = UDim2.fromScale(0.5, 0.5)
							icon.Size = UDim2.new(1, -2, 1, -2)
							icon.BackgroundTransparency = 1
							icon.ImageColor3 = child:GetAttribute("HearthboundHovered") == true
								and Color3.fromRGB(255, 210, 112)
								or Color3.fromRGB(244, 237, 224)
							icon.ScaleType = Enum.ScaleType.Crop
							icon.ClipsDescendants = true
							ensureCorner(icon, UDim.new(0, 4))
							icon.ZIndex = child.ZIndex + 1
							local iconStroke = icon:FindFirstChildWhichIsA("UIStroke")
							if iconStroke then iconStroke.Transparency = 1 end
						end
					end
				end
			end
		end
	end
end

local function styleNativeInteractionDialog()
	local ok, descendants = pcall(function()
		return CoreGui:GetDescendants()
	end)
	if not ok then
		return
	end

	for _, obj in ipairs(descendants) do
		if obj.Name == "UserPrompt" and isTextObject(obj) then
			if obj.Text == "" or obj.Text == "Label" then
				obj.Text = "Interactuar"
			end
			obj.Font = UITheme.GetFont("BodyMedium")
			obj.TextColor3 = COLORS.Parchment
			obj.TextTransparency = 0
			obj.TextStrokeTransparency = 1
		end
	end
end

local function bindScreen(screenGui)
	if boundScreens[screenGui] then
		return
	end
	boundScreens[screenGui] = true

	for _, obj in ipairs(screenGui:GetDescendants()) do
		styleObject(obj)
	end
	applyResponsive(screenGui)
	styleCombatElements(screenGui)
	styleCharacterScreens(screenGui)

	local refreshQueued = false
	screenGui.DescendantAdded:Connect(function(obj)
		task.defer(function()
			if obj.Parent then
				styleObject(obj)
			end
		end)
		-- One layout pass per burst, not a full traversal for every new item.
		if refreshQueued then return end
		refreshQueued = true
		task.defer(function()
			refreshQueued = false
			if screenGui.Parent then
				applyResponsive(screenGui)
				styleCombatElements(screenGui)
				styleCharacterScreens(screenGui)
			end
		end)
	end)
end

for _, child in ipairs(playerGui:GetChildren()) do
	if child:IsA("ScreenGui") then
		bindScreen(child)
	end
end

playerGui.ChildAdded:Connect(function(child)
	if child:IsA("ScreenGui") then
		task.defer(function()
			if child.Parent then
				bindScreen(child)
			end
		end)
	end
end)

task.spawn(function()
	while playerGui.Parent do
		for _, screenGui in ipairs(playerGui:GetChildren()) do
			if screenGui:IsA("ScreenGui")
				and (screenGui.Name == "HUD"
					or screenGui.Name == "SkillBar"
					or screenGui.Name == "MicroMenuUI"
					or screenGui.Name == "MobileAccessUI") then
				styleCombatElements(screenGui)
			end
		end
		task.wait(0.35)
	end
end)

-- The custom prompt is event-driven; no repeated scan of Roblox CoreGui.
game:GetService("ProximityPromptService").PromptShown:Connect(function()
	task.defer(styleNativeInteractionDialog)
end)

local responsiveCameraConnection
local function refreshResponsiveScreens()
		for screenGui in pairs(boundScreens) do
			if screenGui.Parent then
				applyResponsive(screenGui)
				styleCharacterScreens(screenGui)
			end
		end
	end
local function bindResponsiveCamera()
	if responsiveCameraConnection then responsiveCameraConnection:Disconnect() end
	local camera = workspace.CurrentCamera
	if camera then
		responsiveCameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshResponsiveScreens)
	end
	refreshResponsiveScreens()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindResponsiveCamera)
bindResponsiveCamera()

print("[UIReskinClient] Hearthbound Gold theme applied to existing and dynamic UI")


