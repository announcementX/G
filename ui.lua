local Library = {Tabs = {}}

function Library:Init(HubName)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    
    -- 基础配置
    local COLORS = {
        Main = Color3.fromRGB(255, 230, 240),      -- 主粉色
        Bar = Color3.fromRGB(255, 185, 205),       -- 深粉色 (上下45px)
        Sidebar = Color3.fromRGB(255, 245, 250),   -- 极浅粉 (侧边栏)
        Accent = Color3.fromRGB(255, 120, 180),    -- 强调/文字色
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ElitePinkUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = COLORS.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- --- 渐变系统 (实现你要求的上下、左右过渡) ---
    
    -- 顶部栏渐变
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Bar
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 5
    TopBar.Parent = MainFrame
    local TGrad = Instance.new("UIGradient", TopBar)
    TGrad.Rotation = 90
    TGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1) -- 向下渐变为透明
    })

    -- 底部栏渐变
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Bar
    BottomBar.BorderSizePixel = 0
    BottomBar.ZIndex = 5
    BottomBar.Parent = MainFrame
    local BGrad = Instance.new("UIGradient", BottomBar)
    BGrad.Rotation = -90
    BGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1) -- 向上渐变为透明
    })

    -- 侧边栏渐变
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 130, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.ZIndex = 4
    Sidebar.Parent = MainFrame
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 1) -- 向右渐变为透明
    })

    -- --- 按钮区 (缩小/关闭) ---
    local Title = Instance.new("TextLabel")
    Title.Text = HubName or "PINK HUB"
    Title.Size = UDim2.new(0, 200, 0, 45)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = COLORS.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.ZIndex = 6
    Title.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.ZIndex = 6
    CloseBtn.Parent = MainFrame
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -75, 0, 8)
    MinBtn.BackgroundColor3 = COLORS.Bar
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.ZIndex = 6
    MinBtn.Parent = MainFrame
    Instance.new("UICorner", MinBtn)

    -- 内容容器
    local ContainerHolder = Instance.new("Frame")
    ContainerHolder.Size = UDim2.new(1, -145, 1, -100)
    ContainerHolder.Position = UDim2.new(0, 140, 0, 50)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.ZIndex = 2
    ContainerHolder.Parent = MainFrame

    -- --- 功能逻辑 ---
    
    -- 拖动 (点击顶部栏区域)
    local function MakeDraggable(frame, handle)
        local dragging, dragStart, startPos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true dragStart = input.Position startPos = frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input) dragging = false end)
    end
    MakeDraggable(MainFrame, TopBar)

    -- 缩小化逻辑
    local MiniIcon = Instance.new("TextButton")
    MiniIcon.Size = UDim2.new(0, 50, 0, 50)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Visible = false
    MiniIcon.Text = "❤"
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.TextSize = 25
    MiniIcon.Parent = ScreenGui
    Instance.new("UICorner", MiniIcon)
    MakeDraggable(MiniIcon, MiniIcon)

    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MiniIcon.Visible = true
        MiniIcon.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 225, 0, MainFrame.AbsolutePosition.Y + 150)
    end)
    MiniIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true MiniIcon.Visible = false end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- --- API ---
    local UIList = Instance.new("UIListLayout", Sidebar)
    UIList.Padding = UDim.new(0, 5)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 110, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Accent
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.ZIndex = 10
        
        local Page = Instance.new("ScrollingFrame", ContainerHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ZIndex = 10
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContainerHolder:GetChildren()) do v.Visible = false end
            Page.Visible = true
        end)

        local TabAPI = {}
        function TabAPI:AddButton(text, callback)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.3
            b.Text = "  " .. text
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextColor3 = COLORS.Accent
            b.Font = Enum.Font.GothamSemibold
            b.ZIndex = 11
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
        end
        
        if #Sidebar:GetChildren() == 2 then Page.Visible = true end -- 默认显示第一页
        return TabAPI
    end

    return Library
end

return Library
