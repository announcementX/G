local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ 顶层容器 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_Elite_UI"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- [[ 缩小后的图标 - 修复拖拽 ]]
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Parent = sg
MiniIcon.Size = UDim2.new(0, 60, 0, 60)
MiniIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniIcon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
MiniIcon.Visible = false
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MiniIcon).Color = Color3.fromRGB(0, 120, 255)

-- 缩小图标拖拽
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

-- [[ 主悬浮窗 - 现代卡片设计 ]]
local Main = Instance.new("Frame")
Main.Parent = sg
Main.Size = UDim2.new(0, 420, 0, 340) 
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 2

-- [[ 侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 120, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
SideBar.BorderSizePixel = 0
Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 12)

-- 移动限制开关 (点击 XU 标志切换)
local Logo = Instance.new("TextButton", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Text = "XU"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 170, 255)
Logo.TextSize = 34
Logo.BackgroundTransparency = 1

local isMoving = false
Logo.MouseButton1Click:Connect(function()
    isMoving = not isMoving
    -- 反馈：开启移动时标志变绿，锁定变蓝
    Logo.TextColor3 = isMoving and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(0, 170, 255)
end)

UIS.InputChanged:Connect(function(input)
    if isMoving and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        Main.Position = UDim2.new(0, mousePos.X - 60, 0, mousePos.Y - 30)
    end
end)

-- 左下角用户信息（修复白色色块）
local UserFrame = Instance.new("Frame", SideBar)
UserFrame.Size = UDim2.new(1, 0, 0, 60)
UserFrame.Position = UDim2.new(0, 0, 1, -65)
UserFrame.BackgroundTransparency = 1 -- 确保透明，无白色底色

local Head = Instance.new("ImageLabel", UserFrame)
Head.Size = UDim2.new(0, 36, 0, 36)
Head.Position = UDim2.new(0, 10, 0, 12)
Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

local LName = Instance.new("TextLabel", UserFrame)
LName.Size = UDim2.new(0, 70, 0, 36)
LName.Position = UDim2.new(0, 52, 0, 12)
LName.Text = lplr.Name
LName.TextColor3 = Color3.new(1, 1, 1)
LName.Font = Enum.Font.GothamSemibold
LName.TextSize = 15
LName.TextXAlignment = Enum.TextXAlignment.Left
LName.BackgroundTransparency = 1

-- [[ 页面容器 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 120, 0, 0)
Container.Size = UDim2.new(1, -120, 1, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 15); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = p
    return p
end

local HomeP = CreatePage("Home")
local UniversalP = CreatePage("Universal")
HomeP.Visible = true

-- [[ 主页严格顺序布局 ]]

-- 1. 最上边：轮播图 (Banner)
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.92, 0, 0, 100)
Banner.Image = "rbxassetid://6073743371" -- 替换为高质量背景
Banner.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)

-- 2. 最中间：作者信息 (统一字号 18, 纯蓝色)
local Author = Instance.new("TextLabel", HomeP)
Author.Size = UDim2.new(0.92, 0, 0, 30)
Author.Text = "作者: HaoChen | QQ: 1626844714"
Author.TextColor3 = Color3.fromRGB(0, 100, 255)
Author.Font = Enum.Font.GothamBold
Author.TextSize = 18
Author.BackgroundTransparency = 1

-- 3. 最下边：详细数据信息
local InfoBox = Instance.new("Frame", HomeP)
InfoBox.Size = UDim2.new(0.92, 0, 0, 140)
InfoBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 8)

local InfoTxt = Instance.new("TextLabel", InfoBox)
InfoTxt.Size = UDim2.new(1, -20, 1, -20)
InfoTxt.Position = UDim2.new(0, 10, 0, 10)
InfoTxt.BackgroundTransparency = 1
InfoTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoTxt.Font = Enum.Font.Gotham
InfoTxt.TextSize = 18
InfoTxt.TextXAlignment = Enum.TextXAlignment.Left
InfoTxt.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        InfoTxt.Text = string.format("【服务器】ID: %d\n节点: %s\n人数: %d/%d\n\n【玩家】ID: %d\n机龄: %d天",
            game.PlaceId, game.JobId == "" and "Local" or "Active", #Players:GetPlayers(), Players.MaxPlayers,
            lplr.UserId, lplr.AccountAge
        )
    end
end)

-- [[ 确认加载弹窗 ]]
local function ConfirmAndRun(name, url)
    local Mask = Instance.new("Frame", sg)
    Mask.Size = UDim2.new(1, 0, 1, 0); Mask.BackgroundColor3 = Color3.new(0,0,0); Mask.BackgroundTransparency = 0.5
    local Pop = Instance.new("Frame", Mask)
    Pop.Size = UDim2.new(0, 250, 0, 130); Pop.Position = UDim2.new(0.5, -125, 0.5, -65); Pop.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", Pop).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Pop).Color = Color3.fromRGB(0, 170, 255)
    
    local T = Instance.new("TextLabel", Pop); T.Size = UDim2.new(1, 0, 0, 80); T.Text = "是否确认加载:\n" .. name .. "?"; T.TextColor3 = Color3.new(1,1,1); T.TextSize = 18; T.BackgroundTransparency = 1; T.Font = Enum.Font.GothamBold

    local function CreatePBtn(txt, x, color, func)
        local b = Instance.new("TextButton", Pop); b.Size = UDim2.new(0, 95, 0, 35); b.Position = UDim2.new(0, x, 0, 85)
        b.BackgroundColor3 = color; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); b.MouseButton1Click:Connect(func)
    end

    CreatePBtn("确认加载", 20, Color3.fromRGB(0, 180, 100), function() Mask:Destroy(); loadstring(game:HttpGet(url))() end)
    CreatePBtn("取消", 135, Color3.fromRGB(180, 50, 50), function() Mask:Destroy() end)
end

-- [[ 脚本列表 - 按钮间距优化 ]]
Instance.new("UIPadding", UniversalP).PaddingTop = UDim.new(0, 50)
local function AddScript(page, name, url)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(0.9, 0, 0, 50); b.BackgroundColor3 = Color3.fromRGB(30, 30, 45); b.Text = "▶ " .. name; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 20; b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(function() ConfirmAndRun(name, url) end)
end

-- 你的飞行脚本加载
AddScript(UniversalP, "XU飞行脚本", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")

-- [[ 导航切换 ]]
local function Nav(txt, pos_y, target)
    local b = Instance.new("TextButton", SideBar)
    b.Size = UDim2.new(0.85, 0, 0, 40); b.Position = UDim2.new(0.07, 0, 0, pos_y); b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.Text = txt; b.TextColor3 = Color3.new(0.9,0.9,0.9); b.TextSize = 16; b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end target.Visible = true end)
end

Nav("🏠 主页", 70, HomeP)
Nav("🛠️ 通用", 120, UniversalP)

-- [[ 顶栏操作按钮 ]]
local function TopBtn(txt, x, color, func)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 28, 0, 28); b.Position = UDim2.new(1, x, 0, 12); b.Text = txt; b.TextColor3 = color; b.BackgroundTransparency = 1; b.TextSize = 26; b.MouseButton1Click:Connect(func)
end

TopBtn("×", -40, Color3.fromRGB(255, 80, 80), function() sg:Destroy() end)
TopBtn("-", -75, Color3.new(0.8, 0.8, 0.8), function() Main.Visible = false; MiniIcon.Visible = true end)

MiniIcon.MouseButton1Click:Connect(function() Main.Visible = true; MiniIcon.Visible = false end)
