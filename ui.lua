local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 宝宝要求的默认黑粉色
local Defaults = {
    Main = Color3.fromRGB(255, 182, 193), -- 粉色
    Bg = Color3.fromRGB(15, 15, 15),     -- 深黑
    Btn = Color3.fromRGB(25, 25, 25),    -- 组件黑
    Text = Color3.fromRGB(255, 235, 245), -- 浅粉白
    Size = UDim2.new(0, 500, 0, 340)     -- 默认大小
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

function Library:CreateWindow(title, config)
    local c = config or {}
    local Colors = {
        Main = c.Main or Defaults.Main,
        Bg = c.Bg or Defaults.Bg,
        Btn = c.Btn or Defaults.Btn,
        Text = c.Text or Defaults.Text
    }
    local WinSize = c.Size or Defaults.Size

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkyPink_Absolute_Working"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = WinSize
    MainFrame.Position = UDim2.new(0.5, -WinSize.X.Offset/2, 0.5, -WinSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Colors.Bg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- 内容容器 (不再用 CanvasGroup 以免显示异常)
    local Container = Instance.new("Frame")
    Container.Name = "MainContent"
    Container.Size = UDim2.new(1, 0, 1, -50)
    Container.Position = UDim2.new(0, 0, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50); TopBar.BackgroundTransparency = 1; TopBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0); TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.Main; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar

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

    local function CreateIcon(pos, isClose, func)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 32, 0, 32); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = ""; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local icon = Instance.new("Frame"); icon.Size = UDim2.new(0, 16, 0, 2); icon.Position = UDim2.new(0.5, 0, 0.5, 0); icon.AnchorPoint = Vector2.new(0.5, 0.5); icon.BorderSizePixel = 0; icon.Parent = b
        if isClose then 
            icon.BackgroundColor3 = Color3.fromRGB(255, 100, 100); icon.Rotation = 45; local i2 = icon:Clone(); i2.Rotation = -45; i2.Parent = b 
        else 
            icon.BackgroundColor3 = Colors.Main 
        end
        ClickAnim(b); b.MouseButton1Click:Connect(func)
    end

    CreateIcon(UDim2.new(1, -42, 0.5, -16), true, function() ScreenGui:Destroy() end)
    local isMin = false
    CreateIcon(UDim2.new(1, -82, 0.5, -16), false, function()
        isMin = not isMin
        Container.Visible = not isMin
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = isMin and UDim2.new(0, WinSize.X.Offset, 0, 50) or WinSize}):Play()
    end)

    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 135, 1, 0); SideBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22); SideBar.BorderSizePixel = 0; SideBar.Parent = Container
    local Stroke = Instance.new("UIStroke", SideBar); Stroke.Color = Colors.Main; Stroke.Transparency = 0.8

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, 0); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; TabContainer.Parent = SideBar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 10)
    Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 15); Instance.new("UIPadding", TabContainer).PaddingLeft = UDim.new(0, 10)

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -155, 1, -15); ContentHolder.Position = UDim2.new(0, 145, 0, 5); ContentHolder.BackgroundTransparency = 1; ContentHolder.Parent = Container

    local WindowObj = {}

    local function CreateTab(self, name, color)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 115, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.Text = name; TabBtn.TextColor3 = color or Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.Parent = ContentHolder
        local Layout = Instance.new("UIListLayout", Page); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        if Container:FindFirstChild("First") == nil then 
            local f = Instance.new("BoolValue", Container); f.Name = "First"
            Page.Visible = true; TabBtn.TextColor3 = color or Colors.Main 
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true; TabBtn.TextColor3 = color or Colors.Main
        end)

        local TabObj = {}
        local function Update() Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20) end
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)

        local function CreateButton(self, t, clr, cb)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = Colors.Btn; b.Text = "  " .. t; b.TextColor3 = clr or Colors.Text; b.TextXAlignment = Enum.TextXAlignment.Left; b.Font = Enum.Font.GothamMedium; b.TextSize = 14; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10); ClickAnim(b); b.MouseButton1Click:Connect(cb); Update()
        end
        TabObj["[anniu]"] = CreateButton

        local function CreateFolder(self, fn, fc)
            local fBase = Instance.new("Frame"); fBase.Size = UDim2.new(1, -10, 0, 42); fBase.BackgroundColor3 = Color3.fromRGB(32, 32, 32); fBase.ClipsDescendants = true; fBase.Parent = Page; Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)
            local fBtn = Instance.new("TextButton"); fBtn.Size = UDim2.new(1, 0, 0, 42); fBtn.BackgroundTransparency = 1; fBtn.Text = "  📁  " .. fn; fBtn.TextColor3 = fc or Colors.Main; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("Frame"); fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 42); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            fBtn.MouseButton1Click:Connect(function()
                local open = fBase.Size.Y.Offset == 42
                TweenService:Create(fBase, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -10, 0, fList.AbsoluteContentSize.Y + 50) or UDim2.new(1, -10, 0, 42)}):Play()
                task.spawn(function() local s = tick(); while tick()-s<0.4 do Update(); task.wait() end end)
            end)
            local FolderObj = {}
            FolderObj["[anniu]"] = function(self, t, c, cb) CreateButton(nil, t, c, cb) end
            return FolderObj
        end
        TabObj["[wenjianjia]"] = CreateFolder
        return TabObj
    end
    WindowObj["[lanmu]"] = CreateTab
    return WindowObj
end

Library["[chuangkou]"] = Library.CreateWindow
return Library
