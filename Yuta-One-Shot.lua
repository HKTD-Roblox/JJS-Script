local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera
local isExecuting = false
local CFloop = nil

local BTN_IMAGE_OFF = "rbxassetid://6256840888"
local BTN_IMAGE_ON = "rbxassetid://12815575858"
local ICON_IMAGE = "rbxassetid://97537169093698"

local function doBlackFlash()
if isExecuting or not lp.Character then return end
local char = lp.Character
local hrp = char:FindFirstChild("HumanoidRootPart")
local head = char:FindFirstChild("Head")
local hum = char:FindFirstChildOfClass('Humanoid')
if not hrp or not head or not hum then return end
isExecuting = true
hum.PlatformStand = true
head.Anchored = true
local moveset = char:FindFirstChild("Moveset")
local move = moveset and moveset:FindFirstChild("Resolute Slash")
if move then
pcall(function() replicatesignal(lp.Kill) end)
task.wait(0.1)
local target = nil
pcall(function()
local Knit = require(ReplicatedStorage.Knit.Knit)
target = Knit.GetController("ToolController"):GetTarget()
end)
local skillTarget = (target and target.Parent) and target or char
local remote = ReplicatedStorage:FindFirstChild("Knit")
if remote then
remote.Knit.Services.ResoluteSlashService.RE.Activated:FireServer(move, skillTarget)
end
end
if CFloop then CFloop:Disconnect() end
CFloop = RunService.Heartbeat:Connect(function(deltaTime)
if not isExecuting or not head or not head.Parent then return end
local moveDir = hum.MoveDirection
local camLook = cam.CFrame.LookVector
local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
if moveDir.Magnitude > 0 then
moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
local newPos = head.Position + (moveDir * 28 * deltaTime)
head.CFrame = CFrame.lookAt(newPos, newPos + flatLook)
else
head.CFrame = CFrame.lookAt(head.Position, head.Position + flatLook)
end
end)
task.delay(4.67, function()
if CFloop then CFloop:Disconnect() CFloop = nil end
isExecuting = false
hum.PlatformStand = false
head.Anchored = false
end)
end

local oldGui = PlayerGui:FindFirstChild("BlackFlashExecutor")
if oldGui then oldGui:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "BlackFlashExecutor"
sg.ResetOnSpawn = false
sg.Parent = PlayerGui

local yutaBtn = Instance.new("ImageButton")
yutaBtn.Name = "YutaButton"
yutaBtn.Parent = sg
yutaBtn.Size = UDim2.new(0, 70, 0, 70)
yutaBtn.Position = UDim2.new(0, 20, 0.5, -35)
yutaBtn.BackgroundTransparency = 1
yutaBtn.Image = BTN_IMAGE_OFF
yutaBtn.Active = true
yutaBtn.Draggable = true

local yutaIcon = Instance.new("ImageLabel")
yutaIcon.Name = "YutaIcon"
yutaIcon.Parent = yutaBtn
yutaIcon.BackgroundTransparency = 1
yutaIcon.Size = UDim2.new(0, 76, 0, 76)
yutaIcon.Position = UDim2.new(0, -2, 0, -4)
yutaIcon.Image = ICON_IMAGE
yutaIcon.ZIndex = 2

local yutaCorner = Instance.new("UICorner")
yutaCorner.CornerRadius = UDim.new(1, 0)
yutaCorner.Parent = yutaBtn

yutaBtn.MouseButton1Click:Connect(function()
if isExecuting then return end
yutaBtn.Image = BTN_IMAGE_ON
doBlackFlash()
task.delay(4.67, function()
if yutaBtn and yutaBtn.Parent then
yutaBtn.Image = BTN_IMAGE_OFF
end
end)
end)

lp.CharacterAdded:Connect(function()
isExecuting = false
if CFloop then CFloop:Disconnect() CFloop = nil end
if yutaBtn and yutaBtn.Parent then
yutaBtn.Image = BTN_IMAGE_OFF
end
end)
