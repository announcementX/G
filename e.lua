--[[
    XU 悬浮窗脚本
    作者: HaoChen
    QQ: 1626844714
    版本: 2.0
    特色: 可移动悬浮窗 | 多样式切换 | 北京时间显示 | 无卡密/白名单
]]

-- 加载动画函数
local function showLoadingAnimation()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XULoading"
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- 背景遮罩
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    bg.Parent = screenGui
    
    -- 加载主框
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 300, 0, 150)
    loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ClipsDescendants = true
    loadingFrame.Parent = screenGui
    
    -- 圆角处理
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = loadingFrame
    
    -- XU 标志
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 50)
    logo.Position = UDim2.new(0, 0, 0, 15)
    logo.BackgroundTransparency = 1
    logo.Text = "XU"
    logo.TextColor3 = Color3.fromRGB(255, 100, 150)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0.5
    logo.TextStrokeColor3 = Color3.fromRGB(255, 200, 220)
    logo.Parent = loadingFrame
    
    -- 加载文本
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0, 70)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "正在加载 XU 脚本..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextScaled = true
    loadingText.Font = Enum.Font.Gotham
    loadingText.Parent = loadingFrame
    
    -- 加载进度条
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(0.8, 0, 0, 8)
    progressBarBg.Position = UDim2.new(0.1, 0, 0, 110)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    progressBarBg.BorderSizePixel = 0
    progressBarBg.Parent = loadingFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBarBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBg
    
    local progressCorner2 = Instance.new("UICorner")
    progressCorner2.CornerRadius = UDim.new(1, 0)
    progressCorner2.Parent = progressBar
    
    -- 动画效果
    local progress = 0
    local tweenService = game:GetService("TweenService")
    
    local function animateProgress()
        progress = progress + 0.02
        if progress <= 1 then
            progressBar:TweenSize(UDim2.new(progress, 0, 1, 0), "Out", "Quad", 0.05)
            task.wait(0.05)
            animateProgress()
        else
            task.wait(0.5)
            screenGui:Destroy()
        end
    end
    
    animateProgress()
    
    return screenGui
end

-- 启动加载动画
showLoadingAnimation()
task.wait(1.5)

-- 等待玩家加载
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 主GUI
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "XUFloatingUI"
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.IgnoreGuiInset = true
mainGui.Parent = CoreGui

-- ========== 悬浮窗主框架 ==========
local floatingFrame = Instance.new("Frame")
floatingFrame.Size = UDim2.new(0, 320, 0, 480)
floatingFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
floatingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
floatingFrame.BorderSizePixel = 0
floatingFrame.ClipsDescendants = true
floatingFrame.Parent = mainGui

-- 主框架圆角
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = floatingFrame

-- 阴影效果
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = floatingFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 25)
shadowCorner.Parent = shadow

-- ========== 可拖动区域（左上角）==========
local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(0, 50, 0, 30)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
dragArea.BackgroundTransparency = 0.8
dragArea.Text = "⋮⋮"
dragArea.TextColor3 = Color3.fromRGB(255, 255, 255)
dragArea.TextScaled = true
dragArea.Font = Enum.Font.GothamBold
dragArea.AutoButtonColor = false
dragArea.Parent = floatingFrame

local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0, 10)
dragCorner.Parent = dragArea

-- 拖动功能变量
local dragging = false
local dragStartPos = nil
local frameStartPos = nil
local longPressActive = false
local pressTimer = nil

-- 长按检测
dragArea.MouseButton1Down:Connect(function()
    pressTimer = tick()
    longPressActive = false
end)

dragArea.MouseButton1Up:Connect(function()
    if pressTimer and (tick() - pressTimer) >= 0.5 and longPressActive == false then
        longPressActive = true
        -- 长按激活拖动
        dragging = true
        dragStartPos = UserInputService:GetMouseLocation()
        frameStartPos = floatingFrame.Position
    end
    pressTimer = nil
    task.wait(0.1)
    dragging = false
end)

-- 移动逻辑
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        floatingFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== 缩小化按钮 ==========
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Text = "✕"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.AutoButtonColor = true
minimizeBtn.Parent = floatingFrame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeBtn

local isMinimized = false
local originalSize = floatingFrame.Size
local originalPosition = floatingFrame.Position

-- 缩小化功能
minimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        -- 恢复原状
        floatingFrame:TweenSize(originalSize, "Out", "Quad", 0.3, true)
        floatingFrame:TweenPosition(originalPosition, "Out", "Quad", 0.3, true)
        for _, v in pairs(floatingFrame:GetChildren()) do
            if v:IsA("Frame") and v ~= dragArea and v ~= minimizeBtn and v ~= shadow then
                v.Visible = true
            end
        end
        isMinimized = false
    else
        -- 缩小为正方形
        local minimizedSize = UDim2.new(0, 60, 0, 60)
        local minimizedPos = UDim2.new(
            floatingFrame.Position.X.Scale,
            floatingFrame.Position.X.Offset,
            floatingFrame.Position.Y.Scale,
            floatingFrame.Position.Y.Offset
        )
        floatingFrame:TweenSize(minimizedSize, "Out", "Quad", 0.3, true)
        for _, v in pairs(floatingFrame:GetChildren()) do
            if v:IsA("Frame") and v ~= dragArea and v ~= minimizeBtn and v ~= shadow then
                v.Visible = false
            end
        end
        dragArea.Visible = true
        minimizeBtn.Visible = true
        isMinimized = true
    end
end)

-- 防误触：缩小状态下长按恢复
local minimizedDragTimer = nil
dragArea.MouseButton1Down:Connect(function()
    if isMinimized then
        minimizedDragTimer = tick()
    end
end)

dragArea.MouseButton1Up:Connect(function()
    if isMinimized and minimizedDragTimer and (tick() - minimizedDragTimer) >= 0.5 then
        minimizeBtn.MouseButton1Click:Fire()
    end
    minimizedDragTimer = nil
end)

-- ========== 顶部标题栏 + 北京时间 ==========
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.BorderSizePixel = 0
titleBar.Parent = floatingFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 100, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "XU PANEL"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- 北京时间显示
local beijingTime = Instance.new("TextLabel")
beijingTime.Size = UDim2.new(0, 150, 1, 0)
beijingTime.Position = UDim2.new(1, -160, 0, 0)
beijingTime.BackgroundTransparency = 1
beijingTime.Text = "00:00:00"
beijingTime.TextColor3 = Color3.fromRGB(200, 200, 200)
beijingTime.TextSize = 14
beijingTime.Font = Enum.Font.Gotham
beijingTime.TextXAlignment = Enum.TextXAlignment.Right
beijingTime.Parent = titleBar

-- 更新时间
local function updateBeijingTime()
    local time = os.date("!*t")
    local hour = (time.hour + 8) % 24
    beijingTime.Text = string.format("%02d:%02d:%02d", hour, time.min, time.sec)
end

updateBeijingTime()
task.spawn(function()
    while true do
        task.wait(1)
        updateBeijingTime()
    end
end)

-- ========== 侧边栏导航 ==========
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 70, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
sidebar.BorderSizePixel = 0
sidebar.Parent = floatingFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 15)
sidebarCorner.Parent = sidebar

-- 信息按钮
local infoBtn = Instance.new("TextButton")
infoBtn.Size = UDim2.new(0, 50, 0, 50)
infoBtn.Position = UDim2.new(0.5, -25, 0, 20)
infoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
infoBtn.Text = "ℹ️"
infoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBtn.TextScaled = true
infoBtn.Font = Enum.Font.GothamBold
infoBtn.Parent = sidebar

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 15)
infoCorner.Parent = infoBtn

-- 样式按钮
local styleBtn = Instance.new("TextButton")
styleBtn.Size = UDim2.new(0, 50, 0, 50)
styleBtn.Position = UDim2.new(0.5, -25, 0, 90)
styleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
styleBtn.Text = "🎨"
styleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
styleBtn.TextScaled = true
styleBtn.Font = Enum.Font.GothamBold
styleBtn.Parent = sidebar

local styleCorner = Instance.new("UICorner")
styleCorner.CornerRadius = UDim.new(0, 15)
styleCorner.Parent = styleBtn

-- ========== 内容区域 ==========
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -70, 1, -45)
contentArea.Position = UDim2.new(0, 70, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = floatingFrame

-- ========== 信息页面 ==========
local infoPage = Instance.new("Frame")
infoPage.Size = UDim2.new(1, -20, 1, -20)
infoPage.Position = UDim2.new(0, 10, 0, 10)
infoPage.BackgroundTransparency = 1
infoPage.Visible = true
infoPage.Parent = contentArea

-- 作者信息框（框框样式，内文字颜色深）
local authorBox = Instance.new("Frame")
authorBox.Size = UDim2.new(1, 0, 0, 100)
authorBox.Position = UDim2.new(0, 0, 0, 0)
authorBox.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
authorBox.BorderSizePixel = 0
authorBox.Parent = infoPage

local authorCorner = Instance.new("UICorner")
authorCorner.CornerRadius = UDim.new(0, 12)
authorCorner.Parent = authorBox

local authorText = Instance.new("TextLabel")
authorText.Size = UDim2.new(1, -20, 1, -10)
authorText.Position = UDim2.new(0, 10, 0, 5)
authorText.BackgroundTransparency = 1
authorText.Text = "作者：HaoChen\n\nQQ：1626844714"
authorText.TextColor3 = Color3.fromRGB(200, 180, 220)
authorText.TextSize = 16
authorText.Font = Enum.Font.Gotham
authorText.TextXAlignment = Enum.TextXAlignment.Left
authorText.TextYAlignment = Enum.TextYAlignment.Top
authorText.Parent = authorBox

-- XU标志展示框
local xuBox = Instance.new("Frame")
xuBox.Size = UDim2.new(1, 0, 0, 150)
xuBox.Position = UDim2.new(0, 0, 0, 115)
xuBox.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
xuBox.BorderSizePixel = 0
xuBox.Parent = infoPage

local xuCorner = Instance.new("UICorner")
xuCorner.CornerRadius = UDim.new(0, 12)
xuCorner.Parent = xuBox

local xuText = Instance.new("TextLabel")
xuText.Size = UDim2.new(1, -20, 1, -10)
xuText.Position = UDim2.new(0, 10, 0, 5)
xuText.BackgroundTransparency = 1
xuText.Text = "━━━━━━━━━━━━━━━━\n        ✨ XU ✨\n   炫酷悬浮窗系统\n━━━━━━━━━━━━━━━━"
xuText.TextColor3 = Color3.fromRGB(255, 150, 200)
xuText.TextSize = 18
xuText.Font = Enum.Font.GothamBold
xuText.TextXAlignment = Enum.TextXAlignment.Center
xuText.TextYAlignment = Enum.TextYAlignment.Center
xuText.Parent = xuBox

-- 说明框
local descBox = Instance.new("Frame")
descBox.Size = UDim2.new(1, 0, 0, 120)
descBox.Position = UDim2.new(0, 0, 0, 280)
descBox.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
descBox.BorderSizePixel = 0
descBox.Parent = infoPage

local descCorner = Instance.new("UICorner")
descCorner.CornerRadius = UDim.new(0, 12)
descCorner.Parent = descBox

local descText = Instance.new("TextLabel")
descText.Size = UDim2.new(1, -20, 1, -10)
descText.Position = UDim2.new(0, 10, 0, 5)
descText.BackgroundTransparency = 1
descText.Text = "使用说明：\n• 长按左上角「⋮⋮」可移动窗口\n• 点击「✕」缩小为悬浮球\n• 缩小后长按可恢复\n• 侧边栏切换页面"
descText.TextColor3 = Color3.fromRGB(180, 180, 200)
descText.TextSize = 14
descText.Font = Enum.Font.Gotham
descText.TextXAlignment = Enum.TextXAlignment.Left
descText.TextYAlignment = Enum.TextYAlignment.Top
descText.Parent = descBox

-- ========== 样式页面 ==========
local stylePage = Instance.new("Frame")
stylePage.Size = UDim2.new(1, -20, 1, -20)
stylePage.Position = UDim2.new(0, 10, 0, 10)
stylePage.BackgroundTransparency = 1
stylePage.Visible = false
stylePage.Parent = contentArea

-- 样式预设
local styles = {
    {
        name = "✨ 炫光紫 ✨",
        bgColor = Color3.fromRGB(25, 20, 45),
        titleColor = Color3.fromRGB(100, 50, 150),
        accentColor = Color3.fromRGB(180, 80, 220),
        textColor = Color3.fromRGB(220, 180, 255),
        layout = "default"
    },
    {
        name = "🌊 深海蓝 🌊",
        bgColor = Color3.fromRGB(20, 35, 60),
        titleColor = Color3.fromRGB(30, 100, 180),
        accentColor = Color3.fromRGB(50, 150, 220),
        textColor = Color3.fromRGB(150, 200, 255),
        layout = "dark"
    },
    {
        name = "🔥 烈焰红 🔥",
        bgColor = Color3.fromRGB(50, 20, 25),
        titleColor = Color3.fromRGB(180, 50, 50),
        accentColor = Color3.fromRGB(220, 80, 80),
        textColor = Color3.fromRGB(255, 150, 150),
        layout = "dark"
    },
    {
        name = "🌿 翡翠绿 🌿",
        bgColor = Color3.fromRGB(25, 45, 30),
        titleColor = Color3.fromRGB(50, 130, 80),
        accentColor = Color3.fromRGB(80, 180, 120),
        textColor = Color3.fromRGB(150, 220, 180),
        layout = "default"
    },
    {
        name: "💎 极简白 💎",
        bgColor = Color3.fromRGB(45, 45, 55),
        titleColor = Color3.fromRGB(100, 100, 120),
        accentColor = Color3.fromRGB(200, 200, 220),
        textColor = Color3.fromRGB(255, 255, 255),
        layout = "light"
    }
}

local styleButtons = {}
local currentStyle = 1

-- 应用样式函数
local function applyStyle(styleIndex)
    local style = styles[styleIndex]
    if not style then return end
    
    -- 切换主背景色
    floatingFrame.BackgroundColor3 = style.bgColor
    
    -- 切换标题栏颜色
    titleBar.BackgroundColor3 = style.titleColor
    
    -- 切换侧边栏颜色
    sidebar.BackgroundColor3 = Color3.fromRGB(
        style.titleColor.R * 0.7,
        style.titleColor.G * 0.7,
        style.titleColor.B * 0.7
    )
    
    -- 切换强调色（按钮等）
    dragArea.BackgroundColor3 = style.accentColor
    minimizeBtn.BackgroundColor3 = style.accentColor
    infoBtn.BackgroundColor3 = style.accentColor
    styleBtn.BackgroundColor3 = style.accentColor
    
    -- 切换文字颜色
    for _, btn in pairs(styleButtons) do
        if btn then
            btn.TextColor3 = style.textColor
        end
    end
    
    -- 根据布局切换排版
    if style.layout == "dark" then
        -- 深色布局：更紧凑
        contentArea.BackgroundTransparency = 0.9
        for _, box in pairs(infoPage:GetChildren()) do
            if box:IsA("Frame") then
                box.BackgroundTransparency = 0.3
            end
        end
    elseif style.layout == "light" then
        -- 亮色布局：更通透
        contentArea.BackgroundTransparency = 0.95
        for _, box in pairs(infoPage:GetChildren()) do
            if box:IsA("Frame") then
                box.BackgroundTransparency = 0.2
                box.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            end
        end
    else
        -- 默认布局
        contentArea.BackgroundTransparency = 1
        for _, box in pairs(infoPage:GetChildren()) do
            if box:IsA("Frame") then
                box.BackgroundTransparency = 0
                box.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            end
        end
    end
end

-- 创建样式按钮
local function createStyleButtons()
    local buttonHeight = 60
    local spacing = 10
    local startY = 10
    
    for i, style in ipairs(styles) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, buttonHeight)
        btn.Position = UDim2.new(0, 10, 0, startY + (i-1) * (buttonHeight + spacing))
        btn.BackgroundColor3 = Color3.fromRGB(65, 65, 80)
        btn.Text = style.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.Parent = stylePage
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn
        
        -- 按钮悬停效果
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(85, 85, 105)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 80)}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            currentStyle = i
            applyStyle(i)
            -- 按钮点击反馈
            btn.TextTransparency = 0.5
            task.wait(0.1)
            btn.TextTransparency = 0
        end)
        
        styleButtons[i] = btn
    end
end

createStyleButtons()

-- 添加滚动功能（如果按钮太多）
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #styles * 70 + 20)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 180)
scrollingFrame.Parent = stylePage

-- 将按钮移到滚动框内
for _, btn in pairs(styleButtons) do
    btn.Parent = scrollingFrame
end

-- 页面切换逻辑
infoBtn.MouseButton1Click:Connect(function()
    infoPage.Visible = true
    stylePage.Visible = false
    infoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    styleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
end)

styleBtn.MouseButton1Click:Connect(function()
    infoPage.Visible = false
    stylePage.Visible = true
    styleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    infoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
end)

-- 应用默认样式
applyStyle(1)

-- 炫酷入场动画
floatingFrame.Position = UDim2.new(0.5, -160, 0, -500)
TweenService:Create(floatingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -160, 0.5, -240)
}):Play()

-- 控制台输出
print("XU 悬浮窗脚本已加载 | 作者: HaoChen | QQ: 1626844714")

-- 返回主GUI供其他脚本调用
return mainGui