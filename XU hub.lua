local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ UI 顶层 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_V2_System"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- [[ 1. 缩小后的图标 (默认隐藏) ]]
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Name = "MiniIcon"
MiniIcon.Parent = sg
MiniIcon.Size = UDim2.new(0, 60, 0, 60)
MiniIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniIcon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
MiniIcon.Visible = false
MiniIcon.Active = true
MiniIcon.Draggable = true -- 缩小图标可自由拖动
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 12)
local MiniStroke = Instance.new("UIStroke", MiniIcon)
MiniStroke.Color = Color3.fromRGB(0, 200, 255)
MiniStroke.Thickness = 2

-- [[ 2. 主悬浮窗 ]]
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = sg
Main.Size = UDim2.new(0, 520, 0, 360) -- 缩小整体尺寸
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- 星空背景
local StarBG = Instance.new("ImageLabel", Main)
StarBG.Size = UDim2.new(1, 0, 1, 0)
StarBG.Image = "rbxassetid://2043644365"
StarBG.ImageTransparency = 0.8
StarBG.BackgroundTransparency = 1
StarBG.ScaleType = Enum.ScaleType.Crop

-- [[ 左侧侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 150, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
SideBar.BackgroundTransparency = 0.3
SideBar.BorderSizePixel = 0

-- 拖拽标题
local Logo = Instance.new("TextLabel", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Text = "XU CENTER"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 200, 255)
Logo.TextSize = 22 -- 增大字体
Logo.BackgroundTransparency = 1

local dragging, dragStart, startPos
Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- 左下角用户信息修复
local UserFrame = Instance.new("Frame", SideBar)
UserFrame.Size = UDim2.new(1, 0, 0, 50)
UserFrame.Position = UDim2.new(0, 0, 1, -60)
UserFrame.BackgroundTransparency = 1

local Head = Instance.new("ImageLabel", UserFrame)
Head.Size = UDim2.new(0, 35, 0, 35)
Head.Position = UDim2.new(0, 10, 0, 7)
Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

local LName = Instance.new("TextLabel", UserFrame)
LName.Size = UDim2.new(0, 95, 0, 35)
LName.Position = UDim2.new(0, 50, 0, 7)
LName.Text = lplr.Name
LName.TextColor3 = Color3.fromRGB(255, 255, 255)
LName.Font = Enum.Font.GothamSemibold
LName.TextSize = 16 -- 增大字体
LName.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 页面管理 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 150, 0, 0)
Container.Size = UDim2.new(1, -150, 1, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", p).PaddingLeft = UDim.new(0, 10)
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 10)
    Pages[name] = p
    return p
end

local HomeP = CreatePage("主页")
local UniversalP = CreatePage("通用脚本")
local DisasterP = CreatePage("自然灾害")
local DeadRailP = CreatePage("死铁轨")
local AbandonedP = CreatePage("被遗弃")
HomeP.Visible = true

-- [[ 主页布局：严格顺序 ]]
-- 1. 轮播图在上面
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.95, 0, 0, 110)
Banner.Image = "rbxassetid://6073743371"
Banner.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)

-- 2. 作者信息在中间
local Author = Instance.new("TextLabel", HomeP)
Author.Size = UDim2.new(0.95, 0, 0, 35)
Author.Text = "作者: HaoChen | QQ: 1626844714"
Author.TextColor3 = Color3.fromRGB(0, 255, 200)
Author.Font = Enum.Font.GothamBold
Author.TextSize = 18 -- 增大字体
Author.BackgroundTransparency = 1

-- 3. 服务器和玩家信息在下面
local DetailBox = Instance.new("Frame", HomeP)
DetailBox.Size = UDim2.new(0.95, 0, 0, 150)
DetailBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Instance.new("UICorner", DetailBox).CornerRadius = UDim.new(0, 8)

local Info = Instance.new("TextLabel", DetailBox)
Info.Size = UDim2.new(1, -16, 1, -16)
Info.Position = UDim2.new(0, 8, 0, 8)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(220, 220, 220)
Info.Font = Enum.Font.Code
Info.TextSize = 13 -- 增大字体
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        Info.Text = string.format("【服务器信息】\nID: %d\n节点: %s\n人数: %d/%d\n\n【详细用户信息】\n名称: %s\nUserID: %d\n机龄: %d天\n位置: %s",
            game.PlaceId, game.JobId=="" and "Local" or game.JobId, #Players:GetPlayers(), Players.MaxPlayers,
            lplr.Name, lplr.UserId, lplr.AccountAge, tostring(math.floor(lplr.Character.PrimaryPart.Position.X))..","..tostring(math.floor(lplr.Character.PrimaryPart.Position.Y))
        )
    end
end)

-- [[ 脚本添加逻辑：保持严格格式 ]]
local function AddScript(parent, name, link)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = "  ▶ 运行: " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet(link))() 
    end)
end

AddScript(UniversalP, "飞行脚本", "https://raw.githubusercontent.com/announcementX/G/main/e.txt")
AddScript(DisasterP, "自动躲避", "https://link.com/auto.lua")

-- [[ 缩小/恢复逻辑 ]]
MiniIcon.MouseButton1Click:Connect(function()
    MiniIcon.Visible = false
    Main.Visible = true
end)

-- [[ 侧边栏按钮 ]]
local function Nav(txt, pos, target)
    local b = Instance.new("TextButton", SideBar)
    b.Size = UDim2.new(0.85, 0, 0, 35)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 15
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        target.Visible = true
    end)
end

Nav("🏠 主页", UDim2.new(0.07, 0, 0, 60), HomeP)
Nav("🛠️ 通用脚本", UDim2.new(0.07, 0, 0, 100), UniversalP)
Nav("🌪️ 自然灾害", UDim2.new(0.07, 0, 0, 140), DisasterP)
Nav("🛤️ 死铁轨", UDim2.new(0.07, 0, 0, 180), DeadRailP)
Nav("🏚️ 被遗弃", UDim2.new(0.07, 0, 0, 220), AbandonedP)

-- [[ 右上角控制 ]]
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 25, 0, 25); Cls.Position = UDim2.new(1, -35, 0, 10)
Cls.Text = "×"; Cls.TextColor3 = Color3.fromRGB(255, 80, 80); Cls.BackgroundTransparency = 1; Cls.TextSize = 25
Cls.MouseButton1Click:Connect(function() sg:Destroy() end)

local MiniBtn = Instance.new("TextButton", Main)
MiniBtn.Size = UDim2.new(0, 25, 0, 25); MiniBtn.Position = UDim2.new(1, -65, 0, 10)
MiniBtn.Text = "-"; MiniBtn.TextColor3 = Color3.fromRGB(200, 200, 200); MiniBtn.BackgroundTransparency = 1; MiniBtn.TextSize = 25
MiniBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    MiniIcon.Visible = true
end)
