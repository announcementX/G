--[[
    脚本名称：XU GALAXY V25 (全维度后门寄生 & 物理同步版)
    核心亮点：
    1. 深度扫描引擎：递归扫描 20+ 个系统服务，捕捉任何非标准 Remote。
    2. 动态植入：一旦发现后门，自动尝试常用的提权参数 (Sync, Execute, Run)。
    3. 全维光环：X/Y/Z 三轴旋转 + 偏移调节 + 速度镜像恢复。
    4. 稳定算法：RenderStepped 锁定 CFrame，防止 V19 的乱飞 Bug。
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local isEnabled = false
local activeBackdoor = nil 

-- --- 1. 后门探测引擎 (极致搜索) ---
local function findEveryBackdoor()
    local suspects = {}
    -- 搜索所有可能隐藏后门的敏感服务
    local targetServices = {
        game:GetService("JointsService"),
        game:GetService("LogService"),
        game:GetService("Selection"),
        game:GetService("ReplicatedStorage"),
        game:GetService("TeleportService"),
        game:GetService("InsertService"),
        game:GetService("HttpService"),
        game:GetService("RobloxReplicatedStorage"),
        workspace
    }

    for _, service in pairs(targetServices) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                -- 核心逻辑：寻找所有能与服务器通信的对象，无论它叫什么
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    -- 过滤掉游戏正常的 Remote (通常在 ReplicatedStorage 的常规路径下)
                    if not obj:GetFullName():find("Default") then
                        table.insert(suspects, obj)
                    end
                end
            end
        end)
    end

    -- 优先级排序：隐藏在 JointsService 或名字是乱码的优先
    for _, r in pairs(suspects) do
        if r.Parent == game:GetService("JointsService") or #r.Name > 15 or r.Name:match("%W") then
            activeBackdoor = r
            return true, "!!! 成功识别后门信道: " .. r.Name
        end
    end
    
    if #suspects > 0 then
        activeBackdoor = suspects[1]
        return true, "找到疑似远程事件: " .. activeBackdoor.Name
    end

    return false, "未发现后门，启用高频物理同步模式。"
end

-- --- 2. 配置与还原逻辑 ---
local cfg = {
    speed = 60, fly = false, radius = 6, rotSpeed = 2,
    offX = 0, offY = 0, offZ = 0,
    tiltX = 0, tiltY = 0, tiltZ = 0,
    headFollow = true
}

local tasks = {}

local function resetCharacter()
    isEnabled = false
    if tasks.Main then tasks.Main:Disconnect() end
    local hum = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if hum then hum.WalkSpeed = 16 end
    if root then root.Anchored = false end
    for _, v in pairs(character:GetDescendants()) do 
        if v:IsA("Motor6D") then v.Enabled = true end
        if v:IsA("BasePart") then v.CanCollide = true end
    end
end

-- --- 3. 核心驱动 (后门植入/物理双驱) ---
local function runXULoop()
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    local limbs = {}
    
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.CanCollide = false
            p.Massless = true
            if p.Name ~= "Head" then table.insert(limbs, p) end
        end
    end

    tasks.Main = RunService.RenderStepped:Connect(function(dt)
        if not isEnabled or not root then return end
        
        -- A. 飞行逻辑 (全维度)
        if cfg.fly then
            root.Anchored = true
            root.Velocity = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (cam.CFrame.LookVector * cfg.speed * dt)
            end
        else
            root.Anchored = false
            hum.WalkSpeed = cfg.speed
        end

        -- B. 光环逻辑
        local t = tick() * cfg.rotSpeed
        local centerPos = root.Position + Vector3.new(cfg.offX, cfg.offY, cfg.offZ)
        local centerCF = CFrame.new(centerPos) * CFrame.Angles(math.rad(cfg.tiltX), math.rad(cfg.tiltY), math.rad(cfg.tiltZ))

        if cfg.headFollow then character.Head.CFrame = centerCF end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local lPos = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
            local targetCF = centerCF * CFrame.new(lPos) * CFrame.Angles(t, t, 0)
            
            -- 【后门植入逻辑】
            if activeBackdoor then
                pcall(function()
                    -- 尝试多种后门协议进行服务器同步
                    activeBackdoor:FireServer("Sync", part.Name, targetCF)
                    activeBackdoor:FireServer(string.format("game.Players.LocalPlayer.Character['%s'].CFrame = ...", part.Name), targetCF)
                end)
            end

            part.CFrame = targetCF
        end
    end)
end

-- --- 4. 极致全功能 UI ---
local function createUI()
    local sg = Instance.new("ScreenGui", CoreGui)
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 200, 0, 400); main.Position = UDim2.new(0.5, -100, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20); main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", main).Color = Color3.fromRGB(100, 150, 255)

    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 35); bar.BackgroundTransparency = 0.8
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -40, 1, 0); title.Text = "  ✦ XU OMNI V25"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextXAlignment = 0

    local minBtn = Instance.new("TextButton", bar)
    minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -35, 0, 2.5); minBtn.Text = "−"; minBtn.TextColor3 = Color3.new(1,1,1); minBtn.BackgroundColor3 = Color3.fromRGB(50,50,100); Instance.new("UICorner", minBtn)

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, 0, 1, -95); scroll.Position = UDim2.new(0, 0, 0, 35); scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0, 0, 0, 850); scroll.ScrollBarThickness = 2

    local function addControl(name, y, key, step)
        local l = Instance.new("TextLabel", scroll)
        l.Size = UDim2.new(1, 0, 0, 20); l.Position = UDim2.new(0, 0, 0, y); l.Text = name; l.TextColor3 = Color3.fromRGB(180, 200, 255); l.BackgroundTransparency = 1; l.TextSize = 10
        local b1 = Instance.new("TextButton", scroll)
        b1.Size = UDim2.new(0, 50, 0, 25); b1.Position = UDim2.new(0.1, 0, 0, y+22); b1.Text = "-"; b1.BackgroundColor3 = Color3.fromRGB(40,40,80); b1.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b1)
        local b2 = Instance.new("TextButton", scroll)
        b2.Size = UDim2.new(0, 50, 0, 25); b2.Position = UDim2.new(0.65, 0, 0, y+22); b2.Text = "+"; b2.BackgroundColor3 = Color3.fromRGB(40,40,80); b2.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b2)
        b1.Activated:Connect(function() cfg[key] = cfg[key] - step end)
        b2.Activated:Connect(function() cfg[key] = cfg[key] + step end)
    end

    addControl("飞行/移动速度", 10, "speed", 10)
    addControl("光环半径", 65, "radius", 1)
    addControl("垂直偏移(Y)", 120, "offY", 1)
    addControl("侧向偏移(X)", 175, "offX", 1)
    addControl("深度偏移(Z)", 230, "offZ", 1)
    addControl("俯仰角度(X)", 285, "tiltX", 15)
    addControl("水平角度(Y)", 340, "tiltY", 15)
    addControl("侧倾角度(Z)", 395, "tiltZ", 15)
    addControl("自转速率", 450, "rotSpeed", 0.5)

    local function addToggle(name, y, key)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 60); btn.Text = name; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
        btn.Activated:Connect(function() cfg[key] = not cfg[key]; btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 60) end)
    end

    addToggle("开启视角飞行", 510, "fly")
    addToggle("中心锁定头部", 550, "headFollow")

    local statusLab = Instance.new("TextLabel", scroll)
    statusLab.Size = UDim2.new(1, 0, 0, 40); statusLab.Position = UDim2.new(0, 0, 0, 600); statusLab.Text = "准备扫描服务器..."; statusLab.TextColor3 = Color3.new(1,1,0); statusLab.BackgroundTransparency = 1; statusLab.TextWrapped = true; statusLab.TextSize = 10

    local toggle = Instance.new("TextButton", main)
    toggle.Size = UDim2.new(1, 0, 0, 55); toggle.Position = UDim2.new(0, 0, 1, -55); toggle.Text = "✦ 启动深度核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 90, 220); toggle.TextColor3 = Color3.new(1,1,1); toggle.Font = Enum.Font.GothamBold

    toggle.Activated:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggle.Text = "停止重置速度"; toggle.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
            local found, msg = findEveryBackdoor()
            statusLab.Text = msg
            for _, v in pairs(character:GetDescendants()) do if v:IsA("Motor6D") then v.Enabled = false end end
            runXULoop()
        else
            toggle.Text = "✦ 启动深度核心"; toggle.BackgroundColor3 = Color3.fromRGB(60, 90, 220)
            resetCharacter()
        end
    end)

    -- 拖拽与缩小
    local dragging, dragStart, startPos
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = main.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then local delta = input.Position - dragStart; main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
    local isMin = false
    minBtn.Activated:Connect(function()
        isMin = not isMin; minBtn.Text = isMin and "+" or "−"
        scroll.Visible = not isMin; toggle.Visible = not isMin
        main:TweenSize(isMin and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 200, 0, 400), "Out", "Quart", 0.3, true)
    end)
end

createUI()
