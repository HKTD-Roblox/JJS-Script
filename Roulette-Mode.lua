-- JJS Roulette Helper
-- Mode 1: PFT / Mahito Tag
-- Mode 2: True Cannon Boss

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local Config = {
    PFT = false,
    Cannon = false,

    PFTDistance = 75,
    PFTDashDistance = 28,
    PFTDashCooldown = 1.15,

    CannonRange = 90,
    CannonOrbitSpeed = 1.15,
    CannonAttackDelay = 0.18,
    CannonHeatLimit = 0.78,

    Enabled = true
}

local State = {
    LastDash = 0,
    LastAttack = 0,
    Orbit = 0
}

local function Character()
    return LP.Character
end

local function Root(plr)
    local c = plr.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function Humanoid()
    local c = Character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(plr)
    local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function Distance(a, b)
    return (a.Position - b.Position).Magnitude
end

--------------------------------------------------
-- TARGET DETECTION
--------------------------------------------------

local function FindMahito()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and IsAlive(plr) then
            local c = plr.Character

            if c then
                local n = string.lower(c.Name .. " " .. plr.Name)

                if string.find(n, "mahito") then
                    return plr
                end

                for _, v in ipairs(c:GetDescendants()) do
                    if v:IsA("StringValue") then
                        local s = string.lower(v.Value)

                        if string.find(s, "mahito") then
                            return plr
                        end
                    end
                end
            end
        end
    end
end

local function FindBoss()
    local best
    local bestDistance = math.huge

    local myRoot = Root(LP)
    if not myRoot then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character() then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                local n = string.lower(obj.Name)

                if string.find(n, "boss")
                or string.find(n, "ryu")
                or string.find(n, "true cannon") then

                    local d = Distance(myRoot, hrp)

                    if d < bestDistance then
                        best = obj
                        bestDistance = d
                    end
                end
            end
        end
    end

    return best
end

--------------------------------------------------
-- SIMPLE MOVEMENT
--------------------------------------------------

local function FacePosition(pos)
    local r = Root(LP)
    if not r then return end

    local look = Vector3.new(
        pos.X,
        r.Position.Y,
        pos.Z
    )

    r.CFrame = CFrame.lookAt(r.Position, look)
end

local function MoveDirection(dir)
    local h = Humanoid()
    if not h then return end

    if dir.Magnitude > 0 then
        h:Move(dir.Unit, false)
    end
end

local function Dash(dir)
    local r = Root(LP)
    if not r then return end

    if os.clock() - State.LastDash < Config.PFTDashCooldown then
        return
    end

    State.LastDash = os.clock()

    local h = Humanoid()
    if h then
        h:Move(dir.Unit, false)
    end

    r.AssemblyLinearVelocity =
        Vector3.new(
            dir.X * 65,
            r.AssemblyLinearVelocity.Y,
            dir.Z * 65
        )
end

--------------------------------------------------
-- MODE 1
--------------------------------------------------

local function PFT()
    local myRoot = Root(LP)
    if not myRoot then return end

    local target = FindMahito()
    if not target then return end

    local tr = Root(target)
    if not tr then return end

    local offset = myRoot.Position - tr.Position
    local dist = offset.Magnitude

    if dist < 1 then
        offset = Vector3.new(1, 0, 0)
        dist = 1
    end

    local away = offset.Unit

    -- Không chạy thẳng.
    -- Tạo hướng ngang quanh Mahito.
    local side = Vector3.new(
        -away.Z,
        0,
        away.X
    )

    local time = os.clock()

    local wave =
        math.sin(time * 4.5) > 0 and 1 or -1

    local movement =
        (away * 0.72) +
        (side * wave * 0.85)

    if dist < Config.PFTDashDistance then
        Dash(away + side * wave)
        return
    end

    if dist < Config.PFTDistance then
        MoveDirection(movement)
    else
        MoveDirection(side * wave)
    end

    FacePosition(tr.Position)
end

--------------------------------------------------
-- TRUE CANNON
--------------------------------------------------

local function GetHeat()
    local c = Character()
    if not c then return 0 end

    for _, v in ipairs(c:GetDescendants()) do
        if v:IsA("NumberValue") then
            local n = string.lower(v.Name)

            if string.find(n, "heat")
            or string.find(n, "overheat") then

                if v.Value <= 1 then
                    return v.Value
                end
            end
        end
    end

    return 0
end

--------------------------------------------------
-- INPUT
--------------------------------------------------

local function PressKey(key)
    -- Chỉ dùng input bình thường.
    -- Không gọi remote trực tiếp.
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(
            true,
            key,
            false,
            game
        )

        task.wait(0.05)

        game:GetService("VirtualInputManager"):SendKeyEvent(
            false,
            key,
            false,
            game
        )
    end)
end

--------------------------------------------------
-- CANNON
--------------------------------------------------

local function Cannon()
    local myRoot = Root(LP)
    if not myRoot then return end

    local boss = FindBoss()
    if not boss then return end

    local br = boss:FindFirstChild("HumanoidRootPart")
    if not br then return end

    State.Orbit += Config.CannonOrbitSpeed * 0.016

    local angle = State.Orbit

    local targetDistance = Config.CannonRange

    local desired =
        br.Position +
        Vector3.new(
            math.cos(angle) * targetDistance,
            0,
            math.sin(angle) * targetDistance
        )

    local delta = desired - myRoot.Position

    -- Orbit, không teleport.
    MoveDirection(delta)

    FacePosition(br.Position)

    ------------------------------------------------
    -- OVERHEAT
    ------------------------------------------------

    local heat = GetHeat()

    if heat >= Config.CannonHeatLimit then
        PressKey(Enum.KeyCode.R)
        return
    end

    ------------------------------------------------
    -- ATTACK
    ------------------------------------------------

    if os.clock() - State.LastAttack >= Config.CannonAttackDelay then
        State.LastAttack = os.clock()

        local d = Distance(myRoot, br)

        if d <= Config.CannonRange then
            PressKey(Enum.KeyCode.One)

            task.wait(0.12)

            PressKey(Enum.KeyCode.Four)
        end
    end
end

--------------------------------------------------
-- UI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name = "JJSRouletteHelper"
Gui.ResetOnSpawn = false
Gui.Parent = LP:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(190, 135)
Main.Position = UDim2.new(0, 15, 0.5, -67)
Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90,90,100)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "JJS Roulette"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local function Button(text, y)
    local b = Instance.new("TextButton")

    b.Size = UDim2.new(1,-20,0,32)
    b.Position = UDim2.new(0,10,0,y)

    b.BackgroundColor3 = Color3.fromRGB(32,32,38)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamMedium
    b.Text = text

    b.AutoButtonColor = true
    b.Parent = Main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = b

    return b
end

local PFTButton = Button("PFT / Mahito : OFF", 35)
local CannonButton = Button("True Cannon : OFF", 73)
local CloseButton = Button("Hide", 111)

PFTButton.MouseButton1Click:Connect(function()
    Config.PFT = not Config.PFT

    PFTButton.Text =
        "PFT / Mahito : " ..
        (Config.PFT and "ON" or "OFF")
end)

CannonButton.MouseButton1Click:Connect(function()
    Config.Cannon = not Config.Cannon

    CannonButton.Text =
        "True Cannon : " ..
        (Config.Cannon and "ON" or "OFF")
end)

CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--------------------------------------------------
-- MOBILE / PC DRAG
--------------------------------------------------

local dragging = false
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end

    if Config.PFT then
        pcall(PFT)
    end

    if Config.Cannon then
        pcall(Cannon)
    end
end)
