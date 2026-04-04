--[[
    LIMEHUB & BLOXPASTE 风格定制脚本
    功能：R15 肢体星空环绕 + 传送移动 + 距离/速度调节
    特性：单文件执行，全服可见（利用 Network Ownership）
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- --- 核心变量 ---
local isEnabled = false
local moveSpeed = 50
local orbitDistance = 5
local connections = {}
local folderName = "StarryLimb_Storage"

-- --- 1. 启动弹窗 (左图右字) ---
local function showNotify()
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 280, 0, 70)
    frame.Position = UDim2.new(0.5, -140, 0, -100)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(0, 50, 0, 50)
    img.Position = UDim2.new(0, 10, 0, 10)
    img.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=15"
    img.BackgroundTransparency = 1
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(0, 200, 0, 70)
    txt.Position = UDim2.new(0, 70, 0, 0)
    txt.Text = "脚本已打开"
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    txt.BackgroundTransparency = 1
    txt.TextXAlignment = Enum.TextXAlignment.Left

    frame:TweenPosition(UDim2.new(0.5, -140, 0, 60), "Out", "Quart", 0.5, true)
    task.delay(3, function()
        frame:TweenPosition(UDim2.new(0.5, -140, 0, -100), "In", "Quart", 0.5, true)
        task.wait(0.5)
        sg:Destroy()
    end)
end

-- --- 2. 核心功能逻辑 ---
local function toggleScript(state)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")

    if state then
        -- R15 体型检测
        if hum.RigType ~= Enum.HumanoidRigType.R15 then
            warn("检测到非 R15 体型，脚本强制终止")
            isEnabled = false
            return
        end

        -- 禁用关节同步 (利用执行器的本地控制权)
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
        end
        root.Anchored = true

        local limbs = {}
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
                table.insert(limbs, p)
                p.CanCollide = false
            end
        end

        -- 每一帧刷新位置
        connections.Orbit = RunService.Heartbeat:Connect(function()
            local t = tick()
            for i, limb in ipairs(limbs) do
                local angle = (i / #limbs) * math.pi * 2 + t
                local offset = Vector3.new(math.cos(angle) * orbitDistance, math.sin(t * 0.5) * 2, math.sin(angle) * orbitDistance)
                limb.CFrame = head.CFrame * CFrame.new(offset) * CFrame.Angles(t, angle, 0)
            end
            
            -- 传送移动处理
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * moveSpeed * 0.016)
            end
        end)
    else
        -- 恢复正常
        if connections.Orbit then connections.Orbit:Disconnect() end
        root.Anchored = false
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end
end

-- --- 3. 星空 UI 界面 ---
local function createUI()
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "StarryEx"

    -- 左侧控制面板
    local panel = Instance.new("Frame", sg)
    panel.Size = UDim2.new(0, 80, 0, 220)
    panel.Position = UDim2.new(0.02, 0, 0.4, 0)
    panel.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    panel.Visible = false
    Instance.new("UICorner", panel)
    
    local grad = Instance.new("UIGradient", panel)
    grad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 60), Color3.fromRGB(0, 0, 0))
    grad.Rotation = 90

    local function makeAdjuster(name, yPos, callback)
        local label = Instance.new("TextLabel", panel)
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, yPos)
        label.Text = name
        label.TextColor3 = Color3.new(0.8, 0.8, 1)
        label.BackgroundTransparency = 1
        
        local up = Instance.new("TextButton", panel)
        up.Size = UDim2.new(0.4, 0, 0, 30)
        up.Position = UDim2.new(0.5, 0, 0, yPos + 30)
        up.Text = "+"
        up.TextColor3 = Color3.new(1, 1, 1)
        up.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
        Instance.new("UICorner", up)

        local down = Instance.new("TextButton", panel)
        down.Size = UDim2.new(0.4, 0, 0, 30)
        down.Position = UDim2.new(0.1, 0, 0, yPos + 30)
        down.Text = "-"
        down.TextColor3 = Color3.new(1, 1, 1)
        down.BackgroundColor3 = Color3.fromRGB(30, 30, 70)
        Instance.new("UICorner", down)

        up.MouseButton1Click:Connect(function() callback(true) end)
        down.MouseButton1Click:Connect(function() callback(false) end)
    end

    makeAdjuster("速度", 10, function(inc) moveSpeed = inc and moveSpeed + 10 or math.max(10, moveSpeed - 10) end)
    makeAdjuster("距离", 100, function(inc) orbitDistance = inc and orbitDistance + 1 or math.max(1, orbitDistance - 1) end)

    -- 主开关
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 130, 0, 45)
    btn.Position = UDim2.new(0.5, -65, 0.9, 0)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
    btn.Text = "开启脚本"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(80, 80, 255)

    btn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            toggleScript(true)
            if isEnabled then
                btn.Text = "关闭脚本"
                panel.Visible = true
            end
        else
            toggleScript(false)
            btn.Text = "开启脚本"
            panel.Visible = false
        end
    end)
end

-- 初始化
showNotify()
createUI()
