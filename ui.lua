-- [[ CyberPink UI V8 - Mobile Optimized with Minimize ]]
local CyberPink = { _Toggled = true }
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function CyberPink:CreateWindow(Config)
    local WindowName = Config.Name or "CyberPink UI"
    
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "CyberPink_Root" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CyberPink_Root"
    ScreenGui.Parent = CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 420, 0, 280)
    Main.Position = UDim2.new(0.5, -210, 0.5, -140)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

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
    Title.TextColor3 = Color3.fromRGB(255, 192, 203)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- 【按钮组】
    local Btns = Instance.new("Frame")
    Btns.Size = UDim2.new(0, 80, 1, 0)
    Btns.Position = UDim2.new(1, -85, 0, 0)
    Btns.BackgroundTransparency = 1
    Btns.Parent = Topbar

    -- 关闭按钮
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(0, 45, 0.5, -15)
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(255, 100, 100)
    Close.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Close.Parent = Btns
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- 最小化按钮 (恢复正常！)
    local Minimize = Instance.new("TextButton")
    Minimize.Size = UDim2.new(0, 30, 0, 30)
    Minimize.Position = UDim2.new(0, 5, 0.5, -15)
    Minimize.Text = "-"
    Minimize.TextColor3 = Color3.fromRGB(255, 192, 203)
    Minimize.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Minimize.Parent = Btns
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 8)

    Minimize.MouseButton1Click:Connect(function()
        CyberPink._Toggled = not CyberPink._Toggled
        local targetSize = CyberPink._Toggled and UDim2.new(0, 420, 0, 280) or UDim2.new(0, 420, 0, 45)
        Main:TweenSize(targetSize, "Out", "Quart", 0.35, true)
    end)

    -- 【手机端丝滑拖拽】
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 内容区
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -45)
    ContentFrame.Position = UDim2.new(0, 0, 0, 45)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Main

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 120, 1, -10)
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = ContentFrame
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -135, 1, -10)
    PageContainer.Position = UDim2.new(0, 130, 0, 5)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentFrame

    local Window = {}
    function Window:CreateTab(Name)
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, 0, 0, 35)
        TBtn.Text = Name
        TBtn.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
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
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then v.BackgroundTransparency = 0.9 end 
            end
            Page.Visible = true
            TBtn.BackgroundTransparency = 0.8
            TBtn.TextColor3 = Color3.fromRGB(255, 192, 203)
        end)

        if #TabContainer:GetChildren() == 1 then Page.Visible = true TBtn.BackgroundTransparency = 0.8 TBtn.TextColor3 = Color3.fromRGB(255, 192, 203) end

        local Elements = {}
        function Elements:CreateToggle(tname, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 40)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.Text = "  " .. tname
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Font = Enum.Font.Gotham
            b.Parent = Page
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

            local s = false
            b.MouseButton1Click:Connect(function()
                s = not s
                b.TextColor3 = s and Color3.fromRGB(255, 192, 203) or Color3.fromRGB(255, 255, 255)
                callback(s)
            end)
        end
        return Elements
    end
    return Window
end

return CyberPink
