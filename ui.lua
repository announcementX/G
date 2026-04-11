local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local SOUL_UI = {
    Themes = {
        Default = {
            Main = Color3.fromRGB(15, 15, 15),
            Accent = Color3.fromRGB(255, 105, 180),
            Gradient = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 20, 35)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
            })
        }
    }
}

function SOUL_UI:CreateWindow(Config)
    local Window = {
        Size = Config.Size or UDim2.new(0, 500, 0, 300),
        MinimizedStyle = Config.MinimizedStyle or "RoundedSquare",
        Title = Config.Name or "SOUL | UI"
    }

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SOUL_PROJECT"
    MainGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = Window.Size
    MainFrame.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = SOUL_UI.Themes.Default.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local TopGradient = Instance.new("UIGradient")
    TopGradient.Color = SOUL_UI.Themes.Default.Gradient
    TopGradient.Rotation = 90
    
    local GradientFrame = Instance.new("Frame")
    GradientFrame.Size = UDim2.new(1, 0, 1, 0)
    GradientFrame.BackgroundColor3 = Color3.new(1,1,1)
    GradientFrame.BorderSizePixel = 0
    TopGradient.Parent = GradientFrame
    GradientFrame.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Text = Window.Title
    Title.TextColor3 = SOUL_UI.Themes.Default.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "×"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 7)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 24
    CloseBtn.Parent = TopBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Text = "−"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 7)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeBtn.TextSize = 24
    MinimizeBtn.Parent = TopBar

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 130, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = SOUL_UI.Themes.Default.Accent
    Sidebar.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = Sidebar

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -140, 1, -55)
    Container.Position = UDim2.new(0, 135, 0, 50)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 4
    Container.Parent = MainFrame

    local ContLayout = Instance.new("UIListLayout")
    ContLayout.Padding = UDim.new(0, 8)
    ContLayout.Parent = Container

    local function Drag()
        local dragging, dragInput, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    Drag()

    local MinimizedIcon = Instance.new("TextButton")
    MinimizedIcon.Visible = false
    MinimizedIcon.BackgroundColor3 = SOUL_UI.Themes.Default.Main
    MinimizedIcon.BorderSizePixel = 0
    MinimizedIcon.Parent = MainGui

    local MinCorner = Instance.new("UICorner")
    MinCorner.Parent = MinimizedIcon

    local function ApplyStyle(style)
        if style == "Circle" then MinCorner.CornerRadius = UDim.new(1, 0)
        elseif style == "RoundedSquare" then MinCorner.CornerRadius = UDim.new(0, 12)
        else MinCorner.CornerRadius = UDim.new(0, 5) end
    end
    ApplyStyle(Window.MinimizedStyle)

    MinimizeBtn.MouseButton1Click:Connect(function()
        local Tween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
        Tween:Play()
        Tween.Completed:Wait()
        MainFrame.Visible = false
        MinimizedIcon.Visible = true
        MinimizedIcon.Size = UDim2.new(0, 50, 0, 50)
        MinimizedIcon.Position = MainFrame.Position
    end)

    MinimizedIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizedIcon.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = Window.Size, BackgroundTransparency = 0}):Play()
    end)

    function Window:Notify(Text, Img)
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(0, 220, 0, 60)
        Notif.Position = UDim2.new(1, 10, 0, 20)
        Notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Notif.Parent = MainGui
        Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = SOUL_UI.Themes.Default.Accent
        Stroke.Thickness = 1.5
        Stroke.Parent = Notif

        local Lab = Instance.new("TextLabel")
        Lab.Text = Text
        Lab.Size = UDim2.new(1, -50, 1, 0)
        Lab.Position = UDim2.new(0, 45, 0, 0)
        Lab.BackgroundTransparency = 1
        Lab.TextColor3 = Color3.new(1,1,1)
        Lab.TextWrapped = true
        Lab.Parent = Notif

        if Img then
            local Icon = Instance.new("ImageLabel")
            Icon.Image = Img
            Icon.Size = UDim2.new(0, 30, 0, 30)
            Icon.Position = UDim2.new(0, 10, 0, 15)
            Icon.BackgroundTransparency = 1
            Icon.Parent = Notif
        end

        TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -230, 0, 20)}):Play()
        task.delay(3, function()
            TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 10, 0, 20)}):Play()
            task.wait(0.5)
            Notif:Destroy()
        end)
    end

    return Window
end

return SOUL_UI
-- 在 Window 对象内添加以下方法
function Window:AddTab(Name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Text = Name
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabObj = {}

    function TabObj:AddButton(Text, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 40)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Btn.Text = Text
        Btn.TextColor3 = Color3.new(1,1,1)
        Btn.Parent = Container
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(function()
            local T = TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = SOUL_UI.Themes.Default.Accent})
            T:Play()
            T.Completed:Wait()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
            Callback()
        end)
    end

    function TabObj:AddToggle(Text, Default, Callback)
        local Toggled = Default
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 40)
        Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Frame.Parent = Container
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lab = Instance.new("TextLabel")
        Lab.Text = Text
        Lab.Size = UDim2.new(1, -50, 1, 0)
        Lab.Position = UDim2.new(0, 10, 0, 0)
        Lab.BackgroundTransparency = 1
        Lab.TextColor3 = Color3.new(1,1,1)
        Lab.TextXAlignment = Enum.TextXAlignment.Left
        Lab.Parent = Frame

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 40, 0, 20)
        Box.Position = UDim2.new(1, -50, 0.5, -10)
        Box.BackgroundColor3 = Toggled and SOUL_UI.Themes.Default.Accent or Color3.fromRGB(50, 50, 50)
        Box.Parent = Frame
        Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 16, 0, 16)
        Dot.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Dot.BackgroundColor3 = Color3.new(1,1,1)
        Dot.Parent = Box
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        Frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Toggled = not Toggled
                TweenService:Create(Box, TweenInfo.new(0.3), {BackgroundColor3 = Toggled and SOUL_UI.Themes.Default.Accent or Color3.fromRGB(50, 50, 50)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3), {Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                Callback(Toggled)
            end
        end)
    end

    function TabObj:AddInput(Text, Placeholder, Callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 45)
        Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Frame.Parent = Container
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Box = Instance.new("TextBox")
        Box.PlaceholderText = Placeholder
        Box.Size = UDim2.new(1, -20, 0, 30)
        Box.Position = UDim2.new(0, 10, 0, 7)
        Box.BackgroundTransparency = 1
        Box.TextColor3 = Color3.new(1,1,1)
        Box.TextXAlignment = Enum.TextXAlignment.Left
        Box.Parent = Frame

        Box.FocusLost:Connect(function()
            Callback(Box.Text)
        end)
    end

    function TabObj:ImportScript(Url)
        local Success, Error = pcall(function()
            loadstring(game:HttpGet(Url))()
        end)
        if not Success then Window:Notify("Import Failed!", nil) end
    end

    return TabObj
end
