local oldTick = tick

local fakeTime = oldTick()

hookfunction(tick, function(...)
    fakeTime = fakeTime + 100
    return fakeTime
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Infinite Dash",
    Text = "Script loaded successfully!",
    Duration = 5
})
