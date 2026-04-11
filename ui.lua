-- [[ CyberPink UI V15 - The God Edition ]]
local CyberPink = { _Toggled = true }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 核心动画映射表 (12种)
local AnimStyles = {
    ["None"] = {Enum.EasingStyle.Linear, 0},
    ["Default"] = {Enum.EasingStyle.Quart, 0.4},
    ["Back"] = {Enum.EasingStyle.Back, 0.5},
    ["Bounce"] = {Enum.EasingStyle.Bounce, 0.6},
    ["Elastic"] = {Enum.EasingStyle.Elastic, 0.8},
    ["Exponential"] = {Enum.EasingStyle.Exponential, 0.5},
    ["Circular"] = {Enum.EasingStyle.Circular, 0.4},
    ["Sine"] = {Enum.EasingStyle.Sine, 0.3},
    ["Cubic"] = {Enum.EasingStyle.Cubic, 0.4},
    ["Quint"] = {Enum.EasingStyle.Quint, 0.5},
    ["Soft"] = {Enum.EasingStyle.Quad, 0.3},
    ["Sharp"] = {Enum.EasingStyle.Linear, 0.15}
}

function CyberPink:CreateWindow(Config)
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 192, 203)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_V15"
    ScreenGui.Parent = CoreGui

    -- 【全屏加载系统】
    if Config.LoadingScreen then
        local LoadingFrame = Instance.new("Frame")
        LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
        LoadingFrame.BackgroundColor3 = Config.LoadingBgColor or Color3.fromRGB(10, 10, 10)
        LoadingFrame.ZIndex = 100
        LoadingFrame.Parent = ScreenGui

        local Spinner = Instance.new("ImageLabel")
        Spinner.Size = UDim2.new(0, 80, 0, 80)
        Spinner.Position = UDim2.new(0.5, -40, 0.5, -40)
        Spinner.BackgroundTransparency = 1
        Spinner.Image = "rbxassetid://6031068433" -- 默认旋转图标
        Spinner.ImageColor3 = Config.LoadingAccentColor or AccentColor
        Spinner.Parent = LoadingFrame

        task.spawn(function()
            local rot = 0
            while LoadingFrame.Parent do
                rot = rot + 5
                Spinner.Rotation = rot
                task.wait()
            end
        end)

        local LAnim = AnimStyles[Config.LoadingAnimation or "Exponential"]
        task.wait(Config.LoadingTime or 1.5)
        LoadingFrame:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", LAnim[1], LAnim[2], true, function()
            LoadingFrame:Destroy()
        end)
    end

    -- 【通知系统 Notify】
    function CyberPink:Notify(NConfig)
        local Notification = Instance.new("Frame")
        Notification.Size = UDim2.new(0, 250, 0, 60)
        Notification.Position = UDim2.new(1, 10, 0.8, 0)
        Notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Notification.Parent = ScreenGui
        Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", Notification).Color = AccentColor

        if NConfig.Image then
            local Img = Instance.new("ImageLabel")
            Img.Size = UDim2.new(0, 40, 0, 40)
            Img.Position = UDim2.new(0, 10, 0.5, -20)
            Img.Image = NConfig.Image
            Img.BackgroundTransparency = 1
            Img.Parent = Notification
        end

        local Lab = Instance.new("TextLabel")
        Lab.Text = NConfig.Text or "Notification"
        Lab.Size = NConfig.Image and UDim2.new(1, -60, 1, 0) or UDim2.new(1, -20, 1, 0)
        Lab.Position = NConfig.Image and UDim2.new(0, 55, 0, 0) or UDim2.new(0, 15, 0, 0)
        Lab.TextColor3 = Color3.new(1,1,1)
        Lab.TextXAlignment = Enum.TextXAlignment.Left
        Lab.BackgroundTransparency = 1
        Lab.Font = Enum.Font.GothamBold
        Lab.Parent = Notification

        Notification:TweenPosition(UDim2.new(1, -260, 0.8, 0), "Out", "Back", 0.5)
        task.delay(NConfig.Duration or 3, function()
            Notification:TweenPosition(UDim2.new(1, 10, 0.8, 0), "In", "Back", 0.5, true, function()
                Notification:Destroy()
            end)
        end)
    end

    -- 弹出加载信息
    if Config.HasLoadingInfo then
        CyberPink:Notify({
            Text = Config.LoadingText or "Script Loaded Successfully!",
            Image = Config.LoadingImage,
            Duration = 4
        })
    end

    -- 主窗口主体
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = MainColor
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    local OpenAnim = AnimStyles[Config.OpenAnimation or "Default"]
    Main:TweenSizeAndPosition(UDim2.new(0, 450, 0, 300), UDim2.new(0.5, -225, 0.5, -150), "Out", OpenAnim[1], OpenAnim[2], true)

    -- 标题栏
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. (Config.Name or "CyberPink")
    Title.Size = UDim2.new(1, -120, 1, 0); Title.TextColor3 = AccentColor
    Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1; Title.Parent = Topbar

    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 100, 1, 0); Btns.Position = UDim2.new(1, -100, 0, 0)
    Btns.BackgroundTransparency = 1; Btns.Parent = Topbar

    -- 切换与关闭动画逻辑
    local function ToggleUI()
        self._Toggled = not self._Toggled
        local MAnim = AnimStyles[Config.MinimizeAnimation or "Default"]
        local target = self._Toggled and UDim2.new(0, 450, 0, 300) or UDim2.new(0, 450, 0, 45)
        
        if not self._Toggled and Config.MinimizeStyle ~= "Default" then
            target = UDim2.new(0, 60, 0, 60)
            Topbar.Visible = false; Main.Content.Visible = false
            Main.BackgroundColor3 = Config.MinimizeBgColor or MainColor
            if Config.MinimizeStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0) end
            local el = (Config.MinimizeType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
            el.Name = "MinElement"; el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1
            if Config.MinimizeType == "Image" then el.Image = Config.MinimizeValue else el.Text = Config.MinimizeValue end
            el.TextColor3 = Config.MinimizeTextColor or AccentColor; el.Parent = Main
        else
            Topbar.Visible = true; Main.Content.Visible = true
            MainCorner.CornerRadius = UDim.new(0, 12); Main.BackgroundColor3 = MainColor
            if Main:FindFirstChild("MinElement") then Main.MinElement:Destroy() end
        end
        Main:TweenSize(target, "Out", MAnim[1], MAnim[2], true)
    end

    local function CreateTopBtn(t, c, x, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(0, x, 0.5, -15)
        b.Text = t; b.TextColor3 = c; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        b.Parent = Btns; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(cb)
    end

    CreateTopBtn("-", AccentColor, 15, ToggleUI)
    CreateTopBtn("×", Color3.fromRGB(255, 80, 80), 55, function()
        local CAnim = AnimStyles[Config.CloseAnimation or "Sharp"]
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", CAnim[1], CAnim[2], true, function() ScreenGui:Destroy() end)
    end)

    -- 内容区与列表逻辑 (完全补全)
    local Content = Instance.new("Frame")
    Content.Name = "Content"; Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45); Content.BackgroundTransparency = 1; Content.Parent = Main

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(0, 120, 1, -10); TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1; TabScroll.ScrollBarThickness = 0; TabScroll.Parent = Content
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -135, 1, -10); PageContainer.Position = UDim2.new(0, 130, 0, 5)
    PageContainer.BackgroundTransparency = 1; PageContainer.Parent = Content

    local Window = { _DefaultSet = Config.DefaultTab }
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 35); TBtn.Text = Name; TBtn.BackgroundColor3 = AccentColor
        TBtn.BackgroundTransparency = 0.9; TBtn.TextColor3 = Color3.fromRGB(200, 200, 200); TBtn.Parent = TabScroll
        Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
        Page.ScrollBarThickness = 0; Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        local function Select()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.9; v.TextColor3 = Color3.fromRGB(200, 200, 200) end end
            Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor
        end
        TBtn.MouseButton1Click:Connect(Select)
        if self._DefaultSet == Name or (not self._DefaultSet and #TabScroll:GetChildren() == 1) then Select() end

        local Elements = {}
        function Elements:CreateToggle(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = "  "..text
            b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0,40,0,20); box.Position = UDim2.new(1,-50,0.5,-10); box.BackgroundColor3 = Color3.fromRGB(50,50,50); box.Parent = b
            Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
            local ball = Instance.new("Frame")
            ball.Size = UDim2.new(0,16,0,16); ball.Position = UDim2.new(0,2,0.5,-8); ball.BackgroundColor3 = Color3.new(1,1,1); ball.Parent = box
            Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
            local s = false
            b.MouseButton1Click:Connect(function()
                s = not s
                ball:TweenPosition(s and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), "Out", "Quad", 0.2, true)
                box.BackgroundColor3 = s and AccentColor or Color3.fromRGB(50,50,50)
                callback(s)
            end)
        end
        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 38); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.Parent = Page
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local l = Instance.new("TextLabel")
            l.Text = "  " .. text; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1, 1, 1); l.TextXAlignment = 0; l.Parent = f
            local i = Instance.new("TextBox")
            i.Size = UDim2.new(0.4, 0, 0.7, 0); i.Position = UDim2.new(0.55, 0, 0.15, 0); i.BackgroundColor3 = Color3.fromRGB(40, 40, 40); i.Text = ""
            i.PlaceholderText = placeholder; i.TextColor3 = AccentColor; i.Parent = f; Instance.new("UICorner", i).CornerRadius = UDim.new(0, 6)
            i.FocusLost:Connect(function() callback(i.Text) end)
        end
        return Elements
    end
    return Window
end

return CyberPink
