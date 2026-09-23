local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────────────────────────────────
--  CONFIG
-- ──────────────────────────────────────────────
local CONFIG = {
    Delay_AfterPebble = 1,
    Delay_AfterRight  = 0,
    Delay_AfterBrute1 = 0.60,
    ToggleKey         = Enum.KeyCode.RightShift,
}

-- ──────────────────────────────────────────────
--  DETECT MOBILE
-- ──────────────────────────────────────────────
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ──────────────────────────────────────────────
--  GUI
-- ──────────────────────────────────────────────
local function createGUI()
    local old = LocalPlayer.PlayerGui:FindFirstChild("TodoBFGui")
    if old then old:Destroy() end

    local screenGui            = Instance.new("ScreenGui")
    screenGui.Name             = "TodoBFGui"
    screenGui.ResetOnSpawn     = false
    screenGui.IgnoreGuiInset   = true
    screenGui.Parent           = LocalPlayer.PlayerGui

    -- ── Status Bar (top center) ──
    local bar             = Instance.new("Frame")
    bar.Name              = "StatusBar"
    bar.Size              = UDim2.new(0, 220, 0, 44)
    bar.Position          = UDim2.new(0.5, -110, 0, 20)
    bar.BackgroundColor3  = Color3.fromRGB(18, 18, 18)
    bar.BorderSizePixel   = 0
    bar.Parent            = screenGui
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    local stroke          = Instance.new("UIStroke")
    stroke.Thickness      = 1.5
    stroke.Color          = Color3.fromRGB(60, 60, 60)
    stroke.Parent         = bar

    local dot             = Instance.new("Frame")
    dot.Size              = UDim2.new(0, 10, 0, 10)
    dot.Position          = UDim2.new(0, 14, 0.5, -5)
    dot.BackgroundColor3  = Color3.fromRGB(80, 80, 80)
    dot.BorderSizePixel   = 0
    dot.Parent            = bar
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local label           = Instance.new("TextLabel")
    label.Size            = UDim2.new(1, -34, 1, 0)
    label.Position        = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Font            = Enum.Font.GothamBold
    label.TextSize        = 13
    label.TextColor3      = Color3.fromRGB(140, 140, 140)
    label.TextXAlignment  = Enum.TextXAlignment.Left
    label.Text            = "Todo Black Flash  [OFF]"
    label.Parent          = bar

    -- ── Mobile Toggle Button (bottom left) ──
    local btn = nil
    if isMobile then
        btn                      = Instance.new("TextButton")
        btn.Name                 = "MobileToggle"
        btn.Size                 = UDim2.new(0, 80, 0, 80)
        btn.Position             = UDim2.new(0, 24, 1, -110)
        btn.BackgroundColor3     = Color3.fromRGB(18, 18, 18)
        btn.BorderSizePixel      = 0
        btn.Font                 = Enum.Font.GothamBold
        btn.TextSize             = 11
        btn.TextColor3           = Color3.fromRGB(140, 140, 140)
        btn.Text                 = "TODO\nBLACK\nFLASH"
        btn.AutoButtonColor      = false
        btn.Parent               = screenGui

        local btnCorner          = Instance.new("UICorner")
        btnCorner.CornerRadius   = UDim.new(1, 0)   -- วงกลม
        btnCorner.Parent         = btn

        local btnStroke          = Instance.new("UIStroke")
        btnStroke.Name           = "BtnStroke"
        btnStroke.Thickness      = 2
        btnStroke.Color          = Color3.fromRGB(60, 60, 60)
        btnStroke.Parent         = btn
    end

    return dot, label, stroke, btn
end

local dot, label, stroke, mobileBtn = createGUI()

-- ──────────────────────────────────────────────
--  GUI UPDATE
-- ──────────────────────────────────────────────
local function setGUI(enabled)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

    if enabled then
        TweenService:Create(dot,    tweenInfo, { BackgroundColor3 = Color3.fromRGB(80, 220, 100) }):Play()
        TweenService:Create(stroke, tweenInfo, { Color            = Color3.fromRGB(80, 220, 100) }):Play()
        label.Text       = "Todo Black Flash  [ON]"
        label.TextColor3 = Color3.fromRGB(230, 230, 230)

        if mobileBtn then
            local btnStroke = mobileBtn:FindFirstChild("BtnStroke")
            TweenService:Create(mobileBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(25, 50, 25) }):Play()
            if btnStroke then
                TweenService:Create(btnStroke, tweenInfo, { Color = Color3.fromRGB(80, 220, 100) }):Play()
            end
            mobileBtn.TextColor3 = Color3.fromRGB(80, 220, 100)
        end
    else
        TweenService:Create(dot,    tweenInfo, { BackgroundColor3 = Color3.fromRGB(80, 80, 80) }):Play()
        TweenService:Create(stroke, tweenInfo, { Color            = Color3.fromRGB(60, 60, 60) }):Play()
        label.Text       = "Todo Black Flash  [OFF]"
        label.TextColor3 = Color3.fromRGB(140, 140, 140)

        if mobileBtn then
            local btnStroke = mobileBtn:FindFirstChild("BtnStroke")
            TweenService:Create(mobileBtn, tweenInfo, { BackgroundColor3 = Color3.fromRGB(18, 18, 18) }):Play()
            if btnStroke then
                TweenService:Create(btnStroke, tweenInfo, { Color = Color3.fromRGB(60, 60, 60) }):Play()
            end
            mobileBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
end

-- ──────────────────────────────────────────────
--  REMOTE HELPER
-- ──────────────────────────────────────────────
local function getRemote(...)
    local path = { ... }
    local ok, result = pcall(function()
        local node = ReplicatedStorage
        for _, name in ipairs(path) do
            node = node:WaitForChild(name, 5)
        end
        return node
    end)
    return ok and result or nil
end

-- ──────────────────────────────────────────────
--  REMOTES
-- ──────────────────────────────────────────────
local PebbleThrowRemote = getRemote("Knit","Knit","Services","PebbleThrowService","RE","Activated")
local RightActivated    = getRemote("Knit","Knit","Services","TodoService","RE","RightActivated")
local BruteForceRemote  = getRemote("Knit","Knit","Services","BruteForceService","RE","Activated")

if not PebbleThrowRemote then warn("[TodoBlackFlash] Not found PebbleThrowService Remote!") return end
if not RightActivated    then warn("[TodoBlackFlash] Not found TodoService RightActivated!")  return end
if not BruteForceRemote  then warn("[TodoBlackFlash] Not found BruteForceService Remote!")    return end

-- ──────────────────────────────────────────────
--  MOVESET HELPER
-- ──────────────────────────────────────────────
local function getMovesetItem(name)
    local char = LocalPlayer.Character
    if not char then return nil end
    local moveset = char:FindFirstChild("Moveset")
    if not moveset then return nil end
    return moveset:FindFirstChild(name)
end

-- ──────────────────────────────────────────────
--  COMBO EXECUTOR
-- ──────────────────────────────────────────────
local isEnabled      = false
local isComboRunning = false

local function runCombo()
    if isComboRunning then return end
    isComboRunning = true

    task.delay(CONFIG.Delay_AfterPebble, function()
        if not isEnabled then isComboRunning = false return end

        pcall(function() RightActivated:FireServer() end)
        print("[TodoBlackFlash] → RightActivated")

        task.delay(CONFIG.Delay_AfterRight, function()
            if not isEnabled then isComboRunning = false return end

            local bruteArg = getMovesetItem("Brute Force")
            if bruteArg then
                pcall(function() BruteForceRemote:FireServer(bruteArg) end)
                print("[TodoBlackFlash] → BruteForce #1")
            else
                warn("[TodoBlackFlash] Not found 'Brute Force' ใน Moveset")
            end

            task.delay(CONFIG.Delay_AfterBrute1, function()
                if not isEnabled then isComboRunning = false return end

                local bruteArg2 = getMovesetItem("Brute Force")
                if bruteArg2 then
                    pcall(function() BruteForceRemote:FireServer(bruteArg2) end)
                    print("[TodoBlackFlash] → BruteForce #2")
                else
                    warn("[TodoBlackFlash] Not found 'Brute Force' ใน Moveset (รอบ 2)")
                end

                task.defer(function() isComboRunning = false end)
                print("[TodoBlackFlash] Combo End!")
            end)
        end)
    end)
end

-- ──────────────────────────────────────────────
--  HOOK
-- ──────────────────────────────────────────────
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if method == "FireServer" and self == PebbleThrowRemote then
        local result = oldNamecall(self, ...)
        if isEnabled then task.spawn(runCombo) end
        return result
    end

    return oldNamecall(self, ...)
end)

-- ──────────────────────────────────────────────
--  TOGGLE LOGIC
-- ──────────────────────────────────────────────
local function toggle()
    isEnabled = not isEnabled
    setGUI(isEnabled)
    print("[TodoBlackFlash]", isEnabled and "True ✓" or "False ✗")
end

-- PC — RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.ToggleKey then toggle() end
end)

-- Mobile
if mobileBtn then
    mobileBtn.MouseButton1Click:Connect(toggle)
end

-- ──────────────────────────────────────────────
--  INIT
-- ──────────────────────────────────────────────
setGUI(false)
print(string.format(
    "[TodoBlackFlash] Loaded! (%s) | Toggle: %s | Pebble→Right: %.2fs | Right→Brute1: %.2fs | Brute1→Brute2: %.2fs",
    isMobile and "Mobile" or "PC",
    isMobile and "Bottom left button" or CONFIG.ToggleKey.Name,
    CONFIG.Delay_AfterPebble, CONFIG.Delay_AfterRight, CONFIG.Delay_AfterBrute1
))
