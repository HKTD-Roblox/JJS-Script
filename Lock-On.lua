local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BUTTON_IMAGE_DEFAULT = "rbxassetid://140051166681897"
local BUTTON_IMAGE_PRESSED = "rbxassetid://109696699865842"
local MARKER_IMAGE = "rbxassetid://262619584"

local MAX_LOCK_DISTANCE = 500
local HOLD_TO_DRAG_TIME = 2
local DRAG_THRESHOLD = 8

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartLockOnGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local LockButton = Instance.new("ImageButton")
LockButton.Name = "SmartLockOn"
LockButton.Size = UDim2.fromOffset(70, 70)
LockButton.Position = UDim2.new(0, 682, 0, -10)
LockButton.BackgroundTransparency = 1
LockButton.Image = BUTTON_IMAGE_DEFAULT
LockButton.AutoButtonColor = false
LockButton.ZIndex = 10
LockButton.Parent = ScreenGui

local isLocked = false
local lockedPart = nil
local lockedHumanoid = nil
local lockedPlayer = nil
local markerGui = nil

local isHolding = false
local holdStartTime = 0
local isDragging = false
local dragStarted = false

local function isVisible(targetPart)
	if not targetPart or not targetPart.Parent then return false end
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local distance = direction.Magnitude
	if distance > MAX_LOCK_DISTANCE then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local result = Workspace:Raycast(origin, direction.Unit * distance, rayParams)
	if not result then return true end
	local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
	if hitModel and hitModel == targetPart.Parent then return true end
	return false
end

local function isValidDummy(model)
	if not model or not model:IsA("Model") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	return string.find(model.Name, "Dummy", 1, true) ~= nil
end

local function getBestTarget()
	local myChar = LocalPlayer.Character
	if not myChar then return nil, nil, nil end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil, nil, nil end

	local viewportSize = Camera.ViewportSize
	local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
	local bestPart, bestHumanoid, bestPlayer = nil, nil, nil
	local bestScore = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
				if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
					local worldDist = (root.Position - myRoot.Position).Magnitude
					if worldDist <= MAX_LOCK_DISTANCE then
						local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
						if onScreen and screenPos.Z > 0 and isVisible(root) then
							local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
							local score = screenDist + (worldDist * 0.15)
							if score < bestScore then
								bestScore = score
								bestPart = root
								bestHumanoid = humanoid
								bestPlayer = player
							end
						end
					end
				end
			end
		end
	end

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Model") and isValidDummy(descendant) then
			local humanoid = descendant:FindFirstChildOfClass("Humanoid")
			local root = descendant:FindFirstChild("HumanoidRootPart") or descendant.PrimaryPart
			if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
				local worldDist = (root.Position - myRoot.Position).Magnitude
				if worldDist <= MAX_LOCK_DISTANCE then
					local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
					if onScreen and screenPos.Z > 0 and isVisible(root) then
						local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
						local score = screenDist + (worldDist * 0.15)
						if score < bestScore then
							bestScore = score
							bestPart = root
							bestHumanoid = humanoid
							bestPlayer = nil
						end
					end
				end
			end
		end
	end

	return bestPart, bestHumanoid, bestPlayer
end

local function destroyMarker()
	if markerGui then
		markerGui:Destroy()
		markerGui = nil
	end
end

local function createMarker(adornee)
	destroyMarker()
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "LockTargetMarker"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(80, 80)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
	billboard.MaxDistance = MAX_LOCK_DISTANCE
	billboard.Parent = PlayerGui
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromScale(1, 1)
	img.Image = MARKER_IMAGE
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = billboard
	markerGui = billboard
end

local function unlock()
	isLocked = false
	lockedPart = nil
	lockedHumanoid = nil
	lockedPlayer = nil
	destroyMarker()
	Camera.CameraType = Enum.CameraType.Custom
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraSubject = hum
		end
	end
end

local function lock()
	local part, humanoid, player = getBestTarget()
	if not part or not humanoid then return end
	lockedPart = part
	lockedHumanoid = humanoid
	lockedPlayer = player
	isLocked = true
	createMarker(part)
end

local function toggleLock()
	if isLocked then
		unlock()
	else
		lock()
	end
end

LockButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	isHolding = true
	holdStartTime = tick()
	isDragging = false
	dragStarted = false
	LockButton.Image = BUTTON_IMAGE_PRESSED
end)

UserInputService.InputChanged:Connect(function(input)
	if not isHolding then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local elapsed = tick() - holdStartTime
	if elapsed >= HOLD_TO_DRAG_TIME then
		if not dragStarted then
			dragStarted = true
			isDragging = true
		end
	end
	if isDragging then
		local mousePos = UserInputService:GetMouseLocation()
		LockButton.Position = UDim2.fromOffset(mousePos.X - LockButton.AbsoluteSize.X / 2, mousePos.Y - LockButton.AbsoluteSize.Y / 2)
	end
end)

LockButton.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local elapsed = tick() - holdStartTime
	LockButton.Image = BUTTON_IMAGE_DEFAULT
	if isDragging or dragStarted then
		isHolding = false
		isDragging = false
		dragStarted = false
		return
	end
	if elapsed < HOLD_TO_DRAG_TIME then
		toggleLock()
	end
	isHolding = false
	isDragging = false
	dragStarted = false
end)

RunService.RenderStepped:Connect(function()
	if not isLocked then return end
	if not lockedPart or not lockedPart.Parent or not lockedHumanoid or lockedHumanoid.Health <= 0 then
		unlock()
		return
	end
	if lockedPlayer and not lockedPlayer.Parent then
		unlock()
		return
	end
	local myChar = LocalPlayer.Character
	if not myChar then
		unlock()
		return
	end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar:FindFirstChildOfClass("Humanoid")
	if not myRoot or not myHum or myHum.Health <= 0 then
		unlock()
		return
	end
	local dist = (lockedPart.Position - myRoot.Position).Magnitude
	if dist > MAX_LOCK_DISTANCE or not isVisible(lockedPart) then
		unlock()
		return
	end
	local lookPos = Vector3.new(lockedPart.Position.X, myRoot.Position.Y, lockedPart.Position.Z)
	myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookPos)
	Camera.CameraType = Enum.CameraType.Scriptable
	local camOffset = myRoot.CFrame:ToWorldSpace(CFrame.new(0, 5.5, 11))
	local desiredCFrame = CFrame.lookAt(camOffset.Position, lockedPart.Position)
	Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, 0.28)
	if markerGui then
		local size = math.clamp(90 - dist * 0.08, 55, 90)
		markerGui.Size = UDim2.fromOffset(size, size)
	end
end)

local function onCharacterAdded(char)
	unlock()
	local hum = char:WaitForChild("Humanoid", 8)
	if hum then
		hum.Died:Connect(function()
			unlock()
		end)
	end
end

if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Players.PlayerRemoving:Connect(function(player)
	if player == lockedPlayer then
		unlock()
	end
end)
