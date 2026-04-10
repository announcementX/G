local Library = {Tabs = {}; SelectedTab = nil; IsActive = true}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_ENGINE_V5"
    ScreenGui.DisplayOrder = 100
    
    local COLORS = {
        Main = Color3.fromRGB(255, 230, 240),
        Bar = Color3.fromRGB(255, 170, 195),
        Sidebar = Color3.fromRGB(255, 242, 248),
        Accent = Color3.fromRGB(230, 90, 140),
        Text = Color3.fromRGB(60, 45, 50)
    }

    -- --- 1. 全屏震撼加载动画 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Loader.ZIndex = 5000

    local SoulText = Instance.new("TextLabel", Loader)
    SoulText.Text = "S  O  U  L"
    SoulText.Font = Enum.Font.GothamBold
    SoulText.TextSize = 60
    SoulText.TextColor3 = COLORS.Main
    SoulText.Size = UDim2.new(1, 0, 1, 0)
    SoulText.BackgroundTransparency = 1
    SoulText.ZIndex = 5001

    -- 粒子爆炸效果
    task.spawn(function()
        for i = 1, 20 do
            local p = Instance.new("Frame", Loader)
            p.Size = UDim2.new(0, 2, 0, 20)
            p.BackgroundColor3 = COLORS.Accent
            p.Position = UDim2.new(0.5, 0, 0.5, 0)
            p.AnchorPoint = Vector2.new(0.5, 0.5)
            Instance.new("UICorner", p)
            local angle = math.rad(i * (360/20))
            local dist = 300
            TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0.5, math.cos(angle)*dist, 0.5, math.sin(angle)*dist),
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
        end
        task.wait(1)
        TweenService:Create(Loader, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
        TweenService:Create(SoulText, TweenInfo.new(0.6), {TextTransparency = 1, TextSize = 100}):Play()
        task.delay(0.8, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 400)
    Main.Position = UDim2.new(0.5, -280, 0.5, -200)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- 渐变系统 (上下45px)
    local function AddBar(pos, rot)
        local b = Instance.new("Frame", Main)
        b.Size = UDim2.new(1, 0, 0, 45)
        b.Position = pos
        b.BackgroundColor3 = COLORS.Bar
        b.BorderSizePixel = 0
        local g = Instance.new("UIGradient", b)
        g.Rotation = rot
        g.Transparency = NumberSequence.new(0, 1)
        return b
    end
    local Top = AddBar(UDim2.new(0,0,0,0), 90)
    local Bottom = AddBar(UDim2.new(0,0,1,-45), -90)

    -- 侧边栏
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    local SLayout = Instance.new("UIListLayout", Sidebar)
    SLayout.Padding = UDim.new(0, 2)
    SLayout.HorizontalAlignment = "Center"

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -165, 1, -110)
    Container.Position = UDim2.new(0, 160, 0, 55)
    Container.BackgroundTransparency = 1

    -- --- 3. 核心交互 (关闭/缩小) ---
    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.ZIndex = 10
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -78, 0, 7)
    MinBtn.BackgroundColor3 = COLORS.Accent
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.ZIndex = 10
    Instance.new("UICorner", MinBtn)

    -- 缩小回显图标
    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 0, 0, 0)
    MiniIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "S"
    MiniIcon.TextColor3 = Color3.new(1,1,1)
    MiniIcon.Visible = false
    Instance.new("UICorner", MiniIcon)

    CloseBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.4, true)
        task.wait(0.4) ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenScale(0, Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon:TweenSize(UDim2.new(0,55,0,55), "Out", "Back", 0.4, true)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MiniIcon:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.3, true)
        task.wait(0.3)
        Main.Visible = true
        Main:TweenScale(1, Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
        MiniIcon.Visible = false
    end)

    -- 拖拽修复
    local dragging, dragStart, startPos
    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = i.Position startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- --- 4. API (修复无法切换栏目的核心逻辑) ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "Gotham"
        TabBtn.TextSize = 14

        local Line = Instance.new("Frame", TabBtn)
        Line.Size = UDim2.new(0, 0, 0, 2)
        Line.Position = UDim2.new(0.5, 0, 1, -5)
        Line.BackgroundColor3 = COLORS.Accent
        Line.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            -- 核心修复：遍历所有页面并重置
            for _, otherBtn in pairs(Sidebar:GetChildren()) do
                if otherBtn:IsA("TextButton") then
                    TweenService:Create(otherBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Text}):Play()
                    TweenService:Create(otherBtn.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5)}):Play()
                end
            end
            for _, otherPage in pairs(Container:GetChildren()) do
                if otherPage:IsA("ScrollingFrame") then otherPage.Visible = false end
            end

            -- 激活当前
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Accent}):Play()
            TweenService:Create(Line, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0.8, 0, 0, 2), Position = UDim2.new(0.1, 0, 1, -5)}):Play()
            
            -- 切入动画
            Page.Position = UDim2.new(0, 30, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end)

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.new(1,1,1)
            b.BackgroundTransparency = 0.4
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.TextColor3 = COLORS.Text
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(cb)
        end
        
        function TabAPI:AddToggle(text, cb)
            local t = Instance.new("TextButton", Page)
            t.Size = UDim2.new(1, -10, 0, 38)
            t.BackgroundColor3 = Color3.new(1,1,1)
            t.BackgroundTransparency = 0.4
            t.Text = "  " .. text
            t.TextXAlignment = "Left"
            t.TextColor3 = COLORS.Text
            Instance.new("UICorner", t)
            local box = Instance.new("Frame", t)
            box.Size = UDim2.new(0, 36, 0, 18)
            box.Position = UDim2.new(1, -45, 0.5, -9)
            box.BackgroundColor3 = COLORS.Bar
            Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(0, 2, 0.5, -7)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot)
            local s = false
            t.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(s and 0.55 or 0, 2, 0.5, -7)}):Play()
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = s and COLORS.Accent or COLORS.Bar}):Play()
                cb(s)
            end)
        end

        return TabAPI
    end

    return Library
end

return Library
