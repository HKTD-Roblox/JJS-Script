local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local BLUE = Color3.fromRGB(80, 160, 255)
local RED = Color3.fromRGB(220, 60, 80)
local PURPLE = Color3.fromRGB(140, 80, 255)
local BG = Color3.fromRGB(20, 20, 35)
local TEXT = Color3.fromRGB(255, 255, 255)

local isBusy = false
local DEFAULT_STATUS = "Anti-Cheat Bypass..."
local DEFAULT_BYPASS = "BYPASS"

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getResetRemote()
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Knit", 5)
            :WaitForChild("Knit", 5)
            :WaitForChild("Services", 5)
            :WaitForChild("JoinService", 5)
            :WaitForChild("RE", 5)
            :WaitForChild("Reset", 5)
    end)
    return ok and remote or nil
end

local function findFarPlayer(minDist)
    local myHRP = getHRP(LocalPlayer.Character)
    if not myHRP then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = getHRP(plr.Character)
            if hrp then
                local d = (myHRP.Position - hrp.Position).Magnitude
                if d >= minDist then
                    return plr, hrp, d
                end
            end
        end
    end
    return nil
end

local function waitForRespawn()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
    end
    local newChar = LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    return newChar
end

local gui = Instance.new("ScreenGui")
gui.Name = "AntiCheatBypassUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0.5, -140, 0.5, -100)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = PURPLE
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 0, 32)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundColor3 = PURPLE
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = TEXT
title.Text = "Anti-Cheat Bypass"
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local bypassBtn = Instance.new("TextButton")
bypassBtn.Name = "BypassBtn"
bypassBtn.Size = UDim2.new(1, -40, 0, 36)
bypassBtn.Position = UDim2.new(0, 20, 0, 52)
bypassBtn.BackgroundColor3 = BLUE
bypassBtn.BorderSizePixel = 0
bypassBtn.Font = Enum.Font.GothamBold
bypassBtn.TextSize = 15
bypassBtn.TextColor3 = TEXT
bypassBtn.Text = DEFAULT_BYPASS
bypassBtn.AutoButtonColor = true
bypassBtn.Parent = frame

local bypassCorner = Instance.new("UICorner")
bypassCorner.CornerRadius = UDim.new(0, 8)
bypassCorner.Parent = bypassBtn

local checkBtn = Instance.new("TextButton")
checkBtn.Name = "CheckBtn"
checkBtn.Size = UDim2.new(1, -40, 0, 36)
checkBtn.Position = UDim2.new(0, 20, 0, 96)
checkBtn.BackgroundColor3 = RED
checkBtn.BorderSizePixel = 0
checkBtn.Font = Enum.Font.GothamBold
checkBtn.TextSize = 15
checkBtn.TextColor3 = TEXT
checkBtn.Text = "CHECK"
checkBtn.AutoButtonColor = true
checkBtn.Parent = frame

local checkCorner = Instance.new("UICorner")
checkCorner.CornerRadius = UDim.new(0, 8)
checkCorner.Parent = checkBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 144)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
statusLabel.BorderSizePixel = 0
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextColor3 = TEXT
statusLabel.Text = "Status: " .. DEFAULT_STATUS
statusLabel.TextWrapped = true
statusLabel.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local function setStatus(text)
    statusLabel.Text = "Status: " .. tostring(text)
end

local function setBypassText(text)
    bypassBtn.Text = tostring(text)
end

local function runBypass()
    if isBusy then return end
    isBusy = true
    bypassBtn.AutoButtonColor = false
    setBypassText("Bypassing...")
    setStatus("Teleporting...")

    local myChar = LocalPlayer.Character
    local myHRP = getHRP(myChar)
    if not myHRP then
        setBypassText(DEFAULT_BYPASS)
        setStatus(DEFAULT_STATUS)
        isBusy = false
        bypassBtn.AutoButtonColor = true
        return
    end

    local originCF = myHRP.CFrame

    local function tryOnce()
        local targetPlr, targetHRP = findFarPlayer(20)
        if not targetHRP then
            return nil
        end
        local nearPos = targetHRP.Position + Vector3.new(0, 0, 3)
        myHRP = getHRP(LocalPlayer.Character)
        if not myHRP then return nil end
        myHRP.CFrame = CFrame.new(nearPos)
        task.wait(0.15)
        myHRP = getHRP(LocalPlayer.Character)
        if not myHRP or not targetHRP.Parent then return nil end
        return (myHRP.Position - targetHRP.Position).Magnitude
    end

    while true do
        local dist = tryOnce()
        if dist == nil then
            setBypassText(DEFAULT_BYPASS)
            setStatus(DEFAULT_STATUS)
            isBusy = false
            bypassBtn.AutoButtonColor = true
            return
        end

        if dist < 10 then
            myHRP = getHRP(LocalPlayer.Character)
            if myHRP then
                myHRP.CFrame = originCF
            end
            setBypassText("Bypass successful")
            setStatus("Bypass successful")
            task.wait(5)
            setBypassText(DEFAULT_BYPASS)
            setStatus(DEFAULT_STATUS)
            isBusy = false
            bypassBtn.AutoButtonColor = true
            return
        end

        if dist > 15 then
            setStatus("Rubber Banded! Resetting...")
            local remote = getResetRemote()
            if remote then
                pcall(function()
                    remote:FireServer()
                end)
            end
            waitForRespawn()
            myHRP = getHRP(LocalPlayer.Character)
            if myHRP then
                originCF = myHRP.CFrame
            end
            setStatus("Teleporting...")
        else
            setStatus("Teleporting...")
            task.wait(0.2)
        end
    end
end

bypassBtn.MouseButton1Click:Connect(function()
    task.spawn(runBypass)
end)

checkBtn.MouseButton1Click:Connect(function()
end)
