local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ UI 顶层容器 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_Final_v3"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- [[ 缩小后的图标 (带拖拽) ]]
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Parent = sg
MiniIcon.Size = UDim2.new(0, 55, 0, 55)
MiniIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniIcon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
MiniIcon.Visible = false
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MiniIcon).Color = Color3.fromRGB(0, 120, 255)

-- 缩小图标拖拽逻辑
local m_drag, m_start, m_pos
MiniIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        m_drag = true; m_start = input.Position; m_pos = MiniIcon.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if m_drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - m_start
        MiniIcon.Position = UDim2.new(m_pos.X.Scale, m_pos.X.Offset + delta.X, m_pos.Y.Scale, m_pos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then m_drag = false end end)

-- [[ 主悬浮窗 (进一步缩小) ]]
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = sg
Main.Size = UDim2.new(0, 420, 0, 340) 
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(45, 45, 60)
MainStroke.Thickness = 1.5

-- [[ 侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 120, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
SideBar.BackgroundTransparency = 0.2
SideBar.BorderSizePixel = 0

-- 拖拽开关: XU
local Logo = Instance.new("TextButton", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 55)
Logo.Text = "XU"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 170, 255)
Logo.TextSize = 30
Logo.BackgroundTransparency = 1

-- 窗口跟随模式逻辑
local isMoving = false
local moveConn
Logo.MouseButton1Click:Connect(function()
    isMoving = not isMoving
    Logo.TextColor3 = isMoving and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 170, 255)
end)

UIS.InputChanged:Connect(function(input)
    if isMoving and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        Main.Position = UDim2.new(0, mousePos.X - 60, 0, mousePos.Y - 30)
    end
end)

-- 左下角用户信息
local UserBar = Instance.new("Frame", SideBar)
UserBar.Size = UDim2.new(1, 0, 0, 50)
UserBar.Position = UDim2.new(0, 0, 1, -55)
UserBar.BackgroundTransparency = 1

local Head = Instance.new("ImageLabel", UserBar)
Head.Size = UDim2.new(0, 32, 0, 32)
Head.Position = UDim2.new(0, 10, 0, 9)
Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

local LName = Instance.new("TextLabel", UserBar)
LName.Size = UDim2.new(0, 70, 0, 32)
LName.Position = UDim2.new(0, 48, 0, 9)
LName.Text = lplr.Name
LName.TextColor3 = Color3.new(1,1,1)
LName.Font = Enum.Font.GothamBold
LName.TextSize = 16
LName.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 页面管理 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.Size = UDim2.new(1, -120, 1, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 12); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = p
    return p
end

local HomeP = CreatePage("Home")
local UniversalP = CreatePage("Universal")
HomeP.Visible = true

-- 防止脚本按钮被遮挡：顶部内边距
Instance.new("UIPadding", UniversalP).PaddingTop = UDim.new(0, 40)

-- [[ 主页严格顺序布局 ]]

-- 1. 最上边：悬浮窗主体 (轮播图)
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.9, 0, 0, 100)
Banner.Image = "rbxassetid://6073743371"
Banner.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)

-- 2. 最中间：我的信息 (字号18, 纯蓝色)
local Author = Instance.new("TextLabel", HomeP)
Author.Size = UDim2.new(0.9, 0, 0, 30)
Author.Text = "作者: HaoChen | QQ: 1626844714"
Author.TextColor3 = Color3.fromRGB(0, 100, 255)
Author.Font = Enum.Font.GothamBold
Author.TextSize = 18
Author.BackgroundTransparency = 1

-- 3. 最下边：详细数据信息
local InfoBox = Instance.new("Frame", HomeP)
InfoBox.Size = UDim2.new(0.9, 0, 0, 130)
InfoBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 8)

local InfoTxt = Instance.new("TextLabel", InfoBox)
InfoTxt.Size = UDim2.new(1, -16, 1, -16)
InfoTxt.Position = UDim2.new(0, 8, 0, 8)
InfoTxt.BackgroundTransparency = 1
InfoTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoTxt.Font = Enum.Font.Gotham
InfoTxt.TextSize = 18
InfoTxt.TextXAlignment = Enum.TextXAlignment.Left
InfoTxt.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        InfoTxt.Text = string.format("【服务器】ID: %d\n节点: %s\n人数: %d/%d\n\n【玩家】ID: %d\n机龄: %d天",
            game.PlaceId, game.JobId == "" and "Studio" or "Server", #Players:GetPlayers(), Players.MaxPlayers,
            lplr.UserId, lplr.AccountAge
        )
    end
end)

-- [[ 脚本执行确认逻辑 ]]
local function ConfirmAndRun(name, url)
    local Mask = Instance.new("Frame", sg)
    Mask.Size = UDim2.new(1, 0, 1, 0); Mask.BackgroundColor3 = Color3.new(0,0,0); Mask.BackgroundTransparency = 0.5
    
    local Pop = Instance.new("Frame", Mask)
    Pop.Size = UDim2.new(0, 240, 0, 120)
    Pop.Position = UDim2.new(0.5, -120, 0.5, -60)
    Pop.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", Pop).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Pop).Color = Color3.fromRGB(0, 120, 255)
    
    local T = Instance.new("TextLabel", Pop)
    T.Size = UDim2.new(1, 0, 0, 70); T.Text = "确定加载: " .. name .. "?"; T.TextColor3 = Color3.new(1,1,1); T.TextSize = 18; T.BackgroundTransparency = 1

    local function CreatePBtn(txt, x, color, func)
        local b = Instance.new("TextButton", Pop)
        b.Size = UDim2.new(0, 90, 0, 32); b.Position = UDim2.new(0, x, 0, 75)
        b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(func)
    end

    CreatePBtn("确认加载", 20, Color3.fromRGB(0, 180, 100), function()
        Mask:Destroy()
        -- 严格格式执行
        loadstring(game:HttpGet(url))() 
    end)
    CreatePBtn("取消", 130, Color3.fromRGB(180, 50, 50), function() Mask:Destroy() end)
end

-- [[ 脚本按钮创建 ]]
local function AddScript(page, name, url)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(0.9, 0, 0, 45)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    b.Text = "▶ " .. name
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 20
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        ConfirmAndRun(name, url)
    end)
end

-- 这里现在就在“通用”页面的正中心
AddScript(UniversalP, "通用飞行脚本", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")

-- [[ 导航切换 ]]
local function Nav(txt, pos, target)
    local b = Instance.new("TextButton", SideBar)
    b.Size = UDim2.new(0.85, 0, 0, 35); b.Position = pos; b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    b.Text = txt; b.TextColor3 = Color3.new(0.8,0.8,0.8); b.TextSize = 16; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        target.Visible = true
    end)
end

Nav("🏠 主页", UDim2.new(0.07, 0, 0, 65), HomeP)
Nav("🛠️ 通用", UDim2.new(0.07, 0, 0, 110), UniversalP)

-- [[ 顶部操作按钮 ]]
local function TopB(txt, x, color, func)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0, 25, 0, 25); b.Position = UDim2.new(1, x, 0, 10)
    b.Text = txt; b.TextColor3 = color; b.BackgroundTransparency = 1; b.TextSize = 25
    b.MouseButton1Click:Connect(func)
end

TopB("×", -35, Color3.fromRGB(255, 80, 80), function() sg:Destroy() end)
TopB("-", -65, Color3.new(0.8,0.8,0.8), function() Main.Visible = false; MiniIcon.Visible = true end)

MiniIcon.MouseButton1Click:Connect(function() Main.Visible = true; MiniIcon.Visible = false end)
