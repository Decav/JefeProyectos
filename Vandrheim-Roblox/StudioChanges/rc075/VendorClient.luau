--[[
	VendorClient - Vandrheim Fase R5
	Cliente: interacción con NPCs (ProximityPrompt), ventana de vendor,
	compra/venta, uso de consumibles. Pausa drag de cámara al abrir.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DungeonConfig = require(ReplicatedStorage.Config:WaitForChild("DungeonConfig"))
local VendorConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("VendorConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local UITheme = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("UITheme"))
local BLACK_CELL = UITheme.Colors.Shadow
local RequestRespec = Remotes:WaitForChild("RequestRespec")
local RespecResult = Remotes:WaitForChild("RespecResult")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Esperar a que la UI exista
local vendorGui = playerGui:WaitForChild("VendorUI")
if DungeonConfig.IsDungeonPlace() then
	vendorGui.Enabled = false
	return
end
local mainFrame = vendorGui:WaitForChild("MainFrame")
local buyPanel = mainFrame:WaitForChild("BuyPanel")
local sellPanel = mainFrame:WaitForChild("SellPanel")
local buyTab = mainFrame:WaitForChild("BuyTab")
local sellTab = mainFrame:WaitForChild("SellTab")
local closeBtn = mainFrame:WaitForChild("CloseButton")
local goldLabel = mainFrame:WaitForChild("GoldLabel")
local errorLabel = mainFrame:WaitForChild("ErrorLabel")
local title = mainFrame:WaitForChild("Title")
local trainerPanel = mainFrame:WaitForChild("TrainerPanel")
local trainerDescription = trainerPanel:WaitForChild("TrainerDescription")
local trainerRespec = trainerPanel:WaitForChild("TrainerRespecButton")
local trainerConfirmDialog = trainerPanel:WaitForChild("TrainerConfirmDialog")
local trainerConfirmButton = trainerConfirmDialog:WaitForChild("TrainerConfirmButton")
local trainerCancelButton = trainerConfirmDialog:WaitForChild("TrainerCancelButton")

local currentVendorId = nil
local currentVendorData = nil
local isVendorOpen = false
local trainerConfirmArmed = false

local VENDOR_COLORS = {
	Canvas = Color3.fromRGB(21, 16, 13),
	Surface = Color3.fromRGB(33, 25, 22),
	SurfaceAlt = Color3.fromRGB(23, 19, 17),
	Brass = Color3.fromRGB(200, 148, 69),
	BrassDark = Color3.fromRGB(107, 74, 43),
	Text = Color3.fromRGB(244, 237, 224),
	Muted = Color3.fromRGB(181, 167, 154),
	Danger = Color3.fromRGB(184, 78, 91),
	DangerSurface = Color3.fromRGB(58, 37, 37),
}

local function ensureVendorCorner(obj, radius)
	local corner = obj:FindFirstChildWhichIsA("UICorner")
	if not corner then
		corner = Instance.new("UICorner")
		corner.Name = "VendorCorner"
		corner.Parent = obj
	end
	corner.CornerRadius = UDim.new(0, radius or 8)
	return corner
end

local function ensureVendorStroke(obj, color, transparency, thickness)
	local stroke = obj:FindFirstChildWhichIsA("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Name = "VendorStroke"
		stroke.Parent = obj
	end
	stroke.Color = color or VENDOR_COLORS.Brass
	stroke.Transparency = transparency or 0.2
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return stroke
end

local function removeVendorGradient(obj)
	local gradient = obj:FindFirstChild("HearthboundGradient")
	if gradient then
		gradient:Destroy()
	end
end

local vendorCanvasBindings = {}
local function configurePanelLayout(panel, isGrid)
	local padding = panel:FindFirstChildOfClass("UIPadding")
	if not padding then
		padding = Instance.new("UIPadding")
		padding.Name = "VendorContentPadding"
		padding.Parent = panel
	end
	padding.PaddingLeft = UDim.new(0.025, 0)
	padding.PaddingRight = UDim.new(0.025, 0)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	local list = panel:FindFirstChildWhichIsA("UIListLayout")
	local grid = panel:FindFirstChildWhichIsA("UIGridLayout")

	if isGrid then
		if list then
			list:Destroy()
		end
		if not grid then
			grid = Instance.new("UIGridLayout")
			grid.Name = "VendorGridLayout"
			grid.Parent = panel
		end
		grid.CellSize = UDim2.new(0.44, 0, 0, 88)
		grid.CellPadding = UDim2.new(0.04, 0, 0, 10)
		grid.FillDirection = Enum.FillDirection.Horizontal
		grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
		grid.VerticalAlignment = Enum.VerticalAlignment.Top
		grid.SortOrder = Enum.SortOrder.LayoutOrder
	else
		if grid then
			grid:Destroy()
		end
		if not list then
			list = Instance.new("UIListLayout")
			list.Name = "VendorListLayout"
			list.Parent = panel
		end
		list.Padding = UDim.new(0, 18)
		list.FillDirection = Enum.FillDirection.Vertical
		list.HorizontalAlignment = Enum.HorizontalAlignment.Left
		list.VerticalAlignment = Enum.VerticalAlignment.Top
		list.SortOrder = Enum.SortOrder.LayoutOrder
	end

	panel.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.ScrollBarImageColor3 = VENDOR_COLORS.Brass
	panel.ScrollBarImageTransparency = 0.15
	panel.ScrollBarThickness = 6
	panel.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	panel.AutomaticCanvasSize = Enum.AutomaticSize.None
	local function updateCanvas()
		local layout = panel:FindFirstChildOfClass("UIGridLayout") or panel:FindFirstChildOfClass("UIListLayout")
		-- CanvasSize.Scale se resuelve contra el padre, no contra la ventana de scroll.
		if layout and panel.Parent.AbsoluteSize.Y > 0 then
			panel.CanvasSize = UDim2.fromScale(0, (layout.AbsoluteContentSize.Y + 16) / panel.Parent.AbsoluteSize.Y)
		end
	end
	if vendorCanvasBindings[panel] then vendorCanvasBindings[panel]:Disconnect() end
	local layout = grid or list
	-- La rama puede haber destruido el layout contrario.
	layout = panel:FindFirstChildOfClass("UIGridLayout") or panel:FindFirstChildOfClass("UIListLayout")
	vendorCanvasBindings[panel] = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	if not panel:GetAttribute("VendorCanvasResizeBound") then
		panel:SetAttribute("VendorCanvasResizeBound", true)
		panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
	end
	task.defer(updateCanvas)
	panel.CanvasPosition = Vector2.zero
	ensureVendorCorner(panel, 6)
	local panelStroke = panel:FindFirstChildWhichIsA("UIStroke")
	if panelStroke then
		panelStroke:Destroy()
	end
	removeVendorGradient(panel)
end

local vendorListTop = 0.20
local function updateVendorListSpace()
	local hasError = errorLabel.Visible and errorLabel.Text ~= ""
	local bottom = hasError and 0.81 or 0.95
	for _, panel in ipairs({buyPanel, sellPanel}) do
		panel.Position = UDim2.fromScale(0.05, vendorListTop)
		panel.Size = UDim2.fromScale(0.90, bottom - vendorListTop)
	end
	errorLabel.Position = UDim2.fromScale(0.05, 0.84)
	errorLabel.Size = UDim2.fromScale(0.90, 0.11)
end
errorLabel:GetPropertyChangedSignal("Visible"):Connect(updateVendorListSpace)
errorLabel:GetPropertyChangedSignal("Text"):Connect(updateVendorListSpace)

local function configureVendorWindow(vendorId)
	local aspect = mainFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
	local width = 0.52
	local ratio = 0.89

	if vendorId == "vendor_consumables" then
		width = 0.40
		ratio = 0.60
	elseif vendorId == "vendor_trainer" then
		width = 0.36
		ratio = 0.52
	end

	if UserInputService.TouchEnabled then
		width = 0.92
		ratio = 1.65
		mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		mainFrame.Size = UDim2.fromScale(width, 0.90)
		mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	else
		mainFrame.AnchorPoint = Vector2.zero
		mainFrame.Size = UDim2.fromScale(width, 0.72)
		mainFrame.Position = UDim2.fromScale(0.5 - width / 2, 0.14)
	end
	if aspect then
		aspect.AspectRatio = ratio
	end

	mainFrame.BackgroundColor3 = VENDOR_COLORS.Surface
	mainFrame.BackgroundTransparency = 0
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = false
	ensureVendorCorner(mainFrame, 10)
	ensureVendorStroke(mainFrame, VENDOR_COLORS.Brass, 0.12, 1)
	removeVendorGradient(mainFrame)

	title.Position = UDim2.new(0.05, 0, 0.035, 0)
	title.Size = UDim2.new(0.58, 0, 0.08, 0)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextColor3 = VENDOR_COLORS.Text
	title.TextStrokeTransparency = 1
	title.Font = Enum.Font.GothamBold

	goldLabel.Position = UDim2.new(0.60, 0, 0.035, 0)
	goldLabel.Size = UDim2.new(0.31, 0, 0.08, 0)
	goldLabel.BackgroundTransparency = 1
	goldLabel.TextXAlignment = Enum.TextXAlignment.Right
	goldLabel.TextYAlignment = Enum.TextYAlignment.Center
	goldLabel.TextColor3 = VENDOR_COLORS.Brass
	goldLabel.TextStrokeTransparency = 1
	goldLabel.Font = Enum.Font.GothamBold

	closeBtn.Position = UDim2.new(0.92, 0, 0.025, 0)
	closeBtn.Size = UDim2.new(0.055, 0, 0.09, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = VENDOR_COLORS.Muted
	closeBtn.TextStrokeTransparency = 1
	closeBtn.Font = Enum.Font.GothamBold

	local isGear = vendorId == "vendor_gear"
	if not isGear then
		closeBtn.Position = UDim2.new(0.84, 0, 0.025, 0)
		closeBtn.Size = UDim2.new(0.11, 0, 0.09, 0)
		title.Size = UDim2.new(0.85, 0, 0.07, 0)
		goldLabel.Position = UDim2.new(0.05, 0, 0.105, 0)
		goldLabel.Size = UDim2.new(0.50, 0, 0.06, 0)
		goldLabel.TextXAlignment = Enum.TextXAlignment.Left
	else
		title.Size = UDim2.new(0.58, 0, 0.08, 0)
		goldLabel.Position = UDim2.new(0.60, 0, 0.035, 0)
		goldLabel.Size = UDim2.new(0.31, 0, 0.08, 0)
		goldLabel.TextXAlignment = Enum.TextXAlignment.Right
	end

	buyTab.Position = UDim2.new(0.05, 0, 0.13, 0)
	buyTab.Size = UDim2.new(0.245, 0, 0.065, 0)
	sellTab.Position = UDim2.new(0.315, 0, 0.13, 0)
	sellTab.Size = UDim2.new(0.245, 0, 0.065, 0)
	for _, tab in ipairs({buyTab, sellTab}) do
		tab.TextScaled = true
		tab.TextStrokeTransparency = 1
		tab.Font = Enum.Font.GothamBold
		tab.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
		tab.TextColor3 = VENDOR_COLORS.Muted
		tab.BorderSizePixel = 0
		ensureVendorCorner(tab, 6)
		ensureVendorStroke(tab, VENDOR_COLORS.BrassDark, 0.2, 1)
	end
	buyTab.BackgroundColor3 = VENDOR_COLORS.Brass
	buyTab.TextColor3 = VENDOR_COLORS.Canvas
	sellTab.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
	sellTab.TextColor3 = VENDOR_COLORS.Muted

	local panelTop = isGear and 0.22 or 0.20
	vendorListTop = panelTop
	configurePanelLayout(buyPanel, isGear)
	configurePanelLayout(sellPanel, isGear)

	errorLabel.BackgroundColor3 = VENDOR_COLORS.DangerSurface
	errorLabel.BackgroundTransparency = 0
	errorLabel.BorderSizePixel = 0
	errorLabel.TextColor3 = Color3.fromRGB(214, 138, 120)
	errorLabel.TextStrokeTransparency = 1
	errorLabel.Visible = false
	errorLabel.TextXAlignment = Enum.TextXAlignment.Left
	errorLabel.TextYAlignment = Enum.TextYAlignment.Center
	errorLabel.Font = Enum.Font.GothamBold
	errorLabel.TextWrapped = true
	updateVendorListSpace()
	ensureVendorCorner(errorLabel, 6)

	trainerPanel.Position = UDim2.new(0.05, 0, 0.16, 0)
	trainerPanel.Size = UDim2.new(0.90, 0, 0.69, 0)
	trainerPanel.BackgroundTransparency = 1
	trainerPanel.BorderSizePixel = 0
	removeVendorGradient(trainerPanel)

	trainerDescription.Position = UDim2.new(0.05, 0, 0.08, 0)
	trainerDescription.Size = UDim2.new(0.90, 0, 0.20, 0)
	trainerDescription.BackgroundTransparency = 1
	trainerDescription.TextColor3 = VENDOR_COLORS.Muted
	trainerDescription.TextStrokeTransparency = 1
	trainerDescription.TextXAlignment = Enum.TextXAlignment.Center
	trainerDescription.TextYAlignment = Enum.TextYAlignment.Center
	trainerDescription.Font = Enum.Font.Gotham

	trainerRespec.Position = UDim2.new(0.05, 0, 0.32, 0)
	trainerRespec.Size = UDim2.new(0.90, 0, 0.10, 0)
	trainerRespec.BackgroundColor3 = VENDOR_COLORS.Brass
	trainerRespec.TextColor3 = VENDOR_COLORS.Canvas
	trainerRespec.TextStrokeTransparency = 1
	trainerRespec.Font = Enum.Font.GothamBold
	ensureVendorCorner(trainerRespec, 6)
	ensureVendorStroke(trainerRespec, VENDOR_COLORS.Brass, 0.05, 1)

	trainerConfirmDialog.Position = UDim2.new(0.05, 0, 0.45, 0)
	trainerConfirmDialog.Size = UDim2.new(0.90, 0, 0.31, 0)
	trainerConfirmDialog.BackgroundColor3 = VENDOR_COLORS.DangerSurface
	trainerConfirmDialog.BackgroundTransparency = 0
	trainerConfirmDialog.BorderSizePixel = 0
	ensureVendorCorner(trainerConfirmDialog, 8)
	ensureVendorStroke(trainerConfirmDialog, VENDOR_COLORS.Danger, 0.08, 1)

	trainerConfirmButton.Position = UDim2.new(0.54, 0, 0.64, 0)
	trainerConfirmButton.Size = UDim2.new(0.40, 0, 0.25, 0)
	trainerCancelButton.Position = UDim2.new(0.06, 0, 0.64, 0)
	trainerCancelButton.Size = UDim2.new(0.40, 0, 0.25, 0)
	for _, button in ipairs({trainerConfirmButton, trainerCancelButton}) do
		button.TextStrokeTransparency = 1
		button.Font = Enum.Font.GothamBold
		ensureVendorCorner(button, 6)
	end
	trainerConfirmButton.BackgroundColor3 = VENDOR_COLORS.Brass
	trainerConfirmButton.TextColor3 = VENDOR_COLORS.Canvas
	trainerCancelButton.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
	trainerCancelButton.TextColor3 = VENDOR_COLORS.Text
	ensureVendorStroke(trainerCancelButton, VENDOR_COLORS.BrassDark, 0.1, 1)
end

local sharedGui = playerGui:WaitForChild("SharedUI")
local tooltip = sharedGui:WaitForChild("Tooltip")
local tipName = tooltip:WaitForChild("ItemName")
local tipRarity = tooltip:WaitForChild("Rarity")
local tipStats = tooltip:WaitForChild("Stats")
local tipAffixes = tooltip:WaitForChild("Affixes")
local tipBind = tooltip:WaitForChild("Bind")
local tipLevelReq = tooltip:WaitForChild("LevelReq")
local tipDescription = tooltip:WaitForChild("Description")

-- ============================================================================
-- Helpers
-- ============================================================================

local function showError(msg)
	local text = msg or ""
	errorLabel.Text = text
	errorLabel.Visible = text ~= ""
	if text == "" then
		return
	end
	task.delay(3, function()
		if errorLabel.Text == text then
			errorLabel.Text = ""
			errorLabel.Visible = false
		end
	end)
end

local function updateGold(amount)
	goldLabel.Text = "◈ " .. tostring(amount) .. " ORO"
end

local function clearPanel(panel)
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("GuiButton") or child:IsA("Frame") then
			child:Destroy()
		end
	end
end

-- Rarity colors
local RARITY_COLORS = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(75, 220, 75),
	Rare = Color3.fromRGB(75, 150, 255),
	Epic = Color3.fromRGB(180, 75, 255),
}

local function bumpVendorTooltipCloseVersion()
	local version = (tonumber(tooltip:GetAttribute("TooltipCloseVersion")) or 0) + 1
	tooltip:SetAttribute("TooltipCloseVersion", version)
	return version
end

local function hideVendorTooltip()
	local version = bumpVendorTooltipCloseVersion()
	task.delay(0.28, function()
		if tooltip:GetAttribute("TooltipCloseVersion") ~= version
			or tooltip:GetAttribute("TooltipHovering") == true
			or tooltip:GetAttribute("TooltipOwner") ~= "Vendor" then
			return
		end
		tooltip:SetAttribute("TooltipOwner", "")
		tooltip:SetAttribute("ItemInstanceId", "")
		tooltip.Visible = false
	end)
end

local function showVendorTooltip(itemData)
	if not itemData then
		hideVendorTooltip()
		return
	end

	bumpVendorTooltipCloseVersion()
	tooltip:SetAttribute("TooltipOwner", "Vendor")
	tooltip:SetAttribute("ItemInstanceId", "")
	local rarityColor = RARITY_COLORS[itemData.rarity] or Color3.fromRGB(255, 255, 255)
	tipName.Text = itemData.name or itemData.templateId or "Ítem"
	tipName.TextColor3 = rarityColor
	tipRarity.Text = tostring(itemData.rarity or "Común") .. (itemData.slot and ("  ·  " .. tostring(itemData.slot)) or "")
	tipRarity.TextColor3 = rarityColor

	local statLines = {}
	if itemData.stats then
		for statName, value in pairs(itemData.stats) do
			table.insert(statLines, "  +" .. tostring(math.floor(tonumber(value) or 0)) .. " " .. tostring(statName))
		end
	end
	tipStats.Text = #statLines > 0 and table.concat(statLines, "\n") or ""

	local affixLines = {}
	if itemData.affixes then
		for _, affix in ipairs(itemData.affixes) do
			table.insert(affixLines, "  " .. tostring(affix))
		end
	end
	tipAffixes.Text = #affixLines > 0 and table.concat(affixLines, "\n") or ""
	tipBind.Text = itemData.bindState == "Bound" and "Vinculado al equipar" or (itemData.bindState or "")
	local template = itemData.templateId and ItemConfig.GetTemplate(itemData.templateId) or nil
	local levelReq = template and tonumber(template.levelReq) or nil
	tipLevelReq.Text = levelReq and ("Requiere nivel " .. tostring(levelReq)) or "Nivel requerido no disponible"
	tipDescription.Text = itemData.description or ""
	tooltip.Visible = true

	local mouse = UserInputService:GetMouseLocation()
	local viewport = workspace.CurrentCamera.ViewportSize
	local tipSize = tooltip.AbsoluteSize
	local px = math.clamp(mouse.X + 15, 4, math.max(4, viewport.X - tipSize.X - 4))
	local py = math.clamp(mouse.Y + 15, 4, math.max(4, viewport.Y - tipSize.Y - 4))
	tooltip.Position = UDim2.fromOffset(px, py)
end

-- ============================================================================
-- Buy Panel
-- ============================================================================

local function addVendorIcon(row, item, itemColor)
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0.31, 0, 0.80, 0)
	icon.Position = UDim2.new(0.025, 0, 0.10, 0)
	icon.BackgroundColor3 = BLACK_CELL
	icon.BackgroundTransparency = 0
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = item.iconId or ""
	icon.Parent = row
	ensureVendorCorner(icon, 5)
	ensureVendorStroke(icon, itemColor, 0.28, 1)
	return icon
end

local function addVendorPrice(row, text, isDisabled)
	local price = Instance.new("TextLabel")
	price.Name = "PriceLabel"
	price.Size = UDim2.new(0.31, 0, 0.20, 0)
	price.Position = UDim2.new(0.37, 0, 0.39, 0)
	price.BackgroundTransparency = 1
	price.BorderSizePixel = 0
	price.Text = "◈ " .. tostring(text) .. " ORO"
	price.TextColor3 = VENDOR_COLORS.Brass
	price.TextTransparency = isDisabled and 0.45 or 0
	price.TextScaled = false
	price.TextSize = 12
	price.TextStrokeTransparency = 1
	price.TextXAlignment = Enum.TextXAlignment.Left
	price.TextYAlignment = Enum.TextYAlignment.Center
	price.Font = UITheme.GetFont("BodyBold")
	price.Active = false
	price.Parent = row
	price.TextColor3 = VENDOR_COLORS.Brass
	price.TextTransparency = isDisabled and 0.45 or 0
	return price
end

local function addVendorAction(row, isDisabled)
	local action = Instance.new("TextLabel")
	action.Name = "BuyButton"
	action.Size = UDim2.new(0.25, 0, 0.44, 0)
	action.Position = UDim2.new(0.71, 0, 0.28, 0)
	action.BackgroundColor3 = isDisabled and VENDOR_COLORS.Surface or VENDOR_COLORS.Brass
	action.BackgroundTransparency = 0
	action.BorderSizePixel = 0
	action.Text = "COMPRAR"
	action.TextColor3 = isDisabled and VENDOR_COLORS.Muted or VENDOR_COLORS.Canvas
	action.TextTransparency = isDisabled and 0.25 or 0
	action.TextScaled = true
	action.TextStrokeTransparency = 1
	action.TextXAlignment = Enum.TextXAlignment.Center
	action.TextYAlignment = Enum.TextYAlignment.Center
	action.Font = UITheme.GetFont("BodyBold")
	action.Active = false
	action.Parent = row
	ensureVendorCorner(action, 5)
	ensureVendorStroke(action, isDisabled and VENDOR_COLORS.BrassDark or VENDOR_COLORS.Brass, 0.12, 1)
	return action
end

local function addInsufficientLabel(row, isDisabled)
	if not isDisabled then
		return
	end
	local warning = Instance.new("TextLabel")
	warning.Name = "InsufficientLabel"
	warning.Size = UDim2.new(0.31, 0, 0.20, 0)
	warning.Position = UDim2.new(0.37, 0, 0.68, 0)
	warning.BackgroundTransparency = 1
	warning.BorderSizePixel = 0
	warning.Text = "Oro insuficiente"
	warning.TextTruncate = Enum.TextTruncate.AtEnd
	warning.TextColor3 = Color3.fromRGB(214, 138, 120)
	warning.TextScaled = false
	warning.TextSize = 11
	warning.TextStrokeTransparency = 1
	warning.TextXAlignment = Enum.TextXAlignment.Left
	warning.TextYAlignment = Enum.TextYAlignment.Center
	warning.Font = UITheme.GetFont("BodyMedium")
	warning.Active = false
	warning.Parent = row
	warning.TextColor3 = Color3.fromRGB(214, 138, 120)
end

local function styleVendorRow(row, item, label, priceText, isDisabled, showBuyAction)
	local itemColor = RARITY_COLORS[item.rarity] or VENDOR_COLORS.Text
	local isConsumable = currentVendorId == "vendor_consumables"
	local rowHeight = isConsumable and 104 or 88
	row.Size = UDim2.new(0.94, 0, 0, rowHeight)
	row:SetAttribute("HearthboundBlackCell", true)
	row:SetAttribute("HearthboundCellBaseStrokeColor", itemColor)
	row:SetAttribute("HearthboundCellBaseStrokeThickness", 1)
	row:SetAttribute("HearthboundCellBaseStrokeTransparency", isDisabled and 0.55 or 0.28)
	row.BackgroundColor3 = BLACK_CELL
	row.BackgroundTransparency = 0
	row.BorderSizePixel = 0
	row.Text = ""
	row.TextColor3 = itemColor
	row.TextTransparency = isDisabled and 0.45 or 0
	row.TextScaled = false
	row.AutoButtonColor = false
	row.Active = not isDisabled
	row:SetAttribute("HearthboundVendorDisabled", isDisabled)
	row:SetAttribute("HearthboundRarity", item.rarity or "Common")
	ensureVendorCorner(row, isConsumable and 7 or 5)
	ensureVendorStroke(row, itemColor, isDisabled and 0.55 or 0.28, 1)

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Name = "ItemName"
	itemLabel.Size = UDim2.new(0.31, 0, 0.24, 0)
	itemLabel.Position = UDim2.new(0.37, 0, 0.10, 0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = label
	itemLabel.TextColor3 = itemColor
	itemLabel.TextTransparency = isDisabled and 0.45 or 0
	itemLabel.TextScaled = false
	itemLabel.TextSize = 14
	itemLabel.TextWrapped = false
	itemLabel.TextTruncate = Enum.TextTruncate.AtEnd
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.TextYAlignment = Enum.TextYAlignment.Center
	itemLabel.TextStrokeTransparency = 1
	itemLabel.Font = UITheme.GetFont("BodyMedium")
	itemLabel.Active = false
	itemLabel.Parent = row
	itemLabel.TextColor3 = itemColor
	itemLabel.TextTransparency = isDisabled and 0.45 or 0

	addVendorIcon(row, item, itemColor)
	addVendorPrice(row, priceText, isDisabled)
	if showBuyAction then
		addVendorAction(row, isDisabled)
		addInsufficientLabel(row, isDisabled)
	end
end

local function populateBuyPanel(items)
	clearPanel(buyPanel)

	for i, item in ipairs(items) do
		local price = tonumber(item.price) or 0
		local affordable = (localPlayer:GetAttribute("Gold") or 0) >= price
		local row = Instance.new("TextButton")
		row.Name = "BuyItem_" .. i
		row.LayoutOrder = i
		row:SetAttribute("HearthboundBlackCell", true)
		row:SetAttribute("HearthboundCellBaseStrokeColor", RARITY_COLORS[item.rarity] or VENDOR_COLORS.Text)
		row:SetAttribute("HearthboundCellBaseStrokeThickness", 1)
		row:SetAttribute("HearthboundCellBaseStrokeTransparency", not affordable and 0.55 or 0.28)
		row.Parent = buyPanel
		styleVendorRow(row, item, item.name or item.templateId or "Ítem", tostring(price), not affordable, true)
		row.MouseEnter:Connect(function() showVendorTooltip(item) end)
		row.MouseLeave:Connect(hideVendorTooltip)
		row.MouseButton1Click:Connect(function()
			if not affordable then
				return
			end
			Remotes.RequestBuyItem:FireServer({
				vendorId = currentVendorId,
				templateId = item.templateId,
				qty = 1,
			})
		end)
	end
end

-- ============================================================================
-- Sell Panel
-- ============================================================================

local function populateSellPanel(inventory)
	clearPanel(sellPanel)

	if not inventory or not inventory.bag then return end

	local order = 1
	local function addSellRow(item, label)
		local sellPrice = VendorConfig.GetSellPrice(item.rarity)
		local row = Instance.new("TextButton")
		row.Name = "SellItem_" .. order
		row.LayoutOrder = order
		row:SetAttribute("HearthboundBlackCell", true)
		row:SetAttribute("HearthboundCellBaseStrokeColor", RARITY_COLORS[item.rarity] or VENDOR_COLORS.Text)
		row:SetAttribute("HearthboundCellBaseStrokeThickness", 1)
		row:SetAttribute("HearthboundCellBaseStrokeTransparency", 0.28)
		row.Parent = sellPanel
		styleVendorRow(row, item, label, tostring(sellPrice), false, false)
		row.MouseEnter:Connect(function() showVendorTooltip(item) end)
		row.MouseLeave:Connect(hideVendorTooltip)
		row.MouseButton1Click:Connect(function()
			Remotes.RequestSellItem:FireServer({
				instanceId = item.instanceId,
			})
		end)
		order = order + 1
	end

	-- Solo se listan objetos de la mochila; el equipo nunca es vendible desde aquí.
	for _, item in ipairs(inventory.bag) do
		local quantity = tonumber(item.quantity) or 1
		local quantityText = quantity > 1 and (" x" .. tostring(quantity)) or ""
		addSellRow(item, string.format("%s%s", item.name or item.templateId or "Ítem", quantityText))
	end
end

-- ============================================================================
-- Open / Close
-- ============================================================================

local function openVendor(vendorId, vendorName)
	configureVendorWindow(vendorId)
	currentVendorId = vendorId
	currentVendorData = nil
	trainerConfirmArmed = false
	title.Text = vendorName or "Vendedor"
	isVendorOpen = true
	vendorGui.Enabled = true
	trainerPanel.Visible = false
	trainerConfirmDialog.Visible = false
	trainerRespec.Visible = true
	errorLabel.Text = ""
	errorLabel.Visible = false
	buyTab.Visible = true
	sellTab.Visible = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	-- Request vendor list
	Remotes.RequestVendorList:FireServer({ vendorId = vendorId })
end

local function closeVendor()
	isVendorOpen = false
	vendorGui.Enabled = false
	currentVendorId = nil
	currentVendorData = nil
	trainerConfirmArmed = false
	trainerPanel.Visible = false
	trainerConfirmDialog.Visible = false
	trainerRespec.Visible = true
	clearPanel(buyPanel)
	clearPanel(sellPanel)
	errorLabel.Text = ""
	errorLabel.Visible = false
	-- Restaurar mouse behavior (el cliente de cámara lo gestiona)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- ============================================================================
-- Tab switching
-- ============================================================================

buyTab.MouseButton1Click:Connect(function()
	buyPanel.Visible = true
	sellPanel.Visible = false
	buyTab.BackgroundColor3 = VENDOR_COLORS.Brass
	buyTab.TextColor3 = VENDOR_COLORS.Canvas
	sellTab.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
	sellTab.TextColor3 = VENDOR_COLORS.Muted
end)

sellTab.MouseButton1Click:Connect(function()
	buyPanel.Visible = false
	sellPanel.Visible = true
	buyTab.BackgroundColor3 = VENDOR_COLORS.SurfaceAlt
	buyTab.TextColor3 = VENDOR_COLORS.Muted
	sellTab.BackgroundColor3 = VENDOR_COLORS.Brass
	sellTab.TextColor3 = VENDOR_COLORS.Canvas

	-- Request inventory to populate sell panel
	Remotes.RequestInventory:FireServer()
end)

closeBtn.MouseButton1Click:Connect(closeVendor)

-- ============================================================================
-- Trainer window: dedicated respec flow without duplicating the talent tree
-- ============================================================================

trainerRespec.MouseButton1Click:Connect(function()
	if not currentVendorData or not currentVendorData.isTrainer then return end
	trainerConfirmArmed = true
	trainerRespec.Visible = false
	trainerConfirmDialog.Visible = true
	trainerDescription.Text = "El reentrenamiento devuelve tus puntos y revoca las skills de talento. Esta acción cuesta " .. tostring(VendorConfig.GetRespecCost()) .. " oro."
end)

trainerCancelButton.MouseButton1Click:Connect(function()
	trainerConfirmArmed = false
	trainerConfirmDialog.Visible = false
	trainerRespec.Visible = true
end)

trainerConfirmButton.MouseButton1Click:Connect(function()
	if not trainerConfirmArmed or not currentVendorData or not currentVendorData.isTrainer then return end
	trainerConfirmArmed = false
	trainerConfirmDialog.Visible = false
	trainerRespec.Visible = true
	RequestRespec:FireServer({})
end)

-- ============================================================================
-- Remote handlers
-- ============================================================================

Remotes.VendorListResult.OnClientEvent:Connect(function(data)
	if not data.success then
		showError(data.error)
		return
	end

	currentVendorData = data
	updateGold(data.gold or 0)
	errorLabel.Text = ""
	errorLabel.Visible = false

	-- Instructor usa una ventana propia con solo el flujo de respec.
	if data.isTrainer then
		buyPanel.Visible = false
		sellPanel.Visible = false
		buyTab.Visible = false
		sellTab.Visible = false
		trainerPanel.Visible = true
		trainerConfirmDialog.Visible = false
		trainerRespec.Visible = true
		trainerConfirmArmed = false
		local respecCost = VendorConfig.GetRespecCost()
		trainerDescription.Text = "Reentrena tus talentos para devolver los puntos invertidos y revocar las skills aprendidas. Coste: " .. tostring(respecCost) .. " oro."
		errorLabel.Text = ""
		return
	end

	trainerPanel.Visible = false
	trainerConfirmDialog.Visible = false
	local isConsumableVendor = currentVendorId == "vendor_consumables"
	buyTab.Visible = not isConsumableVendor
	sellTab.Visible = data.buysFromPlayer == true and not isConsumableVendor
	buyPanel.Visible = true
	sellPanel.Visible = false
	configurePanelLayout(buyPanel, currentVendorId == "vendor_gear")
	configurePanelLayout(sellPanel, currentVendorId == "vendor_gear")

	-- Populate buy panel
	if data.items then
		populateBuyPanel(data.items)
	end
end)

Remotes.VendorResult.OnClientEvent:Connect(function(data)
	if data.gold then
		updateGold(data.gold)
	end

	if data.success then
		errorLabel.Text = ""
		errorLabel.Visible = false
		-- Si estamos en tab de vender, actualizar lista
		if sellPanel.Visible and data.inventory then
			populateSellPanel(data.inventory)
		end
	else
		showError(data.error)
	end
end)

RespecResult.OnClientEvent:Connect(function(data)
	if not isVendorOpen or not currentVendorData or not currentVendorData.isTrainer then return end
	if data.success then
		trainerConfirmArmed = false
		trainerConfirmDialog.Visible = false
		trainerRespec.Visible = true
		trainerDescription.Text = "Reentrenamiento completado. Tus talentos fueron reiniciados."
		errorLabel.Text = ""
		errorLabel.Visible = false
	else
		showError(data.error)
	end
end)

-- Recibir datos de inventario para poblar panel de venta
Remotes.InventoryData.OnClientEvent:Connect(function(data)
	if isVendorOpen and sellPanel.Visible then
		populateSellPanel(data)
	end
end)

-- ============================================================================
-- NPC ProximityPrompt handlers
-- ============================================================================

local function isTrainer(vendorId)
	local vendor = VendorConfig.GetVendor(vendorId)
	return vendor and vendor.isTrainer or false
end

local function hookNPCs()
	local hub = Workspace:FindFirstChild("Hub")
	if not hub then return end

	for _, desc in hub:GetDescendants() do
		if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Parent and desc.Parent.Parent:GetAttribute("VendorId") then
			local vendorId = desc.Parent.Parent:GetAttribute("VendorId")
			local vendorName = desc.ObjectText

			desc.Triggered:Connect(function()
				openVendor(vendorId, vendorName)
			end)
		end
	end
end

hookNPCs()

-- Hook NPCs added later
Workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Parent and desc.Parent.Parent:GetAttribute("VendorId") then
		local vendorId = desc.Parent.Parent:GetAttribute("VendorId")
		local vendorName = desc.ObjectText

		desc.Triggered:Connect(function()
			openVendor(vendorId, vendorName)
		end)
	end
end)

-- ============================================================================
-- Gold attribute update
-- ============================================================================

localPlayer:GetAttributeChangedSignal("Gold"):Connect(function()
	local gold = localPlayer:GetAttribute("Gold") or 0
	updateGold(gold)
end)

print("[Vandrheim] VendorClient R5 activo")
