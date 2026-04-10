local Library = {Tabs = {}; Count = 0; IsMobile = true}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function Library:Init()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "SOUL_V11_MOBILE"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local COLORS = {
        Main = Color3.fromRGB(255, 248, 252),
        Accent = Color3.fromRGB(255, 105, 180),
        Text = Color3.fromRGB(80, 60, 70),
        Sidebar = Color3.fromRGB(255, 215, 230)
    }

    -- --- 1. 强制手机端拖拽适配函数 ---
    local function MakeDraggable(UIObj)
        local dragStart, startPos, dragging
        UIObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = UIObj.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                UIObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() dragging = false end)
    end

    -- --- 2. 加载动画 ---
    local Loader = Instance.new("Frame", ScreenGui)
    Loader.Size = UDim2.new(1, 0, 1, 0)
    Loader.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
    Loader.ZIndex = 5000

    local Logo = Instance.new("TextLabel", Loader)
    Logo.Text = "S O U L"
    Logo.Size = UDim2.new(1, 0, 1, 0)
    Logo.TextColor3 = Color3.new(1,1,1)
    Logo.Font = "GothamBold"
    Logo.TextSize = 1 -- 初始值
    Logo.BackgroundTransparency = 1

    task.spawn(function()
        TweenService:Create(Logo, TweenInfo.new(1.5, Enum.EasingStyle.Back), {TextSize = 60}):Play()
        task.wait(2)
        TweenService:Create(Loader, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Logo, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.delay(1, function() Loader:Destroy() end)
    end)

    -- --- 3. 主界面 ---
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 320) -- 针对手机缩小尺寸
    Main.Position = UDim2.new(0.5, -250, 0.5, -160)
    Main.BackgroundColor3 = COLORS.Main
    Main.ZIndex = 100
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
    MakeDraggable(Main)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BackgroundTransparency = 0.5
    local SLayout = Instance.new("UIListLayout", Sidebar)
    SLayout.Padding = UDim.new(0, 5)
    SLayout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 50)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -150, 1, -60)
    Container.Position = UDim2.new(0, 140, 0, 50)
    Container.BackgroundTransparency = 1

    -- --- 4. 纯 UI 绘制的功能键 (解决显示问题) ---
    local function CreateControl(x, color, cb, type)
        local btn = Instance.new("TextButton", Main)
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.Position = UDim2.new(1, x, 0, 12)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.ZIndex = 200
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        -- 绘制叉号或横杠
        local line1 = Instance.new("Frame", btn)
        line1.BackgroundColor3 = Color3.new(1,1,1)
        line1.AnchorPoint = Vector2.new(0.5, 0.5)
        line1.Position = UDim2.new(0.5, 0, 0.5, 0)
        if type == "close" then
            line1.Size = UDim2.new(0.6, 0, 0, 2)
            line1.Rotation = 45
            local line2 = line1:Clone()
            line2.Parent = btn
            line2.Rotation = -45
        else
            line1.Size = UDim2.new(0.6, 0, 0, 2)
        end

        btn.MouseButton1Click:Connect(cb)
    end

    -- 缩小回显图标 (手机极小化)
    local Mini = Instance.new("TextButton", ScreenGui)
    Mini.Size = UDim2.new(0, 40, 0, 40)
    Mini.Position = UDim2.new(0.5, -20, 0.1, 0)
    Mini.BackgroundColor3 = COLORS.Accent
    Mini.Text = "S"
    Mini.TextColor3 = Color3.new(1,1,1)
    Mini.Font = "GothamBold"
    Mini.Visible = false
    Mini.ZIndex = 1000
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)
    MakeDraggable(Mini) -- 修复悬浮窗不可移动

    CreateControl(-38, Color3.fromRGB(255, 120, 120), function() ScreenGui:Destroy() end, "close")
    CreateControl(-72, COLORS.Accent, function()
        Main.Visible = false
        Mini.Visible = true
    end, "min")

    Mini.MouseButton1Click:Connect(function()
        Main.Visible = true
        Mini.Visible = false
    end)

    -- --- 5. 栏目 API ---
    function Library:CreateTab(name)
        Library.Count = Library.Count + 1
        local ID = Library.Count

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = COLORS.Text
        TabBtn.Font = "Gotham"

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.BackgroundTransparency = 1 end end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.BackgroundColor3 = Color3.new(1,1,1)
        end)

        if ID == 1 then task.delay(2, function() Page.Visible = true; TabBtn.BackgroundTransparency = 0.8 end) end

        local TabAPI = {}
        function TabAPI:AddButton(text, cb)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.Text = "  " .. text
            b.TextXAlignment = "Left"
            b.Font = "GothamBold"
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(cb)
        end
        return TabAPI
    end

    return Library
end

return Library
