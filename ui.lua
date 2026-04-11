--[[
    SOUL UI Library v4.0 - "Invisible & Soul"
    修复：关闭失效、重影问题、缩小残留、拖拽死锁
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // 调色盘：深邃且渐变的粉 // --
local Theme = {
    Main = Color3.fromRGB(255, 245, 247),  -- 极淡粉背景
    Deep = Color3.fromRGB(255, 160, 190),  -- 边框渐变色
    Accent = Color3.fromRGB(255, 90, 140), -- 强调色
    Text = Color3.fromRGB(90, 70, 80),
    Transparent = Color3.fromRGB(255, 245, 247)
}

local function Tween(obj, time, prop, style)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

-- // 强化版拖拽引擎 (修复缩小后失效) // --
local function MakeDraggable(obj)
    local dragging, dragInput, dragStart, startPos
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
    self.Gui.Name = "SOUL_V4"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. 悬浮球 (完全独立，防止主窗体干扰)
    self.Ball = Instance.new("TextButton")
    self.Ball.Size = UDim2.new(0, 50, 0, 50)
    self.Ball.Position = UDim2.new(0.1, 0, 0.2, 0)
    self.Ball.BackgroundColor3 = Theme.Accent
    self.Ball.Text = "S"
    self.Ball.Font = Enum.Font.GothamBold
    self.Ball.TextColor3 = Color3.new(1,1,1)
    self.Ball.Visible = false
    self.Ball.Parent = self.Gui
    Instance.new("UICorner", self.Ball).CornerRadius = UDim.new(1, 0)
    MakeDraggable(self.Ball)

    -- 3. 主窗口 (缩小到 450x300)
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 450, 0, 300)
    self.Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    self.Main.BackgroundColor3 = Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Visible = false
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 20)
    MakeDraggable(self.Main)

    -- 4. 极致渐变边框 (45px)
    local function CreateGradientBar(pos, rotation)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 45)
        f.Position = pos
        f.BackgroundTransparency = 0
        f.BorderSizePixel = 0
        f.ZIndex = 5
        f.Parent = self.Main
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Theme.Deep, Theme.Main)
        g.Transparency = NumberSequence.new(0.2, 1) -- 更加通透
        g.Rotation = rotation
        g.Parent = f
    end
    CreateGradientBar(UDim2.new(0,0,0,0), 90)
    CreateGradientBar(UDim2.new(0,0,1,-45), -90)

    -- 5. 极简控制按键 (不再明显)
    local function CreateDot(color, x)
        local d = Instance.new("TextButton")
        d.Size = UDim2.new(0, 12, 0, 12)
        d.Position = UDim2.new(1, x, 0, 15)
        d.BackgroundColor3 = color
        d.Text = ""
        d.ZIndex = 10
        d.Parent = self.Main
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
        return d
    end
    local closeBtn = CreateDot(Color3.fromRGB(255, 110, 110), -25)
    local minBtn = CreateDot(Theme.Accent, -45)

    -- 6. 侧边栏与容器
    self.SideScroll = Instance.new("ScrollingFrame")
    self.SideScroll.Size = UDim2.new(0, 120, 1, -90)
    self.SideScroll.Position = UDim2.new(0, 10, 0, 50)
    self.SideScroll.BackgroundTransparency = 1
    self.SideScroll.BorderSizePixel = 0
    self.SideScroll.ScrollBarThickness = 0
    self.SideScroll.ZIndex = 6
    self.SideScroll.Parent = self.Main
    Instance.new("UIListLayout", self.SideScroll).Padding = UDim.new(0, 8)

    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -150, 1, -100)
    self.Container.Position = UDim2.new(0, 140, 0, 55)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 6
    self.Container.Parent = self.Main

    -- // 交互逻辑 // --

    -- 真正的关闭 (修复失效问题)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, Enum.EasingStyle.Back)
        task.wait(0.4)
        self.Gui:Destroy()
    end)

    -- 彻底的缩小
    minBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, 0.5, {Size = UDim2.new(0,0,0,0), Position = self.Ball.Position}, Enum.EasingStyle.Back)
        task.wait(0.4)
        self.Main.Visible = false
        self.Ball.Visible = true
        Tween(self.Ball, 0.5, {Size = UDim2.new(0, 50, 0, 50)}, Enum.EasingStyle.Elastic)
    end)

    self.Ball.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.Ball.Visible = false
        Tween(self.Main, 0.7, {Size = UDim2.new(0, 450, 0, 300), Position = UDim2.new(0.5, -225, 0.5, -150)}, Enum.EasingStyle.Elastic)
    end)

    return self
end

-- // 修复栏目切换时的“重影” // --
function SOUL_Lib:CreateTab(name)
    local tab = {}
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.ZIndex = 7
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
        
        -- 核心修复：先让当前页面彻底消失
        if self.CurrentTab then
            self.CurrentTab.Group.Visible = false
        end
        
        -- 再让新页面出现并执行动画
        self.CurrentTab = tab
        group.Visible = true
        group.GroupTransparency = 1
        group.Position = UDim2.new(0, 15, 0, 0)
        
        Tween(group, 0.3, {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
        Tween(btn, 0.3, {TextColor3 = Theme.Accent})
        
        -- 其他按钮恢复颜色
        for _, other in pairs(self.Tabs) do
            if other ~= tab then
                Tween(other.Btn, 0.3, {TextColor3 = Theme.Text})
            end
        end
    end)

    tab.Btn = btn
    table.insert(self.Tabs, tab)
    
    -- 默认显示第一个
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
    b.BackgroundTransparency = 0.5
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

-- // 开场动画：极简灵魂呼吸 // --
function SOUL_Lib:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 450, 0, 300)}, Enum.EasingStyle.Elastic)
end

return SOUL_Lib
