-- [[ CyberPink UI V19 - Absolute Reality Edition ]]
local CyberPink = { _Toggled = true, _SelectedTab = nil }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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
    ["Sharp"] = {Enum.EasingStyle.Linear, 0.1},
    ["Slow"] = {Enum.EasingStyle.Sine, 1.2},
    ["Rapid"] = {Enum.EasingStyle.Quad, 0.2}
}

function CyberPink:CreateWindow(Config)
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 105, 180)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_V19"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999
    ScreenGui.IgnoreGuiInset = true -- 【关键：实现真正物理全屏】

    -- [[ 1. 真·全屏加载动画系统 ]]
    if Config.LoadingMode and Config.LoadingMode ~= "None" then
        local LoadingOverlay = Instance.new("Frame")
        LoadingOverlay.BackgroundColor3 = Config.LoadingBgColor or Color3.fromRGB(10, 10, 10)
        LoadingOverlay.BorderSizePixel = 0
        LoadingOverlay.ZIndex = 10000
        LoadingOverlay.Parent = ScreenGui

        if Config.LoadingMode == "FullScreen" then
            LoadingOverlay.Size = UDim2.new(1, 0, 1, 0) -- 真正铺满
        else
            LoadingOverlay.Size = UDim2.new(0, 220, 0, 220)
            LoadingOverlay.Position = UDim2.new(0.5, -110, 0.5, -110)
            Instance.new("UICorner", LoadingOverlay).CornerRadius = UDim.new(0, 20)
        end

        local Spinner = Instance.new("ImageLabel")
        Spinner.Size = UDim2.new(0, 80, 0, 80)
        Spinner.Position = UDim2.new(0.5, -40, 0.5, -50)
        Spinner.BackgroundTransparency = 1; Spinner.Image = "rbxassetid://6031068433"
        Spinner.ImageColor3 = Config.LoadingAccentColor or AccentColor
        Spinner.ZIndex = 10001; Spinner.Parent = LoadingOverlay
        
        local LText = Instance.new("TextLabel")
        LText.Size = UDim2.new(1, 0, 0, 30); LText.Position = UDim2.new(0, 0, 0.5, 40)
        LText.Text = Config.LoadingText or "INITIALIZING..."
        LText.TextColor3 = Config.LoadingTextColor or Color3.new(1,1,1)
        LText.TextSize = Config.LoadingTextSize or 18
        LText.Font = Enum.Font.GothamBold; LText.BackgroundTransparency = 1
        LText.ZIndex = 10001; LText.Parent = LoadingOverlay

        task.spawn(function() while LoadingOverlay.Parent do Spinner.Rotation = Spinner.Rotation + 6; task.wait() end end)
        task.wait(Config.LoadingTime or 2)
        
        local LAnim = AnimStyles[Config.LoadingAnimation or "Exponential"]
        LoadingOverlay:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", LAnim[1], LAnim[2], true, function() LoadingOverlay:Destroy() end)
    end

    -- [[ 2. 通知系统 (支持图片) ]]
    if Config.HasLoadingInfo then
        local Notify = Instance.new("Frame")
        Notify.Size = UDim2.new(0, 280, 0, 70); Notify.Position = UDim2.new(1, 20, 0.85, 0)
        Notify.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Notify.Parent = ScreenGui
        Instance.new("UICorner", Notify).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", Notify).Color = AccentColor; Instance.new("UIStroke", Notify).Thickness = 2
        
        if Config.LoadingImage then
            local Img = Instance.new("ImageLabel")
            Img.Size = UDim2.new(0, 50, 0, 50); Img.Position = UDim2.new(0, 10, 0.5, -25)
            Img.Image = Config.LoadingImage; Img.BackgroundTransparency = 1; Img.Parent = Notify
        end
        local Msg = Instance.new("TextLabel")
        Msg.Text = Config.LoadingInfoText or "System Ready."; Msg.Size = UDim2.new(1, -80, 1, 0); Msg.Position = UDim2.new(0, 70, 0, 0); Msg.TextColor3 = Color3.new(1,1,1); Msg.Font = Enum.Font.GothamBold; Msg.TextSize = 14; Msg.TextXAlignment = 0; Msg.BackgroundTransparency = 1; Msg.Parent = Notify
        
        Notify:TweenPosition(UDim2.new(1, -300, 0.85, 0), "Out", "Back", 0.6)
        task.delay(4, function() Notify:TweenPosition(UDim2.new(1, 20, 0.85, 0), "In", "Back", 0.5, true, function() Notify:Destroy() end) end)
    end

    -- [[ 3. 主窗口及交互 ]]
    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.ClipsDescendants = true; Main.BackgroundColor3 = MainColor; Main.BorderSizePixel = 0
    Main.Size = UDim2.new(0, 0, 0, 0); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(0, 12)
    
    local OpenAnim = AnimStyles[Config.OpenAnimation or "Default"]
    Main:TweenSizeAndPosition(UDim2.new(0, 480, 0, 320), UDim2.new(0.5, -240, 0.5, -160), "Out", OpenAnim[1], OpenAnim[2], true)

    local Topbar = Instance.new("Frame"); Topbar.Size = UDim2.new(1, 0, 0, 50); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)
    local Title = Instance.new("TextLabel"); Title.Text = "  " .. (Config.Name or "CyberPink"); Title.Size = UDim2.new(1, -120, 1, 0); Title.TextColor3 = AccentColor; Title.TextSize = Config.WindowTitleSize or 16; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = 0; Title.BackgroundTransparency = 1; Title.Parent = Topbar

    -- 按钮与切换逻辑
    local function ToggleUI()
        self._Toggled = not self._Toggled
        local MAnim = AnimStyles[Config.MinimizeAnimation or "Default"]
        if self._Toggled then
            Main.Content.Visible = true; Topbar.Visible = true; MainCorner.CornerRadius = UDim.new(0, 12); Main.BackgroundColor3 = MainColor
            if Main:FindFirstChild("MinEl") then Main.MinEl:Destroy() end
            Main:TweenSize(UDim2.new(0, 480, 0, 320), "Out", MAnim[1], MAnim[2], true)
        else
            if Config.MinimizeStyle ~= "Default" then
                Topbar.Visible = false; Main.Content.Visible = false; Main.BackgroundColor3 = Config.MinimizeBgColor or MainColor
                if Config.MinimizeStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0) end
                local el = (Config.MinimizeType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
                el.Name = "MinEl"; el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1; el.TextColor3 = Config.MinimizeTextColor or AccentColor; el.Font = Enum.Font.GothamBold; el.Parent = Main
                if Config.MinimizeType == "Image" then el.Image = Config.MinimizeValue else el.Text = Config.MinimizeValue; el.TextSize = Config.MinTextSize or 20 end
                Main:TweenSize(UDim2.new(0, 65, 0, 65), "Out", MAnim[1], MAnim[2], true)
            else
                Main:TweenSize(UDim2.new(0, 480, 0, 50), "Out", MAnim[1], MAnim[2], true)
            end
        end
    end

    local Btns = Instance.new("Frame"); Btns.Size = UDim2.new(0, 100, 1, 0); Btns.Position = UDim2.new(1, -100, 0, 0); Btns.BackgroundTransparency = 1; Btns.Parent = Topbar
    local function CreateTopBtn(t, c, x, cb)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 32, 0, 32); b.Position = UDim2.new(0, x, 0.5, -16); b.Text = t; b.TextColor3 = c; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Parent = Btns; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(cb)
    end
    CreateTopBtn("-", AccentColor, 10, ToggleUI); CreateTopBtn("×", Color3.fromRGB(255, 80, 80), 55, function()
        local CAnim = AnimStyles[Config.CloseAnimation or "Sharp"]
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", CAnim[1], CAnim[2], true, function() ScreenGui:Destroy() end)
    end)

    -- 拖拽 (Magnitude 区分点击和滑动)
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not self._Toggled then 
                local sPos = input.Position; local con; con = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then if (input.Position - sPos).Magnitude < 8 then ToggleUI() end con:Disconnect() end
                end)
            end
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    -- 内容区
    local Content = Instance.new("Frame"); Content.Name = "Content"; Content.Size = UDim2.new(1, 0, 1, -50); Content.Position = UDim2.new(0, 0, 0, 50); Content.BackgroundTransparency = 1; Content.Parent = Main
    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(0, 130, 1, -15); TabScroll.Position = UDim2.new(0, 8, 0, 8); TabScroll.BackgroundTransparency = 1; TabScroll.ScrollBarThickness = 0; TabScroll.Parent = Content
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 6)
    local PageContainer = Instance.new("Frame"); PageContainer.Size = UDim2.new(1, -150, 1, -15); PageContainer.Position = UDim2.new(0, 142, 0, 8); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = Content

    local Window = { _Tabs = {}, _DefaultTab = Config.DefaultTab }
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 38); TBtn.Text = Name; TBtn.BackgroundColor3 = AccentColor; TBtn.BackgroundTransparency = 0.9; TBtn.TextColor3 = Color3.fromRGB(200, 200, 200); TBtn.Parent = TabScroll; TBtn.TextSize = Config.TabBtnSize or 15; Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.Parent = PageContainer; Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)
        
        local function Select()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.9; v.TextColor3 = Color3.fromRGB(200, 200, 200) end end
            Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor
        end
        TBtn.MouseButton1Click:Connect(Select)
        table.insert(self._Tabs, {Name = Name, Func = Select})

        -- 页面导演逻辑
        task.spawn(function()
            task.wait(0.2)
            if self._DefaultTab == "Random" then
                local r = self._Tabs[math.random(1, #self._Tabs)]; if r then r.Func() end
            elseif self._DefaultTab == "None" then
                Page.Visible = false
            elseif self._DefaultTab == Name then
                Select()
            end
        end)

        local Elements = {}
        -- [[ 按钮 (Button) ]]
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page; b.TextSize = Config.ElementTextSize or 14; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(callback)
        end
        -- [[ 开关 (Toggle) ]]
        function Elements:CreateToggle(text, callback)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,40); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page; b.TextSize = Config.ElementTextSize or 14; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local box = Instance.new("Frame"); box.Size = UDim2.new(0,42,0,22); box.Position = UDim2.new(1,-52,0.5,-11); box.BackgroundColor3 = Color3.fromRGB(50,50,50); box.Parent = b; Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
            local ball = Instance.new("Frame"); ball.Size = UDim2.new(0,18,0,18); ball.Position = UDim2.new(0,2,0.5,-9); ball.BackgroundColor3 = Color3.new(1,1,1); ball.Parent = box; Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
            local s = false
            b.MouseButton1Click:Connect(function()
                s = not s; ball:TweenPosition(s and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), "Out", "Quad", 0.2, true)
                box.BackgroundColor3 = s and AccentColor or Color3.fromRGB(50,50,50); callback(s)
            end)
        end
        -- [[ 输入框 (Input) ]]
        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.Parent = Page; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local l = Instance.new("TextLabel"); l.Text = "  "..text; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.TextSize = Config.ElementTextSize or 14; l.TextXAlignment = 0; l.Parent = f
            local i = Instance.new("TextBox"); i.Size = UDim2.new(0.4, -10, 0.7, 0); i.Position = UDim2.new(0.6, 5, 0.15, 0); i.BackgroundColor3 = Color3.fromRGB(40, 40, 40); i.Text = ""; i.PlaceholderText = placeholder; i.TextColor3 = AccentColor; i.TextSize = Config.ElementTextSize or 14; i.Parent = f; Instance.new("UICorner", i).CornerRadius = UDim.new(0, 6)
            i.FocusLost:Connect(function() callback(i.Text) end)
        end
        return Elements
    end
    return Window
end

return CyberPink
