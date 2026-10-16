local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Gojo Sweep All")

local state = {
    SweepAll = false,
    Bypass = false,
    Noclip = false,
}

local CONFIG = {
    SweepTime = 0.05
}

local resetCount = 0

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function fireReset()
    local ok, remote = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Knit", 2)
            :WaitForChild("Knit", 2)
            :WaitForChild("Services", 2)
            :WaitForChild("JoinService", 2)
            :WaitForChild("RE", 2)
            :WaitForChild("Reset", 2)
    end)
    if ok and remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
        return true
    end
    return false
end

local function getTarget(maxDistance)
    maxDistance = maxDistance or 500
    local targets = {}
    local myHRP = getHRP()
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrp then
                if (hrp.Position - myHRP.Position).Magnitude <= maxDistance then
                    table.insert(targets, humanoid)
                end
            end
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if humanoid and humanoid.Health > 0 and hrp then
                if (hrp.Position - myHRP.Position).Magnitude <= maxDistance then
                    table.insert(targets, humanoid)
                end
            end
        end
    end

    if #targets > 0 then
        return targets[math.random(1, #targets)]
    end
    return nil
end

RunService.Stepped:Connect(function()
    if state.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(CONFIG.SweepTime)
        if state.SweepAll then
            local myHRP = getHRP()
            local humanoid = getHumanoid()

            if myHRP and humanoid and humanoid.Health > 0 then
                local targets = {}

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        if (hrp.Position - myHRP.Position).Magnitude <= 500 then
                            table.insert(targets, hrp)
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then
                        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                        if hrp and (hrp.Position - myHRP.Position).Magnitude <= 500 then
                            table.insert(targets, hrp)
                        end
                    end
                end

                for _, targetHRP in ipairs(targets) do
                    if not state.SweepAll or not humanoid or humanoid.Health <= 0 then break end
                    if myHRP and targetHRP and targetHRP.Parent then
                        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)
                        task.wait(CONFIG.SweepTime)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if state.Bypass then
            local hrp = getHRP()
            local humanoid = getHumanoid()

            if hrp and humanoid and humanoid.Health > 0 then
                local targetHumanoid = getTarget(500)
                local targetHRP = targetHumanoid and targetHumanoid.Parent and (
                    targetHumanoid.Parent:FindFirstChild("HumanoidRootPart") or
                    targetHumanoid.Parent:FindFirstChild("Torso")
                )

                if targetHRP then
                    local startPos = hrp.Position
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)

                    local teleportedBack = false
                    local timer = 0

                    while timer < 3 do
                        task.wait(0.1)
                        timer = timer + 0.1
                        if not state.Bypass or not humanoid or humanoid.Health <= 0 then
                            break
                        end
                        if (hrp.Position - startPos).Magnitude < 10 then
                            teleportedBack = true
                            break
                        end
                    end

                    if state.Bypass and humanoid and humanoid.Health > 0 then
                        if teleportedBack then
                            while state.Bypass and humanoid and humanoid.Health > 0 do
                                if fireReset() then
                                    resetCount = resetCount + 1
                                end
                                task.wait(3)
                                humanoid = getHumanoid()
                            end
                        else
                            task.wait(2)
                        end
                    end
                end
            end
        end
    end
end)

Window:AddToggle({
    text = "Sweep All",
    flag = "SweepAll",
    state = false,
    callback = function(value)
        state.SweepAll = value
    end,
})

Window:AddToggle({
    text = "Anti-Cheat Bypass",
    flag = "Anti-CheatBypass",
    state = false,
    callback = function(value)
        state.Bypass = value
        if value then
            resetCount = 0
        end
    end,
})

Window:AddToggle({
    text = "Noclip",
    flag = "Noclip",
    state = false,
    callback = function(value)
        state.Noclip = value
    end,
})

Window:AddBox({
    text = "Time",
    value = "0.05",
    callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            CONFIG.SweepTime = num
        end
    end,
})

Window:AddLabel({
    text = "Made by Zorcex",
})

library:Init()
