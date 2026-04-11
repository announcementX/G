-- [[ CyberPink UI Library - V5 Professional Edition ]]
-- 建议直接替换你 GitHub 仓库中的 ui.lua 内容

local CyberPink = {
    _Toggled = true,
    _CurrentTab = nil
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 顶级配色方案
local Theme = {
    Main = Color3.fromRGB(15, 15, 15),       -- 深黑背景
    Topbar = Color3.fromRGB(22, 22, 22),     -- 独立标题栏
    Side = Color3.fromRGB(20, 20, 20),       -- 侧边栏
    Accent = Color3.fromRGB(255, 209, 220),   -- 优雅淡粉 (Sakura Pink)
    Text = Color3.fromRGB(245, 245, 245),    -- 主文字
    TextDark = Color3.fromRGB(140, 140, 140),-- 隐藏/非选中文字
    Element = Color3.fromRGB(30, 30, 30),     -- 组件背景
    Stroke = Color3.fromRGB(255, 192, 203)    -- 边框色
}

function CyberPink:CreateWindow(Config)
    local WindowName = Config.Name or "CyberPink Library"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CP_V5_" .. math.random(100, 999)
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gethui().Parent = ScreenGui end)

    -- 主容器
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 350)
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Theme.Stroke
    Stroke.Thickness = 1
    Stroke.Transparency = 0.8

    -- 【独立标题栏】
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local TopCorner = Instance.new("UICorner", Topbar)
    TopCorner.CornerRadius = UDim.new(0, 12)

    -- 补齐圆角缺口
    local TopbarFill = Instance.new("Frame")
    TopbarFill.Size = UDim2.new(1, 0, 0, 10)
    TopbarFill.Position = UDim2.new(0, 0, 1, -10)
    TopbarFill.BackgroundColor3 = Theme.Topbar
    TopbarFill.BorderSizePixel = 0
    TopbarFill.Parent = Topbar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "  " .. WindowName
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 【控制按钮：关闭与最小化】
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 80, 1, 0)
    Controls.Position = UDim2.new(1, -85, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Topbar

    local function CreateBtn(symbol, color, xOffset, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(0, xOffset, 0.5, -13)
        b.BackgroundColor3 = Theme.Element
        b.Text = symbol
        b.TextColor3 = color
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.AutoButtonColor = true
        b.Parent = Controls
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(callback)
    end

    CreateBtn("×", Color3.fromRGB(255, 100, 100), 50, function() ScreenGui:Destroy() end)
    CreateBtn("-", Theme.Accent, 15, function()
        CyberPink._Toggled = not CyberPink._Toggled
        local targetSize = CyberPink._Toggled and UDim2.new(0, 550, 0, 350) or UDim2.new(0, 550, 0, 40)
        Main:TweenSize(targetSize, "Out", "Quart", 0.4, true)
    end)

    -- 【修复后的拖拽功能】
    local dragToggle, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)

    -- 【内容分区】
    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 160, 1, -40)
    Side.Position = UDim2.new(0, 0, 0, 40)
    Side.BackgroundColor3 = Theme.Side
    Side.BorderSizePixel = 0
    Side.Parent = Main

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -10)
    TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Side
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -160, 1, -40)
    Content.Position = UDim2.new(0, 160, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

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
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.85, TextColor3 = Theme.Accent}):Play()
        end)

        if not CyberPink._CurrentTab then
            CyberPink._CurrentTab = true
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.85
            TabBtn.TextColor3 = Theme.Accent
        end

        local Elements = {}
        function Elements:CreateToggle(TConfig)
            local TFrame = Instance.new("TextButton")
            TFrame.Size = UDim2.new(1, 0, 0, 42)
            TFrame.BackgroundColor3 = Theme.Element
            TFrame.AutoButtonColor = false
            TFrame.Text = ""
            TFrame.Parent = Page
            Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 8)

            local TTitle = Instance.new("TextLabel")
            TTitle.Text = "  " .. TConfig.Name
            TTitle.Size = UDim2.new(1, -50, 1, 0)
            TTitle.TextColor3 = Theme.Text
            TTitle.BackgroundTransparency = 1
            TTitle.TextXAlignment = Enum.TextXAlignment.Left
            TTitle.Font = Enum.Font.Gotham
            TTitle.Parent = TFrame

            local Tgl = Instance.new("Frame")
            Tgl.Size = UDim2.new(0, 38, 0, 20)
            Tgl.Position = UDim2.new(1, -48, 0.5, -10)
            Tgl.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Tgl.Parent = TFrame
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)

            local Ball = Instance.new("Frame")
            Ball.Size = UDim2.new(0, 16, 0, 16)
            Ball.Position = UDim2.new(0, 2, 0.5, -8)
            Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Ball.Parent = Tgl
            Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

            local active = false
            TFrame.MouseButton1Click:Connect(function()
                active = not active
                TweenService:Create(Ball, TweenInfo.new(0.25), {Position = active and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                TweenService:Create(Tgl, TweenInfo.new(0.25), {BackgroundColor3 = active and Theme.Accent or Color3.fromRGB(45, 45, 45)}):Play()
                TConfig.Callback(active)
            end)
        end
        return Elements
    end
    return Window
end

return CyberPink
