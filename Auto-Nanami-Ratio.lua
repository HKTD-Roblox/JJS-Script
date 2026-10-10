local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Service = ReplicatedStorage.Knit.Knit.Services.NanamiService
local Active = true

Service.RE.Effects.OnClientEvent:Connect(function(...)
    local args = {...}
    if not Active or args[1] ~= "SpawnRatio" or args[2] ~= Player then return end

    local value = tonumber(args[6])
    if not value then return end

    local delayTime = math.max(0, value * 0.5676767676767676 - Player:GetNetworkPing())
    delayTime = math.max(0, delayTime + math.random(-3, 3) / 1000)

    task.delay(delayTime, function()
        if Active then
            Service.RE.RightActivated:FireServer()
        end
    end)
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Nanami Ratio",
    Text = "Script loaded successfully!",
    Duration = 5
})
