local Library = {}
local TweenService = game:GetService("TweenService")

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeonPinkPro"
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.Parent = ScreenGui

    -- 整体淡粉色霓虹边框
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 182, 193)
    MainStroke.Thickness = 1.2
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
    TitleLabel.TextColor3 = Color3.fromRGB(255, 182, 193) -- 淡粉文字
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 按钮组（靠近放置）
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
    CloseBtn.TextColor3 = Color3.fromRGB(255, 182, 193)
    CloseBtn.TextSize = 22
    CloseBtn.Parent = BtnGroup

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -50, 0.5, -12)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255, 182, 193)
    MinBtn.TextSize = 22
    MinBtn.Parent = BtnGroup

    -- --- 侧边栏 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 130, 1, -35)
    SideBar.Position = UDim2.new(0, 0, 0, 35)
    SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame

    local SideStroke = Instance.new("UIStroke")
    SideStroke.Color = Color3.fromRGB(255, 182, 193)
    SideStroke.Transparency = 0.8
    SideStroke.Parent = SideBar

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
    ContentHolder.Size = UDim2.new(1, -140, 1, -45)
    ContentHolder.Position = UDim2.new(0, 135, 0, 40)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    local Tabs = {}
    local FirstTab = true

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(255, 182, 193)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.Parent = TabContainer

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabBtn

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.ScrollBarThickness = 3
        Container.ScrollBarImageColor3 = Color3.fromRGB(255, 182, 193)
        Container.Parent = ContentHolder

        local UIList = Instance.new("UIListLayout")
        UIList.Padding = UDim.new(0, 8)
        UIList.Parent = Container

        if FirstTab then
            Container.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end 
            end
            Container.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 35)
        end)

        local Elements = {}
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 35)
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            b.Text = text
            b.TextColor3 = Color3.fromRGB(255, 220, 230) -- 极淡粉
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Parent = Container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local s = Instance.new("UIStroke", b)
            s.Color = Color3.fromRGB(255, 182, 193)
            s.Transparency = 0.8

            b.MouseButton1Click:Connect(callback)
            Container.CanvasSize = UDim2.new(0,0,0, UIList.AbsoluteContentSize.Y)
        end
        return Elements
    end

    -- 最小化/关闭逻辑
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    local min = false
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        MainFrame:TweenSize(min and UDim2.new(0, 550, 0, 35) or UDim2.new(0, 550, 0, 350), "Out", "Quart", 0.3, true)
        SideBar.Visible = not min
        ContentHolder.Visible = not min
    end)

    return Library
end

return Library
