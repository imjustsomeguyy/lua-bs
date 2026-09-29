local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Global table to allow cleanly overriding the script if re-run
if _G.TouchCleanerConnection then
	_G.TouchCleanerConnection:Disconnect()
	_G.TouchCleanerConnection = nil
end

-- Function to find and delete TouchInterests from the target parts
local function cleanVehicleTouches(seat)
	local body = seat.Parent
	if not body then return end
	
	local targets = {"DRIFT_TOUCH_LEFT", "DRIFT_TOUCH_RIGHT", "TOUCH_PART"}
	for _, partName in ipairs(targets) do
		local part = body:FindFirstChild(partName)
		if part then
			local touchInterest = part:FindFirstChild("TouchInterest")
			if touchInterest then
				touchInterest:Destroy()
				print("Successfully destroyed TouchInterest inside: " .. partName)
			end
		end
	end
end

-- Tracks when you enter a seat
local function setupSeatTracking(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end
	
	-- Listen for changes to the SeatPart property
	local connection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		local seat = humanoid.SeatPart
		if seat and seat:IsA("VehicleSeat") then
			cleanVehicleTouches(seat)
		end
	end)
	
	-- Store connection globally so we can clean it up if the character changes/respawns
	_G.TouchCleanerConnection = connection
end

-- Handle character spawning and current character status
player.CharacterAdded:Connect(setupSeatTracking)
if player.Character then 
	setupSeatTracking(player.Character) 
end

print("TouchInterest vehicle cleaner actively loaded.")
