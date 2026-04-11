--[[
    SOUL UI LIBRARY - Premium Edition
    Theme: Light Pink & Soul Essence
    Features: Mobile Friendly, Smooth Animations, Sidebar Gradients, Script Hub
]]

local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // 颜色主题配置 // --
local Theme = {
    Main = Color3.fromRGB(255, 230, 235),      -- 淡粉色
    Borders = Color3.fromRGB(255, 185, 200),   -- 稍深一丢丢的淡粉色 (45px边框用)
    Sidebar = Color3.fromRGB(255, 245, 250),   -- 稍浅一丢丢的淡粉色 (侧边栏用)
    Accent = Color3.fromRGB(255, 105, 180),    -- 灵魂强调色
    Text = Color3.fromRGB(80, 80, 80),         -- 文本色
    White = Color3.fromRGB(255, 255, 255)
}

-- // 工具函数 // --
local function Tween(obj, info, prop)
    local t = TweenService:Create(obj, TweenInfo.new(unpack(info)), prop)
    t:Play()
    return t
end

-- // 构造函数 // --
function SOUL_Lib.new(projectName)
    local self = setmetatable({}, SOUL_Lib)
    self.ProjectName = projectName or "SOUL"
    self.Tabs = {}
    self.CurrentTab = nil

    -- 1. 创建 ScreenGui (挂载在 CoreGui 确保外挂不被删除)
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SOUL_" .. math.random(1000, 9999)
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 2. 主框架
    self.Main = Instance.new("Frame")
    self.Main.Name = "MainFrame"
    self.Main.Size = UDim2.new(0, 550, 0, 350)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    self.Main.BackgroundColor3 = Theme.Main
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Active = true
    self.Main.Visible = false -- 初始不可见，等待加载动画
    self.Main.Parent = self.Gui
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 15)

    -- 整个悬浮窗拖动功能 (支持手机)
    local dragStart, startPos
    self.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = self.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 3. 上下 45px 边框
    local function CreateBar(pos, name)
        local bar = Instance.new("Frame")
        bar.Name = name
        bar.Size = UDim2.new(1, 0, 0, 45)
        bar.Position = pos
        bar.BackgroundColor3 = Theme.Borders
        bar.BorderSizePixel = 0
        bar.ZIndex = 5
        bar.Parent = self.Main
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 15)
        -- 遮盖多余圆角
        local cover = Instance.new("Frame")
        cover.Size = UDim2.new(1, 0, 0, 10)
        cover.Position = (name == "TopBar") and UDim2.new(0,0,1,-10) or UDim2.new(0,0,0,0)
        cover.BackgroundColor3 = Theme.Borders
        cover.BorderSizePixel = 0
        cover.Parent = bar
        return bar
    end

    self.TopBar = CreateBar(UDim2.new(0, 0, 0, 0), "TopBar")
    self.BottomBar = CreateBar(UDim2.new(0, 0, 1, -45), "BottomBar")

    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PROJECT: " .. self.ProjectName
    title.TextColor3 = Theme.Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.TopBar

    -- 4. 控制按钮 (缩小/关闭)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(0, 80, 1, 0)
    btnContainer.Position = UDim2.new(1, -90, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.Parent = self.TopBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(0.5, 5, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.White
    closeBtn.Parent = btnContainer
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(0, 0, 0.5, -15)
    minBtn.BackgroundColor3 = Theme.Accent
    minBtn.Text = "-"
    minBtn.TextColor3 = Theme.White
    minBtn.Parent = btnContainer
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

    -- 5. 侧边栏与显示区域
    -- 侧边栏 (可滑动)
    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Size = UDim2.new(0, 150, 1, -90)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 45)
    self.Sidebar.BackgroundColor3 = Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Sidebar.ScrollBarThickness = 2
    self.Sidebar.ScrollBarImageColor3 = Theme.Accent
    self.Sidebar.Parent = self.Main
    local sLayout = Instance.new("UIListLayout", self.Sidebar)
    sLayout.Padding = UDim.new(0, 5)
    sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- 渐变条 (侧边栏与右侧显示区域的颜色渐变)
    local gradientFrame = Instance.new("Frame")
    gradientFrame.Size = UDim2.new(0, 10, 1, -90)
    gradientFrame.Position = UDim2.new(0, 150, 0, 45)
    gradientFrame.BorderSizePixel = 0
    gradientFrame.ZIndex = 4
    gradientFrame.Parent = self.Main
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(Theme.Sidebar, Theme.Main)
    g.Parent = gradientFrame

    -- 显示区域总容器
    self.DisplayArea = Instance.new("Frame")
    self.DisplayArea.Size = UDim2.new(1, -165, 1, -100)
    self.DisplayArea.Position = UDim2.new(0, 160, 0, 50)
    self.DisplayArea.BackgroundTransparency = 1
    self.DisplayArea.Parent = self.Main

    -- 缩小化后的占位符
    self.MiniIcon = Instance.new("TextButton")
    self.MiniIcon.Size = UDim2.new(0, 60, 0, 60)
    self.MiniIcon.Position = UDim2.new(0.9, 0, 0.5, 0)
    self.MiniIcon.BackgroundColor3 = Theme.Accent
    self.MiniIcon.Text = "SOUL"
    self.MiniIcon.Font = Enum.Font.GothamBold
    self.MiniIcon.TextColor3 = Theme.White
    self.MiniIcon.Visible = false
    self.MiniIcon.Parent = self.Gui
    Instance.new("UICorner", self.MiniIcon).CornerRadius = UDim.new(0, 15)
    self.MiniIcon.Draggable = true

    -- // 功能逻辑实现 // --

    -- 缩小/展开动画
    minBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, {0.5, Enum.EasingStyle.Back}, {Size = UDim2.new(0,0,0,0), Position = self.MiniIcon.Position})
        task.wait(0.4)
        self.Main.Visible = false
        self.MiniIcon.Visible = true
    end)

    self.MiniIcon.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.MiniIcon.Visible = false
        Tween(self.Main, {0.5, Enum.EasingStyle.OutBack}, {Size = UDim2.new(0, 550, 0, 350), Position = UDim2.new(0.5, -275, 0.5, -175)})
    end)

    -- 关闭
    closeBtn.MouseButton1Click:Connect(function()
        Tween(self.Main, {0.3, Enum.EasingStyle.Quart}, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
        task.wait(0.3)
        self.Gui:Destroy()
    end)

    return self
end

-- // 创建栏目 (Tab) // --
function SOUL_Lib:CreateTab(name)
    local tab = {}
    
    -- 侧边栏按钮
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.9, 0, 0, 40)
    tabBtn.BackgroundColor3 = Theme.Accent
    tabBtn.BackgroundTransparency = 0.9
    tabBtn.Text = name
    tabBtn.TextColor3 = Theme.Text
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.Parent = self.Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

    -- 右侧可滑动内容区域
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.ScrollBarThickness = 3
    container.Visible = false
    container.Parent = self.DisplayArea
    local cLayout = Instance.new("UIListLayout", container)
    cLayout.Padding = UDim.new(0, 10)
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tab.Container = container
    
    -- 切换栏目逻辑
    tabBtn.MouseButton1Click:Connect(function()
        for _, otherTab in pairs(self.Tabs) do
            otherTab.Container.Visible = false
            otherTab.Btn.BackgroundTransparency = 0.9
        end
        container.Visible = true
        tabBtn.BackgroundTransparency = 0.5 -- 选中效果显著
        -- 切换动画
        container.Position = UDim2.new(0, 20, 0, 0)
        Tween(container, {0.3, Enum.EasingStyle.Quad}, {Position = UDim2.new(0, 0, 0, 0)})
    end)

    -- 自动更新滚动大小
    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 20)
    end)

    tab.Btn = tabBtn
    table.insert(self.Tabs, tab)

    -- 默认选中第一个
    if #self.Tabs == 1 then
        container.Visible = true
        tabBtn.BackgroundTransparency = 0.5
    end

    return tab
end

-- // 按钮组件: 点击触发 // --
function SOUL_Lib:CreateButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Theme.White
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.Parent = tab.Container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    -- 点击动画
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {0.1}, {Size = UDim2.new(0.9, 0, 0, 35)})
        task.wait(0.1)
        Tween(btn, {0.1}, {Size = UDim2.new(0.95, 0, 0, 40)})
        callback()
    end)
end

-- // 按钮组件: 开关触发 (Toggle) // --
function SOUL_Lib:CreateToggle(tab, text, default, callback)
    local enabled = default or false
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.95, 0, 0, 40)
    toggleBtn.BackgroundColor3 = Theme.White
    toggleBtn.Text = "  " .. text
    toggleBtn.TextColor3 = Theme.Text
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    toggleBtn.Parent = tab.Container
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 40, 0, 20)
    status.Position = UDim2.new(1, -50, 0.5, -10)
    status.BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(200, 200, 200)
    status.Parent = toggleBtn
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Theme.White
    circle.Parent = status
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = enabled and Theme.Accent or Color3.fromRGB(200, 200, 200)
        
        Tween(circle, {0.2}, {Position = targetPos})
        Tween(status, {0.2}, {BackgroundColor3 = targetColor})
        callback(enabled)
    end)
end

-- // 脚本导入功能: 通过链接导入 // --
function SOUL_Lib:ImportLibrary(tab, libName, url)
    self:CreateButton(tab, "RUN: " .. libName, function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        if not success then warn("SOUL Loader Error: " .. err) end
    end)
end

-- // 炫酷启动动画 // --
function SOUL_Lib:PlayLoadingAnimation()
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 100, 0, 100)
    loadingFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
    loadingFrame.BackgroundTransparency = 1
    loadingFrame.Parent = self.Gui

    local soulOrb = Instance.new("Frame")
    soulOrb.Size = UDim2.new(0, 0, 0, 0)
    soulOrb.Position = UDim2.new(0.5, 0, 0.5, 0)
    soulOrb.BackgroundColor3 = Theme.Accent
    soulOrb.Parent = loadingFrame
    Instance.new("UICorner", soulOrb).CornerRadius = UDim.new(1, 0)

    -- 灵魂聚合动画
    Tween(soulOrb, {0.8, Enum.EasingStyle.Elastic}, {Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, -40, 0.5, -40)})
    task.wait(1)
    Tween(soulOrb, {0.5}, {BackgroundTransparency = 1, Size = UDim2.new(0, 500, 0, 500), Position = UDim2.new(0.5, -250, 0.5, -250)})
    
    task.wait(0.2)
    self.Main.Visible = true
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, {0.5, Enum.EasingStyle.Back}, {Size = UDim2.new(0, 550, 0, 350)})
    
    loadingFrame:Destroy()
end

-- // 必须在脚本末尾 return 库对象 // --
return SOUL_Lib
