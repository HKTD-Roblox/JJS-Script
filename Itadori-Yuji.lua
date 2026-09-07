local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Itadori Yuji")

-- ──────────────────────────────────────────────
--  SERVICES & PLAYER
-- ──────────────────────────────────────────────
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer

if game.PlaceId ~= 9391468976 then
    game.Players.LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

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
        trail:Destroy()
        a0:Destroy()
        a1:Destroy()
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
        if track.IsPlaying then
            track:Stop()
        end
    end)
end

-- ──────────────────────────────────────────────
--  CURVED DASH
-- ──────────────────────────────────────────────
local function performCurvedDash(targetRoot)
    local hrp = getHRP()
    if not hrp then return end

    local myPos = hrp.Position
    local destPos = (targetRoot.CFrame * CFrame.new(0, 0, CONFIG.BehindOffset)).Position

    if (myPos - destPos).Magnitude < CONFIG.AlreadyBehindTolerance then
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
        local lookDir = (i < #waypoints)
            and (waypoints[i + 1] - wp).Unit
            or (targetRoot.Position - wp).Unit

        TweenService:Create(hrp,
            TweenInfo.new(segTime, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(wp, wp + lookDir)}
        ):Play()
        task.wait(segTime)
    end

    hrp.CFrame = CFrame.lookAt(destPos, targetRoot.Position)

    if dashTrack and dashTrack.IsPlaying then
        dashTrack:Stop(0.1)
    end
    playAttackAnimation()
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

        -- Nếu tắt Auto Black Flash → chạy skill bình thường
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

        task.delay(CONFIG.FireDelay, function()
            if targetRoot and targetRoot.Parent and not isTargetFacingAway(targetRoot) then
                -- Địch quay mặt → cancel + retry
                if returnSkillRemote then
                    pcall(function()
                        returnSkillRemote:FireServer()
                    end)
                end

                task.spawn(function()
                    task.wait(CONFIG.RetryDelay)

                    if not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                        task.defer(function() isCooling = false end)
                        return
                    end

                    performCurvedDash(targetRoot)

                    local shouldRetryFire = (_G.retryfire ~= nil) and _G.retryfire or CONFIG.RetryFire

                    if not isTargetFacingAway(targetRoot) then
                        -- Retry cũng fail
                    elseif not shouldRetryFire then
                        -- Thành công nhưng không fire lại
                    else
                        -- Thành công → fire lại skill
                        isRetrying = true
                        pcall(function()
                            targetRemote:FireServer(table.unpack(args))
                        end)
                        task.wait(CONFIG.FireDelay)
                        pcall(function()
                            targetRemote:FireServer(table.unpack(args))
                        end)
                        isRetrying = false
                    end

                    task.defer(function() isCooling = false end)
                end)
            else
                -- Round 1 thành công
                pcall(function()
                    targetRemote:FireServer(table.unpack(args))
                end)
                task.defer(function() isCooling = false end)
            end
        end)

        -- Dash round 1
        task.spawn(function()
            if not targetRoot or not targetRoot.Parent then return end
            performCurvedDash(targetRoot)
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
        -- Updating...
    end
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()
