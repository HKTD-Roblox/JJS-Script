local players = game:GetService("Players")

local runService = game:GetService("RunService")

local workspace = game:GetService("Workspace")

local userInputService = game:GetService("UserInputService")

local starterGui = game:GetService("StarterGui")

local tweenService = game:GetService("TweenService")

local httpService = game:GetService("HttpService")
local currentCamera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local val = game.PlaceId == 9391468976
local val2 = false
local targetMode = "PLAYER"
local lockType = "Camera"
local device = "Mobile"
local forceResetUniversal = false
local camSmooth = 1
local charSmooth = 0.35
local rightOffset = -1.27
local val3 = 0

local val4 = val and "rbxassetid://110432273832755" or "rbxassetid://73466246454364"

local val5 = val and "rbxassetid://139332620449694" or "rbxassetid://113252099863593"

local val6 = val and "rbxassetid://100230908593841" or "rbxassetid://125342227220370"

local function fileIO()
  writefile("LockOn_Config.json", httpService:JSONEncode({
    camSmooth = camSmooth, charSmooth = charSmooth, rightOffset = rightOffset, lockType = lockType, targetMode = targetMode, device = device, forceResetUniversal = forceResetUniversal, }))

  return
end

local val7 = {
  camSmooth = 1, charSmooth = 0.35, rightOffset = -1.27, lockType = "Camera", targetMode = "PLAYER", device = "Mobile", forceResetUniversal = false, }

local val8 = false
local val9

local function helper()

  if not val9 then
    return
  else
    local character = localPlayer.Character

    if not character then
      return
    else
      local humanoid = character:FindFirstChildOfClass("Humanoid")

      if humanoid and currentCamera then
        currentCamera.CameraType = Enum.CameraType.Watch
        currentCamera.CameraType = Enum.CameraType.Custom
        currentCamera.CameraSubject = humanoid
      end

      return
    end
  end
end

local function safeCall()
local val10

  if val8 then
    return
  else
    val8 = true

    if (isfile("LockOn_Config.json")) then
      local val11, success

      val11, success = pcall(function()
        return httpService:JSONDecode(readfile("LockOn_Config.json"))
      end)

      if val11 and success then

        camSmooth = success.camSmooth or 1

        charSmooth = success.charSmooth or 0.35

        rightOffset = success.rightOffset or -1.27

        lockType = success.lockType or "Camera"

        targetMode = success.targetMode or "PLAYER"

        device = success.device or "Mobile"
        forceResetUniversal = success.forceResetUniversal or false
        return
      else
        ::L2600126::
        val10 = httpService
        writefile("LockOn_Config.json", httpService:JSONEncode(val7))
        return
      end
    else
      goto L2600126
    end
  end
end

safeCall()

val9 = false

local function helper2(val12)
local val13

  if val then
    val13 = lockType ~= "Character"
  else

    val13 = forceResetUniversal and lockType ~= "Character"
  end

  if not val13 then
    if val9 then
      val9 = false
      runService:UnbindFromRenderStep("FlashCamLoop")
    end

    return
  else

    if val12 and not val9 then
      val9 = true
      runService:BindToRenderStep("FlashCamLoop", Enum.RenderPriority.Last.Value + 2000, helper)
    else

      if not val12 and val9 then
        val9 = false
        runService:UnbindFromRenderStep("FlashCamLoop")
      end
    end

    return
  end
end

localPlayer.PlayerGui:FindFirstChild("LockOnScreenGui")

local lockOnScreenGui = Instance.new("ScreenGui")
lockOnScreenGui.Name = "LockOnScreenGui"
lockOnScreenGui.ResetOnSpawn = false
lockOnScreenGui.Parent = localPlayer.PlayerGui

local overlapParams = OverlapParams.new()

local function helper3(val14)

  local val15 = not val14 or not val14.Parent

  if val15 then
    return false
  else
    local parent = val14.Parent
    local getPlayerFromCharacter = players:GetPlayerFromCharacter(parent)
    local humanoid2 = parent:FindFirstChildOfClass("Humanoid")
    local val16 = not humanoid2
    local val17 = val16

    if not val16 then

      val17 = humanoid2.Health <= 0 or parent == localPlayer.Character
    end

    if val17 then
      return false
    else

      local val18 = targetMode == "PLAYER" and getPlayerFromCharacter ~= nil
      local val19 = val18

      if not val18 then

        val19 = targetMode == "NPC" and getPlayerFromCharacter == nil
      end

      return val19
    end
  end
end

overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function helper4(val20)

  return val20 and val20:FindFirstChild("Head")
end

local val21 = {}
local val22 = 0
local val23

local function helper5(val24)

  if not val24 then
    return nil
  else
    local val25 = tick()

    if val21[val24] and val25 - val22 < val23 then
      return val21[val24]
    else
      local parent2 = val24.Parent

      if not parent2 then
        return nil
      else
        local neckAttachment = val24:FindFirstChild("NeckAttachment")

        if not neckAttachment then
          local upperTorso = parent2:FindFirstChild("UpperTorso")

          neckAttachment = upperTorso or parent2:FindFirstChild("Torso")

          if neckAttachment then
            neckAttachment = neckAttachment:FindFirstChild("NeckAttachment")
          end
        end

        if neckAttachment and neckAttachment:IsA("Attachment") then
          worldPosition = neckAttachment.WorldPosition
        else
          worldPosition = (val24.CFrame * (CFrame.new(0, -0.5, 0))).Position
        end

        val21[val24] = worldPosition
        val22 = val25
        return worldPosition
      end
    end
  end
end

val23 = 0.016
local val26, vector

local function helper6(val27)

  if not val27 then
    return nil
  else
    local parent3 = val27.Parent
    local character2 = localPlayer.Character

    if not character2 or not parent3 then
      return helper5(val27)
    else
      local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
      local humanoidRootPart2 = parent3:FindFirstChild("HumanoidRootPart")

      if not humanoidRootPart or not humanoidRootPart2 then
        return helper5(val27)
      else
        local val28 = helper5(val27)
        local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

        if magnitude >= 22 then
          return val28
        else
          if magnitude <= 7 then
            return humanoidRootPart2.Position
          else

            return humanoidRootPart2.Position:Lerp(val28, (magnitude - 7) / 15)
          end
        end
      end
    end
  end
end

val26 = nil
local val29

local function helper7(val30)

  if not val30 then
    return
  else
    local humanoid3 = val30:FindFirstChildOfClass("Humanoid")

    if humanoid3 then
      connect = nil

      connect = humanoid3.Died:Connect(function()

        connect:Disconnect()
        val2 = false
        val29 = nil
        helper2(false)
        return
      end)
    end

    return
  end
end

vector = nil
local val31, val32

local function helper8()
  local val33 = val31()
  local huge = math.huge
  local character3 = localPlayer.Character
  local humanoidRootPart3 = character3

  if character3 then

    humanoidRootPart3 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
  end

  local element = humanoidRootPart3
  local val34, val35, val36, val37

  if not element then
    return nil
  else
    overlapParams.FilterDescendantsInstances = { localPlayer.Character }

    local getPartBoundsInRadius = workspace:GetPartBoundsInRadius(
      element.Position, 55, overlapParams
    )

    table.clear(val32)

    for index, value in ipairs(getPartBoundsInRadius) do
      local model = value:FindFirstAncestorWhichIsA("Model")
      local val38 = not model
      local val39 = val38

      if not val38 then

        val39 = model == localPlayer.Character or val32[model]
      end

      if val39 then
      else
        val32[model] = true
        local getPlayerFromCharacter2 = players:GetPlayerFromCharacter(model)
        local humanoid4 = model:FindFirstChildOfClass("Humanoid")

        if humanoid4 and humanoid4.Health > 0 then

          local val40 = targetMode == "PLAYER" and getPlayerFromCharacter2 ~= nil
          local val41 = val40

          if not val40 then

            val41 = targetMode == "NPC" and getPlayerFromCharacter2 == nil
          end

          if not val41 then
          else
            local val42 = helper4(model)

            local val43 = val42 and helper5(val42)

            if not val43 then
            else
              local val44 = { currentCamera:WorldToViewportPoint(val43) }
              local element2 = val44[1]

              if not val44[2] then
              else
                val35 = element2.X - val33.X
                val36 = element2.Y - val33.Y
                val37 = val35 * val35 + val36 * val36

                if val37 < huge * huge then
                  val34 = val42
                  huge = math.sqrt(val37)
                end

                ::L3769118::
              end
            end
          end
        else
          goto L3769118
        end
      end
    end

    return val34
  end
end

val31 = function()
  local viewportSize = currentCamera.ViewportSize

  if val26 ~= viewportSize then
    val26 = viewportSize
    vector = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
  end

  return vector
end

local instance

local function helper9(val45)

  local val46 = not instance or not instance.Visible

  if val46 then
    return
  else
    local udim = val45
    udim = val45 and UDim2.new(0, 78, 0, 78)

    local udim2 = udim or UDim2.new(0, 85, 0, 85)

    tweenService:Create(instance, TweenInfo.new(val45 and 0.2 or 0.25, Enum.EasingStyle.Quad), {
      Size = udim2, ImageTransparency = val45 and 0.15 or 0, }):Play()

    return
  end
end

val32 = {}

local function helper10()

  local val47 = not instance or not instance.Visible

  if val47 then
    return
  else
    local udim3 = UDim2.new(0, 85, 0, 85)

    local create2 = tweenService:Create(instance, TweenInfo.new(
      0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out
    ), { Size = (UDim2.new(0, 72, 0, 72)) })

    create = tweenService:Create(instance, TweenInfo.new(
      0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out
    ), { Size = udim3 })

    create2.Play(create2)

    create2.Completed:Connect(function()
      create:Play()
      return
    end)

    return
  end
end

local val48 = false
local instance2

local function helper11()
  helper10()

  val2 = not val2

  val29 = val2 and helper8() or nil

  if not val2 then
    helper2(false)

    if instance2 then
      instance2.Enabled = false
    end
  else
    if val29 then
      helper2(true)
    end
  end

  if instance and instance.Visible then

    instance.Image = val2 and val5 or val4
  end

  return
end

local function createElement()

  instance = Instance.new("ImageButton", lockOnScreenGui)
  instance.Size = UDim2.new(0, 85, 0, 85)
  instance.Position = UDim2.new(1, -95, 0, 10)
  instance.BackgroundTransparency = 1
  instance.Image = val4

  Instance.new("UICorner", instance).CornerRadius = UDim.new(1, 0)
  instance.Visible = false

  instance2 = Instance.new("BillboardGui", lockOnScreenGui)
  instance2.AlwaysOnTop = true
  instance2.Enabled = false

  local instance3 = Instance.new("ImageLabel", instance2)
  instance3.Size = UDim2.new(1, 0, 1, 0)
  instance3.BackgroundTransparency = 1
  instance3.Image = val6
  instance3.ImageTransparency = val and 0.45 or 0.5

  local color = val
  color = val and Color3.fromRGB(0, 255, 255)

  instance3.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
  Instance.new("UICorner", instance3).CornerRadius = UDim.new(1, 0)
  local val49 = false
  local val50 = false

  local position, position2

  instance.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      val49 = true
      position = instance.Position
      position2 = input.Position
      helper9(true)

      task.delay(0.45, function()
        if val49 then
          val50 = true
          val48 = true
        end

        return
      end)
    end

    return
  end)

  instance.InputChanged:Connect(function(input2)
    local val51 = val50
    local val52 = val51

    if val51 then

      val52 = input2.UserInputType == Enum.UserInputType.MouseMovement
        or input2.UserInputType == Enum.UserInputType.Touch
    end

    if val52 then
      local element3 = input2.Position - position2

      instance.Position = UDim2.new(
        position.X.Scale, position.X.Offset + element3.X, position.Y.Scale, position.Y.Offset + element3.Y
      )
    end

    return
  end)

  instance.InputEnded:Connect(function(input3)

    if input3.UserInputType == Enum.UserInputType.MouseButton1
      or input3.UserInputType == Enum.UserInputType.Touch then
      val49 = false
      val50 = false
      val48 = false
      helper9(false)
    end

    return
  end)

  instance.MouseButton1Click:Connect(function()

    if val50 or val48 then
      return
    else
      helper11()
      return
    end
  end)

  return
end

createElement()

userInputService.InputBegan:Connect(function(input4, p8)
  if p8 then
    return
  else
    if input4.KeyCode == Enum.KeyCode.L then
      helper11()
    end

    return
  end
end)

local function createElement2(val55, val53, val54, val56)
  local instance4 = Instance.new("TextLabel", val55)
  instance4.Size = UDim2.new(0.42, 0, 0, 18)
  instance4.Position = UDim2.new(0.04, 0, 0, val56)
  instance4.BackgroundTransparency = 1
  instance4.Text = val53
  instance4.TextColor3 = Color3.fromRGB(200, 200, 200)
  instance4.TextXAlignment = Enum.TextXAlignment.Left
  instance4.Font = Enum.Font.Gotham
  instance4.TextSize = 12

  local instance5 = Instance.new("TextBox", val55)
  instance5.Size = UDim2.new(0.48, 0, 0, 22)
  instance5.Position = UDim2.new(0.48, 0, 0, val56 - 2)
  instance5.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
  instance5.Text = tostring(val54)
  instance5.TextColor3 = Color3.new(1, 1, 1)
  instance5.Font = Enum.Font.Gotham
  instance5.TextSize = 12
  instance5.ClearTextOnFocus = false

  Instance.new("UICorner", instance5).CornerRadius = UDim.new(0, 5)
  Instance.new("UIStroke", instance5).Color = Color3.fromRGB(0, 200, 200)

  return instance5
end

local function createElement3()
  local instance6 = Instance.new("Frame", lockOnScreenGui)

  instance6.Size = UDim2.new(0, 300, 0, val and 310 or 380)
  instance6.Position = UDim2.new(0.5, -150, 0.5, val and -155 or -190)
  instance6.BackgroundColor3 = Color3.fromRGB(28, 28, 28)

  Instance.new("UICorner", instance6).CornerRadius = UDim.new(0, 10)
  Instance.new("UIStroke", instance6).Color = Color3.fromRGB(0, 255, 255)

  local instance7 = Instance.new("TextLabel", instance6)
  instance7.Size = UDim2.new(1, 0, 0, 26)

  instance7.Text = val and "JJS Lock On" or "Lock On Settings"
  instance7.TextColor3 = Color3.new(1, 1, 1)
  instance7.BackgroundTransparency = 1
  instance7.Font = Enum.Font.GothamBold
  instance7.TextSize = 15

  local instance8 = Instance.new("TextLabel", instance6)
  instance8.Size = UDim2.new(1, 0, 0, 16)
  instance8.Position = UDim2.new(0, 0, 0, 28)
  instance8.BackgroundTransparency = 1
  instance8.Text = "Lock Mode:"
  instance8.TextColor3 = Color3.fromRGB(200, 200, 200)
  instance8.Font = Enum.Font.Gotham
  instance8.TextSize = 12

  local val57 = {}
  local name = lockType

  local instance9 = Instance.new("Frame", instance6)
  instance9.Size = UDim2.new(1, 0, 0, 80)
  instance9.Position = UDim2.new(0, 0, 0, 78)
  instance9.BackgroundTransparency = 1

  local instance10, instance11, instance12

  local function helper12()

    if val then
      return
    else

      local val58 = name == "Camera" or name == "CameraCharacter"

      if instance10 then
        instance10.Visible = val58
      end

      if instance11 then
        instance11.Visible = val58
      end

      if instance12 then
        instance12.Visible = val58
      end

      return
    end
  end

  instance12 = nil
  local val59, val60, val61

  local function iterate()

    for index2, value2 in ipairs(instance9:GetChildren()) do
      value2:Destroy()
    end

    local total = 0

    if name == "Camera" or name == "CameraCharacter" then

      if val or name == "CameraCharacter" then
        val59 = createElement2(instance9, "Cam Smooth", camSmooth, total)
        total = total + 26
      end

      if val or name == "CameraCharacter" then
        val60 = createElement2(instance9, "Right Offset", rightOffset, total)
        total = total + 26
      end
    end

    if name == "CameraCharacter" or name == "Character" then
      val61 = createElement2(instance9, "Char Smooth", charSmooth, total)
    end

    helper12()
    return
  end

  for index3, value3 in ipairs({
    { name = "Camera", display = "Camera" }, { name = "CameraCharacter", display = "Cam + Char" }, { name = "Character", display = "Character" }, }) do
    local element4 = value3

    local instance13 = Instance.new("TextButton", instance6)
    instance13.Size = UDim2.new(0.29, 0, 0, 24)
    instance13.Position = UDim2.new(0.04 + (index3 - 1) * 0.32, 0, 0, 46)
    instance13.Text = element4.display
    instance13.Font = Enum.Font.GothamBold
    instance13.TextSize = 11
    instance13.TextColor3 = Color3.new(1, 1, 1)

    local val62 = name == element4.name

    local color2 = val62
    color2 = val62 and Color3.fromRGB(0, 180, 180)

    instance13.BackgroundColor3 = color2 or Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", instance13).CornerRadius = UDim.new(0, 5)
    val57[element4.name] = instance13

    instance13.MouseButton1Click:Connect(function()
      name = element4.name

      for key, value4 in pairs(val57) do
        local val63 = key == element4.name

        local color3 = val63
        color3 = val63 and Color3.fromRGB(0, 180, 180)

        value4.BackgroundColor3 = color3 or Color3.fromRGB(45, 45, 45)
      end

      iterate()
      return
    end)
  end

  if not val then
    instance10 = Instance.new("TextLabel", instance6)
    instance10.Size = UDim2.new(1, -16, 0, 14)
    instance10.Position = UDim2.new(0, 8, 0, 165)
    instance10.BackgroundTransparency = 1
    instance10.Text = "HOLD CAMERA"
    instance10.TextColor3 = Color3.fromRGB(200, 200, 200)
    instance10.Font = Enum.Font.Gotham
    instance10.TextSize = 11
    instance10.TextXAlignment = Enum.TextXAlignment.Left

    instance11 = Instance.new("TextLabel", instance6)
    instance11.Size = UDim2.new(1, -16, 0, 24)
    instance11.Position = UDim2.new(0, 8, 0, 178)
    instance11.BackgroundTransparency = 1
    instance11.Text = "Keeps camera locked on target. Enable only if it detaches."
    instance11.TextColor3 = Color3.fromRGB(160, 160, 160)
    instance11.Font = Enum.Font.Gotham
    instance11.TextSize = 10
    instance11.TextWrapped = true
    instance11.TextXAlignment = Enum.TextXAlignment.Left
    instance11.TextYAlignment = Enum.TextYAlignment.Top

    instance12 = Instance.new("TextButton", instance6)
    instance12.Size = UDim2.new(0.85, 0, 0, 24)
    instance12.Position = UDim2.new(0.075, 0, 0, 204)

    instance12.Text = forceResetUniversal and "ENABLED" or "DISABLED"
    instance12.Font = Enum.Font.GothamBold
    instance12.TextSize = 12
    instance12.TextColor3 = Color3.new(1, 1, 1)

    local val64 = forceResetUniversal

    local color4 = val64
    color4 = val64 and Color3.fromRGB(0, 180, 100)

    instance12.BackgroundColor3 = color4 or Color3.fromRGB(180, 50, 50)
    Instance.new("UICorner", instance12).CornerRadius = UDim.new(0, 5)

    instance12.MouseButton1Click:Connect(function()
      local val65 = not forceResetUniversal
      forceResetUniversal = val65

      instance12.Text = forceResetUniversal and "ENABLED" or "DISABLED"
      local val66 = forceResetUniversal

      local color5 = val66
      color5 = val66 and Color3.fromRGB(0, 180, 100)

      instance12.BackgroundColor3 = color5 or Color3.fromRGB(180, 50, 50)
      return
    end)
  end

  iterate()
  local val67 = val and 165 or 235

  local instance14 = Instance.new("TextLabel", instance6)
  instance14.Size = UDim2.new(1, 0, 0, 14)
  instance14.Position = UDim2.new(0, 0, 0, val67)
  instance14.BackgroundTransparency = 1
  instance14.Text = "Target Mode:"
  instance14.TextColor3 = Color3.fromRGB(200, 200, 200)
  instance14.Font = Enum.Font.Gotham
  instance14.TextSize = 12

  local instance15 = Instance.new("TextButton", instance6)
  instance15.Size = UDim2.new(0.4, 0, 0, 24)
  instance15.Position = UDim2.new(0.07, 0, 0, val67 + 16)
  instance15.Text = "Players"
  instance15.Font = Enum.Font.GothamBold
  instance15.TextColor3 = Color3.new(1, 1, 1)
  instance15.BackgroundColor3 = Color3.fromRGB(0, 180, 180)

  Instance.new("UICorner", instance15).CornerRadius = UDim.new(0, 5)

  local instance16 = Instance.new("TextButton", instance6)
  instance16.Size = UDim2.new(0.4, 0, 0, 24)
  instance16.Position = UDim2.new(0.53, 0, 0, val67 + 16)
  instance16.Text = "NPC"
  instance16.Font = Enum.Font.GothamBold
  instance16.TextColor3 = Color3.new(1, 1, 1)
  instance16.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

  Instance.new("UICorner", instance16).CornerRadius = UDim.new(0, 5)
  local val68 = targetMode

  if targetMode == "NPC" then
    instance16.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
    instance15.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
  end

  local function helper13(val69)
    val68 = val69
    local val70 = val69 == "PLAYER"

    local color6 = val70
    color6 = val70 and Color3.fromRGB(0, 180, 180)

    instance15.BackgroundColor3 = color6 or Color3.fromRGB(45, 45, 45)
    local val71 = val69 == "NPC"

    local color7 = val71
    color7 = val71 and Color3.fromRGB(0, 180, 180)

    instance16.BackgroundColor3 = color7 or Color3.fromRGB(45, 45, 45)
    return
  end

  instance15.MouseButton1Click:Connect(function()
    helper13("PLAYER")
    return
  end)

  instance16.MouseButton1Click:Connect(function()
    helper13("NPC")
    return
  end)

  local val72 = val67 + 48

  local instance17 = Instance.new("TextLabel", instance6)
  instance17.Size = UDim2.new(1, 0, 0, 14)
  instance17.Position = UDim2.new(0, 0, 0, val72)
  instance17.BackgroundTransparency = 1
  instance17.Text = "Device:"
  instance17.TextColor3 = Color3.fromRGB(200, 200, 200)
  instance17.Font = Enum.Font.Gotham
  instance17.TextSize = 12

  local instance18 = Instance.new("TextButton", instance6)
  instance18.Size = UDim2.new(0.4, 0, 0, 24)
  instance18.Position = UDim2.new(0.07, 0, 0, val72 + 16)
  instance18.Text = "Mobile"
  instance18.Font = Enum.Font.GothamBold
  instance18.TextColor3 = Color3.new(1, 1, 1)
  instance18.BackgroundColor3 = Color3.fromRGB(0, 180, 180)

  Instance.new("UICorner", instance18).CornerRadius = UDim.new(0, 5)

  local instance19 = Instance.new("TextButton", instance6)
  instance19.Size = UDim2.new(0.4, 0, 0, 24)
  instance19.Position = UDim2.new(0.53, 0, 0, val72 + 16)
  instance19.Text = "PC"
  instance19.Font = Enum.Font.GothamBold
  instance19.TextColor3 = Color3.new(1, 1, 1)
  instance19.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

  Instance.new("UICorner", instance19).CornerRadius = UDim.new(0, 5)
  local val73 = device

  if device == "PC" then
    instance19.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
    instance18.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
  end

  local function helper14(val74)
    val73 = val74
    local val75 = val74 == "Mobile"

    local color8 = val75
    color8 = val75 and Color3.fromRGB(0, 180, 180)

    instance18.BackgroundColor3 = color8 or Color3.fromRGB(45, 45, 45)
    local val76 = val74 == "PC"

    local color9 = val76
    color9 = val76 and Color3.fromRGB(0, 180, 180)

    instance19.BackgroundColor3 = color9 or Color3.fromRGB(45, 45, 45)
    return
  end

  instance18.MouseButton1Click:Connect(function()
    helper14("Mobile")
    return
  end)

  instance19.MouseButton1Click:Connect(function()
    helper14("PC")
    return
  end)

  local instance20 = Instance.new("TextButton", instance6)
  instance20.Size = UDim2.new(0.85, 0, 0, 28)
  instance20.Position = UDim2.new(0.075, 0, 0, val72 + 48)
  instance20.Text = "Confirm & Save"
  instance20.Font = Enum.Font.GothamBold
  instance20.TextColor3 = Color3.new(1, 1, 1)
  instance20.BackgroundColor3 = Color3.fromRGB(0, 200, 200)

  Instance.new("UICorner", instance20).CornerRadius = UDim.new(0, 6)

  instance20.MouseButton1Click:Connect(function()

    local numVal = val59 and tonumber(val59.Text) or camSmooth
    camSmooth = numVal

    rightOffset = val60 and tonumber(val60.Text) or rightOffset

    charSmooth = val61 and tonumber(val61.Text) or charSmooth
    lockType = name
    device = val73
    targetMode = val68
    fileIO()
    instance6:Destroy()
    instance.Visible = device == "Mobile"

    task.defer(function()
      pcall(function()
        starterGui:SetCore("SendNotification", {
          Title = "Lock On", Text = "Settings saved!", Icon = "rbxassetid://7205866966", Duration = 4, })

        return
      end)

      return
    end)

    return
  end)

  return
end

createElement3()

if localPlayer.Character then
  helper7(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(helper7)
local val77 = 0

runService:BindToRenderStep("LockCameraLoop", Enum.RenderPriority.Last.Value + 100, function()

  if not val2 then
    if instance2 then
      instance2.Enabled = false
    end

    return
  else
    local val78 = tick()

    if val78 - val3 > 0.25 then
      if not (helper3(val29)) then
        val29 = helper8()
        helper2(val29 ~= nil)
      end

      val3 = val78
    end

    if val29 and val29.Parent then
      local val79 = helper6(val29)
      local character4 = localPlayer.Character

      local humanoidRootPart4 = character4
      humanoidRootPart4 = character4 and character4:FindFirstChild("HumanoidRootPart")

      local val80 = lockType == "CameraCharacter" or lockType == "Character"
      local val81 = val80

      if val80 then

        val81 = humanoidRootPart4 and val79
      end

      if val81 then
        local vector2 = Vector3.new(val79.X, humanoidRootPart4.Position.Y, val79.Z)
        local cframe = CFrame.new(humanoidRootPart4.Position, vector2)

        humanoidRootPart4.CFrame = humanoidRootPart4.CFrame:Lerp(cframe, charSmooth)
      end

      if lockType == "Camera" or lockType == "CameraCharacter" then
        if val79 then
          if val then
            local cframe2 = CFrame.new(
              currentCamera.CFrame.Position, val79 - currentCamera.CFrame.RightVector * rightOffset
            )

            currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe2, camSmooth)
          else
            if lockType == "Camera" then
              currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position, val79)
            else
              local cframe3 = CFrame.new(
                currentCamera.CFrame.Position, val79 - currentCamera.CFrame.RightVector * rightOffset
              )

              currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe3, camSmooth)
            end
          end
        end
      end

      local upperTorso2 = val29.Parent:FindFirstChild("UpperTorso")
      local val82 = upperTorso2

      if not upperTorso2 then

        local torso = val29.Parent:FindFirstChild("Torso")
        local humanoidRootPart5 = torso

        if not torso then

          humanoidRootPart5 = val29.Parent:FindFirstChild("HumanoidRootPart")
        end

        val82 = humanoidRootPart5
      end

      if val82 then
        instance2.Adornee = val82
        instance2.Enabled = true

        if val78 - val77 > 0.1 then
          local val83 = 1400 / ((currentCamera.CFrame.Position - val82.Position).Magnitude + 8)
            * (math.clamp(val29.Size.Y * 2.5, 3, 10))

          instance2.Size = UDim2.new(0, val83, 0, val83)
          val77 = val78
        end
      else
        instance2.Enabled = false
      end
    else
      if instance2 then
        instance2.Enabled = false
      end
    end

    return
  end
end)