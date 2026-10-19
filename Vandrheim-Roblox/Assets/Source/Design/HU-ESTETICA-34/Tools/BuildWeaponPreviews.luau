local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modelTest = workspace:FindFirstChild("ModelTest")
assert(modelTest, "Workspace.ModelTest missing")
assert(not modelTest:FindFirstChild("HU34_WeaponModelsPreview"), "HU34 preview already exists; refusing to overwrite")

local function get(path)
    local node = game
    for segment in string.gmatch(path, "[^%.]+") do
        node = node:FindFirstChild(segment)
        assert(node, "Missing source reference: " .. path)
    end
    return node
end
local refs = {
    sword = "ReplicatedStorage.Assets.Models.Equipment.Paladin.paladin_sword_1h_mesh",
    greatsword = "ReplicatedStorage.Assets.Models.Equipment.Paladin.paladin_sword_2h",
    bow = "ReplicatedStorage.Assets.Models.Equipment.Hunter.hunter_bow",
    wand = "ReplicatedStorage.Assets.Models.Equipment.Weapons.cleric_wand",
    shield = "ReplicatedStorage.Assets.Models.Equipment.Paladin.paladin_shield_mesh",
}
local folder = Instance.new("Folder")
folder.Name = "HU34_WeaponModelsPreview"
folder:SetAttribute("DesignOnly", true)
folder:SetAttribute("ApprovedForIntegration", false)
folder.Parent = modelTest

local C = {
    blueSteel = Color3.fromRGB(88, 131, 169),
    blueEdge = Color3.fromRGB(130, 199, 232),
    frostSteel = Color3.fromRGB(47, 66, 88),
    frostSilver = Color3.fromRGB(156, 185, 202),
    ice = Color3.fromRGB(147, 226, 255),
    amethyst = Color3.fromRGB(150, 102, 213),
    gold = Color3.fromRGB(211, 164, 66),
    leather = Color3.fromRGB(48, 31, 27),
    frostLeather = Color3.fromRGB(32, 29, 38),
    wood = Color3.fromRGB(66, 42, 28),
    ivory = Color3.fromRGB(217, 207, 183),
}
local M = Enum.Material
local function findPart(model, names)
    for _, name in ipairs(names) do
        local item = model:FindFirstChild(name, true)
        if item and item:IsA("BasePart") then return item end
    end
    return nil
end
local function weldAccent(model, part, anchor)
    local weld = Instance.new("WeldConstraint")
    weld.Name = "DesignWeld_" .. part.Name
    weld.Part0 = anchor
    weld.Part1 = part
    weld.Parent = part
end
local function addAccent(model, name, className, size, cf, color, material, transparency, anchor)
    local item = Instance.new(className)
    item.Name = name
    item.Size = size
    item.CFrame = cf
    item.Color = color
    item.Material = material
    item.Transparency = transparency or 0
    item.Anchored = true
    item.CanCollide = false
    item.CanTouch = false
    item.CanQuery = false
    item.Massless = true
    item.Parent = model
    if anchor then weldAccent(model, item, anchor) end
    return item
end
local function tint(model, family, tier)
    local frost = tier == "frost"
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            local n = string.lower(item.Name)
            if string.find(n, "handle") or string.find(n, "grip") then
                item.Color = frost and C.frostLeather or C.leather
                item.Material = M.SmoothPlastic
            elseif string.find(n, "gem") or string.find(n, "crystal") or string.find(n, "accent") and family ~= "sword" then
                item.Color = frost and C.amethyst or C.ice
                item.Material = frost and M.Ice or M.Neon
                if item.Name == "BladeAccent" then item.Color = frost and C.ice or C.blueEdge; item.Material = M.Neon end
            elseif string.find(n, "pommel") or string.find(n, "crossguard") or string.find(n, "filigree") or string.find(n, "rim") or string.find(n, "boss") or string.find(n, "cap") or string.find(n, "collar") then
                item.Color = frost and C.frostSilver or C.gold
                item.Material = M.Metal
            elseif family == "bow" and (string.find(n, "limb") or string.find(n, "wood")) then
                item.Color = frost and C.frostSteel or C.wood
                item.Material = M.Wood
            elseif family == "wand" and string.find(n, "shaft") then
                item.Color = frost and C.frostSteel or C.ivory
                item.Material = M.SmoothPlastic
            elseif family == "shield" and (string.find(n, "cross") or string.find(n, "shieldbody") or string.find(n, "shield_body")) then
                if string.find(n, "cross") then
                    item.Color = frost and C.ice or C.gold
                    item.Material = frost and M.Ice or M.Metal
                else
                    item.Color = frost and C.frostSteel or C.blueSteel
                    item.Material = M.Metal
                end
            elseif string.find(n, "string") then
                item.Color = frost and C.ice or C.frostSilver
                item.Material = frost and M.Neon or M.SmoothPlastic
            elseif string.find(n, "blade") or string.find(n, "steel") or string.find(n, "iron") then
                item.Color = frost and C.frostSteel or C.blueSteel
                item.Material = M.Metal
            elseif family == "shield" then
                item.Color = frost and C.frostSilver or C.blueSteel
                item.Material = M.Metal
            elseif family == "wand" then
                item.Color = frost and C.frostSilver or C.gold
                item.Material = M.Metal
            end
        end
    end
end
local function addSwordCrystals(model, count, unique)
    local blade = findPart(model, {"Blade", "blade_geom"})
    local anchor = findPart(model, {"Handle"}) or blade
    if not blade then return end
    local length = blade.Size.Y
    local width = blade.Size.X
    for i = 1, count do
        local t = -0.32 + (i - 1) * (0.64 / math.max(1, count - 1))
        local side = (i % 2 == 0) and 1 or -1
        local scale = unique and 1.25 or 1
        local cf = blade.CFrame * CFrame.new(side * (width * 0.58 + 0.07), t * length, -0.02) * CFrame.Angles(0, 0, math.rad(side * 26))
        addAccent(model, "IceShard_" .. i, "WedgePart", Vector3.new(0.19 * scale, 0.40 * scale, 0.13), cf, C.ice, M.Ice, 0.12, anchor)
    end
end
local function addBowCrystals(model, count)
    local bounds, size = model:GetBoundingBox()
    local anchor = findPart(model, {"BowGrip", "Handle"})
    for i = 1, count do
        local y = (i % 2 == 1) and size.Y * 0.35 or -size.Y * 0.35
        local side = (i % 2 == 1) and 1 or -1
        local cf = bounds * CFrame.new(side * size.X * 0.18, y, -size.Z * 0.35) * CFrame.Angles(0, 0, math.rad(side * 24))
        addAccent(model, "BowIceShard_" .. i, "WedgePart", Vector3.new(0.24, 0.42, 0.18), cf, C.ice, M.Ice, 0.10, anchor)
    end
end
local function addWandCrystals(model)
    local crystal = findPart(model, {"Crystal", "body_geom"})
    local anchor = findPart(model, {"Handle"}) or crystal
    if not crystal then return end
    for i, angle in ipairs({-28, 28}) do
        local cf = crystal.CFrame * CFrame.new((i == 1 and -1 or 1) * crystal.Size.X * 0.45, -crystal.Size.Y * 0.15, -crystal.Size.Z * 0.15) * CFrame.Angles(0, 0, math.rad(angle))
        addAccent(model, "CrystalShard_" .. i, "WedgePart", Vector3.new(0.14, 0.38, 0.12), cf, C.ice, M.Ice, 0.10, anchor)
    end
end
local function addShieldCrystals(model)
    local body = findPart(model, {"ShieldBody", "Shield", "shield_geom"})
    local anchor = findPart(model, {"Handle"}) or body
    if not body then return end
    local x = body.Size.X * 0.44
    local y = body.Size.Y * 0.37
    for i, offset in ipairs({Vector3.new(-x,y,0), Vector3.new(x,y,0), Vector3.new(-x,-y,0), Vector3.new(x,-y,0)}) do
        local cf = body.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad((i % 2 == 0) and 22 or -22))
        addAccent(model, "ShieldIceFacet_" .. i, "WedgePart", Vector3.new(0.24, 0.36, 0.12), cf, C.ice, M.Ice, 0.10, anchor)
    end
end
local specs = {
    {id="sword_knight", family="sword", tier="blue", source=refs.sword, attach="RightHand"},
    {id="paladin_sword_frost", family="sword", tier="frost", source=refs.sword, attach="RightHand"},
    {id="paladin_greatsword", family="greatsword", tier="base", source=refs.greatsword, attach="RightHand"},
    {id="paladin_greatsword_blue", family="greatsword", tier="blue", source=refs.greatsword, attach="RightHand"},
    {id="paladin_greatsword_frost", family="greatsword", tier="frost", source=refs.greatsword, attach="RightHand"},
    {id="unique_frost_greatsword", family="greatsword", tier="unique", source=refs.greatsword, attach="RightHand"},
    {id="hunter_bow_blue", family="bow", tier="blue", source=refs.bow, attach="RightHand"},
    {id="hunter_bow_frost", family="bow", tier="frost", source=refs.bow, attach="RightHand"},
    {id="cleric_wand_blue", family="wand", tier="blue", source=refs.wand, attach="RightHand"},
    {id="cleric_wand_frost", family="wand", tier="frost", source=refs.wand, attach="RightHand"},
    {id="shield_guard_blue", family="shield", tier="blue", source=refs.shield, attach="LeftHand"},
    {id="shield_guard_frost", family="shield", tier="frost", source=refs.shield, attach="LeftHand"},
}
local lines = {}
for index, spec in ipairs(specs) do
    local source = get(spec.source)
    assert(source:IsA("Model"), "Expected Model source: " .. spec.source)
    local model = source:Clone()
    model.Name = spec.id
    model.Parent = folder
    model:SetAttribute("VisualAssetId", spec.id)
    model:SetAttribute("AttachTo", spec.attach)
    model:SetAttribute("AssetSource", "ProductionOwn")
    model:SetAttribute("PhysicsProfile", "VisualOnly")
    model:SetAttribute("PreviewOnly", true)
    model:SetAttribute("ApprovedForIntegration", false)
    model:SetAttribute("CandidateVariant", spec.tier)
    model:SetAttribute("SourceReference", spec.source)
    model:SetAttribute("DesignFamily", spec.family)
    if spec.tier == "blue" or spec.tier == "frost" or spec.tier == "unique" then tint(model, spec.family, spec.tier == "unique" and "frost" or spec.tier) end
    if spec.family == "greatsword" and spec.tier == "blue" then
        local guard = findPart(model, {"Crossguard"})
        if guard then addAccent(model, "BlueTierGem", "Part", Vector3.new(0.23,0.23,0.16), guard.CFrame * CFrame.new(0,0,-0.15), C.ice, M.Glass, 0, findPart(model,{"Handle"}) or guard).Shape = Enum.PartType.Ball end
    elseif spec.family == "greatsword" and spec.tier == "frost" then
        addSwordCrystals(model, 4, false)
    elseif spec.family == "greatsword" and spec.tier == "unique" then
        addSwordCrystals(model, 6, true)
    elseif spec.family == "sword" and spec.tier == "blue" then
        local guard = findPart(model, {"Crossguard"})
        local h = findPart(model, {"Handle"})
        if guard then addAccent(model, "BlueTierGem", "Part", Vector3.new(0.18,0.18,0.12), guard.CFrame * CFrame.new(0,0,-0.12), C.ice, M.Glass, 0, h or guard).Shape = Enum.PartType.Ball end
    elseif spec.family == "sword" and spec.tier == "frost" then
        addSwordCrystals(model, 3, false)
    elseif spec.family == "bow" and spec.tier == "blue" then
        local grip = findPart(model, {"BowGrip"})
        if grip then addAccent(model, "BlueTierCore", "Part", Vector3.new(0.16,0.16,0.10), grip.CFrame * CFrame.new(0,0,-0.20), C.ice, M.Glass, 0, findPart(model,{"Handle"}) or grip).Shape = Enum.PartType.Ball end
    elseif spec.family == "bow" and spec.tier == "frost" then
        addBowCrystals(model, 4)
    elseif spec.family == "wand" and spec.tier == "blue" then
        local crystal = findPart(model, {"Crystal"})
        if crystal then crystal.Color = C.ice end
    elseif spec.family == "wand" and spec.tier == "frost" then
        addWandCrystals(model)
    elseif spec.family == "shield" and spec.tier == "blue" then
        local body = findPart(model, {"ShieldBody"})
        if body then addAccent(model, "BlueTierBossGem", "Part", Vector3.new(0.22,0.22,0.13), body.CFrame * CFrame.new(0,0,-0.17), C.ice, M.Glass, 0, findPart(model,{"Handle"}) or body).Shape = Enum.PartType.Ball end
    elseif spec.family == "shield" and spec.tier == "frost" then
        addShieldCrystals(model)
    end
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
            item.Massless = true
        end
    end
    local column = (index - 1) % 4
    local row = math.floor((index - 1) / 4)
    model:PivotTo(CFrame.new(-520 + column * 13, 40, -520 + row * 14))
    local parts, scripts = 0, 0
    for _, item in ipairs(model:GetDescendants()) do
        if item:IsA("BasePart") then parts += 1 end
        if item:IsA("BaseScript") then scripts += 1 end
    end
    table.insert(lines, string.format("%s | %s | %d parts | %d scripts | attach=%s | preview anchored", spec.id, spec.source, parts, scripts, spec.attach))
end
return table.concat(lines, "\n")
