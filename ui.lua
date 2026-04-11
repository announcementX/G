--[[
    SOUL UI Library v3.0 - "Cyber Essence"
    核心改进：独立拖拽引擎、Canvas切换系统、全渐变渲染
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // 顶级配色 (根据你的要求：渐变粉色调) // --
local Theme = {
    Background = Color3.fromRGB(255, 240, 245), -- 极淡粉
    DeepPink = Color3.fromRGB(255, 140, 180),  -- 渐变深处
    Accent = Color3.fromRGB(255, 80, 150),     -- 灵魂色
    Text = Color3.fromRGB(80, 60, 70)
}

-- // 核心动画函数 // --
local function Tween(obj, time, prop, style)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

-- // 独立拖拽引擎 (支持所有组件) // --
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    obj.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function SOUL_Lib.new(projectName)
    local self = setmetatable({}, SOUL_Lib)
    self.Tabs = {}
    self.CurrentTab = nil

    -- 1. 根容器
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SOUL_V3"
    self.Gui.Parent = CoreGui

    -- 2. 悬浮球 (预设隐藏)
    self.MiniBall = Instance.new("TextButton")
    self.MiniBall.Size = UDim2.new(0, 60, 0, 60)
    self.MiniBall.Position = UDim2.new(0.1, 0, 0.5, 0)
    self.MiniBall.BackgroundColor3 = Theme.Accent
    self.MiniBall.Text = "魂"
    self.MiniBall.TextColor3 = Color3.new(1,1,1)
    self.MiniBall.Font = Enum.Font.GothamBold
    self.MiniBall.Visible = false
    self.MiniBall.Parent = self.Gui
    Instance.new("UICorner", self.MiniBall).CornerRadius = UDim.new(1, 0)
    MakeDraggable(self.MiniBall)

    -- 3. 主窗口
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 560, 0, 360)
    self.Main.Position = UDim2.new(0.5, -280, 0.5, -180)
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Visible = false
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 24)
    MakeDraggable(self.Main)

    -- 4. 全屏渐变层 (上下 45px 融合效果)
    local function AddGradientBar(pos, size, rotation)
        local bar = Instance.new("Frame")
        bar.Size = size
        bar.Position = pos
        bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0
        bar.ZIndex = 5
        bar.Parent = self.Main
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Theme.DeepPink, Theme.Background)
        g.Transparency = NumberSequence.new(0, 1)
        g.Rotation = rotation
        g.Parent = bar
        return bar
    end

    self.TopBar = AddGradientBar(UDim2.new(0,0,0,0), UDim2.new(1,0,0,50), 90)
    self.BottomBar = AddGradientBar(UDim2.new(0,0,1,-50), UDim2.new(1,0,0,50), -90)

    -- 5. 侧边栏渐变背景
    self.SidebarBg = Instance.new("Frame")
    self.SidebarBg.Size = UDim2.new(0, 160, 1, 0)
    self.SidebarBg.BackgroundColor3 = Color3.fromRGB(255, 210, 225)
    self.SidebarBg.BorderSizePixel = 0
    self.SidebarBg.ZIndex = 2
    self.SidebarBg.Parent = self.Main
    local sg = Instance.new("UIGradient")
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.9, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    sg.Parent = self.SidebarBg

    -- 6. 交互组件
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 50)
    title.Position = UDim2.new(0, 25, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = projectName
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Theme.Text
    title.TextSize = 18
    title.ZIndex = 6
    title.Parent = self.Main

    -- 关闭与缩小按钮
    local function CreateControl(text, color, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(1, x, 0, 10)
        b.BackgroundColor3 = color
        b.BackgroundTransparency = 0.5
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.ZIndex = 6
        b.Parent = self.Main
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        return b
    end

    local closeBtn = CreateControl("×", Color3.fromRGB(255, 100, 100), -40)
    local minBtn = CreateControl("-", Theme.Accent, -80)

    -- 7. 容器系统
    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Size = UDim2.new(0, 140, 1, -110)
    self.TabList.Position = UDim2.new(0, 10, 0, 60)
    self.TabList.BackgroundTransparency = 1
    self.TabList.BorderSizePixel = 0
    self.TabList.CanvasSize = UDim2.new(0,0,0,0)
    self.TabList.ScrollBarThickness = 0
    self.TabList.ZIndex = 6
    self.TabList.Parent = self.Main
    Instance.new("UIListLayout", self.TabList).Padding = UDim.new(0, 10)

    self.ContainerHolder = Instance.new("Frame")
    self.ContainerHolder.Size = UDim2.new(1, -190, 1, -120)
    self.ContainerHolder.Position = UDim2.new(0, 170, 0, 60)
    self.ContainerHolder.BackgroundTransparency = 1
    self.ContainerHolder.ZIndex = 6
    self.ContainerHolder.Parent = self.Main

    -- // 动画逻辑重构 // --
    minBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.6, {Size = UDim2.new(0,0,0,0), Position = self.MiniBall.Position, Rotation = 45, BackgroundTransparency = 1}, Enum.EasingStyle.Back)
        task.wait(0.5)
        self.Main.Visible = false
        self.MiniBall.Visible = true
        Tween(self.MiniBall, 0.6, {Size = UDim2.new(0, 60, 0, 60)}, Enum.EasingStyle.Elastic)
    end)

    self.MiniBall.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.MiniBall.Visible = false
        self.Main.BackgroundTransparency = 0
        self.Main.Rotation = 0
        Tween(self.Main, 0.8, {Size = UDim2.new(0, 560, 0, 360), Position = UDim2.new(0.5, -280, 0.5, -180)}, Enum.EasingStyle.Elastic)
    end)

    return self
end

-- // 顶级栏目切换逻辑 // --
function SOUL_Lib:CreateTab(name)
    local tab = {}
    
    -- 按钮
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundTransparency = 0.9
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.ZIndex = 7
    btn.Parent = self.TabList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    -- 容器 (CanvasGroup 确保淡入淡出完美)
    local group = Instance.new("CanvasGroup")
    group.Size = UDim2.new(1, 0, 1, 0)
    group.BackgroundTransparency = 1
    group.GroupTransparency = 1
    group.Visible = false
    group.Parent = self.ContainerHolder

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.Parent = group
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tab.Group = group
    tab.Scroll = scroll

    -- 切换函数
    btn.MouseButton1Click:Connect(function()
        if self.CurrentTab == tab then return end
        
        -- 隐藏旧的
        if self.CurrentTab then
            local old = self.CurrentTab
            Tween(old.Group, 0.3, {GroupTransparency = 1, Position = UDim2.new(0, 20, 0, 0)})
            task.delay(0.3, function() old.Group.Visible = false end)
        end
        
        -- 显示新的
        self.CurrentTab = tab
        group.Visible = true
        group.Position = UDim2.new(0, -20, 0, 0)
        Tween(group, 0.4, {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self.CurrentTab = tab
        group.Visible = true
        group.GroupTransparency = 0
    end

    return tab
end

-- // 组件: 按钮 // --
function SOUL_Lib:AddButton(tab, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 45)
    b.BackgroundColor3 = Color3.new(1,1,1)
    b.BackgroundTransparency = 0.3
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.Gotham
    b.Parent = tab.Scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)

    b.MouseButton1Click:Connect(function()
        Tween(b, 0.1, {Size = UDim2.new(0.9, 0, 0, 40)})
        task.wait(0.1)
        Tween(b, 0.1, {Size = UDim2.new(0.95, 0, 0, 45)})
        callback()
    end)
    
    tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 20)
end

-- // 开场动画: 灵魂震荡 // --
function SOUL_Lib:Show()
    local core = Instance.new("Frame")
    core.Size = UDim2.new(0, 10, 0, 10)
    core.Position = UDim2.new(0.5, 0, 0.5, 0)
    core.BackgroundColor3 = Theme.Accent
    core.Parent = self.Gui
    Instance.new("UICorner", core).CornerRadius = UDim.new(1, 0)

    -- 核心爆破
    Tween(core, 1, {Size = UDim2.new(0, 150, 0, 150), Position = UDim2.new(0.5, -75, 0.5, -75), BackgroundTransparency = 1}, Enum.EasingStyle.Elastic)
    task.wait(0.3)
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, 1, {Size = UDim2.new(0, 560, 0, 360), Position = UDim2.new(0.5, -280, 0.5, -180)}, Enum.EasingStyle.Elastic)
    task.wait(1)
    core:Destroy()
end

return SOUL_Lib
