-- UITheme
-- Shared visual tokens and helpers for HU-ESTETICA-14.
-- This module contains presentation-only data; gameplay and remotes remain untouched.

local UITheme = {}

UITheme.Colors = {
	Canvas = Color3.fromRGB(21, 16, 13),
	Surface = Color3.fromRGB(36, 27, 22),
	SurfaceAlt = Color3.fromRGB(33, 25, 22),
	SurfaceRaised = Color3.fromRGB(48, 36, 28),
	Slot = Color3.fromRGB(45, 34, 28),
	BarBackground = Color3.fromRGB(24, 18, 15),
	CombatPanel = Color3.fromRGB(15, 13, 11),
	CombatSlot = Color3.fromRGB(23, 19, 17),
	CombatSlotSelected = Color3.fromRGB(42, 29, 18),
	CombatStroke = Color3.fromRGB(58, 44, 37),
	Parchment = Color3.fromRGB(244, 237, 224),
	Text = Color3.fromRGB(226, 215, 201),
	Muted = Color3.fromRGB(181, 167, 154),
	Brass = Color3.fromRGB(200, 148, 69),
	BrassBright = Color3.fromRGB(230, 186, 103),
	BrassDark = Color3.fromRGB(126, 84, 34),
	Crimson = Color3.fromRGB(177, 67, 61),
	CrimsonBright = Color3.fromRGB(218, 94, 85),
	ArcaneBlue = Color3.fromRGB(73, 139, 190),
	ArcaneBlueBright = Color3.fromRGB(103, 185, 228),
	LifeGreen = Color3.fromRGB(78, 163, 96),
	LifeGreenBright = Color3.fromRGB(111, 202, 121),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
}

-- All interface text uses the BuilderSans family; weights provide hierarchy.
UITheme.Fonts = {
	Title = Enum.Font.BuilderSansBold,
	Body = Enum.Font.BuilderSans,
	BodyMedium = Enum.Font.BuilderSansMedium,
	BodyBold = Enum.Font.BuilderSansBold,
	Mono = Enum.Font.BuilderSans,
}

UITheme.CornerRadius = UDim.new(0, 8)
UITheme.SmallCornerRadius = UDim.new(0, 5)
UITheme.OpenTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
UITheme.HoverTween = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
UITheme.PopupTween = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function UITheme.GetFont(role)
	return UITheme.Fonts[role] or UITheme.Fonts.Body
end

function UITheme.GetButtonColors(variant)
	if variant == "Primary" then
		return UITheme.Colors.Brass, UITheme.Colors.BrassBright, UITheme.Colors.Parchment
	elseif variant == "Danger" then
		return UITheme.Colors.Crimson, UITheme.Colors.CrimsonBright, UITheme.Colors.Parchment
	elseif variant == "Close" then
		return UITheme.Colors.SurfaceRaised, UITheme.Colors.Brass, UITheme.Colors.Muted
	end
	return UITheme.Colors.SurfaceRaised, UITheme.Colors.Brass, UITheme.Colors.Text
end

function UITheme.GetBarColor(name)
	local value = string.lower(name or "")
	if string.find(value, "xp", 1, true) or string.find(value, "experience", 1, true) then
		return UITheme.Colors.Brass
	elseif string.find(value, "mp", 1, true) or string.find(value, "mana", 1, true) then
		return UITheme.Colors.ArcaneBlue
	elseif string.find(value, "hp", 1, true) or string.find(value, "health", 1, true) then
		return UITheme.Colors.Crimson
	end
	return UITheme.Colors.Brass
end

function UITheme.IsTitle(name)
	local value = string.lower(name or "")
	return value == "title"
		or value == "statsTitle"
		or value == "slotlabel"
		or string.find(value, "header", 1, true) ~= nil
end

function UITheme.IsMuted(name)
	local value = string.lower(name or "")
	return value == "subtitle"
		or value == "infolabel"
		or value == "hintlabel"
		or value == "description"
		or value == "bind"
		or value == "levelreq"
		or string.find(value, "feedback", 1, true) ~= nil
end

return UITheme
