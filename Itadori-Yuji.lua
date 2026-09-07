local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Itadori Yuji")

if game.PlaceId ~= 9391468976 then
    LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

-- ──────────────────────────────────────────────
--  SERVICES
-- ──────────────────────────────────────────────
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

-- ──────────────────────────────────────────────
--  CONFIG
-- ──────────────────────────────────────────────
local CONFIG = {
    BehindOffset           = 5.5,
    AlreadyBehindTolerance = 3.5,
    FireDelay              = 0.37,
    DashSpeed              = 79,
    ArcSegments            = 5,
    SideWidth              = 0.65,
    TrailLifetime          = 0.35,
    DashAnimLeft           = "rbxassetid://117223862448096",
    DashAnimRight          = "rbxassetid://75203303352791",
    AttackAnimId           = "rbxassetid://100962226150441",
    FacingDotThreshold     = -0.6,
    RetryDelay             = 0.04,
    RetryFire              = true,
}

if _G.retryfire ~= nil then
    CONFIG.RetryFire = _G.retryfire
end

-- ──────────────────────────────────────────────
--  STATE
-- ──────────────────────────────────────────────
local AutoBlackFlash = false
local isCooling  = false
local isRetrying = false

-- ──────────────────────────────────────────────
--  REMOTES
-- ──────────────────────────────────────────────
local function getRemote(...)
    local path = {...}
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

-- ──────────────────────────────────────────────
--  UTILS
-- ──────────────────────────────────────────────
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getAnimator()
    local humanoid = getHumanoid()
    return humanoid and humanoid:FindFirstChildOfClass("Animator")
end

local function isLocalAlive()
    local humanoid = getHumanoid()
    return humanoid and humanoid.Health > 0
end

local function isAliveModel(model)
    if not model or model == LocalPlayer.Character then return false end
    local root = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return root and humanoid and humanoid.Health > 0
end

local function isTargetFacingAway(targetRoot)
    local hrp = getHRP()
    if not hrp or not targetRoot or not targetRoot.Parent then return false end

    local toPlayer = (hrp.Position - targetRoot.Position)
    if toPlayer.Magnitude < 0.01 then return false end

    local dot = targetRoot.CFrame.LookVector:Dot(toPlayer.Unit)
    return dot < CONFIG.FacingDotThreshold
end

local function findNearestTarget()
    local hrp = getHRP()
    if not hrp then return nil end

    local nearest = nil
    local bestDist = math.huge

    local function checkModel(model)
        if not isAliveModel(model) then return end
        local root = model:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local dist = (hrp.Position - root.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            nearest = model
        end
    end

    -- Players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            checkModel(player.Character)
        end
    end

    -- Chỉ quét Model cấp 1 trong workspace (tránh GetDescendants gây lag)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            checkModel(obj)
        end
    end

    return nearest
end

-- ──────────────────────────────────────────────
--  TRAIL
-- ──────────────────────────────────────────────
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
    trail.Lifetime = CONFIG.TrailLifetime
    trail.MinLength = 0
    trail.FaceCamera = true

    task.delay(CONFIG.TrailLifetime + 0.1, function()
        if trail then trail:Destroy() end
        if a0 then a0:Destroy() end
        if a1 then a1:Destroy() end
    end)
end

-- ──────────────────────────────────────────────
--  ANIMATIONS
-- ──────────────────────────────────────────────
local cachedAnims = {}

local function playDashAnimation(direction, duration)
    local animator = getAnimator()
    if not animator then return nil end

    local animId = (direction == "Left") and CONFIG.DashAnimLeft or CONFIG.DashAnimRight

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
        anim.AnimationId = CONFIG.AttackAnimId
        anim.Name = "DivergentFistAttackAnim"
        cachedAnims["Attack"] = anim
    end

    local track = animator:LoadAnimation(cachedAnims["Attack"])
    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    task.delay(1.113, function()
        if track and track.IsPlaying then
            track:Stop()
        end
    end)
end

-- ──────────────────────────────────────────────
--  CURVED DASH
-- ──────────────────────────────────────────────
local function performCurvedDash(targetRoot)
    if not isLocalAlive() then return false end
    local hrp = getHRP()
    if not hrp or not targetRoot or not targetRoot.Parent then return false end

    local myPos = hrp.Position
    local destPos = (targetRoot.CFrame * CFrame.new(0, 0, CONFIG.BehindOffset)).Position

    if (myPos - destPos).Magnitude < CONFIG.AlreadyBehindTolerance then
        playAttackAnimation()
        return true
    end

    local dist = (destPos - myPos).Magnitude
    if dist < 0.5 then return false end

    local dir = (destPos - myPos).Unit
    local side = dir:Cross(Vector3.new(0, 1, 0)).Unit

    local isLeft = math.random(1, 2) == 2
    if isLeft then side = -side end
    local dashDirection = isLeft and "Left" or "Right"

    local arcDef = {
        {0.10, CONFIG.SideWidth * 0.50},
        {0.30, CONFIG.SideWidth * 0.80},
        {0.55, CONFIG.SideWidth * 0.70},
        {0.75, CONFIG.SideWidth * 0.40},
        {1.00, 0},
    }

    local waypoints = {}
    for i = 1, math.min(CONFIG.ArcSegments, #arcDef) do
        table.insert(waypoints, myPos + (dir * dist * arcDef[i][1]) + (side * dist * arcDef[i][2]))
    end

    local totalTime = math.max(dist / CONFIG.DashSpeed, 0.08)
    local segTime = totalTime / #waypoints

    createTrail(hrp)
    local dashTrack = playDashAnimation(dashDirection, totalTime)

    for i, wp in ipairs(waypoints) do
        if not isLocalAlive() or not targetRoot.Parent then
            if dashTrack and dashTrack.IsPlaying then dashTrack:Stop(0.1) end
            return false
        end

        local lookDir = (i < #waypoints)
            and (waypoints[i + 1] - wp).Unit
            or (targetRoot.Position - wp).Unit

        TweenService:Create(hrp,
            TweenInfo.new(segTime, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(wp, wp + lookDir)}
        ):Play()
        task.wait(segTime)
    end

    if not isLocalAlive() or not targetRoot.Parent then
        if dashTrack and dashTrack.IsPlaying then dashTrack:Stop(0.1) end
        return false
    end

    hrp.CFrame = CFrame.lookAt(destPos, targetRoot.Position)

    if dashTrack and dashTrack.IsPlaying then
        dashTrack:Stop(0.1)
    end
    playAttackAnimation()
    return true
end

-- ──────────────────────────────────────────────
--  HOOK
-- ──────────────────────────────────────────────
if targetRemote then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if getnamecallmethod() ~= "FireServer" or self ~= targetRemote then
            return oldNamecall(self, ...)
        end

        if not AutoBlackFlash then
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
        local args = {...}

        local target = findNearestTarget()
        local targetRoot = target and target:FindFirstChild("HumanoidRootPart")

        -- Dash round 1
        task.spawn(function()
            if targetRoot and targetRoot.Parent and isLocalAlive() then
                performCurvedDash(targetRoot)
            end
        end)

        task.delay(CONFIG.FireDelay, function()
            if not isLocalAlive() then
                isCooling = false
                return
            end

            if not targetRoot or not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                isCooling = false
                return
            end

            -- THẤT BẠI → Cancel + Retry
            if not isTargetFacingAway(targetRoot) then
                if returnSkillRemote then
                    pcall(function()
                        returnSkillRemote:FireServer()
                    end)
                end

                task.spawn(function()
                    task.wait(CONFIG.RetryDelay)

                    if not isLocalAlive() then
                        isCooling = false
                        return
                    end

                    if not targetRoot or not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                        isCooling = false
                        return
                    end

                    local dashSuccess = performCurvedDash(targetRoot)
                    task.wait(0.05)

                    if not isLocalAlive() or not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                        isCooling = false
                        return
                    end

                    local shouldRetryFire = (_G.retryfire ~= nil) and _G.retryfire or CONFIG.RetryFire

                    -- Chỉ fire retry khi đủ điều kiện (đã bỏ Distance Check)
                    if dashSuccess and isTargetFacingAway(targetRoot) and shouldRetryFire then
                        isRetrying = true
                        local success, err = pcall(function()
                            targetRemote:FireServer(table.unpack(args))
                            task.wait(CONFIG.FireDelay)
                            if isLocalAlive() and targetRoot and targetRoot.Parent and isAliveModel(targetRoot.Parent) then
                                targetRemote:FireServer(table.unpack(args))
                            end
                        end)
                        isRetrying = false
                    end

                    isCooling = false
                end)
            else
                -- THÀNH CÔNG
                pcall(function()
                    targetRemote:FireServer(table.unpack(args))
                end)
                isCooling = false
            end
        end)

        return result
    end)
end

-- ──────────────────────────────────────────────
--  UI
-- ──────────────────────────────────────────────
Window:AddToggle({
    text = "Auto Black Flash",
    flag = "AutoBlackFlash",
    callback = function(value)
        AutoBlackFlash = value
    end
})

Window:AddToggle({
    text = "Auto Counter [Beta]",
    flag = "AutoCounter",
    callback = function(value)
        -- chưa làm
    end
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()
