-- [[ CyberPink UI V18 - The Omni-Customization Engine ]]
local CyberPink = { _Toggled = true, _Version = "1.8" }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 【核心：14种顶级动画算法库】
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
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 192, 203)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_V18"; ScreenGui.Parent = CoreGui; ScreenGui.DisplayOrder = 9999

    -- 【1. 加载系统：全屏/悬浮/通知】
    if Config.LoadingMode and Config.LoadingMode ~= "None" then
        local LoadingOverlay = Instance.new("Frame")
        LoadingOverlay.BackgroundColor3 = Config.LoadingBgColor or Color3.fromRGB(10, 10, 10)
        LoadingOverlay.ZIndex = 1000; LoadingOverlay.Parent = ScreenGui
        
        if Config.LoadingMode == "FullScreen" then
            LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
        else
            LoadingOverlay.Size = UDim2.new(0, 220, 0, 220)
            LoadingOverlay.Position = UDim2.new(0.5, -110, 0.5, -110)
            Instance.new("UICorner", LoadingOverlay).CornerRadius = UDim.new(0, 20)
        end

        local Spinner = Instance.new("ImageLabel")
        Spinner.Size = UDim2.new(0, 70, 0, 70); Spinner.Position = UDim2.new(0.5, -35, 0.5, -50); Spinner.BackgroundTransparency = 1
        Spinner.Image = "rbxassetid://6031068433"; Spinner.ImageColor3 = Config.LoadingAccentColor or AccentColor; Spinner.ZIndex = 1001; Spinner.Parent = LoadingOverlay
        
        local LText = Instance.new("TextLabel")
        LText.Size = UDim2.new(1, 0, 0, 30); LText.Position = UDim2.new(0, 0, 0.5, 30)
        LText.Text = Config.LoadingText or "Loading..."; LText.TextColor3 = Config.LoadingTextColor or Color3.new(1,1,1)
        LText.TextSize = Config.LoadingTextSize or 16; LText.Font = Enum.Font.GothamBold; LText.BackgroundTransparency = 1; LText.ZIndex = 1001; LText.Parent = LoadingOverlay

        task.spawn(function() while LoadingOverlay.Parent do Spinner.Rotation = Spinner.Rotation + 6; task.wait() end end)
        task.wait(Config.LoadingTime or 2)
        
        local LAnim = AnimStyles[Config.LoadingAnimation or "Exponential"]
        LoadingOverlay:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", LAnim[1], LAnim[2], true, function() LoadingOverlay:Destroy() end)
    end

    -- 加载后通知
    if Config.HasLoadingInfo then
        local Notify = Instance.new("Frame")
        Notify.Size = UDim2.new(0, 260, 0, 70); Notify.Position = UDim2.new(1, 10, 0.85, 0); Notify.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Notify.Parent = ScreenGui
        Instance.new("UICorner", Notify).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", Notify).Color = AccentColor
        
        if Config.LoadingImage then
            local Img = Instance.new("ImageLabel")
            Img.Size = UDim2.new(0, 45, 0, 45); Img.Position = UDim2.new(0, 10, 0.5, -22); Img.Image = Config.LoadingImage; Img.BackgroundTransparency = 1; Img.Parent = Notify
        end
        local Msg = Instance.new("TextLabel")
        Msg.Text = Config.LoadingInfoText or "Welcome!"; Msg.Size = UDim2.new(1, -70, 1, 0); Msg.Position = UDim2.new(0, 60, 0, 0); Msg.TextColor3 = Color3.new(1,1,1); Msg.Font = Enum.Font.GothamBold; Msg.TextXAlignment = 0; Msg.BackgroundTransparency = 1; Msg.Parent = Notify
        
        Notify:TweenPosition(UDim2.new(1, -270, 0.85, 0), "Out", "Back", 0.5)
        task.delay(4, function() Notify:TweenPosition(UDim2.new(1, 10, 0.85, 0), "In", "Back", 0.5, true, function() Notify:Destroy() end) end)
    end

    -- 【2. 主窗口主体】
    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.ClipsDescendants = true; Main.BackgroundColor3 = MainColor; Main.BorderSizePixel = 0
    Main.Size = UDim2.new(0, 0, 0, 0); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(0, 12)
    
    local OpenAnim = AnimStyles[Config.OpenAnimation or "Default"]
    Main:TweenSizeAndPosition(UDim2.new(0, 450, 0, 300), UDim2.new(0.5, -225, 0.5, -150), "Out", OpenAnim[1], OpenAnim[2], true)

    -- 标题栏
    local Topbar = Instance.new("Frame"); Topbar.Size = UDim2.new(1, 0, 0, 45); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)
    local Title = Instance.new("TextLabel"); Title.Text = "  " .. (Config.Name or "CyberPink"); Title.Size = UDim2.new(1, -120, 1, 0); Title.TextColor3 = AccentColor; Title.TextSize = Config.WindowTitleSize or 14; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = 0; Title.BackgroundTransparency = 1; Title.Parent = Topbar

    -- 【3. 交互控制库】
    local function ToggleUI()
        self._Toggled = not self._Toggled
        local MAnim = AnimStyles[Config.MinimizeAnimation or "Default"]
        if self._Toggled then
            Main.Content.Visible = true; Topbar.Visible = true
            if Main:FindFirstChild("MinElement") then Main.MinElement:Destroy() end
            MainCorner.CornerRadius = UDim.new(0, 12); Main.BackgroundColor3 = MainColor
            Main:TweenSize(UDim2.new(0, 450, 0, 300), "Out", MAnim[1], MAnim[2], true)
        else
            if Config.MinimizeStyle ~= "Default" then
                Topbar.Visible = false; Main.Content.Visible = false
                Main.BackgroundColor3 = Config.MinimizeBgColor or MainColor
                if Config.MinimizeStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0) end
                local el = (Config.MinimizeType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
                el.Name = "MinElement"; el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1; el.TextColor3 = Config.MinimizeTextColor or AccentColor; el.Font = Enum.Font.GothamBold; el.Parent = Main
                if Config.MinimizeType == "Image" then el.Image = Config.MinimizeValue else el.Text = Config.MinimizeValue; el.TextSize = Config.MinTextSize or 18 end
                Main:TweenSize(UDim2.new(0, 60, 0, 60), "Out", MAnim[1], MAnim[2], true)
            else
                Main:TweenSize(UDim2.new(0, 450, 0, 45), "Out", MAnim[1], MAnim[2], true)
            end
        end
    end

    local Btns = Instance.new("Frame"); Btns.Size = UDim2.new(0, 100, 1, 0); Btns.Position = UDim2.new(1, -100, 0, 0); Btns.BackgroundTransparency = 1; Btns.Parent = Topbar
    local function CreateTopBtn(t, c, x, cb)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(0, x, 0.5, -15); b.Text = t; b.TextColor3 = c; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Parent = Btns; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(cb)
    end
    CreateTopBtn("-", AccentColor, 15, ToggleUI)
    CreateTopBtn("×", Color3.fromRGB(255, 80, 80), 55, function()
        local CAnim = AnimStyles[Config.CloseAnimation or "Sharp"]
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", CAnim[1], CAnim[2], true, function() ScreenGui:Destroy() end)
    end)

    -- 拖拽逻辑 (手机可用)
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not self._Toggled then 
                local sPos = input.Position; local con; con = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then if (input.Position - sPos).Magnitude < 5 then ToggleUI() end con:Disconnect() end
                end)
            end
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    -- 内容区
    local Content = Instance.new("Frame"); Content.Name = "Content"; Content.Size = UDim2.new(1, 0, 1, -45); Content.Position = UDim2.new(0, 0, 0, 45); Content.BackgroundTransparency = 1; Content.Parent = Main
    local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(0, 120, 1, -10); TabScroll.Position = UDim2.new(0, 5, 0, 5); TabScroll.BackgroundTransparency = 1; TabScroll.ScrollBarThickness = 0; TabScroll.Parent = Content
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)
    local PageContainer = Instance.new("Frame"); PageContainer.Size = UDim2.new(1, -135, 1, -10); PageContainer.Position = UDim2.new(0, 130, 0, 5); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = Content

    local Window = { _Tabs = {}, _DefaultTab = Config.DefaultTab }
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton"); TBtn.Size = UDim2.new(1, 0, 0, 35); TBtn.Text = Name; TBtn.BackgroundColor3 = AccentColor; TBtn.BackgroundTransparency = 0.9; TBtn.TextColor3 = Color3.fromRGB(200, 200, 200); TBtn.Parent = TabScroll; TBtn.TextSize = Config.TabBtnSize or 14; Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)
        local Page = Instance.new("ScrollingFrame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.Parent = PageContainer; Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
        
        local function Select()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.9; v.TextColor3 = Color3.fromRGB(200, 200, 200) end end
            Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor
        end
        TBtn.MouseButton1Click:Connect(Select)
        table.insert(self._Tabs, {Name = Name, Func = Select})

        -- 页面导演逻辑：启动后执行
        task.spawn(function()
            task.wait(0.1)
            if self._DefaultTab == "Random" then
                local r = self._Tabs[math.random(1, #self._Tabs)]; if r then r.Func() end
            elseif self._DefaultTab == "None" then
                Page.Visible = false -- 不显示任何页面
            elseif self._DefaultTab == Name then
                Select()
            elseif self._DefaultTab == nil and #TabScroll:GetChildren() == 1 then
                Select()
            end
        end)

        local Elements = {}
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page; b.TextSize = Config.ElementTextSize or 13; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(callback)
        end
        return Elements
    end
    return Window
end

return CyberPink
