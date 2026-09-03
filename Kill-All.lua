--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local LMG2L = {}
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Khởi tạo ScreenGui
LMG2L["ScreenGui_1"] = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
LMG2L["ScreenGui_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling
LMG2L["ScreenGui_1"]["ResetOnSpawn"] = false 

-- --- NÚT "JJS v3" ĐỂ ẨN/HIỆN ---
LMG2L["TextButton_b"] = Instance.new("TextButton", LMG2L["ScreenGui_1"])
LMG2L["TextButton_b"]["BorderSizePixel"] = 0
LMG2L["TextButton_b"]["BackgroundColor3"] = Color3.fromRGB(50, 50, 50)
LMG2L["TextButton_b"]["Size"] = UDim2.new(0, 75, 0, 35)
LMG2L["TextButton_b"]["Position"] = UDim2.new(0, 15, 0, 15)
LMG2L["TextButton_b"]["Text"] = "Gojo 0.2"
LMG2L["TextButton_b"]["Font"] = Enum.Font.GothamBold
LMG2L["TextButton_b"]["TextSize"] = 14
LMG2L["TextButton_b"]["TextColor3"] = Color3.fromRGB(255, 255, 255)
LMG2L["TextButton_b"]["ZIndex"] = 10 

LMG2L["UICorner_c"] = Instance.new("UICorner", LMG2L["TextButton_b"])

-- Main Frame
LMG2L["Frame_2"] = Instance.new("Frame", LMG2L["ScreenGui_1"])
LMG2L["Frame_2"]["BorderSizePixel"] = 0
LMG2L["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36)
LMG2L["Frame_2"]["Size"] = UDim2.new(0, 160, 0, 105)
LMG2L["Frame_2"]["Position"] = UDim2.new(0.5, -80, 0.4, 0)
LMG2L["Frame_2"]["ClipsDescendants"] = true
LMG2L["Frame_2"]["Visible"] = true 

LMG2L["UICorner_3"] = Instance.new("UICorner", LMG2L["Frame_2"])

-- Title Label
LMG2L["TextLabel_4"] = Instance.new("TextLabel", LMG2L["Frame_2"])
LMG2L["TextLabel_4"]["BorderSizePixel"] = 0
LMG2L["TextLabel_4"]["BackgroundTransparency"] = 1
LMG2L["TextLabel_4"]["Size"] = UDim2.new(1, 0, 0, 25)
LMG2L["TextLabel_4"]["Text"] = "Kill All - JJS"
LMG2L["TextLabel_4"]["Font"] = Enum.Font.GothamBold
LMG2L["TextLabel_4"]["TextSize"] = 11
LMG2L["TextLabel_4"]["TextColor3"] = Color3.fromRGB(255, 255, 255)

-- Nút Toggle ON/OFF
LMG2L["TextButton_5"] = Instance.new("TextButton", LMG2L["Frame_2"])
LMG2L["TextButton_5"]["BorderSizePixel"] = 0
LMG2L["TextButton_5"]["BackgroundColor3"] = Color3.fromRGB(255, 0, 0)
LMG2L["TextButton_5"]["Size"] = UDim2.new(0, 140, 0, 30)
LMG2L["TextButton_5"]["Position"] = UDim2.new(0, 10, 0, 28)
LMG2L["TextButton_5"]["Text"] = "Off"
LMG2L["TextButton_5"]["Font"] = Enum.Font.GothamBold
LMG2L["TextButton_5"]["TextSize"] = 14
LMG2L["TextButton_5"]["TextColor3"] = Color3.fromRGB(255, 255, 255)

LMG2L["UICorner_6"] = Instance.new("UICorner", LMG2L["TextButton_5"])

-- TextBox Khoảng cách
LMG2L["TextBox_7"] = Instance.new("TextBox", LMG2L["Frame_2"])
LMG2L["TextBox_7"]["BorderSizePixel"] = 0
LMG2L["TextBox_7"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 26)
LMG2L["TextBox_7"]["Size"] = UDim2.new(0, 65, 0, 30)
LMG2L["TextBox_7"]["Position"] = UDim2.new(0, 10, 0, 65)
LMG2L["TextBox_7"]["PlaceholderText"] = "Khoảng cách"
LMG2L["TextBox_7"]["Text"] = "0"
LMG2L["TextBox_7"]["Font"] = Enum.Font.GothamBold
LMG2L["TextBox_7"]["TextSize"] = 12
LMG2L["TextBox_7"]["TextColor3"] = Color3.fromRGB(255, 255, 255)

LMG2L["UICorner_8"] = Instance.new("UICorner", LMG2L["TextBox_7"])

-- TextBox Delay Chuyển Mục Tiêu
LMG2L["TextBox_9"] = Instance.new("TextBox", LMG2L["Frame_2"])
LMG2L["TextBox_9"]["BorderSizePixel"] = 0
LMG2L["TextBox_9"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 26)
LMG2L["TextBox_9"]["Size"] = UDim2.new(0, 65, 0, 30)
LMG2L["TextBox_9"]["Position"] = UDim2.new(0, 85, 0, 65)
LMG2L["TextBox_9"]["PlaceholderText"] = "Delay"
LMG2L["TextBox_9"]["Text"] = "0.1" -- Thời gian ở lại trên đầu mỗi đứa trước khi đổi mục tiêu
LMG2L["TextBox_9"]["Font"] = Enum.Font.GothamBold
LMG2L["TextBox_9"]["TextSize"] = 12
LMG2L["TextBox_9"]["TextColor3"] = Color3.fromRGB(255, 255, 255)

LMG2L["UICorner_a"] = Instance.new("UICorner", LMG2L["TextBox_9"])

-- Kéo thả Frame
local function makeFrameDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeFrameDraggable(LMG2L["Frame_2"])

-- Ẩn / hiện GUI
LMG2L["TextButton_b"].MouseButton1Click:Connect(function()
    LMG2L["Frame_2"].Visible = not LMG2L["Frame_2"].Visible
end)

-- --- LOGIC CHUYỂN MỤC TIÊU LUÂN PHIÊN (LOOP TELEPORT) ---
local toggled = false
local loopConnection = nil
local targetLoopConnection = nil
local currentTargetChar = nil
local targetIndex = 1

local function stopKillAll()
    toggled = false
    if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
    if targetLoopConnection then task.cancel(targetLoopConnection); targetLoopConnection = nil end
    currentTargetChar = nil
    targetIndex = 1
    LMG2L["TextButton_5"].Text = "Off"
    LMG2L["TextButton_5"].BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end

LMG2L["TextButton_5"].MouseButton1Click:Connect(function()
    toggled = not toggled
    if toggled then
        LMG2L["TextButton_5"].Text = "On"
        LMG2L["TextButton_5"].BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Vòng lặp 1: Luân phiên nhảy danh sách mục tiêu sau mỗi khoảng Delay
        targetLoopConnection = task.spawn(function()
            while toggled do
                local all = Players:GetPlayers()
                local validTargets = {}
                
                -- Thu thập toàn bộ mục tiêu hợp lệ còn sống
                for _, p in pairs(all) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
                        if p.Character.Humanoid.Health > 0 then
                            table.insert(validTargets, p.Character)
                        end
                    end
                end
                
                if #validTargets > 0 then
                    -- Đảm bảo index không vượt quá độ dài danh sách
                    if targetIndex > #validTargets then
                        targetIndex = 1
                    end
                    
                    -- Chọn mục tiêu hiện tại theo thứ tự tăng dần
                    currentTargetChar = validTargets[targetIndex]
                    
                    -- Nhảy chỉ mục cho lượt loop tiếp theo
                    targetIndex = targetIndex + 1
                else
                    currentTargetChar = nil
                    targetIndex = 1
                end
                
                local delayTime = tonumber(LMG2L["TextBox_9"].Text) or 0.5
                task.wait(delayTime)
            end
        end)
        
        -- Vòng lặp 2 (Heartbeat): Khóa cứng vị trí và ép góc nghiêng nhìn xuống đầu mục tiêu đã chọn
        loopConnection = RunService.Heartbeat:Connect(function()
            if not toggled or not currentTargetChar then return end
            
            local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = currentTargetChar:FindFirstChild("HumanoidRootPart")
            local targetHead = currentTargetChar:FindFirstChild("Head")
            
            -- Nếu mục tiêu bất ngờ chết trước khi hết delay, hủy khóa ngay để tránh lỗi kẹt hình
            if currentTargetChar:FindFirstChild("Humanoid") and currentTargetChar.Humanoid.Health <= 0 then
                currentTargetChar = nil
                return
            end
            
            if myHrp and targetHrp and targetHead then
                local dist = tonumber(LMG2L["TextBox_7"].Text) or 1
                
                -- Tọa độ trên đầu mục tiêu
                local spawnPos = targetHead.Position + Vector3.new(0, dist + 1.5, 0)
                
                -- Ép góc nghiêng: Quay người chúi thẳng hướng nhìn từ trên đầu xuống mục tiêu
                myHrp.CFrame = CFrame.lookAt(spawnPos, targetHrp.Position)
                
                -- Chặn lực phản chấn vật lý của game
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        stopKillAll()
    end
end)

lp.CharacterAdded:Connect(function()
    stopKillAll()
end)

return LMG2L["ScreenGui_1"]
