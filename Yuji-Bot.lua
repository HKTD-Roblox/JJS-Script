-- =====================================================
--   JJS BOT V40 YUJI ULTRA MASTERY - MADE BY HKTD Roblox
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =====================================================
--  CONFIG
-- =====================================================
local CFG = {
    targeting = {
        maxDist = 350,
        retargetDist = 40,
        teamCheck = true,
        targetNPCs = true,
        smartTarget = true,
        priorityHealth = true,
        updateRate = 0.15,
        predictiveTargeting = true,
        maxPredictionTime = 0.4,
    },
    
    combat = {
        attackRange = 8,
        minAttackRange = 2,
        optimalRange = 5,
        closeRange = 3,
        m1Delay = 0.175,
        m1Count = 3,
        perfectTiming = true,
        adaptiveDelay = true,
        trackingAccuracy = 0.95,
        autoAim = true,
        hitConfirmation = true,
        autoAttack = true,
        aggressiveMode = true,
        alwaysApproach = true,
    },
    
    skills = {
        globalCD = 0.8,
        adaptiveCD = true,
        smartUsage = true,
        comboIntegration = true,
        useMoreOften = true,
        
        [1] = { name = "Divergent Fist", cooldown = 2.0, range = 25, lastUsed = 0, useFrequency = 0.6 },
        [2] = { name = "Crushing Blow", cooldown = 2.5, range = 25, lastUsed = 0, useFrequency = 0.5 },
        [3] = { name = "Black Flash", cooldown = 1.8, range = 20, lastUsed = 0, useFrequency = 0.7 },
        [4] = { name = "Counter", cooldown = 3.5, range = 18, lastUsed = 0, useFrequency = 0.8 },
        
        keys = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four },
    },
    
    movement = {
        dashCooldown = 0.7,
        lateralDashCD = 0.6,
        dashMinDist = 8,
        dashMaxDist = 45,
        useLateralDash = true,
        lateralDashChance = 0.5,
        sideDashAttack = true,
        sideDashAttackRange = 25,
        sideDashAttackCD = 1.2,
        sideDashAttackChance = 0.4,
        ragdollSpeed = 40,
        ragdollDashCD = 0.3,
        approachRange = 10,
        kiteRange = 1.5,
        optimalDistance = 5,
        zigzagEnabled = true,
        zigzagInterval = {0.25, 0.6},
        zigzagStopDist = 3,
        obstacleRange = 10,
        obstacleJumpDelay = 0.15,
        predictionFactor = 0.3,
        smoothRotation = true,
        rotationSpeed = 0.4,
        alwaysForward = true,
    },
    
    defense = {
        blockEnabled = true,
        blockRange = 20,
        blockMinTime = 0.18,
        blockMaxTime = 0.45,
        blockCooldown = 0.4,
        counterEnabled = true,
        counterRange = 18,
        blockBreakEnabled = true,
        blockBreakRange = 16,
        blockBreakPriority = {1, 2, 3},
        instantPunish = true,
        punishDelay = 0.08,
    },
    
    camera = {
        lerpSpeed = 0.35,
        smoothAim = true,
        verticalOffset = 1.5,
    },
}

-- =====================================================
--  STATE
-- =====================================================
local STATE = {
    active = false,
    lastUpdate = 0,
    
    target = {
        root = nil, humanoid = nil, name = "", distance = 999,
        lastSeen = 0, predictedPos = Vector3.zero, velocity = Vector3.zero,
        isStunned = false, isBlocking = false, isAttacking = false, isUsingSkill = false,
        health = 100, maxHealth = 100,
    },
    
    player = {
        root = nil, humanoid = nil, character = nil,
        health = 100, maxHealth = 100, isRagdoll = false,
        velocity = Vector3.zero, position = Vector3.zero,
    },
    
    input = {
        holdW = false, holdA = false, holdS = false, holdD = false,
        holdF = false, holdSpace = false,
    },
    
    combat = {
        combatLock = false, comboActive = false, comboCount = 0,
        m1Count = 0, m1InCombo = 0, lastM1 = 0, attacking = false,
    },
    
    defense = {
        blocking = false, blockStart = 0, blockEnd = 0, blockReacting = false,
        justBlocked = false, countering = false, lastBlockBreak = 0,
    },
    
    movement = {
        zigzagActive = false, zigzagDir = 1, zigzagClock = 0, zigzagNext = 0.4,
        currentStrafe = nil, lastDash = 0, lastLateralDash = 0,
        lastRagdollDash = 0, lastSideDashAttack = 0,
    },
    
    skills = { lastGlobalUse = 0, skillInProgress = false },
    
    stats = {
        m1Hits = 0, skillsUsed = 0,
        skill1Used = 0, skill2Used = 0, skill3Used = 0, skill4Used = 0,
        blocksSuccess = 0, blockBreaks = 0, countersSuccess = 0,
        combosLanded = 0, punishesLanded = 0, sideDashAttacks = 0,
        startTime = 0,
    },
    
    perf = { fps = 60, ping = 0, deltaTime = 0 },
    cache = { lastCacheUpdate = 0 },
}

-- =====================================================
--  GUI + NOTIFICATION SYSTEM (ĐẦY ĐỦ)
-- =====================================================
local function getUIParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local test = pcall(function() return core.Name end)
        if test then return core end
    end
    return LP:WaitForChild("PlayerGui")
end

local UIParent = getUIParent()
if UIParent:FindFirstChild("YUJI_V40") then
    UIParent:FindFirstChild("YUJI_V40"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "YUJI_V40"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = UIParent

local BG = Color3.fromRGB(10, 10, 15)
local LINE = Color3.fromRGB(60, 60, 80)
local ACC = Color3.fromRGB(255, 100, 100)
local GRN = Color3.fromRGB(50, 200, 100)
local RED = Color3.fromRGB(200, 50, 50)
local WHT = Color3.new(1, 1, 1)
local GOLD = Color3.fromRGB(255, 215, 0)

local Main = Instance.new("Frame", SG)
Main.Name = "Main"
Main.Size = UDim2.new(0, 340, 0, 310)
Main.Position = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 2
Main.BorderColor3 = ACC
Main.Active = true
Main.Draggable = true

Instance.new("UIStroke", Main).Color = ACC
Instance.new("UIStroke", Main).Thickness = 1
Instance.new("UIStroke", Main).Transparency = 0.5

local TB = Instance.new("Frame", Main)
TB.Size = UDim2.new(1, 0, 0, 32)
TB.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TB.BorderSizePixel = 0

local TL = Instance.new("TextLabel", TB)
TL.Size = UDim2.new(1, -30, 0, 16)
TL.Position = UDim2.new(0, 8, 0, 2)
TL.BackgroundTransparency = 1
TL.Text = "👊 YUJI BOT V40 MASTERY"
TL.TextSize = 14
TL.TextColor3 = GOLD
TL.Font = Enum.Font.GothamBold
TL.TextXAlignment = Enum.TextXAlignment.Left

local CreditLabel = Instance.new("TextLabel", TB)
CreditLabel.Size = UDim2.new(1, -30, 0, 12)
CreditLabel.Position = UDim2.new(0, 8, 0, 18)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Made by HKTD Roblox"
CreditLabel.TextSize = 10
CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.TextXAlignment = Enum.TextXAlignment.Left

local XB = Instance.new("TextButton", TB)
XB.Size = UDim2.new(0, 24, 0, 26)
XB.Position = UDim2.new(1, -28, 0, 3)
XB.BackgroundColor3 = RED
XB.TextColor3 = WHT
XB.Text = "✕"
XB.Font = Enum.Font.GothamBold
XB.TextSize = 13
XB.BorderSizePixel = 0

local Sep = Instance.new("Frame", Main)
Sep.Size = UDim2.new(1, 0, 0, 1)
Sep.Position = UDim2.new(0, 0, 0, 32)
Sep.BackgroundColor3 = LINE
Sep.BorderSizePixel = 0

local SB = Instance.new("TextButton", Main)
SB.Size = UDim2.new(1, -16, 0, 34)
SB.Position = UDim2.new(0, 8, 0, 40)
SB.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SB.TextColor3 = WHT
SB.Text = "▶  START YUJI BOT"
SB.Font = Enum.Font.GothamBold
SB.TextSize = 14
SB.BorderSizePixel = 1
SB.BorderColor3 = LINE
SB.AutoButtonColor = false

local StatsLabel = Instance.new("TextLabel", Main)
StatsLabel.Size = UDim2.new(1, -16, 0, 36)
StatsLabel.Position = UDim2.new(0, 8, 0, 80)
StatsLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.Text = "M1: 0 | Skills: 0\nCombos: 0 | Blocks: 0"
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 11
StatsLabel.BorderSizePixel = 1
StatsLabel.BorderColor3 = LINE

local InfoLabel = Instance.new("TextLabel", Main)
InfoLabel.Size = UDim2.new(1, -16, 0, 40)
InfoLabel.Position = UDim2.new(0, 8, 0, 122)
InfoLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
InfoLabel.TextColor3 = ACC
InfoLabel.Text = "S1: 0 | S2: 0 | BF: 0 | C: 0\nBlock Breaks: 0 | Side Dash: 0"
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextSize = 10
InfoLabel.BorderSizePixel = 1
InfoLabel.BorderColor3 = LINE

-- Notification Area (lớn + dễ thấy)
local NotifyFrame = Instance.new("Frame", Main)
NotifyFrame.Size = UDim2.new(1, -16, 0, 130)
NotifyFrame.Position = UDim2.new(0, 8, 0, 168)
NotifyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
NotifyFrame.BorderSizePixel = 1
NotifyFrame.BorderColor3 = LINE

local NotifyTitle = Instance.new("TextLabel", NotifyFrame)
NotifyTitle.Size = UDim2.new(1, -10, 0, 18)
NotifyTitle.Position = UDim2.new(0, 5, 0, 4)
NotifyTitle.BackgroundTransparency = 1
NotifyTitle.Text = "📋 NOTIFICATIONS"
NotifyTitle.TextColor3 = GOLD
NotifyTitle.TextSize = 11
NotifyTitle.Font = Enum.Font.GothamBold
NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left

local NotifyLabel = Instance.new("TextLabel", NotifyFrame)
NotifyLabel.Size = UDim2.new(1, -10, 1, -24)
NotifyLabel.Position = UDim2.new(0, 5, 0, 22)
NotifyLabel.BackgroundTransparency = 1
NotifyLabel.Text = "Waiting..."
NotifyLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
NotifyLabel.TextSize = 11
NotifyLabel.Font = Enum.Font.Code
NotifyLabel.TextXAlignment = Enum.TextXAlignment.Left
NotifyLabel.TextYAlignment = Enum.TextYAlignment.Top
NotifyLabel.TextWrapped = true

local notifyHistory = {}

local function Notify(text, color)
    color = color or Color3.fromRGB(180, 255, 180)
    
    table.insert(notifyHistory, 1, text)
    if #notifyHistory > 6 then
        table.remove(notifyHistory)
    end
    
    NotifyLabel.Text = table.concat(notifyHistory, "\n")
    NotifyLabel.TextColor3 = color
    
    -- Flash
    NotifyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    task.delay(0.12, function()
        if NotifyFrame then
            NotifyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
        end
    end)
end

-- =====================================================
--  UTILITIES
-- =====================================================
local function sendKey(press, key)
    pcall(function() VIM:SendKeyEvent(press, key, false, game) end)
end

local function sendClick(press)
    pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, press, game, 1) end)
end

local function getMyRoot()
    if STATE.player.character then
        local root = STATE.player.character:FindFirstChild("HumanoidRootPart")
        if root then return root end
    end
    local char = LP.Character
    if char then
        STATE.player.character = char
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getMyHumanoid()
    if STATE.player.character then
        local hum = STATE.player.character:FindFirstChildOfClass("Humanoid")
        if hum then return hum end
    end
    local char = LP.Character
    if char then
        STATE.player.character = char
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function randomFloat(min, max)
    return min + math.random() * (max - min)
end

local function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function releaseKey(key, stateKey)
    if STATE.input[stateKey] then
        sendKey(false, key)
        STATE.input[stateKey] = false
    end
end

local function pressKey(key, stateKey)
    if not STATE.input[stateKey] then
        sendKey(true, key)
        STATE.input[stateKey] = true
    end
end

local function releaseAllInputs()
    releaseKey(Enum.KeyCode.W, "holdW")
    releaseKey(Enum.KeyCode.A, "holdA")
    releaseKey(Enum.KeyCode.S, "holdS")
    releaseKey(Enum.KeyCode.D, "holdD")
    releaseKey(Enum.KeyCode.F, "holdF")
    releaseKey(Enum.KeyCode.Space, "holdSpace")
    
    STATE.movement.zigzagActive = false
    STATE.movement.currentStrafe = nil
    STATE.combat.combatLock = false
    STATE.combat.comboActive = false
    STATE.combat.attacking = false
    STATE.defense.blocking = false
    STATE.defense.blockReacting = false
    STATE.defense.countering = false
end

local function stopMovement()
    releaseKey(Enum.KeyCode.W, "holdW")
    releaseKey(Enum.KeyCode.A, "holdA")
    releaseKey(Enum.KeyCode.S, "holdS")
    releaseKey(Enum.KeyCode.D, "holdD")
    STATE.movement.zigzagActive = false
    STATE.movement.currentStrafe = nil
end

local function stopZigzag()
    if STATE.movement.currentStrafe then
        if STATE.movement.currentStrafe == "A" then
            releaseKey(Enum.KeyCode.A, "holdA")
        else
            releaseKey(Enum.KeyCode.D, "holdD")
        end
        STATE.movement.currentStrafe = nil
    end
    STATE.movement.zigzagActive = false
    STATE.movement.zigzagClock = 0
end

local function resetState()
    releaseAllInputs()
    STATE.target.root = nil
    STATE.target.humanoid = nil
    STATE.target.name = ""
    STATE.target.distance = 999
    STATE.combat.combatLock = false
    STATE.combat.comboActive = false
    STATE.combat.attacking = false
    STATE.defense.blocking = false
    STATE.defense.blockReacting = false
    STATE.defense.countering = false
    STATE.defense.justBlocked = false
    STATE.movement.zigzagActive = false
    STATE.movement.currentStrafe = nil
    STATE.skills.skillInProgress = false
    STATE.cache.lastCacheUpdate = 0
end

-- =====================================================
--  ANIMATION DETECTION
-- =====================================================
local ANIMATION_PATTERNS = {
    attack = {"attack", "swing", "punch", "slash", "m1", "hit", "strike", "combo", "jab", "smash", "uppercut", "kick"},
    skill  = {"skill", "technique", "curse", "domain", "special", "ability", "ultimate", "barrage", "blast"},
    stun   = {"stun", "hitstun", "stagger", "downed", "knockback", "launch", "ragdoll", "tumble", "hurt", "flinch"},
    block  = {"block", "guard", "parry", "deflect", "defend", "shield"},
    ragdoll= {"ragdoll", "stagger", "knockback", "launch", "tumble", "fall", "downed", "hitstun"},
}

local function matchAnimationPattern(humanoid, patterns)
    if not humanoid then return false end
    local success, tracks = pcall(function() return humanoid:GetPlayingAnimationTracks() end)
    if not success or not tracks then return false end
    
    for _, track in ipairs(tracks) do
        if track.IsPlaying and track.Animation then
            local animId = (track.Animation.AnimationId or ""):lower()
            local trackName = (track.Name or ""):lower()
            for _, pattern in ipairs(patterns) do
                if animId:find(pattern, 1, true) or trackName:find(pattern, 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

local function isAnimationPlaying(humanoid, animType)
    local patterns = ANIMATION_PATTERNS[animType]
    if not patterns then return false end
    return matchAnimationPattern(humanoid, patterns)
end

local function isTargetAttacking(hum) return isAnimationPlaying(hum, "attack") end
local function isTargetUsingSkill(hum) return isAnimationPlaying(hum, "skill") end
local function isTargetBlocking(hum) return isAnimationPlaying(hum, "block") end

local function isTargetStunned(hum, root)
    if isAnimationPlaying(hum, "stun") or isAnimationPlaying(hum, "ragdoll") then return true end
    if hum.PlatformStand or hum.Sit then return true end
    if root then
        local vel = root.AssemblyLinearVelocity or Vector3.zero
        if Vector2.new(vel.X, vel.Z).Magnitude > CFG.movement.ragdollSpeed then return true end
        if math.abs(vel.Y) > CFG.movement.ragdollSpeed then return true end
    end
    return false
end

local function isPlayerRagdolled(root, hum)
    if not root or not hum then return false end
    local vel = root.AssemblyLinearVelocity or Vector3.zero
    if Vector2.new(vel.X, vel.Z).Magnitude > CFG.movement.ragdollSpeed then return true end
    if math.abs(vel.Y) > CFG.movement.ragdollSpeed then return true end
    if hum.PlatformStand or hum.Sit then return true end
    if isAnimationPlaying(hum, "ragdoll") then return true end
    return false
end

-- =====================================================
--  TARGETING
-- =====================================================
local function isSameTeam(player)
    if not CFG.targeting.teamCheck then return false end
    return LP.Team ~= nil and player.Team == LP.Team
end

local function isValidTarget(model, fromPos)
    local hum = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return false end
    if model == LP.Character then return false end
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and isSameTeam(plr) then return false end
    local dist = (fromPos - root.Position).Magnitude
    if dist > CFG.targeting.maxDist then return false end
    return true, hum, root, dist
end

local function calculateTargetPriority(hum, root, dist)
    local prio = (CFG.targeting.maxDist - dist) / CFG.targeting.maxDist * 100
    if CFG.targeting.priorityHealth then
        prio = prio + (1 - hum.Health / hum.MaxHealth) * 50
    end
    if isTargetStunned(hum, root) then prio = prio + 75 end
    if isTargetBlocking(hum) then prio = prio - 30 end
    return prio
end

local function scanForTargets()
    local myRoot = getMyRoot()
    if not myRoot then return end
    local now = tick()
    
    if STATE.target.root and STATE.target.humanoid and STATE.target.humanoid.Health > 0 then
        local dist = (myRoot.Position - STATE.target.root.Position).Magnitude
        if dist < CFG.targeting.retargetDist then
            STATE.target.distance = dist
            STATE.target.lastSeen = now
            return
        end
    end
    
    local bestPrio, best = -math.huge, {root=nil, humanoid=nil, name="", distance=999}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local valid, hum, root, dist = isValidTarget(plr.Character, myRoot.Position)
            if valid then
                local prio = calculateTargetPriority(hum, root, dist)
                if prio > bestPrio then
                    bestPrio = prio
                    best = {root=root, humanoid=hum, name=plr.Name, distance=dist}
                end
            end
        end
    end
    
    if CFG.targeting.targetNPCs then
        for _, obj in ipairs(workspace:GetChildren()) do
            if not Players:GetPlayerFromCharacter(obj) then
                local valid, hum, root, dist = isValidTarget(obj, myRoot.Position)
                if valid then
                    local prio = calculateTargetPriority(hum, root, dist)
                    if prio > bestPrio then
                        bestPrio = prio
                        best = {root=root, humanoid=hum, name=obj.Name or "NPC", distance=dist}
                    end
                end
            end
        end
    end
    
    if best.root then
        STATE.target.root = best.root
        STATE.target.humanoid = best.humanoid
        STATE.target.name = best.name
        STATE.target.distance = best.distance
        STATE.target.lastSeen = now
        if STATE.target.humanoid then
            STATE.target.health = STATE.target.humanoid.Health
            STATE.target.maxHealth = STATE.target.humanoid.MaxHealth
        end
    else
        STATE.target.root = nil
        STATE.target.humanoid = nil
        STATE.target.name = ""
        STATE.target.distance = 999
    end
end

-- =====================================================
--  PREDICTION + RAYCAST
-- =====================================================
local RAYCAST_PARAMS = RaycastParams.new()
RAYCAST_PARAMS.FilterType = Enum.RaycastFilterType.Exclude

local function predictTargetPosition(root, t)
    if not root then return Vector3.zero end
    local vel = root.AssemblyLinearVelocity or Vector3.zero
    return root.Position + vel * (t or CFG.movement.predictionFactor)
end

local function hasObstacleInFront(root, dist)
    if not root then return false end
    local exclude = {}
    if LP.Character then table.insert(exclude, LP.Character) end
    if STATE.target.root and STATE.target.root.Parent then table.insert(exclude, STATE.target.root.Parent) end
    RAYCAST_PARAMS.FilterDescendantsInstances = exclude
    local result = workspace:Raycast(root.Position, root.CFrame.LookVector * (dist or CFG.movement.obstacleRange), RAYCAST_PARAMS)
    return result and result.Instance and result.Instance.CanCollide
end

-- =====================================================
--  SKILLS
-- =====================================================
local function canUseSkill(idx)
    if not idx or idx < 1 or idx > 4 then return false end
    local now = tick()
    local data = CFG.skills[idx]
    if not data then return false end
    if (now - data.lastUsed) < data.cooldown then return false end
    if (now - STATE.skills.lastGlobalUse) < CFG.skills.globalCD then return false end
    if STATE.skills.skillInProgress then return false end
    return true
end

local function executeSkill(idx)
    if not canUseSkill(idx) then return false end
    local now = tick()
    local data = CFG.skills[idx]
    local key = CFG.skills.keys[idx]
    
    STATE.skills.skillInProgress = true
    sendKey(true, key)
    task.wait(0.1)
    sendKey(false, key)
    
    data.lastUsed = now
    STATE.skills.lastGlobalUse = now
    STATE.stats.skillsUsed += 1
    
    if idx == 1 then STATE.stats.skill1Used += 1
    elseif idx == 2 then STATE.stats.skill2Used += 1
    elseif idx == 3 then STATE.stats.skill3Used += 1
    elseif idx == 4 then STATE.stats.skill4Used += 1 end
    
    task.delay(0.25, function() STATE.skills.skillInProgress = false end)
    return true
end

local function useDivergentFist(purpose)
    if purpose == "blockbreak" then
        sendKey(true, Enum.KeyCode.Space)
        task.wait(0.12)
        sendKey(false, Enum.KeyCode.Space)
        task.wait(0.08)
    end
    return executeSkill(1)
end

local function useCrushingBlow(purpose)
    if purpose == "gapcloser" then
        sendKey(true, Enum.KeyCode.Space)
        task.wait(0.12)
        sendKey(false, Enum.KeyCode.Space)
        task.wait(0.08)
    end
    return executeSkill(2)
end

local function useBlackFlash()
    return executeSkill(3)
end

local function useCounter()
    if executeSkill(4) then
        STATE.defense.countering = true
        task.delay(0.8, function() STATE.defense.countering = false end)
        return true
    end
    return false
end

-- =====================================================
--  SIDE DASH ATTACK
-- =====================================================
local function performSideDashAttack()
    if not CFG.movement.sideDashAttack then return false end
    local now = tick()
    if (now - STATE.movement.lastSideDashAttack) < CFG.movement.sideDashAttackCD then return false end
    local myRoot = getMyRoot()
    if not myRoot or not STATE.target.root then return false end
    local dist = STATE.target.distance
    if dist > CFG.movement.sideDashAttackRange or dist < 8 then return false end
    if math.random() > CFG.movement.sideDashAttackChance then return false end
    
    STATE.movement.lastSideDashAttack = now
    STATE.stats.sideDashAttacks += 1
    Notify("Side Dash Attack!", Color3.fromRGB(255, 200, 80))
    
    task.spawn(function()
        local toTarget = (STATE.target.root.Position - myRoot.Position).Unit
        local right = Vector3.new(-toTarget.Z, 0, toTarget.X)
        local sideDir = math.random() > 0.5 and right or -right
        myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + sideDir * 5)
        task.wait(0.05)
        sendKey(true, Enum.KeyCode.Q)
        task.wait(0.06)
        sendKey(false, Enum.KeyCode.Q)
        task.wait(0.1)
        if STATE.target.root and myRoot then
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, STATE.target.root.Position)
            task.wait(0.05)
            sendClick(true)
            task.wait(0.01)
            sendClick(false)
            STATE.combat.lastM1 = tick()
            STATE.stats.m1Hits += 1
        end
    end)
    return true
end

-- =====================================================
--  BLOCK BREAK
-- =====================================================
local function attemptBlockBreak()
    if not CFG.defense.blockBreakEnabled then return false end
    local now = tick()
    if (now - STATE.defense.lastBlockBreak) < 1.2 then return false end
    if STATE.target.distance > CFG.defense.blockBreakRange then return false end
    
    for _, idx in ipairs(CFG.defense.blockBreakPriority) do
        if canUseSkill(idx) then
            STATE.defense.lastBlockBreak = now
            if idx == 1 then useDivergentFist("blockbreak")
            elseif idx == 2 then useCrushingBlow("blockbreak")
            elseif idx == 3 then useBlackFlash() end
            STATE.stats.blockBreaks += 1
            Notify("Block Break! (" .. CFG.skills[idx].name .. ")", Color3.fromRGB(255, 120, 80))
            return true
        end
    end
    return false
end

-- =====================================================
--  BLOCK SYSTEM
-- =====================================================
local function handleBlockSystem()
    if not CFG.defense.blockEnabled then return end
    local now = tick()
    local tHum = STATE.target.humanoid
    local dist = STATE.target.distance
    if not tHum then return end
    
    local attacking = isTargetAttacking(tHum)
    local skill = isTargetUsingSkill(tHum)
    local stunned = STATE.target.isStunned
    
    if stunned or skill then
        if STATE.defense.blocking or STATE.defense.blockReacting then
            releaseKey(Enum.KeyCode.F, "holdF")
            STATE.defense.blocking = false
            STATE.defense.blockReacting = false
            STATE.defense.blockEnd = now
        end
        return
    end
    
    if attacking and dist < CFG.defense.blockRange then
        if (now - STATE.defense.blockEnd) > CFG.defense.blockCooldown then
            if not STATE.defense.blocking and not STATE.defense.blockReacting then
                pressKey(Enum.KeyCode.F, "holdF")
                STATE.defense.blocking = true
                STATE.defense.blockReacting = true
                STATE.defense.blockStart = now
                STATE.defense.justBlocked = true
                STATE.stats.blocksSuccess += 1
                Notify("Perfect Block!", Color3.fromRGB(100, 200, 255))
                
                task.delay(CFG.defense.blockMinTime, function()
                    if STATE.defense.blocking then
                        releaseKey(Enum.KeyCode.F, "holdF")
                        STATE.defense.blocking = false
                        STATE.defense.blockReacting = false
                        STATE.defense.blockEnd = tick()
                        
                        if STATE.defense.justBlocked and CFG.defense.instantPunish then
                            task.delay(CFG.defense.punishDelay, function()
                                if STATE.active and not STATE.combat.combatLock then
                                    executePerfectPunish()
                                end
                            end)
                        end
                    end
                end)
            else
                if (now - STATE.defense.blockStart) > CFG.defense.blockMaxTime then
                    releaseKey(Enum.KeyCode.F, "holdF")
                    STATE.defense.blocking = false
                    STATE.defense.blockReacting = false
                    STATE.defense.blockEnd = now
                end
            end
        end
    else
        if STATE.defense.blocking or STATE.defense.blockReacting then
            if (now - STATE.defense.blockStart) >= CFG.defense.blockMinTime then
                releaseKey(Enum.KeyCode.F, "holdF")
                STATE.defense.blocking = false
                STATE.defense.blockReacting = false
                STATE.defense.blockEnd = now
            end
        end
    end
end

function executePerfectPunish()
    if STATE.combat.combatLock or not STATE.defense.justBlocked then return end
    STATE.defense.justBlocked = false
    STATE.combat.combatLock = true
    
    task.spawn(function()
        task.wait(0.02)
        sendClick(true)
        task.wait(0.01)
        sendClick(false)
        STATE.combat.lastM1 = tick()
        STATE.stats.m1Hits += 1
        STATE.stats.punishesLanded += 1
        Notify("Punish M1 Landed!", Color3.fromRGB(255, 80, 80))
        task.wait(0.15)
        STATE.combat.combatLock = false
    end)
end

-- =====================================================
--  COUNTER
-- =====================================================
local function handleCounterSystem()
    if not CFG.defense.counterEnabled then return end
    local tHum = STATE.target.humanoid
    local dist = STATE.target.distance
    if not tHum then return end
    
    if (isTargetAttacking(tHum) or isTargetUsingSkill(tHum)) and dist < CFG.defense.counterRange then
        if canUseSkill(4) and math.random() < CFG.skills[4].useFrequency then
            if not STATE.defense.countering then
                useCounter()
                STATE.stats.countersSuccess += 1
                Notify("Auto Counter!", Color3.fromRGB(180, 100, 255))
            end
        end
    end
end

-- =====================================================
--  COMBO
-- =====================================================
local function executeM1Combo()
    if STATE.combat.combatLock or STATE.combat.comboActive then return end
    STATE.combat.combatLock = true
    STATE.combat.comboActive = true
    STATE.combat.attacking = true
    
    task.spawn(function()
        local delay = CFG.combat.m1Delay
        for i = 1, CFG.combat.m1Count do
            if not STATE.active or not STATE.combat.comboActive then
                STATE.combat.combatLock = false
                STATE.combat.comboActive = false
                STATE.combat.attacking = false
                return
            end
            sendClick(true)
            task.wait(0.01)
            sendClick(false)
            STATE.combat.lastM1 = tick()
            STATE.stats.m1Hits += 1
            if i < CFG.combat.m1Count then task.wait(delay) end
        end
        
        task.wait(0.1)
        if not STATE.active then
            STATE.combat.combatLock = false
            STATE.combat.comboActive = false
            STATE.combat.attacking = false
            return
        end
        
        local used = false
        if canUseSkill(1) and math.random() < CFG.skills[1].useFrequency then
            useDivergentFist("combo")
            used = true
        elseif canUseSkill(3) and math.random() < CFG.skills[3].useFrequency then
            useBlackFlash()
            used = true
        elseif canUseSkill(2) and math.random() < CFG.skills[2].useFrequency then
            useCrushingBlow("combo")
            used = true
        end
        
        if used then
            STATE.stats.combosLanded += 1
            Notify("3M1 + Skill Combo!", Color3.fromRGB(255, 100, 100))
        end
        
        task.wait(0.3)
        STATE.combat.combatLock = false
        STATE.combat.comboActive = false
        STATE.combat.attacking = false
    end)
end

-- =====================================================
--  MOVEMENT
-- =====================================================
local function updateZigzag(dt)
    if not CFG.movement.zigzagEnabled or not STATE.movement.zigzagActive then return end
    STATE.movement.zigzagClock += dt
    if STATE.movement.zigzagClock >= STATE.movement.zigzagNext then
        if STATE.movement.currentStrafe == "A" then releaseKey(Enum.KeyCode.A, "holdA")
        elseif STATE.movement.currentStrafe == "D" then releaseKey(Enum.KeyCode.D, "holdD") end
        
        STATE.movement.zigzagDir = -STATE.movement.zigzagDir
        if STATE.movement.zigzagDir > 0 then
            STATE.movement.currentStrafe = "D"
            pressKey(Enum.KeyCode.D, "holdD")
        else
            STATE.movement.currentStrafe = "A"
            pressKey(Enum.KeyCode.A, "holdA")
        end
        STATE.movement.zigzagClock = 0
        STATE.movement.zigzagNext = randomFloat(CFG.movement.zigzagInterval[1], CFG.movement.zigzagInterval[2])
    end
end

local function performLateralDash()
    if not CFG.movement.useLateralDash then return false end
    local now = tick()
    if (now - STATE.movement.lastLateralDash) < CFG.movement.lateralDashCD then return false end
    local myRoot = getMyRoot()
    if not myRoot or not STATE.target.root then return false end
    
    local toTarget = (STATE.target.root.Position - myRoot.Position).Unit
    local right = Vector3.new(-toTarget.Z, 0, toTarget.X)
    local dir = math.random() > 0.5 and right or -right
    myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + dir)
    sendKey(true, Enum.KeyCode.Q)
    task.delay(0.06, function()
        sendKey(false, Enum.KeyCode.Q)
        if STATE.target.root and myRoot then
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, STATE.target.root.Position)
        end
    end)
    STATE.movement.lastLateralDash = now
    return true
end

local function performNormalDash()
    local now = tick()
    if (now - STATE.movement.lastDash) < CFG.movement.dashCooldown then return false end
    sendKey(true, Enum.KeyCode.Q)
    task.delay(0.05, function() sendKey(false, Enum.KeyCode.Q) end)
    STATE.movement.lastDash = now
    return true
end

local function handleMovement(dt)
    local myRoot = getMyRoot()
    if not myRoot or not STATE.target.root then return end
    local dist = STATE.target.distance
    
    if CFG.movement.alwaysForward and dist > CFG.combat.minAttackRange then
        pressKey(Enum.KeyCode.W, "holdW")
    end
    
    if dist < CFG.movement.zigzagStopDist then
        if dist > CFG.combat.minAttackRange then pressKey(Enum.KeyCode.W, "holdW") end
        stopZigzag()
    elseif dist < CFG.movement.kiteRange and not STATE.target.isStunned then
        releaseKey(Enum.KeyCode.W, "holdW")
        pressKey(Enum.KeyCode.S, "holdS")
        stopZigzag()
    elseif dist > CFG.movement.approachRange then
        releaseKey(Enum.KeyCode.S, "holdS")
        pressKey(Enum.KeyCode.W, "holdW")
        if hasObstacleInFront(myRoot) then
            sendKey(true, Enum.KeyCode.Space)
            task.delay(CFG.movement.obstacleJumpDelay, function() sendKey(false, Enum.KeyCode.Space) end)
        end
        if dist > CFG.movement.zigzagStopDist * 2 then
            STATE.movement.zigzagActive = true
            updateZigzag(dt)
        else
            stopZigzag()
        end
    else
        pressKey(Enum.KeyCode.W, "holdW")
        releaseKey(Enum.KeyCode.S, "holdS")
        if dist > CFG.combat.optimalRange then
            STATE.movement.zigzagActive = true
            updateZigzag(dt)
        else
            stopZigzag()
        end
    end
    
    if dist <= CFG.movement.sideDashAttackRange and dist >= 8 then
        if performSideDashAttack() then return end
    end
    
    if dist > CFG.movement.dashMinDist and dist < CFG.movement.dashMaxDist then
        if math.random() < CFG.movement.lateralDashChance then
            performLateralDash()
        else
            performNormalDash()
        end
    end
end

-- =====================================================
--  COMBAT
-- =====================================================
local function handleCombat()
    if STATE.combat.combatLock or STATE.combat.comboActive then return end
    local dist = STATE.target.distance
    local now = tick()
    
    if dist >= CFG.combat.minAttackRange and dist <= CFG.combat.attackRange then
        if (now - STATE.combat.lastM1) > 0.35 then
            if STATE.target.isStunned or dist <= CFG.combat.optimalRange then
                executeM1Combo()
            end
        end
    end
    
    if dist > CFG.combat.attackRange and dist < 25 then
        local roll = math.random()
        if canUseSkill(1) and roll < CFG.skills[1].useFrequency then
            useDivergentFist("gapcloser")
            Notify("Gap Close: Divergent Fist", Color3.fromRGB(255, 150, 50))
        elseif canUseSkill(2) and roll < CFG.skills[2].useFrequency then
            useCrushingBlow("gapcloser")
            Notify("Gap Close: Crushing Blow", Color3.fromRGB(255, 150, 50))
        elseif canUseSkill(3) and roll < CFG.skills[3].useFrequency then
            useBlackFlash()
            Notify("Gap Close: Black Flash", Color3.fromRGB(255, 150, 50))
        end
    end
end

-- =====================================================
--  CAMERA
-- =====================================================
local function updateCameraAndRotation()
    local myRoot = getMyRoot()
    if not myRoot or not STATE.target.root then return end
    
    local pred = predictTargetPosition(STATE.target.root, CFG.targeting.maxPredictionTime)
    STATE.target.predictedPos = pred
    
    if CFG.camera.smoothAim then
        local camTarget = pred + Vector3.new(0, CFG.camera.verticalOffset, 0)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, camTarget), CFG.camera.lerpSpeed)
    end
    
    local lookPos = Vector3.new(pred.X, myRoot.Position.Y, pred.Z)
    if CFG.movement.smoothRotation then
        myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(myRoot.Position, lookPos), CFG.movement.rotationSpeed)
    else
        myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookPos)
    end
end

-- =====================================================
--  RAGDOLL
-- =====================================================
local function handleRagdollRecovery()
    local myRoot = getMyRoot()
    local myHum = getMyHumanoid()
    if not myRoot or not myHum then return end
    
    if isPlayerRagdolled(myRoot, myHum) then
        STATE.player.isRagdoll = true
        local now = tick()
        if (now - STATE.movement.lastRagdollDash) > CFG.movement.ragdollDashCD then
            releaseAllInputs()
            local side = math.random() > 0.5 and Enum.KeyCode.A or Enum.KeyCode.D
            sendKey(true, side)
            sendKey(true, Enum.KeyCode.Q)
            task.delay(0.05, function()
                sendKey(false, Enum.KeyCode.Q)
                sendKey(false, side)
            end)
            STATE.movement.lastRagdollDash = now
            Notify("Ragdoll Recovery Dash", Color3.fromRGB(200, 200, 100))
        end
    else
        STATE.player.isRagdoll = false
    end
end

-- =====================================================
--  STATE UPDATE
-- =====================================================
local function updateTargetState()
    if not STATE.target.humanoid or not STATE.target.root then return end
    STATE.target.isStunned = isTargetStunned(STATE.target.humanoid, STATE.target.root)
    STATE.target.isBlocking = isTargetBlocking(STATE.target.humanoid)
    STATE.target.isAttacking = isTargetAttacking(STATE.target.humanoid)
    STATE.target.isUsingSkill = isTargetUsingSkill(STATE.target.humanoid)
    STATE.target.velocity = STATE.target.root.AssemblyLinearVelocity or Vector3.zero
end

local function updatePlayerState()
    local root = getMyRoot()
    local hum = getMyHumanoid()
    if root then
        STATE.player.root = root
        STATE.player.position = root.Position
        STATE.player.velocity = root.AssemblyLinearVelocity or Vector3.zero
    end
    if hum then
        STATE.player.humanoid = hum
        STATE.player.health = hum.Health
        STATE.player.maxHealth = hum.MaxHealth
    end
end

-- =====================================================
--  MAIN LOOP
-- =====================================================
local function mainLoop(dt)
    if not STATE.active then return end
    local now = tick()
    updatePlayerState()
    
    local myRoot = STATE.player.root
    local myHum = STATE.player.humanoid
    if not myRoot or not myHum or myHum.Health <= 0 then return end
    
    if (now - STATE.cache.lastCacheUpdate) >= CFG.targeting.updateRate then
        scanForTargets()
        STATE.cache.lastCacheUpdate = now
    end
    
    if not STATE.target.root or not STATE.target.humanoid or STATE.target.humanoid.Health <= 0 then
        scanForTargets()
        if not STATE.target.root then
            stopMovement()
            return
        end
    end
    
    updateTargetState()
    STATE.target.distance = (myRoot.Position - STATE.target.root.Position).Magnitude
    
    if isPlayerRagdolled(myRoot, myHum) then
        handleRagdollRecovery()
        return
    end
    
    updateCameraAndRotation()
    handleCounterSystem()
    handleBlockSystem()
    
    if STATE.target.isBlocking and STATE.target.distance < CFG.defense.blockBreakRange then
        if attemptBlockBreak() then return end
    end
    
    handleMovement(dt)
    handleCombat()
end

-- =====================================================
--  STOP BOT
-- =====================================================
local function stopBot()
    STATE.active = false
    releaseAllInputs()
    resetState()
    
    local t = tick() - STATE.stats.startTime
    Notify(string.format(
        "BOT STOPPED (%.0fs)\nM1: %d | Skills: %d | Combos: %d\nBlocks: %d | Breaks: %d | Counters: %d\nPunish: %d | SideDash: %d",
        t,
        STATE.stats.m1Hits,
        STATE.stats.skillsUsed,
        STATE.stats.combosLanded,
        STATE.stats.blocksSuccess,
        STATE.stats.blockBreaks,
        STATE.stats.countersSuccess,
        STATE.stats.punishesLanded,
        STATE.stats.sideDashAttacks
    ), Color3.fromRGB(255, 180, 80))
end

-- =====================================================
--  GUI EVENTS
-- =====================================================
SB.MouseButton1Click:Connect(function()
    STATE.active = not STATE.active
    if STATE.active then
        resetState()
        SB.Text = "⏸  STOP YUJI BOT"
        SB.BackgroundColor3 = GRN
        SB.TextColor3 = Color3.fromRGB(0, 30, 0)
        STATE.stats.startTime = tick()
        
        Notify("YUJI BOT V40 ENABLED!\n• Perfect Tracking (2-8 stud)\n• Perfect Block + Instant Punish\n• 3M1 + Skill Combos\n• Auto Counter + Block Break\n• Side Dash Attack\n• Always Approach", Color3.fromRGB(80, 255, 120))
    else
        stopBot()
        SB.Text = "▶  START YUJI BOT"
        SB.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        SB.TextColor3 = WHT
    end
end)

XB.MouseButton1Click:Connect(function()
    stopBot()
    SG:Destroy()
end)

task.spawn(function()
    while true do
        if STATE.active then
            StatsLabel.Text = string.format("M1: %d | Skills: %d\nCombos: %d | Blocks: %d",
                STATE.stats.m1Hits, STATE.stats.skillsUsed, STATE.stats.combosLanded, STATE.stats.blocksSuccess)
            InfoLabel.Text = string.format("S1: %d | S2: %d | BF: %d | C: %d\nBlock Breaks: %d | Side Dash: %d",
                STATE.stats.skill1Used, STATE.stats.skill2Used, STATE.stats.skill3Used, STATE.stats.skill4Used,
                STATE.stats.blockBreaks, STATE.stats.sideDashAttacks)
        end
        task.wait(0.3)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    pcall(function() mainLoop(dt) end)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        SB.MouseButton1Click:Fire()
    end
end)

-- Thông báo khi load
Notify("YUJI BOT V40 LOADED!\nPress START or RightAlt to toggle\n• Tracking + Block + Combo\n• Auto Counter + Block Break\n• Side Dash Attack + Gap Close", Color3.fromRGB(100, 200, 255))
