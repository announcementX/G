--[[
    ✦ XU OMNI-PROJECT V31 - 幽灵渗透版 ✦
    核心：后门递归扫描、全协议注入、物理所有权强制同步
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    SizeScale = 1, -- 缩小/放大功能核心变量
    HeadFollow = true, BackdoorFound = "Scanning...", CurrentVelocity = 0
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local activeBackdoor = nil

-- --- 1. 递归式后门探测引擎 ---
local function deepInject()
    local targetServices = {
        game:GetService("JointsService"), 
        game:GetService("LogService"), 
        game:GetService("RobloxReplicatedStorage"),
        game:GetService("ScriptContext")
    }
    
    local function scan(obj)
        for _, v in pairs(obj:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                -- 排除系统默认 Remote，锁定用户自定义后门
                if not v:GetFullName():find("Default") then
                    activeBackdoor = v
                    return true
                end
            end
        end
        return false
    end

    for _, s in pairs(targetServices) do
        if scan(s) then break end
    end
    
    _G.XU_Config.BackdoorFound = activeBackdoor and "SYNC: "..activeBackdoor.Name or "SYNC: P-PHYSICS"
end

-- --- 2. 完美防死与缩小/放大算法 ---
local function applyPhysicalState(state)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if state then
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum.Health = 100
        
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                -- 应用缩小功能：通过原生的 Size 调整
                if v.Name ~= "HumanoidRootPart" then
                    v.Size = v.Size * _G.XU_Config.SizeScale
                end
            end
        end
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        -- 恢复原始尺寸逻辑（需记录初始值，此处简化为重置关节）
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
        end
    end
end
-- --- 3. 全服同步核心逻辑 ---
local function universalSync(part, targetCF)
    if not activeBackdoor then return end
    
    pcall(function()
        -- 尝试市面 99% 后门的同步协议
        local args = {
            [1] = "Update", 
            [2] = part, 
            [3] = targetCF,
            ["CFrame"] = targetCF,
            ["Part"] = part
        }
        -- 暴力协议尝试
        activeBackdoor:FireServer(args[1], args[2], args[3]) -- 协议 A
        activeBackdoor:FireServer(part, targetCF)            -- 协议 B
        activeBackdoor:FireServer("CFrame", targetCF)       -- 协议 C
    end)
end

-- --- 4. 核心几何循环 (六轴 + 飞行 + 缩放) ---
local function startOmniLoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    local limbs = {}

    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
        end
    end

    tasks.Main = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled or not root then return end
        
        hum.Health = 100
        _G.XU_Config.CurrentVelocity = math.floor(root.Velocity.Magnitude)

        -- A. 平滑飞行逻辑 (非锚定同步)
        if _G.XU_Config.Fly then
            local moveDir = (hum.MoveDirection.Magnitude > 0) and cam.CFrame.LookVector or Vector3.zero
            root.CFrame = root.CFrame:Lerp(root.CFrame + (moveDir * _G.XU_Config.Speed * dt), 0.7)
            root.Velocity = Vector3.new(0, 0.1, 0)
        else
            hum.WalkSpeed = _G.XU_Config.Speed
        end

        -- B. 六轴光环核心计算
        local t = tick() * _G.XU_Config.RotSpeed
        local baseCF = CFrame.new(root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ))
        local rotCF = CFrame.Angles(math.rad(_G.XU_Config.TiltX), math.rad(_G.XU_Config.TiltY), math.rad(_G.XU_Config.TiltZ))
        local centerCF = baseCF * rotCF

        if _G.XU_Config.HeadFollow and character:FindFirstChild("Head") then
            character.Head.CFrame = centerCF
        end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * _G.XU_Config.Radius, 0, math.sin(angle) * _G.XU_Config.Radius)
            
            -- 计算最终坐标（应用缩放系数）
            local targetCF = centerCF * CFrame.new(lPos * _G.XU_Config.SizeScale) * CFrame.Angles(t, t, t/2)
            
            -- 执行全服同步注入
            universalSync(part, targetCF)
            
            -- 本地实时渲染
            part.CFrame = targetCF
        end
    end)
end

_G.StartGalaxy = function()
    deepInject()
    applyPhysicalState(true)
    startOmniLoop()
end

_G.StopGalaxy = function()
    if tasks.Main then tasks.Main:Disconnect() end
    applyPhysicalState(false)
end
-- --- 5. Nano-Star UI (极简星空美学) ---
local function createNanoUI()
    if CoreGui:FindFirstChild("XU_V31") then CoreGui.XU_V31:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_V31"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 150, 0, 300) -- 微型尺寸
    main.Position = UDim2.new(0.5, -75, 0.2, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20); main.BackgroundTransparency = 0.2
    Instance.new("UICorner", main)
    
    local stroke = Instance.new("UIStroke", main); stroke.Thickness = 1.5; stroke.Color = Color3.fromRGB(0, 200, 255)
    
    local mon = Instance.new("TextLabel", main)
    mon.Size = UDim2.new(1, -10, 0, 50); mon.Position = UDim2.new(0, 5, 0, 5)
    mon.BackgroundColor3 = Color3.new(0,0,0); mon.TextColor3 = Color3.fromRGB(0,255,200); mon.TextSize = 8; mon.Font = Enum.Font.Code; mon.RichText = true
    Instance.new("UICorner", mon)

    RunService.Heartbeat:Connect(function()
        local c = _G.XU_Config
        mon.Text = string.format("<b>%s</b><br/>SPD: %d | SCALE: %.1f<br/>ROT: %d,%d,%d", 
            c.BackdoorFound, c.CurrentVelocity, c.SizeScale, c.TiltX, c.TiltY, c.TiltZ)
    end)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -6, 1, -105); scroll.Position = UDim2.new(0, 3, 0, 60)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 600); scroll.ScrollBarThickness = 1

    local function addAdj(text, y, key, min, max, step)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -4, 0, 35); f.Position = UDim2.new(0, 2, 0, y); f.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = text; l.TextColor3 = Color3.new(0.7,0.7,1); l.TextSize = 8; l.BackgroundTransparency = 1
        local b1 = Instance.new("TextButton", f); b1.Size = UDim2.new(0, 25, 0, 18); b1.Position = UDim2.new(0, 2, 0, 15); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,70); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", f); b2.Size = UDim2.new(0, 25, 0, 18); b2.Position = UDim2.new(1, -27, 0, 15); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,70); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1, -60, 0, 18); v.Position = UDim2.new(0, 30, 0, 15); v.Text = tostring(_G.XU_Config[key]); v.TextColor3 = Color3.new(1,1,1); v.BackgroundTransparency = 0.9; v.BackgroundColor3 = Color3.new(1,1,1)
        b1.Activated:Connect(function() _G.XU_Config[key] = math.max(min, _G.XU_Config[key]-step); v.Text = tostring(_G.XU_Config[key]) end)
        b2.Activated:Connect(function() _G.XU_Config[key] = math.min(max, _G.XU_Config[key]+step); v.Text = tostring(_G.XU_Config[key]) end)
    end

    -- 核心调节：增加缩小（SizeScale）功能
    addAdj("BODY SCALE (缩小)", 0, "SizeScale", 0.1, 5, 0.1)
    addAdj("RING RADIUS", 40, "Radius", 1, 100, 1)
    addAdj("MOVE SPEED", 80, "Speed", 0, 800, 10)
    addAdj("OFFSET Y", 120, "OffY", -100, 100, 1)
    addAdj("TILT X (角度)", 160, "TiltX", -360, 360, 15)
    addAdj("TILT Y (角度)", 200, "TiltY", -360, 360, 15)
    addAdj("ROT RATE", 240, "RotSpeed", 0, 30, 0.5)

    local flyBtn = Instance.new("TextButton", main)
    flyBtn.Size = UDim2.new(1, -20, 0, 30); flyBtn.Position = UDim2.new(0, 10, 1, -85)
    flyBtn.Text = "FLY: OFF"; flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60); flyBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", flyBtn)
    flyBtn.Activated:Connect(function() _G.XU_Config.Fly = not _G.XU_Config.Fly; flyBtn.Text = _G.XU_Config.Fly and "FLY: ON" or "FLY: OFF"; flyBtn.BackgroundColor3 = _G.XU_Config.Fly and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(40, 40, 60) end)

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, -20, 0, 40); toggle.Position = UDim2.new(0, 10, 1, -50)
    toggle.BackgroundColor3 = Color3.fromRGB(45, 75, 180); toggle.Text = "✧ START ✧"; toggle.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggle)
    toggle.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then toggle.Text = "RUNNING"; toggle.BackgroundColor3 = Color3.fromRGB(180, 40, 40); _G.StartGalaxy() else toggle.Text = "✧ START ✧"; toggle.BackgroundColor3 = Color3.fromRGB(45, 75, 180); _G.StopGalaxy() end
    end)
    
    -- 拖拽交互
    local d, s, p; main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; s = i.Position; p = main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s; main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

createNanoUI()
