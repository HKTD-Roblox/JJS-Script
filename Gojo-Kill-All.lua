-- ============================================
-- GOJO 0.2 KILL ALL HUB | by GESI YT
-- Key System + Library original com cores azuis (via gsub)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================
-- CONFIG
-- ============================================
local API_URL = "https://script.google.com/macros/s/AKfycby_8smGs_VD7Mk1Mi1f01vzJTrJzn9jyGawQ1RQ9vm5I6g3Dmb8slro3kCEUW0wuTKE/exec"
local SITE_URL = "https://systemkey-gesiscriptadm.netlify.app/"
local KEY_FILE = "gesi_gojo_key.txt"
local IMAGEM_BOTAO = "rbxassetid://90690760116376"

local KEY_VALIDADA = false
local PAINEL_CRIADO = false

local C = {
    Fundo       = Color3.fromRGB(0, 0, 0),
    FundoRow    = Color3.fromRGB(10, 12, 20),
    Borda       = Color3.fromRGB(0, 170, 255),
    BordaGlow   = Color3.fromRGB(80, 200, 255),
    BordaSub    = Color3.fromRGB(0, 90, 160),
    Texto       = Color3.fromRGB(220, 240, 255),
    TextoSub    = Color3.fromRGB(120, 180, 230),
    BotaoOff    = Color3.fromRGB(15, 20, 35),
    BotaoOn     = Color3.fromRGB(0, 140, 255),
    KnobOff     = Color3.fromRGB(120, 180, 230),
    KnobOn      = Color3.fromRGB(255, 255, 255),
    Scrollbar   = Color3.fromRGB(0, 120, 200),
    verde       = Color3.fromRGB(80, 255, 120),
    vermelho    = Color3.fromRGB(200, 40, 60),
    amarelo     = Color3.fromRGB(255, 200, 100),
}

-- ============================================
-- HWID
-- ============================================
local function getHWID()
    local data = tostring(LP.UserId) .. "|" .. game.PlaceId .. "|GOJO"
    local hash = 0
    for i = 1, #data do
        hash = bit32.bxor(bit32.lshift(hash, 5) - hash, data:byte(i))
        hash = bit32.band(hash, 0xFFFFFFFF)
    end
    return "HW-" .. string.upper(string.format("%x", hash))
end

-- ============================================
-- VALIDAR / SALVAR
-- ============================================
local function validarKey(key)
    local pattern = "^GESI%-[A-Z2-9][A-Z2-9][A-Z2-9][A-Z2-9]%-[A-Z2-9][A-Z2-9][A-Z2-9][A-Z2-9]%-[A-Z2-9][A-Z2-9][A-Z2-9][A-Z2-9]$"
    if not string.match(key, pattern) then
        return false, "Formato invĂ¡lido"
    end

    local url = API_URL .. "?acao=validar&chave=" .. key .. "&hwid=" .. getHWID()
    local ok, resposta = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not resposta or resposta == "" then
        return false, "Erro de conexĂ£o"
    end

    local okJ, dados = pcall(function()
        return HttpService:JSONDecode(resposta)
    end)

    if not okJ or type(dados) ~= "table" then
        return false, "Resposta invĂ¡lida"
    end

    if dados.ok == true then
        return true
    end

    return false, dados.msg or "Key invĂ¡lida"
end

local function salvarKey(key)
    pcall(function()
        if writefile then writefile(KEY_FILE, key) end
    end)
end

local function lerKeySalva()
    local ok, key = pcall(function()
        if isfile and isfile(KEY_FILE) and readfile then
            return readfile(KEY_FILE)
        end
    end)
    if ok and key and key ~= "" then return key end
    return nil
end

-- ============================================
-- TELA DE KEY (azul Gojo)
-- ============================================
local ScreenGuiKey = Instance.new("ScreenGui")
ScreenGuiKey.Name = "GojoKey"
ScreenGuiKey.ResetOnSpawn = false
ScreenGuiKey.IgnoreGuiInset = true
ScreenGuiKey.DisplayOrder = 99999
ScreenGuiKey.Parent = LP:WaitForChild("PlayerGui")

local Fundo = Instance.new("Frame")
Fundo.Size = UDim2.new(1, 0, 1, 0)
Fundo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Fundo.BackgroundTransparency = 0.4
Fundo.BorderSizePixel = 0
Fundo.Parent = ScreenGuiKey

local PainelKey = Instance.new("Frame")
PainelKey.Size = UDim2.new(0, 340, 0, 300)
PainelKey.Position = UDim2.new(0.5, -170, 0.5, -150)
PainelKey.BackgroundColor3 = C.Fundo
PainelKey.BorderSizePixel = 0
PainelKey.Active = true
PainelKey.Draggable = true
PainelKey.Parent = ScreenGuiKey

local cantoKey = Instance.new("UICorner")
cantoKey.CornerRadius = UDim.new(0, 16)
cantoKey.Parent = PainelKey

local bordaKey = Instance.new("UIStroke")
bordaKey.Color = C.Borda
bordaKey.Thickness = 2
bordaKey.Parent = PainelKey

local TituloKey = Instance.new("TextLabel")
TituloKey.Size = UDim2.new(1, 0, 0, 35)
TituloKey.Position = UDim2.new(0, 0, 0, 18)
TituloKey.BackgroundTransparency = 1
TituloKey.Text = "GOJO 0.2 KILL ALL HUB"
TituloKey.TextColor3 = C.BordaGlow
TituloKey.TextSize = 18
TituloKey.Font = Enum.Font.GothamBold
TituloKey.Parent = PainelKey

local SubKey = Instance.new("TextLabel")
SubKey.Size = UDim2.new(1, 0, 0, 18)
SubKey.Position = UDim2.new(0, 0, 0, 52)
SubKey.BackgroundTransparency = 1
SubKey.Text = "Sistema de Chave"
SubKey.TextColor3 = C.TextoSub
SubKey.TextSize = 13
SubKey.Font = Enum.Font.Gotham
SubKey.Parent = PainelKey

local MarcaKey = Instance.new("TextLabel")
MarcaKey.Size = UDim2.new(1, 0, 0, 14)
MarcaKey.Position = UDim2.new(0, 0, 0, 68)
MarcaKey.BackgroundTransparency = 1
MarcaKey.Text = "| GESI YT |"
MarcaKey.TextColor3 = C.Borda
MarcaKey.TextSize = 11
MarcaKey.Font = Enum.Font.GothamBold
MarcaKey.Parent = PainelKey

local LinhaKey = Instance.new("Frame")
LinhaKey.Size = UDim2.new(1, -40, 0, 1)
LinhaKey.Position = UDim2.new(0, 20, 0, 88)
LinhaKey.BackgroundColor3 = C.BordaSub
LinhaKey.BorderSizePixel = 0
LinhaKey.Parent = PainelKey

local InputKey = Instance.new("TextBox")
InputKey.Size = UDim2.new(1, -40, 0, 44)
InputKey.Position = UDim2.new(0, 20, 0, 105)
InputKey.BackgroundColor3 = C.FundoRow
InputKey.BorderSizePixel = 0
InputKey.Text = ""
InputKey.PlaceholderText = "GESI-XXXX-XXXX-XXXX"
InputKey.PlaceholderColor3 = C.TextoSub
InputKey.TextColor3 = C.Texto
InputKey.TextSize = 14
InputKey.Font = Enum.Font.Code
InputKey.ClearTextOnFocus = false
InputKey.Parent = PainelKey

local cantoInput = Instance.new("UICorner")
cantoInput.CornerRadius = UDim.new(0, 10)
cantoInput.Parent = InputKey

local strokeInput = Instance.new("UIStroke")
strokeInput.Color = C.BordaSub
strokeInput.Thickness = 1.5
strokeInput.Parent = InputKey

local BtnValidar = Instance.new("TextButton")
BtnValidar.Size = UDim2.new(1, -40, 0, 44)
BtnValidar.Position = UDim2.new(0, 20, 0, 162)
BtnValidar.BackgroundColor3 = C.Borda
BtnValidar.BorderSizePixel = 0
BtnValidar.Text = "VALIDAR"
BtnValidar.TextColor3 = C.Texto
BtnValidar.TextSize = 15
BtnValidar.Font = Enum.Font.GothamBold
BtnValidar.AutoButtonColor = false
BtnValidar.Parent = PainelKey

local cantoBtnKey = Instance.new("UICorner")
cantoBtnKey.CornerRadius = UDim.new(0, 10)
cantoBtnKey.Parent = BtnValidar

local strokeBtnKey = Instance.new("UIStroke")
strokeBtnKey.Color = C.BordaGlow
strokeBtnKey.Thickness = 1.5
strokeBtnKey.Parent = BtnValidar

local BtnLink = Instance.new("TextButton")
BtnLink.Size = UDim2.new(1, -40, 0, 36)
BtnLink.Position = UDim2.new(0, 20, 0, 216)
BtnLink.BackgroundColor3 = C.FundoRow
BtnLink.BorderSizePixel = 0
BtnLink.Text = "Pegar Key (Get Key)"
BtnLink.TextColor3 = C.BordaGlow
BtnLink.TextSize = 13
BtnLink.Font = Enum.Font.GothamBold
BtnLink.AutoButtonColor = false
BtnLink.Parent = PainelKey

local cantoBtnLink = Instance.new("UICorner")
cantoBtnLink.CornerRadius = UDim.new(0, 10)
cantoBtnLink.Parent = BtnLink

local strokeBtnLink = Instance.new("UIStroke")
strokeBtnLink.Color = C.BordaSub
strokeBtnLink.Thickness = 1.5
strokeBtnLink.Parent = BtnLink

local StatusKey = Instance.new("TextLabel")
StatusKey.Size = UDim2.new(1, -40, 0, 20)
StatusKey.Position = UDim2.new(0, 20, 1, -25)
StatusKey.BackgroundTransparency = 1
StatusKey.Text = ""
StatusKey.TextColor3 = C.TextoSub
StatusKey.TextSize = 12
StatusKey.Font = Enum.Font.Gotham
StatusKey.Parent = PainelKey

-- ============================================
-- LĂ“GICA DA KEY
-- ============================================
local function mostrarStatus(texto, cor)
    StatusKey.Text = texto
    StatusKey.TextColor3 = cor
end

local function liberarPainel()
    if not KEY_VALIDADA then return end

    TweenService:Create(PainelKey, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    TweenService:Create(Fundo, TweenInfo.new(0.35), {
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.35)
    ScreenGuiKey:Destroy()

    if PAINEL_CRIADO then return end
    PAINEL_CRIADO = true

    if _G.MostrarPainel then
        _G.MostrarPainel()
    end
end

local function tentarValidar(key)
    if key == "" then
        mostrarStatus("Digite uma key", C.amarelo)
        return
    end
    mostrarStatus("Validando...", C.amarelo)
    BtnValidar.Text = "VALIDANDO..."
    BtnValidar.BackgroundColor3 = C.BordaSub
    local sucesso, msg = validarKey(key)
    if sucesso then
        KEY_VALIDADA = true
        mostrarStatus("Key vĂ¡lida!", C.verde)
        BtnValidar.Text = "OK"
        BtnValidar.BackgroundColor3 = C.verde
        salvarKey(key)
        task.wait(1.2)
        liberarPainel()
    else
        mostrarStatus(msg, C.vermelho)
        BtnValidar.Text = "VALIDAR"
        BtnValidar.BackgroundColor3 = C.Borda
    end
end

BtnValidar.MouseButton1Click:Connect(function()
    tentarValidar(InputKey.Text)
end)

InputKey.FocusLost:Connect(function(enter)
    if enter then
        tentarValidar(InputKey.Text)
    end
end)

BtnLink.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(SITE_URL) end
    end)
    BtnLink.Text = "Copiado!"
    task.wait(1.5)
    BtnLink.Text = "Pegar Key (Get Key)"
end)

-- ============================================
-- PAINEL GOJO
-- ============================================
_G.MostrarPainel = function()
    if not KEY_VALIDADA then return end

    local pg = LP:WaitForChild("PlayerGui")

    -- â¡ Carrega Library original e aplica gsub nas cores
    local libCode = game:HttpGet("https://pastefy.app/g3niwpJt/raw")

    -- Substitui cores originais (roxo/cinza) pelas do Gojo (preto/azul)
    libCode = libCode:gsub("Color3%.fromRGB%(18,%s*18,%s*18%)", "Color3.fromRGB(0,0,0)")
    libCode = libCode:gsub("Color3%.fromRGB%(45,%s*45,%s*45%)", "Color3.fromRGB(0,170,255)")
    libCode = libCode:gsub("Color3%.fromRGB%(35,%s*35,%s*35%)", "Color3.fromRGB(0,90,160)")
    libCode = libCode:gsub("Color3%.fromRGB%(80,%s*80,%s*80%)", "Color3.fromRGB(0,120,200)")
    libCode = libCode:gsub("Color3%.fromRGB%(20,%s*20,%s*20%)", "Color3.fromRGB(0,0,0)")
    libCode = libCode:gsub("Color3%.fromRGB%(60,%s*60,%s*60%)", "Color3.fromRGB(0,170,255)")
    libCode = libCode:gsub("Color3%.fromRGB%(26,%s*26,%s*26%)", "Color3.fromRGB(10,12,20)")
    libCode = libCode:gsub("Color3%.fromRGB%(220,%s*220,%s*220%)", "Color3.fromRGB(220,240,255)")
    libCode = libCode:gsub("Color3%.fromRGB%(50,%s*50,%s*50%)", "Color3.fromRGB(15,20,35)")
    libCode = libCode:gsub("Color3%.fromRGB%(200,%s*200,%s*200%)", "Color3.fromRGB(120,180,230)")
    libCode = libCode:gsub("Color3%.fromRGB%(100,%s*100,%s*100%)", "Color3.fromRGB(120,180,230)")
    libCode = libCode:gsub("Color3%.fromRGB%(90,%s*90,%s*90%)", "Color3.fromRGB(0,90,160)")
    libCode = libCode:gsub("Color3%.fromRGB%(90,%s*90,%s*100%)", "Color3.fromRGB(0,90,160)")

    local Library = loadstring(libCode)()
    local Window = Library:CreateWindow("GOJO 0.2 KILL ALL HUB")

    -- â¡ Substitui o botĂ£o "T" pelo botĂ£o com imagem Gojo
    task.spawn(function()
        task.wait(0.1)
        local sg = CoreGui:FindFirstChild("ClashHubGuiLib") or pg:FindFirstChild("ClashHubGuiLib")
        if sg then
            local oldBtn = sg:FindFirstChild("ToggleMenuBtn")
            if oldBtn then
                oldBtn.Text = ""
                oldBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                oldBtn.Size = UDim2.new(0, 50, 0, 50)
                oldBtn.AutoButtonColor = false

                -- Ajusta o UICorner pra circular
                local corner = oldBtn:FindFirstChildOfClass("UICorner")
                if corner then
                    corner.CornerRadius = UDim.new(1, 0)
                end

                -- Ajusta o stroke
                local stroke = oldBtn:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = Color3.fromRGB(0, 170, 255)
                    stroke.Thickness = 1.5
                end

                -- Adiciona a imagem
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1, -6, 1, -6)
                img.Position = UDim2.new(0, 3, 0, 3)
                img.BackgroundTransparency = 1
                img.Image = IMAGEM_BOTAO
                img.ScaleType = Enum.ScaleType.Fit
                img.Parent = oldBtn
                local imgCorner = Instance.new("UICorner")
                imgCorner.CornerRadius = UDim.new(1, 0)
                imgCorner.Parent = img
            end
        end
    end)

    -- â•â•â• NOTIFICAĂ‡ĂƒO CUSTOMIZADA â•â•â•
    local notifScreenGui = Instance.new("ScreenGui")
    notifScreenGui.Name = "GojoNotify"
    notifScreenGui.ResetOnSpawn = false
    notifScreenGui.IgnoreGuiInset = true
    notifScreenGui.DisplayOrder = 99998
    notifScreenGui.Parent = pg

    local notifContainer = Instance.new("Frame")
    notifContainer.Size = UDim2.new(0, 280, 1, -40)
    notifContainer.Position = UDim2.new(1, -300, 0, 20)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = notifScreenGui

    local nLayout = Instance.new("UIListLayout")
    nLayout.SortOrder = Enum.SortOrder.LayoutOrder
    nLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    nLayout.Padding = UDim.new(0, 8)
    nLayout.Parent = notifContainer

    local function customNotify(title, text)
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 60)
        notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notif.BorderSizePixel = 0
        notif.Parent = notifContainer

        local nc = Instance.new("UICorner")
        nc.CornerRadius = UDim.new(0, 8)
        nc.Parent = notif

        local borda = Instance.new("UIStroke")
        borda.Color = C.Borda
        borda.Thickness = 2
        borda.Parent = notif

        local glow = Instance.new("UIStroke")
        glow.Color = C.BordaGlow
        glow.Thickness = 4
        glow.Transparency = 0.6
        glow.Parent = notif

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 40, 90)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
        })
        grad.Rotation = 45
        grad.Parent = notif

        local nPad = Instance.new("UIPadding")
        nPad.PaddingTop = UDim.new(0, 8)
        nPad.PaddingBottom = UDim.new(0, 8)
        nPad.PaddingLeft = UDim.new(0, 12)
        nPad.PaddingRight = UDim.new(0, 12)
        nPad.Parent = notif

        local nTitulo = Instance.new("TextLabel")
        nTitulo.Size = UDim2.new(1, 0, 0, 18)
        nTitulo.BackgroundTransparency = 1
        nTitulo.Text = title
        nTitulo.TextColor3 = C.BordaGlow
        nTitulo.Font = Enum.Font.GothamBold
        nTitulo.TextSize = 13
        nTitulo.TextXAlignment = Enum.TextXAlignment.Left
        nTitulo.Parent = notif

        local nText = Instance.new("TextLabel")
        nText.Size = UDim2.new(1, 0, 0, 16)
        nText.Position = UDim2.new(0, 0, 0, 20)
        nText.BackgroundTransparency = 1
        nText.Text = text
        nText.TextColor3 = C.Texto
        nText.Font = Enum.Font.Gotham
        nText.TextSize = 11
        nText.TextXAlignment = Enum.TextXAlignment.Left
        nText.Parent = notif

        local linha = Instance.new("Frame")
        linha.Size = UDim2.new(1, -24, 0, 1)
        linha.Position = UDim2.new(0, 12, 1, -10)
        linha.BackgroundColor3 = C.Borda
        linha.BorderSizePixel = 0
        linha.Parent = notif

        notif.BackgroundTransparency = 1
        nTitulo.TextTransparency = 1
        nText.TextTransparency = 1
        task.spawn(function()
            for i = 1, 10 do
                notif.BackgroundTransparency = 1 - (i / 10)
                nTitulo.TextTransparency = 1 - (i / 10)
                nText.TextTransparency = 1 - (i / 10)
                task.wait(0.02)
            end
        end)

        task.spawn(function()
            while notif.Parent do
                local t = tick() * 2
                local p = (math.sin(t) + 1) / 2
                glow.Transparency = 0.4 + (p * 0.3)
                task.wait(0.05)
            end
        end)

        task.delay(3.5, function()
            for i = 1, 10 do
                if notif.Parent then
                    notif.BackgroundTransparency = i / 10
                    nTitulo.TextTransparency = i / 10
                    nText.TextTransparency = i / 10
                end
                task.wait(0.02)
            end
            if notif.Parent then notif:Destroy() end
        end)
    end

    -- â•â•â• ESTADO â•â•â•
    local state = {
        Noclip = false,
        Bypass = false,
        SweepAll = false,
    }

    local CONFIG = {
        SweepTime = 0.01
    }

    local resetCount = 0

    local function notify(title, text)
        pcall(function()
            customNotify(title, text)
        end)
    end

    RunService.Stepped:Connect(function()
        if state.Noclip and LP.Character then
            for _, part in ipairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    local function getTarget(maxDistance)
        maxDistance = maxDistance or 500
        local targets = {}

        local myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and hrp then
                    if (hrp.Position - myHRP.Position).Magnitude <= maxDistance then
                        table.insert(targets, humanoid)
                    end
                end
            end
        end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if humanoid and humanoid.Health > 0 and hrp then
                    if (hrp.Position - myHRP.Position).Magnitude <= maxDistance then
                        table.insert(targets, humanoid)
                    end
                end
            end
        end

        if #targets > 0 then
            return targets[math.random(1, #targets)]
        end
        return nil
    end

    task.spawn(function()
        while true do
            task.wait(0.5)
            if state.Bypass then
                local character = LP.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if hrp and humanoid and humanoid.Health > 0 then
                    local targetHumanoid = getTarget(500)
                    local targetHRP = targetHumanoid and targetHumanoid.Parent and (targetHumanoid.Parent:FindFirstChild("HumanoidRootPart") or targetHumanoid.Parent:FindFirstChild("Torso"))

                    if targetHRP then
                        local startPos = hrp.Position
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)

                        local teleportedBack = false
                        local timer = 0

                        while timer < 3 do
                            task.wait(0.1)
                            timer = timer + 0.1
                            if not state.Bypass or not humanoid or humanoid.Health <= 0 then
                                break
                            end
                            if (hrp.Position - startPos).Magnitude < 10 then
                                teleportedBack = true
                                break
                            end
                        end

                        if state.Bypass and humanoid and humanoid.Health > 0 then
                            if teleportedBack then
                                local resetRemote = ReplicatedStorage:FindFirstChild("Knit")
                                    and ReplicatedStorage.Knit:FindFirstChild("Knit")
                                    and ReplicatedStorage.Knit.Knit:FindFirstChild("Services")
                                    and ReplicatedStorage.Knit.Knit.Services:FindFirstChild("JoinService")
                                    and ReplicatedStorage.Knit.Knit.Services.JoinService:FindFirstChild("RE")
                                    and ReplicatedStorage.Knit.Knit.Services.JoinService.RE:FindFirstChild("Reset")

                                while state.Bypass and humanoid and humanoid.Health > 0 do
                                    if resetRemote then
                                        resetRemote:FireServer()
                                        resetCount = resetCount + 1
                                    end
                                    task.wait(3)
                                end
                            else
                                notify("Gojo 0.2 Bypass | GESI |", "Bypass Success (Resets: " .. tostring(resetCount) .. ")")
                                task.wait(2)
                            end
                        end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.01)
            if state.SweepAll then
                local myChar = LP.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myHRP and humanoid and humanoid.Health > 0 then
                    local targets = {}

                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = p.Character.HumanoidRootPart
                            if (hrp.Position - myHRP.Position).Magnitude <= 500 then
                                table.insert(targets, hrp)
                            end
                        end
                    end

                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then
                            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                            if hrp and (hrp.Position - myHRP.Position).Magnitude <= 500 then
                                table.insert(targets, hrp)
                            end
                        end
                    end

                    for _, targetHRP in ipairs(targets) do
                        if not state.SweepAll or not humanoid or humanoid.Health <= 0 then break end
                        if myHRP and targetHRP and targetHRP.Parent then
                            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)
                            task.wait(CONFIG.SweepTime)
                        end
                    end
                end
            end
        end
    end)

    Window:AddToggle("Auto 0.2 KillAll", false, function(value)
        state.SweepAll = value
    end)

    Window:AddToggle("Noclip", false, function(value)
        state.Noclip = value
    end)

    Window:AddToggle("Bypass", false, function(value)
        state.Bypass = value
        if value then
            resetCount = 0
            notify("Gojo 0.2 Bypass | GESI |", "Bypass iniciado")
        end
    end)

    Window:AddInput("Time...", "0.01", function(text)
        local num = tonumber(text)
        if num then
            CONFIG.SweepTime = num
        end
    end)
end

-- ============================================
-- AUTO-LOGIN
-- ============================================
task.spawn(function()
    local salva = lerKeySalva()
    if salva then
        local ok = validarKey(salva)
        if ok then
            KEY_VALIDADA = true
            task.wait(0.5)
            liberarPainel()
        end
    end
end)
