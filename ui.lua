-- [[ CyberPink UI V26 | Flawless Execution Engine ]]
local CyberPink = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [1. 20+ 艺术字体字典]
local FontDict = {
    ["Default"] = Enum.Font.Gotham, ["Bold"] = Enum.Font.GothamBold, ["Black"] = Enum.Font.GothamBlack,
    ["Arcade"] = Enum.Font.Arcade, ["SciFi"] = Enum.Font.SciFi, ["Fantasy"] = Enum.Font.Fantasy,
    ["Antique"] = Enum.Font.Antique, ["Cartoon"] = Enum.Font.Cartoon, ["Code"] = Enum.Font.Code,
    ["SpecialElite"] = Enum.Font.SpecialElite, ["LuckiestGuy"] = Enum.Font.LuckiestGuy, 
    ["FredokaOne"] = Enum.Font.FredokaOne, ["Bangers"] = Enum.Font.Bangers, ["Creepster"] = Enum.Font.Creepster,
    ["DenkOne"] = Enum.Font.DenkOne, ["Fondamento"] = Enum.Font.Fondamento, ["Jura"] = Enum.Font.Jura,
    ["Kalam"] = Enum.Font.Kalam, ["Michroma"] = Enum.Font.Michroma, ["Oswald"] = Enum.Font.Oswald,
    ["PatrickHand"] = Enum.Font.PatrickHand, ["PermanentMarker"] = Enum.Font.PermanentMarker
}

-- [2. 20+ 动画样式字典]
local AnimDict = {
    ["Linear"] = {Enum.EasingStyle.Linear, 0.3}, ["Smooth"] = {Enum.EasingStyle.Quad, 0.4},
    ["Quick"] = {Enum.EasingStyle.Quart, 0.2}, ["Slow"] = {Enum.EasingStyle.Sine, 0.8},
    ["BackOut"] = {Enum.EasingStyle.Back, 0.5}, ["BackIn"] = {Enum.EasingStyle.Back, 0.5},
    ["Bounce"] = {Enum.EasingStyle.Bounce, 0.6}, ["HardBounce"] = {Enum.EasingStyle.Bounce, 0.3},
    ["Elastic"] = {Enum.EasingStyle.Elastic, 0.8}, ["SlowElastic"] = {Enum.EasingStyle.Elastic, 1.2},
    ["Expo"] = {Enum.EasingStyle.Exponential, 0.5}, ["Circular"] = {Enum.EasingStyle.Circular, 0.4},
    ["Cubic"] = {Enum.EasingStyle.Cubic, 0.4}, ["Quint"] = {Enum.EasingStyle.Quint, 0.5},
    ["Flash"] = {Enum.EasingStyle.Exponential, 0.1}, ["Soft"] = {Enum.EasingStyle.Sine, 0.3},
    ["Heavy"] = {Enum.EasingStyle.Quint, 0.9}, ["Spring"] = {Enum.EasingStyle.Back, 0.4},
    ["Wobble"] = {Enum.EasingStyle.Elastic, 0.6}, ["Snappy"] = {Enum.EasingStyle.Quart, 0.25}
}

-- [3. 20+ 悬浮窗形状字典]
local ShapeDict = {
    ["Circle"] = UDim.new(1, 0), ["Square"] = UDim.new(0, 0),
    ["RoundSquare"] = UDim.new(0, 15), ["SoftEdge"] = UDim.new(0, 8),
    ["Pill"] = UDim.new(0.5, 0), ["Leaf"] = UDim.new(0, 25), 
    ["Sharp"] = UDim.new(0, 2), ["Smooth"] = UDim.new(0, 12),
    ["Diamond"] = UDim.new(0.2, 0), ["HexagonSim"] = UDim.new(0.3, 0),
    ["OctagonSim"] = UDim.new(0.4, 0), ["Oval"] = UDim.new(1, 0),
    ["Ticket"] = UDim.new(0, 6), ["Card"] = UDim.new(0, 10),
    ["Badge"] = UDim.new(0.5, 0), ["Tag"] = UDim.new(0, 4),
    ["Modern"] = UDim.new(0, 20), ["Classic"] = UDim.new(0, 0),
    ["Future"] = UDim.new(0, 30), ["Minimal"] = UDim.new(0, 5)
}

local function ParseSize(val, default)
    if not val then return default end
    if type(val) == "number" then
        if val <= 1.0 then return UDim.new(val, 0) else return UDim.new(0, val) end
    end
    return default
end

-- [修复核心：高级拖拽与点击判定分离 (防止拖拽悬浮窗时触发恢复)]
local function MakeDraggableAndClickable(dragHandle, moveTarget, clickCallback)
    local dragging = false; local moved = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            dragStart = input.Position; startPos = moveTarget.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and clickCallback then clickCallback() end
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 3 then moved = true end -- 如果移动超过3像素，视为拖拽，不触发点击
            moveTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function ApplyNeon(inst, enabled, mode)
    if not enabled then return nil end
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = (mode == "Border" and 2.5 or 1.5)
    stroke.ApplyStrokeMode = (mode == "Border" and Enum.ApplyStrokeMode.Border or Enum.ApplyStrokeMode.Contextual)
    stroke.Parent = inst
    task.spawn(function()
        local h = 0
        while stroke.Parent do
            stroke.Color = Color3.fromHSV(h, 0.8, 1)
            h = (h + 0.003) % 1
            task.wait(0.02)
        end
    end)
    return stroke
end

function CyberPink:CreateWindow(Config)
    local Window = { _Toggled = true }
    
    local W = Config.Width or 550; local H = Config.Height or 350
    local MainUDimW = ParseSize(W, UDim.new(0, 550)); local MainUDimH = ParseSize(H, UDim.new(0, 350))
    local MinW = Config.MinW or 80; local MinH = Config.MinH or 80
    local MinUDimW = ParseSize(MinW, UDim.new(0, 80)); local MinUDimH = ParseSize(MinH, UDim.new(0, 80))

    local TitleSize = math.clamp(Config.TitleSize or 16, 10, 50)
    local MainBgColor = Config.MainBgColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 105, 180)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_V26"; ScreenGui.Parent = CoreGui; ScreenGui.IgnoreGuiInset = true

    -- [重制：真正的高级加载界面]
    if Config.LoadMode and Config.LoadMode ~= "None" then
        local LFrame = Instance.new("Frame")
        LFrame.BackgroundColor3 = Config.LoadBgColor or Color3.fromRGB(10, 10, 10)
        LFrame.BorderSizePixel = 0; LFrame.Parent = ScreenGui; LFrame.ZIndex = 10000
        
        if Config.LoadMode == "FullScreen" then
            LFrame.Size = UDim2.new(1, 0, 1, 0); LFrame.Position = UDim2.new(0, 0, 0, 0)
        else
            LFrame.Size = UDim2.new(0, 400, 0, 250); LFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
            Instance.new("UICorner", LFrame).CornerRadius = UDim.new(0, 15)
            ApplyNeon(LFrame, true, "Border")
        end
        
        -- 旋转光环
        local Spinner = Instance.new("Frame", LFrame)
        Spinner.Size = UDim2.new(0, 80, 0, 80); Spinner.Position = UDim2.new(0.5, -40, 0.5, -60)
        Spinner.BackgroundTransparency = 1
        Instance.new("UICorner", Spinner).CornerRadius = UDim.new(1, 0)
        ApplyNeon(Spinner, true, "Border")
        task.spawn(function() while Spinner.Parent do Spinner.Rotation = Spinner.Rotation + 4; task.wait(0.01) end end)

        -- 居中文字
        local LTxt = Instance.new("TextLabel", LFrame)
        LTxt.Size = UDim2.new(1, 0, 0, 50); LTxt.Position = UDim2.new(0, 0, 0.5, 30)
        LTxt.Text = Config.LoadText or "SYSTEM BOOTING..."
        LTxt.TextColor3 = Config.LoadTextColor or AccentColor; LTxt.BackgroundTransparency = 1
        LTxt.Font = FontDict[Config.LoadFont] or Enum.Font.GothamBlack
        LTxt.TextScaled = true -- 确保文字绝不越界
        local tc = Instance.new("UITextSizeConstraint", LTxt)
        tc.MaxTextSize = math.clamp(Config.LoadTextSize or 30, 10, 80)
        ApplyNeon(LTxt, Config.LoadNeon, "Text")

        local anim = AnimDict[Config.LoadAnim or "Quint"]
        task.wait(Config.LoadTime or 2)
        LFrame:TweenPosition(UDim2.new(0.5, -200, -1, 0), "In", anim[1], anim[2], true, function() LFrame:Destroy() end)
    end

    function Window:Notify(nConfig)
        local positions = {
            ["TopRight"] = UDim2.new(1, -310, 0, 20), ["TopLeft"] = UDim2.new(0, 20, 0, 20),
            ["BottomRight"] = UDim2.new(1, -310, 1, -100), ["BottomLeft"] = UDim2.new(0, 20, 1, -100)
        }
        local NFrame = Instance.new("Frame")
        NFrame.Size = UDim2.new(0, 280, 0, 70); NFrame.Position = positions[nConfig.Position or "BottomRight"] or positions["BottomRight"]
        NFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); NFrame.Parent = ScreenGui
        Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 8); ApplyNeon(NFrame, true, "Border")

        local txtOffset = 10
        if nConfig.Image then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 40, 0, 40); img.Position = UDim2.new(0, 15, 0.5, -20)
            img.Image = nConfig.Image; img.BackgroundTransparency = 1; img.Parent = NFrame
            txtOffset = 65
        end

        local Txt = Instance.new("TextLabel")
        Txt.Size = UDim2.new(1, -(txtOffset+10), 1, 0); Txt.Position = UDim2.new(0, txtOffset, 0, 0)
        Txt.Text = nConfig.Text or "Notice"; Txt.TextColor3 = Color3.new(1,1,1)
        Txt.Font = FontDict[nConfig.Font] or Enum.Font.Gotham; Txt.TextSize = 14
        Txt.BackgroundTransparency = 1; Txt.TextWrapped = true; Txt.TextXAlignment = Enum.TextXAlignment.Left; Txt.Parent = NFrame
        task.delay(nConfig.Duration or 3, function() NFrame:Destroy() end)
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"; Main.BackgroundColor3 = MainBgColor; Main.ClipsDescendants = true
    Main.Size = UDim2.new(MainUDimW.Scale, MainUDimW.Offset, MainUDimH.Scale, MainUDimH.Offset)
    Main.Position = UDim2.new(0.5, -(MainUDimW.Offset/2), 0.5, -(MainUDimH.Offset/2))
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(0, 12)
    local MainNeonStroke = ApplyNeon(Main, Config.NeonMain, "Border")

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45); Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Topbar.Parent = Main
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = Config.Name or "UI Engine"; Title.TextColor3 = AccentColor
    Title.Font = FontDict[Config.TitleFont] or Enum.Font.GothamBold; Title.TextSize = TitleSize; Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Topbar
    ApplyNeon(Title, Config.NeonTitle, "Text")

    -- 缩小悬浮窗容器
    local MinContainer = Instance.new("Frame")
    MinContainer.Size = UDim2.new(1, 0, 1, 0); MinContainer.BackgroundTransparency = 1; MinContainer.Visible = false; MinContainer.Parent = Main
    local MinContent
    if Config.MinType == "Image" then
        MinContent = Instance.new("ImageLabel"); MinContent.Image = Config.MinImage or ""
    else
        MinContent = Instance.new("TextLabel"); MinContent.Text = Config.MinText or "CP"
        MinContent.Font = FontDict[Config.MinFont] or Enum.Font.GothamBold
        MinContent.TextScaled = true
        local mtc = Instance.new("UITextSizeConstraint", MinContent)
        mtc.MaxTextSize = math.clamp(Config.MinTextSize or 30, 10, 150)
    end
    MinContent.Size = UDim2.new(1, 0, 1, 0); MinContent.BackgroundTransparency = 1; MinContent.TextColor3 = AccentColor; MinContent.Parent = MinContainer
    ApplyNeon(MinContent, Config.NeonMinText, "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -45); Content.Position = UDim2.new(0, 0, 0, 45); Content.BackgroundTransparency = 1; Content.Parent = Main
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(0, 130, 1, -10); TabScroll.Position = UDim2.new(0, 10, 0, 5); TabScroll.BackgroundTransparency = 1; TabScroll.ScrollBarThickness = 0; TabScroll.Parent = Content
    Instance.new("UIListLayout", TabScroll).Padding = UDim.new(0, 5)
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -150, 1, -10); PageContainer.Position = UDim2.new(0, 140, 0, 5); PageContainer.BackgroundTransparency = 1; PageContainer.Parent = Content

    -- [修复：缩小与恢复切换核心]
    local function ToggleUI()
        Window._Toggled = not Window._Toggled
        local minAnim = AnimDict[Config.MinAnim or "Bounce"]
        
        if Window._Toggled then
            -- 恢复大窗口
            MinContainer.Visible = false
            Content.Visible = true; Topbar.Visible = true
            MainCorner.CornerRadius = UDim.new(0, 12)
            if MainNeonStroke then MainNeonStroke.Enabled = Config.NeonMain end
            Main:TweenSize(UDim2.new(MainUDimW.Scale, MainUDimW.Offset, MainUDimH.Scale, MainUDimH.Offset), "Out", minAnim[1], minAnim[2], true)
        else
            -- 变成悬浮窗
            Content.Visible = false; Topbar.Visible = false
            MinContainer.Visible = true
            MainCorner.CornerRadius = ShapeDict[Config.MinShape] or UDim.new(1, 0)
            if MainNeonStroke then MainNeonStroke.Enabled = Config.NeonMin end
            Main:TweenSize(UDim2.new(MinUDimW.Scale, MinUDimW.Offset, MinUDimH.Scale, MinUDimH.Offset), "Out", minAnim[1], minAnim[2], true)
        end
    end

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0.5, -15); CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.Parent = Topbar; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -75, 0.5, -15); MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Parent = Topbar; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
    
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- 挂载拖拽：大窗口拖标题栏，小窗口拖容器（并且小窗口单击可恢复）
    MakeDraggableAndClickable(Topbar, Main, nil)
    MakeDraggableAndClickable(MinContainer, Main, ToggleUI)

    function Window:CreateTab(Name, tConfig)
        tConfig = tConfig or {}
        local TBtn = Instance.new("TextButton")
        local tW = ParseSize(tConfig.Width, UDim.new(1, 0)); local tH = ParseSize(tConfig.Height, UDim.new(0, 35))
        TBtn.Size = UDim2.new(tW.Scale, tW.Offset, tH.Scale, tH.Offset)
        TBtn.Text = Name; TBtn.BackgroundColor3 = AccentColor; TBtn.BackgroundTransparency = 0.8
        TBtn.TextColor3 = Color3.new(1,1,1)
        TBtn.Font = FontDict[tConfig.Font] or FontDict[Config.TabFont] or Enum.Font.Gotham
        TBtn.TextSize = math.clamp(tConfig.Size or Config.TabSize or 14, 8, 40)
        TBtn.Parent = TabScroll; Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 6)
        ApplyNeon(TBtn, tConfig.Neon, "Text")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            Page.Visible = true
        end)

        local Elements = {}
        function Elements:CreateButton(text, callback, bConfig)
            bConfig = bConfig or {}
            local b = Instance.new("TextButton")
            local bW = ParseSize(bConfig.Width, UDim.new(1, 0)); local bH = ParseSize(bConfig.Height, UDim.new(0, 40))
            b.Size = UDim2.new(bW.Scale, bW.Offset, bH.Scale, bH.Offset)
            b.Text = "  " .. text; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = FontDict[bConfig.Font] or FontDict[Config.ElementFont] or Enum.Font.Gotham
            b.Parent = Page; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            
            b.TextScaled = true
            local constrain = Instance.new("UITextSizeConstraint", b)
            constrain.MaxTextSize = math.clamp(bConfig.Size or Config.ElementSize or 14, 8, 100)
            
            ApplyNeon(b, bConfig.NeonBorder, "Border")
            ApplyNeon(b, bConfig.NeonText, "Text")
            
            b.MouseButton1Click:Connect(callback)
        end
        return Elements
    end
    return Window
end

return CyberPink
