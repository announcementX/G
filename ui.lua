--[[
    SOUL UI Library v12.0 - "SAKURA SUPERNOVA"
    - 特色：中心冲击波加载、完全自定义悬浮窗尺寸
]]

local SOUL = {}
SOUL.__index = SOUL

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Main = Color3.fromRGB(255, 182, 193),
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

function SOUL.new(projName, miniCfg)
    local self = setmetatable({}, SOUL)
    self.Gui = Instance.new("ScreenGui", CoreGui)
    self.Gui.Name = "SOUL_V12"
    self.Gui.DisplayOrder = 999
    
    -- // 自定义悬浮窗 (脚本传参控制大小) //
    local mSize = miniCfg.Size or 55 -- 脚本中设置
    self.Mini = Instance.new("TextButton", self.Gui)
    self.Mini.Size = UDim2.new(0, mSize, 0, mSize)
    self.Mini.Position = UDim2.new(0.5, -mSize/2, 0.5, -mSize/2)
    self.Mini.BackgroundColor3 = miniCfg.Color or Theme.Main
    self.Mini.Text = (miniCfg.Image == "") and (miniCfg.Text or "S") or ""
    self.Mini.TextColor3 = Color3.new(1,1,1)
    self.Mini.Font = "GothamBold"
    self.Mini.TextSize = mSize * 0.4
    self.Mini.Visible = false
    self.Mini.ZIndex = 100
    Instance.new("UICorner", self.Mini).CornerRadius = UDim.new(0, miniCfg.Radius or 12)
    
    if miniCfg.Image ~= "" then
        local img = Instance.new("ImageLabel", self.Mini)
        img.Size = UDim2.new(0.7,0,0.7,0) img.Position = UDim2.new(0.15,0,0.15,0) img.Image = miniCfg.Image img.BackgroundTransparency = 1
    end
    MakeDraggable(self.Mini)

    -- // 冲击波加载特效层 //
    self.Shockwave = Instance.new("Frame", self.Gui)
    self.Shockwave.Size = UDim2.new(0, 0, 0, 0)
    self.Shockwave.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Shockwave.BackgroundColor3 = Theme.Main
    self.Shockwave.BackgroundTransparency = 0.5
    self.Shockwave.ZIndex = 98
    Instance.new("UICorner", self.Shockwave).CornerRadius = UDim.new(1, 0)

    -- // 主界面 //
    self.Main = Instance.new("CanvasGroup", self.Gui)
    self.Main.Size = UDim2.new(0,0,0,0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.BackgroundColor3 = Theme.Bg
    self.Main.Visible = false
    self.Main.GroupTransparency = 1
    self.Main.ZIndex = 99
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 15)
    MakeDraggable(self.Main)

    -- 顶部控制 (画出来的缩小键)
    local Top = Instance.new("Frame", self.Main)
    Top.Size = UDim2.new(1, 0, 0, 50) Top.BackgroundTransparency = 1 Top.ZIndex = 101
    
    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(0, 200, 1, 0) Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = projName Title.TextColor3 = Theme.Main Title.Font = "GothamBold" Title.TextSize = 18 Title.TextXAlignment = "Left" Title.BackgroundTransparency = 1

    local CloseBtn = Instance.new("TextButton", Top)
    CloseBtn.Size = UDim2.new(0, 40, 0, 40) CloseBtn.Position = UDim2.new(1, -45, 0, 5) CloseBtn.Text = "×" CloseBtn.TextColor3 = Theme.Main CloseBtn.TextSize = 26 CloseBtn.BackgroundTransparency = 1

    -- 矢量画出来的缩小横杠
    local MinBtn = Instance.new("TextButton", Top)
    MinBtn.Size = UDim2.new(0, 40, 0, 40) MinBtn.Position = UDim2.new(1, -85, 0, 5) MinBtn.Text = "" MinBtn.BackgroundTransparency = 1
    local MinLine = Instance.new("Frame", MinBtn)
    MinLine.Size = UDim2.new(0, 18, 0, 2) MinLine.Position = UDim2.new(0.5, -9, 0.5, -1) MinLine.BackgroundColor3 = Theme.Main MinLine.BorderSizePixel = 0

    -- 侧边栏和容器
    self.TabHolder = Instance.new("ScrollingFrame", self.Main)
    self.TabHolder.Size = UDim2.new(0, 140, 1, -60) self.TabHolder.Position = UDim2.new(0, 10, 0, 55) self.TabHolder.BackgroundTransparency = 1 self.TabHolder.ScrollBarThickness = 0
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 5)

    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(1, -170, 1, -70) self.Container.Position = UDim2.new(0, 160, 0, 60) self.Container.BackgroundTransparency = 1

    -- // 核心动画逻辑修复 //
    MinBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Main:GetChildren()) do if v:IsA("GuiObject") then v.Visible = false end end
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        self.Main.Visible = false
        self.Mini.Visible = true
        self.Mini.Position = UDim2.new(0.5, -mSize/2, 0.5, -mSize/2)
        Tween(self.Mini, 0.5, {Size = UDim2.new(0, mSize, 0, mSize)}, Enum.EasingStyle.Elastic)
    end)

    self.Mini.MouseButton1Click:Connect(function()
        self.Mini.Visible = false
        self.Main.Visible = true
        Tween(self.Main, 0.6, {Size = UDim2.new(0, 540, 0, 360), Position = UDim2.new(0.5, -270, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
        task.wait(0.2)
        for _, v in pairs(self.Main:GetChildren()) do if v:IsA("GuiObject") then v.Visible = true end end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        self.Gui:Destroy()
    end)

    self.NotifyArea = Instance.new("Frame", self.Gui)
    self.NotifyArea.Size = UDim2.new(0, 300, 1, 0) self.NotifyArea.Position = UDim2.new(1, -310, 0, 0) self.NotifyArea.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.NotifyArea).VerticalAlignment = Enum.VerticalAlignment.Bottom

    self.Tabs = {}
    return self
end

-- // 加载动画：中心冲击波爆发 //
function SOUL:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    -- 冲击波扩散
    self.Shockwave.Visible = true
    Tween(self.Shockwave, 0.8, {Size = UDim2.new(0, 600, 0, 600), Position = UDim2.new(0.5, -300, 0.5, -300), BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- 主界面爆发
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 540, 0, 360), Position = UDim2.new(0.5, -270, 0.5, -180), GroupTransparency = 0}, Enum.EasingStyle.Elastic)
    
    task.delay(0.8, function() self.Shockwave:Destroy() end)
end

-- // 右下角通知 //
function SOUL:Notify(cfg)
    local f = Instance.new("Frame", self.NotifyArea)
    f.Size = UDim2.new(1, 0, 0, 60) f.BackgroundColor3 = Theme.Element
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", f).Color = Theme.Main
    
    local off = 15
    if cfg.Icon and cfg.Icon ~= "" then
        local i = Instance.new("ImageLabel", f) i.Size = UDim2.new(0,35,0,35) i.Position = UDim2.new(0,10,0.5,-17) i.Image = cfg.Icon i.BackgroundTransparency = 1
        off = 55
    end
    
    local tl = Instance.new("TextLabel", f) tl.Size = UDim2.new(1,-off,0,25) tl.Position = UDim2.new(0,off,0,8) tl.Text = cfg.Title tl.TextColor3 = Theme.Main tl.Font = "GothamBold" tl.BackgroundTransparency = 1 tl.TextXAlignment = "Left"
    local dl = Instance.new("TextLabel", f) dl.Size = UDim2.new(1,-off,0,20) dl.Position = UDim2.new(0,off,0,30) dl.Text = cfg.Text dl.TextColor3 = Color3.new(1,1,1) dl.Font = "Gotham" dl.BackgroundTransparency = 1 dl.TextXAlignment = "Left"

    f.Position = UDim2.new(1.2, 0, 0, 0)
    Tween(f, 0.5, {Position = UDim2.new(0,0,0,0)})
    task.delay(cfg.Duration or 3, function()
        Tween(f, 0.5, {Position = UDim2.new(1.2,0,0,0)})
        task.wait(0.5) f:Destroy()
    end)
end

-- // 其他基础组件 (保持逻辑) //
function SOUL:CreateTab(name)
    local t = {Btn = Instance.new("TextButton", self.TabHolder), Scroll = Instance.new("ScrollingFrame", self.Container)}
    t.Btn.Size = UDim2.new(1,0,0,35) t.Btn.BackgroundTransparency = 1 t.Btn.Text = name t.Btn.TextColor3 = Color3.fromRGB(150,150,150) t.Btn.Font = "GothamBold"
    t.Scroll.Size = UDim2.new(1,0,1,0) t.Scroll.BackgroundTransparency = 1 t.Scroll.Visible = false t.Scroll.ScrollBarThickness = 2
    Instance.new("UIListLayout", t.Scroll).Padding = UDim.new(0,10)
    t.Btn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do v.Scroll.Visible = false v.Btn.TextColor3 = Color3.fromRGB(150,150,150) end
        t.Scroll.Visible = true t.Btn.TextColor3 = Theme.Main
    end)
    table.insert(self.Tabs, t)
    if #self.Tabs == 1 then t.Scroll.Visible = true t.Btn.TextColor3 = Theme.Main end
    return t
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

return SOUL
