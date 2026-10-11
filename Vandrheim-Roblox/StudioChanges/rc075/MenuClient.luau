--[[
    MenuClient - Vandrheim Fase R6.10 (HU-R6.10)
    Menú modal in-game mediante botón de UI para PC/móvil, placeholders y
    retorno seguro a CharacterSelect. No muta progreso desde el cliente.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local DungeonConfig = require(ReplicatedStorage.Config:WaitForChild("DungeonConfig"))
local isDungeonPlace = DungeonConfig.IsDungeonPlace()
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local menuGui = playerGui:WaitForChild("MenuUI")
local dimmer = menuGui:WaitForChild("Dimmer")
local panel = menuGui:WaitForChild("Panel")
local continueButton = panel:WaitForChild("Buttons"):WaitForChild("ContinueButton")
local returnButton = panel:WaitForChild("Buttons"):WaitForChild("ReturnButton")
local volumeButton = panel:WaitForChild("Buttons"):WaitForChild("VolumeButton")
local graphicsButton = panel:WaitForChild("Buttons"):WaitForChild("GraphicsButton")
local uiOrderButton = panel:WaitForChild("Buttons"):WaitForChild("UIOrderButton")
local feedbackLabel = panel:WaitForChild("FeedbackLabel")
returnButton.Visible = not isDungeonPlace

local menuOpen = false
local requestPending = false
local feedbackToken = 0
local previousMouseBehavior = nil
local previousMouseIconEnabled = nil

local function getGui(name)
    return playerGui:FindFirstChild(name)
end

local function isCharacterGameplayActive()
    local charSelect = getGui("CharacterSelect")
    local charCreate = getGui("CharacterCreate")
    if (charSelect and charSelect.Enabled) or (charCreate and charCreate.Enabled) then
        return false
    end

    local character = player.Character
    local characterName = player:GetAttribute("CharacterName")
    return character ~= nil and type(characterName) == "string" and characterName ~= ""
end

local function isBlockedScreen()
    local dungeonHud = getGui("DungeonHUD")
    local runEndedNotice = dungeonHud and dungeonHud:FindFirstChild("RunEndedNotice")
    if runEndedNotice and runEndedNotice.Visible then
        return true
    end

    return player:GetAttribute("DungeonTeleporting") == true
        or player:GetAttribute("TeleportInProgress") == true
        or player:GetAttribute("Teleporting") == true
end

local function showFeedback(message, isError)
    feedbackToken += 1
    local token = feedbackToken
    feedbackLabel.Text = tostring(message or "")
    feedbackLabel.TextColor3 = isError
        and Color3.fromRGB(255, 135, 125)
        or Color3.fromRGB(255, 220, 130)
    feedbackLabel.TextTransparency = 0
    feedbackLabel.Visible = true

    task.delay(2.4, function()
        if token ~= feedbackToken or not feedbackLabel.Parent then
            return
        end
        local fade = TweenService:Create(
            feedbackLabel,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { TextTransparency = 1 }
        )
        fade:Play()
        fade.Completed:Connect(function()
            if token == feedbackToken and feedbackLabel.Parent then
                feedbackLabel.Visible = false
            end
        end)
    end)
end

local function closeSupportingWindows()
    for _, name in ipairs({ "InventoryUI", "EquipmentUI", "VendorUI", "TalentUI", "SpellbookUI" }) do
        local gui = getGui(name)
        if gui then
            gui.Enabled = false
        end
    end

    local sharedUi = getGui("SharedUI")
    if sharedUi then
        local tooltip = sharedUi:FindFirstChild("Tooltip")
        local sharedFeedback = sharedUi:FindFirstChild("FeedbackLabel")
        if tooltip then tooltip.Visible = false end
        if sharedFeedback then sharedFeedback.Visible = false end
    end

    player:SetAttribute("MenuUIOpen", true)
end

local function openMenu()
    if menuOpen or requestPending then
        return
    end
    if not isCharacterGameplayActive() or isBlockedScreen() then
        return
    end

    previousMouseBehavior = UserInputService.MouseBehavior
    previousMouseIconEnabled = UserInputService.MouseIconEnabled
    closeSupportingWindows()

    menuOpen = true
    menuGui.Enabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
    player:SetAttribute("UIWindowOpen", true)
end

local function closeMenu()
    if not menuOpen then
        return
    end

    menuOpen = false
    requestPending = false
    menuGui.Enabled = false
    player:SetAttribute("MenuUIOpen", false)
    player:SetAttribute("UIWindowOpen", false)

    UserInputService.MouseBehavior = previousMouseBehavior or Enum.MouseBehavior.Default
    if previousMouseIconEnabled == nil then
        UserInputService.MouseIconEnabled = true
    else
        UserInputService.MouseIconEnabled = previousMouseIconEnabled
    end
    previousMouseBehavior = nil
    previousMouseIconEnabled = nil
end

local function hideGameplayInterfaces()
    for _, name in ipairs({
        "HUD",
        "SkillBar",
        "Crosshair",
        "InventoryUI",
        "EquipmentUI",
        "VendorUI",
        "TalentUI",
        "SpellbookUI",
        "DungeonHUD",
        "MicroMenuUI",
        "MobileAccessUI",
    }) do
        local gui = getGui(name)
        if gui then
            gui.Enabled = false
        end
    end

    local sharedUi = getGui("SharedUI")
    if sharedUi then
        local tooltip = sharedUi:FindFirstChild("Tooltip")
        local sharedFeedback = sharedUi:FindFirstChild("FeedbackLabel")
        if tooltip then tooltip.Visible = false end
        if sharedFeedback then sharedFeedback.Visible = false end
    end
end

local function showCharacterSelect()
    if isDungeonPlace then return end
    hideGameplayInterfaces()

    local charCreate = getGui("CharacterCreate")
    local charSelect = getGui("CharacterSelect")
    if charCreate then charCreate.Enabled = false end
    if charSelect then charSelect.Enabled = true end

    menuGui.Enabled = false
    menuOpen = false
    requestPending = false
    player:SetAttribute("MenuUIOpen", false)
    player:SetAttribute("UIWindowOpen", false)
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true

    Remotes.RequestCharacterList:FireServer()
end

local function requestReturnToCharacterSelect()
    if isDungeonPlace or not menuOpen or requestPending then
        return
    end

    requestPending = true
    returnButton.AutoButtonColor = false
    showFeedback("Guardando progreso...", false)
    Remotes.RequestReturnToCharacterSelect:FireServer()
end

local function restoreGameplayInterfaces()
    if player:GetAttribute("CharacterSelectionMode") == true then
        return
    end

    local hud = getGui("HUD")
    local skillBar = getGui("SkillBar")
    local crosshair = getGui("Crosshair")
    local microMenuGui = getGui("MicroMenuUI")
    local mobileAccessGui = getGui("MobileAccessUI")
    local charSelect = getGui("CharacterSelect")
    local charCreate = getGui("CharacterCreate")

    if hud then hud.Enabled = true end
    if skillBar then skillBar.Enabled = true end
    if crosshair then crosshair.Enabled = true end
    if microMenuGui then
        microMenuGui.Enabled = not UserInputService.TouchEnabled
    end
    if mobileAccessGui then
        mobileAccessGui.Enabled = UserInputService.TouchEnabled
    end
    if charSelect then charSelect.Enabled = false end
    if charCreate then charCreate.Enabled = false end
end

local function showPlaceholder()
    showFeedback("Próximamente", false)
end

continueButton.Activated:Connect(closeMenu)
returnButton.Activated:Connect(requestReturnToCharacterSelect)
volumeButton.Activated:Connect(showPlaceholder)
graphicsButton.Activated:Connect(showPlaceholder)
uiOrderButton.Activated:Connect(function()
	if not menuOpen or requestPending then return end
	closeMenu()
	player:SetAttribute("UILayoutEditRequest", os.clock())
end)

-- M alterna el menú en escritorio sin interferir con campos de texto ni
-- con el editor de HUD. El botón de UI sigue siendo la entrada en touch.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.KeyCode ~= Enum.KeyCode.M
		or UserInputService:GetFocusedTextBox()
		or player:GetAttribute("UILayoutEditMode") == true then
		return
	end
	if menuOpen then
		if not requestPending then closeMenu() end
	else
		openMenu()
	end
end)

Remotes.ReturnToCharacterSelectResult.OnClientEvent:Connect(function(payload)
    if isDungeonPlace then return end
    payload = type(payload) == "table" and payload or {}
    requestPending = false
    returnButton.AutoButtonColor = true

    if payload.success == true then
        showCharacterSelect()
    else
        showFeedback(payload.error or "No se pudo volver a la selección", true)
    end
end)

Remotes.SpawnCharacter.OnClientEvent:Connect(function()
    restoreGameplayInterfaces()
end)

Remotes.CharacterOperationResult.OnClientEvent:Connect(function(payload)
    if type(payload) == "table"
        and payload.success == true
        and (payload.operation == "select" or payload.operation == "create")
    then
        restoreGameplayInterfaces()
    end
end)

Remotes.DungeonRunEnded.OnClientEvent:Connect(function()
    if menuOpen then
        closeMenu()
    end
end)

-- El menú se abre desde un control de UI para conservar libre el menú nativo de Roblox.
-- Escritorio: micro menú horizontal elevado sobre los accesos rápidos de consumibles.
-- Touch: accesos separados en una columna compacta al costado derecho.
do
    local function configureScreenGui(screenGui, name)
        screenGui.Name = name
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 45
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        pcall(function()
            screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
        end)
    end

    local microMenuGui = playerGui:FindFirstChild("MicroMenuUI")
    if not microMenuGui then
        microMenuGui = Instance.new("ScreenGui")
        configureScreenGui(microMenuGui, "MicroMenuUI")
        microMenuGui.Parent = playerGui
    end

    local microBar = microMenuGui:FindFirstChild("MicroMenuBar")
    if not microBar then
        microBar = Instance.new("Frame")
        microBar.Name = "MicroMenuBar"
        microBar.Parent = microMenuGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = microBar

        local stroke = Instance.new("UIStroke")
        stroke.Name = "MicroMenuStroke"
        stroke.Color = Color3.fromRGB(212, 174, 78)
        stroke.Thickness = 1.5
        stroke.Parent = microBar

        local sizeConstraint = Instance.new("UISizeConstraint")
        sizeConstraint.Name = "ResponsiveSize"
        sizeConstraint.MinSize = Vector2.new(280, 52)
        sizeConstraint.MaxSize = Vector2.new(280, 52)
        sizeConstraint.Parent = microBar

        local padding = Instance.new("UIPadding")
        padding.Name = "PencilPadding"
        padding.PaddingLeft = UDim.new(0, 13)
        padding.PaddingRight = UDim.new(0, 13)
        padding.PaddingTop = UDim.new(0, 5)
        padding.PaddingBottom = UDim.new(0, 5)
        padding.Parent = microBar

        local layout = Instance.new("UIListLayout")
        layout.Name = "ButtonLayout"
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = microBar
    end

    microBar.AnchorPoint = Vector2.new(1, 1)
    microBar.Position = UDim2.new(1, -10, 1, -12)
    microBar.Size = UDim2.fromOffset(280, 52)
    microBar.BackgroundColor3 = Color3.fromRGB(33, 25, 22)
    microBar.BackgroundTransparency = 0
    microBar.BorderSizePixel = 0
    microBar.Active = true
    microBar.ZIndex = 1

    local mobileAccessGui = playerGui:FindFirstChild("MobileAccessUI")
    if not mobileAccessGui then
        mobileAccessGui = Instance.new("ScreenGui")
        configureScreenGui(mobileAccessGui, "MobileAccessUI")
        mobileAccessGui.Parent = playerGui
    end

    local mobileStack = mobileAccessGui:FindFirstChild("MobileAccessStack")
    if not mobileStack then
        mobileStack = Instance.new("Frame")
        mobileStack.Name = "MobileAccessStack"
        mobileStack.Parent = mobileAccessGui

        local sizeConstraint = Instance.new("UISizeConstraint")
        sizeConstraint.Name = "ResponsiveSize"
        sizeConstraint.MinSize = Vector2.new(48, 236)
        sizeConstraint.MaxSize = Vector2.new(48, 236)
        sizeConstraint.Parent = mobileStack

        local layout = Instance.new("UIListLayout")
        layout.Name = "ButtonLayout"
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = mobileStack
    end

    mobileStack.AnchorPoint = Vector2.new(1, 0.5)
    mobileStack.Position = UDim2.new(1, -10, 0.50, 0)
    mobileStack.Size = UDim2.fromOffset(48, 236)
    mobileStack.BackgroundTransparency = 1
    mobileStack.BorderSizePixel = 0
    mobileStack.Active = false

    local requestId = 0
    local actionGuiNames = {
        Inventory = "InventoryUI",
        Equipment = "EquipmentUI",
        Talent = "TalentUI",
        Spellbook = "SpellbookUI",
    }

    local function requestMicroMenuAction(action)
        requestId += 1

        -- R6.11: cada botón alterna su ventana sin cerrar las demás.
        -- Así mochila y equipo pueden permanecer visibles al mismo tiempo.
        player:SetAttribute("MicroMenuAction", action)
        player:SetAttribute("MicroMenuRequestId", requestId)
    end

    -- Pega aquí los IDs de imagen cuando estén publicados en Roblox.
    -- Se conserva la letra como fallback mientras el valor sea rbxassetid://0.
    local desktopDefinitions = {
		{ name = "CharacterButton", text = "C", action = "Equipment", iconId = "rbxassetid://119395720243011" }, -- escudo/equipo
		{ name = "SpellbookButton", text = "P", action = "Spellbook", iconId = "rbxassetid://85451713578861" }, -- libro abierto
		{ name = "TalentButton", text = "T", action = "Talent", iconId = "rbxassetid://80900320700539" }, -- destellos
		{ name = "InventoryButton", text = "B", action = "Inventory", iconId = "rbxassetid://132680288124569" }, -- mochila
		{ name = "MenuButton", text = "M", action = "MainMenu", iconId = "rbxassetid://103126744028067", accent = true }, -- menú
    }

    local mobileDefinitions = {
        { name = "MenuButton", text = "M", action = "MainMenu", iconId = "rbxassetid://103126744028067", accent = true },
        { name = "InventoryButton", text = "B", action = "Inventory", iconId = "rbxassetid://132680288124569" },
        { name = "CharacterButton", text = "C", action = "Equipment", iconId = "rbxassetid://119395720243011" },
        { name = "TalentButton", text = "T", action = "Talent", iconId = "rbxassetid://80900320700539" },
        { name = "SpellbookButton", text = "P", action = "Spellbook", iconId = "rbxassetid://85451713578861" },
    }

    local function setupButton(parent, definition, index, isMobile)
        local button = parent:FindFirstChild(definition.name)
        if not button then
            button = Instance.new("TextButton")
            button.Name = definition.name
            button.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, isMobile and 8 or 7)
            corner.Parent = button

            local buttonStroke = Instance.new("UIStroke")
            buttonStroke.Name = "ButtonStroke"
            buttonStroke.Thickness = isMobile and 1.25 or 1
            buttonStroke.Parent = button

            if isMobile then
                local textConstraint = Instance.new("UITextSizeConstraint")
                textConstraint.Name = "ReadableText"
                textConstraint.MinTextSize = 10
                textConstraint.MaxTextSize = 17
                textConstraint.Parent = button
            end
        end

        button.LayoutOrder = index
        button.Size = isMobile
            and UDim2.fromOffset(44, 44)
            or UDim2.fromOffset(46, 42)
        button.BackgroundColor3 = definition.accent
            and Color3.fromRGB(200, 148, 69)
            or Color3.fromRGB(23, 19, 17)
        button.BackgroundTransparency = 0
        button.BorderSizePixel = 0
        button.ClipsDescendants = true
        button.Font = Enum.Font.GothamBold
        local icon = button:FindFirstChild("Icon")
                    if not icon then
                icon = Instance.new("ImageLabel")
                icon.Name = "Icon"
                icon.AnchorPoint = Vector2.new(0.5, 0.5)
                icon.Position = UDim2.fromScale(0.5, 0.5)
                -- Mismo patrón del SkillBar: 1 px interior por lado y recorte dentro del borde.
                icon.Size = UDim2.new(1, -2, 1, -2)
                icon.BackgroundTransparency = 1
                icon.BorderSizePixel = 0
                icon.ScaleType = Enum.ScaleType.Crop
                icon.ClipsDescendants = true
                icon.ZIndex = button.ZIndex + 1
                icon.Parent = button
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 4)
                iconCorner.Parent = icon
            end
            local hasIcon = type(definition.iconId) == "string"
                and definition.iconId ~= ""
                and definition.iconId ~= "rbxassetid://0"
            icon.Image = hasIcon and definition.iconId or ""
            icon.ImageColor3 = Color3.fromRGB(244, 237, 224)
            icon.Visible = hasIcon
            button.Text = hasIcon and "" or definition.text
        button.TextColor3 = definition.accent
            and Color3.fromRGB(21, 16, 13)
            or Color3.fromRGB(244, 237, 224)
        button.TextScaled = true
        button.TextWrapped = true
        button.AutoButtonColor = true
        button.Active = true
        button.ZIndex = 2

        local buttonStroke = button:FindFirstChild("ButtonStroke")
        if buttonStroke then
            buttonStroke.Color = definition.accent
                and Color3.fromRGB(226, 174, 83)
                or Color3.fromRGB(107, 74, 43)
        end

        if not button:GetAttribute("MicroMenuHooked") then
            button:SetAttribute("MicroMenuHooked", true)
            local action = definition.action
            button.Activated:Connect(function()
                if action == "MainMenu" then
                    if menuOpen then
                        closeMenu()
                    else
                        openMenu()
                    end
                else
                    requestMicroMenuAction(action)
                end
            end)
        end
    end

    for index, definition in ipairs(desktopDefinitions) do
        setupButton(microBar, definition, index, false)
    end

    for index, definition in ipairs(mobileDefinitions) do
        setupButton(mobileStack, definition, index, true)
    end

    microMenuGui.Enabled = not UserInputService.TouchEnabled and isCharacterGameplayActive()
    mobileAccessGui.Enabled = UserInputService.TouchEnabled and isCharacterGameplayActive()
end

player:SetAttribute("MenuUIOpen", false)
print("[Vandrheim] MenuClient R6.10 activo")
