local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if game.PlaceId ~= 9391468976 then
    LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

-- ──────────────────────────────────────────────
--  NATIVE ROBLOX NOTIFICATION WITH YES / NO
-- ──────────────────────────────────────────────
local Bindable = Instance.new("BindableFunction")

Bindable.OnInvoke = function(answer)
    if answer ~= "Yes" then return end

    -- ====================== START CAMLOCK SCRIPT ======================
    local isLocked = false
    local lockedTarget = nil
    local lockConnection = nil
    local isDragging = false
    local dragStartPos = nil
    local buttonStartPos = nil
    local holdStart = 0

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CamLockGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    -- ──────────────────────────────────────────────
    --  CROSSHAIR (follows target)
    -- ──────────────────────────────────────────────
    local CrosshairFrame = Instance.new("Frame")
    CrosshairFrame.Name = "Crosshair"
    CrosshairFrame.Size = UDim2.new(0, 36, 0, 36)
    CrosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrosshairFrame.BackgroundTransparency = 1
    CrosshairFrame.Visible = false
    CrosshairFrame.Parent = ScreenGui

    -- Center ring (O shape)
    local CenterRing = Instance.new("Frame")
    CenterRing.Name = "CenterRing"
    CenterRing.Size = UDim2.new(0, 14, 0, 14)
    CenterRing.Position = UDim2.new(0.5, -7, 0.5, -7)
    CenterRing.BackgroundTransparency = 1
    CenterRing.Parent = CrosshairFrame

    local RingStroke = Instance.new("UIStroke")
    RingStroke.Color = Color3.fromRGB(255, 70, 70)
    RingStroke.Thickness = 2.2
    RingStroke.Transparency = 0.15
    RingStroke.Parent = CenterRing

    local RingCorner = Instance.new("UICorner")
    RingCorner.CornerRadius = UDim.new(1, 0)
    RingCorner.Parent = CenterRing

    -- Outer lines (close to center, no sway)
    local function createLine(name, size, pos)
        local line = Instance.new("Frame")
        line.Name = name
        line.Size = size
        line.Position = pos
        line.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0
        line.Parent = CrosshairFrame
        return line
    end

    local LineTop    = createLine("Top",    UDim2.new(0, 2, 0, 8),  UDim2.new(0.5, -1, 0, 0))
    local LineBottom = createLine("Bottom", UDim2.new(0, 2, 0, 8),  UDim2.new(0.5, -1, 1, -8))
    local LineLeft   = createLine("Left",   UDim2.new(0, 8, 0, 2),  UDim2.new(0, 0, 0.5, -1))
    local LineRight  = createLine("Right",  UDim2.new(0, 8, 0, 2),  UDim2.new(1, -8, 0.5, -1))

    -- ──────────────────────────────────────────────
    --  MOBILE BUTTON (only on mobile)
    -- ──────────────────────────────────────────────
    local Button = nil
    local ButtonStroke = nil

    if isMobile then
        Button = Instance.new("ImageButton")
        Button.Name = "CamLockButton"
        Button.Size = UDim2.new(0, 56, 0, 56)
        Button.Position = UDim2.new(1, -145, 1, -210)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Button.BackgroundTransparency = 0.25
        Button.BorderSizePixel = 0
        Button.Image = "rbxassetid://13961481889" -- Icon tâm ngắm đúng như ảnh
        Button.ImageColor3 = Color3.fromRGB(240, 240, 240)
        Button.ScaleType = Enum.ScaleType.Fit
        Button.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = Button

        ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = Color3.fromRGB(200, 200, 200)
        ButtonStroke.Thickness = 1.8
        ButtonStroke.Transparency = 0.35
        ButtonStroke.Parent = Button

        -- Drag mượt (giữ nhẹ + kéo là được)
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                holdStart = tick()
                isDragging = false
                dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
                buttonStartPos = Button.Position
            end
        end)

        Button.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragStartPos then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
                if delta.Magnitude > 8 then
                    isDragging = true
                    Button.Position = UDim2.new(
                        buttonStartPos.X.Scale,
                        buttonStartPos.X.Offset + delta.X,
                        buttonStartPos.Y.Scale,
                        buttonStartPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        Button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not isDragging then
                    toggleLock()
                end
                isDragging = false
                dragStartPos = nil
            end
        end)
    end

    -- ──────────────────────────────────────────────
    --  UTILS
    -- ──────────────────────────────────────────────
    local function isAlive(model)
        if not model or model == LocalPlayer.Character then return false end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        return hum and root and hum.Health > 0
    end

    local function getScreenPos(worldPos)
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end

    local function findBestTarget()
        local viewport = Camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        local bestTarget = nil
        local bestScore = math.huge

        local function check(model)
            if not isAlive(model) then return end
            local root = model:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local screenPos, onScreen, depth = getScreenPos(root.Position)
            if not onScreen or depth <= 0 then return end

            local distToCenter = (screenPos - center).Magnitude
            local worldDist = (root.Position - Camera.CFrame.Position).Magnitude
            local score = distToCenter * 1.6 + worldDist * 0.3

            if score < bestScore then
                bestScore = score
                bestTarget = model
            end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                check(plr.Character)
            end
        end

        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") then
                check(obj)
            end
        end

        return bestTarget
    end

    -- ──────────────────────────────────────────────
    --  LOCK / UNLOCK
    -- ──────────────────────────────────────────────
    local function stopLock()
        isLocked = false
        lockedTarget = nil
        CrosshairFrame.Visible = false
        if lockConnection then
            lockConnection:Disconnect()
            lockConnection = nil
        end
        if ButtonStroke then
            ButtonStroke.Color = Color3.fromRGB(200, 200, 200)
        end
    end

    local function startLock(target)
        if not target or not isAlive(target) then return end

        lockedTarget = target
        isLocked = true
        CrosshairFrame.Visible = true
        if ButtonStroke then
            ButtonStroke.Color = Color3.fromRGB(255, 70, 70)
        end

        if lockConnection then lockConnection:Disconnect() end

        lockConnection = RunService.RenderStepped:Connect(function()
            if not isLocked or not lockedTarget or not isAlive(lockedTarget) then
                stopLock()
                return
            end

            local root = lockedTarget:FindFirstChild("HumanoidRootPart")
            if not root then
                stopLock()
                return
            end

            local screenPos, onScreen, depth = getScreenPos(root.Position)

            -- Ra khỏi màn hình hoặc quá xa → hủy lock
            if not onScreen or depth <= 0 or depth > 220 then
                stopLock()
                return
            end

            -- Cam lock
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.lookAt(camPos, root.Position)

            -- Crosshair follow target + scale theo khoảng cách
            local size = math.clamp(48 - (depth * 0.12), 22, 48)
            CrosshairFrame.Size = UDim2.new(0, size, 0, size)
            CrosshairFrame.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
        end)
    end

    function toggleLock()
        if isLocked then
            stopLock()
        else
            local target = findBestTarget()
            if target then
                startLock(target)
            end
        end
    end

    -- ──────────────────────────────────────────────
    --  PC KEYBIND (X)
    -- ──────────────────────────────────────────────
    if not isMobile then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.X then
                toggleLock()
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        stopLock()
    end)

    -- ====================== END CAMLOCK SCRIPT ======================
end

-- Hiện thông báo native
StarterGui:SetCore("SendNotification", {
    Title = "Camlock Script",
    Text = "Do you want to enable the Camlock script?",
    Duration = 999999,
    Callback = Bindable,
    Button1 = "Yes",
    Button2 = "No"
})
