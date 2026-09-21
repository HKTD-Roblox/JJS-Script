local SRC_MOBILE_FLY = [=[
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character  = player.Character or player.CharacterAdded:Wait()
local humanoid   = character:WaitForChild("Humanoid")
local rootPart   = character:WaitForChild("HumanoidRootPart")
local drAnimator = humanoid:WaitForChild("Animator")

local cleanedUp = false
local function forceCleanup()
    if cleanedUp then return end
    cleanedUp = true

    
    pcall(function()
        if _G.__FlySystemCleanup then _G.__FlySystemCleanup() end
    end)

    
    
    pcall(function()
        local flyGui = player.PlayerGui:FindFirstChild("FlyGui")
        if flyGui then flyGui:Destroy() end
    end)
    pcall(function()
        for _, ch in ipairs(player.PlayerGui:GetDescendants()) do
            if ch.Name == "destructive rush" then ch:Destroy() end
        end
    end)
    pcall(function() if camera then camera.FieldOfView = 70 end end)

    
    script:Destroy()
end

humanoid.Died:Connect(forceCleanup)
player.CharacterRemoving:Connect(function(char)
    if char == character then forceCleanup() end
end)

task.spawn(function()
    local targetGui = player.PlayerGui:WaitForChild("110978068388232", 5)
    if targetGui then targetGui.Visible = false end
end)

local gui = Instance.new("ScreenGui")
gui.Name         = "FlyGui"
gui.ResetOnSpawn = false
gui.Parent       = player:WaitForChild("PlayerGui")

local flyBtn = Instance.new("ImageButton")
flyBtn.Name                   = "FlyButton"
flyBtn.Parent                 = gui
flyBtn.Size                   = UDim2.new(0, 70, 0, 70)
flyBtn.Position               = UDim2.new(0, 682, 0, -10)
flyBtn.BackgroundTransparency = 1
flyBtn.Image                  = "rbxassetid://6256840888"

local flyIcon = Instance.new("ImageLabel")
flyIcon.Parent                 = flyBtn
flyIcon.BackgroundTransparency = 1
flyIcon.Size                   = UDim2.new(0, 76, 0, 76)
flyIcon.Position               = UDim2.new(0, -2, 0, -4)
flyIcon.Image                  = "rbxassetid://97537169093698"

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(1, 0)
flyCorner.Parent       = flyBtn

local CFG = {
    NORMAL_SPEED = 30,
    BOOST_SPEED  = 90,
    HOVER_AMP    = 0.5,
    HOVER_FREQ   = 0.5,
    HOVER_SPRING = 14,
    IDLE_FREEZE_TIME = 0.75, 
}

local ANIM = {
    IDLE     = "rbxassetid://99249148382757",
    FORWARD  = "rbxassetid://9443519528",
    BACKWARD = "rbxassetid://134581973800784",
    BOOST    = "rbxassetid://128524425761051",
    LAND     = "rbxassetid://78540995456941",
}

local DR_STARTUP = "rbxassetid://139078698020363"
local DR_RISE    = "rbxassetid://136676738644802"
local DR_FLOAT   = "rbxassetid://131522534497146"

local RISE_HEIGHT = 120
local RISE_SPEED  = 1
local FLOAT_TIME  = 15
local BLEND       = 0.15
local COOLDOWN    = 5

local isDeadCleanup    = false
local flying           = false
local floatMode        = false
local verticalInput    = 0
local currentAnimState = ""

local bodyGyro, bodyVelocity      = nil, nil
local flyConn, animConn, landConn = nil, nil, nil
local landVfxConn                 = nil

local idleTrack, forwardTrack, backwardTrack
local boostTrack, landTrack, floatAnimTrack

local hoverBobT   = 0
local baseHoverY  = 0
local wasIdle     = false
local idleAnimT   = 0
local boostFrozen = false

local boostActive      = false
_G.BoostActive      = false
local boostVfxClone    = nil
local currentFadeTween = nil

local lastWTapTime    = 0
local DOUBLE_TAP_TIME = 0.3 

local prevCameraAngleY = 0   
local tiltSmoothed     = 0   
local TILT_SENSITIVITY = 2.5 

local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))

local cursedStrikeANIM = ReplicatedStorage.Animations.Todo.BruteForce
local roughEnergyANIM  = ReplicatedStorage.Animations.Megumi.Mahoraga.WorldSlash
local isAnimSeqActive  = false

local function playAnimOverride(p)
    if isAnimSeqActive then return end
    isAnimSeqActive = true
    local char = p.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = roughEnergyANIM.AnimationId
    local track = hum:LoadAnimation(anim)
    
    for _, t in pairs(hum:GetPlayingAnimationTracks()) do
        if t ~= idleTrack and t ~= forwardTrack and t ~= backwardTrack
           and t ~= boostTrack and t ~= floatAnimTrack and t ~= landTrack then
            t:Stop()
        end
    end
    task.spawn(function()
        task.wait()
        track:Play(); track.TimePosition = 0.5
        task.wait(1); track:Stop(1)
        task.wait(1.2); isAnimSeqActive = false
    end)
end

local flySound = Instance.new("Sound")
flySound.SoundId       = "rbxassetid://3308152153"
flySound.Volume        = 1.4
flySound.Looped        = true
flySound.PlaybackSpeed = 1.05
flySound.Parent        = SoundService

local boostSound = Instance.new("Sound")
boostSound.SoundId       = "rbxassetid://1295446488"
boostSound.Volume        = 1.5
boostSound.Looped        = false
boostSound.PlaybackSpeed = 1
boostSound.Parent        = SoundService

local function fadeOutSound(dur)
    if currentFadeTween then currentFadeTween:Cancel() end
    currentFadeTween = TweenService:Create(flySound, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Volume = 0})
    currentFadeTween:Play()
    currentFadeTween.Completed:Connect(function()
        flySound:Stop()
        flySound.Volume        = 1.4
        flySound.PlaybackSpeed = 1.05
        currentFadeTween       = nil
    end)
end

local function spawnBoostVfx()
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if boostVfxClone then boostVfxClone:Destroy(); boostVfxClone = nil end
    local vfxTemplate = ReplicatedStorage.Utils.MeiMei.FallStage3.Attachment
    boostVfxClone = vfxTemplate:Clone()
    boostVfxClone.Parent = head
    boostVfxClone.CFrame = CFrame.new(0,0,0) * CFrame.Angles(math.rad(120),0,0)
    for _, c in ipairs(boostVfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then
            c.Enabled = true; c.EmissionDirection = Enum.NormalId.Top; c:Emit(15)
        end
    end
end

local function destroyBoostVfx()
    if not boostVfxClone then return end
    for _, c in ipairs(boostVfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then c.Enabled = false end
    end
    local ref = boostVfxClone; boostVfxClone = nil
    task.delay(1.5, function() if ref then ref:Destroy() end end)
end

local activeBoostBlur    = nil
local activeBoostColorFx = nil
local activeBoostBloom   = nil

local function playBoostEffects()
    
    if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
    if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
    if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end

    
    local blur = Instance.new("BlurEffect")
    blur.Size   = 20
    blur.Parent = camera
    activeBoostBlur = blur

    local colorFx = Instance.new("ColorCorrectionEffect")
    colorFx.Brightness = 0.20
    colorFx.Contrast   = 0
    colorFx.Saturation = 0
    colorFx.TintColor  = Color3.fromRGB(255, 255, 255)
    colorFx.Parent     = camera
    activeBoostColorFx = colorFx

    local bloom = Instance.new("BloomEffect")
    bloom.Intensity  = 0.8
    bloom.Size       = 24
    bloom.Threshold  = 0.9
    bloom.Parent     = camera
    activeBoostBloom = bloom

    
    local info = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blur,    info, { Size       = 0 }):Play()
    TweenService:Create(colorFx, info, { Brightness = 0 }):Play()
    TweenService:Create(bloom,   info, { Intensity  = 0 }):Play()

    
    task.delay(0.7, function()
        if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
        if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
        if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end
        if boostActive then fadeShake() end
    end)

    
    startShake(0.14)
end

local function stopBoostEffects()
    
    if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
    if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
    if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end
    fadeShake()
end

local function spawnLandVfx()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vfxClone = ReplicatedStorage.Utils.Nanami.CleavingWhirlwind.SlashEmit.Floor:Clone()
    vfxClone.Parent = hrp
    for _, c in ipairs(vfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then c.Enabled = true; c:Emit(15) end
    end
    task.delay(0.4, function()
        for _, c in ipairs(vfxClone:GetChildren()) do
            if c:IsA("ParticleEmitter") then c.Enabled = false end
        end
        task.delay(2, function() if vfxClone and vfxClone.Parent then vfxClone:Destroy() end end)
    end)
end

local function startLandVfxMonitor()
    if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end
    local vfxFired = false; local elapsed = 0
    landVfxConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if vfxFired or elapsed > 10 then
            landVfxConn:Disconnect(); landVfxConn = nil; return
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Y > -1 then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(hrp.Position, Vector3.new(0,-50,0), rp)
        if res and (hrp.Position - res.Position).Magnitude <= 4 then
            vfxFired = true; spawnLandVfx()
        end
    end)
end

local function makeAnim(animator, id)
    local a = Instance.new("Animation")
    a.AnimationId = id
    return animator:LoadAnimation(a)
end

local function setupAnimations(char)
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", hum)

    idleTrack      = makeAnim(animator, ANIM.IDLE)
    forwardTrack   = makeAnim(animator, ANIM.FORWARD)
    backwardTrack  = makeAnim(animator, ANIM.BACKWARD)
    boostTrack     = makeAnim(animator, ANIM.BOOST)
    landTrack      = makeAnim(animator, ANIM.LAND)
    floatAnimTrack = makeAnim(animator, DR_FLOAT)

    idleTrack.Priority      = Enum.AnimationPriority.Movement
    forwardTrack.Priority   = Enum.AnimationPriority.Movement
    backwardTrack.Priority  = Enum.AnimationPriority.Movement
    boostTrack.Priority     = Enum.AnimationPriority.Action
    landTrack.Priority      = Enum.AnimationPriority.Action
    floatAnimTrack.Priority = Enum.AnimationPriority.Idle

    idleTrack.Looped      = true
    forwardTrack.Looped   = true
    backwardTrack.Looped  = true
    boostTrack.Looped     = true
    floatAnimTrack.Looped = true
end

local function stopAllFlyAnims(fade)
    local f = fade or 0.2
    for _, t in ipairs({idleTrack, forwardTrack, backwardTrack, boostTrack, floatAnimTrack}) do
        if t and t.IsPlaying then t:Stop(f) end
    end
end

local function setAnimState(newState)
    if currentAnimState == newState then return end
    currentAnimState = newState
    stopAllFlyAnims(0.15)

    if newState == "idle" then
        if floatMode then
            if floatAnimTrack then
                floatAnimTrack:Play(0.2)
                task.defer(function()
                    floatAnimTrack:AdjustSpeed(0)
                    floatAnimTrack.TimePosition = 0.7
                end)
            end
        else
            idleAnimT = 0
            if idleTrack then
                idleTrack:Play(0.2)
                task.defer(function()
                    idleTrack:AdjustSpeed(0)
                    idleTrack.TimePosition = CFG.IDLE_FREEZE_TIME
                end)
            end
        end

    elseif newState == "forward" or newState == "backward" then
        local track = newState == "forward" and forwardTrack or backwardTrack
        if track then
            track:Play(0.2)
            task.defer(function()
                track:AdjustSpeed(0); track.TimePosition = 0.1
            end)
        end

    elseif newState == "boost" then
        boostFrozen = false
        if boostTrack then
            boostTrack:Play(0.15)
            task.defer(function()
                boostTrack.TimePosition = 0.4; boostTrack:AdjustSpeed(1)
            end)
        end
    end
end

local function playLanding(hrp)
    if landConn then landConn:Disconnect(); landConn = nil end
    if not landTrack then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    landTrack:Play(0.1); landTrack:AdjustSpeed(1)
    local frozen = false
    landConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then landConn:Disconnect(); landConn = nil; return end
        local st = hum:GetState()
        local grounded = st == Enum.HumanoidStateType.Running
            or st == Enum.HumanoidStateType.RunningNoPhysics
            or st == Enum.HumanoidStateType.Landed
            or st == Enum.HumanoidStateType.Seated
        if not frozen and landTrack.TimePosition >= 0.1 then landTrack:AdjustSpeed(0); frozen = true end
        if frozen and (hrp.Position.Y <= -0.7 or grounded) then landTrack:AdjustSpeed(1); frozen = false end
        if not landTrack.IsPlaying then landConn:Disconnect(); landConn = nil end
    end)
end

local function activateBoost()
    if not flying then return end
    boostActive = true
    _G.BoostActive = true
    flySound.PlaybackSpeed = 1.35; flySound.Volume = 2
    if not flySound.IsPlaying then flySound:Play() end
    boostSound:Stop(); boostSound:Play()
    spawnBoostVfx()
    
    TweenService:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 90}):Play()
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do
                if t ~= boostTrack then t:Stop(0.05) end
            end
        end
    end
    
    playBoostEffects()
end

local function deactivateBoost()
    boostActive = false
    _G.BoostActive = false
    flySound.PlaybackSpeed = 1.05; flySound.Volume = 1.4
    destroyBoostVfx()
    
    TweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
    
    stopBoostEffects()
end

local function startFlying()
    if flying then return end
    if landConn    then landConn:Disconnect();    landConn    = nil end
    if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end
    if landTrack and landTrack.IsPlaying then landTrack:Stop(0.2) end

    local char = player.Character
    if not char then return end
    setupAnimations(char)

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    flying           = true
    currentAnimState = ""
    hoverBobT        = 0
    baseHoverY       = hrp.Position.Y
    wasIdle          = false
    boostFrozen      = false
    
    prevCameraAngleY = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
    tiltSmoothed     = 0

    hum.PlatformStand = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P         = 30000
    bodyGyro.Parent    = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.Parent   = hrp

    if animConn then animConn:Disconnect() end
    animConn = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end

        
        if currentAnimState == "idle" and floatMode then
            if floatAnimTrack and floatAnimTrack.IsPlaying then
                floatAnimTrack:AdjustSpeed(0)
                floatAnimTrack.TimePosition = 0.7
            end
        
        elseif currentAnimState == "idle" and not floatMode then
            if idleTrack and idleTrack.IsPlaying and idleTrack.TimePosition ~= CFG.IDLE_FREEZE_TIME then
                idleTrack:AdjustSpeed(0)
                idleTrack.TimePosition = CFG.IDLE_FREEZE_TIME
            end
        end

        if currentAnimState == "forward"  and forwardTrack  and forwardTrack.IsPlaying  then forwardTrack.TimePosition  = 0.1 end
        if currentAnimState == "backward" and backwardTrack and backwardTrack.IsPlaying then backwardTrack.TimePosition = 0.1 end

        
        if currentAnimState == "boost" and boostTrack and boostTrack.IsPlaying then
            local char2 = player.Character
            if char2 then
                local hum2 = char2:FindFirstChildOfClass("Humanoid")
                if hum2 then
                    for _, t in pairs(hum2:GetPlayingAnimationTracks()) do
                        if t ~= boostTrack then t:Stop(0) end
                    end
                end
            end
            if not boostFrozen then
                if boostTrack.TimePosition >= 0.7 then
                    boostFrozen = true; boostTrack:AdjustSpeed(0); boostTrack.TimePosition = 0.7
                end
            else
                boostTrack.TimePosition = 0.7
            end
        end
    end)

    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flying or not hrp.Parent then return end

        local controls = PlayerModule:GetControls()
        local mv       = controls:GetMoveVector()

        local isMoving   = mv.Magnitude > 0.1 or math.abs(verticalInput) > 0.1
        local isBackward = isMoving and mv.Z > 0.1 and mv.Z > math.abs(mv.X)

        if boostActive and (not isMoving or isBackward) then deactivateBoost() end

        local spd     = boostActive and CFG.BOOST_SPEED or CFG.NORMAL_SPEED
        local nowIdle = not isMoving and not boostActive

        if nowIdle then
            if not wasIdle then baseHoverY = hrp.Position.Y; hoverBobT = 0 end
            hoverBobT = hoverBobT + dt
            local targetY = baseHoverY + math.sin(hoverBobT * CFG.HOVER_FREQ * math.pi * 2) * CFG.HOVER_AMP
            bodyVelocity.Velocity = Vector3.new(0, (targetY - hrp.Position.Y) * CFG.HOVER_SPRING, 0)
        else
            baseHoverY = hrp.Position.Y
            local moveDir = camera.CFrame:VectorToWorldSpace(Vector3.new(mv.X, verticalInput, mv.Z))
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            bodyVelocity.Velocity = moveDir * spd
        end
        wasIdle = nowIdle

        if not nowIdle then
            if not flySound.IsPlaying then flySound.Volume = boostActive and 2 or 1.4; flySound:Play() end
        else
            if flySound.IsPlaying then fadeOutSound(0.6) end
        end

        local desired
        if boostActive      then desired = "boost"
        elseif isMoving     then desired = isBackward and "backward" or "forward"
        else                     desired = "idle" end

        setAnimState(desired)

        
        local currentAngleY = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
        local deltaAngle    = currentAngleY - prevCameraAngleY
        if deltaAngle >  math.pi then deltaAngle = deltaAngle - 2*math.pi end
        if deltaAngle < -math.pi then deltaAngle = deltaAngle + 2*math.pi end
        prevCameraAngleY = currentAngleY

        
        local targetTilt = 0
        if boostActive then
            local camTurnSpeed = deltaAngle / math.max(dt, 0.001)
            local dynamicTilt  = math.clamp(camTurnSpeed * TILT_SENSITIVITY, -math.rad(54), math.rad(47))
            targetTilt = math.rad(31) + dynamicTilt
        end
        tiltSmoothed = tiltSmoothed + (targetTilt - tiltSmoothed) * math.min(dt * 2.5, 1)

        bodyGyro.CFrame = camera.CFrame * CFrame.Angles(0, 0, tiltSmoothed)
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false; boostActive = false; boostFrozen = false; floatMode = false

    destroyBoostVfx()

    if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if flyConn      then flyConn:Disconnect();   flyConn      = nil end
    if animConn     then animConn:Disconnect();  animConn     = nil end

    local char = player.Character; local hrp = nil
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        hrp = char:FindFirstChild("HumanoidRootPart")
    end

    if flySound.IsPlaying then fadeOutSound(0.8) end
    stopAllFlyAnims(0.3)
    flySound.PlaybackSpeed = 1.05
    
    TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
    startLandVfxMonitor()
    if hrp and landTrack then playLanding(hrp) end

    verticalInput = 0; currentAnimState = ""; wasIdle = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if flying then stopFlying() else startFlying() end

    elseif input.KeyCode == Enum.KeyCode.W then
        if not flying then return end
        local now = os.clock()
        if now - lastWTapTime <= DOUBLE_TAP_TIME then
            if boostActive then deactivateBoost() else activateBoost() end
            lastWTapTime = 0 
        else
            lastWTapTime = now
        end
    end
end)

flyBtn.Activated:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

task.spawn(function()
    local pg = player:WaitForChild("PlayerGui")
    local ctrl = pg:WaitForChild("Controls", 30); if not ctrl then return end
    local mob  = ctrl:WaitForChild("Mobile", 10); if not mob  then return end
    local jump = mob:WaitForChild("Jump", 10);    if not jump  then return end
    local spc  = jump:WaitForChild("Special", 10);if not spc   then return end
    spc.Activated:Connect(function()
        if not flying then return end
        if boostActive then deactivateBoost() else activateBoost() end
    end)
end)

local character  = player.Character or player.CharacterAdded:Wait()
local humanoid   = character:WaitForChild("Humanoid")
local rootPart   = character:WaitForChild("HumanoidRootPart")
local drAnimator = humanoid:WaitForChild("Animator")

local original  = player.PlayerGui.Main.Controls.Moveset['Manji Kick']
local newButton = original:Clone()
newButton.Name          = "destructive rush"
newButton.ItemName.Text = "destructive rush"
newButton.Parent        = original.Parent
newButton.Key.Key.Text  = "5"

newButton.Key.Key:GetPropertyChangedSignal("Text"):Connect(function()
    if newButton.Key.Key.Text ~= "5" then
        newButton.Key.Key.Text = "5"
    end
end)

newButton:GetPropertyChangedSignal("Visible"):Connect(function()
    if not isDeadCleanup and not newButton.Visible then
        newButton.Visible = true
    end
end)

local cooldownFrame = newButton:FindFirstChild("Cooldown")
local uiGradient    = cooldownFrame and cooldownFrame:FindFirstChildOfClass("UIGradient")

if cooldownFrame and not uiGradient then
    uiGradient = Instance.new("UIGradient"); uiGradient.Parent = cooldownFrame
end
if cooldownFrame then
    cooldownFrame.BackgroundColor3       = Color3.fromRGB(0, 170, 255)
    cooldownFrame.BackgroundTransparency = 0.3
    cooldownFrame.ZIndex                 = newButton.ZIndex + 3
    cooldownFrame.Visible                = false
end
if uiGradient then
    uiGradient.Color        = ColorSequence.new(Color3.fromRGB(255,255,255))
    uiGradient.Rotation     = 90
    uiGradient.Transparency = NumberSequence.new(0)
end

local function playCooldownVisual()
    if not cooldownFrame or not uiGradient then return end
    cooldownFrame.Visible   = true
    uiGradient.Transparency = NumberSequence.new(0)
    local startTime = tick(); local cdConn
    cdConn = RunService.RenderStepped:Connect(function()
        local p = math.clamp((tick() - startTime) / COOLDOWN, 0, 1)
        if p >= 1 then cdConn:Disconnect(); cooldownFrame.Visible = false; return end
        if p <= 0.001 then
            uiGradient.Transparency = NumberSequence.new(0)
        else
            uiGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,                       1),
                NumberSequenceKeypoint.new(p,                       1),
                NumberSequenceKeypoint.new(math.min(p+0.001, 1),   0),
                NumberSequenceKeypoint.new(1,                       0),
            })
        end
    end)
end

local shakeIntensity = 0; local shakeFading = false; local shakeConn = nil

local function startShake(intensity)
    shakeIntensity = intensity; shakeFading = false
    if shakeConn then shakeConn:Disconnect() end
    shakeConn = RunService.RenderStepped:Connect(function(dt)
        if shakeIntensity <= 0 then
            if shakeConn then shakeConn:Disconnect(); shakeConn = nil end; return
        end
        local rx = (math.random()-0.5)*2*shakeIntensity
        local ry = (math.random()-0.5)*2*shakeIntensity
        local rz = (math.random()-0.5)*2*shakeIntensity
        camera.CFrame = camera.CFrame * CFrame.new(rx,ry,0) * CFrame.Angles(math.rad(rz*0.4), math.rad(rx*0.2), 0)
        if shakeFading then
            shakeIntensity = shakeIntensity - (shakeIntensity * dt * 3)
            if shakeIntensity < 0.002 then shakeIntensity = 0 end
        end
    end)
end

local function fadeShake() shakeFading = true end
local function stopShake()
    shakeIntensity = 0; shakeFading = false
    if shakeConn then shakeConn:Disconnect(); shakeConn = nil end
end

local function loadDRAnim(id)
    local a = Instance.new("Animation"); a.AnimationId = id
    return drAnimator:LoadAnimation(a)
end

local drActive = false

local function triggerDestructiveRush()
    if drActive then return end
    drActive = true
    playCooldownVisual()

    humanoid.PlatformStand = true
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Parent = rootPart

    
    local drGyro = Instance.new("BodyGyro")
    drGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    drGyro.P         = 50000
    drGyro.D         = 500
    local look = rootPart.CFrame.LookVector
    drGyro.CFrame    = CFrame.new(Vector3.zero, Vector3.new(look.X, 0, look.Z))
    drGyro.Parent    = rootPart

    
    local startTrack = loadDRAnim(DR_STARTUP)
    startTrack.Priority = Enum.AnimationPriority.Action4
    startTrack:Play(BLEND); startTrack.TimePosition = 0
    startShake(0.09)

    
    local drStartVfxClone = ReplicatedStorage.Utils.Mechamaru.EjectDeathVFX.DustLand2.VFX.extra2:Clone()
    drStartVfxClone.Parent = rootPart
    for _, child in ipairs(drStartVfxClone:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child:Emit(15); child.Enabled = true
        end
    end

    local frozen = false; local conn
    conn = RunService.Heartbeat:Connect(function()

        if not frozen and startTrack.TimePosition >= 0.3 then
            frozen = true; startTrack:AdjustSpeed(0)
            task.wait(1); startTrack:AdjustSpeed(1)
        end

        if frozen and startTrack.TimePosition >= 0.6 then
            conn:Disconnect(); fadeShake()

            
            local riseTrack = loadDRAnim(DR_RISE)
            riseTrack.Priority = Enum.AnimationPriority.Action4
            riseTrack.Looped   = true
            riseTrack:Play(BLEND); riseTrack.TimePosition = 4.1; riseTrack:AdjustSpeed(0)
            startTrack:Stop(BLEND)

            
            if drStartVfxClone then
                for _, child in ipairs(drStartVfxClone:GetChildren()) do
                    if child:IsA("ParticleEmitter") then child.Enabled = false end
                end
                local refS = drStartVfxClone; drStartVfxClone = nil
                task.delay(2, function() if refS and refS.Parent then refS:Destroy() end end)
            end

            
            local risingAnchor = Instance.new("Part")
            risingAnchor.Anchored     = true
            risingAnchor.CanCollide   = false
            risingAnchor.CastShadow   = false
            risingAnchor.Transparency = 1
            risingAnchor.Size         = Vector3.new(1, 1, 1)
            risingAnchor.CFrame       = rootPart.CFrame
            risingAnchor.Parent       = workspace

            local risingVfxClone = ReplicatedStorage.Utils.Mechamaru.DeathVFX.DustLand:Clone()
            risingVfxClone.Parent = risingAnchor
            for _, child in ipairs(risingVfxClone:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    child:Emit(15); child.Enabled = true
                end
            end

            task.delay(0.5, function()
                if risingVfxClone and risingVfxClone.Parent then
                    for _, child in ipairs(risingVfxClone:GetChildren()) do
                        if child:IsA("ParticleEmitter") then child.Enabled = false end
                    end
                end
                task.delay(2, function()
                    if risingAnchor and risingAnchor.Parent then risingAnchor:Destroy() end
                end)
            end)

            
            local risingSound = Instance.new("Sound")
            risingSound.SoundId = "rbxassetid://90269024228015"
            risingSound.Volume  = 1
            risingSound.Parent  = SoundService
            risingSound:Play()
            game:GetService("Debris"):AddItem(risingSound, 10)

            local tween = TweenService:Create(
                rootPart,
                TweenInfo.new(RISE_SPEED, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { CFrame = rootPart.CFrame + Vector3.new(0, RISE_HEIGHT, 0) }
            )
            tween:Play()

            tween.Completed:Connect(function()
                stopShake(); riseTrack:Stop(BLEND)

                
                bv:Destroy()
                
                if drGyro then drGyro:Destroy(); drGyro = nil end
                floatMode = true
                startFlying()

                task.wait(FLOAT_TIME)

                floatMode        = false
                currentAnimState = ""

                task.wait(COOLDOWN)
                drActive = false
            end)
        end
    end)
end

local drClickBtn = Instance.new("TextButton")
drClickBtn.Size                   = UDim2.new(1, 0, 1, 0)
drClickBtn.Position               = UDim2.new(0, 0, 0, 0)
drClickBtn.BackgroundTransparency = 1
drClickBtn.Text                   = ""
drClickBtn.ZIndex                 = newButton.ZIndex + 5
drClickBtn.Parent                 = newButton
drClickBtn.MouseButton1Click:Connect(triggerDestructiveRush)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Five then
        triggerDestructiveRush()
    end
end)

local function cleanupOnDeath()
    
    if isDeadCleanup then return end
    
    isDeadCleanup = true

    
    pcall(function() if flying then stopFlying() end end)

    pcall(function() if flyConn     then flyConn:Disconnect();     flyConn     = nil end end)
    pcall(function() if animConn    then animConn:Disconnect();    animConn    = nil end end)
    pcall(function() if landConn    then landConn:Disconnect();    landConn    = nil end end)
    pcall(function() if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end end)
    pcall(function() if shakeConn   then shakeConn:Disconnect();   shakeConn   = nil end end)
    pcall(function() if _G.__FlySystemThrowBoostConn then _G.__FlySystemThrowBoostConn:Disconnect(); _G.__FlySystemThrowBoostConn = nil end end)

    pcall(function() if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end end)
    pcall(function() if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end end)

    pcall(destroyBoostVfx)
    pcall(stopBoostEffects)

    pcall(function() flySound:Stop();   flySound:Destroy()   end)
    pcall(function() boostSound:Stop(); boostSound:Destroy() end)

    
    pcall(function() if newButton and newButton.Parent then newButton:Destroy() end end)

    
    pcall(function() if gui and gui.Parent then gui:Destroy() end end)

    pcall(function() if camera then camera.FieldOfView = 70 end end)

    flying           = false
    boostActive      = false
    boostFrozen      = false
    floatMode        = false
    drActive         = false
    verticalInput    = 0
    currentAnimState = ""

    
    pcall(function() script:Destroy() end)
end

local deathConn
local function bindDeathHandler(char)
    if deathConn then deathConn:Disconnect(); deathConn = nil end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not hum then return end
    if hum.Health <= 0 then
        cleanupOnDeath()
        return
    end
    deathConn = hum.Died:Connect(cleanupOnDeath)
end

bindDeathHandler(character)
player.CharacterAdded:Connect(bindDeathHandler)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ANIM_ID = "rbxassetid://127171275866632"
local BUTTON_IMAGE_ID = "rbxassetid://8618269848"

local HANG_SOUND_ID = "rbxassetid://82687386744947"
local HANG_SOUND_VOLUME = 0.3

local POSITION_OFFSET = Vector3.new(-0.1, -0.5, -2)
local ROTATION_OFFSET = Vector3.new(10, 180, 0)

local MAX_TARGET_DISTANCE = 15
local REMOTE_HIT_COUNT    = 4
local REMOTE_HIT_DELAY    = 0.5
local AFTER_LAST_HIT_DELAY = 0.45   
local BUTTON_COOLDOWN     = 8

local function getRemote(...)
	local path = { ... }
	local ok, remote = pcall(function()
		local node = ReplicatedStorage
		for _, child in ipairs(path) do
			node = node:WaitForChild(child, 5)
		end
		return node
	end)
	return ok and remote or nil
end

local activatedRemote = getRemote("Knit","Knit","Services","ItadoriService","RE","Activated")

if not activatedRemote then warn("[Choke] Activated remote not found!") end

local gui = Instance.new("ScreenGui")
gui.Name = "HeadLockGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function createSound(parent)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://3077287610"
	sound.Volume = 4
	sound.Parent = parent
	return sound
end

local function createButton(posY)
	local frameBorder = Instance.new("Frame")
	frameBorder.Parent = gui
	frameBorder.Size = UDim2.new(0, 50, 0, 50)
	frameBorder.Position = UDim2.new(0, 550, 0, posY)
	frameBorder.BackgroundTransparency = 1
	frameBorder.BorderSizePixel = 0

	local btn = Instance.new("ImageButton")
	btn.Parent = frameBorder
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0.5, 0, 0.5, 0)
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Image = BUTTON_IMAGE_ID
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.ImageColor3 = Color3.fromRGB(255, 255, 255)

	local label = Instance.new("TextLabel")
	label.Parent = frameBorder
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 90, 90)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = ""
	label.ZIndex = 5

	local sound = createSound(btn)

	return btn, sound, label
end

local button, clickSound, cooldownLabel = createButton(60)

local active = false
local lockedTarget = nil
local animTrack = nil
local hangSound = nil
local healthWatchConn = nil
local lastActivationTime = -math.huge

local sequenceRunId = 0

local function getClosestTargetToCamera(hrp)
	local closest = nil
	local bestScore = -math.huge

	local camPos     = camera.CFrame.Position
	local camForward = camera.CFrame.LookVector

	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model")
			and model ~= player.Character
			and model:FindFirstChild("Humanoid")
			and model:FindFirstChild("HumanoidRootPart")
			and model:FindFirstChild("Head") then

			local hum = model:FindFirstChild("Humanoid")

			if hum and hum.Health > 0 then
				local targetHRP = model.HumanoidRootPart
				local dist = (hrp.Position - targetHRP.Position).Magnitude

				if dist <= MAX_TARGET_DISTANCE then
					local toTarget = (targetHRP.Position - camPos)
					local dot = camForward:Dot(toTarget.Unit)

					if dot > 0.3 then
						local score = dot - (dist / MAX_TARGET_DISTANCE)
						if score > bestScore then
							bestScore = score
							closest = model
						end
					end
				end
			end
		end
	end

	return closest
end

local function startHangSound(parent)
	if hangSound then hangSound:Destroy() end
	hangSound = Instance.new("Sound")
	hangSound.SoundId = HANG_SOUND_ID
	hangSound.Volume = HANG_SOUND_VOLUME
	hangSound.Looped = true
	hangSound.Parent = parent
	hangSound:Play()
end

local function stopHangSound()
	if hangSound then
		hangSound:Stop()
		hangSound:Destroy()
		hangSound = nil
	end
end

local function forceAnimation(humanoid)
	if animTrack then
		animTrack:Stop()
		animTrack:Destroy()
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = ANIM_ID

	animTrack = humanoid:LoadAnimation(anim)
	animTrack.Priority = Enum.AnimationPriority.Action4
	animTrack.Looped = true

	animTrack:Play(0)
	task.wait()
	animTrack.TimePosition = 1
	animTrack:AdjustSpeed(0)
end

local function releaseHold()
	active = false
	lockedTarget = nil

	button.ImageColor3 = Color3.fromRGB(255, 255, 255)

	if animTrack then
		animTrack:Stop()
		animTrack:Destroy()
		animTrack = nil
	end

	stopHangSound()

	if healthWatchConn then
		healthWatchConn:Disconnect()
		healthWatchConn = nil
	end

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = true
		end
	end
end

local function watchMyHealth(humanoid)
	if healthWatchConn then
		healthWatchConn:Disconnect()
	end

	local lastHealth = humanoid.Health

	healthWatchConn = humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth and active then
			print("[Choke] ضرر — تحرير الخنقة (السلسلة تكمل بالخلفية)")
			releaseHold()
		end
		lastHealth = newHealth
	end)
end

local function runRemoteSequence(myId)
	if not activatedRemote then return end

	for i = 1, REMOTE_HIT_COUNT do
		
		if myId ~= sequenceRunId then
			print("[Choke] أُلغيت عند Punch " .. i .. " (سلسلة جديدة/إلغاء يدوي)")
			return
		end

		pcall(function()
			activatedRemote:FireServer(false)
		end)
		print("[Choke] Punch " .. i .. " ✅")

		if i < REMOTE_HIT_COUNT then
			local startWait = tick()
			repeat
				RunService.Heartbeat:Wait()
			until tick() - startWait >= REMOTE_HIT_DELAY or myId ~= sequenceRunId

			if myId ~= sequenceRunId then return end
		end
	end

	print("[Choke] اكتملت 4 ضربات — ننتظر " .. AFTER_LAST_HIT_DELAY .. "s ثم إيقاف")

	
	local waitStart = tick()
	repeat
		RunService.Heartbeat:Wait()
	until tick() - waitStart >= AFTER_LAST_HIT_DELAY or myId ~= sequenceRunId

	if myId == sequenceRunId then
		print("[Choke] إيقاف نهائي بعد 4 Punch")
		releaseHold()
	end
end

button.Activated:Connect(function()
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid then return end

	if not active then
		local now = tick()
		local elapsed = now - lastActivationTime
		if elapsed < BUTTON_COOLDOWN then
			print(string.format("[Choke] كولداون — انتظر %.1f ثانية", BUTTON_COOLDOWN - elapsed))
			return
		end

		local target = getClosestTargetToCamera(hrp)

		if not target then
			print("[Choke] ما في هدف ضمن " .. MAX_TARGET_DISTANCE .. " studs من الكاميرا")
			return
		end

		clickSound:Play()

		active = true
		lockedTarget = target
		lastActivationTime = now

		sequenceRunId += 1
		local myId = sequenceRunId

		button.ImageColor3 = Color3.fromRGB(100, 255, 100)

		forceAnimation(humanoid)
		startHangSound(hrp)
		watchMyHealth(humanoid)

		humanoid.AutoRotate = false

		
		task.spawn(function()
			runRemoteSequence(myId)
		end)

	else
		clickSound:Play()
		sequenceRunId += 1
		releaseHold()
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	print("[Choke] Character respawned — تحرير الجانب البصري فقط")
	releaseHold()
end)

RunService.RenderStepped:Connect(function()
	local now = tick()
	local elapsed = now - lastActivationTime

	if not active then
		if elapsed < BUTTON_COOLDOWN then
			cooldownLabel.Text = string.format("%.1f", BUTTON_COOLDOWN - elapsed)
			button.ImageColor3 = Color3.fromRGB(130, 130, 130)
			button.ImageTransparency = 0.35
		else
			cooldownLabel.Text = ""
			button.ImageColor3 = Color3.fromRGB(255, 255, 255)
			button.ImageTransparency = 0
		end
		return
	end

	cooldownLabel.Text = ""

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if not hrp or not humanoid then return end

	
	if humanoid.Health <= 0 then
		print("[Choke] موت حقيقي — تحرير الجانب البصري")
		releaseHold()
		return
	end

	
	
	if not lockedTarget or not lockedTarget.Parent then
		return
	end

	local targetHum = lockedTarget:FindFirstChildOfClass("Humanoid")

	if not targetHum or targetHum.Health <= 0 then
		return
	end

	local head = lockedTarget:FindFirstChild("Head")

	if not head then
		return
	end

	if not hangSound or not hangSound.IsPlaying then
		startHangSound(hrp)
	end

	if humanoid.AutoRotate then
		humanoid.AutoRotate = false
	end

	local finalCFrame = head.CFrame
		* CFrame.new(POSITION_OFFSET)
		* CFrame.Angles(
			math.rad(ROTATION_OFFSET.X),
			math.rad(ROTATION_OFFSET.Y),
			math.rad(ROTATION_OFFSET.Z)
		)

	hrp.CFrame = finalCFrame

	if not animTrack or not animTrack.IsPlaying then
		forceAnimation(humanoid)
	end

	if animTrack then
		animTrack.TimePosition = 1
		animTrack:AdjustSpeed(0)
	end
end)

local disabled = false

local function stopEverything()
	disabled = true

	if gui then
		gui:Destroy()
	end

	releaseHold()

	if healthWatchConn then
		healthWatchConn:Disconnect()
	end
end

local function hookCharacter(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(stopEverything)
end

if player.Character then
	hookCharacter(player.Character)
end

player.CharacterAdded:Connect(stopEverything)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character
local root

local function SetupCharacter(char)
	character = char
	root = char:WaitForChild("HumanoidRootPart")
end

SetupCharacter(player.Character or player.CharacterAdded:Wait())

player.CharacterAdded:Connect(SetupCharacter)

local RightActivated = ReplicatedStorage
	:WaitForChild("Knit")
	:WaitForChild("Knit")
	:WaitForChild("Services")
	:WaitForChild("ItadoriService")
	:WaitForChild("RE")
	:WaitForChild("RightActivated")

local ThrowableFolder = Workspace.Map.Destructible:WaitForChild("Throwable")

local boostConnection

local function StartThrowBoost()

	if boostConnection then
		boostConnection:Disconnect()
	end

	boostConnection = RunService.Heartbeat:Connect(function()

		if not _G.BoostActive then
			return
		end

		if not character or not root then
			return
		end

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = {character}

		local direction = root.CFrame.LookVector * 15

		local result = Workspace:Raycast(
			root.Position,
			direction,
			rayParams
		)

		if result and result.Instance then

			local hit = result.Instance

			if hit:IsDescendantOf(ThrowableFolder) then
				RightActivated:FireServer()
			end
		end
	end)
end

StartThrowBoost()

_G.__FlySystemThrowBoostConn = boostConnection
]=]

local SRC_PC_FLY = [=[
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local character  = player.Character or player.CharacterAdded:Wait()
local humanoid   = character:WaitForChild("Humanoid")
local rootPart   = character:WaitForChild("HumanoidRootPart")
local drAnimator = humanoid:WaitForChild("Animator")

local cleanedUp = false

local flySystemDead = false
local function forceCleanup()
    if cleanedUp then return end
    cleanedUp = true
    flySystemDead = true  

    
    
    pcall(function()
        if _G.__FlySystemCleanup then _G.__FlySystemCleanup() end
    end)
    pcall(function()
        if _G.__ChokeCleanup then _G.__ChokeCleanup() end
    end)

    
    
    pcall(function()
        local flyGui = player.PlayerGui:FindFirstChild("FlyGui")
        if flyGui then flyGui:Destroy() end
    end)
    pcall(function()
        for _, ch in ipairs(player.PlayerGui:GetDescendants()) do
            if ch.Name == "destructive rush" then ch:Destroy() end
        end
    end)
    pcall(function() if camera then camera.FieldOfView = 70 end end)

    
    script:Destroy()
end

humanoid.Died:Connect(forceCleanup)
player.CharacterRemoving:Connect(function(char)
    if char == character then forceCleanup() end
end)

task.spawn(function()
    local targetGui = player.PlayerGui:WaitForChild("110978068388232", 5)
    if targetGui then targetGui.Visible = false end
end)

local gui = Instance.new("ScreenGui")
gui.Name         = "FlyGui"
gui.ResetOnSpawn = false
gui.Parent       = player:WaitForChild("PlayerGui")

local CFG = {
    NORMAL_SPEED = 30,
    BOOST_SPEED  = 90,
    HOVER_AMP    = 0.5,
    HOVER_FREQ   = 0.5,
    HOVER_SPRING = 14,
    IDLE_FREEZE_TIME = 0.75, 
}

local ANIM = {
    IDLE     = "rbxassetid://99249148382757",
    FORWARD  = "rbxassetid://9443519528",
    BACKWARD = "rbxassetid://134581973800784",
    BOOST    = "rbxassetid://128524425761051",
    LAND     = "rbxassetid://78540995456941",
}

local DR_STARTUP = "rbxassetid://139078698020363"
local DR_RISE    = "rbxassetid://136676738644802"
local DR_FLOAT   = "rbxassetid://131522534497146"

local RISE_HEIGHT = 120
local RISE_SPEED  = 1
local FLOAT_TIME  = 15
local BLEND       = 0.15
local COOLDOWN    = 5

local isDeadCleanup    = false
local flying           = false
local floatMode        = false
local verticalInput    = 0
local currentAnimState = ""

local bodyGyro, bodyVelocity      = nil, nil
local flyConn, animConn, landConn = nil, nil, nil
local landVfxConn                 = nil

local idleTrack, forwardTrack, backwardTrack
local boostTrack, landTrack, floatAnimTrack

local hoverBobT   = 0
local baseHoverY  = 0
local wasIdle     = false
local idleAnimT   = 0
local boostFrozen = false

local boostActive      = false
_G.BoostActive      = false
local boostVfxClone    = nil
local currentFadeTween = nil

local lastWTapTime    = 0
local DOUBLE_TAP_TIME = 0.3 

local prevCameraAngleY = 0   
local tiltSmoothed     = 0   
local TILT_SENSITIVITY = 2.5 

local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))

local cursedStrikeANIM = ReplicatedStorage.Animations.Todo.BruteForce
local roughEnergyANIM  = ReplicatedStorage.Animations.Megumi.Mahoraga.WorldSlash
local isAnimSeqActive  = false

local function playAnimOverride(p)
    if isAnimSeqActive then return end
    isAnimSeqActive = true
    local char = p.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = roughEnergyANIM.AnimationId
    local track = hum:LoadAnimation(anim)
    
    for _, t in pairs(hum:GetPlayingAnimationTracks()) do
        if t ~= idleTrack and t ~= forwardTrack and t ~= backwardTrack
           and t ~= boostTrack and t ~= floatAnimTrack and t ~= landTrack then
            t:Stop()
        end
    end
    task.spawn(function()
        task.wait()
        track:Play(); track.TimePosition = 0.5
        task.wait(1); track:Stop(1)
        task.wait(1.2); isAnimSeqActive = false
    end)
end

local flySound = Instance.new("Sound")
flySound.SoundId       = "rbxassetid://3308152153"
flySound.Volume        = 1.4
flySound.Looped        = true
flySound.PlaybackSpeed = 1.05
flySound.Parent        = SoundService

local boostSound = Instance.new("Sound")
boostSound.SoundId       = "rbxassetid://1295446488"
boostSound.Volume        = 1.5
boostSound.Looped        = false
boostSound.PlaybackSpeed = 1
boostSound.Parent        = SoundService

local function fadeOutSound(dur)
    if currentFadeTween then currentFadeTween:Cancel() end
    currentFadeTween = TweenService:Create(flySound, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Volume = 0})
    currentFadeTween:Play()
    currentFadeTween.Completed:Connect(function()
        flySound:Stop()
        flySound.Volume        = 1.4
        flySound.PlaybackSpeed = 1.05
        currentFadeTween       = nil
    end)
end

local function spawnBoostVfx()
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if boostVfxClone then boostVfxClone:Destroy(); boostVfxClone = nil end
    local vfxTemplate = ReplicatedStorage.Utils.MeiMei.FallStage3.Attachment
    boostVfxClone = vfxTemplate:Clone()
    boostVfxClone.Parent = head
    boostVfxClone.CFrame = CFrame.new(0,0,0) * CFrame.Angles(math.rad(120),0,0)
    for _, c in ipairs(boostVfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then
            c.Enabled = true; c.EmissionDirection = Enum.NormalId.Top; c:Emit(15)
        end
    end
end

local function destroyBoostVfx()
    if not boostVfxClone then return end
    for _, c in ipairs(boostVfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then c.Enabled = false end
    end
    local ref = boostVfxClone; boostVfxClone = nil
    task.delay(1.5, function() if ref then ref:Destroy() end end)
end

local activeBoostBlur    = nil
local activeBoostColorFx = nil
local activeBoostBloom   = nil

local function playBoostEffects()
    
    if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
    if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
    if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end

    
    local blur = Instance.new("BlurEffect")
    blur.Size   = 20
    blur.Parent = camera
    activeBoostBlur = blur

    local colorFx = Instance.new("ColorCorrectionEffect")
    colorFx.Brightness = 0.20
    colorFx.Contrast   = 0
    colorFx.Saturation = 0
    colorFx.TintColor  = Color3.fromRGB(255, 255, 255)
    colorFx.Parent     = camera
    activeBoostColorFx = colorFx

    local bloom = Instance.new("BloomEffect")
    bloom.Intensity  = 0.8
    bloom.Size       = 24
    bloom.Threshold  = 0.9
    bloom.Parent     = camera
    activeBoostBloom = bloom

    
    local info = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(blur,    info, { Size       = 0 }):Play()
    TweenService:Create(colorFx, info, { Brightness = 0 }):Play()
    TweenService:Create(bloom,   info, { Intensity  = 0 }):Play()

    
    task.delay(0.7, function()
        if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
        if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
        if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end
        if boostActive then fadeShake() end
    end)

    
    startShake(0.14)
end

local function stopBoostEffects()
    
    if activeBoostBlur    then activeBoostBlur:Destroy();    activeBoostBlur    = nil end
    if activeBoostColorFx then activeBoostColorFx:Destroy(); activeBoostColorFx = nil end
    if activeBoostBloom   then activeBoostBloom:Destroy();   activeBoostBloom   = nil end
    fadeShake()
end

local function spawnLandVfx()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local vfxClone = ReplicatedStorage.Utils.Nanami.CleavingWhirlwind.SlashEmit.Floor:Clone()
    vfxClone.Parent = hrp
    for _, c in ipairs(vfxClone:GetChildren()) do
        if c:IsA("ParticleEmitter") then c.Enabled = true; c:Emit(15) end
    end
    task.delay(0.4, function()
        for _, c in ipairs(vfxClone:GetChildren()) do
            if c:IsA("ParticleEmitter") then c.Enabled = false end
        end
        task.delay(2, function() if vfxClone and vfxClone.Parent then vfxClone:Destroy() end end)
    end)
end

local function startLandVfxMonitor()
    if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end
    local vfxFired = false; local elapsed = 0
    landVfxConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if vfxFired or elapsed > 10 then
            landVfxConn:Disconnect(); landVfxConn = nil; return
        end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.AssemblyLinearVelocity.Y > -1 then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}; rp.FilterType = Enum.RaycastFilterType.Exclude
        local res = workspace:Raycast(hrp.Position, Vector3.new(0,-50,0), rp)
        if res and (hrp.Position - res.Position).Magnitude <= 4 then
            vfxFired = true; spawnLandVfx()
        end
    end)
end

local function makeAnim(animator, id)
    local a = Instance.new("Animation")
    a.AnimationId = id
    return animator:LoadAnimation(a)
end

local function setupAnimations(char)
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", hum)

    idleTrack      = makeAnim(animator, ANIM.IDLE)
    forwardTrack   = makeAnim(animator, ANIM.FORWARD)
    backwardTrack  = makeAnim(animator, ANIM.BACKWARD)
    boostTrack     = makeAnim(animator, ANIM.BOOST)
    landTrack      = makeAnim(animator, ANIM.LAND)
    floatAnimTrack = makeAnim(animator, DR_FLOAT)

    idleTrack.Priority      = Enum.AnimationPriority.Movement
    forwardTrack.Priority   = Enum.AnimationPriority.Movement
    backwardTrack.Priority  = Enum.AnimationPriority.Movement
    boostTrack.Priority     = Enum.AnimationPriority.Action
    landTrack.Priority      = Enum.AnimationPriority.Action
    floatAnimTrack.Priority = Enum.AnimationPriority.Idle

    idleTrack.Looped      = true
    forwardTrack.Looped   = true
    backwardTrack.Looped  = true
    boostTrack.Looped     = true
    floatAnimTrack.Looped = true
end

local function stopAllFlyAnims(fade)
    local f = fade or 0.2
    for _, t in ipairs({idleTrack, forwardTrack, backwardTrack, boostTrack, floatAnimTrack}) do
        if t and t.IsPlaying then t:Stop(f) end
    end
end

local function setAnimState(newState)
    if currentAnimState == newState then return end
    currentAnimState = newState
    stopAllFlyAnims(0.15)

    if newState == "idle" then
        if floatMode then
            if floatAnimTrack then
                floatAnimTrack:Play(0.2)
                task.defer(function()
                    floatAnimTrack:AdjustSpeed(0)
                    floatAnimTrack.TimePosition = 0.7
                end)
            end
        else
            idleAnimT = 0
            if idleTrack then
                idleTrack:Play(0.2)
                task.defer(function()
                    idleTrack:AdjustSpeed(0)
                    idleTrack.TimePosition = CFG.IDLE_FREEZE_TIME
                end)
            end
        end

    elseif newState == "forward" or newState == "backward" then
        local track = newState == "forward" and forwardTrack or backwardTrack
        if track then
            track:Play(0.2)
            task.defer(function()
                track:AdjustSpeed(0); track.TimePosition = 0.1
            end)
        end

    elseif newState == "boost" then
        boostFrozen = false
        if boostTrack then
            boostTrack:Play(0.15)
            task.defer(function()
                boostTrack.TimePosition = 0.4; boostTrack:AdjustSpeed(1)
            end)
        end
    end
end

local function playLanding(hrp)
    if landConn then landConn:Disconnect(); landConn = nil end
    if not landTrack then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    landTrack:Play(0.1); landTrack:AdjustSpeed(1)
    local frozen = false
    landConn = RunService.RenderStepped:Connect(function()
        if not hrp or not hrp.Parent then landConn:Disconnect(); landConn = nil; return end
        local st = hum:GetState()
        local grounded = st == Enum.HumanoidStateType.Running
            or st == Enum.HumanoidStateType.RunningNoPhysics
            or st == Enum.HumanoidStateType.Landed
            or st == Enum.HumanoidStateType.Seated
        if not frozen and landTrack.TimePosition >= 0.1 then landTrack:AdjustSpeed(0); frozen = true end
        if frozen and (hrp.Position.Y <= -0.7 or grounded) then landTrack:AdjustSpeed(1); frozen = false end
        if not landTrack.IsPlaying then landConn:Disconnect(); landConn = nil end
    end)
end

local function activateBoost()
    if not flying then return end
    boostActive = true
    _G.BoostActive = true
    flySound.PlaybackSpeed = 1.35; flySound.Volume = 2
    if not flySound.IsPlaying then flySound:Play() end
    boostSound:Stop(); boostSound:Play()
    spawnBoostVfx()
    
    TweenService:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 90}):Play()
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do
                if t ~= boostTrack then t:Stop(0.05) end
            end
        end
    end
    
    playBoostEffects()
end

local function deactivateBoost()
    boostActive = false
    _G.BoostActive = false
    flySound.PlaybackSpeed = 1.05; flySound.Volume = 1.4
    destroyBoostVfx()
    
    TweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
    
    stopBoostEffects()
end

local function startFlying()
    if flySystemDead then return end  
    if flying then return end
    if landConn    then landConn:Disconnect();    landConn    = nil end
    if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end
    if landTrack and landTrack.IsPlaying then landTrack:Stop(0.2) end

    local char = player.Character
    if not char then return end
    setupAnimations(char)

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    flying           = true
    currentAnimState = ""
    hoverBobT        = 0
    baseHoverY       = hrp.Position.Y
    wasIdle          = false
    boostFrozen      = false
    
    prevCameraAngleY = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
    tiltSmoothed     = 0

    hum.PlatformStand = true

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P         = 30000
    bodyGyro.Parent    = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.Parent   = hrp

    if animConn then animConn:Disconnect() end
    animConn = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end

        
        if currentAnimState == "idle" and floatMode then
            if floatAnimTrack and floatAnimTrack.IsPlaying then
                floatAnimTrack:AdjustSpeed(0)
                floatAnimTrack.TimePosition = 0.7
            end
        
        elseif currentAnimState == "idle" and not floatMode then
            if idleTrack and idleTrack.IsPlaying and idleTrack.TimePosition ~= CFG.IDLE_FREEZE_TIME then
                idleTrack:AdjustSpeed(0)
                idleTrack.TimePosition = CFG.IDLE_FREEZE_TIME
            end
        end

        if currentAnimState == "forward"  and forwardTrack  and forwardTrack.IsPlaying  then forwardTrack.TimePosition  = 0.1 end
        if currentAnimState == "backward" and backwardTrack and backwardTrack.IsPlaying then backwardTrack.TimePosition = 0.1 end

        
        if currentAnimState == "boost" and boostTrack and boostTrack.IsPlaying then
            local char2 = player.Character
            if char2 then
                local hum2 = char2:FindFirstChildOfClass("Humanoid")
                if hum2 then
                    for _, t in pairs(hum2:GetPlayingAnimationTracks()) do
                        if t ~= boostTrack then t:Stop(0) end
                    end
                end
            end
            if not boostFrozen then
                if boostTrack.TimePosition >= 0.7 then
                    boostFrozen = true; boostTrack:AdjustSpeed(0); boostTrack.TimePosition = 0.7
                end
            else
                boostTrack.TimePosition = 0.7
            end
        end
    end)

    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flying or not hrp.Parent then return end

        local controls = PlayerModule:GetControls()
        local mv       = controls:GetMoveVector()

        local isMoving   = mv.Magnitude > 0.1 or math.abs(verticalInput) > 0.1
        local isBackward = isMoving and mv.Z > 0.1 and mv.Z > math.abs(mv.X)

        if boostActive and (not isMoving or isBackward) then deactivateBoost() end

        local spd     = boostActive and CFG.BOOST_SPEED or CFG.NORMAL_SPEED
        local nowIdle = not isMoving and not boostActive

        if nowIdle then
            if not wasIdle then baseHoverY = hrp.Position.Y; hoverBobT = 0 end
            hoverBobT = hoverBobT + dt
            local targetY = baseHoverY + math.sin(hoverBobT * CFG.HOVER_FREQ * math.pi * 2) * CFG.HOVER_AMP
            bodyVelocity.Velocity = Vector3.new(0, (targetY - hrp.Position.Y) * CFG.HOVER_SPRING, 0)
        else
            baseHoverY = hrp.Position.Y
            local moveDir = camera.CFrame:VectorToWorldSpace(Vector3.new(mv.X, verticalInput, mv.Z))
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
            bodyVelocity.Velocity = moveDir * spd
        end
        wasIdle = nowIdle

        if not nowIdle then
            if not flySound.IsPlaying then flySound.Volume = boostActive and 2 or 1.4; flySound:Play() end
        else
            if flySound.IsPlaying then fadeOutSound(0.6) end
        end

        local desired
        if boostActive      then desired = "boost"
        elseif isMoving     then desired = isBackward and "backward" or "forward"
        else                     desired = "idle" end

        setAnimState(desired)

        
        local currentAngleY = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
        local deltaAngle    = currentAngleY - prevCameraAngleY
        if deltaAngle >  math.pi then deltaAngle = deltaAngle - 2*math.pi end
        if deltaAngle < -math.pi then deltaAngle = deltaAngle + 2*math.pi end
        prevCameraAngleY = currentAngleY

        
        local targetTilt = 0
        if boostActive then
            local camTurnSpeed = deltaAngle / math.max(dt, 0.001)
            local dynamicTilt  = math.clamp(camTurnSpeed * TILT_SENSITIVITY, -math.rad(54), math.rad(47))
            targetTilt = math.rad(31) + dynamicTilt
        end
        tiltSmoothed = tiltSmoothed + (targetTilt - tiltSmoothed) * math.min(dt * 2.5, 1)

        bodyGyro.CFrame = camera.CFrame * CFrame.Angles(0, 0, tiltSmoothed)
    end)
end

local function stopFlying()
    if not flying then return end
    flying = false; boostActive = false; boostFrozen = false; floatMode = false

    destroyBoostVfx()

    if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if flyConn      then flyConn:Disconnect();   flyConn      = nil end
    if animConn     then animConn:Disconnect();  animConn     = nil end

    local char = player.Character; local hrp = nil
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
        hrp = char:FindFirstChild("HumanoidRootPart")
    end

    if flySound.IsPlaying then fadeOutSound(0.8) end
    stopAllFlyAnims(0.3)
    flySound.PlaybackSpeed = 1.05
    
    TweenService:Create(camera, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
    startLandVfxMonitor()
    if hrp and landTrack then playLanding(hrp) end

    verticalInput = 0; currentAnimState = ""; wasIdle = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if flySystemDead then return end  

    if input.KeyCode == Enum.KeyCode.LeftControl then
        if flying then stopFlying() else startFlying() end

    elseif input.KeyCode == Enum.KeyCode.W then
        if not flying then return end
        local now = os.clock()
        if now - lastWTapTime <= DOUBLE_TAP_TIME then
            if boostActive then deactivateBoost() else activateBoost() end
            lastWTapTime = 0 
        else
            lastWTapTime = now
        end
    end
end)

local character  = player.Character or player.CharacterAdded:Wait()
local humanoid   = character:WaitForChild("Humanoid")
local rootPart   = character:WaitForChild("HumanoidRootPart")
local drAnimator = humanoid:WaitForChild("Animator")

local original  = player.PlayerGui.Main.Controls.Moveset['Manji Kick']
local newButton = original:Clone()
newButton.Name          = "destructive rush"
newButton.ItemName.Text = "destructive rush"
newButton.Parent        = original.Parent
newButton.Key.Key.Text  = "5"

newButton.Key.Key:GetPropertyChangedSignal("Text"):Connect(function()
    if newButton.Key.Key.Text ~= "5" then
        newButton.Key.Key.Text = "5"
    end
end)

newButton:GetPropertyChangedSignal("Visible"):Connect(function()
    if not isDeadCleanup and not newButton.Visible then
        newButton.Visible = true
    end
end)

local cooldownFrame = newButton:FindFirstChild("Cooldown")
local uiGradient    = cooldownFrame and cooldownFrame:FindFirstChildOfClass("UIGradient")

if cooldownFrame and not uiGradient then
    uiGradient = Instance.new("UIGradient"); uiGradient.Parent = cooldownFrame
end
if cooldownFrame then
    cooldownFrame.BackgroundColor3       = Color3.fromRGB(0, 170, 255)
    cooldownFrame.BackgroundTransparency = 0.3
    cooldownFrame.ZIndex                 = newButton.ZIndex + 3
    cooldownFrame.Visible                = false
end
if uiGradient then
    uiGradient.Color        = ColorSequence.new(Color3.fromRGB(255,255,255))
    uiGradient.Rotation     = 90
    uiGradient.Transparency = NumberSequence.new(0)
end

local function playCooldownVisual()
    if not cooldownFrame or not uiGradient then return end
    cooldownFrame.Visible   = true
    uiGradient.Transparency = NumberSequence.new(0)
    local startTime = tick(); local cdConn
    cdConn = RunService.RenderStepped:Connect(function()
        local p = math.clamp((tick() - startTime) / COOLDOWN, 0, 1)
        if p >= 1 then cdConn:Disconnect(); cooldownFrame.Visible = false; return end
        if p <= 0.001 then
            uiGradient.Transparency = NumberSequence.new(0)
        else
            uiGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,                       1),
                NumberSequenceKeypoint.new(p,                       1),
                NumberSequenceKeypoint.new(math.min(p+0.001, 1),   0),
                NumberSequenceKeypoint.new(1,                       0),
            })
        end
    end)
end

local shakeIntensity = 0; local shakeFading = false; local shakeConn = nil

local function startShake(intensity)
    shakeIntensity = intensity; shakeFading = false
    if shakeConn then shakeConn:Disconnect() end
    shakeConn = RunService.RenderStepped:Connect(function(dt)
        if shakeIntensity <= 0 then
            if shakeConn then shakeConn:Disconnect(); shakeConn = nil end; return
        end
        local rx = (math.random()-0.5)*2*shakeIntensity
        local ry = (math.random()-0.5)*2*shakeIntensity
        local rz = (math.random()-0.5)*2*shakeIntensity
        camera.CFrame = camera.CFrame * CFrame.new(rx,ry,0) * CFrame.Angles(math.rad(rz*0.4), math.rad(rx*0.2), 0)
        if shakeFading then
            shakeIntensity = shakeIntensity - (shakeIntensity * dt * 3)
            if shakeIntensity < 0.002 then shakeIntensity = 0 end
        end
    end)
end

local function fadeShake() shakeFading = true end
local function stopShake()
    shakeIntensity = 0; shakeFading = false
    if shakeConn then shakeConn:Disconnect(); shakeConn = nil end
end

local function loadDRAnim(id)
    local a = Instance.new("Animation"); a.AnimationId = id
    return drAnimator:LoadAnimation(a)
end

local drActive = false

local function triggerDestructiveRush()
    if flySystemDead then return end  
    if drActive then return end
    drActive = true
    playCooldownVisual()

    humanoid.PlatformStand = true
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Parent = rootPart

    
    local drGyro = Instance.new("BodyGyro")
    drGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    drGyro.P         = 50000
    drGyro.D         = 500
    local look = rootPart.CFrame.LookVector
    drGyro.CFrame    = CFrame.new(Vector3.zero, Vector3.new(look.X, 0, look.Z))
    drGyro.Parent    = rootPart

    
    local startTrack = loadDRAnim(DR_STARTUP)
    startTrack.Priority = Enum.AnimationPriority.Action4
    startTrack:Play(BLEND); startTrack.TimePosition = 0
    startShake(0.09)

    
    local drStartVfxClone = ReplicatedStorage.Utils.Mechamaru.EjectDeathVFX.DustLand2.VFX.extra2:Clone()
    drStartVfxClone.Parent = rootPart
    for _, child in ipairs(drStartVfxClone:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child:Emit(15); child.Enabled = true
        end
    end

    local frozen = false; local conn
    conn = RunService.Heartbeat:Connect(function()

        if not frozen and startTrack.TimePosition >= 0.3 then
            frozen = true; startTrack:AdjustSpeed(0)
            task.wait(1); startTrack:AdjustSpeed(1)
        end

        if frozen and startTrack.TimePosition >= 0.6 then
            conn:Disconnect(); fadeShake()

            
            local riseTrack = loadDRAnim(DR_RISE)
            riseTrack.Priority = Enum.AnimationPriority.Action4
            riseTrack.Looped   = true
            riseTrack:Play(BLEND); riseTrack.TimePosition = 4.1; riseTrack:AdjustSpeed(0)
            startTrack:Stop(BLEND)

            
            if drStartVfxClone then
                for _, child in ipairs(drStartVfxClone:GetChildren()) do
                    if child:IsA("ParticleEmitter") then child.Enabled = false end
                end
                local refS = drStartVfxClone; drStartVfxClone = nil
                task.delay(2, function() if refS and refS.Parent then refS:Destroy() end end)
            end

            
            local risingAnchor = Instance.new("Part")
            risingAnchor.Anchored     = true
            risingAnchor.CanCollide   = false
            risingAnchor.CastShadow   = false
            risingAnchor.Transparency = 1
            risingAnchor.Size         = Vector3.new(1, 1, 1)
            risingAnchor.CFrame       = rootPart.CFrame
            risingAnchor.Parent       = workspace

            local risingVfxClone = ReplicatedStorage.Utils.Mechamaru.DeathVFX.DustLand:Clone()
            risingVfxClone.Parent = risingAnchor
            for _, child in ipairs(risingVfxClone:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    child:Emit(15); child.Enabled = true
                end
            end

            task.delay(0.5, function()
                if risingVfxClone and risingVfxClone.Parent then
                    for _, child in ipairs(risingVfxClone:GetChildren()) do
                        if child:IsA("ParticleEmitter") then child.Enabled = false end
                    end
                end
                task.delay(2, function()
                    if risingAnchor and risingAnchor.Parent then risingAnchor:Destroy() end
                end)
            end)

            
            local risingSound = Instance.new("Sound")
            risingSound.SoundId = "rbxassetid://90269024228015"
            risingSound.Volume  = 1
            risingSound.Parent  = SoundService
            risingSound:Play()
            game:GetService("Debris"):AddItem(risingSound, 10)

            local tween = TweenService:Create(
                rootPart,
                TweenInfo.new(RISE_SPEED, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                { CFrame = rootPart.CFrame + Vector3.new(0, RISE_HEIGHT, 0) }
            )
            tween:Play()

            tween.Completed:Connect(function()
                stopShake(); riseTrack:Stop(BLEND)

                
                bv:Destroy()
                
                if drGyro then drGyro:Destroy(); drGyro = nil end
                floatMode = true
                startFlying()

                task.wait(FLOAT_TIME)

                floatMode        = false
                currentAnimState = ""

                task.wait(COOLDOWN)
                drActive = false
            end)
        end
    end)
end

local drClickBtn = Instance.new("TextButton")
drClickBtn.Size                   = UDim2.new(1, 0, 1, 0)
drClickBtn.Position               = UDim2.new(0, 0, 0, 0)
drClickBtn.BackgroundTransparency = 1
drClickBtn.Text                   = ""
drClickBtn.ZIndex                 = newButton.ZIndex + 5
drClickBtn.Parent                 = newButton
drClickBtn.MouseButton1Click:Connect(triggerDestructiveRush)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Five then
        triggerDestructiveRush()
    end
end)

local function cleanupOnDeath()
    
    if isDeadCleanup then return end
    
    isDeadCleanup = true
    flySystemDead = true  

    
    pcall(function() if flying then stopFlying() end end)

    pcall(function() if flyConn     then flyConn:Disconnect();     flyConn     = nil end end)
    pcall(function() if animConn    then animConn:Disconnect();    animConn    = nil end end)
    pcall(function() if landConn    then landConn:Disconnect();    landConn    = nil end end)
    pcall(function() if landVfxConn then landVfxConn:Disconnect(); landVfxConn = nil end end)
    pcall(function() if shakeConn   then shakeConn:Disconnect();   shakeConn   = nil end end)
    pcall(function() if _G.__FlySystemThrowBoostConn then _G.__FlySystemThrowBoostConn:Disconnect(); _G.__FlySystemThrowBoostConn = nil end end)

    pcall(function() if bodyGyro     then bodyGyro:Destroy();     bodyGyro     = nil end end)
    pcall(function() if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end end)

    pcall(destroyBoostVfx)
    pcall(stopBoostEffects)

    pcall(function() flySound:Stop();   flySound:Destroy()   end)
    pcall(function() boostSound:Stop(); boostSound:Destroy() end)

    
    pcall(function() if newButton and newButton.Parent then newButton:Destroy() end end)

    
    pcall(function() if gui and gui.Parent then gui:Destroy() end end)

    pcall(function() if camera then camera.FieldOfView = 70 end end)

    flying           = false
    boostActive      = false
    boostFrozen      = false
    floatMode        = false
    drActive         = false
    verticalInput    = 0
    currentAnimState = ""

    
    pcall(function() script:Destroy() end)
end

_G.__FlySystemCleanup = cleanupOnDeath

local deathConn
local function bindDeathHandler(char)
    if deathConn then deathConn:Disconnect(); deathConn = nil end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not hum then return end
    if hum.Health <= 0 then
        cleanupOnDeath()
        return
    end
    deathConn = hum.Died:Connect(cleanupOnDeath)
end

bindDeathHandler(character)
player.CharacterAdded:Connect(bindDeathHandler)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
	character = char
	root = char:WaitForChild("HumanoidRootPart")
end)

local RightActivated = ReplicatedStorage
	:WaitForChild("Knit")
	:WaitForChild("Knit")
	:WaitForChild("Services")
	:WaitForChild("ItadoriService")
	:WaitForChild("RE")
	:WaitForChild("RightActivated")

local ThrowableFolder = Workspace.Map.Destructible:WaitForChild("Throwable")

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude
overlapParams.FilterDescendantsInstances = {character}

local throwBoostConn
throwBoostConn = RunService.Heartbeat:Connect(function()
	if not _G.BoostActive then
		return
	end

	if not character or not root then
		return
	end

	overlapParams.FilterDescendantsInstances = {character}

	local parts = Workspace:GetPartBoundsInRadius(
		root.Position + root.CFrame.LookVector * 12,
		8, 
		overlapParams
	)

	for _, part in ipairs(parts) do
		if part:IsDescendantOf(ThrowableFolder) then
			RightActivated:FireServer()
			break
		end
	end
end)

_G.__FlySystemThrowBoostConn = throwBoostConn

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ANIM_ID = "rbxassetid://127171275866632"

local HANG_SOUND_ID = "rbxassetid://82687386744947"
local HANG_SOUND_VOLUME = 0.3

local POSITION_OFFSET = Vector3.new(-0.1, -0.5, -2)
local ROTATION_OFFSET = Vector3.new(10, 180, 0)

local MAX_TARGET_DISTANCE = 15
local REMOTE_HIT_COUNT    = 4
local REMOTE_HIT_DELAY    = 0.5
local AFTER_LAST_HIT_DELAY = 0.45
local BUTTON_COOLDOWN     = 4

local function getRemote(...)
local path = { ... }
local ok, remote = pcall(function()
local node = ReplicatedStorage
for _, child in ipairs(path) do
node = node:WaitForChild(child, 5)
end
return node
end)
return ok and remote or nil
end

local activatedRemote = getRemote("Knit","Knit","Services","ItadoriService","RE","Activated")

if not activatedRemote then warn("[Choke] Activated remote not found!") end

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://3077287610"
clickSound.Volume = 4
clickSound.Parent = game:GetService("SoundService")

local active = false
local dead = false
local lockedTarget = nil
local animTrack = nil
local hangSound = nil
local healthWatchConn = nil
local lastActivationTime = -math.huge

local sequenceRunId = 0

local function getClosestTargetToCamera(hrp)
local closest = nil
local bestScore = -math.huge

local camPos     = camera.CFrame.Position    
local camForward = camera.CFrame.LookVector    

for _, model in pairs(workspace:GetDescendants()) do    
	if model:IsA("Model")    
		and model ~= player.Character    
		and model:FindFirstChild("Humanoid")    
		and model:FindFirstChild("HumanoidRootPart")    
		and model:FindFirstChild("Head") then    

		local hum = model:FindFirstChild("Humanoid")    

		if hum and hum.Health > 0 then    
			local targetHRP = model.HumanoidRootPart    
			local dist = (hrp.Position - targetHRP.Position).Magnitude    

			if dist <= MAX_TARGET_DISTANCE then    
				local toTarget = (targetHRP.Position - camPos)    
				local dot = camForward:Dot(toTarget.Unit)    

				if dot > 0.3 then    
					local score = dot - (dist / MAX_TARGET_DISTANCE)    
					if score > bestScore then    
						bestScore = score    
						closest = model    
					end    
				end    
			end    
		end    
	end    
end    

return closest

end

local function startHangSound(parent)
if hangSound then hangSound:Destroy() end
hangSound = Instance.new("Sound")
hangSound.SoundId = HANG_SOUND_ID
hangSound.Volume = HANG_SOUND_VOLUME
hangSound.Looped = true
hangSound.Parent = parent
hangSound:Play()
end

local function stopHangSound()
if hangSound then
hangSound:Stop()
hangSound:Destroy()
hangSound = nil
end
end

local function forceAnimation(humanoid)
if animTrack then
animTrack:Stop()
animTrack:Destroy()
end

local anim = Instance.new("Animation")    
anim.AnimationId = ANIM_ID    

animTrack = humanoid:LoadAnimation(anim)    
animTrack.Priority = Enum.AnimationPriority.Action4    
animTrack.Looped = true    

animTrack:Play(0)    
task.wait()    
animTrack.TimePosition = 1    
animTrack:AdjustSpeed(0)

end

local function releaseHold()
active = false
lockedTarget = nil

if animTrack then    
	animTrack:Stop()    
	animTrack:Destroy()    
	animTrack = nil    
end    

stopHangSound()    

if healthWatchConn then    
	healthWatchConn:Disconnect()    
	healthWatchConn = nil    
end    

local char = player.Character    
if char then    
	local hum = char:FindFirstChildOfClass("Humanoid")    
	if hum then    
		hum.AutoRotate = true    
	end    
end

end

local function watchMyHealth(humanoid)
if healthWatchConn then
healthWatchConn:Disconnect()
end

local lastHealth = humanoid.Health    

healthWatchConn = humanoid.HealthChanged:Connect(function(newHealth)    
	if newHealth < lastHealth and active then    
		print("[Choke] ضرر — تحرير الخنقة (السلسلة تكمل بالخلفية)")    
		releaseHold()    
	end    
	lastHealth = newHealth    
end)

end

local function runRemoteSequence(myId)
if not activatedRemote then return end

for i = 1, REMOTE_HIT_COUNT do    
	if myId ~= sequenceRunId then    
		print("[Choke] أُلغيت عند Punch " .. i .. " (سلسلة جديدة/إلغاء يدوي)")    
		return    
	end    

	pcall(function()    
		activatedRemote:FireServer(false)    
	end)    
	print("[Choke] Punch " .. i .. " ✅")    

	if i < REMOTE_HIT_COUNT then    
		local startWait = tick()    
		repeat    
			RunService.Heartbeat:Wait()    
		until tick() - startWait >= REMOTE_HIT_DELAY or myId ~= sequenceRunId    

		if myId ~= sequenceRunId then return end    
	end    
end    

print("[Choke] اكتملت 4 ضربات — ننتظر " .. AFTER_LAST_HIT_DELAY .. "s ثم إيقاف")    

local waitStart = tick()    
repeat    
	RunService.Heartbeat:Wait()    
until tick() - waitStart >= AFTER_LAST_HIT_DELAY or myId ~= sequenceRunId    

if myId == sequenceRunId then    
	print("[Choke] إيقاف نهائي بعد 4 Punch")    
	releaseHold()    
end

end

local function tryToggle()
if dead then return end

local char = player.Character
if not char then return end

local hrp = char:FindFirstChild("HumanoidRootPart")    
local humanoid = char:FindFirstChildOfClass("Humanoid")    

if not hrp or not humanoid then return end    

if not active then    
	local now = tick()    
	local elapsed = now - lastActivationTime    
	if elapsed < BUTTON_COOLDOWN then    
		print(string.format("[Choke] كولداون — انتظر %.1f ثانية", BUTTON_COOLDOWN - elapsed))    
		return    
	end    

	local target = getClosestTargetToCamera(hrp)    

	if not target then    
		print("[Choke] ما في هدف ضمن " .. MAX_TARGET_DISTANCE .. " studs من الكاميرا")    
		return    
	end    

	clickSound:Play()    

	active = true    
	lockedTarget = target    
	lastActivationTime = now    

	sequenceRunId += 1    
	local myId = sequenceRunId    

	forceAnimation(humanoid)    
	startHangSound(hrp)    
	watchMyHealth(humanoid)    

	humanoid.AutoRotate = false    

	task.spawn(function()    
		runRemoteSequence(myId)    
	end)    

else    
	clickSound:Play()    
	sequenceRunId += 1    
	releaseHold()    
end

end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end
if dead then return end

if input.KeyCode == Enum.KeyCode.R then
tryToggle()
end
end)

player.CharacterAdded:Connect(function()
task.wait(1)
print("[Choke] Character respawned — تحرير الجانب البصري فقط")
releaseHold()
end)

RunService.RenderStepped:Connect(function()
if not active then return end

local char = player.Character    
if not char then return end    

local hrp = char:FindFirstChild("HumanoidRootPart")    
local humanoid = char:FindFirstChildOfClass("Humanoid")    

if not hrp or not humanoid then return end    

if humanoid.Health <= 0 then    
	print("[Choke] موت حقيقي — تحرير الجانب البصري")    
	releaseHold()    
	return    
end    

if not lockedTarget or not lockedTarget.Parent then    
	return    
end    

local targetHum = lockedTarget:FindFirstChildOfClass("Humanoid")    

if not targetHum or targetHum.Health <= 0 then    
	return    
end    

local head = lockedTarget:FindFirstChild("Head")    

if not head then    
	return    
end    

if not hangSound or not hangSound.IsPlaying then    
	startHangSound(hrp)    
end    

if humanoid.AutoRotate then    
	humanoid.AutoRotate = false    
end    

local finalCFrame = head.CFrame    
	* CFrame.new(POSITION_OFFSET)    
	* CFrame.Angles(    
		math.rad(ROTATION_OFFSET.X),    
		math.rad(ROTATION_OFFSET.Y),    
		math.rad(ROTATION_OFFSET.Z)    
	)    

hrp.CFrame = finalCFrame    

if not animTrack or not animTrack.IsPlaying then    
	forceAnimation(humanoid)    
end    

if animTrack then    
	animTrack.TimePosition = 1    
	animTrack:AdjustSpeed(0)    
end

end)

local function destroyChoke()
	if dead then return end
	dead = true

	
	pcall(function()
		releaseHold()
	end)

	sequenceRunId += 1
	active = false
	lockedTarget = nil

	
	if clickSound then
		clickSound:Destroy()
	end

	if hangSound then
		hangSound:Destroy()
	end

	
	if healthWatchConn then
		healthWatchConn:Disconnect()
		healthWatchConn = nil
	end

	print("[Choke] Deleted forever after death")
end

_G.__ChokeCleanup = destroyChoke

local function setupDeath(char)
	local hum = char:WaitForChild("Humanoid")

	hum.Died:Connect(function()
		destroyChoke()
	end)
end

if player.Character then
	setupDeath(player.Character)
end

player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	destroyChoke()
end)
]=]

local SRC_MAIN = [=[
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UpdateGui = Instance.new("ScreenGui")
UpdateGui.Name = "ViltrumiteUpdate"
UpdateGui.ResetOnSpawn = false
UpdateGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UpdateGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,340,0,260)
Frame.Position = UDim2.new(0.5,-170,0.5,-130)
Frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame.BackgroundTransparency = 1
Frame.BorderSizePixel = 0
Frame.Parent = UpdateGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,18)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(150,150,150)
Stroke.Thickness = 1.5
Stroke.Transparency = 1
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.Position = UDim2.new(0,0,0,15)
Title.BackgroundTransparency = 1
Title.Text = "Viltrumite V3.1 Update"
Title.TextColor3 = Color3.fromRGB(150,150,150)
Title.TextTransparency = 1
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Text = Instance.new("TextLabel")
Text.Size = UDim2.new(1,-40,0,140)
Text.Position = UDim2.new(0,20,0,65)
Text.BackgroundTransparency = 1

Text.Text = [[
✅ Update Features:

• Improved Performance
• Fixed Skill 1 And Fly System
• Added New Finishers Animation
• Better Supports
• Fixed Minor Bugs
• New Skill
• Added Auto Throw In Boost Time
]]

Text.TextColor3 = Color3.fromRGB(100,100,100)
Text.TextTransparency = 1
Text.TextSize = 14
Text.Font = Enum.Font.Gotham
Text.TextXAlignment = Enum.TextXAlignment.Left
Text.TextYAlignment = Enum.TextYAlignment.Top
Text.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0,180,0,40)
Button.Position = UDim2.new(0.5,-90,1,-55)
Button.BackgroundColor3 = Color3.fromRGB(150,150,150)
Button.BackgroundTransparency = 1
Button.Text = "Continue"
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.TextTransparency = 1
Button.TextSize = 17
Button.Font = Enum.Font.GothamBold
Button.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0,12)
ButtonCorner.Parent = Button

TweenService:Create(Frame,TweenInfo.new(0.5),{
	BackgroundTransparency = 0.05
}):Play()

TweenService:Create(Stroke,TweenInfo.new(0.5),{
	Transparency = 0.5
}):Play()

TweenService:Create(Title,TweenInfo.new(0.5),{
	TextTransparency = 0
}):Play()

TweenService:Create(Text,TweenInfo.new(0.5),{
	TextTransparency = 0
}):Play()

TweenService:Create(Button,TweenInfo.new(0.5),{
	BackgroundTransparency = 0,
	TextTransparency = 0
}):Play()

Button.MouseEnter:Connect(function()

	TweenService:Create(Button,TweenInfo.new(0.15),{
		BackgroundColor3 = Color3.fromRGB(180,180,180)
	}):Play()

end)

Button.MouseLeave:Connect(function()

	TweenService:Create(Button,TweenInfo.new(0.15),{
		BackgroundColor3 = Color3.fromRGB(150,150,150)
	}):Play()

end)

Button.MouseButton1Click:Connect(function()

	local Time = 0.45

	TweenService:Create(Frame,TweenInfo.new(Time),{
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(Stroke,TweenInfo.new(Time),{
		Transparency = 1
	}):Play()

	for _,obj in pairs(Frame:GetDescendants()) do

		if obj:IsA("TextLabel") or obj:IsA("TextButton") then

			TweenService:Create(obj,TweenInfo.new(Time),{
				TextTransparency = 1
			}):Play()

		end

	end

	TweenService:Create(Button,TweenInfo.new(Time),{
		BackgroundTransparency = 1
	}):Play()

	task.wait(Time)

	UpdateGui:Destroy()

end)

Wait(3)

local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://82952123018614"

local Humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local Track = Humanoid:LoadAnimation(Anim)

Track:Play()
Track.TimePosition = 2.7

local s = Instance.new("Sound", game:GetService("SoundService"))
s.SoundId = "rbxassetid://131940521052115"
s.Volume = 1
s:Play()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local BlockService = ReplicatedStorage
	:WaitForChild("Knit")
	:WaitForChild("Knit")
	:WaitForChild("Services")
	:WaitForChild("BlockService")
	:WaitForChild("RE")

local Activated = BlockService:WaitForChild("Activated")
local Deactivated = BlockService:WaitForChild("Deactivated")

local ItadoriService = ReplicatedStorage
	:WaitForChild("Knit")
	:WaitForChild("Knit")
	:WaitForChild("Services")
	:WaitForChild("ItadoriService")
	:WaitForChild("RE")

local ItadoriActivated = ItadoriService:WaitForChild("Activated")

local BLOCK_ANIMATION = "rbxassetid://120133391090244"
local BLOCK_TRACK

local COUNTER_RANGE = 5   
local COUNTER_ANIMS = {
	"rbxassetid://103513893010999",
	"rbxassetid://103513893010999",
	"rbxassetid://111214152450580",
	"rbxassetid://85003123457049",
}

local function stopOriginalBlockAnimation()
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if track.Animation and track.Animation.AnimationId == "rbxassetid://101865783312435" then
			track:Stop(0)
		end
	end
end

local function playCustomBlockAnimation()
	stopOriginalBlockAnimation()

	if BLOCK_TRACK then
		BLOCK_TRACK:Stop()
		BLOCK_TRACK:Destroy()
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = BLOCK_ANIMATION

	BLOCK_TRACK = animator:LoadAnimation(anim)
	BLOCK_TRACK.Priority = Enum.AnimationPriority.Action
	BLOCK_TRACK.Looped = true
	BLOCK_TRACK:Play(0)
end

local function getClosestPlayerDistance()
	local char = player.Character
	if not char then return nil, nil end

	local myRoot = char:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil, nil end

	local closestPlayer = nil
	local closestDist = math.huge

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
			local theirHum   = p.Character:FindFirstChildOfClass("Humanoid")

			if theirRoot and theirHum and theirHum.Health > 0 then
				local dist = (myRoot.Position - theirRoot.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = p
				end
			end
		end
	end

	return closestPlayer, closestDist
end

local function playRandomCounterAnimation()
	local animId = COUNTER_ANIMS[math.random(1, #COUNTER_ANIMS)]

	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()

	print("[Block] 🎬 Counter animation: " .. animId)
	return track
end

local function checkCounterAttack()
	local closestPlayer, dist = getClosestPlayerDistance()

	if closestPlayer and dist and dist <= COUNTER_RANGE then
		print(string.format("[Block] لاعب قريب جداً (%.1f studs) — تفعيل الهجوم المضاد", dist))

		
		local args = { false }
		pcall(function()
			ItadoriActivated:FireServer(unpack(args))
		end)

		
		playRandomCounterAnimation()
	end
end

Activated:FireServer()
playCustomBlockAnimation()

checkCounterAttack()

Deactivated:FireServer()

if BLOCK_TRACK then
	BLOCK_TRACK:Stop(0)
	BLOCK_TRACK:Destroy()
	BLOCK_TRACK = nil
end

animator.AnimationPlayed:Connect(function(track)
	if track.Animation and track.Animation.AnimationId == "rbxassetid://101865783312435" then
		track:Stop(0)
	end
end)

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local animationConfig = {
    ["80843134889167"] = { id = "rbxassetid://103513893010999", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["85382723645632"] = { id = "rbxassetid://140381676724931", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["111902759344637"] = { id = "rbxassetid://111214152450580", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["90226048419187"] = { id = "rbxassetid://85003123457049", speed = 1,   timePos = 0,   fade = 0.1 }, 
}

local animationsToBlock = {}
for id in pairs(animationConfig) do
    animationsToBlock[tonumber(id)] = true
end

local queue = {}
local isAnimating = false

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
    track:Play(config.fade)                  
    track:AdjustSpeed(config.speed)          
    track.TimePosition = config.timePos      

    
    track.Stopped:Connect(function()
        isAnimating = false
        if #queue > 0 then
            playReplacement(table.remove(queue, 1))
        end
    end)
end

local function stopBlockedAnimations()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = tonumber(track.Animation.AnimationId:match("%d+"))
        if animationsToBlock[id] then
            track:Stop()
        end
    end
end

local function onAnimationPlayed(track)
    local id = tonumber(track.Animation.AnimationId:match("%d+"))
    if animationsToBlock[id] then
        stopBlockedAnimations()
        track:Stop()
        playReplacement(id)
    end
end

humanoid.AnimationPlayed:Connect(onAnimationPlayed)

local function clampBodyVelocity(obj)
    if obj:IsA("BodyVelocity") then
        obj.Velocity = Vector3.new(obj.Velocity.X, 0, obj.Velocity.Z)
    end
end

character.DescendantAdded:Connect(clampBodyVelocity)
for _, obj in ipairs(character:GetDescendants()) do
    clampBodyVelocity(obj)
end

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Effects = workspace:WaitForChild("Effects")

local white = Color3.new(1, 1, 1)

local function isMyEffect(effect)
	local char = LocalPlayer.Character
	if not char then return false end

	
	for _, obj in ipairs(effect:GetDescendants()) do
		if obj:IsA("Trail") then
			
			if obj.Attachment0 and obj.Attachment0:IsDescendantOf(char) then
				return true
			end
			if obj.Attachment1 and obj.Attachment1:IsDescendantOf(char) then
				return true
			end
		end
	end

	
	for _, obj in ipairs(effect:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Attachment") then
			
			for _, weld in ipairs(obj:GetChildren()) do
				if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
					local p0 = weld:IsA("Weld") and weld.Part0 or weld.Part0
					local p1 = weld:IsA("Weld") and weld.Part1 or weld.Part1
					if (p0 and p0:IsDescendantOf(char))
						or (p1 and p1:IsDescendantOf(char)) then
						return true
					end
				end
			end
		end
	end

	
	local myRoot = char:FindFirstChild("HumanoidRootPart")
	local effectPos = effect:IsA("BasePart") and effect.Position
		or (effect:FindFirstChildOfClass("BasePart") and effect:FindFirstChildOfClass("BasePart").Position)

	if myRoot and effectPos then
		local dist = (myRoot.Position - effectPos).Magnitude
		if dist < 5 then
			
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
					if theirRoot then
						local theirDist = (theirRoot.Position - effectPos).Magnitude
						
						if theirDist < dist then
							return false
						end
					end
				end
			end
			return true
		end
	end

	return false
end

local function applyWhite(obj)
	pcall(function()
		if obj:IsA("Trail") then
			obj.Color          = ColorSequence.new(white)
			obj.LightEmission  = 0
			obj.LightInfluence = 1

		elseif obj:IsA("Beam") then
			obj.Color          = ColorSequence.new(white)
			obj.LightEmission  = 0
			obj.LightInfluence = 1

		elseif obj:IsA("ParticleEmitter") then
			obj.Color         = ColorSequence.new(white)
			obj.LightEmission = 0
			obj.Enabled       = true

		elseif obj:IsA("BasePart") then
			obj.Color    = white
			obj.Material = Enum.Material.SmoothPlastic

		elseif obj:IsA("Highlight") then
			obj.FillColor    = white
			obj.OutlineColor = white

		elseif obj:IsA("Decal") then
			obj.Color3 = white

		elseif obj:IsA("Texture") then
			obj.Color3 = white
		end
	end)
end

local function makeCombatTrailWhite(effect)
	
	task.spawn(function()
		task.wait()

		
		if not isMyEffect(effect) then
			return  
		end

		for i = 1, 60 do
			if not effect or not effect.Parent then break end

			applyWhite(effect)
			for _, obj in ipairs(effect:GetDescendants()) do
				applyWhite(obj)
			end

			task.wait()
		end
	end)
end

local function clearAllEffects()
	for _, effect in ipairs(Effects:GetChildren()) do
		if effect.Name == "CombatTrail" then
			makeCombatTrailWhite(effect)
		end
	end
end

Effects.ChildAdded:Connect(function(child)
	if child.Name == "CombatTrail" then
		makeCombatTrailWhite(child)
	end
end)

clearAllEffects()

LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	clearAllEffects()
end)

local FLY_PROTECTED_IDS = {
    ["117844331774372"] = true, 
    ["9443519528"]       = true, 
    ["134581973800784"] = true, 
    ["128524425761051"] = true, 
    ["78540995456941"]  = true, 
    ["139078698020363"] = true, 
    ["136676738644802"] = true, 
    ["131522534497146"] = true, 
}

local function isFlyProtected(track)
    local id = track.Animation.AnimationId:match("%d+")
    return id and FLY_PROTECTED_IDS[id]
end

pcall(function() 
    getgenv().Idle:Disconnect() 
end)

getgenv().Idle = game.Players.LocalPlayer.Character.Humanoid.AnimationPlayed:Connect(function(v)

    local original1 = "rbxassetid://120133391090244"
    local original2 = "rbxassetid://138196552148011"
    local DR_FLOAT_ID = "131522534497146"

    if v.Animation.AnimationId == original1 or v.Animation.AnimationId == original2 then

        local humanoid = game.Players.LocalPlayer.Character.Humanoid

        
        for _, t in ipairs(humanoid:GetPlayingAnimationTracks()) do
            local id = t.Animation.AnimationId:match("%d+")
            if id == DR_FLOAT_ID then
                return
            end
        end

        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://117844331774372"

        local k = humanoid:LoadAnimation(Anim)

        k.Priority = Enum.AnimationPriority.Idle
        k.Looped = true
        k:Play(0.3)
        k:AdjustSpeed(0)

        local startTime = 0.157
        local endTime = 0.157
        local cycleDuration = 1.5
        local timeElapsed = 0

        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            timeElapsed = (timeElapsed + deltaTime) % (cycleDuration * 2)

            
            local stillSafe = true
            for _, t in ipairs(humanoid:GetPlayingAnimationTracks()) do
                local id = t.Animation.AnimationId:match("%d+")
                if id == DR_FLOAT_ID then
                    stillSafe = false
                    break
                end
            end
            if not stillSafe then
                k:Stop(0.1)
                connection:Disconnect()
                return
            end

            local alpha = (math.sin((timeElapsed / cycleDuration) * math.pi - math.pi / 2) + 1) / 2
            k.TimePosition = startTime + (endTime - startTime) * alpha
        end)

        v.Stopped:Wait()
        k:Stop(0.3)
        connection:Disconnect()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local cursedStrikeANIM = "rbxassetid://124901309160375"
local roughEnergyANIM  = "rbxassetid://72157009600725"
local luckyVolleyANIM  = "rbxassetid://113722638806911"
local Finisher1ANIM    = "rbxassetid://131506102901134"

local PLAY_DURATION   = 1.2
local DAMAGE_DISTANCE = 60
local DAMAGE_WAIT     = 1.5

local FINISHER1_START = 0.9
local FINISHER1_END   = 2

local isAnimationSequenceActive = false
local didDealDamage    = false
local positionAtStrike = nil

local trackedHumanoids = {}

local function trackHumanoid(humanoid)
	if trackedHumanoids[humanoid] then return end
	trackedHumanoids[humanoid] = true

	local lastHealth = humanoid.Health

	humanoid.HealthChanged:Connect(function(newHealth)
		local character = LocalPlayer.Character
		if not character then return end

		local myRoot    = character:FindFirstChild("HumanoidRootPart")
		local enemyRoot = humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")

		if not myRoot or not enemyRoot then return end

		local checkPos = positionAtStrike or myRoot.Position
		local dist = (checkPos - enemyRoot.Position).Magnitude

		if newHealth < lastHealth and dist <= DAMAGE_DISTANCE then
			didDealDamage = true
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

local function waitForDamage(timeout)
	local elapsed = 0
	while elapsed < timeout do
		if didDealDamage then return true end
		elapsed += task.wait(0.05)
	end
	return false
end

local noclipConn = nil

local function enableNoclip(character)
	
	if noclipConn then return end

	noclipConn = RunService.Stepped:Connect(function()
		if not character or not character.Parent then
			noclipConn:Disconnect()
			noclipConn = nil
			return
		end
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

local function disableNoclip(character)
	
	if noclipConn then
		noclipConn:Disconnect()
		noclipConn = nil
	end
	if not character or not character.Parent then return end
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = true
		end
	end
end

local function dashForward(character, duration)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then return end

	
	enableNoclip(character)

	local elapsed = 0
	local conn

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt

		if not rootPart or not rootPart.Parent then
			conn:Disconnect()
			disableNoclip(character)
			return
		end

		if elapsed >= duration then
			conn:Disconnect()
			rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			
			disableNoclip(character)
			return
		end

		local forwardDir = rootPart.CFrame.LookVector
		rootPart.AssemblyLinearVelocity = Vector3.new(
			forwardDir.X * 120,
			0,
			forwardDir.Z * 120
		)
	end)
end

local function launchUpward(character, duration)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then return end

	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	
	enableNoclip(character)

	local elapsed = 0
	local conn

	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt

		if not rootPart or not rootPart.Parent then
			conn:Disconnect()
			disableNoclip(character)
			return
		end

		if elapsed >= duration then
			conn:Disconnect()
			rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			
			disableNoclip(character)
			return
		end

		rootPart.AssemblyLinearVelocity = Vector3.new(
			rootPart.AssemblyLinearVelocity.X,
			220,
			rootPart.AssemblyLinearVelocity.Z
		)
	end)
end

local function resetState(tracks)
	for _, track in pairs(tracks) do
		pcall(function() track:Stop() end)
	end
	positionAtStrike          = nil
	didDealDamage             = false
	isAnimationSequenceActive = false
end

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

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		isAnimationSequenceActive = false
		return
	end

	local rootPart   = character:FindFirstChild("HumanoidRootPart")
	positionAtStrike = rootPart and rootPart.Position or nil
	didDealDamage    = false

	local enemyLowAtStart = false
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Parent ~= character then
			local enemyRoot = obj.Parent:FindFirstChild("HumanoidRootPart")
			if enemyRoot and rootPart then
				local dist = (rootPart.Position - enemyRoot.Position).Magnitude
				if dist <= DAMAGE_DISTANCE and obj.Health <= 16 then
					enemyLowAtStart = true
					break
				end
			end
		end
	end

	local animRoughEnergy = Instance.new("Animation")
	animRoughEnergy.AnimationId = roughEnergyANIM
	local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)

	local animLuckyVolley = Instance.new("Animation")
	animLuckyVolley.AnimationId = luckyVolleyANIM
	local trackLuckyVolley = animator:LoadAnimation(animLuckyVolley)

	local animFinisher1 = Instance.new("Animation")
	animFinisher1.AnimationId = Finisher1ANIM
	local trackFinisher1 = animator:LoadAnimation(animFinisher1)

	local allTracks = { trackRoughEnergy, trackLuckyVolley, trackFinisher1 }

	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	task.spawn(function()

		local ok, err = pcall(function()

			trackRoughEnergy:Play()
			trackRoughEnergy.TimePosition = 2
			task.wait(0.5)
			trackRoughEnergy:Stop(0.5)

			local damageConfirmed = waitForDamage(DAMAGE_WAIT)

			if damageConfirmed then

				
				dashForward(character, 0.5)

				trackLuckyVolley:Play()
				trackLuckyVolley.TimePosition = 0
				task.wait(0.5)
				trackLuckyVolley:Stop(0.5)

				if enemyLowAtStart then
					task.wait(0.1)

					local f1Duration = FINISHER1_END - FINISHER1_START

					
					launchUpward(character, f1Duration)

					trackFinisher1:Play()
					trackFinisher1.TimePosition = FINISHER1_START
					task.wait(f1Duration)
					trackFinisher1:Stop(0.2)

					task.wait(0.5)
				end
			end

			task.wait(PLAY_DURATION)

		end)

		if not ok then
			warn("[Skill2] Error:", err)
		end

		
		disableNoclip(LocalPlayer.Character)
		resetState(allTracks)
	end)
end

local function onAnimationPlayed(animationTrack)
	if animationTrack.Animation.AnimationId == cursedStrikeANIM then
		playAnimationSequence(LocalPlayer)
	end
end

local function setupHumanoid(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		disableNoclip(character)
		isAnimationSequenceActive = false
		didDealDamage             = false
		positionAtStrike          = nil
		script:Destroy()
	end)

	humanoid.AnimationPlayed:Connect(onAnimationPlayed)
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
setupHumanoid(character)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local cursedStrikeANIM = "rbxassetid://100962226150441"
local roughEnergyANIM  = "rbxassetid://86045680364061"

local PLAY_DURATION = 1.2
local isAnimationSequenceActive = false

local function findTargetInFront()
	local character = LocalPlayer.Character
	if not character then return nil end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return nil end

	local camCF      = workspace.CurrentCamera.CFrame
	local camPos     = camCF.Position
	local camForward = camCF.LookVector

	local bestTarget = nil
	local bestScore  = -math.huge  

	
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Parent ~= character then
			local targetRoot = obj.Parent:FindFirstChild("HumanoidRootPart")
			if targetRoot and obj.Health > 0 then
				local toTarget = (targetRoot.Position - camPos)
				local dist     = toTarget.Magnitude
				local dot      = camForward:Dot(toTarget.Unit)

				
				if dot > 0.3 and dist < 80 then
					
					local score = dot - (dist / 80)
					if score > bestScore then
						bestScore  = score
						bestTarget = targetRoot
					end
				end
			end
		end
	end

	return bestTarget
end

local function rushToTarget(character, target)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or not target then return end

	
	local noclipConn = RunService.Stepped:Connect(function()
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not rootPart or not rootPart.Parent then
			conn:Disconnect()
			noclipConn:Disconnect()
			return
		end

		local toTarget = target.Position - rootPart.Position
		local dist     = toTarget.Magnitude

		
		if dist < 5 then
			conn:Disconnect()
			noclipConn:Disconnect()

			
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end

			rootPart.AssemblyLinearVelocity = Vector3.zero
			return
		end

		
		local dir = toTarget.Unit
		rootPart.AssemblyLinearVelocity = Vector3.new(
			dir.X * 120,
			0,
			dir.Z * 120
		)
	end)

	
	task.delay(0.4, function()
		if conn.Connected then
			conn:Disconnect()
			noclipConn:Disconnect()

			if rootPart and rootPart.Parent then
				rootPart.AssemblyLinearVelocity = Vector3.zero
				for _, part in pairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end)
end

local function playAnimationSequence(player)
	if isAnimationSequenceActive then return end
	isAnimationSequenceActive = true

	local character = player.Character
	if not character then isAnimationSequenceActive = false return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then isAnimationSequenceActive = false return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then isAnimationSequenceActive = false return end

	local animRoughEnergy = Instance.new("Animation")
	animRoughEnergy.AnimationId = roughEnergyANIM
	local trackRoughEnergy = animator:LoadAnimation(animRoughEnergy)

	for _, track in pairs(animator:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	task.spawn(function()

		local ok, err = pcall(function()

			
			local target = findTargetInFront()

			
			if target then
				rushToTarget(character, target)
			end

			task.wait()

			trackRoughEnergy:Play(0.2)
			trackRoughEnergy.TimePosition = 0.52
			trackRoughEnergy:AdjustSpeed(1)

			
			
			task.wait(0.18)

			
			trackRoughEnergy:AdjustSpeed(0)
			task.wait(0.2)

			
			trackRoughEnergy:AdjustSpeed(1)

			
			task.wait(1 - 0.18 - 0.2)
			trackRoughEnergy:Stop(0.5)

			task.wait(PLAY_DURATION)

		end)

		if not ok then
			warn("[Skill3] Error:", err)
		end

		isAnimationSequenceActive = false
		trackRoughEnergy:Stop()
	end)
end

local function onAnimationPlayed(animationTrack)
	if animationTrack.Animation.AnimationId == cursedStrikeANIM then
		playAnimationSequence(LocalPlayer)
	end
end

local function setupHumanoid(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		isAnimationSequenceActive = false
	end)

	humanoid.AnimationPlayed:Connect(onAnimationPlayed)
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
setupHumanoid(character)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	isAnimationSequenceActive = false
	setupHumanoid(newCharacter)
end)

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local animationConfig = {
    ["95295463826732"] = { id = "rbxassetid://96185406489877", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["124862357369335"] = { id = "rbxassetid://77583711129628", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["105077924973072"] = { id = "rbxassetid://117831239064143", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["92966188946988"] = { id = "rbxassetid://84989753395518", speed = 1,   timePos = 0,   fade = 0.1 }, 
    ["134243365075812"] = { id = "rbxassetid://83843118463884", speed = 1,   timePos = 0,   fade = 0.1 }, 
}

local animationsToBlock = {}
for id in pairs(animationConfig) do
    animationsToBlock[tonumber(id)] = true
end

local queue = {}
local isAnimating = false

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
    track:Play(config.fade)          
    track.TimePosition = config.timePos      

    
    track.Stopped:Connect(function()
        isAnimating = false
        if #queue > 0 then
            playReplacement(table.remove(queue, 1))
        end
    end)
end

local function stopBlockedAnimations()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local id = tonumber(track.Animation.AnimationId:match("%d+"))
        if animationsToBlock[id] then
            track:Stop()
        end
    end
end

local function onAnimationPlayed(track)
    local id = tonumber(track.Animation.AnimationId:match("%d+"))
    if animationsToBlock[id] then
        stopBlockedAnimations()
        track:Stop()
        playReplacement(id)
    end
end

humanoid.AnimationPlayed:Connect(onAnimationPlayed)

local function clampBodyVelocity(obj)
    if obj:IsA("BodyVelocity") then
        obj.Velocity = Vector3.new(obj.Velocity.X, 0, obj.Velocity.Z)
    end
end

character.DescendantAdded:Connect(clampBodyVelocity)
for _, obj in ipairs(character:GetDescendants()) do
    clampBodyVelocity(obj)
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local pl = Players.LocalPlayer
local ef = workspace:WaitForChild("Effects")
local ch = workspace:WaitForChild("Characters")

local ParticleHolder = RS.Utils.Damage.Explode.Head.Attachment

local activeEffects = {}

local function spawnHitEffect(enemyRoot)
    local test = ParticleHolder:Clone()
    test.Parent = enemyRoot
    table.insert(activeEffects, test)

    local emitters = {}
    for _, child in ipairs(test:GetChildren()) do
        if child:IsA("ParticleEmitter") then
            child:Emit(15)
            child.Enabled = true
            table.insert(emitters, child)
        end
    end

    task.spawn(function()
        task.wait(0.1)
        for _, emitter in ipairs(emitters) do
            if emitter.Parent then
                emitter.Enabled = false
            end
        end
        task.wait(0.5)
        if test.Parent then
            test:Destroy()
        end
        
        for i, v in ipairs(activeEffects) do
            if v == test then table.remove(activeEffects, i) break end
        end
    end)
end

local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        for _, effect in ipairs(activeEffects) do
            if effect and effect.Parent then
                effect:Destroy()
            end
        end
        activeEffects = {}
    end)
end

if pl.Character then onCharacterAdded(pl.Character) end
pl.CharacterAdded:Connect(onCharacterAdded)

local function watchEnemy(enemy)
    local eh = enemy:FindFirstChildOfClass("Humanoid")
    if not eh then return end
    local lastHp = eh.Health
    eh:GetPropertyChangedSignal("Health"):Connect(function()
        local newHp = eh.Health
        if newHp < lastHp then
            local char = ch:FindFirstChild(pl.Name)
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local er = enemy:FindFirstChild("HumanoidRootPart")
            if er and root and (er.Position - root.Position).Magnitude < 15 then
                spawnHitEffect(er)
            end
        end
        lastHp = newHp
    end)
end

for _, ec in ipairs(ch:GetChildren()) do
    if ec.Name ~= pl.Name then watchEnemy(ec) end
end
ch.ChildAdded:Connect(function(c)
    if c.Name ~= pl.Name then
        task.wait(0.2)
        watchEnemy(c)
    end
end)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local cursedStrikeANIM = "rbxassetid://77200218033775"
local roughEnergyANIM  = "rbxassetid://84039122607068"
local vesselMelee1     = "rbxassetid://129678103897608"
local vesselMelee2     = "rbxassetid://99920923658527"
local jumpANIM         = "rbxassetid://135411487367370"
local Finisher1ANIM    = "rbxassetid://106892235857467"
local Finisher2ANIM    = "rbxassetid://77624096831098"

local PLAY_DURATION   = 1.2
local DAMAGE_DISTANCE = 80
local DAMAGE_WAIT     = 1.5

local isAnimationSequenceActive = false
local didDealDamage    = false
local isJumping        = false
local positionAtStrike = nil

local flightConn  = nil
local flightSpeed = 150  

local trackedHumanoids = {}

local function trackHumanoid(humanoid)
	if trackedHumanoids[humanoid] then return end
	trackedHumanoids[humanoid] = true

	local lastHealth = humanoid.Health

	humanoid.HealthChanged:Connect(function(newHealth)
		local character = LocalPlayer.Character
		if not character then return end

		local myRoot    = character:FindFirstChild("HumanoidRootPart")
		local enemyRoot = humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")

		if not myRoot or not enemyRoot then return end

		local checkPos = positionAtStrike or myRoot.Position
		local dist = (checkPos - enemyRoot.Position).Magnitude

		if newHealth < lastHealth
			and dist <= DAMAGE_DISTANCE
			and isAnimationSequenceActive then
			didDealDamage = true
		end

		lastHealth = newHealth
	end)
end

task.spawn(function()
	while true do
		task.wait(1)
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("Humanoid") then
				trackHumanoid(obj)
			end
		end
	end
end)

local function stopFlight()
	if flightConn then
		flightConn:Disconnect()
		flightConn = nil
	end

	local character = LocalPlayer.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			
			rootPart.AssemblyLinearVelocity = Vector3.zero
		end
	end
end

local function launchPlayer(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid then return end

	stopFlight()

	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	local initDir    = workspace.CurrentCamera.CFrame.LookVector
	local upVelocity = math.sqrt(1.7 * workspace.Gravity * 100)
	rootPart.AssemblyLinearVelocity = (initDir * flightSpeed) + Vector3.new(0, upVelocity, 0)

	flightConn = RunService.Heartbeat:Connect(function()
		if not rootPart or not rootPart.Parent then
			stopFlight()
			return
		end
		local currentDir = workspace.CurrentCamera.CFrame.LookVector
		
		rootPart.AssemblyLinearVelocity = currentDir * flightSpeed
	end)
end

local function waitForDamage(timeout)
	local elapsed = 0
	while elapsed < timeout do
		if didDealDamage then return true end
		elapsed += task.wait(0.05)
	end
	return false
end

local function resetState(tracks)
	stopFlight()
	for _, track in pairs(tracks) do
		pcall(function() track:Stop() end)
	end
	positionAtStrike          = nil
	didDealDamage             = false
	isAnimationSequenceActive = false
	flightSpeed               = 150  
end

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

	local rootPart   = character:FindFirstChild("HumanoidRootPart")
	positionAtStrike = rootPart and rootPart.Position or nil
	didDealDamage    = false
	flightSpeed      = 150  

	
	local enemyLowAtStart = false
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Parent ~= character then
			local enemyRoot = obj.Parent:FindFirstChild("HumanoidRootPart")
			if enemyRoot and rootPart then
				local dist = (rootPart.Position - enemyRoot.Position).Magnitude
				if dist <= DAMAGE_DISTANCE and obj.Health <= 16 then
					enemyLowAtStart = true
					break
				end
			end
		end
	end

	local animRoughEnergy = Instance.new("Animation")
	animRoughEnergy.AnimationId = roughEnergyANIM
	local trackRoughEnergy = humanoid:LoadAnimation(animRoughEnergy)

	local animMelee1 = Instance.new("Animation")
	animMelee1.AnimationId = vesselMelee1
	local trackMelee1 = humanoid:LoadAnimation(animMelee1)

	local animMelee2 = Instance.new("Animation")
	animMelee2.AnimationId = vesselMelee2
	local trackMelee2 = humanoid:LoadAnimation(animMelee2)

	local animJump = Instance.new("Animation")
	animJump.AnimationId = jumpANIM
	local trackJump = humanoid:LoadAnimation(animJump)

	local animFinisher1 = Instance.new("Animation")
	animFinisher1.AnimationId = Finisher1ANIM
	local trackFinisher1 = humanoid:LoadAnimation(animFinisher1)

	local animFinisher2 = Instance.new("Animation")
	animFinisher2.AnimationId = Finisher2ANIM
	local trackFinisher2 = humanoid:LoadAnimation(animFinisher2)

	local allTracks = {
		trackRoughEnergy, trackMelee1, trackMelee2,
		trackJump, trackFinisher1, trackFinisher2
	}

	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	task.spawn(function()

		local ok, err = pcall(function()

			if not isJumping then
				trackRoughEnergy:Play()
				trackRoughEnergy.TimePosition = 0
				task.wait(0.5)
				trackRoughEnergy:Stop(0.5)
			end

			if isJumping then
				trackJump:Play()
				task.wait(0.51)
				trackJump:Stop(0.2)
				return
			end

			local damageConfirmed = waitForDamage(DAMAGE_WAIT)

			if damageConfirmed then

				
				flightSpeed = 150
				launchPlayer(character)

				trackMelee1:Play()
				task.wait(1.2)
				trackMelee1:Stop(0.5)

				task.wait(0.3)

				trackMelee2:Play()
				trackMelee2.TimePosition = 3.1

				local melee2Duration = trackMelee2.Length - 3.1
				if melee2Duration <= 0 then melee2Duration = 1.5 end

				if enemyLowAtStart and didDealDamage then

					task.wait(melee2Duration - 0.15)
					trackMelee2:Stop(0.15)

					
					flightSpeed = 30

					
					trackFinisher1:Play()
					local f1Duration = trackFinisher1.Length > 0 and trackFinisher1.Length or 2
					task.wait(f1Duration)
					trackFinisher1:Stop(0.3)

					task.wait(0.1)

					
					trackFinisher2:Play()
					trackFinisher2.TimePosition = 5.4
					trackFinisher2:AdjustSpeed(1.3)
					local f2Duration = trackFinisher2.Length > 0
						and ((trackFinisher2.Length - 5.4) / 1.3)
						or 2
					if f2Duration <= 0 then f2Duration = 1 end
					task.wait(f2Duration)
					trackFinisher2:Stop(0.3)

					
					stopFlight()

				else
					task.wait(melee2Duration)
					trackMelee2:Stop(0.5)

					
					stopFlight()
				end
			end

			task.wait(PLAY_DURATION)

		end)

		if not ok then
			warn("[Skill1] Error:", err)
		end

		resetState(allTracks)
	end)
end

local function onAnimationPlayed(animationTrack)
	if animationTrack.Animation.AnimationId == cursedStrikeANIM then
		playAnimationSequence(LocalPlayer)
	end
end

local function setupJumpTracking(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Jumping
			or newState == Enum.HumanoidStateType.Freefall then
			isJumping = true
		else
			isJumping = false
		end
	end)
end

local function setupAnimationListener(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		stopFlight()
		isAnimationSequenceActive = false
		didDealDamage             = false
		positionAtStrike          = nil
		isJumping                 = false
		flightSpeed               = 150
	end)

	local animator = humanoid:WaitForChild("Animator")
	animator.AnimationPlayed:Connect(onAnimationPlayed)
	setupJumpTracking(character)
end

if LocalPlayer.Character then
	setupAnimationListener(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
	stopFlight()
	isAnimationSequenceActive = false
	didDealDamage             = false
	positionAtStrike          = nil
	isJumping                 = false
	flightSpeed               = 150
	setupAnimationListener(character)
end)

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local function applyChanges()
	local main = gui:FindFirstChild("Main")
	if not main then return end

	local controls = main:FindFirstChild("Controls")
	if not controls then return end

	local moveset = controls:FindFirstChild("Moveset")
	if not moveset then return end

	local ultimate = controls:FindFirstChild("Ultimate")
	if not ultimate then return end

	
	pcall(function()
		moveset['Cursed Strikes'].ItemName.Text = "Flight Strike"
		moveset['Crushing Blow'].ItemName.Text = "Base Killer"
		moveset['Divergent Fist'].ItemName.Text = "Deadly punch"
		moveset['Divergent Fist'].Tip.Text = "Body Blower"
		moveset['Manji Kick'].ItemName.Text = "Too weak"
	end)

	
	pcall(function()
		ultimate.Bar.Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
		ultimate.Special.Fill.BackgroundColor3 = Color3.fromRGB(100,100,100)

		ultimate.Bar.Fill.UIGradient.Color = ColorSequence.new(
			Color3.fromRGB(100,100,100),
			Color3.fromRGB(255,255,255)
		)

		ultimate.Special.Fill.UIGradient.Color = ColorSequence.new(
			Color3.fromRGB(100,100,100),
			Color3.fromRGB(255,255,255)
		)

		ultimate.Title.Text = "The Empire's Final Weapon"
	end)
end

applyChanges()

gui.DescendantAdded:Connect(function(obj)
	task.wait(0.01)
	applyChanges()
end)

while task.wait(1) do
	applyChanges()
end
]=]

local SRC_ESP = [=[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local SHOW_DISTANCE = 30 

local function createMarker(player)
	if player == LocalPlayer then
		return
	end

	
	if not player:IsFriendsWith(LocalPlayer.UserId) then
		return
	end

	local function setup(character)
		local head = character:WaitForChild("Head")

		if head:FindFirstChild("TeamESP") then
			head.TeamESP:Destroy()
		end

		local gui = Instance.new("BillboardGui")
		gui.Name = "TeamESP"
		gui.Size = UDim2.fromOffset(20, 20)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.Enabled = false
		gui.Parent = head

		local bg = Instance.new("Frame")
		bg.Size = UDim2.fromScale(1, 1)
		bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		bg.BorderSizePixel = 0
		bg.Parent = gui

		local bgCorner = Instance.new("UICorner")
		bgCorner.CornerRadius = UDim.new(1, 0)
		bgCorner.Parent = bg

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.new(1, 1, 1)
		stroke.Parent = bg

		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 1
		image.Size = UDim2.fromScale(0.82, 0.82)
		image.Position = UDim2.fromScale(0.09, 0.09)
		image.Image = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
		image.Parent = bg

		local imgCorner = Instance.new("UICorner")
		imgCorner.CornerRadius = UDim.new(1, 0)
		imgCorner.Parent = image

		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not character.Parent then
				if connection then
					connection:Disconnect()
				end
				return
			end

			local myCharacter = LocalPlayer.Character
			if not myCharacter then
				gui.Enabled = false
				return
			end

			local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
			local targetRoot = character:FindFirstChild("HumanoidRootPart")

			if myRoot and targetRoot then
				local distance = (myRoot.Position - targetRoot.Position).Magnitude
				gui.Enabled = distance >= SHOW_DISTANCE
			else
				gui.Enabled = false
			end
		end)
	end

	if player.Character then
		setup(player.Character)
	end

	player.CharacterAdded:Connect(setup)
end

for _, player in ipairs(Players:GetPlayers()) do
	createMarker(player)
end

Players.PlayerAdded:Connect(createMarker)
]=]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SOUND_CLICK = "rbxassetid://96867813755421"

local function playSound(id, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = 1
	sound.Parent = parent
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 3)
end

local function runChunk(src)
	local fn = loadstring(src)
	if fn then
		pcall(fn)
	end
end

local function showCredit(deviceText)
	local CreditGui = Instance.new("ScreenGui")
	CreditGui.Name = "ViltrumiteCredit"
	CreditGui.ResetOnSpawn = false
	CreditGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	CreditGui.Parent = PlayerGui

	local CreditFrame = Instance.new("Frame")
	CreditFrame.Size = UDim2.new(0, 270, 0, 62)
	CreditFrame.Position = UDim2.new(0.5, -135, 1, 10)
	CreditFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CreditFrame.BackgroundTransparency = 0.05
	CreditFrame.BorderSizePixel = 0
	CreditFrame.Parent = CreditGui
	Instance.new("UICorner", CreditFrame).CornerRadius = UDim.new(0, 14)

	local CStroke = Instance.new("UIStroke")
	CStroke.Color = Color3.fromRGB(150, 150, 150)
	CStroke.Thickness = 1.5
	CStroke.Transparency = 0.5
	CStroke.Parent = CreditFrame

	local NameLbl = Instance.new("TextLabel")
	NameLbl.Size = UDim2.new(1, -20, 0, 30)
	NameLbl.Position = UDim2.new(0, 12, 0, 4)
	NameLbl.BackgroundTransparency = 1
	NameLbl.Text = "Viltrumite V3.1  |  " .. deviceText
	NameLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
	NameLbl.TextSize = 15
	NameLbl.Font = Enum.Font.GothamBold
	NameLbl.TextXAlignment = Enum.TextXAlignment.Left
	NameLbl.Parent = CreditFrame

	local CreditLbl = Instance.new("TextLabel")
	CreditLbl.Size = UDim2.new(1, -20, 0, 24)
	CreditLbl.Position = UDim2.new(0, 12, 0, 32)
	CreditLbl.BackgroundTransparency = 1
	CreditLbl.Text = "Make by Zorcex"
	CreditLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
	CreditLbl.TextSize = 12
	CreditLbl.Font = Enum.Font.Gotham
	CreditLbl.TextXAlignment = Enum.TextXAlignment.Left
	CreditLbl.Parent = CreditFrame

	TweenService:Create(CreditFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -135, 1, -75)
	}):Play()
	task.wait(4)
	TweenService:Create(CreditFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -135, 1, 10)
	}):Play()
	task.wait(0.45)
	CreditGui:Destroy()
end

local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Parent = Lighting

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViltrumiteSelector"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 300)
Main.Position = UDim2.new(0.5, -170, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(150, 150, 150)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 14)
Title.BackgroundTransparency = 1
Title.Text = "Viltrumite V3.1"
Title.TextColor3 = Color3.fromRGB(150, 150, 150)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, 0, 0, 24)
Sub.Position = UDim2.new(0, 0, 0, 58)
Sub.BackgroundTransparency = 1
Sub.Text = "Choose your device"
Sub.TextColor3 = Color3.fromRGB(100, 100, 100)
Sub.TextSize = 14
Sub.Font = Enum.Font.Gotham
Sub.Parent = Main

local function createButton(text, icon, yPos)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0, 280, 0, 64)
	Btn.Position = UDim2.new(0.5, -140, 0, yPos)
	Btn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	Btn.BorderSizePixel = 0
	Btn.Text = ""
	Btn.AutoButtonColor = false
	Btn.Parent = Main
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 14)

	local IconLabel = Instance.new("TextLabel")
	IconLabel.Size = UDim2.new(0, 50, 1, 0)
	IconLabel.Position = UDim2.new(0, 10, 0, 0)
	IconLabel.BackgroundTransparency = 1
	IconLabel.Text = icon
	IconLabel.TextSize = 26
	IconLabel.Font = Enum.Font.GothamBold
	IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	IconLabel.Parent = Btn

	local BtnLabel = Instance.new("TextLabel")
	BtnLabel.Size = UDim2.new(1, -70, 1, 0)
	BtnLabel.Position = UDim2.new(0, 60, 0, 0)
	BtnLabel.BackgroundTransparency = 1
	BtnLabel.Text = text
	BtnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	BtnLabel.TextSize = 18
	BtnLabel.Font = Enum.Font.GothamBold
	BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
	BtnLabel.Parent = Btn

	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
	end)
	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
	end)
	return Btn
end

local MobileBtn = createButton("Mobile version", "M", 100)
local PcBtn = createButton("PC version", "PC", 180)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 22)
Status.Position = UDim2.new(0, 0, 1, -28)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(120, 120, 120)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 10)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Main

local function closeGui()
	TweenService:Create(Main, TweenInfo.new(0.25), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
	TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
	task.wait(0.3)
	ScreenGui:Destroy()
	if blur and blur.Parent then
		blur:Destroy()
	end
end

CloseBtn.MouseButton1Click:Connect(function()
	playSound(SOUND_CLICK, CloseBtn)
	closeGui()
end)

local function startMobile()
	playSound(SOUND_CLICK, MobileBtn)
	Status.Text = "Loading Mobile..."
	task.wait(0.3)
	closeGui()
	task.spawn(showCredit, "Mobile")
	runChunk(SRC_MOBILE_FLY)
	runChunk(SRC_MAIN)
	runChunk(SRC_ESP)
end

local function startPC()
	playSound(SOUND_CLICK, PcBtn)
	Status.Text = "Loading PC..."
	task.wait(0.3)
	closeGui()
	task.spawn(showCredit, "PC")
	runChunk(SRC_PC_FLY)
	runChunk(SRC_MAIN)
	runChunk(SRC_ESP)
end

MobileBtn.MouseButton1Click:Connect(startMobile)
PcBtn.MouseButton1Click:Connect(startPC)

Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 340, 0, 300),
	Position = UDim2.new(0.5, -170, 0.5, -150)
}):Play()
