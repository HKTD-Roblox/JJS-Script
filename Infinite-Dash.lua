local oldTick = tick

local fakeTime = oldTick()

hookfunction(tick, function(...)
    fakeTime = fakeTime + 100
    return fakeTime
end)

setclipboard("http://dsc.gg/zorcex")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "SCRIPT LOADED!",
    Text = "COPIED DISCORD LINK\nhttp://dsc.gg/zorcex",
    Duration = 5
})
