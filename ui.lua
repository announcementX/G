local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeonSoftPinkLib"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- 深黑
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- 建议后期改用更丝滑的拖拽函数
    MainFrame.Parent = ScreenGui

    -- 淡粉色霓虹边框
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 182, 193) -- 淡粉色 (Light Pink)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame

    -- 顶部标题栏
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 182, 193) -- 淡粉文字
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.Parent = TopBar

    -- 右上角控制按钮组
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 70, 1, 0)
    Controls.Position = UDim2.new(1, -75, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

    -- 关闭键 (X)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(0.5, 5, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 24
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Parent = Controls

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- 最小化键 (-)
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(0, -5, 0.5, -15)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 24
    MinimizeBtn.Font = Enum.Font.Gotham
    MinimizeBtn.Parent = Controls

    local Minimized = false
    local Container = Instance.new("ScrollingFrame") -- 内容区域

    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Container.Visible = false
            MainFrame:TweenSize(UDim2.new(0, 480, 0, 35), "Out", "Quart", 0.3, true)
        else
            MainFrame:TweenSize(UDim2.new(0, 480, 0, 320), "Out", "Quart", 0.3, true, function()
                Container.Visible = true
            end)
        end
    end)

    -- 内容容器
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Color3.fromRGB(255, 182, 193)
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = Container

    local Elements = {}

    -- 创建按钮方法
    function Elements:CreateButton(name, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 440, 0, 40)
        Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(240, 240, 240)
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 14
        Button.AutoButtonColor = false
        Button.Parent = Container

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = Button

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(255, 182, 193)
        BtnStroke.Transparency = 0.8
        BtnStroke.Parent = Button

        Button.MouseButton1Click:Connect(function()
            callback()
            -- 点击微动效果
            local ts = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            ts:Play()
            ts.Completed:Wait()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
        end)
        
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end

    return Elements
end

return Library
