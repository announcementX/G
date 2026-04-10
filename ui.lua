local Library = {Tabs = {}; SelectedTab = nil; Elements = {}}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- 颜色配置：灵魂深粉色调
local COLORS = {
    Main = Color3.fromRGB(255, 230, 240),
    Bar = Color3.fromRGB(255, 175, 200),
    Sidebar = Color3.fromRGB(255, 240, 245),
    Accent = Color3.fromRGB(200, 100, 150), -- 灵魂深粉
    Text = Color3.fromRGB(80, 60, 70),
    Highlight = Color3.fromRGB(255, 120, 180)
}

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V4"
    
    -- --- 1. SOUL 灵魂加载动画 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- 灵魂深处背景
    Loader.ZIndex = 2000

    local SoulText = Instance.new("TextLabel", Loader)
    SoulText.Text = "SOUL"
    SoulText.Font = Enum.Font.GothamBold
    SoulText.TextSize = 100
    SoulText.TextColor3 = COLORS.Main
    SoulText.Position = UDim2.new(0.5, -100, 0.5, -50)
    SoulText.Size = UDim2.new(0, 200, 0, 100)
    SoulText.BackgroundTransparency = 1
    SoulText.ZIndex = 2001

    -- 粒子效果 (简单的灵魂光点)
    for i = 1, 10 do
        local p = Instance.new("Frame", Loader)
        p.Size = UDim2.new(0, 4, 0, 4)
        p.BackgroundColor3 = COLORS.Accent
        p.Position = UDim2.new(0.5, math.random(-150, 150), 0.5, math.random(-150, 150))
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        TweenService:Create(p, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}):Play()
    end

    task.wait(1.5)
    TweenService:Create(Loader, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(SoulText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.delay(0.8, function() Loader:Destroy() end)

    -- --- 2. 主框架 ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 550, 0, 380)
    Main.Position = UDim2.new(0.5, -275, 0.5, -190)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 拖拽逻辑修复
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- 上下渐变栏 (45px)
    local function MakeBar(pos, rot)
        local bar = Instance.new("Frame", Main)
        bar.Size = UDim2.new(1, 0, 0, 45)
        bar.Position = pos
        bar.BackgroundColor3 = COLORS.Bar
        bar.BorderSizePixel = 0
        local g = Instance.new("UIGradient", bar)
        g.Rotation = rot
        g.Transparency = NumberSequence.new(0, 1)
        return bar
    end
    local TopBar = MakeBar(UDim2.new(0,0,0,0), 90)
    local BottomBar = MakeBar(UDim2.new(0,0,1,-45), -90)

    -- 侧边栏
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.8,0), NumberSequenceKeypoint.new(1,1)})
    
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.HorizontalAlignment = "Center"

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -160, 1, -100)
    Container.Position = UDim2.new(0, 150, 0, 50)
    Container.BackgroundTransparency = 1

    -- --- 3. 功能键修复 (关闭/缩小) ---
    local Title = Instance.new("TextLabel", Main)
    Title.Text = "SOUL | ENGINE"
    Title.Font = "GothamBold"
    Title.TextColor3 = COLORS.Text
    Title.TextSize = 16
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 0, 45)
    Title.BackgroundTransparency = 1

    local function CreateControl(txt, pos, color, callback)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(1, pos, 0, 7)
        btn.BackgroundColor3 = color
        btn.Text = txt
        btn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
    end

    CreateControl("×", -40, Color3.fromRGB(255, 80, 80), function() ScreenGui:Destroy() end)
    
    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 50, 0, 50)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "S"
    MiniIcon.TextColor3 = Color3.new(1,1,1)
    MiniIcon.Visible = false
    Instance.new("UICorner", MiniIcon)

    CreateControl("-", -75, COLORS.Accent, function()
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon.Position = UDim2.new(0, Main.AbsolutePosition.X + 250, 0, Main.AbsolutePosition.Y + 160)
    end)

    MiniIcon.MouseButton1Click:Connect(function() Main.Visible = true MiniIcon.Visible = false end)

    -- --- 4. API (修复高亮提示不消除) ---
    local currentBtn = nil

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 125, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "GothamMedium"
        TabBtn.TextSize = 14

        local Indicator = Instance.new("Frame", TabBtn)
        Indicator.Size = UDim2.new(0, 4, 0, 0) -- 初始高度0
        Indicator.Position = UDim2.new(0, 5, 0.5, 0)
        Indicator.BackgroundColor3 = COLORS.Highlight
        Indicator.BorderSizePixel = 0
        Instance.new("UICorner", Indicator)

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            -- 消除之前的高亮
            if currentBtn and currentBtn ~= TabBtn then
                TweenService:Create(currentBtn.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 4, 0, 0), Position = UDim2.new(0, 5, 0.5, 0)}):Play()
                TweenService:Create(currentBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Text}):Play()
            end
            
            -- 设置当前高亮
            currentBtn = TabBtn
            TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 4, 0, 24), Position = UDim2.new(0, 5, 0.5, -12)}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Highlight}):Play()

            -- 页面切换效果
            for _, p in pairs(Container:GetChildren()) do p.Visible = false end
            Page.Visible = true
            Page.Position = UDim2.new(0, 50, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end)

        local TabAPI = {}
        function TabAPI:AddButton(text, callback)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.new(1,1,1)
            b.BackgroundTransparency = 0.5
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.TextColor3 = COLORS.Text
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
        end

        function TabAPI:AddToggle(text, callback)
            local t = Instance.new("TextButton", Page)
            t.Size = UDim2.new(1, -10, 0, 40)
            t.BackgroundColor3 = Color3.new(1,1,1)
            t.BackgroundTransparency = 0.5
            t.Text = "  " .. text
            t.TextXAlignment = "Left"
            t.TextColor3 = COLORS.Text
            Instance.new("UICorner", t)

            local box = Instance.new("Frame", t)
            box.Size = UDim2.new(0, 40, 0, 20)
            box.Position = UDim2.new(1, -50, 0.5, -10)
            box.BackgroundColor3 = COLORS.Bar
            Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)

            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.new(0, 16, 0, 16)
            dot.Position = UDim2.new(0, 2, 0.5, -8)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

            local s = false
            t.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(dot, TweenInfo.new(0.3), {Position = UDim2.new(s and 1 or 0, s and -18 or 2, 0.5, -8)}):Play()
                TweenService:Create(box, TweenInfo.new(0.3), {BackgroundColor3 = s and COLORS.Highlight or COLORS.Bar}):Play()
                callback(s)
            end)
        end

        return TabAPI
    end

    return Library
end

return Library
