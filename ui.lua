--[[
    ASTRAEA UI FRAMEWORK • ULTIMATE EDITION
    ---------------------------------------
    Version: 2.0.0 (Custom Build)
    Architecture: Adaptive OOP / GPU Accelerated
    Features: Acrylic Damping, Spring Physics, Modular API
]]

local Astraea = {
    Themes = {},
    Elements = {},
    Registry = {},
    Connections = {},
    LocalPlayer = game:GetService("Players").LocalPlayer,
    Mouse = game:GetService("Players").LocalPlayer:GetMouse(),
}

-- [1] 核心服务加载
local Services = setmetatable({}, {
    __index = function(t, k)
        return game:GetService(k)
    end
})

local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local CoreGui = Services.CoreGui
local HttpService = Services.HttpService

-- [2] 高级动效引擎 (Spring & Bezier)
local Lucide = {} -- 预留图标索引空间
local TweenLib = {
    Default = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Fast = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
}

-- [3] 主题引擎 (比原版更强大的配色字典)
Astraea.Themes = {
    Dark = {
        Main = Color3.fromHex("#08080A"),
        Secondary = Color3.fromHex("#0C0C0F"),
        Section = Color3.fromHex("#121217"),
        Accent = Color3.fromHex("#7B61FF"), -- 极光紫
        AccentLight = Color3.fromHex("#9B87FF"),
        Outline = Color3.fromHex("#1F1F26"),
        Text = Color3.fromHex("#FFFFFF"),
        TextDim = Color3.fromHex("#919199"),
        Success = Color3.fromHex("#00FFAA"),
        Danger = Color3.fromHex("#FF4B4B")
    },
    Midnight = {
        Main = Color3.fromHex("#050505"),
        Secondary = Color3.fromHex("#0A0A0A"),
        Section = Color3.fromHex("#0F0F0F"),
        Accent = Color3.fromHex("#00D1FF"), -- 冰晶蓝
        AccentLight = Color3.fromHex("#5EE4FF"),
        Outline = Color3.fromHex("#1A1A1A"),
        Text = Color3.fromHex("#FFFFFF"),
        TextDim = Color3.fromHex("#808080"),
        Success = Color3.fromHex("#2ECC71"),
        Danger = Color3.fromHex("#E74C3C")
    }
}

-- [4] 基础工具函数
local Utils = {}

function Utils.Create(cls, props)
    local inst = Instance.new(cls)
    for i, v in pairs(props) do
        if i ~= "Parent" then inst[i] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Utils.Tween(obj, info, goal)
    local t = TweenService:Create(obj, info, goal)
    t:Play()
    return t
end

-- 阻尼拖拽算法 (解决原版拖拽掉帧问题)
function Utils.MakeDraggable(obj, handler)
    local dragStart, startPos
    local dragging = false
    
    handler.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Utils.Tween(obj, TweenLib.Fast, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- [5] 窗口构造逻辑
function Astraea:CreateWindow(cfg)
    cfg = cfg or {}
    local Title = cfg.Title or "ASTRAEA PREMIUM"
    local Author = cfg.Author or "By Mister"
    local Theme = Astraea.Themes[cfg.Theme] or Astraea.Themes.Dark
    
    -- 保护性销毁
    if CoreGui:FindFirstChild("Astraea_Root") then
        CoreGui.Astraea_Root:Destroy()
    end

    local Screen = Utils.Create("ScreenGui", {
        Name = "Astraea_Root",
        Parent = CoreGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    })

    -- 主画布 (使用 CanvasGroup 优化渲染)
    local Main = Utils.Create("CanvasGroup", {
        Name = "Main",
        Parent = Screen,
        Size = UDim2.new(0, 680, 0, 460),
        Position = UDim2.new(0.5, -340, 0.5, -230),
        BackgroundColor3 = Theme.Main,
        GroupTransparency = 1,
        BorderSizePixel = 0
    })
    Utils.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
    Utils.Create("UIStroke", {Thickness = 1.2, Color = Theme.Outline, Parent = Main})

    -- 背景阴影层
    local Shadow = Utils.Create("ImageLabel", {
        Name = "Shadow",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://6015667343",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ZIndex = -1
    })

    -- 侧边栏
    local Sidebar = Utils.Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    })
    Utils.Create("Frame", {
        Name = "SplitLine",
        Parent = Sidebar,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Outline,
        BorderSizePixel = 0
    })

    -- 标题区域
    local TitleArea = Utils.Create("Frame", {
        Name = "TitleArea",
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1
    })
    
    Utils.Create("TextLabel", {
        Parent = TitleArea,
        Position = UDim2.new(0, 20, 0, 25),
        Size = UDim2.new(1, -40, 0, 20),
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    Utils.Create("TextLabel", {
        Parent = TitleArea,
        Position = UDim2.new(0, 20, 0, 45),
        Size = UDim2.new(1, -40, 0, 15),
        Text = Author,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    -- 选项卡滚动容器
    local TabScroll = Utils.Create("ScrollingFrame", {
        Name = "TabScroll",
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -100),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabList = Utils.Create("UIListLayout", {
        Parent = TabScroll,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    -- 内容容器
    local Container = Utils.Create("Frame", {
        Name = "Container",
        Parent = Main,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -200, 1, 0),
        BackgroundTransparency = 1
    })

    -- 入场动画
    Utils.Tween(Main, TweenLib.Smooth, {GroupTransparency = 0, Size = UDim2.new(0, 680, 0, 460)})
    Utils.MakeDraggable(Main, TitleArea)

    return {Main = Main, Container = Container, TabScroll = TabScroll, Theme = Theme}
end

local Window = {
    Tabs = {},
    ActiveTab = nil,
    Container = Container,
    TabScroll = TabScroll,
    Theme = Theme
}

-- [6] 选项卡创建逻辑
function Window:CreateTab(name, icon)
    local Tab = {
        Name = name,
        Instances = {},
        Active = false
    }

    -- 选项卡按钮渲染
    local TabBtn = Utils.Create("TextButton", {
        Name = name .. "_Tab",
        Parent = TabScroll,
        Size = UDim2.new(0, 180, 0, 40),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})

    local TabLabel = Utils.Create("TextLabel", {
        Parent = TabBtn,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -15, 1, 0),
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    -- 侧边激活指示条
    local Indicator = Utils.Create("Frame", {
        Parent = TabBtn,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Indicator})

    -- 页面容器
    local Page = Utils.Create("ScrollingFrame", {
        Name = name .. "_Page",
        Parent = Container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Outline,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local PageLayout = Utils.Create("UIListLayout", {
        Parent = Page,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Utils.Create("UIPadding", {
        Parent = Page,
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })

    -- 切换函数
    local function Activate()
        if Window.ActiveTab == Tab then return end
        
        if Window.ActiveTab then
            Window.ActiveTab.Page.Visible = false
            Utils.Tween(Window.ActiveTab.TabBtn, TweenLib.Fast, {BackgroundTransparency = 1})
            Utils.Tween(Window.ActiveTab.TabLabel, TweenLib.Fast, {TextColor3 = Theme.TextDim})
            Utils.Tween(Window.ActiveTab.Indicator, TweenLib.Fast, {Size = UDim2.new(0, 3, 0, 0)})
        end

        Window.ActiveTab = {TabBtn = TabBtn, TabLabel = TabLabel, Page = Page, Indicator = Indicator}
        Page.Visible = true
        Utils.Tween(TabBtn, TweenLib.Fast, {BackgroundTransparency = 0.92})
        Utils.Tween(TabLabel, TweenLib.Fast, {TextColor3 = Theme.Text})
        Utils.Tween(Indicator, TweenLib.Elastic, {Size = UDim2.new(0, 3, 0, 24)})
    end

    TabBtn.MouseButton1Click:Connect(Activate)
    if not Window.ActiveTab then Activate() end

    -- [7] 组件生成器 (Elements)
    local Elements = {}

    -- 7.1 标题分栏 (Section)
    function Elements:CreateSection(text)
        local SecFrame = Utils.Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.92, 0, 0, 30),
            BackgroundTransparency = 1
        })
        Utils.Create("TextLabel", {
            Parent = SecFrame,
            Size = UDim2.new(1, 0, 1, 0),
            Text = text:upper(),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end

    -- 7.2 高级按钮 (Button)
    function Elements:CreateButton(title, desc, callback)
        local Btn = Utils.Create("TextButton", {
            Parent = Page,
            Size = UDim2.new(0.92, 0, 0, 55),
            BackgroundColor3 = Theme.Section,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})
        Utils.Create("UIStroke", {Thickness = 1, Color = Theme.Outline, Parent = Btn})

        Utils.Create("TextLabel", {
            Parent = Btn,
            Position = UDim2.new(0, 15, 0, 12),
            Size = UDim2.new(1, -30, 0, 15),
            Text = title,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })

        Utils.Create("TextLabel", {
            Parent = Btn,
            Position = UDim2.new(0, 15, 0, 28),
            Size = UDim2.new(1, -30, 0, 15),
            Text = desc or "点击执行功能",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })

        -- 交互动画
        Btn.MouseEnter:Connect(function() Utils.Tween(Btn, TweenLib.Fast, {BackgroundColor3 = Theme.Outline}) end)
        Btn.MouseLeave:Connect(function() Utils.Tween(Btn, TweenLib.Fast, {BackgroundColor3 = Theme.Section}) end)
        Btn.MouseButton1Click:Connect(function()
            task.spawn(callback)
            -- 点击缩放反馈
            Utils.Tween(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0, 52)})
            task.wait(0.1)
            Utils.Tween(Btn, TweenLib.Fast, {Size = UDim2.new(0.92, 0, 0, 55)})
        end)

        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end

    -- 7.3 物理开关 (Toggle)
    function Elements:CreateToggle(title, default, callback)
        local TglState = default or false
        local TglFrame = Utils.Create("TextButton", {
            Parent = Page,
            Size = UDim2.new(0.92, 0, 0, 45),
            BackgroundColor3 = Theme.Section,
            Text = "",
            AutoButtonColor = false
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TglFrame})
        
        Utils.Create("TextLabel", {
            Parent = TglFrame,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -100, 1, 0),
            Text = title,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })

        local Switch = Utils.Create("Frame", {
            Parent = TglFrame,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -15, 0.5, 0),
            Size = UDim2.new(0, 42, 0, 22),
            BackgroundColor3 = Theme.Outline
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})

        local Ball = Utils.Create("Frame", {
            Parent = Switch,
            Position = UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = Theme.TextDim
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

        local function Update()
            Utils.Tween(Switch, TweenLib.Fast, {BackgroundColor3 = TglState and Theme.Accent or Theme.Outline})
            Utils.Tween(Ball, TweenLib.Elastic, {
                Position = TglState and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = TglState and Theme.Text or Theme.TextDim
            })
            callback(TglState)
        end

        TglFrame.MouseButton1Click:Connect(function()
            TglState = not TglState
            Update()
        end)
        
        Update() -- 初始化状态
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end

    -- 7.4 精准滑块 (Slider)
    function Elements:CreateSlider(title, min, max, default, callback)

        local SliderFrame = Utils.Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.92, 0, 0, 60),
            BackgroundColor3 = Theme.Section,
            BorderSizePixel = 0
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SliderFrame})
        Utils.Create("UIStroke", {Thickness = 1, Color = Theme.Outline, Parent = SliderFrame})

        local Title = Utils.Create("TextLabel", {
            Parent = SliderFrame,
            Position = UDim2.new(0, 15, 0, 12),
            Size = UDim2.new(1, -120, 0, 15),
            Text = title,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })

        local ValueLabel = Utils.Create("TextLabel", {
            Parent = SliderFrame,
            Position = UDim2.new(1, -110, 0, 12),
            Size = UDim2.new(0, 100, 0, 15),
            Text = tostring(default),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            BackgroundTransparency = 1
        })

        local SliderBack = Utils.Create("TextButton", {
            Parent = SliderFrame,
            Position = UDim2.new(0, 15, 0, 38),
            Size = UDim2.new(1, -30, 0, 6),
            BackgroundColor3 = Theme.Outline,
            Text = "",
            AutoButtonColor = false
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBack})

        local SliderFill = Utils.Create("Frame", {
            Parent = SliderBack,
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})

        local Dragging = false
        local function UpdateSlider()
            local MousePos = UserInputService:GetMouseLocation().X
            local BtnPos = SliderBack.AbsolutePosition.X
            local BtnSize = SliderBack.AbsoluteSize.X
            local Percent = math.clamp((MousePos - BtnPos) / BtnSize, 0, 1)
            local Value = math.floor(min + (max - min) * Percent)

            Utils.Tween(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(Percent, 0, 1, 0)})
            ValueLabel.Text = tostring(Value)
            callback(Value)
        end

        SliderBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                UpdateSlider()
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider()
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)

        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end

    -- 7.5 文本输入框 (Input)
    function Elements:CreateInput(title, placeholder, callback)
        local InputFrame = Utils.Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.92, 0, 0, 60),
            BackgroundColor3 = Theme.Section,
            BorderSizePixel = 0
        })
        Utils.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = InputFrame})
        Utils.Create("UIStroke", {Thickness = 1, Color = Theme.Outline, Parent = InputFrame})

        Utils.Create("TextLabel", {
            Parent = InputFrame,
            Position = UDim2.new(0, 15, 0, 12),
            Size = UDim2.new(1, -30, 0, 15),
            Text = title,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })

        local TextBox = Utils.Create("TextBox", {
            Parent = InputFrame,
            Position = UDim2.new(0, 15, 0, 32),
            Size = UDim2.new(1, -30, 0, 20),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = placeholder or "输入内容...",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        TextBox.FocusLost:Connect(function(enter)
            if enter then callback(TextBox.Text) end
        end)

        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end

    return Elements
end

-- [8] 最终导出
return Astraea
