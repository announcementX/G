local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local SOUL = {
    Elements = {},
    Themes = {
        Main = Color3.fromRGB(15, 15, 15),
        Accent = Color3.fromRGB(255, 105, 180),
        Text = Color3.fromRGB(255, 255, 255),
        Gradient = ColorSequence.new(Color3.fromRGB(25, 25, 25), Color3.fromRGB(45, 20, 35))
    }
}

local function Create(cls, props)
    local inst = Instance.new(cls)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

function SOUL:Notify(cfg)
    local title = cfg.Title or "SOUL"
    local desc = cfg.Content or ""
    local icon = cfg.Icon or ""
    
    local notifyFrame = Create("Frame", {
        Name = "SOUL_Notify",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(1, 10, 0, 20),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = notifyFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = notifyFrame, Color = self.Themes.Accent, Thickness = 1.5})
    
    local t = Create("TextLabel", {
        Parent = notifyFrame,
        Text = title,
        Size = UDim2.new(1, -50, 0, 25),
        Position = UDim2.new(0, 45, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = self.Themes.Accent,
        TextXAlignment = "Left",
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    
    if icon ~= "" then
        Create("ImageLabel", {
            Parent = notifyFrame,
            Image = icon,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 8, 0, 15),
            BackgroundTransparency = 1
        })
    end
    
    TweenService:Create(notifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -260, 0, 20)}):Play()
    task.delay(3, function()
        TweenService:Create(notifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 10, 0, 20)}):Play()
        task.wait(0.5)
        notifyFrame:Destroy()
    end)
end

function SOUL:CreateWindow(cfg)
    local lib = {
        CurrentTab = nil,
        Minimized = false,
        Size = cfg.Size or UDim2.new(0, 550, 0, 320)
    }
    
    self.ScreenGui = Create("ScreenGui", {Parent = CoreGui, Name = "SOUL_ENGINE"})
    
    local Main = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = lib.Size,
        Position = UDim2.new(0.5, -275, 0.5, -160),
        BackgroundColor3 = self.Themes.Main,
        ClipsDescendants = true,
        Active = true,
        Draggable = true
    })
    lib.Main = Main
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 12)})
    
    local AccentGradient = Create("UIGradient", {
        Parent = Main,
        Color = self.Themes.Gradient,
        Rotation = 45
    })

    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = Main,
        Size = UDim2.new(0, 140, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 5)})
    
    local Container = Create("Frame", {
        Name = "Container",
        Parent = Main,
        Size = UDim2.new(1, -150, 1, -50),
        Position = UDim2.new(0, 145, 0, 45),
        BackgroundTransparency = 1
    })

    local TitleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1
    })
    
    local TitleText = Create("TextLabel", {
        Parent = TitleBar,
        Text = "SOUL PROJECT",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = self.Themes.Accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        BackgroundTransparency = 1,
        TextXAlignment = "Left"
    })

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        Text = "×",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 20
    })
    Create("UICorner", {Parent = CloseBtn})

    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        Text = "-",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0, 2),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 20
    })
    Create("UICorner", {Parent = MinBtn})

    local MiniFrame = Create("Frame", {
        Name = "MiniFrame",
        Parent = self.ScreenGui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundColor3 = self.Themes.Main,
        Visible = false,
        Active = true,
        Draggable = true
    })
    lib.MiniFrame = MiniFrame
    local MiniCorner = Create("UICorner", {Parent = MiniFrame, CornerRadius = UDim.new(0, 12)})
    local MiniImg = Create("ImageLabel", {
        Parent = MiniFrame,
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031225818" -- Soul Icon
    })

    MinBtn.MouseButton1Click:Connect(function()
        lib.Minimized = true
        local tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0),
            Position = MiniFrame.Position
        })
        tween:Play()
        tween.Completed:Wait()
        Main.Visible = false
        MiniFrame.Visible = true
    end)

    MiniFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            MiniFrame.Visible = false
            Main.Visible = true
            Main.Size = UDim2.new(0,0,0,0)
            local tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = lib.Size
            })
            tween:Play()
            lib.Minimized = false
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Wait()
        self.ScreenGui:Destroy()
    end)

    return setmetatable(lib, {__index = SOUL})
end
--[继续接上一段代码]--

function SOUL:AddTab(cfg)
    local tabName = cfg.Name or "Tab"
    local tabIcon = cfg.Icon or ""
    local lib = self
    
    local TabBtn = Create("TextButton", {
        Parent = self.Main.Sidebar,
        Size = UDim2.new(1, -10, 0, 35),
        BackgroundTransparency = 1,
        Text = "  " .. tabName,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = "Left"
    })
    
    local Page = Create("ScrollingFrame", {
        Parent = self.Main.Container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Themes.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8), HorizontalAlignment = "Center"})
    Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5)})

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Main.Container:GetChildren()) do v.Visible = false end
        for _, v in pairs(self.Main.Sidebar:GetChildren()) do 
            if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play() end
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = self.Themes.Accent}):Play()
    end)

    local tabObj = {Page = Page}

    -- 按钮组件 (支持内置点击动画)
    function tabObj:AddButton(name, callback)
        local Btn = Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.9, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
        local Label = Create("TextLabel", {
            Parent = Btn,
            Text = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold,
            TextSize = 14
        })
        local Trigger = Create("TextButton", {
            Parent = Btn,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = ""
        })
        
        Trigger.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = lib.Themes.Accent}):Play()
            callback()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        end)
    end

    -- 开关组件
    function tabObj:AddToggle(name, default, callback)
        local state = default or false
        local ToggleFrame = Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.9, 0, 0, 40),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0
        })
        Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})
        
        local Label = Create("TextLabel", {
            Parent = ToggleFrame,
            Text = "  " .. name,
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = "Left"
        })

        local Box = Create("Frame", {
            Parent = ToggleFrame,
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        })
        Create("UICorner", {Parent = Box, CornerRadius = UDim.new(1, 0)})
        
        local Dot = Create("Frame", {
            Parent = Box,
            Size = UDim2.new(0, 16, 0, 16),
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = state and lib.Themes.Accent or Color3.new(1,1,1)
        })
        Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})

        local Trigger = Create("TextButton", {Parent = ToggleFrame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
        Trigger.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Dot, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = state and lib.Themes.Accent or Color3.new(1,1,1)
            }):Play()
            callback(state)
        end)
    end

    -- 输入框组件
    function tabObj:AddInput(name, placeholder, callback)
        local InputFrame = Create("Frame", {
            Parent = Page,
            Size = UDim2.new(0.9, 0, 0, 45),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        })
        Create("UICorner", {Parent = InputFrame})
        
        local Box = Create("TextBox", {
            Parent = InputFrame,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 7),
            BackgroundTransparency = 1,
            PlaceholderText = name .. ": " .. placeholder,
            Text = "",
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.Gotham,
            TextSize = 14
        })

        Box.FocusLost:Connect(function(enter)
            if enter then callback(Box.Text) end
        end)
    end

    return tabObj
end

-- 远程/内置脚本库导入逻辑
function SOUL:ImportLibrary(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        self:Notify({Title = "Library Loaded", Content = "Successfully imported soul script."})
        return result
    else
        self:Notify({Title = "Error", Content = "Failed to load remote script."})
    end
end

-- 自定义缩小样式接口 (支持数十种样式通过 CornerRadius 和 Shape 模拟)
function SOUL:SetMiniStyle(cfg)
    -- cfg: {Shape = "Circle" | "Square" | "Rounded", Size = UDim2, Icon = "rbxid"}
    local targetRadius = UDim.new(0, 12)
    if cfg.Shape == "Circle" then targetRadius = UDim.new(1, 0)
    elseif cfg.Shape == "Square" then targetRadius = UDim.new(0, 0) end
    
    self.MiniFrame.Size = cfg.Size or UDim2.new(0, 50, 0, 50)
    self.MiniFrame.UICorner.CornerRadius = targetRadius
    if cfg.Icon then self.MiniFrame.ImageLabel.Image = cfg.Icon end
end

return SOUL
--[继续接上一段代码]--

-- 页面滚动高度自适应优化
RunService.RenderStepped:Connect(function()
    for _, page in pairs(SOUL.ScreenGui.MainFrame.Container:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 10)
        end
    end
    SOUL.ScreenGui.MainFrame.Sidebar.CanvasSize = UDim2.new(0, 0, 0, SOUL.ScreenGui.MainFrame.Sidebar.UIListLayout.AbsoluteContentSize.Y)
end)

-- 信息显示页面组件 (Info Display)
function SOUL:AddInfoPage(name)
    local tab = self:AddTab({Name = name})
    local page = tab.Page
    
    local infoObj = {}
    
    function infoObj:UpdateText(labelName, content)
        local target = page:FindFirstChild(labelName)
        if target then
            target.Text = content
        else
            local newLabel = Create("TextLabel", {
                Name = labelName,
                Parent = page,
                Size = UDim2.new(0.9, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = Color3.new(0.8, 0.8, 0.8),
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = "Left"
            })
        end
    end
    
    return infoObj
end

-- 炫酷加载动画引擎
function SOUL:InitLoader(callback)
    local LoadUI = Create("Frame", {
        Parent = self.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        ZIndex = 10
    })
    
    local Logo = Create("ImageLabel", {
        Parent = LoadUI,
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0.5, -50, 0.5, -60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031225818", -- Soul Icon
        ImageColor3 = self.Themes.Accent
    })
    
    local BarBG = Create("Frame", {
        Parent = LoadUI,
        Size = UDim2.new(0, 200, 0, 4),
        Position = UDim2.new(0.5, -100, 0.5, 50),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    })
    local Bar = Create("Frame", {
        Parent = BarBG,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Themes.Accent
    })
    
    -- 进场动画
    TweenService:Create(Logo, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
    local t = TweenService:Create(Bar, TweenInfo.new(2, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 1, 0)})
    t:Play()
    
    t.Completed:Connect(function()
        TweenService:Create(LoadUI, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        TweenService:Create(BarBG, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Bar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        LoadUI:Destroy()
        if callback then callback() end
    end)
end

