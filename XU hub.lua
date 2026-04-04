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
    fly = false,        -- 上帝飞行模式
    headFollow = true,  -- 头部跟随开关
    radius = 6,
    rotSpeed = 2,
    offY = 0, offZ = 0, offX = 0,
    tiltX = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 防死与关节锁定 ---
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

-- --- 2. 核心移动与坐标计算 ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and (not cfg.headFollow or p.Name ~= "Head") then
            -- 如果开启头部跟随，则头部也加入控制列表，但不进入圆周运动
            if p.Name ~= "Head" then table.insert(limbs, p) end
            p.CanCollide = false
        end
    end

    tasks.Main = RunService.RenderStepped:Connect(function(dt)
        if not root or not head then return end
        local t = tick() * cfg.rotSpeed
        
        -- 计算基础中心点 (Root + 偏移)
        local baseCF = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local ringRot = CFrame.Angles(cfg.tiltX, 0, cfg.tiltZ)
        local centerCF = baseCF * ringRot

        -- A. 头部跟随逻辑
        if cfg.headFollow then
            head.CFrame = centerCF -- 头部直接锁定在光环中心
            head.Velocity = Vector3.new(0,0,0)
        end

        -- B. 四肢光环圆周运动
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            part.CFrame = centerCF * CFrame.new(lPos) * CFrame.Angles(t, 0, 0)
        end

        -- C. 视角飞行移动 (彻底修复方向)
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.fly then
                root.Anchored = true
                -- 核心修复：基于相机 CFrame 计算移动向量
                -- hum.MoveDirection 是相对于世界坐标的，我们需要将其转换
                local moveDir = cam.CFrame:VectorToWorldSpace(Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z))
                -- 移除微小的 Y 轴偏差确保平稳，如果想垂直飞，可以用 LookVector
                if math.abs(hum.MoveDirection.Z) > 0.1 then
                   moveDir = (cam.CFrame.LookVector * -hum.MoveDirection.Z) + (cam.CFrame.RightVector * hum.MoveDirection.X)
                end
                root.CFrame = root.CFrame + (moveDir.Unit * cfg.speed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.speed
            end
        else
            if cfg.fly then root.Velocity = Vector3.new(0,0,0) end
        end
    end)
end

-- --- 3. UI 构建 ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 340)
    main.Position = UDim2.new(0.5, -90, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(80, 100, 255)

    local bar = Instance.new("TextButton", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundColor3 = Color3.fromRGB(40, 45, 80); bar.Text = "  XU 光环 V11"; bar.TextColor3 = Color3.new(1,1,1); bar.TextXAlignment = 0; bar.AutoButtonColor = false

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 35, 1, 0); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "—"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundTransparency = 1

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -95); content.Position = UDim2.new(0, 0, 0, 35); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 0, 520); content.ScrollBarThickness = 0

    local function addRow(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 12
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 45, 0, 25); b1.Position = UDim2.new(0.15, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(50,55,90); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 45, 0, 25); b2.Position = UDim2.new(0.6, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(50,55,90); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addRow("移动速度", 10, "speed", 10)
    addRow("光环半径", 65, "radius", 1)
    addRow("上下偏移", 120, "offY", 1)
    addRow("光环倾斜X", 175, "tiltX", 0.2)
    addRow("旋转速度", 230, "rotSpeed", 0.5)

    -- 开关组
    local function createToggle(name, y, key, callback)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(0.8, 0, 0, 30); btn.Position = UDim2.new(0.1, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
        btn.Text = name .. (cfg[key] and ": ON" or ": OFF"); btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
        btn.Activated:Connect(function()
            cfg[key] = not cfg[key]
            btn.Text = name .. (cfg[key] and ": ON" or ": OFF")
            btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
            if callback then callback() end
        end)
    end

    createToggle("上帝飞行", 290, "fly")
    createToggle("头部跟随", 330, "headFollow", function()
        -- 切换头部跟随需要重启循环
        if isEnabled then 
            if tasks.Main then tasks.Main:Disconnect() end
            runXULoop() 
        end
    end)

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50); toggle.Text = "开启 XU 核心"; toggle.BackgroundColor3 = Color3.fromRGB(50, 100, 250); toggle.TextColor3 = Color3.new(1,1,1)

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "停止重置" or "开启 XU 核心"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(150, 50, 50) or Color3.fromRGB(50, 100, 250)
        if isEnabled then setSafety(true); runXULoop() else if tasks.Main then tasks.Main:Disconnect() end setSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false end
    end)

    -- --- 触屏拖动 ---
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
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragData.Dragging = false
        end
    end)

    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "—"
        content.Visible = not isMin
        toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 340), "Out", "Quart", 0.3, true)
    end)
end

createUI()
