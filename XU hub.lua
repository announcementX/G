--// =========================
--// XU HUB - HaoChen Edition
--// =========================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local Theme = "Dark"
local ESP = {
    Name = false,
    Health = false,
    Box2D = false,
    Box3D = false,
    Highlight = false,
}

--// =========================
--// UI SYSTEM
--// =========================

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "XU_HUB"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 400)
Main.Position = UDim2.new(0.5,-300,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0,15)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,150,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)

-- Pages
local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.new(0,150,0,0)
Pages.Size = UDim2.new(1,-150,1,0)
Pages.BackgroundTransparency = 1

-- Button creator
local function CreateButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Tabs
local MainPage = Instance.new("Frame", Pages)
MainPage.Size = UDim2.new(1,0,1,0)

local InfoPage = Instance.new("Frame", Pages)
InfoPage.Size = UDim2.new(1,0,1,0)
InfoPage.Visible = false

-- Sidebar buttons
CreateButton("Main", Sidebar, function()
    MainPage.Visible = true
    InfoPage.Visible = false
end)

CreateButton("Info", Sidebar, function()
    MainPage.Visible = false
    InfoPage.Visible = true
end)

-- Theme toggle
CreateButton("Toggle Theme", Sidebar, function()
    if Theme == "Dark" then
        Theme = "Light"
        Main.BackgroundColor3 = Color3.fromRGB(220,220,220)
    else
        Theme = "Dark"
        Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    end
end)

--// =========================
--// ESP SYSTEM
--// =========================

local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "ESP"

local function CreateESP(player)
    if player == LocalPlayer then return end

    local function Apply(char)
        local humanoid = char:WaitForChild("Humanoid")
        local root = char:WaitForChild("HumanoidRootPart")

        -- Name
        local billboard = Instance.new("BillboardGui", ESPFolder)
        billboard.Adornee = root
        billboard.Size = UDim2.new(0,100,0,40)

        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1

        -- Highlight
        local highlight = Instance.new("Highlight", char)

        RunService.RenderStepped:Connect(function()
            if ESP.Name then
                text.Text = player.Name
            else
                text.Text = ""
            end

            if ESP.Health then
                text.Text = player.Name.." | "..math.floor(humanoid.Health)
            end

            highlight.Enabled = ESP.Highlight
        end)
    end

    if player.Character then
        Apply(player.Character)
    end

    player.CharacterAdded:Connect(Apply)
end

for _,p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end

Players.PlayerAdded:Connect(CreateESP)

-- Buttons
CreateButton("ESP Name", MainPage, function()
    ESP.Name = not ESP.Name
end)

CreateButton("ESP Health", MainPage, function()
    ESP.Health = not ESP.Health
end)

CreateButton("ESP Highlight", MainPage, function()
    ESP.Highlight = not ESP.Highlight
end)

--// =========================
--// INFO SYSTEM（真实数据）
--// =========================

local InfoLabel = Instance.new("TextLabel", InfoPage)
InfoLabel.Size = UDim2.new(1,0,1,0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.new(1,1,1)
InfoLabel.TextScaled = false
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")

    local health = humanoid and humanoid.Health or 0

    local serverInfo = "Players: "..#Players:GetPlayers().."\n"
        .."JobId: "..game.JobId.."\n"
        .."PlaceId: "..game.PlaceId.."\n"
        .."Memory: "..Stats:GetTotalMemoryUsageMb()

    InfoLabel.Text =
        "Player Info\n"
        .."Name: "..LocalPlayer.Name.."\n"
        .."UserId: "..LocalPlayer.UserId.."\n"
        .."Health: "..math.floor(health).."\n\n"
        .."Server Info\n"..serverInfo.."\n\n"
        .."Author: HaoChen\nQQ:1626844714"
end)

--// =========================
--// MINIMIZE SYSTEM
--// =========================

local Minimized = false

local Icon = Instance.new("ImageButton", ScreenGui)
Icon.Size = UDim2.new(0,60,0,60)
Icon.Position = UDim2.new(0,20,0,200)
Icon.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"
Icon.Visible = false

Instance.new("UICorner", Icon).CornerRadius = UDim.new(0,15)

CreateButton("Minimize", Sidebar, function()
    Minimized = true
    Main.Visible = false
    Icon.Visible = true
end)

Icon.MouseButton1Click:Connect(function()
    Main.Visible = true
    Icon.Visible = false
end)

--// =========================
--// LOADING POPUP
--// =========================

local LoadFrame = Instance.new("Frame", ScreenGui)
LoadFrame.Size = UDim2.new(0,300,0,100)
LoadFrame.Position = UDim2.new(0.5,-150,0.5,-50)
LoadFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local img = Instance.new("ImageLabel", LoadFrame)
img.Size = UDim2.new(0,60,0,60)
img.Position = UDim2.new(0,10,0,20)
img.Image = "rbxthumb://type=Asset&id=72322540419714&w=150&h=150"

local txt = Instance.new("TextLabel", LoadFrame)
txt.Size = UDim2.new(1,-80,1,0)
txt.Position = UDim2.new(0,70,0,0)
txt.Text = "冰陈你的屁股痛不痛"
txt.TextColor3 = Color3.new(1,1,1)
txt.BackgroundTransparency = 1

task.wait(3)
LoadFrame:Destroy()