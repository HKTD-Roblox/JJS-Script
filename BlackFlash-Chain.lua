local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CFG = {
	m1Delay = 0.15,
	behindOffset = 1.5,
	bfDelay = 0.30,
	behindTimeout = 0.45,
	maxLockDist = 45,
	skill3Key = Enum.KeyCode.Three,
}

local STATE = {
	active = false,
	locked = false,
	targetRoot = nil,
	targetHum = nil,
	running = false,
}

local function sendKey(down, key)
	pcall(function() VIM:SendKeyEvent(down, key, false, game) end)
end

local function sendClick(down)
	pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, down, game, 1) end)
end

local function doM1()
	sendClick(true)
	task.wait(0.008)
	sendClick(false)
end

local function castSkill3()
	sendKey(true, CFG.skill3Key)
	task.wait(0.05)
	sendKey(false, CFG.skill3Key)
end

local function getRoot()
	local c = LP.Character
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart")
end

local function isAlive(model)
	if not model then return false end
	local h = model:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0
end

local function isInFront(myPos, myLook, targetPos)
	local to = (targetPos - myPos)
	if to.Magnitude < 0.5 then return false end
	local flatTo = Vector3.new(to.X, 0, to.Z).Unit
	local flatLook = Vector3.new(myLook.X, 0, myLook.Z).Unit
	return flatLook:Dot(flatTo) > 0.15
end

local function findFrontTarget()
	local my = getRoot()
	if not my then return nil, nil end
	local camLook = Camera.CFrame.LookVector
	local myPos = my.Position
	local bestDist, bestRoot, bestHum = CFG.maxLockDist, nil, nil

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			local h = plr.Character:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 then
				local d = (myPos - r.Position).Magnitude
				if d < bestDist and isInFront(myPos, camLook, r.Position) then
					bestDist = d
					bestRoot = r
					bestHum = h
				end
			end
		end
	end

	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj ~= LP.Character then
			local r = obj:FindFirstChild("HumanoidRootPart")
			local h = obj:FindFirstChildOfClass("Humanoid")
			if r and h and h.Health > 0 then
				local p = Players:GetPlayerFromCharacter(obj)
				if not p then
					local d = (myPos - r.Position).Magnitude
					if d < bestDist and isInFront(myPos, camLook, r.Position) then
						bestDist = d
						bestRoot = r
						bestHum = h
					end
				end
			end
		end
	end

	return bestRoot, bestHum
end

local function goBehind(targetRoot)
	local my = getRoot()
	if not my or not targetRoot then return false end
	local cf = targetRoot.CFrame * CFrame.new(0, 0, CFG.behindOffset)
	my.CFrame = CFrame.lookAt(cf.Position, targetRoot.Position)
	my.AssemblyLinearVelocity = Vector3.zero
	return true
end

local function isBehind(targetRoot)
	local my = getRoot()
	if not my or not targetRoot then return false end
	local toMe = (my.Position - targetRoot.Position)
	if toMe.Magnitude < 0.5 then return false end
	local look = targetRoot.CFrame.LookVector
	local flatToMe = Vector3.new(toMe.X, 0, toMe.Z).Unit
	local flatLook = Vector3.new(look.X, 0, look.Z).Unit
	return flatLook:Dot(flatToMe) > 0.40
end

local function faceTarget(targetRoot)
	local my = getRoot()
	if not my or not targetRoot then return end
	local look = Vector3.new(targetRoot.Position.X, my.Position.Y, targetRoot.Position.Z)
	my.CFrame = CFrame.lookAt(my.Position, look)
end

local setStatus

local function doBlackFlash(targetRoot, isFinisher)
	if not targetRoot or not targetRoot.Parent then return false end
	if not isAlive(targetRoot.Parent) then return false end

	if not isFinisher then
		local start = tick()
		while tick() - start < CFG.behindTimeout do
			if not STATE.running or not targetRoot or not targetRoot.Parent then return false end
			goBehind(targetRoot)
			if isBehind(targetRoot) then break end
			task.wait(0.025)
		end
	end

	faceTarget(targetRoot)
	castSkill3()
	task.wait(CFG.bfDelay)
	if STATE.running and targetRoot and targetRoot.Parent and isAlive(targetRoot.Parent) then
		castSkill3()
	end
	task.wait(0.12)
	return true
end

local function doM1String(targetRoot)
	for i = 1, 3 do
		if not STATE.running or not targetRoot or not targetRoot.Parent or not isAlive(targetRoot.Parent) then
			return false
		end
		faceTarget(targetRoot)
		doM1()
		task.wait(CFG.m1Delay)
	end
	return true
end

local function runChain()
	if STATE.running then return end
	STATE.running = true

	local root, hum = findFrontTarget()
	if not root or not hum then
		setStatus("Status: No Target Found")
		STATE.running = false
		STATE.locked = false
		STATE.targetRoot = nil
		STATE.targetHum = nil
		return
	end

	STATE.locked = true
	STATE.targetRoot = root
	STATE.targetHum = hum

	local function stillValid()
		return STATE.running and root and root.Parent and isAlive(root.Parent)
	end

	setStatus("Status: M1 String (1/4)")
	if not doM1String(root) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end
	setStatus("Status: Black Flash (1/4)")
	if not doBlackFlash(root, false) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end

	setStatus("Status: M1 String (2/4)")
	if not doM1String(root) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end
	setStatus("Status: Black Flash (2/4)")
	if not doBlackFlash(root, false) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end

	setStatus("Status: M1 String (3/4)")
	if not doM1String(root) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end
	setStatus("Status: Black Flash (3/4)")
	if not doBlackFlash(root, false) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end

	setStatus("Status: M1 String (4/4)")
	if not doM1String(root) or not stillValid() then
		setStatus("Status: Interrupted")
		STATE.running = false
		STATE.locked = false
		return
	end
	setStatus("Status: Finisher Black Flash")
	doBlackFlash(root, true)

	setStatus("Status: Ready for Black Flash")
	STATE.running = false
	STATE.locked = false
	STATE.targetRoot = nil
	STATE.targetHum = nil
end

local camConn
local function startCamLock()
	if camConn then camConn:Disconnect() end
	camConn = RunService.RenderStepped:Connect(function()
		if not STATE.locked or not STATE.targetRoot or not STATE.targetRoot.Parent then return end
		local targetPos = STATE.targetRoot.Position
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
	end)
end

local function stopCamLock()
	if camConn then
		camConn:Disconnect()
		camConn = nil
	end
end

local function getUIParent()
	local ok, core = pcall(function() return game:GetService("CoreGui") end)
	if ok and core then
		local t = pcall(function() return core.Name end)
		if t then return core end
	end
	return LP:WaitForChild("PlayerGui")
end

local UIParent = getUIParent()
if UIParent:FindFirstChild("BF_CHAIN_GUI") then
	UIParent:FindFirstChild("BF_CHAIN_GUI"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "BF_CHAIN_GUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = UIParent

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 130)
Main.Position = UDim2.new(0.5, -160, 0.78, 0)
Main.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = Main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 58, 68)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.25
mainStroke.Parent = Main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "JJS Yuji Combo Black Flash Chain"
title.TextColor3 = Color3.fromRGB(80, 220, 200)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = Main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = Main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -24, 0, 52)
btn.Position = UDim2.new(0, 12, 0, 40)
btn.BackgroundColor3 = Color3.fromRGB(180, 30, 40)
btn.Text = "BLACK FLASH"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 20
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Parent = Main

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = btn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 60, 70)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.35
btnStroke.Parent = btn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 1, -28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready for Black Flash"
statusLabel.TextColor3 = Color3.fromRGB(160, 165, 175)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = Main

setStatus = function(text)
	statusLabel.Text = text
end

btn.MouseButton1Click:Connect(function()
	if STATE.running then return end
	btn.Text = "RUNNING..."
	btn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
	startCamLock()
	task.spawn(function()
		runChain()
		stopCamLock()
		btn.Text = "BLACK FLASH"
		btn.BackgroundColor3 = Color3.fromRGB(180, 30, 40)
		if statusLabel.Text ~= "Status: Ready for Black Flash"
			and not statusLabel.Text:find("Interrupted")
			and not statusLabel.Text:find("No Target") then
			setStatus("Status: Ready for Black Flash")
		end
	end)
end)

closeBtn.MouseButton1Click:Connect(function()
	STATE.running = false
	STATE.locked = false
	stopCamLock()
	SG:Destroy()
end)

UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.V then
		if not STATE.running then
			btn.MouseButton1Click:Fire()
		end
	end
end)

LP.CharacterAdded:Connect(function()
	STATE.running = false
	STATE.locked = false
	STATE.targetRoot = nil
	STATE.targetHum = nil
	stopCamLock()
	setStatus("Status: Ready for Black Flash")
end)
