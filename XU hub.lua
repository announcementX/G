--[[
    脚本名称：XU 光环人物 (V18 物理同步版)
    核心更新：
    1. 物理驱动：使用物理属性确保其他玩家可见。
    2. 坐标调节：找回光环偏移 (OffX/Y/Z) 和 角度 (TiltX/Z)。
    3. 全向飞行：修复飞行方向，优化星空 UI。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 核心配置 (找回了偏移和旋转) ---
local cfg = {
    speed = 60,
    fly = false,        
    headFollow = true,  
    radius = 6,
    rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0, -- 光环移动偏移
    tiltX = 0, tiltZ = 0          -- 光环方向调节
}

local tasks = {}

-- --- 1. 强制物理所有权 (让别人看见的关键) ---
local function setPhysics()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        -- 尝试声明网络所有权（部分游戏环境可能受限）
        settings().Physics.AllowSleep = false
    end
end

local function setSafety(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        for _, v in pairs(character:GetDescendants()) do 
            if v:IsA("Motor6D") then v.Enabled = false end 
        end
    else
        for _, v in pairs(character:GetDescendants()) do 
            if v:IsA("Motor6D") then v.Enabled = true end 
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end

-- --- 2. 核心逻辑 ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    
    setPhysics()

    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.CanCollide = false
            p.Massless = true -- 减轻重量有助于物理同步
            if p.Name ~= "Head" then table.insert(limbs, p) end
        end
    end

    tasks.Main = RunService.RenderStepped:Connect(function(dt)
        if not root or not head then return end
        local t = tick() * cfg.rotSpeed
        
        -- A. 计算光环中心 (应用 OffX/Y/Z 和 TiltX/Z)
        -- 这里使用世界坐标系，保证光环方向是你手动设定的，不随镜头乱转
        local centerPos = root.Position + Vector3.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = CFrame.new(centerPos) * CFrame.Angles(math.rad(cfg.tiltX), 0, math.rad(cfg.tiltZ))

        if cfg.headFollow then
            head.CFrame = centerCF
        end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 物理更新 CFrame（RenderStepped 频率最高，同步效果最好）
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, t, t)
        end

        -- B. 飞行移动 (全维度)
        if cfg.fly then
            root.Anchored = true
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                -- 核心：位移同步
                root.CFrame = CFrame.new(root.Position + (camLook * (cfg.speed * dt)))
            end
        else
            root.Anchored = false
            hum.WalkSpeed = cfg.speed
        end
    end)
end

-- --- 3. 星空 UI V18 (功能全回归) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 350)
    main.Position = UDim2.new(0.5, -90, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main)

    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(70, 80, 180), Color3.fromRGB(15, 15, 30))

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(100, 130, 255)
    stroke.Thickness = 2

    -- 标题栏
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundTransparency = 0.9
    
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(0.7, 0, 1, 0); title.Text = " ✦ XU NEBULA V18"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1; title.TextXAlignment = 0; title.TextSize = 11

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 2); minBtn.Text = "−"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundColor3 = Color3.fromRGB(40,40,70); Instance.new("UICorner", minBtn)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -95); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 0, 600); content.ScrollBarThickness = 2

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(180, 200, 255); l.BackgroundTransparency = 1; l.TextSize = 10
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 45, 0, 22); b1.Position = UDim2.new(0.1, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(30,35,80); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 45, 0, 22); b2.Position = UDim2.new(0.6, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(30,35,80); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    -- 找回的控制项
    addRow("飞行速度", 10, "speed", 10)
    addRow("光环半径", 60, "radius", 1)
    addRow("垂直偏移 (Y)", 110, "offY", 1)
    addRow("前后偏移 (Z)", 160, "offZ", 1)
    addRow("倾斜角度 (TiltX)", 210, "tiltX", 5)
    addRow("公转速度", 260, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 30); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(60, 100, 220) or Color3.fromRGB(30, 30, 40)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 10
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(60, 100, 220) or Color3.fromRGB(30, 30, 40)
        end)
    end

    createToggle("开启全维视角飞行", 310, "fly")
    createToggle("中心锁定头部", 350, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50); toggle.Text = "✦ 启动物理星空"; toggle.BackgroundColor3 = Color3.fromRGB(50, 70, 180); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止重置" or "✦ 启动物理星空"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 70, 180)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- 拖动
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

    -- 缩小
    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "−"
        content.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 350), "Out", "Quart", 0.3, true)
    end)
end

createUI()
