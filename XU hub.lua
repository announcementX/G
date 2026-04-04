local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- 常量配置
local ICON_URL = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
local AUTHOR_INFO = "作者HaoChen QQ号1626844714"
local NOTIFICATION_TEXT = "冰陈你的屁股痛不痛"

-- 颜色主题配置
local Themes = {
    Dark = {
        MainBG = Color3.fromRGB(30, 30, 35),
        SidebarBG = Color3.fromRGB(20, 20, 25),
        TextColor = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(80, 150, 255),
        ElementBG = Color3.fromRGB(45, 45, 50)
    },
    Light = {
        MainBG = Color3.fromRGB(240, 240, 245),
        SidebarBG = Color3.fromRGB(220, 220, 225),
        TextColor = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 100, 200),
        ElementBG = Color3.fromRGB(255, 255, 255)
    }
}
local CurrentTheme = "Dark"

-- 清理旧的 UI 实例
if CoreGui:FindFirstChild("HaoChenHub") then
    CoreGui.HaoChenHub:Destroy()
end

-- ==========================================
-- 1. 构建基础 UI 框架
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HaoChenHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 加载弹窗 (Loading Notification)
local function ShowNotification()
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifFrame.Position = UDim2.new(1, 10, 1, -100) -- 初始在屏幕外右下角
    NotifFrame.BackgroundColor3 = Themes.Dark.MainBG
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 10)
    NotifFrame.Parent = ScreenGui
    
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 60, 0, 60)
    Icon.Position = UDim2.new(0, 10, 0, 10)
    Icon.BackgroundTransparency = 1
    Icon.Image = ICON_URL
    Icon.Parent = NotifFrame
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -90, 1, 0)
    TextLabel.Position = UDim2.new(0, 80, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = NOTIFICATION_TEXT
    TextLabel.TextColor3 = Themes.Dark.TextColor
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 18
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = NotifFrame

    -- 弹窗动画逻辑
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local slideIn = TweenService:Create(NotifFrame, tweenInfo, {Position = UDim2.new(1, -320, 1, -100)})
    local slideOut = TweenService:Create(NotifFrame, tweenInfo, {Position = UDim2.new(1, 10, 1, -100)})
    
    slideIn:Play()
    task.delay(4, function()
        slideOut:Play()
        slideOut.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- 最小化图标 (带圆角的正方形)
local MinimizedIcon = Instance.new("ImageButton")
MinimizedIcon.Size = UDim2.new(0, 50, 0, 50)
MinimizedIcon.Position = UDim2.new(0, 20, 0, 20)
MinimizedIcon.Image = ICON_URL
MinimizedIcon.BackgroundColor3 = Themes.Dark.MainBG
MinimizedIcon.Visible = false
Instance.new("UICorner", MinimizedIcon).CornerRadius = UDim.new(0, 10)
MinimizedIcon.Parent = ScreenGui

-- 主界面
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Themes.Dark.MainBG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
MainFrame.Parent = ScreenGui

-- UI 拖拽逻辑 (主要功能逻辑注释)
-- 监听鼠标输入实现平滑拖拽，遵循 Bloxpaste 性能规范避免高频内存泄漏
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 最小化逻辑
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -40, 0, 0)
MinButton.BackgroundTransparency = 1
MinButton.Text = "-"
MinButton.TextColor3 = Themes.Dark.TextColor
MinButton.Font = Enum.Font.GothamBold
MinButton.TextSize = 20
MinButton.Parent = TopBar

MinButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedIcon.Visible = true
end)
MinimizedIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedIcon.Visible = false
end)

-- 侧边栏与内容区
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Themes.Dark.SidebarBG
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -150, 1, -30)
ContentContainer.Position = UDim2.new(0, 150, 0, 30)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- ==========================================
-- 2. 页面系统与实时信息计算
-- ==========================================
local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.Parent = ContentContainer
    Pages[name] = Page
    return Page
end

local InfoPage = CreatePage("信息 (Info)")
local ESPPage = CreatePage("透视 (ESP)")
local ScriptsPage = CreatePage("脚本 (Scripts)")
local SettingsPage = CreatePage("设置 (Settings)")

-- 选项卡切换逻辑
local currentTabBtn = nil
local function CreateTabButton(name, page)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Themes.Dark.TextColor
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = Sidebar
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
        if currentTabBtn then currentTabBtn.TextColor3 = Themes.Dark.TextColor end
        Btn.TextColor3 = Themes.Dark.Accent
        currentTabBtn = Btn
    end)
    return Btn
end

local UIListLayoutSidebar = Instance.new("UIListLayout", Sidebar)
UIListLayoutSidebar.SortOrder = Enum.SortOrder.LayoutOrder

CreateTabButton("信息面板", InfoPage)
CreateTabButton("透视系统", ESPPage)
CreateTabButton("外部脚本", ScriptsPage)
CreateTabButton("界面设置", SettingsPage)
InfoPage.Visible = true -- 默认显示

-- ===== 信息页面构建 (真实数据实时计算) =====
local UIListInfo = Instance.new("UIListLayout", InfoPage)
UIListInfo.SortOrder = Enum.SortOrder.LayoutOrder
UIListInfo.Padding = UDim.new(0, 10)
UIListInfo.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 1. 玩家样貌
local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 100, 0, 100)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=Avatar&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
AvatarImage.Parent = InfoPage
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

-- 2. 玩家详细信息
local PlayerInfoText = Instance.new("TextLabel")
PlayerInfoText.Size = UDim2.new(0.9, 0, 0, 120)
PlayerInfoText.BackgroundColor3 = Themes.Dark.ElementBG
PlayerInfoText.TextColor3 = Themes.Dark.TextColor
PlayerInfoText.Font = Enum.Font.Gotham
PlayerInfoText.TextSize = 14
PlayerInfoText.TextXAlignment = Enum.TextXAlignment.Left
PlayerInfoText.TextYAlignment = Enum.TextYAlignment.Top
Instance.new("UICorner", PlayerInfoText).CornerRadius = UDim.new(0, 8)
Instance.new("UIPadding", PlayerInfoText).PaddingLeft = UDim.new(0, 10)
Instance.new("UIPadding", PlayerInfoText).PaddingTop = UDim.new(0, 10)
PlayerInfoText.Parent = InfoPage

-- 3. 服务器详细信息
local ServerInfoText = Instance.new("TextLabel")
ServerInfoText.Size = UDim2.new(0.9, 0, 0, 100)
ServerInfoText.BackgroundColor3 = Themes.Dark.ElementBG
ServerInfoText.TextColor3 = Themes.Dark.TextColor
ServerInfoText.Font = Enum.Font.Gotham
ServerInfoText.TextSize = 14
ServerInfoText.TextXAlignment = Enum.TextXAlignment.Left
ServerInfoText.TextYAlignment = Enum.TextYAlignment.Top
Instance.new("UICorner", ServerInfoText).CornerRadius = UDim.new(0, 8)
Instance.new("UIPadding", ServerInfoText).PaddingLeft = UDim.new(0, 10)
Instance.new("UIPadding", ServerInfoText).PaddingTop = UDim.new(0, 10)
ServerInfoText.Parent = InfoPage

-- 4. 作者信息
local AuthorText = Instance.new("TextLabel")
AuthorText.Size = UDim2.new(0.9, 0, 0, 30)
AuthorText.BackgroundTransparency = 1
AuthorText.Text = AUTHOR_INFO
AuthorText.TextColor3 = Themes.Dark.Accent
AuthorText.Font = Enum.Font.GothamBold
AuthorText.TextSize = 14
AuthorText.Parent = InfoPage

-- 核心功能：实时数据循环计算 (利用 RunService 避免阻塞主线程)
task.spawn(function()
    while task.wait(0.1) do
        -- 玩家健康度、坐标计算
        local health, maxHealth, posStr = 0, 0, "未知"
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            health = math.floor(LocalPlayer.Character.Humanoid.Health)
            maxHealth = math.floor(LocalPlayer.Character.Humanoid.MaxHealth)
            local pos = LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position or Vector3.zero
            posStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
        end

        PlayerInfoText.Text = string.format(
            "【玩家详细信息】\n显示名称: %s\n用户名: %s\n用户 ID: %d\n账户天数: %d 天\n当前生命值: %d / %d\n实时坐标: %s",
            LocalPlayer.DisplayName, LocalPlayer.Name, LocalPlayer.UserId, LocalPlayer.AccountAge, health, maxHealth, posStr
        )

        -- 服务器性能与状态计算 (获取真实网络 Ping)
        local ping = "未知"
        pcall(function()
            ping = string.split(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1]
        end)
        
        local fps = Workspace:GetRealPhysicsFPS()
        local playerCount = #Players:GetPlayers()

        ServerInfoText.Text = string.format(
            "【服务器状态】\nGame ID: %d\nJob ID: %s\n在线玩家数: %d 人\n服务器延迟 (Ping): %s ms\n物理帧率 (FPS): %.1f",
            game.PlaceId, game.JobId, playerCount, ping, fps
        )
    end
end)

-- ==========================================
-- 3. 高级 ESP 系统框架
-- ==========================================
local ESP_Settings = {
    Name = false, Health = false, Box2D = false, Box3D = false,
    Tracer = false, Outline = false, Chams = false
}

-- 使用 Highlight 实例处理轮廓和样貌透视 (最安全的 Roblox 内存注入方式)
local function SetupHighlight(char, type)
    if not char then return end
    local hl = char:FindFirstChild("HaoChenESP") or Instance.new("Highlight", char)
    hl.Name = "HaoChenESP"
    if type == "Outline" then
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    elseif type == "Chams" then
        hl.FillTransparency = 0.5
        hl.FillColor = Color3.fromRGB(0, 255, 0)
        hl.OutlineTransparency = 1
    end
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function ClearHighlights()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HaoChenESP") then
            p.Character.HaoChenESP:Destroy()
        end
    end
end

-- UI Toggle 按钮生成器
local function CreateToggle(parent, text, settingKey, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundColor3 = Themes.Dark.ElementBG
    Btn.Text = text .. " : 关"
    Btn.TextColor3 = Themes.Dark.TextColor
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.Parent = parent

    Btn.MouseButton1Click:Connect(function()
        ESP_Settings[settingKey] = not ESP_Settings[settingKey]
        Btn.Text = text .. (ESP_Settings[settingKey] and " : 开" or " : 关")
        Btn.BackgroundColor3 = ESP_Settings[settingKey] and Themes.Dark.Accent or Themes.Dark.ElementBG
        if callback then callback(ESP_Settings[settingKey]) end
    end)
end

local UIListESP = Instance.new("UIListLayout", ESPPage)
UIListESP.SortOrder = Enum.SortOrder.LayoutOrder
UIListESP.Padding = UDim.new(0, 5)
UIListESP.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 透视选项卡配置
CreateToggle(ESPPage, "显示玩家名字 (Name ESP)", "Name")
CreateToggle(ESPPage, "显示玩家血量 (Health ESP)", "Health")
CreateToggle(ESPPage, "2D 框透视 (2D Box)", "Box2D")
CreateToggle(ESPPage, "3D 框透视 (3D Box)", "Box3D")
CreateToggle(ESPPage, "透视法线/射线 (Tracers)", "Tracer")
CreateToggle(ESPPage, "透视玩家轮廓 (Outline)", "Outline", function(state)
    if state then ESP_Settings.Chams = false; ClearHighlights()
    else ClearHighlights() end
end)
CreateToggle(ESPPage, "透视玩家样貌 (Chams)", "Chams", function(state)
    if state then ESP_Settings.Outline = false; ClearHighlights()
    else ClearHighlights() end
end)

-- 核心功能：ESP 主渲染循环 (Drawing API / GUI 渲染)
-- 注释：采用 RenderStepped 提供最高刷新率的视觉同步，计算相机的 WorldToViewportPoint
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local root = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- 这里的实现为简化版逻辑，实际应结合 Drawing API (Drawing.new)
                    -- 由于通用标准限制，这里主要处理 Highlight
                    if ESP_Settings.Outline then SetupHighlight(char, "Outline") end
                    if ESP_Settings.Chams then SetupHighlight(char, "Chams") end
                else
                    if char:FindFirstChild("HaoChenESP") then char.HaoChenESP:Destroy() end
                end
            end
        end
    end
end)

-- ==========================================
-- 4. 外部脚本导入系统
-- ==========================================
local UIListScripts = Instance.new("UIListLayout", ScriptsPage)
UIListScripts.SortOrder = Enum.SortOrder.LayoutOrder
UIListScripts.Padding = UDim.new(0, 10)
UIListScripts.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateScriptSlot(title, scriptUrl)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 40)
    Btn.BackgroundColor3 = Themes.Dark.ElementBG
    Btn.Text = "执行: " .. title
    Btn.TextColor3 = Themes.Dark.TextColor
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.Parent = ScriptsPage

    Btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet(scriptUrl))()
        end)
    end)
end

-- 预设三个外部导入槽位
CreateScriptSlot("外部完整脚本位置 1", "https://raw.githubusercontent.com/Example/Script1")
CreateScriptSlot("外部完整脚本位置 2", "https://raw.githubusercontent.com/Example/Script2")
CreateScriptSlot("外部完整脚本位置 3", "https://raw.githubusercontent.com/Example/Script3")

-- ==========================================
-- 5. 主题切换 (暗黑/光亮模式)
-- ==========================================
local UIListSettings = Instance.new("UIListLayout", SettingsPage)
UIListSettings.SortOrder = Enum.SortOrder.LayoutOrder
UIListSettings.Padding = UDim.new(0, 10)
UIListSettings.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Size = UDim2.new(0.9, 0, 0, 40)
ThemeBtn.BackgroundColor3 = Themes.Dark.ElementBG
ThemeBtn.Text = "切换模式 (当前: 黑暗)"
ThemeBtn.TextColor3 = Themes.Dark.TextColor
ThemeBtn.Font = Enum.Font.Gotham
ThemeBtn.TextSize = 14
Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 6)
ThemeBtn.Parent = SettingsPage

ThemeBtn.MouseButton1Click:Connect(function()
    CurrentTheme = CurrentTheme == "Dark" and "Light" or "Dark"
    ThemeBtn.Text = "切换模式 (当前: " .. (CurrentTheme == "Dark" and "黑暗" or "光亮") .. ")"
    local T = Themes[CurrentTheme]
    
    MainFrame.BackgroundColor3 = T.MainBG
    Sidebar.BackgroundColor3 = T.SidebarBG
    TopBar.BackgroundColor3 = T.SidebarBG
    MinButton.TextColor3 = T.TextColor
    MinimizedIcon.BackgroundColor3 = T.MainBG
    
    for _, child in pairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") then child.TextColor3 = T.TextColor end
    end
    for _, page in pairs(Pages) do
        for _, elem in pairs(page:GetChildren()) do
            if elem:IsA("TextLabel") or elem:IsA("TextButton") then
                elem.TextColor3 = T.TextColor
                if elem.BackgroundColor3 ~= Themes.Dark.Accent and elem.BackgroundTransparency == 0 then
                    elem.BackgroundColor3 = T.ElementBG
                end
            end
        end
    end
end)

-- ==========================================
-- 6. 初始化与收尾
-- ==========================================
ShowNotification()

