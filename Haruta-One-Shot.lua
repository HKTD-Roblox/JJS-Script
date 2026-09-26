_G.Multi = 40
_G.Enabled = true
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if _G.Enabled and method == "FireServer" and self.Parent == game.Players.LocalPlayer.Character then
        if typeof(args[1]) == "table" then
            local newTable = {}
            for _, v in ipairs(args[1]) do
                for i = 1, (_G.Multi or 1) do
                    table.insert(newTable, v)
                end
            end
            args[1] = newTable
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)
