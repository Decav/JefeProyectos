local folder = workspace.ModelTest.HU34_WeaponModelsPreview.R15FitPreview
assert(folder, "R15 fit preview missing")
local lines = {}
for _, rig in ipairs(folder:GetChildren()) do
    if rig:IsA("Model") then
        local weapon = nil
        for _, child in ipairs(rig:GetChildren()) do
            if child:IsA("Model") and child:GetAttribute("VisualAssetId") then weapon = child; break end
        end
        for _, item in ipairs(rig:GetDescendants()) do
            if not (weapon and item:IsDescendantOf(weapon)) then
                if item:IsA("BaseScript") or item:IsA("Accessory") or item:IsA("Constraint") or item.ClassName == "NoCollisionConstraint" or item:IsA("Attachment") or item:IsA("SurfaceAppearance") or item:IsA("Decal") or item:IsA("Texture") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("WrapLayer") or item:IsA("WrapTarget") then
                    item:Destroy()
                elseif item:IsA("BasePart") then
                    item.Color = Color3.fromRGB(190, 174, 153)
                    item.Material = Enum.Material.SmoothPlastic
                    item.Anchored = true
                    item.CanCollide = false
                    item.CanTouch = false
                    item.CanQuery = false
                end
            end
        end
        table.insert(lines, rig.Name .. " cleaned: static body copy, visual constraints/clothing removed; weapon preserved=" .. tostring(weapon ~= nil))
    end
end
return table.concat(lines, "\n")
