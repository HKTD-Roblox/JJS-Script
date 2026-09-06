--======================= CHECK GAME (JJS) =======================--
local JJS_PLACE_ID = 9391468976 -- Jujutsu Shenanigans

if game.PlaceId ~= JJS_PLACE_ID then
    LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

local loadedFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = loadedFn:CreateWindow("JJS Gojo 0.2")

--======================= SERVICES =======================--
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local StarterGui  = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--======================= NOTIFY =======================--
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

--======================= CONFIG =======================--
local PredictionFactor = 0.08
local SafetyDistance   = 1.15      -- sát nhất ổn định
local SmoothSpeed      = 0.85      -- bắt kịp cực nhanh
local SwitchDelay      = 0.05      -- đổi target gần như tức thì

local AttemptsLimit    = 12
local AttemptsDelay    = 0.25
local BypassSmoothDur  = 0.12

--======================= UTILS =======================--
local function GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetNearestPlayer()
    local myHRP = GetHRP(LocalPlayer.Character)
    if not myHRP then return nil end

    local nearest, nearestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if IsAlive(char) then
                local root = GetHRP(char)
                if root then
                    local dist = (root.Position - myHRP.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = root
                    end
                end
            end
        end
    end

    return nearest
end

local function SmoothTeleportTo(targetRoot, duration)
    local myHRP = GetHRP(LocalPlayer.Character)
    if not myHRP or not targetRoot then return false end

    local velocity  = targetRoot.AssemblyLinearVelocity or Vector3.zero
    local predicted = targetRoot.Position + (velocity * PredictionFactor)
    local offset    = predicted - myHRP.Position

    if offset.Magnitude < 0.4 then return true end

    local finalPos = predicted - (offset.Unit * SafetyDistance)
    local startCF  = myHRP.CFrame
    local goalCF   = CFrame.new(finalPos, predicted)
    local start    = tick()

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

--======================= SWEEP ALL =======================--
local SweepEnabled   = false
local SweepConnection = nil
local CurrentTarget  = nil
local LastSwitchTime = 0

local function UpdateTarget()
    if CurrentTarget and CurrentTarget.Parent and IsAlive(CurrentTarget.Parent) then
        return CurrentTarget
    end

    local now = tick()
    if now - LastSwitchTime < SwitchDelay then
        return CurrentTarget
    end

    local newTarget = GetNearestPlayer()
    if newTarget ~= CurrentTarget then
        CurrentTarget  = newTarget
        LastSwitchTime = now
    end
    return CurrentTarget
end

local function SetSweepAll(state)
    SweepEnabled = state

    if SweepConnection then
        SweepConnection:Disconnect()
        SweepConnection = nil
    end
    CurrentTarget = nil

    if state then
        Notify("Sweep All", "Enabled", 2)

        SweepConnection = RunService.Heartbeat:Connect(function(dt)
            if not SweepEnabled then return end
            if not IsAlive(LocalPlayer.Character) then return end

            local target = UpdateTarget()
            if not target then return end

            local myHRP = GetHRP(LocalPlayer.Character)
            if not myHRP then return end

            local velocity  = target.AssemblyLinearVelocity or Vector3.zero
            local predicted = target.Position + (velocity * PredictionFactor)
            local offset    = predicted - myHRP.Position
            local dist      = offset.Magnitude

            if dist < 0.35 then return end

            local finalPos = predicted - (offset.Unit * SafetyDistance)
            local alpha    = math.clamp(SmoothSpeed * dt * 60, 0, 1)

            myHRP.CFrame = myHRP.CFrame:Lerp(CFrame.new(finalPos, predicted), alpha)
        end)
    else
        Notify("Sweep All", "Disabled", 2)
    end
end

--======================= BYPASS ANTI-CHEAT =======================--
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
            Notify("Bypass Anti-Cheat", "Success!", 5)
        else
            Notify("Bypass Anti-Cheat", "Failed - Jump into the void and try again", 5)
        end
    end)
end

--======================= UI =======================--
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
