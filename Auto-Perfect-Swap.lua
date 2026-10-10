local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local function notify(title, text, duration)
  pcall(function()
    StarterGui:SetCore("SendNotification", {
      Title = tostring(title or "Auto Perfect Swap"),
      Text = tostring(text or "SUPER OP SCRIPT!"),
      Duration = duration or 3,
    })
  end)
end

local triggerRemote = ReplicatedStorage.Knit.Knit.Services.TodoService.RE.RightActivated
local success = triggerRemote ~= nil

local oldNamecall
local busy = false

oldNamecall = hookmetamethod(
  game,
  "__namecall",
  newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

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
  end)
)

if not success then
  notify("Auto Perfect Swap", "Script loading failed!", 3)
  return
end

if success then
  notify("Auto Perfect Swap", "Script loaded successfully!", 3)
  return
end
