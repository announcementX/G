--[[
    SOUL UI Library v9.0 - "Sakura Black Hole"
    配色：淡粉色 & 深暗色
    动画：中心爆发加载 / 中心坍缩缩小 / 右下角图文通知
]]

local SOUL = {}
SOUL.__index = SOUL

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 严格执行淡粉色配色
local Theme = {
    Main = Color3.fromRGB(255, 182, 193), -- 淡粉色 (Light Pink)
    Background = Color3.fromRGB(20, 20, 25),
    Element = Color3.fromRGB(30, 30, 35),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 200, 200)
}

local function Tween(obj, time, prop, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), prop)
    t:Play()
    return t
end

local function Drag(obj)
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

function SOUL.new(title, miniCfg)
    local self = setmetatable({}, SOUL)
    miniCfg = miniCfg or {Radius = 15, Color = Theme.Main, Text = "S", Image = ""}

    self.Gui = Instance.new("ScreenGui", CoreGui)
    self.Gui.Name = "SOUL_V9"

    -- // 右下角通知容器 (严格位置) //
    self.NotifyArea = Instance.new("Frame", self.Gui)
    self.NotifyArea.Size = UDim2.new(0, 280, 0.8, 0)
    self.NotifyArea.Position = UDim2.new(1, -290, 0.1, 0)
    self.NotifyArea.BackgroundTransparency = 1
    local notifyLayout = Instance.new("UIListLayout", self.NotifyArea)
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.Padding = UDim.new(0, 10)

    -- // 悬浮窗 (固定中心出现) //
    self.Mini = Instance.new("TextButton", self.Gui)
    self.Mini.Size = UDim2.new(0, 55, 0, 55)
    self.Mini.Position = UDim2.new(0.5, -27, 0.5, -27) -- 严格中心
    self.Mini.BackgroundColor3 = miniCfg.Color
    self.Mini.Text = miniCfg.Image == "" and miniCfg.Text or ""
    self.Mini.Font = Enum.Font.GothamBold
    self.Mini.TextSize = 22
    self.Mini.TextColor3 = Color3.new(1,1,1)
    self.Mini.Visible = false
    Instance.new("UICorner", self.Mini).CornerRadius = UDim.new(0, miniCfg.Radius)
    
    if miniCfg.Image ~= "" then
        local i = Instance.new("ImageLabel", self.Mini)
        i.Size = UDim2.new(0.7,0,0.7,0) i.Position = UDim2.new(0.15,0,0.15,0) i.BackgroundTransparency = 1 i.Image = miniCfg.Image
    end
    Drag(self.Mini)

    -- // 主界面 (中心爆发动画对象) //
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- 初始大小0
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- 中心点
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.GroupTransparency = 1
    self.Main.Visible = false
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 15)
    Drag(self.Main)

    -- 侧边
    local Side = Instance.new("Frame", self.Main)
    Side.Size = UDim2.new(0, 140, 1, 0)
    Side.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Side.BorderSizePixel = 0

    local Ttl = Instance.new("TextLabel", self.Main)
    Ttl.Size = UDim2.new(0, 200, 0, 50)
    Ttl.Position = UDim2.new(0, 15, 0, 0)
    Ttl.Text = title Ttl.TextColor3 = Theme.Main Ttl.Font = Enum.Font.GothamBold Ttl.TextSize = 18 Ttl.TextXAlignment = "Left" Ttl.BackgroundTransparency = 1

    -- 按钮区
    self.TabLib = Instance.new("ScrollingFrame", Side)
    self.TabLib.Size = UDim2.new(1, 0, 1, -60)
    self.TabLib.Position = UDim2.new(0, 0, 0, 50)
    self.TabLib.BackgroundTransparency = 1 self.TabLib.ScrollBarThickness = 0
    Instance.new("UIListLayout", self.TabLib).Padding = UDim.new(0, 5)

    self.PageCont = Instance.new("Frame", self.Main)
    self.PageCont.Size = UDim2.new(1, -155, 1, -60)
    self.PageCont.Position = UDim2.new(0, 145, 0, 55)
    self.PageCont.BackgroundTransparency = 1

    -- // 控制逻辑 //
    local close = Instance.new("TextButton", self.Main)
    close.Size = UDim2.new(0,30,0,30) close.Position = UDim2.new(1,-40,0,10) close.Text = "×" close.TextColor3 = Theme.Main close.BackgroundTransparency = 1 close.TextSize = 25

    local mini = Instance.new("TextButton", self.Main)
    mini.Size = UDim2.new(0,30,0,30) mini.Position = UDim2.new(1,-80,0,10) mini.Text = "—" mini.TextColor3 = Theme.Main mini.BackgroundTransparency = 1 mini.TextSize = 25

    -- 缩小动画 (向中心点缩小)
    mini.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = false end
        local midX, midY = self.Main.Position.X.Offset + (self.Main.Size.X.Offset/2), self.Main.Position.Y.Offset + (self.Main.Size.Y.Offset/2)
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, midX, 0.5, midY), GroupTransparency = 1})
        task.wait(0.4)
        self.Main.Visible = false
        self.Mini.Visible = true
        self.Mini.Position = UDim2.new(0.5, -27, 0.5, -27)
        Tween(self.Mini, 0.3, {Size = UDim2.new(0,55,0,55)}, Enum.EasingStyle.Back)
    end)

    -- 展开 (从悬浮窗原位爆发)
    self.Mini.MouseButton1Click:Connect(function()
        self.Mini.Visible = false
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0,0,0,0)
        self.Main.GroupTransparency = 1
        Tween(self.Main, 0.6, {Size = UDim2.new(0,520,0,360), Position = UDim2.new(0.5, -260, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
        task.wait(0.2)
        for _, v in pairs(self.Main:GetChildren()) do v.Visible = true end
    end)

    -- 关闭 (彻底中心黑洞)
    close.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, self.Main.Position.X.Offset+260, 0.5, self.Main.Position.Y.Offset+180), GroupTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        self.Gui:Destroy()
    end)

    self.Tabs = {}
    return self
end

-- // 右下角通知 //
function SOUL:Notify(cfg)
    local f = Instance.new("Frame", self.NotifyArea)
    f.Size = UDim2.new(1, 0, 0, 55) f.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", f) stroke.Color = Theme.Main stroke.Transparency = 0.8
    
    local txtX = 15
    if cfg.Icon and cfg.Icon ~= "" then
        local i = Instance.new("ImageLabel", f) i.Size = UDim2.new(0,30,0,30) i.Position = UDim2.new(0,10,0.5,-15) i.Image = cfg.Icon i.BackgroundTransparency = 1
        txtX = 50
    end

    local t = Instance.new("TextLabel", f) t.Size = UDim2.new(1,-txtX,0,20) t.Position = UDim2.new(0,txtX,0,8) t.Text = cfg.Title t.TextColor3 = Theme.Main t.Font = "GothamBold" t.BackgroundTransparency = 1 t.TextXAlignment = "Left"
    local d = Instance.new("TextLabel", f) d.Size = UDim2.new(1,-txtX,0,20) d.Position = UDim2.new(0,txtX,0,28) d.Text = cfg.Text t.TextColor3 = Theme.SubText t.Font = "Gotham" d.BackgroundTransparency = 1 d.TextXAlignment = "Left" d.TextColor3 = Color3.new(1,1,1)

    f.Position = UDim2.new(1.5, 0, 0, 0)
    Tween(f, 0.5, {Position = UDim2.new(0,0,0,0)})
    task.delay(cfg.Duration or 3, function()
        Tween(f, 0.5, {Position = UDim2.new(1.5,0,0,0)})
        task.wait(0.5) f:Destroy()
    end)
end

function SOUL:CreateTab(name)
    local t = {Btn = Instance.new("TextButton", self.TabLib), Page = Instance.new("ScrollingFrame", self.PageCont)}
    t.Btn.Size = UDim2.new(1,0,0,35) t.Btn.BackgroundTransparency = 1 t.Btn.Text = name t.Btn.TextColor3 = Theme.SubText t.Btn.Font = "GothamBold"
    t.Page.Size = UDim2.new(1,0,1,0) t.Page.BackgroundTransparency = 1 t.Page.Visible = false t.Page.ScrollBarThickness = 2 t.Page.ScrollBarImageColor3 = Theme.Main
    Instance.new("UIListLayout", t.Page).Padding = UDim.new(0,8)

    t.Btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do v.Page.Visible = false v.Btn.TextColor3 = Theme.SubText end
        t.Page.Visible = true t.Btn.TextColor3 = Theme.Main
    end)
    table.insert(self.Tabs, t)
    if #self.Tabs == 1 then t.Page.Visible = true t.Btn.TextColor3 = Theme.Main end
    return t
end

-- // 信息显示 (四边形背景) //
function SOUL:AddParagraph(tab, title, desc)
    local f = Instance.new("Frame", tab.Page)
    f.Size = UDim2.new(0.96, 0, 0, 0) f.BackgroundColor3 = Theme.Element f.AutomaticSize = "Y"
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local p = Instance.new("UIPadding", f) p.PaddingTop = UDim.new(0,8) p.PaddingBottom = UDim.new(0,8) p.PaddingLeft = UDim.new(0,12)
    Instance.new("UIListLayout", f).Padding = UDim.new(0,4)
    
    local tl = Instance.new("TextLabel", f) tl.Size = UDim2.new(1,0,0,20) tl.Text = title tl.TextColor3 = Theme.Main tl.Font = "GothamBold" tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local dl = Instance.new("TextLabel", f) dl.Size = UDim2.new(1,0,0,0) dl.Text = desc dl.TextColor3 = Color3.new(1,1,1) dl.Font = "Gotham" dl.BackgroundTransparency = 1 dl.TextXAlignment = "Left" dl.TextWrapped = true dl.AutomaticSize = "Y"
    
    task.spawn(function() task.wait(0.1) tab.Page.CanvasSize = UDim2.new(0,0,0, tab.Page.UIListLayout.AbsoluteContentSize.Y + 20) end)
end

-- // 功能开关 (Toggle) //
function SOUL:AddToggle(tab, text, callback)
    local state = false
    local b = Instance.new("TextButton", tab.Page)
    b.Size = UDim2.new(0.96,0,0,40) b.BackgroundColor3 = Theme.Element b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    
    local tl = Instance.new("TextLabel", b) tl.Size = UDim2.new(1,-60,1,0) tl.Position = UDim2.new(0,12,0,0) tl.Text = text tl.TextColor3 = Color3.new(1,1,1) tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local tr = Instance.new("Frame", b) tr.Size = UDim2.new(0,35,0,18) tr.Position = UDim2.new(1,-45,0.5,-9) tr.BackgroundColor3 = Color3.fromRGB(50,50,55)
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1,0)
    local d = Instance.new("Frame", tr) d.Size = UDim2.new(0,14,0,14) d.Position = UDim2.new(0,2,0.5,-7) d.BackgroundColor3 = Color3.new(1,1,1) Instance.new("UICorner", d).CornerRadius = UDim.new(1,0)

    b.MouseButton1Click:Connect(function()
        state = not state
        Tween(tr, 0.2, {BackgroundColor3 = state and Theme.Main or Color3.fromRGB(50,50,55)})
        Tween(d, 0.2, {Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        callback(state)
    end)
end

-- // 输入执行 (Input) //
function SOUL:AddInput(tab, text, placeholder, callback)
    local f = Instance.new("Frame", tab.Page)
    f.Size = UDim2.new(0.96,0,0,40) f.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    
    local tl = Instance.new("TextLabel", f) tl.Size = UDim2.new(0.5,0,1,0) tl.Position = UDim2.new(0,12,0,0) tl.Text = text tl.TextColor3 = Color3.new(1,1,1) tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local b = Instance.new("TextBox", f) b.Size = UDim2.new(0.4,0,0.7,0) b.Position = UDim2.new(0.6,-5,0.15,0) b.BackgroundColor3 = Color3.fromRGB(20,20,25) b.Text = "" b.PlaceholderText = placeholder b.TextColor3 = Theme.Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    
    b.FocusLost:Connect(function(enter) if enter then callback(b.Text) end end)
end

-- // 原点爆发启动 //
function SOUL:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.GroupTransparency = 1
    
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 520, 0, 360), Position = UDim2.new(0.5, -260, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
end

return SOUL
