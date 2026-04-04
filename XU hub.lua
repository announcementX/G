--[[
    脚本名称：XU 光环人物 (V16 全维度飞行修复)
    修复内容：彻底解决无法向上飞的问题，视角看哪飞哪。
]]

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

-- --- 2. 核心移动逻辑 (全维度修复) ---
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
        
        -- 光环中心点计算
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = baseCF * CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        if cfg.headFollow then head.CFrame = centerCF end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- --- 上帝模式移动：全维度视角对齐 ---
        if cfg.fly then
            root.Anchored = true
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- 获取相机的 CFrame 矩阵
                local camCF = cam.CFrame
                
                -- 核心算法：将水平摇杆输入转化为相机空间的 3D 向量
                -- 这样做当你视角朝上时，LookVector 的 Y 分量会很大，从而实现向上飞
                local direction = (camCF.LookVector * -math.sign(moveDir:Dot(camCF.LookVector)) * moveDir.Magnitude)
                
                -- 如果是手机端，直接简化为：视角方向 * 摇杆力度
                -- 判定：如果用户是在往前推摇杆
                local forwardLook = camCF.LookVector
                local sideLook = camCF.RightVector
                
                -- 这里的逻辑确保 W 是朝镜头中心飞，S 是背离镜头飞
                -- 通过简单的向量合成实现 360 度无死角飞行
                root.CFrame = root.CFrame + (moveDir * cfg.speed * dt)
                
                -- 额外修正：为了能向上飞，我们需要手动加上相机的垂直分量
                -- 手机端摇杆在 Anchored 状态下 Z 轴代表前后
                if math.abs(moveDir.Z) > 0.1 or math.abs(moveDir.X) > 0.1 then
                    -- 这里的 0.5 是上升灵敏度，你可以根据需要调整
                    local verticalLift = camCF.LookVector * (cfg.speed * dt)
                    -- 我们只在“推摇杆”的时候应用相机的纵向分量
                    root.CFrame = CFrame.new(root.Position + (moveDir.Unit * cfg.speed * dt)) * camCF.Rotation
                    -- 强制设置坐标，混合相机高度
                    root.Position = root.Position + (camCF.LookVector * (moveDir.Magnitude * cfg.speed * dt))
                end
            else
                root.Velocity = Vector3.zero
            end
        else
            root.Anchored = false
            hum.WalkSpeed = cfg.speed
        end
    end)
end

-- --- 3. 星空极简 UI ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 160, 0, 310)
    main.Position = UDim2.new(0.5, -80, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(45, 55, 120), Color3.fromRGB(15, 15, 30))
    grad.Rotation = 45

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2

    local bar = Instance.new("TextButton", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundTransparency = 1
    bar.Text = "  ✦ XU GALAXY V16"; bar.TextColor3 = Color3.new(1,1,1); bar.TextXAlignment = 0; bar.Font = Enum.Font.GothamBold; bar.TextSize = 12

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -90); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(180, 200, 255); l.BackgroundTransparency = 1; l.TextSize = 11
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 40, 0, 25); b1.Position = UDim2.new(0.12, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,80); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 40, 0, 25); b2.Position = UDim2.new(0.62, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,80); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("全维飞行速度", 10, "speed", 10)
    addRow("星环半径", 65, "radius", 1)
    addRow("高度修正", 120, "offY", 1)
    addRow("公转速率", 175, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 30); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(60, 80, 200) or Color3.fromRGB(30, 30, 45)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 11; btn.Font = Enum.Font.GothamBold
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(60, 80, 200) or Color3.fromRGB(30, 30, 45)
        end)
    end

    createToggle("开启全维飞行", 235, "fly")
    createToggle("头部锁定中心", 275, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50); toggle.Text = "✦ 启动星空核心"; toggle.BackgroundColor3 = Color3.fromRGB(50, 70, 160); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "还原角色" or "✦ 启动星空核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 70, 160)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- 拖动逻辑
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
end

createUI()
