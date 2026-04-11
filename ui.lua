local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [[ 颜色配置：极致淡粉 ]]
local Colors = {
    MainPink = Color3.fromRGB(255, 182, 193),   -- 主色：淡粉
    LightPink = Color3.fromRGB(255, 230, 240),  -- 辅助：极浅粉
    DeepPink = Color3.fromRGB(255, 105, 180)    -- 强调：亮粉
}

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkParadise_Fixed"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true -- 保证整体缩放时不溢出
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- --- 手机端拖拽脚本 ---
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainFrame.AbsolutePosition.Y < 40 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- --- 顶部栏 ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -90, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.MainPink
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 15; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 右上角粉色按钮
    local function CreateTopBtn(text, offset, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(1, offset, 0.5, -15)
        b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Colors.MainPink
        b.TextSize = 30; b.Parent = TopBar
        b.MouseButton1Click:Connect(func)
    end
    CreateTopBtn("×", -35, function() ScreenGui:Destroy() end)
    local min = false
    CreateTopBtn("−", -65, function()
        min = not min
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = min and UDim2.new(0, 480, 0, 40) or UDim2.new(0, 480, 0, 320)}):Play()
    end)

    -- --- 布局 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 120, 1, -40); SideBar.Position = UDim2.new(0, 0, 0, 40)
    SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SideBar.Parent = MainFrame

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -135, 1, -50); ContentHolder.Position = UDim2.new(0, 130, 0, 45)
    ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -10); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    Instance.new("UIListLayout", TabContainer).HorizontalAlignment = Enum.HorizontalAlignment.Center

    local FirstTab = true

    -- --- 核心组件逻辑 ---
    local function AddElements(container, listLayout)
        local Elements = {}
        
        -- 核心修复：更新 CanvasSize
        local function UpdateCanvas()
            if container:IsA("ScrollingFrame") then
                container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            end
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        -- 1. 按钮
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 38); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.Text = "  " .. text; b.TextColor3 = Colors.LightPink; b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham; b.TextSize = 13; b.Parent = container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(callback)
        end

        -- 2. 开关
        function Elements:CreateToggle(text, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 38); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
            l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = f
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 36, 0, 20); btn.Position = UDim2.new(1, -48, 0.5, -10); btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.Text = ""; btn.Parent = f
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(0, 2, 0.5, -8); dot.BackgroundColor3 = Color3.fromRGB(150,150,150); dot.Parent = btn
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            
            local s = false
            btn.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = s and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = s and Colors.MainPink or Color3.fromRGB(150,150,150)}):Play()
                callback(s)
            end)
        end

        -- 3. 输入框
        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 38); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0, 120, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
            l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = f
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 80, 0, 26); box.Position = UDim2.new(1, -90, 0.5, -13); box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Text = ""; box.PlaceholderText = placeholder; box.TextColor3 = Colors.MainPink; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Parent = f
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        -- 4. 文件夹 (修复关键：增加 ClipsDescendants)
        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame")
            fBase.Size = UDim2.new(1, -10, 0, 38)
            fBase.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            fBase.ClipsDescendants = true -- !!! 重要修复：隐藏溢出的按钮 !!!
            fBase.Parent = container
            Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 8)

            local fBtn = Instance.new("TextButton")
            fBtn.Size = UDim2.new(1, 0, 0, 38); fBtn.BackgroundTransparency = 1
            fBtn.Text = "  ▼  " .. name; fBtn.TextColor3 = Colors.MainPink
            fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 13; fBtn.Parent = fBase

            local fContent = Instance.new("Frame")
            fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 38)
            fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent)
            fList.Padding = UDim.new(0, 6); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                fBtn.Text = (open and "  ▲  " or "  ▼  ") .. name
                local targetH = open and (fList.AbsoluteContentSize.Y + 45) or 38
                local t = TweenService:Create(fBase, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetH)})
                t:Play()
                t.Completed:Connect(UpdateCanvas) -- 动画结束后刷新大容器
            end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 105, 0, 35); TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false
        Container.ScrollBarThickness = 3; Container.ScrollBarImageColor3 = Colors.MainPink; Container.Parent = ContentHolder
        local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 8); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

        if FirstTab then Container.Visible = true; TabBtn.TextColor3 = Colors.MainPink; FirstTab = false end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Container.Visible = true; TabBtn.TextColor3 = Colors.MainPink
        end)
        return AddElements(Container, UIList)
    end
    return Library
end
return Library
