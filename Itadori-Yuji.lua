local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("Itadori Yuji")

if game.PlaceId ~= 9391468976 then
    LocalPlayer:Kick("This script only works in Jujutsu Shenanigans")
    return
end

Window:AddToggle({
    text = "Auto Black Flash",
    flag = "",
    callback = function(value)
        
})

Window:AddToggle({
    text = "Auto Counter [Beta]",
    flag = "",
    callback = function(value)
        
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()
