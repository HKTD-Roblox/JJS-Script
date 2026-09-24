local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "Auto Black Flash"),
            Text = tostring(text or "SUPER OP SCRIPT!"),
            Duration = duration or 3,
        })
    end)
end

local DF_CONFIG = {
    BehindOffset = 5.5,
    AlreadyBehindTolerance = 3.5,
    FireDelay = 0.37,
    DashSpeed = 79,
    ArcSegments = 5,
    SideWidth = 0.65,
    TrailLifetime = 0.35,
    DashAnimLeft = "rbxassetid://117223862448096",
    DashAnimRight = "rbxassetid://75203303352791",
    AttackAnimId = "rbxassetid://100962226150441",
    FacingDotThreshold = -0.6,
    RetryDelay = 0.04,
    RetryFire = true,
}

if _G.retryfire ~= nil then
    DF_CONFIG.RetryFire = _G.retryfire
end

local TODO_CONFIG = {
    Delay_AfterPebble = 1,
    Delay_AfterRight = 0,
    Delay_AfterBrute1 = 0.60,
}

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

local targetRemote = getRemote("Knit", "Knit", "Services", "DivergentFistService", "RE", "Activated")
local returnSkillRemote = getRemote("Knit", "Knit", "Services", "ItadoriService", "RE", "RightActivated")
local PebbleThrowRemote = getRemote("Knit", "Knit", "Services", "PebbleThrowService", "RE", "Activated")
local RightActivated = getRemote("Knit", "Knit", "Services", "TodoService", "RE", "RightActivated")
local BruteForceRemote = getRemote("Knit", "Knit", "Services", "BruteForceService", "RE", "Activated")

local dfOk = targetRemote ~= nil
local todoOk = PebbleThrowRemote ~= nil and RightActivated ~= nil and BruteForceRemote ~= nil

if not dfOk and not todoOk then
    notify("Script", "Load failed", 4)
    return
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getAnimator()
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    return humanoid:FindFirstChildOfClass("Animator")
end

local function isAliveModel(model)
    local myChar = LocalPlayer.Character
    if model == myChar then return false end
    local root = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChild("Humanoid")
    return root and humanoid and humanoid.Health > 0
end

local function isTargetFacingAway(targetRoot)
    local hrp = getHRP()
    if not hrp or not targetRoot or not targetRoot.Parent then return false end
    local toPlayer = (hrp.Position - targetRoot.Position)
    if toPlayer.Magnitude < 0.01 then return false end
    local dot = targetRoot.CFrame.LookVector:Dot(toPlayer.Unit)
    return dot < DF_CONFIG.FacingDotThreshold
end

local function findNearestTarget()
    local hrp = getHRP()
    if not hrp then return nil end
    local nearest = nil
    local bestDist = math.huge
    local function checkModel(model)
        if not isAliveModel(model) then return end
        local root = model:FindFirstChild("HumanoidRootPart")
        local dist = (hrp.Position - root.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            nearest = model
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            checkModel(player.Character)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            checkModel(obj)
        end
    end
    return nearest
end

local function createTrail(rootPart)
    local a0 = Instance.new("Attachment", rootPart)
    local a1 = Instance.new("Attachment", rootPart)
    a1.Position = Vector3.new(0, 2, 0)
    local trail = Instance.new("Trail", rootPart)
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Lifetime = DF_CONFIG.TrailLifetime
    trail.MinLength = 0
    trail.FaceCamera = true
    task.delay(DF_CONFIG.TrailLifetime + 0.1, function()
        trail:Destroy()
        a0:Destroy()
        a1:Destroy()
    end)
end

local cachedAnims = {}

local function playDashAnimation(direction, duration)
    local animator = getAnimator()
    if not animator then return nil end
    local animId = (direction == "Left") and DF_CONFIG.DashAnimLeft or DF_CONFIG.DashAnimRight
    if not cachedAnims[direction] then
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        anim.Name = "DivergentFistDashAnim_" .. direction
        cachedAnims[direction] = anim
    end
    local track = animator:LoadAnimation(cachedAnims[direction])
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    task.delay(duration + 0.05, function()
        if track and track.IsPlaying then
            track:Stop(0.15)
        end
    end)
    return track
end

local function playAttackAnimation()
    local animator = getAnimator()
    if not animator then return end
    if not cachedAnims["Attack"] then
        local anim = Instance.new("Animation")
        anim.AnimationId = DF_CONFIG.AttackAnimId
        anim.Name = "DivergentFistAttackAnim"
        cachedAnims["Attack"] = anim
    end
    local track = animator:LoadAnimation(cachedAnims["Attack"])
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    task.delay(1.113, function()
        if track.IsPlaying then
            track:Stop()
        end
    end)
end

local function performCurvedDash(targetRoot)
    local hrp = getHRP()
    if not hrp then return end
    local myPos = hrp.Position
    local destPos = (targetRoot.CFrame * CFrame.new(0, 0, DF_CONFIG.BehindOffset)).Position
    if (myPos - destPos).Magnitude < DF_CONFIG.AlreadyBehindTolerance then
        playAttackAnimation()
        return
    end
    local dist = (destPos - myPos).Magnitude
    if dist < 0.5 then return end
    local dir = (destPos - myPos).Unit
    local side = dir:Cross(Vector3.new(0, 1, 0)).Unit
    local isLeft = math.random(1, 2) == 2
    if isLeft then side = -side end
    local dashDirection = isLeft and "Left" or "Right"
    local arcDef = {
        { 0.10, DF_CONFIG.SideWidth * 0.50 },
        { 0.30, DF_CONFIG.SideWidth * 0.80 },
        { 0.55, DF_CONFIG.SideWidth * 0.70 },
        { 0.75, DF_CONFIG.SideWidth * 0.40 },
        { 1.00, 0 },
    }
    local waypoints = {}
    for i = 1, math.min(DF_CONFIG.ArcSegments, #arcDef) do
        table.insert(waypoints, myPos + (dir * dist * arcDef[i][1]) + (side * dist * arcDef[i][2]))
    end
    local totalTime = math.max(dist / DF_CONFIG.DashSpeed, 0.08)
    local segTime = totalTime / #waypoints
    createTrail(hrp)
    local dashTrack = playDashAnimation(dashDirection, totalTime)
    for i, wp in ipairs(waypoints) do
        local lookDir = (i < #waypoints) and (waypoints[i + 1] - wp).Unit or (targetRoot.Position - wp).Unit
        TweenService:Create(hrp, TweenInfo.new(segTime, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(wp, wp + lookDir),
        }):Play()
        task.wait(segTime)
    end
    hrp.CFrame = CFrame.lookAt(destPos, targetRoot.Position)
    if dashTrack and dashTrack.IsPlaying then
        dashTrack:Stop(0.1)
    end
    playAttackAnimation()
end

local isCooling = false
local isRetrying = false

local function setupDivergentFistHook()
    if not dfOk then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if getnamecallmethod() ~= "FireServer" or self ~= targetRemote then
            return oldNamecall(self, ...)
        end
        if isRetrying then
            return oldNamecall(self, ...)
        end
        if isCooling then
            return oldNamecall(self, ...)
        end
        isCooling = true
        local result = oldNamecall(self, ...)
        local args = { ... }
        local target = findNearestTarget()
        local targetRoot = target and target:FindFirstChild("HumanoidRootPart")
        task.delay(DF_CONFIG.FireDelay, function()
            if targetRoot and targetRoot.Parent and not isTargetFacingAway(targetRoot) then
                if returnSkillRemote then
                    pcall(function() returnSkillRemote:FireServer() end)
                end
                task.spawn(function()
                    task.wait(DF_CONFIG.RetryDelay)
                    if not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                        task.defer(function() isCooling = false end)
                        return
                    end
                    performCurvedDash(targetRoot)
                    local shouldRetryFire = (_G.retryfire ~= nil) and _G.retryfire or DF_CONFIG.RetryFire
                    if not isTargetFacingAway(targetRoot) then
                    elseif not shouldRetryFire then
                    else
                        isRetrying = true
                        pcall(function() targetRemote:FireServer(table.unpack(args)) end)
                        task.wait(DF_CONFIG.FireDelay)
                        pcall(function() targetRemote:FireServer(table.unpack(args)) end)
                        isRetrying = false
                    end
                    task.defer(function() isCooling = false end)
                end)
            else
                pcall(function() targetRemote:FireServer(table.unpack(args)) end)
                task.defer(function() isCooling = false end)
            end
        end)
        task.spawn(function()
            if not targetRoot or not targetRoot.Parent then return end
            performCurvedDash(targetRoot)
        end)
        return result
    end)
end

local function getMovesetItem(name)
    local char = LocalPlayer.Character
    if not char then return nil end
    local moveset = char:FindFirstChild("Moveset")
    if not moveset then return nil end
    return moveset:FindFirstChild(name)
end

local isComboRunning = false

local function runCombo()
    if isComboRunning then return end
    isComboRunning = true
    task.delay(TODO_CONFIG.Delay_AfterPebble, function()
        pcall(function() RightActivated:FireServer() end)
        task.delay(TODO_CONFIG.Delay_AfterRight, function()
            local bruteArg = getMovesetItem("Brute Force")
            if bruteArg then
                pcall(function() BruteForceRemote:FireServer(bruteArg) end)
            end
            task.delay(TODO_CONFIG.Delay_AfterBrute1, function()
                local bruteArg2 = getMovesetItem("Brute Force")
                if bruteArg2 then
                    pcall(function() BruteForceRemote:FireServer(bruteArg2) end)
                end
                task.defer(function() isComboRunning = false end)
            end)
        end)
    end)
end

local function setupTodoHook()
    if not todoOk then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == PebbleThrowRemote then
            local result = oldNamecall(self, ...)
            task.spawn(runCombo)
            return result
        end
        return oldNamecall(self, ...)
    end)
end

local loadOk, loadErr = pcall(function()
    setupDivergentFistHook()
    setupTodoHook()
end)

if not loadOk then
    notify("Auto Black Flash", "Script loading failed!", 3)
    return
end

notify("Auto Black Flash", "Script loaded successfully!", 3)
task.wait(3)
notify("Auto Black Flash", "Script supports Yuji & Todo only!", 5)
