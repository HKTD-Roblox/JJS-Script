local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Invisible")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local connections = {}
local platform = nil
local character, humanoid, rootPart
local originalTransparencies = {}
local fixedY = nil

local function setupCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    originalTransparencies = {}
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalTransparencies[part] = part.Transparency
        end
    end
end

local function createPlatform()
    if platform then
        platform:Destroy()
    end
    platform = Instance.new("Part")
    platform.Name = "InvisPlatform"
    platform.Size = Vector3.new(14, 1, 14)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Parent = workspace
end

local function setLocalTransparency(state)
    if not character then return end
    for part, original in pairs(originalTransparencies) do
        if part and part.Parent then
            part.Transparency = state and 0.65 or original
        end
    end
end

local function startLoop()
    if connections.Heartbeat then
        connections.Heartbeat:Disconnect()
    end
    connections.Heartbeat = RunService.Heartbeat:Connect(function()
        if enabled and character and rootPart and rootPart.Parent and humanoid then
            local realCF = rootPart.CFrame
            local oldOffset = humanoid.CameraOffset

            if not fixedY then
                fixedY = realCF.Y - 1000
            end

            local hiddenPos = Vector3.new(realCF.X, fixedY, realCF.Z)
            local hiddenCF = CFrame.new(hiddenPos) * (realCF - realCF.Position)

            if platform then
                platform.CFrame = CFrame.new(hiddenPos - Vector3.new(0, 3.5, 0))
            end

            rootPart.CFrame = hiddenCF
            humanoid.CameraOffset = hiddenCF:ToObjectSpace(CFrame.new(realCF.Position)).Position

            RunService.RenderStepped:Wait()

            if rootPart and rootPart.Parent then
                rootPart.CFrame = realCF
                humanoid.CameraOffset = oldOffset
            end
        end
    end)
end

local function stopLoop()
    if connections.Heartbeat then
        connections.Heartbeat:Disconnect()
        connections.Heartbeat = nil
    end
    if platform then
        platform:Destroy()
        platform = nil
    end
    fixedY = nil
    setLocalTransparency(false)
end

Window:AddToggle({
    text = "Invisible",
    flag = "Invisible",
    state = false,
    callback = function(value)
        enabled = value
        if value then
            setupCharacter()
            createPlatform()
            setLocalTransparency(true)
            startLoop()
        else
            stopLoop()
        end
    end,
})

Window:AddLabel({
    text = "Made by Zorcex",
})

library:Init()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupCharacter()
    if enabled then
        fixedY = nil
        createPlatform()
        setLocalTransparency(true)
        startLoop()
    end
end)

setupCharacter()
