game.ReplicatedStorage.Knit.Knit.Services.NanamiService.RE.Effects.OnClientEvent:Connect(function(...)
	local args = {...}
	if args[1] == "SpawnRatio" and args[2] == game.Players.LocalPlayer then
		task.wait((args[6] * 0.5676767676767676) - game.Players.LocalPlayer:GetNetworkPing())
		game.ReplicatedStorage.Knit.Knit.Services.NanamiService.RE.RightActivated:FireServer()
	end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Nanami Ratio",
    Text = "Script ",
    Duration = 5
})
