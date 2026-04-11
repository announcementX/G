local Library = {}
local TweenService = game:GetService("TweenService")

-- 颜色配置
local NeonPink = Color3.fromRGB(255, 182, 193) -- 淡粉色
local DarkBg = Color3.fromRGB(10, 10, 10)
local SecondaryBg = Color3.fromRGB(25, 25, 25)

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeonPinkPro_Fixed"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = DarkBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = NeonPink
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- --- 顶部栏 ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = NeonPink
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 按钮组
    local BtnGroup = Instance.new("Frame")
    BtnGroup.Size = UDim2.new(0, 60, 1, 0)
    BtnGroup.Position = UDim2.new(1, -65, 0, 0)
    BtnGroup.BackgroundTransparency = 1
    BtnGroup.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -25, 0.5, -12)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = NeonPink
    CloseBtn.TextSize = 24
    CloseBtn.Parent = BtnGroup

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -55, 0.5, -12)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = NeonPink
    MinBtn.TextSize = 24
    MinBtn.Parent = BtnGroup

    -- --- 侧边栏 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 130, 1, -35)
    SideBar.Position = UDim2.new(0, 0, 0, 35)
    SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = SideBar

    local TabList = Instance.new("UIListLayout")
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer

    -- --- 内容区 ---
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -145, 1, -45)
    ContentHolder.Position = UDim2.new(0, 135, 0, 40)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    local FirstTab = true

    -- 初始加载动画
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 550, 0, 350), 
        Position = UDim2.new(0.5, -275, 0.5, -175)
    }):Play()

    -- 关闭事件
    CloseBtn.MouseButton1Click:Connect(function()
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), 
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        t:Play()
        t.Completed:Wait()
        ScreenGui:Destroy()
    end)

    -- 缩小事件
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = minimized and UDim2.new(0, 550, 0, 35) or UDim2.new(0, 550, 0, 350)
        }):Play()
    end)

    -- --- 创建栏目方法 ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 115, 0, 32)
        TabBtn.BackgroundColor3 = SecondaryBg
        TabBtn.Text = name
        TabBtn.TextColor3 = NeonPink
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local TabStroke = Instance.new("UIStroke", TabBtn)
        TabStroke.Color = NeonPink
        TabStroke.Transparency = 0.9

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.ScrollBarThickness = 2
        Container.ScrollBarImageColor3 = NeonPink
        Container.CanvasSize = UDim2.new(0, 0, 0, 0) -- 初始 0
        Container.Parent = ContentHolder

        local UIList = Instance.new("UIListLayout")
        UIList.Padding = UDim.new(0, 8)
        UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIList.Parent = Container
        
        -- 核心修复：自动更新画布大小
        UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
        end)

        if FirstTab then
            Container.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 40)
            TabStroke.Transparency = 0.5
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.BackgroundColor3 = SecondaryBg 
                    v.UIStroke.Transparency = 0.9
                end 
            end
            Container.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 40)
            TabStroke.Transparency = 0.5
        end)

        local Elements = {}

        -- 1. 按钮
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = SecondaryBg
            b.Text = "  " .. text
            b.TextColor3 = Color3.fromRGB(255, 235, 240)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Parent = Container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", b).Color = NeonPink
            
            b.MouseButton1Click:Connect(callback)
        end

        -- 2. 开关 (Toggle)
        function Elements:CreateToggle(text, callback)
            local tFrame = Instance.new("Frame")
            tFrame.Size = UDim2.new(1, -10, 0, 38)
            tFrame.BackgroundColor3 = SecondaryBg
            tFrame.Parent = Container
            Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 6)

            local tLabel = Instance.new("TextLabel")
            tLabel.Size = UDim2.new(1, -60, 1, 0)
            tLabel.Position = UDim2.new(0, 12, 0, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.Text = text
            tLabel.TextColor3 = Color3.fromRGB(255, 235, 240)
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.Font = Enum.Font.Gotham
            tLabel.TextSize = 13
            tLabel.Parent = tFrame

            local tOuter = Instance.new("TextButton")
            tOuter.Size = UDim2.new(0, 38, 0, 20)
            tOuter.Position = UDim2.new(1, -50, 0.5, -10)
            tOuter.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            tOuter.Text = ""
            tOuter.Parent = tFrame
            Instance.new("UICorner", tOuter).CornerRadius = UDim.new(1, 0)

            local tInner = Instance.new("Frame")
            tInner.Size = UDim2.new(0, 16, 0, 16)
            tInner.Position = UDim2.new(0, 2, 0.5, -8)
            tInner.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            tInner.Parent = tOuter
            Instance.new("UICorner", tInner).CornerRadius = UDim.new(1, 0)

            local state = false
            tOuter.MouseButton1Click:Connect(function()
                state = not state
                local targetPos = state and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetCol = state and NeonPink or Color3.fromRGB(200, 200, 200)
                TweenService:Create(tInner, TweenInfo.new(0.25), {Position = targetPos, BackgroundColor3 = targetCol}):Play()
                callback(state)
            end)
        end

        -- 3. 输入框 (Input)
        function Elements:CreateInput(text, placeholder, callback)
            local iFrame = Instance.new("Frame")
            iFrame.Size = UDim2.new(1, -10, 0, 38)
            iFrame.BackgroundColor3 = SecondaryBg
            iFrame.Parent = Container
            Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 6)

            local iLabel = Instance.new("TextLabel")
            iLabel.Size = UDim2.new(0, 150, 1, 0)
            iLabel.Position = UDim2.new(0, 12, 0, 0)
            iLabel.BackgroundTransparency = 1
            iLabel.Text = text
            iLabel.TextColor3 = Color3.fromRGB(255, 235, 240)
            iLabel.TextXAlignment = Enum.TextXAlignment.Left
            iLabel.Font = Enum.Font.Gotham
            iLabel.TextSize = 13
            iLabel.Parent = iFrame

            local iBox = Instance.new("TextBox")
            iBox.Size = UDim2.new(0, 90, 0, 26)
            iBox.Position = UDim2.new(1, -100, 0.5, -13)
            iBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            iBox.Text = ""
            iBox.PlaceholderText = placeholder
            iBox.TextColor3 = NeonPink
            iBox.Font = Enum.Font.Gotham
            iBox.TextSize = 12
            iBox.Parent = iFrame
            Instance.new("UICorner", iBox)
            Instance.new("UIStroke", iBox).Color = NeonPink

            iBox.FocusLost:Connect(function()
                callback(iBox.Text)
            end)
        end

        return Elements
    end

    return Library
end

return Library
