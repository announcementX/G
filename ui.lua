local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 霓虹淡粉色
local NeonPink = Color3.fromRGB(255, 182, 193)
local DarkBg = Color3.fromRGB(10, 10, 10)

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeonPinkPro_Animated"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Enabled = false -- 初始隐藏，用于加载动画

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = DarkBg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true 
    MainFrame.ClipsDescendants = true -- 缩小动画需要
    MainFrame.Parent = ScreenGui

    -- 整体淡粉色霓虹边框
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = NeonPink
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
    CloseBtn.TextSize = 22
    CloseBtn.Parent = BtnGroup

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -50, 0.5, -12)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = NeonPink
    MinBtn.TextSize = 22
    MinBtn.Parent = BtnGroup

    -- --- 侧边栏 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 130, 1, -35)
    SideBar.Position = UDim2.new(0, 0, 0, 35)
    SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SideBar.BorderSizePixel = 0
    SideBar.ClipsDescendants = true -- 缩小动画需要
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
    ContentHolder.Size = UDim2.new(1, -140, 1, -45)
    ContentHolder.Position = UDim2.new(0, 135, 0, 40)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ClipsDescendants = true -- 缩小动画需要
    ContentHolder.Parent = MainFrame

    local Tabs = {}
    local FirstTab = true

    -- ==============================
    -- 核心动效函数
    -- ==============================

    -- 1. 加载动画 (从中间放大并淡入)
    local function PlayLoadAnimation()
        ScreenGui.Enabled = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- 居中起始
        MainFrame.BackgroundTransparency = 1
        
        -- 并行Tween
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        local sizeTween = TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 550, 0, 350),
            Position = UDim2.new(0.5, -275, 0.5, -175)
        })
        local transTween = TweenService:Create(MainFrame, tweenInfo, {
            BackgroundTransparency = 0
        })
        
        sizeTween:Play()
        transTween:Play()
    end

    -- 2. 关闭动画 (向中间缩小并淡出)
    local function PlayCloseAnimation()
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        local closeTween = TweenService:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
        
        closeTween:Play()
        closeTween.Completed:Wait() -- 等待动画完成
        ScreenGui:Destroy()
    end

    -- 3. 缩小/还原动画
    local isMinimized = false
    local originalSize = UDim2.new(0, 550, 0, 350)
    local minSize = UDim2.new(0, 550, 0, 35) -- 只保留TopBar
    
    local function ToggleMinimize()
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        isMinimized = not isMinimized
        
        local targetSize = isMinimized and minSize or originalSize
        local sizeTween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize})
        
        sizeTween:Play()
        
        -- 动画中隐藏侧边栏和内容，避免重叠
        if isMinimized then
            SideBar.Visible = false
            ContentHolder.Visible = false
        else
            -- 还原时，等稍微变大一点再显示内容，效果更自然
            task.delay(0.2, function()
                SideBar.Visible = true
                ContentHolder.Visible = true
            end)
        end
    end

    -- 绑定按钮事件
    CloseBtn.MouseButton1Click:Connect(PlayCloseAnimation)
    MinBtn.MouseButton1Click:Connect(ToggleMinimize)

    -- 执行加载动画
    task.spawn(PlayLoadAnimation)

    -- ==============================
    -- 原有创建栏目方法 (保持不变)
    -- ==============================
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Text = name
        TabBtn.TextColor3 = NeonPink
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.Parent = TabContainer

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.ScrollBarThickness = 3
        Container.ScrollBarImageColor3 = NeonPink
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
            b.TextColor3 = Color3.fromRGB(255, 220, 230)
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Parent = Container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local s = Instance.new("UIStroke", b)
            s.Color = NeonPink
            s.Transparency = 0.8

            b.MouseButton1Click:Connect(callback)
            Container.CanvasSize = UDim2.new(0,0,0, UIList.AbsoluteContentSize.Y)
        end
        return Elements
    end

    return Library
end

return Library
