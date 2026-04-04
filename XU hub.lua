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
    offY = 0, offX = 0, offZ = 0,
    tiltX = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 防死 & 关节锁定 ---
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

-- --- 2. 获取手机摇杆输入 (核心修复) ---
local function getMobileMoveVec()
    local moveVec = player:FindFirstChildOfClass("PlayerScripts").ControlModule:GetMoveVector()
    -- moveVec.X 是左右，moveVec.Z 是前后 (负值向前)
    return moveVec
end

-- --- 3. 核心循环 ---
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
        
        -- 计算中心
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = baseCF * CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        if cfg.headFollow then head.CFrame = centerCF end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- --- 上帝模式移动：摇杆向量直接映射相机 CFrame ---
        local inputVec = getMobileMoveVec()
        
        if inputVec.Magnitude > 0 then
            if cfg.fly then
                root.Anchored = true
                -- 核心算法：将摇杆输入直接乘以相机的旋转矩阵
                -- inputVec.Z 为负是前进，所以取 -inputVec.Z
                local moveDir = (cam.CFrame.LookVector * -inputVec.Z) + (cam.CFrame.RightVector * inputVec.X)
                
                root.CFrame = root.CFrame + (moveDir * cfg.speed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.speed
            end
        else
            if cfg.fly then 
                root.Anchored = true 
                root.Velocity = Vector3.zero
            end
        end
    end)
end

-- --- 4. 星空 UI 设计 (极简、星尘感) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 165, 0, 310)
    main.Position = UDim2.new(0.5, -82, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

    -- 星空渐变背景
    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 40, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
    })
    grad.Rotation = 45

    -- 蓝色流光边框
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(130, 150, 255)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local bar = Instance.new("TextButton", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundTransparency = 0.8; bar.BackgroundColor3 = Color3.new(0,0,0)
    bar.Text = "  ✧ XU STAR V14"; bar.TextColor3 = Color3.new(1,1,1); bar.Font = Enum.Font.GothamBold; bar.TextSize = 12; bar.TextXAlignment = 0; bar.AutoButtonColor = false

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 35, 1, 0); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "⊹"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundTransparency = 1; minBtn.TextSize = 20

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -95); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 0, 480); content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(180, 200, 255); l.BackgroundTransparency = 1; l.TextSize = 11; l.Font = Enum.Font.Gotham
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 40, 0, 24); b1.Position = UDim2.new(0.12, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,80); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 40, 0, 24); b2.Position = UDim2.new(0.62, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,80); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("移动/飞行速度", 10, "speed", 10)
    addRow("光环半径", 65, "radius", 1)
    addRow("垂直偏移", 120, "offY", 1)
    addRow("旋转速率", 175, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 30); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(70, 90, 200) or Color3.fromRGB(30, 30, 45)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(70, 90, 200) or Color3.fromRGB(30, 30, 45)
        end)
    end

    createToggle("上帝飞行(视角对齐)", 235, "fly")
    createToggle("头部跟随中心", 275, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50); toggle.Text = "✦ 启动 XU STAR"; toggle.BackgroundColor3 = Color3.fromRGB(50, 70, 180); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止并还原" or "✦ 启动 XU STAR"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 70, 180)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- --- 触屏拖动代码 (优化) ---
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
    UserInputService.InputEnded:Connect(function() dragging = false end)

    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "✧" or "⊹"
        content.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 165, 0, 35) or UDim2.new(0, 165, 0, 310), "Out", "Quart", 0.3, true)
    end)
end

createUI()
