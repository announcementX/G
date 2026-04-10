local Library = {Tabs = {}; Count = 0}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V9_FINAL"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        Main = Color3.fromRGB(255, 240, 245),
        Sidebar = Color3.fromRGB(255, 200, 220),
        Accent = Color3.fromRGB(255, 80, 150),
        Text = Color3.fromRGB(60, 40, 50),
        Dark = Color3.fromRGB(20, 10, 15)
    }

    -- --- 1. 真正的全屏炫酷加载 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.Dark
    Loader.ZIndex = 10000

    local SoulText = Instance.new("TextLabel", Loader)
    SoulText.Size = UDim2.new(1, 0, 1, 0)
    SoulText.Text = "S O U L"
    SoulText.Font = Enum.Font.GothamBold
    SoulText.TextColor3 = Color3.new(1, 1, 1)
    SoulText.TextSize = 0
    SoulText.BackgroundTransparency = 1
    SoulText.ZIndex = 10001

    task.spawn(function()
        -- 震荡放大效果
        TweenService:Create(SoulText, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 100}):Play()
        task.wait(1.2)
        TweenService:Create(SoulText, TweenInfo.new(0.5), {TextTransparency = 1, TextSize = 150}):Play()
        TweenService:Create(Loader, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        task.delay(0.8, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (解决点击失效) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 580, 0, 400)
    Main.Position = UDim2.new(0.5, -290, 0.5, -200)
    Main.BackgroundColor3 = COLORS.Main
    Main.BorderSizePixel = 0
    Main.ZIndex = 100
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- 背景渐变
    local MainGrad = Instance.new("UIGradient", Main)
    MainGrad.Color = ColorSequence.new(COLORS.Sidebar, COLORS.Main)
    MainGrad.Rotation = 45

    -- 侧边栏
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ZIndex = 110

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 60)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -170, 1, -80)
    Container.Position = UDim2.new(0, 160, 0, 60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 105

    -- --- 3. 核心控制键 (强制置顶) ---
    local function CreateBtn(name, txt, x, color, cb)
        local b = Instance.new("TextButton", Main)
        b.Name = name
        b.Size = UDim2.new(0, 32, 0, 32)
        b.Position = UDim2.new(1, x, 0, 12)
        b.BackgroundColor3 = color
        b.Text = txt
        b.Font = "GothamBold"
        b.TextColor3 = Color3.new(1, 1, 1)
        b.ZIndex = 500 -- 极高层级
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        -- 增加点击缩小动画
        b.MouseButton1Down:Connect(function()
            b:TweenSize(UDim2.new(0, 28, 0, 28), "Out", "Quad", 0.1, true)
        end)
        b.MouseButton1Up:Connect(function()
            b:TweenSize(UDim2.new(0, 32, 0, 32), "Out", "Quad", 0.1, true)
        end)
        b.MouseButton1Click:Connect(cb)
    end

    -- 关闭功能 (带缩小消失动画)
    CreateBtn("Close", "×", -45, Color3.fromRGB(255, 90, 90), function()
        Main:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Back", 0.4, true)
        task.wait(0.4) ScreenGui:Destroy()
    end)

    -- 缩小功能
    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Size = UDim2.new(0, 55, 0, 55)
    MiniIcon.BackgroundColor3 = COLORS.Accent
    MiniIcon.Text = "S"
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.Visible = false
    MiniIcon.ZIndex = 1000
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)

    CreateBtn("Min", "-", -85, COLORS.Accent, function()
        Main.Visible = false
        MiniIcon.Visible = true
        MiniIcon.Position = UDim2.new(0.5, -27, 0.1, 0)
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        Main.Visible = true
        MiniIcon.Visible = false
    end)

    -- --- 4. API (修复切换逻辑) ---
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
        TabBtn.BackgroundColor3 = Color3.new(1, 1, 1)
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.ZIndex = 120
        Instance.new("UICorner", TabBtn)

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            -- 强制重置
            for _, v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = COLORS.Text}):Play()
                end
            end
            -- 激活动画
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.4, TextColor3 = COLORS.Accent}):Play()
            
            -- 切换特效 (位移)
            Page.Position = UDim2.new(0, 20, 0, 0)
            Page:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.3, true)
        end)

        -- 默认开启第一个
        if ID == 1 then
            task.spawn(function()
                task.wait(1.5)
                Page.Visible = true
                TabBtn.BackgroundTransparency = 0.4
                TabBtn.TextColor3 = COLORS.Accent
            end)
        end

        local TabAPI = {}
        
        -- 点击触发按钮 (带缩小动画)
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.Font = "GothamBold"
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                b:TweenSize(UDim2.new(1, -20, 0, 36), "Out", "Quad", 0.1, true)
                task.wait(0.1)
                b:TweenSize(UDim2.new(1, -10, 0, 40), "Out", "Quad", 0.1, true)
                cb()
            end)
        end

        -- 开关按钮
        function TabAPI:AddToggle(text, cb)
            local t = Instance.new("TextButton", Page)
            t.Size = UDim2.new(1, -10, 0, 40)
            t.BackgroundColor3 = Color3.new(1, 1, 1)
            t.Text = "  " .. text
            t.TextXAlignment = "Left"
            Instance.new("UICorner", t)
            
            local box = Instance.new("Frame", t)
            box.Size = UDim2.new(0, 40, 0, 20)
            box.Position = UDim2.new(1, -50, 0.5, -10)
            box.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
            
            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.new(0, 16, 0, 16)
            dot.Position = UDim2.new(0, 2, 0.5, -8)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", dot)

            local s = false
            t.MouseButton1Click:Connect(function()
                s = not s
                dot:TweenPosition(UDim2.new(s and 1 or 0, s and -18 or 2, 0.5, -8), "Out", "Quad", 0.2, true)
                TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = s and COLORS.Accent or Color3.fromRGB(220, 220, 220)}):Play()
                cb(s)
            end)
        end

        return TabAPI
    end

    -- 简单拖拽
    local dStart, sPos, dragging
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dStart = i.Position sPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType.Name:find("Mouse") or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dStart
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    return Library
end

return Library
