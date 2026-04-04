--[[
    ✦ XU GALAXY OMNI V27 终极拼接版 ✦
    作者：XU Logic
    说明：请将 Part 1, Part 2, Part 3 拼接在一起运行。
    特性：星空 UI、全维度角度控制、幽灵后门探测、高频物理同步。
]]

-- --- 1. 全局配置与状态初始化 ---
_G.XU_Config = {
    Enabled = false,
    Speed = 60,
    Fly = false,
    Radius = 8,
    RotSpeed = 2,
    -- 坐标偏移 (六轴控制)
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    -- 辅助开关
    HeadFollow = true,
    BackdoorFound = "Ready to Scan",
    CurrentVelocity = 0,
    Version = "V27.0.4 - OMNI"
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

-- --- 2. 深度幽灵后门扫描引擎 ---
local function performDeepScan()
    local hiddenServices = {
        game:GetService("JointsService"),
        game:GetService("LogService"),
        game:GetService("RobloxReplicatedStorage"),
        game:GetService("TeleportService"),
        game:GetService("ScriptContext"),
        game:GetService("Selection")
    }
    
    local found = nil
    -- 深度递归扫描所有隐藏服务
    for _, s in pairs(hiddenServices) do
        pcall(function()
            for _, v in pairs(s:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    found = v -- 只要在这些敏感位置发现通信器，即判定为后门
                    break
                end
            end
        end)
        if found then break end
    end
    
    -- 若未找到，执行特征码扫描
    if not found then
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v:GetFullName():find("Default") then
                if #v.Name > 15 or v.Name:match("[%W%d]") then
                    found = v; break
                end
            end
        end
    end
    
    activeBackdoor = found
    _G.XU_Config.BackdoorFound = found and "FOUND: "..found.Name or "NONE (Using Physics)"
end

-- --- 3. 核心防死锁定系统 (防止散架即死) ---
local function toggleState(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if state then
        -- 核心：禁用重置逻辑与伤害判定
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum.Health = 100
        
        -- 断开关节连接，但不触发死亡
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = false
                v.Massless = true
                v.Velocity = Vector3.zero -- 抹除初始冲力
            end
        end
    else
        -- 彻底还原
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
            if v:IsA("BasePart") then v.CanCollide = true end
        end
        hum.WalkSpeed = 16
        if character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Anchored = false
        end
    end
end
-- --- 4. 核心几何驱动引擎 (全维度计算) ---
local function initGalaxyLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local cam = workspace.CurrentCamera
    local limbs = {}
    
    -- 收集所有可移动肢体（排除根部）
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
        end
    end

    -- 使用 RenderStepped 确保最高频率的物理同步
    tasks.Loop = RunService.RenderStepped:Connect(function(dt)
        if not _G.XU_Config.Enabled or not root then return end
        
        -- 实时生命维持与速度监控
        hum.Health = 100
        _G.XU_Config.CurrentVelocity = math.floor(root.Velocity.Magnitude)

        -- A. 全维度视角移动逻辑
        if _G.XU_Config.Fly then
            root.Anchored = true
            root.Velocity = Vector3.zero -- 抹除任何物理干扰产生的初速度
            
            -- 处理键盘/摇杆移动方向
            if hum.MoveDirection.Magnitude > 0 then
                -- 按视角方向进行坐标增量位移
                local moveDir = cam.CFrame.LookVector
                root.CFrame = root.CFrame + (moveDir * _G.XU_Config.Speed * dt)
            end
        else
            root.Anchored = false
            hum.WalkSpeed = _G.XU_Config.Speed
        end

        -- B. 光环几何排列算法 (六轴控制)
        local t = tick() * _G.XU_Config.RotSpeed
        
        -- 计算中心参考点 (包含 X/Y/Z 三轴位移偏移)
        local centerPos = root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ)
        
        -- 构建全维度旋转矩阵 (将角度转换为弧度进行 CFrame 变换)
        local rotationMatrix = CFrame.Angles(
            math.rad(_G.XU_Config.TiltX), 
            math.rad(_G.XU_Config.TiltY), 
            math.rad(_G.XU_Config.TiltZ)
        )
        
        -- 最终的光环平面中心 CFrame
        local centerCF = CFrame.new(centerPos) * rotationMatrix

        -- 中心点跟随设置
        if _G.XU_Config.HeadFollow and head then 
            head.CFrame = centerCF 
        end

        -- 遍历并排列肢体
        for i, part in ipairs(limbs) do
            -- 计算圆周分布角度
            local angle = (i / #limbs) * math.pi * 2 + t
            
            -- 在旋转平面上计算相对于中心的偏移向量
            local circleOffset = Vector3.new(
                math.cos(angle) * _G.XU_Config.Radius, 
                0, 
                math.sin(angle) * _G.XU_Config.Radius
            )
            
            -- 最终肢体坐标：中心平面 * 圆周偏移 * 肢体自转
            local targetCF = centerCF * CFrame.new(circleOffset) * CFrame.Angles(t, t, t/2)
            
            -- 后门注入尝试 (如果通过第一部分找到了可用 Remote)
            if activeBackdoor then
                pcall(function() 
                    -- 尝试最通用的同步协议
                    activeBackdoor:FireServer("UpdatePart", part.Name, targetCF) 
                end)
            end
            
            -- 本地同步：即使没后门，RenderStepped 也会强迫本地和部分物理所有权同步
            part.CFrame = targetCF
        end
    end)
end

-- --- 5. 系统开关接口 ---
_G.StartGalaxy = function()
    print("✦ 系统启动：正在执行幽灵探测...")
    performDeepScan()
    toggleState(true)
    initGalaxyLoop()
end

_G.StopGalaxy = function()
    print("✦ 系统停止：正在还原物理状态...")
    if tasks.Loop then tasks.Loop:Disconnect() end
    toggleState(false)
end
-- --- 6. 极光星空 UI 系统 (全维度监控) ---
local function createGalaxyUI()
    -- 清理旧 UI
    if CoreGui:FindFirstChild("XU_Galaxy_V27") then CoreGui.XU_Galaxy_V27:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Galaxy_V27"
    sg.ResetOnSpawn = false

    -- 主面板渲染 (极光深蓝)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 240, 0, 480)
    main.Position = UDim2.new(0.5, -120, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)

    -- 星空背景渐变效果
    local uigrad = Instance.new("UIGradient", main)
    uigrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 25, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 5, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 20, 70))
    })
    uigrad.Rotation = 45

    -- 霓虹呼吸边框
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2.5
    stroke.Color = Color3.fromRGB(80, 120, 255)
    spawn(function()
        while true do
            local t = TweenService:Create(stroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(200, 100, 255)})
            t:Play(); t.Completed:Wait()
            local t2 = TweenService:Create(stroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(80, 150, 255)})
            t2:Play(); t2.Completed:Wait()
        end
    end)

    -- 标题栏
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 40); bar.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, 0, 1, 0); title.Text = "✧ XU GALAXY OMNI ✧"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 13

    -- 实时监控看板 (Monitor Area)
    local monitor = Instance.new("Frame", main)
    monitor.Size = UDim2.new(1, -20, 0, 85); monitor.Position = UDim2.new(0, 10, 0, 45)
    monitor.BackgroundColor3 = Color3.new(0, 0, 0); monitor.BackgroundTransparency = 0.6
    Instance.new("UICorner", monitor)

    local infoLab = Instance.new("TextLabel", monitor)
    infoLab.Size = UDim2.new(1, -10, 1, -10); infoLab.Position = UDim2.new(0, 5, 0, 5)
    infoLab.BackgroundTransparency = 1; infoLab.TextColor3 = Color3.fromRGB(0, 255, 220); infoLab.Font = Enum.Font.Code; infoLab.TextSize = 10; infoLab.TextXAlignment = 0; infoLab.TextYAlignment = 0; infoLab.RichText = true

    -- 实时参数刷新逻辑
    RunService.RenderStepped:Connect(function()
        local c = _G.XU_Config
        infoLab.Text = string.format(
            "<b>[SYSTEM]</b>: %s<br/>" ..
            "<b>[BACKDOOR]</b>: <font color='#FFD700'>%s</font><br/>" ..
            "<b>[SPEED]</b>: %d studs/s<br/>" ..
            "<b>[ANGLES]</b>: X:%d° Y:%d° Z:%d°<br/>" ..
            "<b>[OFFSET]</b>: X:%.f Y:%.f Z:%.f",
            c.Enabled and "<font color='#00FF00'>ON</font>" or "<font color='#FF0000'>OFF</font>",
            c.BackdoorFound,
            c.CurrentVelocity,
            c.TiltX, c.TiltY, c.TiltZ,
            c.OffX, c.OffY, c.OffZ
        )
    end)

    -- 控制滚动列表 (全功能不删减)
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -200); scroll.Position = UDim2.new(0, 5, 0, 140)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 850); scroll.ScrollBarThickness = 2

    local function addControl(name, y, key, min, max, step)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -15, 0, 45); f.Position = UDim2.new(0, 5, 0, y); f.BackgroundTransparency = 1
        
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, 0, 0, 15); l.Text = "  ✦ " .. name; l.TextColor3 = Color3.fromRGB(200, 210, 255); l.TextSize = 10; l.Font = Enum.Font.GothamBold; l.BackgroundTransparency = 1; l.TextXAlignment = 0
        
        local b1 = Instance.new("TextButton", f)
        b1.Size = UDim2.new(0, 45, 0, 24); b1.Position = UDim2.new(0, 0, 0, 20); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40, 45, 90); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        
        local b2 = Instance.new("TextButton", f)
        b2.Size = UDim2.new(0, 45, 0, 24); b2.Position = UDim2.new(1, -45, 0, 20); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40, 45, 90); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        
        local val = Instance.new("TextLabel", f)
        val.Size = UDim2.new(1, -100, 0, 24); val.Position = UDim2.new(0, 50, 0, 20); val.Text = tostring(_G.XU_Config[key]); val.TextColor3 = Color3.new(1,1,1); val.BackgroundTransparency = 0.9; val.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", val)
        
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key] - step); val.Text = tostring(_G.XU_Config[key]) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key] + step); val.Text = tostring(_G.XU_Config[key]) end)
    end

    -- 部署调节滑块 (无精简)
    addControl("飞行/移动速度", 0, "Speed", 0, 500, 10)
    addControl("光环半径", 50, "Radius", 1, 50, 1)
    addControl("垂直偏移 (Y)", 100, "OffY", -50, 50, 1)
    addControl("水平偏移 (X)", 150, "OffX", -50, 50, 1)
    addControl("深度偏移 (Z)", 200, "OffZ", -50, 50, 1)
    addControl("俯仰旋转 (X)", 250, "TiltX", -360, 360, 15)
    addControl("偏航旋转 (Y)", 300, "TiltY", -360, 360, 15)
    addControl("自旋速率", 350, "RotSpeed", 0, 20, 0.5)

    -- 开关选项
    local function addToggle(name, y, key)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = _G.XU_Config[key] and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(40, 40, 60)
        btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
        btn.Activated:Connect(function()
            _G.XU_Config[key] = not _G.XU_Config[key]
            btn.BackgroundColor3 = _G.XU_Config[key] and Color3.fromRGB(60, 100, 255) or Color3.fromRGB(40, 40, 60)
        end)
    end

    addToggle("开启全维飞行模式", 410, "Fly")
    addToggle("锁定中心点跟随头部", 455, "HeadFollow")

    -- 底部启动按钮
    local activate = Instance.new("TextButton", main)
    activate.Size = UDim2.new(1, -20, 0, 50); activate.Position = UDim2.new(0, 10, 1, -60)
    activate.BackgroundColor3 = Color3.fromRGB(50, 90, 240); activate.Text = "✧ ACTIVATE GALAXY CORE ✧"; activate.TextColor3 = Color3.new(1,1,1); activate.Font = Enum.Font.GothamBold; activate.TextSize = 13; Instance.new("UICorner", activate)

    activate.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then
            activate.Text = "SYSTEM ACTIVE"; activate.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            _G.StartGalaxy()
        else
            activate.Text = "✧ ACTIVATE GALAXY CORE ✧"; activate.BackgroundColor3 = Color3.fromRGB(50, 90, 240)
            _G.StopGalaxy()
        end
    end)

    -- 拖拽交互
    local drag = false; local start; local pos
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; start = i.Position; pos = main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - start; main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function() drag = false end)
end

createGalaxyUI()
print("✦ XU GALAXY V27.0.4 终极版已就绪 ✦")
