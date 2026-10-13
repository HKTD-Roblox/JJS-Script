local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local localPlayer = players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v1 = false
local v2 = false
local v3 = false
local v4 = {}

local lockGui = Instance.new("ScreenGui")
lockGui.Name = "LockGui"
lockGui.ResetOnSpawn = false
lockGui.IgnoreGuiInset = true
lockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
lockGui.Parent = playerGui

local lockButton = Instance.new("TextButton")
lockButton.Name = "LockButton"
lockButton.Size = UDim2.fromOffset(70, 70)
lockButton.Position = UDim2.new(0.5, 35, 0.5, -140)
lockButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
lockButton.Text = ""
lockButton.AutoButtonColor = false
lockButton.ClipsDescendants = false
lockButton.ZIndex = 10
lockButton.Parent = lockGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = lockButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.Thickness = 3
uiStroke.Parent = lockButton

local lockImage = Instance.new("ImageLabel")
lockImage.Name = "LockImage"
lockImage.BackgroundTransparency = 1
lockImage.Size = UDim2.fromScale(0.72, 0.72)
lockImage.Position = UDim2.fromScale(0.14, 0.14)
lockImage.Image = "rbxassetid://135307403282786"
lockImage.ScaleType = Enum.ScaleType.Fit
lockImage.ZIndex = 11
lockImage.Parent = lockButton

local moveLock = Instance.new("TextButton")
moveLock.Name = "MoveLock"
moveLock.Size = UDim2.fromOffset(30, 30)
moveLock.Position = UDim2.new(1, -4, 0, -4)
moveLock.AnchorPoint = Vector2.new(1, 1)
moveLock.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
moveLock.BackgroundTransparency = 0.15
moveLock.Text = "🔓"
moveLock.TextSize = 16
moveLock.ZIndex = 20
moveLock.Parent = lockButton

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(1, 0)
uiCorner2.Parent = moveLock

local function f1(p1)
  if not p1 or not p1:IsA("Model") then
    return nil, nil
  elseif p1 == localPlayer.Character then
    return nil, nil
  else
    local humanoid = p1:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
      return nil, nil
    else
      local humanoidRootPart = p1:FindFirstChild("HumanoidRootPart") or p1.PrimaryPart
        or p1:FindFirstChild("UpperTorso") or p1:FindFirstChild("Torso")

      if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
        return nil, nil
      end

      return humanoidRootPart, humanoid
    end
  end
end

local v5 = {}

local function f2(p2)
  if not p2 or not p2:IsA("Model") then
    return
  elseif p2 == localPlayer.Character then
    return
  elseif players:GetPlayerFromCharacter(p2) then
    return
  else
    if p2:FindFirstChildOfClass("Humanoid")
      and (p2:FindFirstChild("HumanoidRootPart") or p2.PrimaryPart
        or p2:FindFirstChild("UpperTorso") or p2:FindFirstChild("Torso")) then
      v5[p2] = true
    end

    return
  end
end

for index, value in ipairs(workspace:GetDescendants()) do
  if value:IsA("Model") then
    f2(value)
  end
end

workspace.DescendantAdded:Connect(function(descendant)
  if descendant:IsA("Model") then
    task.defer(f2, descendant)
  elseif descendant:IsA("Humanoid") or descendant.Name == "HumanoidRootPart"
    or descendant.Name == "UpperTorso" or descendant.Name == "Torso" then
    local model = descendant:FindFirstAncestorOfClass("Model")

    if model then
      task.defer(f2, model)
    end
  end
end)

workspace.DescendantRemoving:Connect(function(descendant2) v5[descendant2] = nil end)

local v6

local function f3()
  if v6 then
    v6:Destroy()
    v6 = nil
  end
end

local function f4()
  currentCamera.CameraType = Enum.CameraType.Custom
  local character = localPlayer.Character

  if character then
    local humanoid2 = character:FindFirstChildOfClass("Humanoid")

    if humanoid2 then
      currentCamera.CameraSubject = humanoid2
    end
  end
end

local function f5(adornee)
  f3()

  local lockTargetMarker = Instance.new("BillboardGui")
  lockTargetMarker.Name = "LockTargetMarker"
  lockTargetMarker.Adornee = adornee
  lockTargetMarker.AlwaysOnTop = true
  lockTargetMarker.Enabled = true
  lockTargetMarker.Size = UDim2.fromOffset(100, 100)
  lockTargetMarker.StudsOffsetWorldSpace = Vector3.new(0, 0.2, 0)
  lockTargetMarker.MaxDistance = 500
  lockTargetMarker.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  lockTargetMarker.Parent = playerGui

  local imageLabel = Instance.new("ImageLabel")
  imageLabel.BackgroundTransparency = 1
  imageLabel.Size = UDim2.fromScale(1, 1)
  imageLabel.Image = "rbxassetid://115409148246822"
  imageLabel.ScaleType = Enum.ScaleType.Fit
  imageLabel.ZIndex = 10
  imageLabel.Parent = lockTargetMarker

  v6 = lockTargetMarker
end

local v7, v8

local function f6()
  v1 = false
  v7 = nil
  v8 = nil
  f3()
  f4()
end

local f7

local function f8()
  if v1 then
    f6()
    return
  else
    local v9, v10, v11 = f7()

    if not v9 or not v10 then
      return
    end

    v7 = v9
    v8 = v10
    v1 = true
    f5(v7)
    return
  end
end

function f7()
  local character2 = localPlayer.Character

  if not character2 then
    return nil, nil, nil
  else
    local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart2 then
      return nil, nil, nil
    else
      local viewportSize = currentCamera.ViewportSize
      local vector = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
      local v12 = nil
      local v13 = nil
      local v14 = nil
      local huge = math.huge

      for index2, value2 in ipairs(players:GetPlayers()) do
        if value2 ~= localPlayer then
          local character3 = value2.Character

          if character3 then
            local v15, v16 = f1(character3)

            if v15 and v16 then
              if (v15.Position - humanoidRootPart2.Position).Magnitude <= 500 then
                local v17, v18 = currentCamera:WorldToViewportPoint(v15.Position)

                if v18 then
                  local magnitude = (Vector2.new(v17.X, v17.Y) - vector).Magnitude

                  if magnitude < huge then
                    huge = magnitude
                    v14 = value2
                    v13 = v16
                    v12 = v15
                  end
                end
              end
            end
          end
        end
      end

      for key in pairs(v5) do
        if key and key.Parent and key ~= character2 and not players:GetPlayerFromCharacter(key) then
          local v19, v20 = f1(key)

          if v19 and v20 then
            if (v19.Position - humanoidRootPart2.Position).Magnitude <= 500 then
              local v21, v22 = currentCamera:WorldToViewportPoint(v19.Position)

              if v22 then
                local magnitude2 = (Vector2.new(v21.X, v21.Y) - vector).Magnitude

                if magnitude2 < huge then
                  v12 = v19
                  huge = magnitude2
                  v14 = nil
                  v13 = v20
                end
              end
            end
          end
        end
      end

      return v12, v13, v14
    end
  end
end

local v23 = false
local position, position2

local function f9(p3)
  if not v23 or v2 then
    return
  else
    local v24 = p3.Position - position

    lockButton.Position = UDim2.new(
      position2.X.Scale, position2.X.Offset + v24.X, position2.Y.Scale,
      position2.Y.Offset + v24.Y
    )

    return
  end
end

lockButton.InputBegan:Connect(function(input)
  if v2 then
    return
  end

  if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
    v23 = true
    v3 = false
    position = input.Position
    position2 = lockButton.Position

    input.Changed:Connect(function()
      if input.UserInputState == Enum.UserInputState.End then
        v23 = false
      end
    end)
  end
end)

userInputService.InputChanged:Connect(function(input2)
  if input2.UserInputType == Enum.UserInputType.MouseMovement
    or input2.UserInputType == Enum.UserInputType.Touch then
    if v23 then
      if (input2.Position - position).Magnitude > 8 then
        v3 = true
      end

      f9(input2)
    end
  end
end)

lockButton.InputEnded:Connect(function(input3)
  if input3.UserInputType == Enum.UserInputType.MouseButton1
    or input3.UserInputType == Enum.UserInputType.Touch then
    v23 = false
  end
end)

lockButton.Activated:Connect(function()
  if v3 then
    v3 = false
    return
  end

  f8()
end)

moveLock.Activated:Connect(function()
  v2 = not v2

  if v2 then
    moveLock.Text = "🔒"
  else
    moveLock.Text = "🔓"
  end
end)

local function f10()
  if v1 then
    return Color3.fromRGB(0, 255, 80)
  end

  return Color3.fromRGB(255, 40, 40)
end

local function f11()
  local pulse = Instance.new("Frame")
  pulse.Name = "Pulse"
  pulse.AnchorPoint = Vector2.new(0.5, 0.5)
  pulse.Position = UDim2.fromScale(0.5, 0.5)
  pulse.Size = UDim2.fromScale(1, 1)
  pulse.BackgroundColor3 = f10()
  pulse.BackgroundTransparency = 0.45
  pulse.BorderSizePixel = 0
  pulse.ZIndex = 9
  pulse.Parent = lockButton

  local uiCorner3 = Instance.new("UICorner")
  uiCorner3.CornerRadius = UDim.new(1, 0)
  uiCorner3.Parent = pulse

  table.insert(v4, { Object = pulse, Start = tick() })
end

f11()

runService.RenderStepped:Connect(function()
  for i = #v4, 1, -1 do
    local v25 = v4[i]
    local object = v25.Object

    if not object.Parent then
      table.remove(v4, i)
    else
      local v26 = (tick() - v25.Start) / 0.8
      local v27 = 1 + 0.3500000000000001 * v26

      object.Size = UDim2.fromScale(v27, v27)
      object.BackgroundColor3 = f10()
      object.BackgroundTransparency = 0.45 + 0.55 * v26

      if v26 >= 1 then
        object:Destroy()
        table.remove(v4, i)
        f11()
      end
    end
  end

  if v1 then
    if not v7 or not v7.Parent or not v8 or v8.Health <= 0 then
      f6()
      return
    else
      local character4 = localPlayer.Character

      if not character4 then
        f6()
        return
      else
        local humanoidRootPart3 = character4:FindFirstChild("HumanoidRootPart")
        local v28 = not humanoidRootPart3
        local humanoid3 = character4:FindFirstChildOfClass("Humanoid")

        if v28 or not humanoid3 or humanoid3.Health <= 0 then
          f6()
          return
        else
          local magnitude3 = (v7.Position - humanoidRootPart3.Position).Magnitude

          if magnitude3 > 500 then
            f6()
            return
          end

          if v6 then
            local v29 = math.clamp(140 - magnitude3 * 0.14, 70, 140)
            v6.Size = UDim2.fromOffset(v29, v29)
          end

          local vector2 = Vector3.new(
            v7.Position.X, humanoidRootPart3.Position.Y, v7.Position.Z
          )

          humanoidRootPart3.CFrame = CFrame.lookAt(humanoidRootPart3.Position, vector2)
          currentCamera.CameraType = Enum.CameraType.Scriptable
          local toWorldSpace = humanoidRootPart3.CFrame:ToWorldSpace(CFrame.new(0, 6, 12))
          local cframe = CFrame.lookAt(toWorldSpace.Position, v7.Position)
          currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, 0.35)
          return
        end
      end
    end
  else
    return
  end
end)

local function f12(p4)
  f6()
  local waitForChild = p4:WaitForChild("Humanoid", 5)

  if waitForChild then
    waitForChild.Died:Connect(function() f6() end)
  end

  f4()
end

if localPlayer.Character then
  f12(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(f12)
