--[[
    ✦ XU GALAXY V30 - 物理平滑同步版 ✦
    解决：行走卡顿、FE 别人看不见、UI 显示异常
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    HeadFollow = true, BackdoorFound = "Searching...", CurrentVelocity = 0
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local activeBackdoor = nil

-- --- 1. 增强型后门搜索 ---
local function findBackdoor()
    local list = {game:GetService("JointsService"), game:GetService("LogService"), game:GetService("RobloxReplicatedStorage")}
    for _, s in pairs(list) do
        pcall(function()
            for _, v in pairs(s:GetDescendants()) do
                if v:IsA("RemoteEvent") then activeBackdoor = v return end
            end
        end)
    end
end

-- --- 2. 物理平滑同步 (解决卡顿关键) ---
local function togglePhysics(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.Health = 100
        -- 物理伪装：不锚定根部，而是通过 CFrame 强制补位
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = false
                v.Massless = true
            end
        end
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
        end
    end
end

-- --- 3. 全服广播协议 ---
local function broadcast(part, cf)
    if not activeBackdoor then return end
    pcall(function()
        -- 尝试多种服务器端可识别的同步指令
        activeBackdoor:FireServer("CFrame", part, cf)
        activeBackdoor:FireServer("SetCFrame", part, cf)
        activeBackdoor:FireServer(part, cf)
    end)
end
-- --- 4. 核心几何驱动引擎 (平滑同步版) ---
local function initGalaxyLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local cam = workspace.CurrentCamera
    local limbs = {}

    -- 收集肢体并初始化物理属性
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            p.Massless = true
            p.CanCollide = false
        end
    end

    -- 使用 Stepped 而非 RenderStepped 以匹配物理引擎频率，减少抖动
    tasks.Loop = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled or not root then return end
        
        -- 基础数值监控
        hum.Health = 100
        _G.XU_Config.CurrentVelocity = math.floor(root.Velocity.Magnitude)

        -- A. 平滑飞行逻辑 (非锚定方案)
        if _G.XU_Config.Fly then
            -- 使用力平衡或直接 CFrame 补偿，不使用 Anchored=true 以防别人看你卡死
            local moveDir = Vector3.new(0,0,0)
            if hum.MoveDirection.Magnitude > 0 then
                moveDir = cam.CFrame.LookVector
            end
            -- 核心：平滑坐标推演
            root.CFrame = root.CFrame:Lerp(root.CFrame + (moveDir * _G.XU_Config.Speed * dt), 0.8)
            root.Velocity = Vector3.new(0, 0.1, 0) -- 给一个极小的向上力，防止物理引擎判定休眠
        else
            hum.WalkSpeed = _G.XU_Config.Speed
        end

        -- B. 六轴星环算法 (支持 X/Y/Z 偏移与旋转)
        local t = tick() * _G.XU_Config.RotSpeed
        
        -- 1. 计算中心点（包含三轴偏移）
        local centerPos = root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ)
        
        -- 2. 构建旋转平面矩阵 (Tilt X/Y/Z)
        local rotMatrix = CFrame.Angles(
            math.rad(_G.XU_Config.TiltX), 
            math.rad(_G.XU_Config.TiltY), 
            math.rad(_G.XU_Config.TiltZ)
        )
        local centerCF = CFrame.new(centerPos) * rotMatrix

        -- 头部同步
        if _G.XU_Config.HeadFollow and head then
            head.CFrame = centerCF
        end

        -- 3. 肢体环绕与后门广播
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local circleOffset = Vector3.new(
                math.cos(angle) * _G.XU_Config.Radius, 
                0, 
                math.sin(angle) * _G.XU_Config.Radius
            )
            
            -- 计算最终目标坐标
            local targetCF = centerCF * CFrame.new(circleOffset) * CFrame.Angles(t, t, t/2)
            
            -- 【全服可见核心】
            -- 调用 Part 1 的广播函数，将坐标推送到服务器
            if _G.XU_Config.Enabled then
                broadcast(part, targetCF)
            end
            
            -- 本地渲染
            part.CFrame = targetCF
        end
    end)
end

-- --- 5. 启动接口 ---
_G.StartGalaxy = function()
    findBackdoor()
    togglePhysics(true)
    initGalaxyLoop()
    _G.XU_Config.BackdoorFound = activeBackdoor and "SYNC ACTIVE" or "LOCAL ONLY"
end

_G.StopGalaxy = function()
    if tasks.Loop then tasks.Loop:Disconnect() end
    togglePhysics(false)
end
-- --- 6. 微型星空 UI (Nano Space V30) ---
local function createNanoUI()
    -- 清理旧 UI
    if CoreGui:FindFirstChild("XU_Nano_V30") then CoreGui.XU_Nano_V30:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Nano_V30"
    sg.ResetOnSpawn = false

    -- 主面板 (改为固定微型尺寸，防止折叠异常)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 160, 0, 280) 
    main.Position = UDim2.new(0.5, -80, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
    main.BackgroundTransparency = 0.2 -- 半透明毛玻璃感
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- 流光霓虹边框 (星空感)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(0, 150, 255)
    spawn(function()
        while true do
            local t = TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(200, 50, 255)})
            t:Play(); t.Completed:Wait()
            local t2 = TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(0, 150, 255)})
            t2:Play(); t2.Completed:Wait()
        end
    end)

    -- 极简标题
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 25); title.Text = "✧ GALAXY V30 ✧"; title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold; title.TextSize = 10; title.BackgroundTransparency = 1

    -- 实时看板 (极小化显示)
    local mon = Instance.new("TextLabel", main)
    mon.Size = UDim2.new(1, -10, 0, 45); mon.Position = UDim2.new(0, 5, 0, 25)
    mon.BackgroundColor3 = Color3.new(0, 0, 0); mon.BackgroundTransparency = 0.8
    mon.TextColor3 = Color3.fromRGB(0, 255, 180); mon.Font = Enum.Font.Code; mon.TextSize = 8; mon.RichText = true
    Instance.new("UICorner", mon)

    RunService.RenderStepped:Connect(function()
        local c = _G.XU_Config
        mon.Text = string.format(" [SYNC]: %s | [V]: %d\n [ROT]: %d,%d,%d\n [OFF]: %.f,%.f,%.f", 
            c.BackdoorFound, c.CurrentVelocity, c.TiltX, c.TiltY, c.TiltZ, c.OffX, c.OffY, c.OffZ)
    end)

    -- 调节区滚动列表
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -6, 1, -120); scroll.Position = UDim2.new(0, 3, 0, 75)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 500); scroll.ScrollBarThickness = 1

    local function addRow(text, y, key, min, max, step)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -4, 0, 32); f.Position = UDim2.new(0, 2, 0, y); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 12); l.Text = text; l.TextColor3 = Color3.new(0.6,0.7,1); l.TextSize = 8; l.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0, 25, 0, 15); b1.Position = UDim2.new(0, 2, 0, 14); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,70); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0, 25, 0, 15); b2.Position = UDim2.new(1, -27, 0, 14); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,70); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1, -60, 0, 15); v.Position = UDim2.new(0, 30, 0, 14); v.Text = tostring(_G.XU_Config[key]); v.TextColor3 = Color3.new(1,1,1); v.BackgroundTransparency = 0.9; v.BackgroundColor3 = Color3.new(1,1,1)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key]-step); v.Text = tostring(_G.XU_Config[key]) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key]+step); v.Text = tostring(_G.XU_Config[key]) end)
    end

    -- 部署调节（全六轴方向 + 速度）
    addRow("MOVE SPEED", 0, "Speed", 0, 800, 10)
    addRow("RING RADIUS", 35, "Radius", 1, 80, 1)
    addRow("OFFSET Y", 70, "OffY", -80, 80, 1)
    addRow("OFFSET X", 105, "OffX", -80, 80, 1)
    addRow("TILT X (角度)", 140, "TiltX", -360, 360, 15)
    addRow("TILT Y (角度)", 175, "TiltY", -360, 360, 15)
    addRow("ROT SPEED", 210, "RotSpeed", 0, 30, 0.5)

    -- 启动核心
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, -16, 0, 35); toggle.Position = UDim2.new(0, 8, 1, -40)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 80, 200); toggle.Text = "INIT CORE"; toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold; toggle.TextSize = 10; Instance.new("UICorner", toggle)

    toggle.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then
            toggle.Text = "RUNNING..."; toggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40); _G.StartGalaxy()
        else
            toggle.Text = "INIT CORE"; toggle.BackgroundColor3 = Color3.fromRGB(40, 80, 200); _G.StopGalaxy()
        end
    end)

    -- 极简拖拽
    local d, s, p; title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s; main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

createNanoUI()
