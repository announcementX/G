local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 颜色配置
local SoftPink = Color3.fromRGB(255, 182, 193) -- 纯净淡粉
local DarkBg = Color3.fromRGB(15, 15, 15)      -- 深黑底色
local ItemBg = Color3.fromRGB(25, 25, 25)      -- 组件底色

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobilePinkLib"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 280) -- 手机端稍微缩小一点尺寸更合适
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
    MainFrame.BackgroundColor3 = DarkBg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- --- 手机端丝滑拖拽脚本 ---
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- --- 顶部栏 ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = SoftPink
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 右上角按钮组（全部变粉！）
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = SoftPink -- 变粉啦！
    CloseBtn.TextSize = 28
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -65, 0.5, -15)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = SoftPink -- 变粉啦！
    MinBtn.TextSize = 28
    MinBtn.Font = Enum.Font.Gotham
    MinBtn.Parent = TopBar

    -- --- 侧边栏 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 110, 1, -40)
    SideBar.Position = UDim2.new(0, 0, 0, 40)
    SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
    ContentHolder.Size = UDim2.new(1, -125, 1, -50)
    ContentHolder.Position = UDim2.new(0, 120, 0, 45)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    local FirstTab = true

    -- 按钮事件
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    local min = false
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = min and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 280)
        }):Play()
    end)

    -- --- 创建栏目方法 ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 100, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 12
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.ScrollBarThickness = 2
        Container.ScrollBarImageColor3 = SoftPink
        Container.Parent = ContentHolder

        local UIList = Instance.new("UIListLayout")
        UIList.Padding = UDim.new(0, 8)
        UIList.Parent = Container

        UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 5)
        end)

        if FirstTab then
            Container.Visible = true
            TabBtn.TextColor3 = SoftPink
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.TextColor3 = Color3.fromRGB(150, 150, 150)
                    v.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                end 
            end
            Container.Visible = true
            TabBtn.TextColor3 = SoftPink
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        local Elements = {}

        -- 1. 按钮
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = ItemBg
            b.Text = "  " .. text
            b.TextColor3 = SoftPink
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Parent = Container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(callback)
        end

        -- 2. 开关
        function Elements:CreateToggle(text, callback)
            local tFrame = Instance.new("Frame")
            tFrame.Size = UDim2.new(1, -10, 0, 38)
            tFrame.BackgroundColor3 = ItemBg
            tFrame.Parent = Container
            Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 6)

            local tLabel = Instance.new("TextLabel")
            tLabel.Size = UDim2.new(1, 0, 1, 0)
            tLabel.Position = UDim2.new(0, 12, 0, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.Text = text
            tLabel.TextColor3 = SoftPink
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.Font = Enum.Font.Gotham
            tLabel.TextSize = 13
            tLabel.Parent = tFrame

            local tOuter = Instance.new("TextButton")
            tOuter.Size = UDim2.new(0, 34, 0, 18)
            tOuter.Position = UDim2.new(1, -45, 0.5, -9)
            tOuter.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tOuter.Text = ""
            tOuter.Parent = tFrame
            Instance.new("UICorner", tOuter).CornerRadius = UDim.new(1, 0)

            local tInner = Instance.new("Frame")
            tInner.Size = UDim2.new(0, 14, 0, 14)
            tInner.Position = UDim2.new(0, 2, 0.5, -7)
            tInner.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            tInner.Parent = tOuter
            Instance.new("UICorner", tInner).CornerRadius = UDim.new(1, 0)

            local state = false
            tOuter.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(tInner, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    BackgroundColor3 = state and SoftPink or Color3.fromRGB(180, 180, 180)
                }):Play()
                callback(state)
            end)
        end

        -- 3. 输入框
        function Elements:CreateInput(text, placeholder, callback)
            local iFrame = Instance.new("Frame")
            iFrame.Size = UDim2.new(1, -10, 0, 38)
            iFrame.BackgroundColor3 = ItemBg
            iFrame.Parent = Container
            Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 6)

            local iLabel = Instance.new("TextLabel")
            iLabel.Size = UDim2.new(0, 120, 1, 0)
            iLabel.Position = UDim2.new(0, 12, 0, 0)
            iLabel.BackgroundTransparency = 1
            iLabel.Text = text
            iLabel.TextColor3 = SoftPink
            iLabel.TextXAlignment = Enum.TextXAlignment.Left
            iLabel.Font = Enum.Font.Gotham
            iLabel.TextSize = 13
            iLabel.Parent = iFrame

            local iBox = Instance.new("TextBox")
            iBox.Size = UDim2.new(0, 80, 0, 24)
            iBox.Position = UDim2.new(1, -90, 0.5, -12)
            iBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            iBox.Text = ""
            iBox.PlaceholderText = placeholder
            iBox.TextColor3 = SoftPink
            iBox.Font = Enum.Font.Gotham
            iBox.TextSize = 11
            iBox.Parent = iFrame
            Instance.new("UICorner", iBox).CornerRadius = UDim.new(0, 4)

            iBox.FocusLost:Connect(function() callback(iBox.Text) end)
        end

        return Elements
    end

    return Library
end

return Library
