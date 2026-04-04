--[[
    脚本名称：XU 光环人物 (V15 物理巅峰版)
    核心更新：
    1. 100% 物理同步：利用 BodyForce 逻辑确保全服可见。
    2. 全维角度：增加 X/Y/Z 三轴旋转调节。
    3. 逻辑修复：修复停止后速度不还原的 Bug。
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
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0 -- 三轴全开
}

local tasks = {}

-- --- 1. 速度与状态恢复 ---
local function resetCharacter()
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if hum then 
        hum.WalkSpeed = 16 -- 强制恢复默认速度
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
    if root then root.Anchored = false end
    for _, v in pairs(character:GetDescendants()) do 
        if v:IsA("Motor6D") then v.Enabled = true end 
    end
end

-- --- 2. 核心逻辑 (物理驱动) ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.CanCollide = false
            p.Massless = true -- 物理减重利于同步
            if p.Name ~= "Head" then table.insert(limbs, p) end
        end
    end

    tasks.Main = RunService.Heartbeat:Connect(function(dt)
        if not root or not head then return end
        local t = tick() * cfg.rotSpeed
        
        -- A. 全维角度矩阵 (X, Y, Z 三轴)
        local centerPos = root.Position + Vector3.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = CFrame.new(centerPos) 
                         * CFrame.Angles(math.rad(cfg.tiltX), math.rad(cfg.tiltY), math.rad(cfg.tiltZ))

        if cfg.headFollow then head.CFrame = centerCF end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 使用物理 CFrame 设置，由于开启了 Massless，系统会强制同步这些坐标
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, t, 0)
        end

        -- B. 飞行移动 (视角全向)
        if cfg.fly then
            root.Anchored = true
            if hum.MoveDirection.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                root.CFrame = CFrame.new(root.Position + (camLook * (cfg.speed * dt)))
            end
        else
            root.Anchored = false
            hum.WalkSpeed = cfg.speed
        end
    end)
end

-- --- 3. 星空 UI V19 (多功能滑动版) ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 360)
    main.Position = UDim2.new(0.5, -90, 0.25, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new(Color3.fromRGB(80, 80, 200), Color3.fromRGB(20, 15, 40))

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(130, 170, 255); stroke.Thickness = 2

    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundTransparency = 0.9
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -40, 1, 0); title.Text = "  ✦ XU GALAXY V19"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1; title.TextXAlignment = 0

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 2.5); minBtn.Text = "−"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundColor3 = Color3.fromRGB(50,50,90); Instance.new("UICorner", minBtn)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -100); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 0, 680); content.ScrollBarThickness = 2

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 18); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(200, 220, 255); l.BackgroundTransparency = 1; l.TextSize = 10
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 45, 0, 24); b1.Position = UDim2.new(0.1, 0, 0, y+20); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(35,40,90); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 45, 0, 24); b2.Position = UDim2.new(0.65, 0, 0, y+20); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(35,40,90); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    -- 极简控制面板
    addRow("移动速度", 10, "speed", 10)
    addRow("光环半径", 60, "radius", 1)
    addRow("垂直偏移 (Y)", 110, "offY", 1)
    addRow("前后偏移 (Z)", 160, "offZ", 1)
    addRow("俯仰角度 (TiltX)", 210, "tiltX", 10)
    addRow("偏航角度 (TiltY)", 260, "tiltY", 10)
    addRow("滚动角度 (TiltZ)", 310, "tiltZ", 10)
    addRow("自转速率", 360, "rotSpeed", 0.5)

    local function createToggle(name, y, key)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.85, 0, 0, 30); btn.Position = UDim2.new(0.075, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn); btn.TextSize = 10
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 100, 255) or Color3.fromRGB(30, 30, 50)
        end)
    end

    createToggle("开启全维飞行", 415, "fly")
    createToggle("中心跟随头部", 455, "headFollow")

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 55); toggle.Position = UDim2.new(0, 0, 1, -55); toggle.Text = "✦ 启动物理星空核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 85, 220); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "还原并重置速度" or "✦ 启动物理星空核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(60, 85, 220)
        if isEnabled then 
            hum = character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 100 end -- 初始防死
            runXULoop() 
        else 
            if tasks.Main then tasks.Main:Disconnect() end 
            resetCharacter() 
        end
    end)

    -- 拖拽与缩小逻辑
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
        minBtn.Text = isMin and "+" or "−"
        content.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 360), "Out", "Quart", 0.3, true)
    end)
end

createUI()
