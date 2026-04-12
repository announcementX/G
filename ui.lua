local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Colors = {
    MainPink = Color3.fromRGB(255, 182, 193),
    LightPink = Color3.fromRGB(255, 235, 245),
    DarkBg = Color3.fromRGB(15, 15, 15),
    ElementBg = Color3.fromRGB(25, 25, 25)
}

local function ClickAnim(obj)
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.05), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset - 2, obj.Size.Y.Scale, obj.Size.Y.Offset - 2)}):Play()
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(obj, TweenInfo.new(0.05), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset + 2, obj.Size.Y.Scale, obj.Size.Y.Offset + 2)}):Play()
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkyPink_Perfect"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
    MainFrame.BackgroundColor3 = Colors.DarkBg
    MainFrame.ClipsDescendants = true 
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- 全局内容容器
    local GlobalContent = Instance.new("CanvasGroup")
    GlobalContent.Size = UDim2.new(1, 0, 1, -50)
    GlobalContent.Position = UDim2.new(0, 0, 0, 50)
    GlobalContent.BackgroundTransparency = 1
    GlobalContent.ZIndex = 2
    GlobalContent.Parent = MainFrame

    -- 顶部栏 (ZIndex 最高，确保盖住一切)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Colors.DarkBg
    TopBar.ZIndex = 10 
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 15)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.MainPink; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.ZIndex = 11; TitleLabel.Parent = TopBar

    -- 拖拽
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

    local function CreateFancyBtn(pos, isClose, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 32); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = ""; b.ZIndex = 12; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local icon = Instance.new("Frame"); icon.Size = UDim2.new(0, 16, 0, 2); icon.Position = UDim2.new(0.5, 0, 0.5, 0); icon.AnchorPoint = Vector2.new(0.5, 0.5); icon.BorderSizePixel = 0; icon.Parent = b
        if isClose then icon.BackgroundColor3 = Color3.fromRGB(255,100,100); icon.Rotation = 45; local i2 = icon:Clone(); i2.Rotation = -45; i2.Parent = b else icon.BackgroundColor3 = Colors.MainPink end
        ClickAnim(b); b.MouseButton1Click:Connect(func)
    end

    CreateFancyBtn(UDim2.new(1, -42, 0.5, -16), true, function() ScreenGui:Destroy() end)
    
    local min = false
    CreateFancyBtn(UDim2.new(1, -82, 0.5, -16), false, function()
        min = not min
        -- 核心逻辑：缩小就彻底关掉下方内容的可见性
        if min then
            TweenService:Create(GlobalContent, TweenInfo.new(0.15), {GroupTransparency = 1}):Play()
            task.delay(0.15, function() if min then GlobalContent.Visible = false end end)
        else
            GlobalContent.Visible = true
            TweenService:Create(GlobalContent, TweenInfo.new(0.2), {GroupTransparency = 0}):Play()
        end
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = min and UDim2.new(0, 500, 0, 50) or UDim2.new(0, 500, 0, 340)}):Play()
    end)

    -- 侧边栏 (向下挪动优化)
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 135, 1, 0); SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SideBar.BorderSizePixel = 0; SideBar.Parent = GlobalContent
    Instance.new("UIStroke", SideBar).Color = Colors.MainPink; SideBar.UIStroke.Transparency = 0.8

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, 0); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 10)
    
    -- 【修复】让侧边按钮往下挪一点点，不要太靠上
    local SidePadding = Instance.new("UIPadding", TabContainer)
    SidePadding.PaddingTop = UDim.new(0, 15) 
    SidePadding.PaddingLeft = UDim.new(0, 10)
    SidePadding.PaddingRight = UDim.new(0, 10)

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -155, 1, -15); ContentHolder.Position = UDim2.new(0, 145, 0, 5); ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = GlobalContent

    local function AddElements(container, listLayout)
        local Elements = {}
        local function UpdateCanvas() if container:IsA("ScrollingFrame") then container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10) end end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = Colors.ElementBg; b.Text = "  " .. text; b.TextColor3 = Colors.LightPink; b.TextXAlignment = Enum.TextXAlignment.Left; b.Font = Enum.Font.GothamMedium; b.TextSize = 14; b.Parent = container; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10); ClickAnim(b); b.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateToggle(text, callback)
            local f = Instance.new("Frame"); f.Size = UDim2.new(1, -10, 0, 42); f.BackgroundColor3 = Colors.ElementBg; f.Parent = container; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Colors.LightPink; l.TextXAlignment = Enum.TextXAlignment.Left; l.Font = Enum.Font.Gotham; l.TextSize = 14; l.Parent = f
            local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 42, 0, 22); btn.Position = UDim2.new(1, -55, 0.5, -11); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.Text = ""; btn.Parent = f; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 18, 0, 18); dot.Position = UDim2.new(0, 2, 0.5, -9); dot.BackgroundColor3 = Color3.fromRGB(150,150,150); dot.Parent = btn; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            local s = false
            btn.MouseButton1Click:Connect(function() s = not s; TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = s and UDim2.new(0, 22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = s and Colors.MainPink or Color3.fromRGB(150,150,150)}):Play(); callback(s) end)
        end

        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame"); fBase.Size = UDim2.new(1, -10, 0, 42); fBase.BackgroundColor3 = Color3.fromRGB(32, 32, 32); fBase.ClipsDescendants = true; fBase.Parent = container; Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)
            local fBtn = Instance.new("TextButton"); fBtn.Size = UDim2.new(1, 0, 0, 42); fBtn.BackgroundTransparency = 1; fBtn.Text = "  📁  " .. name; fBtn.TextColor3 = Colors.MainPink; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("Frame"); fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 42); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            local open = false
            fBtn.MouseButton1Click:Connect(function() open = not open; TweenService:Create(fBase, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = open and UDim2.new(1, -10, 0, fList.AbsoluteContentSize.Y + 55) or UDim2.new(1, -10, 0, 42)}):Play(); task.wait(0.3); UpdateCanvas() end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 115, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.Text = name; TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        local Container = Instance.new("CanvasGroup"); Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false; Container.Parent = ContentHolder; Container.GroupTransparency = 1 
        local SContainer = Instance.new("ScrollingFrame"); SContainer.Size = UDim2.new(1, 0, 1, 0); SContainer.BackgroundTransparency = 1; SContainer.ScrollBarThickness = 3; SContainer.ScrollBarImageColor3 = Colors.MainPink; SContainer.Parent = Container
        local UIList = Instance.new("UIListLayout", SContainer); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        if ScreenGui:FindFirstChild("First") == nil then local f = Instance.new("BoolValue", ScreenGui); f.Name = "First"; Container.Visible = true; Container.GroupTransparency = 0; TabBtn.TextColor3 = Colors.MainPink end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("CanvasGroup") and v ~= Container then v.Visible = false; v.GroupTransparency = 1 end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Container.Visible = true; TweenService:Create(Container, TweenInfo.new(0.15), {GroupTransparency = 0}):Play(); TabBtn.TextColor3 = Colors.MainPink
        end)
        return AddElements(SContainer, UIList)
    end
    return Library
end
return Library
