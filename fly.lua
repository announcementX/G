local main = Instance.new("ScreenGui")
main.Name = "XU_Fly_Modern"
main.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- 背景主框 (星空深色主题)
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25) -- 深邃夜空蓝黑
Frame.Position = UDim2.new(0.5, -125, 0.5, -100)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.BorderSizePixel = 0

-- UI圆角
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

-- 星空背景图片
local StarBG = Instance.new("ImageLabel")
StarBG.Parent = Frame
StarBG.BackgroundTransparency = 1
StarBG.Size = UDim2.new(1, 0, 1, 0)
StarBG.Image = "rbxassetid://2043644365" -- 星空素材
StarBG.ImageTransparency = 0.5
StarBG.ScaleType = Enum.ScaleType.Crop

-- 标题
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "XU飞行"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

-- 分割线
local Line = Instance.new("Frame")
Line.Parent = Frame
Line.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
Line.BorderSizePixel = 0
Line.Position = UDim2.new(0.05, 0, 0, 40)
Line.Size = UDim2.new(0.9, 0, 0, 1)

-- 按钮实例化
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local plus = Instance.new("TextButton")
local mine = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")

-- 统一样式构建函数
local function styleButton(btn, text, pos, size)
    btn.Parent = Frame
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BackgroundTransparency = 0.3
    btn.Position = pos
    btn.Size = size
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
end

styleButton(up, "上升", UDim2.new(0.05, 0, 0.28, 0), UDim2.new(0.4, 0, 0, 30))
styleButton(down, "下降", UDim2.new(0.05, 0, 0.48, 0), UDim2.new(0.4, 0, 0, 30))
styleButton(onof, "开启", UDim2.new(0.5, 0, 0.28, 0), UDim2.new(0.45, 0, 0, 50))
onof.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
onof.BackgroundTransparency = 0.1
onof.Font = Enum.Font.GothamBold

styleButton(plus, "+ 加速", UDim2.new(0.05, 0, 0.75, 0), UDim2.new(0.25, 0, 0, 30))
styleButton(mine, "- 减速", UDim2.new(0.35, 0, 0.75, 0), UDim2.new(0.25, 0, 0, 30))

speed.Parent = Frame
speed.BackgroundTransparency = 1
speed.Position = UDim2.new(0.65, 0, 0.75, 0)
speed.Size = UDim2.new(0.3, 0, 0, 30)
speed.Font = Enum.Font.GothamBold
speed.Text = "速度: 1"
speed.TextColor3 = Color3.fromRGB(255, 255, 255)
speed.TextSize = 14

closebutton.Parent = Frame
closebutton.BackgroundTransparency = 1
closebutton.Position = UDim2.new(0.88, 0, 0, 5)
closebutton.Size = UDim2.new(0, 30, 0, 30)
closebutton.Font = Enum.Font.GothamBold
closebutton.Text = "X"
closebutton.TextColor3 = Color3.fromRGB(255, 100, 100)
closebutton.TextSize = 16

mini.Parent = Frame
mini.BackgroundTransparency = 1
mini.Position = UDim2.new(0.76, 0, 0, 5)
mini.Size = UDim2.new(0, 30, 0, 30)
mini.Font = Enum.Font.GothamBold
mini.Text = "-"
mini.TextColor3 = Color3.fromRGB(200, 200, 255)
mini.TextSize = 20

-- 窗口控制逻辑
local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Frame.Size = UDim2.new(0, 250, 0, 40)
        mini.Text = "+"
        up.Visible, down.Visible, onof.Visible, plus.Visible, mine.Visible, speed.Visible = false, false, false, false, false, false
    else
        Frame.Size = UDim2.new(0, 250, 0, 200)
        mini.Text = "-"
        up.Visible, down.Visible, onof.Visible, plus.Visible, mine.Visible, speed.Visible = true, true, true, true, true, true
    end
end)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)


-- ================= 原有核心飞行逻辑 ================= --
local speeds = 1
local speaker = game:GetService("Players").LocalPlayer
local chr = game.Players.LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
local nowe = false
local tpwalking = false

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "XU飞行已加载";
	Text = "冰陈，你的屁股痛不痛";
	Icon = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
})

onof.MouseButton1Down:connect(function()
	if nowe == true then
		nowe = false
        onof.Text = "开启飞行"
        onof.BackgroundColor3 = Color3.fromRGB(80, 120, 255)

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
        onof.Text = "关闭飞行"
        onof.BackgroundColor3 = Color3.fromRGB(255, 80, 100)

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
		
        -- 禁用所有状态并切换为Swimming
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
            if state ~= Enum.HumanoidStateType.Swimming and state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.None then
                pcall(function() speaker.Character.Humanoid:SetStateEnabled(state, false) end)
            end
        end
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end

	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
		local plr = game.Players.LocalPlayer
		local torso = plr.Character.Torso
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local flyspeed = 0

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
				flyspeed = flyspeed+.5+(flyspeed/maxspeed)
				if flyspeed > maxspeed then flyspeed = maxspeed end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and flyspeed ~= 0 then
				flyspeed = flyspeed-1
				if flyspeed < 0 then flyspeed = 0 end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*flyspeed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and flyspeed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*flyspeed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*flyspeed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		flyspeed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game.Players.LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false

	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local flyspeed = 0

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
				flyspeed = flyspeed+.5+(flyspeed/maxspeed)
				if flyspeed > maxspeed then flyspeed = maxspeed end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and flyspeed ~= 0 then
				flyspeed = flyspeed-1
				if flyspeed < 0 then flyspeed = 0 end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*flyspeed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and flyspeed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*flyspeed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*flyspeed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		flyspeed = 0
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
	speed.Text = "速度: " .. speeds
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
	if speeds <= 1 then
		speed.Text = '速度: 最低'
		wait(1)
		speed.Text = "速度: " .. speeds
	else
		speeds = speeds - 1
		speed.Text = "速度: " .. speeds
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
