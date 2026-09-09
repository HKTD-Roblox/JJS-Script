local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────
--  NOTIFICATION YES / NO
-- ──────────────────────────────────────────────
local Bindable = Instance.new("BindableFunction")

Bindable.OnInvoke = function(answer)
    if answer ~= "Yes" then return end

    -- ====================== START AUTO FARM ======================

    local kills = 0
    local money = 0
    local currentTarget = nil
    local farmConnection = nil
    local m1Connection = nil

    -- ──────────────────────────────────────────────
    --  FULL BLACK SCREEN UI
    -- ──────────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JJSAutoFarmGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = PlayerGui

    local BlackFrame = Instance.new("Frame")
    BlackFrame.Size = UDim2.new(1, 0, 1, 0)
    BlackFrame.Position = UDim2.new(0, 0, 0, 0)
    BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BlackFrame.BorderSizePixel = 0
    BlackFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 80)
    Title.BackgroundTransparency = 1
    Title.Text = "Jujutsu Shenanigans Auto-Farm"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 28
    Title.Font = Enum.Font.GothamBold
    Title.Parent = BlackFrame

    local KillsLabel = Instance.new("TextLabel")
    KillsLabel.Size = UDim2.new(1, 0, 0, 35)
    KillsLabel.Position = UDim2.new(0, 0, 0, 140)
    KillsLabel.BackgroundTransparency = 1
    KillsLabel.Text = "Kills: 0"
    KillsLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    KillsLabel.TextSize = 22
    KillsLabel.Font = Enum.Font.GothamBold
    KillsLabel.Parent = BlackFrame

    local MoneyLabel = Instance.new("TextLabel")
    MoneyLabel.Size = UDim2.new(1, 0, 0, 35)
    MoneyLabel.Position = UDim2.new(0, 0, 0, 180)
    MoneyLabel.BackgroundTransparency = 1
    MoneyLabel.Text = "Money: 0$"
    MoneyLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    MoneyLabel.TextSize = 22
    MoneyLabel.Font = Enum.Font.GothamBold
    MoneyLabel.Parent = BlackFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0, 230)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Searching..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 18
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = BlackFrame

    -- ──────────────────────────────────────────────
    --  MAKE CHARACTER INVISIBLE
    -- ──────────────────────────────────────────────
    local function makeInvisible(char)
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 1
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") then
                part.Enabled = false
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 1
                end
            end
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    if LocalPlayer.Character then
        makeInvisible(LocalPlayer.Character)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        makeInvisible(char)
    end)

    -- ──────────────────────────────────────────────
    --  FIND LOWEST HP TARGET
    -- ──────────────────────────────────────────────
    local function getLowestHPTarget()
        local lowest = nil
        local lowestHP = math.huge

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 and hum.Health < lowestHP then
                    lowestHP = hum.Health
                    lowest = plr
                end
            end
        end
        return lowest
    end

    -- ──────────────────────────────────────────────
    --  M1 SPAM (Animation + Remote attempt)
    -- ──────────────────────────────────────────────
    local function getM1Remote()
        local ok, remote = pcall(function()
            return ReplicatedStorage:WaitForChild("Knit", 2)
                :WaitForChild("Services", 2)
                :WaitForChild("CombatService", 2)
                :WaitForChild("RE", 2)
                :WaitForChild("M1", 2)
        end)
        if ok and remote then return remote end

        -- fallback common paths
        local paths = {
            {"Knit", "Services", "CombatService", "RE", "LeftClick"},
            {"Knit", "Services", "CombatService", "RE", "Punch"},
            {"Remotes", "M1"},
        }
        for _, path in ipairs(paths) do
            local node = ReplicatedStorage
            local found = true
            for _, name in ipairs(path) do
                node = node:FindFirstChild(name)
                if not node then found = false break end
            end
            if found then return node end
        end
        return nil
    end

    local m1Remote = getM1Remote()

    local function spamM1()
        -- Play punch animation
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://100962226150441" -- attack anim from previous scripts
                    local track = animator:LoadAnimation(anim)
                    track.Priority = Enum.AnimationPriority.Action
                    track:Play()
                    task.delay(0.4, function()
                        if track then track:Stop() end
                    end)
                end
            end
        end

        -- Fire remote if found
        if m1Remote then
            pcall(function()
                m1Remote:FireServer()
            end)
        end
    end

    -- ──────────────────────────────────────────────
    --  MAIN FARM LOOP
    -- ──────────────────────────────────────────────
    local function startFarm()
        farmConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            local myHum = char and char:FindFirstChildOfClass("Humanoid")

            if not myRoot or not myHum or myHum.Health <= 0 then
                StatusLabel.Text = "Status: Waiting for character..."
                return
            end

            -- Check current target still valid
            if currentTarget then
                local tChar = currentTarget.Character
                local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

                if not tHum or tHum.Health <= 0 or not tRoot then
                    -- Target died
                    kills = kills + 1
                    money = money + 5
                    KillsLabel.Text = "Kills: " .. kills
                    MoneyLabel.Text = "Money: " .. money .. "$"
                    currentTarget = nil
                    StatusLabel.Text = "Status: Target eliminated. Searching..."
                end
            end

            -- Find new target if needed
            if not currentTarget then
                currentTarget = getLowestHPTarget()
                if currentTarget then
                    StatusLabel.Text = "Status: Farming " .. currentTarget.Name
                else
                    StatusLabel.Text = "Status: No targets found..."
                    return
                end
            end

            local tChar = currentTarget.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")

            if not tRoot or not tHum or tHum.Health <= 0 then
                currentTarget = nil
                return
            end

            -- Teleport behind target (1.5 studs) + always face them + follow jump
            local behindCF = tRoot.CFrame * CFrame.new(0, 0, 1.5)
            myRoot.CFrame = CFrame.lookAt(behindCF.Position, tRoot.Position)

            -- Keep character stiff (no velocity)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)

        -- M1 spam loop
        m1Connection = RunService.Heartbeat:Connect(function()
            if currentTarget then
                spamM1()
                task.wait(0.25) -- spam speed
            end
        end)
    end

    startFarm()

    -- ====================== END AUTO FARM ======================
end

-- Hiện thông báo
StarterGui:SetCore("SendNotification", {
    Title = "JJS Auto-Farm",
    Text = "Do you want to enable the JJS Auto-Farm script?",
    Duration = 999999,
    Callback = Bindable,
    Button1 = "Yes",
    Button2 = "No"
})
