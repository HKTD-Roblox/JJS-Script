game.ReplicatedStorage.Knit.Knit.Services.NanamiService.RE.Effects.OnClientEvent:Connect(function(...)
local args = {...}
if args[1] == "SpawnRatio" and args[2] == game.Players.LocalPlayer then
task.wait((args[6]*0.56767676767676769420)-game.Players.LocalPlayer:GetNetworkPing())
game:GetService("ReplicatedStorage").Knit.Knit.Services.NanamiService.RE.RightActivated:FireServer()
end
end)
