local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "Mahito BF"),
            Text = tostring(text or ""),
            Duration = duration or 3,
        })
    end)
end

local DF_CONFIG = {
    FireDelay = 0.3,
    RetryDelay = 0.04,
    RetryFire = true,
    FacingDotThreshold = -0.6,
}

if _G.retryfire ~= nil then
    DF_CONFIG.RetryFire = _G.retryfire
end

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

local targetRemote = getRemote("Knit", "Knit", "Services", "FocusStrikeService", "RE", "Activated")
local returnSkillRemote = getRemote("Knit", "Knit", "Services", "MahitoService", "RE", "RightActivated")

if not targetRemote then
    notify("Mahito BF", "Load failed", 4)
    return
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isAliveModel(model)
    local myChar = LocalPlayer.Character
    if model == myChar then
        return false
    end
    local root = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChild("Humanoid")
    return root and humanoid and humanoid.Health > 0
end

local function isTargetFacingAway(targetRoot)
    local hrp = getHRP()
    if not hrp or not targetRoot or not targetRoot.Parent then
        return false
    end
    local toPlayer = hrp.Position - targetRoot.Position
    if toPlayer.Magnitude < 0.01 then
        return false
    end
    local dot = targetRoot.CFrame.LookVector:Dot(toPlayer.Unit)
    return dot < DF_CONFIG.FacingDotThreshold
end

local function findNearestTarget()
    local hrp = getHRP()
    if not hrp then
        return nil
    end
    local nearest = nil
    local bestDist = math.huge
    local function checkModel(model)
        if not isAliveModel(model) then
            return
        end
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

local isCooling = false
local isRetrying = false

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
                pcall(function()
                    returnSkillRemote:FireServer()
                end)
            end
            task.spawn(function()
                task.wait(DF_CONFIG.RetryDelay)
                if not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                    task.defer(function()
                        isCooling = false
                    end)
                    return
                end
                local shouldRetryFire = (_G.retryfire ~= nil) and _G.retryfire or DF_CONFIG.RetryFire
                if not isTargetFacingAway(targetRoot) then
                elseif not shouldRetryFire then
                else
                    isRetrying = true
                    pcall(function()
                        targetRemote:FireServer(table.unpack(args))
                    end)
                    task.wait(DF_CONFIG.FireDelay)
                    pcall(function()
                        targetRemote:FireServer(table.unpack(args))
                    end)
                    isRetrying = false
                end
                task.defer(function()
                    isCooling = false
                end)
            end)
        else
            pcall(function()
                targetRemote:FireServer(table.unpack(args))
            end)
            task.defer(function()
                isCooling = false
            end)
        end
    end)
    return result
end)

notify("Mahito BF", "Script loaded successfully!", 3)
task.wait(3)
notify("Mahito BF", "Focus Strike + Mahito Right (no dash)", 5)
