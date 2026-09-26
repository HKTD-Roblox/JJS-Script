-- credits --
local Credits= loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Credits2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceCredits = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


Fluent:Notify({
    Title = "A-TRAIN MOVESET",
    Content = "The script has been loaded!",
    Duration = 5
})

Fluent:Notify({
    Title = "By Zorcex",
    Content = "Don't forget to follow us for more!",
    Duration = 4
})

-- Super Run 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===================== إنشاء الـ GUI =====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiStunGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local button = Instance.new("ImageButton")
button.Name = "AntiStunButton"
button.Parent = screenGui
button.Size = UDim2.new(0, 70, 0, 70)
button.Position = UDim2.new(0, 682, 0, -10)
button.BackgroundTransparency = 1
button.Image = "rbxassetid://6256840888"

local imageLabel = Instance.new("ImageLabel")
imageLabel.Name = "IconLabel"
imageLabel.Parent = button
imageLabel.BackgroundTransparency = 1
imageLabel.Size = UDim2.new(0, 45, 0, 45)
imageLabel.Position = UDim2.new(0, 15, 0, 10)
imageLabel.Image = "rbxassetid://92553230892068"
imageLabel.ImageTransparency = 0.2

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

-- ===================== Sound =====================

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://117957946745116"
sound.Volume = 1
sound.Parent = SoundService

-- ===================== متغيرات =====================

local isActive = false
local flingActive = false
local mainLoop = nil
local runTrack = nil
local offTrack = nil
local characterAddedConn = nil

local NORMAL_SPEED = 90
local ANIM_START = 0
local ANIM_END = 0.7
local RUN_ANIM_ID = "rbxassetid://77992084875736"
local OFF_ANIM_ID = "rbxassetid://119635500264882"
local OFF_ANIM_TIME = 0.2

local vfxAttachment = nil
local vfxParticles = {}

-- ===================== Blur / FOV =====================

local blur = Lighting:FindFirstChild("SpeedBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "SpeedBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

local function getCamera()
	return workspace.CurrentCamera
end

local function playBlurEffect()
	local blurIn = TweenService:Create(
		blur,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = 24 }
	)
	local blurOut = TweenService:Create(
		blur,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = 0 }
	)
	blurIn:Play()
	blurIn.Completed:Once(function()
		blurOut:Play()
	end)
end

local function playFovEffect()
	local camera = getCamera()
	if not camera then return end
	local originalFov = camera.FieldOfView
	local fovIn = TweenService:Create(
		camera,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = 80 }
	)
	local fovOut = TweenService:Create(
		camera,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ FieldOfView = originalFov }
	)
	fovIn:Play()
	fovIn.Completed:Once(function()
		fovOut:Play()
	end)
end

-- ===================== VFX =====================

local function setupVFX(char)
	local hrp = char:WaitForChild("HumanoidRootPart")
	if vfxAttachment then
		vfxAttachment:Destroy()
		vfxAttachment = nil
		vfxParticles = {}
	end
	local success, err = pcall(function()
		local source = ReplicatedStorage.Utils.Mechamaru.Offload.SmoothLanding1.ArriveSmokeEnable.Strike.Attachment
		local clone = source:Clone()
		clone.Parent = hrp
		vfxAttachment = clone
		for _, child in ipairs(clone:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				child.Enabled = true
				table.insert(vfxParticles, child)
			end
		end
	end)
	if not success then
		warn("VFX Error: " .. tostring(err))
	end
end

local function setVFX(enabled)
	for _, particle in ipairs(vfxParticles) do
		if particle and particle.Parent then
			particle.Enabled = enabled
		end
	end
end

-- ===================== Fling =====================

local function startFling()
	flingActive = true
	local movel = 0.1
	while flingActive do
		RunService.Heartbeat:Wait()
		local c = player.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then
			local vel = hrp.Velocity
			hrp.Velocity = vel * 30 + Vector3.new(0, 30, 0)
			RunService.RenderStepped:Wait()
			hrp.Velocity = vel
			RunService.Stepped:Wait()
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

-- ===================== Off Animation =====================

local function playOffAnimation(char)
	local humanoid = char and char:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	if not animator then return end

	if offTrack then
		offTrack:Stop()
		offTrack = nil
	end

	local animObj = Instance.new("Animation")
	animObj.AnimationId = OFF_ANIM_ID
	offTrack = animator:LoadAnimation(animObj)
	offTrack.Priority = Enum.AnimationPriority.Action4
	offTrack.Looped = false
	offTrack:Play(0.1, 1, 1)
	offTrack.TimePosition = OFF_ANIM_TIME
end

-- ===================== اللووب الرئيسي الموحد =====================

local function startMainLoop(char)
	local humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	if mainLoop then
		mainLoop:Disconnect()
		mainLoop = nil
	end
	if runTrack then
		runTrack:Stop()
		runTrack = nil
	end
	local animObj = Instance.new("Animation")
	animObj.AnimationId = RUN_ANIM_ID
	runTrack = animator:LoadAnimation(animObj)
	runTrack.Priority = Enum.AnimationPriority.Action4
	runTrack.Looped = true
	setupVFX(char)
	runTrack:Play(0.1, 1, 1)
	setVFX(true)
	mainLoop = RunService.RenderStepped:Connect(function()
		if not isActive then return end
		local cam = getCamera()
		if cam then
			local camLook = cam.CFrame.LookVector
			local forwardDir = Vector3.new(camLook.X, 0, camLook.Z)
			if forwardDir.Magnitude > 0 then
				forwardDir = forwardDir.Unit
				humanoid:Move(forwardDir, false)
			end
		end
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do
			if track ~= runTrack then
				track:Stop(0)
			end
		end
		if not runTrack.IsPlaying then
			runTrack:Play(0.1, 1, 1)
		end
		runTrack:AdjustSpeed(1)
		if runTrack.TimePosition >= ANIM_END then
			runTrack.TimePosition = ANIM_START
		end
		setVFX(true)
		if humanoid.WalkSpeed < NORMAL_SPEED then
			humanoid.WalkSpeed = NORMAL_SPEED
		end
		if humanoid.PlatformStand == true then
			humanoid.PlatformStand = false
		end
		if humanoid.Sit == true then
			humanoid.Sit = false
		end
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BoolValue") and string.lower(v.Name):find("stun") then
				v.Value = false
			end
		end
		for _, attr in pairs(char:GetAttributes()) do
			if tostring(attr):lower():find("stun") then
				char:SetAttribute(attr, false)
			end
		end
	end)
end

-- ===================== دالة التفعيل الموحدة =====================

local function activate()
	isActive = not isActive

	if isActive then
		sound:Play()
		playBlurEffect()
		playFovEffect()
		flingActive = true
		coroutine.wrap(startFling)()
		if player.Character then
			startMainLoop(player.Character)
		end
		if characterAddedConn then
			characterAddedConn:Disconnect()
			characterAddedConn = nil
		end
		characterAddedConn = player.CharacterAdded:Connect(function(char)
			if isActive then
				startMainLoop(char)
			end
		end)
	else
		sound:Stop()
		button.ImageColor3 = Color3.fromRGB(255, 255, 255)
		imageLabel.ImageTransparency = 0.2
		flingActive = false
		setVFX(false)
		if mainLoop then
			mainLoop:Disconnect()
			mainLoop = nil
		end
		if runTrack and runTrack.IsPlaying then
			runTrack:Stop()
			runTrack = nil
		end
		if characterAddedConn then
			characterAddedConn:Disconnect()
			characterAddedConn = nil
		end
		if player.Character then
			playOffAnimation(player.Character)
		end
	end
end

-- ===================== زر التفعيل / الإيقاف =====================

button.MouseButton1Click:Connect(function()
	activate()
end)

-- ===================== زر R للكيبورد =====================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		activate()
	end
end)

-- ===================== حذف الـ GUI عند الموت =====================

player.CharacterRemoving:Connect(function()
	isActive = false
	flingActive = false
	setVFX(false)
	if mainLoop then
		mainLoop:Disconnect()
		mainLoop = nil
	end
	if runTrack then
		runTrack:Stop()
		runTrack = nil
	end
	if offTrack then
		offTrack:Stop()
		offTrack = nil
	end
	if characterAddedConn then
		characterAddedConn:Disconnect()
		characterAddedConn = nil
	end
	task.wait(0.1)
	if screenGui and screenGui.Parent then
		screenGui:Destroy()
	end
end)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://140054008594529" -- حط الـ ID هنا
sound.Volume = 1
sound.Parent = workspace

task.wait()

sound:Play()

sound.Ended:Connect(function()
	sound:Destroy()
end)

--Anitmation execute

local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://119635500264882"

local Humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local Track = Humanoid:LoadAnimation(Animation)

task.wait()

Track:Play()

-- Ilde animation --

pcall(function() 
    getgenv().Idle:Disconnect() 
end)

getgenv().Idle = game.Players.LocalPlayer.Character.Humanoid.AnimationPlayed:Connect(function(v)

    local original1 = "rbxassetid://120133391090244"
    local original2 = "rbxassetid://138196552148011"

    if v.Animation.AnimationId == original1 or v.Animation.AnimationId == original2 then

        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://93874873522369"

        local humanoid = game.Players.LocalPlayer.Character.Humanoid
        local k = humanoid:LoadAnimation(Anim)

        k.Priority = Enum.AnimationPriority.Idle
        k.Looped = true
        k:Play(0.3)
        k:AdjustSpeed(0)

        local startTime = 7.5
        local endTime = 7.6
        local cycleDuration = 1.5
        local timeElapsed = 0

        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            timeElapsed = (timeElapsed + deltaTime) % (cycleDuration * 2)

            local alpha = (math.sin((timeElapsed / cycleDuration) * math.pi - math.pi / 2) + 1) / 2
            k.TimePosition = startTime + (endTime - startTime) * alpha
        end)

        v.Stopped:Wait()
        k:Stop(0.3)
        connection:Disconnect()
    end
end)


local skillOne = game.Players.LocalPlayer.PlayerGui.Main.Controls.Moveset['Cursed Strikes'].ItemName
local skillTwo = game.Players.LocalPlayer.PlayerGui.Main.Controls.Moveset['Crushing Blow'].ItemName
local skillThree = game.Players.LocalPlayer.PlayerGui.Main.Controls.Moveset['Divergent Fist'].ItemName
local skillThreeToolTip = game.Players.LocalPlayer.PlayerGui.Main.Controls.Moveset['Divergent Fist'].Tip
local skillFour = game.Players.LocalPlayer.PlayerGui.Main.Controls.Moveset['Manji Kick'].ItemName
local ultTitle = game.Players.LocalPlayer.PlayerGui.Main.Controls.Ultimate.Title


game.Players.LocalPlayer.PlayerGui.Main.Controls.Ultimate.Bar.Fill.BackgroundColor3 = Color3.fromRGB(0, 117, 176)

game.Players.LocalPlayer.PlayerGui.Main.Controls.Ultimate.Special.Fill.BackgroundColor3 = Color3.fromRGB(0, 117, 176)


--Skill names
skillOne.Text = "Dash Crusher"
skillTwo.Text = "Destruction Blow"
skillThree.Text = "Train strike"
skillThreeToolTip.Text = "Death Step"
skillFour.Text = "Too Slow!"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


-- Skill 1
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local cursedStrikeANIM = "rbxassetid://77200218033775"
local roughEnergyANIM  = "rbxassetid://135411487367370"
local vesselMelee1     = "rbxassetid://129678103897608"
local vesselMelee2     = "rbxassetid://132704398648016"

local ATTACK_RANGE   = 120
local MELEE_DISTANCE = 40
local FLY_SPEED      = 120
local FLY_DURATION   = 1.5

local isDead = false
local isAnimationSequenceActive = false
local animationTriggered = false

local cachedTracks = nil
local flyConnection = nil
local trackedHumanoids = {}

local roughEnergyCooldown = false
local roughEnergyToken = 0

local function getAnimationTracks()
	if cachedTracks then return cachedTracks end
	local char = player.Character
	if not char then return nil end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return nil end
	local function makeTrack(id)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		return animator:LoadAnimation(anim)
	end
	cachedTracks = {
		animator = animator,
		roughEnergy = makeTrack(roughEnergyANIM),
		melee1 = makeTrack(vesselMelee1),
		melee2 = makeTrack(vesselMelee2),
	}
	return cachedTracks
end

local function stopRoughEnergyInstant()
	local tracks = getAnimationTracks()
	if not tracks then return end
	if tracks.roughEnergy and tracks.roughEnergy.IsPlaying then
		tracks.roughEnergy:Stop(0)
	end
end

local function flyForward()
	if isDead then return end
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	local elapsed = 0
	flyConnection = RunService.Heartbeat:Connect(function(dt)
		if isDead then
			flyConnection:Disconnect()
			flyConnection = nil
			return
		end
		elapsed += dt
		if elapsed >= FLY_DURATION then
			flyConnection:Disconnect()
			flyConnection = nil
			return
		end
		local char2 = player.Character
		if not char2 then
			flyConnection:Disconnect()
			flyConnection = nil
			return
		end
		local root2 = char2:FindFirstChild("HumanoidRootPart")
		if not root2 then
			flyConnection:Disconnect()
			flyConnection = nil
			return
		end
		local forward = root2.CFrame.LookVector
		root2.CFrame = root2.CFrame + Vector3.new(
			forward.X * FLY_SPEED * dt,
			0,
			forward.Z * FLY_SPEED * dt
		)
	end)
end

local function onAnimationPlayed(animationTrack)
	if isDead then return end
	local anim = animationTrack.Animation
	if not anim then return end
	if anim.AnimationId == cursedStrikeANIM then
		animationTriggered = true
		task.delay(2, function()
			animationTriggered = false
		end)
		animationTrack:Stop(0)
		local tracks = getAnimationTracks()
		if not tracks then return end
		if roughEnergyCooldown then return end
		roughEnergyCooldown = true
		roughEnergyToken += 1
		local myToken = roughEnergyToken
		tracks.roughEnergy:Stop(0)
		tracks.roughEnergy.TimePosition = 0
		tracks.roughEnergy:Play()
		task.spawn(function()
			task.wait(0.5)
			if isDead then return end
			if myToken ~= roughEnergyToken then return end
			if tracks.roughEnergy and tracks.roughEnergy.IsPlaying then
				tracks.roughEnergy:Stop(0.4)
			end
			task.wait(2)
			if myToken == roughEnergyToken then
				roughEnergyCooldown = false
			end
		end)
	end
end

local function playMeleeSequence(dist)
	if isDead then return end
	if isAnimationSequenceActive then return end
	if not animationTriggered then return end
	isAnimationSequenceActive = true
	local tracks = getAnimationTracks()
	if not tracks then
		isAnimationSequenceActive = false
		return
	end
	local isClose = dist <= MELEE_DISTANCE
	stopRoughEnergyInstant()
	flyForward()
	task.spawn(function()
		if isClose and not isDead then
			tracks.melee1:Play()
			task.wait(1.2)
			if isDead then return end
			tracks.melee1:Stop(0.5)
			task.wait(0.1)
			if isDead then return end
			tracks.melee2:Play()
			tracks.melee2.TimePosition = 3.2
			task.wait(1.5)
			if isDead then return end
			tracks.melee2:Stop(0.5)
		end
		isAnimationSequenceActive = false
	end)
end

local function trackHumanoid(humanoid)
	if isDead then return end
	if trackedHumanoids[humanoid] then return end
	if humanoid.Parent == player.Character then return end
	trackedHumanoids[humanoid] = true
	local lastHealth = humanoid.Health
	humanoid.HealthChanged:Connect(function(newHealth)
		if isDead then return end
		if newHealth >= lastHealth then
			lastHealth = newHealth
			return
		end
		local char = player.Character
		if not char then
			lastHealth = newHealth
			return
		end
		local myRoot = char:FindFirstChild("HumanoidRootPart")
		local enemyRoot = humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
		if myRoot and enemyRoot then
			local dist = (myRoot.Position - enemyRoot.Position).Magnitude
			if dist <= ATTACK_RANGE then
				playMeleeSequence(dist)
			end
		end
		lastHealth = newHealth
	end)
	humanoid.Died:Connect(function()
		trackedHumanoids[humanoid] = nil
	end)
end

workspace.DescendantAdded:Connect(function(obj)
	if isDead then return end
	if obj:IsA("Humanoid") then
		trackHumanoid(obj)
	end
end)

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Humanoid") then
		trackHumanoid(obj)
	end
end

local function setupCharacter(char)
	character = char
	cachedTracks = nil
	isAnimationSequenceActive = false
	animationTriggered = false
	roughEnergyCooldown = false
	roughEnergyToken += 1
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.AnimationPlayed:Connect(onAnimationPlayed)
end

setupCharacter(character)
player.CharacterAdded:Connect(setupCharacter)

--------------------------------------------------
-- إيقاف كل شيء عند الموت
--------------------------------------------------
player.CharacterRemoving:Connect(function()
	isDead = true

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if cachedTracks then
		if cachedTracks.roughEnergy and cachedTracks.roughEnergy.IsPlaying then
			cachedTracks.roughEnergy:Stop(0)
		end
		if cachedTracks.melee1 and cachedTracks.melee1.IsPlaying then
			cachedTracks.melee1:Stop(0)
		end
		if cachedTracks.melee2 and cachedTracks.melee2.IsPlaying then
			cachedTracks.melee2:Stop(0)
		end
		cachedTracks = nil
	end

	isAnimationSequenceActive = false
	animationTriggered = false
	roughEnergyCooldown = false
	roughEnergyToken += 1
	trackedHumanoids = {}
end)


-- Skill 2 --
local Players = game:GetService("Players")  
local ReplicatedStorage = game:GetService("ReplicatedStorage")  
  
local LocalPlayer = Players.LocalPlayer  
  
-- Animation references  
local cursedStrikeANIM = "rbxassetid://124901309160375"
local roughEnergyANIM  = "rbxassetid://74074876224161"
local luckyVolleyANIM  = "rbxassetid://113722638806911"

local PLAY_DURATION = 1.2  
local DAMAGE_DISTANCE = 20  
  
local isAnimationSequenceActive = false  
local didDealDamage = false  
  
--------------------------------------------------  
-- 🔥 تتبع الدامج
--------------------------------------------------  
local trackedHumanoids = {}  
  
local function trackHumanoid(humanoid)  
    if trackedHumanoids[humanoid] then return end  
    trackedHumanoids[humanoid] = true  
  
    local lastHealth = humanoid.Health  
  
    humanoid.HealthChanged:Connect(function(newHealth)  
        local character = LocalPlayer.Character  
        if not character then return end  
  
        local myRoot = character:FindFirstChild("HumanoidRootPart")  
        local enemyRoot = humanoid.Parent:FindFirstChild("HumanoidRootPart")  
  
        if not myRoot or not enemyRoot then return end  
  
        local dist = (myRoot.Position - enemyRoot.Position).Magnitude  
  
        if newHealth < lastHealth and dist <= DAMAGE_DISTANCE then  
            didDealDamage = true  
  
            task.delay(1, function()  
                didDealDamage = false  
            end)  
        end  
  
        lastHealth = newHealth  
    end)  
end  
  
local function scanAllHumanoids()  
    while true do  
        task.wait(1)  
        for _, obj in pairs(workspace:GetDescendants()) do  
            if obj:IsA("Humanoid") then  
                trackHumanoid(obj)  
            end  
        end  
    end  
end  
  
task.spawn(scanAllHumanoids)  
  
--------------------------------------------------  
-- 🎬 تشغيل الأنيميشن
--------------------------------------------------  
local function playAnimationSequence(player)  
    if isAnimationSequenceActive then return end  
    isAnimationSequenceActive = true  
  
    local character = player.Character  
    if not character then
        isAnimationSequenceActive = false
        return
    end  
  
    local humanoid = character:FindFirstChildOfClass("Humanoid")  
    if not humanoid then
        isAnimationSequenceActive = false
        return
    end

    -- ✅ استخدام Animator بدل LoadAnimation مباشرة
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        isAnimationSequenceActive = false
        return
    end
  
    local animRoughEnergy = Instance.new("Animation")
    animRoughEnergy.AnimationId = roughEnergyANIM

    local animLuckyVolley = Instance.new("Animation")
    animLuckyVolley.AnimationId = luckyVolleyANIM
  
    local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)
    local trackLuckyVolley = animator:LoadAnimation(animLuckyVolley)
  
    -- إيقاف كل الأنيميشنات الحالية
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do  
        track:Stop()  
    end  
  
    task.spawn(function()  
        -- الأنيميشن الأول
        trackRoughEnergy:Play()  
        trackRoughEnergy.TimePosition = 3.92  
        task.wait(0.65)  
        trackRoughEnergy:Stop(0.5)  
  
        -- الأنيميشن الثاني (فقط إذا ضرب)
        if didDealDamage then  
            trackLuckyVolley:Play()  
            trackLuckyVolley.TimePosition = 0  
            task.wait(0.5)  
            trackLuckyVolley:Stop(0.5)  
        end  
  
        task.wait(PLAY_DURATION)  
        isAnimationSequenceActive = false  

        trackRoughEnergy:Stop()
        trackLuckyVolley:Stop()
    end)  
end  
  
--------------------------------------------------  
-- 🎯 التفعيل
--------------------------------------------------  
local function onAnimationPlayed(animationTrack)  
    if animationTrack.Animation.AnimationId == cursedStrikeANIM then  
        playAnimationSequence(LocalPlayer)  
    end  
end  
  
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
local humanoid = character:WaitForChild("Humanoid")  

humanoid.AnimationPlayed:Connect(onAnimationPlayed)

-- Skill 3 (نسخة مصلحة)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Animation references
local cursedStrikeANIM = "rbxassetid://100962226150441"
local roughEnergyANIM  = "rbxassetid://72932825817330"

local PLAY_DURATION = 1.2
local isAnimationSequenceActive = false

--------------------------------------------------
-- 🎬 الأنيميشن
--------------------------------------------------
local function playAnimationSequence(player)
    if isAnimationSequenceActive then return end
    isAnimationSequenceActive = true

    local character = player.Character
    if not character then isAnimationSequenceActive = false return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then isAnimationSequenceActive = false return end

    -- ✅ Animator بدل LoadAnimation مباشرة
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then isAnimationSequenceActive = false return end

    local animRoughEnergy = Instance.new("Animation")
    animRoughEnergy.AnimationId = roughEnergyANIM

    -- ✅ تحميل عبر Animator
    local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)

    -- إيقاف أي أنيميشن شغال
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    task.spawn(function()
        task.wait()
        trackRoughEnergy:Play(0.2)
        -- ✅ TimePosition رقم مش string
        trackRoughEnergy.TimePosition = 1.7
        task.wait(1)
        trackRoughEnergy:Stop(0.4)

        task.wait(PLAY_DURATION)
        isAnimationSequenceActive = false
        trackRoughEnergy:Stop()
    end)
end

--------------------------------------------------
-- 🎯 التفعيل
--------------------------------------------------
local function onAnimationPlayed(animationTrack)
    -- ✅ مقارنة string مع string
    if animationTrack.Animation.AnimationId == cursedStrikeANIM then
        playAnimationSequence(LocalPlayer)
    end
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
humanoid.AnimationPlayed:Connect(onAnimationPlayed)


--  Dash

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Animation references
local cursedStrikeANIM = "rbxassetid://110978068388232"
local roughEnergyANIM  = "rbxassetid://105571879949076"

local PLAY_DURATION = 1.2
local isAnimationSequenceActive = false

--------------------------------------------------
-- 🎬 الأنيميشن
--------------------------------------------------
local function playAnimationSequence(player)
    if isAnimationSequenceActive then return end
    isAnimationSequenceActive = true

    local character = player.Character
    if not character then isAnimationSequenceActive = false return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then isAnimationSequenceActive = false return end

    -- ✅ Animator بدل LoadAnimation مباشرة
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then isAnimationSequenceActive = false return end

    local animRoughEnergy = Instance.new("Animation")
    animRoughEnergy.AnimationId = roughEnergyANIM

    -- ✅ تحميل عبر Animator
    local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)

    -- إيقاف أي أنيميشن شغال
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    task.spawn(function()
        task.wait()
        trackRoughEnergy:Play(0.2)
        -- ✅ TimePosition رقم مش string
        trackRoughEnergy.TimePosition = 0.7
        task.wait(2)
        trackRoughEnergy:Stop(0.4)

        task.wait(PLAY_DURATION)
        isAnimationSequenceActive = false
        trackRoughEnergy:Stop()
    end)
end

--------------------------------------------------
-- 🎯 التفعيل
--------------------------------------------------
local function onAnimationPlayed(animationTrack)
    -- ✅ مقارنة string مع string
    if animationTrack.Animation.AnimationId == cursedStrikeANIM then
        playAnimationSequence(LocalPlayer)
    end
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
humanoid.AnimationPlayed:Connect(onAnimationPlayed)


-- // Animation Replacer Script
-- // Services
local Players = game:GetService("Players")

-- // Player Setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- // Animation Config: [OriginalID] = { replacement, speed, timePosition, fadeTime }
local animationConfig = {
    ["95295463826732"] = { id = "rbxassetid://111083699259354", speed = 1,   timePos = 0,   fade = 0.1 }, -- punch1
    ["105077924973072"] = { id = "rbxassetid://117831239064143", speed = 1,   timePos = 0,   fade = 0.1 }, -- punch2
    ["92966188946988"] = { id = "rbxassetid://95002584969527", speed = 1,   timePos = 0,   fade = 0.1 }, -- downslam 
    ["134243365075812"] = { id = "rbxassetid://88849926869776", speed = 1,   timePos = 0,   fade = 0.1 }, -- up
}

-- // IDs to intercept (auto-built from config)
local animationsToBlock = {}
for id in pairs(animationConfig) do
    animationsToBlock[tonumber(id)] = true
end

-- // Queue system
local queue = {}
local isAnimating = false

-- // Play replacement animation with full controls
local function playReplacement(animationId)
    if isAnimating then
        table.insert(queue, animationId)
        return
    end

    local config = animationConfig[tostring(animationId)]
    if not config then return end

    isAnimating = true

    local anim = Instance.new("Animation")
    anim.AnimationId = config.id

    local track = humanoid:LoadAnimation(anim)
    track:Play(config.fade)          -- Speed
    track.TimePosition = config.timePos      -- Time Position

    -- End / Stop handler
    track.Stopped:Connect(function()
        isAnimating = false
        if #queue > 0 then
            playReplacement(table.remove(queue, 1))
        end
    end)
end

-- // Stop all blocked animations currently playing
local function stopBlockedAnimations()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = tonumber(track.Animation.AnimationId:match("%d+"))
        if animationsToBlock[id] then
            track:Stop()
        end
    end
end

-- // On animation played hook
local function onAnimationPlayed(track)
    local id = tonumber(track.Animation.AnimationId:match("%d+"))
    if animationsToBlock[id] then
        stopBlockedAnimations()
        track:Stop()
        playReplacement(id)
    end
end

humanoid.AnimationPlayed:Connect(onAnimationPlayed)

-- // Block upward BodyVelocity (anti-launch)
local function clampBodyVelocity(obj)
    if obj:IsA("BodyVelocity") then
        obj.Velocity = Vector3.new(obj.Velocity.X, 0, obj.Velocity.Z)
    end
end

character.DescendantAdded:Connect(clampBodyVelocity)
for _, obj in ipairs(character:GetDescendants()) do
    clampBodyVelocity(obj)
end

-- Melee --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Animation references
local cursedStrikeANIM = "rbxassetid://81630213087988"
local roughEnergyANIM  = "rbxassetid://131917532383382"

local PLAY_DURATION = 1.2
local isAnimationSequenceActive = false

--------------------------------------------------
-- 🎬 الأنيميشن
--------------------------------------------------
local function playAnimationSequence(player)
    if isAnimationSequenceActive then return end
    isAnimationSequenceActive = true

    local character = player.Character
    if not character then isAnimationSequenceActive = false return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then isAnimationSequenceActive = false return end

    -- ✅ Animator بدل LoadAnimation مباشرة
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then isAnimationSequenceActive = false return end

    local animRoughEnergy = Instance.new("Animation")
    animRoughEnergy.AnimationId = roughEnergyANIM

    -- ✅ تحميل عبر Animator
    local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)

    -- إيقاف أي أنيميشن شغال
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    task.spawn(function()
        task.wait()
        trackRoughEnergy:Play(0.2)
        -- ✅ TimePosition رقم مش string
        trackRoughEnergy.TimePosition = 0.2
        task.wait(0.4)
        trackRoughEnergy:Stop(0.5)

        task.wait(PLAY_DURATION)
        isAnimationSequenceActive = false
        trackRoughEnergy:Stop()
    end)
end

--------------------------------------------------
-- 🎯 التفعيل
--------------------------------------------------
local function onAnimationPlayed(animationTrack)
    -- ✅ مقارنة string مع string
    if animationTrack.Animation.AnimationId == cursedStrikeANIM then
        playAnimationSequence(LocalPlayer)
    end
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
humanoid.AnimationPlayed:Connect(onAnimationPlayed)


ultTitle.Font = Enum.Font.Fantasy

local texts = {
	"The fastest man alive",
	"A-TRAIN"
}

local index = 1

local function fadeText(newText)
	-- Fade Out
	for i = 0, 1, 0.05 do
		ultTitle.TextTransparency = i
		task.wait(0.03)
	end


	ultTitle.Text = newText

	-- Fade In
	for i = 1, 0, -0.05 do
		ultTitle.TextTransparency = i
		task.wait(0.03)
	end
end

-- أول ظهور
ultTitle.Text = texts[1]
ultTitle.TextTransparency = 1

for i = 1, 0, -0.05 do
	ultTitle.TextTransparency = i
	task.wait(0.03)
end

-- Loop
while true do
	task.wait(15)
	index = (index % #texts) + 1
	fadeText(texts[index])
end
