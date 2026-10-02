local modelTest = workspace:FindFirstChild("ModelTest")
assert(modelTest, "Workspace.ModelTest missing")
local assets = modelTest:FindFirstChild("HU34_WeaponModelsPreview")
assert(assets, "Weapon asset preview folder missing")
assert(not assets:FindFirstChild("R15FitPreview"), "R15 fit folder already exists; refusing to overwrite")
local sourceRig = modelTest:FindFirstChild("Rig")
assert(sourceRig and sourceRig:IsA("Model"), "Workspace.ModelTest.Rig missing")
local fitFolder = Instance.new("Folder")
fitFolder.Name = "R15FitPreview"
fitFolder:SetAttribute("DesignOnly", true)
fitFolder:SetAttribute("ApprovedForIntegration", false)
fitFolder.Parent = assets
local previewIds = {"sword_knight","paladin_sword_frost","paladin_greatsword","paladin_greatsword_blue","paladin_greatsword_frost","unique_frost_greatsword","hunter_bow_blue","hunter_bow_frost","cleric_wand_blue","cleric_wand_frost","shield_guard_blue","shield_guard_frost"}
local lines = {}
for index, id in ipairs(previewIds) do
    local sourceWeapon = assets:FindFirstChild(id)
    assert(sourceWeapon and sourceWeapon:IsA("Model"), "Preview model not found: " .. id)
    local rig = sourceRig:Clone()
    rig.Name = "Fit_" .. id
    for _, item in ipairs(rig:GetDescendants()) do
        if item:IsA("BaseScript") or item:IsA("Accessory") then item:Destroy() end
    end
    local humanoid = rig:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AutoRotate = false
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.BreakJointsOnDeath = false
    end
    rig:SetAttribute("DesignOnly", true)
    rig:SetAttribute("WeaponPreview", id)
    rig:SetAttribute("ApprovedForIntegration", false)
    rig.Parent = fitFolder
    local column = (index - 1) % 4
    local row = math.floor((index - 1) / 4)
    rig:PivotTo(CFrame.new(-160 + column * 10, 0, 900 + row * 14))
    for _, item in ipairs(rig:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored = true
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
        end
    end
    local weapon = sourceWeapon:Clone()
    weapon.Name = id
    weapon.Parent = rig
    local handle = weapon:FindFirstChild("Handle", true)
    local attach = sourceWeapon:GetAttribute("AttachTo") or ((string.find(id,"shield") and "LeftHand") or "RightHand")
    local hand = rig:FindFirstChild(attach, true)
    assert(handle and handle:IsA("BasePart"), "Handle missing in " .. id)
    assert(hand and hand:IsA("BasePart"), attach .. " missing in R15 rig for " .. id)
    local pivot = weapon:GetPivot()
    local handleRelative = pivot:ToObjectSpace(handle.CFrame)
    weapon:PivotTo(hand.CFrame * handleRelative:Inverse())
    for _, item in ipairs(weapon:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Anchored = false
            item.CanCollide = false
            item.CanTouch = false
            item.CanQuery = false
            item.Massless = true
        end
    end
    local handWeld = Instance.new("WeldConstraint")
    handWeld.Name = "Preview_HandWeld"
    handWeld.Part0 = hand
    handWeld.Part1 = handle
    handWeld.Parent = handle
    local scripts, partCount = 0, 0
    for _, item in ipairs(weapon:GetDescendants()) do
        if item:IsA("BaseScript") then scripts += 1 end
        if item:IsA("BasePart") then partCount += 1 end
    end
    table.insert(lines, string.format("%s on %s | %d visible parts | scripts=%d | handle welded", id, attach, partCount, scripts))
end
return table.concat(lines, "\n")
