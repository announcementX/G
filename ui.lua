-- [[ CyberPink UI Library - Official Source ]]
-- 建议在 GitHub 上命名为: Library.lua

local CyberPink = {
    _V = "2.0.0",
    _SelectedTab = nil,
    _WindowCreated = false
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 颜色配置
local Theme = {
    Main = Color3.fromRGB(10, 10, 10),      -- 极深黑
    Side = Color3.fromRGB(15, 15, 15),      -- 侧边栏黑
    Accent = Color3.fromRGB(255, 0, 127),   -- 顶级荧光粉
    Text = Color3.fromRGB(255, 255, 255),  -- 纯白文字
    DarkText = Color3.fromRGB(100, 100, 100) -- 暗灰文字
}

-- 核心方法：创建主窗口
function CyberPink:CreateWindow(Config)
    local WindowName = Config.Name or "CyberPink Premium"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CP_" .. math.random(1000, 9999)
    ScreenGui.Parent = CoreGui
    -- 尝试保护 GUI
    pcall(function() gethui().Parent = ScreenGui end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 500, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    -- 顶部发光条 (标志性的粉色呼吸灯效果)
    local GlowBar = Instance.new("Frame")
    GlowBar.Size = UDim2.new(1, 0, 0, 2)
    GlowBar.BackgroundColor3 = Theme.Accent
    GlowBar.BorderSizePixel = 0
    GlowBar.Parent = MainFrame
    
    -- 侧边栏
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = Theme.Side
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 5)

    -- 内容区域
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -150, 1, -10)
    ContentHolder.Position = UDim2.new(0, 145, 0, 5)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- 拖拽逻辑 (顶级库必备)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Window = {}

    -- 创建分页方法
    function Window:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = Name
        TabBtn.TextColor3 = Theme.DarkText
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.Parent = TabContainer
        
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Parent = ContentHolder
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Theme.DarkText; v.BackgroundTransparency = 1 end end
            
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundTransparency = 0.8
        end)

        -- 默认选中第一个
        if not CyberPink._SelectedTab then
            CyberPink._SelectedTab = true
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundTransparency = 0.8
        end

        local Elements = {}

        -- 开关功能 (Toggle)
        function Elements:CreateToggle(TConfig)
            local TName = TConfig.Name or "Toggle"
            local Callback = TConfig.Callback or function() end
            local State = false

            local TFrame = Instance.new("TextButton")
            TFrame.Size = UDim2.new(1, -10, 0, 35)
            TFrame.BackgroundColor3 = Theme.Side
            TFrame.Text = "  " .. TName
            TFrame.TextColor3 = Theme.Text
            TFrame.Font = Enum.Font.Gotham
            TFrame.TextSize = 14
            TFrame.TextXAlignment = Enum.TextXAlignment.Left
            TFrame.AutoButtonColor = false
            TFrame.Parent = Page
            
            local TIndicator = Instance.new("Frame")
            TIndicator.Size = UDim2.new(0, 20, 0, 20)
            TIndicator.Position = UDim2.new(1, -30, 0.5, -10)
            TIndicator.BackgroundColor3 = Theme.Main
            TIndicator.BorderSizePixel = 1
            TIndicator.BorderColor3 = Theme.DarkText
            TIndicator.Parent = TFrame

            TFrame.MouseButton1Click:Connect(function()
                State = not State
                TweenService:Create(TIndicator, TweenInfo.new(0.3), {
                    BackgroundColor3 = State and Theme.Accent or Theme.Main,
                    Rotation = State and 90 or 0
                }):Play()
                Callback(State)
            end)
        end

        -- 这里可以继续扩展 Slider, Button 等...
        return Elements
    end

    return Window
end

return CyberPink -- 关键！必须返回对象
