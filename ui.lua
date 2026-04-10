local Library = {Tabs = {}; SelectedTab = nil}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

function Library:Init(HubName)
    local COLORS = {
        Main = Color3.fromRGB(255, 230, 240),
        Bar = Color3.fromRGB(255, 185, 205),
        Sidebar = Color3.fromRGB(255, 242, 248),
        Accent = Color3.fromRGB(255, 100, 160),
        Text = Color3.fromRGB(80, 50, 60),
        Success = Color3.fromRGB(150, 255, 150)
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PinkPremium_V3"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- --- 1. 帅气的加载动画 ---
    local LoadingFrame = Instance.new("Frame", ScreenGui)
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = COLORS.Main
    LoadingFrame.ZIndex = 100

    local Logo = Instance.new("TextLabel", LoadingFrame)
    Logo.Text = "❤"
    Logo.Size = UDim2.new(0, 100, 0, 100)
    Logo.Position = UDim2.new(0.5, -50, 0.5, -50)
    Logo.TextColor3 = COLORS.Accent
    Logo.TextSize = 80
    Logo.BackgroundTransparency = 1

    local LoadBarWrap = Instance.new("Frame", LoadingFrame)
    LoadBarWrap.Size = UDim2.new(0, 200, 0, 4)
    LoadBarWrap.Position = UDim2.new(0.5, -100, 0.5, 60)
    LoadBarWrap.BackgroundColor3 = COLORS.Bar
    Instance.new("UICorner", LoadBarWrap)

    local LoadBar = Instance.new("Frame", LoadBarWrap)
    LoadBar.Size = UDim2.new(0, 0, 1, 0)
    LoadBar.BackgroundColor3 = COLORS.Accent
    Instance.new("UICorner", LoadBar)

    -- 加载动画逻辑
    task.spawn(function()
        TweenService:Create(LoadBar, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(1.5)
        TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Logo, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(LoadBarWrap, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(LoadBar, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        LoadingFrame:Destroy()
    end)

    -- --- 2. 主框架 ---
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 520, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
    MainFrame.BackgroundColor3 = COLORS.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

    -- 渐变系统
    local function AddGrad(parent, rot, trans)
        local g = Instance.new("UIGradient", parent)
        g.Rotation = rot
        g.Transparency = trans
        g.Color = ColorSequence.new(COLORS.Bar, COLORS.Main)
    end

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Bar
    TopBar.ZIndex = 5
    AddGrad(TopBar, 90, NumberSequence.new(0, 1))

    local BottomBar = Instance.new("Frame", MainFrame)
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Bar
    BottomBar.ZIndex = 5
    AddGrad(BottomBar, -90, NumberSequence.new(0, 1))

    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Size = UDim2.new(0, 130, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.ZIndex = 4
    Sidebar.ScrollBarThickness = 0
    AddGrad(Sidebar, 0, NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}))
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local ContainerHolder = Instance.new("Frame", MainFrame)
    ContainerHolder.Size = UDim2.new(1, -145, 1, -100)
    ContainerHolder.Position = UDim2.new(0, 140, 0, 50)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.ZIndex = 6

    -- --- 3. 按钮与动画逻辑 ---
    local function Ripple(obj)
        obj.MouseButton1Click:Connect(function()
            local circle = Instance.new("Frame", obj)
            circle.BackgroundColor3 = Color3.new(1,1,1)
            circle.BackgroundTransparency = 0.5
            circle.Size = UDim2.new(0,0,0,0)
            circle.Position = UDim2.new(0.5,0,0.5,0)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
            TweenService:Create(circle, TweenInfo.new(0.4), {Size = UDim2.new(1.5,0,1.5,0), BackgroundTransparency = 1, Position = UDim2.new(-0.25,0,-0.25,0)}):Play()
            task.wait(0.4)
            circle:Destroy()
        end)
    end

    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.ZIndex = 7
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton", MainFrame)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -75, 0, 8)
    MinBtn.BackgroundColor3 = COLORS.Accent
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.ZIndex = 7
    Instance.new("UICorner", MinBtn)

    -- 关闭/缩小动画
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.BackIn), {Size = UDim2.new(0,0,0,0), ImageTransparency = 1}):Play()
        task.wait(0.4) ScreenGui:Destroy()
    end)

    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 0, 0, 0)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Visible = false
    MiniIcon.Text = "❤"
    MiniIcon.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", MiniIcon)

    MinBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.BackIn), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.4)
        MainFrame.Visible = false
        MiniIcon.Visible = true
        MiniIcon:TweenSize(UDim2.new(0,55,0,55), "Out", "Back", 0.4)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MiniIcon:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.3)
        task.wait(0.3)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.BackOut), {Size = UDim2.new(0,520,0,360)}):Play()
    end)

    -- --- 4. 核心 API 组件 ---
    function Library:CreateTab(name)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = Enum.Font.GothamMedium

        local Page = Instance.new("ScrollingFrame", ContainerHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContainerHolder:GetChildren()) do v.Visible = false end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = COLORS.Accent}):Play()
        end)

        local TabAPI = {}
        
        -- 按钮组件
        function TabAPI:AddButton(text, callback)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.new(1,1,1)
            b.BackgroundTransparency = 0.4
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.TextColor3 = COLORS.Text
            b.Font = "GothamSemibold"
            Instance.new("UICorner", b)
            Ripple(b)
            b.MouseButton1Click:Connect(callback)
        end

        -- 开关组件 (Toggle)
        function TabAPI:AddToggle(text, callback)
            local tMain = Instance.new("TextButton", Page)
            tMain.Size = UDim2.new(1, -10, 0, 40)
            tMain.BackgroundColor3 = Color3.new(1,1,1)
            tMain.BackgroundTransparency = 0.4
            tMain.Text = "  " .. text
            tMain.TextXAlignment = "Left"
            tMain.TextColor3 = COLORS.Text
            Instance.new("UICorner", tMain)

            local box = Instance.new("Frame", tMain)
            box.Size = UDim2.new(0, 34, 0, 18)
            box.Position = UDim2.new(1, -45, 0.5, -9)
            box.BackgroundColor3 = COLORS.Bar
            Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)

            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(0, 2, 0.5, -7)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

            local state = false
            tMain.MouseButton1Click:Connect(function()
                state = not state
                local targetX = state and 0.55 or 0
                TweenService:Create(dot, TweenInfo.new(0.3), {Position = UDim2.new(targetX, 2, 0.5, -7)}):Play()
                TweenService:Create(box, TweenInfo.new(0.3), {BackgroundColor3 = state and COLORS.Accent or COLORS.Bar}):Play()
                callback(state)
            end)
        end

        if #Sidebar:GetChildren() == 1 then Page.Visible = true end
        return TabAPI
    end

    -- 拖动逻辑
    local dStart, sPos, dragging = nil, nil, false
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dStart = i.Position sPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType.Name:find("Mouse") or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dStart
            MainFrame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    return Library
end

return Library
