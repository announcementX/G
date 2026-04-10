local Library = {Tabs = {}; SelectedTab = nil; Count = 0}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local COLORS = {
        Main = Color3.fromRGB(255, 235, 240), -- 极淡粉
        Bar = Color3.fromRGB(255, 190, 210),  -- 稍深粉
        Sidebar = Color3.fromRGB(255, 245, 250),
        Accent = Color3.fromRGB(255, 130, 170), -- 强调粉
        Text = Color3.fromRGB(60, 50, 55),
        Dark = Color3.fromRGB(40, 40, 40)
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SOUL_ENGINE"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- --- 1. SOUL 启动加载动画 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.Main
    Loader.ZIndex = 1000

    local SoulTitle = Instance.new("TextLabel", Loader)
    SoulTitle.Text = "SOUL"
    SoulTitle.Size = UDim2.new(0, 200, 0, 100)
    SoulTitle.Position = UDim2.new(0.5, -100, 0.45, -50)
    SoulTitle.Font = Enum.Font.GothamBold
    SoulTitle.TextColor3 = COLORS.Accent
    SoulTitle.TextSize = 80
    SoulTitle.BackgroundTransparency = 1
    SoulTitle.TextTransparency = 1

    local Line = Instance.new("Frame", Loader)
    Line.Size = UDim2.new(0, 0, 0, 2)
    Line.Position = UDim2.new(0.5, 0, 0.55, 0)
    Line.BackgroundColor3 = COLORS.Accent
    Line.BorderSizePixel = 0

    task.spawn(function()
        TweenService:Create(SoulTitle, TweenInfo.new(1), {TextTransparency = 0}):Play()
        TweenService:Create(Line, TweenInfo.new(1, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 150, 0, 2), Position = UDim2.new(0.5, -75, 0.55, 0)}):Play()
        task.wait(1.8)
        TweenService:Create(Loader, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(SoulTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(Line, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        Loader:Destroy()
    end)

    -- --- 2. 主框架 ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 540, 0, 380)
    Main.Position = UDim2.new(0.5, -270, 0.5, -190)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- 渐变层
    local function SetGrad(obj, rot)
        local g = Instance.new("UIGradient", obj)
        g.Rotation = rot
        g.Color = ColorSequence.new(COLORS.Bar, COLORS.Main)
        g.Transparency = NumberSequence.new(0, 1)
    end

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = COLORS.Bar
    TopBar.ZIndex = 10
    SetGrad(TopBar, 90)

    local BottomBar = Instance.new("Frame", Main)
    BottomBar.Size = UDim2.new(1, 0, 0, 45)
    BottomBar.Position = UDim2.new(0, 0, 1, -45)
    BottomBar.BackgroundColor3 = COLORS.Bar
    BottomBar.ZIndex = 10
    SetGrad(BottomBar, -90)

    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, -90)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.ZIndex = 9
    Sidebar.ScrollBarThickness = 0
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.8,0), NumberSequenceKeypoint.new(1,1)})

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = "Center"

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -155, 1, -110)
    Container.Position = UDim2.new(0, 150, 0, 55)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 5

    -- --- 3. 核心功能键 (关闭/缩小) ---
    local Title = Instance.new("TextLabel", Main)
    Title.Text = "SOUL PREMIUM"
    Title.Font = "GothamBold"
    Title.TextSize = 16
    Title.TextColor3 = COLORS.Text
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 0, 45)
    Title.BackgroundTransparency = 1
    Title.ZIndex = 11

    local CloseBtn = Instance.new("TextButton", Main)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 110, 110)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.ZIndex = 12
    Instance.new("UICorner", CloseBtn)

    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -75, 0, 7)
    MinBtn.BackgroundColor3 = COLORS.Accent
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.ZIndex = 12
    Instance.new("UICorner", MinBtn)

    -- 缩小/关闭动画修复
    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 0, 0, 0)
    MiniIcon.BackgroundColor3 = COLORS.Bar
    MiniIcon.Text = "S"
    MiniIcon.TextColor3 = Color3.new(1,1,1)
    MiniIcon.Font = "GothamBold"
    MiniIcon.Visible = false
    Instance.new("UICorner", MiniIcon)

    CloseBtn.MouseButton1Click:Connect(function()
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.3, true)
        task.wait(0.3) ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Main:TweenScale(0, Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon:TweenSize(UDim2.new(0,50,0,50), "Out", "Back", 0.3, true)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        MiniIcon:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.2, true)
        task.wait(0.2)
        Main.Visible = true
        Main:TweenScale(1, Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.3, true)
        MiniIcon.Visible = false
    end)

    -- 拖动逻辑
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- --- 4. API 系统 ---
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count
        
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 120, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "Gotham"
        TabBtn.TextSize = 13
        TabBtn.ZIndex = 15

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = (ID == 1)
        Page.ScrollBarThickness = 0
        Page.Position = UDim2.new(0, 20, 0, 0) -- 初始偏移用于特效
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Container:GetChildren()) do
                if p:IsA("ScrollingFrame") and p.Visible then
                    TweenService:Create(p, TweenInfo.new(0.2), {Position = UDim2.new(0, -20, 0, 0), GroupTransparency = 1}):Play()
                    task.wait(0.1)
                    p.Visible = false
                end
            end
            Page.Visible = true
            Page.Position = UDim2.new(0, 20, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end)

        local TabAPI = {}
        
        function TabAPI:AddButton(text, callback)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 38)
            b.BackgroundColor3 = Color3.new(1,1,1)
            b.BackgroundTransparency = 0.4
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.TextColor3 = COLORS.Accent
            b.Font = "GothamSemibold"
            Instance.new("UICorner", b)
            
            b.MouseButton1Click:Connect(function()
                local t = TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Accent, TextColor3 = Color3.new(1,1,1)})
                t:Play() t.Completed:Wait()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(1,1,1), TextColor3 = COLORS.Accent}):Play()
                callback()
            end)
        end

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
                TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(state and 0.55 or 0, 2, 0.5, -7)}):Play()
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = state and COLORS.Accent or COLORS.Bar}):Play()
                callback(state)
            end)
        end

        return TabAPI
    end

    return Library
end

return Library
