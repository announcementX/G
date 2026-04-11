-- [[ CyberPink UI Library - V4 Final Refined ]]
-- 配色：极简灰黑背景 + 顶级淡粉 (Sakura Pink)

local CyberPink = {
    _V = "4.0.0",
    _Toggled = true
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(12, 12, 12),       -- 主背景
    Topbar = Color3.fromRGB(20, 20, 20),     -- 顶部标题栏背景
    Side = Color3.fromRGB(18, 18, 18),       -- 侧边栏
    Accent = Color3.fromRGB(255, 192, 203),   -- 优雅淡粉色
    Text = Color3.fromRGB(255, 255, 255),    -- 纯白
    TextDark = Color3.fromRGB(150, 150, 150),-- 灰色
    Element = Color3.fromRGB(28, 28, 28)     -- 控件背景
}

function CyberPink:CreateWindow(Config)
    local WindowName = Config.Name or "CyberPink Premium"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CP_V4_" .. math.random(1000, 9999)
    ScreenGui.Parent = CoreGui
    pcall(function() gethui().Parent = ScreenGui end)

    -- 主窗口
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 1
    Stroke.Transparency = 0.7
    Stroke.Parent = MainFrame

    -- 【独立标题栏】
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 35)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)

    -- 补齐下方圆角，让标题栏底部平整
    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.BackgroundColor3 = Theme.Topbar
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. WindowName
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 【控制按钮组】
    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 80, 1, 0)
    Btns.Position = UDim2.new(1, -85, 0, 0)
    Btns.BackgroundTransparency = 1
    Btns.Parent = Topbar

    local function CreateControlBtn(txt, color, xPos, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 24, 0, 24)
        b.Position = UDim2.new(0, xPos, 0.5, -12)
        b.BackgroundColor3 = Theme.Element
        b.Text = txt
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.Parent = Btns
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(callback)
    end

    CreateControlBtn("×", Color3.fromRGB(255, 100, 100), 50, function() ScreenGui:Destroy() end)
    CreateControlBtn("-", Theme.Accent, 20, function()
        CyberPink._Toggled = not CyberPink._Toggled
        MainFrame:TweenSize(CyberPink._Toggled and UDim2.new(0, 550, 0, 350) or UDim2.new(0, 550, 0, 35), "Out", "Quart", 0.3, true)
    end)

    -- 【拖拽逻辑核心】
    local dragToggle, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)

    -- 【侧边栏与内容区】
    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 150, 1, -35)
    Side.Position = UDim2.new(0, 0, 0, 35)
    Side.BackgroundColor3 = Theme.Side
    Side.BorderSizePixel = 0
    Side.Parent = MainFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -10)
    TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Side
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -150, 1, -35)
    Content.Position = UDim2.new(0, 150, 0, 35)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local Window = {}

    function Window:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Text = "  " .. Name
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Parent = Content
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then 
                TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}):Play()
            end end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = Theme.Accent}):Play()
        end)

        if not CyberPink._CurrentTab then
            CyberPink._CurrentTab = true
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.TextColor3 = Theme.Accent
        end

        local Elements = {}
        function Elements:CreateToggle(TConfig)
            local TFrame = Instance.new("TextButton")
            TFrame.Size = UDim2.new(1, 0, 0, 40)
            TFrame.BackgroundColor3 = Theme.Element
            TFrame.AutoButtonColor = false
            TFrame.Text = ""
            TFrame.Parent = Page
            Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 8)

            local TTitle = Instance.new("TextLabel")
            TTitle.Text = "  " .. TConfig.Name
            TTitle.Size = UDim2.new(1, 0, 1, 0)
            TTitle.TextColor3 = Theme.Text
            TTitle.BackgroundTransparency = 1
            TTitle.TextXAlignment = Enum.TextXAlignment.Left
            TTitle.Font = Enum.Font.Gotham
            TTitle.Parent = TFrame

            local Tgl = Instance.new("Frame")
            Tgl.Size = UDim2.new(0, 36, 0, 18)
            Tgl.Position = UDim2.new(1, -45, 0.5, -9)
            Tgl.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Tgl.Parent = TFrame
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)

            local Ball = Instance.new("Frame")
            Ball.Size = UDim2.new(0, 14, 0, 14)
            Ball.Position = UDim2.new(0, 2, 0.5, -7)
            Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Ball.Parent = Tgl
            Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

            local active = false
            TFrame.MouseButton1Click:Connect(function()
                active = not active
                TweenService:Create(Ball, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                TweenService:Create(Tgl, TweenInfo.new(0.2), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(45, 45, 45)}):Play()
                TConfig.Callback(active)
            end)
        end
        return Elements
    end
    return Window
end

return CyberPink
