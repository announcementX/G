local Library = {Tabs = {}; CurrentTab = nil; FirstTab = nil}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V7"
    ScreenGui.IgnoreGuiInset = true
    
    local COLORS = {
        Main = Color3.fromRGB(255, 235, 245), -- 极淡粉
        Bar = Color3.fromRGB(255, 180, 210),  -- 稍深粉
        Sidebar = Color3.fromRGB(255, 220, 235), -- 侧边渐变粉
        Accent = Color3.fromRGB(255, 100, 160),
        Text = Color3.fromRGB(80, 50, 65)
    }

    -- --- 1. 震撼全屏灵魂加载 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(20, 10, 15)
    Loader.ZIndex = 10000

    local SoulText = Instance.new("TextLabel", Loader)
    SoulText.Text = "S O U L"
    SoulText.Font = "GothamBold"
    SoulText.TextSize = 80
    SoulText.TextColor3 = COLORS.Main
    SoulText.Size = UDim2.new(1, 0, 1, 0)
    SoulText.BackgroundTransparency = 1

    task.spawn(function()
        TweenService:Create(SoulText, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextSize = 90, TextTransparency = 0.5}):Play()
        task.wait(2)
        TweenService:Create(Loader, TweenInfo.new(1, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
        TweenService:Create(SoulText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (背景渐变) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 560, 0, 380)
    Main.Position = UDim2.new(0.5, -280, 0.5, -190)
    Main.BackgroundColor3 = Color3.new(1, 1, 1)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

    -- 背景渐变色
    local MainGrad = Instance.new("UIGradient", Main)
    MainGrad.Color = ColorSequence.new(COLORS.Main, Color3.fromRGB(255, 250, 252))
    MainGrad.Rotation = 45

    -- 侧边栏 (带向右消失的渐变)
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.ZIndex = 5
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 1)})
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -160, 1, -60)
    Container.Position = UDim2.new(0, 150, 0, 50)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 2

    -- --- 3. 拖拽与功能键逻辑 ---
    local function MakeDraggable(obj)
        local dragStart, startPos, dragging
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true dragStart = i.Position startPos = obj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() dragging = false end)
    end
    MakeDraggable(Main)

    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 110, 110)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.ZIndex = 10
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -74, 0, 10)
    MinBtn.BackgroundColor3 = COLORS.Accent
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.ZIndex = 10
    Instance.new("UICorner", MinBtn)

    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 55, 0, 55)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "S"
    MiniIcon.Font = "GothamBold"
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.Visible = false
    MiniIcon.ZIndex = 100
    Instance.new("UICorner", MiniIcon)
    MakeDraggable(MiniIcon)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.BackIn), {Size = UDim2.new(0, 0, 0, 0), Position = Main.Position + UDim2.new(0, 280, 0, 190)}):Play()
        task.wait(0.4) ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon.Position = UDim2.new(0.5, -27, 0.5, -27)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 560, 0, 380), "Out", "Back", 0.4, true)
        MiniIcon.Visible = false
    end)

    -- --- 4. API (修复无法切换和默认开启) ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 45)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "Gotham"
        TabBtn.TextSize = 14
        TabBtn.ZIndex = 6

        local Highlight = Instance.new("Frame", TabBtn)
        Highlight.Size = UDim2.new(0, 3, 0, 0)
        Highlight.Position = UDim2.new(0, 0, 0.5, 0)
        Highlight.BackgroundColor3 = COLORS.Accent
        Highlight.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        local function Activate()
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = COLORS.Text}):Play()
                    TweenService:Create(v.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}):Play()
                end
            end
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Accent}):Play()
            TweenService:Create(Highlight, TweenInfo.new(0.3), {Size = UDim2.new(0, 4, 0, 25), Position = UDim2.new(0, 0, 0.5, -12.5)}):Play()
        end

        TabBtn.MouseButton1Click:Connect(Activate)

        if not Library.FirstTab then
            Library.FirstTab = Activate
            task.delay(0.1, function() Activate() end)
        end

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.5
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.Font = "GothamBold"
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(cb)
        end
        return TabAPI
    end

    return Library
end

return Library
