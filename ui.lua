--[[
    SOUL UI Library v7.0 - "Seamless & Vector"
    核心改进：
    1. 纯代码绘制控制键（非文本字符），增大点击热区。
    2. 无缝缩小动画：主窗口直接缩小成 50x50 的悬浮窗，零闪烁。
    3. 恢复并优化关闭动画。
    4. 新增信息页面显示功能 (AddParagraph)。
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

local function Tween(obj, time, prop, style, dir)
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
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
    self.Gui.Name = "XINGYUN_UI"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 1. 悬浮窗 (预先设定好，但不直接显示，用于定位)
    self.MiniSquare = Instance.new("TextButton")
    self.MiniSquare.Size = UDim2.new(0, 50, 0, 50)
    self.MiniSquare.Position = UDim2.new(0.05, 0, 0.4, 0)
    self.MiniSquare.BackgroundColor3 = Theme.Accent
    self.MiniSquare.Text = "魂"
    self.MiniSquare.Font = Enum.Font.GothamBold
    self.MiniSquare.TextColor3 = Color3.new(1,1,1)
    self.MiniSquare.Visible = false
    self.MiniSquare.ZIndex = 10
    self.MiniSquare.Parent = self.Gui
    Instance.new("UICorner", self.MiniSquare).CornerRadius = UDim.new(0, 12)
    MakeDraggable(self.MiniSquare)

    -- 2. 主窗口 (CanvasGroup 方便整体做透明度动画)
    self.Main = Instance.new("CanvasGroup")
    self.Main.Size = UDim2.new(0, 460, 0, 310)
    self.Main.Position = UDim2.new(0.5, -230, 0.5, -155)
    self.Main.BackgroundColor3 = Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.Visible = false
    self.Main.Parent = self.Gui
    self.MainCorner = Instance.new("UICorner", self.Main)
    self.MainCorner.CornerRadius = UDim.new(0, 18)
    MakeDraggable(self.Main)

    -- 3. 边框渐变
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

    -- 5. 标题
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 0, 45)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = projectName or "XINGYUN INTERNAL"
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 5
    Title.Parent = self.Main

    -- // 6. 核心重写：纯手工绘制按键 // --
    local function CreateDrawBtn(typeStr, xOffset)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40) -- 更大的触控热区
        btn.Position = UDim2.new(1, xOffset, 0, 2)
        btn.BackgroundTransparency = 1
        btn.Text = "" -- 绝对不使用文字
        btn.ZIndex = 10
        btn.Parent = self.Main

        if typeStr == "Close" then
            local line1 = Instance.new("Frame", btn)
            line1.Size = UDim2.new(0, 16, 0, 2)
            line1.Position = UDim2.new(0.5, -8, 0.5, -1)
            line1.BackgroundColor3 = Theme.Text
            line1.Rotation = 45
            line1.BorderSizePixel = 0
            
            local line2 = line1:Clone()
            line2.Rotation = -45
            line2.Parent = btn
        elseif typeStr == "Min" then
            local line = Instance.new("Frame", btn)
            line.Size = UDim2.new(0, 16, 0, 2)
            line.Position = UDim2.new(0.5, -8, 0.5, -1)
            line.BackgroundColor3 = Theme.Text
            line.BorderSizePixel = 0
        end
        return btn
    end

    local closeBtn = CreateDrawBtn("Close", -45)
    local minBtn = CreateDrawBtn("Min", -85)

    -- 7. 内容容器
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

    -- // 8. 彻底无缝的动画逻辑 // --

    -- 恢复并优化关闭动画 (向中心坍缩)
    closeBtn.MouseButton1Click:Connect(function()
        local cx = self.Main.Position.X.Offset + (self.Main.Size.X.Offset / 2)
        local cy = self.Main.Position.Y.Offset + (self.Main.Size.Y.Offset / 2)
        Tween(self.Main, 0.4, {
            Size = UDim2.new(0, 0, 0, 0), 
            Position = UDim2.new(0.5, cx, 0.5, cy),
            GroupTransparency = 1
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        self.Gui:Destroy()
    end)

    -- 极致平滑的缩小动画 (把主窗体直接变成悬浮窗)
    minBtn.MouseButton1Click:Connect(function()
        -- 隐藏内部元素，防止缩小过程中挤压变形
        closeBtn.Visible = false
        minBtn.Visible = false
        Title.Visible = false
        self.Container.Visible = false
        self.TabHolder.Visible = false
        self.Sidebar.Visible = false
        
        -- 主窗体变色并缩向目标位置
        Tween(self.Main, 0.5, {
            Size = UDim2.new(0, 50, 0, 50),
            Position = self.MiniSquare.Position,
            BackgroundColor3 = Theme.Accent
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        -- 圆角平滑过渡到12
        Tween(self.MainCorner, 0.5, {CornerRadius = UDim.new(0, 12)})

        task.wait(0.5)
        -- 动画结束瞬间切换实体，零闪烁
        self.Main.Visible = false
        self.MiniSquare.Visible = true
    end)

    -- 展开动画
    self.MiniSquare.MouseButton1Click:Connect(function()
        self.MiniSquare.Visible = false
        self.Main.Visible = true
        
        Tween(self.Main, 0.7, {
            Size = UDim2.new(0, 460, 0, 310),
            Position = UDim2.new(0.5, -230, 0.5, -155),
            BackgroundColor3 = Theme.Main
        }, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
        
        Tween(self.MainCorner, 0.7, {CornerRadius = UDim.new(0, 18)})

        task.wait(0.3)
        -- 展开一半时恢复内部元素
        closeBtn.Visible = true
        minBtn.Visible = true
        Title.Visible = true
        self.Container.Visible = true
        self.TabHolder.Visible = true
        self.Sidebar.Visible = true
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
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

-- // 新增：信息显示功能 (支持自动换行与高度调整) // --
function SOUL_Lib:AddParagraph(tab, titleText, descText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.BackgroundTransparency = 0.5
    frame.AutomaticSize = Enum.AutomaticSize.Y -- Roblox 原生自动高度
    frame.Parent = tab.Scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local pad = Instance.new("UIPadding", frame)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)

    -- 标题
    if titleText and titleText ~= "" then
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.TextColor3 = Theme.Accent
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.LayoutOrder = 1
        title.Parent = frame
    end

    -- 正文内容
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 0)
    desc.BackgroundTransparency = 1
    desc.Text = descText
    desc.TextColor3 = Theme.Text
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.AutomaticSize = Enum.AutomaticSize.Y -- 随文字长度自动撑开高度
    desc.LayoutOrder = 2
    desc.Parent = frame

    -- 更新画布高度
    task.spawn(function()
        task.wait(0.05)
        tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
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
    b.MouseButton1Click:Connect(function()
        Tween(b, 0.1, {Size = UDim2.new(0.9, 0, 0, 35)})
        task.wait(0.1)
        Tween(b, 0.1, {Size = UDim2.new(0.95, 0, 0, 40)})
        callback()
    end)
    
    task.spawn(function()
        task.wait(0.05)
        tab.Scroll.CanvasSize = UDim2.new(0,0,0, tab.Scroll.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end

function SOUL_Lib:Show()
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0,0,0,0)
    Tween(self.Main, 0.8, {Size = UDim2.new(0, 460, 0, 310)}, Enum.EasingStyle.Elastic)
end

return SOUL_Lib
