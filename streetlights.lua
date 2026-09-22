local StreetLights : Folder = workspace.GameMap.StreetLights

for _, part : Part in StreetLights:GetDescendants() do
    pcall(function()
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
    end)
end
