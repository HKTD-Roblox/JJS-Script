local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local triggerRemote = ReplicatedStorage.Knit.Knit.Services.TodoService.RE.RightActivated

local oldNamecall
local busy = false

oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if self ~= triggerRemote or method ~= "FireServer" then
        return oldNamecall(self, ...)
    end

    local result = oldNamecall(self, unpack(args))

    if not busy then
        busy = true

        task.delay(0.5, function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            busy = false
        end)
    end

    return result
end))
