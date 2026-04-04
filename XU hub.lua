--[[
    LIMEHUB & BLOXPASTE 风格 - 重装加强版脚本
    --------------------------------------------------
    1. 弹窗提示：左图右字，带滑入滑出动画。
    2. 防死系统：强制锁定 Humanoid 状态，断开 Neck 不死。
    3. 全服可见：利用 Network Ownership 广播 CFrame 变化。
    4. 星空 UI：包含速度调节、距离调节、动态渐变效果。
    5. 环绕算法：基于 R15 全部 15 个部位的圆形矩阵排列。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false
local moveSpeed = 50
local orbitDistance = 5
local activeConnections = {}

-- --- 1. 核心功能：防死与关节控制 ---
local function setCharacterLogic(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if state then
        -- 核心：防止断开连接导致死亡
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        -- 禁用所有身体关节 (Motor6D)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then
                v.Enabled = false
            end
        end
    else
        -- 恢复关节
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then
                v.Enabled = true
            end
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end

-- --- 2. 核心算法：肢体矩阵环绕 ---
local function startOrbit()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    if not root or not head or not hum then return end
    if hum.RigType ~= Enum.HumanoidRigType.R15 then
        warn("LIMEHUB: 检测到 R6，请切换至 R15 再试")
        return
    end

    setCharacterLogic(true)
    root.Anchored = true -- 锁定重心实现悬浮

    -- 筛选环绕部位（排除 Head 和 Root）
    local orbitParts = {}
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
            table.insert(orbitParts, part)
            part.CanCollide = false -- 防止肢体碰撞抖动
        end
    end

    -- 建立高频循环
    activeConnections.Orbit = RunService.Heartbeat:Connect(function(dt)
        if not character or not head then return end
        
        local t = tick()
        for i, part in ipairs(orbitParts) do
            -- 计算圆周坐标 (角度平分)
            local angle = (i / #orbitParts) * math.pi * 2 + t
            local x = math.cos(angle) * orbitDistance
            local z = math.sin(angle) * orbitDistance
            local y = math.sin(t * 0.7 + i) * 1.2 -- 增加上下波浪感
            
            -- 应用 CFrame (此时会自动同步给服务器其他玩家)
            part.CFrame = head.CFrame * CFrame.new(x, y, z) * CFrame.Angles(t, angle, 0)
        end

        -- 传送式移动
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * moveSpeed * dt)
        end
    end)
end

local function stopOrbit()
    if activeConnections.Orbit then activeConnections.Orbit:Disconnect() end
    setCharacterLogic(false)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then root.Anchored = false end
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

-- --- 3. UI 界面：星空风格加强版 ---
local function createUI()
    local mainGui = Instance.new("ScreenGui", CoreGui)
    mainGui.Name = "LimeHub_StarryEffect"

    -- [ 启动弹窗 ]
    local notifyFrame = Instance.new("Frame", mainGui)
    notifyFrame.Size = UDim2.new(0, 280, 0, 75)
    notifyFrame.Position = UDim2.new(0.5, -140, 0, -100)
    notifyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    notifyFrame.BorderSizePixel = 0
    Instance.new("UICorner", notifyFrame).CornerRadius = UDim.new(0, 12)
    
    local icon = Instance.new("ImageLabel", notifyFrame)
    icon.Size = UDim2.new(0, 55, 0, 55)
    icon.Position = UDim2.new(0, 10, 0.5, -27)
    icon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=15"
    icon.BackgroundTransparency = 1
    
    local notifyText = Instance.new("TextLabel", notifyFrame)
    notifyText.Size = UDim2.new(1, -75, 1, 0)
    notifyText.Position = UDim2.new(0, 70, 0, 0)
    notifyText.Text = "脚本已打开"
    notifyText.TextColor3 = Color3.new(1, 1, 1)
    notifyText.TextSize = 20
    notifyText.Font = Enum.Font.GothamBold
    notifyText.BackgroundTransparency = 1
    notifyText.TextXAlignment = Enum.TextXAlignment.Left

    -- [ 左侧控制面板 ]
    local sidePanel = Instance.new("Frame", mainGui)
    sidePanel.Size = UDim2.new(0, 90, 0, 260)
    sidePanel.Position = UDim2.new(0.02, -150, 0.4, 0) -- 初始隐藏
    sidePanel.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
    Instance.new("UICorner", sidePanel)
    
    local grad = Instance.new("UIGradient", sidePanel)
    grad.Color = ColorSequence.new(Color3.fromRGB(40, 40, 110), Color3.fromRGB(5, 5, 15))
    grad.Rotation = 90

    -- 面板内部组件（辅助函数）
    local function addControl(name, y, callback)
        local lab = Instance.new("TextLabel", sidePanel)
        lab.Size = UDim2.new(1, 0, 0, 30)
        lab.Position = UDim2.new(0, 0, 0, y)
        lab.Text = name
        lab.TextColor3 = Color3.fromRGB(180, 180, 255)
        lab.BackgroundTransparency = 1
        
        local up = Instance.new("TextButton", sidePanel)
        up.Size = UDim2.new(0.4, 0, 0, 35)
        up.Position = UDim2.new(0.55, 0, 0, y + 30)
        up.Text = "+"
        up.BackgroundColor3 = Color3.fromRGB(30, 30, 80)
        up.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", up)

        local down = Instance.new("TextButton", sidePanel)
        down.Size = UDim2.new(0.4, 0, 0, 35)
        down.Position = UDim2.new(0.05, 0, 0, y + 30)
        down.Text = "-"
        down.BackgroundColor3 = Color3.fromRGB(30, 30, 80)
        down.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", down)

        up.MouseButton1Click:Connect(function() callback(true) end)
        down.MouseButton1Click:Connect(function() callback(false) end)
    end

    addControl("移动速度", 20, function(inc) moveSpeed = inc and moveSpeed + 10 or math.max(10, moveSpeed - 10) end)
    addControl("环绕距离", 120, function(inc) orbitDistance = inc and orbitDistance + 1 or math.max(1, orbitDistance - 1) end)

    -- [ 主开关 ]
    local mainBtn = Instance.new("TextButton", mainGui)
    mainBtn.Size = UDim2.new(0, 150, 0, 50)
    mainBtn.Position = UDim2.new(0.5, -75, 0.88, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    mainBtn.Text = "开启环绕"
    mainBtn.TextColor3 = Color3.new(1, 1, 1)
    mainBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", mainBtn)
    local stroke = Instance.new("UIStroke", mainBtn)
    stroke.Color = Color3.fromRGB(100, 100, 255)
    stroke.Thickness = 2

    -- --- 4. 交互逻辑动画 ---
    notifyFrame:TweenPosition(UDim2.new(0.5, -140, 0, 60), "Out", "Quart", 0.6, true)
    task.delay(3, function() notifyFrame:TweenPosition(UDim2.new(0.5, -140, 0, -100), "In", "Quart", 0.6, true) end)

    mainBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            startOrbit()
            mainBtn.Text = "关闭环绕"
            mainBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            sidePanel:TweenPosition(UDim2.new(0.02, 0, 0.4, 0), "Out", "Back", 0.5, true)
        else
            stopOrbit()
            mainBtn.Text = "开启环绕"
            mainBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
            sidePanel:TweenPosition(UDim2.new(0.02, -150, 0.4, 0), "In", "Quart", 0.5, true)
        end
    end)
end

-- 执行初始化
createUI()
