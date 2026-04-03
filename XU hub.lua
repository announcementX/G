local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer

-- [[ 顶层容器 ]]
local sg = Instance.new("ScreenGui")
sg.Name = "HaoChen_Pro_System"
sg.Parent = lplr:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- [[ 缩小后的图标 ]]
local MiniIcon = Instance.new("ImageButton")
MiniIcon.Parent = sg
MiniIcon.Size = UDim2.new(0, 65, 0, 65)
MiniIcon.Position = UDim2.new(0.05, 0, 0.4, 0)
MiniIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MiniIcon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
MiniIcon.Visible = false
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 15)
local MStroke = Instance.new("UIStroke", MiniIcon)
MStroke.Color = Color3.fromRGB(0, 170, 255)
MStroke.Thickness = 2

-- [[ 主悬浮窗 ]]
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = sg
Main.Size = UDim2.new(0, 480, 0, 380)
Main.Position = UDim2.new(0.5, -240, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 1

-- 星空背景
local StarBG = Instance.new("ImageLabel", Main)
StarBG.Size = UDim2.new(1, 0, 1, 0)
StarBG.Image = "rbxassetid://2043644365"
StarBG.ImageTransparency = 0.85
StarBG.BackgroundTransparency = 1
StarBG.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", StarBG).CornerRadius = UDim.new(0, 12)

-- [[ 左侧侧边栏 ]]
local SideBar = Instance.new("Frame", Main)
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
SideBar.BorderSizePixel = 0

-- 拖拽标题：XU (长按逻辑)
local Logo = Instance.new("TextLabel", SideBar)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Text = "XU"
Logo.Font = Enum.Font.GothamBold
Logo.TextColor3 = Color3.fromRGB(0, 200, 255)
Logo.TextSize = 30 
Logo.BackgroundTransparency = 1

-- 长按拖拽逻辑
local dragging = false
local holdTime = 0
local dragConn

Logo.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local currentHold = true
		task.delay(0.5, function() -- 必须长按0.5秒
			if currentHold then
				dragging = not dragging
				if dragging then
					Logo.TextColor3 = Color3.fromRGB(255, 255, 0) -- 变黄提示正在移动
				else
					Logo.TextColor3 = Color3.fromRGB(0, 200, 255)
				end
			end
		end)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then currentHold = false end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		Main.Position = UDim2.new(0, input.Position.X - 70, 0, input.Position.Y - 30)
	end
end)

-- 左下角用户信息 (修复显示)
local UserBottom = Instance.new("Frame", SideBar)
UserBottom.Size = UDim2.new(1, 0, 0, 60)
UserBottom.Position = UDim2.new(0, 0, 1, -65)
UserBottom.BackgroundTransparency = 1

local Head = Instance.new("ImageLabel", UserBottom)
Head.Size = UDim2.new(0, 40, 0, 40)
Head.Position = UDim2.new(0, 10, 0, 10)
Head.Image = Players:GetUserThumbnailAsync(lplr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
Instance.new("UICorner", Head).CornerRadius = UDim.new(1, 0)

local LName = Instance.new("TextLabel", UserBottom)
LName.Size = UDim2.new(0, 80, 0, 40)
LName.Position = UDim2.new(0, 55, 0, 10)
LName.Text = lplr.Name
LName.TextColor3 = Color3.fromRGB(255, 255, 255)
LName.Font = Enum.Font.GothamSemibold
LName.TextSize = 18
LName.TextXAlignment = Enum.TextXAlignment.Left

-- [[ 页面容器 ]]
local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 140, 0, 0)
Container.Size = UDim2.new(1, -140, 1, 0)
Container.BackgroundTransparency = 1

local HomeP = Instance.new("ScrollingFrame", Container)
HomeP.Size = UDim2.new(1, 0, 1, 0); HomeP.BackgroundTransparency = 1; HomeP.Visible = true; HomeP.ScrollBarThickness = 0
local HomeLayout = Instance.new("UIListLayout", HomeP)
HomeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
HomeLayout.Padding = UDim.new(0, 15)

-- [[ 主页布局顺序 ]]

-- 1. 悬浮窗主体 (轮播图) 在最上边
local Banner = Instance.new("ImageLabel", HomeP)
Banner.Size = UDim2.new(0.9, 0, 0, 120)
Banner.Image = "rbxassetid://6073743371"
Banner.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)

-- 2. 我的信息在最中间 (同等字号, 蓝色)
local Author = Instance.new("TextLabel", HomeP)
Author.Size = UDim2.new(0.9, 0, 0, 30)
Author.Text = "作者: HaoChen | QQ: 1626844714"
Author.TextColor3 = Color3.fromRGB(0, 120, 255) -- 蓝色
Author.Font = Enum.Font.GothamBold
Author.TextSize = 18 -- 与其他字体同等大小
Author.BackgroundTransparency = 1

-- 3. 服务器信息和玩家信息在最下边
local InfoBox = Instance.new("Frame", HomeP)
InfoBox.Size = UDim2.new(0.9, 0, 0, 160)
InfoBox.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 8)

local Detail = Instance.new("TextLabel", InfoBox)
Detail.Size = UDim2.new(1, -20, 1, -20)
Detail.Position = UDim2.new(0, 10, 0, 10)
Detail.BackgroundTransparency = 1
Detail.TextColor3 = Color3.fromRGB(200, 200, 200)
Detail.Font = Enum.Font.Gotham
Detail.TextSize = 18 -- 调大字号
Detail.TextXAlignment = Enum.TextXAlignment.Left
Detail.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do
		Detail.Text = string.format("【服务器】ID: %d\n节点: %s\n人数: %d/%d\n\n【玩家】ID: %d\n机龄: %d天\n坐标: %s",
			game.PlaceId, game.JobId == "" and "Local" or "Active", #Players:GetPlayers(), Players.MaxPlayers,
			lplr.UserId, lplr.AccountAge, tostring(math.floor(lplr.Character.PrimaryPart.Position.X))..","..tostring(math.floor(lplr.Character.PrimaryPart.Position.Y))
		)
	end
end)

-- [[ 其它页面逻辑 ]]
local function CreatePage(name)
	local p = Instance.new("ScrollingFrame", Container)
	p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
	Instance.new("UIListLayout", p).Padding = UDim.new(0, 12)
	Instance.new("UIPadding", p).PaddingLeft = UDim.new(0, 15)
	Instance.new("UIPadding", p).PaddingTop = UDim.new(0, 20)
	return p
end

local UniversalP = CreatePage("Universal")
local DisasterP = CreatePage("Disaster")

-- [[ 加载格式：硬核执行 ]]
local function AddBtn(page, name, url)
	local b = Instance.new("TextButton", page)
	b.Size = UDim2.new(0.9, 0, 0, 50)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	b.Text = "  ▶ 启动: " .. name
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 20 -- 调大字号
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function()
		loadstring(game:HttpGet(url))() 
	end)
end

AddBtn(UniversalP, "通用飞行", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")

-- [[ 侧边栏导航 ]]
local function Nav(txt, pos, target)
	local b = Instance.new("TextButton", SideBar)
	b.Size = UDim2.new(0.85, 0, 0, 40)
	b.Position = pos
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.MouseButton1Click:Connect(function()
		HomeP.Visible = false; UniversalP.Visible = false; DisasterP.Visible = false
		target.Visible = true
	end)
end

Nav("🏠 主页", UDim2.new(0.07, 0, 0, 70), HomeP)
Nav("🛠️ 通用", UDim2.new(0.07, 0, 0, 120), UniversalP)
Nav("🌪️ 灾难", UDim2.new(0.07, 0, 0, 170), DisasterP)

-- [[ 右上角按键 ]]
local function TopBtn(txt, pos, color, func)
	local b = Instance.new("TextButton", Main)
	b.Size = UDim2.new(0, 30, 0, 30); b.Position = pos
	b.Text = txt; b.TextColor3 = color; b.BackgroundTransparency = 1; b.TextSize = 25
	b.MouseButton1Click:Connect(func)
end

TopBtn("×", UDim2.new(1, -35, 0, 10), Color3.fromRGB(255, 80, 80), function() sg:Destroy() end)
TopBtn("-", UDim2.new(1, -65, 0, 10), Color3.fromRGB(200, 200, 200), function() 
	Main.Visible = false; MiniIcon.Visible = true 
end)

MiniIcon.MouseButton1Click:Connect(function()
	Main.Visible = true; MiniIcon.Visible = false
end)
