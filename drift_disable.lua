-- This code was modified from Cobalt -- https://gitlab.com/upio/cobalt 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Function to check if the local player is currently sitting
local function isPlayerSitting()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid.Sit -- Returns true if sitting, false if not
        end
    end
    return false
end

local function GetNil(Name, DebugId) 
    for _, Object in getnilinstances() do 
        if Object.Name == Name and Object:GetDebugId() == DebugId then 
            return Object 
        end 
    end 
end 

-- Only execute if the player is NOT sitting down
if not isPlayerSitting() then
    local Event = ReplicatedStorage.Events.VehicleService 
    Event:FireServer( "skid", GetNil("VehicleSeat", "1_850635"), 1 )
else
    print("Event blocked: Player is currently sitting.")
end
