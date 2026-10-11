--[[
	TalentClient v2 - Vandrheim Fase R5.1 (HU-R5.1)
	Cliente: árbol de talentos tipo WoW con 3 ramas visuales,
	prereqs en cadena, gates por puntos y nivel. Nodos Passive/Skill.
	Tecla T para abrir/cerrar. NPC Trainer via ProximityPrompt.
	Remotes v2: RequestTalentTree, TalentTreeData, RequestSpendTalentPoint,
	TalentPointSpent, RequestRespec, RespecResult.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local VendorConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("VendorConfig"))
local UITheme = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("UITheme"))
local BLACK_CELL = UITheme.Colors.Shadow

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Remotes v2
local RequestTalentTree = Remotes:WaitForChild("RequestTalentTree")
local RequestSpendTalentPoint = Remotes:WaitForChild("RequestSpendTalentPoint")
local RequestRespec = Remotes:WaitForChild("RequestRespec")
local TalentTreeData = Remotes:WaitForChild("TalentTreeData")
local TalentPointSpent = Remotes:WaitForChild("TalentPointSpent")
local RespecResult = Remotes:WaitForChild("RespecResult")

-- UI references
local talentGui = playerGui:WaitForChild("TalentUI")
local mainFrame = talentGui:WaitForChild("MainFrame")
local nodesContainer = mainFrame:WaitForChild("NodesContainer")
local pointsLabel = mainFrame:WaitForChild("PointsLabel")
local specLabel = mainFrame:WaitForChild("SpecLabel")
local respecBtn = mainFrame:WaitForChild("RespecButton")
local closeBtn = mainFrame:WaitForChild("CloseButton")
local errorLabel = mainFrame:WaitForChild("ErrorLabel")

-- State
local isTalentOpen = false
local currentData = nil
local browsingSpecId = nil
local shellReady = false
local aspectConstraint
local titleLabel
local characterLabel
local treeMeta
local tooltipFrame, tooltipTitle, tooltipType, tooltipEffect, tooltipReq
local tooltipIcon, tooltipDivider, tooltipEffectHeader
local legendFrame, noPointsFeedback, respecDialog, respecConfirm, respecCancel, footerLabel
local backToSpecsButton

-- Spec display names
local SPEC_NAMES = {
	["Paladin_Protector"] = "Paladín - Protector",
	["Paladin_Castigo"] = "Paladín - Castigo",
	["Hunter_Assault"] = "Cazador - Asalto",
	["Hunter_Punteria"] = "Cazador - Puntería",
	["Cleric_Misericordia"] = "Clérigo - Misericordia",
	["Cleric_Colera"] = "Clérigo - Cólera",
}

local EFFECT_NAMES = {
	MaxHPMult = "Vida",
	DEFMult = "Def",
	ATKMult = "Atq",
	MaxMPMult = "Mana",
	MATKMult = "MATK",
	CooldownReduction = "CDR",
	CritBonus = "Crit",
	ThreatMult = "Amenaza",
}

-- ============================================================================
-- Helpers
-- ============================================================================

local function showError(msg)
	errorLabel.Text = msg or ""
	errorLabel.Visible = msg ~= nil and msg ~= ""
	if noPointsFeedback then
		noPointsFeedback.Visible = msg and string.find(string.lower(msg), "punto") ~= nil or false
	end
	task.delay(3, function()
		if errorLabel.Text == msg then
			errorLabel.Text = ""
			errorLabel.Visible = false
		end
	end)
end

local function clearNodes()
	for _, child in ipairs(nodesContainer:GetChildren()) do
		if child:IsA("GuiButton") or child:IsA("Frame") or child:IsA("TextLabel") then
			if child.Name ~= "BranchBg" then
				child:Destroy()
			end
		end
	end
end


local function makeCorner(parent, radius)
	local corner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function makeStroke(parent, color, thickness)
	local stroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0
	stroke.Parent = parent
	return stroke
end

local function makeLabel(parent, name, text, size, position, color, font, textSize)
	local label = parent:FindFirstChild(name)
	if not label then
		label = Instance.new("TextLabel")
		label.Name = name
		label.Parent = parent
	end
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text or ""
	label.TextColor3 = color or Color3.fromRGB(244, 237, 224)
	label.Font = font or Enum.Font.Gotham
	label.TextSize = textSize or 12
	label.TextScaled = false
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	local parentZIndex = parent:IsA("GuiObject") and parent.ZIndex or 0
	label.ZIndex = math.max(5, parentZIndex + 1)
	return label
end

local function showNodeTooltip(btn)
	if not tooltipFrame or not btn then return end
	local nodeName = btn:GetAttribute("TalentNodeName") or "Talento"
	local nodeType = btn:GetAttribute("TalentNodeType") or "Passive"
	local effect = btn:GetAttribute("TalentNodeEffect") or ""
	local rank = btn:GetAttribute("TalentNodeRank") or 0
	local maxRank = btn:GetAttribute("TalentNodeMaxRank") or 1
	local levelReq = btn:GetAttribute("TalentNodeLevelReq") or 1
	local pointsReq = btn:GetAttribute("TalentNodePointsRequired") or 0
	local prereqCount = btn:GetAttribute("TalentNodePrereqCount") or 0

	tooltipTitle.Text = nodeName
	tooltipType.Text = string.upper(nodeType == "Skill" and "HABILIDAD" or "PASIVA") .. "  ·  RANGO " .. rank .. "/" .. maxRank
	tooltipIcon.Text = nodeType == "Skill" and "✦" or "◇"
	tooltipIcon.BackgroundColor3 = nodeType == "Skill" and Color3.fromRGB(104, 70, 130) or Color3.fromRGB(82, 73, 93)
	tooltipEffect.Text = effect ~= "" and effect or "Sin efecto adicional"
	local requirements = "Nivel " .. tostring(levelReq)
	if pointsReq > 0 then requirements = requirements .. "  ·  Tier: ≥" .. tostring(pointsReq) .. " puntos" end
	if prereqCount > 0 then requirements = requirements .. "  ·  Requiere nodo anterior" end
	tooltipReq.Text = requirements
	tooltipFrame.Visible = true
end

local function hideNodeTooltip()
	-- El tooltip permanece como panel de contexto, igual que en la referencia de Pencil.
end

local function resetNodeTooltip()
	if not tooltipFrame then return end
	tooltipIcon.Text = "◇"
	tooltipIcon.BackgroundColor3 = Color3.fromRGB(82, 73, 93)
	tooltipTitle.Text = "SELECCIONA UN TALENTO"
	tooltipType.Text = "PASIVA  ·  RANGO 0/1"
	tooltipEffect.Text = "Pasa el cursor sobre un nodo para ver sus detalles."
	tooltipReq.Text = "Requisitos y gates aparecerán aquí."
	tooltipFrame.Visible = true
end

local function styleNodeButton(btn)
	if not btn:IsA("TextButton") then return end
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local compactPortrait = UserInputService.TouchEnabled and viewport.X < viewport.Y * 1.15
	local compactTouch = UserInputService.TouchEnabled
	local state = btn:GetAttribute("TalentState") or "blocked"
	local palette = {
		learned = { bg = Color3.fromRGB(58, 44, 37), stroke = Color3.fromRGB(200, 148, 69), text = Color3.fromRGB(244, 237, 224), badge = "APREN.", badgeText = Color3.fromRGB(32, 24, 19) },
		available = { bg = Color3.fromRGB(32, 51, 64), stroke = Color3.fromRGB(143, 183, 214), text = Color3.fromRGB(232, 241, 246), badge = "DISP.", badgeText = Color3.fromRGB(16, 31, 41) },
		blocked = { bg = Color3.fromRGB(23, 19, 17), stroke = Color3.fromRGB(82, 73, 93), text = Color3.fromRGB(170, 160, 153), badge = "BLOQ.", badgeText = Color3.fromRGB(235, 226, 238) },
		maxed = { bg = Color3.fromRGB(58, 44, 37), stroke = Color3.fromRGB(244, 211, 125), text = Color3.fromRGB(255, 245, 219), badge = "MAX", badgeText = Color3.fromRGB(39, 27, 15) },
	}
	local colors = palette[state] or palette.blocked
	btn:SetAttribute("HearthboundBlackCell", true)
	btn:SetAttribute("HearthboundCellBaseStrokeColor", colors.stroke)
	btn:SetAttribute("HearthboundCellBaseStrokeThickness", (state == "available" or state == "maxed") and 1.5 or 1)
	btn:SetAttribute("HearthboundCellBaseStrokeTransparency", 0)
	btn.BackgroundColor3 = BLACK_CELL
	btn.Size = UDim2.new(0.9, 0, 0, compactPortrait and 48 or compactTouch and 60 or 84)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.TextTransparency = 1
	btn.ZIndex = 3
	makeCorner(btn, 9)
	local stateStroke = (state == "available" or state == "maxed") and 1.5 or 1
	makeStroke(btn, colors.stroke, stateStroke)

	local stateBadge = btn:FindFirstChild("StateBadge") or Instance.new("TextLabel")
	stateBadge.Name = "StateBadge"
	stateBadge.Parent = btn
	stateBadge.Size = UDim2.new(0, compactPortrait and 36 or compactTouch and 46 or 54, 0, compactPortrait and 10 or compactTouch and 13 or 16)
	stateBadge.Position = UDim2.new(1, compactPortrait and -40 or compactTouch and -51 or -60, 0, compactPortrait and 2 or compactTouch and 3 or 5)
	stateBadge.BackgroundColor3 = colors.stroke
	stateBadge.BackgroundTransparency = state == "blocked" and 0.35 or 0.05
	stateBadge.Text = colors.badge or state
	stateBadge.TextColor3 = colors.badgeText or Color3.fromRGB(255, 255, 255)
	stateBadge.Font = UITheme.GetFont("BodyBold")
	stateBadge.TextSize = compactPortrait and 7 or compactTouch and 8 or 9
	stateBadge.TextScaled = false
	stateBadge.TextXAlignment = Enum.TextXAlignment.Center
	stateBadge.ZIndex = 6
	makeCorner(stateBadge, 4)

	local stateAccent = btn:FindFirstChild("StateAccent") or Instance.new("Frame")
	stateAccent.Name = "StateAccent"
	stateAccent.Parent = btn
	stateAccent.Size = UDim2.new(0, 4, 1, -14)
	stateAccent.Position = UDim2.new(0, 4, 0, 7)
	stateAccent.BackgroundColor3 = colors.stroke
	stateAccent.BackgroundTransparency = state == "blocked" and 0.25 or 0
	stateAccent.BorderSizePixel = 0
	stateAccent.ZIndex = 5
	makeCorner(stateAccent, 2)

	local stateBorder = btn:FindFirstChild("StateBorder") or Instance.new("Frame")
	stateBorder.Name = "StateBorder"
	stateBorder.Parent = btn
	stateBorder.Size = UDim2.new(1, 0, 1, 0)
	stateBorder.Position = UDim2.new(0, 0, 0, 0)
	stateBorder.BackgroundTransparency = 1
	stateBorder.BorderSizePixel = 0
	stateBorder.Active = false
	stateBorder.ZIndex = 6
	makeCorner(stateBorder, 9)
	local stateBorderStroke = stateBorder:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stateBorderStroke.Color = colors.stroke
	stateBorderStroke.Thickness = 1.25
	stateBorderStroke.Transparency = 0
	stateBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stateBorderStroke.Parent = stateBorder

	local rawText = btn:GetAttribute("TalentRawText") or ""
	local lines = string.split(rawText, "\n")
	local nodeName = btn:GetAttribute("TalentNodeName") or lines[1] or "Talento"
	local cleanName = string.gsub(nodeName, " %[%s*Skill%s*%]", "")
	local nodeType = btn:GetAttribute("TalentNodeType") or (string.find(nodeName, "%[Skill%]") and "Skill" or "Passive")
	local rank = btn:GetAttribute("TalentNodeRank") or 0
	local maxRank = btn:GetAttribute("TalentNodeMaxRank") or 1
	local effect = btn:GetAttribute("TalentNodeEffect") or ""
	local levelReq = btn:GetAttribute("TalentNodeLevelReq") or 1

	local icon = btn:FindFirstChild("NodeIcon") or Instance.new("TextLabel")
	icon.Name = "NodeIcon"
	icon.Parent = btn
	icon.Visible = not compactPortrait
	icon.Size = UDim2.new(0, compactTouch and 20 or 28, 0, compactTouch and 20 or 28)
	icon.Position = UDim2.new(0, compactTouch and 7 or 12, 0, compactTouch and 5 or 8)
	icon.BackgroundColor3 = nodeType == "Skill" and Color3.fromRGB(104, 70, 130) or Color3.fromRGB(82, 73, 93)
	icon.BackgroundTransparency = 0.1
	icon.Text = nodeType == "Skill" and "✦" or "◇"
	icon.TextColor3 = Color3.fromRGB(255, 248, 226)
	icon.Font = UITheme.GetFont("BodyBold")
	icon.TextSize = compactTouch and 13 or 17
	icon.TextScaled = false
	icon.ZIndex = 5
	makeCorner(icon, 7)

	local title = btn:FindFirstChild("NodeTitle") or Instance.new("TextLabel")
	title.Name = "NodeTitle"
	title.Parent = btn
	local titleLeftInset = compactPortrait and 4 or compactTouch and 34 or 48
	local badgeLeftInset = compactPortrait and 40 or compactTouch and 51 or 60
	local titleBadgeGap = 4
	title.Size = UDim2.new(1, -(titleLeftInset + badgeLeftInset + titleBadgeGap), 0, compactPortrait and 12 or compactTouch and 16 or 20)
	title.Position = UDim2.new(0, titleLeftInset, 0, compactPortrait and 1 or compactTouch and 2 or 5)
	title.BackgroundTransparency = 1
	title.Text = cleanName
	title.TextColor3 = colors.text
	title.Font = UITheme.GetFont("BodyBold")
	title.TextSize = compactPortrait and 8 or compactTouch and 10 or 14
	title.TextScaled = false
	title.TextWrapped = false
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.ZIndex = 5

	local typeLabel = btn:FindFirstChild("NodeType") or Instance.new("TextLabel")
	typeLabel.Name = "NodeType"
	typeLabel.Parent = btn
	typeLabel.Visible = not compactTouch
	typeLabel.Size = UDim2.new(1, compactTouch and -42 or -56, 0, compactTouch and 9 or 13)
	typeLabel.Position = UDim2.new(0, compactTouch and 34 or 48, 0, compactTouch and 19 or 26)
	typeLabel.BackgroundTransparency = 1
	typeLabel.Text = nodeType == "Skill" and "HABILIDAD ACTIVA" or "PASIVA"
	typeLabel.TextColor3 = nodeType == "Skill" and Color3.fromRGB(180, 138, 222) or Color3.fromRGB(181, 167, 154)
	typeLabel.Font = UITheme.GetFont("BodyBold")
	typeLabel.TextSize = compactTouch and 7 or 10
	typeLabel.TextScaled = false
	typeLabel.TextXAlignment = Enum.TextXAlignment.Left
	typeLabel.ZIndex = 5

	local effectLabel = btn:FindFirstChild("NodeEffect") or Instance.new("TextLabel")
	effectLabel.Name = "NodeEffect"
	effectLabel.Parent = btn
	effectLabel.Size = UDim2.new(1, compactPortrait and -8 or compactTouch and -42 or -56, 0, compactPortrait and 10 or compactTouch and 11 or 17)
	effectLabel.Position = UDim2.new(0, compactPortrait and 4 or compactTouch and 34 or 48, 0, compactPortrait and 15 or compactTouch and 29 or 41)
	effectLabel.BackgroundTransparency = 1
	effectLabel.Text = effect
	effectLabel.TextColor3 = Color3.fromRGB(220, 205, 183)
	effectLabel.Font = UITheme.GetFont("Body")
	effectLabel.TextSize = compactPortrait and 7 or compactTouch and 8 or 10
	effectLabel.TextScaled = false
	effectLabel.TextXAlignment = Enum.TextXAlignment.Left
	effectLabel.TextTruncate = Enum.TextTruncate.AtEnd
	effectLabel.ZIndex = 5

	if compactTouch and not compactPortrait then
		title.Position = UDim2.fromScale(0.06, 0.44)
		title.Size = UDim2.fromScale(0.88, 0.34)
		title.TextWrapped = true
		title.TextSize = 10
		effectLabel.Visible = false -- El efecto completo se consulta en el detalle al tocar.
	else
		effectLabel.Visible = true
	end

	local pips = btn:FindFirstChild("NodePips") or Instance.new("TextLabel")
	pips.Name = "NodePips"
	pips.Parent = btn
	pips.Size = UDim2.new(0, compactTouch and 30 or 56, 0, compactTouch and 9 or 14)
	pips.Position = UDim2.new(1, compactTouch and -34 or -64, 1, compactTouch and -10 or -18)
	pips.BackgroundTransparency = 1
	pips.Text = string.rep("●", math.min(rank, maxRank)) .. string.rep("○", math.max(maxRank - rank, 0))
	pips.TextColor3 = state == "blocked" and Color3.fromRGB(105, 95, 104) or colors.stroke
	pips.Font = UITheme.GetFont("BodyBold")
	pips.TextSize = compactTouch and 7 or 10
	pips.TextScaled = false
	pips.TextXAlignment = Enum.TextXAlignment.Right
	pips.ZIndex = 5

	local gate = btn:FindFirstChild("NodeGate") or Instance.new("TextLabel")
	gate.Name = "NodeGate"
	gate.Parent = btn
	gate.Size = UDim2.new(0, compactTouch and 36 or 54, 0, compactTouch and 9 or 14)
	gate.Position = UDim2.new(0, compactPortrait and 4 or compactTouch and 34 or 48, 1, compactTouch and -10 or -18)
	gate.BackgroundTransparency = 1
	gate.Text = "NIVEL " .. tostring(levelReq)
	gate.TextColor3 = state == "blocked" and Color3.fromRGB(130, 119, 114) or Color3.fromRGB(198, 148, 69)
	gate.Font = UITheme.GetFont("BodyMedium")
	gate.TextSize = compactTouch and 7 or 9
	gate.TextScaled = false
	gate.TextXAlignment = Enum.TextXAlignment.Left
	gate.ZIndex = 5

	-- UIReskinClient styles dynamic labels asynchronously; preserve this node-specific typography.
	for _, label in ipairs({ stateBadge, icon, title, typeLabel, effectLabel, pips, gate }) do
		label:SetAttribute("HearthboundCustomTextStyle", true)
	end
end

local function styleSpecButton(btn)
	if not btn:IsA("TextButton") then return end
	btn.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
	btn.TextColor3 = Color3.fromRGB(244, 237, 224)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextScaled = false
	btn.TextWrapped = true
	btn.AutoButtonColor = false
	btn.ZIndex = 3
	makeCorner(btn, 7)
	makeStroke(btn, Color3.fromRGB(107, 74, 43), 1)
end

local applyResponsiveLayout

local function refreshTalentVisuals()
	if not shellReady then return end
	applyResponsiveLayout()

	for _, child in ipairs(nodesContainer:GetChildren()) do
		if child:IsA("Frame") and string.sub(child.Name, 1, 7) == "Branch_" then
			child.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
			child.BackgroundTransparency = 0
			child.ZIndex = 1
			makeCorner(child, 8)
			makeStroke(child, Color3.fromRGB(107, 74, 43), 1)
			local title = child:FindFirstChild("BranchTitle")
			if title and title:IsA("TextLabel") then
				title.BackgroundTransparency = 1
				title.TextColor3 = Color3.fromRGB(200, 148, 69)
				title.Font = Enum.Font.GothamBold
				title.TextSize = 12
				title.TextScaled = false
				title.ZIndex = 4
			end
			local connector = child:FindFirstChild("BranchConnector")
			if not connector then
				connector = Instance.new("Frame")
				connector.Name = "BranchConnector"
				connector.Parent = child
			end
			local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
			local compactPortrait = UserInputService.TouchEnabled and viewport.X < viewport.Y * 1.15
			local compactTouch = UserInputService.TouchEnabled
			local connectorTop = compactPortrait and 38 or compactTouch and 42 or 58
			connector.Size = UDim2.new(0, 2, 1, -connectorTop - 14)
			connector.Position = UDim2.new(0.5, -1, 0, connectorTop)
			connector.BackgroundColor3 = Color3.fromRGB(200, 148, 69)
			connector.BackgroundTransparency = 0.55
			connector.BorderSizePixel = 0
			connector.ZIndex = 2
			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("TextButton") and string.sub(descendant.Name, 1, 5) == "Node_" then
					styleNodeButton(descendant)
				end
			end
		end
		if child:IsA("TextButton") and string.sub(child.Name, 1, 5) == "Spec_" then
			styleSpecButton(child)
		end
	end

	for _, descendant in ipairs(nodesContainer:GetDescendants()) do
		if descendant:IsA("TextButton") and string.sub(descendant.Name, 1, 5) == "Spec_" then
			styleSpecButton(descendant)
		end
	end
end

applyResponsiveLayout = function()
	if not shellReady then return end
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local portrait = viewport.X < viewport.Y * 1.15
	local narrow = viewport.X < 760
	local touch = UserInputService.TouchEnabled

	if portrait then
		mainFrame.Size = UDim2.new(0.94, 0, 0.94, 0)
		mainFrame.Position = UDim2.new(0.03, 0, 0.03, 0)
		if aspectConstraint then aspectConstraint.AspectRatio = 0.70 end
		nodesContainer.Size = UDim2.new(0.93, 0, 0.43, 0)
		nodesContainer.Position = UDim2.new(0.035, 0, 0.17, 0)
		tooltipFrame.Size = UDim2.new(0.93, 0, 0.17, 0)
		tooltipFrame.Position = UDim2.new(0.035, 0, 0.63, 0)
		legendFrame.Size = UDim2.new(0.44, 0, 0.13, 0)
		legendFrame.Position = UDim2.new(0.035, 0, 0.81, 0)
		noPointsFeedback.Size = UDim2.new(0.44, 0, 0.13, 0)
		noPointsFeedback.Position = UDim2.new(0.52, 0, 0.81, 0)
		respecBtn.Size = UDim2.new(0.44, 0, 0.06, 0)
		respecBtn.Position = UDim2.new(0.52, 0, 0.95, 0)
		footerLabel.Visible = false
	elseif touch then
		mainFrame.Size = UDim2.new(0.96, 0, 0.92, 0)
		mainFrame.Position = UDim2.new(0.02, 0, 0.04, 0)
		if aspectConstraint then aspectConstraint.AspectRatio = 2.05 end
		nodesContainer.Size = UDim2.new(0.66, 0, 0.78, 0)
		nodesContainer.Position = UDim2.new(0.025, 0, 0.17, 0)
		tooltipFrame.Size = UDim2.new(0.28, 0, 0.46, 0)
		tooltipFrame.Position = UDim2.new(0.70, 0, 0.17, 0)
		legendFrame.Size = UDim2.new(0.13, 0, 0.18, 0)
		legendFrame.Position = UDim2.new(0.70, 0, 0.65, 0)
		noPointsFeedback.Size = UDim2.new(0.13, 0, 0.18, 0)
		noPointsFeedback.Position = UDim2.new(0.85, 0, 0.65, 0)
		respecBtn.Size = UDim2.new(0.28, 0, 0.08, 0)
		respecBtn.Position = UDim2.new(0.70, 0, 0.86, 0)
		footerLabel.Visible = false
	elseif narrow then
		mainFrame.Size = UDim2.new(0.94, 0, 0.88, 0)
		mainFrame.Position = UDim2.new(0.03, 0, 0.06, 0)
		if aspectConstraint then aspectConstraint.AspectRatio = 1.45 end
		nodesContainer.Size = UDim2.new(0.93, 0, 0.54, 0)
		nodesContainer.Position = UDim2.new(0.035, 0, 0.18, 0)
		tooltipFrame.Size = UDim2.new(0.45, 0, 0.18, 0)
		tooltipFrame.Position = UDim2.new(0.515, 0, 0.75, 0)
		legendFrame.Size = UDim2.new(0.44, 0, 0.18, 0)
		legendFrame.Position = UDim2.new(0.035, 0, 0.75, 0)
		noPointsFeedback.Visible = false
		respecBtn.Size = UDim2.new(0.44, 0, 0.06, 0)
		respecBtn.Position = UDim2.new(0.515, 0, 0.94, 0)
		footerLabel.Visible = false
	else
		mainFrame.Size = UDim2.new(0.82, 0, 0.80, 0)
		mainFrame.Position = UDim2.new(0.09, 0, 0.10, 0)
		if aspectConstraint then aspectConstraint.AspectRatio = 1.62 end
		nodesContainer.Size = UDim2.new(0.63, 0, 0.64, 0)
		nodesContainer.Position = UDim2.new(0.035, 0, 0.21, 0)
		tooltipFrame.Size = UDim2.new(0.29, 0, 0.29, 0)
		tooltipFrame.Position = UDim2.new(0.70, 0, 0.21, 0)
		legendFrame.Size = UDim2.new(0.29, 0, 0.19, 0)
		legendFrame.Position = UDim2.new(0.70, 0, 0.53, 0)
		noPointsFeedback.Size = UDim2.new(0.29, 0, 0.19, 0)
		noPointsFeedback.Position = UDim2.new(0.70, 0, 0.53, 0)
		respecBtn.Size = UDim2.new(0.29, 0, 0.08, 0)
		respecBtn.Position = UDim2.new(0.70, 0, 0.76, 0)
		footerLabel.Visible = true
	end

	local dialogParent = respecDialog
	if touch and not portrait then
		tooltipTitle.TextSize = 12
		tooltipTitle.Size = UDim2.fromScale(0.70, 0.20)
		tooltipType.Position = UDim2.fromScale(0.20, 0.28)
		tooltipReq.Position = UDim2.fromScale(0.06, 0.77)
		tooltipReq.Size = UDim2.fromScale(0.88, 0.19)
		if tooltipEffect.Text == "Pasa el cursor sobre un nodo para ver sus detalles." then
			tooltipEffect.Text = "Toca un talento para ver sus detalles."
		end
		respecBtn.Position = UDim2.fromScale(0.70, 0.84)
		respecBtn.Size = UDim2.fromScale(0.28, math.max(0.08, 44 / math.max(1, mainFrame.AbsoluteSize.Y)))
	else
		tooltipTitle.TextSize = 16
		tooltipTitle.Size = UDim2.fromScale(0.70, 0.16)
		tooltipType.Position = UDim2.fromScale(0.20, 0.25)
		tooltipReq.Position = UDim2.fromScale(0.06, 0.79)
		tooltipReq.Size = UDim2.fromScale(0.88, 0.16)
	end
	if dialogParent then
		dialogParent.Size = tooltipFrame.Size
		dialogParent.Position = tooltipFrame.Position
	end
end

local function showRespecDialog(cost)
	if not respecDialog then return end
	respecDialog.Visible = true
	respecDialog:SetAttribute("RespecCost", cost)
	respecConfirm.Text = "CONFIRMAR · " .. tostring(cost) .. " ORO"
	respecDialog.BackgroundTransparency = 0
	respecDialog.Position = tooltipFrame.Position
end

local function setupTalentReskin()
	if shellReady then return end
	shellReady = true
	aspectConstraint = mainFrame:FindFirstChildOfClass("UIAspectRatioConstraint")
	if not aspectConstraint then
		aspectConstraint = Instance.new("UIAspectRatioConstraint")
		aspectConstraint.Parent = mainFrame
	end
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(21, 16, 13)
	mainFrame.BackgroundTransparency = 0
	mainFrame.ClipsDescendants = false
	makeCorner(mainFrame, 12)
	makeStroke(mainFrame, Color3.fromRGB(200, 148, 69), 1)

	titleLabel = mainFrame:FindFirstChild("Title")
	titleLabel.Size = UDim2.new(0.62, 0, 0.06, 0)
	titleLabel.Position = UDim2.new(0.035, 0, 0.025, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "TALENTOS"
	titleLabel.TextColor3 = Color3.fromRGB(244, 237, 224)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.TextScaled = false
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 5

	characterLabel = makeLabel(mainFrame, "CharacterLabel", "EIRIK  ·  NIVEL 16", UDim2.new(0.45, 0, 0.035, 0), UDim2.new(0.035, 0, 0.085, 0), Color3.fromRGB(181, 167, 154), Enum.Font.GothamBold, 10)

	pointsLabel.Size = UDim2.new(0.22, 0, 0.06, 0)
	pointsLabel.Position = UDim2.new(0.73, 0, 0.025, 0)
	pointsLabel.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
	pointsLabel.BackgroundTransparency = 0
	pointsLabel.TextColor3 = Color3.fromRGB(244, 237, 224)
	pointsLabel.Font = Enum.Font.GothamBold
	pointsLabel.TextSize = 12
	pointsLabel.TextScaled = false
	pointsLabel.TextWrapped = true
	pointsLabel.TextXAlignment = Enum.TextXAlignment.Center
	pointsLabel.ZIndex = 5
	makeCorner(pointsLabel, 8)
	makeStroke(pointsLabel, Color3.fromRGB(200, 148, 69), 1)

	closeBtn.Size = UDim2.new(0.045, 0, 0.06, 0)
	closeBtn.Position = UDim2.new(0.94, 0, 0.025, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
	closeBtn.TextColor3 = Color3.fromRGB(244, 237, 224)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.TextScaled = false
	closeBtn.ZIndex = 6
	makeCorner(closeBtn, 7)
	makeStroke(closeBtn, Color3.fromRGB(107, 74, 43), 1)

	specLabel.Size = UDim2.new(0.36, 0, 0.045, 0)
	specLabel.Position = UDim2.new(0.035, 0, 0.125, 0)
	specLabel.BackgroundTransparency = 1
	specLabel.TextColor3 = Color3.fromRGB(200, 148, 69)
	specLabel.Font = Enum.Font.GothamBold
	specLabel.TextSize = 11
	specLabel.TextScaled = false
	specLabel.TextXAlignment = Enum.TextXAlignment.Left
	specLabel.ZIndex = 5

	backToSpecsButton = mainFrame:FindFirstChild("BackToSpecsButton") or Instance.new("TextButton")
	backToSpecsButton.Name = "BackToSpecsButton"
	backToSpecsButton.Parent = mainFrame
	backToSpecsButton.Size = UDim2.new(0.25, 0, 0.045, 0)
	backToSpecsButton.Position = UDim2.new(0.40, 0, 0.125, 0)
	backToSpecsButton.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
	backToSpecsButton.Text = "← VOLVER A SPECS"
	backToSpecsButton.TextColor3 = Color3.fromRGB(200, 148, 69)
	backToSpecsButton.Font = Enum.Font.GothamBold
	backToSpecsButton.TextSize = 8
	backToSpecsButton.TextScaled = false
	backToSpecsButton.Visible = false
	backToSpecsButton.ZIndex = 6
	makeCorner(backToSpecsButton, 5)
	makeStroke(backToSpecsButton, Color3.fromRGB(107, 74, 43), 1)
	backToSpecsButton.MouseButton1Click:Connect(function()
		browsingSpecId = nil
		backToSpecsButton.Visible = false
		resetNodeTooltip()
		RequestTalentTree:FireServer()
	end)

	nodesContainer.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	nodesContainer.BackgroundTransparency = 0
	nodesContainer.ClipsDescendants = false
	nodesContainer.ZIndex = 1
	makeCorner(nodesContainer, 10)
	makeStroke(nodesContainer, Color3.fromRGB(107, 74, 43), 1)

	treeMeta = makeLabel(mainFrame, "TreeMeta", "ÁRBOL DE TALENTOS", UDim2.new(0.63, 0, 0.035, 0), UDim2.new(0.035, 0, 0.175, 0), Color3.fromRGB(181, 167, 154), Enum.Font.GothamBold, 9)

	tooltipFrame = mainFrame:FindFirstChild("TalentTooltip") or Instance.new("Frame")
	tooltipFrame.Name = "TalentTooltip"
	tooltipFrame.Parent = mainFrame
	tooltipFrame.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	tooltipFrame.ZIndex = 8
	tooltipFrame.Visible = true
	tooltipFrame.ClipsDescendants = true
	makeCorner(tooltipFrame, 9)
	makeStroke(tooltipFrame, Color3.fromRGB(200, 148, 69), 1)
	tooltipIcon = tooltipFrame:FindFirstChild("TooltipIcon") or Instance.new("TextLabel")
	tooltipIcon.Name = "TooltipIcon"
	tooltipIcon.Parent = tooltipFrame
	tooltipIcon.Size = UDim2.new(0, 30, 0, 30)
	tooltipIcon.Position = UDim2.new(0.06, 0, 0.06, 0)
	tooltipIcon.BackgroundColor3 = Color3.fromRGB(82, 73, 93)
	tooltipIcon.Text = "◇"
	tooltipIcon.TextColor3 = Color3.fromRGB(255, 248, 226)
	tooltipIcon.Font = Enum.Font.GothamBold
	tooltipIcon.TextSize = 17
	tooltipIcon.TextScaled = false
	tooltipIcon.TextXAlignment = Enum.TextXAlignment.Center
	tooltipIcon.ZIndex = 10
	makeCorner(tooltipIcon, 7)

	tooltipTitle = makeLabel(tooltipFrame, "TooltipTitle", "SELECCIONA UN TALENTO", UDim2.new(0.70, 0, 0.16, 0), UDim2.new(0.20, 0, 0.06, 0), Color3.fromRGB(244, 237, 224), UITheme.GetFont("BodyBold"), 16)
	tooltipType = makeLabel(tooltipFrame, "TooltipType", "PASIVA  ·  RANGO 0/1", UDim2.new(0.70, 0, 0.12, 0), UDim2.new(0.20, 0, 0.25, 0), Color3.fromRGB(200, 148, 69), UITheme.GetFont("BodyBold"), 11)

	tooltipDivider = tooltipFrame:FindFirstChild("TooltipDivider") or Instance.new("Frame")
	tooltipDivider.Name = "TooltipDivider"
	tooltipDivider.Parent = tooltipFrame
	tooltipDivider.Size = UDim2.new(0.88, 0, 0, 1)
	tooltipDivider.Position = UDim2.new(0.06, 0, 0.42, 0)
	tooltipDivider.BackgroundColor3 = Color3.fromRGB(107, 74, 43)
	tooltipDivider.BorderSizePixel = 0
	tooltipDivider.ZIndex = 9

	tooltipEffectHeader = makeLabel(tooltipFrame, "TooltipEffectHeader", "EFECTO POR RANGO", UDim2.new(0.88, 0, 0.10, 0), UDim2.new(0.06, 0, 0.47, 0), Color3.fromRGB(200, 148, 69), UITheme.GetFont("BodyBold"), 10)
	tooltipEffect = makeLabel(tooltipFrame, "TooltipEffect", "Pasa el cursor sobre un nodo para ver sus detalles.", UDim2.new(0.88, 0, 0.18, 0), UDim2.new(0.06, 0, 0.58, 0), Color3.fromRGB(244, 237, 224), UITheme.GetFont("Body"), 12)
	tooltipReq = makeLabel(tooltipFrame, "TooltipReq", "Requisitos y gates aparecerán aquí.", UDim2.new(0.88, 0, 0.16, 0), UDim2.new(0.06, 0, 0.79, 0), Color3.fromRGB(205, 194, 182), UITheme.GetFont("Body"), 11)

	legendFrame = mainFrame:FindFirstChild("TalentLegend") or Instance.new("Frame")
	legendFrame.Name = "TalentLegend"
	legendFrame.Parent = mainFrame
	legendFrame.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	legendFrame.ZIndex = 7
	makeCorner(legendFrame, 8)
	makeStroke(legendFrame, Color3.fromRGB(107, 74, 43), 1)
	makeLabel(legendFrame, "LegendTitle", "LEYENDA", UDim2.new(0.86, 0, 0.18, 0), UDim2.new(0.07, 0, 0.05, 0), Color3.fromRGB(244, 237, 224), Enum.Font.GothamBold, 9)
	local legendItems = {
		{"Aprendido", Color3.fromRGB(200, 148, 69)},
		{"Disponible", Color3.fromRGB(143, 183, 214)},
		{"Bloqueado", Color3.fromRGB(102, 88, 111)},
		{"Habilidad", Color3.fromRGB(180, 138, 222)},
	}
	for index, item in ipairs(legendItems) do
		local swatch = legendFrame:FindFirstChild("LegendSwatch_" .. index) or Instance.new("Frame")
		swatch.Name = "LegendSwatch_" .. index
		swatch.Parent = legendFrame
		swatch.Size = UDim2.new(0, 10, 0, 10)
		swatch.Position = UDim2.new(0.07, 0, 0.25 + (index - 1) * 0.18, 0)
		swatch.BackgroundColor3 = item[2]
		swatch.BorderSizePixel = 0
		swatch.ZIndex = 8
		makeCorner(swatch, 3)
		local itemLabel = makeLabel(legendFrame, "Legend_" .. index, item[1], UDim2.new(0.70, 0, 0.16, 0), UDim2.new(0.20, 0, 0.22 + (index - 1) * 0.18, 0), Color3.fromRGB(244, 237, 224), Enum.Font.Gotham, 8)
		itemLabel.TextWrapped = false
	end

	noPointsFeedback = mainFrame:FindFirstChild("NoPointsFeedback") or Instance.new("Frame")
	noPointsFeedback.Name = "NoPointsFeedback"
	noPointsFeedback.Parent = mainFrame
	noPointsFeedback.BackgroundColor3 = Color3.fromRGB(58, 37, 37)
	noPointsFeedback.ZIndex = 7
	noPointsFeedback.Visible = false
	makeCorner(noPointsFeedback, 8)
	makeStroke(noPointsFeedback, Color3.fromRGB(184, 78, 91), 1)
	makeLabel(noPointsFeedback, "NoPointsTitle", "SIN PUNTOS", UDim2.new(0.88, 0, 0.36, 0), UDim2.new(0.06, 0, 0.12, 0), Color3.fromRGB(235, 155, 158), Enum.Font.GothamBold, 9)
	makeLabel(noPointsFeedback, "NoPointsBody", "Sube de nivel para obtener más.", UDim2.new(0.88, 0, 0.38, 0), UDim2.new(0.06, 0, 0.52, 0), Color3.fromRGB(220, 183, 183), Enum.Font.Gotham, 8)

	respecDialog = mainFrame:FindFirstChild("TalentRespecDialog") or Instance.new("Frame")
	respecDialog.Name = "TalentRespecDialog"
	respecDialog.Parent = mainFrame
	respecDialog.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
	respecDialog.ZIndex = 12
	respecDialog.Visible = false
	makeCorner(respecDialog, 10)
	makeStroke(respecDialog, Color3.fromRGB(184, 78, 91), 1)
	makeLabel(respecDialog, "RespecTitle", "REASIGNAR TALENTOS", UDim2.new(0.86, 0, 0.18, 0), UDim2.new(0.07, 0, 0.08, 0), Color3.fromRGB(244, 237, 224), Enum.Font.GothamBold, 12)
	makeLabel(respecDialog, "RespecWarning", "Perderás todos los puntos invertidos.", UDim2.new(0.86, 0, 0.18, 0), UDim2.new(0.07, 0, 0.29, 0), Color3.fromRGB(235, 155, 158), Enum.Font.Gotham, 9)
	respecCancel = respecDialog:FindFirstChild("RespecCancel") or Instance.new("TextButton")
	respecCancel.Name = "RespecCancel"
	respecCancel.Parent = respecDialog
	respecCancel.Size = UDim2.new(0.38, 0, 0.25, 0)
	respecCancel.Position = UDim2.new(0.07, 0, 0.66, 0)
	respecCancel.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
	respecCancel.Text = "CANCELAR"
	respecCancel.TextColor3 = Color3.fromRGB(244, 237, 224)
	respecCancel.Font = Enum.Font.GothamBold
	respecCancel.TextSize = 9
	respecCancel.ZIndex = 13
	makeCorner(respecCancel, 6)
	respecConfirm = respecDialog:FindFirstChild("RespecConfirm") or Instance.new("TextButton")
	respecConfirm.Name = "RespecConfirm"
	respecConfirm.Parent = respecDialog
	respecConfirm.Size = UDim2.new(0.48, 0, 0.25, 0)
	respecConfirm.Position = UDim2.new(0.45, 0, 0.66, 0)
	respecConfirm.BackgroundColor3 = Color3.fromRGB(184, 78, 91)
	respecConfirm.Text = "CONFIRMAR"
	respecConfirm.TextColor3 = Color3.fromRGB(255, 235, 235)
	respecConfirm.Font = Enum.Font.GothamBold
	respecConfirm.TextSize = 9
	respecConfirm.ZIndex = 13
	makeCorner(respecConfirm, 6)

	respecCancel.MouseButton1Click:Connect(function()
		respecDialog.Visible = false
	end)
	respecConfirm.MouseButton1Click:Connect(function()
		respecDialog.Visible = false
		RequestRespec:FireServer({})
	end)

	footerLabel = makeLabel(mainFrame, "TalentFooter", "Tier 2: ≥4 puntos + nivel 8  ·  Capstone: ≥8 puntos + nivel 16  ·  1 punto cada 2 niveles", UDim2.new(0.63, 0, 0.045, 0), UDim2.new(0.035, 0, 0.90, 0), Color3.fromRGB(181, 167, 154), Enum.Font.Gotham, 8)
	respecBtn.Text = "REASIGNAR · 100 ORO"
	respecBtn.Font = Enum.Font.GothamBold
	respecBtn.TextSize = 10
	respecBtn.TextScaled = false
	respecBtn.TextColor3 = Color3.fromRGB(244, 237, 224)
	respecBtn.ZIndex = 6
	makeCorner(respecBtn, 7)
	makeStroke(respecBtn, Color3.fromRGB(107, 74, 43), 1)

	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
	end
	applyResponsiveLayout()
end

local function formatEffects(perRank)
	if not perRank then return "" end
	local parts = {}
	for effectName, value in pairs(perRank) do
		local displayName = EFFECT_NAMES[effectName] or effectName
		local pct = math.floor(value * 100 + 0.5)
		table.insert(parts, "+" .. pct .. "% " .. displayName)
	end
	return table.concat(parts, "  ")
end

-- ============================================================================
-- Node rendering (v2: branch layout with 3 columns)
-- ============================================================================

local showSpecSelection -- forward declaration

local function populateBranchNodes(data, specId, isBrowsing)
	clearNodes()

	-- Get nodes for the spec
	local nodes
	if isBrowsing then
		for _, spec in ipairs(data.availableSpecs or {}) do
			if spec.specId == specId then
				nodes = spec.nodes
				break
			end
		end
	else
		nodes = data.nodes
	end

	if not nodes then return end

	-- Group nodes by branchId
	local branches = {}
	local branchOrder = {}
	for _, node in ipairs(nodes) do
		local bid = node.branchId or "unknown"
		if not branches[bid] then
			branches[bid] = { name = node.branchName or bid, nodes = {} }
			table.insert(branchOrder, bid)
		end
		table.insert(branches[bid].nodes, node)
	end

	-- Sort nodes within each branch by their position in the chain (prereqs)
	for _, bid in ipairs(branchOrder) do
		local branchNodes = branches[bid].nodes
		-- Sort by levelReq then by pointsRequired (approximate chain order)
		table.sort(branchNodes, function(a, b)
			return (a.levelReq or 0) < (b.levelReq or 0)
		end)
	end

	-- Create 3-column layout
	local branchCount = #branchOrder
	local colWidth = 1 / math.max(branchCount, 1)
	local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local compactPortrait = UserInputService.TouchEnabled and viewport.X < viewport.Y * 1.15
	local compactTouch = UserInputService.TouchEnabled

	for colIdx, bid in ipairs(branchOrder) do
		local branch = branches[bid]

		-- Branch background frame
		local branchFrame = Instance.new("Frame")
		branchFrame.Name = "Branch_" .. bid
		branchFrame.Size = UDim2.new(colWidth - 0.02, 0, 1, 0)
		branchFrame.Position = UDim2.new((colIdx - 1) * colWidth + 0.01, 0, 0, 0)
		branchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		branchFrame.BackgroundTransparency = 0.3
		branchFrame.Parent = nodesContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.05, 0)
		corner.Parent = branchFrame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 80)
		stroke.Thickness = 1
		stroke.Parent = branchFrame

		-- Branch title
		local branchTitle = Instance.new("TextLabel")
		branchTitle.Name = "BranchTitle"
		branchTitle.Size = UDim2.new(1, 0, 0, compactPortrait and 18 or compactTouch and 20 or 30)
		branchTitle.Position = UDim2.new(0, 0, 0, 0)
		branchTitle.BackgroundTransparency = 1
		branchTitle.Text = branch.name
		branchTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
		branchTitle.Font = Enum.Font.GothamBold
		branchTitle.TextSize = compactPortrait and 8 or compactTouch and 10 or 12
		branchTitle.TextScaled = false
		branchTitle.TextTruncate = Enum.TextTruncate.AtEnd
		branchTitle.Parent = branchFrame

		-- Nodes container within branch (vertical list)
		local nodesList = Instance.new("Frame")
		nodesList.Name = "NodesList"
		local listTop = compactPortrait and 20 or compactTouch and 22 or 32
		nodesList.Size = UDim2.new(1, -10, 1, -(listTop + 3))
		nodesList.Position = UDim2.new(0, 5, 0, listTop)
		nodesList.BackgroundTransparency = 1
		nodesList.Parent = branchFrame

		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, compactTouch and 4 or 8)
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		listLayout.Parent = nodesList

		-- Render each node
		for nodeIdx, node in ipairs(branch.nodes) do
			local rank = node.rank or 0
			local maxRank = node.maxRank or 3
			local level = data.level or 1
			local points = data.points or 0

			-- Determine node state
			local isMaxed = rank >= maxRank
			local hasRank = rank > 0
			local levelOk = level >= (node.levelReq or 1)

			-- Check prereqs
			local prereqsMet = true
			if not isBrowsing then
				for _, prereqId in ipairs(node.prereqs or {}) do
					local prereqNode = nil
					for _, n in ipairs(nodes) do
						if n.id == prereqId then prereqNode = n break end
					end
					if not prereqNode or (prereqNode.rank or 0) < 1 then
						prereqsMet = false
						break
					end
				end
			else
				-- When browsing, only nodes with no prereqs are accessible
				prereqsMet = (#(node.prereqs or {}) == 0)
			end

			-- Check pointsRequired
			local totalSpent = 0
			if not isBrowsing and data.nodes then
				for _, n in ipairs(data.nodes) do
					totalSpent = totalSpent + (n.rank or 0)
				end
			end
			local pointsReqMet = totalSpent >= (node.pointsRequired or 0)

			local canSpend = not isMaxed and levelOk and prereqsMet and pointsReqMet and points > 0

			-- Node button
			local btn = Instance.new("TextButton")
			btn.Name = "Node_" .. node.id
			btn.Size = UDim2.new(0.9, 0, 0, compactPortrait and 48 or compactTouch and 60 or 84)
			btn.TextScaled = false
			btn.Font = UITheme.GetFont("Body")
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn:SetAttribute("HearthboundBlackCell", true)
			btn.Parent = nodesList

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0.1, 0)
			btnCorner.Parent = btn

			local btnStroke = btn:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke")
			btnStroke.Thickness = 1.5
			btnStroke.Parent = btn

			btn:SetAttribute("TalentState", isMaxed and "maxed" or hasRank and "learned" or canSpend and "available" or "blocked")
			-- Color based on state
			if isMaxed then
				btnStroke.Color = Color3.fromRGB(80, 200, 80)
			elseif hasRank then
				btnStroke.Color = Color3.fromRGB(80, 160, 220)
			elseif canSpend then
				btnStroke.Color = Color3.fromRGB(220, 200, 80)
			elseif not levelOk then
				btnStroke.Color = Color3.fromRGB(100, 50, 50)
			else
				btnStroke.Color = Color3.fromRGB(70, 70, 80)
			end
			btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			btn:SetAttribute("HearthboundCellBaseStrokeColor", btnStroke.Color)
			btn:SetAttribute("HearthboundCellBaseStrokeThickness", btnStroke.Thickness)
			btn:SetAttribute("HearthboundCellBaseStrokeTransparency", btnStroke.Transparency)

			-- Node text
			local rankText = string.format("%d/%d", rank, maxRank)
			local nodeType = node.type == "Skill" and " [Skill]" or ""
			local effectStr = formatEffects(node.perRank)
			local levelStr = "Niv." .. (node.levelReq or 1)

			if effectStr ~= "" then
				btn.Text = string.format("%s%s\n%s\n%s\n%s", node.name, nodeType, rankText, effectStr, levelStr)
			elseif node.type == "Skill" then
				btn.Text = string.format("%s [Skill]\n%s\n%s", node.name, rankText, levelStr)
			else
				btn.Text = string.format("%s\n%s\n%s", node.name, rankText, levelStr)
			end

			btn:SetAttribute("TalentRawText", "")
			btn:SetAttribute("TalentNodeName", node.name or node.id)
			btn:SetAttribute("TalentNodeType", node.type or "Passive")
			btn:SetAttribute("TalentNodeRank", rank)
			btn:SetAttribute("TalentNodeMaxRank", maxRank)
			btn:SetAttribute("TalentNodeLevelReq", node.levelReq or 1)
			btn:SetAttribute("TalentNodePointsRequired", node.pointsRequired or 0)
			btn:SetAttribute("TalentNodePrereqCount", #(node.prereqs or {}))
			btn:SetAttribute("TalentNodeEffect", effectStr)
			-- Apply the styled node typography on first render, not after its first hover.
			styleNodeButton(btn)
		btn.MouseEnter:Connect(function()
			showNodeTooltip(btn)
			local cellStroke = btn:FindFirstChildWhichIsA("UIStroke")
			if cellStroke then
				local baseColor = btn:GetAttribute("HearthboundCellBaseStrokeColor") or cellStroke.Color
				cellStroke.Color = baseColor:Lerp(Color3.fromRGB(255, 248, 226), 0.28)
				cellStroke.Thickness = math.max(2, tonumber(btn:GetAttribute("HearthboundCellBaseStrokeThickness")) or 1)
			end
		end)
		btn.MouseLeave:Connect(function()
			hideNodeTooltip()
			styleNodeButton(btn)
		end)
		-- Click handler
		btn.MouseButton1Click:Connect(function()
				if isBrowsing then
					-- Only allow clicking base nodes (no prereqs, no pointsRequired)
					if #(node.prereqs or {}) > 0 or (node.pointsRequired or 0) > 0 then
						showError("Invierte un punto en un nodo base para elegir esta spec")
						return
				end
					-- Fire spend request with specId to confirm spec selection
					RequestSpendTalentPoint:FireServer({
						nodeId = node.id,
					specId = specId,
					})
					return
				end
				RequestSpendTalentPoint:FireServer({
					nodeId = node.id,
					specId = specId,
				})
			end)
		end
	end
end

-- ============================================================================
-- Spec selection (when no spec chosen)
-- ============================================================================

showSpecSelection = function(data)
	clearNodes()
	browsingSpecId = nil
	if backToSpecsButton then
		backToSpecsButton.Visible = false
	end
	resetNodeTooltip()

	local specs = data.availableSpecs or {}
	local specRow = Instance.new("Frame")
	specRow.Name = "SpecSelectionRow"
	specRow.Size = UDim2.new(1, -10, 0, 84)
	specRow.Position = UDim2.new(0, 5, 0, 48)
	specRow.BackgroundTransparency = 1
	specRow.Parent = nodesContainer

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rowLayout.Padding = UDim.new(0, 12)
	rowLayout.Parent = specRow

	local buttonWidth = math.min(0.45, 0.92 / math.max(#specs, 1))
	for _, spec in ipairs(specs) do
		local btn = Instance.new("TextButton")
		btn.Name = "Spec_" .. spec.specId
		btn.Size = UDim2.new(buttonWidth, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.Text = SPEC_NAMES[spec.specId] or spec.specId
		btn.Parent = specRow

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.1, 0)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(120, 100, 160)
		stroke.Thickness = 2
		stroke.Parent = btn

		btn.MouseButton1Click:Connect(function()
			browsingSpecId = spec.specId
			if backToSpecsButton then
				backToSpecsButton.Visible = true
			end
			specLabel.Text = (SPEC_NAMES[spec.specId] or spec.specId) .. " (vista previa)"
			populateBranchNodes(data, spec.specId, true)
			refreshTalentVisuals()
		end)
	end

	-- Info text
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Size = UDim2.new(0.86, 0, 0, 40)
	infoLabel.Position = UDim2.new(0.07, 0, 0.02, 0)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Elige una spec para ver el árbol (el primer punto confirma tu elección)"
	infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextScaled = true
	infoLabel.Parent = nodesContainer
end

setupTalentReskin()

-- ============================================================================
-- Update UI from data
-- ============================================================================

local function updateUI(data)
	currentData = data

	local activeSpec = data.specId or browsingSpecId
	local activeSpecName = activeSpec and (SPEC_NAMES[activeSpec] or activeSpec) or "ELIGE TU ESPECIALIZACIÓN"
	if data.specId then
		specLabel.Text = string.upper(activeSpecName)
		browsingSpecId = nil
		if backToSpecsButton then backToSpecsButton.Visible = false end
	elseif browsingSpecId then
		specLabel.Text = string.upper(activeSpecName) .. "  ·  VISTA PREVIA"
	else
		specLabel.Text = "ELIGE TU ESPECIALIZACIÓN"
	end

	local level = data.level or localPlayer:GetAttribute("Level") or 1
	if titleLabel then
		titleLabel.Text = data.specId and ("TALENTOS  ·  " .. string.upper(activeSpecName)) or "TALENTOS"
	end
	if characterLabel then
		characterLabel.Text = string.upper(tostring(localPlayer:GetAttribute("CharacterName") or "EIRIK")) .. "  ·  NIVEL " .. tostring(level)
	end
	local points = data.points or 0
	pointsLabel.Text = "✦  PUNTOS DISPONIBLES  ·  " .. tostring(points)
	if noPointsFeedback then
		noPointsFeedback.Visible = data.specId ~= nil and points <= 0
	end

	local totalSpent = 0
	for _, talentNode in ipairs(data.nodes or {}) do
		totalSpent = totalSpent + (talentNode.rank or 0)
	end
	if treeMeta then
		treeMeta.Text = "ÁRBOL DE TALENTOS  ·  " .. tostring(totalSpent) .. " PUNTOS GASTADOS"
	end

	-- Populate nodes
	if data.specId then
		populateBranchNodes(data, data.specId, false)
	elseif browsingSpecId and data.availableSpecs then
		populateBranchNodes(data, browsingSpecId, true)
	else
		showSpecSelection(data)
	end
	refreshTalentVisuals()
end

-- ============================================================================
-- Open / Close
-- ============================================================================

local function openTalents()
	isTalentOpen = true
	talentGui.Enabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	localPlayer:SetAttribute("UIWindowOpen", true)
	if shellReady then
		local targetPosition = mainFrame.Position
		mainFrame.Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset + 10)
		TweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = targetPosition }):Play()
	end
	-- Request fresh talent tree data
	RequestTalentTree:FireServer()
end

local function closeTalents()
	isTalentOpen = false
	if tooltipFrame then tooltipFrame.Visible = false end
	if respecDialog then respecDialog.Visible = false end
	talentGui.Enabled = false
	applyResponsiveLayout() -- R6.11: restaura el default tras arrastre temporal.
	errorLabel.Text = ""
	errorLabel.Visible = false
	localPlayer:SetAttribute("UIWindowOpen", false)
end

closeBtn.MouseButton1Click:Connect(closeTalents)

-- MicroMenuUI: el menú centralizado controla también la rama de talentos.
local lastMicroMenuRequestId = nil
local lastMicroMenuCloseRequestId = nil

localPlayer:GetAttributeChangedSignal("MicroMenuCloseRequestId"):Connect(function()
	local requestId = localPlayer:GetAttribute("MicroMenuCloseRequestId")
	if requestId == lastMicroMenuCloseRequestId then
		return
	end
	lastMicroMenuCloseRequestId = requestId
	if isTalentOpen then
		closeTalents()
	end
end)

localPlayer:GetAttributeChangedSignal("MicroMenuRequestId"):Connect(function()
	local requestId = localPlayer:GetAttribute("MicroMenuRequestId")
	if requestId == lastMicroMenuRequestId then
		return
	end
	lastMicroMenuRequestId = requestId

	if localPlayer:GetAttribute("MicroMenuAction") ~= "Talent" then
		return
	end

	if isTalentOpen then
		closeTalents()
	elseif localPlayer:GetAttribute("CharacterName") then
		openTalents()
	end
end)

-- ============================================================================
-- Respec button
-- ============================================================================

respecBtn.MouseButton1Click:Connect(function()
	if not currentData then return end

	if not currentData.specId then
		showError("Necesitas tener una spec para respec")
		return
	end

	local respecCost = VendorConfig.GetRespecCost and VendorConfig.GetRespecCost() or 100
	showRespecDialog(respecCost)
end)

-- ============================================================================
-- Remote handlers (v2)
-- ============================================================================

TalentTreeData.OnClientEvent:Connect(function(data)
	updateUI(data)
end)

TalentPointSpent.OnClientEvent:Connect(function(data)
	if data.success then
		errorLabel.Text = ""
		if data.talents then
			updateUI(data.talents)
		end
	else
		showError(data.error)
	end
end)

RespecResult.OnClientEvent:Connect(function(data)
	if data.success then
		errorLabel.Text = ""
		if data.talents then
			if not data.talents.specId then
				browsingSpecId = nil
				resetNodeTooltip()
			end
			updateUI(data.talents)
		end
	else
		showError(data.error)
	end
end)

-- Legacy TalentData/TalentResult for backward compat
local legacyTalentData = Remotes:FindFirstChild("TalentData")
local legacyTalentResult = Remotes:FindFirstChild("TalentResult")
if legacyTalentData then
	legacyTalentData.OnClientEvent:Connect(function(data)
		updateUI(data)
	end)
end
if legacyTalentResult then
	legacyTalentResult.OnClientEvent:Connect(function(data)
		if data.success then
			errorLabel.Text = ""
			if data.talents then
				updateUI(data.talents)
			end
		else
			showError(data.error)
		end
	end)
end

-- ============================================================================
-- Input: Toggle with T key
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.T then
		if isTalentOpen then
			closeTalents()
		else
			local hasChar = localPlayer:GetAttribute("CharacterName")
			if hasChar then
				openTalents()
			end
		end
	end
end)

-- ============================================================================
-- Gold attribute update for respec button state
-- ============================================================================

localPlayer:GetAttributeChangedSignal("Gold"):Connect(function()
	local gold = localPlayer:GetAttribute("Gold") or 0
	local respecCost = VendorConfig.GetRespecCost and VendorConfig.GetRespecCost() or 100
	if gold < respecCost then
		respecBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 20)
	else
		respecBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 20)
	end
end)

-- ============================================================================
-- NPC ProximityPrompt handler for Trainer
-- ============================================================================

local function isTrainer(vendorId)
	-- El instructor ahora abre VendorUI; evita duplicar el hook de ProximityPrompt.
	return false
end

local function hookTrainerNPCs()
	local hub = Workspace:FindFirstChild("Hub")
	if not hub then return end

	for _, desc in hub:GetDescendants() do
		if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Parent and desc.Parent.Parent:GetAttribute("VendorId") then
			local vendorId = desc.Parent.Parent:GetAttribute("VendorId")
			if isTrainer(vendorId) then
				desc.Triggered:Connect(function()
					if not isTalentOpen then
						local hasChar = localPlayer:GetAttribute("CharacterName")
						if hasChar then
							openTalents()
						end
					end
				end)
			end
		end
	end
end

hookTrainerNPCs()

Workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Parent and desc.Parent.Parent:GetAttribute("VendorId") then
		local vendorId = desc.Parent.Parent:GetAttribute("VendorId")
		if isTrainer(vendorId) then
			desc.Triggered:Connect(function()
				if not isTalentOpen then
					local hasChar = localPlayer:GetAttribute("CharacterName")
					if hasChar then
						openTalents()
					end
				end
			end)
		end
	end
end)

print("[Vandrheim] TalentClient R5.1 v2 activo")

