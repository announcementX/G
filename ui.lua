local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 默认颜色配置
local DefaultColors = {
    MainPink = Color3.fromRGB(255, 182, 193), -- 主色调
    LightPink = Color3.fromRGB(255, 235, 245), -- 文本默认色
    DarkBg = Color3.fromRGB(15, 15, 15), -- 背景色
    ElementBg = Color3.fromRGB(25, 25, 25), -- 按钮/组件色
    CloseBtn = Color3.fromRGB(255, 100, 100), -- 关闭键颜色
    MinBtn = Color3.fromRGB(255, 182, 193) -- 缩小键颜色
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

-- 增加 config 参数
function Library:CreateWindow(title, config)
    local cfg = config or {}
    local Colors = {
        Main = cfg.MainPink or DefaultColors.MainPink,
        Text = cfg.LightPink or DefaultColors.LightPink,
        Bg = cfg.DarkBg or DefaultColors.DarkBg,
        Element = cfg.ElementBg or DefaultColors.ElementBg,
        Close = cfg.CloseBtn or DefaultColors.CloseBtn,
        Min = cfg.MinBtn or DefaultColors.MinBtn
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkyPink_Custom_V3"
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
    MainFrame.BackgroundColor3 = Colors.Bg
    MainFrame.ClipsDescendants = true 
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    local GlobalGroup = Instance.new("CanvasGroup")
    GlobalGroup.Size = UDim2.new(1, 0, 1, 0)
    GlobalGroup.BackgroundTransparency = 1
    GlobalGroup.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50); TopBar.BackgroundTransparency = 1; TopBar.ZIndex = 100; TopBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0); TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.Main; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar

    -- 按钮创建函数（带自定义颜色）
    local function CreateFancyBtn(pos, isClose, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 32); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = ""; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local icon = Instance.new("Frame"); icon.Size = UDim2.new(0, 16, 0, 2); icon.Position = UDim2.new(0.5, 0, 0.5, 0); icon.AnchorPoint = Vector2.new(0.5, 0.5); icon.BorderSizePixel = 0; icon.Parent = b
        
        if isClose then 
            icon.BackgroundColor3 = Colors.Close; icon.Rotation = 45; local i2 = icon:Clone(); i2.Rotation = -45; i2.Parent = b 
        else 
            icon.BackgroundColor3 = Colors.Min 
        end
        ClickAnim(b); b.MouseButton1Click:Connect(func)
    end

    CreateFancyBtn(UDim2.new(1, -42, 0.5, -16), true, function() ScreenGui:Destroy() end)
    local min = false
    CreateFancyBtn(UDim2.new(1, -82, 0.5, -16), false, function()
        min = not min
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = min and UDim2.new(0, 500, 0, 50) or UDim2.new(0, 500, 0, 340)}):Play()
        TweenService:Create(GlobalGroup, TweenInfo.new(0.2), {GroupTransparency = min and 1 or 0}):Play()
    end)

    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 135, 1, -50); SideBar.Position = UDim2.new(0, 0, 0, 50); SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SideBar.Parent = GlobalGroup
    Instance.new("UIStroke", SideBar).Color = Colors.Main; SideBar.UIStroke.Transparency = 0.8

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, 0); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 10)
    local SidePadding = Instance.new("UIPadding", TabContainer)
    SidePadding.PaddingTop = UDim.new(0, 15); SidePadding.PaddingLeft = UDim.new(0, 10); SidePadding.PaddingRight = UDim.new(0, 10)

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -155, 1, -65); ContentHolder.Position = UDim2.new(0, 145, 0, 55); ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = GlobalGroup

    local function AddElements(container, listLayout)
        local Elements = {}
        local function UpdateCanvas() 
            if container:IsA("ScrollingFrame") then container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20) end
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        -- 增加 color 参数，不写默认 Colors.Text
        function Elements:CreateButton(text, color, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = Colors.Element
            b.Text = "  " .. text; b.TextColor3 = color or Colors.Text
            b.TextXAlignment = Enum.TextXAlignment.Left; b.Font = Enum.Font.GothamMedium; b.TextSize = 14; b.Parent = container
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10); ClickAnim(b); b.MouseButton1Click:Connect(callback)
            UpdateCanvas()
        end

        function Elements:CreateFolder(name, color)
            local fBase = Instance.new("Frame"); fBase.Size = UDim2.new(1, -10, 0, 42); fBase.BackgroundColor3 = Color3.fromRGB(30,30,30); fBase.ClipsDescendants = true; fBase.Parent = container; Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)
            local fBtn = Instance.new("TextButton"); fBtn.Size = UDim2.new(1, 0, 0, 42); fBtn.BackgroundTransparency = 1
            fBtn.Text = "  📁  " .. name; fBtn.TextColor3 = color or Colors.Main
            fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("Frame"); fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 42); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                local targetHeight = open and (fList.AbsoluteContentSize.Y + 50) or 42
                TweenService:Create(fBase, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
                task.spawn(function() local s = tick(); while tick()-s<0.4 do UpdateCanvas(); task.wait() end end)
            end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name, color)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 115, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.Text = name; TabBtn.TextColor3 = color or Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        local Container = Instance.new("ScrollingFrame"); Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false; Container.ScrollBarThickness = 0; Container.Parent = ContentHolder
        local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        if ScreenGui:FindFirstChild("First") == nil then 
            Instance.new("BoolValue", ScreenGui).Name = "First"
            Container.Visible = true; TabBtn.TextColor3 = color or Colors.Main 
        end
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Container.Visible = true; TabBtn.TextColor3 = color or Colors.Main
        end)
        return AddElements(Container, UIList)
    end
    return Library
end
return Library
