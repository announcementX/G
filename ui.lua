--[[
    SOUL UI Library v5.0 - "Pure & Minimal"
    核心改进：符号化控制键、修正多层重叠、降低亮度、正方形缩小图标
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // 调色盘：柔和、低亮度 // --
local Theme = {
    Main = Color3.fromRGB(245, 230, 235),  -- 降低了亮度的莫兰迪粉
    Deep = Color3.fromRGB(235, 170, 190),  -- 边框渐变色
    Accent = Color3.fromRGB(255, 120, 160), -- 强调色
    Text = Color3.fromRGB(70, 60, 65)
}

local function Tween(obj, time, prop, style)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

-- // 独立拖拽逻辑 // --
local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

function SOUL_Lib.new(projectName)
    local self = setmetatable({}, SOUL_Lib)
    self.Tabs = {}
    self.CurrentTab = nil

    -- 1. 根容器
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SOUL_V5"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. 缩小后的圆角正方形 (修复形状)
    self.MiniSquare = Instance.new("TextButton")
    self.MiniSquare.Size = UDim2.new(0, 50, 0, 50)
    self.MiniSquare.Position = UDim2.new(0.05, 0, 0.45, 0)
    self.MiniSquare.BackgroundColor3 = Theme.Accent
    self.MiniSquare.Text = "魂"
    self.MiniSquare.Font = Enum.Font.GothamBold
    self.MiniSquare.TextColor3 = Color3.new(1,1,1)
    self.MiniSquare.Visible = false
    self.MiniSquare.Parent = self.Gui
    Instance.new("UICorner", self.MiniSquare).CornerRadius = UDim.new(0, 12) -- 12px 确保它是带圆角的正方形
    MakeDraggable(self.MiniSquare)

    -- 3. 主窗口
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 460, 0, 310)
    self.Main.Position = UDim2.new(0.5, -230, 0.5, -155)
    self.Main.BackgroundColor3 = Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Visible = false
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 18)
    MakeDraggable(self.Main)

    -- 4. 彻底消除重叠层的 45px 渐变
    local function CreatePureGradient(pos, rotation)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 45)
        bar.Position = pos
        bar.BackgroundTransparency = 0
        bar.BorderSizePixel = 0
        bar.ZIndex = 2 -- 置于背景之上
        bar.Parent = self.Main
        
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Theme.Deep, Theme.Main)
        g.Transparency = NumberSequence.new(0, 1)
        g.Rotation = rotation
        g.Parent = bar
        
        -- 给渐变条也加圆角，防止出现直角正方形阴影
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 18)
    end
    CreatePureGradient(UDim2.new(0,0,0,0), 90)
    CreatePureGradient(UDim2.new(0,0,1,-45), -90)

    -- 5. 侧边栏渐变效果 (修复丢失问题)
    self.SidebarBg = Instance.new("Frame")
    self.SidebarBg.Size = UDim2.new(0, 130, 1, 0)
    self.SidebarBg.BackgroundColor3 = Theme.Deep
    self.SidebarBg.BorderSizePixel = 0
    self.SidebarBg.ZIndex = 1
    self.SidebarBg.Parent = self.Main
    local sg = Instance.new("UIGradient")
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2), -- 起点带一点透明
        NumberSequenceKeypoint.new(1, 1)   -- 终点完全消失
    })
    sg.Parent = self.SidebarBg
    Instance.new("UICorner", self.SidebarBg).CornerRadius = UDim.new(0, 18)

    -- 6. 极致纯净控制键 (只有符号)
    local function CreateSymbol(text, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(1, x, 0, 8)
        b.BackgroundTransparency = 1
        b.Text = text
        b.Font = Enum.Font.Gotham
        b.TextSize = 22
        b.TextColor3 = Theme.Text
        b.ZIndex = 10
        b.Parent = self.Main
        return b
    end
    local closeBtn = CreateSymbol("✕", -35)
    local minBtn = CreateSymbol("—", -65)

    -- 7. 容器布局
    self.SideScroll = Instance.new("ScrollingFrame")
    self.SideScroll.Size = UDim2.new(0, 110, 1, -100)
    self.SideScroll.Position = UDim2.new(0, 10, 0, 55)
    self.SideScroll.BackgroundTransparency = 1
    self.SideScroll.BorderSizePixel = 0
    self.SideScroll.ScrollBarThickness = 0
    self.SideScroll.ZIndex = 5
    self.SideScroll.Parent = self.Main
    Instance.new("UIListLayout", self.SideScroll).Padding = UDim.new(0, 10)

    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -150, 1, -110)
    self.Container.Position = UDim2.new(0, 135, 0, 60)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 5
    self.Container.Parent = self.Main

    -- // 逻辑实现 // --

    closeBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.3, {Size = UDim2.new(0,0,0,0), GroupTransparency = 1}, Enum.EasingStyle.Back)
        task.wait(0.3)
        self.Gui:Destroy()
    end)

    minBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.5, {Size = UDim2.new(0,0,0,0), Position = self.MiniSquare.Position}, Enum.EasingStyle.Back)
        task.wait(0.4)
        self.Main.Visible = false
        self.MiniSquare.Visible = true
        Tween(self.MiniSquare, 0.5, {Size = UDim2.new(0, 50, 0, 50)}, Enum.EasingStyle.Elastic)
    end)

    self.MiniSquare.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.MiniSquare.Visible = false
        Tween(self.Main, 0.7, {Size = UDim2.new(0, 460, 0, 310), Position = UDim2.new(0.5, -230, 0.5, -155)}, Enum.EasingStyle.Elastic)
    end)

    return self
end

function SOUL_Lib:CreateTab(name)
    local tab = {}
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.ZIndex = 6
    btn.Parent = self.SideScroll

    local group = Instance.new("CanvasGroup")
    group.Size = UDim2.new(1, 0, 1, 0)
    group.BackgroundTransparency = 1
    group.Visible = false
    group.Parent = self.Container

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 1
    scroll.Parent = group
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tab.Group = group
    tab.Scroll = scroll

    btn.MouseButton1Click:Connect(function()
        if self.CurrentTab == tab then return end
        if self.CurrentTab then self.CurrentTab.Group.Visible = false end
        
        self.CurrentTab = tab
        group.Visible = true
        group.GroupTransparency = 1
        Tween(group, 0.3, {GroupTransparency = 0})
        
        -- 视觉高亮
        for _, other in pairs(self.Tabs) do
            other.Btn.TextColor3 = (other.Btn == btn) and Theme.Accent or Theme.Text
        end
    end)

    tab.Btn = btn
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self.CurrentTab = tab
        group.Visible = true
        btn.TextColor3 = Theme.Accent
    end
    return tab
end

function SOUL_Lib:AddButton(tab, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 40)
    b.BackgroundColor3 = Color3.new(1,1,1)
    b.BackgroundTransparency = 0.6 -- 增加透明度，融入背景
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.Gotham
    b.Parent = tab.Scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    b.MouseButton1Click:Connect(function()
        Tween(b, 0.1, {Size = UDim2.new(0.9, 0, 0, 35)})
        task.wait(0.1)
        Tween(b, 0.1, {Size = UDim2.new(0.95, 0, 0, 40)})
        callback()
    end)
    tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 10)
end

function SOUL_Lib:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 460, 0, 310)}, Enum.EasingStyle.Elastic)
end

return SOUL_Lib
