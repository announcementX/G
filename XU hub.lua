--[[
    脚本名称：XU 光环人物 (V17 坐标系分离版)
    核心修复：
    1. 旋转分离：镜头转动不再带动光环旋转，光环保持水平。
    2. 飞行修正：依然可以看哪飞哪，但身体不会乱转。
    3. UI 修复：找回缩小键，增加星空动态效果。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

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

-- --- 1. 安全防护 ---
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

-- --- 2. 核心逻辑 (旋转分离算法) ---
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
        
        -- 【核心修复】使用绝对世界坐标，不继承 RootPart 的旋转
        -- 这样无论你面向哪，光环的 0 度角永远指向世界坐标的正北
        local centerPos = root.Position + Vector3.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = CFrame.new(centerPos) * CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)

        if cfg.headFollow then
            head.CFrame = centerCF
        end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 这里的旋转也是基于世界的
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, t*0.5, 0)
        end

        -- --- 飞行移动：方向跟随视角，但身体不随视角转动 ---
        if cfg.fly then
            root.Anchored = true
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- 核心算法：直接取相机朝向作为位移矢量，但不改变 root 的旋转
                local camLook = cam.CFrame.LookVector
                -- 强制位移
                root.Position = root.Position + (camLook * (moveDir.Magnitude * cfg.speed * dt))
            end
        else
            root.Anchored = false
            hum.WalkSpeed = cfg.speed
        end
    end)
end

-- --- 3. 星空 UI V17 (带缩小键修复) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 160, 0, 300)
    main.Position = UDim2.new(0.5, -80, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    -- 动态渐变
    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(80, 100, 255), Color3.fromRGB(20, 20, 40))
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(120, 150, 255)
    stroke.Thickness = 1.5

    -- 标题栏
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 35)
    bar.BackgroundTransparency = 0.9
    
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Text = " ✦ XU NEBULA"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1; title.TextXAlignment = 0; title.TextSize = 12

    -- 【找回缩小键】
    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -35, 0, 2)
    minBtn.Text = "−"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundColor3 = Color3.fromRGB(50,50,80); minBtn.TextSize = 20; Instance.new("UICorner", minBtn)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -95); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(200, 220, 255); l.BackgroundTransparency = 1; l.TextSize = 10
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 40, 0, 22); b1.Position = UDim2.new(0.1, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,45,90); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 40, 0, 22); b2.Position = UDim2.new(0.6, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,45,90); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("全维飞行速度", 10, "speed", 10)
    addRow("光环半径", 65, "radius", 1)
    addRow("垂直偏移", 120, "offY", 1)
    addRow("自转速率", 175, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 28); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 11
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        end)
    end

    createToggle("开启全维视角飞行", 235, "fly")
    createToggle("头部跟随中心", 275, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50); toggle.Text = "✦ 激活星空核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 80, 200); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止重置" or "✦ 激活星空核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(60, 80, 200)
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

    -- 缩小功能修复
    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "−"
        content.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 160, 0, 35) or UDim2.new(0, 160, 0, 300), "Out", "Quart", 0.3, true)
    end)
end

createUI()
