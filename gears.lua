local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local storedGearValue = nil 

local currentSeat = nil
local gasValueObject = nil
local loopConnection = nil

-- Max cap boundary rule
local MAX_GEAR = 12

-- Helper function to fetch the active car's gear object
local function getActiveGearValue()
    local character = player.Character
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not (humanoid and humanoid.SeatPart and humanoid.SeatPart:IsA("VehicleSeat")) then return nil end
    
    local status = humanoid.SeatPart:FindFirstChild("Status")
    if not status then return nil end
    
    local gearVal = status:FindFirstChild("Gear")
    if gearVal and gearVal:IsA("ValueBase") then
        return gearVal
    end
    
    return nil
end

-- ==========================================
-- ⚡ HIGH-SPEED CLEANER & PUMPER LIFE-CYCLE
-- ==========================================
local function cleanAndPumpVehicle(seat)
    currentSeat = seat
    
    -- Find the vehicle body from the seat
    local body = seat.Parent
    if body then
        -- Safely clear TouchInterests out of the requested targets if they exist
        local targets = {"DRIFT_TOUCH_LEFT", "DRIFT_TOUCH_RIGHT", "TOUCH_PART"}
        for _, partName in ipairs(targets) do
            local part = body:FindFirstChild(partName)
            if part then
                local touchInterest = part:FindFirstChild("TouchInterest")
                if touchInterest then
                    touchInterest:Destroy()
                end
            end
        end
    end
end

local function stopVehicleLoop()
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
    currentSeat = nil
    gasValueObject = nil
    storedGearValue = nil
end

-- Monitor Seat entry/exit to trigger the pumper dynamically
local function setupSeatTracking(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    
    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            cleanAndPumpVehicle(seat)
        else
            stopVehicleLoop()
        end
    end)
end

player.CharacterAdded:Connect(setupSeatTracking)
if player.Character then setupSeatTracking(player.Character) end

-- ==========================================
-- ⌨️ KEY DETECTION PIPELINES
-- ==========================================

-- 1. DETECT KEY DOWN (Press E, Q, or Hold F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    local gearVal = getActiveGearValue()
    if not gearVal then return end
    
    -- Shift Up to Multiples of Two (Max 12)
    if input.KeyCode == Enum.KeyCode.E then
        if storedGearValue == nil then
            task.spawn(function()
                task.wait(0.02) -- Anti-conflict layout buffer delay
                local currentVal = gearVal.Value
                -- Round to the next highest multiple of 2
                local nextGear = math.floor((currentVal / 2) + 1) * 2
                if nextGear > MAX_GEAR then
                    nextGear = MAX_GEAR
                end
                gearVal.Value = nextGear
            end)
        end
        
    -- Shift Down to Multiples of Two (Min 0)
    elseif input.KeyCode == Enum.KeyCode.Q then
        if storedGearValue == nil then
            task.spawn(function()
                task.wait(0.02) -- Anti-conflict layout buffer delay
                local currentVal = gearVal.Value
                -- Round to the next lowest multiple of 2
                local nextGear = math.ceil((currentVal / 2) - 1) * 2
                if nextGear < 0 then
                    nextGear = 0
                end
                gearVal.Value = nextGear
            end)
        end
        
    -- Emergency Clutch Hold Mode
    elseif input.KeyCode == Enum.KeyCode.F then
        if storedGearValue == nil then
            storedGearValue = gearVal.Value 
            gearVal.Value = 0               
        end
    end
end)

-- 2. DETECT KEY RELEASE (Let go of F)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F then
        local gearVal = getActiveGearValue()
        
        if storedGearValue ~= nil then
            if gearVal then
                gearVal.Value = math.clamp(storedGearValue, 0, MAX_GEAR)
            end
            storedGearValue = nil 
        end
    end
end)
