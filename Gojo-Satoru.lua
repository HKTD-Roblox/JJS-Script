local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Gojo Satoru")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

if game.PlaceId ~= 9391468976 and game.PlaceId ~= 3508322461 then
    LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local PredictionFactor = 0.08
local SafetyDistance = 3.0
local TouchDistance = 4.8
local TouchWait = 0.12
local AttemptsLimit = 12
local AttemptsDelay = 0.25
local BypassSmoothDur = 0.12

local BypassReady = false
local BypassRunning = false
local KillEnabled = false
local KillConnection = nil
local ControlsRef = nil

local function GetControls()
    local ok, controls = pcall(function()
        local scripts = LocalPlayer:WaitForChild("PlayerScripts", 2)
        local module = require(scripts:WaitForChild("PlayerModule", 2))
        return module:GetControls()
    end)
    if ok then return controls end
    return nil
end

local function DisablePlayerControl()
    ControlsRef = GetControls()
    if ControlsRef then
        pcall(function()
            ControlsRef:Disable()
        end)
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        end)
    end
end

local function EnablePlayerControl()
    if ControlsRef then
        pcall(function()
            ControlsRef:Enable()
        end)
    end
    ControlsRef = nil
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end)
    end
end

local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetVelocity(root)
    local ok, vel = pcall(function()
        return root.AssemblyLinearVelocity
    end)
    if ok and typeof(vel) == "Vector3" then
        return vel
    end
    return root.Velocity or Vector3.zero
end

local function GetAllAlivePlayers()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if IsAlive(char) then
                local root = GetHRP(char)
                if root then
                    table.insert(list, root)
                end
            end
        end
    end
    return list
end

local function GetNearestPlayer()
    local myHRP = GetHRP(LocalPlayer.Character)
    if not myHRP then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, root in ipairs(GetAllAlivePlayers()) do
        local dist = (root.Position - myHRP.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = root
        end
    end
    return nearest
end

local function SmoothTeleportTo(targetRoot, duration)
    local myHRP = GetHRP(LocalPlayer.Character)
    if not myHRP or not targetRoot then return false end

    local velocity = GetVelocity(targetRoot)
    local predicted = targetRoot.Position + (velocity * PredictionFactor)
    local offset = predicted - myHRP.Position

    if offset.Magnitude < 0.5 then
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, predicted)
        return true
    end

    local finalPos = predicted - (offset.Unit * SafetyDistance)
    local startCF = myHRP.CFrame
    local goalCF = CFrame.lookAt(finalPos, predicted)
    local start = tick()

    while tick() - start < duration do
        if not myHRP.Parent then return false end
        local alpha = math.clamp((tick() - start) / duration, 0, 1)
        myHRP.CFrame = startCF:Lerp(goalCF, alpha)
        RunService.Heartbeat:Wait()
    end

    if myHRP.Parent then
        myHRP.CFrame = goalCF
    end
    return true
end

local function FaceTarget(myHRP, targetPos)
    local pos = myHRP.Position
    local flatTarget = Vector3.new(targetPos.X, pos.Y, targetPos.Z)
    if (flatTarget - pos).Magnitude < 0.05 then return end
    myHRP.CFrame = CFrame.lookAt(pos, flatTarget)
end

local function RunBypassAntiCheat()
    if BypassRunning then
        Notify("Bypass Anti-Cheat", "Already running...", 2)
        return
    end
    if BypassReady then
        Notify("Bypass Anti-Cheat", "Already bypassed. Use Kill Everyone first.", 3)
        return
    end

    BypassRunning = true
    Notify("Bypass Anti-Cheat", "Running...", 2)

    task.spawn(function()
        local success = false
        for i = 1, AttemptsLimit do
            if not IsAlive(LocalPlayer.Character) then break end
            local target = GetNearestPlayer()
            if target then
                success = SmoothTeleportTo(target, BypassSmoothDur)
                if success then break end
            end
            task.wait(AttemptsDelay)
        end
        BypassRunning = false
        if success then
            BypassReady = true
            Notify("Bypass Anti-Cheat", "Success! Ready for Kill Everyone", 3)
        else
            Notify("Bypass Anti-Cheat", "Failed - Jump into the void and try again", 5)
        end
    end)
end

local function SetKillEveryone(state)
    if state then
        if not BypassReady then
            Notify("Kill Everyone", "Bypass first before using this", 3)
            return
        end

        BypassReady = false
        KillEnabled = true
        Notify("Kill Everyone", "Enabled", 2)
        DisablePlayerControl()

        local targetIndex = 1
        local waitingTouch = false
        local touchTime = 0
        local currentTarget = nil
        local hasTeleported = false

        if KillConnection then
            KillConnection:Disconnect()
            KillConnection = nil
        end

        KillConnection = RunService.Heartbeat:Connect(function()
            if not KillEnabled then return end
            if not IsAlive(LocalPlayer.Character) then return end

            local myHRP = GetHRP(LocalPlayer.Character)
            if not myHRP then return end

            local aliveList = GetAllAlivePlayers()
            if #aliveList == 0 then
                currentTarget = nil
                waitingTouch = false
                hasTeleported = false
                return
            end

            if targetIndex > #aliveList then
                targetIndex = 1
            end

            local target = aliveList[targetIndex]

            if not target or not target.Parent or not IsAlive(target.Parent) then
                targetIndex = targetIndex + 1
                currentTarget = nil
                waitingTouch = false
                hasTeleported = false
                return
            end

            if target ~= currentTarget then
                currentTarget = target
                waitingTouch = false
                touchTime = 0
                hasTeleported = false
            end

            local velocity = GetVelocity(target)
            local predicted = target.Position + (velocity * PredictionFactor)
            local dist = (predicted - myHRP.Position).Magnitude

            if not hasTeleported then
                local offset = predicted - myHRP.Position
                if offset.Magnitude > 0.05 then
                    local finalPos = predicted - (offset.Unit * SafetyDistance)
                    myHRP.CFrame = CFrame.lookAt(finalPos, predicted)
                end
                hasTeleported = true
                return
            end

            FaceTarget(myHRP, predicted)

            if dist <= TouchDistance then
                if not waitingTouch then
                    waitingTouch = true
                    touchTime = tick()
                elseif tick() - touchTime >= TouchWait then
                    targetIndex = targetIndex + 1
                    currentTarget = nil
                    waitingTouch = false
                    hasTeleported = false
                end
            else
                waitingTouch = false
            end
        end)
    else
        KillEnabled = false
        if KillConnection then
            KillConnection:Disconnect()
            KillConnection = nil
        end
        EnablePlayerControl()
        Notify("Kill Everyone", "Disabled", 2)
    end
end

Window:AddToggle({
    text = "Kill Everyone",
    flag = "KillEveryone",
    callback = function(value)
        if value then
            if not BypassReady then
                Notify("Kill Everyone", "Bypass first before using this", 3)
                return
            end
            SetKillEveryone(true)
        else
            SetKillEveryone(false)
        end
    end
})

Window:AddToggle({
    text = "Bypass Anti-Cheat",
    flag = "BypassAntiCheat",
    callback = function(value)
        if value then
            RunBypassAntiCheat()
        end
    end
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()
