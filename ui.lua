local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [[ 顶级颜色配置：淡粉色风暴 ]]
local Colors = {
    MainPink = Color3.fromRGB(255, 182, 193),   -- 主色：淡粉
    LightPink = Color3.fromRGB(255, 220, 230),  -- 辅助：极淡粉（文字用）
    DarkPink = Color3.fromRGB(200, 140, 150),   -- 互动：深粉（未选中用）
    Background = Color3.fromRGB(15, 15, 15),     -- 背景：炭黑
    SideBar = Color3.fromRGB(22, 22, 22),        -- 侧边：微黑
    Element = Color3.fromRGB(28, 28, 28),        -- 组件：暗灰
    Folder = Color3.fromRGB(35, 35, 35)         -- 文件夹：稍亮灰
}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkParadise_v2"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- --- 主界面 ---
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- --- 手机端丝滑拖拽 ---
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if input.Position.Y - MainFrame.AbsolutePosition.Y < 40 then -- 仅顶部栏可拖拽
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- --- 顶部栏 ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.MainPink
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 右上角粉色按钮组
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Colors.MainPink
    CloseBtn.TextSize = 30
    CloseBtn.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -65, 0.5, -15)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Colors.MainPink
    MinBtn.TextSize = 30
    MinBtn.Parent = TopBar

    -- --- 侧边栏 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 120, 1, -40)
    SideBar.Position = UDim2.new(0, 0, 0, 40)
    SideBar.BackgroundColor3 = Colors.SideBar
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = SideBar

    Instance.new("UIListLayout", TabContainer).HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- --- 内容区 ---
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -135, 1, -50)
    ContentHolder.Position = UDim2.new(0, 130, 0, 45)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    local FirstTab = true

    -- 按钮事件
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    local min = false
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {
            Size = min and UDim2.new(0, 480, 0, 40) or UDim2.new(0, 480, 0, 320)
        }):Play()
    end)

    -- --- 统一组件处理逻辑 ---
    local function AddElements(container, listLayout)
        local Elements = {}

        -- 自动 CanvasSize
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if container:IsA("ScrollingFrame") then
                container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
            end
        end)

        -- 辅助函数：创建通用底座
        local function CreateBaseFrame(height)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, height or 38)
            frame.BackgroundColor3 = Colors.Element
            frame.Parent = container
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
            return frame
        end

        -- 1. 按钮
        function Elements:CreateButton(text, callback)
            local bBase = CreateBaseFrame()
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BackgroundTransparency = 1
            b.Text = "  " .. text
            b.TextColor3 = Colors.LightPink
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Parent = bBase
            b.MouseButton1Click:Connect(callback)
        end

        -- 2. 开关
        function Elements:CreateToggle(text, callback)
            local tBase = CreateBaseFrame()
            local tLabel = Instance.new("TextLabel")
            tLabel.Size = UDim2.new(1, -60, 1, 0)
            tLabel.Position = UDim2.new(0, 12, 0, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.Text = text
            tLabel.TextColor3 = Colors.LightPink
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.Font = Enum.Font.Gotham
            tLabel.TextSize = 13
            tLabel.Parent = tBase

            local tOuter = Instance.new("TextButton")
            tOuter.Size = UDim2.new(0, 36, 0, 20)
            tOuter.Position = UDim2.new(1, -48, 0.5, -10)
            tOuter.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            tOuter.Text = ""
            tOuter.Parent = tBase
            Instance.new("UICorner", tOuter).CornerRadius = UDim.new(1, 0)

            local tInner = Instance.new("Frame")
            tInner.Size = UDim2.new(0, 16, 0, 16)
            tInner.Position = UDim2.new(0, 2, 0.5, -8)
            tInner.BackgroundColor3 = Colors.DarkPink
            tInner.Parent = tOuter
            Instance.new("UICorner", tInner).CornerRadius = UDim.new(1, 0)

            local state = false
            tOuter.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(tInner, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                    Position = state and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = state and Colors.MainPink or Colors.DarkPink
                }):Play()
                callback(state)
            end)
        end

        -- 3. 输入框
        function Elements:CreateInput(text, placeholder, callback)
            local iBase = CreateBaseFrame()
            local iLabel = Instance.new("TextLabel")
            iLabel.Size = UDim2.new(0, 120, 1, 0)
            iLabel.Position = UDim2.new(0, 12, 0, 0)
            iLabel.BackgroundTransparency = 1
            iLabel.Text = text
            iLabel.TextColor3 = Colors.LightPink
            iLabel.TextXAlignment = Enum.TextXAlignment.Left
            iLabel.Font = Enum.Font.Gotham
            iLabel.TextSize = 13
            iLabel.Parent = iBase

            local iBox = Instance.new("TextBox")
            iBox.Size = UDim2.new(0, 90, 0, 26)
            iBox.Position = UDim2.new(1, -100, 0.5, -13)
            iBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            iBox.Text = ""
            iBox.PlaceholderText = placeholder
            iBox.TextColor3 = Colors.MainPink
            iBox.PlaceholderColor3 = Colors.DarkPink
            iBox.Font = Enum.Font.Gotham
            iBox.TextSize = 12
            iBox.Parent = iBase
            Instance.new("UICorner", iBox).CornerRadius = UDim.new(0, 6)
            iBox.FocusLost:Connect(function() callback(iBox.Text) end)
        end

        -- 4. 新增：文件夹 (CreateFolder)
        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame")
            fBase.Size = UDim2.new(1, -10, 0, 38)
            fBase.BackgroundColor3 = Colors.Folder
            fBase.ClipsDescendants = true
            fBase.Parent = container
            local fCorner = Instance.new("UICorner", fBase)
            fCorner.CornerRadius = UDim.new(0, 8)

            local fBtn = Instance.new("TextButton")
            fBtn.Size = UDim2.new(1, 0, 0, 38)
            fBtn.BackgroundTransparency = 1
            fBtn.Text = "   📁  " .. name -- 加上小图标
            fBtn.TextColor3 = Colors.MainPink -- 文件夹名字用深粉色
            fBtn.TextXAlignment = Enum.TextXAlignment.Left
            fBtn.Font = Enum.Font.GothamMedium
            fBtn.TextSize = 13
            fBtn.Parent = fBase

            -- 文件夹内部容器
            local fContent = Instance.new("Frame")
            fContent.Size = UDim2.new(1, -10, 1, -45)
            fContent.Position = UDim2.new(0, 5, 0, 42)
            fContent.BackgroundTransparency = 1
            fContent.Parent = fBase

            local fList = Instance.new("UIListLayout", fContent)
            fList.Padding = UDim.new(0, 6)
            fList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                -- 核心逻辑：自动计算内容高度并Tween
                local targetHeight = open and (fList.AbsoluteContentSize.Y + 50) or 38
                TweenService:Create(fBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
                    Size = UDim2.new(1, -10, 0, targetHeight)
                }):Play()
                
                -- 如果在主滚动框里，需要强制触发父容器重绘 CanvasSize
                task.wait(0.4)
                if container:IsA("ScrollingFrame") then
                   container.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 5)
                end
            end)

            -- 文件夹也支持 AddElements 里的三种格式
            return AddElements(fContent, fList)
        end

        return Elements
    end

    -- --- 侧边栏栏目方法 ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 105, 0, 35)
        TabBtn.BackgroundColor3 = Colors.SideBar
        TabBtn.Text = name
        TabBtn.TextColor3 = Colors.DarkPink
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.ScrollBarThickness = 3
        Container.ScrollBarImageColor3 = Colors.MainPink -- 滚动条也变粉！
        Container.Parent = ContentHolder

        local UIList = Instance.new("UIListLayout", Container)
        UIList.Padding = UDim.new(0, 8)
        UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        if FirstTab then
            Container.Visible = true
            TabBtn.TextColor3 = Colors.MainPink
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 28, 30)
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Colors.DarkPink; v.BackgroundColor3 = Colors.SideBar end end
            Container.Visible = true
            TabBtn.TextColor3 = Colors.MainPink
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 28, 30)
        end)

        -- 返回该分类下的组件方法
        return AddElements(Container, UIList)
    end

    return Library
end

return Library
