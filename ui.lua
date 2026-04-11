local SOUL = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local TWEEN_PROPS = {Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out, Time = 0.2}
local THEME = {
    Primary = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 100, 150),
    AccentDark = Color3.fromRGB(200, 50, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    GradientStart = Color3.fromRGB(255, 80, 130),
    GradientEnd = Color3.fromRGB(255, 150, 180)
}
SOUL.SETTINGS = {
    WindowSize = UDim2.new(0, 350, 0, 500),
    NotificationText = "SOUL 已加载",
    LeftImageEnabled = false,
    LeftImageURL = "",
    MinimizedStyle = "RoundedSquare",
    MinimizedSize = UDim2.new(0, 60, 0, 60),
    MinimizedText = "SOUL",
    MinimizedImage = ""
}

local function createGradient(parent, startC, endC, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, startC), ColorSequenceKeypoint.new(1, endC)})
    g.Rotation = rot or 45
    g.Parent = parent
    return g
end

local function tween(obj, props, dur, cb)
    local t = TweenService:Create(obj, TweenInfo.new(dur or TWEEN_PROPS.Time, TWEEN_PROPS.Style, TWEEN_PROPS.Direction), props)
    t:Play()
    if cb then t.Completed:Connect(cb) end
    return t
end

local function makeDraggable(frame)
    local drag, startPos, dragInput, dragStart
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and drag then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function SOUL.CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SOUL_UI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui end)

    -- 加载动画
    local loading = Instance.new("Frame")
    loading.Size = UDim2.new(1,0,1,0)
    loading.BackgroundColor3 = THEME.Primary
    loading.BorderSizePixel = 0
    loading.ZIndex = 100
    loading.Parent = gui
    createGradient(loading, THEME.GradientStart, THEME.GradientEnd, 45)
    local loadIcon = Instance.new("ImageLabel")
    loadIcon.Size = UDim2.new(0,60,0,60)
    loadIcon.Position = UDim2.new(0.5,-30,0.4,-30)
    loadIcon.BackgroundTransparency = 1
    loadIcon.Image = "rbxassetid://8992230677"
    loadIcon.ZIndex = 101
    loadIcon.Parent = loading
    local loadText = Instance.new("TextLabel")
    loadText.Size = UDim2.new(1,0,0,30)
    loadText.Position = UDim2.new(0,0,0.55,0)
    loadText.BackgroundTransparency = 1
    loadText.Text = "SOUL"
    loadText.TextColor3 = THEME.Text
    loadText.Font = Enum.Font.GothamBold
    loadText.TextSize = 24
    loadText.ZIndex = 101
    loadText.Parent = loading
    spawn(function()
        for i=0,100,2 do
            tween(loadIcon, {Rotation = loadIcon.Rotation + 30}, 0.05)
            wait(0.02)
        end
        loading:Destroy()
    end)

    -- 缩小窗口
    local minimized = Instance.new("Frame")
    minimized.Size = SOUL.SETTINGS.MinimizedSize
    minimized.Position = UDim2.new(0.8,0,0.1,0)
    minimized.BackgroundColor3 = THEME.Primary
    minimized.BorderSizePixel = 0
    minimized.Visible = false
    minimized.Parent = gui
    createGradient(minimized, THEME.GradientStart, THEME.GradientEnd, 45)
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0,12)
    minCorner.Parent = minimized
    Instance.new("UIStroke", minimized).Color = THEME.Accent
    local minText = Instance.new("TextLabel")
    minText.Size = UDim2.new(1,-10,1,-10)
    minText.Position = UDim2.new(0,5,0,5)
    minText.BackgroundTransparency = 1
    minText.Text = SOUL.SETTINGS.MinimizedText
    minText.TextColor3 = THEME.Text
    minText.Font = Enum.Font.GothamBold
    minText.TextSize = 14
    minText.TextWrapped = true
    minText.Parent = minimized
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(1,0,1,0)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = ""
    minBtn.Parent = minimized
    makeDraggable(minimized)

    -- 主窗口
    local main = Instance.new("Frame")
    main.Size = SOUL.SETTINGS.WindowSize
    main.Position = UDim2.new(0.5,-175,0.5,-250)
    main.BackgroundColor3 = THEME.Primary
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0,12)
    mainCorner.Parent = main
    Instance.new("UIStroke", main).Color = THEME.Accent
    createGradient(main, THEME.Primary, THEME.Secondary, 135)

    -- 顶栏
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1,0,0,40)
    top.BackgroundColor3 = THEME.Secondary
    top.BorderSizePixel = 0
    top.Parent = main
    Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)
    createGradient(top, THEME.Secondary, THEME.Primary, 90)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-100,1,0)
    titleLabel.Position = UDim2.new(0,15,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "SOUL"
    titleLabel.TextColor3 = THEME.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = top

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-35,0,5)
    closeBtn.BackgroundColor3 = THEME.Accent
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = top
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.25, function()
            gui:Destroy()
        end)
    end)

    local minBtnMain = Instance.new("TextButton")
    minBtnMain.Size = UDim2.new(0,30,0,30)
    minBtnMain.Position = UDim2.new(1,-70,0,5)
    minBtnMain.BackgroundColor3 = THEME.Secondary
    minBtnMain.Text = "—"
    minBtnMain.TextColor3 = THEME.Text
    minBtnMain.Font = Enum.Font.GothamBold
    minBtnMain.TextSize = 18
    minBtnMain.Parent = top
    Instance.new("UICorner", minBtnMain).CornerRadius = UDim.new(0,6)
    minBtnMain.MouseButton1Click:Connect(function()
        tween(main, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.8,0,0.1,0)}, 0.25, function()
            main.Visible = false
            minimized.Visible = true
        end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimized.Visible = false
        main.Visible = true
        tween(main, {Size = SOUL.SETTINGS.WindowSize}, 0.25)
    end)

    makeDraggable(main)

    -- 左侧边栏
    local leftBar = Instance.new("ScrollingFrame")
    leftBar.Size = UDim2.new(0,100,1,-40)
    leftBar.Position = UDim2.new(0,0,0,40)
    leftBar.BackgroundColor3 = THEME.Secondary
    leftBar.BorderSizePixel = 0
    leftBar.CanvasSize = UDim2.new(0,0,0,0)
    leftBar.ScrollBarThickness = 2
    leftBar.ScrollBarImageColor3 = THEME.Accent
    leftBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftBar.Parent = main
    createGradient(leftBar, THEME.Secondary, THEME.Primary, 180)
    local leftList = Instance.new("UIListLayout")
    leftList.Padding = UDim.new(0,5)
    leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftList.SortOrder = Enum.SortOrder.LayoutOrder
    leftList.Parent = leftBar

    local leftImg = Instance.new("ImageLabel")
    leftImg.Size = UDim2.new(1,-20,0,80)
    leftImg.Position = UDim2.new(0,10,0,10)
    leftImg.BackgroundTransparency = 1
    leftImg.Image = SOUL.SETTINGS.LeftImageURL
    leftImg.Visible = SOUL.SETTINGS.LeftImageEnabled
    leftImg.Parent = leftBar

    -- 右侧内容区
    local rightContent = Instance.new("ScrollingFrame")
    rightContent.Size = UDim2.new(1,-100,1,-40)
    rightContent.Position = UDim2.new(0,100,0,40)
    rightContent.BackgroundColor3 = THEME.Primary
    rightContent.BorderSizePixel = 0
    rightContent.CanvasSize = UDim2.new(0,0,0,0)
    rightContent.ScrollBarThickness = 3
    rightContent.ScrollBarImageColor3 = THEME.Accent
    rightContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    rightContent.Parent = main
    local rightList = Instance.new("UIListLayout")
    rightList.Padding = UDim.new(0,8)
    rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rightList.SortOrder = Enum.SortOrder.LayoutOrder
    rightList.Parent = rightContent
    local rightPad = Instance.new("UIPadding")
    rightPad.PaddingTop = UDim.new(0,10)
    rightPad.PaddingBottom = UDim.new(0,10)
    rightPad.PaddingLeft = UDim.new(0,10)
    rightPad.PaddingRight = UDim.new(0,10)
    rightPad.Parent = rightContent

    -- 通知系统
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0,250,0,50)
    notif.Position = UDim2.new(1,-260,0,10)
    notif.BackgroundColor3 = THEME.Secondary
    notif.BorderSizePixel = 0
    notif.Visible = false
    notif.ZIndex = 200
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", notif).Color = THEME.Accent
    createGradient(notif, THEME.Secondary, THEME.Primary, 90)
    local notifIcon = Instance.new("ImageLabel")
    notifIcon.Size = UDim2.new(0,30,0,30)
    notifIcon.Position = UDim2.new(0,10,0.5,-15)
    notifIcon.BackgroundTransparency = 1
    notifIcon.Image = "rbxassetid://8992230677"
    notifIcon.ZIndex = 201
    notifIcon.Parent = notif
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1,-50,1,-10)
    notifText.Position = UDim2.new(0,45,0,5)
    notifText.BackgroundTransparency = 1
    notifText.Text = SOUL.SETTINGS.NotificationText
    notifText.TextColor3 = THEME.Text
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 14
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextWrapped = true
    notifText.ZIndex = 201
    notifText.Parent = notif

    function SOUL.Notification:Show(msg, dur)
        notifText.Text = msg or SOUL.SETTINGS.NotificationText
        notif.Visible = true
        notif.Position = UDim2.new(1,10,0,10)
        tween(notif, {Position = UDim2.new(1,-260,0,10)}, 0.3)
        delay(dur or 3, function()
            tween(notif, {Position = UDim2.new(1,10,0,10)}, 0.3)
            wait(0.3)
            notif.Visible = false
        end)
    end

    local tabs = {}
    local currentTab = nil

    function SOUL:AddTab(tabName, iconId)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1,-10,0,40)
        tabBtn.BackgroundColor3 = THEME.Secondary
        tabBtn.Text = tabName
        tabBtn.TextColor3 = THEME.Text
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14
        tabBtn.Parent = leftBar
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,8)
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1,0,0,0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = rightContent
        local tabList = Instance.new("UIListLayout")
        tabList.Padding = UDim.new(0,5)
        tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Parent = tabContent

        tabBtn.MouseButton1Click:Connect(function()
            if currentTab then currentTab.Visible = false end
            tabContent.Visible = true
            currentTab = tabContent
            tween(tabBtn, {BackgroundColor3 = THEME.Accent}, 0.2)
            for _,b in ipairs(leftBar:GetChildren()) do
                if b:IsA("TextButton") and b ~= tabBtn then
                    tween(b, {BackgroundColor3 = THEME.Secondary}, 0.2)
                end
            end
        end)

        if #tabs == 0 then
            tabContent.Visible = true
            currentTab = tabContent
            tabBtn.BackgroundColor3 = THEME.Accent
        end

        local tabAPI = {}
        function tabAPI:AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-20,0,35)
            btn.BackgroundColor3 = THEME.Secondary
            btn.Text = text
            btn.TextColor3 = THEME.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = tabContent
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
            btn.MouseButton1Click:Connect(function()
                tween(btn, {BackgroundColor3 = THEME.Accent}, 0.1)
                wait(0.1)
                tween(btn, {BackgroundColor3 = THEME.Secondary}, 0.1)
                callback()
            end)
        end
        function tabAPI:AddToggle(text, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,40)
            frame.BackgroundColor3 = THEME.Secondary
            frame.Parent = tabContent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = THEME.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(0,40,0,20)
            toggle.Position = UDim2.new(1,-45,0.5,-10)
            toggle.BackgroundColor3 = default and THEME.Accent or THEME.Primary
            toggle.Text = ""
            toggle.Parent = frame
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)
            local state = default
            toggle.MouseButton1Click:Connect(function()
                state = not state
                tween(toggle, {BackgroundColor3 = state and THEME.Accent or THEME.Primary}, 0.15)
                callback(state)
            end)
        end
        function tabAPI:AddSlider(text, min, max, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,60)
            frame.BackgroundColor3 = THEME.Secondary
            frame.Parent = tabContent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,0,0,20)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. default
            label.TextColor3 = THEME.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.Parent = frame
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1,-20,0,4)
            slider.Position = UDim2.new(0,10,0,30)
            slider.BackgroundColor3 = THEME.Primary
            slider.Parent = frame
            Instance.new("UICorner", slider).CornerRadius = UDim.new(0,2)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = THEME.Accent
            fill.Parent = slider
            Instance.new("UICorner", fill).CornerRadius = UDim.new(0,2)
            local dragBtn = Instance.new("TextButton")
            dragBtn.Size = UDim2.new(0,12,0,12)
            dragBtn.Position = UDim2.new((default-min)/(max-min),-6,0.5,-6)
            dragBtn.BackgroundColor3 = THEME.AccentDark
            dragBtn.Text = ""
            dragBtn.Parent = slider
            Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1,0)
            local dragging = false
            dragBtn.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                    local val = min + (max - min) * pos
                    fill.Size = UDim2.new(pos,0,1,0)
                    dragBtn.Position = UDim2.new(pos,-6,0.5,-6)
                    label.Text = text .. ": " .. math.floor(val)
                    callback(math.floor(val))
                end
            end)
        end
        function tabAPI:AddInput(text, placeholder, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1,-20,0,45)
            frame.BackgroundColor3 = THEME.Secondary
            frame.Parent = tabContent
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,0,0,18)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = THEME.Text
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1,-10,0,20)
            box.Position = UDim2.new(0,5,0,22)
            box.BackgroundColor3 = THEME.Primary
            box.Text = placeholder or ""
            box.TextColor3 = THEME.Text
            box.Font = Enum.Font.Gotham
            box.TextSize = 12
            box.Parent = frame
            Instance.new("UICorner", box).CornerRadius = UDim.new(0,4)
            box.FocusLost:Connect(function(enter)
                if enter then callback(box.Text) end
            end)
        end
        function tabAPI:AddLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-20,0,25)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = THEME.TextSecondary
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.Parent = tabContent
        end
        return tabAPI
    end

    return SOUL
end

return SOUL