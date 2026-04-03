local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ 基础 UI 架构 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_XU_System"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = sg
Main.Size = UDim2.new(0, 620, 0, 420)
Main.Position = UDim2.new(0.5, -310, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

-- 星空背景
local StarBG = Instance.new("ImageLabel", Main)
StarBG.Size = UDim2.new(1, 0, 1, 0)
StarBG.Image = "rbxassetid://2043644365"
StarBG.ImageTransparency = 0.8
StarBG.BackgroundTransparency = 1
StarBG.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", StarBG).CornerRadius = UDim.new(0, 15)

-- [[ 左侧侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 170, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
SideBar.BackgroundTransparency = 0.3
SideBar.BorderSizePixel = 0

-- 唯一拖拽区域：XU CENTER
local Logo = Instance.new("TextLabel", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Text = "XU CENTER"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 200, 255)
Logo.TextSize = 22
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

-- 左下角用户信息
local UserInfo = Instance.new("Frame", SideBar)
UserInfo.Size = UDim2.new(1, 0, 0, 60)
UserInfo.Position = UDim2.new(0, 0, 1, -70)
UserInfo.BackgroundTransparency = 1

local Head = Instance.new("ImageLabel", UserInfo)
Head.Size = UDim2.new(0, 42, 0, 42)
Head.Position = UDim2.new(0, 15, 0, 9)
Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

local LName = Instance.new("TextLabel", UserInfo)
LName.Size = UDim2.new(0, 100, 0, 42)
LName.Position = UDim2.new(0, 65, 0, 9)
LName.Text = lplr.Name
LName.TextColor3 = Color3.fromRGB(255, 255, 255)
LName.Font = Enum.Font.GothamSemibold
LName.TextSize = 14
LName.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 页面管理 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 170, 0, 0)
Container.Size = UDim2.new(1, -170, 1, 0)
Container.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 10)
    Instance.new("UIPadding", p).PaddingLeft = UDim.new(0, 15)
    Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 15)
    Pages[name] = p
    return p
end

local HomeP = CreatePage("主页")
local UniversalP = CreatePage("通用脚本")
local DisasterP = CreatePage("自然灾害")
local DeadRailP = CreatePage("死铁轨")
local AbandonedP = CreatePage("被遗弃")
HomeP.Visible = true

-- [[ 主页内容：HaoChen 专属展示 ]]
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.95, 0, 0, 140)
Banner.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 12)
Banner.Image = "rbxassetid://6073743371"
Banner.ScaleType = Enum.ScaleType.Crop

local AuthorTxt = Instance.new("TextLabel", HomeP)
AuthorTxt.Size = UDim2.new(0.95, 0, 0, 40)
AuthorTxt.Text = "作者: HaoChen | QQ: 1626844714"
AuthorTxt.TextColor3 = Color3.fromRGB(0, 255, 200)
AuthorTxt.Font = Enum.Font.GothamBold
AuthorTxt.TextSize = 18
AuthorTxt.BackgroundTransparency = 1

local DetailBox = Instance.new("Frame", HomeP)
DetailBox.Size = UDim2.new(0.95, 0, 0, 140)
DetailBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Instance.new("UICorner", DetailBox).CornerRadius = UDim.new(0, 10)

local Info = Instance.new("TextLabel", DetailBox)
Info.Size = UDim2.new(1, -20, 1, -20)
Info.Position = UDim2.new(0, 10, 0, 10)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(220, 220, 220)
Info.Font = Enum.Font.Code
Info.TextSize = 11
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(1) do
        Info.Text = string.format("【服务器】\nID: %d\n节点: %s\n人数: %d/%d\n\n【用户】\n名称: %s\nID: %d\n机龄: %d天\n位置: %s",
            game.PlaceId, game.JobId=="" and "Local" or game.JobId, #Players:GetPlayers(), Players.MaxPlayers,
            lplr.Name, lplr.UserId, lplr.AccountAge, tostring(math.floor(lplr.Character.PrimaryPart.Position.X))..","..tostring(math.floor(lplr.Character.PrimaryPart.Position.Y))
        )
    end
end)

-- [[ 核心逻辑：创建脚本按钮并强制使用你的格式 ]]
local function AddScript(parent, name, link)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = "   ▶ 启动: " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        loadstring(game:HttpGet(link))() 
    end)
end

-- 填充栏目内容 (替换为你自己的链接)
AddScript(UniversalP, "飞行脚本", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")
AddScript(DisasterP, "自动躲避灾难", "https://link.com/disaster_auto.lua")
AddScript(DeadRailP, "死铁轨辅助", "https://link.com/deadrail.lua")
AddScript(AbandonedP, "被遗弃主脚本", "https://link.com/abandoned.lua")

-- [[ 侧边栏导航控制 ]]
local function Nav(txt, pos, target)
    local b = Instance.new("TextButton", SideBar)
    b.Size = UDim2.new(0.85, 0, 0, 35)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        target.Visible = true
    end)
end

Nav("🏠 主页", UDim2.new(0.07, 0, 0, 70), HomeP)
Nav("🛠️ 通用脚本", UDim2.new(0.07, 0, 0, 110), UniversalP)
Nav("🌪️ 自然灾害", UDim2.new(0.07, 0, 0, 150), DisasterP)
Nav("🛤️ 死铁轨", UDim2.new(0.07, 0, 0, 190), DeadRailP)
Nav("🏚️ 被遗弃", UDim2.new(0.07, 0, 0, 230), AbandonedP)

-- 关闭按钮
local Cls = Instance.new("TextButton", Main)
Cls.Size = UDim2.new(0, 30, 0, 30); Cls.Position = UDim2.new(1, -40, 0, 10)
Cls.Text = "×"; Cls.TextColor3 = Color3.fromRGB(255, 80, 80); Cls.BackgroundTransparency = 1; Cls.TextSize = 30
Cls.MouseButton1Click:Connect(function() sg:Destroy() end)
