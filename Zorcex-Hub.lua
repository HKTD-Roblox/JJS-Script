if getgenv().ZorcexHub then
    return
end
getgenv().ZorcexHub = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local JJS_GAME_ID = 3508322461

pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

local oldTbo = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("TBO")
if oldTbo then
    oldTbo:Destroy()
end
local oldZorcex = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ZorcexHub")
if oldZorcex then
    oldZorcex:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZorcexHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 190)
frame.Position = UDim2.new(0.5, -210, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "Zorcex Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = frame

local line1 = Instance.new("TextLabel")
line1.Size = UDim2.new(1, -20, 0, 20)
line1.Position = UDim2.new(0, 10, 0, 50)
line1.Font = Enum.Font.Gotham
line1.TextSize = 16
line1.TextColor3 = Color3.fromRGB(200, 200, 200)
line1.BackgroundTransparency = 1
line1.TextXAlignment = Enum.TextXAlignment.Left
line1.Text = "Welcome, " .. LocalPlayer.Name
line1.Parent = frame

local line2 = Instance.new("TextLabel")
line2.Size = UDim2.new(1, -20, 0, 20)
line2.Position = UDim2.new(0, 10, 0, 70)
line2.Font = Enum.Font.Gotham
line2.TextSize = 16
line2.TextColor3 = Color3.fromRGB(200, 200, 200)
line2.BackgroundTransparency = 1
line2.TextXAlignment = Enum.TextXAlignment.Left
line2.Text = "Waiting for Character..."
line2.Parent = frame

local line3 = Instance.new("TextLabel")
line3.Size = UDim2.new(1, -20, 0, 20)
line3.Position = UDim2.new(0, 10, 0, 90)
line3.Font = Enum.Font.Gotham
line3.TextSize = 16
line3.TextColor3 = Color3.fromRGB(200, 200, 200)
line3.BackgroundTransparency = 1
line3.TextXAlignment = Enum.TextXAlignment.Left
line3.Text = "Checking game..."
line3.Parent = frame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -20, 0, 25)
barBg.Position = UDim2.new(0, 10, 1, -40)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.Parent = frame
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 8)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
bar.Parent = barBg

TweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
    Position = UDim2.new(0.5, -210, 0.5, -95)
}):Play()

local function notify(titleText, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titleText,
            Text = text,
            Duration = 5
        })
    end)
end

task.spawn(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char:FindFirstChildOfClass("ForceField") then
        repeat
            task.wait()
            char = LocalPlayer.Character
        until char and not char:FindFirstChildOfClass("ForceField")
    end

    line2.Text = "Found Character!"
    line2.TextColor3 = Color3.fromRGB(0, 255, 0)

    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    local isJJS = (game.GameId == JJS_GAME_ID)

    if isJJS then
        line3.Text = "Game: " .. gameName .. " - Supported"
        line3.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        line3.Text = "Game: " .. gameName .. " - Not Supported"
        line3.TextColor3 = Color3.fromRGB(255, 0, 0)
    end

    for i = 1, 100 do
        bar.Size = UDim2.new(i / 100, 0, 1, 0)
        task.wait(0.02)
    end

    TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -210, 1, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.6)
    screenGui:Destroy()

    if not isJJS then
        notify("Zorcex Hub", "This script only supports Jujutsu Shenanigans.")
        return
    end

    local aliveOk = false
    pcall(function()
        local body = game:HttpGet("https://peeky.pythonanywhere.com/Alive")
        if string.find(tostring(body), "yes") then
            aliveOk = true
        end
    end)

    if not aliveOk then
        notify("Zorcex Hub", "Script is currently down.")
        return
    end

    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://zorcex-script.web.app/Jujutsu-Shenanigans"))()
    end)

    if not ok then
        notify("Zorcex Hub", "Failed to load Jujutsu Shenanigans script.")
        warn("[Zorcex Hub]", err)
    end
end)
