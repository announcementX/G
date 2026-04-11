--[[
    SOUL UI Library - "Where Scripts Find Their Essence"
    Developed for: User Request
    Style: Soft Pink, Smooth Animations, Mobile Friendly, Fully Functional

    Instructions: Place this in a LocalScript under StarterPlayerScripts.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService") -- Used for URL script loading

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // configuration // --
local UI_NAME = "SOUL_Library"
local THEME = {
	Main = Color3.fromRGB(255, 230, 235), -- 淡粉色
	Borders = Color3.fromRGB(255, 210, 220), -- 稍深一丢丢
	Sidebar = Color3.fromRGB(255, 235, 240), -- 稍浅一丢丢
	Accent = Color3.fromRGB(255, 105, 180), -- 灵魂强调色 (Hot Pink)
	Text = Color3.fromRGB(60, 60, 60),
	ToggleOn = Color3.fromRGB(100, 255, 100),
	ToggleOff = Color3.fromRGB(200, 200, 200),
}
local ANIM_SPEED = 0.3
local EASE_STYLE = Enum.EasingStyle.Quint

-- // Library Table // --
local SOUL_Lib = {}
SOUL_Lib.__index = SOUL_Lib
SOUL_Lib.Elements = {}
SOUL_Lib.Signals = {}

-- // Utility Functions // --
local function Create(class, properties)
	local instance = Instance.new(class)
	for property, value in pairs(properties) do
		instance[property] = value
	end
	return instance
end

local function Tween(instance, properties, duration, style)
	local info = TweenInfo.new(duration or ANIM_SPEED, style or EASE_STYLE, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

-- Make GUI Draggable
local function MakeDraggable(gui)
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		Tween(gui, { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) }, 0.1)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- // CORE LIBRARY FUNCTIONS // --

function SOUL_Lib.new(projectName)
	local self = setmetatable({}, SOUL_Lib)
	self.ProjectName = projectName or "SOUL Project"
	self.Tabs = {}
	self.CurrentTab = nil
	self.Minimized = false

	self:_BuildBaseUI()
	return self
end

function SOUL_Lib:_BuildBaseUI()
	-- Protect against multiple instances
	if PlayerGui:FindFirstChild(UI_NAME) then PlayerGui[UI_NAME]:Destroy() end

	-- ScreenGui
	self.ScreenGui = Create("ScreenGui", {
		Name = UI_NAME,
		Parent = PlayerGui,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	-- Main Frame
	self.MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = self.ScreenGui,
		BackgroundColor3 = THEME.Main,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -275, 0.5, -175), -- Centered
		Size = UDim2.new(0, 550, 0, 350), -- Phone friendly size
		ClipsDescendants = true,
		Active = true,
		Visible = false, -- Start invisible for loading anim
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = self.MainFrame })
	MakeDraggable(self.MainFrame)

	-- Top Bar (45px, darker pink)
	local topBar = Create("Frame", {
		Name = "TopBar",
		Parent = self.MainFrame,
		BackgroundColor3 = THEME.Borders,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 45),
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = topBar })
	-- Corner fix frame (hide bottom corners of top bar)
	Create("Frame", {
		BackgroundColor3 = THEME.Borders,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -10),
		Size = UDim2.new(1, 0, 0, 10),
		Parent = topBar
	})

	local title = Create("TextLabel", {
		Name = "Title",
		Parent = topBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(0.7, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "PROJECT | " .. self.ProjectName:upper(),
		TextColor3 = THEME.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	-- Soul Icon in Title
	local soulIcon = Create("ImageLabel", {
		Name = "SoulIcon",
		Parent = topBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -160, 0.5, -12),
		Size = UDim2.new(0, 24, 0, 24),
		Image = "rbxassetid://6031068433", -- Placeholder: A subtle 'sparkle/core' icon
		ImageColor3 = THEME.Accent,
	})
	-- Spin the icon slowly
	task.spawn(function()
		while soulIcon.Parent do
			soulIcon.Rotation += 1
			task.wait(0.02)
		end
	end)

	-- Control Buttons (Minimize / Close)
	local controls = Create("Frame", {
		Name = "Controls",
		Parent = topBar,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -90, 0, 0),
		Size = UDim2.new(0, 80, 1, 0),
	})
	Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = controls })

	self.MinimizeBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = controls,
		BackgroundColor3 = THEME.Accent,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 28, 0, 28),
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.new(1,1,1),
		TextSize = 20,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.MinimizeBtn })

	self.CloseBtn = Create("TextButton", {
		Name = "Close",
		Parent = controls,
		BackgroundColor3 = Color3.fromRGB(255, 100, 100),
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 28, 0, 28),
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.new(1,1,1),
		TextSize = 22,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.CloseBtn })

	-- Bottom Bar (45px, darker pink)
	local bottomBar = Create("Frame", {
		Name = "BottomBar",
		Parent = self.MainFrame,
		BackgroundColor3 = THEME.Borders,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -45),
		Size = UDim2.new(1, 0, 0, 45),
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = bottomBar })
	-- Corner fix frame (hide top corners of bottom bar)
	Create("Frame", {
		BackgroundColor3 = THEME.Borders,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 10),
		Parent = bottomBar
	})
	
	Create("TextLabel", {
		Parent = bottomBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.Gotham,
		Text = "Status: Soul Synchronization Active",
		TextColor3 = THEME.Text,
		TextTransparency = 0.5,
		TextSize = 12,
	})

	-- // Layout logic // --
	
	-- Sidebar (Left, Lighter Pink)
	self.Sidebar = Create("ScrollingFrame", {
		Name = "Sidebar",
		Parent = self.MainFrame,
		BackgroundColor3 = THEME.Sidebar,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(0, 150, 1, -90),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = THEME.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0), -- Dynamic
	})
	Create("UIListLayout", { Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = self.Sidebar })
	Create("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = self.Sidebar })

	-- Gradient transition between Sidebar and Content
	local gradientEdge = Create("Frame", {
		Name = "GradientEdge",
		Parent = self.MainFrame,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 150, 0, 45),
		Size = UDim2.new(0, 15, 1, -90),
		ZIndex = 2,
	})
	Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.Sidebar),
			ColorSequenceKeypoint.new(1, THEME.Main)
		}),
		Parent = gradientEdge
	})

	-- Content Area (Right, Main Pink, Scrolling)
	self.ContentHolder = Create("Frame", {
		Name = "ContentHolder",
		Parent = self.MainFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 165, 0, 55),
		Size = UDim2.new(1, -175, 1, -110),
	})

	-- Minimize Icon (Hidden by default)
	self.MinimizedIcon = Create("ImageButton", {
		Name = "MinimizedIcon",
		Parent = self.ScreenGui,
		BackgroundColor3 = THEME.Accent,
		Position = UDim2.new(0.9, 0, 0.5, 0), -- Right side of screen
		Size = UDim2.new(0, 60, 0, 60), -- Rounded Square
		Visible = false,
		ClipsDescendants = true,
		AutoButtonColor = false,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = self.MinimizedIcon })
	
	local miniSoul = Create("ImageLabel", {
		Parent = self.MinimizedIcon,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.8, 0, 0.8, 0),
		Image = soulIcon.Image,
		ImageColor3 = Color3.new(1, 1, 1),
	})

	-- // Event Handling // --
	
	-- Minimize Logic
	self.MinimizeBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
	self.MinimizedIcon.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
	
	-- Close Logic
	self.CloseBtn.MouseButton1Click:Connect(function() self:Close() end)

	-- Update Sidebar Canvas Size automatically
	self.Sidebar.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, self.Sidebar.UIListLayout.AbsoluteContentSize.Y + 20)
	end)
end

-- // Tab Creation // --

function SOUL_Lib:CreateTab(name, iconId)
	local tab = {}
	tab.Name = name
	tab.Container = nil

	-- Sidebar Button
	local tabBtn = Create("TextButton", {
		Name = name .. "_Tab",
		Parent = self.Sidebar,
		BackgroundColor3 = THEME.Accent,
		BackgroundTransparency = 1, -- Invisible until selected
		Size = UDim2.new(0.9, 0, 0, 40),
		Font = Enum.Font.GothamMedium,
		Text = "  " .. name,
		TextColor3 = THEME.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabBtn })
	
	-- Column highlight
	local highlight = Create("Frame", {
		Parent = tabBtn,
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundTransparency = 1, -- Start invisible
	})
	Create("UICorner", {Parent = highlight})

	-- Content Container for this tab
	local container = Create("ScrollingFrame", {
		Name = name .. "_Container",
		Parent = self.ContentHolder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.Accent,
		Visible = false,
		CanvasSize = UDim2.new(0, 0, 0, 0), -- Dynamic
	})
	Create("UIListLayout", { Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = container })
	Create("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = container })
	tab.Container = container

	-- Tab selection logic
	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
		-- Tab Switch Animation (small scale)
		Tween(tabBtn, {Size = UDim2.new(0.95, 0, 0, 42)}, 0.1):Completed:Connect(function()
			Tween(tabBtn, {Size = UDim2.new(0.9, 0, 0, 40)}, 0.1)
		end)
	end)

	-- Hover animation
	tabBtn.MouseEnter:Connect(function()
		if self.CurrentTab ~= tab then
			Tween(tabBtn, {BackgroundTransparency = 0.9}, 0.2)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if self.CurrentTab ~= tab then
			Tween(tabBtn, {BackgroundTransparency = 1}, 0.2)
		end
	end)

	-- Update Content Canvas Size
	container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, container.UIListLayout.AbsoluteContentSize.Y + 10)
	end)

	tab.Button = tabBtn
	tab.Highlight = highlight
	self.Tabs[name] = tab

	-- Select first tab by default
	if self.CurrentTab == nil then
		self:SelectTab(tab)
	end

	return tab
end

function SOUL_Lib:SelectTab(tab)
	if self.CurrentTab then
		-- Deselect current
		Tween(self.CurrentTab.Button, {BackgroundTransparency = 1, TextColor3 = THEME.Text}, ANIM_SPEED)
		Tween(self.CurrentTab.Highlight, {BackgroundTransparency = 1}, ANIM_SPEED)
		self.CurrentTab.Container.Visible = false
	end

	-- Select new
	self.CurrentTab = tab
	Tween(tab.Button, {BackgroundTransparency = 0.7, TextColor3 = Color3.new(0,0,0)}, ANIM_SPEED)
	Tween(tab.Highlight, {BackgroundTransparency = 0}, ANIM_SPEED)
	tab.Container.Visible = true
end

-- // UI Elements // --

-- 1. Click Button
function SOUL_Lib:CreateButton(parentTab, text, callback)
	local button = {}
	callback = callback or function() end

	local btnFrame = Create("TextButton", {
		Name = text .. "_Button",
		Parent = parentTab.Container,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0.95, 0, 0, 40),
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = THEME.Text,
		TextSize = 14,
		AutoButtonColor = false,
		ClipsDescendants = true,
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btnFrame })
	Create("UIStroke", { Color = THEME.Borders, Thickness = 1, Parent = btnFrame })

	-- Soul Ripple Effect on Click
	local function ripple(x, y)
		local circle = Create("Frame", {
			Parent = btnFrame,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = THEME.Accent,
			Position = UDim2.new(0, x - btnFrame.AbsolutePosition.X, 0, y - btnFrame.AbsolutePosition.Y),
			Size = UDim2.new(0, 0, 0, 0),
			ZIndex = 3,
		})
		Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = circle })
		Tween(circle, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quad):Completed:Connect(function()
			circle:Destroy()
		end)
	end

	btnFrame.MouseButton1Down:Connect(function(x, y)
		ripple(x, y)
		Tween(btnFrame, {Size = UDim2.new(0.9, 0, 0, 38), BackgroundColor3 = THEME.Sidebar}, 0.1)
	end)

	btnFrame.MouseButton1Up:Connect(function()
		Tween(btnFrame, {Size = UDim2.new(0.95, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
		task.spawn(callback)
	end)

	btnFrame.MouseLeave:Connect(function()
		Tween(btnFrame, {Size = UDim2.new(0.95, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
	end)

	return button
end

-- 2. Toggle Switch
function SOUL_Lib:CreateToggle(parentTab, text, default, callback)
	local toggle = {}
	toggle.State = default or false
	callback = callback or function() end

	local toggleFrame = Create("Frame", {
		Name = text .. "_Toggle",
		Parent = parentTab.Container,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0.95, 0, 0, 45),
	})
	Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = toggleFrame })
	Create("UIStroke", { Color = THEME.Borders, Thickness = 1, Parent = toggleFrame })

	local label = Create("TextLabel", {
		Parent = toggleFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = THEME.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local switchPath = Create("TextButton", {
		Name = "Switch",
		Parent = toggleFrame,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.new(0, 45, 0, 22),
		BackgroundColor3 = toggle.State and THEME.ToggleOn or THEME.ToggleOff,
		Text = "",
		AutoButtonColor = false,
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switchPath })

	local slider = Create("Frame", {
		Name = "Slider",
		Parent = switchPath,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = toggle.State and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		BackgroundColor3 = Color3.new(1, 1, 1),
	})
	Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slider })

	local function updateVisuals()
		local targetPos = toggle.State and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		local targetColor = toggle.State and THEME.ToggleOn or THEME.ToggleOff
		Tween(slider, {Position = targetPos}, ANIM_SPEED)
		Tween(switchPath, {BackgroundColor3 = targetColor}, ANIM_SPEED)
		
		-- Soul Pulse on target
		local pulse = Create("Frame", {
			Parent = slider,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = THEME.Accent,
			BackgroundTransparency = 0.5,
		})
		Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = pulse})
		Tween(pulse, {Size = UDim2.new(2,0,2,0), BackgroundTransparency = 1}, 0.4):Completed:Connect(function() pulse:Destroy() end)
	end

	switchPath.MouseButton1Click:Connect(function()
		toggle.State = not toggle.State
		updateVisuals()
		task.spawn(callback, toggle.State)
	end)

	return toggle
end

-- // Script Loading Logic // --

-- 1. Internal Script (Executed by button click directly)
function SOUL_Lib:AddInternalScript(parentTab, name, luauCodeFunc)
	self:CreateButton(parentTab, "Run: " .. name, luauCodeFunc)
end

-- 2. External Script by URL (Raw Link)
function SOUL_Lib:AddExternalScriptURL(parentTab, name, url)
	self:CreateButton(parentTab, "Load Ext: " .. name, function()
		print("Attempting to load script from: " .. url)
		-- WARNING: Standard Roblox does not allow 'loadstring' for security.
		-- In a standard game context, you cannot execute external raw code.
		-- This is where custom exploit executors usually provide a 'loadstring' or 'game:HttpGet' implementation.
		
		-- Simulation of loading for UI purpose:
		local connectionStatus = "Failed (standard Roblox security)"
		
		pcall(function()
			-- If this were a real exploit environment, you'd use something like:
			-- loadstring(game:HttpGet(url))()
			
			-- For standard Roblox, we can only simulated or use HttpService if enabled (but not loadstring)
			connectionStatus = "Simulated Success (Cannot execute external code in standard Roblox)"
		end)
		
		print("Status: " .. connectionStatus)
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Script Loader",
			Text = "External script ["..name.."] " .. connectionStatus,
			Duration = 5
		})
	end)
end

-- // System Animations (Loading, Minimize, Close) // --

function SOUL_Lib:PlayLoadingAnimation()
	self.MainFrame.Visible = false
	local loadingFrame = Create("Frame", {
		Name = "SOUL_Loading",
		Parent = self.ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 100, 0, 100),
		BackgroundTransparency = 1,
	})
	
	-- 4 "Soul fragments" rotating
	local frags = {}
	for i = 1, 4 do
		local f = Create("Frame", {
			Parent = loadingFrame,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = THEME.Accent,
			BackgroundTransparency = 0.2,
			Rotation = i * 90,
		})
		Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = f})
		-- move outwards
		Tween(f, {Position = UDim2.new(0.5, math.cos(math.rad(i*90))*40, 0.5, math.sin(math.rad(i*90))*40)}, 1, Enum.EasingStyle.Quad)
		table.insert(frags, f)
	end
	
	task.wait(1)
	
	-- Convergence and Fade
	for _, f in pairs(frags) do
		Tween(f, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}, 0.8, Enum.EasingStyle.Back)
	end
	
	task.wait(0.8)
	loadingFrame:Destroy()
	
	-- Show Main UI with a zoom-in fade
	self.MainFrame.Visible = true
	self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
	self.MainFrame.BackgroundTransparency = 1
	Tween(self.MainFrame, {Size = UDim2.new(0, 550, 0, 350), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)
end

function SOUL_Lib:ToggleMinimize()
	self.Minimized = not self.Minimized
	local startPos = self.MainFrame.Position
	
	if self.Minimized then
		-- Minimize Animation
		Tween(self.MainFrame, {
			Size = UDim2.new(0, 60, 0, 60), 
			Position = self.MinimizedIcon.Position,
			BackgroundTransparency = 1,
		}, 0.4, Enum.EasingStyle.Quad):Completed:Connect(function()
			self.MainFrame.Visible = false
			self.MinimizedIcon.Visible = true
			-- Pulsing icon to show it's active
			Tween(self.MinimizedIcon, {Size = UDim2.new(0, 65, 0, 65)}, 0.2):Completed:Connect(function()
				Tween(self.MinimizedIcon, {Size = UDim2.new(0, 60, 0, 60)}, 0.2)
			end)
		end)
	else
		-- Restore Animation
		self.MinimizedIcon.Visible = false
		self.MainFrame.Visible = true
		-- You might need to store the original central position to restore to it.
		Tween(self.MainFrame, {
			Size = UDim2.new(0, 550, 0, 350), 
			Position = UDim2.new(0.5, -275, 0.5, -175), -- Default center
			BackgroundTransparency = 0,
		}, 0.4, Enum.EasingStyle.OutBack)
	end
end

function SOUL_Lib:Close()
	-- Close Animation (Shrink and Fade)
	Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back):Completed:Connect(function()
		self.ScreenGui:Destroy()
	end)
end

-- // // // =========================================== // // // --
-- // // //               EXAMPLE USAGE                // // // --
-- // // // =========================================== // // // --

-- 1. Initialize the Library
local MySoulWindow = SOUL_Lib.new("Soul Eater")

-- 2. Create Tabs
local MainTab = MySoulWindow:CreateTab("Main")
local ScriptsTab = MySoulWindow:CreateTab("Script Hub")
local SettingsTab = MySoulWindow:CreateTab("Settings")

-- 3. Populate Main Tab (Internal Scripts)
MySoulWindow:AddInternalScript(MainTab, "Kill Roblox", function()
	print("SOUL: Simulating 'Kill Roblox' - Your soul is too strong!")
end)

MySoulWindow:CreateButton(MainTab, "Teleport to Random Player", function()
	print("SOUL: Shifting reality to another player...")
end)

MySoulWindow:CreateToggle(MainTab, "Auto Farm Souls", false, function(state)
	print("SOUL: Auto Farm is now: " .. (state and "ACTIVE" or "INACTIVE"))
end)

-- 4. Populate Scripts Tab (External/Library)
MySoulWindow:AddExternalScriptURL(ScriptsTab, "Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
MySoulWindow:AddExternalScriptURL(ScriptsTab, "Dex Explorer", "https://raw.githubusercontent.com/infy返返/master/Dex.lua") -- Placeholder link

-- 5. Populate Settings
MySoulWindow:CreateToggle(SettingsTab, "Rainbow UI Accent", false, function(state)
	print("SOUL: Accent effect changed.")
end)

-- 6. Play the introduction animation
MySoulWindow:PlayLoadingAnimation()

