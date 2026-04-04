--[[
    脚本名称：XU 光环人物 (V10 触屏极简修复版)
    适配：手机端/触屏/R15
    功能：全维星环、视角锁定上帝模式、极简磨砂 UI、防死
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 精简配置 ---
local cfg = {
    speed = 60,
    fly = false,
    radius = 6,
    rotSpeed = 2,
    offY = 0, offZ = 0, offX = 0,
    tiltX = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 核心防护 ---
local function setSafety(state)
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

-- --- 2. 视角锁定上帝模式与环绕控制 ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
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
        if not root then return end
        local t = tick() * cfg.rotSpeed
        
        -- A. 计算光环位置 (绝对绑定根部)
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local ringRot = CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = (baseCF * ringRot) * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- B. 视角锁定移动模式 (核心修复)
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.fly then
                root.Anchored = true
                -- 获取相机当前看向的方向
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                -- 将摇杆输入转化为相对于相机视角的移动向量
                local moveVector = (look * -hum.MoveDirection.Z) + (right * hum.MoveDirection.X)
                root.CFrame = root.CFrame + (moveVector.Unit * cfg.speed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.speed
            end
        else
            if cfg.fly then 
                root.Anchored = true 
                root.Velocity = Vector3.new(0,0,0) 
            end
        end
    end)
end

-- --- 3. 极简 UI 构建 (适配触屏) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_V10_Lite"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 320)
    main.Position = UDim2.new(0.5, -90, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(120, 150, 255), Color3.fromRGB(30, 30, 50))
    grad.Rotation = 45

    -- 标题 & 拖动区
    local titleBar = Instance.new("TextButton", main)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    titleBar.BackgroundTransparency = 0.8
    titleBar.Text = "  XU 光环人物"
    titleBar.TextColor3 = Color3.new(1, 1, 1)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 14
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.AutoButtonColor = false

    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size = UDim2.new(0, 35, 1, 0)
    minBtn.Position = UDim2.new(1, -35, 0, 0)
    minBtn.Text = "×"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.BackgroundTransparency = 1
    minBtn.TextSize = 20

    -- 精简状态条
    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 35)
    status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    status.BackgroundTransparency = 0.9
    status.Text = "模式: 常规 | 速度: 60"
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 10
    status.Font = Enum.Font.Code

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -110)
    content.Position = UDim2.new(0, 0, 0, 60)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 550)
    content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 12
        
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 45, 0, 25); b1.Position = UDim2.new(0.15, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(60,60,80); Instance.new("UICorner", b1)
        
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 45, 0, 25); b2.Position = UDim2.new(0.6, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(60,60,80); Instance.new("UICorner", b2)
        
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("移动速度", 5, "speed", 10)
    addRow("光环半径", 60, "radius", 1)
    addRow("上下偏移", 115, "offY", 1)
    addRow("前后偏移", 170, "offZ", 1)
    addRow("光环倾斜X", 225, "tiltX", 0.2)
    addRow("光环倾斜Z", 280, "tiltZ", 0.2)
    addRow("旋转速度", 335, "rotSpeed", 0.5)

    -- 模式切换
    local mBtn = Instance.new("TextButton", content)
    mBtn.Size = UDim2.new(0.8, 0, 0, 35); mBtn.Position = UDim2.new(0.1, 0, 0, 400)
    mBtn.Text = "常规行走"; mBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    
    mBtn.Activated:Connect(function()
        cfg.fly = not cfg.fly
        mBtn.Text = cfg.fly and "视角飞行模式" or "常规行走模式"
        mBtn.BackgroundColor3 = cfg.fly and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(40, 40, 50)
    end)

    -- 总开关
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(0.9, 0, 0, 45); toggle.Position = UDim2.new(0.05, 0, 1, -50)
    toggle.Text = "开启 XU 核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 80, 200); toggle.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggle)

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止重置" or "开启 XU 核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(60, 80, 200)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    RunService.RenderStepped:Connect(function()
        status.Text = string.format("模式: %s | 速度: %d", cfg.fly and "飞行" or "常规", cfg.speed)
    end)

    -- --- 触屏拖动代码 ---
    local dragData = { Dragging = false, StartTouch = nil, StartPos = nil }
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.Dragging = true; dragData.StartTouch = input.Position; dragData.StartPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragData.Dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragData.StartTouch
            main.Position = UDim2.new(dragData.StartPos.X.Scale, dragData.StartPos.X.Offset + delta.X, dragData.StartPos.Y.Scale, dragData.StartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.Dragging = false
        end
    end)

    -- --- 极简缩小逻辑 ---
    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "×"
        content.Visible = not isMin
        toggle.Visible = not isMin
        status.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 320), "Out", "Quart", 0.3, true)
    end)
end

createUI()
