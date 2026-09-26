local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("ToraScript") then
    CoreGui.ToraScript:Destroy()
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = library:CreateWindow("JJS Invisible")

local invisibleOn = false
local keepConnection = nil
local saved = {}

local FADE = -0.4

local function getCharacter()
    return localPlayer.Character
end

local function saveAndHide(inst)
    if not inst or saved[inst] then
        return
    end
    if inst:IsA("BasePart") then
        if inst.Name == "HumanoidRootPart" then
            saved[inst] = {
                kind = "hrp",
                Transparency = inst.Transparency,
                LocalTransparencyModifier = inst.LocalTransparencyModifier,
                CastShadow = inst.CastShadow,
            }
            inst.Transparency = 1
            inst.LocalTransparencyModifier = 0
            inst.CastShadow = false
        else
            saved[inst] = {
                kind = "part",
                Transparency = inst.Transparency,
                LocalTransparencyModifier = inst.LocalTransparencyModifier,
                CastShadow = inst.CastShadow,
            }
            inst.Transparency = 1
            inst.LocalTransparencyModifier = FADE
            inst.CastShadow = false
        end
    elseif inst:IsA("Decal") or inst:IsA("Texture") then
        saved[inst] = {
            kind = "decal",
            Transparency = inst.Transparency,
        }
        inst.Transparency = 1
    elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
        saved[inst] = {
            kind = "fx",
            Enabled = inst.Enabled,
        }
        inst.Enabled = false
    elseif inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") then
        saved[inst] = { kind = "clothing" }
    end
end

local function applyInvisible(character)
    if not character then
        return
    end
    for _, inst in ipairs(character:GetDescendants()) do
        saveAndHide(inst)
    end
    local head = character:FindFirstChild("Head")
    if head then
        local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
        if face then
            saveAndHide(face)
        end
    end
end

local function restoreInvisible()
    for inst, data in pairs(saved) do
        if inst and inst.Parent then
            pcall(function()
                if data.kind == "part" or data.kind == "hrp" then
                    inst.Transparency = data.Transparency
                    inst.LocalTransparencyModifier = data.LocalTransparencyModifier
                    inst.CastShadow = data.CastShadow
                elseif data.kind == "decal" then
                    inst.Transparency = data.Transparency
                elseif data.kind == "fx" then
                    inst.Enabled = data.Enabled
                end
            end)
        end
    end
    table.clear(saved)
end

local function maintainInvisible()
    local character = getCharacter()
    if not character then
        return
    end
    for _, inst in ipairs(character:GetDescendants()) do
        if inst:IsA("BasePart") then
            if inst.Name == "HumanoidRootPart" then
                if inst.Transparency < 1 then
                    inst.Transparency = 1
                end
                inst.LocalTransparencyModifier = 0
                inst.CastShadow = false
            else
                if inst.Transparency < 1 then
                    inst.Transparency = 1
                end
                if inst.LocalTransparencyModifier > FADE + 0.05 or inst.LocalTransparencyModifier < FADE - 0.05 then
                    inst.LocalTransparencyModifier = FADE
                end
                inst.CastShadow = false
            end
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            if inst.Transparency < 1 then
                inst.Transparency = 1
            end
        elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
            if inst.Enabled then
                inst.Enabled = false
            end
        end
        if not saved[inst] then
            saveAndHide(inst)
        end
    end
end

local function setInvisible(state)
    invisibleOn = state
    if keepConnection then
        keepConnection:Disconnect()
        keepConnection = nil
    end
    if state then
        applyInvisible(getCharacter())
        keepConnection = RunService.RenderStepped:Connect(function()
            if not invisibleOn then
                return
            end
            maintainInvisible()
        end)
    else
        restoreInvisible()
    end
end

Window:AddToggle({
    text = "Invisible",
    flag = "invisible",
    state = false,
    callback = function(state)
        setInvisible(state)
    end,
})

Window:AddLabel({
    text = "Make by HKTD Roblox",
})

library:Init()

localPlayer.CharacterAdded:Connect(function(character)
    table.clear(saved)
    if invisibleOn then
        task.wait(0.35)
        if invisibleOn then
            applyInvisible(character)
        end
    end
end)
