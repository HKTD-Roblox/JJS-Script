local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local val = false
local val2 = 0.53
local val3 = 0.37
local val4 = 0.76
local playerGui

if not playerGui then
  playerGui = localPlayer:WaitForChild("PlayerGui")
end

if playerGui:FindFirstChild("NanamiModernUI") then
  playerGui.NanamiModernUI:Destroy()
end

local nanamiModernUI = Instance.new("ScreenGui")
nanamiModernUI.Name = "NanamiModernUI"
nanamiModernUI.ResetOnSpawn = false
nanamiModernUI.Parent = playerGui

local udim = UDim2.new(0, 230, 0, 215)
local udim2 = UDim2.new(0, 230, 0, 35)
local val5 = false

local frame = Instance.new("Frame")
frame.Size = udim
frame.Position = UDim2.new(0.5, -115, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = nanamiModernUI

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(50, 50, 60)
uiStroke.Thickness = 1
uiStroke.Parent = frame

local frame2 = Instance.new("Frame")
frame2.Size = UDim2.new(1, 0, 0, 35)
frame2.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
frame2.BorderSizePixel = 0
frame2.Parent = frame

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = frame2

local frame3 = Instance.new("Frame")
frame3.Size = UDim2.new(1, 0, 0, 10)
frame3.Position = UDim2.new(0, 0, 1, -10)
frame3.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
frame3.BorderSizePixel = 0
frame3.Parent = frame2

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -40, 1, 0)
textLabel.Position = UDim2.new(0, 12, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Auto ratio"
textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 14
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = frame2

local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(0, 35, 0, 35)
textButton.Position = UDim2.new(1, -35, 0, 0)
textButton.BackgroundTransparency = 1
textButton.Text = "â"
textButton.TextColor3 = Color3.fromRGB(200, 200, 200)
textButton.Font = Enum.Font.GothamBold
textButton.TextSize = 18
textButton.Parent = frame2

local frame4 = Instance.new("Frame")
frame4.Size = UDim2.new(1, 0, 1, -35)
frame4.Position = UDim2.new(0, 0, 0, 35)
frame4.BackgroundTransparency = 1
frame4.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = frame4

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 12)
uiPadding.PaddingBottom = UDim.new(0, 12)
uiPadding.Parent = frame4

local function createTextBox(placeholderText, val6, layoutOrder)
  local textBox = Instance.new("TextBox")
  textBox.Size = UDim2.new(1, -24, 0, 32)
  textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
  textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
  textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
  textBox.Font = Enum.Font.Gotham
  textBox.TextSize = 13
  textBox.Text = tostring(val6)
  textBox.PlaceholderText = placeholderText
  textBox.LayoutOrder = layoutOrder

  local uiCorner3 = Instance.new("UICorner")
  uiCorner3.CornerRadius = UDim.new(0, 6)
  uiCorner3.Parent = textBox

  local uiStroke2 = Instance.new("UIStroke")
  uiStroke2.Color = Color3.fromRGB(60, 60, 70)
  uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  uiStroke2.Parent = textBox

  local uiPadding2 = Instance.new("UIPadding")
  uiPadding2.PaddingLeft = UDim.new(0, 10)
  uiPadding2.Parent = textBox

  return textBox
end

local textButton2 = Instance.new("TextButton")
textButton2.Size = UDim2.new(1, -24, 0, 36)
textButton2.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
textButton2.Font = Enum.Font.GothamBold
textButton2.TextSize = 14
textButton2.Text = "OFF"
textButton2.LayoutOrder = 1
textButton2.AutoButtonColor = false
textButton2.Parent = frame4

local uiCorner4 = Instance.new("UICorner")
uiCorner4.CornerRadius = UDim.new(0, 6)
uiCorner4.Parent = textButton2

local parent = createTextBox("delay 1", val2, 2)
parent.Parent = frame4

local parent2 = createTextBox("delay 2", val3, 3)
parent2.Parent = frame4

local parent3 = createTextBox("health", val4 * 100, 4)
parent3.Parent = frame4

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

textButton.MouseButton1Click:Connect(function()
  val5 = not val5
  tweenService:Create(frame, tweenInfo, { Size = val5 and udim2 or udim }):Play()
  tweenService:Create(textButton, tweenInfo, { Rotation = val5 and 180 or 0 }):Play()
end)

textButton2.MouseButton1Click:Connect(function()
  val = not val
  local color

  if val then
    color = Color3.fromRGB(60, 200, 100)
    textButton2.Text = "ON"
  else
    color = Color3.fromRGB(200, 60, 60)
    textButton2.Text = "OFF"
  end

  tweenService:Create(textButton2, TweenInfo.new(0.2), { BackgroundColor3 = color }):Play()
end)

textButton2.MouseEnter:Connect(function()
  local color2 = val and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(220, 80, 80)
  tweenService:Create(textButton2, TweenInfo.new(0.15), { BackgroundColor3 = color2 }):Play()
end)

textButton2.MouseLeave:Connect(function()
  local color3 = val and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(200, 60, 60)
  tweenService:Create(textButton2, TweenInfo.new(0.15), { BackgroundColor3 = color3 }):Play()
end)

parent.FocusLost:Connect(function()
  local numVal = tonumber(parent.Text)

  if numVal then
    val2 = numVal
  else
    parent.Text = tostring(val2)
  end
end)

parent2.FocusLost:Connect(function()
  local numVal2 = tonumber(parent2.Text)

  if numVal2 then
    val3 = numVal2
  else
    parent2.Text = tostring(val3)
  end
end)

parent3.FocusLost:Connect(function()
  local decoded = tonumber((string.gsub(parent3.Text, "%%", "")))

  if decoded then
    local val7 = math.clamp(decoded, 0, 100)
    val4 = val7 / 100
    parent3.Text = tostring(val7)
  else
    parent3.Text = tostring(math.floor(val4 * 100))
  end
end)

local function iterate()
  local val8 = currentCamera.ViewportSize / 2
  local huge = math.huge
  local character = localPlayer.Character
  local val9

  for key, value in pairs(workspace:GetDescendants()) do
    if value:IsA("Model") and value ~= character then
      local humanoid = value:FindFirstChildOfClass("Humanoid")
      local humanoidRootPart = value:FindFirstChild("HumanoidRootPart") or value.PrimaryPart

      if humanoid and humanoid.Health > 0 and humanoidRootPart then
        local element, val10 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

        if val10 then
          local magnitude = (Vector2.new(element.X, element.Y) - val8).Magnitude

          if magnitude < huge then
            val9 = value
            huge = magnitude
          end
        end
      end
    end
  end

  return val9
end

local function helper(val11)
  if val11.Parent then
    if val11.Parent:IsA("BasePart") then
      return val11.Parent.Position
    end

    if val11.Parent:IsA("Attachment") then
      return val11.Parent.WorldPosition
    end

    return nil
  end

  return nil
end

local function helper2(val12)
  local val13

  if not val then
    return
  else
    local val14 = helper(val12)

    if not val14 then
      return
    end

    val13 = iterate()

    if not val13 then
      return
    else
      local humanoidRootPart2 = val13:FindFirstChild("HumanoidRootPart") or val13.PrimaryPart

      if not humanoidRootPart2 then
        return
      end

      if (humanoidRootPart2.Position - val14).Magnitude <= 3 then
        print("[Sound Tracker] Sound found near target: " .. val12:GetFullName())
        local val15 = 1
        local humanoid2 = val13:FindFirstChildOfClass("Humanoid")

        if humanoid2 and humanoid2.MaxHealth > 0 then
          val15 = humanoid2.Health / humanoid2.MaxHealth
        end

        local val16 = val2

        if val15 < val4 then
          val16 = val3
          print("1")
        else
          print("1")
        end

        task.delay(val16, function()
          if not val then
            return
          end

          print(val13.Name)
          replicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("NanamiService"):WaitForChild("RE"):WaitForChild("RightActivated"):FireServer(val13)
        end)
      end

      return
    end
  end
end

local function helper3(val17)
  if val17:IsA("Sound") and string.find(val17.SoundId, "91977155481568") then
    val17.Played:Connect(function() helper2(val17) end)
  end
end

for key2, value2 in pairs(workspace:GetDescendants()) do
  helper3(value2)
end

workspace.DescendantAdded:Connect(helper3)
