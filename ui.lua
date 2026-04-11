local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local SOUL_LIB = {}

function SOUL_LIB:CreateWindow(Config)
    local Window = {
        Size = Config.Size or UDim2.new(0, 500, 0, 300),
        MinimizedStyle = Config.MinimizedStyle or "RoundedSquare",
        Title = Config.Name or "SOUL | UI",
        Tabs = {}
    }

    -- 主容器
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SOUL_V2"
    MainGui.ResetOnSpawn = false
    -- 确保在移动端显示在最上层
    pcall(function() MainGui.Parent = CoreGui end)
    if not MainGui.Parent then MainGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = Window.Size
    MainFrame.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- 顶部渐变标题栏 (粉黑渐变)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.new(1, 1, 1)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(15, 15, 15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
    })
    TopGradient.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. Window.Title
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- 缩小键和关闭键
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "×"
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 25
    CloseBtn.Parent = TopBar

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Text = "−"
    MiniBtn.Size = UDim2.new(0, 35, 0, 35)
    MiniBtn.Position = UDim2.new(1, -75, 0, 5)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.TextColor3 = Color3.new(1, 1, 1)
    MiniBtn.TextSize = 25
    MiniBtn.Parent = TopBar

    -- 拖动逻辑
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- 左侧侧边栏 (可滑动)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 130, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.Parent = Sidebar

    -- 右侧页面容器
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -135, 1, -50)
    PageContainer.Position = UDim2.new(0, 135, 0, 50)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- 缩小化后的悬浮窗
    local MinimizedFrame = Instance.new("TextButton")
    MinimizedFrame.Size = UDim2.new(0, 50, 0, 50)
    MinimizedFrame.Visible = false
    MinimizedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MinimizedFrame.Text = "SOUL"
    MinimizedFrame.TextColor3 = Color3.fromRGB(255, 105, 180)
    MinimizedFrame.Font = Enum.Font.GothamBold
    MinimizedFrame.Parent = MainGui

    local MinCorner = Instance.new("UICorner")
    MinCorner.Parent = MinimizedFrame

    -- 处理缩小样式
    local function ApplyMinStyle(style)
        if style == "Circle" then MinCorner.CornerRadius = UDim.new(1, 0)
        elseif style == "RoundedSquare" then MinCorner.CornerRadius = UDim.new(0, 12)
        elseif style == "Square" then MinCorner.CornerRadius = UDim.new(0, 0) end
    end
    ApplyMinStyle(Window.MinimizedStyle)

    -- 动画逻辑
    MiniBtn.MouseButton1Click:Connect(function()
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        t:Play()
        t.Completed:Wait()
        MainFrame.Visible = false
        MinimizedFrame.Position = MainFrame.Position
        MinimizedFrame.Visible = true
    end)

    MinimizedFrame.MouseButton1Click:Connect(function()
        MinimizedFrame.Visible = false
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Window.Size}):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)

    -- Tab 功能
    function Window:AddTab(Name)
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = #Window.Tabs == 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundColor3 = Page.Visible and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(30, 30, 30)
        TabBtn.Text = Name
        TabBtn.TextColor3 = Color3.new(1, 1, 1)
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end 
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
        end)

        table.insert(Window.Tabs, Page)

        local Elements = {}

        -- 按钮组件
        function Elements:AddButton(Text, Callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.Text = "  " .. Text
            b.TextColor3 = Color3.new(1, 1, 1)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseButton1Click:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 105, 180)}):Play()
                task.wait(0.1)
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                Callback()
            end)
        end

        -- 输入框组件
        function Elements:AddInput(Text, Placeholder, Callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 45)
            f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            f.Parent = Page
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -20, 0, 30)
            box.Position = UDim2.new(0, 10, 0.5, -15)
            box.PlaceholderText = Text .. ": " .. Placeholder
            box.BackgroundTransparency = 1
            box.TextColor3 = Color3.new(1, 1, 1)
            box.Parent = f
            
            box.FocusLost:Connect(function()
                Callback(box.Text)
            end)
        end

        -- 信息显示组件
        function Elements:AddLabel(Text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 30)
            l.BackgroundTransparency = 1
            l.Text = "  " .. Text
            l.TextColor3 = Color3.fromRGB(200, 200, 200)
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = Page
        end

        return Elements
    end

    function Window:Notify(Text)
        print("SOUL NOTIFICATION: " .. Text)
        -- 可选：在这里添加右上角弹窗逻辑
    end

    return Window
end

return SOUL_LIB
