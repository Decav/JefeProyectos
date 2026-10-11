--[[
    SpellbookClient - Vandrheim HU-ESTETICA-17
    Grimorio Hearthbound Gold: skills, tooltip y barra de 4 slots.
    Mantiene intactos los remotes y el flujo click-slot -> click-skill.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local SkillConfig = require(ReplicatedStorage.Config:WaitForChild("SkillConfig"))
local UITheme = require(ReplicatedStorage.Config:WaitForChild("UITheme"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestSpellbook = Remotes:WaitForChild("RequestSpellbook")
local RequestAssignBarSlot = Remotes:WaitForChild("RequestAssignBarSlot")
local SpellbookData = Remotes:WaitForChild("SpellbookData")
local BarSlotAssigned = Remotes:WaitForChild("BarSlotAssigned")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local spellbookGui = playerGui:WaitForChild("SpellbookUI")
local mainFrame = spellbookGui:WaitForChild("MainFrame")
local skillList = mainFrame:WaitForChild("SkillList")
local barPreview = mainFrame:WaitForChild("BarPreview")
local closeBtn = mainFrame:WaitForChild("CloseButton")
local errorLabel = mainFrame:WaitForChild("ErrorLabel")

-- Hearthbound Gold / Pencil HU-ESTETICA-09
local COLORS = {
    shell = Color3.fromRGB(21, 16, 13),
    panel = Color3.fromRGB(33, 25, 22),
    panel2 = Color3.fromRGB(36, 27, 22),
    card = Color3.fromRGB(23, 19, 17),
    gold = Color3.fromRGB(200, 148, 69),
    goldLight = Color3.fromRGB(244, 237, 224),
    muted = Color3.fromRGB(181, 167, 154),
    blue = Color3.fromRGB(143, 183, 214),
    blueBg = Color3.fromRGB(32, 51, 64),
    purple = Color3.fromRGB(180, 138, 222),
    dim = Color3.fromRGB(82, 73, 93),
    error = Color3.fromRGB(181, 78, 78),
    black = UITheme.Colors.Shadow,
}

local isOpen = false
local currentData = nil
local selectedSlot = nil
local selectedSkillId = nil
local shellBuilt = false
local aspectConstraint = nil
local desktopPosition = UDim2.fromScale(0.08, 0.09)

local titleLabel
local characterLabel
local specTabs
local listHeader
local loadoutHeader
local infoLabel
local tooltipFrame
local tooltipTitle
local tooltipIcon
local tooltipType
local tooltipStats
local tooltipDescription
local statesFrame
local statesInfo
local footerLabel
local slotRow
local mobileStack = false
local mobileAccessWasEnabled = false
local mobileAccessStackWasVisible = false

local barSlots = {}
for i = 1, 4 do
    barSlots[i] = barPreview:FindFirstChild("BarSlot" .. i)
end

local function ensureChild(parent, className, name)
    local child = parent:FindFirstChild(name)
    if child and child.ClassName == className then
        return child
    end
    if child then
        child:Destroy()
    end
    child = Instance.new(className)
    child.Name = name
    child.Parent = parent
    return child
end

local function corner(parent, radius)
    local item = parent:FindFirstChild("SpellbookCorner")
    if not item then
        item = Instance.new("UICorner")
        item.Name = "SpellbookCorner"
        item.Parent = parent
    end
    item.CornerRadius = UDim.new(0, radius or 8)
    return item
end

local function stroke(parent, color, thickness)
    local item = parent:FindFirstChild("SpellbookStroke") or parent:FindFirstChildWhichIsA("UIStroke")
    if not item then
        item = Instance.new("UIStroke")
        item.Parent = parent
    end
    item.Name = "SpellbookStroke"
    item.Color = color
    item.Thickness = thickness or 1
    item.Transparency = 0
    return item
end

local function label(parent, name, text, position, size, color, font, textSize)
    local item = ensureChild(parent, "TextLabel", name)
    item.BackgroundTransparency = 1
    item.Text = text or ""
    item.TextColor3 = color or COLORS.goldLight
    item.Font = font or Enum.Font.Gotham
    item.TextSize = textSize or 12
    item.TextWrapped = false
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextYAlignment = Enum.TextYAlignment.Center
    item.Position = position
    item.Size = size
    item.ZIndex = 5
    return item
end

local function frame(parent, name, position, size, background, border, radius)
    local item = ensureChild(parent, "Frame", name)
    item.Position = position
    item.Size = size
    item.BackgroundColor3 = background or COLORS.panel
    item.BackgroundTransparency = 0
    item.BorderSizePixel = 0
    item.ZIndex = 2
    corner(item, radius or 8)
    stroke(item, border or COLORS.gold, 1)
    return item
end

local function niceName(value)
    value = tostring(value or "—")
    value = value:gsub("_", " "):gsub("%-", " ")
    return value:sub(1, 1):upper() .. value:sub(2)
end

local function findSkill(skillId)
    if not currentData or not currentData.skills then
        return nil
    end
    for _, skill in ipairs(currentData.skills) do
        if skill.skillId == skillId then
            return skill
        end
    end
    return nil
end

local function isInLoadout(skillId)
    for _, id in ipairs((currentData and currentData.loadout) or {}) do
        if id == skillId then
            return true
        end
    end
    return false
end

local function skillTypeName(skillType)
    return ({
        Instant = "INSTANT",
        GroundAoE = "AOE ZONA",
        SelfAoE = "AOE PROPIA",
        Heal = "CURACIÓN",
        Shield = "ESCUDO",
    })[skillType] or string.upper(tostring(skillType or "SKILL"))
end

local function skillOrigin(skill)
    if skill.origin and skill.origin ~= "" then
        return tostring(skill.origin)
    end
    if skill.specId and currentData and currentData.specId and skill.specId ~= currentData.specId then
        return "Otra especialización"
    end
    if not skill.canUse and skill.levelReq then
        return "Nivel requerido: " .. tostring(skill.levelReq)
    end
    return skill.canUse and "Aprendida" or "Bloqueada"
end

local function skillState(skill)
    if isInLoadout(skill.skillId) then
        return "ASIGNADA"
    elseif skill.canUse then
        return "DISPONIBLE"
    end
    return "BLOQUEADA"
end

local function stateColors(state)
    if state == "ASIGNADA" then
        return COLORS.gold, COLORS.black
    elseif state == "DISPONIBLE" then
        return COLORS.blue, COLORS.black
    end
    return COLORS.dim, COLORS.black
end

local function formatSkillNumber(value)
    local number = tonumber(value)
    if not number then return nil end
    return string.format("%.2f", number):gsub("0+$", ""):gsub("%.$", "")
end

local function getConfiguredSkill(skill)
    if not skill then return nil end
    return SkillConfig.Get(skill.skillId) or skill
end

local function getSkillRangeText(config)
    local skillType = config.type
    if skillType == "GroundAoE" then
        local radius = formatSkillNumber(config.aoeRadius)
        local castRange = formatSkillNumber(config.maxCastRange)
        return "Radio: " .. (radius and (radius .. " studs") or "no definido")
            .. " · Alcance de lanzamiento: " .. (castRange and (castRange .. " studs") or "no definido")
    elseif skillType == "SelfAoE" then
        local radius = formatSkillNumber(config.aoeRadius)
        return "Radio: " .. (radius and (radius .. " studs") or "no definido") .. " · Centro: propio"
    elseif config.allyRange ~= nil then
        local range = formatSkillNumber(config.allyRange)
        return "Rango aliado: " .. (range and (range .. " studs") or "no definido")
    elseif config.range ~= nil then
        local range = formatSkillNumber(config.range)
        return "Rango: " .. (range and (range .. " studs") or "no definido")
    elseif config.targetType == "self_only" then
        return "Objetivo: propio"
    elseif skillType == "Heal" or skillType == "Shield" then
        return config.targetType == "ally_or_self" and "Objetivo: aliado o propio · alcance no configurado" or "Alcance aliado no configurado"
    end
    return "Rango no configurado"
end

local function getSkillEffectText(skill)
    local config = getConfiguredSkill(skill) or {}
    local skillType = config.type or skill.type
    local effectName = skillType == "Heal" and "Cura"
        or skillType == "Shield" and "Escudo"
        or (skillType == "DoT" or skillType == "GroundAoE") and "Daño/tick"
        or "Daño"
    local base = formatSkillNumber(config.damageBase)
    local coefficient = formatSkillNumber(config.coefficient)
    local stat = tostring(config.stat or "stat")
    local parts = {}
    if base or coefficient then
        local formula = base or "0"
        if coefficient then formula ..= " + " .. coefficient .. " × " .. stat end
        table.insert(parts, effectName .. ": " .. formula)
    end
    if skillType == "DoT" or skillType == "GroundAoE" then
        local timing = {}
        local interval = formatSkillNumber(config.tickInterval)
        local duration = formatSkillNumber(config.duration or config.zoneDuration)
        if interval then table.insert(timing, "cada " .. interval .. " s") end
        if duration then table.insert(timing, "duración " .. duration .. " s") end
        if #timing > 0 then
            if #parts == 0 then table.insert(parts, effectName) end
            parts[#parts] ..= " · " .. table.concat(timing, " · ")
        end
    end
    local description = tostring(config.description or skill.description or "")
    if description ~= "" then table.insert(parts, description) end
    if #parts == 0 then return "Efecto no configurado." end
    return table.concat(parts, "\n")
end

local function setImageOrPlaceholder(icon, placeholder, imageId)
    local valid = imageId and tostring(imageId) ~= "" and tostring(imageId) ~= "rbxassetid://0"
    icon.Image = valid and tostring(imageId) or ""
    icon.Visible = valid
    placeholder.Visible = not valid
end

local function showError(message)
    errorLabel.Text = message or ""
    errorLabel.Visible = message ~= nil and message ~= ""
    if message and message ~= "" then
        task.delay(3, function()
            if errorLabel.Text == message then
                errorLabel.Text = ""
                errorLabel.Visible = false
            end
        end)
    end
end

local function setTooltip(skill)
    selectedSkillId = skill and skill.skillId or nil
    if not tooltipFrame then
        return
    end
    if not skill then
        tooltipTitle.Text = "SELECCIONA UNA SKILL"
        tooltipType.Text = "GRIMORIO"
        tooltipStats.Text = "Elige una habilidad para ver sus detalles."
        tooltipDescription.Text = "Las skills se asignan seleccionando primero un slot de la barra y luego una skill."
        tooltipIcon.Image = ""
        return
    end
    local config = getConfiguredSkill(skill) or skill
    tooltipTitle.Text = tostring(skill.name or config.name or niceName(skill.skillId))
    tooltipType.Text = skillTypeName(config.type or skill.type) .. "  ·  " .. skillState(skill) .. "  ·  " .. skillOrigin(skill)
    tooltipStats.Text = string.format(
        "Coste: %s MP  ·  Cooldown: %s s\n%s",
        tostring(config.manaCost or skill.manaCost or 0),
        tostring(config.cooldown or skill.cooldown or 0),
        getSkillRangeText(config)
    )
    tooltipDescription.Text = getSkillEffectText(skill)
    local iconId = config.iconId or skill.iconId
    local valid = iconId and tostring(iconId) ~= "" and tostring(iconId) ~= "rbxassetid://0"
    tooltipIcon.Image = valid and tostring(iconId) or ""
end

local lastSlotActivation = 0
local function selectBarSlot(index)
    local now = os.clock()
    if now - lastSlotActivation < 0.12 then
        return
    end
    lastSlotActivation = now
    if selectedSlot == index then
        selectedSlot = nil
    else
        selectedSlot = index
    end
    updateBarPreview(currentData and currentData.loadout or nil)
    if infoLabel then
        if selectedSlot then
            infoLabel.Text = "SLOT " .. tostring(selectedSlot) .. " DESTINO · selecciona una skill"
        else
            infoLabel.Text = "Selecciona un slot y luego una skill para asignarla"
        end
    end
end

local function buildShell()
    if shellBuilt then
        return
    end
    shellBuilt = true

    spellbookGui.DisplayOrder = math.max(spellbookGui.DisplayOrder, 20)
    mainFrame.BackgroundColor3 = COLORS.shell
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = UDim2.fromScale(0.84, 0.82)
    mainFrame.Position = desktopPosition
    mainFrame.Visible = false
    corner(mainFrame, 12)
    stroke(mainFrame, COLORS.gold, 1)

    aspectConstraint = mainFrame:FindFirstChild("SpellbookAspect")
    if not aspectConstraint then
        aspectConstraint = Instance.new("UIAspectRatioConstraint")
        aspectConstraint.Name = "SpellbookAspect"
        aspectConstraint.Parent = mainFrame
    end
    aspectConstraint.AspectRatio = 1.49
    aspectConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
    aspectConstraint.DominantAxis = Enum.DominantAxis.Width
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("UIAspectRatioConstraint") and child ~= aspectConstraint then
            child:Destroy()
        end
    end

    titleLabel = label(mainFrame, "Title", "GRIMORIO", UDim2.fromScale(0.025, 0.025), UDim2.fromScale(0.72, 0.045), COLORS.goldLight, Enum.Font.GothamBold, 20)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    characterLabel = label(mainFrame, "CharacterLabel", "PERSONAJE · NIVEL 1 · 0 HABILIDADES APRENDIDAS", UDim2.fromScale(0.025, 0.082), UDim2.fromScale(0.72, 0.035), COLORS.muted, Enum.Font.Code, 11)

    -- Geometría común de cierre en WindowLayoutClient; referencia EST-16.
    closeBtn.BackgroundColor3 = Color3.fromRGB(58, 44, 37)
    closeBtn.TextColor3 = Color3.fromRGB(244, 237, 224)
    closeBtn.Text = "X"
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 10
    corner(closeBtn, 7)
    stroke(closeBtn, Color3.fromRGB(107, 74, 43), 1)

    specTabs = frame(mainFrame, "SpecTabs", UDim2.fromScale(0.025, 0.135), UDim2.fromScale(0.58, 0.055), COLORS.panel, Color3.fromRGB(107, 74, 43), 8)
    local tabActive = label(specTabs, "ActiveTab", "PALADÍN · CASTIGO", UDim2.fromScale(0.02, 0.08), UDim2.fromScale(0.46, 0.84), COLORS.shell, Enum.Font.GothamBold, 11)
    tabActive.BackgroundColor3 = COLORS.gold
    tabActive.BackgroundTransparency = 0
    tabActive.TextXAlignment = Enum.TextXAlignment.Center
    corner(tabActive, 6)
    label(specTabs, "TabSkills", "HABILIDADES", UDim2.fromScale(0.49, 0.08), UDim2.fromScale(0.24, 0.84), COLORS.muted, Enum.Font.Code, 10).TextXAlignment = Enum.TextXAlignment.Center
    label(specTabs, "TabTalents", "TALENTOS", UDim2.fromScale(0.74, 0.08), UDim2.fromScale(0.24, 0.84), COLORS.muted, Enum.Font.Code, 10).TextXAlignment = Enum.TextXAlignment.Center

    listHeader = label(mainFrame, "ListHeader", "HABILIDADES · NIVEL · TALENTO", UDim2.fromScale(0.04, 0.205), UDim2.fromScale(0.55, 0.035), COLORS.gold, Enum.Font.Code, 10)
    skillList.Position = UDim2.fromScale(0.025, 0.245)
    skillList.Size = UDim2.fromScale(0.58, 0.48)
    skillList.BackgroundColor3 = COLORS.panel
    skillList.BackgroundTransparency = 0
    skillList.BorderSizePixel = 0
    skillList.ScrollBarThickness = 4
    skillList.ScrollBarImageColor3 = COLORS.gold
    skillList.ClipsDescendants = true
    skillList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    corner(skillList, 10)
    stroke(skillList, Color3.fromRGB(107, 74, 43), 1)
    local listPadding = skillList:FindFirstChild("SpellbookPadding") or Instance.new("UIPadding")
    listPadding.Name = "SpellbookPadding"
    listPadding.PaddingTop = UDim.new(0, 12)
    listPadding.PaddingBottom = UDim.new(0, 12)
    listPadding.PaddingLeft = UDim.new(0, 12)
    listPadding.PaddingRight = UDim.new(0, 12)
    listPadding.Parent = skillList
    local listLayout = skillList:FindFirstChild("SpellbookLayout") or Instance.new("UIListLayout")
    listLayout.Name = "SpellbookLayout"
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = skillList

    barPreview.Position = UDim2.fromScale(0.025, 0.755)
    barPreview.Size = UDim2.fromScale(0.58, 0.17)
    barPreview.BackgroundColor3 = COLORS.panel2
    barPreview.BackgroundTransparency = 0
    barPreview.BorderSizePixel = 0
    barPreview.ClipsDescendants = false
    corner(barPreview, 10)
    stroke(barPreview, COLORS.gold, 1)
    loadoutHeader = label(barPreview, "LoadoutHeader", "BARRA ACTIVA · 4 SLOTS", UDim2.fromScale(0.025, 0.05), UDim2.fromScale(0.6, 0.22), COLORS.gold, Enum.Font.Code, 10)

    slotRow = ensureChild(barPreview, "Frame", "SlotRow")
    slotRow.BackgroundTransparency = 1
    slotRow.BorderSizePixel = 0
    slotRow.Position = UDim2.fromScale(0.025, 0.30)
    slotRow.Size = UDim2.fromScale(0.95, 0.63)
    slotRow.ZIndex = 3
    local slotLayout = slotRow:FindFirstChild("SlotLayout") or Instance.new("UIListLayout")
    slotLayout.Name = "SlotLayout"
    slotLayout.FillDirection = Enum.FillDirection.Horizontal
    slotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    slotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    slotLayout.Padding = UDim.new(0, 6)
    slotLayout.SortOrder = Enum.SortOrder.LayoutOrder
    slotLayout.Parent = slotRow

    for i = 1, 4 do
        local slot = barSlots[i]
        if slot then
            local legacySlotLabel = slot:FindFirstChild("SlotLabel")
            if legacySlotLabel then
                legacySlotLabel.Visible = false
            end
            slot:SetAttribute("HearthboundBlackCell", true)
            slot.Parent = slotRow
            slot.Size = UDim2.fromScale(0.20, 1)
            local slotAspect = slot:FindFirstChild("SpellbookSlotAspect") or Instance.new("UIAspectRatioConstraint")
            slotAspect.Name = "SpellbookSlotAspect"
            slotAspect.AspectRatio = 1
            slotAspect.DominantAxis = Enum.DominantAxis.Height
            slotAspect.Parent = slot
            slot.ClipsDescendants = true
            slot.BackgroundColor3 = COLORS.black
            slot:SetAttribute("HearthboundCellBaseStrokeColor", COLORS.dim)
            slot:SetAttribute("HearthboundCellBaseStrokeThickness", 1)
            slot:SetAttribute("HearthboundCellBaseStrokeTransparency", 0)
            slot.Active = true
            slot.BorderSizePixel = 0
            slot.LayoutOrder = i
            slot.ZIndex = 4
            corner(slot, 6)
            stroke(slot, COLORS.dim, 1)

            local icon = ensureChild(slot, "ImageLabel", "SkillIcon")
            icon.BackgroundColor3 = COLORS.black
            icon.BackgroundTransparency = 0
            icon.Position = UDim2.fromScale(0, 0)
            icon.Size = UDim2.fromScale(1, 1)
            icon.ScaleType = Enum.ScaleType.Crop
            icon.ZIndex = 12
            corner(icon, 5)

            local placeholder = label(slot, "IconPlaceholder", "✦", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), COLORS.gold, UITheme.GetFont("BodyBold"), 22)
            placeholder.TextXAlignment = Enum.TextXAlignment.Center
            placeholder.Visible = true
            placeholder.ZIndex = 13

            local key = label(slot, "KeyLabel", tostring(i), UDim2.fromScale(0.04, 0.03), UDim2.fromScale(0.23, 0.20), COLORS.goldLight, UITheme.GetFont("Mono"), 10)
            key.BackgroundColor3 = COLORS.black
            key.BackgroundTransparency = 0.18
            key.ZIndex = 14
            local footer = ensureChild(slot, "Frame", "SkillSlotFooter")
            footer.Position = UDim2.fromScale(0, 0.68)
            footer.Size = UDim2.fromScale(1, 0.32)
            footer.BackgroundColor3 = COLORS.black
            footer.BackgroundTransparency = 0.18
            footer.BorderSizePixel = 0
            footer.Active = false
            footer.ZIndex = 13
            local name = label(slot, "SlotName", "VACÍO", UDim2.fromScale(0.05, 0.69), UDim2.fromScale(0.90, 0.16), COLORS.goldLight, UITheme.GetFont("BodyBold"), 9)
            name.TextWrapped = false
            name.TextTruncate = Enum.TextTruncate.AtEnd
            name.TextXAlignment = Enum.TextXAlignment.Center
            name.ZIndex = 14
            local cost = label(slot, "SlotCost", "—", UDim2.fromScale(0.05, 0.84), UDim2.fromScale(0.90, 0.13), COLORS.muted, UITheme.GetFont("Mono"), 8)
            cost.TextXAlignment = Enum.TextXAlignment.Center
            cost.ZIndex = 14

            local hitbox = ensureChild(slot, "TextButton", "SlotHitbox")
            hitbox.BackgroundTransparency = 1
            hitbox.BorderSizePixel = 0
            hitbox.Text = ""
            hitbox.AutoButtonColor = false
            hitbox.Size = UDim2.fromScale(1, 1)
            hitbox.Position = UDim2.fromScale(0, 0)
            hitbox.ZIndex = 10
            hitbox.Activated:Connect(function()
                selectBarSlot(i)
            end)
            if not slot:GetAttribute("SpellbookCellHoverBound") then
                slot:SetAttribute("SpellbookCellHoverBound", true)
                slot.MouseEnter:Connect(function()
                    local cellStroke = slot:FindFirstChild("SpellbookStroke")
                    if cellStroke then
                        local baseColor = slot:GetAttribute("HearthboundCellBaseStrokeColor") or COLORS.dim
                        cellStroke.Color = baseColor:Lerp(COLORS.goldLight, 0.28)
                        cellStroke.Thickness = math.max(2, tonumber(slot:GetAttribute("HearthboundCellBaseStrokeThickness")) or 1)
                    end
                end)
                slot.MouseLeave:Connect(function()
                    local cellStroke = slot:FindFirstChild("SpellbookStroke")
                    if cellStroke then
                        cellStroke.Color = slot:GetAttribute("HearthboundCellBaseStrokeColor") or COLORS.dim
                        cellStroke.Thickness = tonumber(slot:GetAttribute("HearthboundCellBaseStrokeThickness")) or 1
                    end
                end)
            end
            slot.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    selectBarSlot(i)
                end
            end)
        end
    end

    infoLabel = ensureChild(mainFrame, "TextLabel", "InfoLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Selecciona un slot y luego una skill para asignarla"
    infoLabel.TextColor3 = COLORS.muted
    infoLabel.Font = UITheme.GetFont("Mono")
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Position = UDim2.fromScale(0.04, 0.935)
    infoLabel.Size = UDim2.fromScale(0.56, 0.035)
    infoLabel.ZIndex = 5

    tooltipFrame = frame(mainFrame, "TooltipFrame", UDim2.fromScale(0.635, 0.135), UDim2.fromScale(0.34, 0.30), COLORS.panel, COLORS.purple, 10)
    tooltipTitle = label(tooltipFrame, "TooltipTitle", "SELECCIONA UNA SKILL", UDim2.fromScale(0.045, 0.07), UDim2.fromScale(0.78, 0.13), COLORS.goldLight, UITheme.GetFont("BodyBold"), 18)
    tooltipTitle.TextTruncate = Enum.TextTruncate.AtEnd
    tooltipIcon = ensureChild(tooltipFrame, "ImageLabel", "TooltipIcon")
    tooltipIcon.BackgroundTransparency = 1
    tooltipIcon.Position = UDim2.fromScale(0.86, 0.07)
    tooltipIcon.Size = UDim2.fromScale(0.09, 0.13)
    tooltipIcon.ScaleType = Enum.ScaleType.Fit
    tooltipIcon.ImageColor3 = COLORS.purple
    tooltipIcon.ZIndex = 6
    tooltipType = label(tooltipFrame, "TooltipType", "GRIMORIO", UDim2.fromScale(0.045, 0.23), UDim2.fromScale(0.86, 0.10), COLORS.purple, UITheme.GetFont("Mono"), 11)
    tooltipType.TextTruncate = Enum.TextTruncate.AtEnd
    tooltipStats = label(tooltipFrame, "TooltipStats", "Elige una habilidad para ver sus detalles.", UDim2.fromScale(0.045, 0.35), UDim2.fromScale(0.87, 0.25), COLORS.goldLight, UITheme.GetFont("BodyMedium"), 12)
    tooltipStats.TextWrapped = true
    local divider = ensureChild(tooltipFrame, "Frame", "TooltipDivider")
    divider.BackgroundColor3 = Color3.fromRGB(107, 74, 43)
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromScale(0.045, 0.65)
    divider.Size = UDim2.fromScale(0.87, 0.005)
    divider.ZIndex = 5
    tooltipDescription = label(tooltipFrame, "TooltipDescription", "Las skills se asignan seleccionando primero un slot de la barra y luego una skill.", UDim2.fromScale(0.045, 0.71), UDim2.fromScale(0.87, 0.23), COLORS.muted, UITheme.GetFont("Body"), 12)
    tooltipDescription.TextWrapped = true
    tooltipDescription.TextYAlignment = Enum.TextYAlignment.Top

    statesFrame = frame(mainFrame, "StatesFrame", UDim2.fromScale(0.635, 0.46), UDim2.fromScale(0.34, 0.25), COLORS.panel, Color3.fromRGB(107, 74, 43), 10)
    label(statesFrame, "StatesTitle", "ESTADOS DEL GRIMORIO", UDim2.fromScale(0.045, 0.08), UDim2.fromScale(0.88, 0.13), COLORS.gold, Enum.Font.Code, 10)
    local legendAssigned = label(statesFrame, "LegendAssigned", "●  ASIGNADA     skill equipada en la barra", UDim2.fromScale(0.06, 0.28), UDim2.fromScale(0.86, 0.16), COLORS.gold, Enum.Font.Code, 9)
    legendAssigned.TextWrapped = true
    local legendAvailable = label(statesFrame, "LegendAvailable", "●  DISPONIBLE   aprendida, sin asignar", UDim2.fromScale(0.06, 0.47), UDim2.fromScale(0.86, 0.16), COLORS.blue, Enum.Font.Code, 9)
    legendAvailable.TextWrapped = true
    local legendBlocked = label(statesFrame, "LegendBlocked", "●  BLOQUEADA    nivel o requisito pendiente", UDim2.fromScale(0.06, 0.66), UDim2.fromScale(0.86, 0.16), COLORS.dim, Enum.Font.Code, 9)
    legendBlocked.TextWrapped = true
    statesInfo = label(statesFrame, "StatesInfo", "No hay más skills por aprender.", UDim2.fromScale(0.06, 0.84), UDim2.fromScale(0.86, 0.12), COLORS.muted, Enum.Font.Gotham, 9)
    statesInfo.TextWrapped = true

    footerLabel = label(mainFrame, "Footer", "0 skills aprendidas · barra limita a 4 · las skills de talento se revocan con respec", UDim2.fromScale(0.635, 0.935), UDim2.fromScale(0.34, 0.035), COLORS.muted, Enum.Font.Code, 9)
    footerLabel.TextXAlignment = Enum.TextXAlignment.Right

    errorLabel.BackgroundColor3 = COLORS.error
    errorLabel.BackgroundTransparency = 0.08
    errorLabel.TextColor3 = COLORS.goldLight
    errorLabel.Font = Enum.Font.GothamBold
    errorLabel.TextSize = 10
    errorLabel.TextWrapped = true
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Position = UDim2.fromScale(0.635, 0.735)
    errorLabel.Size = UDim2.fromScale(0.34, 0.075)
    errorLabel.ZIndex = 30
    corner(errorLabel, 6)
    stroke(errorLabel, COLORS.error, 1)
    errorLabel.Visible = false

    setTooltip(nil)
end

local function applyResponsiveLayout()
    if not shellBuilt then
        return
    end
    local camera = workspace.CurrentCamera
    local viewport = spellbookGui.AbsoluteSize
    if viewport.X <= 0 or viewport.Y <= 0 then return end
    local touchPortrait = UserInputService.TouchEnabled and viewport.X < viewport.Y
    mobileStack = touchPortrait

    if touchPortrait then
        aspectConstraint.Parent = nil
        mainFrame.Size = UDim2.fromScale(0.94, 0.94)
        mainFrame.Position = UDim2.fromScale(0.03, 0.03)
        titleLabel.TextSize = 16
        characterLabel.TextSize = 9
        specTabs.Position = UDim2.fromScale(0.025, 0.125)
        specTabs.Size = UDim2.fromScale(0.95, 0.055)
        listHeader.Visible = true
        listHeader.Position = UDim2.fromScale(0.04, 0.195)
        skillList.Position = UDim2.fromScale(0.025, 0.23)
        skillList.Size = UDim2.fromScale(0.95, 0.35)
        barPreview.Position = UDim2.fromScale(0.025, 0.60)
        barPreview.Size = UDim2.fromScale(0.95, 0.16)
        tooltipFrame.Position = UDim2.fromScale(0.025, 0.78)
        tooltipFrame.Size = UDim2.fromScale(0.95, 0.18)
        statesFrame.Visible = false
        footerLabel.Visible = false
        infoLabel.Position = UDim2.fromScale(0.04, 0.965)
        infoLabel.Size = UDim2.fromScale(0.92, 0.025)
        errorLabel.Position = UDim2.fromScale(0.025, 0.715)
        errorLabel.Size = UDim2.fromScale(0.95, 0.055)
        tooltipTitle.TextSize = 15
        tooltipStats.TextSize = 10
        tooltipDescription.TextSize = 10
        tooltipStats.Size = UDim2.fromScale(0.90, 0.28)
        tooltipStats.Position = UDim2.fromScale(0.045, 0.36)
        tooltipDescription.Size = UDim2.fromScale(0.90, 0.25)
        tooltipDescription.Position = UDim2.fromScale(0.045, 0.72)
        local tooltipDivider = tooltipFrame:FindFirstChild("TooltipDivider")
        if tooltipDivider then tooltipDivider.Position = UDim2.fromScale(0.045, 0.68) end
    else
        aspectConstraint.Parent = nil
        local viewportWidth = viewport.X
        local viewportHeight = viewport.Y
        local desktopHeight = math.min(viewportHeight * 0.88, 720)
        local desktopWidth = math.min(viewportWidth * 0.78, desktopHeight * 1.49)
        mainFrame.Size = UDim2.fromScale(desktopWidth / viewportWidth, desktopHeight / viewportHeight)
        mainFrame.Position = UDim2.fromScale(math.max(12, (viewportWidth - desktopWidth) / 2) / viewportWidth,
            math.max(12, (viewportHeight - desktopHeight) / 2) / viewportHeight)
        titleLabel.TextSize = 20
        characterLabel.TextSize = 11
        specTabs.Position = UDim2.fromScale(0.025, 0.135)
        specTabs.Size = UDim2.fromScale(0.58, 0.055)
        listHeader.Visible = true
        listHeader.Position = UDim2.fromScale(0.04, 0.205)
        skillList.Position = UDim2.fromScale(0.025, 0.245)
        skillList.Size = UDim2.fromScale(0.58, 0.48)
        barPreview.Position = UDim2.fromScale(0.025, 0.755)
        barPreview.Size = UDim2.fromScale(0.58, 0.17)
        tooltipFrame.Position = UDim2.fromScale(0.635, 0.135)
        tooltipFrame.Size = UDim2.fromScale(0.34, 0.30)
        statesFrame.Position = UDim2.fromScale(0.635, 0.46)
        statesFrame.Size = UDim2.fromScale(0.34, 0.25)
        statesFrame.Visible = true
        footerLabel.Visible = true
        infoLabel.Position = UDim2.fromScale(0.04, 0.935)
        infoLabel.Size = UDim2.fromScale(0.56, 0.035)
        errorLabel.Position = UDim2.fromScale(0.635, 0.735)
        errorLabel.Size = UDim2.fromScale(0.34, 0.075)
        tooltipTitle.TextSize = 18
        tooltipStats.TextSize = 12
        tooltipDescription.TextSize = 12
        tooltipStats.Size = UDim2.fromScale(0.87, 0.25)
        tooltipStats.Position = UDim2.fromScale(0.045, 0.35)
        tooltipDescription.Size = UDim2.fromScale(0.87, 0.23)
        tooltipDescription.Position = UDim2.fromScale(0.045, 0.71)
        local tooltipDivider = tooltipFrame:FindFirstChild("TooltipDivider")
        if tooltipDivider then tooltipDivider.Position = UDim2.fromScale(0.045, 0.65) end
        if UserInputService.TouchEnabled then
            -- Landscape uses two columns instead of shrinking a portrait stack.
            mainFrame.Size = UDim2.fromScale(0.94, 0.94)
            mainFrame.Position = UDim2.fromScale(0.03, 0.03)
            titleLabel.TextSize = 16
            characterLabel.TextSize = 10
            skillList.Position = UDim2.fromScale(0.025, 0.23)
            skillList.Size = UDim2.fromScale(0.58, 0.43)
            barPreview.Position = UDim2.fromScale(0.025, 0.69)
            barPreview.Size = UDim2.fromScale(0.58, 0.25)
            tooltipFrame.Position = UDim2.fromScale(0.635, 0.17)
            tooltipFrame.Size = UDim2.fromScale(0.34, 0.72)
            tooltipTitle.TextSize = 15
            tooltipStats.TextSize = 11
            tooltipDescription.TextSize = 11
            statesFrame.Visible = false
            footerLabel.Visible = false
        end
    end
end

local function clearSkillList()
    for _, child in ipairs(skillList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local function updateBarPreview(loadout)
    for i = 1, 4 do
        local slot = barSlots[i]
        if slot then
            local icon = slot:FindFirstChild("SkillIcon")
            local placeholder = slot:FindFirstChild("IconPlaceholder")
            local name = slot:FindFirstChild("SlotName")
            local cost = slot:FindFirstChild("SlotCost")
            local skillId = loadout and loadout[i]
            local skillInfo = skillId and findSkill(skillId) or nil
            if skillInfo then
                setImageOrPlaceholder(icon, placeholder, skillInfo.iconId)
                if name then name.Text = tostring(skillInfo.name or niceName(skillInfo.skillId)) end
                if cost then cost.Text = tostring(skillInfo.manaCost or 0) .. " MP · " .. tostring(skillInfo.cooldown or 0) .. "s" end
            else
                if icon then icon.Image = "" end
                if icon then icon.Visible = false end
                if placeholder then placeholder.Visible = true end
                if name then name.Text = "VACÍO" end
                if cost then cost.Text = "—" end
            end

            local selected = selectedSlot == i
            local baseStrokeColor = selected and COLORS.blue or (skillInfo and COLORS.gold or COLORS.dim)
            slot:SetAttribute("HearthboundBlackCell", true)
            slot:SetAttribute("HearthboundCellBaseStrokeColor", baseStrokeColor)
            slot:SetAttribute("HearthboundCellBaseStrokeThickness", selected and 2 or 1)
            slot:SetAttribute("HearthboundCellBaseStrokeTransparency", 0)
            local slotStroke = slot:FindFirstChild("SpellbookStroke")
            if slotStroke then
                slotStroke.Color = baseStrokeColor
                slotStroke.Thickness = selected and 2 or 1
            end
            slot.BackgroundColor3 = COLORS.black
        end
    end
end

local function makeSkillCard(skill, index)
    local state = skillState(skill)
    local borderColor, backgroundColor = stateColors(state)
    local card = Instance.new("TextButton")
    card.Name = "Skill_" .. tostring(skill.skillId or index)
    card.Size = UDim2.new(1, -2, 0, 68)
    card.BackgroundColor3 = COLORS.black
    card:SetAttribute("HearthboundBlackCell", true)
    card:SetAttribute("HearthboundCellBaseStrokeColor", borderColor)
    card:SetAttribute("HearthboundCellBaseStrokeThickness", state == "ASIGNADA" and 2 or 1)
    card:SetAttribute("HearthboundCellBaseStrokeTransparency", 0)
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.LayoutOrder = index
    card.ZIndex = 4
    card.Parent = skillList
    corner(card, 7)
    local cardStroke = stroke(card, borderColor, state == "ASIGNADA" and 2 or 1)

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundColor3 = COLORS.black
    icon.BackgroundTransparency = 0
    icon.Position = UDim2.fromScale(0.025, 0.12)
    icon.Size = UDim2.fromScale(0.12, 0.76)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 6
    icon.Parent = card
    corner(icon, 5)
    local placeholder = label(card, "IconPlaceholder", "✦", UDim2.fromScale(0.025, 0.12), UDim2.fromScale(0.12, 0.76), borderColor, UITheme.GetFont("BodyBold"), 20)
    placeholder.TextXAlignment = Enum.TextXAlignment.Center
    placeholder.ZIndex = 7
    corner(placeholder, 5)
    setImageOrPlaceholder(icon, placeholder, skill.iconId)

    local name = label(card, "Name", tostring(skill.name or niceName(skill.skillId)), UDim2.fromScale(0.16, 0.10), UDim2.fromScale(0.53, 0.34), COLORS.goldLight, UITheme.GetFont("BodyBold"), 14)
    name.ZIndex = 8
    local meta = label(card, "Meta", string.format("%s  ·  %s", skillTypeName(skill.type), skillOrigin(skill)), UDim2.fromScale(0.16, 0.52), UDim2.fromScale(0.62, 0.25), COLORS.muted, UITheme.GetFont("Mono"), 10)
    meta.ZIndex = 8
    local stats = label(card, "Stats", string.format("%s MP  ·  CD %ss", tostring(skill.manaCost or 0), tostring(skill.cooldown or 0)), UDim2.fromScale(0.70, 0.15), UDim2.fromScale(0.27, 0.30), COLORS.muted, UITheme.GetFont("Mono"), 10)
    stats.TextXAlignment = Enum.TextXAlignment.Right
    stats.ZIndex = 8
    local badge = label(card, "State", state, UDim2.fromScale(0.70, 0.52), UDim2.fromScale(0.27, 0.25), borderColor, UITheme.GetFont("Mono"), 10)
    badge.TextXAlignment = Enum.TextXAlignment.Right
    badge.ZIndex = 8

    card.MouseEnter:Connect(function()
        setTooltip(skill)
        cardStroke.Color = borderColor:Lerp(COLORS.goldLight, 0.28)
        cardStroke.Thickness = math.max(2, state == "ASIGNADA" and 2 or 1)
    end)
    card.MouseLeave:Connect(function()
        cardStroke.Color = borderColor
        cardStroke.Thickness = state == "ASIGNADA" and 2 or 1
    end)
    card.Activated:Connect(function()
        setTooltip(skill)
        if not skill.canUse then
            showError("Esta skill está bloqueada: " .. skillOrigin(skill))
            return
        end
        if not selectedSlot then
            showError("Selecciona un slot de la barra primero")
            return
        end
        RequestAssignBarSlot:FireServer({
            slot = selectedSlot,
            skillId = skill.skillId,
        })
    end)
    return card
end

local function populateSkillList()
    clearSkillList()
    if not currentData or not currentData.skills then
        statesInfo.Text = "No hay skills disponibles."
        footerLabel.Text = "0 skills aprendidas · barra limita a 4"
        return
    end

    local count = #currentData.skills
    for index, skill in ipairs(currentData.skills) do
        makeSkillCard(skill, index)
    end
    statesInfo.Text = count == 0 and "No hay más skills por aprender." or (tostring(count) .. " skills en el grimorio.")
    footerLabel.Text = tostring(count) .. " skills aprendidas · barra limita a 4 · las skills de talento se revocan con respec"
    characterLabel.Text = string.format(
        "%s · NIVEL %s · %d HABILIDADES APRENDIDAS",
        tostring(localPlayer:GetAttribute("CharacterName") or localPlayer.Name),
        tostring(currentData.level or localPlayer:GetAttribute("CharacterLevel") or localPlayer:GetAttribute("Level") or localPlayer:GetAttribute("PlayerLevel") or 1),
        count
    )
    local className = niceName(currentData.classId or localPlayer:GetAttribute("ClassId") or "Paladín")
    local specName = niceName(currentData.specId or localPlayer:GetAttribute("SpecId") or "Castigo")
    titleLabel.Text = "GRIMORIO · " .. string.upper(className) .. " — " .. string.upper(specName)
    local activeTab = specTabs:FindFirstChild("ActiveTab")
    if activeTab then
        activeTab.Text = string.upper(className) .. " · " .. string.upper(specName)
    end
end

buildShell()
applyResponsiveLayout()
local viewportConnection
local function bindViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout) end
    applyResponsiveLayout()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
spellbookGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyResponsiveLayout)
bindViewport()

SpellbookData.OnClientEvent:Connect(function(data)
    currentData = data
    populateSkillList()
    updateBarPreview(data and data.loadout or nil)
    setTooltip(nil)
end)

BarSlotAssigned.OnClientEvent:Connect(function(data)
    if data and data.success then
        if currentData and currentData.loadout then
            currentData.loadout[data.slot] = data.skillId
        end
        selectedSlot = nil
        updateBarPreview(currentData and currentData.loadout or nil)
        populateSkillList()
        setTooltip(findSkill(data.skillId))
        showError(nil)
    else
        showError((data and data.error) or "Error al asignar")
    end
end)

local function openSpellbook()
    buildShell()
    applyResponsiveLayout()
    isOpen = true
    spellbookGui.Enabled = true
    mainFrame.Visible = true
    if UserInputService.TouchEnabled then
        local mobileAccessGui = playerGui:FindFirstChild("MobileAccessUI")
        if mobileAccessGui then
            mobileAccessWasEnabled = mobileAccessGui.Enabled
            mobileAccessGui.Enabled = false
            local mobileStackGui = mobileAccessGui:FindFirstChild("MobileAccessStack")
            if mobileStackGui then
                mobileAccessStackWasVisible = mobileStackGui.Visible
                mobileStackGui.Visible = false
            end
        end
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    localPlayer:SetAttribute("UIWindowOpen", true)
    selectedSlot = nil
    local target = mainFrame.Position
    mainFrame.Position = target + UDim2.fromOffset(0, 12)
    mainFrame.BackgroundTransparency = 0.05
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = target,
        BackgroundTransparency = 0,
    }):Play()
    RequestSpellbook:FireServer()
end

local function closeSpellbook()
    isOpen = false
    spellbookGui.Enabled = false
    mainFrame.Visible = false
    if UserInputService.TouchEnabled and mobileAccessWasEnabled then
        local mobileAccessGui = playerGui:FindFirstChild("MobileAccessUI")
        if mobileAccessGui then
            mobileAccessGui.Enabled = true
            local mobileStackGui = mobileAccessGui:FindFirstChild("MobileAccessStack")
            if mobileStackGui and mobileAccessStackWasVisible then
                mobileStackGui.Visible = true
            end
        end
        mobileAccessWasEnabled = false
        mobileAccessStackWasVisible = false
    end
    errorLabel.Text = ""
    errorLabel.Visible = false
    selectedSlot = nil
    localPlayer:SetAttribute("UIWindowOpen", false)
end

closeBtn.Activated:Connect(closeSpellbook)

local lastMicroMenuRequestId = nil
local lastMicroMenuCloseRequestId = nil

localPlayer:GetAttributeChangedSignal("MicroMenuCloseRequestId"):Connect(function()
    local requestId = localPlayer:GetAttribute("MicroMenuCloseRequestId")
    if requestId == lastMicroMenuCloseRequestId then
        return
    end
    lastMicroMenuCloseRequestId = requestId
    if isOpen then
        closeSpellbook()
    end
end)

localPlayer:GetAttributeChangedSignal("MicroMenuRequestId"):Connect(function()
    local requestId = localPlayer:GetAttribute("MicroMenuRequestId")
    if requestId == lastMicroMenuRequestId then
        return
    end
    lastMicroMenuRequestId = requestId
    if localPlayer:GetAttribute("MicroMenuAction") ~= "Spellbook" then
        return
    end
    if isOpen then
        closeSpellbook()
    elseif localPlayer:GetAttribute("CharacterName") then
        openSpellbook()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.P then
        if isOpen then
            closeSpellbook()
        elseif localPlayer:GetAttribute("CharacterName") then
            openSpellbook()
        end
    end
end)

print("[Vandrheim] SpellbookClient HU-ESTETICA-17 activo")
