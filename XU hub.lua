local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false

-- --- 全局物理参数存储 ---
local cfg = {
    moveSpeed = 50,
    orbitDist = 6,
    rotSpeed = 2,
    -- 位移偏移量 (XYZ)
    offX = 0, offY = 0, offZ = 0,
    -- 旋转倾斜量 (Angles)
    tiltX = 0, tiltY = 0, tiltZ = 0
}

local connections = {}

-- --- 1. 深度防护：彻底防止暴毙 ---
local function protectPlayer(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if state then
        -- 核心：禁用死亡检测
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        -- 强制锁定生命值（本地模拟，防止引擎因断肢判定死亡）
        connections.HealthLock = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health <= 0 then hum.Health = hum.MaxHealth end
        end)

        -- 禁用关节同步
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
        end
    else
        -- 恢复
        if connections.HealthLock then connections.HealthLock:Disconnect() end
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        hum.Health = hum.MaxHealth
    end
end

-- --- 2. 核心逻辑：全维度矩阵计算 ---
local function startOmniLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local hum = character:FindFirstChildOfClass("Humanoid")
    
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            p.CanCollide = false
        end
    end

    connections.Main = RunService.Heartbeat:Connect(function(dt)
        local t = tick() * cfg.rotSpeed
        
        for i, part in ipairs(limbs) do
            -- 基础环绕计算
            local angle = (i / #limbs) * math.pi * 2 + t
            local basePos = Vector3.new(
                math.cos(angle) * cfg.orbitDist,
                math.sin(t + i) * 0.5, 
                math.sin(angle) * cfg.orbitDist
            )
            
            -- 应用用户自定义偏移 (向上/下, 左/右, 前/后)
            local userOffset = Vector3.new(cfg.offX, cfg.offY, cfg.offZ)
            
            -- 应用全向倾斜角度 (Tilt/Pitch/Roll)
            local userRotation = CFrame.Angles(cfg.tiltX, cfg.tiltY + angle, cfg.tiltZ)
            
            -- 最终 CFrame 合成
            part.CFrame = head.CFrame * CFrame.new(basePos + userOffset) * userRotation
        end

        -- 传送移动
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * cfg.moveSpeed * dt)
        end
    end)
end

-- --- 3. UI 构建：星空全维控制台 ---
local function buildUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "LimeHub_OmniV4"

    -- [ 状态监控板 ]
    local monitor = Instance.new("Frame", sg)
    monitor.Size = UDim2.new(0, 180, 0, 130)
    monitor.Position = UDim2.new(0.02, 0, 0.02, 0)
    monitor.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    Instance.new("UICorner", monitor)
    
    local log = Instance.new("TextLabel", monitor)
    log.Size = UDim2.new(1, -10, 1, -10)
    log.Position = UDim2.new(0, 5, 0, 5)
    log.TextColor3 = Color3.fromRGB(0, 200, 255)
    log.TextSize = 12
    log.Font = Enum.Font.Code
    log.TextXAlignment = Enum.TextXAlignment.Left
    log.BackgroundTransparency = 1

    RunService.RenderStepped:Connect(function()
        log.Text = string.format(
            "◆ OMNI STATUS: %s\n◆ OFFSET_Y (上下): %.1f\n◆ OFFSET_X (左右): %.1f\n◆ OFFSET_Z (前后): %.1f\n◆ TILT_X (俯仰): %.1f\n◆ TILT_Z (翻滚): %.1f",
            isEnabled and "RUNNING" or "IDLE", cfg.offY, cfg.offX, cfg.offZ, cfg.tiltX, cfg.tiltZ
        )
    end)

    -- [ 控制调节轴 ]
    local scroll = Instance.new("ScrollingFrame", sg)
    scroll.Size = UDim2.new(0, 120, 0, 350)
    scroll.Position = UDim2.new(0.02, -150, 0.25, 0)
    scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    scroll.ScrollBarThickness = 2
    Instance.new("UICorner", scroll)

    local function createBtnGroup(name, y, key, step)
        local l = Instance.new("TextLabel", scroll)
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name
        l.TextColor3 = Color3.new(1, 1, 1)
        l.BackgroundTransparency = 1
        
        local btnA = Instance.new("TextButton", scroll)
        btnA.Size = UDim2.new(0.4, 0, 0, 30)
        btnA.Position = UDim2.new(0.55, 0, 0, y + 25)
        btnA.Text = "+"
        btnA.BackgroundColor3 = Color3.fromRGB(30, 40, 100)
        Instance.new("UICorner", btnA)

        local btnB = Instance.new("TextButton", scroll)
        btnB.Size = UDim2.new(0.4, 0, 0, 30)
        btnB.Position = UDim2.new(0.05, 0, 0, y + 25)
        btnB.Text = "-"
        btnB.BackgroundColor3 = Color3.fromRGB(30, 40, 100)
        Instance.new("UICorner", btnB)

        btnA.MouseButton1Click:Connect(function() cfg[key] = cfg[key] + step end)
        btnB.MouseButton1Click:Connect(function() cfg[key] = cfg[key] - step end)
    end

    -- 布局所有调节器
    createBtnGroup("移动速度", 10, "moveSpeed", 10)
    createBtnGroup("环绕距离", 70, "orbitDist", 1)
    createBtnGroup("上下偏移", 130, "offY", 1)
    createBtnGroup("左右偏移", 190, "offX", 1)
    createBtnGroup("前后偏移", 250, "offZ", 1)
    createBtnGroup("俯仰倾斜", 310, "tiltX", 0.2)
    createBtnGroup("翻滚倾斜", 370, "tiltZ", 0.2)
    createBtnGroup("旋转速度", 430, "rotSpeed", 0.5)

    -- [ 主开关 ]
    local main = Instance.new("TextButton", sg)
    main.Size = UDim2.new(0, 150, 0, 50)
    main.Position = UDim2.new(0.5, -75, 0.9, 0)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    main.Text = "开启上帝模式"
    main.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", main)

    main.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            protectPlayer(true)
            startOmniLoop()
            main.Text = "重置并恢复"
            main.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
            scroll:TweenPosition(UDim2.new(0.02, 0, 0.25, 0), "Out", "Back", 0.5)
        else
            if connections.Main then connections.Main:Disconnect() end
            protectPlayer(false)
            character:FindFirstChild("HumanoidRootPart").Anchored = false
            main.Text = "开启上帝模式"
            main.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
            scroll:TweenPosition(UDim2.new(0.02, -150, 0.25, 0), "In", "Quart", 0.5)
        end
    end)
end

-- 启动
buildUI()
