local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local uiName = "XU_SCRIPT"
local targetParent = (gethui and gethui()) or Players.LocalPlayer:WaitForChild("PlayerGui")
if targetParent:FindFirstChild(uiName) then targetParent[uiName]:Destroy() end

local SG = Instance.new("ScreenGui", targetParent)
SG.Name = uiName
SG.ResetOnSpawn = false

local Colors = {
    Void = Color3.fromRGB(3, 3, 5),
    Cyan = Color3.fromRGB(0, 255, 255),
    Magenta = Color3.fromRGB(255, 0, 150),
    Gold = Color3.fromRGB(255, 175, 0),
    White = Color3.fromRGB(255, 255, 255)
}

-- [核心外壳 - 尺寸调小至 440x280]
local Shell = Instance.new("Frame", SG)
Shell.AnchorPoint = Vector2.new(0.5, 0.5)
Shell.Position = UDim2.new(0.5, 0, 0.5, 0)
Shell.Size = UDim2.new(0, 0, 0, 0)
Shell.BackgroundColor3 = Colors.Void
Shell.BorderSizePixel = 0
Shell.ClipsDescendants = true
Instance.new("UICorner", Shell).CornerRadius = UDim.new(0, 20)
local Stroke = Instance.new("UIStroke", Shell)
Stroke.Thickness = 3; Stroke.Color = Colors.Gold

-- [故障特效函数]
local function TriggerGlitch()
    local g = Instance.new("Frame", Shell)
    g.Size = UDim2.new(1, -4, 1, -4)
    g.Position = UDim2.new(0, 2, 0, 2)
    g.BackgroundColor3 = Colors.Cyan; g.ZIndex = 1000; g.BackgroundTransparency = 0.5
    Instance.new("UICorner", g).CornerRadius = UDim.new(0, 18)
    task.spawn(function()
        task.wait(0.04); g.BackgroundColor3 = Colors.Magenta
        task.wait(0.04); g:Destroy()
    end)
    local o = Shell.Position
    for i=1,5 do
        Shell.Position = o + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
        task.wait(0.01)
    end
    Shell.Position = o
end

-- [文字组件]
local function CreateGlitchText(txt, parent, size, align)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1,0,1,0); c.BackgroundTransparency = 1
    local function l(col, off)
        local t = Instance.new("TextLabel", c)
        t.Size = UDim2.new(1,0,1,0); t.Position = UDim2.new(0, off, 0, 0)
        t.BackgroundTransparency = 1; t.Text = txt; t.TextColor3 = col
        t.Font = Enum.Font.Code; t.TextSize = size; t.TextXAlignment = align or "Center"; t.ZIndex = 50
        return t
    end
    l(Colors.Magenta, -1); l(Colors.Cyan, 1); l(Colors.White, 0)
    return c
end

-- [布局设置]
local MainView = Instance.new("Frame", Shell)
MainView.Size = UDim2.new(1,0,1,0); MainView.BackgroundTransparency = 1; MainView.Visible = false

local Sidebar = Instance.new("Frame", MainView)
Sidebar.Size = UDim2.new(0, 100, 1, 0); Sidebar.BackgroundTransparency = 1

local PageContainer = Instance.new("Frame", MainView)
PageContainer.Size = UDim2.new(1, -125, 1, -85); PageContainer.Position = UDim2.new(0, 115, 0, 70); PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", PageContainer)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.BorderSizePixel = 0; p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = Colors.Gold; p.Visible = false; Pages[name] = p
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder
    return p
end

local p1 = CreatePage("我不知道该取啥名1"); p1.Visible = true
local p2 = CreatePage("我不知道该取啥名2"); local p3 = CreatePage("我不知道该取啥名3"); local p4 = CreatePage("我不知道该取啥名4"); local p5 = CreatePage("我不知道该取啥名5")

local function AddTab(name, targetPage, index)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, -10, 0, 35); b.Position = UDim2.new(0, 10, 0, 70 + (index-1)*40)
    b.BackgroundTransparency = 1; b.Text = ""
    CreateGlitchText(name, b, 13, "Left")
    b.MouseButton1Click:Connect(function()
        TriggerGlitch()
        for _, p in pairs(Pages) do p.Visible = false end
        targetPage.Visible = true
    end)
end

AddTab("我不知道该取啥名1", p1, 1); AddTab("我不知道该取啥名2", p2, 2); AddTab("我不知道该取啥名3", p3, 3); AddTab("我不知道该取啥名4", p4, 4); AddTab("我不知道该取啥名5", p5, 5)

local function AddScript(parent, name, desc, url)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.96, 0, 0, 48); b.BackgroundColor3 = Color3.fromRGB(20, 20, 32); b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local n = Instance.new("TextLabel", b)
    n.Size = UDim2.new(1,-15,0,25); n.Position = UDim2.new(0,10,0,4); n.Text = name; n.TextColor3 = Colors.White; n.Font = Enum.Font.Code; n.TextSize = 13; n.TextXAlignment = "Left"; n.BackgroundTransparency = 1
    local d = Instance.new("TextLabel", b)
    d.Size = UDim2.new(1,-15,0,15); d.Position = UDim2.new(0,10,0,26); d.Text = desc; d.TextColor3 = Colors.Cyan; d.Font = Enum.Font.Code; d.TextSize = 9; d.TextXAlignment = "Left"; d.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function() TriggerGlitch(); if url ~= "" then pcall(function() loadstring(game:HttpGet(url))() end) end end)
end

-- [ 脚本大库填充 ]
AddScript(p1, "XU飞行", "冰陈，你的屁股痛不痛", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")
AddScript(p1, "指令脚本", "我不知道该咋形容", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
AddScript(p1, "Dex", "这个我也不知道该怎么形容", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
AddScript(p1, "SimpleSpy", "你猜猜有什么用", "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua")

AddScript(p2, "自瞄", "好像失效了", "https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/Aimbot%20V3.lua")
AddScript(p2, "ESP", "显示玩家名字之类的", "https://raw.githubusercontent.com/Exunys/ESP-Script/main/ESP.lua")
AddScript(p2, "这也是飞行", "飞行", "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.lua")

AddScript(p3, "键盘", "键盘", "https://raw.githubusercontent.com/advcrem/GuiS/main/Keyboard.lua")

-- [ 拖拽控制层 - 缩小后依然生效的核心 ]
local DragHandle = Instance.new("Frame", Shell)
DragHandle.Size = UDim2.new(1, 0, 0, 60)
DragHandle.BackgroundTransparency = 1
DragHandle.ZIndex = 300

-- [ 标题与控制 ]
local Title = CreateGlitchText("XU SCRIPT", DragHandle, 20, "Left")
Title.Position = UDim2.new(0, 115, 0, 15)

local function MakeCtrl(txt, x, col, func)
    local b = Instance.new("TextButton", Shell)
    b.Size = UDim2.new(0, 30, 0, 30); b.Position = UDim2.new(1, x, 0, 15); b.BackgroundTransparency = 1
    b.Text = txt; b.TextColor3 = col; b.Font = Enum.Font.Code; b.TextSize = 22; b.ZIndex = 500
    b.MouseButton1Click:Connect(func)
end

MakeCtrl("×", -40, Colors.Magenta, function() TriggerGlitch(); Shell:TweenSize(UDim2.new(0, 440, 0, 2), "Out", "Quart", 0.3, true); task.wait(0.3); SG:Destroy() end)

local isMin = false
MakeCtrl("−", -80, Colors.Cyan, function()
    TriggerGlitch(); isMin = not isMin
    if isMin then
        MainView.Visible = false
        Shell:TweenSize(UDim2.new(0, 440, 0, 60), "Out", "Back", 0.4, true)
    else
        Shell:TweenSize(UDim2.new(0, 440, 0, 280), "Out", "Elastic", 0.6, true)
        task.wait(0.4); MainView.Visible = true
    end
end)

-- [ 移动逻辑重写 ]
local drag, dStart, sPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = input.Position; sPos = Shell.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dStart
        Shell.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function() drag = false end)

-- [ 震撼加载 ]
local function Launch()
    for i = 1, 100 do
        task.spawn(function()
            local f = Instance.new("Frame", SG); f.BorderSizePixel = 0; f.ZIndex = 2000
            f.Size = UDim2.new(0, math.random(40, 120), 0, 2); f.Position = UDim2.new(math.random(), 0, math.random(), 0)
            f.BackgroundColor3 = (i%2==0 and Colors.Cyan or Colors.Magenta)
            for _ = 1, 4 do f.Visible = not f.Visible; f.Position = UDim2.new(math.random(), 0, math.random(), 0); task.wait(0.06) end
            f:Destroy()
        end)
        if i % 25 == 0 then task.wait(0.1) end
    end
    Shell:TweenSize(UDim2.new(0, 440, 0, 280), "Out", "Elastic", 1.2, true)
    task.wait(1); MainView.Visible = true; TriggerGlitch()
end
Launch()
