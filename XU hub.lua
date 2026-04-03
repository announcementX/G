local ScriptConfig = {
	-- // 🔹 通用功能栏目
	General = {
		{ Name = "自动刷取模块", Url = "https://raw.githubusercontent.com/example/autofarm/main.lua" },
		{ Name = "透视辅助开关", Url = "https://raw.githubusercontent.com/example/esp/main.lua" },
		{ Name = "速度强化器", Url = "https://raw.githubusercontent.com/example/speed/main.lua" },
		{ Name = "飞行", Url = "https://raw.githubusercontent.com/announcementX/G/main/XU%20hub.lua" },
	},
	-- // 🔹 自然灾害栏目
	NaturalDisaster = {
		{ Name = "灾害免疫护盾", Url = "https://raw.githubusercontent.com/example/disaster/shield.lua" },
		{ Name = "天气控制终端", Url = "https://raw.githubusercontent.com/example/weather/control.lua" },
		{ Name = "安全区传送", Url = "https://raw.githubusercontent.com/example/disaster/tp_safe.lua" },
	},
	-- // 🔹 死铁轨栏目
	DeadRails = {
		{ Name = "轨道瞬移器", Url = "https://raw.githubusercontent.com/example/rails/teleport.lua" },
		{ Name = "无限燃料模块", Url = "https://raw.githubusercontent.com/example/rails/fuel.lua" },
		{ Name = "车厢防脱轨", Url = "https://raw.githubusercontent.com/example/rails/derail_prevent.lua" },
		{ Name = "轨道加速引擎", Url = "https://raw.githubusercontent.com/example/rails/accelerate.lua" },
	}
}

-- // ========================================================================
-- // ⚙️ 02 **核心服务与主题配置**
-- // ========================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Config = {
	Theme = {
		Primary = Color3.fromRGB(18, 22, 45),
		Secondary = Color3.fromRGB(28, 34, 65),
		Accent = Color3.fromRGB(100, 180, 255),
		Text = Color3.fromRGB(220, 230, 255),
		TextDim = Color3.fromRGB(140, 160, 200),
		Glow = Color3.fromRGB(120, 200, 255),
		StatusReady = Color3.fromRGB(180, 190, 210),		StatusSuccess = Color3.fromRGB(80, 200, 120),
		StatusError = Color3.fromRGB(220, 80, 80),
	},
	UI = {
		Corner = 12,
		Stroke = 2,
		MinimizedIcon = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150",
		AnimSpeed = 0.3,
	},
	Info = {
		Author = "HaoChen",
		QQ = "1626844714",
		Version = "3.0.0 | LimeHub Standard",
	},
}

-- // ========================================================================
-- // 🎨 03 **GUI 初始化与星空背景**
-- // ========================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- // 动态星空粒子生成
local function CreateStarfield(parent: Frame)
	for i = 1, 60 do
		local star = Instance.new("Frame")
		star.Name = "Star_"..i
		star.BackgroundColor3 = Config.Theme.Accent
		star.BackgroundTransparency = 0.5 + math.random(0,3)/10
		star.BorderSizePixel = 0
		star.Shape = Enum.CircleType.Circle
		star.Size = UDim2.fromOffset(math.random(2,4), math.random(2,4))
		star.Position = UDim2.fromScale(math.random(), math.random())
		star.Parent = parent
		task.spawn(function()
			while star:IsDescendantOf(parent) do
				TweenService:Create(star, TweenInfo.new(math.random(6,12)/10, Enum.EasingStyle.Linear), 
					{BackgroundTransparency = 0.3 + math.random(0,5)/10}):Play()
				task.wait(math.random(4,10)/10)
			end
		end)
	end
end

-- // 主窗口
local MainWindow = Instance.new("TextFrame")
MainWindow.Name = "StarlightHub"MainWindow.Size = UDim2.fromOffset(740, 500)
MainWindow.Position = UDim2.fromScale(0.5, 0.5)
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.BackgroundColor3 = Config.Theme.Primary
MainWindow.BorderColor3 = Config.Theme.Accent
MainWindow.BorderSizePixel = Config.UI.Stroke
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.Visible = true
MainWindow.Parent = ScreenGui
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, Config.UI.Corner)

-- // 窗口光晕
local UIGlow = Instance.new("ImageLabel")
UIGlow.BackgroundTransparency = 1
UIGlow.Image = "rbxassetid://50288871"
UIGlow.ImageColor3 = Config.Theme.Glow
UIGlow.ImageTransparency = 0.85
UIGlow.ScaleType = Enum.ScaleType.Slice
UIGlow.SliceCenter = Rect.new(24,24,276,276)
UIGlow.Size = UDim2.fromScale(1.15, 1.15)
UIGlow.Position = UDim2.fromScale(-0.075, -0.075)
UIGlow.ZIndex = 0
UIGlow.Parent = MainWindow

CreateStarfield(MainWindow)

-- // ========================================================================
-- // 📑 04 **侧边栏与导航系统**
-- // ========================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(210, 500)
Sidebar.BackgroundColor3 = Config.Theme.Secondary
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, Config.UI.Corner)

local NavContainer = Instance.new("ScrollingFrame")
NavContainer.Name = "NavContainer"
NavContainer.Size = UDim2.new(1, 0, 1, -60)
NavContainer.Position = UDim2.new(0, 0, 0, 60)
NavContainer.BackgroundTransparency = 1
NavContainer.ScrollBarThickness = 4
NavContainer.ScrollBarImageColor3 = Config.Theme.Accent
NavContainer.Parent = Sidebar

local function CreateNavButton(title: string, icon: string?, order: number): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = title	btn.Size = UDim2.new(1, -16, 0, 42)
	btn.Position = UDim2.new(0, 8, 0, 10 + (order-1)*52)
	btn.BackgroundColor3 = Color3.fromRGB(35,42,75)
	btn.BorderColor3 = Config.Theme.Accent
	btn.BorderSizePixel = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = NavContainer
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	
	if icon then
		local iconLbl = Instance.new("ImageLabel")
		iconLbl.Size = UDim2.fromOffset(20,20)
		iconLbl.Position = UDim2.new(0,12,0.5,-10)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Image = icon
		iconLbl.Parent = btn
	end
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -44, 1, 0)
	label.Position = UDim2.new(0, 42, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.Text = title
	label.TextColor3 = Config.Theme.Text
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn
	
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45,55,95)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35,42,75)}):Play() end)
	return btn
end

local navButtons = {
	CreateNavButton("👤 我的信息", "rbxassetid://72322540419714", 1),
	CreateNavButton("⚙️ 通用功能", "rbxassetid://3926305904", 2),
	CreateNavButton("🌪️ 自然灾害", "rbxassetid://1121848078", 3),
	CreateNavButton("🛤️ 死铁轨", "rbxassetid://9145632901", 4),
}

-- // ========================================================================
-- // 📄 05 **内容区域与信息面板**
-- // ========================================================================
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -220, 1, -10)
ContentArea.Position = UDim2.new(0, 220, 0, 10)
ContentArea.BackgroundTransparency = 1ContentArea.Parent = MainWindow

local Pages = Instance.new("Frame")
Pages.Size = UDim2.fromScale(1,1)
Pages.BackgroundTransparency = 1
Pages.Parent = ContentArea

-- // 页面：我的信息
local PageMyInfo = Instance.new("Frame")
PageMyInfo.Name = "Page_MyInfo"
PageMyInfo.Size = UDim2.fromScale(1,1)
PageMyInfo.BackgroundTransparency = 1
PageMyInfo.Visible = true
PageMyInfo.Parent = Pages

local AuthorCard = Instance.new("Frame")
AuthorCard.Size = UDim2.new(1, -20, 0, 100)
AuthorCard.Position = UDim2.new(0,10,0,10)
AuthorCard.BackgroundColor3 = Color3.fromRGB(30,38,70)
AuthorCard.BorderSizePixel = 1
AuthorCard.BorderColor3 = Config.Theme.Accent
AuthorCard.Parent = PageMyInfo
Instance.new("UICorner", AuthorCard).CornerRadius = UDim.new(0,10)

local authorTitle = Instance.new("TextLabel")
authorTitle.Size = UDim2.new(1,0,0,25)
authorTitle.Position = UDim2.new(0,12,0,8)
authorTitle.BackgroundTransparency = 1
authorTitle.Font = Enum.Font.GothamBold
authorTitle.Text = "✦ 作者信息"
authorTitle.TextColor3 = Config.Theme.Accent
authorTitle.TextSize = 14
authorTitle.TextXAlignment = Enum.TextXAlignment.Left
authorTitle.Parent = AuthorCard

local authorDetail = Instance.new("TextLabel")
authorDetail.Size = UDim2.new(1,0,0,60)
authorDetail.Position = UDim2.new(0,12,0,35)
authorDetail.BackgroundTransparency = 1
authorDetail.Font = Enum.Font.Gotham
authorDetail.Text = "作者: **"..Config.Info.Author.."**\nQQ号: **"..Config.Info.QQ.."**\n版本: **"..Config.Info.Version.."**"
authorDetail.TextColor3 = Config.Theme.Text
authorDetail.TextSize = 12
authorDetail.RichText = true
authorDetail.TextWrapped = true
authorDetail.TextYAlignment = Enum.TextYAlignment.Top
authorDetail.Parent = AuthorCard

-- // 玩家信息卡片
local PlayerInfoFrame = Instance.new("Frame")PlayerInfoFrame.Size = UDim2.new(0.48, -10, 0, 180)
PlayerInfoFrame.Position = UDim2.new(0,10,0,120)
PlayerInfoFrame.BackgroundColor3 = Color3.fromRGB(30,38,70)
PlayerInfoFrame.BorderSizePixel = 1
PlayerInfoFrame.BorderColor3 = Config.Theme.Accent
PlayerInfoFrame.Parent = PageMyInfo
Instance.new("UICorner", PlayerInfoFrame).CornerRadius = UDim.new(0,10)

-- // 服务器信息卡片
local ServerInfoFrame = PlayerInfoFrame:Clone()
ServerInfoFrame.Position = UDim2.new(0.52, 0, 0, 120)
ServerInfoFrame.Parent = PageMyInfo

local function SetupInfoFrame(frame: Frame, title: string, getData: () -> {string})
	local lblTitle = Instance.new("TextLabel")
	lblTitle.Size = UDim2.new(1,0,0,25)
	lblTitle.Position = UDim2.new(0,12,0,8)
	lblTitle.BackgroundTransparency = 1
	lblTitle.Font = Enum.Font.GothamBold
	lblTitle.Text = "✦ "..title
	lblTitle.TextColor3 = Config.Theme.Accent
	lblTitle.TextSize = 14
	lblTitle.TextXAlignment = Enum.TextXAlignment.Left
	lblTitle.Parent = frame
	
	local lblContent = Instance.new("TextLabel")
	lblContent.Size = UDim2.new(1,-24,1,-40)
	lblContent.Position = UDim2.new(0,12,0,35)
	lblContent.BackgroundTransparency = 1
	lblContent.Font = Enum.Font.Gotham
	lblContent.TextColor3 = Config.Theme.Text
	lblContent.TextSize = 11
	lblContent.RichText = true
	lblContent.TextWrapped = true
	lblContent.TextYAlignment = Enum.TextYAlignment.Top
	lblContent.Parent = frame
	
	task.spawn(function()
		while frame:IsDescendantOf(ScreenGui) do
			lblContent.Text = table.concat(getData(), "\n")
			task.wait(2)
		end
	end)
end

SetupInfoFrame(PlayerInfoFrame, "玩家信息", function():{string}
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	return {		"名字: **"..LocalPlayer.Name.."**",
		"显示名: **"..LocalPlayer.DisplayName.."**",
		"用户ID: **"..LocalPlayer.UserId.."**",
		"队伍: **"..(LocalPlayer.Team and LocalPlayer.Team.Name or "无").."**",
		"生命值: **"..(hum and math.floor(hum.Health).." / "..math.floor(hum.MaxHealth) or "N/A").."**",
		"坐标: **"..(root and string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z) or "N/A").."**",
		"延迟: **"..math.floor(LocalPlayer:GetPing()).." ms**",
		"同步延迟: **"..math.floor(LocalPlayer:GetReplicationLag()*1000).." ms**",
	}
end)

SetupInfoFrame(ServerInfoFrame, "服务器信息", function():{string}
	return {
		"游戏ID: **"..game.PlaceId.."**",
		"服务器ID: **"..game.JobId:sub(1,8).."**",
		"服务器时间: **"..os.date("%H:%M:%S", os.time()).."**",
		"在线玩家: **"..#Players:GetPlayers().."/"..Players.MaxPlayers.."**",
		"地图状态: **"..(game.Workspace:FindFirstChild("Map") and "已加载" or "加载中").."**",
		"帧率: **"..math.floor(1/RunService.RenderStepped:Wait()).." FPS**",
		"物理引擎: **"..(game.Workspace.PhysicsEnvironmentalHydrationEnabled and "增强版" or "标准版").."**",
		"流式传输: **"..(LocalPlayer:IsStreamingEnabled and "已开启" or "已关闭").."**",
	}
end)

-- // ========================================================================
-- // 🔌 06 **外部脚本加载引擎 (LimeHub 标准流)**
-- // ========================================================================
local function CreateConfirmDialog(title: string, message: string, callback: (boolean) -> ()): Frame
	local overlay = Instance.new("TextFrame")
	overlay.Size = UDim2.fromScale(1,1)
	overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
	overlay.BackgroundTransparency = 0.65
	overlay.Visible = false
	overlay.ZIndex = 20
	overlay.Parent = ScreenGui
	
	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.fromOffset(380, 220)
	dialog.Position = UDim2.fromScale(0.5,0.5)
	dialog.AnchorPoint = Vector2.new(0.5,0.5)
	dialog.BackgroundColor3 = Config.Theme.Secondary
	dialog.BorderSizePixel = 2
	dialog.BorderColor3 = Config.Theme.Accent
	dialog.ZIndex = 21
	dialog.Parent = overlay
	Instance.new("UICorner", dialog).CornerRadius = UDim.new(0,12)
	
	local lblTitle = Instance.new("TextLabel")
	lblTitle.Size = UDim2.new(1,0,0,40)
	lblTitle.Position = UDim2.new(0,0,0,10)	lblTitle.BackgroundTransparency = 1
	lblTitle.Font = Enum.Font.GothamBold
	lblTitle.Text = title
	lblTitle.TextColor3 = Config.Theme.Text
	lblTitle.TextSize = 15
	lblTitle.Parent = dialog
	
	local lblMsg = Instance.new("TextLabel")
	lblMsg.Size = UDim2.new(1,-40,0,100)
	lblMsg.Position = UDim2.new(0,20,0,50)
	lblMsg.BackgroundTransparency = 1
	lblMsg.Font = Enum.Font.Gotham
	lblMsg.Text = message
	lblMsg.TextColor3 = Config.Theme.TextDim
	lblMsg.TextSize = 12
	lblMsg.TextWrapped = true
	lblMsg.TextYAlignment = Enum.TextYAlignment.Top
	lblMsg.Parent = dialog
	
	local btnGroup = Instance.new("Frame")
	btnGroup.Size = UDim2.new(1,0,0,40)
	btnGroup.Position = UDim2.new(0,0,1,-50)
	btnGroup.BackgroundTransparency = 1
	btnGroup.Parent = dialog
	
	local function makeBtn(text: string, color: Color3, isConfirm: boolean)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0,100,0,32)
		btn.Position = UDim2.new(0, isConfirm and 210 or 70, 0, 4)
		btn.BackgroundColor3 = color
		btn.BorderSizePixel = 0
		btn.Text = text
		btn.Font = Enum.Font.GothamSemibold
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.TextSize = 13
		btn.Parent = btnGroup
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
		btn.MouseButton1Click:Connect(function()
			overlay:Destroy()
			callback(isConfirm)
		end)
	end
	makeBtn("取消", Color3.fromRGB(80,90,120), false)
	makeBtn("确认执行", Config.Theme.Accent, true)
	return overlay
end

-- // 脚本按钮生成器
local function CreateScriptButton(parent: Frame, name: string, url: string, index: number): TextButton
	local btn = Instance.new("TextButton")	btn.Size = UDim2.new(1, -30, 0, 48)
	btn.Position = UDim2.new(0, 15, 0, 15 + (index-1)*58)
	btn.BackgroundColor3 = Color3.fromRGB(40,50,90)
	btn.BorderSizePixel = 1
	btn.BorderColor3 = Config.Theme.Accent
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
	
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 15, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.Text = "► "..name
	lbl.TextColor3 = Config.Theme.Text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn
	
	-- // 悬停高亮
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,65,110)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,50,90)}):Play() end)
	
	-- // 点击执行逻辑
	btn.MouseButton1Click:Connect(function()
		local confirmDlg = CreateConfirmDialog("确认执行外部脚本", 
			"即将加载并运行以下脚本：\n\n【"..name.."】\n\n直链地址: "..url.."\n\n是否确认执行？",
			function(confirmed: boolean)
				if confirmed then
					task.spawn(function()
						-- // LimeHub 标准外部脚本加载流程
						local success, result = pcall(function()
							local fn = loadstring(game:HttpGet(url))
							if fn then fn() else error("脚本返回空内容或格式无效") end
						end)
						if success then
							print("★ [星光] ✅ 脚本已执行 ["..name.."]")
						else
							warn("★ [星光] ❌ 执行失败 ["..name.."]: "..tostring(result))
						end
					end)
				end
			end
		)
		confirmDlg.Visible = true
	end)
	return btn
end
-- // ========================================================================
-- // 🗂️ 07 **页面渲染器 (配置驱动)**
-- // ========================================================================
local function BuildPage(category: string, configTable: { {Name: string, Url: string} }): ScrollingFrame
	local page = Instance.new("Frame")
	page.Name = "Page_"..category
	page.Size = UDim2.fromScale(1,1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = Pages
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1,0,1,-20)
	scroll.Position = UDim2.new(0,0,0,20)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Config.Theme.Accent
	scroll.CanvasSize = UDim2.new(0,0,0,#configTable * 68 + 40)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = page
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 0)
	padding.Parent = scroll
	
	for i, entry in ipairs(configTable) do
		if entry.Name ~= "" and entry.Url ~= "" then
			CreateScriptButton(scroll, entry.Name, entry.Url, i)
		end
	end
	
	return scroll
end

-- // 自动构建三个脚本栏目
BuildPage("General", ScriptConfig.General)
BuildPage("NaturalDisaster", ScriptConfig.NaturalDisaster)
BuildPage("DeadRails", ScriptConfig.DeadRails)

-- // ========================================================================
-- // 🎮 08 **窗口控制与页面切换**-- // ========================================================================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = Config.Theme.Secondary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainWindow
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, Config.UI.Corner, 0, Config.UI.Corner)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-100,1,0)
titleLabel.Position = UDim2.new(0,12,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "✦ 星光枢纽"
titleLabel.TextColor3 = Config.Theme.Accent
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TitleBar

local function makeControlBtn(icon: string, color: Color3, callback: () -> ())
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(32,32)
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = TitleBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	local iconLbl = Instance.new("ImageLabel")
	iconLbl.Size = UDim2.fromOffset(16,16)
	iconLbl.Position = UDim2.fromScale(0.5,0.5)
	iconLbl.AnchorPoint = Vector2.new(0.5,0.5)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Image = icon
	iconLbl.Parent = btn
	btn.MouseButton1Click:Connect(callback)
end

-- // 最小化图标 (带圆角正方形)
local minimizedBtn = Instance.new("ImageButton")
minimizedBtn.Size = UDim2.fromOffset(50,50)
minimizedBtn.Position = UDim2.fromScale(0.5,0.5)
minimizedBtn.AnchorPoint = Vector2.new(0.5,0.5)
minimizedBtn.BackgroundColor3 = Config.Theme.Primary
minimizedBtn.BorderSizePixel = 2
minimizedBtn.BorderColor3 = Config.Theme.Accent
minimizedBtn.Image = Config.UI.MinimizedIcon
minimizedBtn.Visible = false
minimizedBtn.ZIndex = 50minimizedBtn.Parent = ScreenGui
Instance.new("UICorner", minimizedBtn).CornerRadius = UDim.new(0,14)

minimizedBtn.MouseButton1Click:Connect(function()
	TweenService:Create(MainWindow, TweenInfo.new(Config.UI.AnimSpeed), {
		Size = UDim2.fromOffset(740,500),
		Position = UDim2.fromScale(0.5,0.5),
		BackgroundTransparency = 0
	}):Play()
	MainWindow.Visible = true
	minimizedBtn.Visible = false
end)

makeControlBtn("rbxassetid://3926307971", Color3.fromRGB(60,70,100), function()
	MainWindow.Visible = false
	minimizedBtn.Visible = true
	TweenService:Create(minimizedBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(60,60)}):Play()
	task.defer(function() TweenService:Create(minimizedBtn, TweenInfo.new(0.3), {Size = UDim2.fromOffset(50,50)}):Play() end)
end)

makeControlBtn("rbxassetid://3926305904", Color3.fromRGB(180,60,60), function()
	TweenService:Create(MainWindow, TweenInfo.new(0.3), {Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1}):Play()
	task.wait(0.3)
	ScreenGui:Destroy()
end)

-- // 页面切换逻辑
local pagesList = {PageMyInfo, Pages.Page_General, Pages.Page_NaturalDisaster, Pages.Page_DeadRails}
for i, btn in ipairs(navButtons) do
	btn.MouseButton1Click:Connect(function()
		for _,b in ipairs(navButtons) do b.BackgroundColor3 = Color3.fromRGB(35,42,75) end
		btn.BackgroundColor3 = Color3.fromRGB(50,65,110)
		for _,p in ipairs(pagesList) do p.Visible = false end
		pagesList[i].Visible = true
		pagesList[i].Position = UDim2.fromScale(1.05, 0)
		TweenService:Create(pagesList[i], TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(0,0)}):Play()
	end)
end
navButtons[1].BackgroundColor3 = Color3.fromRGB(50,65,110)

-- // 🚀 初始化完成
print("★ [星光枢纽] 已加载 | 作者: HaoChen | QQ: 1626844714")
print("★ [开发指引] 请修改顶部 ScriptConfig 表格中的 Url 字段以注入您的脚本")