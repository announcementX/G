local Library = {Tabs = {}; Count = 0; Animating = false}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V10_ETHEREAL"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        Main = Color3.fromRGB(255, 245, 250),
        Sidebar = Color3.fromRGB(255, 210, 230),
        Accent = Color3.fromRGB(255, 120, 180),
        Text = Color3.fromRGB(80, 60, 70),
        LoaderBG = Color3.fromRGB(15, 12, 14)
    }

    -- --- 1. 震撼：灵魂粒子炸裂加载 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.LoaderBG
    Loader.ZIndex = 20000

    local CenterText = Instance.new("TextLabel", Loader)
    CenterText.Size = UDim2.new(1, 0, 1, 0)
    CenterText.Text = "SOUL"
    CenterText.Font = "GothamBold"
    CenterText.TextColor3 = Color3.new(1, 1, 1)
    CenterText.TextSize = 0
    CenterText.BackgroundTransparency = 1
    CenterText.ZIndex = 20001

    task.spawn(function()
        -- 粒子爆炸
        for i = 1, 24 do
            local p = Instance.new("Frame", Loader)
            p.Size = UDim2.new(0, 4, 0, 4)
            p.BackgroundColor3 = COLORS.Accent
            p.Position = UDim2.new(0.5, 0, 0.5, 0)
            Instance.new("UICorner", p)
            local angle = math.rad(i * (360/24))
            local targetPos = UDim2.new(0.5 + math.cos(angle)*0.2, 0, 0.5 + math.sin(angle)*0.2, 0)
            TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Position = targetPos, BackgroundTransparency = 1}):Play()
        end
        TweenService:Create(CenterText, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 80}):Play()
        task.wait(1.5)
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        TweenService:Create(CenterText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (极简设计) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 380)
    Main.Position = UDim2.new(0.5, -280, 0.5, -190)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.ZIndex = 100
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

    -- 渐变背景
    local Grad = Instance.new("UIGradient", Main)
    Grad.Color = ColorSequence.new(COLORS.Sidebar, COLORS.Main)
    Grad.Rotation = 45

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -170, 1, -70)
    Container.Position = UDim2.new(0, 160, 0, 60)
    Container.BackgroundTransparency = 1

    -- --- 3. 隐藏式控制键 (点击必灵敏) ---
    local function CreateControl(icon, x, cb)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0, 24, 0, 24)
        b.Position = UDim2.new(1, x, 0, 15)
        b.BackgroundTransparency = 0.8
        b.BackgroundColor3 = COLORS.Accent
        b.Text = icon
        b.TextColor3 = COLORS.Text
        b.Font = "Gotham"
        b.TextSize = 12
        b.ZIndex = 500
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        b.MouseButton1Click:Connect(function()
            if Library.Animating then return end -- 动画中禁止重复点击
            cb()
        end)
    end

    -- 缩小回显球 (极小化设计)
    local MiniBall = Instance.new("TextButton", ScreenGui)
    MiniBall.Size = UDim2.new(0, 35, 0, 35) -- 缩小尺寸
    MiniBall.BackgroundColor3 = COLORS.Accent
    MiniBall.Visible = false
    MiniBall.ZIndex = 1000
    MiniBall.Text = ""
    Instance.new("UICorner", MiniBall).CornerRadius = UDim.new(1, 0)
    -- 呼吸灯特效
    task.spawn(function()
        while true do
            TweenService:Create(MiniBall, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.4}):Play()
            task.wait(1)
            TweenService:Create(MiniBall, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
            task.wait(1)
        end
    end)

    -- 关闭动画
    CreateControl("✕", -35, function()
        Library.Animating = true
        Main:TweenSizeAndPosition(UDim2.new(0,0,0,0), Main.Position + UDim2.new(0,280,0,190), "In", "Back", 0.4, true)
        task.wait(0.4) ScreenGui:Destroy()
    end)

    -- 缩小动画 (丝滑衔接)
    CreateControl("—", -65, function()
        Library.Animating = true
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Quad", 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        MiniBall.Position = UDim2.new(0.5, -17, 0.05, 0)
        MiniBall.Visible = true
        Library.Animating = false
    end)

    MiniBall.MouseButton1Click:Connect(function()
        MiniBall.Visible = false
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 560, 0, 380), "Out", "Back", 0.4, true)
    end)

    -- --- 4. 栏目 API ---
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundTransparency = 1
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 10)
    SideLayout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 70)

    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count
        
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.85, 0, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "Gotham"
        TabBtn.TextSize = 13
        TabBtn.ZIndex = 120

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            if Library.Animating then return end
            -- 强制物理重置
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 1 end end
            
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.BackgroundColor3 = Color3.new(1,1,1)
            -- 侧边栏切入动画
            Page.Position = UDim2.new(0, 15, 0, 0)
            Page:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
        end)

        -- 默认开启第一个
        if ID == 1 then task.delay(1.6, function() Page.Visible = true end) end

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.5
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.Font = "GothamMedium"
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(cb)
        end
        function TabAPI:AddToggle(text, cb)
            local t = Instance.new("TextButton", Page)
            t.Size = UDim2.new(1, -10, 0, 38)
            t.BackgroundColor3 = Color3.new(1, 1, 1)
            t.BackgroundTransparency = 0.5
            t.Text = "  " .. text
            t.TextXAlignment = "Left"
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
            
            local box = Instance.new("Frame", t)
            box.Size = UDim2.new(0, 34, 0, 18)
            box.Position = UDim2.new(1, -45, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
            
            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(0, 2, 0.5, -7)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", dot)

            local s = false
            t.MouseButton1Click:Connect(function()
                s = not s
                dot:TweenPosition(UDim2.new(s and 1 or 0, s and -16 or 2, 0.5, -7), "Out", "Quad", 0.2, true)
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = s and COLORS.Accent or Color3.fromRGB(210, 210, 210)}):Play()
                cb(s)
            end)
        end
        return TabAPI
    end

    -- 拖拽逻辑修复
    local dStart, sPos, dragging
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dStart = i.Position sPos = Main.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dStart
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    return Library
end

return Library
