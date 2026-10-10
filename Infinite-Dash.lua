local oldTick = tick

local fakeTime = oldTick()

hookfunction(tick, function(...)
    fakeTime = fakeTime + 100
    return fakeTime
end)

setclipboard("http://dsc.gg/zorcex")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Infinite Dash",
    Text = "Copied Discord link:\nhttp://dsc.gg/zorcex",
    Duration = 5
})
