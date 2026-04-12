local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 默认黑粉色
local Defaults = {
    Main = Color3.fromRGB(255, 182, 193), 
    Bg = Color3.fromRGB(15, 15, 15),     
    Btn = Color3.fromRGB(30, 30, 30),    
    Text = Color3.fromRGB(255, 235, 245), 
    Size = UDim2.new(0, 500, 0, 350)
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
    ScreenGui.Name = "SkyPink_Pinyin_Final"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 100

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = WinSize
    MainFrame.Position = UDim2.new(0.5, -WinSize.X.Offset/2, 0.5, -WinSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Colors.Bg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- 标题 (绝对不会消失)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 0, 50)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Colors.Main
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 10
    Title.Parent = MainFrame

    -- 侧边栏容器
    local SideBar = Instance.new("Frame")
    SideBar.Size = UDim2.new(0, 130, 1, -60)
    SideBar.Position = UDim2.new(0, 10, 0, 50)
    SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", SideBar).Color = Colors.Main

    -- 内容容器
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -160, 1, -60)
    PageContainer.Position = UDim2.new(0, 150, 0, 50)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- 拖拽
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - MainFrame.AbsolutePosition.Y < 50 then
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

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -10)
    TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = SideBar
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)

    local WindowObj = {}

    local function CreateTab(self, name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.Text = name; TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.Gotham; TabBtn.TextSize = 13; TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
        Page.ScrollBarThickness = 2; Page.Parent = PageContainer
        local Layout = Instance.new("UIListLayout", Page); Layout.Padding = UDim.new(0, 8); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        if SideBar:FindFirstChild("Selected") == nil then
            Instance.new("StringValue", SideBar).Name = "Selected"
            Page.Visible = true; TabBtn.TextColor3 = Colors.Main
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true; TabBtn.TextColor3 = Colors.Main
        end)

        local TabObj = {}
        local function Update() Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10) end
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)

        local function CreateButton(self, t, clr, cb)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -5, 0, 38); b.BackgroundColor3 = Colors.Btn
            b.Text = "  " .. t; b.TextColor3 = clr or Colors.Text; b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham; b.TextSize = 14; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            ClickAnim(b); b.MouseButton1Click:Connect(cb); Update()
        end
        TabObj["[anniu]"] = CreateButton
        TabObj["anniu"] = CreateButton

        local function CreateFolder(self, fn)
            local fBase = Instance.new("Frame")
            fBase.Size = UDim2.new(1, -5, 0, 38); fBase.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            fBase.ClipsDescendants = true; fBase.Parent = Page; Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 8)
            local fBtn = Instance.new("TextButton")
            fBtn.Size = UDim2.new(1, 0, 0, 38); fBtn.BackgroundTransparency = 1; fBtn.Text = "  📁 " .. fn
            fBtn.TextColor3 = Colors.Main; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold
            fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("Frame")
            fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 38); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 5); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            fBtn.MouseButton1Click:Connect(function()
                local open = fBase.Size.Y.Offset == 38
                TweenService:Create(fBase, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -5, 0, fList.AbsoluteContentSize.Y + 45) or UDim2.new(1, -5, 0, 38)}):Play()
                task.spawn(function() local s = tick(); while tick()-s<0.4 do Update(); task.wait() end end)
            end)
            local FolderObj = {}
            FolderObj["[anniu]"] = function(self, t, c, cb) CreateButton(nil, t, c, cb) end
            FolderObj["anniu"] = FolderObj["[anniu]"]
            return FolderObj
        end
        TabObj["[wenjianjia]"] = CreateFolder
        TabObj["wenjianjia"] = CreateFolder
        return TabObj
    end
    WindowObj["[lanmu]"] = CreateTab
    WindowObj["lanmu"] = CreateTab
    return WindowObj
end

Library["[chuangkou]"] = Library.CreateWindow
Library["chuangkou"] = Library.CreateWindow
return Library
