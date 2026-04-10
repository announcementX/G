local Library = {Tabs = {}}

function Library:Init(HubName)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkRayfield_Elite"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local COLORS = {
        Main = Color3.fromRGB(255, 230, 240),      -- 主淡粉
        Bar = Color3.fromRGB(255, 195, 215),       -- 上下Bar深粉
        Sidebar = Color3.fromRGB(255, 245, 250),   -- 侧边浅粉
        Accent = Color3.fromRGB(255, 150, 190),    -- 强调色
        Text = Color3.fromRGB(100, 70, 80)         -- 文字色
    }

    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    MainFrame.BackgroundColor3 = COLORS.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- 顶部栏 (45px) + 渐变
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Bar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    local TGrad = Instance.new("UIGradient", TopBar)
    TGrad.Rotation = 90
    TGrad.Color = ColorSequence.new(COLORS.Bar, COLORS.Main)

    local Title = Instance.new("TextLabel")
    Title.Text = HubName or "PINK ELITE HUB"
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- 右上角按钮组 (关闭与缩小)
    local BtnHolder = Instance.new("Frame")
    BtnHolder.Size = UDim2.new(0, 80, 1, 0)
    BtnHolder.Position = UDim2.new(1, -85, 0, 0)
    BtnHolder.BackgroundTransparency = 1
    BtnHolder.Parent = TopBar

    local function CreateTopBtn(text, pos, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(0, pos, 0.5, -14)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.Parent = BtnHolder
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end

    local CloseBtn = CreateTopBtn("×", 45, Color3.fromRGB(255, 120, 120))
    local MinBtn = CreateTopBtn("-", 10, COLORS.Accent)

    -- 底部栏 (45px) + 渐变
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Bar
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = MainFrame
    local BGrad = Instance.new("UIGradient", BottomBar)
    BGrad.Rotation = -90
    BGrad.Color = ColorSequence.new(COLORS.Bar, COLORS.Main)

    -- 侧边栏 (带有向右的平滑色彩渐变)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 130, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Sidebar),
        ColorSequenceKeypoint.new(1, COLORS.Main)
    })
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    -- 内容容器
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -140, 1, -100)
    ContentHolder.Position = UDim2.new(0, 135, 0, 50)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- 交互逻辑：拖动、关闭、缩小
    local function Drag(obj)
        local dragging, dragStart, startPos
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true dragStart = input.Position startPos = obj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    end
    Drag(TopBar) -- 拖动顶部栏即可移动

    local MiniIcon = Instance.new("TextButton")
    MiniIcon.Size = UDim2.new(0, 55, 0, 55)
    MiniIcon.Visible = false
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "❤"
    MiniIcon.TextSize = 25
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.Parent = ScreenGui
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 12)
    Drag(MiniIcon)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false MiniIcon.Visible = true MiniIcon.Position = UDim2.new(0, MainFrame.AbsolutePosition.X+230, 0, MainFrame.AbsolutePosition.Y+150) end)
    MiniIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true MiniIcon.Visible = false end)

    -- API 功能块
    function Library:CreateTab(name)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = COLORS.Accent
        TabPage.Parent = ContentHolder
        Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 13

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            TabPage.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Accent}):Play()
        end)

        local TabAPI = {}
        function TabAPI:AddButton(text, callback)
            local b = Instance.new("TextButton", TabPage)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.5
            b.Text = "  " .. text
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.GothamSemibold
            b.TextColor3 = COLORS.Text
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
        end
        
        -- 默认显示第一个 Tab
        if #Sidebar:GetChildren() == 2 then TabPage.Visible = true end 

        return TabAPI
    end

    return Library
end

return Library
