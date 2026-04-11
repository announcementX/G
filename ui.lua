-- [[ CyberPink UI V11 - Professional Fix & Multi-Style ]]
local CyberPink = { _Toggled = true }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function CyberPink:CreateWindow(Config)
    local WindowName = Config.Name or "CyberPink UI"
    local MinStyle = Config.MinimizeStyle or "Default"
    local MinType = Config.MinimizeType or "Text"
    local MinValue = Config.MinimizeValue or "CP"
    
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
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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

    -- 【内容区域容器】一定要在最下面，防止挡住 Topbar
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -45)
    ContentContainer.Position = UDim2.new(0, 0, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 1
    ContentContainer.Parent = Main

    -- 【顶部标题栏】
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 2
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

    -- 【按钮组修复】
    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 90, 1, 0)
    Btns.Position = UDim2.new(1, -95, 0, 0)
    Btns.BackgroundTransparency = 1
    Btns.Parent = Topbar

    local function CreateTopBtn(text, color, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = pos
        btn.Text = text
        btn.TextColor3 = color
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = Btns
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
    end

    -- 【缩小逻辑】
    local function ToggleUI()
        CyberPink._Toggled = not CyberPink._Toggled
        if CyberPink._Toggled then
            -- 展开
            MainCorner.CornerRadius = UDim.new(0, 12)
            Main.BackgroundColor3 = MainColor
            Topbar.Visible = true
            ContentContainer.Visible = true
            if Main:FindFirstChild("MinElement") then Main.MinElement:Destroy() end
            Main:TweenSize(UDim2.new(0, 420, 0, 280), "Out", "Back", 0.4, true)
        else
            -- 缩小
            if MinStyle == "Default" then
                Main:TweenSize(UDim2.new(0, 420, 0, 45), "Out", "Quart", 0.3, true)
            else
                Topbar.Visible = false
                ContentContainer.Visible = false
                Main.BackgroundColor3 = MinBgColor
                
                -- 形状处理
                if MinStyle == "Circle" then MainCorner.CornerRadius = UDim.new(1, 0)
                elseif MinStyle == "RoundSquare" then MainCorner.CornerRadius = UDim.new(0, 15)
                else MainCorner.CornerRadius = UDim.new(0, 0) end

                -- 创建图标/文字
                local minEl
                if MinType == "Image" then
                    minEl = Instance.new("ImageLabel")
                    minEl.Image = MinValue
                    minEl.ImageColor3 = MinTextColor
                    minEl.Size = UDim2.new(0.6, 0, 0.6, 0)
                    minEl.Position = UDim2.new(0.2, 0, 0.2, 0)
                else
                    minEl = Instance.new("TextLabel")
                    minEl.Text = MinValue
                    minEl.TextColor3 = MinTextColor
                    minEl.Font = Enum.Font.GothamBold
                    minEl.TextSize = 18
                    minEl.Size = UDim2.new(1, 0, 1, 0)
                end
                minEl.Name = "MinElement"
                minEl.BackgroundTransparency = 1
                minEl.Parent = Main
                
                Main:TweenSize(UDim2.new(0, 60, 0, 60), "Out", "Back", 0.4, true)
            end
        end
    end

    CreateTopBtn("-", AccentColor, UDim2.new(0, 10, 0.5, -15), ToggleUI)
    CreateTopBtn("×", Color3.fromRGB(255, 100, 100), UDim2.new(0, 50, 0.5, -15), function() ScreenGui:Destroy() end)

    -- 【顶级拖拽逻辑修复 - 支持大窗口和悬浮窗】
    local dragging, dragStart, startPos
    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            -- 如果已经缩小，点击任何地方都还原；如果是大窗口，由 Topbar 负责（或全局）
            if not CyberPink._Toggled then
                ToggleUI()
            else
                dragging = true; dragStart = input.Position; startPos = Main.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    -- 【分页与按钮显示逻辑修复】
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
        TBtn.Font = Enum.Font.GothamSemibold
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
            for _, v in pairs(PageContainer:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
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
