-- [[ CyberPink UI V10 - Infinite Customization Edition ]]
local CyberPink = { _Toggled = true }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function CyberPink:CreateWindow(Config)
    -- 获取配置参数 (提供默认值)
    local WindowName = Config.Name or "CyberPink UI"
    local MinStyle = Config.MinimizeStyle or "Default"
    local MinType = Config.MinimizeType or "Text" -- "Text" 或 "Image"
    local MinValue = Config.MinimizeValue or "CP"   -- 缩小时显示的文字或图片链接
    
    -- 颜色配置 (默认黑粉)
    local MainColor = Config.MainColor or Color3.fromRGB(15, 15, 15)
    local AccentColor = Config.AccentColor or Color3.fromRGB(255, 192, 203)
    local MinBgColor = Config.MinimizeBgColor or MainColor
    local MinTextColor = Config.MinimizeTextColor or AccentColor

    -- 清理旧 UI
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "CyberPink_Root" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_Root"
    ScreenGui.Parent = CoreGui
    
    -- 主窗口
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 420, 0, 280)
    Main.Position = UDim2.new(0.5, -210, 0.5, -140)
    Main.BackgroundColor3 = MainColor
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 12)

    -- 【顶部标题栏】
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = "  " .. WindowName
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.TextColor3 = AccentColor
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 【内容区域容器 - 解决缩小后显示栏目的问题】
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, 0, 1, -45)
    ContentContainer.Position = UDim2.new(0, 0, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Main

    -- 【缩小后的悬浮组件】
    local MinIcon = Instance.new("TextButton") -- 使用 TextButton 兼顾文本和点击
    MinIcon.Name = "MinIcon"
    MinIcon.Size = UDim2.new(1, 0, 1, 0)
    MinIcon.BackgroundTransparency = 1
    MinIcon.Text = ""
    MinIcon.Visible = false
    MinIcon.Parent = Main

    local MinImage = Instance.new("ImageLabel")
    MinImage.Size = UDim2.new(0.7, 0, 0.7, 0)
    MinImage.Position = UDim2.new(0.15, 0, 0.15, 0)
    MinImage.BackgroundTransparency = 1
    MinImage.Visible = false
    MinImage.Parent = Main

    -- 【核心：最小化逻辑】
    local function ToggleUI()
        self._Toggled = not self._Toggled
        
        if self._Toggled then
            -- 展开
            MainCorner.CornerRadius = UDim.new(0, 12)
            Main.BackgroundColor3 = MainColor
            Topbar.Visible = true
            ContentContainer.Visible = true
            MinIcon.Visible = false
            MinImage.Visible = false
            Main:TweenSize(UDim2.new(0, 420, 0, 280), "Out", "Back", 0.4, true)
        else
            -- 缩小
            if MinStyle == "Default" then
                Main:TweenSize(UDim2.new(0, 420, 0, 45), "Out", "Quart", 0.3, true)
            else
                -- 变成悬浮窗样式
                Topbar.Visible = false
                ContentContainer.Visible = false
                Main.BackgroundColor3 = MinBgColor
                
                -- 设置形状
                if MinStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0)
                elseif MinStyle == "RoundSquare" then MainCorner.CornerRadius = UDim.new(0, 15)
                else MainCorner.CornerRadius = UDim.new(0, 0) end

                -- 设置内容 (文字或图片)
                if MinType == "Image" then
                    MinImage.Image = MinValue
                    MinImage.ImageColor3 = MinTextColor
                    MinImage.Visible = true
                else
                    MinIcon.Text = MinValue
                    MinIcon.TextColor3 = MinTextColor
                    MinIcon.Font = Enum.Font.GothamBold
                    MinIcon.TextSize = 20
                    MinIcon.Visible = true
                end
                
                Main:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Back", 0.4, true)
            end
        end
    end

    -- 最小化按钮点击
    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 30, 0, 30)
    MiniBtn.Position = UDim2.new(1, -75, 0.5, -15)
    MiniBtn.Text = "-"
    MiniBtn.TextColor3 = AccentColor
    MiniBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MiniBtn.Parent = Topbar
    Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 8)
    MiniBtn.MouseButton1Click:Connect(ToggleUI)
    
    -- 缩小后的点击还原
    MinIcon.MouseButton1Click:Connect(ToggleUI)

    -- 【手机端拖拽】
    local dragging, dragStart, startPos
    local function HandleDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(HandleDrag)

    -- ... (CreateTab 和 CreateToggle 逻辑保持不变，但父级设为 ContentContainer) ...
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 120, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = ContentContainer
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -135, 1, -10)
    PageContainer.Position = UDim2.new(0, 130, 0, 5)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentContainer

    local Window = {}
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 35)
        TBtn.Text = Name
        TBtn.BackgroundColor3 = AccentColor
        TBtn.BackgroundTransparency = 0.9
        TBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TBtn.Parent = TabContainer
        Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.Parent = PageContainer
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 0.9 end end
            Page.Visible = true; TBtn.BackgroundTransparency = 0.8; TBtn.TextColor3 = AccentColor
        end)
        
        if #TabContainer:GetChildren() == 1 then Page.Visible = true TBtn.BackgroundTransparency = 0.8 TBtn.TextColor3 = AccentColor end
        
        local Elements = {}
        function Elements:CreateToggle(tname, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 40)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.Text = "  " .. tname
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham; b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local s = false
            b.MouseButton1Click:Connect(function() s = not s; b.TextColor3 = s and AccentColor or Color3.fromRGB(255, 255, 255); callback(s) end)
        end
        return Elements
    end
    return Window
end

return CyberPink
