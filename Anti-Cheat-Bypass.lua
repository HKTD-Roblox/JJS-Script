local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OLD_NAME = "AntiCheatBypassUI"
local old = PlayerGui:FindFirstChild(OLD_NAME)
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = OLD_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 175)
Main.Position = UDim2.new(0.5, -120, 0.5, -87)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(90, 140, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 22, 45)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 14, 28)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 40))
})
MainGradient.Rotation = 45
MainGradient.Parent = Main

local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0, -20, 0, -20)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Color3.fromRGB(80, 140, 255)
Glow.ImageTransparency = 0.75
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24, 24, 276, 276)
Glow.ZIndex = 0
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 34)
Title.Position = UDim2.new(0, 0, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Anti-Cheat Bypass"
Title.TextColor3 = Color3.fromRGB(170, 210, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = Main

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 180, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 160))
})
TitleGradient.Parent = Title

local BypassBtn = Instance.new("TextButton")
BypassBtn.Name = "BypassBtn"
BypassBtn.Size = UDim2.new(0.86, 0, 0, 34)
BypassBtn.Position = UDim2.new(0.07, 0, 0, 42)
BypassBtn.BackgroundColor3 = Color3.fromRGB(35, 75, 190)
BypassBtn.Text = "BYPASS"
BypassBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassBtn.Font = Enum.Font.GothamBold
BypassBtn.TextSize = 15
BypassBtn.AutoButtonColor = false
BypassBtn.Parent = Main

local BypassCorner = Instance.new("UICorner")
BypassCorner.CornerRadius = UDim.new(0, 9)
BypassCorner.Parent = BypassBtn

local BypassStroke = Instance.new("UIStroke")
BypassStroke.Color = Color3.fromRGB(100, 180, 255)
BypassStroke.Thickness = 1.6
BypassStroke.Parent = BypassBtn

local BypassGrad = Instance.new("UIGradient")
BypassGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 110, 240)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 60, 170))
})
BypassGrad.Rotation = 90
BypassGrad.Parent = BypassBtn

local CheckBtn = Instance.new("TextButton")
CheckBtn.Name = "CheckBtn"
CheckBtn.Size = UDim2.new(0.86, 0, 0, 34)
CheckBtn.Position = UDim2.new(0.07, 0, 0, 84)
CheckBtn.BackgroundColor3 = Color3.fromRGB(150, 35, 70)
CheckBtn.Text = "CHECK"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 15
CheckBtn.AutoButtonColor = false
CheckBtn.Parent = Main

local CheckCorner = Instance.new("UICorner")
CheckCorner.CornerRadius = UDim.new(0, 9)
CheckCorner.Parent = CheckBtn

local CheckStroke = Instance.new("UIStroke")
CheckStroke.Color = Color3.fromRGB(230, 90, 130)
CheckStroke.Thickness = 1.6
CheckStroke.Parent = CheckBtn

local CheckGrad = Instance.new("UIGradient")
CheckGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 100)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 25, 55))
})
CheckGrad.Rotation = 90
CheckGrad.Parent = CheckBtn

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 128)
Status.BackgroundTransparency = 1
Status.Text = "Anti-Cheat Bypass..."
Status.TextColor3 = Color3.fromRGB(190, 200, 230)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextWrapped = true
Status.Parent = Main

local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	local delta = input.Position - dragStart
	Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			updateDrag(input)
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

local function hoverEffect(btn, stroke, enterColor, leaveColor)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = enterColor}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.18), {Thickness = 2.4}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = leaveColor}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.18), {Thickness = 1.6}):Play()
	end)
end

hoverEffect(BypassBtn, BypassStroke, Color3.fromRGB(55, 105, 230), Color3.fromRGB(35, 75, 190))
hoverEffect(CheckBtn, CheckStroke, Color3.fromRGB(185, 50, 95), Color3.fromRGB(150, 35, 70))

local function getHRP()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

local function measureDistance(targetHRP)
	local myHRP = getHRP()
	if not myHRP or not targetHRP then return math.huge end
	return (myHRP.Position - targetHRP.Position).Magnitude
end

local function teleNear(targetHRP, offset)
	offset = offset or 3
	local myHRP = getHRP()
	if not myHRP or not targetHRP then return false end
	local dir = (myHRP.Position - targetHRP.Position).Unit
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(1, 0, 0)
	end
	myHRP.CFrame = CFrame.new(targetHRP.Position + dir * offset)
	return true
end

local function findFarPlayer(minDist)
	local myHRP = getHRP()
	if not myHRP then return nil end
	local best, bestDist = nil, 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local d = (myHRP.Position - hrp.Position).Magnitude
				if d >= minDist and d > bestDist then
					best = hrp
					bestDist = d
				end
			end
		end
	end
	return best
end

local function findFarPlayerFallback()
	for _, dist in ipairs({20, 19, 18, 17, 16, 15}) do
		local target = findFarPlayer(dist)
		if target then return target, dist end
	end
	return nil, nil
end

local function fireReset()
	local ok, remote = pcall(function()
		return ReplicatedStorage
			:WaitForChild("Knit", 3)
			:WaitForChild("Knit", 3)
			:WaitForChild("Services", 3)
			:WaitForChild("JoinService", 3)
			:WaitForChild("RE", 3)
			:WaitForChild("Reset", 3)
	end)
	if ok and remote and remote:IsA("RemoteEvent") then
		remote:FireServer()
		return true
	end
	return false
end

local function waitForRespawn(timeout)
	timeout = timeout or 8
	local start = tick()
	local hum = getHumanoid()
	if hum and hum.Health > 0 then
		while hum and hum.Health > 0 and tick() - start < timeout do
			task.wait(0.1)
			hum = getHumanoid()
		end
	end
	while tick() - start < timeout do
		local char = LocalPlayer.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local h = char:FindFirstChildOfClass("Humanoid")
			if hrp and h and h.Health > 0 then
				task.wait(0.3)
				return true
			end
		end
		task.wait(0.1)
	end
	return false
end

local busy = false

BypassBtn.MouseButton1Click:Connect(function()
	if busy then return end
	busy = true
	BypassBtn.Text = "Bypassing..."
	BypassBtn.Active = false
	CheckBtn.Active = false
	Status.Text = "Teleporting..."
	Status.TextColor3 = Color3.fromRGB(200, 210, 240)

	local originalCFrame = nil
	local myHRP = getHRP()
	if myHRP then
		originalCFrame = myHRP.CFrame
	end

	local success = false
	local attempts = 0
	local maxAttempts = 6

	while attempts < maxAttempts and not success do
		attempts += 1
		Status.Text = "Teleporting... (" .. attempts .. ")"

		local target = findFarPlayerFallback()
		if not target then
			Status.Text = "Bypass failed"
			Status.TextColor3 = Color3.fromRGB(255, 90, 90)
			break
		end

		if not originalCFrame then
			myHRP = getHRP()
			if myHRP then originalCFrame = myHRP.CFrame end
		end

		teleNear(target, 3)
		task.wait(0.35)

		local dist = measureDistance(target)

		if dist < 10 then
			if originalCFrame and getHRP() then
				getHRP().CFrame = originalCFrame
			end
			Status.Text = "Bypass successful"
			Status.TextColor3 = Color3.fromRGB(80, 255, 140)
			success = true
			task.wait(5)
			break
		elseif dist > 15 then
			Status.Text = "Rubber-band detected, resetting..."
			fireReset()
			waitForRespawn(8)
			task.wait(0.5)
		else
			task.wait(0.4)
		end
	end

	if not success and Status.Text ~= "Bypass failed" then
		Status.Text = "Bypass failed"
		Status.TextColor3 = Color3.fromRGB(255, 90, 90)
	end

	BypassBtn.Text = "BYPASS"
	BypassBtn.Active = true
	CheckBtn.Active = true
	busy = false

	if success then
		task.wait(0.1)
		Status.Text = "Anti-Cheat Bypass..."
		Status.TextColor3 = Color3.fromRGB(190, 200, 230)
	else
		task.delay(3, function()
			if Status.Text == "Bypass failed" then
				Status.Text = "Anti-Cheat Bypass..."
				Status.TextColor3 = Color3.fromRGB(190, 200, 230)
			end
		end)
	end
end)

CheckBtn.MouseButton1Click:Connect(function()
	if busy then return end
	busy = true
	CheckBtn.Text = "Checking..."
	CheckBtn.Active = false
	BypassBtn.Active = false
	Status.Text = "Teleporting..."
	Status.TextColor3 = Color3.fromRGB(200, 210, 240)

	local originalCFrame = nil
	local myHRP = getHRP()
	if myHRP then
		originalCFrame = myHRP.CFrame
	end

	local target = findFarPlayerFallback()
	if not target then
		Status.Text = "Bypass Fail"
		Status.TextColor3 = Color3.fromRGB(255, 90, 90)
		CheckBtn.Text = "CHECK"
		CheckBtn.Active = true
		BypassBtn.Active = true
		busy = false
		task.delay(3, function()
			Status.Text = "Anti-Cheat Bypass..."
			Status.TextColor3 = Color3.fromRGB(190, 200, 230)
		end)
		return
	end

	teleNear(target, 3)
	task.wait(0.4)

	local dist = measureDistance(target)

	if dist < 10 then
		if originalCFrame and getHRP() then
			getHRP().CFrame = originalCFrame
		end
		Status.Text = "Bypass Success"
		Status.TextColor3 = Color3.fromRGB(80, 255, 140)
	else
		Status.Text = "Bypass Fail"
		Status.TextColor3 = Color3.fromRGB(255, 90, 90)
	end

	CheckBtn.Text = "CHECK"
	CheckBtn.Active = true
	BypassBtn.Active = true
	busy = false

	task.delay(5, function()
		if Status.Text == "Bypass Success" or Status.Text == "Bypass Fail" then
			Status.Text = "Anti-Cheat Bypass..."
			Status.TextColor3 = Color3.fromRGB(190, 200, 230)
		end
	end)
end)
