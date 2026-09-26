game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "JJS Infinite Dash",
    Text = "Loading script...",
    Duration = 2
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local dashing = false
local keys = {
    [Enum.KeyCode.A] = false,
    [Enum.KeyCode.D] = false,
    [Enum.KeyCode.S] = false,
    [Enum.KeyCode.W] = false,
    [Enum.KeyCode.Left] = false,
    [Enum.KeyCode.Right] = false,
    [Enum.KeyCode.Down] = false,
    [Enum.KeyCode.Up] = false,
}

local sideNames = {
    sidedashcd = true,
    backdashcd = true,
    sidecd = true,
    backcd = true,
    cansidedash = true,
    canbackdash = true,
    lastsidedash = true,
    lastbackdash = true,
    sidedashcooldown = true,
    backdashcooldown = true,
    sidecooldown = true,
    backcooldown = true,
}

local function isSideOrBack()
    local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local move = hum.MoveDirection
    if move.Magnitude < 0.05 then return false end
    local look = camera.CFrame.LookVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    if flatLook.Magnitude < 0.01 then return false end
    flatLook = flatLook.Unit
    local flatMove = Vector3.new(move.X, 0, move.Z)
    if flatMove.Magnitude < 0.01 then return false end
    flatMove = flatMove.Unit
    local forwardDot = flatMove:Dot(flatLook)
    return forwardDot < 0.55
end

local function getRoot()
    local char = localPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = localPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function clearCooldownObject(obj)
    if not obj then return end
    local n = string.lower(tostring(obj.Name))
    if not sideNames[n] and not string.find(n, "side") and not string.find(n, "back") then
        return
    end
    if string.find(n, "front") or string.find(n, "forward") or string.find(n, "chase") then
        return
    end
    pcall(function()
        if obj:IsA("BoolValue") then
            if string.find(n, "can") then
                obj.Value = true
            else
                obj.Value = false
            end
        elseif obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("DoubleConstrainedValue") then
            obj.Value = 0
        end
    end)
end

local function clearAttributes(inst)
    if not inst then return end
    pcall(function()
        for name, value in pairs(inst:GetAttributes()) do
            local n = string.lower(tostring(name))
            if sideNames[n] or ((string.find(n, "side") or string.find(n, "back")) and (string.find(n, "cd") or string.find(n, "cool") or string.find(n, "dash") or string.find(n, "can"))) then
                if not string.find(n, "front") and not string.find(n, "forward") then
                    if typeof(value) == "boolean" then
                        if string.find(n, "can") then
                            inst:SetAttribute(name, true)
                        else
                            inst:SetAttribute(name, false)
                        end
                    elseif typeof(value) == "number" then
                        inst:SetAttribute(name, 0)
                    end
                end
            end
        end
    end)
end

local function scanAndClear(root)
    if not root then return end
    clearAttributes(root)
    for _, d in ipairs(root:GetDescendants()) do
        clearCooldownObject(d)
        clearAttributes(d)
    end
end

local function tryGetgcClear()
    if not getgc then return end
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if type(v) == "table" then
                local ok, hasSide = pcall(function()
                    return v.SideDashCD ~= nil or v.BackDashCD ~= nil or v.SideCD ~= nil or v.BackCD ~= nil
                end)
                if ok and hasSide then
                    pcall(function()
                        if v.SideDashCD ~= nil then v.SideDashCD = false end
                        if v.BackDashCD ~= nil then v.BackDashCD = false end
                        if v.CanSideDash ~= nil then v.CanSideDash = true end
                        if v.CanBackDash ~= nil then v.CanBackDash = true end
                        if v.LastSideDash ~= nil then v.LastSideDash = 0 end
                        if v.LastBackDash ~= nil then v.LastBackDash = 0 end
                    end)
                end
            end
        end
    end)
end

local function applySideBackVelocity()
    if dashing then return end
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    if not isSideOrBack() then return end
    dashing = true
    local move = hum.MoveDirection
    local flat = Vector3.new(move.X, 0, move.Z)
    if flat.Magnitude < 0.05 then
        dashing = false
        return
    end
    flat = flat.Unit
    local speed = 92
    local duration = 0.22
    local att = Instance.new("Attachment")
    att.Parent = root
    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = att
    lv.MaxForce = 1e6
    lv.VectorVelocity = flat * speed
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = root
    task.delay(duration, function()
        if lv then lv:Destroy() end
        if att then att:Destroy() end
        dashing = false
    end)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if keys[input.KeyCode] ~= nil then
        keys[input.KeyCode] = true
    end
    if input.KeyCode == Enum.KeyCode.Q then
        if isSideOrBack() then
            applySideBackVelocity()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if keys[input.KeyCode] ~= nil then
        keys[input.KeyCode] = false
    end
end)

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if char then
        scanAndClear(char)
        clearAttributes(localPlayer)
    end
    tryGetgcClear()
    local hum = getHum()
    if hum and hum.MoveDirection.Magnitude > 0.1 and isSideOrBack() then
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            applySideBackVelocity()
        end
    end
end)

localPlayer.CharacterAdded:Connect(function(char)
    dashing = false
    task.wait(0.5)
    scanAndClear(char)
end)

if hookmetamethod and getnamecallmethod then
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local name = string.lower(tostring(self.Name))
            if string.find(name, "dash") or string.find(name, "chase") or string.find(name, "side") or string.find(name, "back") then
                task.defer(function()
                    local char = localPlayer.Character
                    if char then scanAndClear(char) end
                    tryGetgcClear()
                end)
            end
        end
        return old(self, ...)
    end)
end

task.wait(2)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "JJS Infinite Dash",
    Text = "Script loaded successfully!",
    Duration = 3
})
