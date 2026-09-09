local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
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

    -- Remote M1
    local m1Remote = ReplicatedStorage
        :WaitForChild("Knit")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("MeleeService")
        :WaitForChild("RE")
        :WaitForChild("Activated")

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
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
                v.CanCollide = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("Accessory") then
                local handle = v:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end

    if LocalPlayer.Character then
        makeInvisible(LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.4)
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
    --  MAIN LOOP
    -- ──────────────────────────────────────────────
    local lastM1 = 0

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local myHum = char and char:FindFirstChildOfClass("Humanoid")

        if not myRoot or not myHum or myHum.Health <= 0 then
            StatusLabel.Text = "Status: Waiting for character..."
            return
        end

        -- Check target death
        if currentTarget then
            local tChar = currentTarget.Character
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

            if not tHum or tHum.Health <= 0 or not tRoot then
                kills += 1
                money += 5
                KillsLabel.Text = "Kills: " .. kills
                MoneyLabel.Text = "Money: " .. money .. "$"
                currentTarget = nil
                StatusLabel.Text = "Status: Target eliminated. Searching..."
            end
        end

        -- Find new target
        if not currentTarget then
            currentTarget = getLowestHPTarget()
            if currentTarget then
                StatusLabel.Text = "Status: Farming " .. currentTarget.Name
            else
                StatusLabel.Text = "Status: No targets found..."
                return
            end
        end

        local tRoot = currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart")
        local tHum = currentTarget.Character and currentTarget.Character:FindFirstChildOfClass("Humanoid")

        if not tRoot or not tHum or tHum.Health <= 0 then
            currentTarget = nil
            return
        end

        -- Teleport behind 1.5 studs + face target + follow jump
        local behindPos = (tRoot.CFrame * CFrame.new(0, 0, 1.5)).Position
        myRoot.CFrame = CFrame.lookAt(behindPos, tRoot.Position)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero

        -- Spam M1
        if tick() - lastM1 >= 0.22 then
            lastM1 = tick()
            pcall(function()
                m1Remote:FireServer()
            end)
        end
    end)

    -- ====================== END AUTO FARM ======================
end

StarterGui:SetCore("SendNotification", {
    Title = "JJS Auto Farm",
    Text = "Do you want to enable the JJS Auto-Farm script?",
    Duration = 999999,
    Callback = Bindable,
    Button1 = "Yes",
    Button2 = "No"
})
