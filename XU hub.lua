--[[
    脚本名称：XU 光环人物 (V8 完美适配版)
    更新：
    1. 修复 UI 拖动：标题栏现在 100% 可拖动。
    2. 修复 UI 折叠：缩小后内容隐藏，不再重叠，点击恢复按钮必响应。
    3. 修复上帝模式跟随：解决锚定状态下肢体掉队的问题。
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
    flyMode = false,
    radius = 6,
    rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0
}

local tasks = {}

-- --- 1. 防死系统 ---
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

-- --- 2. 核心跟随逻辑 (强制坐标对齐) ---
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
        if not root then return end
        local t = tick() * cfg.rotSpeed
        
        -- 矩阵合成：每一帧都以 RootPart 的最新位置作为基准
        local baseCFrame = root.CFrame * CFrame.new(cfg.offX, cfg.offY, cfg.offZ)
        local ringRot = CFrame.Angles(cfg.tiltX, cfg.tiltY, cfg.tiltZ)

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local localPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            -- 即使上帝模式下 root.Anchored = true，这里也会实时跟随
            part.CFrame = (baseCFrame * ringRot) * CFrame.new(localPos) * CFrame.Angles(t, 0, 0)
        end

        -- 移动控制
        if hum.MoveDirection.Magnitude > 0 then
            if cfg.flyMode then
                root.Anchored = true
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local moveDir = (look * -hum.MoveDirection.Z) + (right * hum.MoveDirection.X)
                root.CFrame = root.CFrame + (moveDir.Unit * cfg.moveSpeed * dt)
            else
                root.Anchored = false
                hum.WalkSpeed = cfg.moveSpeed
            end
        else
            if cfg.flyMode then root.Velocity = Vector3.new(0,0,0) end
        end
    end)
end

-- --- 3. UI 界面构建 ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Ring_V8"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 200, 0, 350)
    main.Position = UDim2.new(0.1, 0, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    Instance.new("UICorner", main)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(100, 100, 255)

    -- 标题栏 (拖动区域)
    local titleBar = Instance.new("TextButton", main)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
    titleBar.Text = "  XU 光环人物 V8"
    titleBar.TextColor3 = Color3.new(1, 1, 1)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.AutoButtonColor = false

    -- 最小化
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -35, 0, 2)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.BackgroundTransparency = 1
    minBtn.TextSize = 20

    -- 内容容器
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -85)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 600)
    content.ScrollBarThickness = 2

    -- 显示看板
    local info = Instance.new("TextLabel", content)
    info.Size = UDim2.new(1, -20, 0, 80)
    info.Position = UDim2.new(0, 10, 0, 5)
    info.TextColor3 = Color3.fromRGB(0, 255, 255)
    info.TextSize = 12
    info.Font = Enum.Font.Code
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.BackgroundTransparency = 1
    
    RunService.RenderStepped:Connect(function()
        info.Text = string.format("移动模式: %s\n坐标偏移: %.1f, %.1f\n倾斜角度: %.1f, %.1f\n光环跟随: 正常", 
            cfg.flyMode and "上帝飞行" or "常规行走", cfg.offX, cfg.offY, cfg.tiltX, cfg.tiltZ)
    end)

    -- 调节器
    local function addSet(name, y, key, step)
        local l = Instance.new("TextLabel", content)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y)
        l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", content)
        b1.Size = UDim2.new(0, 40, 0, 25); b1.Position = UDim2.new(0.2, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(50,50,100); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", content)
        b2.Size = UDim2.new(0, 40, 0, 25); b2.Position = UDim2.new(0.6, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(50,50,100); Instance.new("UICorner", b2)
        b1.MouseButton1Click:Connect(function() cfg[key] = cfg[key] - step end)
        b2.MouseButton1Click:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addSet("移动速度", 90, "moveSpeed", 10)
    addSet("光环半径", 145, "radius", 1)
    addSet("上下偏移", 200, "offY", 1)
    addSet("前后偏移", 255, "offZ", 1)
    addSet("左右偏移", 310, "offX", 1)
    addSet("倾斜 X", 365, "tiltX", 0.2)
    addSet("倾斜 Z", 420, "tiltZ", 0.2)

    -- 模式切换
    local mBtn = Instance.new("TextButton", content)
    mBtn.Size = UDim2.new(0.8, 0, 0, 30); mBtn.Position = UDim2.new(0.1, 0, 0, 500)
    mBtn.Text = "切换模式"; mBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); mBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", mBtn)
    mBtn.MouseButton1Click:Connect(function()
        cfg.flyMode = not cfg.flyMode
        mBtn.Text = cfg.flyMode and "上帝飞行模式" or "常规行走模式"
        mBtn.BackgroundColor3 = cfg.flyMode and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(60, 60, 60)
    end)

    -- 总开关
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 50); toggle.Position = UDim2.new(0, 0, 1, -50)
    toggle.Text = "启动脚本"; toggle.BackgroundColor3 = Color3.fromRGB(50, 60, 150); toggle.TextColor3 = Color3.new(1,1,1)

    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggleSafety(true); startLoop()
            toggle.Text = "关闭/重置"; toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        else
            if tasks.Main then tasks.Main:Disconnect() end
            toggleSafety(false); character:FindFirstChild("HumanoidRootPart").Anchored = false
            toggle.Text = "启动脚本"; toggle.BackgroundColor3 = Color3.fromRGB(50, 60, 150)
        end
    end)

    -- --- 修复拖动 ---
    local dragging, dragStart, startPos
    titleBar.MouseButton1Down:Connect(function()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = main.Position
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local curr = UserInputService:GetMouseLocation()
            local delta = curr - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- --- 修复最小化 ---
    local isMin = false
    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        minBtn.Text = isMin and "+" or "—"
        content.Visible = not isMin
        toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 350), "Out", "Quart", 0.3, true)
    end)
end

createUI()
