-- [[ CyberPink UI V14 - Complete Standard Edition ]]
local CyberPink = { _Toggled = true, _SelectedTab = nil }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- 动画预设库
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
    -- 配置初始化
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 192, 203)
    local TitleColor = Config.TitleColor or AccentColor
    
    local OpenAnim = AnimStyles[Config.OpenAnimation or "Default"]
    local MinAnim = AnimStyles[Config.MinimizeAnimation or "Default"]
    local CloseAnim = AnimStyles[Config.CloseAnimation or "Default"]

    -- 清理旧 UI
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "CyberPink_Root" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_Root"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 主窗口
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.ClipsDescendants = true
    Main.BackgroundColor3 = MainColor
    Main.BorderSizePixel = 0
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    -- 打开动画
    if OpenAnim[2] > 0 then
        Main:TweenSizeAndPosition(UDim2.new(0, 450, 0, 300), UDim2.new(0.5, -225, 0.5, -150), "Out", OpenAnim[1], OpenAnim[2], true)
    else
        Main.Size = UDim2.new(0, 450, 0, 300)
        Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    end

    -- 标题栏
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.ZIndex = 5
    Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. (Config.Name or "CyberPink UI")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.TextColor3 = TitleColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 按钮组容器
    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 100, 1, 0)
    Btns.Position = UDim2.new(1, -100, 0, 0)
    Btns.BackgroundTransparency = 1
    Btns.ZIndex = 6
    Btns.Parent = Topbar

    -- 切换/最小化逻辑
    local function ToggleUI()
        self._Toggled = not self._Toggled
        local targetSize
        
        if self._Toggled then
            -- 展开逻辑
            Main.Content.Visible = true
            Topbar.Visible = true
            if Main:FindFirstChild("MinElement") then Main.MinElement:Destroy() end
            MainCorner.CornerRadius = UDim.new(0, 12)
            Main.BackgroundColor3 = MainColor
            targetSize = UDim2.new(0, 450, 0, 300)
        else
            -- 缩小逻辑
            if Config.MinimizeStyle == "Default" or not Config.MinimizeStyle then
                targetSize = UDim2.new(0, 450, 0, 45)
            else
                Main.Content.Visible = false
                Topbar.Visible = false
                Main.BackgroundColor3 = Config.MinimizeBgColor or MainColor
                
                -- 处理形状
                if Config.MinimizeStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0)
                elseif Config.MinimizeStyle == "RoundSquare" then MainCorner.CornerRadius = UDim.new(0, 15) end
                
                -- 创建缩小占位符
                local minEl = (Config.MinimizeType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
                minEl.Name = "MinElement"
                minEl.Size = UDim2.new(1, 0, 1, 0)
                minEl.BackgroundTransparency = 1
                if Config.MinimizeType == "Image" then
                    minEl.Image = Config.MinimizeValue; minEl.ImageColor3 = Config.MinimizeTextColor or AccentColor
                else
                    minEl.Text = Config.MinimizeValue or "CP"; minEl.TextColor3 = Config.MinimizeTextColor or AccentColor
                    minEl.Font = Enum.Font.GothamBold; minEl.TextSize = 20
                end
                minEl.Parent = Main
                targetSize = UDim2.new(0, 60, 0, 60)
            end
        end
        Main:TweenSize(targetSize, "Out", MinAnim[1], MinAnim[2], true)
    end

    -- 创建顶部按钮
    local function CreateTopBtn(text, color, xPos, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(0, xPos, 0.5, -15)
        b.Text = text; b.TextColor3 = color; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        b.Font = Enum.Font.GothamBold; b.Parent = Btns
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(cb)
    end

    CreateTopBtn("-", AccentColor, 15, ToggleUI)
    CreateTopBtn("×", Color3.fromRGB(255, 100, 100), 55, function()
        if CloseAnim[2] > 0 then
            Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", CloseAnim[1], CloseAnim[2], true, function() ScreenGui:Destroy() end)
        else
            ScreenGui:Destroy()
        end
    end)

    -- 手机拖拽逻辑
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not self._Toggled then ToggleUI() 
            else dragging = true; dragStart = input.Position; startPos = Main.Position end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    -- 内容区
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(0, 120, 1, -10)
    TabScroll.Position = UDim2.new(0, 5, 0, 5)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Content
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -135, 1, -10)
    PageContainer.Position = UDim2.new(0, 130, 0, 5)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    local Window = { _Tabs = {}, _DefaultSet = Config.DefaultTab }

    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 35); TBtn.Text = Name
        TBtn.BackgroundColor3 = AccentColor; TBtn.BackgroundTransparency = 0.9; TBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TBtn.Font = Enum.Font.GothamSemibold; TBtn.Parent = TabScroll; Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)

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

        -- 处理默认页面逻辑
        task.spawn(function()
            if self._DefaultSet == Name then Select()
            elseif self._DefaultSet == nil and #TabScroll:GetChildren() == 1 then Select() end
        end)

        local Elements = {}

        -- 按钮
        function Elements:CreateButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.Text = "  " .. text; b.TextColor3 = Color3.new(1, 1, 1); b.TextXAlignment = 0
            b.Font = Enum.Font.Gotham; b.Parent = Page; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(callback)
        end

        -- 滑动开关 (Toggle Switch)
        function Elements:CreateToggle(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.Text = "  " .. text; b.TextColor3 = Color3.new(1, 1, 1); b.TextXAlignment = 0
            b.Font = Enum.Font.Gotham; b.Parent = Page; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 40, 0, 20); box.Position = UDim2.new(1, -50, 0.5, -10)
            box.BackgroundColor3 = Color3.fromRGB(50, 50, 50); box.Parent = b; Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local ball = Instance.new("Frame")
            ball.Size = UDim2.new(0, 16, 0, 16); ball.Position = UDim2.new(0, 2, 0.5, -8)
            ball.BackgroundColor3 = Color3.new(1, 1, 1); ball.Parent = box; Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

            local s = false
            b.MouseButton1Click:Connect(function()
                s = not s
                local targetX = s and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetCol = s and AccentColor or Color3.fromRGB(50, 50, 50)
                TweenService:Create(ball, TweenInfo.new(0.25), {Position = targetX}):Play()
                TweenService:Create(box, TweenInfo.new(0.25), {BackgroundColor3 = targetCol}):Play()
                callback(s)
            end)
        end

        -- 输入框
        function Elements:CreateInput(text, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 38); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.Parent = Page
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

            local l = Instance.new("TextLabel")
            l.Text = "  " .. text; l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1
            l.TextColor3 = Color3.new(1, 1, 1); l.TextXAlignment = 0; l.Font = Enum.Font.Gotham; l.Parent = f

            local i = Instance.new("TextBox")
            i.Size = UDim2.new(0.4, 0, 0.7, 0); i.Position = UDim2.new(0.55, 0, 0.15, 0)
            i.BackgroundColor3 = Color3.fromRGB(40, 40, 40); i.Text = ""; i.PlaceholderText = placeholder
            i.TextColor3 = AccentColor; i.Font = Enum.Font.Gotham; i.Parent = f; Instance.new("UICorner", i).CornerRadius = UDim.new(0, 6)
            i.FocusLost:Connect(function() callback(i.Text) end)
        end

        return Elements
    end
    return Window
end

return CyberPink
