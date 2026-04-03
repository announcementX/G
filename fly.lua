local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local chr = LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
local speeds = 1
local nowe = false
local tpwalking = false

-- 通知
StarterGui:SetCore("SendNotification", {
	Title = "✦ XU飞行系统";
	Text = "星空主题UI已加载 | 点击面板可拖动";
	Icon = "rbxassetid://72322540419714";
	Duration = 5;
})

-- ================= UI 创建 =================
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

-- 主容器
main.Name = "main"
main.Parent = LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false
main.IgnoreGuiInset = true

-- 主面板 (星空磨砂玻璃)
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 35)
Frame.BackgroundTransparency = 0.15Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -130, 0.4, 0)
Frame.Size = UDim2.new(0, 260, 0, 170)
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true

-- 星空渐变背景
local frameGrad = Instance.new("UIGradient")
frameGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 30)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 18, 55)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 25))
})
frameGrad.Rotation = 35
frameGrad.Parent = Frame

-- 圆角
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = Frame

-- 发光边框
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(90, 140, 255)
frameStroke.Transparency = 0.4
frameStroke.Thickness = 1.5
frameStroke.Parent = Frame

-- 标题
TextLabel.Name = "Title"
TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 0, 0, 0)
TextLabel.Size = UDim2.new(1, 0, 0, 40)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "✦ XU 飞行控制 ✦"
TextLabel.TextColor3 = Color3.fromRGB(180, 210, 255)
TextLabel.TextSize = 18
TextLabel.TextScaled = true
TextLabel.TextStrokeTransparency = 0.3
TextLabel.TextStrokeColor3 = Color3.fromRGB(60, 100, 255)

-- 通用按钮样式函数
local function styleButton(btn, bg, txt, stroke, gradStart, gradEnd)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextColor3 = txt
	btn.TextSize = 14	btn.AutoButtonColor = true
	btn.BackgroundColor3 = bg
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	local strokeObj = Instance.new("UIStroke")
	strokeObj.Color = stroke
	strokeObj.Transparency = 0.5
	strokeObj.Thickness = 1
	strokeObj.Parent = btn
	
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(gradStart, gradEnd)
	grad.Parent = btn
end

-- 上
up.Name = "上"
up.Parent = Frame
up.Position = UDim2.new(0.05, 0, 0.28, 0)
up.Size = UDim2.new(0, 45, 0, 32)
up.Text = "↑ 上"
styleButton(up, Color3.fromRGB(25, 35, 70), Color3.fromRGB(200, 230, 255), Color3.fromRGB(100, 150, 255), Color3.fromRGB(40, 60, 120), Color3.fromRGB(15, 25, 50))

-- 下
down.Name = "下"
down.Parent = Frame
down.Position = UDim2.new(0.05, 0, 0.52, 0)
down.Size = UDim2.new(0, 45, 0, 32)
down.Text = "↓ 下"
styleButton(down, Color3.fromRGB(25, 35, 70), Color3.fromRGB(200, 230, 255), Color3.fromRGB(100, 150, 255), Color3.fromRGB(40, 60, 120), Color3.fromRGB(15, 25, 50))

-- 飞/关
onof.Name = "onof"
onof.Parent = Frame
onof.Position = UDim2.new(0.32, 0, 0.28, 0)
onof.Size = UDim2.new(0, 65, 0, 32)
onof.Text = "启动飞行"
onof.Font = Enum.Font.GothamBold
styleButton(onof, Color3.fromRGB(30, 50, 100), Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 180, 255), Color3.fromRGB(50, 80, 180), Color3.fromRGB(20, 35, 80))

-- 加速
plus.Name = "plus"
plus.Parent = Frame
plus.Position = UDim2.new(0.32, 0, 0.52, 0)
plus.Size = UDim2.new(0, 50, 0, 32)
plus.Text = "加速"
styleButton(plus, Color3.fromRGB(20, 45, 45), Color3.fromRGB(150, 255, 200), Color3.fromRGB(100, 200, 150), Color3.fromRGB(30, 100, 90), Color3.fromRGB(10, 40, 40))
-- 速度显示
speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
speed.BackgroundTransparency = 0.2
speed.BorderSizePixel = 0
speed.Position = UDim2.new(0.54, 0, 0.52, 0)
speed.Size = UDim2.new(0, 45, 0, 32)
speed.Font = Enum.Font.GothamBold
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(255, 220, 100)
speed.TextSize = 16
speed.TextScaled = true
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speed
local speedStroke = Instance.new("UIStroke")
speedStroke.Color = Color3.fromRGB(255, 180, 80)
speedStroke.Transparency = 0.5
speedStroke.Thickness = 1
speedStroke.Parent = speed
local speedGrad = Instance.new("UIGradient")
speedGrad.Color = ColorSequence.new(Color3.fromRGB(40, 35, 20), Color3.fromRGB(15, 15, 10))
speedGrad.Parent = speed

-- 减速
mine.Name = "mine"
mine.Parent = Frame
mine.Position = UDim2.new(0.7, 0, 0.52, 0)
mine.Size = UDim2.new(0, 50, 0, 32)
mine.Text = "减速"
styleButton(mine, Color3.fromRGB(50, 25, 25), Color3.fromRGB(255, 180, 180), Color3.fromRGB(255, 100, 100), Color3.fromRGB(100, 40, 40), Color3.fromRGB(40, 15, 15))

-- 关闭
closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
closebutton.BackgroundTransparency = 0.2
closebutton.BorderSizePixel = 0
closebutton.Position = UDim2.new(0.88, 0, 0.05, 0)
closebutton.Size = UDim2.new(0, 28, 0, 28)
closebutton.Font = Enum.Font.GothamBold
closebutton.Text = "✕"
closebutton.TextColor3 = Color3.fromRGB(255, 220, 220)
closebutton.TextSize = 16
closebutton.AutoButtonColor = true
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closebuttonlocal closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(255, 100, 100)
closeStroke.Transparency = 0.5
closeStroke.Thickness = 1
closeStroke.Parent = closebutton

-- 收起
mini.Name = "minimize"
mini.Parent = Frame
mini.Position = UDim2.new(0.32, 0, 0.76, 0)
mini.Size = UDim2.new(0, 65, 0, 32)
mini.Text = "收起"
styleButton(mini, Color3.fromRGB(30, 30, 60), Color3.fromRGB(200, 200, 255), Color3.fromRGB(120, 120, 200), Color3.fromRGB(40, 40, 80), Color3.fromRGB(15, 15, 30))

-- 展开
mini2.Name = "minimize2"
mini2.Parent = Frame
mini2.Position = UDim2.new(0.32, 0, 0.76, 0)
mini2.Size = UDim2.new(0, 65, 0, 32)
mini2.Text = "展开"
mini2.Visible = false
styleButton(mini2, Color3.fromRGB(30, 30, 60), Color3.fromRGB(200, 200, 255), Color3.fromRGB(120, 120, 200), Color3.fromRGB(40, 40, 80), Color3.fromRGB(15, 15, 30))

-- 生成背景星点
for i = 1, 18 do
	local star = Instance.new("Frame")
	star.Name = "Star"
	star.Parent = Frame
	star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	star.BackgroundTransparency = 0.7
	star.BorderSizePixel = 0
	star.Position = UDim2.new(math.random(0, 99)/100, 0, math.random(0, 99)/100, 0)
	star.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
	star.ZIndex = 0
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(1, 0)
	sc.Parent = star
end

-- ================= 逻辑绑定 =================
onof.MouseButton1Down:Connect(function()
	if nowe == true then
		nowe = false
		tpwalking = false
		local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then
			for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
				h:SetStateEnabled(state, true)
			end
			h:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)			h.PlatformStand = false
		end
		LocalPlayer.Character.Animate.Disabled = false
		onof.Text = "启动飞行"
	else 
		nowe = true
		onof.Text = "关闭飞行"
		
		for i = 1, speeds do
			spawn(function()
				local hb = RunService.Heartbeat
				tpwalking = true
				local chr = LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
		LocalPlayer.Character.Animate.Disabled = true
		local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if h then
			for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
				h:SetStateEnabled(state, false)
			end
			h:ChangeState(Enum.HumanoidStateType.Swimming)
			h.PlatformStand = true
		end
	end
end)

local tis
up.MouseButton1Down:Connect(function()
	tis = up.MouseEnter:Connect(function()
		while tis do
			wait()
			if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
			end
		end
	end)
end)
up.MouseLeave:Connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)
local dis
down.MouseButton1Down:Connect(function()
	dis = down.MouseEnter:Connect(function()
		while dis do
			wait()
			if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
			end
		end
	end)
end)
down.MouseLeave:Connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	local h = char:FindFirstChildOfClass("Humanoid")
	if h then
		h.PlatformStand = false
		nowe = false
		tpwalking = false
		char.Animate.Disabled = false
		onof.Text = "启动飞行"
	end
end)

plus.MouseButton1Down:Connect(function()
	speeds = math.min(speeds + 1, 10)
	speed.Text = tostring(speeds)
	if nowe == true then
		tpwalking = false
		for i = 1, speeds do
			spawn(function()
				local hb = RunService.Heartbeat
				tpwalking = true
				local chr = LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
	endend)

mine.MouseButton1Down:Connect(function()
	if speeds == 1 then
		speed.Text = 'flyno1'
		wait(1)
		speed.Text = tostring(speeds)
	else
		speeds = math.max(speeds - 1, 1)
		speed.Text = tostring(speeds)
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()
					local hb = RunService.Heartbeat
					tpwalking = true
					local chr = LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end
				end)
			end
		end
	end
end)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	Frame.BackgroundTransparency = 0.8
	frameStroke.Transparency = 0.9
	closebutton.Position = UDim2.new(0.88, 0, 0.05, 0)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	Frame.BackgroundTransparency = 0.15
	frameStroke.Transparency = 0.4
	closebutton.Position = UDim2.new(0.88, 0, 0.05, 0)
end)