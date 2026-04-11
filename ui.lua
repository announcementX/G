local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [[ 顶级配色：渐变淡粉 ]]
local Colors = {
    MainPink = Color3.fromRGB(255, 182, 193),
    LightPink = Color3.fromRGB(255, 230, 240),
    HoverPink = Color3.fromRGB(255, 200, 215),
    DarkBg = Color3.fromRGB(12, 12, 12),
    ElementBg = Color3.fromRGB(25, 25, 25)
}

-- 动画辅助函数
local function ClickAnim(obj)
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset - 4, obj.Size.Y.Scale, obj.Size.Y.Offset - 4)}):Play()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset + 4, obj.Size.Y.Scale, obj.Size.Y.Offset + 4)}):Play()
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkPremium_v3"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 480, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
    MainFrame.BackgroundColor3 = Colors.DarkBg
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- --- 手机端丝滑拖拽 ---
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainFrame.AbsolutePosition.Y < 45 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- --- 顶部栏 (高级感设计) ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundTransparency = 1; TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.MainPink
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- 优雅的关闭/缩小键
    local function CreateIconBtn(text, pos, color, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 28); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.Text = text; b.TextColor3 = color; b.TextSize = 18; b.Font = Enum.Font.GothamBold; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        ClickAnim(b)
        b.MouseButton1Click:Connect(func)
    end

    CreateIconBtn("✕", UDim2.new(1, -40, 0.5, -14), Color3.fromRGB(255, 100, 100), function() ScreenGui:Destroy() end)
    local min = false
    CreateIconBtn("—", UDim2.new(1, -75, 0.5, -14), Colors.MainPink, function()
        min = not min
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = min and UDim2.new(0, 480, 0, 45) or UDim2.new(0, 480, 0, 320)}):Play()
    end)

    -- --- 侧边栏 & 内容区 ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 120, 1, -45); SideBar.Position = UDim2.new(0, 0, 0, 45)
    SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); SideBar.Parent = MainFrame

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -135, 1, -55); ContentHolder.Position = UDim2.new(0, 130, 0, 50)
    ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -10); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    Instance.new("UIListLayout", TabContainer).HorizontalAlignment = Enum.HorizontalAlignment.Center

    local FirstTab = true

    -- --- 组件工厂 ---
    local function AddElements(container, listLayout)
        local Elements = {}
        local function UpdateCanvas() 
            if container:IsA("ScrollingFrame") then container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10) end 
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        -- 1. 按钮 (带动画)
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 40); b.BackgroundColor3 = Colors.ElementBg
            b.Text = "  " .. text; b.TextColor3 = Colors.LightPink; b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.GothamMedium; b.TextSize = 13; b.Parent = container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            ClickAnim(b)
            b.MouseButton1Click:Connect(callback)
        end

        -- 2. 开关 (带丝滑位移)
        function Elements:CreateToggle(text, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = Colors.ElementBg; f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
            l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = f
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 40, 0, 22); btn.Position = UDim2.new(1, -52, 0.5, -11); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.Text = ""; btn.Parent = f
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 2, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(150,150,150); dot.Parent = btn
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            
            local s = false
            btn.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = s and UDim2.new(0, 20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = s and Colors.MainPink or Color3.fromRGB(150,150,150)}):Play()
                callback(s)
            end)
        end

        -- 3. 输入框 (带边框动画)
        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = Colors.ElementBg; f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0, 120, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1
            l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 13; l.Parent = f
            
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 85, 0, 28); box.Position = UDim2.new(1, -95, 0.5, -14); box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            box.Text = ""; box.PlaceholderText = placeholder; box.TextColor3 = Colors.MainPink; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Parent = f
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
            
            box.Focused:Connect(function() TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 40, 42)}):Play() end)
            box.FocusLost:Connect(function() TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play(); callback(box.Text) end)
        end

        -- 4. 文件夹 (还原 📁 图标 + 展开动画)
        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame")
            fBase.Size = UDim2.new(1, -10, 0, 40); fBase.BackgroundColor3 = Color3.fromRGB(32, 32, 32); fBase.ClipsDescendants = true; fBase.Parent = container
            Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)

            local fBtn = Instance.new("TextButton")
            fBtn.Size = UDim2.new(1, 0, 0, 40); fBtn.BackgroundTransparency = 1
            fBtn.Text = "  📁  " .. name; fBtn.TextColor3 = Colors.MainPink; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 13; fBtn.Parent = fBase

            local fContent = Instance.new("Frame")
            fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 40); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                local targetH = open and (fList.AbsoluteContentSize.Y + 50) or 40
                TweenService:Create(fBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetH), BackgroundColor3 = open and Color3.fromRGB(38, 34, 36) or Color3.fromRGB(32, 32, 32)}):Play()
                task.wait(0.4); UpdateCanvas()
            end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 105, 0, 36); TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false
        Container.ScrollBarThickness = 3; Container.ScrollBarImageColor3 = Colors.MainPink; Container.Parent = ContentHolder
        local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

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
