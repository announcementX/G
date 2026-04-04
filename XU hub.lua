--[[
    ✦ XU GALAXY V37 - 手机移动端专用版 ✦
    修复：手机无法拖拽、缩小重叠、后门注入不平滑
    功能：全轴控制、防弹飞、自动扫描后门、可拖拽悬浮窗
]]

local _G = _G or {}
_G.XU_Config = {
    Enabled = false, Fly = false, Speed = 60, Radius = 10, RotSpeed = 2,
    Scale = 1, OffX = 0, OffY = 0, OffZ = 0, TiltX = 0, TiltY = 0, TiltZ = 0,
    Status = "IDLE", TargetRemote = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

-- --- 1. 后门注入引擎 ---
local function findBackdoor()
    _G.XU_Config.Status = "SCANNING..."
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and not v:GetFullName():find("Default") then
            if v.Name:lower():find("sync") or v.Name:lower():find("event") or #v.Name > 15 then
                _G.XU_Config.TargetRemote = v
                _G.XU_Config.Status = "HOOK: " .. v.Name:sub(1,8)
                return
            end
        end
    end
    _G.XU_Config.TargetRemote = game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
    _G.XU_Config.Status = _G.XU_Config.TargetRemote and "GENERIC" or "LOCAL"
end

local function fireRemote(part, cf)
    if _G.XU_Config.TargetRemote then
        pcall(function()
            _G.XU_Config.TargetRemote:FireServer(part, cf)
            _G.XU_Config.TargetRemote:FireServer("Update", part, cf)
        end)
    end
end

-- --- 2. 核心逻辑 (防飞/几何旋转) ---
local function runEngine()
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            table.insert(limbs, p)
            p.CanCollide = false
            local m = p:FindFirstChildOfClass("Motor6D")
            if m then m.Enabled = false end
        end
    end

    _G.MainLoop = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled then return end
        local c = _G.XU_Config
        local t = tick() * c.RotSpeed
        
        -- 强制稳定物理，防止手机端因网络波动起飞
        hum.PlatformStand = true
        root.Velocity = Vector3.new(0, 0.5, 0) -- 微弱悬浮感

        local centerCF = CFrame.new(root.Position + Vector3.new(c.OffX, c.OffY, c.OffZ))
                       * CFrame.Angles(math.rad(c.TiltX), math.rad(c.TiltY), math.rad(c.TiltZ))
        
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local offset = Vector3.new(math.cos(angle)*c.Radius, 0, math.sin(angle)*c.Radius) * c.Scale
            local targetCF = centerCF * CFrame.new(offset) * CFrame.Angles(t, t, t/2)
            
            fireRemote(part, targetCF) -- 后门注入
            part.CFrame = targetCF     -- 本地同步
        end
    end)
end

-- --- 3. 手机端适配 UI ---
local function buildMobileUI()
    if CoreGui:FindFirstChild("XU_MOBILE") then CoreGui.XU_MOBILE:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_MOBILE"

    -- 主框架
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 170, 0, 300); main.Position = UDim2.new(0.5, -85, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); main.ClipsDescendants = true
    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 255, 150)

    -- 标题栏 (拖拽触碰区)
    local title = Instance.new("TextButton", main)
    title.Size = UDim2.new(1, 0, 0, 35); title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.Text = "  GALAXY V37 (Drag)"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 10
    title.AutoButtonColor = false

    -- 状态标签
    local statLabel = Instance.new("TextLabel", main)
    statLabel.Size = UDim2.new(1, 0, 0, 15); statLabel.Position = UDim2.new(0,0,0,35)
    statLabel.BackgroundTransparency = 1; statLabel.TextColor3 = Color3.new(0,1,0); statLabel.TextSize = 8
    RunService.RenderStepped:Connect(function() statLabel.Text = "NET: ".._G.XU_Config.Status end)

    -- 滚动容器 (存放所有功能)
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, 0, 1, -100); scroll.Position = UDim2.new(0, 0, 0, 55)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,500); scroll.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- 缩小功能逻辑
    local miniBtn = Instance.new("TextButton", title)
    miniBtn.Size = UDim2.new(0, 35, 0, 35); miniBtn.Position = UDim2.new(1, -35, 0, 0)
    miniBtn.Text = "-"; miniBtn.TextColor3 = Color3.new(1,1,1); miniBtn.BackgroundTransparency = 1
    local minimized = false
    miniBtn.Activated:Connect(function()
        minimized = not minimized
        scroll.Visible = not minimized
        main:TweenSize(minimized and UDim2.new(0, 170, 0, 35) or UDim2.new(0, 170, 0, 300), "Out", "Quart", 0.3, true)
        miniBtn.Text = minimized and "+" or "-"
    end)

    -- 功能添加函数
    local function addControl(name, key, step, min, max)
        local f = Instance.new("Frame", scroll); f.Size = UDim2.new(0.9, 0, 0, 40); f.BackgroundTransparency = 0.8; f.BackgroundColor3 = Color3.new(0,0,0)
        Instance.new("UICorner", f)
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0.4, 0); l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.TextSize = 9; l.BackgroundTransparency = 1
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(0.4, 0, 0.6, 0); v.Position = UDim2.new(0.3,0,0.4,0); v.TextColor3 = Color3.new(0,1,1); v.TextSize = 10; v.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0.2,0,0.5,0); b1.Position = UDim2.new(0.05,0,0.4,0); b1.Text = "-"; b1.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0.2,0,0.5,0); b2.Position = UDim2.new(0.75,0,0.4,0); b2.Text = "+"; b2.BackgroundColor3 = Color3.new(0.2,0.2,0.2); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        
        RunService.RenderStepped:Connect(function() v.Text = tostring(math.floor(_G.XU_Config[key]*10)/10) end)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key] - step) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key] + step) end)
    end

    addControl("Radius 半径", "Radius", 2, 0, 100)
    addControl("Scale 缩放", "Scale", 0.1, 0.1, 5)
    addControl("Off Y 垂直", "OffY", 1, -50, 50)
    addControl("Tilt X 倾斜", "TiltX", 15, -360, 360)
    addControl("RotSpeed 转速", "RotSpeed", 0.5, 0, 10)

    -- 底部启动按钮
    local run = Instance.new("TextButton", main)
    run.Size = UDim2.new(0.9, 0, 0, 40); run.Position = UDim2.new(0.05, 0, 1, -45)
    run.Text = "✧ START ENGINE ✧"; run.BackgroundColor3 = Color3.fromRGB(0, 120, 255); run.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", run)
    
    run.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        run.Text = _G.XU_Config.Enabled and "ACTIVE" or "✧ START ENGINE ✧"
        run.BackgroundColor3 = _G.XU_Config.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 120, 255)
        if _G.XU_Config.Enabled then findBackdoor(); runEngine() else hum.PlatformStand = false; if _G.MainLoop then _G.MainLoop:Disconnect() end end
    end)

    -- 手机端拖拽脚本 (修复核心)
    local dragToggle, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
end

buildMobileUI()
