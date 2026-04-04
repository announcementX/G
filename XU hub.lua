--[[
    脚本名称：XU 光环人物 (V9 手机触屏优化版)
    适用平台：移动端 (Android/iOS 执行器)
    更新内容：
    1. 专项适配触屏拖动逻辑。
    2. 修复手机端点击切换模式不生效的问题。
    3. 修复上帝模式下肢体由于锚定(Anchored)不跟随的问题。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 参数配置 ---
local cfg = {
    moveSpeed = 60,
    flyMode = false, -- false:常规, true:上帝
    radius = 6,
    rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 防死系统 (针对 R15 优化) ---
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

-- --- 2. 核心跟随逻辑 (手机上帝模式适配) ---
local function startLoop()
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
        if not root or not character:FindFirstChild("HumanoidRootPart") then return end
        local t = tick() * cfg.rotSpeed
        
        -- 每一帧实时获取位置，解决上帝模式跟随问题
        local currentPos = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local ringRot = CFrame.Angles(cfg.tiltX, cfg.tiltY, cfg.tiltZ)

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local localPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 强制对齐
            part.CFrame = (currentPos * ringRot) * CFrame.new(localPos) * CFrame.Angles(t, 0, 0)
        end

        -- 移动逻辑
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.flyMode then
                root.Anchored = true
                -- 手机端上帝模式：朝摇杆方向+相机朝向移动
                local moveDir = (cam.CFrame.LookVector * hum.MoveDirection.Z * -1) + (cam.CFrame.RightVector * hum.MoveDirection.X)
                root.CFrame = root.CFrame + (moveDir * cfg.moveSpeed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.moveSpeed
            end
        else
            -- 停止时保持悬浮
            if cfg.flyMode then 
                root.Anchored = true 
                root.Velocity = Vector3.new(0,0,0)
            end
        end
    end)
end

-- --- 3. UI 构建 (手机触屏专用拖动与交互) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Mobile_V9"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 210, 0, 360)
    main.Position = UDim2.new(0.5, -105, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(100, 100, 255)

    -- 标题栏 (触屏拖动区)
    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
    
    local titleTxt = Instance.new("TextLabel", titleBar)
    titleTxt.Size = UDim2.new(1, -50, 1, 0)
    titleTxt.Position = UDim2.new(0, 10, 0, 0)
    titleTxt.Text = "XU 光环人物 V9"
    titleTxt.TextColor3 = Color3.new(1, 1, 1)
    titleTxt.Font = Enum.Font.GothamBold
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left
    titleTxt.BackgroundTransparency = 1

    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size = UDim2.new(0, 40, 0, 40)
    minBtn.Position = UDim2.new(1, -40, 0, 0)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.BackgroundTransparency = 1
    minBtn.TextSize = 25

    -- 内容容器
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -100)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 700)
    content.ScrollBarThickness = 4

    -- 看板
    local info = Instance.new("TextLabel", content)
    info.Size = UDim2.new(1, -20, 0, 80)
    info.Position = UDim2.new(0, 10, 0, 5)
    info.TextColor3 = Color3.fromRGB(0, 255, 255)
    info.TextSize = 14
    info.Font = Enum.Font.Code
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    RunService.RenderStepped:Connect(function()
        info.Text = string.format("模式: %s\n偏移: %.1f | %.1f | %.1f\n角度: %.1f | %.1f", 
            cfg.flyMode and "上帝飞行" or "常规行走", cfg.offX, cfg.offY, cfg.offZ, cfg.tiltX, cfg.tiltZ)
    end)

    -- 按钮/调节器 (使用 Activated 兼容手机)
    local function addSet(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 25); l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
        
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 50, 0, 30); b1.Position = UDim2.new(0.15, 0, 0, y+25); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(50,50,120); Instance.new("UICorner", b1)
        
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 50, 0, 30); b2.Position = UDim2.new(0.6, 0, 0, y+25); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(50,50,120); Instance.new("UICorner", b2)
        
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addSet("移动速度", 90, "moveSpeed", 10)
    addSet("光环半径", 155, "radius", 1)
    addSet("上下偏移", 220, "offY", 1)
    addSet("前后偏移", 285, "offZ", 1)
    addSet("左右偏移", 350, "offX", 1)
    addSet("倾斜 X (俯仰)", 415, "tiltX", 0.2)
    addSet("倾斜 Z (侧倾)", 480, "tiltZ", 0.2)

    -- 手机模式切换按钮
    local mBtn = Instance.new("TextButton", content)
    mBtn.Size = UDim2.new(0.8, 0, 0, 40); mBtn.Position = UDim2.new(0.1, 0, 0, 560)
    mBtn.Text = "切换至上帝模式"; mBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    
    mBtn.Activated:Connect(function()
        cfg.flyMode = not cfg.flyMode
        mBtn.Text = cfg.flyMode and "当前: 上帝模式" or "当前: 常规模式"
        mBtn.BackgroundColor3 = cfg.flyMode and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
    end)

    -- 总开关
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 60); toggle.Position = UDim2.new(0, 0, 1, -60)
    toggle.Text = "开启 XU 核心"; toggle.BackgroundColor3 = Color3.fromRGB(40, 60, 180); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggleSafety(true); startLoop()
            toggle.Text = "停止并重置"; toggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        else
            if tasks.Main then tasks.Main:Disconnect() end
            toggleSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false
            toggle.Text = "开启 XU 核心"; toggle.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
        end
    end)

    -- --- 手机触屏拖动核心代码 ---
    local dragData = { Dragging = false, StartPos = nil, StartTouch = nil }
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.Dragging = true
            dragData.StartTouch = input.Position
            dragData.StartPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragData.Dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragData.StartTouch
            main.Position = UDim2.new(
                dragData.StartPos.X.Scale, dragData.StartPos.X.Offset + delta.X,
                dragData.StartPos.Y.Scale, dragData.StartPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.Dragging = false
        end
    end)

    -- --- 最小化修复 ---
    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "—"
        content.Visible = not isMin
        toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 210, 0, 40) or UDim2.new(0, 210, 0, 360), "Out", "Quart", 0.3, true)
    end)
end

createUI()
