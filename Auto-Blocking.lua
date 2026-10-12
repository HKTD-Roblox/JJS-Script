if game:GetService("CoreGui"):FindFirstChild("ToraScript") then
    game:GetService("CoreGui").ToraScript:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

_G.AutoBlockEnabled = false
_G.AutoBlockDistance = 10

local BlockService = ReplicatedStorage:WaitForChild("Knit", 8)
    :WaitForChild("Knit", 5)
    :WaitForChild("Services", 5)
    :WaitForChild("BlockService", 5)
    :WaitForChild("RE", 5)

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
    task.delay(0.5, function()
        if hum then hum.AutoRotate = true end
    end)
end

local function doBlock(enemyHrp)
    if isBlocking or not enemyHrp then return end
    isBlocking = true
    faceTarget(enemyHrp)
    blockActivated:FireServer()
    task.delay(0.5, function()
        blockDeactivated:FireServer()
        isBlocking = false
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
        for _, arg in pairs({...}) do
            if typeof(arg) == "Instance" then
                local char = arg:IsA("Model") and arg or arg:FindFirstAncestorOfClass("Model")
                if char and char ~= myChar then
                    local targetHrp = getHRP(char)
                    if targetHrp then
                        local dist = (myHrp.Position - targetHrp.Position).Magnitude
                        if dist <= (_G.AutoBlockDistance or 10) then
                            doBlock(targetHrp)
                            break
                        end
                    end
                end
            end
        end
    end)
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    hookRemote(obj)
end
ReplicatedStorage.DescendantAdded:Connect(hookRemote)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Auto Blocking")

Window:AddToggle({
    text = "Auto Blocking",
    flag = "AutoBlocking",
    state = false,
    callback = function(value)
        _G.AutoBlockEnabled = value
    end,
})

local distanceBox
distanceBox = Window:AddBox({
    text = "Distance",
    value = "10 Studs",
    callback = function(value)
        local clean = tostring(value or ""):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
        local num = clean:match("(%d+)")
        if num then
            _G.AutoBlockDistance = tonumber(num)
            local forced = num .. " Studs"
            if clean ~= forced and distanceBox then
                pcall(function()
                    if distanceBox.Set then
                        distanceBox:Set(forced)
                    elseif distanceBox.SetValue then
                        distanceBox:SetValue(forced)
                    elseif distanceBox.Value ~= nil then
                        distanceBox.Value = forced
                    end
                end)
            end
        end
    end,
})

Window:AddLabel({
    text = "Made by Zorcex",
})

library:Init()
