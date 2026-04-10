local Library = {Tabs = {}; Count = 0}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V8_GHOST"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        BG = Color3.fromRGB(255, 240, 245),
        Sidebar = Color3.fromRGB(255, 215, 230),
        Accent = Color3.fromRGB(255, 90, 150),
        Text = Color3.fromRGB(70, 50, 60),
        White = Color3.new(1, 1, 1)
    }

    -- --- 1. 顶级：SOUL 灵魂波动加载动画 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
    Loader.ZIndex = 20000

    local Label = Instance.new("TextLabel", Loader)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Text = "S O U L"
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = COLORS.White
    Label.TextSize = 2 -- 从极小开始
    Label.BackgroundTransparency = 1
    Label.ZIndex = 20001

    -- 加载动画逻辑：文字扩散 + 模糊消失
    task.spawn(function()
        local t1 = TweenService:Create(Label, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {TextSize = 120, TextTransparency = 0})
        t1:Play()
        t1.Completed:Wait()
        task.wait(0.5)
        TweenService:Create(Label, TweenInfo.new(0.8), {TextSize = 200, TextTransparency = 1}):Play()
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (多重渐变背景) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 580, 0, 400)
    Main.Position = UDim2.new(0.5, -290, 0.5, -200)
    Main.BackgroundColor3 = COLORS.BG
    Main.ClipsDescendants = true
    Main.ZIndex = 100
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

    -- 背景渐变 (实现你要求的粉色过渡)
    local MainGrad = Instance.new("UIGradient", Main)
    MainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Sidebar),
        ColorSequenceKeypoint.new(1, COLORS.BG)
    })
    MainGrad.Rotation = 45

    -- 侧边栏 (半透明毛玻璃感)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.ZIndex = 110
    
    local SGrad = Instance.new("UIGradient", Sidebar)
    SGrad.Transparency = NumberSequence.new(0, 1) -- 向右淡出

    local SideScroll = Instance.new("ScrollingFrame", Sidebar)
    SideScroll.Size = UDim2.new(1, 0, 1, -80)
    SideScroll.Position = UDim2.new(0, 0, 0, 60)
    SideScroll.BackgroundTransparency = 1
    SideScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", SideScroll).Padding = UDim.new(0, 8)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -170, 1, -70)
    Container.Position = UDim2.new(0, 160, 0, 60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 105

    -- --- 3. 拖拽与控制键 ---
    local function Drag(obj)
        local gs, sp, dragging
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true gs = i.Position sp = obj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType.Name:find("Mouse") or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - gs
                obj.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() dragging = false end)
    end
    Drag(Main)

    local function CreateCtrl(txt, x, color, cb)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0, 30, 0, 30)
        b.Position = UDim2.new(1, x, 0, 15)
        b.BackgroundColor3 = color
        b.Text = txt
        b.TextColor3 = COLORS.White
        b.ZIndex = 150
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        b.MouseButton1Click:Connect(cb)
    end

    -- 关闭键 (带动画)
    CreateCtrl("×", -45, Color3.fromRGB(255, 100, 100), function()
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.BackIn), {Position = UDim2.new(0.5, -290, 1.2, 0), Rotation = 15}):Play()
        task.wait(0.5) ScreenGui:Destroy()
    end)

    -- 缩小键 (带归位动画)
    local Mini = Instance.new("TextButton", ScreenGui)
    Mini.Size = UDim2.new(0, 60, 0, 60)
    Mini.Position = UDim2.new(0.5, -30, -0.2, 0) -- 初始在屏幕上方外面
    Mini.BackgroundColor3 = COLORS.Accent
    Mini.Text = "S"
    Mini.TextColor3 = COLORS.White
    Mini.Font = "GothamBold"
    Mini.ZIndex = 500
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(1, 0)
    Drag(Mini)

    CreateCtrl("-", -85, COLORS.Accent, function()
        Main:TweenPosition(UDim2.new(0.5, -290, -0.6, 0), "In", "Back", 0.5)
        task.wait(0.5)
        Main.Visible = false
        Mini.Position = UDim2.new(0.5, -30, -0.2, 0)
        Mini.Visible = true
        Mini:TweenPosition(UDim2.new(0.5, -30, 0.1, 0), "Out", "Back", 0.5)
    end)

    Mini.MouseButton1Click:Connect(function()
        Mini:TweenPosition(UDim2.new(0.5, -30, -0.2, 0), "In", "Quad", 0.3)
        task.wait(0.3)
        Main.Visible = true
        Main:TweenPosition(UDim2.new(0.5, -290, 0.5, -200), "Out", "Back", 0.5)
        Mini.Visible = false
    end)

    -- --- 4. API 系统 (支持 Toggle 和切换特效) ---
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count
        
        local TabBtn = Instance.new("TextButton", SideScroll)
        TabBtn.Size = UDim2.new(1, -20, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "GothamMedium"
        TabBtn.TextSize = 14
        TabBtn.ZIndex = 120

        local Line = Instance.new("Frame", TabBtn)
        Line.Size = UDim2.new(0, 0, 0, 2)
        Line.Position = UDim2.new(0, 10, 1, -5)
        Line.BackgroundColor3 = COLORS.Accent
        Line.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            -- 切换特效：旧页面淡出位移
            for _, v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") and v.Visible then
                    local t = TweenService:Create(v, TweenInfo.new(0.3), {Position = UDim2.new(0, -30, 0, 0), GroupTransparency = 1})
                    t:Play() t.Completed:Wait() v.Visible = false
                end
            end
            -- 重置按钮样式
            for _, v in pairs(SideScroll:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v.Frame, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,2)}):Play()
                end
            end
            -- 激活新页面：切入动画
            Page.Visible = true
            Page.Position = UDim2.new(0, 30, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0,0,0,0)}):Play()
            TweenService:Create(Line, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, -20, 0, 2)}):Play()
        end)

        -- 默认开启第一个
        if ID == 1 then task.delay(1.5, function() Page.Visible = true end) end

        local TabAPI = {}
        
        -- 按钮类型 1: 点击触发
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = COLORS.White
            b.BackgroundTransparency = 0.4
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.Font = "GothamBold"
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                local t = TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Accent})
                t:Play() t.Completed:Wait()
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.White}):Play()
                cb()
            end)
        end

        -- 按钮类型 2: 开关 (Toggle)
        function TabAPI:AddToggle(text, cb)
            local tMain = Instance.new("TextButton", Page)
            tMain.Size = UDim2.new(1, -10, 0, 40)
            tMain.BackgroundColor3 = COLORS.White
            tMain.BackgroundTransparency = 0.4
            tMain.Text = "  " .. text
            tMain.TextXAlignment = "Left"
            Instance.new("UICorner", tMain)

            local Box = Instance.new("Frame", tMain)
            Box.Size = UDim2.new(0, 40, 0, 20)
            Box.Position = UDim2.new(1, -50, 0.5, -10)
            Box.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1,0)

            local Dot = Instance.new("Frame", Box)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = UDim2.new(0, 2, 0.5, -8)
            Dot.BackgroundColor3 = COLORS.White
            Instance.new("UICorner", Dot)

            local s = false
            tMain.MouseButton1Click:Connect(function()
                s = not s
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(s and 1 or 0, s and -18 or 2, 0.5, -8)}):Play()
                TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = s and COLORS.Accent or Color3.fromRGB(200, 200, 200)}):Play()
                cb(s)
            end)
        end

        return TabAPI
    end

    return Library
end

return Library
