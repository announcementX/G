local Library = {Tabs = {}; Count = 0; IsMobile = true; Dragging = false}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V12_PRO"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        Main = Color3.fromRGB(255, 240, 245),
        Accent = Color3.fromRGB(255, 100, 160),
        Dark = Color3.fromRGB(15, 10, 12),
        Sidebar = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 225)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 245))
        })
    }

    -- --- 1. 高级加载动画：灵魂坍缩 (全屏) ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.Dark
    Loader.ZIndex = 10000

    local Logo = Instance.new("TextLabel", Loader)
    Logo.Text = "S  O  U  L"
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 50
    Logo.TextColor3 = Color3.new(1, 1, 1)
    Logo.Size = UDim2.new(1, 0, 1, 0)
    Logo.BackgroundTransparency = 1
    Logo.ZIndex = 10001

    -- 粒子背景动效
    task.spawn(function()
        for i = 1, 30 do
            local p = Instance.new("Frame", Loader)
            p.Size = UDim2.new(0, 3, 0, 3)
            p.BackgroundColor3 = COLORS.Accent
            p.Position = UDim2.new(math.random(), 0, math.random(), 0)
            Instance.new("UICorner", p)
            TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}):Play()
        end
        TweenService:Create(Logo, TweenInfo.new(1.2, Enum.EasingStyle.Back), {TextSize = 100}):Play()
        task.wait(1.5)
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Logo, TweenInfo.new(0.8), {TextTransparency = 1, TextSize = 150}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (物理重构) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Main.ZIndex = 100
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 侧边栏
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Color3.new(1,1,1)
    Sidebar.ZIndex = 110
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Color = COLORS.Sidebar
    SGrad.Rotation = 90

    local SideScroll = Instance.new("ScrollingFrame", Sidebar)
    SideScroll.Size = UDim2.new(1, 0, 1, -60)
    SideScroll.Position = UDim2.new(0, 0, 0, 60)
    SideScroll.BackgroundTransparency = 1
    SideScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", SideScroll).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -160, 1, -70)
    Container.Position = UDim2.new(0, 150, 0, 60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 105

    -- --- 3. 手机端顶级拖拽系统 (物理帧同步) ---
    local function EnableDrag(UI)
        local dragInput, dragStart, startPos
        UI.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Library.Dragging = true
                dragStart = input.Position
                startPos = UI.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Library.Dragging = false end
                end)
            end
        end)
        UI.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        RunService.RenderStepped:Connect(function()
            if Library.Dragging and dragInput then
                local delta = dragInput.Position - dragStart
                UI.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    EnableDrag(Main)

    -- --- 4. 纯手工控制键 (解决叉号显示) ---
    local function CreateIconBtn(x, color, cb, isClose)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(1, x, 0, 15)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.ZIndex = 500
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        local l1 = Instance.new("Frame", btn)
        l1.Size = UDim2.new(0.6, 0, 0, 2)
        l1.Position = UDim2.new(0.5, 0, 0.5, 0)
        l1.AnchorPoint = Vector2.new(0.5, 0.5)
        l1.BackgroundColor3 = Color3.new(1,1,1)
        l1.BorderSizePixel = 0
        if isClose then
            l1.Rotation = 45
            local l2 = l1:Clone()
            l2.Parent = btn
            l2.Rotation = -45
        end
        
        btn.MouseButton1Click:Connect(cb)
    end

    -- 极小化悬浮窗
    local MiniBall = Instance.new("TextButton", ScreenGui)
    MiniBall.Size = UDim2.new(0, 45, 0, 45)
    MiniBall.BackgroundColor3 = COLORS.Accent
    MiniBall.Text = "S"
    MiniBall.Font = "GothamBold"
    MiniBall.TextColor3 = Color3.new(1, 1, 1)
    MiniBall.Visible = false
    MiniBall.ZIndex = 2000
    Instance.new("UICorner", MiniBall).CornerRadius = UDim.new(1,0)
    EnableDrag(MiniBall)

    CreateIconBtn(-45, Color3.fromRGB(255, 95, 95), function()
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.4, true)
        task.wait(0.4) ScreenGui:Destroy()
    end, true)

    CreateIconBtn(-85, COLORS.Accent, function()
        Main.Visible = false
        MiniBall.Visible = true
        MiniBall.Position = UDim2.new(0.5, -22, 0.1, 0)
    end, false)

    MiniBall.MouseButton1Click:Connect(function()
        Main.Visible = true
        MiniBall.Visible = false
    end)

    -- --- 5. 核心 API (强制物理切换) ---
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count

        local TabBtn = Instance.new("TextButton", SideScroll)
        TabBtn.Size = UDim2.new(1, -20, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(100, 80, 90)
        TabBtn.Font = "Gotham"
        TabBtn.TextSize = 14

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            -- 强制物理清除
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(SideScroll:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(100, 80, 90) end end
            
            Page.Visible = true
            TabBtn.TextColor3 = COLORS.Accent
            -- 切入动画
            Page.Position = UDim2.new(0, 30, 0, 0)
            Page:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.4, true)
        end)

        if ID == 1 then task.delay(1.5, function() Page.Visible = true; TabBtn.TextColor3 = COLORS.Accent end) end

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 42)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
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
