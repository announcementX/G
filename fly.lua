local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local StarBg = Instance.new("ImageLabel")
local FrameGradient = Instance.new("UIGradient")
local FrameCorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

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

local TweenService = game:GetService("TweenService")

-- ==========================================
-- 1. 星空 UI 视觉框架搭建
-- ==========================================
main.Name = "XU_Space_Mod_Original"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 280, 0, 140)
Frame.ClipsDescendants = true

FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = Frame

-- 动态呼吸边框
UIStroke.Parent = Frame
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

spawn(function()
	local hue = 0
	while wait() do
		hue = hue + 0.005
		if hue > 1 then hue = 0 end
		UIStroke.Color = Color3.fromHSV(hue, 0.8, 1)
	end
end)

FrameGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 10, 25)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 50))
}
FrameGradient.Rotation = 45
FrameGradient.Parent = Frame

StarBg.Name = "StarBg"
StarBg.Parent = Frame
StarBg.BackgroundTransparency = 1
StarBg.Size = UDim2.new(1, 0, 1, 0)
StarBg.Image = "rbxassetid://9753760451"
StarBg.ImageColor3 = Color3.fromRGB(180, 200, 255)
StarBg.ImageTransparency = 0.5
StarBg.ScaleType = Enum.ScaleType.Tile
StarBg.TileSize = UDim2.new(0, 150, 0, 150)
StarBg.ZIndex = 0

Frame.Active = true
Frame.Draggable = true

-- 按钮样式与动效函数
local function styleTechBtn(btn, neonColor)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 14
	btn.ZIndex = 2
	btn.TextStrokeColor3 = neonColor
	btn.TextStrokeTransparency = 0.4
	btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	btn.BackgroundTransparency = 0.3
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
	-- 丝滑悬停动效
	local hoverTween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = neonColor, BackgroundTransparency = 0.5})
	local leaveTween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 40), BackgroundTransparency = 0.3})
	
	btn.MouseEnter:Connect(function() hoverTween:Play() end)
	btn.MouseLeave:Connect(function() leaveTween:Play() end)
end

-- ==========================================
-- 2. 界面元素布局
-- ==========================================
TextLabel.Parent = Frame
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 15, 0, 8)
TextLabel.Size = UDim2.new(0, 150, 0, 20)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "XU 飞行辅助"
TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TextLabel.TextSize = 16
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.ZIndex = 2
TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 200)
TextLabel.TextStrokeTransparency = 0.5

closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.BackgroundTransparency = 1
closebutton.Position = UDim2.new(1, -30, 0, 5)
closebutton.Size = UDim2.new(0, 25, 0, 25)
closebutton.Font = Enum.Font.GothamBold
closebutton.Text = "✕"
closebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
closebutton.TextSize = 18
closebutton.ZIndex = 3
local closeHover = TweenService:Create(closebutton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50), BackgroundTransparency = 0})
local closeLeave = TweenService:Create(closebutton, TweenInfo.new(0.2), {BackgroundTransparency = 1})
closebutton.MouseEnter:Connect(function() closeHover:Play() end)
closebutton.MouseLeave:Connect(function() closeLeave:Play() end)

mini.Name = "mini"
mini.Parent = Frame
mini.BackgroundTransparency = 1
mini.Position = UDim2.new(1, -55, 0, 5)
mini.Size = UDim2.new(0, 25, 0, 25)
mini.Font = Enum.Font.GothamBold
mini.Text = "—"
mini.TextColor3 = Color3.fromRGB(200, 200, 200)
mini.TextSize = 14
mini.ZIndex = 3
local miniHover = TweenService:Create(mini, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100), BackgroundTransparency = 0.5})
local miniLeave = TweenService:Create(mini, TweenInfo.new(0.2), {BackgroundTransparency = 1})
mini.MouseEnter:Connect(function() miniHover:Play() end)
mini.MouseLeave:Connect(function() miniLeave:Play() end)

up.Parent = Frame
up.Position = UDim2.new(0.05, 0, 0.35, 0)
up.Size = UDim2.new(0, 60, 0, 35)
up.Text = "上升"
styleTechBtn(up, Color3.fromRGB(0, 170, 255))

down.Parent = Frame
down.Position = UDim2.new(0.05, 0, 0.65, 0)
down.Size = UDim2.new(0, 60, 0, 35)
down.Text = "下降"
styleTechBtn(down, Color3.fromRGB(0, 170, 255))

mine.Parent = Frame
mine.Position = UDim2.new(0.32, 0, 0.35, 0)
mine.Size = UDim2.new(0, 60, 0, 35)
mine.Text = "减速"
styleTechBtn(mine, Color3.fromRGB(170, 0, 255))

plus.Parent = Frame
plus.Position = UDim2.new(0.32, 0, 0.65, 0)
plus.Size = UDim2.new(0, 60, 0, 35)
plus.Text = "加速"
styleTechBtn(plus, Color3.fromRGB(170, 0, 255))

speed.Parent = Frame
speed.BackgroundTransparency = 1
speed.Position = UDim2.new(0.57, 0, 0.4, 0)
speed.Size = UDim2.new(0, 40, 0, 45)
speed.Font = Enum.Font.Code
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(255, 215, 0)
speed.TextScaled = true
speed.ZIndex = 2
speed.TextStrokeColor3 = Color3.fromRGB(150, 100, 0)
speed.TextStrokeTransparency = 0.2

onof.Parent = Frame
onof.Position = UDim2.new(0.75, 0, 0.35, 0)
onof.Size = UDim2.new(0, 60, 0, 77)
onof.Text = "飞行\nOFF"
styleTechBtn(onof, Color3.fromRGB(255, 50, 50))

mini2.Parent = main
mini2.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
mini2.Size = UDim2.new(0, 90, 0, 25)
mini2.Text = "展开 XU"
mini2.TextColor3 = Color3.fromRGB(0, 255, 255)
mini2.Font = Enum.Font.GothamBold
mini2.Visible = false
local m2c = Instance.new("UICorner")
m2c.CornerRadius = UDim.new(0, 6)
m2c.Parent = mini2

-- ==========================================
-- 3. 原汁原味的核心逻辑 (绝对未删减)
-- ==========================================

speeds = 1

local speaker = game:GetService("Players").LocalPlayer

local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")

nowe = false

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "XU飞行";
	Text = "星空主题已加载";
	Icon = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"})
Duration = 5;

onof.MouseButton1Down:connect(function()

	if nowe == true then
		nowe = false
		
		-- UI视觉反馈
		onof.Text = "飞行\nOFF"
		onof.TextStrokeColor3 = Color3.fromRGB(255, 50, 50)

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
		
		-- UI视觉反馈
		onof.Text = "飞行\nON"
		onof.TextStrokeColor3 = Color3.fromRGB(0, 255, 120)

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
		speed.Text = 'flyno1'
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
	Frame.Visible = false
	mini2.Visible = true
	mini2.Position = Frame.Position
end)

mini2.MouseButton1Click:Connect(function()
	Frame.Visible = true
	mini2.Visible = false
end)
