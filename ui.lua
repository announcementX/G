--[[
    SOUL UI Library v11.0 - "PURE VECTOR"
    - 配色：极致淡粉色 (Sakura Pink)
    - 绘制：纯代码绘制缩小横杠 (非文本)，增大点击热区。
    - 动画：中心爆发加载 / 中心坍缩缩小 / 中心坍缩关闭
    - 组件：信息栏、滑动开关、输入框、右下角图文提示
]]

local SOUL = {}
SOUL.__index = SOUL

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Main = Color3.fromRGB(255, 182, 193), -- 淡粉色
    Bg = Color3.fromRGB(15, 15, 18),     
    Element = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(255, 255, 255)
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
            dragging = true dragStart = input.Position startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) dragging = false end)
end

function SOUL.new(projName, miniConfig)
    local self = setmetatable({}, SOUL)
    self.Gui = Instance.new("ScreenGui", CoreGui)
    self.Gui.Name = "SOUL_PERFECT"
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- // 右下角提示容器 //
    self.NotifyArea = Instance.new("Frame", self.Gui)
    self.NotifyArea.Size = UDim2.new(0, 300, 1, 0)
    self.NotifyArea.Position = UDim2.new(1, -310, 0, 0)
    self.NotifyArea.BackgroundTransparency = 1
    local nl = Instance.new("UIListLayout", self.NotifyArea)
    nl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    nl.Padding = UDim.new(0, 10)

    -- // 悬浮窗配置 (出现在中心) //
    miniConfig = miniConfig or {Radius = 100, Color = Theme.Main, Text = "S", Image = ""}
    self.Mini = Instance.new("TextButton", self.Gui)
    self.Mini.Size = UDim2.new(0, 55, 0, 55)
    self.Mini.Position = UDim2.new(0.5, -27, 0.5, -27) -- 严格中心
    self.Mini.BackgroundColor3 = miniConfig.Color
    self.Mini.Text = (miniConfig.Image == "") and miniConfig.Text or ""
    self.Mini.TextColor3 = Color3.new(1,1,1)
    self.Mini.Font = "GothamBold"
    self.Mini.TextSize = 20
    self.Mini.Visible = false
    self.Mini.ZIndex = 10 -- 确保在顶层
    Instance.new("UICorner", self.Mini).CornerRadius = UDim.new(0, miniConfig.Radius)
    
    if miniConfig.Image ~= "" then
        local img = Instance.new("ImageLabel", self.Mini)
        img.Size = UDim2.new(0.7,0,0.7,0) img.Position = UDim2.new(0.15,0,0.15,0) img.Image = miniConfig.Image img.BackgroundTransparency = 1
    end
    MakeDraggable(self.Mini)

    -- // 主界面 (中心爆发动画) //
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0,0,0,0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.BackgroundColor3 = Theme.Bg
    self.Main.Visible = false
    self.Main.GroupTransparency = 1
    self.Main.ZIndex = 5
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 15)
    MakeDraggable(self.Main)

    -- 标题与控制
    local Top = Instance.new("Frame", self.Main)
    Top.Size = UDim2.new(1, 0, 0, 50) Top.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(0, 200, 1, 0) Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = projName Title.TextColor3 = Theme.Main Title.Font = "GothamBold" Title.TextSize = 18 Title.TextXAlignment = "Left" Title.BackgroundTransparency = 1

    -- 关闭按钮 (×)
    local CloseBtn = Instance.new("TextButton", Top)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40) CloseBtn.Position = UDim2.new(1, -45, 0, 5) CloseBtn.Text = "×" CloseBtn.TextColor3 = Theme.Main CloseBtn.TextSize = 26 CloseBtn.BackgroundTransparency = 1

    -- // 狠活：纯代码绘制缩小横杠 //
    -- 这是一个透明的按钮，用来做点击热区
    local MinHandle = Instance.new("TextButton", Top)
    MinHandle.Size = UDim2.new(0, 40, 0, 40) MinHandle.Position = UDim2.new(1, -85, 0, 5) MinHandle.Text = "" MinHandle.BackgroundTransparency = 1

    -- 这是画出来的横杠
    local MinDraw = Instance.new("Frame", MinHandle)
    MinDraw.Size = UDim2.new(0, 16, 0, 2) -- 16像素宽，2像素高
    MinDraw.Position = UDim2.new(0.5, -8, 0.5, -1) -- 居中
    MinDraw.BackgroundColor3 = Theme.Main -- 淡粉色
    MinDraw.BorderSizePixel = 0
    MinDraw.ZIndex = 2 -- 确保在按钮上层

    -- 侧边栏
    self.TabHolder = Instance.new("ScrollingFrame", self.Main)
    self.TabHolder.Size = UDim2.new(0, 140, 1, -60) self.TabHolder.Position = UDim2.new(0, 10, 0, 55) self.TabHolder.BackgroundTransparency = 1 self.TabHolder.ScrollBarThickness = 0
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 5)

    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(1, -170, 1, -70) self.Container.Position = UDim2.new(0, 160, 0, 60) self.Container.BackgroundTransparency = 1

    -- // 动画逻辑 (严格执行中心点坍缩) //
    
    -- 缩小功能 (修复逻辑 & 绑定到画出来的横杠上)
    MinHandle.MouseButton1Click:Connect(function()
        -- 1. 瞬间隐藏内部所有东西，防止缩小过程中挤压变形
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = false end
        
        -- 2. 向中心坍缩动画
        Tween(self.Main, 0.5, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 1})
        
        task.wait(0.5)
        -- 3. 切换状态
        self.Main.Visible = false
        self.Mini.Visible = true
        -- 4. 确保悬浮窗在中心，且大小正确
        self.Mini.Position = UDim2.new(0.5, -27, 0.5, -27)
        self.Mini.Size = UDim2.new(0, 55, 0, 55)
    end)

    -- 展开功能
    self.Mini.MouseButton1Click:Connect(function()
        self.Mini.Visible = false
        self.Main.Visible = true
        Tween(self.Main, 0.7, {Size = UDim2.new(0, 540, 0, 360), Position = UDim2.new(0.5, -270, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
        
        task.wait(0.2)
        -- 展开后恢复内部显示
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = true end
    end)

    -- 关闭功能 (中心点坍缩消失)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.5, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        self.Gui:Destroy()
    end)

    self.Tabs = {}
    return self
end

-- // 其余函数保持一致 (Notify, CreateTab, AddParagraph, AddToggle, AddInput, Show) //
function SOUL:Notify(cfg)
    local f = Instance.new("Frame", self.NotifyArea)
    f.Size = UDim2.new(1, 0, 0, 60) f.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", f) stroke.Color = Theme.Main stroke.Transparency = 0.5
    
    local off = 15
    if cfg.Icon and cfg.Icon ~= "" then
        local i = Instance.new("ImageLabel", f) i.Size = UDim2.new(0,35,0,35) i.Position = UDim2.new(0,10,0.5,-17) i.Image = cfg.Icon i.BackgroundTransparency = 1
        off = 55
    end

    local t = Instance.new("TextLabel", f) t.Size = UDim2.new(1,-off,0,25) t.Position = UDim2.new(0,off,0,8) t.Text = cfg.Title t.TextColor3 = Theme.Main t.Font = "GothamBold" t.BackgroundTransparency = 1 t.TextXAlignment = "Left"
    local d = Instance.new("TextLabel", f) d.Size = UDim2.new(1,-off,0,20) d.Position = UDim2.new(0,off,0,30) d.Text = cfg.Text d.TextColor3 = Color3.new(1,1,1) d.Font = "Gotham" d.BackgroundTransparency = 1 d.TextXAlignment = "Left"

    f.Position = UDim2.new(1.2, 0, 0, 0)
    Tween(f, 0.5, {Position = UDim2.new(0,0,0,0)})
    task.delay(cfg.Duration or 3, function()
        Tween(f, 0.5, {Position = UDim2.new(1.2,0,0,0)})
        task.wait(0.5) f:Destroy()
    end)
end

function SOUL:CreateTab(name)
    local tab = {Btn = Instance.new("TextButton", self.TabHolder), Scroll = Instance.new("ScrollingFrame", self.Container)}
    tab.Btn.Size = UDim2.new(1, 0, 0, 35) tab.Btn.BackgroundTransparency = 1 tab.Btn.Text = name tab.Btn.TextColor3 = Color3.fromRGB(150,150,150) tab.Btn.Font = "GothamBold"
    tab.Scroll.Size = UDim2.new(1,0,1,0) tab.Scroll.BackgroundTransparency = 1 tab.Scroll.Visible = false tab.Scroll.ScrollBarThickness = 2
    Instance.new("UIListLayout", tab.Scroll).Padding = UDim.new(0, 10)

    tab.Btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do v.Scroll.Visible = false v.Btn.TextColor3 = Color3.fromRGB(150,150,150) end
        tab.Scroll.Visible = true tab.Btn.TextColor3 = Theme.Main
    end)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then tab.Scroll.Visible = true tab.Btn.TextColor3 = Theme.Main end
    return tab
end

function SOUL:AddParagraph(tab, title, desc)
    local f = Instance.new("Frame", tab.Scroll)
    f.Size = UDim2.new(0.96, 0, 0, 0) f.BackgroundColor3 = Theme.Element f.AutomaticSize = "Y"
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local p = Instance.new("UIPadding", f) p.PaddingTop = UDim.new(0,10) p.PaddingBottom = UDim.new(0,10) p.PaddingLeft = UDim.new(0,15)
    Instance.new("UIListLayout", f).Padding = UDim.new(0,5)
    
    local tl = Instance.new("TextLabel", f) tl.Size = UDim2.new(1,0,0,20) tl.Text = title tl.TextColor3 = Theme.Main tl.Font = "GothamBold" tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local dl = Instance.new("TextLabel", f) dl.Size = UDim2.new(1,0,0,0) dl.Text = desc dl.TextColor3 = Color3.new(1,1,1) dl.Font = "Gotham" dl.BackgroundTransparency = 1 dl.TextXAlignment = "Left" dl.TextWrapped = true dl.AutomaticSize = "Y"
    
    task.spawn(function() task.wait(0.1) tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 20) end)
end

function SOUL:AddToggle(tab, text, callback)
    local state = false
    local b = Instance.new("TextButton", tab.Scroll)
    b.Size = UDim2.new(0.96,0,0,45) b.BackgroundColor3 = Theme.Element b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    
    local tl = Instance.new("TextLabel", b) tl.Size = UDim2.new(1,-70,1,0) tl.Position = UDim2.new(0,15,0,0) tl.Text = text tl.TextColor3 = Color3.new(1,1,1) tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local tr = Instance.new("Frame", b) tr.Size = UDim2.new(0,40,0,20) tr.Position = UDim2.new(1,-55,0.5,-10) tr.BackgroundColor3 = Color3.fromRGB(45,45,50)
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1,0)
    local d = Instance.new("Frame", tr) d.Size = UDim2.new(0,16,0,16) d.Position = UDim2.new(0,2,0.5,-8) d.BackgroundColor3 = Color3.new(1,1,1) Instance.new("UICorner", d).CornerRadius = UDim.new(1,0)

    b.MouseButton1Click:Connect(function()
        state = not state
        Tween(tr, 0.2, {BackgroundColor3 = state and Theme.Main or Color3.fromRGB(45,45,50)})
        Tween(d, 0.2, {Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
        callback(state)
    end)
end

function SOUL:AddInput(tab, text, placeholder, callback)
    local f = Instance.new("Frame", tab.Scroll)
    f.Size = UDim2.new(0.96,0,0,45) f.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    
    local tl = Instance.new("TextLabel", f) tl.Size = UDim2.new(0.5,0,1,0) tl.Position = UDim2.new(0,15,0,0) tl.Text = text tl.TextColor3 = Color3.new(1,1,1) tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local b = Instance.new("TextBox", f) b.Size = UDim2.new(0.4,0,0.7,0) b.Position = UDim2.new(0.6,-5,0.15,0) b.BackgroundColor3 = Theme.Bg b.Text = "" b.PlaceholderText = placeholder b.TextColor3 = Theme.Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    
    b.FocusLost:Connect(function(enter) if enter then callback(b.Text) end end)
end

function SOUL:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0,0,0,0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 540, 0, 360), Position = UDim2.new(0.5, -270, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
end

return SOUL
