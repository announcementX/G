--[[
    ✦ XU GALAXY CORE V28 ✦
    主题：Nebula Minimal (星云极简)
    特性：超小悬浮窗、深度后门、防死系统、星空美学
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    HeadFollow = true, BackdoorFound = "Scanning...", CurrentVelocity = 0
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local tasks = {}
local activeBackdoor = nil

-- --- 1. 幽灵后门探测 (深度递归) ---
local function performDeepScan()
    local hidden = {game:GetService("JointsService"), game:GetService("LogService"), game:GetService("RobloxReplicatedStorage")}
    local found = nil
    for _, s in pairs(hidden) do
        pcall(function()
            for _, v in pairs(s:GetDescendants()) do
                if v:IsA("RemoteEvent") then found = v; break end
            end
        end)
        if found then break end
    end
    activeBackdoor = found
    _G.XU_Config.BackdoorFound = found and "FOUND" or "NONE"
end

-- --- 2. 防死与灵体化逻辑 ---
local function toggleState(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.Health = 100
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = false; v.Massless = true
            end
        end
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
        end
        hum.WalkSpeed = 16
    end
end
-- --- 3. 核心几何驱动引擎 (物理全同步) ---
local function initGalaxyLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local cam = workspace.CurrentCamera
    local limbs = {}
    
    -- 智能肢体识别
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
        end
    end

    -- 高频渲染同步 (锁定物理判定)
    tasks.Loop = RunService.RenderStepped:Connect(function(dt)
        if not _G.XU_Config.Enabled or not root then return end
        
        -- 实时生命维持与状态镜像
        hum.Health = 100
        _G.XU_Config.CurrentVelocity = math.floor(root.Velocity.Magnitude)

        -- A. 极简视角飞行驱动
        if _G.XU_Config.Fly then
            root.Anchored = true
            root.Velocity = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then
                -- 核心：基于摄像机LookVector的精准位移
                local moveDirection = cam.CFrame.LookVector
                root.CFrame = root.CFrame + (moveDirection * _G.XU_Config.Speed * dt)
            end
        else
            root.Anchored = false
            hum.WalkSpeed = _G.XU_Config.Speed
        end

        -- B. 星核轨道算法 (全轴矩阵变换)
        local t = tick() * _G.XU_Config.RotSpeed
        
        -- 计算中心参考点 (应用三轴 Offset)
        local basePos = root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ)
        
        -- 构建旋转平面 (Tilt X/Y/Z)
        local rotCF = CFrame.Angles(
            math.rad(_G.XU_Config.TiltX), 
            math.rad(_G.XU_Config.TiltY), 
            math.rad(_G.XU_Config.TiltZ)
        )
        local centerCF = CFrame.new(basePos) * rotCF

        -- 头部跟随逻辑
        if _G.XU_Config.HeadFollow and head then head.CFrame = centerCF end

        -- 排列肢体星环
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(
                math.cos(angle) * _G.XU_Config.Radius, 
                0, 
                math.sin(angle) * _G.XU_Config.Radius
            )
            
            -- 最终变换矩阵：平移 * 旋转矩阵 * 圆周位移 * 肢体自转
            local targetCF = centerCF * CFrame.new(lPos) * CFrame.Angles(t, t, t/2)
            
            -- 后门通信注入 (如果捕获成功)
            if activeBackdoor then
                pcall(function() 
                    activeBackdoor:FireServer("Update", part.Name, targetCF) 
                end)
            end
            
            -- 强制本地 CFrame 同步
            part.CFrame = targetCF
        end
    end)
end

-- --- 4. 外部调用接口 ---
_G.StartGalaxy = function()
    performDeepScan()
    toggleState(true)
    initGalaxyLoop()
end

_G.StopGalaxy = function()
    if tasks.Loop then tasks.Loop:Disconnect() end
    toggleState(false)
end

print("✦ XU GALAXY PART 2 (Physics Engine) 已就绪...")
-- --- 5. 星空微缩 UI (Nebula Minimalist) ---
local function createNebulaUI()
    -- 清理
    if CoreGui:FindFirstChild("XU_Nebula_V28") then CoreGui.XU_Nebula_V28:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Nebula_V28"
    sg.IgnoreGuiInset = true

    -- 主框架 (极简小巧版)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 200, 0, 40) -- 初始折叠状态
    main.Position = UDim2.new(0.5, -100, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    -- 星空流光边框
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(100, 150, 255)
    spawn(function()
        while true do
            local t = TweenService:Create(stroke, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(255, 100, 255)})
            t:Play(); t.Completed:Wait()
            local t2 = TweenService:Create(stroke, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(100, 150, 255)})
            t2:Play(); t2.Completed:Wait()
        end
    end)

    -- 标题栏 (点击展开/折叠)
    local header = Instance.new("TextButton", main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = "✧ XU NEBULA V28"
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.GothamBold; header.TextSize = 12

    -- 实时监控看板 (Monitor)
    local monitor = Instance.new("TextLabel", main)
    monitor.Size = UDim2.new(1, -20, 0, 60); monitor.Position = UDim2.new(0, 10, 0, 45)
    monitor.BackgroundColor3 = Color3.new(0, 0, 0); monitor.BackgroundTransparency = 0.7
    monitor.TextColor3 = Color3.fromRGB(0, 255, 200); monitor.Font = Enum.Font.Code; monitor.TextSize = 9
    monitor.TextXAlignment = 0; monitor.RichText = true; Instance.new("UICorner", monitor)

    RunService.Heartbeat:Connect(function()
        local c = _G.XU_Config
        monitor.Text = string.format(
            " [BD]: %s | [SPD]: %d\n [ROT]: X%d Y%d Z%d\n [OFF]: X%.f Y%.f Z%.f",
            c.BackdoorFound, c.CurrentVelocity,
            c.TiltX, c.TiltY, c.TiltZ,
            c.OffX, c.OffY, c.OffZ
        )
    end)

    -- 控制滚动列表
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -170); scroll.Position = UDim2.new(0, 5, 0, 110)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 600); scroll.ScrollBarThickness = 1

    local function addAdj(name, y, key, min, max, step)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -10, 0, 35); f.Position = UDim2.new(0, 5, 0, y); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = name; l.TextColor3 = Color3.new(0.7,0.7,1); l.TextSize = 9; l.BackgroundTransparency = 1; l.TextXAlignment = 0
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0, 30, 0, 18); b1.Position = UDim2.new(0, 0, 0, 15); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,70); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0, 30, 0, 18); b2.Position = UDim2.new(1, -30, 0, 15); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,70); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1, -70, 0, 18); v.Position = UDim2.new(0, 35, 0, 15); v.Text = tostring(_G.XU_Config[key]); v.TextColor3 = Color3.new(1,1,1); v.BackgroundTransparency = 0.9; v.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", v)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key]-step); v.Text = tostring(_G.XU_Config[key]) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key]+step); v.Text = tostring(_G.XU_Config[key]) end)
    end

    -- 紧凑调节项
    addAdj("SPEED", 0, "Speed", 0, 500, 10)
    addAdj("RADIUS", 40, "Radius", 1, 50, 1)
    addAdj("OFF Y", 80, "OffY", -50, 50, 1)
    addAdj("OFF X", 120, "OffX", -50, 50, 1)
    addAdj("TILT X", 160, "TiltX", -360, 360, 15)
    addAdj("TILT Y", 200, "TiltY", -360, 360, 15)
    addAdj("ROT RATE", 240, "RotSpeed", 0, 20, 0.5)

    -- 启动与状态切换
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, -20, 0, 40); toggle.Position = UDim2.new(0, 10, 1, -50)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 80, 200); toggle.Text = "ACTIVATE CORE"; toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold; Instance.new("UICorner", toggle)

    local expanded = false
    header.Activated:Connect(function()
        expanded = not expanded
        main:TweenSize(expanded and UDim2.new(0, 200, 0, 400) or UDim2.new(0, 200, 0, 40), "Out", "Quart", 0.4, true)
    end)

    toggle.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then
            toggle.Text = "RUNNING..."; toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50); _G.StartGalaxy()
        else
            toggle.Text = "ACTIVATE CORE"; toggle.BackgroundColor3 = Color3.fromRGB(50, 80, 200); _G.StopGalaxy()
        end
    end)

    -- 拖拽逻辑
    local d, s, p; header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s; main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

createNebulaUI()
print("✦ XU GALAXY V28 - 星核版加载完成！点击标题展开面板。")
