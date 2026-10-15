local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Emote = PlayerGui:WaitForChild("Emotes"):WaitForChild("Emote")
local Page1 = Emote:WaitForChild("Page1")
local Page2 = Emote:WaitForChild("Page2")
local Switch = Emote:WaitForChild("Switch")
local Equipped = PlayerGui:WaitForChild("Menus"):WaitForChild("Group"):WaitForChild("Inventory"):WaitForChild("Items"):WaitForChild("Emotes"):WaitForChild("Equipped")

local function show(gui)
    if gui:IsA("GuiObject") then
        gui.Visible = true
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
end

local Active = false
Page2.Visible = false
Switch.Visible = true
show(Page1)
show(Equipped)

Switch.MouseButton1Click:Connect(function()
    Active = not Active
    Page1.Visible = not Active
    Page2.Visible = Active
    if Active then show(Page2) else show(Page1) end
end)
