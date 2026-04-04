--[[
    ✦ XU GALAXY V33 - 绝对注入版 ✦
    功能：深度后门扫描、协议枚举、强制服务器同步
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0,
    TiltX = 0, TiltY = 0, TiltZ = 0,
    SizeScale = 1, SyncMode = "Scanning..."
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local activeBackdoor = nil

-- --- 1. 深度后门扫描引擎 ---
local function scanForBackdoor()
    -- 扫描高风险路径
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("JointsService"),
        game:GetService("LogService"),
        workspace
    }
    
    for _, loc in pairs(locations) do
        for _, v in pairs(loc:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                -- 常见的后门特征：名称随机、在奇怪的服务里、或者包含特定关键词
                if v.Name:match("Backdoor") or v.Name:match("HD") or #v.Name > 15 or v.Parent == game:GetService("JointsService") then
                    activeBackdoor = v
                    _G.XU_Config.SyncMode = "INJECTED: " .. v.Name
                    return
                end
            end
        end
    end
    
    -- 如果没找到，退而求其次寻找通用的 Remote
    activeBackdoor = game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent")
    _G.XU_Config.SyncMode = activeBackdoor and "GENERIC SYNC" or "LOCAL (NO BACKDOOR)"
end
-- --- 2. 核心同步函数 (协议枚举) ---
local function serverSync(part, targetCF)
    if not activeBackdoor then return end
    
    pcall(function()
        -- 尝试 1: 标准 CFrame 协议
        activeBackdoor:FireServer("CFrame", part, targetCF)
        -- 尝试 2: 简易参数协议
        activeBackdoor:FireServer(part, targetCF)
        -- 尝试 3: 命令注入协议 (针对某些管理插件后门)
        activeBackdoor:FireServer("Execute", string.format("workspace['%s']['%s'].CFrame = %s", player.Name, part.Name, "CFrame.new("..tostring(targetCF.Position)..")"))
    end)
end

-- --- 3. 几何运算与平滑驱动 ---
local function startLoop()
    local root = character:WaitForChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local limbs = {}
    
    -- 准备肢体
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            table.insert(limbs, p)
            if p:FindFirstChildOfClass("Motor6D") then p:FindFirstChildOfClass("Motor6D").Enabled = false end
        end
    end

    tasks.Galaxy = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled then return end
        
        -- 飞行逻辑
        if _G.XU_Config.Fly then
            root.Velocity = Vector3.new(0, 0.1, 0)
            local cam = workspace.CurrentCamera
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame:Lerp(root.CFrame + (cam.CFrame.LookVector * _G.XU_Config.Speed * dt), 0.5)
            end
        end

        -- 六轴光环计算
        local t = tick() * _G.XU_Config.RotSpeed
        local baseCF = CFrame.new(root.Position + Vector3.new(_G.XU_Config.OffX, _G.XU_Config.OffY, _G.XU_Config.OffZ))
        local rotCF = CFrame.Angles(math.rad(_G.XU_Config.TiltX), math.rad(_G.XU_Config.TiltY), math.rad(_G.XU_Config.TiltZ))
        local centerCF = baseCF * rotCF

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local pos = Vector3.new(math.cos(angle) * _G.XU_Config.Radius, 0, math.sin(angle) * _G.XU_Config.Radius) * _G.XU_Config.SizeScale
            local targetCF = centerCF * CFrame.new(pos) * CFrame.Angles(t, t, t/2)
            
            -- 【核心注入】
            serverSync(part, targetCF)
            
            -- 本地预览
            part.CFrame = targetCF
        end
    end)
end
-- --- 4. 微型 UI 部署 ---
local function createUI()
    if CoreGui:FindFirstChild("XU_V33") then CoreGui.XU_V33:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_V33"

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 130, 0, 220); main.Position = UDim2.new(1, -140, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30); main.BackgroundTransparency = 0.2
    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(0, 255, 150); stroke.Thickness = 1.2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 20); title.Text = "✧ GALAXY INJECT ✧"; title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold; title.TextSize = 9; title.BackgroundTransparency = 1

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, -10, 0, 30); status.Position = UDim2.new(0, 5, 0, 20)
    status.Text = "Status: Loading..."; status.TextColor3 = Color3.fromRGB(0, 255, 200); status.TextSize = 8; status.Font = Enum.Font.Code
    status.BackgroundTransparency = 1

    RunService.RenderStepped:Connect(function() status.Text = _G.XU_Config.SyncMode end)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, 0, 1, -90); scroll.Position = UDim2.new(0, 0, 0, 50)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,350); scroll.ScrollBarThickness = 2

    local function makeBtn(txt, key, y, step)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(0.9, 0, 0, 25); b.Position = UDim2.new(0.05, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(40, 45, 60); b.TextColor3 = Color3.new(1,1,1); b.Text = txt..": "..tostring(_G.XU_Config[key])
        b.Font = Enum.Font.Gotham; b.TextSize = 8; Instance.new("UICorner", b)
        b.Activated:Connect(function()
            _G.XU_Config[key] = (_G.XU_Config[key] + step > 100 and key=="Radius") and 2 or (_G.XU_Config[key] + step)
            b.Text = txt..": "..tostring(_G.XU_Config[key])
        end)
    end

    makeBtn("Radius", "Radius", 0, 5)
    makeBtn("Tilt X", "TiltX", 30, 45)
    makeBtn("Speed", "Speed", 60, 20)
    makeBtn("Scale", "SizeScale", 90, 0.2)

    local run = Instance.new("TextButton", main)
    run.Size = UDim2.new(0.9, 0, 0, 30); run.Position = UDim2.new(0.05, 0, 1, -35)
    run.BackgroundColor3 = Color3.fromRGB(0, 120, 255); run.Text = "✧ INJECT ✧"; run.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", run)
    
    run.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        run.BackgroundColor3 = _G.XU_Config.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 120, 255)
        run.Text = _G.XU_Config.Enabled and "RUNNING" or "✧ INJECT ✧"
        if _G.XU_Config.Enabled then scanForBackdoor(); startLoop() end
    end)
end

createUI()
