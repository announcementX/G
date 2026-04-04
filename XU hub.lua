--[[
    ✧ XU GALAXY V36: TITAN EDITION ✧
    核心功能：深层后门自动挂钩、全轴几何控制、智能防飞稳定器
    UI特性：可拖拽悬浮窗、一键折叠缩小、实时状态监控
]]

-- 1. 全局配置初始化 (包含你要求的所有功能)
_G.XU_Config = {
    Enabled = false, 
    Fly = false, 
    Speed = 60, 
    Radius = 10, 
    RotSpeed = 2,
    Scale = 1,          -- 缩小/放大
    OffX = 0, OffY = 0, OffZ = 0, -- 偏移
    TiltX = 0, TiltY = 0, TiltZ = 0, -- 倾斜
    HeadFollow = true,
    TargetRemote = nil,
    Status = "IDLE"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

--=============================================================================
-- 核心引擎：后门扫描与注入 (SERVER-SIDE SYNC)
--=============================================================================
local function findBackdoor()
    _G.XU_Config.Status = "SCANNING..."
    local searchPaths = {game:GetService("ReplicatedStorage"), game:GetService("JointsService"), workspace}
    for _, path in pairs(searchPaths) do
        for _, v in pairs(path:GetDescendants()) do
            if v:IsA("RemoteEvent") and not v:GetFullName():find("Default") then
                -- 匹配高度可疑的后门特征
                if v.Name:lower():find("sync") or v.Name:lower():find("update") or #v.Name > 15 then
                    _G.XU_Config.TargetRemote = v
                    _G.XU_Config.Status = "HOOKED: " .. v.Name:sub(1,10)
                    return
                end
            end
        end
    end
    _G.XU_Config.TargetRemote = game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
    _G.XU_Config.Status = _G.XU_Config.TargetRemote and "GENERIC SYNC" or "LOCAL ONLY"
end

local function fireBackdoor(part, cf)
    if _G.XU_Config.TargetRemote then
        pcall(function()
            _G.XU_Config.TargetRemote:FireServer(part, cf)
            _G.XU_Config.TargetRemote:FireServer("Update", part, cf)
        end)
    end
end

--=============================================================================
-- 稳定器与飞行逻辑 (ANTI-YEET SYSTEM)
--=============================================================================
local function toggleStability(state)
    hum.PlatformStand = state -- 彻底关闭Humanoid物理引擎干扰
    if state then
        _G.Stabilizer = RunService.Heartbeat:Connect(function()
            if _G.XU_Config.Enabled and not _G.XU_Config.Fly then
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
        end)
    elseif _G.Stabilizer then
        _G.Stabilizer:Disconnect()
    end
end

--=============================================================================
-- 几何渲染循环 (SIX-AXIS ENGINE)
--=============================================================================
local function startEngine()
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            table.insert(limbs, p)
            p.CanCollide = false
            local m6d = p:FindFirstChildOfClass("Motor6D")
            if m6d then m6d.Enabled = false end
        end
    end

    _G.MainLoop = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled then return end
        local c = _G.XU_Config
        local t = tick() * c.RotSpeed
        
        -- 1. 飞行控制
        if c.Fly then
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            root.Velocity = Vector3.new(0, 2, 0) -- 抵消重力
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame:Lerp(root.CFrame + (cam.CFrame.LookVector * c.Speed * dt), 0.2)
            end
        end

        -- 2. 坐标矩阵计算
        local centerCF = CFrame.new(root.Position + Vector3.new(c.OffX, c.OffY, c.OffZ))
                       * CFrame.Angles(math.rad(c.TiltX), math.rad(c.TiltY), math.rad(c.TiltZ))
        
        -- 3. 肢体同步
        for i, part in ipairs(limbs) do
            if part.Name == "Head" and not c.HeadFollow then continue end
            
            local angle = (i / #limbs) * math.pi * 2 + t
            local offset = Vector3.new(math.cos(angle) * c.Radius, 0, math.sin(angle) * c.Radius) * c.Scale
            local targetCF = centerCF * CFrame.new(offset) * CFrame.Angles(t, t, t/2)
            
            fireBackdoor(part, targetCF) -- 服务器同步
            part.CFrame = targetCF        -- 本地渲染
        end
    end)
end

--=============================================================================
-- TITAN UI 系统 (可拖拽、可折叠、全功能)
--=============================================================================
local function buildUI()
    if CoreGui:FindFirstChild("XU_TITAN") then CoreGui.XU_TITAN:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_TITAN"

    -- 主容器
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 180, 0, 320); main.Position = UDim2.new(0.5, -90, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); main.ClipsDescendants = true
    Instance.new("UICorner", main)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 180, 255)

    -- 标题栏 (拖拽区域)
    local titleBar = Instance.new("TextButton", main)
    titleBar.Size = UDim2.new(1, 0, 0, 30); titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    titleBar.Text = "  XU GALAXY V36"; titleBar.TextColor3 = Color3.new(1,1,1); titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.Font = Enum.Font.GothamBold; titleBar.TextSize = 10

    -- 折叠按钮
    local miniBtn = Instance.new("TextButton", titleBar)
    miniBtn.Size = UDim2.new(0, 30, 0, 30); miniBtn.Position = UDim2.new(1, -30, 0, 0)
    miniBtn.Text = "-"; miniBtn.TextColor3 = Color3.new(1,1,1); miniBtn.BackgroundTransparency = 1
    local isMini = false
    miniBtn.Activated:Connect(function()
        isMini = not isMini
        main:TweenSize(isMini and UDim2.new(0, 180, 0, 30) or UDim2.new(0, 180, 0, 320), "Out", "Quad", 0.3, true)
        miniBtn.Text = isMini and "+" or "-"
    end)

    -- 内容滚动区
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, 0, 1, -80); content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0,0,0,550); content.ScrollBarThickness = 2

    local function addRow(txt, key, y, step, min, max)
        local f = Instance.new("Frame", content); f.Size = UDim2.new(1, 0, 0, 35); f.Position = UDim2.new(0,0,0,y); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.4, 0, 1, 0); l.Text = txt; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.TextSize = 9; l.BackgroundTransparency = 1
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(0.2, 0, 1, 0); v.Position = UDim2.new(0.4,0,0,0); v.TextColor3 = Color3.new(0,1,1); v.TextSize = 9; v.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0, 20, 0, 20); b1.Position = UDim2.new(0.7,0,0.2,0); b1.Text = "<"; b1.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b1.TextColor3 = Color3.new(1,1,1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0, 20, 0, 20); b2.Position = UDim2.new(0.85,0,0.2,0); b2.Text = ">"; b2.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b2.TextColor3 = Color3.new(1,1,1)
        
        RunService.RenderStepped:Connect(function() v.Text = tostring(_G.XU_Config[key]) end)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key] - step) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key] + step) end)
    end

    -- 功能列表 (你要求的全部功能)
    addRow("Radius 半径", "Radius", 0, 2, 0, 200)
    addRow("Scale 缩放", "Scale", 40, 0.1, 0.1, 10)
    addRow("Speed 速度", "Speed", 80, 10, 0, 500)
    addRow("Off Y 垂直", "OffY", 120, 1, -100, 100)
    addRow("Tilt X 倾斜", "TiltX", 160, 15, -360, 360)
    addRow("Tilt Z 旋转", "TiltZ", 200, 15, -360, 360)
    addRow("RotSpeed 转速", "RotSpeed", 240, 0.5, 0, 20)

    -- 飞行开关
    local flyBtn = Instance.new("TextButton", content)
    flyBtn.Size = UDim2.new(0.9, 0, 0, 30); flyBtn.Position = UDim2.new(0.05, 0, 0, 290)
    flyBtn.Text = "FLY: OFF"; flyBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); flyBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", flyBtn)
    flyBtn.Activated:Connect(function() _G.XU_Config.Fly = not _G.XU_Config.Fly; flyBtn.Text = "FLY: "..(_G.XU_Config.Fly and "ON" or "OFF") end)

    -- 启动按钮
    local run = Instance.new("TextButton", main)
    run.Size = UDim2.new(0.9, 0, 0, 40); run.Position = UDim2.new(0.05, 0, 1, -45)
    run.Text = "✧ START ENGINE ✧"; run.BackgroundColor3 = Color3.fromRGB(0, 120, 255); run.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", run)
    
    local stat = Instance.new("TextLabel", main)
    stat.Size = UDim2.new(1, 0, 0, 15); stat.Position = UDim2.new(0, 0, 1, -60)
    stat.TextSize = 8; stat.TextColor3 = Color3.new(0,1,0); stat.BackgroundTransparency = 1
    RunService.RenderStepped:Connect(function() stat.Text = "NET: ".._G.XU_Config.Status end)

    run.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        run.Text = _G.XU_Config.Enabled and "SYSTEM ACTIVE" or "✧ START ENGINE ✧"
        run.BackgroundColor3 = _G.XU_Config.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 120, 255)
        if _G.XU_Config.Enabled then findBackdoor(); toggleStability(true); startEngine() else toggleStability(false); if _G.MainLoop then _G.MainLoop:Disconnect() end end
    end)

    -- 拖拽逻辑
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

buildUI()
