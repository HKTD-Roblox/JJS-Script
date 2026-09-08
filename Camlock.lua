local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────
--  NATIVE ROBLOX NOTIFICATION WITH YES / NO
-- ──────────────────────────────────────────────
local Bindable = Instance.new("BindableFunction")

Bindable.OnInvoke = function(answer)
    if answer == "Yes" then
        -- ====================== START CAMLOCK SCRIPT ======================

        local isLocked = false
        local lockedTarget = nil
        local lockConnection = nil
        local isDragging = false
        local holdStart = 0
        local HOLD_TIME = 2.5

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "CamLockGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Parent = PlayerGui

        -- Crosshair
        local CrosshairFrame = Instance.new("Frame")
        CrosshairFrame.Name = "Crosshair"
        CrosshairFrame.Size = UDim2.new(0, 40, 0, 40)
        CrosshairFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
        CrosshairFrame.BackgroundTransparency = 1
        CrosshairFrame.Visible = false
        CrosshairFrame.Parent = ScreenGui

        local CenterDot = Instance.new("Frame")
        CenterDot.Name = "CenterDot"
        CenterDot.Size = UDim2.new(0, 4, 0, 4)
        CenterDot.Position = UDim2.new(0.5, -2, 0.5, -2)
        CenterDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        CenterDot.BorderSizePixel = 0
        CenterDot.Parent = CrosshairFrame

        local CenterCorner = Instance.new("UICorner")
        CenterCorner.CornerRadius = UDim.new(1, 0)
        CenterCorner.Parent = CenterDot

        local function createLine(name, size, pos)
            local line = Instance.new("Frame")
            line.Name = name
            line.Size = size
            line.Position = pos
            line.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
            line.BackgroundTransparency = 0.35
            line.BorderSizePixel = 0
            line.Parent = CrosshairFrame
            return line
        end

        local LineTop    = createLine("Top",    UDim2.new(0, 2, 0, 12), UDim2.new(0.5, -1, 0, 2))
        local LineBottom = createLine("Bottom", UDim2.new(0, 2, 0, 12), UDim2.new(0.5, -1, 1, -14))
        local LineLeft   = createLine("Left",   UDim2.new(0, 12, 0, 2), UDim2.new(0, 2, 0.5, -1))
        local LineRight  = createLine("Right",  UDim2.new(0, 12, 0, 2), UDim2.new(1, -14, 0.5, -1))

        -- Button
        local Button = Instance.new("ImageButton")
        Button.Name = "CamLockButton"
        Button.Size = UDim2.new(0, 70, 0, 70)
        Button.Position = UDim2.new(1, -90, 0.55, 0)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.BackgroundTransparency = 0.35
        Button.BorderSizePixel = 0
        Button.Image = "rbxassetid://6031094678"
        Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Button.ScaleType = Enum.ScaleType.Fit
        Button.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0.5, 0)
        ButtonCorner.Parent = Button

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Thickness = 1.5
        ButtonStroke.Transparency = 0.4
        ButtonStroke.Parent = Button

        -- Utils
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
                if not onScreen or depth < 0 then return end

                local distToCenter = (screenPos - center).Magnitude
                local worldDist = (root.Position - Camera.CFrame.Position).Magnitude
                local score = distToCenter * 1.8 + worldDist * 0.35

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

        local function stopLock()
            isLocked = false
            lockedTarget = nil
            CrosshairFrame.Visible = false
            if lockConnection then
                lockConnection:Disconnect()
                lockConnection = nil
            end
            ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
        end

        local function startLock(target)
            if not target or not isAlive(target) then return end
            lockedTarget = target
            isLocked = true
            CrosshairFrame.Visible = true
            ButtonStroke.Color = Color3.fromRGB(255, 80, 80)

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

                local camPos = Camera.CFrame.Position
                Camera.CFrame = CFrame.lookAt(camPos, root.Position)

                local screenPos = Camera:WorldToViewportPoint(root.Position)
                local viewport = Camera.ViewportSize
                local offsetX = math.clamp((screenPos.X - viewport.X / 2) * 0.08, -6, 6)
                local offsetY = math.clamp((screenPos.Y - viewport.Y / 2) * 0.08, -6, 6)

                LineTop.Position    = UDim2.new(0.5, -1 + offsetX, 0, 2 + offsetY)
                LineBottom.Position = UDim2.new(0.5, -1 + offsetX, 1, -14 + offsetY)
                LineLeft.Position   = UDim2.new(0, 2 + offsetX, 0.5, -1 + offsetY)
                LineRight.Position  = UDim2.new(1, -14 + offsetX, 0.5, -1 + offsetY)
            end)
        end

        local function toggleLock()
            if isLocked then
                stopLock()
            else
                local target = findBestTarget()
                if target then
                    startLock(target)
                end
            end
        end

        -- Button Input
        local dragStartPos = nil
        local buttonStartPos = nil

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                holdStart = tick()
                isDragging = false
                dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
                buttonStartPos = Button.Position
            end
        end)

        Button.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragStartPos then
                if tick() - holdStart >= HOLD_TIME then
                    isDragging = true
                    local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not isDragging and (tick() - holdStart) < HOLD_TIME then
                    toggleLock()
                end
                isDragging = false
                dragStartPos = nil
            end
        end)

        LocalPlayer.CharacterAdded:Connect(function()
            stopLock()
        end)

        -- ====================== END CAMLOCK SCRIPT ======================
    end
    -- Nếu bấm "No" thì không làm gì cả
end

-- Hiện thông báo native của Roblox
StarterGui:SetCore("SendNotification", {
    Title = "Camlock Script",
    Text = "Do you want to enable the Camlock script?",
    Duration = 999999, -- không tự tắt
    Callback = Bindable,
    Button1 = "Yes",
    Button2 = "No"
})
