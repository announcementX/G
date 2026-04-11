local SOUL = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local TWEEN_PROPERTIES = {
    Style = Enum.EasingStyle.Quad,
    Direction = Enum.EasingDirection.Out,
    Time = 0.2
}

local THEME = {
    Primary = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 100, 150),
    AccentDark = Color3.fromRGB(200, 50, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(60, 60, 60),
    GradientStart = Color3.fromRGB(255, 80, 130),
    GradientEnd = Color3.fromRGB(255, 150, 180)
}

local SETTINGS = {
    WindowSize = UDim2.new(0, 350, 0, 500),
    NotificationText = "SOUL 已加载",
    LeftImageEnabled = false,
    LeftImageURL = "",
    MinimizedStyle = "Square",
    MinimizedSize = UDim2.new(0, 60, 0, 60),
    MinimizedText = "SOUL",
    MinimizedImage = "",
    MinimizedShape = "Square"
}

local function createGradient(parent, startColor, endColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor),
        ColorSequenceKeypoint.new(1, endColor)
    })
    gradient.Rotation = rotation or 45
    return gradient
end

local function tweenObject(obj, props, duration, callback)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or TWEEN_PROPERTIES.Time, TWEEN_PROPERTIES.Style, TWEEN_PROPERTIES.Direction), props)
    tween:Play()
    if callback then
        tween.Completed:Connect(callback)
    end
    return tween
end

local function createDragFunction(frame)
    local dragToggle, dragStart, startPos, dragInput
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            update(input)
        end
    end)
end

local function createScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SOUL_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            screenGui.Parent = playerGui
        else
            screenGui.Parent = CoreGui
        end
    end)
    
    return screenGui
end

local function createLoadingAnimation(parent)
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = THEME.Primary
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ZIndex = 100
    loadingFrame.Parent = parent
    
    local gradient = createGradient(loadingFrame, THEME.GradientStart, THEME.GradientEnd, 45)
    gradient.Parent = loadingFrame
    
    local soulIcon = Instance.new("ImageLabel")
    soulIcon.Size = UDim2.new(0, 80, 0, 80)
    soulIcon.Position = UDim2.new(0.5, -40, 0.4, -40)
    soulIcon.BackgroundTransparency = 1
    soulIcon.Image = "rbxassetid://8992230677"
    soulIcon.ZIndex = 101
    soulIcon.Parent = loadingFrame
    
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(0, 120, 0, 120)
    glow.Position = UDim2.new(0.5, -60, 0.4, -60)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://8992230677"
    glow.ImageColor3 = THEME.Accent
    glow.ImageTransparency = 0.5
    glow.ZIndex = 100
    glow.Parent = loadingFrame
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0.55, 0)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "SOUL"
    loadingText.TextColor3 = THEME.Text
    loadingText.Font = Enum.Font.GothamBold
    loadingText.TextSize = 24
    loadingText.ZIndex = 101
    loadingText.Parent = loadingFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 200, 0, 4)
    progressBar.Position = UDim2.new(0.5, -100, 0.65, 0)
    progressBar.BackgroundColor3 = THEME.Secondary
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 101
    progressBar.Parent = loadingFrame
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = THEME.Accent
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 102
    progressFill.Parent = progressBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = progressBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = progressFill
    
    local loading = {
        Frame = loadingFrame,
        Fill = progressFill,
        Icon = soulIcon,
        Glow = glow,
        Text = loadingText
    }
    
    spawn(function()
        while true do
            tweenObject(glow, {Rotation = 360}, 3)
            tweenObject(soulIcon, {Rotation = -360}, 3)
            wait(3)
        end
    end)
    
    for i = 0, 100, 2 do
        tweenObject(progressFill, {Size = UDim2.new(i / 100, 0, 1, 0)}, 0.02)
        wait(0.01)
    end
    
    return loading
end

local function createMinimizedWindow(parent, onExpand)
    local minimizedFrame = Instance.new("Frame")
    minimizedFrame.Size = SETTINGS.MinimizedSize
    minimizedFrame.Position = UDim2.new(0.8, 0, 0.1, 0)
    minimizedFrame.BackgroundColor3 = THEME.Primary
    minimizedFrame.BorderSizePixel = 0
    minimizedFrame.Visible = false
    minimizedFrame.Parent = parent
    
    local gradient = createGradient(minimizedFrame, THEME.GradientStart, THEME.GradientEnd, 45)
    gradient.Parent = minimizedFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = minimizedFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Accent
    stroke.Thickness = 2
    stroke.Parent = minimizedFrame
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -10, 1, -10)
    contentLabel.Position = UDim2.new(0, 5, 0, 5)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = SETTINGS.MinimizedText
    contentLabel.TextColor3 = THEME.Text
    contentLabel.Font = Enum.Font.GothamBold
    contentLabel.TextSize = 14
    contentLabel.TextWrapped = true
    contentLabel.Parent = minimizedFrame
    
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(1, -20, 1, -20)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = SETTINGS.MinimizedImage ~= "" and SETTINGS.MinimizedImage or "rbxassetid://8992230677"
    iconLabel.Visible = SETTINGS.MinimizedImage ~= ""
    iconLabel.Parent = minimizedFrame
    
    contentLabel.Visible = SETTINGS.MinimizedImage == ""
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = minimizedFrame
    clickDetector.MouseButton1Click:Connect(function()
        if onExpand then onExpand() end
    end)
    
    createDragFunction(minimizedFrame)
    
    local minimized = {
        Frame = minimizedFrame,
        Content = contentLabel,
        Icon = iconLabel,
        Corner = corner,
        Stroke = stroke,
        Gradient = gradient,
        
        UpdateShape = function(self, shape)
            SETTINGS.MinimizedShape = shape
            if shape == "Circle" then
                self.Corner.CornerRadius = UDim.new(1, 0)
            elseif shape == "Square" then
                self.Corner.CornerRadius = UDim.new(0, 0)
            elseif shape == "RoundedSquare" then
                self.Corner.CornerRadius = UDim.new(0, 12)
            elseif shape == "SoftRounded" then
                self.Corner.CornerRadius = UDim.new(0, 20)
            elseif shape == "Pill" then
                self.Corner.CornerRadius = UDim.new(1, 0)
            elseif shape == "Diamond" then
                self.Frame.Rotation = 45
                self.Content.Rotation = -45
                if self.Icon then self.Icon.Rotation = -45 end
            elseif shape == "Hexagon" then
                self.Corner.CornerRadius = UDim.new(0, 8)
            elseif shape == "Octagon" then
                self.Corner.CornerRadius = UDim.new(0, 6)
            else
                self.Corner.CornerRadius = UDim.new(0, 12)
            end
        end,
        
        SetText = function(self, text)
            SETTINGS.MinimizedText = text
            self.Content.Text = text
        end,
        
        SetImage = function(self, url)
            SETTINGS.MinimizedImage = url
            self.Icon.Image = url
            self.Icon.Visible = url ~= ""
            self.Content.Visible = url == ""
        end,
        
        SetSize = function(self, size)
            SETTINGS.MinimizedSize = size
            self.Frame.Size = size
        end,
        
        SetColor = function(self, primary, accent)
            self.Frame.BackgroundColor3 = primary
            self.Stroke.Color = accent
        end,
        
        SetGradient = function(self, startColor, endColor)
            self.Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, startColor),
                ColorSequenceKeypoint.new(1, endColor)
            })
        end,
        
        Show = function(self)
            self.Frame.Visible = true
            tweenObject(self.Frame, {Position = UDim2.new(0.8, 0, 0.1, 0), Size = SETTINGS.MinimizedSize}, 0.3)
        end,
        
        Hide = function(self)
            tweenObject(self.Frame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            self.Frame.Visible = false
        end
    }
    
    return minimized
end

local function createMainWindow(parent, minimized)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = SETTINGS.WindowSize
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = THEME.Primary
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = parent
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = THEME.Accent
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainFrame
    
    local gradient = createGradient(mainFrame, THEME.Primary, THEME.Secondary, 135)
    gradient.Parent = mainFrame
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = THEME.Secondary
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar
    
    local topGradient = createGradient(topBar, THEME.Secondary, THEME.Primary, 90)
    topGradient.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SOUL"
    titleLabel.TextColor3 = THEME.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = THEME.Accent
    closeButton.Text = "✕"
    closeButton.TextColor3 = THEME.Text
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    minimizeButton.BackgroundColor3 = THEME.Secondary
    minimizeButton.Text = "—"
    minimizeButton.TextColor3 = THEME.Text
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 18
    minimizeButton.Parent = topBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeButton
    
    createDragFunction(mainFrame)
    
    closeButton.MouseButton1Click:Connect(function()
        tweenObject(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.1)
        wait(0.1)
        
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainFrame.Visible = false
            parent:Destroy()
        end)
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        tweenObject(minimizeButton, {BackgroundColor3 = THEME.Accent}, 0.1)
        wait(0.1)
        tweenObject(minimizeButton, {BackgroundColor3 = THEME.Secondary}, 0.1)
        
        local minimizeTween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.8, 0, 0.1, 0)
        })
        minimizeTween:Play()
        minimizeTween.Completed:Connect(function()
            mainFrame.Visible = false
            if minimized then
                minimized:Show()
            end
        end)
    end)
    
    closeButton.MouseEnter:Connect(function()
        tweenObject(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.15)
    end)
    closeButton.MouseLeave:Connect(function()
        tweenObject(closeButton, {BackgroundColor3 = THEME.Accent}, 0.15)
    end)
    
    minimizeButton.MouseEnter:Connect(function()
        tweenObject(minimizeButton, {BackgroundColor3 = THEME.AccentDark}, 0.15)
    end)
    minimizeButton.MouseLeave:Connect(function()
        tweenObject(minimizeButton, {BackgroundColor3 = THEME.Secondary}, 0.15)
    end)
    
    local leftSidebar = Instance.new("ScrollingFrame")
    leftSidebar.Size = UDim2.new(0, 100, 1, -40)
    leftSidebar.Position = UDim2.new(0, 0, 0, 40)
    leftSidebar.BackgroundColor3 = THEME.Secondary
    leftSidebar.BorderSizePixel = 0
    leftSidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftSidebar.ScrollBarThickness = 2
    leftSidebar.ScrollBarImageColor3 = THEME.Accent
    leftSidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    leftSidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftSidebar.Parent = mainFrame
    
    local leftGradient = createGradient(leftSidebar, THEME.Secondary, THEME.Primary, 180)
    leftGradient.Parent = leftSidebar
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Padding = UDim.new(0, 5)
    sidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Parent = leftSidebar
    
    local leftImage = Instance.new("ImageLabel")
    leftImage.Size = UDim2.new(1, -20, 0, 80)
    leftImage.Position = UDim2.new(0, 10, 0, 10)
    leftImage.BackgroundTransparency = 1
    leftImage.Image = SETTINGS.LeftImageURL
    leftImage.Visible = SETTINGS.LeftImageEnabled
    leftImage.Parent = leftSidebar
    
    local rightContent = Instance.new("ScrollingFrame")
    rightContent.Size = UDim2.new(1, -100, 1, -40)
    rightContent.Position = UDim2.new(0, 100, 0, 40)
    rightContent.BackgroundColor3 = THEME.Primary
    rightContent.BorderSizePixel = 0
    rightContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightContent.ScrollBarThickness = 3
    rightContent.ScrollBarImageColor3 = THEME.Accent
    rightContent.ScrollingDirection = Enum.ScrollingDirection.Y
    rightContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    rightContent.Parent = mainFrame
    
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = rightContent
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = rightContent
    
    local window = {
        Frame = mainFrame,
        TopBar = topBar,
        Title = titleLabel,
        Close = closeButton,
        Minimize = minimizeButton,
        LeftSidebar = leftSidebar,
        RightContent = rightContent,
        ContentList = contentList,
        SidebarList = sidebarList,
        LeftImage = leftImage,
        Gradient = gradient,
        Corner = mainCorner,
        Stroke = mainStroke,
        Tabs = {},
        CurrentTab = nil,
        
        SetSize = function(self, size)
            SETTINGS.WindowSize = size
            self.Frame.Size = size
        end,
        
        SetTitle = function(self, title)
            self.Title.Text = title
        end,
        
        SetLeftImage = function(self, enabled, url)
            SETTINGS.LeftImageEnabled = enabled
            SETTINGS.LeftImageURL = url
            self.LeftImage.Visible = enabled
            if url ~= "" then
                self.LeftImage.Image = url
            end
        end,
        
        Show = function(self)
            self.Frame.Visible = true
            self.Frame.Size = UDim2.new(0, 0, 0, 0)
            tweenObject(self.Frame, {Size = SETTINGS.WindowSize}, 0.3)
        end,
        
        Hide = function(self)
            tweenObject(self.Frame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            self.Frame.Visible = false
        end
    }
    
    return window
end

local function createNotificationSystem(parent)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 250, 0, 50)
    notificationFrame.Position = UDim2.new(1, -260, 0, 10)
    notificationFrame.BackgroundColor3 = THEME.Secondary
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Visible = false
    notificationFrame.ZIndex = 200
    notificationFrame.Parent = parent
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notificationFrame
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = THEME.Accent
    notifStroke.Thickness = 1
    notifStroke.Parent = notificationFrame
    
    local notifGradient = createGradient(notificationFrame, THEME.Secondary, THEME.Primary, 90)
    notifGradient.Parent = notificationFrame
    
    local notifIcon = Instance.new("ImageLabel")
    notifIcon.Size = UDim2.new(0, 30, 0, 30)
    notifIcon.Position = UDim2.new(0, 10, 0.5, -15)
    notifIcon.BackgroundTransparency = 1
    notifIcon.Image = "rbxassetid://8992230677"
    notifIcon.ZIndex = 201
    notifIcon.Parent = notificationFrame
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -50, 1, -10)
    notifText.Position = UDim2.new(0, 45, 0, 5)
    notifText.BackgroundTransparency = 1
    notifText.Text = SETTINGS.NotificationText
    notifText.TextColor3 = THEME.Text
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 14
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextWrapped = true
    notifText.ZIndex = 201
    notifText.Parent = notificationFrame
    
    local notification = {
        Frame = notificationFrame,
        Text = notifText,
        Icon = notifIcon,
        
        Show = function(self, message, duration)
            self.Text.Text = message or SETTINGS.NotificationText
            self.Frame.Visible = true
            self.Frame.Position = UDim2.new(1, 10, 0, 10)
            
            tweenObject(self.Frame, {Position = UDim2.new(1, -260, 0, 10)}, 0.3)
            
            delay(duration or 3, function()
                tweenObject(self.Frame, {Position = UDim2.new(1, 10, 0, 10)}, 0.3)
                wait(0.3)
                self.Frame.Visible = false
            end)
        end,
        
        SetText = function(self, text)
            SETTINGS.NotificationText = text
            self.Text.Text = text
        end
    }
    
    return notification
end