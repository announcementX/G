--[[
    ✧ XU GALAXY V35: STVERSION (Stabilized Injection) ✧
    解决：开启后瞬间飞走、乱窜、物理弹射问题。
    增加：动能重置器、平台锁定、平滑后门同步。
]]

_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0, TiltX = 0, TiltY = 0, TiltZ = 0, Scale = 1,
    TargetRemote = nil, Status = "WAITING"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

-- --- 1. 深度后门探测器 (保持不变) ---
local function findBackdoor()
    local potential = {}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and not v:GetFullName():find("Default") then
            if v.Name:lower():find("sync") or v.Name:lower():find("event") or #v.Name > 15 then
                _G.XU_Config.TargetRemote = v
                _G.XU_Config.Status = "SYNC: " .. v.Name
                return
            end
            table.insert(potential, v)
        end
    end
    if #potential > 0 then
        _G.XU_Config.TargetRemote = potential[1]
        _G.XU_Config.Status = "GENERIC: " .. potential[1].Name
    end
end

-- --- 2. 物理稳定器 (解决“乱飞”的核心) ---
local function stabilizePhysics(state)
    if state then
        -- 开启注入时：锁定状态，防止物理引擎反弹
        hum.PlatformStand = true -- 停止 Humanoid 所有内置动画和物理
        root.Anchored = false
        
        -- 清除并持续重置速度
        local velCleanup = RunService.Heartbeat:Connect(function()
            if _G.XU_Config.Enabled then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
        _G.VelCleanup = velCleanup
    else
        -- 关闭注入时：恢复正常
        hum.PlatformStand = false
        if _G.VelCleanup then _G.VelCleanup:Disconnect() end
    end
end

-- --- 3. 后门注入负载 ---
local function sendPayload(part, cf)
    local remote = _G.XU_Config.TargetRemote
    if not remote then return end
    pcall(function()
        remote:FireServer(part, cf) -- 协议1
        remote:FireServer("Update", part, cf) -- 协议2
    end)
end

-- --- 4. 几何同步核心 (V35 稳定版) ---
local function startGalaxyEngine()
    local limbs = {}
    for _, p in pairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            p.CanCollide = false
            p.Massless = true
            local m6d = p:FindFirstChildOfClass("Motor6D")
            if m6d then m6d.Enabled = false end -- 彻底断开关节约束
        end
    end

    _G.MainLoop = RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled then return end
        
        local c = _G.XU_Config
        local t = tick() * c.RotSpeed
        
        -- 核心坐标参考点
        local baseCF = CFrame.new(root.Position + Vector3.new(c.OffX, c.OffY, c.OffZ))
        local masterCF = baseCF * CFrame.Angles(math.rad(c.TiltX), math.rad(c.TiltY), math.rad(c.TiltZ))
        
        -- 飞行移动控制 (平滑处理)
        if c.Fly then
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame:Lerp(root.CFrame + (cam.CFrame.LookVector * c.Speed * dt), 0.3)
            end
        end

        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local offset = Vector3.new(math.cos(angle) * c.Radius, 0, math.sin(angle) * c.Radius) * c.Scale
            local targetCF = masterCF * CFrame.new(offset) * CFrame.Angles(t, t, t/2)
            
            -- 后门注入：让别人看到
            sendPayload(part, targetCF)
            
            -- 本地渲染
            part.CFrame = targetCF
        end
    end)
end

-- --- 5. 极简 UI ---
local function createUI()
    if CoreGui:FindFirstChild("XU_V35") then CoreGui.XU_V35:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_V35"
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 150, 0, 240); main.Position = UDim2.new(1, -160, 0.4, 0)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", main)
    
    local st = Instance.new("TextLabel", main)
    st.Size = UDim2.new(1, 0, 0, 30); st.Text = "STABLE SYNC"; st.TextColor3 = Color3.new(1,1,1); st.BackgroundTransparency = 1
    
    local log = Instance.new("TextLabel", main)
    log.Size = UDim2.new(1, 0, 0, 20); log.Position = UDim2.new(0,0,0,30); log.TextSize = 8; log.TextColor3 = Color3.new(0,1,0); log.BackgroundTransparency = 1
    RunService.RenderStepped:Connect(function() log.Text = _G.XU_Config.Status end)

    local function btn(txt, y, key, step)
        local b = Instance.new("TextButton", main); b.Size = UDim2.new(0.9, 0, 0, 25); b.Position = UDim2.new(0.05, 0, 0, y)
        b.Text = txt..": ".._G.XU_Config[key]; b.BackgroundColor3 = Color3.new(0.2,0.2,0.3); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.Activated:Connect(function()
            _G.XU_Config[key] = (_G.XU_Config[key] + step > 100) and 0 or (_G.XU_Config[key] + step)
            b.Text = txt..": ".._G.XU_Config[key]
        end)
    end

    btn("Radius", 60, "Radius", 5)
    btn("Scale (缩小)", 90, "Scale", 0.2)
    btn("Speed", 120, "Speed", 20)

    local run = Instance.new("TextButton", main)
    run.Size = UDim2.new(0.9, 0, 0, 40); run.Position = UDim2.new(0.05, 0, 1, -50)
    run.Text = "✧ INJECT ✧"; run.BackgroundColor3 = Color3.fromRGB(0, 150, 255); run.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", run)
    
    run.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        run.Text = _G.XU_Config.Enabled and "STABLE RUNNING" or "✧ INJECT ✧"
        run.BackgroundColor3 = _G.XU_Config.Enabled and Color3.new(0.6, 0, 0) or Color3.fromRGB(0, 150, 255)
        
        if _G.XU_Config.Enabled then
            findBackdoor()
            stabilizePhysics(true)
            startGalaxyEngine()
        else
            stabilizePhysics(false)
            if _G.MainLoop then _G.MainLoop:Disconnect() end
        end
    end)
end

createUI()
