-- [[ CyberPink UI V12 - Full Customization & New Elements ]]
local CyberPink = { _Toggled = true }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function CyberPink:CreateWindow(Config)
    -- 全局配置继承
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 192, 203)
    local TitleColor = Config.TitleColor or AccentColor
    
    -- 缩小配置
    local MinStyle = Config.MinimizeStyle or "Default"
    local MinType = Config.MinimizeType or "Text"
    local MinValue = Config.MinimizeValue or "CP"
    local MinBgColor = Config.MinimizeBgColor or MainColor
    local MinTextColor = Config.MinimizeTextColor or AccentColor

    -- 清理
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "CyberPink_Root" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_Root"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.BackgroundColor3 = MainColor
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 【顶部标题栏 - 修复关闭按钮可见性】
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. (Config.Name or "CyberPink UI")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.TextColor3 = TitleColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 【按钮组 - 强制右对齐布局】
    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 100, 1, 0)
    Btns.Position = UDim2.new(1, -100, 0, 0)
    Btns.BackgroundTransparency = 1
    Btns.Parent = Topbar

    local function CreateTopBtn(text, color, xOffset, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(0, xOffset, 0.5, -15)
        btn.Text = text
        btn.TextColor3 = color
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = Btns
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
    end

    local function ToggleUI()
        CyberPink._Toggled = not CyberPink._Toggled
        if CyberPink._Toggled then
            Main:TweenSize(UDim2.new(0, 450, 0, 300), "Out", "Back", 0.4, true)
            if Main:FindFirstChild("MinElement") then Main.MinElement:Destroy() end
            Topbar.Visible = true
            Main.BackgroundColor3 = MainColor
            Main.Content.Visible = true
        else
            if MinStyle == "Default" then
                Main:TweenSize(UDim2.new(0, 450, 0, 45), "Out", "Quart", 0.3, true)
            else
                Topbar.Visible = false
                Main.Content.Visible = false
                Main.BackgroundColor3 = MinBgColor
                local minEl = (MinType == "Image") and Instance.new("ImageLabel") or Instance.new("TextLabel")
                minEl.Name = "MinElement"
                if MinType == "Image" then minEl.Image = MinValue; minEl.ImageColor3 = MinTextColor else minEl.Text = MinValue; minEl.TextColor3 = MinTextColor end
                minEl.Size = UDim2.new(1, 0, 1, 0); minEl.BackgroundTransparency = 1; minEl.Parent = Main
                Main:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Back", 0.4, true)
            end
        end
    end

    CreateTopBtn("-", AccentColor, 15, ToggleUI)
    CreateTopBtn("×", Color3.fromRGB(255, 100, 100), 55, function() ScreenGui:Destroy() end)

    -- 【拖拽修复】
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if not CyberPink._Toggled then ToggleUI() 
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

    local Window = {}
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 35); TBtn.Text = Name; TBtn.BackgroundColor3 = AccentColor
        TBtn.BackgroundTransparency = 0.9; TBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TBtn.Parent = TabScroll; Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false
        Page.ScrollBarThickness = 0; Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabScroll:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.9 end end
            Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor
        end)
        if #TabScroll:GetChildren() == 1 then Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor end

        local Elements = {}
        -- 1. 点击触发 (Button)
        function Elements:CreateButton(name, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(30,30,30)
            b.Text = "  " .. name; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(callback)
        end
        -- 2. 开关 (Toggle)
        function Elements:CreateToggle(name, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(30,30,30)
            b.Text = "  " .. name; b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = 0; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local s = false
            b.MouseButton1Click:Connect(function() s = not s; b.TextColor3 = s and AccentColor or Color3.new(1,1,1); callback(s) end)
        end
        -- 3. 输入触发 (Input)
        function Elements:CreateInput(name, placeholder, callback)
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundColor3 = Color3.fromRGB(30,30,30); f.Parent = Page
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
            local t = Instance.new("TextLabel")
            t.Text = "  " .. name; t.Size = UDim2.new(0.6, 0, 1, 0); t.BackgroundTransparency = 1
            t.TextColor3 = Color3.new(1,1,1); t.TextXAlignment = 0; t.Parent = f
            local i = Instance.new("TextBox")
            i.Size = UDim2.new(0.35, 0, 0.7, 0); i.Position = UDim2.new(0.6, 0, 0.15, 0)
            i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.Text = ""; i.PlaceholderText = placeholder
            i.TextColor3 = AccentColor; i.Parent = f; Instance.new("UICorner", i).CornerRadius = UDim.new(0, 5)
            i.FocusLost:Connect(function() callback(i.Text) end)
        end
        return Elements
    end
    return Window
end

return CyberPink
