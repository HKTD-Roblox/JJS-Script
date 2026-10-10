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

local blocking = false

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
    if blocking == state then return end
    blocking = state
    VirtualInputManager:SendKeyEvent(state, Enum.KeyCode.F, false, game)
end

local function faceTarget(character)
    local myRoot = getRoot(LocalPlayer.Character)
    local targetRoot = getRoot(character)
    if not myRoot or not targetRoot then return end

    local pos = myRoot.Position
    local targetPos = targetRoot.Position
    myRoot.CFrame = CFrame.lookAt(pos, Vector3.new(targetPos.X, pos.Y, targetPos.Z))
end

local function onAttackDetected(character, track)
    if getDistance(character) > MAX_DISTANCE then return end

    setBlock(true)
    faceTarget(character)

    local finished = false
    local conn
    conn = track.Stopped:Connect(function()
        finished = true
    end)

    if not track.IsPlaying then
        finished = true
    end

    while not finished do
        if not character.Parent or not getRoot(LocalPlayer.Character) then
            break
        end
        faceTarget(character)
        task.wait()
    end

    if conn then conn:Disconnect() end
    setBlock(false)
end

local function watchCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.AnimationPlayed:Connect(function(track)
        local animation = track.Animation
        if not animation then return end

        local id = animation.AnimationId:match("%d+")
        if not id or not ATTACK_IDS[id] then return end

        task.spawn(onAttackDetected, character, track)
    end)
end

local function watchPlayer(player)
    if player == LocalPlayer then return end

    if player.Character then
        task.spawn(watchCharacter, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        watchCharacter(character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    watchPlayer(player)
end

Players.PlayerAdded:Connect(watchPlayer)

StarterGui:SetCore("SendNotification", {
    Title = "Auto Block JJS",
    Text = "Early Block version loaded!",
    Duration = 4
})
