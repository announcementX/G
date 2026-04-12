local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [[ 配色方案：纯净淡粉 ]]
local Colors = {
    MainPink = Color3.fromRGB(255, 182, 193),   -- 主粉
    LightPink = Color3.fromRGB(255, 235, 245),  -- 极浅粉
    HoverPink = Color3.fromRGB(255, 210, 225),  -- 悬停粉
    DarkBg = Color3.fromRGB(15, 15, 15),         -- 深黑底
    ElementBg = Color3.fromRGB(25, 25, 25)      -- 组件底
}

-- 【光遇式动画】通用淡入淡出函数
local function SkyBlurAnim(obj, duration, visible)
    if not obj then return end
    obj.Visible = true
    obj.ClipsDescendants = true -- 强制剪裁
    if visible then
        obj.GroupTransparency = 1 -- 初始全透明
        local t1 = TweenService:Create(obj, TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 0 -- 淡入
        })
        t1:Play()
    else
        local t2 = TweenService:Create(obj, TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            GroupTransparency = 1 -- 淡出
        })
        t2:Play()
        t2.Completed:Connect(function() if not visible then obj.Visible = false end end)
    end
end

-- 点击动画
local function ClickAnim(obj)
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset - 2, obj.Size.Y.Scale, obj.Size.Y.Offset - 2)}):Play()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset + 2, obj.Size.Y.Scale, obj.Size.Y.Offset + 2)}):Play()
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkyPink_v5"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainCanvas = Instance.new("CanvasGroup") -- 使用 CanvasGroup 实现整体透明度动画
    MainCanvas.Size = UDim2.new(0, 500, 0, 340)
    MainCanvas.Position = UDim2.new(0.5, -250, 0.5, -170)
    MainCanvas.BackgroundColor3 = Colors.DarkBg
    MainCanvas.BorderSizePixel = 0
    MainCanvas.ClipsDescendants = true -- !!! 重点修复：缩放时剪裁一切 !!!
    MainCanvas.Parent = ScreenGui
    Instance.new("UICorner", MainCanvas).CornerRadius = UDim.new(0, 15)

    -- -- 【光遇加载动画】淡入 + 微缩放 -- --
    MainCanvas.GroupTransparency = 1
    MainCanvas.Size = UDim2.new(0, 0, 0, 0) -- 从 0 开始
    MainCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(MainCanvas, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 340),
        Position = UDim2.new(0.5, -250, 0.5, -170)
    }):Play()
    TweenService:Create(MainCanvas, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { GroupTransparency = 0 }):Play()

    -- --- 拖拽逻辑 (仅顶部栏) ---
    local dragging, dragStart, startPos
    MainCanvas.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainCanvas.AbsolutePosition.Y < 50 then
            dragging = true; dragStart = input.Position; startPos = MainCanvas.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- --- 顶部栏 ---
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50); TopBar.BackgroundTransparency = 1; TopBar.Parent = MainCanvas

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.MainPink
    TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar

    -- 手工画出的按钮 (淡红叉，淡粉减)
    local function CreateFancyBtn(pos, isClose, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 32); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = ""; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        
        if isClose then -- 画叉号
            local l1 = Instance.new("Frame"); l1.Size = UDim2.new(0, 18, 0, 2); l1.Position = UDim2.new(0.5, 0, 0.5, 0); l1.AnchorPoint = Vector2.new(0.5, 0.5); l1.Rotation = 45; l1.BackgroundColor3 = Color3.fromRGB(255, 120, 120); l1.BorderSizePixel = 0; l1.Parent = b
            local l2 = l1:Clone(); l2.Rotation = -45; l2.Parent = b
        else -- 画减号
            local l1 = Instance.new("Frame"); l1.Size = UDim2.new(0, 18, 0, 2); l1.Position = UDim2.new(0.5, 0, 0.5, 0); l1.AnchorPoint = Vector2.new(0.5, 0.5); l1.BackgroundColor3 = Colors.MainPink; l1.BorderSizePixel = 0; l1.Parent = b
        end
        ClickAnim(b)
        b.MouseButton1Click:Connect(func)
    end

    -- 【光遇关闭动画】淡出 + 向中心缩小
    CreateFancyBtn(UDim2.new(1, -42, 0.5, -16), true, function()
        local t1 = TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            GroupTransparency = 1
        })
        t1:Play()
        t1.Completed:Connect(function() ScreenGui:Destroy() end)
    end)
    
    local min = false
    CreateFancyBtn(UDim2.new(1, -82, 0.5, -16), false, function()
        min = not min
        -- !!! 重点修复：缩小后，所有组件由于 MainCanvas 的 ClipsDescendants 而隐身 !!!
        TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = min and UDim2.new(0, 500, 0, 50) or UDim2.new(0, 500, 0, 340)}):Play()
    end)

    -- --- 侧边栏 (修复蓝色边) ---
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 130, 1, -50); SideBar.Position = UDim2.new(0, 0, 0, 50)
    SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SideBar.BorderSizePixel = 0; SideBar.Parent = MainCanvas
    
    -- 【修复蓝色边】亲手画出粉色磨砂边框
    local SideStroke = Instance.new("UIStroke")
    SideStroke.Color = Colors.MainPink
    SideStroke.Transparency = 0.8 -- 磨砂感
    SideStroke.Thickness = 1.2
    SideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SideStroke.Parent = SideBar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -10); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Padding = UDim.new(0, 12) -- 增加间距

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -150, 1, -65); ContentHolder.Position = UDim2.new(0, 140, 0, 55)
    ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = MainCanvas

    local function AddElements(container, listLayout)
        local Elements = {}
        local function UpdateCanvas() if container:IsA("ScrollingFrame") then container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10) end end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = Colors.ElementBg; b.Text = "  " .. text; b.TextColor3 = Colors.LightPink; b.TextXAlignment = Enum.TextXAlignment.Left; b.Font = Enum.Font.GothamMedium; b.TextSize = 14; b.Parent = container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            ClickAnim(b)
            b.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateToggle(text, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 42); f.BackgroundColor3 = Colors.ElementBg; f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 14; l.Parent = f
            local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 42, 0, 22); btn.Position = UDim2.new(1, -55, 0.5, -11); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.Text = ""; btn.Parent = f
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 2, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(150,150,150); dot.Parent = btn; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            local s = false
            btn.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = s and UDim2.new(0, 22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = s and Colors.MainPink or Color3.fromRGB(150,150,150)}):Play()
                callback(s)
            end)
        end

        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, -10, 0, 42); f.BackgroundColor3 = Colors.ElementBg; f.Parent = container
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0, 120, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 14; l.Parent = f
            local box = Instance.new("TextBox"); box.Size = UDim2.new(0, 90, 0, 28); box.Position = UDim2.new(1, -100, 0.5, -14); box.BackgroundColor3 = Color3.fromRGB(35, 35, 35); box.Text = ""; box.PlaceholderText = placeholder; box.TextColor3 = Colors.MainPink; box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Parent = f
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame"); fBase.Size = UDim2.new(1, -10, 0, 42); fBase.BackgroundColor3 = Color3.fromRGB(32, 32, 32); fBase.ClipsDescendants = true; fBase.Parent = container
            Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)
            local fBtn = Instance.new("TextButton"); fBtn.Size = UDim2.new(1, 0, 0, 42); fBtn.BackgroundTransparency = 1; fBtn.Text = "  📁  " .. name; fBtn.TextColor3 = Colors.MainPink; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("CanvasGroup"); fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 42); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                -- 【光遇式文件夹展开】淡入淡出组件
                SkyBlurAnim(fContent, 0.4, open)
                TweenService:Create(fBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = open and UDim2.new(1, -10, 0, fList.AbsoluteContentSize.Y + 55) or UDim2.new(1, -10, 0, 42)}):Play()
                task.wait(0.4); UpdateCanvas()
            end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 110, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        local Container = Instance.new("CanvasGroup") -- 重点修复：使用 CanvasGroup 实现淡入
        Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false; Container.Parent = ContentHolder
        Container.ZIndex = 1

        local SContainer = Instance.new("ScrollingFrame") -- 内部滚动
        SContainer.Size = UDim2.new(1, 0, 1, 0); SContainer.BackgroundTransparency = 1; SContainer.ScrollBarThickness = 3; SContainer.ScrollBarImageColor3 = Colors.MainPink; SContainer.Parent = Container

        local UIList = Instance.new("UIListLayout", SContainer); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        if ScreenGui:FindFirstChild("First") == nil then 
            local f = Instance.new("BoolValue", ScreenGui); f.Name = "First"; 
            Container.Visible = true; TabBtn.TextColor3 = Colors.MainPink;
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("CanvasGroup") then SkyBlurAnim(v, 0.3, false) end end -- 全部淡出
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            
            -- 【光遇栏目切换动画】先隐藏，再淡入
            task.delay(0.2, function() SkyBlurAnim(Container, 0.4, true) end)
            TabBtn.TextColor3 = Colors.MainPink
        end)
        return AddElements(SContainer, UIList)
    end
    return Library
end
return Library
