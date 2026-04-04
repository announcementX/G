--[[
    ✦ XU GALAXY V29 - 全服可见增强版 ✦
    更新：加入了多协议后门注入，解决 FE 同步失效问题。
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    HeadFollow = true, BackdoorFound = "Scanning...", CurrentVelocity = 0
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local tasks = {}
local activeBackdoor = nil

-- --- 1. 暴力后门嗅探与协议分析 ---
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
    
    if not found then
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v:GetFullName():find("Default") then
                if #v.Name > 15 or v.Name:match("[%W%d]") then found = v; break end
            end
        end
    end
    
    activeBackdoor = found
    _G.XU_Config.BackdoorFound = found and "INJECTED: "..found.Name or "PHYSICS ONLY"
end

-- --- 2. 核心同步注入逻辑 (让别人看见的关键) ---
local function syncToService(part, targetCF)
    if not activeBackdoor then return end
    
    -- 尝试多种市面流行的后门调用协议
    pcall(function()
        -- 协议 A: 标准坐标同步
        activeBackdoor:FireServer("CFrame", part, targetCF)
        -- 协议 B: 字符串执行同步 (用于命令行后门)
        activeBackdoor:FireServer("Execute", string.format("game.Workspace['%s']['%s'].CFrame = CFrame.new(%s)", player.Name, part.Name, tostring(targetCF)))
        -- 协议 C: 简易参数同步
        activeBackdoor:FireServer(part, targetCF)
    end)
end

-- --- 3. 生命锁定与网络所有权接管 ---
local function toggleState(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.Health = 100
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = false
                v.Massless = true
                -- 尝试强制接管网络所有权 (如果执行器支持)
                pcall(function() v:SetNetworkOwner(player) end)
            end
        end
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
        end
    end
end
-- --- 4. 核心几何驱动引擎 (多协议全同步) ---
local function initGalaxyLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local cam = workspace.CurrentCamera
    local limbs = {}
    
    -- 智能肢体识别与网络所有权抢夺尝试
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            -- 核心：尝试将零件的物理控制权强行拉回本地，这是 FE 绕过的物理基础
            pcall(function() p:SetNetworkOwner(player) end)
        end
    end

    -- 使用 RenderStepped 锁定最高同步频率
    tasks.Loop = RunService.RenderStepped:Connect(function(dt)
        if not _G.XU_Config.Enabled or not root then return end
        
        -- 实时生命维持与状态镜像
        hum.Health = 100
        _G.XU_Config.CurrentVelocity = math.floor(root.Velocity.Magnitude)

        -- A. 全维度视角飞行驱动 (支持速度镜像)
        if _G.XU_Config.Fly then
            root.Anchored = true
            root.Velocity = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then
                local moveDir = cam.CFrame.LookVector
                root.CFrame = root.CFrame + (moveDir * _G.XU_Config.Speed * dt)
            end
        else
            root.Anchored = false
            hum.WalkSpeed = _G.XU_Config.Speed
        end

        -- B. 星核轨道算法 (应用三轴偏移与旋转)
        local t = tick() * _G.XU_Config.RotSpeed
        local basePos = root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ)
        
        -- 构建全轴旋转矩阵 (Tilt X/Y/Z)
        local rotCF = CFrame.Angles(
            math.rad(_G.XU_Config.TiltX), 
            math.rad(_G.XU_Config.TiltY), 
            math.rad(_G.XU_Config.TiltZ)
        )
        local centerCF = CFrame.new(basePos) * rotCF

        -- 头部跟随逻辑 (若开启则强制同步头部)
        if _G.XU_Config.HeadFollow and head then 
            head.CFrame = centerCF 
        end

        -- 核心排列与全服同步尝试
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local circleOffset = Vector3.new(
                math.cos(angle) * _G.XU_Config.Radius, 
                0, 
                math.sin(angle) * _G.XU_Config.Radius
            )
            
            -- 最终变换矩阵
            local targetCF = centerCF * CFrame.new(circleOffset) * CFrame.Angles(t, t, t/2)
            
            -- 【关键：全服可见注入】
            -- 调用 Part 1 中的多协议同步函数，尝试通过后门向服务器强制广播位置
            if activeBackdoor then
                syncToService(part, targetCF)
            end
            
            -- 本地坐标强制设定 (作为备选物理方案)
            part.CFrame = targetCF
        end
    end)
end

-- --- 5. 系统启动/停止接口 ---
_G.StartGalaxy = function()
    print("✦ 系统启动：正在执行幽灵探测与网络所有权接管...")
    performDeepScan()
    toggleState(true)
    initGalaxyLoop()
end

_G.StopGalaxy = function()
    print("✦ 系统停止：正在释放物理控制权...")
    if tasks.Loop then tasks.Loop:Disconnect() end
    toggleState(false)
    -- 尝试归还网络所有权
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(nil) end) end
    end
end
-- --- 6. 星空微缩 UI (Nebula Minimalist V29) ---
local function createNebulaUI()
    -- 清理旧 UI 缓存
    if CoreGui:FindFirstChild("XU_Nebula_V29") then CoreGui.XU_Nebula_V29:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "XU_Nebula_V29"
    sg.IgnoreGuiInset = true

    -- 主框架 (极简小巧且不遮挡视线)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 190, 0, 40) -- 初始高度极小
    main.Position = UDim2.new(0.5, -95, 0.15, 0)
    main.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- 星空呼吸灯边框
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 1.8
    stroke.Color = Color3.fromRGB(60, 120, 255)
    spawn(function()
        while true do
            local t = TweenService:Create(stroke, TweenInfo.new(3, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(180, 80, 255)})
            t:Play(); t.Completed:Wait()
            local t2 = TweenService:Create(stroke, TweenInfo.new(3, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(60, 120, 255)})
            t2:Play(); t2.Completed:Wait()
        end
    end)

    -- 标题按钮 (点击切换展开/折叠)
    local header = Instance.new("TextButton", main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Text = "✧ XU NEBULA V29 ✧"
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.GothamBold; header.TextSize = 11

    -- 实时监控看板 (Monitor Area)
    local monitor = Instance.new("TextLabel", main)
    monitor.Size = UDim2.new(1, -16, 0, 75); monitor.Position = UDim2.new(0, 8, 0, 45)
    monitor.BackgroundColor3 = Color3.new(0, 0, 0); monitor.BackgroundTransparency = 0.75
    monitor.TextColor3 = Color3.fromRGB(0, 255, 180); monitor.Font = Enum.Font.Code; monitor.TextSize = 9
    monitor.TextXAlignment = 0; monitor.RichText = true; Instance.new("UICorner", monitor)

    -- 动态刷新监控信息
    RunService.RenderStepped:Connect(function()
        local c = _G.XU_Config
        monitor.Text = string.format(
            " [BD]: <font color='#FFD700'>%s</font>\n [SPD]: %d studs/s\n [ROT]: X%d Y%d Z%d\n [OFF]: X%.1f Y%.1f Z%.1f",
            c.BackdoorFound, c.CurrentVelocity,
            c.TiltX, c.TiltY, c.TiltZ,
            c.OffX, c.OffY, c.OffZ
        )
    end)

    -- 调节功能滚动区
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -185); scroll.Position = UDim2.new(0, 5, 0, 125)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 750); scroll.ScrollBarThickness = 1

    local function addAdj(name, y, key, min, max, step)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -10, 0, 38); f.Position = UDim2.new(0, 5, 0, y); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = "✦ "..name; l.TextColor3 = Color3.new(0.7,0.8,1); l.TextSize = 9; l.BackgroundTransparency = 1; l.TextXAlignment = 0
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0, 32, 0, 20); b1.Position = UDim2.new(0, 0, 0, 18); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(35,35,65); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0, 32, 0, 20); b2.Position = UDim2.new(1, -32, 0, 18); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(35,35,65); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1, -74, 0, 20); v.Position = UDim2.new(0, 37, 0, 18); v.Text = tostring(_G.XU_Config[key]); v.TextColor3 = Color3.new(1,1,1); v.BackgroundTransparency = 0.9; v.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", v)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key]-step); v.Text = tostring(_G.XU_Config[key]) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key]+step); v.Text = tostring(_G.XU_Config[key]) end)
    end

    -- 部署调节（全维度，不精简）
    addAdj("MOVE SPEED", 0, "Speed", 0, 1000, 10)
    addAdj("RING RADIUS", 45, "Radius", 1, 100, 1)
    addAdj("OFFSET Y", 90, "OffY", -100, 100, 1)
    addAdj("OFFSET X", 135, "OffX", -100, 100, 1)
    addAdj("TILT X (PITCH)", 180, "TiltX", -360, 360, 15)
    addAdj("TILT Y (YAW)", 225, "TiltY", -360, 360, 15)
    addAdj("TILT Z (ROLL)", 270, "TiltZ", -360, 360, 15)
    addAdj("ROT RATE", 315, "RotSpeed", 0, 50, 0.5)

    -- 辅助切换
    local function addSw(name, y, key)
        local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.9, 0, 0, 30); b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = _G.XU_Config[key] and Color3.fromRGB(50, 100, 220) or Color3.fromRGB(30, 30, 45)
        b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 10; Instance.new("UICorner", b)
        b.Activated:Connect(function() _G.XU_Config[key] = not _G.XU_Config[key]; b.BackgroundColor3 = _G.XU_Config[key] and Color3.fromRGB(50, 100, 220) or Color3.fromRGB(30, 30, 45) end)
    end
    addSw("FLY MODE", 365, "Fly")
    addSw("HEAD FOLLOW", 405, "HeadFollow")

    -- 启动核心按钮
    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, -20, 0, 45); toggle.Position = UDim2.new(0, 10, 1, -55)
    toggle.BackgroundColor3 = Color3.fromRGB(45, 75, 180); toggle.Text = "✦ INITIALIZE CORE ✦"; toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold; Instance.new("UICorner", toggle)

    local expanded = false
    header.Activated:Connect(function()
        expanded = not expanded
        main:TweenSize(expanded and UDim2.new(0, 190, 0, 420) or UDim2.new(0, 190, 0, 40), "Out", "Back", 0.5, true)
    end)

    toggle.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then
            toggle.Text = "CORE RUNNING"; toggle.BackgroundColor3 = Color3.fromRGB(160, 45, 45); _G.StartGalaxy()
        else
            toggle.Text = "✦ INITIALIZE CORE ✦"; toggle.BackgroundColor3 = Color3.fromRGB(45, 75, 180); _G.StopGalaxy()
        end
    end)

    -- 拖拽交互
    local drag, start, pos; header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; start = i.Position; pos = main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - start; main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function() drag = false end)
end

createNebulaUI()
print("✦ XU GALAXY V29 部署成功！点击悬浮窗标题展开配置界面。")
