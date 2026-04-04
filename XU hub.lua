--[[
    LIMEHUB OMNI-RING V6 - 一体化上帝面板
    --------------------------------------------------
    1. 界面：合并信息与控制，支持鼠标拖动、点击最小化。
    2. 移动：支持 [常规行走] 和 [上帝飞行] 模式切换。
    3. 防死：强制生命锁定 + 状态拦截。
    4. 整体环：全向倾斜、整体位移。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 配置字典 ---
local cfg = {
    moveSpeed = 60,
    flyMode = false, -- 默认人物移动，开启后为视角飞行
    radius = 6,
    rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 防死与初始化 ---
local function toggleSafety(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        tasks.Safe = RunService.Heartbeat:Connect(function() if hum.Health < 100 then hum.Health = 100 end end)
        for _, v in pairs(character:GetDescendants()) do if v:IsA("Motor6D") then v.Enabled = false end end
    else
        if tasks.Safe then tasks.Safe:Disconnect() end
        for _, v in pairs(character:GetDescendants()) do if v:IsA("Motor6D") then v.Enabled = true end end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end

-- --- 2. 核心逻辑循环 ---
local function startLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            p.CanCollide = false
        end
    end

    tasks.Main = RunService.RenderStepped:Connect(function(dt)
        if not head or not root then return end
        local t = tick() * cfg.rotSpeed
        
        -- A. 光环矩阵计算
        local ringRot = CFrame.Angles(cfg.tiltX, cfg.tiltY, cfg.tiltZ)
        local ringPos = Vector3.new(cfg.offX, cfg.offY, cfg.offZ)

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = (head.CFrame * CFrame.new(ringPos) * ringRot) * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- B. 移动逻辑切换
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.flyMode then
                -- 上帝飞行模式：朝相机方向移动
                root.CFrame = root.CFrame + (cam.CFrame.LookVector * hum.MoveDirection.Z * -cfg.moveSpeed * dt) + (cam.CFrame.RightVector * hum.MoveDirection.X * cfg.moveSpeed * dt)
                root.Velocity = Vector3.new(0,0,0)
            else
                -- 人物移动模式：人物在地上走，光环跟着
                root.Anchored = false
                hum.WalkSpeed = cfg.moveSpeed
            end
        else
            if cfg.flyMode then root.Anchored = true end
        end
    end)
end

-- --- 3. UI 一体化构建 (支持拖动/缩小) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    
    -- 主容器
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 360)
    main.Position = UDim2.new(0.05, 0, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    main.ClipsDescendants = true
    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(60, 60, 150)

    -- 顶部栏 (拖动区域)
    local titleBar = Instance.new("TextButton", main)
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    titleBar.Text = "  LIMEHUB OMNI V6"
    titleBar.TextColor3 = Color3.new(1, 1, 1)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextXAlignment = Enum.TextXAlignment.Left

    -- 最小化按钮
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -30, 0, 0)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.BackgroundTransparency = 1

    -- 内容区
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 600)
    content.ScrollBarThickness = 2

    -- 信息看板 (合并在内)
    local info = Instance.new("TextLabel", content)
    info.Size = UDim2.new(1, -10, 0, 100)
    info.Position = UDim2.new(0, 5, 0, 5)
    info.TextColor3 = Color3.fromRGB(0, 255, 255)
    info.TextSize = 12
    info.Font = Enum.Font.Code
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1

    RunService.RenderStepped:Connect(function()
        info.Text = string.format("STATUS: %s\nFLY: %s\nPOS: %.1f,%.1f,%.1f\nTILT: %.1f,%.1f,%.1f", 
        isEnabled and "ON" or "OFF", cfg.flyMode and "TRUE" or "FALSE",
        cfg.offX, cfg.offY, cfg.offZ, cfg.tiltX, cfg.tiltY, cfg.tiltZ)
    end)

    -- 辅助函数：调节器
    local function addCtrl(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0.4, 0, 0, 25); b1.Position = UDim2.new(0.05, 0, 0, y+25); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,90); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0.4, 0, 0, 25); b2.Position = UDim2.new(0.55, 0, 0, y+25); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,90); Instance.new("UICorner", b2)
        b1.MouseButton1Click:Connect(function() cfg[key] = cfg[key] - step end)
        b2.MouseButton1Click:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addCtrl("移动速度", 110, "moveSpeed", 10)
    addCtrl("光环半径", 170, "radius", 1)
    addCtrl("上下偏移", 230, "offY", 1)
    addCtrl("前后偏移", 290, "offZ", 1)
    addCtrl("左右偏移", 350, "offX", 1)
    addCtrl("俯仰倾斜", 410, "tiltX", 0.2)
    addCtrl("翻滚倾斜", 470, "tiltZ", 0.2)

    -- [ 模式切换按钮 ]
    local flyBtn = Instance.new("TextButton", content)
    flyBtn.Size = UDim2.new(0.9, 0, 0, 30)
    flyBtn.Position = UDim2.new(0.05, 0, 0, 530)
    flyBtn.Text = "视角飞行: OFF"
    flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    flyBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", flyBtn)
    
    flyBtn.MouseButton1Click:Connect(function()
        cfg.flyMode = not cfg.flyMode
        flyBtn.Text = cfg.flyMode and "视角飞行: ON" or "视角飞行: OFF"
        flyBtn.BackgroundColor3 = cfg.flyMode and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(50, 50, 50)
    end)

    -- [ 总开关 ]
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.Position = UDim2.new(0, 0, 1, -40)
    toggle.Text = "启动上帝模式"
    toggle.BackgroundColor3 = Color3.fromRGB(30, 40, 100)
    toggle.TextColor3 = Color3.new(1, 1, 1)

    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggleSafety(true); startLoop()
            toggle.Text = "关闭重置"; toggle.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        else
            if tasks.Main then tasks.Main:Disconnect() end
            toggleSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false
            toggle.Text = "启动上帝模式"; toggle.BackgroundColor3 = Color3.fromRGB(30, 40, 100)
        end
    end)

    -- --- UI 逻辑：拖动 & 最小化 ---
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(main, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 180, 0, 30) or UDim2.new(0, 180, 0, 360)}):Play()
        minBtn.Text = minimized and "+" or "—"
    end)
end

createUI()
