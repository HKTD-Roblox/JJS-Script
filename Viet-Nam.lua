local Players = game:GetService("Players")

local UIS = game:GetService("UserInputService")

local RunService = game:GetService("RunService")


local Player = Players.LocalPlayer


local Character

local Humanoid

local Root


local Flying = false

local TPAllRunning = false

local ItemESP = false

local CurrentSpeed = 100


local TP_INTERVAL = 0.111

local TP_DURATION = 20

local PASS_DISTANCE = 8


--------------------------------------------------

-- CHARACTER

--------------------------------------------------


local function setupCharacter(char)

 Character = char

 Humanoid = char:WaitForChild("Humanoid")

 Root = char:WaitForChild("HumanoidRootPart")


 Flying = false

end


if Player.Character then

 setupCharacter(Player.Character)

end


Player.CharacterAdded:Connect(setupCharacter)


--------------------------------------------------

-- GUI

--------------------------------------------------


local Gui = Instance.new("ScreenGui")

Gui.Name = "VietnamFlyMiniGui"

Gui.ResetOnSpawn = false

Gui.Parent = Player:WaitForChild("PlayerGui")


--------------------------------------------------

-- PANEL

--------------------------------------------------


local Panel = Instance.new("Frame")

Panel.Size = UDim2.new(0, 210, 0, 335)

Panel.Position = UDim2.new(0, 10, 0.5, -167)

Panel.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

Panel.BorderSizePixel = 0

Panel.Parent = Gui


local PanelCorner = Instance.new("UICorner")

PanelCorner.CornerRadius = UDim.new(0, 12)

PanelCorner.Parent = Panel


--------------------------------------------------

-- HEADER

--------------------------------------------------


local Header = Instance.new("TextButton")

Header.Size = UDim2.new(1, -38, 0, 38)

Header.Position = UDim2.new(0, 0, 0, 0)

Header.BackgroundTransparency = 1

Header.Text = "🇻🇳 VIỆT NAM"

Header.TextColor3 = Color3.fromRGB(255, 230, 0)

Header.TextSize = 16

Header.Font = Enum.Font.GothamBold

Header.Parent = Panel


--------------------------------------------------

-- CLOSE

--------------------------------------------------


local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.new(0, 28, 0, 28)

CloseButton.Position = UDim2.new(1, -34, 0, 5)

CloseButton.Text = "✕"

CloseButton.TextSize = 15

CloseButton.Font = Enum.Font.GothamBold

CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseButton.Parent = Panel


local CloseCorner = Instance.new("UICorner")

CloseCorner.CornerRadius = UDim.new(1, 0)

CloseCorner.Parent = CloseButton


--------------------------------------------------

-- OPEN BUTTON

--------------------------------------------------


local OpenButton = Instance.new("TextButton")

OpenButton.Size = UDim2.new(0, 48, 0, 48)

OpenButton.Position = UDim2.new(0, 10, 0.5, -24)

OpenButton.Text = "⭐"

OpenButton.TextSize = 23

OpenButton.Font = Enum.Font.GothamBold

OpenButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

OpenButton.TextColor3 = Color3.fromRGB(255, 230, 0)

OpenButton.Visible = false

OpenButton.Parent = Gui


local OpenCorner = Instance.new("UICorner")

OpenCorner.CornerRadius = UDim.new(1, 0)

OpenCorner.Parent = OpenButton


--------------------------------------------------

-- STAR

--------------------------------------------------


local Star = Instance.new("TextLabel")

Star.Size = UDim2.new(1, 0, 0, 25)

Star.Position = UDim2.new(0, 0, 0, 35)

Star.BackgroundTransparency = 1

Star.Text = "★"

Star.TextColor3 = Color3.fromRGB(255, 230, 0)

Star.TextSize = 22

Star.Font = Enum.Font.GothamBold

Star.Parent = Panel


--------------------------------------------------

-- BUTTON HELPER

--------------------------------------------------


local function makeButton(text, y, height)


 local Button = Instance.new("TextButton")


 Button.Size = UDim2.new(1, -16, 0, height)

 Button.Position = UDim2.new(0, 8, 0, y)


 Button.Text = text

 Button.TextSize = 13

 Button.Font = Enum.Font.GothamBold


 Button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)

 Button.TextColor3 = Color3.fromRGB(255, 255, 0)


 Button.Parent = Panel


 local Corner = Instance.new("UICorner")

 Corner.CornerRadius = UDim.new(0, 8)

 Corner.Parent = Button


 return Button

end


--------------------------------------------------

-- FLY

--------------------------------------------------


local FlyButton =

 makeButton("🦅 FLY: OFF", 63, 34)


--------------------------------------------------

-- SPEED

--------------------------------------------------


local SpeedBox = Instance.new("TextBox")


SpeedBox.Size = UDim2.new(1, -16, 0, 32)

SpeedBox.Position = UDim2.new(0, 8, 0, 102)


SpeedBox.PlaceholderText = "Speed 1 - 5000"

SpeedBox.Text = "100"


SpeedBox.TextSize = 14

SpeedBox.Font = Enum.Font.GothamBold


SpeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

SpeedBox.TextColor3 = Color3.fromRGB(0, 0, 0)


SpeedBox.Parent = Panel


local SpeedCorner = Instance.new("UICorner")

SpeedCorner.CornerRadius = UDim.new(0, 8)

SpeedCorner.Parent = SpeedBox


--------------------------------------------------

-- FULL HP

--------------------------------------------------


local HPButton =

 makeButton("❤️ FULL HP", 143, 34)


--------------------------------------------------

-- TP ALL

--------------------------------------------------


local TPButton =

 makeButton("👥 TP ALL 20S", 184, 36)


--------------------------------------------------

-- SHOW ITEMS

--------------------------------------------------


local ItemButton =

 makeButton("🗺️ SHOW ITEMS: OFF", 227, 36)


--------------------------------------------------

-- STOP TP

--------------------------------------------------


local StopButton =

 makeButton("🛑 STOP TP", 270, 30)


StopButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)


--------------------------------------------------

-- STATUS

--------------------------------------------------


local Status = Instance.new("TextLabel")


Status.Size = UDim2.new(1, -16, 0, 25)

Status.Position = UDim2.new(0, 8, 0, 303)


Status.BackgroundTransparency = 1


Status.Text = "🇻🇳 Ready"

Status.TextColor3 = Color3.fromRGB(255, 255, 0)


Status.TextSize = 11

Status.Font = Enum.Font.GothamBold


Status.Parent = Panel


--------------------------------------------------

-- MOBILE UP

--------------------------------------------------


local UpButton = Instance.new("TextButton")


UpButton.Size = UDim2.new(0, 55, 0, 55)

UpButton.Position = UDim2.new(1, -68, 0.55, -60)


UpButton.Text = "▲"

UpButton.TextSize = 25

UpButton.Font = Enum.Font.GothamBold


UpButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

UpButton.TextColor3 = Color3.fromRGB(255, 230, 0)


UpButton.Parent = Gui


local UpCorner = Instance.new("UICorner")

UpCorner.CornerRadius = UDim.new(1, 0)

UpCorner.Parent = UpButton


--------------------------------------------------

-- MOBILE DOWN

--------------------------------------------------


local DownButton = Instance.new("TextButton")


DownButton.Size = UDim2.new(0, 55, 0, 55)

DownButton.Position = UDim2.new(1, -68, 0.55, 5)


DownButton.Text = "▼"

DownButton.TextSize = 25

DownButton.Font = Enum.Font.GothamBold


DownButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

DownButton.TextColor3 = Color3.fromRGB(255, 230, 0)


DownButton.Parent = Gui


local DownCorner = Instance.new("UICorner")

DownCorner.CornerRadius = UDim.new(1, 0)

DownCorner.Parent = DownButton


local UpHeld = false

local DownHeld = false


UpButton.MouseButton1Down:Connect(function()

 UpHeld = true

end)


UpButton.MouseButton1Up:Connect(function()

 UpHeld = false

end)


DownButton.MouseButton1Down:Connect(function()

 DownHeld = true

end)


DownButton.MouseButton1Up:Connect(function()

 DownHeld = false

end)


--------------------------------------------------

-- CLOSE / OPEN

--------------------------------------------------


CloseButton.MouseButton1Click:Connect(function()


 Panel.Visible = false


 UpButton.Visible = false

 DownButton.Visible = false


 OpenButton.Visible = true

end)


OpenButton.MouseButton1Click:Connect(function()


 Panel.Visible = true


 UpButton.Visible = true

 DownButton.Visible = true


 OpenButton.Visible = false

end)


--------------------------------------------------

-- SPEED

--------------------------------------------------


SpeedBox.FocusLost:Connect(function()


 local n = tonumber(SpeedBox.Text)


 if n then

  CurrentSpeed = math.clamp(n, 1, 5000)

  SpeedBox.Text = tostring(CurrentSpeed)

 else

  SpeedBox.Text = tostring(CurrentSpeed)

 end

end)


--------------------------------------------------

-- FLY

--------------------------------------------------


FlyButton.MouseButton1Click:Connect(function()


 Flying = not Flying


 if Flying then


  FlyButton.Text = "🦅 FLY: ON"


  Status.Text = "🦅 Flying"


 else


  FlyButton.Text = "🦅 FLY: OFF"


  if Root then

   Root.AssemblyLinearVelocity = Vector3.zero

  end


  Status.Text = "🇻🇳 Ready"

 end

end)


--------------------------------------------------

-- FULL HP

--------------------------------------------------


HPButton.MouseButton1Click:Connect(function()


 if Humanoid then


  Humanoid.Health =

   Humanoid.MaxHealth


  Status.Text = "❤️ FULL HP"

 end

end)


--------------------------------------------------

-- ITEM MARKERS

--------------------------------------------------


local ItemMarkers = {}


local function clearItemMarkers()


 for _, marker in ipairs(ItemMarkers) do


  if marker

   and marker.Parent then


   marker:Destroy()

  end

 end


 table.clear(ItemMarkers)

end


local function getItemPart(item)


 if item:IsA("BasePart") then

  return item

 end


 if item:IsA("Model") then


  if item.PrimaryPart then

   return item.PrimaryPart

  end


  return item:FindFirstChildWhichIsA(

   "BasePart",

   true

  )

 end


 return nil

end


local function showItems()


 clearItemMarkers()


 local ItemsFolder =

  workspace:FindFirstChild("Items")


 if not ItemsFolder then


  Status.Text =

   "❌ Không có Workspace.Items"


  return

 end


 local Count = 0


 for _, item in ipairs(

  ItemsFolder:GetDescendants()

 ) do


  local Part =

   getItemPart(item)


  if Part then


   local Billboard =

    Instance.new("BillboardGui")


   Billboard.Name =

    "ItemMarker"


   Billboard.Size =

    UDim2.fromOffset(150, 30)


   Billboard.StudsOffset =

    Vector3.new(0, 3, 0)


   Billboard.AlwaysOnTop =

    true


   Billboard.Adornee =

    Part


   Billboard.Parent =

    Part


   local Label =

    Instance.new("TextLabel")


   Label.Size =

    UDim2.fromScale(1, 1)


   Label.BackgroundTransparency =

    1


   Label.Text =

    "📦 " .. item.Name


   Label.TextColor3 =

    Color3.fromRGB(

     255,

     255,

     0

    )


   Label.TextStrokeTransparency =

    0


   Label.TextSize = 13


   Label.Font =

    Enum.Font.GothamBold


   Label.Parent =

    Billboard


   table.insert(

    ItemMarkers,

    Billboard

   )


   Count += 1

  end

 end


 Status.Text =

  "🗺️ Items: ON (" .. Count .. ")"

end


--------------------------------------------------

-- ITEM TOGGLE

--------------------------------------------------


ItemButton.MouseButton1Click:Connect(function()


 ItemESP = not ItemESP


 if ItemESP then


  ItemButton.Text =

   "🗺️ ITEMS: ON"


  showItems()


 else


  ItemButton.Text =

   "🗺️ SHOW ITEMS: OFF"


  clearItemMarkers()


  Status.Text =

   "🗺️ Items: OFF"

 end

end)


--------------------------------------------------

-- TP THROUGH PLAYER

--------------------------------------------------


local function teleportThroughPlayer(Target)


 if not Root then

  return

 end


 local TargetCharacter =

  Target.Character


 if not TargetCharacter then

  return

 end


 local TargetRoot =

  TargetCharacter:FindFirstChild(

   "HumanoidRootPart"

  )


 if not TargetRoot then

  return

 end


 local StartPosition =

  TargetRoot.Position

  - TargetRoot.CFrame.LookVector * 0.5


 Root.CFrame =

  CFrame.lookAt(

   StartPosition,

   TargetRoot.Position

  )


 task.wait(0.03)


 local EndPosition =

  TargetRoot.Position

  + TargetRoot.CFrame.LookVector

  * PASS_DISTANCE


 Root.CFrame =

  CFrame.lookAt(

   EndPosition,

   TargetRoot.Position

  )


 task.wait(0.03)

end


--------------------------------------------------

-- TP ALL

--------------------------------------------------


TPButton.MouseButton1Click:Connect(function()


 if TPAllRunning then

  return

 end


 TPAllRunning = true


 Status.Text =

  "👥 TP ALL..."


 task.spawn(function()


  local StartTime =

   os.clock()


  while TPAllRunning

   and os.clock() - StartTime

   < TP_DURATION do


   for _, Target in ipairs(

    Players:GetPlayers()

   ) do


    if not TPAllRunning then

     break

    end


    if Target ~= Player then

     teleportThroughPlayer(Target)

    end


    task.wait(TP_INTERVAL)

   end


   task.wait(TP_INTERVAL)

  end


  TPAllRunning = false


  Status.Text =

   "🇻🇳 TP ALL xong"

 end)

end)


--------------------------------------------------

-- STOP TP

--------------------------------------------------


StopButton.MouseButton1Click:Connect(function()


 TPAllRunning = false


 Status.Text =

  "🛑 TP đã dừng"

end)


--------------------------------------------------

-- FLY LOOP

--------------------------------------------------


RunService.RenderStepped:Connect(function()


 if not Flying then

  return

 end


 if not Character

  or not Humanoid

  or not Root then


  return

 end


 local n =

  tonumber(SpeedBox.Text)


 if n then


  CurrentSpeed =

   math.clamp(

    n,

    1,

    5000

   )

 end


 local MoveDirection =

  Humanoid.MoveDirection


 local Velocity =

  MoveDirection

  * CurrentSpeed


 if UpHeld then


  Velocity += Vector3.new(

   0,

   CurrentSpeed,

   0

  )


 elseif DownHeld then


  Velocity += Vector3.new(

   0,

   -CurrentSpeed,

   0

  )

 end


 Root.AssemblyLinearVelocity =

  Velocity

end)


--------------------------------------------------

-- DRAG PANEL

--------------------------------------------------


local Dragging = false

local DragStart

local StartPosition


Header.InputBegan:Connect(function(Input)


 if Input.UserInputType ==

  Enum.UserInputType.MouseButton1


  or Input.UserInputType ==

  Enum.UserInputType.Touch then


  Dragging = true


  DragStart =

   Input.Position


  StartPosition =

   Panel.Position


  Input.Changed:Connect(function()


   if Input.UserInputState ==

    Enum.UserInputState.End then


    Dragging = false

   end

  end)

 end

end)


UIS.InputChanged:Connect(function(Input)


 if not Dragging then

  return

 end


 if Input.UserInputType ==

  Enum.UserInputType.MouseMovement


  or Input.UserInputType ==

  Enum.UserInputType.Touch then


  local Delta =

   Input.Position

   - DragStart


  Panel.Position =

   UDim2.new(

    StartPosition.X.Scale,

    StartPosition.X.Offset

     + Delta.X,


    StartPosition.Y.Scale,

    StartPosition.Y.Offset

     + Delta.Y

   )

 end

end)


--------------------------------------------------

-- AUTO REFRESH ITEM

--------------------------------------------------


task.spawn(function()


 while true do


  task.wait(2)


  if ItemESP then

   showItems()

  end

 end

end)


--------------------------------------------------

-- READY

--------------------------------------------------


Status.Text =

 "


-- Roblox Studio

-- StarterPlayer > StarterPlayerScripts


local Players = game:GetService("Players")

local UIS = game:GetService("UserInputService")

local RunService = game:GetService("RunService")


local Player = Players.LocalPlayer


local Character

local Humanoid

local Root


local Flying = false

local TPAllRunning = false

local ItemESP = false

local CurrentSpeed = 100


local TP_INTERVAL = 0.111

local TP_DURATION = 20

local PASS_DISTANCE = 8


--------------------------------------------------

-- CHARACTER

--------------------------------------------------


local function setupCharacter(char)

 Character = char

 Humanoid = char:WaitForChild("Humanoid")

 Root = char:WaitForChild("HumanoidRootPart")


 Flying = false

end


if Player.Character then

 setupCharacter(Player.Character)

end


Player.CharacterAdded:Connect(setupCharacter)


--------------------------------------------------

-- GUI

--------------------------------------------------


local Gui = Instance.new("ScreenGui")

Gui.Name = "VietnamFlyMiniGui"

Gui.ResetOnSpawn = false

Gui.Parent = Player:WaitForChild("PlayerGui")


--------------------------------------------------

-- PANEL

--------------------------------------------------


local Panel = Instance.new("Frame")

Panel.Size = UDim2.new(0, 210, 0, 335)

Panel.Position = UDim2.new(0, 10, 0.5, -167)

Panel.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

Panel.BorderSizePixel = 0

Panel.Parent = Gui


local PanelCorner = Instance.new("UICorner")

PanelCorner.CornerRadius = UDim.new(0, 12)

PanelCorner.Parent = Panel


--------------------------------------------------

-- HEADER

--------------------------------------------------


local Header = Instance.new("TextButton")

Header.Size = UDim2.new(1, -38, 0, 38)

Header.Position = UDim2.new(0, 0, 0, 0)

Header.BackgroundTransparency = 1

Header.Text = "🇻🇳 VIỆT NAM"

Header.TextColor3 = Color3.fromRGB(255, 230, 0)

Header.TextSize = 16

Header.Font = Enum.Font.GothamBold

Header.Parent = Panel


--------------------------------------------------

-- CLOSE

--------------------------------------------------


local CloseButton = Instance.new("TextButton")

CloseButton.Size = UDim2.new(0, 28, 0, 28)

CloseButton.Position = UDim2.new(1, -34, 0, 5)

CloseButton.Text = "✕"

CloseButton.TextSize = 15

CloseButton.Font = Enum.Font.GothamBold

CloseButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)

CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseButton.Parent = Panel


local CloseCorner = Instance.new("UICorner")

CloseCorner.CornerRadius = UDim.new(1, 0)

CloseCorner.Parent = CloseButton


--------------------------------------------------

-- OPEN BUTTON

--------------------------------------------------


local OpenButton = Instance.new("TextButton")

OpenButton.Size = UDim2.new(0, 48, 0, 48)

OpenButton.Position = UDim2.new(0, 10, 0.5, -24)

OpenButton.Text = "⭐"

OpenButton.TextSize = 23

OpenButton.Font = Enum.Font.GothamBold

OpenButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

OpenButton.TextColor3 = Color3.fromRGB(255, 230, 0)

OpenButton.Visible = false

OpenButton.Parent = Gui


local OpenCorner = Instance.new("UICorner")

OpenCorner.CornerRadius = UDim.new(1, 0)

OpenCorner.Parent = OpenButton


--------------------------------------------------

-- STAR

--------------------------------------------------


local Star = Instance.new("TextLabel")

Star.Size = UDim2.new(1, 0, 0, 25)

Star.Position = UDim2.new(0, 0, 0, 35)

Star.BackgroundTransparency = 1

Star.Text = "★"

Star.TextColor3 = Color3.fromRGB(255, 230, 0)

Star.TextSize = 22

Star.Font = Enum.Font.GothamBold

Star.Parent = Panel


--------------------------------------------------

-- BUTTON HELPER

--------------------------------------------------


local function makeButton(text, y, height)


 local Button = Instance.new("TextButton")


 Button.Size = UDim2.new(1, -16, 0, height)

 Button.Position = UDim2.new(0, 8, 0, y)


 Button.Text = text

 Button.TextSize = 13

 Button.Font = Enum.Font.GothamBold


 Button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)

 Button.TextColor3 = Color3.fromRGB(255, 255, 0)


 Button.Parent = Panel


 local Corner = Instance.new("UICorner")

 Corner.CornerRadius = UDim.new(0, 8)

 Corner.Parent = Button


 return Button

end


--------------------------------------------------

-- FLY

--------------------------------------------------


local FlyButton =

 makeButton("🦅 FLY: OFF", 63, 34)


--------------------------------------------------

-- SPEED

--------------------------------------------------


local SpeedBox = Instance.new("TextBox")


SpeedBox.Size = UDim2.new(1, -16, 0, 32)

SpeedBox.Position = UDim2.new(0, 8, 0, 102)


SpeedBox.PlaceholderText = "Speed 1 - 5000"

SpeedBox.Text = "100"


SpeedBox.TextSize = 14

SpeedBox.Font = Enum.Font.GothamBold


SpeedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

SpeedBox.TextColor3 = Color3.fromRGB(0, 0, 0)


SpeedBox.Parent = Panel


local SpeedCorner = Instance.new("UICorner")

SpeedCorner.CornerRadius = UDim.new(0, 8)

SpeedCorner.Parent = SpeedBox


--------------------------------------------------

-- FULL HP

--------------------------------------------------


local HPButton =

 makeButton("❤️ FULL HP", 143, 34)


--------------------------------------------------

-- TP ALL

--------------------------------------------------


local TPButton =

 makeButton("👥 TP ALL 20S", 184, 36)


--------------------------------------------------

-- SHOW ITEMS

--------------------------------------------------


local ItemButton =

 makeButton("🗺️ SHOW ITEMS: OFF", 227, 36)


--------------------------------------------------

-- STOP TP

--------------------------------------------------


local StopButton =

 makeButton("🛑 STOP TP", 270, 30)


StopButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)

StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)


--------------------------------------------------

-- STATUS

--------------------------------------------------


local Status = Instance.new("TextLabel")


Status.Size = UDim2.new(1, -16, 0, 25)

Status.Position = UDim2.new(0, 8, 0, 303)


Status.BackgroundTransparency = 1


Status.Text = "🇻🇳 Ready"

Status.TextColor3 = Color3.fromRGB(255, 255, 0)


Status.TextSize = 11

Status.Font = Enum.Font.GothamBold


Status.Parent = Panel


--------------------------------------------------

-- MOBILE UP

--------------------------------------------------


local UpButton = Instance.new("TextButton")


UpButton.Size = UDim2.new(0, 55, 0, 55)

UpButton.Position = UDim2.new(1, -68, 0.55, -60)


UpButton.Text = "▲"

UpButton.TextSize = 25

UpButton.Font = Enum.Font.GothamBold


UpButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

UpButton.TextColor3 = Color3.fromRGB(255, 230, 0)


UpButton.Parent = Gui


local UpCorner = Instance.new("UICorner")

UpCorner.CornerRadius = UDim.new(1, 0)

UpCorner.Parent = UpButton


--------------------------------------------------

-- MOBILE DOWN

--------------------------------------------------


local DownButton = Instance.new("TextButton")


DownButton.Size = UDim2.new(0, 55, 0, 55)

DownButton.Position = UDim2.new(1, -68, 0.55, 5)


DownButton.Text = "▼"

DownButton.TextSize = 25

DownButton.Font = Enum.Font.GothamBold


DownButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)

DownButton.TextColor3 = Color3.fromRGB(255, 230, 0)


DownButton.Parent = Gui


local DownCorner = Instance.new("UICorner")

DownCorner.CornerRadius = UDim.new(1, 0)

DownCorner.Parent = DownButton


local UpHeld = false

local DownHeld = false


UpButton.MouseButton1Down:Connect(function()

 UpHeld = true

end)


UpButton.MouseButton1Up:Connect(function()

 UpHeld = false

end)


DownButton.MouseButton1Down:Connect(function()

 DownHeld = true

end)


DownButton.MouseButton1Up:Connect(function()

 DownHeld = false

end)


--------------------------------------------------

-- CLOSE / OPEN

--------------------------------------------------


CloseButton.MouseButton1Click:Connect(function()


 Panel.Visible = false


 UpButton.Visible = false

 DownButton.Visible = false


 OpenButton.Visible = true

end)


OpenButton.MouseButton1Click:Connect(function()


 Panel.Visible = true


 UpButton.Visible = true

 DownButton.Visible = true


 OpenButton.Visible = false

end)


--------------------------------------------------

-- SPEED

--------------------------------------------------


SpeedBox.FocusLost:Connect(function()


 local n = tonumber(SpeedBox.Text)


 if n then

  CurrentSpeed = math.clamp(n, 1, 5000)

  SpeedBox.Text = tostring(CurrentSpeed)

 else

  SpeedBox.Text = tostring(CurrentSpeed)

 end

end)


--------------------------------------------------

-- FLY

--------------------------------------------------


FlyButton.MouseButton1Click:Connect(function()


 Flying = not Flying


 if Flying then


  FlyButton.Text = "🦅 FLY: ON"


  Status.Text = "🦅 Flying"


 else


  FlyButton.Text = "🦅 FLY: OFF"


  if Root then

   Root.AssemblyLinearVelocity = Vector3.zero

  end


  Status.Text = "🇻🇳 Ready"

 end

end)


--------------------------------------------------

-- FULL HP

--------------------------------------------------


HPButton.MouseButton1Click:Connect(function()


 if Humanoid then


  Humanoid.Health =

   Humanoid.MaxHealth


  Status.Text = "❤️ FULL HP"

 end

end)


--------------------------------------------------

-- ITEM MARKERS

--------------------------------------------------


local ItemMarkers = {}


local function clearItemMarkers()


 for _, marker in ipairs(ItemMarkers) do


  if marker

   and marker.Parent then


   marker:Destroy()

  end

 end


 table.clear(ItemMarkers)

end


local function getItemPart(item)


 if item:IsA("BasePart") then

  return item

 end


 if item:IsA("Model") then


  if item.PrimaryPart then

   return item.PrimaryPart

  end


  return item:FindFirstChildWhichIsA(

   "BasePart",

   true

  )

 end


 return nil

end


local function showItems()


 clearItemMarkers()


 local ItemsFolder =

  workspace:FindFirstChild("Items")


 if not ItemsFolder then


  Status.Text =

   "❌ Không có Workspace.Items"


  return

 end


 local Count = 0


 for _, item in ipairs(

  ItemsFolder:GetDescendants()

 ) do


  local Part =

   getItemPart(item)


  if Part then


   local Billboard =

    Instance.new("BillboardGui")


   Billboard.Name =

    "ItemMarker"


   Billboard.Size =

    UDim2.fromOffset(150, 30)


   Billboard.StudsOffset =

    Vector3.new(0, 3, 0)


   Billboard.AlwaysOnTop =

    true


   Billboard.Adornee =

    Part


   Billboard.Parent =

    Part


   local Label =

    Instance.new("TextLabel")


   Label.Size =

    UDim2.fromScale(1, 1)


   Label.BackgroundTransparency =

    1


   Label.Text =

    "📦 " .. item.Name


   Label.TextColor3 =

    Color3.fromRGB(

     255,

     255,

     0

    )


   Label.TextStrokeTransparency =

    0


   Label.TextSize = 13


   Label.Font =

    Enum.Font.GothamBold


   Label.Parent =

    Billboard


   table.insert(

    ItemMarkers,

    Billboard

   )


   Count += 1

  end

 end


 Status.Text =

  "🗺️ Items: ON (" .. Count .. ")"

end


--------------------------------------------------

-- ITEM TOGGLE

--------------------------------------------------


ItemButton.MouseButton1Click:Connect(function()


 ItemESP = not ItemESP


 if ItemESP then


  ItemButton.Text =

   "🗺️ ITEMS: ON"


  showItems()


 else


  ItemButton.Text =

   "🗺️ SHOW ITEMS: OFF"


  clearItemMarkers()


  Status.Text =

   "🗺️ Items: OFF"

 end

end)


--------------------------------------------------

-- TP THROUGH PLAYER

--------------------------------------------------


local function teleportThroughPlayer(Target)


 if not Root then

  return

 end


 local TargetCharacter =

  Target.Character


 if not TargetCharacter then

  return

 end


 local TargetRoot =

  TargetCharacter:FindFirstChild(

   "HumanoidRootPart"

  )


 if not TargetRoot then

  return

 end


 local StartPosition =

  TargetRoot.Position

  - TargetRoot.CFrame.LookVector * 0.5


 Root.CFrame =

  CFrame.lookAt(

   StartPosition,

   TargetRoot.Position

  )


 task.wait(0.03)


 local EndPosition =

  TargetRoot.Position

  + TargetRoot.CFrame.LookVector

  * PASS_DISTANCE


 Root.CFrame =

  CFrame.lookAt(

   EndPosition,

   TargetRoot.Position

  )


 task.wait(0.03)

end


--------------------------------------------------

-- TP ALL

--------------------------------------------------


TPButton.MouseButton1Click:Connect(function()


 if TPAllRunning then

  return

 end


 TPAllRunning = true


 Status.Text =

  "👥 TP ALL..."


 task.spawn(function()


  local StartTime =

   os.clock()


  while TPAllRunning

   and os.clock() - StartTime

   < TP_DURATION do


   for _, Target in ipairs(

    Players:GetPlayers()

   ) do


    if not TPAllRunning then

     break

    end


    if Target ~= Player then

     teleportThroughPlayer(Target)

    end


    task.wait(TP_INTERVAL)

   end


   task.wait(TP_INTERVAL)

  end


  TPAllRunning = false


  Status.Text =

   "🇻🇳 TP ALL xong"

 end)

end)


--------------------------------------------------

-- STOP TP

--------------------------------------------------


StopButton.MouseButton1Click:Connect(function()


 TPAllRunning = false


 Status.Text =

  "🛑 TP đã dừng"

end)


--------------------------------------------------

-- FLY LOOP

--------------------------------------------------


RunService.RenderStepped:Connect(function()


 if not Flying then

  return

 end


 if not Character

  or not Humanoid

  or not Root then


  return

 end


 local n =

  tonumber(SpeedBox.Text)


 if n then


  CurrentSpeed =

   math.clamp(

    n,

    1,

    5000

   )

 end


 local MoveDirection =

  Humanoid.MoveDirection


 local Velocity =

  MoveDirection

  * CurrentSpeed


 if UpHeld then


  Velocity += Vector3.new(

   0,

   CurrentSpeed,

   0

  )


 elseif DownHeld then


  Velocity += Vector3.new(

   0,

   -CurrentSpeed,

   0

  )

 end


 Root.AssemblyLinearVelocity =

  Velocity

end)


--------------------------------------------------

-- DRAG PANEL

--------------------------------------------------


local Dragging = false

local DragStart

local StartPosition


Header.InputBegan:Connect(function(Input)


 if Input.UserInputType ==

  Enum.UserInputType.MouseButton1


  or Input.UserInputType ==

  Enum.UserInputType.Touch then


  Dragging = true


  DragStart =

   Input.Position


  StartPosition =

   Panel.Position


  Input.Changed:Connect(function()


   if Input.UserInputState ==

    Enum.UserInputState.End then


    Dragging = false

   end

  end)

 end

end)


UIS.InputChanged:Connect(function(Input)


 if not Dragging then

  return

 end


 if Input.UserInputType ==

  Enum.UserInputType.MouseMovement


  or Input.UserInputType ==

  Enum.UserInputType.Touch then


  local Delta =

   Input.Position

   - DragStart


  Panel.Position =

   UDim2.new(

    StartPosition.X.Scale,

    StartPosition.X.Offset

     + Delta.X,


    StartPosition.Y.Scale,

    StartPosition.Y.Offset

     + Delta.Y

   )

 end

end)


--------------------------------------------------

-- AUTO REFRESH ITEM

--------------------------------------------------


task.spawn(function()


 while true do


  task.wait(2)


  if ItemESP then

   showItems()

  end

 end

end)


--------------------------------------------------

-- READY

--------------------------------------------------


Status.Text =

"🇻🇳Ready"
