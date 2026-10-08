local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local JJS_Game = {
    [9391468976] = true,
    [17255146011] = true,
    [18439055812] = true,
    [17992140683] = true,
}

if not JJS_Game[game.PlaceId] then
    LocalPlayer:Kick("This is not Jujutsu Shenanigans game!")
end

local MAX_DISTANCE = 15

local ATTACK_IDS = {
    ["4571259077"] = true,
    ["8595975878"] = true,
    ["8595975458"] = true,
    ["8595974357"] = true,
}

local attackQueue = {}
local sequence = 0
local blocking = false
local processing = false

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

local function addAttack(character, track)
    if not character or not character.Parent then
        return
    end

    local distance = getDistance(character)

    if distance > MAX_DISTANCE then
        return
    end

    sequence += 1

    table.insert(attackQueue, {
        Character = character,
        Track = track,
        Distance = distance,
        Sequence = sequence
    })
end

local function sortQueue()
    table.sort(attackQueue, function(a, b)
        local aDistance = getDistance(a.Character)
        local bDistance = getDistance(b.Character)

        if math.abs(aDistance - bDistance) > 0.05 then
            return aDistance < bDistance
        end

        return a.Sequence < b.Sequence
    end)
end

local function processNext()
    if processing then
        return
    end

    processing = true

    while #attackQueue > 0 do
        sortQueue()

        local attack = table.remove(attackQueue, 1)

        if not attack then
            break
        end

        local character = attack.Character
        local track = attack.Track

        if not character
            or not character.Parent
            or not track
        then
            continue
        end

        local root = getRoot(LocalPlayer.Character)
        local targetRoot = getRoot(character)

        if not root or not targetRoot then
            continue
        end

        if getDistance(character) > MAX_DISTANCE then
            continue
        end

        local oldCFrame = root.CFrame

        faceTarget(character)
        setBlock(true)

        local finished = false

        local connection = track.Stopped:Connect(function()
            finished = true
        end)

        if not track.IsPlaying then
            finished = true
        end

        while not finished do
            if not character.Parent then
                break
            end

            if not getRoot(LocalPlayer.Character) then
                break
            end

            task.wait()
        end

        connection:Disconnect()

        setBlock(false)

        local currentRoot = getRoot(LocalPlayer.Character)

        if currentRoot and oldCFrame then
            currentRoot.CFrame = oldCFrame
        end

        task.wait()
    end

    setBlock(false)
    processing = false
end

local function watchCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        humanoid = character:WaitForChild("Humanoid", 5)
    end

    if not humanoid then
        return
    end

    humanoid.AnimationPlayed:Connect(function(track)
        local animation = track.Animation

        if not animation then
            return
        end

        local id = animation.AnimationId:match("%d+")

        if not id or not ATTACK_IDS[id] then
            return
        end

        if getDistance(character) > MAX_DISTANCE then
            return
        end

        addAttack(character, track)
        task.spawn(processNext)
    end)
end

local function watchPlayer(player)
    if player == LocalPlayer then
        return
    end

    if player.Character then
        task.spawn(function()
            watchCharacter(player.Character)
        end)
    end

    player.CharacterAdded:Connect(function(character)
        watchCharacter(character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

StarterGui:SetCore("SendNotification", {
    Title = "Auto Block JJS",
    Text = "Script loaded successfully!",
    Duration = 5,
    Button1 = "OK"
})
