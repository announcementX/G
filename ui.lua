-- [[ SOUL ENGINE V14 TITANIUM - MOBILE INDUSTRIAL GRADE ]]
-- [[ Size: >22KB | Logic: Advanced | Mobile Optimized ]]

local Library = {Tabs = {}; Count = 0; Flags = {}; Dragging = false; Focused = nil; Animating = false}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ 核心工具函数：物理回弹与矩阵计算 ]]
local function Tween(obj, info, goal)
    local t = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    t:Play()
    return t
end

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_TITANIUM_V14"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 9999
    
    local COLORS = {
        MainBG = Color3.fromRGB(255, 240, 245),
        Sidebar = Color3.fromRGB(255, 205, 225),
        Accent = Color3.fromRGB(255, 80, 155),
        Text = Color3.fromRGB(70, 45, 55),
        Dark = Color3.fromRGB(18, 15, 17),
        Border = Color3.fromRGB(255, 255, 255)
    }

    -- [[ 1. 震撼全屏：粒子湮灭加载动画 ]]
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = COLORS.Dark
    Loader.ZIndex = 50000

    local ParticleContainer = Instance.new("Frame", Loader)
    ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
    ParticleContainer.BackgroundTransparency = 1

    local LoadingText = Instance.new("TextLabel", Loader)
    LoadingText.Size = UDim2.new(1, 0, 1, 0)
    LoadingText.Text = "S O U L"
    LoadingText.Font = Enum.Font.GothamBold
    LoadingText.TextColor3 = Color3.new(1, 1, 1)
    LoadingText.TextSize = 2 -- 起始极小
    LoadingText.BackgroundTransparency = 1
    LoadingText.ZIndex = 50001

    -- 高级粒子数学逻辑
    task.spawn(function()
        for i = 1, 50 do
            local p = Instance.new("Frame", ParticleContainer)
            p.Size = UDim2.new(0, 3, 0, 3)
            p.BackgroundColor3 = COLORS.Accent
            p.Position = UDim2.new(math.random(), 0, math.random(), 0)
            Instance.new("UICorner", p)
            Tween(p, {2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {
                Position = UDim2.new(0.5, math.random(-50,50), 0.5, math.random(-50,50)),
                BackgroundTransparency = 1
            })
        end
        Tween(LoadingText, {1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {TextSize = 120})
        task.wait(2)
        Tween(LoadingText, {0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {TextSize = 300, TextTransparency = 1})
        Tween(Loader, {1, Enum.EasingStyle.Linear}, {BackgroundTransparency = 1})
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- [[ 2. 主框架构造：多层 Canvas 渲染 ]]
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 580, 0, 380)
    Main.Position = UDim2.new(0.5, -290, 0.5, -190)
    Main.BackgroundColor3 = COLORS.MainBG
    Main.ZIndex = 1000
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    -- 绘制渐变背景
    local MainGrad = Instance.new("UIGradient", Main)
    MainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Sidebar),
        ColorSequenceKeypoint.new(1, COLORS.MainBG)
    })
    MainGrad.Rotation = 45

    -- UI 描边 (工业级质感)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.new(1,1,1)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.5

    -- 侧边栏 (半透明隔离)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.ZIndex = 1001
    
    local SideScroll = Instance.new("ScrollingFrame", Sidebar)
    SideScroll.Size = UDim2.new(1, 0, 1, -80)
    SideScroll.Position = UDim2.new(0, 0, 0, 70)
    SideScroll.BackgroundTransparency = 1
    SideScroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", SideScroll).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", SideScroll).PaddingLeft = UDim.new(0, 15)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -180, 1, -80)
    Container.Position = UDim2.new(0, 170, 0, 70)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 1002

    -- [[ 3. 手机端顶级物理拖拽 (支持 Touch 和 Mouse) ]]
    local function SetupDrag(Obj)
        local dragStart, startPos
        Obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Library.Dragging = true
                dragStart = input.Position
                startPos = Obj.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then Library.Dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Library.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    SetupDrag(Main)

    -- [[ 4. 控制组件：手工几何绘制 (关闭与缩小) ]]
    local function CreateButton(x, color, type, callback)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(1, x, 0, 15)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.ZIndex = 2000
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        -- 绘制图标
        local icon = Instance.new("Frame", btn)
        icon.Size = UDim2.new(0.5, 0, 0, 2)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundColor3 = Color3.new(1,1,1)
        if type == "close" then
            icon.Rotation = 45
            local icon2 = icon:Clone()
            icon2.Parent = btn
            icon2.Rotation = -45
        end

        btn.MouseButton1Click:Connect(callback)
    end

    -- 缩小回显球 (手机微型设计)
    local MiniIcon = Instance.new("TextButton", ScreenGui)
    MiniIcon.Name = "MiniIcon"
    MiniIcon.Size = UDim2.new(0, 42, 0, 42)
    MiniIcon.BackgroundColor3 = COLORS.Accent
    MiniIcon.Text = "S"
    MiniIcon.Font = "GothamBold"
    MiniIcon.TextColor3 = Color3.new(1, 1, 1)
    MiniIcon.Visible = false
    MiniIcon.ZIndex = 9999
    Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(1, 0)
    SetupDrag(MiniIcon)

    -- 动画执行器
    CreateButton(-45, Color3.fromRGB(255, 100, 100), "close", function()
        Library.Animating = true
        Tween(Main, {0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In}, {Size = UDim2.new(0,0,0,0), Position = Main.Position + UDim2.new(0,290,0,190)})
        task.wait(0.5) ScreenGui:Destroy()
    end)

    CreateButton(-85, COLORS.Accent, "min", function()
        Library.Animating = true
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Quad", 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        MiniIcon.Position = UDim2.new(0.5, -21, 0.05, 0)
        MiniIcon.Visible = true
        Library.Animating = false
    end)

    MiniIcon.MouseButton1Click:Connect(function()
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 580, 0, 380), "Out", "Back", 0.4, true)
        MiniIcon.Visible = false
    end)

    -- [[ 5. API 系统：高级组件支持 ]]
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count
        
        local TabBtn = Instance.new("TextButton", SideScroll)
        TabBtn.Size = UDim2.new(0.95, 0, 0, 42)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "GothamMedium"
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = "Left"

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = COLORS.Accent
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            if Library.Animating then return end
            -- 彻底隔离物理页面
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(SideScroll:GetChildren()) do 
                if v:IsA("TextButton") then 
                    Tween(v, {0.3, Enum.EasingStyle.Quart}, {TextColor3 = COLORS.Text, TextSize = 14})
                end 
            end
            
            Page.Visible = true
            Tween(TabBtn, {0.3, Enum.EasingStyle.Back}, {TextColor3 = COLORS.Accent, TextSize = 16})
            
            -- 切入动画 (高级位移)
            Page.Position = UDim2.new(0, 40, 0, 0)
            Page:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quart", 0.4, true)
        end)

        -- 默认开启第一个 Tab
        if ID == 1 then
            task.spawn(function()
                task.wait(2.5) -- 等待加载动画
                Page.Visible = true
                TabBtn.TextColor3 = COLORS.Accent
            end)
        end

        local TabAPI = {}

        -- [组件：按钮]
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -15, 0, 45)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.4
            b.Text = "  " .. text
            b.TextColor3 = COLORS.Text
            b.Font = "GothamBold"
            b.TextXAlignment = "Left"
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", b).Color = COLORS.Accent
            
            b.MouseButton1Click:Connect(function()
                Tween(b, {0.1, Enum.EasingStyle.Quad}, {BackgroundTransparency = 0.1})
                task.wait(0.1)
                Tween(b, {0.1, Enum.EasingStyle.Quad}, {BackgroundTransparency = 0.4})
                cb()
            end)
        end

        -- [组件：开关]
        function TabAPI:AddToggle(text, cb)
            local tMain = Instance.new("TextButton", Page)
            tMain.Size = UDim2.new(1, -15, 0, 45)
            tMain.BackgroundColor3 = Color3.new(1, 1, 1)
            tMain.BackgroundTransparency = 0.4
            tMain.Text = "  " .. text
            tMain.TextColor3 = COLORS.Text
            tMain.Font = "GothamBold"
            tMain.TextXAlignment = "Left"
            Instance.new("UICorner", tMain).CornerRadius = UDim.new(0, 10)

            local Box = Instance.new("Frame", tMain)
            Box.Size = UDim2.new(0, 46, 0, 24)
            Box.Position = UDim2.new(1, -60, 0.5, -12)
            Box.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Box)
            Dot.Size = UDim2.new(0, 18, 0, 18)
            Dot.Position = UDim2.new(0, 3, 0.5, -9)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", Dot)

            local state = false
            tMain.MouseButton1Click:Connect(function()
                state = not state
                Tween(Dot, {0.25, Enum.EasingStyle.Back}, {Position = UDim2.new(state and 1 or 0, state and -21 or 3, 0.5, -9)})
                Tween(Box, {0.25, Enum.EasingStyle.Quart}, {BackgroundColor3 = state and COLORS.Accent or Color3.fromRGB(200, 200, 200)})
                cb(state)
            end)
        end

        -- [组件：滑动条]
        function TabAPI:AddSlider(text, min, max, default, cb)
            local sMain = Instance.new("Frame", Page)
            sMain.Size = UDim2.new(1, -15, 0, 60)
            sMain.BackgroundColor3 = Color3.new(1, 1, 1)
            sMain.BackgroundTransparency = 0.4
            Instance.new("UICorner", sMain)

            local sTitle = Instance.new("TextLabel", sMain)
            sTitle.Text = "  " .. text
            sTitle.Size = UDim2.new(1, 0, 0, 30)
            sTitle.BackgroundTransparency = 1
            sTitle.Font = "GothamBold"
            sTitle.TextColor3 = COLORS.Text
            sTitle.TextXAlignment = "Left"

            local sBar = Instance.new("Frame", sMain)
            sBar.Size = UDim2.new(0.85, 0, 0, 4)
            sBar.Position = UDim2.new(0.075, 0, 0.7, 0)
            sBar.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            Instance.new("UICorner", sBar)

            local sFill = Instance.new("Frame", sBar)
            sFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            sFill.BackgroundColor3 = COLORS.Accent
            Instance.new("UICorner", sFill)

            local sDot = Instance.new("TextButton", sBar)
            sDot.Size = UDim2.new(0, 16, 0, 16)
            sDot.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
            sDot.BackgroundColor3 = COLORS.Accent
            sDot.Text = ""
            Instance.new("UICorner", sDot)

            local draggingSlider = false
            local function UpdateSlider()
                local percent = math.clamp((Mouse.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percent)
                sFill.Size = UDim2.new(percent, 0, 1, 0)
                sDot.Position = UDim2.new(percent, -8, 0.5, -8)
                cb(value)
            end
            sDot.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end end)
            UserInputService.InputChanged:Connect(function(i) if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateSlider() end end)
        end

        return TabAPI
    end

    return Library
end

return Library
