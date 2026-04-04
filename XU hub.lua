--[[
    脚本名称：XU 光环人物 (V15 终极兼容修复)
    核心修复：解决 V14 无法飞行的问题，通过原生 CFrame 矩阵修复上帝模式方向。
    UI风格：深空星幻渐变
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 配置 ---
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

-- --- 1. 防死 & 关节处理 ---
local function setSafety(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        tasks.Safe = RunService.Heartbeat:Connect(function() 
            if hum.Health < 100 then hum.Health = 100 end 
        end)
        -- 移除肢体约束
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

-- --- 2. 核心移动与光环循环 ---
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
        
        -- A. 中心坐标计算
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = baseCF * CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        if cfg.headFollow then head.CFrame = centerCF end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- B. 上帝模式移动 (原生矩阵修复版)
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.fly then
                root.Anchored = true
                -- 获取相机的朝向，但不包含倾斜（平滑飞行）
                local camCF = cam.CFrame
                local look = camCF.LookVector
                local right = camCF.RightVector
                
                -- 将 MoveDirection 转换为相对于相机视野的向量
                -- 这样在手机上，摇杆推向前，就是视角的前方
                local moveVec = (look * -math.sign(hum.MoveDirection:Dot(camCF.LookVector)) * hum.MoveDirection.Magnitude)
                -- 极简直接算法：
                local rawDir = hum.MoveDirection
                -- 修正：直接使用相机 LookVector 的水平投影
                root.CFrame = root.CFrame + (rawDir * cfg.speed * dt)
                -- 如果上面的 rawDir 还是反的，请使用下面的逻辑：
                -- root.CFrame = root.CFrame + (Vector3.new(look.X, look.Y, look.Z).Unit * cfg.speed * dt)
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

-- --- 3. 星空 UI ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 160, 0, 300)
    main.Position = UDim2.new(0.5, -80, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main)

    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(60, 80, 150), Color3.fromRGB(15, 15, 30))
    grad.Rotation = 45

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(150, 180, 255)
    stroke.Thickness = 1.5

    local bar = Instance.new("TextButton", main)
    bar.Size = UDim2.new(1, 0, 0, 32); bar.BackgroundTransparency = 1; bar.Text = "  ✧ XU STAR V15"; bar.TextColor3 = Color3.new(1,1,1); bar.TextXAlignment = 0; bar.Font = Enum.Font.GothamBold

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -85); content.Position = UDim2.new(0, 0, 0, 32); content.BackgroundTransparency = 1; content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.new(0.8,0.8,1); l.BackgroundTransparency = 1; l.TextSize = 10
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 35, 0, 22); b1.Position = UDim2.new(0.15, 0, 0, y+20); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,70); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 35, 0, 22); b2.Position = UDim2.new(0.65, 0, 0, y+20); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,70); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("移动速度", 5, "speed", 10)
    addRow("光环半径", 55, "radius", 1)
    addRow("高度偏移", 105, "offY", 1)
    addRow("转速调节", 155, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 28); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(70, 100, 200) or Color3.fromRGB(30, 30, 45)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 11
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(70, 100, 200) or Color3.fromRGB(30, 30, 45)
        end)
    end

    createToggle("开启视角飞行", 215, "fly")
    createToggle("中心跟随头部", 250, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 45); toggle.Position = UDim2.new(0, 0, 1, -45); toggle.Text = "✦ 激活星空核心"; toggle.BackgroundColor3 = Color3.fromRGB(50, 70, 150); toggle.TextColor3 = Color3.new(1,1,1)

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "关闭重置" or "✦ 激活星空核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 70, 150)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- 拖动逻辑
    local dragData = { Dragging = false, StartTouch = nil, StartPos = nil }
    bar.InputBegan:Connect(function(input)
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
    UserInputService.InputEnded:Connect(function() dragData.Dragging = false end)
end

createUI()
