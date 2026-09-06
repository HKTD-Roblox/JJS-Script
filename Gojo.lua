local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("JJS - Gojo 0.2 Sweep All")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local JJS_PLACE_ID = 9391468976
if game.PlaceId ~= JJS_PLACE_ID then
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
local SafetyDistance = 1.0
local SmoothSpeed = 1.2
local StayTime = 0.05
local AttemptsLimit = 12
local AttemptsDelay = 0.25
local BypassSmoothDur = 0.12

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

    if offset.Magnitude < 0.4 then
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

local SweepEnabled = false
local SweepConnection = nil
local TargetIndex = 1
local TargetStartTime = 0
local CurrentTarget = nil

local function SetSweepAll(state)
    SweepEnabled = state

    if SweepConnection then
        SweepConnection:Disconnect()
        SweepConnection = nil
    end

    TargetIndex = 1
    TargetStartTime = 0
    CurrentTarget = nil

    if state then
        Notify("Sweep All", "Enabled", 2)

        SweepConnection = RunService.Heartbeat:Connect(function(dt)
            if not SweepEnabled then return end
            if not IsAlive(LocalPlayer.Character) then return end

            local aliveList = GetAllAlivePlayers()
            if #aliveList == 0 then
                CurrentTarget = nil
                return
            end

            if TargetIndex > #aliveList then
                TargetIndex = 1
            end

            local target = aliveList[TargetIndex]

            if not target or not target.Parent or not IsAlive(target.Parent) then
                TargetIndex = TargetIndex + 1
                TargetStartTime = tick()
                CurrentTarget = nil
                return
            end

            if target ~= CurrentTarget then
                CurrentTarget = target
                TargetStartTime = tick()
            end

            if tick() - TargetStartTime >= StayTime then
                TargetIndex = TargetIndex + 1
                CurrentTarget = nil
                return
            end

            local myHRP = GetHRP(LocalPlayer.Character)
            if not myHRP then return end

            local velocity = GetVelocity(target)
            local predicted = target.Position + (velocity * PredictionFactor)
            local offset = predicted - myHRP.Position

            if offset.Magnitude < 0.3 then
                myHRP.CFrame = CFrame.lookAt(myHRP.Position, predicted)
                return
            end

            local finalPos = predicted - (offset.Unit * SafetyDistance)
            local alpha = math.clamp(SmoothSpeed * dt * 60, 0, 1)
            myHRP.CFrame = myHRP.CFrame:Lerp(CFrame.lookAt(finalPos, predicted), alpha)
        end)
    else
        Notify("Sweep All", "Disabled", 2)
    end
end

local BypassRunning = false

local function RunBypassAntiCheat()
    if BypassRunning then
        Notify("Bypass Anti-Cheat", "Already running...", 2)
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
            Notify("Bypass Anti-Cheat", "Success!", 3)
        else
            Notify("Bypass Anti-Cheat", "Failed - Jump into the void and try again", 5)
        end
    end)
end

Window:AddToggle({
    text = "Sweep All",
    flag = "SweepAll",
    callback = function(value)
        SetSweepAll(value)
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
