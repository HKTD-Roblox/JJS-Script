local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local coreGui = game:GetService("CoreGui")
local starterGui = game:GetService("StarterGui")

print("ââââââââââââââââââââââââââââââ")
print("KEY SYSTEM LOADED")
print("ââââââââââââââââââââââââââââââ")

local function createScreenGui()
  local localPlayer = players.LocalPlayer

  local screenGui = Instance.new("ScreenGui")
  screenGui.Name = "KeySystemUI_" .. tostring(math.random(1000, 9999))
  screenGui.ResetOnSpawn = false

  if not pcall(function() screenGui.Parent = coreGui end) and localPlayer then
    if not localPlayer:FindFirstChild("PlayerGui") then
      localPlayer:WaitForChild("PlayerGui", 10)
    end

    screenGui.Parent = localPlayer.PlayerGui
  end

  local mainFrame = Instance.new("Frame")
  mainFrame.Name = "MainFrame"
  mainFrame.Parent = screenGui
  mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
  mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
  mainFrame.Size = UDim2.new(0, 360, 0, 265)
  mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
  mainFrame.BorderSizePixel = 0
  mainFrame.Active = true
  mainFrame.Draggable = true
  mainFrame.ClipsDescendants = true

  local uiCorner = Instance.new("UICorner")
  uiCorner.CornerRadius = UDim.new(0, 16)
  uiCorner.Parent = mainFrame

  pcall(function()
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(36, 36, 42)
    uiStroke.Thickness = 1.2
    uiStroke.Parent = mainFrame
  end)

  local topAccentLine = Instance.new("Frame")
  topAccentLine.Name = "TopAccentLine"
  topAccentLine.Parent = mainFrame
  topAccentLine.Position = UDim2.new(0, 0, 0, 0)
  topAccentLine.Size = UDim2.new(1, 0, 0, 2)
  topAccentLine.BorderSizePixel = 0
  topAccentLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  topAccentLine.ZIndex = 5

  pcall(function()
    local uiGradient = Instance.new("UIGradient")

    uiGradient.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(161, 161, 170)), ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 27)), })

    uiGradient.Transparency = NumberSequence.new({
      NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.3), NumberSequenceKeypoint.new(1, 0.85), })

    uiGradient.Parent = topAccentLine
  end)

  local topBar = Instance.new("Frame")
  topBar.Name = "TopBar"
  topBar.Parent = mainFrame
  topBar.Size = UDim2.new(1, 0, 0, 46)
  topBar.BackgroundColor3 = Color3.fromRGB(17, 17, 20)
  topBar.BorderSizePixel = 0

  local uiCorner2 = Instance.new("UICorner")
  uiCorner2.CornerRadius = UDim.new(0, 16)
  uiCorner2.Parent = topBar

  local topBarCover = Instance.new("Frame")
  topBarCover.Name = "TopBarCover"
  topBarCover.Parent = topBar
  topBarCover.Position = UDim2.new(0, 0, 1, -10)
  topBarCover.Size = UDim2.new(1, 0, 0, 10)
  topBarCover.BackgroundColor3 = Color3.fromRGB(17, 17, 20)
  topBarCover.BorderSizePixel = 0

  local frame = Instance.new("Frame")
  frame.Parent = topBar
  frame.Position = UDim2.new(0, 0, 1, 0)
  frame.Size = UDim2.new(1, 0, 0, 1)
  frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
  frame.BorderSizePixel = 0

  local frame2 = Instance.new("Frame")
  frame2.Parent = topBar
  frame2.AnchorPoint = Vector2.new(0, 0.5)
  frame2.Position = UDim2.new(0, 16, 0.5, 0)
  frame2.Size = UDim2.new(0, 8, 0, 8)
  frame2.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
  frame2.BorderSizePixel = 0

  local uiCorner3 = Instance.new("UICorner")
  uiCorner3.CornerRadius = UDim.new(1, 0)
  uiCorner3.Parent = frame2

  local textLabel = Instance.new("TextLabel")
  textLabel.Parent = topBar
  textLabel.AnchorPoint = Vector2.new(0, 0.5)
  textLabel.Position = UDim2.new(0, 32, 0.5, 0)
  textLabel.Size = UDim2.new(0, 90, 1, 0)
  textLabel.BackgroundTransparency = 1
  textLabel.Text = "Key System"
  textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel.TextSize = 13
  textLabel.Font = Enum.Font.GothamBold
  textLabel.TextXAlignment = Enum.TextXAlignment.Left

  local frame3 = Instance.new("Frame")
  frame3.Parent = topBar
  frame3.AnchorPoint = Vector2.new(0, 0.5)
  frame3.Position = UDim2.new(0, 114, 0.5, 0)
  frame3.Size = UDim2.new(0, 48, 0, 18)
  frame3.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
  frame3.BorderSizePixel = 0

  local uiCorner4 = Instance.new("UICorner")
  uiCorner4.CornerRadius = UDim.new(0, 5)
  uiCorner4.Parent = frame3

  local textLabel2 = Instance.new("TextLabel")
  textLabel2.Parent = frame3
  textLabel2.Size = UDim2.new(1, 0, 1, 0)
  textLabel2.BackgroundTransparency = 1
  textLabel2.Text = "SECURE"
  textLabel2.TextColor3 = Color3.fromRGB(161, 161, 170)
  textLabel2.TextSize = 9
  textLabel2.Font = Enum.Font.GothamBold

  local closeBtn = Instance.new("TextButton")
  closeBtn.Name = "CloseBtn"
  closeBtn.Parent = topBar
  closeBtn.AnchorPoint = Vector2.new(1, 0.5)
  closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
  closeBtn.Size = UDim2.new(0, 26, 0, 26)
  closeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
  closeBtn.BorderSizePixel = 0
  closeBtn.Text = "Ã"
  closeBtn.TextColor3 = Color3.fromRGB(161, 161, 170)
  closeBtn.TextSize = 17
  closeBtn.Font = Enum.Font.GothamBold

  local uiCorner5 = Instance.new("UICorner")
  uiCorner5.CornerRadius = UDim.new(0, 7)
  uiCorner5.Parent = closeBtn

  closeBtn.MouseButton1Click:Connect(function()
    pcall(function()
      local create = tweenService:Create(mainFrame, TweenInfo.new(
        0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In
      ), {
        Size = UDim2.new(0, 300, 0, 220), BackgroundTransparency = 1, })

      create:Play()
      create.Completed:Connect(function() screenGui:Destroy() end)
    end)
  end)

  closeBtn.MouseEnter:Connect(function()
    pcall(function()
      tweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(239, 68, 68), TextColor3 = Color3.fromRGB(255, 255, 255), }):Play()
    end)
  end)

  closeBtn.MouseLeave:Connect(function()
    pcall(function()
      tweenService:Create(closeBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(24, 24, 30), TextColor3 = Color3.fromRGB(161, 161, 170), }):Play()
    end)
  end)

  local textBox = Instance.new("TextBox")
  textBox.Parent = mainFrame
  textBox.Position = UDim2.new(0.5, 0, 0, 60)
  textBox.AnchorPoint = Vector2.new(0.5, 0)
  textBox.Size = UDim2.new(0.92, 0, 0, 40)
  textBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
  textBox.BorderSizePixel = 0
  textBox.Text = ""
  textBox.PlaceholderText = "Paste your key here..."
  textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
  textBox.PlaceholderColor3 = Color3.fromRGB(113, 113, 122)
  textBox.TextSize = 13
  textBox.Font = Enum.Font.Gotham
  textBox.ClearTextOnFocus = false

  local uiCorner6 = Instance.new("UICorner")
  uiCorner6.CornerRadius = UDim.new(0, 9)
  uiCorner6.Parent = textBox

  local val

  textBox.Focused:Connect(function()
    pcall(function()
      if val then
        tweenService:Create(val, TweenInfo.new(0.18), {
          Color = Color3.fromRGB(255, 255, 255), Thickness = 1.3, }):Play()
      end

      tweenService:Create(textBox, TweenInfo.new(0.18), {
        BackgroundColor3 = Color3.fromRGB(24, 24, 30), }):Play()
    end)
  end)

  textBox.FocusLost:Connect(function()
    pcall(function()
      if val then
        tweenService:Create(val, TweenInfo.new(0.18), {
          Color = Color3.fromRGB(36, 36, 42), Thickness = 1, }):Play()
      end

      tweenService:Create(textBox, TweenInfo.new(0.18), {
        BackgroundColor3 = Color3.fromRGB(18, 18, 22), }):Play()
    end)
  end)

  local textButton = Instance.new("TextButton")
  textButton.Parent = mainFrame
  textButton.Position = UDim2.new(0.5, 0, 0, 110)
  textButton.AnchorPoint = Vector2.new(0.5, 0)
  textButton.Size = UDim2.new(0.92, 0, 0, 40)
  textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  textButton.BorderSizePixel = 0
  textButton.Text = "Verify Key"
  textButton.TextColor3 = Color3.fromRGB(10, 10, 12)
  textButton.TextSize = 13
  textButton.Font = Enum.Font.GothamBold
  textButton.AutoButtonColor = false

  local uiCorner7 = Instance.new("UICorner")
  uiCorner7.CornerRadius = UDim.new(0, 9)
  uiCorner7.Parent = textButton

  textButton.MouseEnter:Connect(function()
    if textButton.Active then
      pcall(function()
        tweenService:Create(textButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
          BackgroundColor3 = Color3.fromRGB(228, 228, 231), Size = UDim2.new(0.92, 4, 0, 40), }):Play()
      end)
    end
  end)

  textButton.MouseLeave:Connect(function()
    if textButton.Active then
      pcall(function()
        tweenService:Create(textButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
          BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0.92, 0, 0, 40), }):Play()
      end)
    end
  end)

  local textButton2 = Instance.new("TextButton")
  textButton2.Parent = mainFrame
  textButton2.Position = UDim2.new(0.5, 0, 0, 158)
  textButton2.AnchorPoint = Vector2.new(0.5, 0)
  textButton2.Size = UDim2.new(0.92, 0, 0, 38)
  textButton2.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
  textButton2.BorderSizePixel = 0
  textButton2.Text = "Get Key Link"
  textButton2.TextColor3 = Color3.fromRGB(244, 244, 245)
  textButton2.TextSize = 13
  textButton2.Font = Enum.Font.GothamBold
  textButton2.AutoButtonColor = false

  local uiCorner8 = Instance.new("UICorner")
  uiCorner8.CornerRadius = UDim.new(0, 9)
  uiCorner8.Parent = textButton2

  local uiStroke2

  pcall(function()
    uiStroke2 = Instance.new("UIStroke")
    uiStroke2.Color = Color3.fromRGB(44, 44, 52)
    uiStroke2.Thickness = 1
    uiStroke2.Parent = textButton2
  end)

  textButton2.MouseEnter:Connect(function()
    pcall(function()
      tweenService:Create(textButton2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(32, 32, 38), Size = UDim2.new(0.92, 4, 0, 38), }):Play()

      if uiStroke2 then
        tweenService:Create(uiStroke2, TweenInfo.new(0.15), {
          Color = Color3.fromRGB(64, 64, 76), }):Play()
      end
    end)
  end)

  textButton2.MouseLeave:Connect(function()
    pcall(function()
      tweenService:Create(textButton2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(22, 22, 26), Size = UDim2.new(0.92, 0, 0, 38), }):Play()

      if uiStroke2 then
        tweenService:Create(uiStroke2, TweenInfo.new(0.15), {
          Color = Color3.fromRGB(44, 44, 52), }):Play()
      end
    end)
  end)

  local textLabel3 = Instance.new("TextLabel")
  textLabel3.Parent = mainFrame
  textLabel3.Position = UDim2.new(0.5, 0, 0, 206)
  textLabel3.AnchorPoint = Vector2.new(0.5, 0)
  textLabel3.Size = UDim2.new(0.92, 0, 0, 48)
  textLabel3.BackgroundTransparency = 1
  textLabel3.Text = "Ready to verify"
  textLabel3.TextColor3 = Color3.fromRGB(113, 113, 122)
  textLabel3.TextSize = 11
  textLabel3.Font = Enum.Font.Gotham
  textLabel3.TextWrapped = true
  textLabel3.TextYAlignment = Enum.TextYAlignment.Center

  pcall(function()
    mainFrame.Size = UDim2.new(0, 310, 0, 230)

    tweenService:Create(
      mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 360, 0, 265) }
    ):Play()
  end)

  return {
    ScreenGui = screenGui, MainFrame = mainFrame, KeyInput = textBox, SubmitBtn = textButton, GetKeyBtn = textButton2, StatusLabel = textLabel3, }
end

local function helper(val2, text, val3)
  if not val2 or not val2.Parent then
    return
  end

  pcall(function()
    tweenService:Create(val2, TweenInfo.new(0.08), { TextTransparency = 0.8 }):Play()
    task.wait(0.08)
    val2.Text = text

    if val3 then
      val2.TextColor3 = val3
    end

    tweenService:Create(val2, TweenInfo.new(0.12), { TextTransparency = 0 }):Play()
  end)
end

local function fetchData(val4, val5)
  helper(val5, "Starting verification...", Color3.fromRGB(251, 191, 36))
  task.wait(0.1)
  local decoded = string.gsub(val4, "%s+", "")
  local decoded2 = string.gsub(decoded, "'", "")
  local decoded3 = string.gsub(decoded2, "\"", "")
  helper(val5, "Building request...", Color3.fromRGB(251, 191, 36))
  local strVal = tostring(tick())

  local val6 = "https://scriptkeysystem.com/api/validate-key?verify=1&key="
    .. httpService:UrlEncode(decoded3) .. "&script=b522c79b-cbc0-4cb2-9ecb-0ed643b68e2c&t=" .. strVal

  task.wait(0.1)
  helper(val5, "Connecting to server...", Color3.fromRGB(251, 191, 36))
  local val7, httpResponse = pcall(function() return game:HttpGet(val6, true) end)
  helper(val5, "Processing response...", Color3.fromRGB(251, 191, 36))

  if not val7 then
    return false, "connection_error"
  else
    local decoded4 = string.lower((string.gsub(string.gsub(
      string.gsub(httpResponse, "^%s*(.-)%s*$", "%1"), "\r", ""
    ), "\n", "")))

    helper(val5, "Validating key...", Color3.fromRGB(251, 191, 36))
    task.wait(0.1)

    if decoded4 == "valid" then
      return true, "valid"
    elseif decoded4 == "expired" then
      return false, "expired"
    else
      if decoded4 == "invalid" then
        return false, "invalid"
      end

      return false, "error"
    end
  end
end

local function safeCall(val8)
  print("[LOADING] Target Script...")

  local val9, success = pcall(function()
    local val10 = "https://scriptkeysystem.com/api/validate-key?script=b522c79b-cbc0-4cb2-9ecb-0ed643b68e2c"

    if val8 and string.find(val10, "?") then
      val10 = val10 .. "&key=" .. httpService:UrlEncode(val8)
    elseif val8 then
      val10 = val10 .. "?key=" .. httpService:UrlEncode(val8)
    end

    loadstring(game:HttpGet(val10 .. (string.find(val10, "?") and "&" or "?") .. "t="
      .. tostring(tick()), true))()
  end)

  if val9 then
    print("[SUCCESS] Target Script loaded!")
  else
    print("[ERROR] Script failed:", success)
  end
end

local function safeCall2()
  local element = createScreenGui()

  element.GetKeyBtn.MouseButton1Click:Connect(function()
    local val11 = setclipboard or toclipboard or Clipboard and Clipboard.set

    if val11 then
      pcall(function()
        val11("https://scriptkeysystem.com/sanaullah/keysystem?script=b522c79b-cbc0-4cb2-9ecb-0ed643b68e2c")
      end)

      helper(element.StatusLabel, "URL copied to clipboard!", Color3.fromRGB(52, 211, 153))
    else
      helper(element.StatusLabel, "Clipboard not supported", Color3.fromRGB(248, 113, 113))
    end

    print("ââââââââââââââââââââââââââââââ")
    print("[Key System] Key Link: https://scriptkeysystem.com/sanaullah/keysystem?script=b522c79b-cbc0-4cb2-9ecb-0ed643b68e2c")
    print("ââââââââââââââââââââââââââââââ")

    task.wait(3)

    if element.StatusLabel and element.StatusLabel.Parent then
      helper(element.StatusLabel, "Ready to verify", Color3.fromRGB(113, 113, 122))
    end
  end)

  element.SubmitBtn.MouseButton1Click:Connect(function()
    local text2 = element.KeyInput.Text

    if text2 == "" then
      helper(element.StatusLabel, "Please enter a key", Color3.fromRGB(248, 113, 113))
      return
    end

    helper(element.StatusLabel, "Verifying key...", Color3.fromRGB(251, 191, 36))

    element.SubmitBtn.Text = "Checking..."
    element.SubmitBtn.Active = false

    task.spawn(function()
      local val12, val13 = fetchData(text2, element.StatusLabel)

      if val12 then
        helper(element.StatusLabel, "Key verified! Loading script...", Color3.fromRGB(52, 211, 153))
        element.SubmitBtn.Text = "Verified"

        pcall(function()
          tweenService:Create(element.SubmitBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(16, 185, 129), TextColor3 = Color3.fromRGB(255, 255, 255), }):Play()
        end)

        pcall(function()
          starterGui:SetCore("SendNotification", {
            Title = "Key Verified", Text = "Loading script...", Duration = 3, })
        end)

        task.wait(1.2)
        local decoded5 = string.gsub(text2, "%s+", "")

        pcall(function()
          local create2 = tweenService:Create(element.MainFrame, TweenInfo.new(
            0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In
          ), {
            Size = UDim2.new(0, 300, 0, 220), BackgroundTransparency = 1, })

          create2:Play()
          create2.Completed:Connect(function() element.ScreenGui:Destroy() end)
        end)

        safeCall(decoded5)
      else
        element.SubmitBtn.Text = "Verify Key"
        element.SubmitBtn.Active = true

        if val13 == "expired" then
          helper(element.StatusLabel, "Key has expired", Color3.fromRGB(248, 113, 113))
        elseif val13 == "invalid" then
          helper(element.StatusLabel, "Invalid key entered", Color3.fromRGB(248, 113, 113))
        else
          helper(
            element.StatusLabel, "Verification failed: " .. tostring(val13), Color3.fromRGB(248, 113, 113)
          )
        end
      end
    end)
  end)
end

safeCall2()