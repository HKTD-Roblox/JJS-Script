local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer
local nexooo = Instance.new("ScreenGui")
nexooo.Name = "Itadori Yuji"
nexooo.ResetOnSpawn = false
nexooo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local function f1()
if not pcall(function()
    if syn and syn.protect_gui then
            syn.protect_gui(nexooo)
            nexooo.Parent = coreGui
        elseif gethui then
                nexooo.Parent = gethui()
            else
                nexooo.Parent = coreGui
            end
        end) or not nexooo.Parent then
            nexooo.Parent = localPlayer:WaitForChild("PlayerGui")
        end
    end
    f1()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 190, 0, 215)
    frame.Position = UDim2.new(0, 150, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    frame.BorderSizePixel = 0
    frame.Parent = nexooo
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(45, 45, 55)
    uiStroke.Thickness = 1
    uiStroke.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 26)
    textLabel.BackgroundColor3 = Color3a   .fromRGB(28, 28, 34)
    textLabel.Text = "  Itadori Yuji  "
    textLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Code
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = frame
    local uiCorner2 = Instance.new("UICorner")
    uiCorner2.CornerRadius = UDim.new(0, 8)
    uiCorner2.Parent = textLabel
    local frame2 = Instance.new("Frame")
    frame2.Size = UDim2.new(1, 0, 0, 6)
    frame2.Position = UDim2.new(0, 0, 1, -6)
    frame2.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    frame2.BorderSizePixel = 0
    frame2.Parent = textLabel
    local textButton = Instance.new("TextButton")
    textButton.Size = UDim2.new(1, -16, 0, 36)
    textButton.Position = UDim2.new(0, 8, 0, 38)
    textButton.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    textButton.Text = "STATUS: OFF"
    textButton.TextColor3 = Color3.fromRGB(220, 80, 80)
    textButton.TextSize = 12
    textButton.Font = Enum.Font.Code
    textButton.Parent = frame
    local uiCorner3 = Instance.new("UICorner")
    uiCorner3.CornerRadius = UDim.new(0, 6)
    uiCorner3.Parent = textButton
    local uiStroke2 = Instance.new("UIStroke")
    uiStroke2.Color = Color3.fromRGB(60, 40, 40)
    uiStroke2.Thickness = 1
    uiStroke2.Parent = textButton
    local textButton2 = Instance.new("TextButton")
    textButton2.Size = UDim2.new(1, -16, 0, 36)
    textButton2.Position = UDim2.new(0, 8, 0, 82)
    textButton2.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    textButton2.Text = "Crushing blow + R: OFF"
    textButton2.TextColor3 = Color3.fromRGB(220, 80, 80)
    textButton2.TextSize = 12
    textButton2.Font = Enum.Font.Code
    textButton2.Parent = frame
    local uiCorner4 = Instance.new("UICorner")
    uiCorner4.CornerRadius = UDim.new(0, 6)
    uiCorner4.Parent = textButton2
    local uiStroke3 = Instance.new("UIStroke")
    uiStroke3.Color = Color3.fromRGB(60, 40, 40)
    uiStroke3.Thickness = 1
    uiStroke3.Parent = textButton2
    local frame3 = Instance.new("Frame")
    frame3.Size = UDim2.new(1, -16, 0, 40)
    frame3.Position = UDim2.new(0, 8, 0, 126)
    frame3.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    frame3.Parent = frame
    local uiCorner5 = Instance.new("UICorner")
    uiCorner5.CornerRadius = UDim.new(0, 6)
    uiCorner5.Parent = frame3
    local uiStroke4 = Instance.new("UIStroke")
    uiStroke4.Color = Color3.fromRGB(50, 50, 60)
    uiStroke4.Thickness = 1
    uiStroke4.Parent = frame3
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel2.Position = UDim2.new(0, 8, 0, 0)
    textLabel2.BackgroundTransparency = 1
    textLabel2.Text = "Fire Delay:"
    textLabel2.TextColor3 = Color3.fromRGB(160, 160, 175)
    textLabel2.TextSize = 11
    textLabel2.Font = Enum.Font.Code
    textLabel2.TextXAlignment = Enum.TextXAlignment.Left
    textLabel2.Parent = frame3
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.4, -8, 1, 0)
    textBox.Position = UDim2.new(0.6, 0, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = "0.33"
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.Code
    textBox.Parent = frame3
    local frame4 = Instance.new("Frame")
    frame4.Size = UDim2.new(1, -16, 0, 40)
    frame4.Position = UDim2.new(0, 8, 0, 170)
    frame4.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    frame4.Parent = frame
    local uiCorner6 = Instance.new("UICorner")
    uiCorner6.CornerRadius = UDim.new(0, 6)
    uiCorner6.Parent = frame4
    local uiStroke5 = Instance.new("UIStroke")
    uiStroke5.Color = Color3.fromRGB(50, 50, 60)
    uiStroke5.Thickness = 1
    uiStroke5.Parent = frame4
    local textLabel3 = Instance.new("TextLabel")
    textLabel3.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel3.Position = UDim2.new(0, 8, 0, 0)
    textLabel3.BackgroundTransparency = 1
    textLabel3.Text = "Camlock Time:"
    textLabel3.TextColor3 = Color3.fromRGB(160, 160, 175)
    textLabel3.TextSize = 11
    textLabel3.Font = Enum.Font.Code
    textLabel3.TextXAlignment = Enum.TextXAlignment.Left
    textLabel3.Parent = frame4
    local textBox2 = Instance.new("TextBox")
    textBox2.Size = UDim2.new(0.4, -8, 1, 0)
    textBox2.Position = UDim2.new(0.6, 0, 0, 0)
    textBox2.BackgroundTransparency = 1
    textBox2.Text = "0.9"
    textBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox2.TextSize = 12
    textBox2.Font = Enum.Font.Code
    textBox2.Parent = frame4
    local textButton3 = Instance.new("TextButton")
    textButton3.Size = UDim2.new(0, 38, 0, 38)
    textButton3.Position = UDim2.new(0, 100, 0, 100)
    textButton3.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    textButton3.Text = "⭕"
    textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton3.TextSize = 20
    textButton3.Font = Enum.Font.GothamBold
    textButton3.Parent = nexooo
    local uiCorner7 = Instance.new("UICorner")
    uiCorner7.CornerRadius = UDim.new(1, 0)
    uiCorner7.Parent = textButton3
    local uiStroke6 = Instance.new("UIStroke")
    uiStroke6.Color = Color3.fromRGB(150, 90, 255)
    uiStroke6.Thickness = 1.5
    uiStroke6.Parent = textButton3
    local function f2(p1, p2)
    local inputBegan = (p2 or p1).InputBegan
    local v1, position, position2
    inputBegan:Connect(function(p3)
    if p3.UserInputType == Enum.UserInputType.MouseButton1
        or p3.UserInputType == Enum.UserInputType.Touch then
            v1 = true
            position = p3.Position
            position2 = p1.Position
            p3.Changed:Connect(function()
            if p3.UserInputState == Enum.UserInputState.End then
                    v1 = false
                end
            end)
        end
    end)
    local v2
    p1.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            v2 = input
        end
    end)
    userInputService.InputChanged:Connect(function(input2)
    if input2 == v2 and v1 then
            local v3 = input2.Position - position
            p1.Position = UDim2.new(
            position2.X.Scale, position2.X.Offset + v3.X, position2.Y.Scale,
            position2.Y.Offset + v3.Y
            )
        end
    end)
end
f2(frame, textLabel)
f2(textButton3)
local v4 = true
textButton3.MouseButton1Click:Connect(function()
v4 = not v4
frame.Visible = v4
end)
local v5 = {
behindOffset = 6.5,
fireDelay = 0.33,
warpDelay = 0.1,
camlockTime = 0.9,
}
textBox.FocusLost:Connect(function()
local v6 = tonumber(textBox.Text)
if v6 then
        v5.fireDelay = v6
    else
        textBox.Text = tostring(v5.fireDelay)
    end
end)
textBox2.FocusLost:Connect(function()
local v7 = tonumber(textBox2.Text)
if v7 then
        v5.camlockTime = v7
    else
        textBox2.Text = tostring(v5.camlockTime)
    end
end)
local function f3()
local character = localPlayer.Character
return character and character:FindFirstChild("HumanoidRootPart")
end
local function f4(p4)
if p4 == localPlayer.Character then
        return false
    else
        local humanoidRootPart = p4:FindFirstChild("HumanoidRootPart")
        local humanoid = p4:FindFirstChild("Humanoid")
        return humanoidRootPart and humanoid and humanoid.Health > 0
    end
end
local function f5()
local v8, v9 = pcall(function()
return replicatedStorage:WaitForChild("Knit", 3):WaitForChild("Knit", 3):WaitForChild(
"Services", 3
):WaitForChild(
"DivergentFistService", 3
):WaitForChild(
"RE", 3
):WaitForChild(
"Activated", 3
)
end)
return v8 and v9 or nil
end
local v10 = f5()
if not v10 then
        warn("oof, couldn't find the remote. game might have updated")
    end
    local activated = pcall(function()
    return replicatedStorage.Knit.Knit.Services.CrushingBlowService.RE.Activated
end) and replicatedStorage.Knit.Knit.Services.CrushingBlowService.RE.Activated or nil
local rightActivated = pcall(function()
return replicatedStorage.Knit.Knit.Services.ItadoriService.RE.RightActivated
end) and replicatedStorage.Knit.Knit.Services.ItadoriService.RE.RightActivated or nil
local function f6()
local v11 = f3()
local v12, huge
if not v11 then
        return nil
    else
        v12 = nil
        huge = math.huge
        local function f7(p5)
        if not f4(p5) then
                return
            else
                local humanoidRootPart2 = p5:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart2 then
                        local magnitude = (v11.Position - humanoidRootPart2.Position).Magnitude
                        if magnitude < huge then
                                huge = magnitude
                                v12 = p5
                            end
                        end
                        return
                    end
                end
                for index, value in ipairs(players:GetPlayers()) do
                        if value ~= localPlayer and value.Character then
                                f7(value.Character)
                            end
                        end
                        for index2, value2 in ipairs(workspace:GetDescendants()) do
                                if value2:IsA("Model") and not players:GetPlayerFromCharacter(value2) then
                                        f7(value2)
                                    end
                                end
                                return v12
                            end
                        end
                        local function f8(p6, p7, p8)
                        local character2 = localPlayer.Character
                        if not character2 then
                                return
                            end
                            local humanoidRootPart3 = character2:FindFirstChild("HumanoidRootPart")
                            local humanoid2 = character2:FindFirstChildOfClass("Humanoid")
                            if not humanoidRootPart3 or not humanoid2 or not p6 then
                                    return
                                end
                                humanoid2.AutoRotate = false
                                local v13 = tick()
                                local position3 = humanoidRootPart3.Position
                                local v14 = p8 or 6.5
                                local connect = nil
                                connect = runService.RenderStepped:Connect(function()
                                if not p6 or not p6.Parent then
                                        humanoid2.AutoRotate = true
                                        connect:Disconnect()
                                        return
                                    else
                                        local v15 = math.clamp((tick() - v13) / p7, 0, 1)
                                        if v15 >= 1 then
                                                humanoid2.AutoRotate = true
                                                connect:Disconnect()
                                                return
                                            else
                                                local cframe = p6.CFrame
                                                local position4 = cframe.Position
                                                local lerp = position3:Lerp(position4 - cframe.LookVector * v14, 1 - (1 - v15) ^ 3)
                                                humanoidRootPart3.CFrame = CFrame.lookAt(lerp, position4)
                                                return
                                            end
                                        end
                                    end)
                                end
                                local currentCamera
                                local function f9(p9)
                                local v16 = tick()
                                local renderStepped = runService.RenderStepped
                                local connect2
                                connect2 = renderStepped:Connect(function()
                                if tick() - v16 >= 0.9 or not p9 or not p9.Parent then
                                        connect2:Disconnect()
                                        return
                                    else
                                        local vector = Vector3.new(0, 1, 0)
                                        currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, p9.Position + vector)
                                        return
                                    end
                                end)
                            end
                            currentCamera = workspace.CurrentCamera
                            local v17 = false
                            getfenv().Enabled = false
                            getfenv().TuffyEnabled = false
                            local v18
                            v18 = hookmetamethod(game, "__namecall", function(p10, ...)
                            local v19 = getnamecallmethod()
                            local v20 = { ... }
                            if TuffyEnabled and v19 == "FireServer" and activated and p10 == activated then
                                    task.delay(0.4, function()
                                    pcall(function()
                                    if rightActivated then
                                            rightActivated:FireServer(nil)
                                        end
                                    end)
                                end)
                            end
                            if v19 ~= "FireServer" or p10 ~= v10 or not Enabled or v17 then
                                    return v18(p10, ...)
                                else
                                    v17 = true
                                    local v21 = v18(p10, ...)
                                    task.delay(0.33, function()
                                    pcall(function() v10:FireServer(table.unpack(v20)) end)
                                    v17 = false
                                end)
                                task.delay(0.1, function()
                                local v22 = f6()
                                if not v22 then
                                        return
                                    else
                                        local humanoidRootPart4 = v22:FindFirstChild("HumanoidRootPart")
                                        if not humanoidRootPart4 then
                                                return
                                            else
                                                f9(humanoidRootPart4)
                                                local v23 = f3()
                                                local v24 = 6.5
                                                if v23 then
                                                        local dot = humanoidRootPart4.CFrame.LookVector:Dot(v23.CFrame.LookVector)
                                                        if math.abs(dot) <= 0.5 then
                                                                v24 = 3.25
                                                            end
                                                        end
                                                        f8(humanoidRootPart4, 0.33, v24)
                                                        return
                                                    end
                                                end
                                            end)
                                            return v21
                                        end
                                    end)
                                    textButton.MouseButton1Click:Connect(function()
                                    Enabled = not Enabled
                                    if Enabled then
                                            textButton.Text = "STATUS: ON"
                                            textButton.TextColor3 = Color3.fromRGB(80, 220, 100)
                                            uiStroke2.Color = Color3.fromRGB(40, 60, 40)
                                        else
                                            textButton.Text = "STATUS: OFF"
                                            textButton.TextColor3 = Color3.fromRGB(220, 80, 80)
                                            uiStroke2.Color = Color3.fromRGB(60, 40, 40)
                                        end
                                    end)
                                    textButton2.MouseButton1Click:Connect(function()
                                    TuffyEnabled = not TuffyEnabled
                                    if TuffyEnabled then
                                            textButton2.Text = "Crushing blow + R: ON"
                                            textButton2.TextColor3 = Color3.fromRGB(80, 220, 100)
                                            uiStroke3.Color = Color3.fromRGB(40, 60, 40)
                                        else
                                            textButton2.Text = "Crushing blow + R: OFF"
                                            textButton2.TextColor3 = Color3.fromRGB(220, 80, 80)
                                            uiStroke3.Color = Color3.fromRGB(60, 40, 40)
                                        end
                                    end)
                                    game:GetService("StarterGui"):SetCore("SendNotification", {
                                        Title = "Itadori Yuji",
                                        Text = "Script loaded successfully!",
                                        Duration = 5
                                    })
