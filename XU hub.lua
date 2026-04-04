--[[
    ✧ XU GALAXY V34: BACKDOOR HUNTER & INJECTOR ✧
    Description: Full monolithic implementation for immediate integration.
    Focus: Deep RemoteEvent memory scanning, protocol fuzzing, and optimized multi-player CFrame replication.
]]

-- System variables & Configuration
_G.XU_Config = {
    Enabled = false, Speed = 60, Fly = false, Radius = 8, RotSpeed = 2,
    OffX = 0, OffY = 0, OffZ = 0, TiltX = 0, TiltY = 0, TiltZ = 0, Scale = 1,
    TargetRemote = nil, Status = "AWAITING SCAN"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JointsService = game:GetService("JointsService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--=============================================================================
-- PRIMARY FUNCTION 1: DEEP REMOTE SCANNER (SECURITY & MEMORY EXPLOITATION)
--=============================================================================
--[[
    Function: scanForVulnerabilities()
    Logic: Iterates through specific game services known for harboring unsecured
    RemoteEvents (often left by infected models or poor development practices).
    It filters out default Roblox remotes and targets anomalies based on naming
    conventions and location.
]]
local function scanForVulnerabilities()
    local potentialTargets = {}
    local servicesToScan = {ReplicatedStorage, JointsService, workspace}
    
    -- Recursively gather all RemoteEvents
    for _, service in ipairs(servicesToScan) do
        pcall(function()
            for _, obj in ipairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") and not string.find(obj:GetFullName(), "Default") then
                    table.insert(potentialTargets, obj)
                end
            end
        end)
    end
    
    -- Filter logic: prioritize Remotes with suspicious names or isolated locations
    for _, remote in ipairs(potentialTargets) do
        local name = string.lower(remote.Name)
        if string.match(name, "sync") or string.match(name, "update") or string.match(name, "event") or #name > 15 then
            _G.XU_Config.TargetRemote = remote
            _G.XU_Config.Status = "HOOKED: " .. remote.Name
            return
        end
    end
    
    -- Fallback: Grab the first available generic RemoteEvent if no suspicious ones are found
    if #potentialTargets > 0 then
        _G.XU_Config.TargetRemote = potentialTargets[1]
        _G.XU_Config.Status = "GENERIC HOOK: " .. potentialTargets[1].Name
    else
        _G.XU_Config.Status = "NO BACKDOOR FOUND"
    end
end

--=============================================================================
-- PRIMARY FUNCTION 2: PAYLOAD INJECTION (ROBLOX API PROTOCOL FUZZING)
--=============================================================================
--[[
    Function: executeInjection(part, targetCFrame)
    Logic: Attempts to brute-force the server's replication handler by firing
    the located RemoteEvent with various common parameter structures. This maximizes
    the chance of the server accepting the CFrame data for multi-player visibility.
]]
local function executeInjection(part, targetCFrame)
    local remote = _G.XU_Config.TargetRemote
    if not remote then return end
    
    pcall(function()
        -- Protocol A: Direct Argument Passing (Standard)
        remote:FireServer(part, targetCFrame)
        -- Protocol B: Keyword String Execution (Common in vulnerable Admin scripts)
        remote:FireServer("UpdateCFrame", part, targetCFrame)
        remote:FireServer("Sync", part, targetCFrame)
        -- Protocol C: Explicit Key-Value Definition (Advanced structures)
        remote:FireServer({["Part"] = part, ["CFrame"] = targetCFrame})
    end)
end

--=============================================================================
-- PRIMARY FUNCTION 3: GEOMETRY ENGINE (PERFORMANCE OPTIMIZED)
--=============================================================================
--[[
    Function: initializeGalaxyCore()
    Logic: Manages the mathematical offset and rotation calculations for the halo.
    Bound to RunService.Stepped for optimal script efficiency and reduced lag,
    ensuring smooth replication even under heavy network load.
]]
local function initializeGalaxyCore()
    local root = character:WaitForChild("HumanoidRootPart")
    local limbs = {}
    
    -- Strip physical constraints for free movement
    for _, p in ipairs(character:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "Head" then
            table.insert(limbs, p)
            local motor = p:FindFirstChildOfClass("Motor6D")
            if motor then motor.Enabled = false end
            p.CanCollide = false
            p.Massless = true
        end
    end

    RunService.Stepped:Connect(function(_, dt)
        if not _G.XU_Config.Enabled then return end
        
        local c = _G.XU_Config
        local t = tick() * c.RotSpeed
        
        -- Pre-calculate base transformation matrix to optimize script efficiency
        local baseCenter = CFrame.new(root.Position + Vector3.new(c.OffX, c.OffY, c.OffZ))
        local rotationMatrix = CFrame.Angles(math.rad(c.TiltX), math.rad(c.TiltY), math.rad(c.TiltZ))
        local masterCF = baseCenter * rotationMatrix
        
        for i, part in ipairs(limbs) do
            local angle = (i / #limbs) * math.pi * 2 + t
            local offsetPos = Vector3.new(math.cos(angle) * c.Radius, 0, math.sin(angle) * c.Radius) * c.Scale
            
            -- Final CFrame construction
            local targetCF = masterCF * CFrame.new(offsetPos) * CFrame.Angles(t, t, t/2)
            
            -- Attempt network replication using the hooked RemoteEvent
            executeInjection(part, targetCF)
            
            -- Local client rendering
            part.CFrame = targetCF
        end
    end)
end

--=============================================================================
-- USER INTERFACE (NANO-HUD)
--=============================================================================
local function deployHUD()
    if CoreGui:FindFirstChild("XU_HUD") then CoreGui.XU_HUD:Destroy() end
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "XU_HUD"

    -- Ultra-compact design to prevent screen obstruction
    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(0, 160, 0, 260); bg.Position = UDim2.new(1, -180, 0.5, -130)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20); bg.BackgroundTransparency = 0.1
    Instance.new("UICorner", bg)
    Instance.new("UIStroke", bg).Color = Color3.fromRGB(80, 150, 255)

    -- Dynamic Status Monitor
    local status = Instance.new("TextLabel", bg)
    status.Size = UDim2.new(1, -10, 0, 30); status.Position = UDim2.new(0, 5, 0, 10)
    status.BackgroundTransparency = 1; status.TextColor3 = Color3.fromRGB(50, 255, 100)
    status.Font = Enum.Font.Code; status.TextSize = 9
    RunService.RenderStepped:Connect(function() status.Text = "NET: " .. _G.XU_Config.Status end)

    local scroll = Instance.new("ScrollingFrame", bg)
    scroll.Size = UDim2.new(1, 0, 1, -90); scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,0,400); scroll.ScrollBarThickness = 1

    local function addControl(txt, key, y, step)
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(30, 35, 50); btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.Gotham; btn.TextSize = 9; Instance.new("UICorner", btn)
        RunService.RenderStepped:Connect(function() btn.Text = txt..": "..tostring(_G.XU_Config[key]) end)
        btn.Activated:Connect(function() 
            _G.XU_Config[key] = (_G.XU_Config[key] + step > 360 and key:match("Tilt")) and 0 or (_G.XU_Config[key] + step)
            if key == "Scale" and _G.XU_Config[key] > 5 then _G.XU_Config[key] = 0.1 end
        end)
    end

    addControl("Radius", "Radius", 0, 2)
    addControl("Tilt X", "TiltX", 30, 45)
    addControl("Tilt Y", "TiltY", 60, 45)
    addControl("Scale", "Scale", 90, 0.2)
    addControl("Off Y", "OffY", 120, 2)

    local runBtn = Instance.new("TextButton", bg)
    runBtn.Size = UDim2.new(0.9, 0, 0, 35); runBtn.Position = UDim2.new(0.05, 0, 1, -40)
    runBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); runBtn.TextColor3 = Color3.new(1,1,1)
    runBtn.Text = "INITIALIZE CORE"; runBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", runBtn)

    runBtn.Activated:Connect(function()
        _G.XU_Config.Enabled = not _G.XU_Config.Enabled
        if _G.XU_Config.Enabled then
            runBtn.Text = "RUNNING"; runBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            -- Trigger deep scan strictly on activation
            scanForVulnerabilities()
            initializeGalaxyCore()
        else
            runBtn.Text = "INITIALIZE CORE"; runBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            _G.XU_Config.Status = "OFFLINE"
        end
    end)
end

deployHUD()
