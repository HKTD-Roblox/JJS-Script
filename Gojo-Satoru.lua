local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Gojo Satoru")

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
local SafetyDistance = 2.4
local SmoothSpeed = 1.0
local TouchDistance = 3.2
local TouchWait = 0.12
local AttemptsLimit = 12
local AttemptsDelay = 0.25
local BypassSmoothDur = 0.12

local BypassReady = false
local BypassRunning = false
local KillEnabled = false
local KillConnection = nil
local InvisibleEnabled = false
local InvisibleConnection = nil

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

        local targetIndex = 1
        local waitingTouch = false
        local touchTime = 0
        local currentTarget = nil

        if KillConnection then
            KillConnection:Disconnect()
            KillConnection = nil
        end

        KillConnection = RunService.Heartbeat:Connect(function(dt)
            if not KillEnabled then return end
            if not IsAlive(LocalPlayer.Character) then return end

            local aliveList = GetAllAlivePlayers()
            if #aliveList == 0 then
                currentTarget = nil
                waitingTouch = false
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
                return
            end

            if target ~= currentTarget then
                currentTarget = target
                waitingTouch = false
                touchTime = 0
            end

            local myHRP = GetHRP(LocalPlayer.Character)
            if not myHRP then return end

            local velocity = GetVelocity(target)
            local predicted = target.Position + (velocity * PredictionFactor)
            local offset = predicted - myHRP.Position
            local dist = offset.Magnitude

            if dist <= TouchDistance then
                myHRP.CFrame = CFrame.lookAt(myHRP.Position, predicted)
                if not waitingTouch then
                    waitingTouch = true
                    touchTime = tick()
                elseif tick() - touchTime >= TouchWait then
                    targetIndex = targetIndex + 1
                    currentTarget = nil
                    waitingTouch = false
                end
                return
            end

            waitingTouch = false
            local finalPos = predicted - (offset.Unit * SafetyDistance)
            local alpha = math.clamp(SmoothSpeed * dt * 60, 0, 1)
            myHRP.CFrame = myHRP.CFrame:Lerp(CFrame.lookAt(finalPos, predicted), alpha)
        end)
    else
        KillEnabled = false
        if KillConnection then
            KillConnection:Disconnect()
            KillConnection = nil
        end
        Notify("Kill Everyone", "Disabled", 2)
    end
end

local function ApplyInvisible(char)
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Transparency = 1
            obj.LocalTransparencyModifier = -0.5
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("Accessory") then
            local handle = obj:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Transparency = 1
                handle.LocalTransparencyModifier = -0.5
            end
        end
    end
    local shirt = char:FindFirstChildOfClass("Shirt")
    local pants = char:FindFirstChildOfClass("Pants")
    local tshirt = char:FindFirstChildOfClass("ShirtGraphic")
    if shirt then shirt.ShirtTemplate = "" end
    if pants then pants.PantsTemplate = "" end
    if tshirt then tshirt.Graphic = "" end
end

local function RemoveInvisible(char)
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.Transparency = 0
            obj.LocalTransparencyModifier = 0
        elseif obj:IsA("BasePart") and obj.Name == "HumanoidRootPart" then
            obj.Transparency = 1
            obj.LocalTransparencyModifier = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0
        end
    end
end

local function SetInvisible(state)
    InvisibleEnabled = state
    if InvisibleConnection then
        InvisibleConnection:Disconnect()
        InvisibleConnection = nil
    end
    local char = LocalPlayer.Character
    if state then
        ApplyInvisible(char)
        InvisibleConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.3)
            if InvisibleEnabled then
                ApplyInvisible(newChar)
            end
        end)
        Notify("Invisible", "Enabled", 2)
    else
        RemoveInvisible(char)
        Notify("Invisible", "Disabled", 2)
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

Window:AddToggle({
    text = "Invisible",
    flag = "Invisible",
    callback = function(value)
        SetInvisible(value)
    end
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()
