local folder = workspace.ModelTest.HU34_WeaponModelsPreview.R15FitPreview
assert(folder, "R15 fit preview missing")
local lines = {}
for index, rig in ipairs(folder:GetChildren()) do
    if rig:IsA("Model") then
        local column = (index - 1) % 4
        local row = math.floor((index - 1) / 4)
        rig:PivotTo(CFrame.new(-300 + column * 42, 0, 1200 + row * 42))
        table.insert(lines, rig.Name .. " -> " .. tostring(rig:GetPivot().Position))
    end
end
return table.concat(lines, "\n")
