local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local BlockService = ReplicatedStorage:WaitForChild("Knit", 5):WaitForChild("Knit", 5):WaitForChild("Services", 5):WaitForChild("BlockService", 5):WaitForChild("RE", 5)
local blockActivated = BlockService:WaitForChild("Activated", 5)
local blockDeactivated = BlockService:WaitForChild("Deactivated", 5)

local isBlocking = false

local function getHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function faceTarget(targetHrp)
    local char = LocalPlayer.Character
    local myHrp = getHRP(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not myHrp or not targetHrp then return end
    if hum then hum.AutoRotate = false end

    local targetPos = Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z)
    myHrp.CFrame = CFrame.lookAt(myHrp.Position, targetPos)

    task.delay(0.4, function()
        if hum then hum.AutoRotate = true end
    end)
end

local function hookRemote(remote)
    if not remote:IsA("RemoteEvent") then return end
    if remote == blockActivated or remote == blockDeactivated then return end

    if remote.Name:lower():find("emote") then return end

    remote.OnClientEvent:Connect(function(...)
        if not _G.AutoBlockEnabled or isBlocking then return end

        local myChar = LocalPlayer.Character
        local myHrp = getHRP(myChar)
        if not myHrp then return end

        local enemyHrp = nil
        for _, arg in pairs({...}) do
            if typeof(arg) == "Instance" then
                local char = arg:IsA("Model") and arg or arg:FindFirstAncestorOfClass("Model")
                
                if char and char ~= myChar then
                    local targetHrp = getHRP(char)
                    if targetHrp then
                        local dist = (myHrp.Position - targetHrp.Position).Magnitude
                        if dist <= (_G.AutoBlockDistance or 20) then
                            enemyHrp = targetHrp
                            break
                        end
                    end
                end
            end
        end

        if enemyHrp then
            isBlocking = true
            faceTarget(enemyHrp)
            blockActivated:FireServer()

            task.delay(0.4, function()
                blockDeactivated:FireServer()
                isBlocking = false
            end)
        end
    end)
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    hookRemote(obj)
end
ReplicatedStorage.DescendantAdded:Connect(hookRemote)
