local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
-- 新增：星空背景图层
local StarBg = Instance.new("ImageLabel")
-- 新增：背景渐变
local FrameGradient = Instance.new("UIGradient")
-- 新增：圆角
local FrameCorner = Instance.new("UICorner")

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

-- =============================================
-- 基础设置
-- =============================================
main.Name = "main"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- =============================================
-- 主面板 (全息星空风格)
-- =============================================
Frame.Parent = main
-- 深蓝黑色背景，带一点透明度模拟全息
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 260, 0, 130) -- 稍微放大布局
Frame.ClipsDescendants = true -- 确保内容不超出圆角

-- 主面板圆角
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

-- 主面板渐变 (深蓝 -> 深紫)
FrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 10, 50))
}
FrameGradient.Rotation = 45
FrameGradient.Parent = Frame

-- 星空背景贴图 (使用Roblox官方星空纹理)
StarBg.Name = "StarBg"
StarBg.Parent = Frame
StarBg.BackgroundTransparency = 1
StarBg.Position = UDim2.new(0, 0, 0, 0)
StarBg.Size = UDim2.new(1, 0, 1, 0)
StarBg.Image = "rbxassetid://9753760451" -- 这是一个Roblox的星空/粒子纹理
StarBg.ImageColor3 = Color3.fromRGB(200, 200, 255) -- 给星星一点蓝光
StarBg.ImageTransparency = 0.6 -- 隐隐约约的星星
StarBg.ScaleType = Enum.ScaleType.Tile -- 平铺
StarBg.TileSize = UDim2.new(0, 128, 0, 128)
StarBg.ZIndex = 0 -- 放在最底层

Frame.Active = true -- main = gui
Frame.Draggable = true

-- =============================================
-- 内部元件美化函数 (霓虹科技感)
-- =============================================
local function styleTechnologyButton(btn, neonColor, isRound)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold -- 现代扁平字体
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.ZIndex = 2
	
	-- 文字发光效果
	btn.TextStrokeColor3 = neonColor
	btn.TextStrokeTransparency = 0.5
	
	-- 按钮自身的渐变 (深色底 -> 霓虹边)
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)), -- 深色基底
		ColorSequenceKeypoint.new(1, neonColor) -- 霓虹色
	}
	grad.Rotation = -90 -- 从下往上渐变，模拟着陆灯
	grad.Parent = btn
	
	-- 按钮透明度 (让背景星空透出来)
	btn.BackgroundTransparency = 0.2
	
	-- 按钮圆角
	local corner = Instance.new("UICorner")
	if isRound then
		corner.CornerRadius = UDim.new(1, 0) -- 圆形
	else
		corner.CornerRadius = UDim.new(0, 4) -- 微圆角
	end
	corner.Parent = btn
end

-- =============================================
-- 标题栏
-- =============================================
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BackgroundTransparency = 1 -- 透明背景
TextLabel.Position = UDim2.new(0, 10, 0, 5)
TextLabel.Size = UDim2.new(0, 120, 0, 25)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "YG全息飞行"
TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255) -- 亮青色
TextLabel.TextSize = 16
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.ZIndex = 2
-- 标题发光
TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 150, 150)
TextLabel.TextStrokeTransparency = 0.2

-- =============================================
-- 按钮与控件排版 (重新规划，更帅气)
-- =============================================

-- 左侧：上下移动 (霓虹蓝)
local blueNeon = Color3.fromRGB(0, 170, 255)
up.Name = "上"
up.Parent = Frame
up.Position = UDim2.new(0.05, 0, 0.35, 0)
up.Size = UDim2.new(0, 50, 0, 30)
up.Text = "▲ 上升"
styleTechnologyButton(up, blueNeon, false)

down.Name = "下"
down.Parent = Frame
down.Position = UDim2.new(0.05, 0, 0.65, 0)
down.Size = UDim2.new(0, 50, 0, 30)
down.Text = "▼ 下降"
styleTechnologyButton(down, blueNeon, false)

-- 中间：速度控制 (霓虹紫)
local purpleNeon = Color3.fromRGB(170, 0, 255)
mine.Name = "mine"
mine.Parent = Frame
mine.Position = UDim2.new(0.3, 0, 0.35, 0)
mine.Size = UDim2.new(0, 50, 0, 30)
mine.Text = "➖ 减速"
styleTechnologyButton(mine, purpleNeon, false)

plus.Name = "plus"
plus.Parent = Frame
plus.Position = UDim2.new(0.3, 0, 0.65, 0)
plus.Size = UDim2.new(0, 50, 0, 30)
plus.Text = "➕ 加速"
styleTechnologyButton(plus, purpleNeon, false)

-- 速度显示 (模拟全息投影数字)
speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
speed.BackgroundTransparency = 1 -- 透明
speed.Position = UDim2.new(0.55, 0, 0.4, 0)
speed.Size = UDim2.new(0, 40, 0, 45)
speed.Font = Enum.Font.Code -- 像素/代码字体，更有科技感
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(255, 215, 0) -- 金色数字
speed.TextScaled = true
speed.ZIndex = 2
-- 数字发光
speed.TextStrokeColor3 = Color3.fromRGB(150, 100, 0)
speed.TextStrokeTransparency = 0.3

-- 右侧：飞行开关 (霓虹绿/红)
local greenNeon = Color3.fromRGB(0, 255, 120)
onof.Name = "onof"
onof.Parent = Frame
onof.Position = UDim2.new(0.75, 0, 0.35, 0)
onof.Size = UDim2.new(0, 50, 0, 55) -- 竖长按钮
onof.Text = "运 行\n中"
onof.TextWrapped = true -- 文字换行
styleTechnologyButton(onof, greenNeon, false)
-- 特别修改onof按钮的渐变方向，让它看起来更亮
local onofGrad = onof:FindFirstChild("UIGradient")
if onofGrad then onofGrad.Rotation = 45 end


-- =============================================
-- 功能按钮 (关闭与收起 - 全息简约风格)
-- =============================================
local function styleTopButton(btn, color)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	btn.BackgroundTransparency = 1 -- 默认透明
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = color
	btn.TextSize = 18
	btn.ZIndex = 3
	
	-- 悬停效果逻辑 (通过原生Lua模拟一点)
	btn.MouseEnter:Connect(function()
		btn.BackgroundTransparency = 0.8
		btn.BackgroundColor3 = color
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundTransparency = 1
	end)
end

closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.Position = UDim2.new(1, -30, 0, 5) -- 右上角
closebutton.Size = UDim2.new(0, 25, 0, 25)
closebutton.Text = "✕"
styleTopButton(closebutton, Color3.fromRGB(255, 50, 50))

mini.Name = "minimize"
mini.Parent = Frame
mini.Position = UDim2.new(1, -55, 0, 5) -- 关闭按钮左侧
mini.Size = UDim2.new(0, 25, 0, 25)
mini.Text = "—" -- 使用长横线
styleTopButton(mini, Color3.fromRGB(200, 200, 200))

-- 展开按钮 (最小化后显示在屏幕上的小横条)
mini2.Name = "minimize2"
mini2.Parent = main
mini2.BackgroundColor3 = Color3.fromRGB(15, 20, 40)
mini2.BackgroundTransparency = 0.3
mini2.BorderSizePixel = 0
mini2.Size = UDim2.new(0, 80, 0, 20)
mini2.Text = "展开辅助"
mini2.TextColor3 = Color3.fromRGB(0, 255, 255)
mini2.Font = Enum.Font.GothamBold
mini2.TextSize = 12
mini2.Position = Frame.Position -- 初始位置同主面板
mini2.Visible = false
local m2c = Instance.new("UICorner")
m2c.CornerRadius = UDim.new(0, 4)
m2c.Parent = mini2
local m2g = Instance.new("UIGradient") -- 展开按钮也加个渐变
m2g.Color = ColorSequence.new(Color3.fromRGB(15, 20, 40), Color3.fromRGB(0, 100, 100))
m2g.Parent = mini2


-- =========================================================================================
-- 逻辑部分 (保持原封不动，仅修正了mini2的可见性逻辑)
-- =========================================================================================

speeds = 1

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "YG全息飞行";
	Text = "星空系统已加载";
	Icon = "rbxthumb://type=Asset&id=123135436684871&w=150&h=150"})
Duration = 5;


onof.MouseButton1Down:connect(function()

	if nowe == true then
		nowe = false
		onof.Text = "已 停\n止"
		-- 动态修改按钮颜色逻辑
		local grad = onof:FindFirstChild("UIGradient")
		if grad then grad.Color = ColorSequence.new(Color3.fromRGB(20,20,30), Color3.fromRGB(255, 50, 50)) end -- 红色
		onof.TextStrokeColor3 = Color3.fromRGB(150, 0, 0)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true
		onof.Text = "运 行\n中"
		-- 动态修改按钮颜色逻辑
		local grad = onof:FindFirstChild("UIGradient")
		if grad then grad.Color = ColorSequence.new(Color3.fromRGB(20,20,30), Color3.fromRGB(0, 255, 120)) end -- 绿色
		onof.TextStrokeColor3 = Color3.fromRGB(0, 150, 0)

		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
		game.Players.LocalPlayer.Character.Animate.Disabled = true
		local Char = game.Players.LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end




	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then



		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			--	game.Players.LocalPlayer.Character.Animate.Disabled = true
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false




	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0


		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()

			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end

			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false



	end





end)

local tis

up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			wait()
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
	game.Players.LocalPlayer.Character.Animate.Disabled = false

end)


plus.MouseButton1Down:connect(function()
	speeds = speeds + 1
	speed.Text = speeds
	if nowe == true then


		tpwalking = false
		for i = 1, speeds do
			spawn(function()

				local hb = game:GetService("RunService").Heartbeat	


				tpwalking = true
				local chr = game.Players.LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end

			end)
		end
	end
end)
mine.MouseButton1Down:connect(function()
	if speeds == 1 then
		speed.Text = 'MIN' -- 修正了原脚本的 flyno1 为更简约的 MIN
		wait(1)
		speed.Text = speeds
	else
		speeds = speeds - 1
		speed.Text = speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()

					local hb = game:GetService("RunService").Heartbeat	


					tpwalking = true
					local chr = game.Players.LocalPlayer.Character
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
	-- 简约的最小化：隐藏面板，显示“展开”
	Frame.Visible = false
	mini2.Visible = true
	-- 确保mini2出现在Frame当前所在位置
	mini2.Position = Frame.Position
end)

mini2.MouseButton1Click:Connect(function()
	-- 简约的展开
	Frame.Visible = true
	mini2.Visible = false
end)
