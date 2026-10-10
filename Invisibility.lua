local enabled5 = false
local enabled = true
local enabled2 = false
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character
if not character then
    character = localPlayer.CharacterAdded:Wait()
end
local enabled3 = false
character.Archivable = true
local v9 = character.Clone(character)
local v88 = nil
local part = Instance.new("Part", workspace)
local v10 = part
v10.Anchored = true
v10.Size = Vector3.new(200, 1, 200)
v10.CFrame = CFrame.new(0, -500, 0)
v10.CanCollide = true
v9.Parent = workspace
v9.HumanoidRootPart.CFrame = v10.CFrame * CFrame.new(0, 5, 0)
local v100, v110, v126
v100, v110, v126 = pairs(character.GetChildren(character))
local v158
for _, v in v100, v110, v126 do
    if v:IsA("LocalScript") then
        v158 = v:Clone()
        v158.Disabled = true
        v158.Parent = v9
    end
end
local v102, v113, v129
if enabled then
    v102, v113, v129 = pairs(v9.GetDescendants(v9))
    for _, v2 in v102, v113, v129 do
        if v2:IsA("BasePart") then
            v2.Transparency = 0.7
        end
    end
end
local enabled4 = true
local function fn3()
    enabled4 = false
    character:Destroy()
    character = localPlayer.Character
    enabled4 = true
    isinvisible = false
    v9:Destroy()
    workspace.CurrentCamera.CameraSubject = character.Humanoid
    character.Archivable = true
    local clone = character:Clone()
    v9 = clone
    v10:Destroy()
    local part2 = Instance.new("Part", workspace)
    v10 = part2
    v10.Anchored = true
    v10.Size = Vector3.new(200, 1, 200)
    v10.CFrame = CFrame.new(9999, 9999, 9999)
    v10.CanCollide = true
    v9.Parent = workspace
    v9.HumanoidRootPart.CFrame = v10.CFrame * CFrame.new(0, 5, 0)
    local v198, v228, v243
    v198, v228, v243 = pairs(character:GetChildren())
    local v263
    for _, v3 in v198, v228, v243 do
        if v3:IsA("LocalScript") then
            v263 = v3:Clone()
            v263.Disabled = true
            v263.Parent = v9
        end
    end
    local v201, v232, v246
    if enabled then
        v201, v232, v246 = pairs(v9:GetDescendants())
        for _, v4 in v201, v232, v246 do
            if v4:IsA("BasePart") then
                v4.Transparency = 0.7
            end
        end
    end
    local died2 = character.Humanoid.Died
    local function fn8()
        character:Destroy()
        v9:Destroy()
    end
    died2:Connect(fn8)
    localPlayer.CharacterAppearanceLoaded:Connect(RealCharacterDied)
end
RealCharacterDied = fn3
local died = character.Humanoid.Died
local function fn4()
    character:Destroy()
    v9:Destroy()
end
died:Connect(fn4)
localPlayer.CharacterAppearanceLoaded:Connect(RealCharacterDied)
local v11 = nil
local RunService = game:GetService("RunService")
local renderStepped = RunService.RenderStepped
local function fn6()
    if v11 ~= nil then
        v11.CFrame = v10.CFrame * CFrame.new(0, 5, 0)
    end
    if enabled2 then
        v9.Humanoid:ChangeState(11)
    end
end
renderStepped:Connect(fn6)
v11 = v9.HumanoidRootPart
local function fn()
    local v309, v312, v326, v341, v353, v364, v367, v370
    if enabled3 == false then
        v309 = character.HumanoidRootPart.CFrame
        character.HumanoidRootPart.CFrame = v9.HumanoidRootPart.CFrame
        v9.HumanoidRootPart.CFrame = v309
        character.Humanoid:UnequipTools()
        localPlayer.Character = v9
        workspace.CurrentCamera.CameraSubject = v9.Humanoid
        v11 = character.HumanoidRootPart
        v326, v353, v367 = pairs(v9:GetChildren())
        for _, v5 in v326, v353, v367 do
            if v5:IsA("LocalScript") then
                v5.Disabled = false
            end
        end
        enabled3 = true
    else
        v312 = v9.HumanoidRootPart.CFrame
        v9.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
        character.HumanoidRootPart.CFrame = v312
        v9.Humanoid:UnequipTools()
        localPlayer.Character = character
        workspace.CurrentCamera.CameraSubject = character.Humanoid
        v11 = v9.HumanoidRootPart
        v341, v364, v370 = pairs(v9:GetChildren())
        for _, v6 in v341, v364, v370 do
            if v6:IsA("LocalScript") then
                v6.Disabled = true
            end
        end
        enabled3 = false
    end
end
local UserInputService = game:GetService("UserInputService")
local inputBegan = UserInputService.InputBegan
local function fn7(arg, arg2)
    if arg2 then
        return
    end
    if arg.KeyCode.Name:lower() == Keybind:lower() then
        if enabled4 then
            if character then
                if v9 then
                    if character:FindFirstChild("HumanoidRootPart") then
                        if v9:FindFirstChild("HumanoidRootPart") then
                            fn()
                        end
                    end
                end
            end
        end
    end
end
inputBegan:Connect(fn7)
local function fn5()
    local function fn2(arg3)
        local v601 = arg3:lower()
        local v604, v609, v612
        v604, v609, v612 = ipairs(game.Players:GetPlayers())
        local v57, v620
        for _, v7 in v604, v609, v612 do
            v620 = v7.Name:lower():find(v601)
            local skipped = false
            if not v620 then
                if not v7.DisplayName:lower():find(v601) then
                    skipped = true
                end
            end
            if not skipped then
                if v57 then
                    return nil
                end
                v57 = v7
            end
        end
        return v57
    end
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local textLabel = Instance.new("TextLabel")
    local textLabel2 = Instance.new("TextLabel")
    local textBox = Instance.new("TextBox")
    local textButton = Instance.new("TextButton")
    local textButton2 = Instance.new("TextButton")
    screenGui.Parent = game.CoreGui
    frame.Parent = screenGui
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0.35, 0, 0.35, 0)
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Active = true
    frame.Draggable = true
    textLabel.Parent = frame
    textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textLabel.BorderSizePixel = 0
    textLabel.Size = UDim2.new(1, 0, 0, 30)
    textLabel.Font = Enum.Font.SourceSans
    textLabel.Text = "Credits X"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 20
    textLabel2.Parent = frame
    textLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel2.BackgroundTransparency = 1
    textLabel2.Position = UDim2.new(0.15, 0, 0.25, 0)
    textLabel2.Size = UDim2.new(0, 200, 0, 50)
    textLabel2.Font = Enum.Font.SourceSans
    textLabel2.Text = "Enter Player Name:"
    textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel2.TextSize = 14
    textLabel2.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = frame
    textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0.15, 0, 0.4, 0)
    textBox.Size = UDim2.new(0.7, 0, 0, 30)
    textBox.Font = Enum.Font.SourceSans
    textBox.PlaceholderText = "Username"
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    textBox.TextSize = 14
    textButton.Parent = frame
    textButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    textButton.BorderSizePixel = 0
    textButton.Position = UDim2.new(0.15, 0, 0.65, 0)
    textButton.Size = UDim2.new(0, 100, 0, 30)
    textButton.Font = Enum.Font.SourceSans
    textButton.Text = "Invisible OFF"
    textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton.TextSize = 14
    textButton2.Parent = frame
    textButton2.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    textButton2.BorderSizePixel = 0
    textButton2.Position = UDim2.new(0.6, 0, 0.65, 0)
    textButton2.Size = UDim2.new(0, 100, 0, 30)
    textButton2.Font = Enum.Font.SourceSans
    textButton2.Text = "Teleport"
    textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton2.TextSize = 14
    local mouseButton1Click = textButton.MouseButton1Click
    local function fn9()
        if enabled3 then
            textButton.Text = "Invisible OFF"
            textButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        else
            textButton.Text = "Invisible ON"
            textButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
        fn()
    end
    mouseButton1Click:Connect(fn9)
    local mouseButton1Click2 = textButton2.MouseButton1Click
    local function fn10()
        local v654 = fn2(textBox.Text)
        if v654 then
            if v654.Character then
                if v654.Character:FindFirstChild("HumanoidRootPart") then
                    if enabled3 then
                        v9.HumanoidRootPart.CFrame = v654.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    else
                        character.HumanoidRootPart.CFrame = v654.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end
    end
    mouseButton1Click2:Connect(fn10)
end
fn5()
