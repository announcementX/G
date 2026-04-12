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
    ScreenGui.Name = "SkyPink_Final_V2"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -170)
    MainFrame.BackgroundColor3 = Colors.DarkBg
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
    TitleLabel.Size = UDim2.new(1, -120, 1, 0); TitleLabel.Position = UDim2.new(0, 20, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.TextColor3 = Colors.MainPink; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar

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
        b.Size = UDim2.new(0, 32, 0, 32); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = ""; b.Parent = TopBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local icon = Instance.new("Frame"); icon.Size = UDim2.new(0, 16, 0, 2); icon.Position = UDim2.new(0.5, 0, 0.5, 0); icon.AnchorPoint = Vector2.new(0.5, 0.5); icon.BorderSizePixel = 0; icon.Parent = b
        if isClose then icon.BackgroundColor3 = Color3.fromRGB(255,100,100); icon.Rotation = 45; local i2 = icon:Clone(); i2.Rotation = -45; i2.Parent = b else icon.BackgroundColor3 = Colors.MainPink end
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
    Instance.new("UIStroke", SideBar).Color = Colors.MainPink; SideBar.UIStroke.Transparency = 0.8

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
            if container:IsA("ScrollingFrame") then 
                container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20) 
            end
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -10, 0, 42); b.BackgroundColor3 = Colors.ElementBg; b.Text = "  " .. text; b.TextColor3 = Colors.LightPink; b.TextXAlignment = Enum.TextXAlignment.Left; b.Font = Enum.Font.GothamMedium; b.TextSize = 14; b.Parent = container; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10); ClickAnim(b); b.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateFolder(name)
            local fBase = Instance.new("Frame"); fBase.Size = UDim2.new(1, -10, 0, 42); fBase.BackgroundColor3 = Color3.fromRGB(32, 32, 32); fBase.ClipsDescendants = true; fBase.Parent = container; Instance.new("UICorner", fBase).CornerRadius = UDim.new(0, 10)
            local fBtn = Instance.new("TextButton"); fBtn.Size = UDim2.new(1, 0, 0, 42); fBtn.BackgroundTransparency = 1; fBtn.Text = "  📁  " .. name; fBtn.TextColor3 = Colors.MainPink; fBtn.TextXAlignment = Enum.TextXAlignment.Left; fBtn.Font = Enum.Font.GothamBold; fBtn.TextSize = 14; fBtn.Parent = fBase
            local fContent = Instance.new("Frame"); fContent.Size = UDim2.new(1, 0, 0, 0); fContent.Position = UDim2.new(0, 0, 0, 42); fContent.BackgroundTransparency = 1; fContent.Parent = fBase
            local fList = Instance.new("UIListLayout", fContent); fList.Padding = UDim.new(0, 8); fList.HorizontalAlignment = Enum.HorizontalAlignment.Center
            
            local open = false
            fBtn.MouseButton1Click:Connect(function()
                open = not open
                -- 【修复核心】增加 5 像素缓冲，并强制触发父容器刷新
                local targetHeight = open and (fList.AbsoluteContentSize.Y + 50) or 42
                TweenService:Create(fBase, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
                task.spawn(function()
                    local start = tick()
                    while tick() - start < 0.4 do -- 动画期间不停更新画布，防止卡住
                        UpdateCanvas()
                        task.wait()
                    end
                end)
            end)
            return AddElements(fContent, fList)
        end
        return Elements
    end

    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 115, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TabBtn.Text = name; TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150); TabBtn.Font = Enum.Font.GothamMedium; TabBtn.TextSize = 13; TabBtn.Parent = TabContainer; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        local Container = Instance.new("ScrollingFrame"); Container.Size = UDim2.new(1, 0, 1, 0); Container.BackgroundTransparency = 1; Container.Visible = false; Container.ScrollBarThickness = 0; Container.Parent = ContentHolder
        local UIList = Instance.new("UIListLayout", Container); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        if ScreenGui:FindFirstChild("First") == nil then local f = Instance.new("BoolValue", ScreenGui); f.Name = "First"; Container.Visible = true; TabBtn.TextColor3 = Colors.MainPink end
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Container.Visible = true; TabBtn.TextColor3 = Colors.MainPink
        end)
        return AddElements(Container, UIList)
    end
    return Library
end

