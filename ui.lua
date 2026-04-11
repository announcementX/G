-- [[ CyberPink UI V21 - Precision & Neon Edition ]]
local CyberPink = { _Toggled = true }
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

-- 【局部霓虹渲染器】
local function ApplyNeon(Instance, Enabled, AccentColor)
    if not Enabled then return end
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2; Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; Stroke.Color = AccentColor; Stroke.Parent = Instance
    task.spawn(function()
        local h = 0
        while Stroke.Parent do
            Stroke.Color = Color3.fromHSV(h, 0.7, 1)
            h = (h + 0.005) % 1
            task.wait(0.03)
        end
    end)
end

function CyberPink:CreateWindow(Config)
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 105, 180)
    local W = math.clamp(Config.Width or 480, 300, 800)
    local H = math.clamp(Config.Height or 320, 200, 600)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_V21"; ScreenGui.Parent = CoreGui; ScreenGui.IgnoreGuiInset = true; ScreenGui.DisplayOrder = 9999

    -- 1. 主窗口 (根据配置决定是否有霓虹)
    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.BackgroundColor3 = MainColor; Main.BorderSizePixel = 0; Main.ClipsDescendants = true
    Main.Size = UDim2.new(0, 0, 0, 0); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    ApplyNeon(Main, Config.NeonMain, AccentColor)

    local OpenAnim = AnimStyles[Config.OpenAnimation or "Default"]
    Main:TweenSizeAndPosition(UDim2.new(0, W, 0, H), UDim2.new(0.5, -W/2, 0.5, -H/2), "Out", OpenAnim[1], OpenAnim[2], true)

    -- 2. 标题栏
    local Topbar = Instance.new("Frame"); Topbar.Size = UDim2.new(1, 0, 0, 50); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel"); Title.Text = "  " .. (Config.Name or "CyberPink"); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.TextColor3 = AccentColor; Title.TextSize = Config.WindowTitleSize or 16; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = 0; Title.BackgroundTransparency = 1; Title.Parent = Topbar
    ApplyNeon(Title, Config.NeonTitleText, AccentColor)

    if Config.ShowTime then
        local TimeLab = Instance.new("TextLabel"); TimeLab.Size = UDim2.new(0.3, 0, 1, 0); TimeLab.Position = UDim2.new(0.4, 0, 0, 0); TimeLab.BackgroundTransparency = 1; TimeLab.TextColor3 = Color3.new(0.8,0.8,0.8); TimeLab.TextSize = 12; TimeLab.Font = Enum.Font.Code; TimeLab.Parent = Topbar
        task.spawn(function() while task.wait(1) do local d = os.date("!*t", os.time() + 28800) TimeLab.Text = string.format("%02d:%02d:%02d", d.hour, d.min, d.sec) end end)
    end

    -- 3. 切换与缩小逻辑
    local function ToggleUI()
        self._Toggled = not self._Toggled
        local MAnim = AnimStyles[Config.MinimizeAnimation or "Default"]
        if self._Toggled then
            Main.Content.Visible = true; Topbar.Visible = true; if Main:FindFirstChild("MinEl") then Main.MinEl:Destroy() end
            Main:TweenSize(UDim2.new(0, W, 0, H), "Out", MAnim[1], MAnim[2], true)
        else
            Topbar.Visible = false; Main.Content.Visible = false
            local el = (Config.MinimizeType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
            el.Name = "MinEl"; el.Size = UDim2.new(1,0,1,0); el.BackgroundTransparency = 1; el.TextColor3 = AccentColor; el.Font = Enum.Font.GothamBold; el.Parent = Main
            if Config.MinimizeType == "Image" then el.Image = Config.MinimizeValue else el.Text = Config.MinimizeValue; el.TextSize = Config.MinTextSize or 20 end
            ApplyNeon(Main, Config.NeonMin, AccentColor)
            Main:TweenSize(UDim2.new(0, Config.MinWindowWidth or 60, 0, Config.MinWindowHeight or 60), "Out", MAnim[1], MAnim[2], true)
        end
    end

    local Btns = Instance.new("Frame"); Btns.Size = UDim2.new(0, 100, 1, 0); Btns.Position = UDim2.new(1, -100, 0, 0); Btns.BackgroundTransparency = 1; Btns.Parent = Topbar
    local function CreateTopBtn(t, c, x, cb)
        local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 32, 0, 32); b.Position = UDim2.new(0, x, 0.5, -16); b.Text = t; b.TextColor3 = c; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Parent = Btns; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(cb)
    end
    CreateTopBtn("-", AccentColor, 10, ToggleUI); CreateTopBtn("×", Color3.fromRGB(255, 80, 80), 55, function() ScreenGui:Destroy() end)

    -- 拖拽修复
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then if not self._Toggled then local sPos = input.Position; local con; con = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then if (input.Position - sPos).Magnitude < 8 then ToggleUI() end con:Disconnect() end end) end dragging = true; dragStart = input.Position; startPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

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
        task.spawn(function() task.wait(0.2) if self._DefaultTab == "Random" then local r = self._Tabs[math.random(1, #self._Tabs)]; if r then r.Func() end elseif self._DefaultTab == Name then Select() end end)

        local Elements = {}
        -- [[ 核心：可变尺寸按钮 ]]
        function Elements:CreateButton(text, callback, btnConfig)
            btnConfig = btnConfig or {}
            local b = Instance.new("TextButton")
            -- 支持自定义宽高，否则默认
            local bW = btnConfig.Width or 1.0 -- 如果是数字且 <= 1，则视为比例
            local bH = btnConfig.Height or 40
            b.Size = (type(bW) == "number" and bW <= 1) and UDim2.new(bW, 0, 0, bH) or UDim2.new(0, bW, 0, bH)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page; b.Font = Enum.Font.Gotham; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            
            -- 文字限制逻辑：TextScaled 开启但设置 UITextSizeConstraint
            b.TextScaled = true
            local textConstraint = Instance.new("UITextSizeConstraint", b)
            textConstraint.MaxTextSize = Config.ElementTextSize or 14 -- 设置上限，确保不大于按钮
            textConstraint.MinTextSize = 8
            
            ApplyNeon(b, btnConfig.Neon, AccentColor)
            b.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateToggle(text, callback, tConfig)
            tConfig = tConfig or {}
            local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,40); b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page; b.TextSize = Config.ElementTextSize or 14; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local box = Instance.new("Frame"); box.Size = UDim2.new(0,42,0,22); box.Position = UDim2.new(1,-52,0.5,-11); box.BackgroundColor3 = Color3.fromRGB(50,50,50); box.Parent = b; Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)
            local ball = Instance.new("Frame"); ball.Size = UDim2.new(0,18,0,18); ball.Position = UDim2.new(0,2,0.5,-9); ball.BackgroundColor3 = Color3.new(1,1,1); ball.Parent = box; Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
            local s = false
            ApplyNeon(b, tConfig.Neon, AccentColor)
            b.MouseButton1Click:Connect(function() s = not s; ball:TweenPosition(s and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), "Out", "Quad", 0.2, true); box.BackgroundColor3 = s and AccentColor or Color3.fromRGB(50,50,50); callback(s) end)
        end
        return Elements
    end
    return Window
end

return CyberPink
