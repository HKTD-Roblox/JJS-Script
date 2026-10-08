local JJS_Game = {
    [9391468976] = true,
    [17255146011] = true,
    [18439055812] = true,
    [17992140683] = true,
}

if not JJS_Game[game.PlaceId] then
    Players.LocalPlayer:Kick("This is not Jujutsu Shenanigans game!")
end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local SWING_ID = "4571259077"

local M1_IDS = {
    ["8595975878"] = true,
    ["8595975458"] = true,
    ["8595974357"] = true
}

local MAX_DISTANCE = 15

local queue = {}
local queued = {}
local currentTarget = nil
local blocking = false
local oldCFrame = nil

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getDistance(character)
    local myRoot = getRoot(LocalPlayer.Character)
    local targetRoot = getRoot(character)

    if not myRoot or not targetRoot then
        return math.huge
    end

    return (myRoot.Position - targetRoot.Position).Magnitude
end

local function setBlock(state)
    if blocking == state then
        return
    end

    blocking = state

    VirtualInputManager:SendKeyEvent(
        state,
        Enum.KeyCode.F,
        false,
        game
    )
end

local function faceTarget(character)
    local myRoot = getRoot(LocalPlayer.Character)
    local targetRoot = getRoot(character)

    if not myRoot or not targetRoot then
        return
    end

    local position = myRoot.Position
    local targetPosition = targetRoot.Position

    myRoot.CFrame = CFrame.lookAt(
        position,
        Vector3.new(
            targetPosition.X,
            position.Y,
            targetPosition.Z
        )
    )
end

local function addToQueue(character)
    if queued[character] then
        return
    end

    if getDistance(character) > MAX_DISTANCE then
        return
    end

    queued[character] = true
    table.insert(queue, character)
end

local function removeFromQueue(character)
    queued[character] = nil

    for i = #queue, 1, -1 do
        if queue[i] == character then
            table.remove(queue, i)
        end
    end
end

local processNext

processNext = function()
    if currentTarget then
        return
    end

    while #queue > 0 do
        local character = table.remove(queue, 1)
        queued[character] = nil

        if character
            and character.Parent
            and getRoot(character)
            and getDistance(character) <= MAX_DISTANCE then

            currentTarget = character

            local myRoot = getRoot(LocalPlayer.Character)

            if not myRoot then
                currentTarget = nil
                processNext()
                return
            end

            oldCFrame = myRoot.CFrame

            faceTarget(character)
            setBlock(true)

            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if not humanoid then
                setBlock(false)
                currentTarget = nil
                processNext()
                return
            end

            local finished = false
            local connection

            connection = humanoid.AnimationPlayed:Connect(function(track)
                local animation = track.Animation

                if not animation then
                    return
                end

                local id = animation.AnimationId:match("%d+")

                if not id or not M1_IDS[id] then
                    return
                end

                if finished then
                    return
                end

                finished = true

                track.Stopped:Wait()

                if connection then
                    connection:Disconnect()
                    connection = nil
                end

                setBlock(false)

                local root = getRoot(LocalPlayer.Character)

                if root and oldCFrame then
                    root.CFrame = oldCFrame
                end

                currentTarget = nil
                oldCFrame = nil

                processNext()
            end)

            task.spawn(function()
                while currentTarget == character and not finished do
                    if getDistance(character) > MAX_DISTANCE then
                        finished = true

                        if connection then
                            connection:Disconnect()
                            connection = nil
                        end

                        setBlock(false)

                        local root = getRoot(LocalPlayer.Character)

                        if root and oldCFrame then
                            root.CFrame = oldCFrame
                        end

                        currentTarget = nil
                        oldCFrame = nil

                        processNext()

                        return
                    end

                    task.wait()
                end
            end)

            return
        end
    end
end

local function watchCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    humanoid.AnimationPlayed:Connect(function(track)
        local animation = track.Animation

        if not animation then
            return
        end

        local id = animation.AnimationId:match("%d+")

        if id ~= SWING_ID then
            return
        end

        if getDistance(character) > MAX_DISTANCE then
            return
        end

        addToQueue(character)
        processNext()
    end)
end

local function watchPlayer(player)
    if player == LocalPlayer then
        return
    end

    if player.Character then
        watchCharacter(player.Character)
    end

    player.CharacterAdded:Connect(watchCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

Players.PlayerAdded:Connect(watchPlayer)

StarterGui:SetCore("SendNotification", {
    Title = "Auto Block JJS",
    Text = "Script loaded successfully!",
    Duration = 2
})
