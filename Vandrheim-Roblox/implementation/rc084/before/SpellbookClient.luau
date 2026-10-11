--[[
    SpellbookClient — HU-ESTETICA-42 / rc082
    Presentación del grimorio WUFrU. SpellService/R5.1 mantiene autoridad y contratos.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ConfigFolder = ReplicatedStorage:WaitForChild("Config")
local SkillConfig = require(ConfigFolder:WaitForChild("SkillConfig"))
local TalentConfig = require(ConfigFolder:WaitForChild("TalentConfig"))
local ClassConfig = require(ConfigFolder:WaitForChild("ClassConfig"))
local UITheme = require(ConfigFolder:WaitForChild("UITheme"))
local BookConfig = require(ConfigFolder:WaitForChild("SpellbookUIConfig"))
local C = BookConfig.Colors
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestSpellbook = Remotes:WaitForChild("RequestSpellbook")
local RequestAssignBarSlot = Remotes:WaitForChild("RequestAssignBarSlot")
local SpellbookData = Remotes:WaitForChild("SpellbookData")
local BarSlotAssigned = Remotes:WaitForChild("BarSlotAssigned")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("SpellbookUI")
local main = gui:WaitForChild("MainFrame")
local closeButton = main:WaitForChild("CloseButton")
local errorLabel = main:WaitForChild("ErrorLabel")
local isOpen, currentData, selectedSlot = false, nil, nil
local filterMode = "All"
local mobileAccessWasEnabled, mobileStackWasVisible = false, false
local aspect
local page, header, titleLabel, characterLabel, countLabel, filterAll, filterUnassigned
local skillList, bar, barTitle, infoLabel
local slotButtons = {}
local COLORS_BORDER = C.Border
local selectBarSlot

local function font(role)
    return UITheme.GetFont(role)
end

local function addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

local function addStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness = color, thickness or 1
    stroke.Parent = obj
    return stroke
end

local function make(className, name, parent, props)
    local obj = Instance.new(className)
    obj.Name, obj.Parent = name, parent
    for key, value in pairs(props or {}) do obj[key] = value end
    return obj
end

local function label(parent, name, text, position, size, color, role, textSize, align)
    return make("TextLabel", name, parent, {
        BackgroundTransparency = 1, Text = text or "", TextColor3 = color or C.Parchment,
        Font = font(role or "Body"), TextSize = textSize or 14,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = false,
        Position = position, Size = size, ZIndex = 5,
    })
end

local function setResponsive()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or gui.AbsoluteSize
    if viewport.X < 1 or viewport.Y < 1 then return end
    header.Size = UDim2.fromScale(0.90, 0.11)
    titleLabel.Size = UDim2.fromScale(0.76, 0.055)
    characterLabel.Position, characterLabel.Size = UDim2.fromScale(0, 0.58), UDim2.fromScale(0.80, 0.30)
    local touchPortrait = UserInputService.TouchEnabled and viewport.X < viewport.Y
    local touchLandscape = UserInputService.TouchEnabled and viewport.X >= viewport.Y
    if aspect then
        if touchPortrait or touchLandscape then aspect.Parent = nil else aspect.Parent = main end
    end
    if touchPortrait then
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.Position = UDim2.fromScale(0.5, 0.5)
        main.Size = UDim2.fromScale(0.94, 0.72)
        page.Position, page.Size = UDim2.fromScale(0.025, 0.13), UDim2.fromScale(0.95, 0.62)
        bar.Position, bar.Size = UDim2.fromScale(0.025, 0.77), UDim2.fromScale(0.95, 0.18)
        skillList.Position, skillList.Size = UDim2.fromScale(0.028, 0.13), UDim2.fromScale(0.944, 0.87)
        titleLabel.TextSize, characterLabel.TextSize = 19, 10
        countLabel.TextSize, infoLabel.TextSize = 10, 9
    elseif touchLandscape then
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.Position = UDim2.fromScale(0.5, 0.5)
        main.Size = UDim2.fromScale(0.48, 0.76)
        page.Position, page.Size = UDim2.fromScale(0.03235, 0.205), UDim2.fromScale(0.9353, 0.58)
        bar.Position, bar.Size = UDim2.fromScale(0.03235, 0.805), UDim2.fromScale(0.9353, 0.18)
        skillList.Position, skillList.Size = UDim2.fromScale(0.0283, 0.22), UDim2.fromScale(0.9434, 0.78)
        local pageTitle = page:FindFirstChild("PageTitle")
        local pageRule = page:FindFirstChild("PageTopRule")
        local filters = page:FindFirstChild("SkillFilters")
        if pageTitle then
            pageTitle.Position, pageTitle.Size = UDim2.fromScale(0.0283, 0.015), UDim2.fromScale(0.48, 0.075)
            pageTitle.TextSize = 10
        end
        countLabel.Position, countLabel.Size, countLabel.TextSize =
            UDim2.fromScale(0.72, 0.015), UDim2.fromScale(0.25, 0.075), 8
        if filters then filters.Position, filters.Size = UDim2.fromScale(0.0283, 0.10), UDim2.fromScale(0.43, 0.09) end
        if filterAll then filterAll.TextSize = 8 end
        if filterUnassigned then filterUnassigned.TextSize = 8 end
        if pageRule then pageRule.Position = UDim2.fromScale(0.0283, 0.205) end
        titleLabel.TextSize, characterLabel.TextSize = 14, 8
        infoLabel.TextSize = 9
    else
        main.AnchorPoint = Vector2.new(0.5, 0.5)
        main.Position = UDim2.fromScale(0.5, 0.5)
        if aspect then
            local heightScale = 0.74
            main.Size = UDim2.fromScale(heightScale * BookConfig.Design.CompactAspectRatio * viewport.Y / viewport.X, heightScale)
        end
        page.Position, page.Size = UDim2.fromScale(0.03235, 0.10), UDim2.fromScale(0.9353, 0.69)
        bar.Position, bar.Size = UDim2.fromScale(0.03235, 0.81), UDim2.fromScale(0.9353, 0.18)
        skillList.Position, skillList.Size = UDim2.fromScale(0.0283, 0.13), UDim2.fromScale(0.9434, 0.87)
        titleLabel.Size = UDim2.fromScale(0.76, 0.045)
        characterLabel.Position = UDim2.fromScale(0, 0.42)
        titleLabel.TextSize, characterLabel.TextSize = 20, 10
        countLabel.TextSize, infoLabel.TextSize = 9, 9
    end
    local closeSize = 32
    local closeWidth = closeSize / main.AbsoluteSize.X
    closeButton.AnchorPoint = Vector2.zero
    closeButton.Position = UDim2.fromScale(0.976 - closeWidth, 0.016)
    closeButton.Size = UDim2.fromScale(closeWidth, closeSize / main.AbsoluteSize.Y)
    closeButton.TextSize = 15
    closeButton.ZIndex = 30
end

local function makeShell()
    for _, child in ipairs(main:GetChildren()) do
        if child ~= closeButton and child ~= errorLabel and child.Name ~= "R611DragHandle" then child:Destroy() end
    end
    main.BackgroundColor3, main.BorderSizePixel, main.ClipsDescendants = C.Canvas, 0, true
    addCorner(main, 14)
    addStroke(main, C.Gold, 1)
    aspect = make("UIAspectRatioConstraint", "SpellbookAspect", main, {
        AspectRatio = BookConfig.Design.CompactAspectRatio, AspectType = Enum.AspectType.ScaleWithParentSize,
        DominantAxis = Enum.DominantAxis.Width,
    })

    header = make("Frame", "BookHeader", main, {
        BackgroundTransparency = 1, Position = UDim2.fromScale(0.05, 0.018), Size = UDim2.fromScale(0.90, 0.11), ZIndex = 4,
    })
    titleLabel = label(main, "Title", "GRIMORIO", UDim2.fromScale(0.05, 0.018), UDim2.fromScale(0.76, 0.055), C.Parchment, "Title", 20)
    titleLabel.Font = UITheme.GetFont("Title")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    characterLabel = label(header, "CharacterLabel", "PERSONAJE · NIVEL 1", UDim2.fromScale(0, 0.58), UDim2.fromScale(0.80, 0.25), C.Gold, "Mono", 10)
    characterLabel.Font = font("Mono")
    closeButton.Parent = main
    for _, child in ipairs(closeButton:GetChildren()) do
        if child:IsA("UICorner") or child:IsA("UIStroke") then child:Destroy() end
    end
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.fromScale(0.976, 0.012)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.BuilderSansBold
    closeButton.TextSize, closeButton.TextScaled = 18, false
    closeButton.TextColor3 = Color3.fromRGB(244, 237, 224)
    closeButton.TextTransparency, closeButton.TextStrokeTransparency = 0, 1
    closeButton.BackgroundColor3, closeButton.BackgroundTransparency = Color3.fromRGB(58, 37, 37), 0
    closeButton.AutoButtonColor, closeButton.BorderSizePixel, closeButton.ZIndex = false, 0, 30
    addCorner(closeButton, 5)
    addStroke(closeButton, Color3.fromRGB(107, 74, 43), 1)

    page = make("Frame", "LearnedSkillsPage", main, {
        BackgroundColor3 = C.Page, BorderSizePixel = 0, Position = UDim2.fromScale(0.03235, 0.10),
        Size = UDim2.fromScale(0.9353, 0.69), ZIndex = 2,
    })
    addCorner(page, 12)
    addStroke(page, C.Border, 1)
    label(page, "PageTitle", "HABILIDADES", UDim2.fromScale(0.0283, 0.02), UDim2.fromScale(0.48, 0.04), C.Gold, "Mono", 12).Font = font("Mono")
    countLabel = label(page, "KnownCount", "0 CONOCIDAS", UDim2.fromScale(0.72, 0.02), UDim2.fromScale(0.25, 0.04), C.Muted, "Mono", 9, Enum.TextXAlignment.Right)
    countLabel.Font = font("Mono")
    local rule = make("Frame", "PageTopRule", page, {
        BackgroundColor3 = C.Border, BorderSizePixel = 0, Position = UDim2.fromScale(0.0283, 0.112), Size = UDim2.fromScale(0.9434, 0.002),
    })
    local filterFrame = make("Frame", "SkillFilters", page, {
        BackgroundColor3 = Color3.fromRGB(23, 19, 17), BorderSizePixel = 0,
        Position = UDim2.fromScale(0.0283, 0.062), Size = UDim2.fromScale(0.43, 0.040),
    })
    addCorner(filterFrame, 5)
    addStroke(filterFrame, C.Border, 1)
    local function makeFilter(name, text, x)
        local button = make("TextButton", name, filterFrame, {
            BackgroundColor3 = C.Panel, BorderSizePixel = 0, Position = UDim2.fromScale(x, 0.12),
            Size = UDim2.fromScale(0.485, 0.76), Text = text, TextColor3 = C.Muted,
            TextSize = 9, Font = font("Mono"), AutoButtonColor = false, ZIndex = 4,
        })
        addCorner(button, 4)
        local function applyFilter()
            local mode = name == "FilterAll" and "All" or "Unassigned"
            filterMode = mode
            filterAll.BackgroundColor3 = mode == "All" and C.Gold or Color3.fromRGB(58, 48, 42)
            filterAll.TextColor3 = mode == "All" and C.Canvas or C.Muted
            filterUnassigned.BackgroundColor3 = mode == "Unassigned" and C.Gold or Color3.fromRGB(58, 48, 42)
            filterUnassigned.TextColor3 = mode == "Unassigned" and C.Canvas or C.Muted
            for _, child in ipairs(skillList:GetChildren()) do
                if child:IsA("TextButton") then
                    local id = string.sub(child.Name, 7)
                    local assigned = false
                    for _, slotId in ipairs(currentData and currentData.loadout or {}) do
                        if slotId == id then assigned = true break end
                    end
                    child.Visible = mode == "All" or not assigned
                end
            end
        end
        button.MouseButton1Click:Connect(applyFilter)
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then applyFilter() end
        end)
        return button
    end
    filterAll = makeFilter("FilterAll", "TODAS · 0", 0.015)
    filterUnassigned = makeFilter("FilterUnassigned", "NO ASIGNADAS · 0", 0.5)
    skillList = make("ScrollingFrame", "SkillList", page, {
        BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromScale(0.0283, 0.13),
        Size = UDim2.fromScale(0.9434, 0.87), ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Gold, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(), ClipsDescendants = true, ZIndex = 3,
    })
    make("UIPadding", "SpellbookPadding", skillList, {
        PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
    })
    make("UIListLayout", "SpellbookLayout", skillList, {
        Padding = UDim.new(2 / (660 * skillList.Size.Y.Scale), 0), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    bar = make("Frame", "BarPreview", main, {
        BackgroundColor3 = C.Bar, BorderSizePixel = 0, Position = UDim2.fromScale(0.03235, 0.80),
        Size = UDim2.fromScale(0.9353, 0.16), ZIndex = 2,
    })
    addCorner(bar, 10)
    addStroke(bar, C.Gold, 1)
    barTitle = label(bar, "LoadoutHeader", "BARRA EQUIPADA · 4 HABILIDADES", UDim2.fromScale(0.022, 0.055), UDim2.fromScale(0.70, 0.22), C.Gold, "Mono", 9)
    barTitle.Font = font("Mono")
    local slotRow = make("Frame", "SlotRow", bar, {
        BackgroundTransparency = 1, Position = UDim2.fromScale(0.018, 0.29), Size = UDim2.fromScale(0.964, 0.65),
    })
    local layout = make("UIListLayout", "SlotLayout", slotRow, {
        FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0.012, 0), SortOrder = Enum.SortOrder.LayoutOrder,
    })
    for i = 1, 4 do
        local slot = make("TextButton", "BarSlot" .. i, slotRow, {
            BackgroundColor3 = C.Slot, BorderSizePixel = 0, Size = UDim2.new(0.238, 0, 1, 0),
            Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 4,
        })
        addCorner(slot, 6)
        slotButtons[i] = {button = slot}
        slotButtons[i].stroke = addStroke(slot, C.Border, 1)
        local icon = make("ImageLabel", "SkillIcon", slot, {
            BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Crop, Image = "", ZIndex = 5,
        })
        local textScrim = make("Frame", "SlotTextScrim", slot, {
            BackgroundColor3 = C.Canvas, BackgroundTransparency = 0.22, BorderSizePixel = 0,
            Position = UDim2.fromScale(0, 0.56), Size = UDim2.fromScale(1, 0.44), ZIndex = 7,
        })
        addCorner(textScrim, 6)
        local keyLabel = label(slot, "KeyLabel", tostring(i),
            UDim2.fromScale(0.045, 0.055), UDim2.fromScale(0.19, 0.29),
            C.Parchment, "Mono", 12, Enum.TextXAlignment.Center)
        keyLabel.Font, keyLabel.ZIndex = font("Mono"), 9
        keyLabel.BackgroundColor3, keyLabel.BackgroundTransparency = C.Canvas, 0.08
        keyLabel.BorderSizePixel = 0
        addCorner(keyLabel, 4)
        local slotName = label(slot, "SlotName", "VACÍO",
            UDim2.fromScale(0.045, 0.595), UDim2.fromScale(0.91, 0.22),
            C.Parchment, "BodyBold", 13, Enum.TextXAlignment.Center)
        slotName.Font, slotName.ZIndex = font("BodyBold"), 9
        slotName.TextTruncate = Enum.TextTruncate.AtEnd
        local slotCost = label(slot, "SlotCost", "—",
            UDim2.fromScale(0.045, 0.815), UDim2.fromScale(0.91, 0.15),
            C.Cost, "Mono", 10, Enum.TextXAlignment.Center)
        slotCost.Font, slotCost.ZIndex = font("Mono"), 9
        slot.Activated:Connect(function() selectBarSlot(i) end)
        slot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                local assigned = currentData and currentData.loadout and currentData.loadout[i]
                if assigned and assigned ~= "" then
                    selectedSlot = nil
                    RequestAssignBarSlot:FireServer({ slot = i, skillId = "" })
                end
            end
        end)
    end
    infoLabel = label(main, "InfoLabel", "Selecciona un slot y luego una habilidad para asignarla.", UDim2.fromScale(0.05, 0.982), UDim2.fromScale(0.90, 0.014), C.Muted, "Mono", 9)
    infoLabel.Visible = false
    errorLabel.Parent = main
    errorLabel.BackgroundColor3, errorLabel.BackgroundTransparency = C.Error, 0.05
    errorLabel.TextColor3, errorLabel.Font = C.Parchment, font("BodyBold")
    errorLabel.TextSize, errorLabel.TextWrapped, errorLabel.Visible = 12, true, false
    errorLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    errorLabel.Position, errorLabel.Size = UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.75, 0.10)
    errorLabel.ZIndex = 50
    setResponsive()
end

local function getSkill(skill)
    return (skill and SkillConfig.Get(skill.skillId)) or skill or {}
end

local function getTalentOrigin(skill)
    for _, specIds in pairs(TalentConfig.SPECS_BY_CLASS or {}) do
        for _, specId in ipairs(specIds) do
            local branches = TalentConfig.GetBranches(specId) or {}
            for _, branch in pairs(branches) do
                for _, node in ipairs(branch.nodes or {}) do
                    if node.skillId == skill.skillId then
                        local capstone = (node.pointsRequired or 0) >= 8 or (node.levelReq or 1) >= 16
                        return {
                            text = string.format("Talento · %s · %s", tostring(branch.name or "Rama"),
                                capstone and "Capstone" or "Tier 2"),
                            tier = capstone and "Capstone" or "Talent",
                        }
                    end
                end
            end
        end
    end
    local level = tonumber(skill.levelReq) or 1
    if level <= 1 and not skill.specId then return {text = "Básica · Nivel 1", tier = "Level"} end
    local specName = tostring(skill.specId or currentData.specId or "Especialización")
    specName = specName:match("([^_]+)$") or specName
    return {text = string.format("%s · Nivel %d", specName, level), tier = "Level"}
end

local function niceName(value)
    value = tostring(value or "—"):gsub("_", " "):gsub("%-", " ")
    return value:sub(1, 1):upper() .. value:sub(2)
end

local function getClassSpecText()
    local classId, specId = currentData.classId, currentData.specId
    local class = ClassConfig[classId] or {}
    local className = class.DisplayName or niceName(classId)
    local specName = ""
    for _, spec in pairs(class.Specs or {}) do
        if specId and (specId == spec.Name or specId:lower():gsub("%s+", "") == tostring(spec.Name):lower():gsub("%s+", "") or specId:match("([^_]+)$") == spec.Name) then
            specName = spec.Name
        end
    end
    if specName == "" then specName = niceName(specId) end
    local level = currentData.level or player:GetAttribute("CharacterLevel") or player:GetAttribute("Level") or player:GetAttribute("PlayerLevel") or 1
    return string.format("%s · %s · NIVEL %s", string.upper(tostring(className)), string.upper(tostring(specName)), tostring(level))
end

local function formatNumber(value)
    local number = tonumber(value)
    if not number then return nil end
    return string.format("%.2f", number):gsub("0+$", ""):gsub("%.$", "")
end

local function detailText(skill)
    local cfg = getSkill(skill)
    local kind = tostring(cfg.type or "Skill"):upper()
    local stat = cfg.stat and (" · " .. tostring(cfg.stat)) or ""
    local radius = formatNumber(cfg.aoeRadius)
    if radius then kind ..= " · R" .. radius end
    local scaling = cfg.coefficient and cfg.coefficient ~= 0 and (" · ESCALA " .. tostring(cfg.stat or "STAT") .. " ×" .. tostring(formatNumber(cfg.coefficient))) or ""
    local range
    if cfg.type == "GroundAoE" then
        range = radius and ("RADIO " .. radius) or nil
        local cast = formatNumber(cfg.maxCastRange)
        if cast then range = (range and range .. " · " or "") .. "LANZAMIENTO " .. cast end
    elseif cfg.type == "SelfAoE" then
        range = radius and ("RADIO " .. radius .. " · PROPIA") or "OBJETIVO PROPIO"
    elseif cfg.range then range = "RANGO " .. tostring(formatNumber(cfg.range))
    elseif cfg.allyRange then range = "RANGO ALIADO " .. tostring(formatNumber(cfg.allyRange))
    elseif cfg.targetType == "self_only" then range = "OBJETIVO PROPIO" end
    return kind .. stat .. scaling, range
end

local function iconIdFor(skill)
    local cfg = getSkill(skill)
    local id = cfg.iconId or skill.iconId
    if not id or id == "" or id == "rbxassetid://0" then return "" end
    return tostring(id)
end

local function assignedSlot(skillId)
    for index, id in ipairs(currentData and currentData.loadout or {}) do
        if id == skillId then return index end
    end
end

local function clearRows()
    for _, child in ipairs(skillList:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

local TOUCH_DRAG_HOLD_SECONDS = 0.30
local DRAG_START_DISTANCE_PX = 8
local pendingSkillDrag = nil
local activeSkillDrag = nil
local skillDragScrollWasEnabled = nil
local lastSkillDragEndAt = -math.huge

local skillDragOverlayGui = playerGui:FindFirstChild("SpellbookDragOverlayUI")
if not skillDragOverlayGui then
    skillDragOverlayGui = Instance.new("ScreenGui")
    skillDragOverlayGui.Name = "SpellbookDragOverlayUI"
    skillDragOverlayGui.ResetOnSpawn = false
    skillDragOverlayGui.IgnoreGuiInset = true
    skillDragOverlayGui.DisplayOrder = 1000
    skillDragOverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    skillDragOverlayGui.Parent = playerGui
end

local skillDragGhost = skillDragOverlayGui:FindFirstChild("SkillDragGhost")
if not skillDragGhost then
    skillDragGhost = Instance.new("ImageLabel")
    skillDragGhost.Name = "SkillDragGhost"
    skillDragGhost.Size = UDim2.fromOffset(48, 48)
    skillDragGhost.AnchorPoint = Vector2.new(0.5, 0.5)
    skillDragGhost.BackgroundColor3 = C.Panel
    skillDragGhost.BackgroundTransparency = 0.12
    skillDragGhost.BorderSizePixel = 0
    skillDragGhost.ScaleType = Enum.ScaleType.Crop
    skillDragGhost.Visible = false
    skillDragGhost.ZIndex = 100
    skillDragGhost.Parent = skillDragOverlayGui
    addCorner(skillDragGhost, 7)
    addStroke(skillDragGhost, C.Gold, 2)
    local aspectConstraint = make("UIAspectRatioConstraint", "AspectConstraint", skillDragGhost, { AspectRatio = 1 })
end

local function pointerInside(guiObject, point)
    if not guiObject or not guiObject.Visible then return false end
    local position, size = guiObject.AbsolutePosition, guiObject.AbsoluteSize
    return size.X > 0 and size.Y > 0
        and point.X >= position.X and point.Y >= position.Y
        and point.X <= position.X + size.X and point.Y <= position.Y + size.Y
end

local function findBarSlotAtPosition(point)
    if not isOpen or not main.Visible then return nil end
    for index, slotInfo in ipairs(slotButtons) do
        if pointerInside(slotInfo.button, point) then return index end
    end
    return nil
end

local function setSkillDropHighlights(point)
    local candidate = activeSkillDrag
    if not candidate then return end
    skillDragGhost.Image = iconIdFor(candidate.skill)
    skillDragGhost.Position = UDim2.fromOffset(point.X, point.Y)
    skillDragGhost.Visible = true
    local hoveredSlot = findBarSlotAtPosition(point)
    for index, slotInfo in ipairs(slotButtons) do
        local button = slotInfo.button
        local highlight = button:FindFirstChild("R6_32DropHighlight")
        if not highlight then
            highlight = Instance.new("Frame")
            highlight.Name = "R6_32DropHighlight"
            highlight.BackgroundTransparency = 1
            highlight.BorderSizePixel = 3
            highlight.Size = UDim2.fromScale(1, 1)
            highlight.Position = UDim2.fromScale(0, 0)
            highlight.Active = false
            highlight.ZIndex = 10
            highlight.Parent = button
            addCorner(highlight, 6)
        end
        highlight.BorderColor3 = index == hoveredSlot and Color3.fromRGB(103, 219, 145) or C.Gold
        highlight.Visible = candidate.skill.canUse == true
    end
end

local function clearSkillDrag()
    pendingSkillDrag = nil
    activeSkillDrag = nil
    skillDragGhost.Visible = false
    for _, slotInfo in ipairs(slotButtons) do
        local highlight = slotInfo.button:FindFirstChild("R6_32DropHighlight")
        if highlight then highlight.Visible = false end
    end
    if skillDragScrollWasEnabled ~= nil and skillList then
        skillList.ScrollingEnabled = skillDragScrollWasEnabled
        skillDragScrollWasEnabled = nil
    end
end

local function startSkillDrag(candidate)
    if pendingSkillDrag ~= candidate or not candidate.skill.canUse then return end
    pendingSkillDrag = nil
    activeSkillDrag = candidate
    if skillList then
        skillDragScrollWasEnabled = skillList.ScrollingEnabled
        skillList.ScrollingEnabled = false
    end
    setSkillDropHighlights(candidate.lastPosition)
end

local function pointerMatchesSkillChange(candidate, input)
    if candidate.inputType == Enum.UserInputType.Touch then
        return input.UserInputType == Enum.UserInputType.Touch
            and (candidate.touchId == nil or input.TouchId == candidate.touchId)
    end
    return input.UserInputType == Enum.UserInputType.MouseMovement
end

local function pointerMatchesSkillEnd(candidate, input)
    if candidate.inputType == Enum.UserInputType.Touch then
        return input.UserInputType == Enum.UserInputType.Touch
            and (candidate.touchId == nil or input.TouchId == candidate.touchId)
    end
    return input.UserInputType == Enum.UserInputType.MouseButton1
end

local function beginSkillDragCandidate(skill, input)
    if not isOpen or not skill.canUse or pendingSkillDrag or activeSkillDrag then return end
    local position = input.Position
    local candidate = {
        skill = skill,
        inputType = input.UserInputType,
        touchId = input.UserInputType == Enum.UserInputType.Touch and input.TouchId or nil,
        startPosition = position,
        lastPosition = position,
        startedAt = os.clock(),
        cancelled = false,
    }
    pendingSkillDrag = candidate
    if candidate.inputType == Enum.UserInputType.Touch then
        task.delay(TOUCH_DRAG_HOLD_SECONDS, function()
            if pendingSkillDrag == candidate and not candidate.cancelled then
                startSkillDrag(candidate)
            end
        end)
    end
end

UserInputService.InputChanged:Connect(function(input)
    local candidate = activeSkillDrag or pendingSkillDrag
    if not candidate or not pointerMatchesSkillChange(candidate, input) then return end
    candidate.lastPosition = input.Position
    if activeSkillDrag == candidate then
        setSkillDropHighlights(input.Position)
        return
    end
    local distance = (input.Position - candidate.startPosition).Magnitude
    if candidate.inputType == Enum.UserInputType.Touch then
        if distance > DRAG_START_DISTANCE_PX then
            candidate.cancelled = true
            pendingSkillDrag = nil
            lastSkillDragEndAt = os.clock()
        end
    elseif distance >= DRAG_START_DISTANCE_PX then
        startSkillDrag(candidate)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local candidate = activeSkillDrag
    if candidate and pointerMatchesSkillEnd(candidate, input) then
        local point = input.Position or candidate.lastPosition
        local targetSlot = findBarSlotAtPosition(point)
        clearSkillDrag()
        lastSkillDragEndAt = os.clock()
        if targetSlot and candidate.skill.canUse then
            RequestAssignBarSlot:FireServer({ slot = targetSlot, skillId = candidate.skill.skillId })
        end
        return
    end
    candidate = pendingSkillDrag
    if not candidate or not pointerMatchesSkillEnd(candidate, input) then return end
    pendingSkillDrag = nil
    if candidate.cancelled then return end
    if candidate.inputType == Enum.UserInputType.Touch
        and os.clock() - candidate.startedAt >= TOUCH_DRAG_HOLD_SECONDS then
        lastSkillDragEndAt = os.clock()
    end
end)

local function makeCard(skill, order)
    local density = math.clamp(page.AbsoluteSize.Y / 660, 0.68, 1)
    local origin = getTalentOrigin(skill)
    local color = BookConfig.SourceColors[origin.tier] or C.Gold
    local cfg = getSkill(skill)
    local camera = workspace.CurrentCamera
    local touchLandscape = UserInputService.TouchEnabled and camera and camera.ViewportSize.X >= camera.ViewportSize.Y
    local rowHeightReference = touchLandscape and 125 or 140
    local card = make("TextButton", "Skill_" .. tostring(skill.skillId), skillList, {
        BackgroundColor3 = C.Panel, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, (rowHeightReference / 660) / skillList.Size.Y.Scale),
        Text = "", AutoButtonColor = false, LayoutOrder = order, ZIndex = 4,
    })
    addCorner(card, 8)
    local edge = addStroke(card, C.Border, 1)
    make("Frame", "OriginStrip", card, {
        BackgroundColor3 = color, BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0), Size = UDim2.fromScale(4 / 600, 1), ZIndex = 5,
    })
    local tile = make("Frame", "IconTile", card, {
        BackgroundColor3 = C.Slot, BorderSizePixel = 0,
        Position = UDim2.fromScale(14 / 600, 17 / 94),
        Size = UDim2.fromScale(56 / 600, 56 / 94), ZIndex = 5,
    })
    addCorner(tile, 6)
    addStroke(tile, color, 1)
    local icon = make("ImageLabel", "SkillIcon", tile, {
        BackgroundTransparency = 1, Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1), Image = iconIdFor(skill),
        ScaleType = Enum.ScaleType.Crop, ZIndex = 6,
    })
    addCorner(icon, 6)
    local placeholder = label(tile, "IconPlaceholder", "✦", UDim2.fromScale(0, 0),
        UDim2.fromScale(1, 1), color, "BodyBold", math.max(18, 24 * density), Enum.TextXAlignment.Center)
    placeholder.Visible = icon.Image == ""
    icon.Visible = not placeholder.Visible

    local name = label(card, "SkillName", tostring(skill.name or niceName(skill.skillId)),
        UDim2.fromScale(84 / 600, 9 / 94), UDim2.fromScale(270 / 600, 18 / 94),
        C.Parchment, "BodyBold", math.max(14, 17 * density))
    name.Font = font("BodyBold")
    name.TextTruncate = Enum.TextTruncate.AtEnd

    local kindText, range = detailText(skill)
    local kind = label(card, "SkillType", kindText,
        UDim2.fromScale(84 / 600, 31 / 94), UDim2.fromScale(310 / 600, 13 / 94),
        color, "Mono", math.max(11, 13 * density))
    kind.Font = font("BodyBold")
    kind.TextTruncate = Enum.TextTruncate.AtEnd

    local costText = string.format("%s MP · CD %ss",
        tostring(cfg.manaCost or skill.manaCost or 0),
        tostring(cfg.cooldown or skill.cooldown or 0))
    local cost = label(card, "SkillCost", costText,
        UDim2.fromScale(84 / 600, 51 / 94), UDim2.fromScale(300 / 600, 13 / 94),
        C.Cost, "Mono", math.max(11, 14 * density))
    cost.Font = font("BodyBold")
    cost.TextTruncate = Enum.TextTruncate.AtEnd

    local source = label(card, "SkillSource", origin.text,
        UDim2.fromScale(84 / 600, 70 / 94), UDim2.fromScale(300 / 600, 13 / 94),
        C.Muted, "Mono", math.max(10, 12 * density))
    source.Font = font("Mono")
    source.TextTruncate = Enum.TextTruncate.AtEnd

    local slot = assignedSlot(skill.skillId)
    local assignmentText = slot and ("ASIGNADA · SLOT " .. slot)
        or ((origin.tier ~= "Level" and "NO ASIGNADA · TALENTO") or "NO ASIGNADA")
    local assignment = label(card, "SkillAssignment", assignmentText,
        UDim2.fromScale(430 / 600, 62 / 94), UDim2.fromScale(150 / 600, 15 / 94),
        slot and C.Gold or C.Muted, "Mono", math.max(11, 12 * density), Enum.TextXAlignment.Right)
    assignment.Font = font("Mono")
    assignment.TextTruncate = Enum.TextTruncate.AtEnd

    if range and range ~= "" then
        local rangeLabel = label(card, "SkillRange", range,
            UDim2.fromScale(420 / 600, 35 / 94), UDim2.fromScale(160 / 600, 13 / 94),
            C.Muted, "Mono", math.max(8, 9 * density), Enum.TextXAlignment.Right)
        rangeLabel.Font = font("Mono")
        rangeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    end

    if touchLandscape then
        -- Landscape mobile cards use three fixed, compact rows sized in pixels relative to the card.
        -- This keeps labels readable and prevents the desktop column layout from collapsing.
        tile.Position = UDim2.new(0, 5, 0.08, 0)
        tile.Size = UDim2.new(0, 22, 0.84, 0)
        placeholder.TextSize = 9
        name.Position, name.Size = UDim2.new(0, 32, 0, 0), UDim2.new(0.55, 0, 0, 11)
        name.TextSize = 11
        assignment.Position, assignment.Size = UDim2.new(0.65, 0, 0, 0), UDim2.new(0.33, 0, 0, 11)
        assignment.TextSize = 8
        kind.Position, kind.Size = UDim2.new(0, 32, 0, 11), UDim2.new(0.95, -34, 0, 8)
        kind.TextSize = 9
        kind.TextTruncate = Enum.TextTruncate.AtEnd
        cost.Text = costText .. (range and (" · " .. range) or "") .. " · " .. origin.text
        cost.Position, cost.Size = UDim2.new(0, 32, 0, 19), UDim2.new(0.95, -34, 0, 8)
        cost.TextSize = 8
        cost.TextTruncate = Enum.TextTruncate.AtEnd
        source.Visible = false
        local mobileRange = card:FindFirstChild("SkillRange")
        if mobileRange then mobileRange.Visible = false end
    end

    if not skill.canUse then
        card.BackgroundColor3 = Color3.fromRGB(30, 25, 23)
        name.TextTransparency, cost.TextTransparency = 0.18, 0.22
    end
    card.MouseEnter:Connect(function() edge.Color, edge.Thickness = color, 2 end)
    card.MouseLeave:Connect(function() edge.Color, edge.Thickness = C.Border, 1 end)
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginSkillDragCandidate(skill, input)
        end
    end)
    card.Activated:Connect(function()
        if os.clock() - lastSkillDragEndAt < 0.25 then return end
        if not skill.canUse then
            errorLabel.Text = "Esta habilidad está bloqueada por nivel."
            errorLabel.Visible = true
            task.delay(3, function()
                if errorLabel.Parent and errorLabel.Text == "Esta habilidad está bloqueada por nivel." then
                    errorLabel.Visible = false
                end
            end)
            return
        end
        if not selectedSlot then
            infoLabel.Text = "Selecciona un slot de la barra; toca una skill asignada para quitarla."
            infoLabel.Visible = true
            return
        end
        local existing = (currentData.loadout or {})[selectedSlot]
        local requestedId = existing == skill.skillId and "" or skill.skillId
        RequestAssignBarSlot:FireServer({slot = selectedSlot, skillId = requestedId})
    end)
    return card
end

local function refreshList()
    clearRows()
    if not currentData then return end
    local skills = table.clone(currentData.skills or {})
    table.sort(skills, function(a, b)
        local originA, originB = getTalentOrigin(a), getTalentOrigin(b)
        local groupA = originA.tier == "Capstone" and 3 or originA.tier == "Talent" and 2 or (a.specId and 1 or 0)
        local groupB = originB.tier == "Capstone" and 3 or originB.tier == "Talent" and 2 or (b.specId and 1 or 0)
        if groupA ~= groupB then return groupA < groupB end
        local levelA, levelB = tonumber(a.levelReq) or 1, tonumber(b.levelReq) or 1
        if levelA ~= levelB then return levelA < levelB end
        return tostring(a.name) < tostring(b.name)
    end)
    local unassignedCount, knownCount = 0, 0
    for _, skill in ipairs(skills) do
        if skill.canUse then knownCount += 1 end
        if not assignedSlot(skill.skillId) then unassignedCount += 1 end
    end
    countLabel.Text = string.format("%d CONOCIDAS", knownCount)
    filterAll.Text = string.format("TODAS · %d", #skills)
    filterUnassigned.Text = string.format("NO ASIGNADAS · %d", unassignedCount)
    filterAll.BackgroundColor3 = filterMode == "All" and C.Gold or Color3.fromRGB(58, 48, 42)
    filterAll.TextColor3 = filterMode == "All" and C.Canvas or C.Muted
    filterUnassigned.BackgroundColor3 = filterMode == "Unassigned" and C.Gold or Color3.fromRGB(58, 48, 42)
    filterUnassigned.TextColor3 = filterMode == "Unassigned" and C.Canvas or C.Muted
    characterLabel.Text = getClassSpecText()
    titleLabel.Text = "GRIMORIO DE " .. string.upper(tostring(player:GetAttribute("CharacterName") or player.Name))
    local shown = 0
    for _, skill in ipairs(skills) do
        if filterMode == "All" or not assignedSlot(skill.skillId) then
            shown += 1
            makeCard(skill, shown)
        end
    end
    if shown == 0 then
        local empty = label(skillList, "EmptyState", filterMode == "All" and "Aún no conoces habilidades." or "Todas tus habilidades están asignadas.", UDim2.fromScale(0.05, 0.2), UDim2.fromScale(0.90, 0.10), C.Muted, "Body", 14, Enum.TextXAlignment.Center)
        empty.LayoutOrder = 1
    end
    skillList.CanvasPosition = Vector2.zero
end

function selectBarSlot(index)
    selectedSlot = selectedSlot == index and nil or index
    infoLabel.Text = selectedSlot and ("SLOT " .. selectedSlot .. " DESTINO · elige una skill; toca la asignada para quitarla") or "Selecciona un slot y luego una habilidad para asignarla."
    infoLabel.Visible = selectedSlot ~= nil
    for i, slot in ipairs(slotButtons) do
        slot.stroke.Color = selectedSlot == i and C.Blue or ((currentData and currentData.loadout[i] and currentData.loadout[i] ~= "") and C.Gold or C.Border)
        slot.stroke.Thickness = selectedSlot == i and 2 or 1
    end
end

local function refreshBar()
    if not currentData then return end
    for i, info in ipairs(slotButtons) do
        local id = currentData.loadout and currentData.loadout[i]
        local skill
        if id and id ~= "" then
            for _, item in ipairs(currentData.skills or {}) do if item.skillId == id then skill = item break end end
        end
        local cfg = getSkill(skill)
        local icon = info.button:FindFirstChild("SkillIcon")
        local name = info.button:FindFirstChild("SlotName")
        local cost = info.button:FindFirstChild("SlotCost")
        if skill then
            icon.Image, icon.Visible = iconIdFor(skill), iconIdFor(skill) ~= ""
            name.Text = tostring(skill.name or niceName(skill.skillId))
            name.TextTruncate = Enum.TextTruncate.AtEnd
            cost.Text = tostring(cfg.manaCost or skill.manaCost or 0) .. " MP · CD " .. tostring(cfg.cooldown or skill.cooldown or 0) .. "s"
        else
            icon.Image, icon.Visible = "", false
            name.Text, cost.Text = "VACÍO", "—"
        end
        info.stroke.Color = selectedSlot == i and C.Blue or (skill and C.Gold or C.Border)
        info.stroke.Thickness = selectedSlot == i and 2 or 1
    end
end

local function refreshAll()
    if not currentData then return end
    refreshList()
    refreshBar()
end

local function applyData(data)
    currentData = data
    refreshAll()
end

local function closeSpellbook()
    clearSkillDrag()
    isOpen = false
    gui.Enabled, main.Visible = false, false
    if UserInputService.TouchEnabled and mobileAccessWasEnabled then
        local mobile = playerGui:FindFirstChild("MobileAccessUI")
        if mobile then
            mobile.Enabled = true
            local stack = mobile:FindFirstChild("MobileAccessStack")
            if stack and mobileStackWasVisible then stack.Visible = true end
        end
    end
    mobileAccessWasEnabled, mobileStackWasVisible = false, false
    errorLabel.Text, errorLabel.Visible = "", false
    selectedSlot = nil
    player:SetAttribute("UIWindowOpen", false)
end

local function openSpellbook()
    setResponsive()
    isOpen = true
    gui.Enabled, main.Visible = true, true
    if UserInputService.TouchEnabled then
        local mobile = playerGui:FindFirstChild("MobileAccessUI")
        if mobile then
            mobileAccessWasEnabled = mobile.Enabled
            mobile.Enabled = false
            local stack = mobile:FindFirstChild("MobileAccessStack")
            if stack then mobileStackWasVisible, stack.Visible = stack.Visible, false end
        end
    end
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    player:SetAttribute("UIWindowOpen", true)
    selectedSlot = nil
    RequestSpellbook:FireServer()
end

makeShell()
gui.DisplayOrder = math.max(gui.DisplayOrder, 20)
gui.Enabled, main.Visible = false, false
closeButton.Activated:Connect(closeSpellbook)
SpellbookData.OnClientEvent:Connect(applyData)
BarSlotAssigned.OnClientEvent:Connect(function(data)
    if data and data.success then
        if currentData and currentData.loadout then currentData.loadout[data.slot] = data.skillId or "" end
        selectedSlot = nil
        refreshAll()
        errorLabel.Visible, errorLabel.Text = false, ""
        infoLabel.Visible = false
    else
        errorLabel.Text = data and data.error or "Error al asignar"
        errorLabel.Visible = true
    end
end)
local lastRequestId, lastCloseId
player:GetAttributeChangedSignal("MicroMenuCloseRequestId"):Connect(function()
    local id = player:GetAttribute("MicroMenuCloseRequestId")
    if id == lastCloseId then return end
    lastCloseId = id
    if isOpen then closeSpellbook() end
end)
player:GetAttributeChangedSignal("MicroMenuRequestId"):Connect(function()
    local id = player:GetAttribute("MicroMenuRequestId")
    if id == lastRequestId then return end
    lastRequestId = id
    if player:GetAttribute("MicroMenuAction") ~= "Spellbook" then return end
    if isOpen then closeSpellbook()
    elseif player:GetAttribute("CharacterName") then openSpellbook() end
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P then
        if isOpen then closeSpellbook()
        elseif player:GetAttribute("CharacterName") then openSpellbook() end
    end
end)
local viewportConnection
local function bindViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(setResponsive) end
    setResponsive()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewport)
bindViewport()
print("[Vandrheim] SpellbookClient HU-ESTETICA-42 rc082 activo")
