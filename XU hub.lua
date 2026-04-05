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

-- [核心外壳]
local Shell = Instance.new("Frame", SG)
Shell.AnchorPoint = Vector2.new(0.5, 0.5)
Shell.Position = UDim2.new(0.5, 0, 0.5, 0)
Shell.Size = UDim2.new(0, 0, 0, 0)
Shell.BackgroundColor3 = Colors.Void
Shell.BorderSizePixel = 0
Shell.ClipsDescendants = true
Instance.new("UICorner", Shell).CornerRadius = UDim.new(0, 24)
local Stroke = Instance.new("UIStroke", Shell)
Stroke.Thickness = 3.5; Stroke.Color = Colors.Gold

-- [故障特效函数]
local function TriggerGlitch()
    local g = Instance.new("Frame", Shell)
    g.Size = UDim2.new(1, -4, 1, -4)
    g.Position = UDim2.new(0, 2, 0, 2)
    g.BackgroundColor3 = Colors.Cyan; g.ZIndex = 1000; g.BackgroundTransparency = 0.5
    Instance.new("UICorner", g).CornerRadius = UDim.new(0, 22)
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

-- [故障文本组件]
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

-- [页面管理]
local Pages = {}
local MainView = Instance.new("Frame", Shell)
MainView.Size = UDim2.new(1,0,1,0); MainView.BackgroundTransparency = 1; MainView.Visible = false

local Sidebar = Instance.new("Frame", MainView)
Sidebar.Size = UDim2.new(0, 115, 1, 0); Sidebar.BackgroundTransparency = 1

local PageContainer = Instance.new("Frame", MainView)
PageContainer.Size = UDim2.new(1, -145, 1, -95); PageContainer.Position = UDim2.new(0, 125, 0, 75); PageContainer.BackgroundTransparency = 1

local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", PageContainer)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.BorderSizePixel = 0; p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = Colors.Gold; p.Visible = false; Pages[name] = p
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder
    return p
end

-- [创建 5 个页面]
local p1 = CreatePage("我没想好该取啥名1")
local p2 = CreatePage("我没想好该取啥名2")
local p3 = CreatePage("我没想好该取啥名3")
local p4 = CreatePage("我没想好该取啥名4")
local p5 = CreatePage("我没想好该取啥名5")
p1.Visible = true -- 默认显示第一个

-- [侧边栏切换按钮]
local function AddTab(name, targetPage, index)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, -10, 0, 40); b.Position = UDim2.new(0, 10, 0, 75 + (index-1)*45)
    b.BackgroundTransparency = 1; b.Text = ""
    CreateGlitchText(name, b, 14, "Left")
    b.MouseButton1Click:Connect(function()
        TriggerGlitch()
        for _, p in pairs(Pages) do p.Visible = false end
        targetPage.Visible = true
    end)
end

AddTab("我没想好该取啥名1", p1, 1)
AddTab("我没想好该取啥名2", p2, 2)
AddTab("我没想好该取啥名3", p3, 3)
AddTab("我没想好该取啥名4", p4, 4)
AddTab("我没想好该取啥名5", p5, 5)

-- [通用添加按钮函数]
local function AddScript(parent, name, desc, url)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.95, 0, 0, 55); b.BackgroundColor3 = Color3.fromRGB(20, 20, 30); b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    local n = Instance.new("TextLabel", b)
    n.Size = UDim2.new(1,-15,0,30); n.Position = UDim2.new(0,10,0,5); n.Text = name; n.TextColor3 = Colors.White; n.Font = Enum.Font.Code; n.TextSize = 15; n.TextXAlignment = "Left"; n.BackgroundTransparency = 1
    local d = Instance.new("TextLabel", b)
    d.Size = UDim2.new(1,-15,0,20); d.Position = UDim2.new(0,10,0,30); d.Text = desc; d.TextColor3 = Colors.Cyan; d.Font = Enum.Font.Code; d.TextSize = 10; d.TextXAlignment = "Left"; d.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function()
        TriggerGlitch()
        if url and url ~= "" then pcall(function() loadstring(game:HttpGet(url))() end) end
    end)
end

-- ==========================================
-- [ 脚本填充区 - 你可以在这里随意增加 ]
-- ==========================================

-- 页面1：常用脚本
AddScript(p1, "XU 飞行", "不知道如何形容这个脚本，那就来一句冰陈,你的屁股痛不痛", "https://raw.githubusercontent.com/announcementX/G/main/fly.lua")
AddScript(p1, "指令脚本", "不知道如何形容这个脚本，那就来一句冰陈,你的屁股痛不痛", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
AddScript(p1, "Dex", "查看游戏内部模型数据", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
AddScript(p1, "Spy", "你猜猜他有啥用", "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua")

-- 页面2：玩家功能
AddScript(p2, "ESP", "显示玩家名字 血量", "https://raw.githubusercontent.com/Exunys/ESP-Script/main/ESP.lua")
AddScript(p2, "", "好像失效了", "https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/Aimbot%20V3.lua")

AddScript(p3, "移动端键盘", "在手机上呼出控制台", "https://raw.githubusercontent.com/advcrem/GuiS/main/Keyboard.lua")
local TopBar = Instance.new("Frame", MainView)
TopBar.Size = UDim2.new(1, 0, 0, 60); TopBar.BackgroundTransparency = 1
local Title = CreateGlitchText("XU SCRIPT 冰陈你的屁股痛不痛", TopBar, 22, "Left")
Title.Position = UDim2.new(0, 125, 0, 15)

local function MakeCtrl(txt, x, col, func)
    local b = Instance.new("TextButton", Shell)
    b.Size = UDim2.new(0, 35, 0, 35); b.Position = UDim2.new(1, x, 0, 15); b.BackgroundTransparency = 1
    b.Text = txt; b.TextColor3 = col; b.Font = Enum.Font.Code; b.TextSize = 25; b.ZIndex = 200
    b.MouseButton1Click:Connect(func)
end
MakeCtrl("×", -45, Colors.Magenta, function() TriggerGlitch(); Shell:TweenSize(UDim2.new(0, 500, 0, 2), "Out", "Quart", 0.3, true); task.wait(0.3); SG:Destroy() end)
MakeCtrl("−", -90, Colors.Cyan, function()
    TriggerGlitch(); isMin = not isMin
    if isMin then MainView.Visible = false; Shell:TweenSize(UDim2.new(0, 500, 0, 65), "Out", "Back", 0.4, true)
    else Shell:TweenSize(UDim2.new(0, 500, 0, 350), "Out", "Elastic", 0.6, true); task.wait(0.4); MainView.Visible = true end
end)

-- [拖拽]
local drag, dStart, sPos
TopBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = true; dStart = input.Position; sPos = Shell.Position end end)
UIS.InputChanged:Connect(function(input) if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dStart; Shell.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function() drag = false end)

-- [真正的故障爆发加载动画]
local function Launch()
    for i = 1, 120 do
        task.spawn(function()
            local f = Instance.new("Frame", SG); f.BorderSizePixel = 0; f.ZIndex = 2000
            f.Size = UDim2.new(0, math.random(40, 150), 0, 3); f.Position = UDim2.new(math.random(), 0, math.random(), 0)
            f.BackgroundColor3 = (i%3==0 and Colors.Cyan or (i%3==1 and Colors.Magenta or Colors.Gold))
            for _ = 1, 5 do f.Visible = not f.Visible; f.Position = UDim2.new(math.random(), 0, math.random(), 0); task.wait(0.05) end
            f:Destroy()
        end)
        if i % 30 == 0 then task.wait(0.1) end
    end
    Shell:TweenSize(UDim2.new(0, 500, 0, 350), "Out", "Elastic", 1.2, true)
    task.wait(1); MainView.Visible = true; TriggerGlitch()
end
Launch()
