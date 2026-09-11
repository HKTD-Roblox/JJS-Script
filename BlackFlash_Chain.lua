local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

	if not doM1String(root) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end
	if not doBlackFlash(root, false) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end

	if not doM1String(root) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end
	if not doBlackFlash(root, false) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end

	if not doM1String(root) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end
	if not doBlackFlash(root, false) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end

	if not doM1String(root) or not stillValid() then
		STATE.running = false
		STATE.locked = false
		return
	end
	doBlackFlash(root, true)

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
		local my = getRoot()
		if not my then return end
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
Main.Size = UDim2.new(0, 130, 0, 42)
Main.Position = UDim2.new(0.5, -65, 0.85, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(220, 60, 60)
stroke.Thickness = 1.2
stroke.Transparency = 0.3
stroke.Parent = Main

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -8, 1, -8)
btn.Position = UDim2.new(0, 4, 0, 4)
btn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
btn.Text = "BF CHAIN"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 13
btn.Font = Enum.Font.GothamBold
btn.BorderSizePixel = 0
btn.Parent = Main

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn

btn.MouseButton1Click:Connect(function()
	if STATE.running then return end
	btn.Text = "..."
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	startCamLock()
	task.spawn(function()
		runChain()
		stopCamLock()
		btn.Text = "BF CHAIN"
		btn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	end)
end)

LP.CharacterAdded:Connect(function()
	STATE.running = false
	STATE.locked = false
	STATE.targetRoot = nil
	STATE.targetHum = nil
	stopCamLock()
end)
