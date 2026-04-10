local Library = {Tabs = {}; Count = 0; IsMobile = true}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V13_MASTER"
    ScreenGui.IgnoreGuiInset = true -- 真正全屏
    
    -- --- 1. 你要的“极致炫酷”全屏加载 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Loader.ZIndex = 20000

    local Logo = Instance.new("TextLabel", Loader)
    Logo.Text = "S O U L"
    Logo.Font = "GothamBold"
    Logo.TextSize = 1
    Logo.TextColor3 = Color3.fromRGB(255, 100, 160)
    Logo.Size = UDim2.new(1, 0, 1, 0)
    Logo.BackgroundTransparency = 1

    -- 灵魂波纹特效
    task.spawn(function()
        local t1 = TweenService:Create(Logo, TweenInfo.new(1.2, Enum.EasingStyle.Back), {TextSize = 80})
        t1:Play()
        t1.Completed:Wait()
        -- 炸裂渐隐
        TweenService:Create(Logo, TweenInfo.new(0.8), {TextSize = 200, TextTransparency = 1}):Play()
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 2. 主框架 (粉色渐变背景 + 手机端拖拽) ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = Color3.new(1, 1, 1)
    Main.ClipsDescendants = true
    Main.ZIndex = 100
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
    
    -- 你要求的渐变背景
    local MainGrad = Instance.new("UIGradient", Main)
    MainGrad.Color = ColorSequence.new(Color3.fromRGB(255, 190, 220), Color3.fromRGB(255, 245, 250))
    MainGrad.Rotation = 45

    -- 拖拽逻辑 (手机端强制优化)
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = i.Position startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            dragInput = i
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)

    -- --- 3. 补全：物理绘制的控制键 ---
    local function CreateCtrl(x, color, isClose, cb)
        local b = Instance.new("TextButton", Main)
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(1, x, 0, 12)
        b.BackgroundColor3 = color
        b.Text = ""
        b.ZIndex = 500
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        local l = Instance.new("Frame", b)
        l.Size = UDim2.new(0.6, 0, 0, 2)
        l.Position = UDim2.new(0.5, 0, 0.5, 0)
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.BackgroundColor3 = Color3.new(1, 1, 1)
        if isClose then
            l.Rotation = 45
            local l2 = l:Clone()
            l2.Parent = b
            l2.Rotation = -45
        end
        b.MouseButton1Click:Connect(cb)
    end

    -- 极小化回显球 (手机适配)
    local Mini = Instance.new("TextButton", ScreenGui)
    Mini.Size = UDim2.new(0, 38, 0, 38)
    Mini.BackgroundColor3 = Color3.fromRGB(255, 100, 160)
    Mini.Visible = false
    Mini.Text = "S"
    Mini.Font = "GothamBold"
    Mini.TextColor3 = Color3.new(1, 1, 1)
    Mini.ZIndex = 1000
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(1, 0)

    -- 关闭动画
    CreateCtrl(-40, Color3.fromRGB(255, 80, 80), true, function()
        Main:TweenSizeAndPosition(UDim2.new(0,0,0,0), Main.Position + UDim2.new(0,260,0,170), "In", "Back", 0.4, true)
        task.wait(0.4) ScreenGui:Destroy()
    end)

    -- 缩小动画
    CreateCtrl(-75, Color3.fromRGB(255, 120, 180), false, function()
        Main:TweenSize(UDim2.new(0,0,0,0), "In", "Quad", 0.3, true)
        task.wait(0.3)
        Main.Visible = false
        Mini.Position = UDim2.new(0.5, -19, 0.05, 0)
        Mini.Visible = true
    end)

    Mini.MouseButton1Click:Connect(function()
        Main.Visible = true
        Main:TweenSize(UDim2.new(0, 520, 0, 340), "Out", "Back", 0.4, true)
        Mini.Visible = false
    end)

    -- --- 4. 栏目系统 (修复无法切换) ---
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 60)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -160, 1, -70)
    Container.Position = UDim2.new(0, 150, 0, 60)
    Container.BackgroundTransparency = 1

    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(80, 60, 70)
        TabBtn.Font = "Gotham"

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            -- 彻底重置
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 1 end end
            -- 激活
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.BackgroundColor3 = Color3.new(1,1,1)
            -- 动画切入
            Page.Position = UDim2.new(0, 20, 0, 0)
            Page:TweenPosition(UDim2.new(0,0,0,0), "Out", "Quart", 0.3, true)
        end)

        if ID == 1 then task.delay(1.5, function() Page.Visible = true; TabBtn.BackgroundTransparency = 0.8 end) end

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
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
