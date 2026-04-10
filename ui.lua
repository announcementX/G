local Library = {}

function Library:Init()
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkPremium_Module"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- 颜色主题
    local COLORS = {
        Main = Color3.fromRGB(255, 220, 230),      -- 淡粉色
        Bar = Color3.fromRGB(255, 190, 205),       -- 稍微深一丢丢 (上下45px)
        Sidebar = Color3.fromRGB(255, 245, 250),   -- 比淡粉浅一丢丢
        Accent = Color3.fromRGB(255, 160, 185),    -- 按钮/强调色
        Text = Color3.fromRGB(120, 80, 90)         -- 深粉色文字
    }

    -- 主界面
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
    MainFrame.BackgroundColor3 = COLORS.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- 顶部栏 (45px)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Bar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "PINK PREMIUM UI"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = TopBar

    -- 底部栏 (45px)
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Bar
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = MainFrame

    -- 缩小按钮
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -40, 0.5, -15)
    MinBtn.BackgroundColor3 = Color3.new(1, 1, 1)
    MinBtn.BackgroundTransparency = 0.8
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.Parent = TopBar
    Instance.new("UICorner", MinBtn)

    -- 侧边栏 (可滑动)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 110, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- 内容区 (可滑动)
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -125, 1, -110)
    Container.Position = UDim2.new(0, 120, 0, 55)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageColor3 = COLORS.Accent
    Container.Parent = MainFrame

    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Parent = Container
    ContainerLayout.Padding = UDim.new(0, 8)

    -- 自动调整滚动范围
    SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y)
    end)
    ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
    end)

    -- 拖动逻辑
    local function Drag(obj)
        local dragging, dragInput, dragStart, startPos
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = obj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    Drag(MainFrame)

    -- 缩小化逻辑
    local MiniIcon = Instance.new("TextButton")
    MiniIcon.Size = UDim2.new(0, 50, 0, 50)
    MiniIcon.Visible = false
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "❤"
    MiniIcon.TextSize = 25
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.Parent = ScreenGui
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 10)
    Drag(MiniIcon)

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MiniIcon.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 185, 0, MainFrame.AbsolutePosition.Y + 135)
        MiniIcon.Visible = true
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MiniIcon.Visible = false
    end)

    -- API 暴露
    local API = {}
    function API:AddTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 95, 0, 35)
        TabBtn.BackgroundColor3 = COLORS.Main
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn)
        return TabBtn
    end

    function API:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.new(1, 1, 1)
        Btn.Text = text
        Btn.TextColor3 = COLORS.Text
        Btn.Font = Enum.Font.GothamSemibold
        Btn.Parent = Container
        Instance.new("UICorner", Btn)
        Btn.MouseButton1Click:Connect(callback)
    end

    return API
end

return Library
