local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ──────────────────────────────────────────────
--  NATIVE ROBLOX NOTIFICATION WITH YES / NO
-- ──────────────────────────────────────────────
local Bindable = Instance.new("BindableFunction")

Bindable.OnInvoke = function(answer)
    if answer ~= "Yes" then return end

    -- ====================== START FLY SCRIPT ======================
    local isFlying = false
    local flyConnection = nil
    local bodyVelocity = nil
    local bodyGyro = nil
    
    local originalWalkSpeed = 16
    
    -- Animation Tracks
    local idleAnimTrack = nil
    local moveAnimTrack = nil

    -- Dragging logic cho Mobile Button
    local isDragging = false
    local dragStartPos = nil
    local buttonStartPos = nil

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlyScriptGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    -- ──────────────────────────────────────────────
    --  MOBILE BUTTON
    -- ──────────────────────────────────────────────
    local Button = nil
    local ButtonStroke = nil

    if isMobile then
        Button = Instance.new("ImageButton")
        Button.Name = "FlyButton"
        Button.Size = UDim2.new(0, 56, 0, 56)
        Button.Position = UDim2.new(1, -145, 1, -210)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Button.BackgroundTransparency = 0.25
        Button.BorderSizePixel = 0
        Button.Image = "rbxassetid://13845012543"
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

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
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
                    toggleFly()
                end
                isDragging = false
                dragStartPos = nil
            end
        end)
    end

    -- ──────────────────────────────────────────────
    --  ANIMATION SETUP
    -- ──────────────────────────────────────────────
    local function setupAnimations(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local idleAnim = Instance.new("Animation")
        idleAnim.AnimationId = "rbxassetid://616006778"

        local moveAnim = Instance.new("Animation")
        moveAnim.AnimationId = "rbxassetid://616117076"

        idleAnimTrack = humanoid:LoadAnimation(idleAnim)
        moveAnimTrack = humanoid:LoadAnimation(moveAnim)

        idleAnimTrack.Priority = Enum.AnimationPriority.Action
        moveAnimTrack.Priority = Enum.AnimationPriority.Action

        idleAnimTrack.Looped = true
        moveAnimTrack.Looped = true
    end

    -- ──────────────────────────────────────────────
    --  FLY LOGIC
    -- ──────────────────────────────────────────────
    local function stopFly()
        isFlying = false

        if ButtonStroke then
            ButtonStroke.Color = Color3.fromRGB(200, 200, 200)
        end

        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end

        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

        if idleAnimTrack then idleAnimTrack:Stop() end
        if moveAnimTrack then moveAnimTrack:Stop() end

        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.WalkSpeed = originalWalkSpeed
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end

    local function startFly()
        local character = LocalPlayer.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not root or not humanoid or humanoid.Health <= 0 then return end

        isFlying = true
        originalWalkSpeed = humanoid.WalkSpeed
        
        if ButtonStroke then
            ButtonStroke.Color = Color3.fromRGB(80, 255, 80)
        end

        setupAnimations(character)

        -- Khóa trạng thái chạy mặt đất & Vô hiệu hóa nhảy
        humanoid.PlatformStand = true
        humanoid.WalkSpeed = 0
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        
        -- Reset vận tốc hiện tại
        root.AssemblyLinearVelocity = Vector3.zero

        -- Raycast kiểm tra khoảng cách đất để nâng lên 4 studs
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local groundRay = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), raycastParams)
        local targetY = root.Position.Y + 4

        if groundRay then
            local distToGround = root.Position.Y - groundRay.Position.Y
            if distToGround < 4 then
                targetY = groundRay.Position.Y + 4
            end
        end

        -- Dịch chuyển nhẹ lên không trung ngay lập tức
        root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z) * root.CFrame.Rotation

        -- Lực nâng không trọng lực
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = root

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 20000
        bodyGyro.CFrame = Camera.CFrame
        bodyGyro.Parent = root

        if idleAnimTrack then idleAnimTrack:Play() end

        -- Vòng lặp RenderStepped
        flyConnection = RunService.RenderStepped:Connect(function()
            if not isFlying or not character or not character.Parent or humanoid.Health <= 0 then
                stopFly()
                return
            end

            local moveDir = humanoid.MoveDirection
            bodyGyro.CFrame = Camera.CFrame

            -- 1. Kiểm tra va chạm tường/vật cản phía trước -> Tự tắt Fly
            local wallCheck = workspace:Raycast(root.Position, root.CFrame.LookVector * 2.5, raycastParams)
            if wallCheck and wallCheck.Instance and wallCheck.Instance.CanCollide then
                stopFly()
                return
            end

            -- 2. Tự động đẩy lên cao 4 studs nếu tụt xuống quá sát đất lúc đứng yên
            local currentGroundRay = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), raycastParams)
            if currentGroundRay and (root.Position.Y - currentGroundRay.Position.Y) < 4 and moveDir.Magnitude == 0 then
                root.CFrame = CFrame.new(root.Position.X, currentGroundRay.Position.Y + 4, root.Position.Z) * root.CFrame.Rotation
            end

            -- 3. Xử lý di chuyển không trung tốc độ 100
            if moveDir.Magnitude > 0 then
                -- Tính toán hướng di chuyển dựa trên góc quay Camera
                local camCFrame = Camera.CFrame
                local flyDir = (camCFrame.RightVector * moveDir.X) + (camCFrame.LookVector * -moveDir.Z)
                
                bodyVelocity.Velocity = flyDir.Unit * 100

                if idleAnimTrack and idleAnimTrack.IsPlaying then idleAnimTrack:Stop() end
                if moveAnimTrack and not moveAnimTrack.IsPlaying then 
                    moveAnimTrack:Play()
                    moveAnimTrack:AdjustSpeed(1) -- Giữ nguyên tốc độ gốc của Animation
                end
            else
                bodyVelocity.Velocity = Vector3.zero

                if moveAnimTrack and moveAnimTrack.IsPlaying then moveAnimTrack:Stop() end
                if idleAnimTrack and not idleAnimTrack.IsPlaying then idleAnimTrack:Play() end
            end
        end)
    end

    function toggleFly()
        if isFlying then
            stopFly()
        else
            startFly()
        end
    end

    -- ──────────────────────────────────────────────
    --  PC KEYBIND (V)
    -- ──────────────────────────────────────────────
    if not isMobile then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.V then
                toggleFly()
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        stopFly()
    end)

    -- ====================== END FLY SCRIPT ======================
end

-- Hiện thông báo native
StarterGui:SetCore("SendNotification", {
    Title = "Fly Script",
    Text = "Do you want to enable the Fly script?",
    Duration = 999999,
    Callback = Bindable,
    Button1 = "Yes",
    Button2 = "No"
})
