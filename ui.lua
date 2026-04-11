--[[
    XINGYUN UI Library v8.0 - "Ultimate Flare"
    功能：原点爆发展开、黑洞坍缩关闭、图文弹窗通知、全能输入框、百变悬浮图标
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 全新 XINGYUN 赛博暗黑主题
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(10, 10, 15),
    Accent = Color3.fromRGB(0, 150, 255), -- 科技蓝
    Text = Color3.fromRGB(240, 240, 240),
    DarkText = Color3.fromRGB(150, 150, 150),
    ElementBg = Color3.fromRGB(25, 25, 30)
}

local function Tween(obj, time, prop, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), prop)
    t:Play()
    return t
end

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // 初始化窗口 //
-- miniConfig 参数支持: {Radius = 圆角大小, Color = 背景色, Text = 文本, Image = 图片ID}
function SOUL_Lib.new(projectName, miniConfig)
    local self = setmetatable({}, SOUL_Lib)
    self.Tabs = {}
    miniConfig = miniConfig or {Radius = 12, Color = Theme.Accent, Text = "X", Image = ""}

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "XINGYUN_V8"
    self.Gui.Parent = CoreGui

    -- // 右下角通知容器 //
    self.NotifyFrame = Instance.new("Frame")
    self.NotifyFrame.Size = UDim2.new(0, 300, 1, 0)
    self.NotifyFrame.Position = UDim2.new(1, -320, 0, 0)
    self.NotifyFrame.BackgroundTransparency = 1
    self.NotifyFrame.Parent = self.Gui
    local notifyLayout = Instance.new("UIListLayout", self.NotifyFrame)
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.Padding = UDim.new(0, 10)

    -- // 悬浮窗 (百变形态) //
    self.Mini = Instance.new("TextButton")
    self.Mini.Size = UDim2.new(0, 50, 0, 50)
    self.Mini.Position = UDim2.new(0.05, 0, 0.2, 0)
    self.Mini.BackgroundColor3 = miniConfig.Color
    self.Mini.Text = miniConfig.Image == "" and (miniConfig.Text or "") or ""
    self.Mini.Font = Enum.Font.GothamBold
    self.Mini.TextSize = 20
    self.Mini.TextColor3 = Color3.new(1,1,1)
    self.Mini.Visible = false
    self.Mini.Parent = self.Gui
    self.MiniCorner = Instance.new("UICorner", self.Mini)
    self.MiniCorner.CornerRadius = UDim.new(0, miniConfig.Radius)
    
    if miniConfig.Image and miniConfig.Image ~= "" then
        local img = Instance.new("ImageLabel", self.Mini)
        img.Size = UDim2.new(0.8, 0, 0.8, 0)
        img.Position = UDim2.new(0.1, 0, 0.1, 0)
        img.BackgroundTransparency = 1
        img.Image = miniConfig.Image
    end
    MakeDraggable(self.Mini)

    -- // 主窗口 //
    self.Main = Instance.new("CanvasGroup")
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- 初始大小为0
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- 居中
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.Visible = false
    self.Main.GroupTransparency = 1
    self.Main.Parent = self.Gui
    self.MainCorner = Instance.new("UICorner", self.Main)
    self.MainCorner.CornerRadius = UDim.new(1, 0) -- 初始为纯圆
    MakeDraggable(self.Main)

    -- 侧边栏
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 130, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 18)

    -- 标题
    local Title = Instance.new("TextLabel", self.Main)
    Title.Size = UDim2.new(0, 200, 0, 45)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = projectName
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- 控制按钮 (纯代码绘制)
    local function CreateDrawBtn(typeStr, xOffset)
        local btn = Instance.new("TextButton", self.Main)
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.Position = UDim2.new(1, xOffset, 0, 2)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 10
        if typeStr == "Close" then
            local l1 = Instance.new("Frame", btn) l1.Size = UDim2.new(0, 14, 0, 2) l1.Position = UDim2.new(0.5, -7, 0.5, -1) l1.BackgroundColor3 = Theme.DarkText l1.Rotation = 45 l1.BorderSizePixel = 0
            local l2 = l1:Clone() l2.Rotation = -45 l2.Parent = btn
        else
            local l = Instance.new("Frame", btn) l.Size = UDim2.new(0, 14, 0, 2) l.Position = UDim2.new(0.5, -7, 0.5, -1) l.BackgroundColor3 = Theme.DarkText l.BorderSizePixel = 0
        end
        return btn
    end
    local closeBtn = CreateDrawBtn("Close", -45)
    local minBtn = CreateDrawBtn("Min", -85)

    -- 容器
    self.TabHolder = Instance.new("ScrollingFrame", self.Main)
    self.TabHolder.Size = UDim2.new(0, 110, 1, -100)
    self.TabHolder.Position = UDim2.new(0, 10, 0, 55)
    self.TabHolder.BackgroundTransparency = 1
    self.TabHolder.ScrollBarThickness = 0
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 5)

    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(1, -150, 1, -70)
    self.Container.Position = UDim2.new(0, 140, 0, 60)
    self.Container.BackgroundTransparency = 1

    -- // 动画逻辑 //
    
    -- 牛逼的缩小动画 (吸入悬浮窗)
    minBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = false end -- 瞬间隐藏内部
        Tween(self.Main, 0.5, {Size = self.Mini.Size, Position = self.Mini.Position, BackgroundColor3 = miniConfig.Color}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Tween(self.MainCorner, 0.5, {CornerRadius = self.MiniCorner.CornerRadius})
        task.wait(0.45)
        self.Main.Visible = false
        self.Mini.Visible = true
    end)

    -- 牛逼的展开动画 (悬浮窗爆发)
    self.Mini.MouseButton1Click:Connect(function()
        self.Mini.Visible = false
        self.Main.Position = self.Mini.Position
        self.Main.Size = self.Mini.Size
        self.Main.BackgroundColor3 = miniConfig.Color
        self.Main.Visible = true
        
        Tween(self.Main, 0.7, {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175), BackgroundColor3 = Theme.Background}, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        Tween(self.MainCorner, 0.7, {CornerRadius = UDim.new(0, 12)})
        
        task.wait(0.2)
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = true end
    end)

    -- 牛逼的关闭动画 (中心黑洞坍缩)
    closeBtn.MouseButton1Click:Connect(function()
        local cx = self.Main.Position.X.Offset + (self.Main.Size.X.Offset / 2)
        local cy = self.Main.Position.Y.Offset + (self.Main.Size.Y.Offset / 2)
        Tween(self.MainCorner, 0.4, {CornerRadius = UDim.new(1, 0)}) -- 变圆
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, cx, 0.5, cy), GroupTransparency = 1, Rotation = 180}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        self.Gui:Destroy()
    end)

    return self
end

-- // 通知弹窗 (支持图文) //
function SOUL_Lib:Notify(cfg)
    local title = cfg.Title or "通知"
    local text = cfg.Text or ""
    local icon = cfg.Icon or ""
    local duration = cfg.Duration or 3

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 60)
    f.BackgroundColor3 = Theme.ElementBg
    f.BackgroundTransparency = 1
    f.Parent = self.NotifyFrame
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local txtOffset = 15
    if icon ~= "" then
        local img = Instance.new("ImageLabel", f)
        img.Size = UDim2.new(0, 30, 0, 30)
        img.Position = UDim2.new(0, 10, 0.5, -15)
        img.BackgroundTransparency = 1
        img.Image = icon
        txtOffset = 50
    end

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -txtOffset-10, 0, 20)
    t.Position = UDim2.new(0, txtOffset, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = Theme.Accent
    t.TextXAlignment = Enum.TextXAlignment.Left

    local d = Instance.new("TextLabel", f)
    d.Size = UDim2.new(1, -txtOffset-10, 0, 20)
    d.Position = UDim2.new(0, txtOffset, 0, 30)
    d.BackgroundTransparency = 1
    d.Text = text
    d.Font = Enum.Font.Gotham
    d.TextColor3 = Theme.Text
    d.TextXAlignment = Enum.TextXAlignment.Left

    -- 划入动画
    f.Position = UDim2.new(1, 50, 0, 0)
    Tween(f, 0.4, {BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0)})
    
    task.spawn(function()
        task.wait(duration)
        Tween(f, 0.4, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)})
        task.wait(0.4)
        f:Destroy()
    end)
end

function SOUL_Lib:CreateTab(name)
    local tab = {}
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.DarkText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14

    local scroll = Instance.new("ScrollingFrame", self.Container)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.Visible = false
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    
    tab.Scroll = scroll
    tab.Btn = btn

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Scroll.Visible = false
            Tween(t.Btn, 0.2, {TextColor3 = Theme.DarkText})
        end
        scroll.Visible = true
        Tween(btn, 0.2, {TextColor3 = Theme.Accent})
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        scroll.Visible = true
        btn.TextColor3 = Theme.Accent
    end
    return tab
end

-- // 信息显示 //
function SOUL_Lib:AddParagraph(tab, titleText, descText)
    local f = Instance.new("Frame", tab.Scroll)
    f.Size = UDim2.new(0.98, 0, 0, 0)
    f.BackgroundColor3 = Theme.ElementBg
    f.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 5)
    local pad = Instance.new("UIPadding", f)
    pad.PaddingTop = UDim.new(0, 10) pad.PaddingBottom = UDim.new(0, 10) pad.PaddingLeft = UDim.new(0, 10)

    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Theme.Accent
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    local desc = Instance.new("TextLabel", f)
    desc.Size = UDim2.new(1, 0, 0, 0)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = Theme.Text
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.AutomaticSize = Enum.AutomaticSize.Y
    
    task.spawn(function() task.wait(0.05) tab.Scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20) end)
end

-- // 普通按钮 //
function SOUL_Lib:AddButton(tab, text, callback)
    local b = Instance.new("TextButton", tab.Scroll)
    b.Size = UDim2.new(0.98, 0, 0, 36)
    b.BackgroundColor3 = Theme.ElementBg
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        Tween(b, 0.1, {BackgroundColor3 = Theme.Accent})
        task.wait(0.1)
        Tween(b, 0.1, {BackgroundColor3 = Theme.ElementBg})
        callback()
    end)
    task.spawn(function() task.wait(0.05) tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 20) end)
end

-- // 开关 (滑动Toggle) //
function SOUL_Lib:AddToggle(tab, text, callback)
    local state = false
    local bg = Instance.new("TextButton", tab.Scroll)
    bg.Size = UDim2.new(0.98, 0, 0, 36)
    bg.BackgroundColor3 = Theme.ElementBg
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local track = Instance.new("Frame", bg)
    track.Size = UDim2.new(0, 40, 0, 20)
    track.Position = UDim2.new(1, -50, 0.5, -10)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", track)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    bg.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Tween(track, 0.2, {BackgroundColor3 = Theme.Accent})
            Tween(dot, 0.2, {Position = UDim2.new(1, -18, 0.5, -8)})
        else
            Tween(track, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)})
            Tween(dot, 0.2, {Position = UDim2.new(0, 2, 0.5, -8)})
        end
        callback(state)
    end)
    task.spawn(function() task.wait(0.05) tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 20) end)
end

-- // 输入执行框 (TextBox) //
function SOUL_Lib:AddInput(tab, text, placeholder, callback)
    local bg = Instance.new("Frame", tab.Scroll)
    bg.Size = UDim2.new(0.98, 0, 0, 40)
    bg.BackgroundColor3 = Theme.ElementBg
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    
    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox", bg)
    box.Size = UDim2.new(0.4, 0, 0.7, 0)
    box.Position = UDim2.new(0.6, -10, 0.15, 0)
    box.BackgroundColor3 = Theme.Sidebar
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Gotham
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and box.Text ~= "" then
            callback(box.Text)
        end
    end)
    task.spawn(function() task.wait(0.05) tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 20) end)
end

-- // 原点爆发启动动画 //
function SOUL_Lib:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.GroupTransparency = 0
    self.MainCorner.CornerRadius = UDim.new(1, 0) -- 极小圆点
    
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 500, 0, 350)}, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    task.wait(0.1)
    Tween(self.MainCorner, 0.6, {CornerRadius = UDim.new(0, 12)})
end

return SOUL_Lib
