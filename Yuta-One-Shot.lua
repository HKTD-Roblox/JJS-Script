local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local skillActive = false
local movementConnection = nil
local keyConnection = nil
local selectedDevice = nil

local BUTTON_IMAGE = "rbxassetid://6256840888"
local ICON_IMAGE = "rbxassetid://12637670015"

local function showNotification(title, text, duration, button1, button2, callback)
    pcall(function()
        local data = {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 5,
        }
        if button1 then
            data.Button1 = button1
        end
        if button2 then
            data.Button2 = button2
        end
        if callback then
            data.Callback = callback
        end
        StarterGui:SetCore("SendNotification", data)
    end)
end

local function activateSkill()
    if skillActive or not localPlayer.Character then
        return
    end
    local character = localPlayer.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not head or not humanoid then
        return
    end
    skillActive = true
    humanoid.PlatformStand = true
    head.Anchored = true
    local moveset = character:FindFirstChild("Moveset")
    local resoluteSlash = moveset and moveset:FindFirstChild("Resolute Slash")
    if resoluteSlash then
        pcall(function()
            replicatesignal(localPlayer.Kill)
        end)
        task.wait(0.1)
        local target = nil
        pcall(function()
            local knit = require(ReplicatedStorage.Knit.Knit)
            target = knit.GetController("ToolController"):GetTarget()
        end)
        local skillTarget = (target and target.Parent) and target or character
        local knitFolder = ReplicatedStorage:FindFirstChild("Knit")
        if knitFolder then
            knitFolder.Knit.Services.ResoluteSlashService.RE.Activated:FireServer(resoluteSlash, skillTarget)
        end
    end
    if movementConnection then
        movementConnection:Disconnect()
    end
    movementConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not skillActive or not head or not head.Parent then
            return
        end
        local moveDirection = humanoid.MoveDirection
        local lookVector = camera.CFrame.LookVector
        local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
        if moveDirection.Magnitude > 0 then
            moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
            local nextPosition = head.Position + (moveDirection * 28 * deltaTime)
            head.CFrame = CFrame.lookAt(nextPosition, nextPosition + flatLook)
        else
            head.CFrame = CFrame.lookAt(head.Position, head.Position + flatLook)
        end
    end)
    task.delay(4.67, function()
        if movementConnection then
            movementConnection:Disconnect()
            movementConnection = nil
        end
        skillActive = false
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = false
        end
        if head and head.Parent then
            head.Anchored = false
        end
    end)
end

local function setupMobileControls()
    local existingGui = playerGui:FindFirstChild("BlackFlashExecutor")
    if existingGui then
        existingGui:Destroy()
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BlackFlashExecutor"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    local activateButton = Instance.new("ImageButton")
    activateButton.Name = "ActivateButton"
    activateButton.Parent = screenGui
    activateButton.Size = UDim2.new(0, 70, 0, 70)
    activateButton.Position = UDim2.new(0, 20, 0.5, -35)
    activateButton.BackgroundTransparency = 1
    activateButton.Image = BUTTON_IMAGE
    activateButton.Active = true
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Name = "IconLabel"
    iconLabel.Parent = activateButton
    iconLabel.BackgroundTransparency = 1
    iconLabel.Size = UDim2.new(0, 76, 0, 76)
    iconLabel.Position = UDim2.new(0, -2, 0, -4)
    iconLabel.Image = ICON_IMAGE
    iconLabel.ZIndex = 2
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = activateButton
    activateButton.MouseButton1Click:Connect(function()
        if skillActive then
            return
        end
        activateSkill()
    end)
end

local function setupPCControls()
    if keyConnection then
        keyConnection:Disconnect()
    end
    keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.KeyCode == Enum.KeyCode.X then
            if skillActive then
                return
            end
            activateSkill()
        end
    end)
    showNotification(
        "Yuta One Shot",
        "Press X to activate One Shot!",
        5
    )
end

local function onDeviceSelected(buttonText)
    selectedDevice = buttonText
    if buttonText == "Mobile" then
        setupMobileControls()
    elseif buttonText == "PC" then
        setupPCControls()
    end
end

local function promptDeviceSelection()
    local callback = Instance.new("BindableFunction")
    callback.OnInvoke = function(buttonText)
        onDeviceSelected(buttonText)
    end
    showNotification(
        "Yuta One Shot",
        "Select the device you are playing on!",
        30,
        "Mobile",
        "PC",
        callback
    )
end

localPlayer.CharacterAdded:Connect(function()
    skillActive = false
    if movementConnection then
        movementConnection:Disconnect()
        movementConnection = nil
    end
end)

promptDeviceSelection()
