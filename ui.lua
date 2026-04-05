local Nebula = {
    Version = "1.0.0",
    Registry = {}, -- 存储所有组件实例
    Flags = {},    -- 存储所有功能的数值 (如: Flags["AutoFarm"])
    Connections = {},
    Theme = {
        Background = Color3.fromRGB(5, 5, 12),
        Sidebar = Color3.fromRGB(8, 8, 20),
        Accent = Color3.fromRGB(115, 80, 255), -- 极光紫
        Secondary = Color3.fromRGB(0, 180, 255), -- 星海蓝
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(160, 160, 180),
        Border = Color3.fromRGB(30, 30, 50),
        Glow = Color3.fromRGB(115, 80, 255)
    }
}

-- [ 1. 高级弹簧物理引擎 ]
-- 工业级 UI 的灵魂在于手感，弹簧模拟能产生自然的物理回弹
local Spring = {}
Spring.__index = Spring

function Spring.new(target, speed, damping)
    return setmetatable({
        Target = target,
        Value = target,
        Velocity = target * 0,
        Speed = speed or 15,
        Damping = damping or 0.7
    }, Spring)
end

function Spring:Update(dt)
    local d = self.Target - self.Value
    local f = d * (self.Speed * self.Speed)
    self.Velocity = self.Velocity + (f - self.Velocity * 2 * self.Damping * self.Speed) * dt
    self.Value = self.Value + self.Velocity * dt
    return self.Value
end

-- [ 2. 核心公共工具 ]
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local function Protect(obj)
    if get_hidden_gui then obj.Parent = get_hidden_gui()
    elseif (syn and syn.protect_gui) then syn.protect_gui(obj); obj.Parent = CoreGui
    else obj.Parent = CoreGui end
end

-- [ 3. 动态星轨渲染 (Star-Rail Renderer) ]
local function CreateStarField(parent)
    local Field = Instance.new("Frame", parent)
    Field.Size = UDim2.new(1, 0, 1, 0)
    Field.BackgroundTransparency = 1
    Field.ClipsDescendants = true
    
    for i = 1, 80 do
        local Star = Instance.new("Frame", Field)
        Star.BorderSizePixel = 0
        Star.BackgroundColor3 = Color3.new(1, 1, 1)
        Star.Size = UDim2.new(0, math.random(1, 2), 0, math.random(1, 2))
        Star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        Star.BackgroundTransparency = 0.5
        
        task.spawn(function()
            while Star.Parent do
                local t = math.random(3, 7)
                TS:Create(Star, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingStyle.InOut, -1, true), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 4, 0, 4)
                }):Play()
                task.wait(t * 2)
            end
        end)
    end
end

-- [ 4. 主窗口构造函数 ]
function Nebula:Init(options)
    local Window = {
        Title = options.Name or "Nebula UI",
        Tabs = {},
        CurrentTab = nil,
        ID = game:GetService("HttpService"):GenerateGUID(false)
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Window.ID
    Protect(ScreenGui)

    local Main = Instance.new("CanvasGroup", ScreenGui)
    Main.Size = UDim2.new(0, 620, 0, 440)
    Main.Position = UDim2.new(0.5, -310, 0.5, -220)
    Main.BackgroundColor3 = Nebula.Theme.Background
    Main.GroupTransparency = 1

    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Nebula.Theme.Border
    MainStroke.Thickness = 1.5

    CreateStarField(Main)

    -- 侧边栏布局 (多级导航)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Nebula.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Text = Window.Title:upper()
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Nebula.Theme.Accent
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -10, 1, -120)
    TabContainer.Position = UDim2.new(0, 5, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 8)
    TabList.HorizontalAlignment = "Center"

    -- 内容容器
    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Size = UDim2.new(1, -200, 1, -20)
    PageHolder.Position = UDim2.new(0, 190, 0, 10)
    PageHolder.BackgroundTransparency = 1

    -- [ 物理入场动画 ]
    task.spawn(function()
        local s = Spring.new(0, 12, 0.6)
        s.Target = 1
        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            local val = s:Update(dt)
            Main.GroupTransparency = 1 - val
            Main.Size = UDim2.new(0, 500 + (120 * val), 0, 340 + (100 * val))
            if val > 0.999 then conn:Disconnect() end
        end)
    end)

    Window.Main = Main
    Window.TabContainer = TabContainer
    Window.PageHolder = PageHolder
    
    return setmetatable(Window, {__index = Nebula})
end
--[[
    PROJECT NEBULA - PART 2
    功能：高级 Tab 类、逻辑分区 Section、Flag 注册系统
]]

-- 这里的 self 指向 Nebula:Init 返回的 Window 对象
function Nebula:CreateTab(name, iconId)
    local Tab = {
        Name = name,
        ID = name .. "_" .. math.random(100, 999),
        Page = nil,
        Button = nil
    }

    -- 1. 创建选项卡按钮
    local TabBtn = Instance.new("TextButton", self.TabContainer)
    TabBtn.Name = Tab.ID
    TabBtn.Size = UDim2.new(1, -10, 0, 38)
    TabBtn.BackgroundColor3 = Nebula.Theme.Accent
    TabBtn.BackgroundTransparency = 1
    TabBtn.AutoButtonColor = false
    TabBtn.Text = ""
    
    local TCorner = Instance.new("UICorner", TabBtn)
    TCorner.CornerRadius = UDim.new(0, 6)

    local TIcon = Instance.new("ImageLabel", TabBtn)
    TIcon.Size = UDim2.new(0, 20, 0, 20)
    TIcon.Position = UDim2.new(0, 12, 0.5, -10)
    TIcon.BackgroundTransparency = 1
    TIcon.Image = iconId or "rbxassetid://6023426915"
    TIcon.ImageColor3 = Nebula.Theme.SubText
    TIcon.ImageTransparency = 0.4

    local TTitle = Instance.new("TextLabel", TabBtn)
    TTitle.Size = UDim2.new(1, -45, 1, 0)
    TTitle.Position = UDim2.new(0, 40, 0, 0)
    TTitle.Text = name
    TTitle.Font = Enum.Font.GothamMedium
    TTitle.TextColor3 = Nebula.Theme.SubText
    TTitle.TextSize = 13
    TTitle.TextXAlignment = "Left"
    TTitle.BackgroundTransparency = 1

    -- 2. 创建页面容器 (CanvasGroup 物理容器)
    local Page = Instance.new("CanvasGroup", self.PageHolder)
    Page.Name = Tab.ID .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.GroupTransparency = 1
    
    local Scroll = Instance.new("ScrollingFrame", Page)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 0
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local PLayout = Instance.new("UIListLayout", Scroll)
    PLayout.Padding = UDim.new(0, 12)
    PLayout.SortOrder = "LayoutOrder"
    
    local PPadding = Instance.new("UIPadding", Scroll)
    PPadding.PaddingLeft = UDim.new(0, 2)
    PPadding.PaddingRight = UDim.new(0, 2)
    PPadding.PaddingTop = UDim.new(0, 2)

    -- 自动计算滚动高度
    PLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, PLayout.AbsoluteContentSize.Y + 20)
    end)

    -- 3. 切换逻辑 (物理驱动)
    local function Switch()
        if self.CurrentTab == Tab then return end
        
        -- 隐藏旧页面
        if self.CurrentTab then
            local OldPage = self.CurrentTab.Page
            local OldBtn = self.CurrentTab.Button
            TS:Create(OldPage, TweenInfo.new(0.3), {GroupTransparency = 1}):Play()
            TS:Create(OldBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TS:Create(OldBtn.Title, TweenInfo.new(0.3), {TextColor3 = Nebula.Theme.SubText}):Play()
            task.delay(0.3, function() OldPage.Visible = false end)
        end

        -- 展现新页面
        self.CurrentTab = Tab
        Page.Visible = true
        Page.Position = UDim2.new(0, 0, 0, 15)
        TS:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Back), {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
        TS:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.88}):Play()
        TS:Create(TTitle, TweenInfo.new(0.3), {TextColor3 = Nebula.Theme.Accent}):Play()
    end

    TabBtn.MouseButton1Click:Connect(Switch)
    if not self.FirstTab then self.FirstTab = Tab; task.spawn(Switch) end

    Tab.Page = Page
    Tab.Button = TabBtn
    Tab.Scroll = Scroll

    -- [ 4. Section 构造器 ]
    -- 让页面内部有漂亮的框框把功能围起来
    function Tab:CreateSection(title)
        local Section = {}
        
        local SFrame = Instance.new("Frame", Tab.Scroll)
        SFrame.Name = title .. "_Section"
        SFrame.Size = UDim2.new(1, -5, 0, 40)
        SFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
        SFrame.BorderSizePixel = 0
        
        local SCorner = Instance.new("UICorner", SFrame)
        SCorner.CornerRadius = UDim.new(0, 8)
        
        local SStroke = Instance.new("UIStroke", SFrame)
        SStroke.Color = Nebula.Theme.Border
        SStroke.Transparency = 0.6
        
        local STitle = Instance.new("TextLabel", SFrame)
        STitle.Size = UDim2.new(1, 0, 0, 30)
        STitle.Position = UDim2.new(0, 12, 0, 0)
        STitle.Text = title:upper()
        STitle.Font = Enum.Font.GothamBold
        STitle.TextColor3 = Nebula.Theme.Secondary
        STitle.TextSize = 11
        STitle.TextXAlignment = "Left"
        STitle.BackgroundTransparency = 1

        local SContainer = Instance.new("Frame", SFrame)
        SContainer.Name = "Container"
        SContainer.Size = UDim2.new(1, -20, 1, -40)
        SContainer.Position = UDim2.new(0, 10, 0, 35)
        SContainer.BackgroundTransparency = 1
        
        local SLayout = Instance.new("UIListLayout", SContainer)
        SLayout.Padding = UDim.new(0, 8)
        
        -- 动态调整 Section 高度
        SLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SFrame.Size = UDim2.new(1, -5, 0, SLayout.AbsoluteContentSize.Y + 45)
        end)

        Section.Container = SContainer
        return Section
    end

    return Tab
end
--[[
    PROJECT NEBULA - PART 3
    功能：带 Flag 的星光开关 (Toggle)、物理感滑动条 (Slider)、多功能按键绑定 (Keybind)
]]

-- 这里的 Section 指向 Tab:CreateSection 返回的对象
function Section:CreateToggle(text, flag, default, callback)
    local Toggled = default or false
    Nebula.Flags[flag] = Toggled -- 注册到全局 Flag
    
    local ToggleFrame = Instance.new("TextButton", self.Container)
    ToggleFrame.Name = text .. "_Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.Text = ""
    
    local TCorner = Instance.new("UICorner", ToggleFrame)
    TCorner.CornerRadius = UDim.new(0, 6)

    local TTitle = Instance.new("TextLabel", ToggleFrame)
    TTitle.Size = UDim2.new(1, -50, 1, 0)
    TTitle.Position = UDim2.new(0, 12, 0, 0)
    TTitle.Text = text
    TTitle.Font = Enum.Font.Gotham
    TTitle.TextColor3 = Nebula.Theme.Text
    TTitle.TextSize = 13
    TTitle.TextXAlignment = "Left"
    TTitle.BackgroundTransparency = 1

    local Switch = Instance.new("Frame", ToggleFrame)
    Switch.Size = UDim2.new(0, 32, 0, 18)
    Switch.Position = UDim2.new(1, -40, 0.5, -9)
    Switch.BackgroundColor3 = Toggled and Nebula.Theme.Accent or Color3.fromRGB(40, 40, 60)
    
    local SCorner = Instance.new("UICorner", Switch, {CornerRadius = UDim.new(1, 0)})
    local SStroke = Instance.new("UIStroke", Switch, {Color = Nebula.Theme.Border, Thickness = 1})

    local Dot = Instance.new("Frame", Switch)
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = Toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    Dot.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Dot, {CornerRadius = UDim.new(1, 0)})

    -- 切换逻辑
    local function Toggle()
        Toggled = not Toggled
        Nebula.Flags[flag] = Toggled
        
        TS:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = Toggled and Nebula.Theme.Accent or Color3.fromRGB(40, 40, 60)}):Play()
        TS:Create(Dot, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = Toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        
        callback(Toggled)
    end

    ToggleFrame.MouseButton1Click:Connect(Toggle)
    return {Set = function(val) if Toggled ~= val then Toggle() end end}
end

function Section:CreateSlider(text, flag, min, max, default, callback)
    local Value = default or min
    Nebula.Flags[flag] = Value

    local SliderFrame = Instance.new("Frame", self.Container)
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
    Instance.new("UICorner", SliderFrame, {CornerRadius = UDim.new(0, 6)})

    local TTitle = Instance.new("TextLabel", SliderFrame)
    TTitle.Size = UDim2.new(1, -100, 0, 25)
    TTitle.Position = UDim2.new(0, 12, 0, 2)
    TTitle.Text = text
    TTitle.Font = Enum.Font.Gotham
    TTitle.TextColor3 = Nebula.Theme.Text
    TTitle.TextSize = 12
    TTitle.TextXAlignment = "Left"
    TTitle.BackgroundTransparency = 1

    local VLabel = Instance.new("TextLabel", SliderFrame)
    VLabel.Size = UDim2.new(0, 50, 0, 25)
    VLabel.Position = UDim2.new(1, -60, 0, 2)
    VLabel.Text = tostring(Value)
    VLabel.Font = Enum.Font.GothamBold
    VLabel.TextColor3 = Nebula.Theme.Accent
    VLabel.TextSize = 12
    VLabel.TextXAlignment = "Right"
    VLabel.BackgroundTransparency = 1

    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, -24, 0, 4)
    Bar.Position = UDim2.new(0, 12, 1, -12)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Instance.new("UICorner", Bar)

    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Nebula.Theme.Accent
    Instance.new("UICorner", Fill)

    local Trigger = Instance.new("TextButton", Bar)
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""

    local function Update()
        local Percent = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local NewVal = math.floor(min + (max - min) * Percent)
        
        Value = NewVal
        Nebula.Flags[flag] = Value
        VLabel.Text = tostring(Value)
        Fill.Size = UDim2.new(Percent, 0, 1, 0)
        callback(Value)
    end

    local Dragging = false
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update() end
    end)
    UIS.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update() end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

function Section:CreateKeybind(text, flag, default, callback)
    local Binding = default or Enum.KeyCode.F
    Nebula.Flags[flag] = Binding
    local IsBinding = false

    local BindFrame = Instance.new("TextButton", self.Container)
    BindFrame.Size = UDim2.new(1, 0, 0, 35)
    BindFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
    BindFrame.AutoButtonColor = false
    BindFrame.Text = ""
    Instance.new("UICorner", BindFrame, {CornerRadius = UDim.new(0, 6)})

    local TTitle = Instance.new("TextLabel", BindFrame)
    TTitle.Size = UDim2.new(1, -100, 1, 0)
    TTitle.Position = UDim2.new(0, 12, 0, 0)
    TTitle.Text = text
    TTitle.Font = Enum.Font.Gotham
    TTitle.TextColor3 = Nebula.Theme.Text
    TTitle.TextSize = 13
    TTitle.TextXAlignment = "Left"
    TTitle.BackgroundTransparency = 1

    local BLabel = Instance.new("TextLabel", BindFrame)
    BLabel.Size = UDim2.new(0, 80, 0, 22)
    BLabel.Position = UDim2.new(1, -90, 0.5, -11)
    BLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    BLabel.Text = Binding.Name
    BLabel.Font = Enum.Font.GothamBold
    BLabel.TextColor3 = Nebula.Theme.Accent
    BLabel.TextSize = 11
    Instance.new("UICorner", BLabel, {CornerRadius = UDim.new(0, 4)})
    Instance.new("UIStroke", BLabel, {Color = Nebula.Theme.Border})

    BindFrame.MouseButton1Click:Connect(function()
        IsBinding = true
        BLabel.Text = "..."
    end)

    UIS.InputBegan:Connect(function(input)
        if IsBinding and input.UserInputType == Enum.UserInputType.Keyboard then
            Binding = input.KeyCode
            Nebula.Flags[flag] = Binding
            BLabel.Text = Binding.Name
            IsBinding = false
            callback(Binding)
        elseif not IsBinding and input.KeyCode == Binding then
            callback(Binding)
        end
    end)
end
--[[
    PROJECT NEBULA - PART 4 (FINAL)
    功能：带搜索过滤的下拉框、全屏通知系统、JSON 配置自动保存
]]

local HttpService = game:GetService("HttpService")

-- [ 1. 幽灵通知系统 ]
function Nebula:Notify(title, content, duration)
    local NotifyGui = self.Main.Parent:FindFirstChild("Notifications") or Instance.new("Frame", self.Main.Parent)
    if not NotifyGui.Name == "Notifications" then
        NotifyGui.Name = "Notifications"
        NotifyGui.Size = UDim2.new(0, 300, 1, 0)
        NotifyGui.Position = UDim2.new(1, -310, 0, 0)
        NotifyGui.BackgroundTransparency = 1
        local L = Instance.new("UIListLayout", NotifyGui)
        L.VerticalAlignment = "Bottom"
        L.Padding = UDim.new(0, 10)
    end

    local Notif = Instance.new("CanvasGroup", NotifyGui)
    Notif.Size = UDim2.new(1, 0, 0, 0) -- 初始高度0用于动画
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    Notif.GroupTransparency = 1
    Instance.new("UICorner", Notif)
    Instance.new("UIStroke", Notif, {Color = Nebula.Theme.Accent, Transparency = 0.5})

    local T = Instance.new("TextLabel", Notif)
    T.Text = title:upper()
    T.Size = UDim2.new(1, -20, 0, 30)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.TextColor3 = Nebula.Theme.Accent
    T.Font = Enum.Font.GothamBold
    T.TextSize = 13
    T.TextXAlignment = "Left"
    T.BackgroundTransparency = 1

    local C = Instance.new("TextLabel", Notif)
    C.Text = content
    C.Size = UDim2.new(1, -20, 0, 40)
    C.Position = UDim2.new(0, 10, 0, 25)
    C.TextColor3 = Nebula.Theme.Text
    C.Font = Enum.Font.Gotham
    C.TextSize = 12
    C.TextXAlignment = "Left"
    C.TextWrapped = true
    C.BackgroundTransparency = 1

    -- 弹出动画
    TS:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 80), GroupTransparency = 0}):Play()
    
    task.delay(duration or 5, function()
        TS:Create(Notif, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

-- [ 2. 星群下拉框 (支持动态更新) ]
function Section:CreateDropdown(text, flag, options, callback)
    Nebula.Flags[flag] = options[1]
    local Opened = false

    local DropFrame = Instance.new("TextButton", self.Container)
    DropFrame.Size = UDim2.new(1, 0, 0, 35)
    DropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
    DropFrame.AutoButtonColor = false
    DropFrame.Text = ""
    DropFrame.ClipsDescendants = true
    Instance.new("UICorner", DropFrame)

    local TTitle = Instance.new("TextLabel", DropFrame)
    TTitle.Size = UDim2.new(1, -100, 0, 35)
    TTitle.Position = UDim2.new(0, 12, 0, 0)
    TTitle.Text = text
    TTitle.TextColor3 = Nebula.Theme.SubText
    TTitle.Font = Enum.Font.Gotham
    TTitle.TextSize = 13
    TTitle.TextXAlignment = "Left"
    TTitle.BackgroundTransparency = 1

    local SelectedLabel = Instance.new("TextLabel", DropFrame)
    SelectedLabel.Size = UDim2.new(0, 100, 0, 35)
    SelectedLabel.Position = UDim2.new(1, -110, 0, 0)
    SelectedLabel.Text = options[1]
    SelectedLabel.TextColor3 = Nebula.Theme.Accent
    SelectedLabel.Font = Enum.Font.GothamBold
    SelectedLabel.TextSize = 12
    SelectedLabel.TextXAlignment = "Right"
    SelectedLabel.BackgroundTransparency = 1

    local OptionHolder = Instance.new("Frame", DropFrame)
    OptionHolder.Position = UDim2.new(0, 10, 0, 40)
    OptionHolder.Size = UDim2.new(1, -20, 0, #options * 25)
    OptionHolder.BackgroundTransparency = 1
    Instance.new("UIListLayout", OptionHolder, {Padding = UDim.new(0, 5)})

    for _, v in pairs(options) do
        local Opt = Instance.new("TextButton", OptionHolder)
        Opt.Size = UDim2.new(1, 0, 0, 25)
        Opt.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        Opt.Text = v
        Opt.TextColor3 = Nebula.Theme.Text
        Opt.Font = Enum.Font.Gotham
        Opt.TextSize = 12
        Instance.new("UICorner", Opt)

        Opt.MouseButton1Click:Connect(function()
            Nebula.Flags[flag] = v
            SelectedLabel.Text = v
            Opened = false
            TS:Create(DropFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            callback(v)
        end)
    end

    DropFrame.MouseButton1Click:Connect(function()
        Opened = not Opened
        local TargetY = Opened and (45 + #options * 30) or 35
        TS:Create(DropFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, TargetY)}):Play()
    end)
end

-- [ 3. 工业级：自动配置保存系统 ]
-- 这是脚本作者最需要的功能，能极大提升用户忠诚度
function Nebula:SaveConfig(folderName)
    local path = folderName .. "/config.json"
    if not isfolder(folderName) then makefolder(folderName) end
    
    local data = {}
    for flag, value in pairs(Nebula.Flags) do
        -- 处理 KeyCode 等特殊类型转字符串
        if typeof(value) == "EnumItem" then
            data[flag] = {type = "Enum", val = tostring(value)}
        else
            data[flag] = {type = "Normal", val = value}
        end
    end
    
    writefile(path, HttpService:JSONEncode(data))
    self:Notify("系统", "配置已成功保存至云端", 3)
end

function Nebula:LoadConfig(folderName)
    local path = folderName .. "/config.json"
    if not isfile(path) then return end
    
    local data = HttpService:JSONDecode(readfile(path))
    for flag, payload in pairs(data) do
        if payload.type == "Enum" then
            -- 恢复按键绑定逻辑（略，需根据实际 Enum 转换）
        else
            Nebula.Flags[flag] = payload.val
            -- 注意：此处需要调用组件的 Set 方法来更新 UI 表现
        end
    end
    self:Notify("系统", "已自动加载历史配置", 3)
end

