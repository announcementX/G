local Library = {Tabs = {}; CurrentTab = nil}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    -- 彻底全屏的容器
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_FINAL_V6"
    ScreenGui.IgnoreGuiInset = true -- 覆盖全屏，包括顶部状态栏
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        Main = Color3.fromRGB(20, 20, 25),      -- 灵魂深邃黑
        LightPink = Color3.fromRGB(255, 200, 220), -- 灵魂粉
        Accent = Color3.fromRGB(255, 80, 150),
        Sidebar = Color3.fromRGB(30, 30, 35)
    }

    -- --- 1. 震撼：全屏灵魂粒子汇聚加载 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.Main
    Loader.ZIndex = 9999

    local Logo = Instance.new("TextLabel", Loader)
    Logo.Text = "S O U L"
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 80
    Logo.TextColor3 = COLORS.LightPink
    Logo.Size = UDim2.new(1, 0, 1, 0)
    Logo.BackgroundTransparency = 1
    Logo.ZIndex = 10000

    -- 灵魂粒子聚拢动效
    task.spawn(function()
        for i = 1, 30 do
            local p = Instance.new("Frame", Loader)
            p.Size = UDim2.new(0, math.random(2,5), 0, math.random(2,5))
            p.BackgroundColor3 = COLORS.Accent
            p.Position = UDim2.new(math.random(), 0, math.random(), 0)
            Instance.new("UICorner", p)
            TweenService:Create(p, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            }):Play()
        end
        task.wait(1.5)
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Logo, TweenInfo.new(1), {TextTransparency = 1, TextSize = 200}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主界面 ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 380)
    Main.Position = UDim2.new(0.5, -280, 0.5, -190)
    Main.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- 顶部栏
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = COLORS.LightPink
    TopBar.ZIndex = 5
    local TGrad = Instance.new("UIGradient", TopBar)
    TGrad.Rotation = 90
    TGrad.Transparency = NumberSequence.new(0, 1)

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.ScrollBarThickness = 0
    Sidebar.ZIndex = 4
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -150, 1, -60)
    Container.Position = UDim2.new(0, 150, 0, 60)
    Container.BackgroundTransparency = 1

    -- --- 3. 按钮修复：物理强制执行 ---
    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.ZIndex = 10
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -75, 0, 10)
    MinBtn.BackgroundColor3 = COLORS.Accent
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.ZIndex = 10
    Instance.new("UICorner", MinBtn)

    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 55, 0, 55)
    MiniIcon.Position = UDim2.new(0.5, -27, 0.9, 0)
    MiniIcon.BackgroundColor3 = COLORS.LightPink
    MiniIcon.Text = "S"
    MiniIcon.Font = "GothamBold"
    MiniIcon.TextColor3 = COLORS.Main
    MiniIcon.Visible = false
    MiniIcon.ZIndex = 20
    Instance.new("UICorner", MiniIcon)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenPosition(UDim2.new(0.5, -280, 1.1, 0), "In", "Back", 0.5)
        task.wait(0.5)
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon:TweenPosition(UDim2.new(0.5, -27, 0.85, 0), "Out", "Back", 0.5)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MiniIcon:TweenPosition(UDim2.new(0.5, -27, 1.1, 0), "In", "Quad", 0.3)
        task.wait(0.3)
        Main.Visible = true
        Main:TweenPosition(UDim2.new(0.5, -280, 0.5, -190), "Out", "Back", 0.5)
        MiniIcon.Visible = false
    end)

    -- --- 4. 栏目切换逻辑 (物理隔离版) ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        TabBtn.Font = "Gotham"
        TabBtn.ZIndex = 5

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 10)
        Layout.HorizontalAlignment = "Center"

        TabBtn.MouseButton1Click:Connect(function()
            -- 1. 彻底关闭所有 Tab 状态
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Color3.new(0.8, 0.8, 0.8)}):Play()
                end
            end
            for _, v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end

            -- 2. 激活当前
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Accent}):Play()
            
            -- 3. 切入动画
            Page.Position = UDim2.new(0, 40, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end)

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(0.9, 0, 0, 40)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.6
            b.Text = text
            b.TextColor3 = COLORS.Main
            b.Font = "GothamBold"
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(cb)
        end
        
        -- 默认开启第一个
        if #Sidebar:GetChildren() == 1 then
            Page.Visible = true
            TabBtn.TextColor3 = COLORS.Accent
        end

        return TabAPI
    end

    -- 拖拽
    local dragStart, startPos, dragging
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = i.Position startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    return Library
end

return Library
