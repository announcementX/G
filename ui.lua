--[[
    SOUL UI Library v1.0 (Mobile Optimized)
    Theme: Light Pink / Soul Elements
    Created for educational purposes on Roblox UI design.

    Features: Dragging, Minimizing, Multiple Scroll Areas, Animations, Various Controls, Script Loading.
]]

local SoulLib = {}
SoulLib.__index = SoulLib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 尝试获取 CoreGui，如果不行则回退到 PlayerGui (防止防注入检测)
local ParentGui
local success, err = pcall(function()
    ParentGui = CoreGui
end)
if not success then
    ParentGui = PlayerGui
end

-- --- 颜色配置 (基于你的需求) ---
local Colors = {
    MainBG = Color3.fromRGB(255, 235, 238),       -- 淡粉色
    TopBottom = Color3.fromRGB(255, 210, 217),  -- 稍微深一丢丢的淡粉色 (上下45px)
    Sidebar = Color3.fromRGB(255, 245, 247),     -- 比淡粉色浅一丢丢 (左侧)
    Text = Color3.fromRGB(100, 70, 75),         -- 暗粉色文字 (提高可读性)
    Accent = Color3.fromRGB(255, 105, 180),     -- 亮粉色 (用于开关打开、动画强调 - "灵魂"元素)
    Placeholder = Color3.fromRGB(200, 180, 185)
}

-- --- 动画配置 ---
local Info = {
    Fast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) -- 用于缩小/关闭
}

-- --- Utility: 创建 UI 元素 ---
local function Create(className, properties)
    local element = Instance.new(className)
    for k, v in pairs(properties) do
        element[k] = v
    end
    return element
end

-- --- Utility: 拖拽功能 (手机端兼容) ---
local function MakeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- --- Utility: 酷炫的飞入加载动画 ---
local function PlayLoadAnimation(mainGui, minimIcon)
    -- 初始状态：隐藏且缩小
    mainGui.Size = UDim2.new(0, 0, 0, 0)
    mainGui.BackgroundTransparency = 1
    mainGui.Visible = true

    minimIcon.Visible = false

    -- 飞入动画
    local tween = TweenService:Create(mainGui, Info.Slow, {
        Size = UDim2.new(0, 500, 0, 350), -- 目标大小 (手机端建议大小)
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- --- 灵魂元素装饰 (轻微闪烁) ---
local function AddSoulEffect(parent)
    local soulDeco = Create("ImageLabel", {
        Name = "SoulDeco",
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.2, 0, 1.2, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10656041692", -- 这是一个类似光晕/烟雾的素材，你可以替换
        ImageColor3 = Colors.Accent,
        ImageTransparency = 0.8,
        ZIndex = parent.ZIndex - 1
    })

    -- 闪烁动画
    coroutine.wrap(function()
        while soulDeco.Parent do
            TweenService:Create(soulDeco, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1.3, 0, 1.3, 0)
            }):Play()
            task.wait(2)
            TweenService:Create(soulDeco, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.9,
                Size = UDim2.new(1.1, 0, 1.1, 0)
            }):Play()
            task.wait(2)
        end
    end)()
end


-- --- 主创建函数 ---
function SoulLib.Init(hubName)
    local self = setmetatable({}, SoulLib)

    -- 防止重复加载
    if ParentGui:FindFirstChild("SOUL_HUB_"..hubName) then
        ParentGui:FindFirstChild("SOUL_HUB_"..hubName):Destroy()
    end

    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "SOUL_HUB_"..hubName,
        Parent = ParentGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- --- 缩小后的图标 ---
    self.MinimizedIcon = Create("TextButton", {
        Name = "MinimizedIcon",
        Parent = self.ScreenGui,
        Position = UDim2.new(0.1, 0, 0.1, 0),
        Size = UDim2.new(0, 50, 0, 50), -- 带圆角的正方形
        BackgroundColor3 = Colors.TopBottom,
        Text = "S", -- 或者放一个灵魂Logo Image
        TextColor3 = Colors.Text,
        TextSize = 25,
        Font = Enum.Font.GothamBold,
        Visible = false, -- 默认隐藏
        ClipsDescendants = true
    })
    local iconCorner = Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.MinimizedIcon })
    Create("UIStroke", { Color = Colors.Accent, Thickness = 2, Transparency = 0.5, Parent = self.MinimizedIcon })
    
    AddSoulEffect(self.MinimizedIcon) -- 给图标添加灵魂效果
    MakeDraggable(self.MinimizedIcon) -- 图标也能拖动


    -- --- 主界面框架 ---
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), -- 居中
        Size = UDim2.new(0, 500, 0, 350), -- 手机端合适的大小
        BackgroundColor3 = Colors.MainBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false -- 用于加载动画
    })
    local mainCorner = Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = self.MainFrame })
    local mainStroke = Create("UIStroke", { Color = Colors.Accent, Thickness = 1, Transparency = 0.7, Parent = self.MainFrame })
    
    MakeDraggable(self.MainFrame)

    -- 顶部标题栏 (45px)
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Colors.TopBottom,
        BorderSizePixel = 0
    })
    local topCorner = Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = TopBar })
    -- 覆盖底部的圆角，只保留顶部圆角
    Create("Frame", { Parent = TopBar, Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Colors.TopBottom, BorderSizePixel = 0 })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundTransparency = 1,
        Text = hubName .. " | SOUL",
        TextColor3 = Colors.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- 顶部控制按钮区域
    local TopBtns = Create("Frame", {
        Name = "TopBtns",
        Parent = TopBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 80, 0, 30),
        BackgroundTransparency = 1
    })
    local topBtnsLayout = Create("UIListLayout", { Parent = TopBtns, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Right })

    -- 关闭按钮
    local CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Parent = TopBtns,
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Color3.fromRGB(255, 120, 120),
        Text = "×",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 25,
        Font = Enum.Font.GothamBold,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = CloseBtn })

    -- 缩小按钮
    local MinimBtn = Create("TextButton", {
        Name = "MinimBtn
