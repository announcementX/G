local Library = {}

function Library:Init()
    local UserInputService = game:GetService("UserInputService")
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkGradientLib"
    ScreenGui.Parent = game:GetService("CoreGui")

    local COLORS = {
        Main = Color3.fromRGB(255, 225, 235),      -- 淡粉
        Darker = Color3.fromRGB(255, 185, 205),    -- 稍深粉
        Lighter = Color3.fromRGB(255, 242, 245),   -- 极浅粉 (侧边栏)
        Text = Color3.fromRGB(110, 80, 90)
    }

    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.BackgroundColor3 = COLORS.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- 顶部 45px (带向下渐变)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Darker
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    local TGrad = Instance.new("UIGradient", TopBar)
    TGrad.Rotation = 90
    TGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Darker),
        ColorSequenceKeypoint.new(1, COLORS.Main)
    })

    -- 底部 45px (带向上渐变)
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Darker
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = MainFrame
    local BGrad = Instance.new("UIGradient", BottomBar)
    BGrad.Rotation = -90
    BGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Darker),
        ColorSequenceKeypoint.new(1, COLORS.Main)
    })

    -- 侧边栏 (带向右渐变)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 120, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Lighter
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Lighter),
        ColorSequenceKeypoint.new(1, COLORS.Main)
    })

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 2)

    -- 内容区
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -130, 1, -100)
    Container.Position = UDim2.new(0, 125, 0, 50)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.Parent = MainFrame

    local ContainerLayout = Instance.new("UIListLayout", Container)
    ContainerLayout.Padding = UDim.new(0, 8)

    -- 缩小/拖动逻辑 (保持不变)
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
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end
    Drag(MainFrame)

    -- API
    local API = {}
    function API:AddTab(name)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundTransparency = 1
        btn.Text = name
        btn.TextColor3 = COLORS.Text
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        return btn
    end

    function API:AddButton(text, callback)
        local btn = Instance.new("TextButton", Container)
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.BackgroundColor3 = Color3.new(1,1,1)
        btn.BackgroundTransparency = 0.4
        btn.Text = "  " .. text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextColor3 = COLORS.Text
        btn.Parent = Container
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
    end

    return API
end

return Library
