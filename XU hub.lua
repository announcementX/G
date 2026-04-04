local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 核心配置 ---
local cfg = {
    speed = 60,
    fly = false,        
    headFollow = true,  
    radius = 6,
    rotSpeed = 2,
    offY = 0, offZ = 0, offX = 0,
    tiltX = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 深度安全防护 ---
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

-- --- 2. 核心逻辑 (视角移动修复) ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            if p.Name ~= "Head" then table.insert(limbs, p) end
            p.CanCollide = false
        end
    end

    tasks.Main = RunService.RenderStepped:Connect(function(dt)
        if not root or not head then return end
        local t = tick() * cfg.rotSpeed
        
        -- 计算中心参考系
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = baseCF * CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        -- 头部跟随
        if cfg.headFollow then
            head.CFrame = centerCF
        end

        -- 光环旋转
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- B. 上帝模式移动 (终极修正：视角空间转换)
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.fly then
                root.Anchored = true
                -- 获取相机的水平偏航角，忽略俯仰，防止斜着飞
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                
                -- 构建基于当前相机视野的移动向量
                -- W/S 控制前后，A/D 控制左右
                local moveDir = (look * -hum.MoveDirection.Z) + (right * hum.MoveDirection.X)
                
                -- 核心修复：确保移动是基于当前帧相机位置的，不会锁死在启动那一刻
                root.CFrame = root.CFrame + (moveDir.Unit * cfg.speed * dt)
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

-- --- 3. 星空 UI 设计 ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 160, 0, 300)
    main.Position = UDim2.new(0.5, -80, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    -- 星空渐变
    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 50, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
    })
    grad.Rotation = 45

    -- 发光边框
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(120, 180, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5

    local bar = Instance.new("TextButton", main)
    bar.Size = UDim2.new(1, 0, 0, 32); bar.BackgroundColor3 = Color3.new(0,0,0); bar.BackgroundTransparency = 0.7
    bar.Text = "  ✧ XU STAR V13"; bar.TextColor3 = Color3.new(1,1,1); bar.TextXAlignment = 0; bar.Font = Enum.Font.GothamBold; bar.TextSize = 13

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 32, 1, 0); minBtn.Position = UDim2.new(1, -32, 0, 0); minBtn.Text = "×"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundTransparency = 1; minBtn.TextSize = 18

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -85); content.Position = UDim2.new(0, 0, 0, 32); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 0, 480); content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(200, 220, 255); l.BackgroundTransparency = 1; l.TextSize = 11; l.Font = Enum.Font.Gotham
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 35, 0, 22); b1.Position = UDim2.new(0.15, 0, 0, y+20); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,45,100); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 35, 0, 22); b2.Position = UDim2.new(0.65, 0, 0, y+20); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,45,100); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("飞行速率", 5, "speed", 10)
    addRow("星环半径", 55, "radius", 1)
    addRow("高度偏移", 105, "offY", 1)
    addRow("星环倾斜", 155, "tiltX", 0.2)
    addRow("公转速度", 205, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 28); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        end)
    end

    createToggle("视角飞行 (上帝)", 260, "fly")
    createToggle("头部跟随中心", 295, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 45); toggle.Position = UDim2.new(0, 0, 1, -45); toggle.Text = "✦ 启动星空核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 80, 220); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止并还原" or "✦ 启动星空核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(60, 80, 220)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- --- 触屏拖动 ---
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) dragging = false end)

    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "✦" or "×"
        content.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 160, 0, 32) or UDim2.new(0, 160, 0, 300), "Out", "Quart", 0.3, true)
    end)
end

createUI()
