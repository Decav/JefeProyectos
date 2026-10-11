--[[
	SkillBarClient v2 - Vandrheim Fase R5.1 (HU-R5.1)
	Client-side skill bar: input (keys 1-4 + touch), CD overlays,
	mana display, AoE ground targeting. Right-click opens SpellbookClient.
	v2: Uses SkillConfig.Get(), BarSlotAssigned, SpellbookData.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local SkillConfig = require(ReplicatedStorage.Config:WaitForChild("SkillConfig"))
local TooltipSystem = require(ReplicatedStorage.Shared:WaitForChild("TooltipSystem"))
local TooltipData = require(ReplicatedStorage.Shared:WaitForChild("TooltipData"))
local TargetState = require(ReplicatedStorage.Shared:WaitForChild("TargetState"))
local AllyTargetState = require(ReplicatedStorage.Shared:WaitForChild("AllyTargetState"))
local AoEIndicatorConfig = require(ReplicatedStorage.Config:WaitForChild("AoEIndicatorConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestCastSkill = Remotes:WaitForChild("RequestCastSkill")
local CastRejected = Remotes:WaitForChild("CastRejected")
local AoeCastVisual = Remotes:WaitForChild("AoeCastVisual")
local SkillCooldownStart = Remotes:WaitForChild("SkillCooldownStart")
local LoadoutData = Remotes:WaitForChild("LoadoutData")
local BarSlotAssigned = Remotes:WaitForChild("BarSlotAssigned")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local skillBarGui = playerGui:WaitForChild("SkillBar")
local hudGui = playerGui:WaitForChild("HUD")

local barContainer = skillBarGui:WaitForChild("BarContainer")
local feedbackLabel = skillBarGui:WaitForChild("FeedbackLabel")
local loadoutPanel = skillBarGui:WaitForChild("LoadoutPanel")
local aoeIndicator = nil
local lastAoEAimScreenPosition = nil

local slots = {}
for i = 1, 4 do
	slots[i] = barContainer:WaitForChild("Slot" .. i)
end

-- ============================================================================
-- State
-- ============================================================================

local currentLoadout = nil
local aoeMode = false
local aoeSkillId = nil
local aoeSkillSlot = nil
local cdTimers = {}

local isTouch = UserInputService.TouchEnabled

-- ============================================================================
-- UI Helpers
-- ============================================================================

local function showFeedback(text)
	feedbackLabel.Text = text
	feedbackLabel.Visible = true
	task.spawn(function()
		task.wait(1.5)
		feedbackLabel.Visible = false
	end)
end

local function updateSlotDisplay(slotIndex, skillId)
	local slot = slots[slotIndex]
	if not slot then return end

	local icon = slot:FindFirstChild("SkillIcon")
    local manaCost = slot:FindFirstChild("ManaCost")
	if skillId and skillId ~= "" then
		local skill = SkillConfig.Get(skillId)
		if skill then
			icon.Image = skill.iconId or ""
			slot:SetAttribute("SkillId", skillId)
		else
			icon.Image = ""
			if manaCost then manaCost.Text = "" end
			slot:SetAttribute("SkillId", nil)
		end
	else
		icon.Image = ""
		if manaCost then manaCost.Text = "" end
		slot:SetAttribute("SkillId", nil)
	end
end

local function refreshAllSlots()
	if not currentLoadout then return end
	for i = 1, 4 do
		updateSlotDisplay(i, currentLoadout[i])
	end
end

-- ============================================================================
-- Cooldown Overlay
-- ============================================================================

local function startCdOverlay(skillId, duration)
	cdTimers[skillId] = os.clock() + duration

	if not currentLoadout then return end
	for i = 1, 4 do
		if currentLoadout[i] == skillId then
			local slot = slots[i]
			local cdOverlay = slot:FindFirstChild("CDOverlay")
			local cdText = cdOverlay and cdOverlay:FindFirstChild("CDText")
			local rail = slot:FindFirstChild("HearthboundCooldownRail")
			if cdOverlay and cdText then
				cdOverlay.Visible = true
				if rail then rail.Visible = true end
				task.spawn(function()
					while os.clock() < cdTimers[skillId] do
						local remaining = cdTimers[skillId] - os.clock()
						if remaining <= 0 then break end
						cdText.Text = string.format("%.1f", remaining)
						if rail then
							rail.Size = UDim2.fromOffset(math.floor(math.max(0, slot.AbsoluteSize.X - 14) * math.clamp(remaining / math.max(duration, 0.01), 0, 1)), 3)
						end
						task.wait(0.1)
					end
					cdOverlay.Visible = false
					cdText.Text = ""
					if rail then rail.Visible = false end
				end)
			end
		end
	end
end

-- ============================================================================
-- AoE Ground Targeting
-- ============================================================================

local function getMouseGroundPosition()
	local camera = Workspace.CurrentCamera
	if not camera then return nil end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = { localPlayer.Character }
	if aoeIndicator and aoeIndicator.Parent then
		table.insert(filter, aoeIndicator)
	end
	params.FilterDescendantsInstances = filter

	local screenPos = lastAoEAimScreenPosition or UserInputService:GetMouseLocation()
	local unitRay = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, params)
	if result then
		return result.Position
	end
	return nil
end

local aoeIndicatorRadius = nil

local function configureIndicatorPart(part, name, color, transparency, material)
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Color = color
    part.Transparency = transparency
    part.Material = material or Enum.Material.Neon
    return part
end

local function makeFlatRuneBar(model, name, position, length, width, angle, color, transparency)
    local bar = Instance.new("Part")
    configureIndicatorPart(bar, name, color, transparency or 0.04, Enum.Material.Neon)
    bar.Size = Vector3.new(length, 0.09, width)
    bar.CFrame = CFrame.new(position) * CFrame.Angles(0, angle, 0)
    bar.Parent = model
    return bar
end

local function buildAoEIndicator(radius)
    local model = Instance.new("Model")
    model.Name = "AoEIndicator"

    local pivot = Instance.new("Part")
    configureIndicatorPart(pivot, "AoEPivot", Color3.new(1, 1, 1), 1, Enum.Material.SmoothPlastic)
    pivot.Size = Vector3.new(0.05, 0.05, 0.05)
    pivot.CFrame = CFrame.new()
    pivot.Parent = model
    model.PrimaryPart = pivot

    local fill = Instance.new("Part")
    configureIndicatorPart(
        fill,
        "AoEFill",
        AoEIndicatorConfig.fillColor,
        AoEIndicatorConfig.fillTransparency,
        Enum.Material.Neon
    )
    fill.Shape = Enum.PartType.Cylinder
    fill.Size = Vector3.new(0.1, radius * 2, radius * 2)
    fill.CFrame = CFrame.Angles(0, 0, math.rad(90))
    fill.Parent = model

    -- Un solo hilo luminoso continuo alrededor del contorno.
    local outlineHost = Instance.new("Part")
    configureIndicatorPart(outlineHost, "AoEOutlineHost", Color3.new(1, 1, 1), 1, Enum.Material.SmoothPlastic)
    outlineHost.Size = Vector3.new(radius * 2, 0.05, radius * 2)
    outlineHost.CFrame = CFrame.new(0, 0.06, 0)
    outlineHost.Parent = model

    local outlineSurface = Instance.new("SurfaceGui")
    outlineSurface.Name = "AoEOutlineSurface"
    outlineSurface.Face = Enum.NormalId.Top
    outlineSurface.AlwaysOnTop = true
    outlineSurface.LightInfluence = 0
    outlineSurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    outlineSurface.PixelsPerStud = AoEIndicatorConfig.outlinePixelsPerStud
    outlineSurface.CanvasSize = Vector2.new(512, 512)
    outlineSurface.Parent = outlineHost

    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "AoEOutlineGlow"
    glowFrame.BackgroundTransparency = 1
    glowFrame.BorderSizePixel = 0
    glowFrame.Size = UDim2.fromScale(1, 1)
    glowFrame.ZIndex = 1
    glowFrame.Parent = outlineSurface

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glowFrame

    local glowStroke = Instance.new("UIStroke")
    glowStroke.Name = "AoEOutlineGlowStroke"
    glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glowStroke.Color = AoEIndicatorConfig.outlineGlowColor
    glowStroke.Transparency = AoEIndicatorConfig.outlineGlowTransparency
    glowStroke.Thickness = AoEIndicatorConfig.outlineGlowThickness
    glowStroke.Parent = glowFrame

    local outlineFrame = Instance.new("Frame")
    outlineFrame.Name = "AoEOutlineFrame"
    outlineFrame.BackgroundTransparency = 1
    outlineFrame.BorderSizePixel = 0
    outlineFrame.Size = UDim2.fromScale(1, 1)
    outlineFrame.ZIndex = 2
    outlineFrame.Parent = outlineSurface

    local outlineCorner = Instance.new("UICorner")
    outlineCorner.CornerRadius = UDim.new(1, 0)
    outlineCorner.Parent = outlineFrame

    local outlineStroke = Instance.new("UIStroke")
    outlineStroke.Name = "AoEOutlineStroke"
    outlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outlineStroke.Color = AoEIndicatorConfig.outlineCoreColor
    outlineStroke.Transparency = AoEIndicatorConfig.outlineTransparency
    outlineStroke.Thickness = AoEIndicatorConfig.outlineThickness
    outlineStroke.Parent = outlineFrame

    -- Hilo luminoso continuo: segmentos Beam solapados que forman un único aro
    -- visualmente circular y con emisión comparable a la runa central.
    local lightPivot = pivot
    local ringSegments = 48
    local ringRadius = radius * 0.965
    local ringY = 0.14

    local function makeRingBeam(name, attachment0, attachment1, color, width, transparency, brightness)
        local beam = Instance.new("Beam")
        beam.Name = name
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(color)
        beam.Width0 = width
        beam.Width1 = width
        beam.Transparency = NumberSequence.new(transparency)
        beam.Brightness = brightness
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.FaceCamera = true
        beam.Segments = 1
        beam.Parent = model
        return beam
    end

    local glowAttachments = {}
    local coreAttachments = {}
    for index = 1, ringSegments do
        local angle = ((index - 1) / ringSegments) * math.pi * 2
        local point = Vector3.new(
            math.cos(angle) * ringRadius,
            ringY,
            math.sin(angle) * ringRadius
        )

        local glowAttachment = Instance.new("Attachment")
        glowAttachment.Name = string.format("AoEOuterGlowAttachment%02d", index)
        glowAttachment.Position = point
        glowAttachment.Parent = lightPivot
        glowAttachments[index] = glowAttachment

        local coreAttachment = Instance.new("Attachment")
        coreAttachment.Name = string.format("AoEOuterCoreAttachment%02d", index)
        coreAttachment.Position = point
        coreAttachment.Parent = lightPivot
        coreAttachments[index] = coreAttachment
    end

    for index = 1, ringSegments do
        local nextIndex = (index % ringSegments) + 1
        makeRingBeam(
            string.format("AoEOuterGlowBeam%02d", index),
            glowAttachments[index],
            glowAttachments[nextIndex],
            AoEIndicatorConfig.outlineGlowColor,
            0.30,
            0.50,
            2.5
        )
        makeRingBeam(
            string.format("AoEOuterCoreBeam%02d", index),
            coreAttachments[index],
            coreAttachments[nextIndex],
            Color3.fromRGB(244, 229, 255),
            0.12,
            0,
            5
        )
    end

    -- Runa nordica ornamental fija: sello central tipo Algiz estilizado.
    local runeY = 0.18
    local runeScale = math.clamp(radius * 0.14, 0.72, 1.45)
    local light = AoEIndicatorConfig.runeLightColor
    local dark = AoEIndicatorConfig.runeDarkColor

    local seal = Instance.new("Part")
    configureIndicatorPart(seal, "RuneSeal", dark, 0.52, Enum.Material.Neon)
    seal.Shape = Enum.PartType.Cylinder
    seal.Size = Vector3.new(0.06, runeScale * 1.42, runeScale * 1.42)
    seal.CFrame = CFrame.new(0, runeY - 0.025, 0) * CFrame.Angles(0, 0, math.rad(90))
    seal.Parent = model

    makeFlatRuneBar(
        model,
        "RuneStem",
        Vector3.new(0, runeY, 0),
        runeScale * 0.78,
        runeScale * 0.13,
        math.pi / 2,
        light
    )
    makeFlatRuneBar(
        model,
        "RuneArmLeft",
        Vector3.new(-runeScale * 0.11, runeY, runeScale * 0.19),
        runeScale * 0.42,
        runeScale * 0.11,
        math.rad(140),
        light
    )
    makeFlatRuneBar(
        model,
        "RuneArmRight",
        Vector3.new(runeScale * 0.11, runeY, runeScale * 0.19),
        runeScale * 0.42,
        runeScale * 0.11,
        math.rad(40),
        light
    )
    makeFlatRuneBar(
        model,
        "RuneCrossbar",
        Vector3.new(0, runeY, -runeScale * 0.06),
        runeScale * 0.38,
        runeScale * 0.105,
        0,
        dark
    )
    makeFlatRuneBar(
        model,
        "RuneBase",
        Vector3.new(0, runeY, -runeScale * 0.22),
        runeScale * 0.26,
        runeScale * 0.095,
        0,
        light
    )

    -- Marca rúnica ampliada: la misma Algiz del sello central, usada como
    -- una única filigrana tenue que ocupa el área morada sin competir con el núcleo.
    local expandedRuneY = runeY - 0.055
    local expandedRuneScale = math.clamp(radius * 1.05, 4.0, 9.5)
    local expandedTransparency = 0.82

    local expandedSeal = Instance.new("Part")
    configureIndicatorPart(
        expandedSeal,
        "AoEExpandedRuneSeal",
        dark,
        0.90,
        Enum.Material.Neon
    )
    expandedSeal.Shape = Enum.PartType.Cylinder
    expandedSeal.Size = Vector3.new(
        0.045,
        expandedRuneScale * 1.42,
        expandedRuneScale * 1.42
    )
    expandedSeal.CFrame =
        CFrame.new(0, expandedRuneY - 0.025, 0) * CFrame.Angles(0, 0, math.rad(90))
    expandedSeal.Parent = model

    makeFlatRuneBar(
        model,
        "AoEExpandedRuneStem",
        Vector3.new(0, expandedRuneY, 0),
        expandedRuneScale * 0.78,
        expandedRuneScale * 0.085,
        math.pi / 2,
        light,
        expandedTransparency
    )
    makeFlatRuneBar(
        model,
        "AoEExpandedRuneArmLeft",
        Vector3.new(-expandedRuneScale * 0.11, expandedRuneY, expandedRuneScale * 0.19),
        expandedRuneScale * 0.42,
        expandedRuneScale * 0.075,
        math.rad(140),
        light,
        expandedTransparency + 0.03
    )
    makeFlatRuneBar(
        model,
        "AoEExpandedRuneArmRight",
        Vector3.new(expandedRuneScale * 0.11, expandedRuneY, expandedRuneScale * 0.19),
        expandedRuneScale * 0.42,
        expandedRuneScale * 0.075,
        math.rad(40),
        light,
        expandedTransparency + 0.03
    )
    makeFlatRuneBar(
        model,
        "AoEExpandedRuneCrossbar",
        Vector3.new(0, expandedRuneY, -expandedRuneScale * 0.06),
        expandedRuneScale * 0.38,
        expandedRuneScale * 0.07,
        0,
        dark,
        expandedTransparency + 0.02
    )
    makeFlatRuneBar(
        model,
        "AoEExpandedRuneBase",
        Vector3.new(0, expandedRuneY, -expandedRuneScale * 0.22),
        expandedRuneScale * 0.26,
        expandedRuneScale * 0.065,
        0,
        light,
        expandedTransparency + 0.03
    )

    return model
end

local function ensureAoEIndicator(radius)
    radius = math.max(0.5, tonumber(radius) or 8)
    if not aoeIndicator or not aoeIndicator.Parent or aoeIndicatorRadius ~= radius then
        if aoeIndicator then
            aoeIndicator:Destroy()
        end
        aoeIndicator = buildAoEIndicator(radius)
        aoeIndicatorRadius = radius
        aoeIndicator.Parent = Workspace
    end
end

local function updateAoEIndicator()
    if not aoeMode or not aoeSkillId then
        if aoeIndicator then
            aoeIndicator:Destroy()
            aoeIndicator = nil
            aoeIndicatorRadius = nil
        end
        return
    end

    local skill = SkillConfig.Get(aoeSkillId)
    if not skill then return end

    local radius = skill.aoeRadius or 8
    if aoeSkillId == "paladin_prot_consecration" then
        local character = localPlayer.Character
        local multiplier = character and character:GetAttribute("SetBonusConsecrationRadiusMultiplier") or 1
        radius *= tonumber(multiplier) or 1
    end
    ensureAoEIndicator(radius)

    local pos = getMouseGroundPosition()
    if pos and aoeIndicator then
        aoeIndicator:PivotTo(CFrame.new(pos + Vector3.new(0, 0.1, 0)))
    end
end

local function enterAoEMode(skillId, slotIndex)
	aoeMode = true
	aoeSkillId = skillId
	aoeSkillSlot = slotIndex
	lastAoEAimScreenPosition = UserInputService:GetMouseLocation()
	showFeedback("Click en el suelo para castear")
	updateAoEIndicator()
end

local function exitAoEMode()
    aoeMode = false
    aoeSkillId = nil
    aoeSkillSlot = nil
    lastAoEAimScreenPosition = nil
    if aoeIndicator then
        aoeIndicator:Destroy()
        aoeIndicator = nil
        aoeIndicatorRadius = nil
    end
end

-- ============================================================================
-- Cast Logic
-- ============================================================================

local function castSkill(slotIndex)
	if localPlayer:GetAttribute("UILayoutEditMode") == true then return end
	if not currentLoadout then return end
	local skillId = currentLoadout[slotIndex]
	if not skillId or skillId == "" then return end

	local skill = SkillConfig.Get(skillId)
	if not skill then return end

	if skill.type == "GroundAoE" then
		if aoeMode and aoeSkillSlot == slotIndex then
			exitAoEMode()
		else
			enterAoEMode(skillId, slotIndex)
		end
		return
	end

	if skill.type == "SelfAoE" then
		if aoeMode then
			exitAoEMode()
		end
		RequestCastSkill:FireServer({ skillId = skillId })
		return
	end

	if skill.type == "DoT" then
		-- La flecha venenosa usa el objetivo seleccionado; el servidor valida
		-- que siga vivo y esté dentro del rango antes de aplicar un solo DoT.
		RequestCastSkill:FireServer({ skillId = skillId, target = TargetState.GetTarget() })
		return
	end

	-- The enemy target and ally support target remain independent.
	local payload = {
		skillId = skillId,
		target = TargetState.GetTarget(),
	}
	if skill.targetType == "ally_or_self" then
		payload.allyTargetUserId = AllyTargetState.GetUserId()
	end
	RequestCastSkill:FireServer(payload)
end

-- ============================================================================
-- Input Handling
-- ============================================================================

local keyMap = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or localPlayer:GetAttribute("UILayoutEditMode") == true then return end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		local slotIndex = keyMap[input.KeyCode]
		if slotIndex then
			castSkill(slotIndex)
		end
	end

	if aoeMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local pos = getMouseGroundPosition()
		if pos then
			RequestCastSkill:FireServer({
				skillId = aoeSkillId,
				position = { pos.X, pos.Y, pos.Z },
			})
		end
		exitAoEMode()
	end
end)

-- Touch: tap on skill slot
for i = 1, 4 do
	local icon = slots[i]:FindFirstChild("SkillIcon")
	if icon then
        TooltipSystem.Bind(icon, function()
            if aoeMode then return nil end
            return TooltipData.Skill(slots[i]:GetAttribute("SkillId"))
        end)
		icon.Activated:Connect(function(input)
            if not TooltipSystem.CanActivate(icon, input) then return end
            TooltipSystem.Hide(icon)
			castSkill(i)
		end)
	end
end

UserInputService.InputChanged:Connect(function(input)
    if not aoeMode then return end

    if input.UserInputType == Enum.UserInputType.Touch then
        lastAoEAimScreenPosition = Vector2.new(input.Position.X, input.Position.Y)
        updateAoEIndicator()
    elseif input.UserInputType == Enum.UserInputType.MouseMovement then
        lastAoEAimScreenPosition = UserInputService:GetMouseLocation()
        updateAoEIndicator()
    end
end)

-- ============================================================================
-- Right-click on slot opens Spellbook (via B key toggle)
-- ============================================================================

for i = 1, 4 do
	local icon = slots[i]:FindFirstChild("SkillIcon")
	if icon then
		icon.MouseButton2Click:Connect(function()
			-- Open spellbook UI (toggle with B key)
			local spellbookGui = playerGui:FindFirstChild("SpellbookUI")
			if spellbookGui then
				spellbookGui.Enabled = not spellbookGui.Enabled
				if spellbookGui.Enabled then
					-- Select the right-clicked slot
					local mainFrame = spellbookGui:FindFirstChild("MainFrame")
					if mainFrame then
						local barPreview = mainFrame:FindFirstChild("BarPreview")
						if barPreview then
							local barSlot = barPreview:FindFirstChild("BarSlot" .. i)
							if barSlot then
								barSlot.BackgroundColor3 = Color3.fromRGB(80, 70, 30)
							end
						end
					end
				end
			end
		end)
	end
end

-- ============================================================================
-- Remote Handlers
-- ============================================================================

LoadoutData.OnClientEvent:Connect(function(payload)
	currentLoadout = payload.loadout
	refreshAllSlots()
end)

BarSlotAssigned.OnClientEvent:Connect(function(data)
	if data.success and currentLoadout then
		currentLoadout[data.slot] = data.skillId
		refreshAllSlots()
	end
end)

CastRejected.OnClientEvent:Connect(function(payload)
	showFeedback(payload.reason or "Cast rechazado")
end)

SkillCooldownStart.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then return end
	startCdOverlay(payload.skillId, payload.duration)
	if type(payload.notice) == "string" and payload.notice ~= "" then
		showFeedback(payload.notice)
	end
end)

-- R6.9: AoeCastVisual se conserva como contrato histórico; el anillo lo dibuja VFXClient.
--[[
AoeCastVisual.OnClientEvent:Connect(function(payload)
	-- El indicador de apuntado sigue siendo local; este listener queda como
	-- compatibilidad con el remote histórico y no duplica el anillo persistente.
	if false then
	if type(payload) ~= "table" or type(payload.position) ~= "table" then
		return
	end

	local pos = Vector3.new(payload.position[1], payload.position[2], payload.position[3])
	local radius = tonumber(payload.radius) or 8

	-- PoC visual aislada: solo Consagración del Paladín usa el VFX sagrado.
	if payload.skillId ~= "paladin_prot_consecration" then
		local visual = Instance.new("Part")
		visual.Name = "AoEVisualFallback"
		visual.Shape = Enum.PartType.Cylinder
		visual.Size = Vector3.new(radius * 2, 0.2, radius * 2)
		visual.Position = pos + Vector3.new(0, 0.1, 0)
		visual.Anchored = true
		visual.CanCollide = false
		visual.CanTouch = false
		visual.CanQuery = false
		visual.Transparency = 0.3
		visual.Color = Color3.fromRGB(100, 200, 255)
		visual.Material = Enum.Material.Neon
		visual.Parent = Workspace
		Debris:AddItem(visual, 1.5)
		return
	end

	local previous = Workspace:FindFirstChild("VFX_POC_PaladinConsecration")
	if previous then
		previous:Destroy()
	end

	local poc = Instance.new("Folder")
	poc.Name = "VFX_POC_PaladinConsecration"
	poc:SetAttribute("ProofOfConcept", true)
	poc.Parent = Workspace

	local gold = Color3.fromRGB(255, 190, 55)
	local whiteGold = Color3.fromRGB(255, 235, 155)
	local visualRadius = math.clamp(radius * 0.9, 4, 7.5)

	local function makePart(name, size, cf, color, transparency)
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = color
		part.Transparency = transparency
		part.Size = size
		part.CFrame = cf
		part.Parent = poc
		return part
	end

	local function flatCylinder(name, diameter, color, transparency, y)
		local part = makePart(
			name,
			Vector3.new(diameter, 0.08, diameter),
			CFrame.new(pos + Vector3.new(0, y or 0, 0)),
			color,
			transparency
		)
		part.Shape = Enum.PartType.Cylinder
		return part
	end

	local function makeRing(name, ringRadius, count, color)
		local result = {}
		for i = 1, count do
			local angle = ((i - 1) / count) * math.pi * 2
			local ringPos = pos + Vector3.new(
				math.cos(angle) * ringRadius,
				0.16,
				math.sin(angle) * ringRadius
			)
			local segment = makePart(
				name .. "_" .. i,
				Vector3.new(0.18, 0.08, 0.12),
				CFrame.new(ringPos) * CFrame.Angles(0, angle + math.pi / 2, 0),
				color,
				1
			)
			table.insert(result, {
				part = segment,
				size = Vector3.new(math.max(0.7, ringRadius * math.pi * 2 / count * 1.2), 0.08, 0.12),
			})
		end
		return result
	end

	local core = flatCylinder("ConsecrationCore", visualRadius * 1.25, gold, 0.78, 0.04)
	local innerGlow = flatCylinder("ConsecrationInnerGlow", visualRadius * 0.72, whiteGold, 0.86, 0.09)
	local outerRing = makeRing("ConsecrationOuterRing", visualRadius, 36, gold)
	local innerRing = makeRing("ConsecrationInnerRing", visualRadius * 0.67, 28, whiteGold)

	for i = 1, 4 do
		local angle = math.rad(45 + (i - 1) * 90)
		makePart(
			"ConsecrationSigil_" .. i,
			Vector3.new(visualRadius * 0.95, 0.07, 0.10),
			CFrame.new(pos + Vector3.new(0, 0.18, 0)) * CFrame.Angles(0, angle, 0),
			whiteGold,
			0.30
		)
	end

	local pulseRings = {}
	for i = 1, 3 do
		local pulse = flatCylinder("ConsecrationPulse_" .. i, 1.0, whiteGold, 0.28, 0.22 + i * 0.025)
		table.insert(pulseRings, pulse)
	end

	local emitterPart = makePart(
		"ConsecrationEmitter",
		Vector3.new(0.2, 0.2, 0.2),
		CFrame.new(pos + Vector3.new(0, 0.2, 0)),
		whiteGold,
		1
	)
	local attachment = Instance.new("Attachment")
	attachment.Parent = emitterPart

	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "HolySparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Rate = 30
	sparks.Lifetime = NumberRange.new(0.9, 1.7)
	sparks.Speed = NumberRange.new(1.2, 3.2)
	sparks.SpreadAngle = Vector2.new(360, 35)
	sparks.Rotation = NumberRange.new(0, 360)
	sparks.RotSpeed = NumberRange.new(-90, 90)
	sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.22),
		NumberSequenceKeypoint.new(0.45, 0.42),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparks.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(0.75, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	sparks.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, whiteGold),
		ColorSequenceKeypoint.new(0.55, gold),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	sparks.LightEmission = 1
	sparks.LightInfluence = 0
	sparks.EmissionDirection = Enum.NormalId.Top
	sparks.Acceleration = Vector3.new(0, 1.5, 0)
	sparks.Parent = attachment

	local burst = sparks:Clone()
	burst.Name = "ConsecrationBurst"
	burst.Rate = 0
	burst.Lifetime = NumberRange.new(0.8, 1.4)
	burst.Parent = attachment

	local light = Instance.new("PointLight")
	light.Name = "ConsecrationLight"
	light.Color = gold
	light.Range = 14
	light.Brightness = 0
	light.Shadows = false
	light.Parent = emitterPart

	local columns = {}
	for i = 1, 12 do
		local angle = ((i - 1) / 12) * math.pi * 2
		local columnPos = pos + Vector3.new(
			math.cos(angle) * visualRadius * 0.85,
			0.8,
			math.sin(angle) * visualRadius * 0.85
		)
		local column = makePart(
			"ConsecrationColumn_" .. i,
			Vector3.new(0.18, 0.8, 0.18),
			CFrame.new(columnPos),
			gold,
			0.82
		)
		table.insert(columns, {
			part = column,
			base = column.CFrame,
		})
	end

	for _, item in ipairs(outerRing) do
		TweenService:Create(item.part, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = item.size,
			Transparency = 0.18,
		}):Play()
	end
	for _, item in ipairs(innerRing) do
		TweenService:Create(item.part, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = item.size,
			Transparency = 0.10,
		}):Play()
	end
	TweenService:Create(core, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.56,
	}):Play()
	TweenService:Create(innerGlow, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.70,
	}):Play()
	TweenService:Create(light, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 2.8,
	}):Play()

	task.delay(0.28, function()
		if burst.Parent then
			burst:Emit(80)
		end
	end)

	task.spawn(function()
		for cycle = 1, 8 do
			task.wait(0.8)
			if not poc.Parent then return end
			for index, pulse in ipairs(pulseRings) do
				pulse.Size = Vector3.new(1.0, 0.06, 1.0)
				pulse.Transparency = 0.24
				local targetDiameter = visualRadius * 0.95 + index * 1.0
				TweenService:Create(pulse, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(targetDiameter, 0.06, targetDiameter),
					Transparency = 1,
				}):Play()
			end
			for _, item in ipairs(columns) do
				local target = item.base * CFrame.new(0, 1.3, 0)
				TweenService:Create(item.part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = target,
					Transparency = 0.45,
				}):Play()
			end
			task.wait(0.45)
			for _, item in ipairs(columns) do
				TweenService:Create(item.part, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					CFrame = item.base,
					Transparency = 0.84,
				}):Play()
			end
		end
		TweenService:Create(light, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Brightness = 0,
		}):Play()
	end)

	Debris:AddItem(poc, 10)
	end
end)
]]
-- ============================================================================
-- Mana Bar Update
-- ============================================================================

local function updateManaBar()
	local char = localPlayer.Character
	if not char then return end

	local mp = char:GetAttribute("MP") or 0
	local maxMP = char:GetAttribute("MaxMP") or 0

	local hudPlayerFrame = hudGui:FindFirstChild("PlayerFrame")
	if not hudPlayerFrame then return end

	local mpBar = hudPlayerFrame:FindFirstChild("PlayerMPBar")
	if not mpBar then return end

	local mpFill = mpBar:FindFirstChild("PlayerMPFill")
	local mpText = mpBar:FindFirstChild("PlayerMPText")

	if maxMP > 0 then
		local ratio = math.clamp(mp / maxMP, 0, 1)
		if mpFill then
			mpFill.Size = UDim2.new(ratio, 0, 1, 0)
		end
		if mpText then
			mpText.Text = math.floor(mp) .. "/" .. math.floor(maxMP)
		end
	end
end

local function bindSetBonusAoE(character)
	character:GetAttributeChangedSignal("SetBonusConsecrationRadiusMultiplier"):Connect(function()
		if aoeMode and aoeSkillId == "paladin_prot_consecration" then
			updateAoEIndicator()
		end
	end)
	if aoeMode and aoeSkillId == "paladin_prot_consecration" then
		updateAoEIndicator()
	end
end

local function bindCharacterForMana(char)
	char:GetAttributeChangedSignal("MP"):Connect(updateManaBar)
	char:GetAttributeChangedSignal("MaxMP"):Connect(updateManaBar)
	updateManaBar()
end

localPlayer.CharacterAdded:Connect(bindCharacterForMana)
localPlayer.CharacterAdded:Connect(bindSetBonusAoE)
if localPlayer.Character then
	bindCharacterForMana(localPlayer.Character)
	bindSetBonusAoE(localPlayer.Character)
end

-- ============================================================================
-- Hide old loadout panel (replaced by SpellbookClient)
-- ============================================================================

if loadoutPanel then
	loadoutPanel.Visible = false
end

print("[Vandrheim] SkillBarClient R5.1 v2 activo")

