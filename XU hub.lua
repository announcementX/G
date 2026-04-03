local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ 顶层 UI ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_Ultimate_Fix"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- [[ 缩小图标：可拖拽的正方形 ]]
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Parent = sg
MiniIcon.Size = UDim2.new(0, 55, 0, 55)
MiniIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniIcon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
MiniIcon.Visible = false
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MiniIcon).Color = Color3.fromRGB(0, 120, 255)

-- 缩小图标自由拖拽逻辑
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

-- [[ 主悬浮窗 (极致缩小尺寸) ]]
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = sg
Main.Size = UDim2.new(0, 400, 0, 320) 
Main.Position = UDim2.new(0.5, -200, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(50, 50, 70)

-- [[ 侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 110, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
SideBar.BorderSizePixel = 0

-- 移动限制开关：点击 XU 开始移动，再点停止
local Logo = Instance.new("TextButton", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Text = "XU"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 170, 255)
Logo.TextSize = 32
Logo.BackgroundTransparency = 1

local isMoving = false
Logo.MouseButton1Click:Connect(function()
    isMoving = not isMoving
    -- 颜色反馈：黄色表示可以移动，蓝色表示锁定
    Logo.TextColor3 = isMoving and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 170, 255)
end)

UIS.InputChanged:Connect(function(input)
    if isMoving and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        Main.Position = UDim2.new(0, mousePos.X - 55, 0, mousePos.Y - 25)
    end
end)

-- 用户头像名字
local UserBox = Instance.new("Frame", SideBar)
UserBox.Size = UDim2.new(1, 0, 0, 50); UserBox.Position = UDim2.new(0, 0, 1, -55); UserBox.BackgroundTransparency = 1
local Head = Instance.new("ImageLabel", UserBox)
Head.Size = UDim2.new(0, 30, 0, 30); Head.Position = UDim2.new(0, 8, 0, 10); Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)
local LName = Instance.new("TextLabel", UserBox)
LName.Size = UDim2.new(0, 65, 0, 30); LName.Position = UDim2.new(0, 42, 0, 10); LName.Text = lplr.Name; LName.TextColor3 = Color3.new(1,1,1); LName.Font = Enum.Font.GothamBold; LName.TextSize = 14; LName.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 内容容器 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 110, 0, 0); Container.Size = UDim2.new(1, -110, 1, 0); Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout", p); layout.Padding = UDim.new(0, 12); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Pages[name] = p
    return p
end

local HomeP = CreatePage("Home")
local UniversalP = CreatePage("Universal")
HomeP.Visible = true

-- 脚本页间距修复
Instance.new("UIPadding", UniversalP).PaddingTop = UDim.new(0, 45)

-- [[ 主页布局：严格死守位置要求 ]]

-- 1. 最上方：轮播图 (Banner)
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.92, 0, 0, 90)
Banner.Image = "rbxassetid://6073743371"
Banner.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 8)

-- 2. 正中间：作者信息 (字号18, 纯蓝色)
local Author = Instance.new("TextLabel", HomeP)
Author.Size = UDim2.new(0.92, 0, 0, 30)
Author.Text = "作者: HaoChen | QQ: 1626844714"
Author.TextColor3 = Color3.fromRGB(0, 100, 255)
Author.Font = Enum.Font.GothamBold
Author.TextSize = 18
Author.BackgroundTransparency = 1

-- 3. 最下方：详细数据
local Detail = Instance.new("Frame", HomeP)
Detail.Size = UDim2.new(0.92, 0, 0, 120)
Detail.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Instance.new("UICorner", Detail).CornerRadius = UDim.new(0, 8)

local InfoTxt = Instance.new("TextLabel", Detail)
InfoTxt.Size = UDim2.new(1, -16, 1, -16); InfoTxt.Position = UDim2.new(0, 8, 0, 8); InfoTxt.BackgroundTransparency = 1; InfoTxt.TextColor3 = Color3.fromRGB(200, 200, 200); InfoTxt.Font = Enum.Font.Gotham; InfoTxt.TextSize = 18; InfoTxt.TextXAlignment = Enum.TextXAlignment.Left; InfoTxt.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        InfoTxt.Text = string.format("【服务器】ID: %d\n人数: %d/%d\n\n【玩家】ID: %d\n机龄: %d天", game.PlaceId, #Players:GetPlayers(), Players.MaxPlayers, lplr.UserId, lplr.AccountAge)
    end
end)

-- [[ 确认加载逻辑 ]]
local function ConfirmLoad(name, url)
    local Mask = Instance.new("Frame", sg)
    Mask.Size = UDim2.new(1, 0, 1, 0); Mask.BackgroundColor3 = Color3.new(0,0,0); Mask.BackgroundTransparency = 0.5
    local Pop = Instance.new("Frame", Mask)
    Pop.Size = UDim2.new(0, 240, 0, 120); Pop.Position = UDim2.new(0.5, -120, 0.5, -60); Pop.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Instance.new("UICorner", Pop).CornerRadius = UDim.new(0, 8)
    local T = Instance.new("TextLabel", Pop); T.Size = UDim2.new(1, 0, 0, 70); T.Text = "确定加载: " .. name .. "?"; T.TextColor3 = Color3.new(1,1,1); T.TextSize = 18; T.BackgroundTransparency = 1
    local function B(t, x, c, f)
        local btn = Instance.new("TextButton", Pop); btn.Size = UDim2.new(0, 90, 0, 32); btn.Position = UDim2.new(0, x, 0, 75); btn.BackgroundColor3 = c; btn.Text = t; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4); btn.MouseButton1Click:Connect(f)
    end
    B("确认", 20, Color3.fromRGB(0, 180, 100), function() Mask:Destroy(); loadstring(game:HttpGet(url))() end)
    B("取消", 130, Color3.fromRGB(180, 50, 50), function() Mask:Destroy() end)
end

-- [[ 脚本按钮 ]]
local function AddScript(page, name, url)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(0.9, 0, 0, 45); b.BackgroundColor3 = Color3.fromRGB(30, 30, 45); b.Text = "▶ " .. name; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 20; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(function() ConfirmLoad(name, url) end)
end

AddScript(UniversalP, "通用飞行脚本", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")

-- [[ 导航控制 ]]
local function Nav(t, y, target)
    local b = Instance.new("TextButton", SideBar)
    b.Size = UDim2.new(0.85, 0, 0, 35); b.Position = UDim2.new(0.07, 0, 0, y); b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.Text = t; b.TextColor3 = Color3.new(0.8,0.8,0.8); b.TextSize = 16; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() for _, p in pairs(Pages) do p.Visible = false end target.Visible = true end)
end
Nav("🏠 主页", 65, HomeP); Nav("🛠️ 通用", 110, UniversalP)

-- [[ 顶栏操作 ]]
local function TopBtn(t, x, c, f)
    local b = Instance.new("TextButton", Main); b.Size = UDim2.new(0, 25, 0, 25); b.Position = UDim2.new(1, x, 0, 10); b.Text = t; b.TextColor3 = c; b.BackgroundTransparency = 1; b.TextSize = 25; b.MouseButton1Click:Connect(f)
end
TopBtn("×", -35, Color3.fromRGB(255, 80, 80), function() sg:Destroy() end)
TopBtn("-", -65, Color3.new(0.8,0.8,0.8), function() Main.Visible = false; MiniIcon.Visible = true end)
MiniIcon.MouseButton1Click:Connect(function() Main.Visible = true; MiniIcon.Visible = false end)
