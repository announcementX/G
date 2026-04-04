--[[
    脚本名称：XU 光环人物 (V7 终极修复版)
    功能：整体星环、上帝模式/常规模式切换、全维偏移、防死、可拖动折叠UI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 核心配置 ---
local cfg = {
    moveSpeed = 60,
    flyMode = false,
    radius = 6,
    rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 深度防死 (确保断肢不死) ---
local function toggleSafety(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        tasks.Safe = RunService.Heartbeat:Connect(function() 
            if hum.Health < 100 then hum.Health = 100 end 
        end)
        for _, v in pairs(character:GetDescendants()) do 
            if v:IsA("Motor6D") then v.Enabled = false end 
        end
    else
        if tasks.Safe then tasks.Safe:Disconnect() end
        for _, v in pairs(character:GetDescendants()) do 
            if v:IsA("Motor6D") then v.Enabled = true end 
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end

-- --- 2. 核心环绕与跟随逻辑 ---
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
        
        -- 整体矩阵：基于 RootPart 或 Head 的实时坐标进行偏移
        local ringRot = CFrame.Angles(cfg.tiltX, cfg.tiltY, cfg.tiltZ)
        local ringPos = Vector3.new(cfg.offX, cfg.offY, cfg.offZ)

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 核心修复：(当前部位坐标 = 头部实时坐标 * 整体位移 * 整体旋转 * 肢体相对位置)
            part.CFrame = (head.CFrame * CFrame.new(ringPos) * ringRot) * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- 移动逻辑
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.flyMode then
                root.Anchored = true
                local moveDir = (cam.CFrame.LookVector * hum.MoveDirection.Z * -1) + (cam.CFrame.RightVector * hum.MoveDirection.X)
                root.CFrame = root.CFrame + (moveDir * cfg.moveSpeed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.moveSpeed
            end
        else
            if cfg.flyMode then root.Anchored = true end
        end
    end)
end

-- --- 3. UI 界面重构 (解决拖动/缩放/重叠) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Ring_Control"

    -- 主面板
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 200, 0, 380)
    main.Position = UDim2.new(0.5, -100, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true -- 关键：折叠时隐藏内容
    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(80, 80, 200)
    stroke.Thickness = 2

    -- 标题栏 (用于拖动)
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "XU 光环人物"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -32, 0.5, -15)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.BackgroundTransparency = 1
    minBtn.TextSize = 20

    -- 滚动内容区
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -85) -- 留出底部开关位置
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 650)
    content.ScrollBarThickness = 3

    -- 信息实时显示
    local info = Instance.new("TextLabel", content)
    info.Size = UDim2.new(1, -20, 0, 90)
    info.Position = UDim2.new(0, 10, 0, 10)
    info.TextColor3 = Color3.fromRGB(0, 255, 255)
    info.TextSize = 12
    info.Font = Enum.Font.Code
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    
    RunService.RenderStepped:Connect(function()
        info.Text = string.format("状态: %s\n模式: %s\n坐标: %.1f, %.1f, %.1f\n倾斜: %.1f, %.1f", 
            isEnabled and "激活" or "空闲", 
            cfg.flyMode and "上帝视角" or "常规行走",
            cfg.offX, cfg.offY, cfg.offZ, cfg.tiltX, cfg.tiltZ)
    end)

    -- 调节器辅助
    local function addReg(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 40, 0, 25); b1.Position = UDim2.new(0.2, 0, 0, y+25); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(50,50,100); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 40, 0, 25); b2.Position = UDim2.new(0.6, 0, 0, y+25); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(50,50,100); Instance.new("UICorner", b2)
        b1.MouseButton1Click:Connect(function() cfg[key] = cfg[key] - step end)
        b2.MouseButton1Click:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addReg("移动速度", 105, "moveSpeed", 10)
    addReg("光环半径", 165, "radius", 1)
    addReg("上下偏移", 225, "offY", 1)
    addReg("左右偏移", 285, "offX", 1)
    addReg("前后偏移", 345, "offZ", 1)
    addReg("倾斜 X", 405, "tiltX", 0.2)
    addReg("倾斜 Z", 465, "tiltZ", 0.2)
    addReg("旋转速度", 525, "rotSpeed", 0.5)

    -- 模式切换按钮
    local flyBtn = Instance.new("TextButton", content)
    flyBtn.Size = UDim2.new(0.8, 0, 0, 30)
    flyBtn.Position = UDim2.new(0.1, 0, 0, 590)
    flyBtn.Text = "切换至上帝模式"
    flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    flyBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", flyBtn)
    flyBtn.MouseButton1Click:Connect(function()
        cfg.flyMode = not cfg.flyMode
        flyBtn.Text = cfg.flyMode and "当前:上帝模式" or "当前:常规模式"
        flyBtn.BackgroundColor3 = cfg.flyMode and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 40)
    end)

    -- 总开关
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50)
    toggle.Position = UDim2.new(0, 0, 1, -50)
    toggle.Text = "启动 XU 光环"
    toggle.BackgroundColor3 = Color3.fromRGB(40, 50, 150)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold

    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggleSafety(true); startLoop()
            toggle.Text = "停止并重置"; toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            if tasks.Main then tasks.Main:Disconnect() end
            toggleSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false
            toggle.Text = "启动 XU 光环"; toggle.BackgroundColor3 = Color3.fromRGB(40, 50, 150)
        end
    end)

    -- --- 拖动逻辑修复 ---
    local dragStart, startPos, dragging
    bar.InputBegan:Connect(function(input)
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

    -- --- 缩小逻辑修复 (解决重叠) ---
    local isMin = false
    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "—"
        local targetSize = isMin and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 380)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)
end

createUI()
