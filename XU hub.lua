--// UI创建
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 120)
Main.Position = UDim2.new(0.3, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true

-- 图片
local Img = Instance.new("ImageLabel", Main)
Img.Size = UDim2.new(0, 80, 0, 80)
Img.Position = UDim2.new(0, 10, 0, 20)
Img.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"

-- 文字
local Text = Instance.new("TextLabel", Main)
Text.Size = UDim2.new(0, 150, 0, 60)
Text.Position = UDim2.new(0, 100, 0, 20)
Text.Text = "冰陈，你的屁股痛不痛"
Text.TextColor3 = Color3.new(1,1,1)
Text.BackgroundTransparency = 1
Text.TextWrapped = true

-- 开关按钮
local Toggle = Instance.new("TextButton", Main)
Toggle.Size = UDim2.new(0, 200, 0, 30)
Toggle.Position = UDim2.new(0, 30, 0, 80)
Toggle.Text = "开启倒立"
Toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
Toggle.TextColor3 = Color3.new(1,1,1)

-- 缩小按钮
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.Text = "-"

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main.Size = UDim2.new(0, 120, 0, 40)
    else
        Main.Size = UDim2.new(0, 260, 0, 120)
    end
end)

--// 倒立核心
local flipped = false
local RunService = game:GetService("RunService")
local conn

local function flipCharacter()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.AutoRotate = false

    conn = RunService.RenderStepped:Connect(function()
        -- 倒立（X轴180度）
        root.CFrame = CFrame.new(root.Position) 
            * CFrame.Angles(math.rad(180), root.Orientation.Y * math.pi/180, 0)
    end)
end

local function unflipCharacter()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if conn then conn:Disconnect() end

    hum.AutoRotate = true
    root.CFrame = CFrame.new(root.Position)
end

-- 开关逻辑
Toggle.MouseButton1Click:Connect(function()
    flipped = not flipped

    if flipped then
        Toggle.Text = "关闭倒立"
        flipCharacter()
    else
        Toggle.Text = "开启倒立"
        unflipCharacter()
    end
end)