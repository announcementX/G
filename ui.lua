--[[
    SOUL UI Library v6.0 - "Final Purity"
    修复：缩小闪现、按键变形、关闭失效、纯粹横杠
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Main = Color3.fromRGB(245, 230, 235),  
    Deep = Color3.fromRGB(235, 170, 190),  
    Accent = Color3.fromRGB(255, 120, 160), 
    Text = Color3.fromRGB(70, 60, 65)
}

local function Tween(obj, time, prop, style)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

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
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SOUL_V6"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 1. 缩小后的圆角正方形
    self.MiniSquare = Instance.new("TextButton")
    self.MiniSquare.Size = UDim2.new(0, 50, 0, 50)
    self.MiniSquare.Position = UDim2.new(0.05, 0, 0.4, 0)
    self.MiniSquare.BackgroundColor3 = Theme.Accent
    self.MiniSquare.Text = "魂"
    self.MiniSquare.Font = Enum.Font.GothamBold
    self.MiniSquare.TextColor3 = Color3.new(1,1,1)
    self.MiniSquare.Visible = false
    self.MiniSquare.Parent = self.Gui
    Instance.new("UICorner", self.MiniSquare).CornerRadius = UDim.new(0, 12)
    MakeDraggable(self.MiniSquare)

    -- 2. 主窗口
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

    -- 3. 渐变条 (带圆角，防重叠)
    local function CreateBar(pos, rot)
        local b = Instance.new("Frame")
        b.Size = UDim2.new(1, 0, 0, 45)
        b.Position = pos
        b.BackgroundTransparency = 0
        b.BorderSizePixel = 0
        b.ZIndex = 2
        b.Parent = self.Main
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Theme.Deep, Theme.Main)
        g.Transparency = NumberSequence.new(0, 1)
        g.Rotation = rot
        g.Parent = b
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 18)
    end
    CreateBar(UDim2.new(0,0,0,0), 90)
    CreateBar(UDim2.new(0,0,1,-45), -90)

    -- 4. 侧边栏
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 130, 1, 0)
    self.Sidebar.BackgroundColor3 = Theme.Deep
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.ZIndex = 1
    self.Sidebar.Parent = self.Main
    local sg = Instance.new("UIGradient")
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    sg.Parent = self.Sidebar
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 18)

    -- 5. 纯粹符号按键 (修复变形与失效)
    local function CreateBtn(symbol, x, name)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(1, x, 0, 8)
        b.BackgroundTransparency = 1
        b.Text = symbol
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 20
        b.TextColor3 = Theme.Text
        b.ZIndex = 10
        b.Parent = self.Main
        return b
    end
    
    local closeBtn = CreateBtn("×", -35, "CloseBtn")
    local minBtn = CreateBtn("—", -65, "MinBtn")

    -- 6. 内容容器
    self.TabHolder = Instance.new("ScrollingFrame")
    self.TabHolder.Size = UDim2.new(0, 110, 1, -100)
    self.TabHolder.Position = UDim2.new(0, 10, 0, 55)
    self.TabHolder.BackgroundTransparency = 1
    self.TabHolder.BorderSizePixel = 0
    self.TabHolder.ScrollBarThickness = 0
    self.TabHolder.ZIndex = 5
    self.TabHolder.Parent = self.Main
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 8)

    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -150, 1, -110)
    self.Container.Position = UDim2.new(0, 135, 0, 60)
    self.Container.BackgroundTransparency = 1
    self.Container.ZIndex = 5
    self.Container.Parent = self.Main

    -- // 核心逻辑修复 // --

    closeBtn.MouseButton1Click:Connect(function()
        print("Closing UI...")
        self.Gui:Destroy()
    end)

    minBtn.MouseButton1Click:Connect(function()
        -- 第一步：瞬间隐藏按键，防止缩小过程中的闪现和变形
        closeBtn.Visible = false
        minBtn.Visible = false
        
        -- 第二步：执行缩小动画
        Tween(self.Main, 0.4, {Size = UDim2.new(0,0,0,0), Position = self.MiniSquare.Position}, Enum.EasingStyle.Back)
        
        task.wait(0.35)
        self.Main.Visible = false
        self.MiniSquare.Visible = true
        Tween(self.MiniSquare, 0.5, {Size = UDim2.new(0, 50, 0, 50)}, Enum.EasingStyle.Elastic)
    end)

    self.MiniSquare.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.MiniSquare.Visible = false
        
        local t = Tween(self.Main, 0.7, {Size = UDim2.new(0, 460, 0, 310), Position = UDim2.new(0.5, -230, 0.5, -155)}, Enum.EasingStyle.Elastic)
        
        -- 展开后重新显示按键
        t.Completed:Connect(function()
            closeBtn.Visible = true
            minBtn.Visible = true
        end)
    end)

    return self
end

-- // 其余函数保持一致 (AddTab, AddButton...) // --
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
    btn.Parent = self.TabHolder

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
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 10)

    tab.Group = group
    tab.Scroll = scroll
    tab.Btn = btn

    btn.MouseButton1Click:Connect(function()
        if self.CurrentTab then self.CurrentTab.Group.Visible = false end
        self.CurrentTab = tab
        group.Visible = true
        for _, t in pairs(self.Tabs) do
            t.Btn.TextColor3 = (t == tab) and Theme.Accent or Theme.Text
        end
    end)

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
    b.BackgroundTransparency = 0.6
    b.Text = text
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.Gotham
    b.Parent = tab.Scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.MouseButton1Click:Connect(callback)
end

function SOUL_Lib:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0,0,0,0)
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 460, 0, 310)}, Enum.EasingStyle.Elastic)
end

return SOUL_Lib
