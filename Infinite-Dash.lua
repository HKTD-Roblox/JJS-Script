local oldTick = tick

local fakeTime = oldTick()

hookfunction(tick, function(...)
    fakeTime = fakeTime + 100
    return fakeTime
end)
