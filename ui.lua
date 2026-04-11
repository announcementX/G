--[[
    SOUL UI Library v2.0 - "Ethereal Essence"
    核心视觉：渐变融合、弹性动画、灵魂元素
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // 顶级视觉配置 // --
local Theme = {
    Main = Color3.fromRGB(255, 235, 240),      -- 底色：极淡粉
    Deep = Color3.fromRGB(255, 170, 190),      -- 深色：用于渐变起源点
    Light = Color3.fromRGB(255, 245, 250),     -- 侧边栏起源点
    Accent = Color3.fromRGB(255, 105, 180),    -- 灵魂强调色
    Text = Color3.fromRGB(100, 80, 90)
}

-- // 弹性补间工具 // --
local function Anim(obj, time, style, dir, prop)
    local info = TweenInfo.new(time, Enum.EasingStyle[style], Enum.EasingDirection[dir])
    local t = TweenService:Create(obj, info, prop)
    t:Play()
    return t
end

function SOUL_Lib.new(projectName)
    local self = setmetatable({}, SOUL_Lib)
    self.ProjectName = projectName or "SOUL"
    
    -- 1. 创建根容器
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SOUL_Ethereal"
    self.Gui.DisplayOrder = 999
    self.Gui.Parent = CoreGui
    
    -- 2. 缩小后的图标 (预创建以防止消失)
    self.MiniFrame = Instance.new("TextButton")
    self.MiniFrame.Name = "SoulCore"
    self.MiniFrame.Size = UDim2.new(0, 55, 0, 55)
    self.MiniFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
    self.MiniFrame.BackgroundColor3 = Theme.Accent
    self.MiniFrame.Text = "魂"
    self.MiniFrame.TextColor3 = Color3.new(1,1,1)
    self.MiniFrame.Font = Enum.Font.GothamBold
    self.MiniFrame.TextSize = 20
    self.MiniFrame.Visible = false
    self.MiniFrame.Parent = self.Gui
    Instance.new("UICorner", self.MiniFrame).CornerRadius = UDim.new(0.3, 0)
    
    -- 3. 主悬浮窗
    self.Main = Instance.new("Frame")
    self.Main.Size = UDim2.new(0, 550, 0, 350)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    self.Main.BackgroundColor3 = Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Visible = false
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 20)

    -- 4. 关键：渐变层级实现 (替代死板色块)
    local function ApplyGradientOverlay(name, size, pos, colors, dir)
        local f = Instance.new("Frame")
        f.Name = name
        f.Size = size
        f.Position = pos
        f.BorderSizePixel = 0
        f.BackgroundTransparency = 0
        f.ZIndex = 3
        f.Parent = self.Main
        
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(colors[1], colors[2])
        g.Transparency = NumberSequence.new(0, 1) -- 从不透明到全透明
        g.Rotation = dir
        g.Parent = f
        return f
    end

    -- 上下 45px 渐变 (向中心透明)
    self.TopBar = ApplyGradientOverlay("TopGrad", UDim2.new(1,0,0,45), UDim2.new(0,0,0,0), {Theme.Deep, Theme.Main}, 90)
    self.BottomBar = ApplyGradientOverlay("BottomGrad", UDim2.new(1,0,0,45), UDim2.new(0,0,1,-45), {Theme.Deep, Theme.Main}, -90)

    -- 侧边栏渐变 (向右透明)
    self.SidebarGrad = Instance.new("Frame")
    self.SidebarGrad.Size = UDim2.new(0, 160, 1, 0)
    self.SidebarGrad.BackgroundColor3 = Theme.Light
    self.SidebarGrad.BorderSizePixel = 0
    self.SidebarGrad.ZIndex = 2
    self.SidebarGrad.Parent = self.Main
    local sg = Instance.new("UIGradient")
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    sg.Parent = self.SidebarGrad

    -- 5. 交互元素
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 45)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = self.ProjectName
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.ZIndex = 4
    title.Parent = self.Main

    -- 缩小/关闭按钮 (隐藏式设计)
    local function CreateControl(text, pos, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 25, 0, 25)
        b.Position = pos
        b.BackgroundTransparency = 0.6
        b.BackgroundColor3 = color
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.new(1,1,1)
        b.ZIndex = 4
        b.Parent = self.Main
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        return b
    end

    local closeBtn = CreateControl("×", UDim2.new(1, -35, 0, 10), Color3.fromRGB(255, 100, 100))
    local minBtn = CreateControl("-", UDim2.new(1, -70, 0, 10), Theme.Accent)

    -- 6. 内容容器 (可滑动)
    self.SideScroll = Instance.new("ScrollingFrame")
    self.SideScroll.Size = UDim2.new(0, 140, 1, -100)
    self.SideScroll.Position = UDim2.new(0, 10, 0, 50)
    self.SideScroll.BackgroundTransparency = 1
    self.SideScroll.BorderSizePixel = 0
    self.SideScroll.CanvasSize = UDim2.new(0,0,0,0)
    self.SideScroll.ScrollBarThickness = 0
    self.SideScroll.ZIndex = 4
    self.SideScroll.Parent = self.Main
    Instance.new("UIListLayout", self.SideScroll).Padding = UDim.new(0, 8)

    self.ContentScroll = Instance.new("ScrollingFrame")
    self.ContentScroll.Size = UDim2.new(1, -180, 1, -110)
    self.ContentScroll.Position = UDim2.new(0, 165, 0, 55)
    self.ContentScroll.BackgroundTransparency = 1
    self.ContentScroll.BorderSizePixel = 0
    self.ContentScroll.CanvasSize = UDim2.new(0,0,0,0)
    self.ContentScroll.ScrollBarThickness = 2
    self.ContentScroll.ScrollBarImageColor3 = Theme.Accent
    self.ContentScroll.ZIndex = 4
    self.ContentScroll.Parent = self.Main
    Instance.new("UIListLayout", self.ContentScroll).Padding = UDim.new(0, 12)

    -- 7. 动画逻辑实现
    minBtn.MouseButton1Click:Connect(function()
        local targetPos = self.MiniFrame.Position
        Anim(self.Main, 0.6, "Back", "In", {
            Size = UDim2.new(0, 40, 0, 40),
            Position = targetPos,
            BackgroundTransparency = 1
        }).Completed:Connect(function()
            self.Main.Visible = false
            self.MiniFrame.Visible = true
            Anim(self.MiniFrame, 0.5, "Elastic", "Out", {Size = UDim2.new(0, 55, 0, 55)})
        end)
    end)

    self.MiniFrame.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.MiniFrame.Visible = false
        self.Main.BackgroundTransparency = 0
        Anim(self.Main, 0.7, "Elastic", "Out", {
            Size = UDim2.new(0, 550, 0, 350),
            Position = UDim2.new(0.5, -275, 0.5, -175)
        })
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Anim(self.Main, 0.4, "Back", "In", {Size = UDim2.new(0,0,0,0), Rotation = 15})
        task.wait(0.4)
        self.Gui:Destroy()
    end)

    -- 拖动支持
    local dragging, dragInput, dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return self
end

-- // 加载动画：顶级灵魂粒子效果 // --
function SOUL_Lib:PlayLoading()
    local load = Instance.new("Frame")
    load.Size = UDim2.new(0, 0, 0, 0)
    load.Position = UDim2.new(0.5, 0, 0.5, 0)
    load.BackgroundColor3 = Theme.Accent
    load.Parent = self.Gui
    local c = Instance.new("UICorner", load)
    c.CornerRadius = UDim.new(1, 0)
    
    -- 呼吸扩散效果
    Anim(load, 1.2, "Elastic", "Out", {Size = UDim2.new(0, 120, 0, 120), Position = UDim2.new(0.5, -60, 0.5, -60)})
    task.wait(1)
    Anim(load, 0.5, "Quart", "In", {Size = UDim2.new(0, 2000, 0, 2000), Position = UDim2.new(0.5, -1000, 0.5, -1000), BackgroundTransparency = 1})
    
    task.wait(0.2)
    self.Main.Visible = true
    Anim(self.Main, 0.8, "Elastic", "Out", {Size = UDim2.new(0, 550, 0, 350)})
end

-- // 组件系统 // --
function SOUL_Lib:AddTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.ZIndex = 5
    btn.Parent = self.SideScroll
    
    -- 点击动画
    btn.MouseButton1Click:Connect(function()
        local originalColor = btn.TextColor3
        Anim(btn, 0.2, "Quad", "Out", {TextColor3 = Theme.Accent})
        task.wait(0.2)
        Anim(btn, 0.2, "Quad", "Out", {TextColor3 = originalColor})
    end)
    
    self.SideScroll.CanvasSize = UDim2.new(0,0,0, self.SideScroll.UIListLayout.AbsoluteContentSize.Y)
    return btn
end

function SOUL_Lib:AddButton(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.new(1,1,1)
    b.BackgroundTransparency = 0.4
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextColor3 = Theme.Text
    b.ZIndex = 5
    b.Parent = self.ContentScroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    
    b.MouseButton1Click:Connect(function()
        Anim(b, 0.1, "Quad", "Out", {Size = UDim2.new(0.9, 0, 0, 35)})
        task.wait(0.1)
        Anim(b, 0.1, "Quad", "Out", {Size = UDim2.new(1, 0, 0, 40)})
        callback()
    end)
    
    self.ContentScroll.CanvasSize = UDim2.new(0,0,0, self.ContentScroll.UIListLayout.AbsoluteContentSize.Y)
end

return SOUL_Lib
