local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getRemote(...)
    local path = { ... }
    local ok, remote = pcall(function()
        local node = ReplicatedStorage
        for _, child in ipairs(path) do
            node = node:WaitForChild(child, 5)
        end
        return node
    end)
    return ok and remote or nil
end

local focusStrikeRemote = getRemote("Knit", "Knit", "Services", "FocusStrikeService", "RE", "Activated")

local isCooling = false
local isRetrying = false

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if getnamecallmethod() ~= "FireServer" or self ~= focusStrikeRemote then
        return oldNamecall(self, ...)
    end
    if isRetrying then
        return oldNamecall(self, ...)
    end
    if isCooling then
        return oldNamecall(self, ...)
    end
    isCooling = true
    local result = oldNamecall(self, ...)
    local args = { ... }
    task.delay(0.3, function()
        isRetrying = true
        pcall(function()
            focusStrikeRemote:FireServer(table.unpack(args))
        end)
        isRetrying = false
        task.defer(function()
            isCooling = false
        end)
    end)
    return result
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Auto Black Flash",
    Text = "Mahito Support only!",
    Duration = 3,
})
