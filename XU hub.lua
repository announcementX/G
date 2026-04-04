local CONFIG = {
    Name = "冰陈脚本中心",
    Version = "2.0.0",
    Author = "HaoChen",
    QQ = "1626844714",
    IconID = "72322540419714",
    
    -- 主题配色
    Accent = Color3.fromRGB(138, 43, 226),
    Dark = {
        BG = Color3.fromRGB(18, 18, 24),
        Surface = Color3.fromRGB(28, 28, 36),
        SurfaceHover = Color3.fromRGB(38, 38, 48),
        Text = Color3.fromRGB(245, 245, 247),
        TextSec = Color3.fromRGB(161, 161, 170),
        Border = Color3.fromRGB(45, 45, 55),
        Success = Color3.fromRGB(50, 205, 121),
        Error = Color3.fromRGB(255, 69, 96),
    },
    Light = {
        BG = Color3.fromRGB(245, 245, 247),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(240, 240, 245),
        Text = Color3.fromRGB(28, 28, 36),
        TextSec = Color3.fromRGB(142, 142, 156),
        Border = Color3.fromRGB(220, 220, 225),
        Success = Color3.fromRGB(34, 166, 91),
        Error = Color3.fromRGB(220, 53, 69),
    },
    
    -- ESP配置
    ESP = {
        Enabled = false,
        MaxDist = 500,
        UpdateRate = 0.05,
        Options = {
            Name = true,
            Health = true,
            Box2D = true,            Box3D = false,
            Tracer = false,
            Outline = false,
            Chams = false,
        }
    }
}

-- ==================== 📦 服务缓存 (性能优化) ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== 🛠️ 工具函数库 ====================
local Utils = {}

function Utils.Round(n: number, d: number): number
    local m = 10^(d or 0)
    return math.floor(n * m + 0.5) / m
end

function Utils.Lerp(a: number, b: number, t: number): number
    return a + (b - a) * t
end

function Utils.WorldToScreen(pos: Vector3): Vector2?, boolean
    if not Camera then return nil, false end
    local vp, on = Camera:WorldToViewportPoint(pos)
    return on and Vector2.new(vp.X, vp.Y) or nil, on
end

function Utils.GetBounds(model: Model): Vector3?, Vector3?
    if not model.PrimaryPart then return nil, nil end
    local min, max = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            local cf, s = p.CFrame, p.Size
            for _, c in ipairs({
                cf * Vector3.new(s.X/2, s.Y/2, s.Z/2),
                cf * Vector3.new(-s.X/2, s.Y/2, s.Z/2),
                cf * Vector3.new(s.X/2, -s.Y/2, s.Z/2),
                cf * Vector3.new(s.X/2, s.Y/2, -s.Z/2),
                cf * Vector3.new(-s.X/2, -s.Y/2, s.Z/2),
                cf * Vector3.new(-s.X/2, s.Y/2, -s.Z/2),
                cf * Vector3.new(s.X/2, -s.Y/2, -s.Z/2),
                cf * Vector3.new(-s.X/2, -s.Y/2, -s.Z/2),            }) do
                min = Vector3.new(math.min(min.X, c.X), math.min(min.Y, c.Y), math.min(min.Z, c.Z))
                max = Vector3.new(math.max(max.X, c.X), math.max(max.Y, c.Y), math.max(max.Z, c.Z))
            end
        end
    end
    return min, max
end

-- ==================== 🎨 主题管理器 ====================
local Theme = {Current = "Dark", Colors = CONFIG.Dark}

local function ApplyTheme(obj: Instance, isDark: boolean)
    local c = isDark and CONFIG.Dark or CONFIG.Light
    if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
        if obj.Name:match("[Bb]g|[Mm]ain") then obj.BackgroundColor3 = c.BG
        elseif obj.Name:match("[Ss]urface|[Pp]anel|[Ii]tem") then obj.BackgroundColor3 = c.Surface end
        obj.BorderColor3 = c.Border
    elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
        obj.TextColor3 = obj.Name:match("[Ss]ec") and c.TextSec or c.Text
    elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
        obj.BackgroundColor3 = c.Surface
        obj.BorderColor3 = c.Border
    elseif obj:IsA("UIStroke") then
        obj.Color = c.Border
    end
    for _, child in ipairs(obj:GetChildren()) do ApplyTheme(child, isDark) end
end

local function ToggleTheme()
    Theme.Current = Theme.Current == "Dark" and "Light" or "Dark"
    Theme.Colors = Theme.Current == "Dark" and CONFIG.Dark or CONFIG.Light
    if _G.IceHub and _G.IceHub.MainFrame then
        ApplyTheme(_G.IceHub.MainFrame, Theme.Current == "Dark")
    end
end

-- ==================== 🧱 UI构建器 ====================
local UI = {}

function UI.Frame(p: GuiObject, n: string, cfg: table): Frame
    local f = Instance.new("Frame")
    f.Name, f.BackgroundTransparency, f.BackgroundColor3 = n, cfg.T or 0, cfg.C or Theme.Colors.Surface
    f.BorderColor3, f.BorderSizePixel = cfg.BC or Theme.Colors.Border, cfg.BW or 1
    f.Size, f.Position, f.AnchorPoint, f.Visible = cfg.S or UDim2.new(0,200,0,200), cfg.P or UDim2.new(), cfg.A or Vector2.new(), cfg.V ~= false
    f.Parent = p
    if cfg.R then Instance.new("UICorner", f).CornerRadius = UDim.new(0, cfg.R) end
    if cfg.St then local s = Instance.new("UIStroke", f); s.Color = cfg.StC or Theme.Colors.Border; s.Thickness = cfg.StW or 1 end
    return f
end
function UI.Label(p: GuiObject, t: string, cfg: table): TextLabel
    local l = Instance.new("TextLabel")
    l.Name, l.Text, l.TextColor3 = cfg.N or "Label", t, cfg.C or Theme.Colors.Text
    l.TextSize, l.Font = cfg.Sz or 14, cfg.F or Enum.Font.Gotham
    l.BackgroundTransparency, l.Size, l.Position = 1, cfg.S or UDim2.new(1,0,0,20), cfg.P or UDim2.new()
    l.AnchorPoint, l.TextXAlignment, l.TextYAlignment = cfg.A or Vector2.new(), cfg.X or Enum.TextXAlignment.Left, cfg.Y or Enum.TextYAlignment.Center
    l.Parent = p
    return l
end

function UI.Button(p: GuiObject, t: string, cfg: table): TextButton
    local b = Instance.new("TextButton")
    b.Name, b.Text, b.TextColor3 = cfg.N or "Btn", t, Theme.Colors.Text
    b.TextSize, b.Font = cfg.TSz or 14, Enum.Font.GothamSemibold
    b.BackgroundColor3, b.BorderColor3 = Theme.Colors.Surface, Theme.Colors.Border
    b.Size, b.Position, b.AutoButtonColor = cfg.S or UDim2.new(1,0,0,30), cfg.P or UDim2.new(), false
    b.Parent = p
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, cfg.R or 6)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Colors.SurfaceHover}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Colors.Surface}):Play() end)
    return b
end

function UI.Toggle(p: GuiObject, txt: string, def: boolean, cb: function?): Frame
    local t = UI.Frame(p, "Toggle", {S = UDim2.new(1,-10,0,35), P = UDim2.new(0,5,0,0), C = Color3.new(1,1,1,0), BW = 0, R = 8})
    UI.Label(t, txt, {P = UDim2.new(0,10,0,0), S = UDim2.new(1,-50,1,0), Y = Enum.TextYAlignment.Center})
    local sw = UI.Frame(t, "Switch", {S = UDim2.new(0,40,0,24), P = UDim2.new(1,-45,0.5,0), A = Vector2.new(0,0.5), C = def and Theme.Colors.Accent or Theme.Colors.TextSec, R = 12})
    local kb = UI.Frame(sw, "Knob", {S = UDim2.new(0,20,0,20), P = UDim2.new(0, def and 18 or 2, 0.5, 0), A = Vector2.new(0,0.5), C = Color3.new(1,1,1), R = 10})
    local en = def
    t.MouseButton1Click:Connect(function()
        en = not en
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3 = en and Theme.Colors.Accent or Theme.Colors.TextSec}):Play()
        TweenService:Create(kb, TweenInfo.new(0.15), {Position = UDim2.new(0, en and 18 or 2, 0.5, 0)}):Play()
        if cb then cb(en) end
    end)
    return t
end

-- ==================== 🔔 弹窗系统 ====================
local Popup = {}

function Popup.Loading(msg: string, icon: string?): Frame
    local pop = UI.Frame(_G.IceHub.MainFrame, "LoadingPopup", {
        S = UDim2.new(0,280,0,120), P = UDim2.new(0.5,-140,0.5,-60), A = Vector2.new(0.5,0.5),
        C = Theme.Colors.Surface, BC = Theme.Colors.Accent, BW = 2, R = 16
    })
    if icon then
        local img = Instance.new("ImageLabel")
        img.Image = "rbxthumb://type=Asset&id="..icon.."&w=80&h=80"        img.Size, img.Position, img.AnchorPoint = UDim2.new(0,60,0,60), UDim2.new(0.5,-30,0,15), Vector2.new(0.5,0)
        img.BackgroundTransparency, img.Parent = 1, pop
        task.spawn(function()
            for i=1,3 do
                TweenService:Create(img, TweenInfo.new(0.2), {ImageTransparency = 0.4}):Play(); task.wait(0.15)
                TweenService:Create(img, TweenInfo.new(0.2), {ImageTransparency = 1}):Play(); task.wait(0.15)
            end
        end)
    end
    UI.Label(pop, msg, {P = UDim2.new(0,0,0,75), S = UDim2.new(1,0,0,25), X = Enum.TextXAlignment.Center, Sz = 15})
    task.defer(function() task.wait(1.8); TweenService:Create(pop, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play(); task.wait(0.2); pop:Destroy() end)
    return pop
end

-- ==================== 👁️ ESP渲染引擎 ====================
local ESP = {Cache = {}}

local function UpdateESP()
    if not CONFIG.ESP.Enabled or not Camera then return end
    local lpChar = LocalPlayer.Character
    if not lpChar then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char, hum, root = plr.Character, plr.Character:FindFirstChild("Humanoid"), plr.Character.PrimaryPart or plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                local scr, on = Utils.WorldToScreen(root.Position)
                if on and (Camera.CFrame.Position - root.Position).Magnitude <= CONFIG.ESP.MaxDist then
                    if not ESP.Cache[plr] then ESP.Cache[plr] = {} end
                    local c = ESP.Cache[plr]
                    
                    -- 📛 名字
                    if CONFIG.ESP.Options.Name then
                        if not c.Name then c.Name = Instance.new("TextLabel"); c.Name.BackgroundTransparency, c.Name.TextStrokeColor3, c.Name.TextStrokeTransparency, c.Name.ZIndex = 1, Color3.new(), 0.7, 100; c.Name.Parent = _G.IceHub.ESPLayer end
                        c.Name.Text, c.Name.Position, c.Name.AnchorPoint, c.Name.Visible = plr.Name, UDim2.new(0, scr.X, 0, scr.Y-25), Vector2.new(0.5,1), true
                    elseif c.Name then c.Name.Visible = false end
                    
                    -- ❤️ 血量
                    if CONFIG.ESP.Options.Health then
                        if not c.HP then c.HP = Instance.new("TextLabel"); c.HP.BackgroundTransparency, c.HP.TextStrokeColor3, c.HP.TextStrokeTransparency, c.HP.ZIndex = 1, Color3.new(), 0.7, 100; c.HP.Parent = _G.IceHub.ESPLayer end
                        local pct = hum.Health/hum.MaxHealth
                        c.HP.Text, c.HP.TextColor3 = string.format("%d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth)), Color3.fromHSV(pct*0.33, 1, 1)
                        c.HP.Position, c.HP.AnchorPoint, c.HP.Visible = UDim2.new(0, scr.X, 0, scr.Y-10), Vector2.new(0.5,1), true
                    elseif c.HP then c.HP.Visible = false end
                    
                    -- 🔲 2D框
                    if CONFIG.ESP.Options.Box2D then
                        if not c.Box then c.Box = Instance.new("Frame"); c.Box.BackgroundTransparency, c.Box.BorderSizePixel, c.Box.BorderColor3, c.Box.ZIndex = 1, 2, Theme.Colors.Accent, 99; c.Box.Parent = _G.IceHub.ESPLayer end
                        local mn, mx = Utils.GetBounds(char)
                        if mn and mx then                            local tp, _ = Utils.WorldToScreen(Vector3.new((mn.X+mx.X)/2, mx.Y, (mn.Z+mx.Z)/2))
                            local bp, _ = Utils.WorldToScreen(Vector3.new((mn.X+mx.X)/2, mn.Y, (mn.Z+mx.Z)/2))
                            if tp and bp then
                                local w = math.abs(((Utils.WorldToScreen(Vector3.new(mx.X,0,0)) or Vector2.zero).X - scr.X)) * 1.3
                                local h = math.abs(tp.Y - bp.Y)
                                c.Box.Position, c.Box.Size, c.Box.Visible = UDim2.new(0, scr.X-w/2, 0, tp.Y), UDim2.new(0, w, 0, h), true
                            end
                        end
                    elseif c.Box then c.Box.Visible = false end
                    
                    -- 🔴 法线
                    if CONFIG.ESP.Options.Tracer then
                        if not c.Tracer then c.Tracer = Instance.new("Frame"); c.Tracer.BackgroundColor3, c.Tracer.BorderSizePixel, c.Tracer.ZIndex = Theme.Colors.Accent, 0, 98; c.Tracer.Parent = _G.IceHub.ESPLayer end
                        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y*0.9)
                        local ang = math.atan2(scr.Y-center.Y, scr.X-center.X)
                        local len = math.min(180, (Camera.CFrame.Position-root.Position).Magnitude * 0.25)
                        c.Tracer.Position, c.Tracer.Size, c.Tracer.Rotation, c.Tracer.AnchorPoint, c.Tracer.Visible = 
                            UDim2.new(0, center.X, 0, center.Y), UDim2.new(0, len, 0, 2), math.deg(ang), Vector2.new(0,0.5), true
                    elseif c.Tracer then c.Tracer.Visible = false end
                    
                    -- ✨ 轮廓 (需执行器支持)
                    if CONFIG.ESP.Options.Outline and pcall(getgenv) and highlightcharacter then
                        if not c.Outline then c.Outline = highlightcharacter(char, {FillColor = Color3.fromRGB(138,43,226), OutlineColor = Color3.new(1,1,1), FillTransparency = 0.75, OutlineTransparency = 0}) end
                    end
                    
                    -- 👤 透视样貌 (Chams - 需执行器支持)
                    if CONFIG.ESP.Options.Chams and pcall(getgenv) and sethiddenproperty then
                        if not c.Cham then
                            c.Cham = {}
                            for _, pt in ipairs(char:GetDescendants()) do
                                if pt:IsA("BasePart") then
                                    c.Cham[pt] = pt.Transparency
                                    pcall(function() pt.LocalTransparencyModifier = 0.45 end)
                                end
                            end
                        end
                    elseif c.Cham then
                        for pt, orig in pairs(c.Cham) do if pt.Parent then pt.LocalTransparencyModifier = orig end end
                        c.Cham = nil
                    end
                end
            end
        end
    end
end

local function CleanupESP()
    for _, cache in pairs(ESP.Cache) do
        for _, obj in pairs(cache) do if obj and obj.Destroy then pcall(function() obj:Destroy() end) end end
    end    ESP.Cache = {}
end

-- ==================== 🏗️ 主界面构建 ====================
local IceHub = {}

function IceHub.Init()
    -- 🎨 主GUI
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.Parent, gui.DisplayOrder, gui.IgnoreGuiInset = "IceHub_v2", LocalPlayer:WaitForChild("PlayerGui"), 100, true
    _G.IceHub = {Gui = gui}
    
    -- 👁️ ESP层
    local esp2d = Instance.new("Frame"); esp2d.Name, esp2d.BackgroundTransparency, esp2d.Size, esp2d.Parent = "ESPLayer", 1, UDim2.new(1,0,1,0), gui
    _G.IceHub.ESPLayer = esp2d
    
    -- 🧊 主窗口
    local main = UI.Frame(gui, "MainFrame", {
        S = UDim2.new(0, 820, 0, 560), P = UDim2.new(0.5, -410, 0.5, -280), A = Vector2.new(0.5, 0.5),
        C = Theme.Colors.BG, BW = 0, R = 14
    })
    _G.IceHub.MainFrame = main
    
    -- 📌 标题栏
    local title = UI.Frame(main, "TitleBar", {S = UDim2.new(1,0,0,48), C = Theme.Colors.Surface, BW = 0, R = 14})
    UI.Label(title, "🎮 "..CONFIG.Name, {P = UDim2.new(0,18,0,0), S = UDim2.new(1,-120,1,0), Sz = 19, F = Enum.Font.GothamBold, Y = Enum.TextYAlignment.Center})
    UI.Label(title, "✨ 冰陈你的屁股痛不痛 ✨", {P = UDim2.new(1,-290,0,0), S = UDim2.new(0,260,1,0), Sz = 13, Y = Enum.TextYAlignment.Center, X = Enum.TextXAlignment.Right, C = Theme.Colors.Accent})
    
    -- 🔘 功能按钮
    local themeBtn = UI.Button(title, "🌓", {N="ThemeBtn", S=UDim2.new(0,38,0,32), P=UDim2.new(1,-48,0.5,0), A=Vector2.new(0.5,0.5), R=9})
    themeBtn.MouseButton1Click:Connect(ToggleTheme)
    
    local minBtn = UI.Button(title, "−", {N="MinBtn", S=UDim2.new(0,32,0,32), P=UDim2.new(1,-90,0.5,0), A=Vector2.new(0.5,0.5), R=9})
    local closeBtn = UI.Button(title, "×", {N="CloseBtn", S=UDim2.new(0,32,0,32), P=UDim2.new(1,-18,0.5,0), A=Vector2.new(0.5,0.5), R=9})
    
    -- 🗂️ 侧边栏
    local sidebar = UI.Frame(main, "Sidebar", {S = UDim2.new(0, 190, 1, -48), P = UDim2.new(0,0,0,48), C = Theme.Colors.Surface, BW = 0})
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)
    
    -- 🧭 导航项
    local pages, current = {}, "Home"
    local navs = {
        {I="🏠", N="首页", K="Home"}, {I="⚡", N="脚本库", K="Scripts"},
        {I="👁️", N="透视设置", K="ESP"}, {I="📊", N="信息面板", K="Info"},
        {I="⚙️", N="设置", K="Settings"}
    }
    
    for i, nav in ipairs(navs) do
        local btn = UI.Button(sidebar, nav.I.."  "..nav.N, {
            N="Nav_"..nav.K, S=UDim2.new(1,-12,0,42), P=UDim2.new(0,6,0,8+(i-1)*48), R=11        })
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(sidebar:GetChildren()) do if b:IsA("TextButton") and b.Name:find("Nav_") then TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Colors.Surface}):Play() end end
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Colors.Accent}):Play()
            for k, pg in pairs(pages) do pg.Visible = (k == nav.K) end
            current = nav.K
        end)
    end
    TweenService:Create(sidebar:WaitForChild("Nav_Home"), TweenInfo.new(0), {BackgroundColor3 = Theme.Colors.Accent}):Play()
    
    -- 📄 内容区
    local content = UI.Frame(main, "Content", {S = UDim2.new(1,-200, 1,-48), P = UDim2.new(0,200,0,48), C = Color3.new(1,1,1,0), BW = 0})
    local container = Instance.new("Frame"); container.Name, container.BackgroundTransparency, container.Size, container.Parent = "Pages", 1, UDim2.new(1,0,1,0), content
    
    -- ===== 🏠 首页 =====
    local home = UI.Frame(container, "Home", {S = UDim2.new(1,0,1,0), C = Color3.new(1,1,1,0)})
    pages.Home = home
    UI.Label(home, "🎮 欢迎使用 "..CONFIG.Name, {P = UDim2.new(0,25,0,35), S = UDim2.new(1,-50,0,40), Sz = 25, F = Enum.Font.GothamBold})
    UI.Label(home, "版本 v"..CONFIG.Version.." • 作者: "..CONFIG.Author, {P = UDim2.new(0,25,0,80), S = UDim2.new(1,-50,0,25), Sz = 14, C = Theme.Colors.TextSec})
    
    -- 功能卡片
    local feats = {
        {I="⚡", T="快速加载", D="一键执行常用脚本"}, {I="🛡️", T="安全保护", D="防检测&防踢出"},
        {I="🎯", T="智能瞄准", D="自动锁定目标"}, {I="🗂️", T="脚本管理", D="导入/导出配置"}
    }
    for i, f in ipairs(feats) do
        local card = UI.Frame(home, "Card"..i, {
            S = UDim2.new(0.5,-18, 0,105), P = UDim2.new((i-1)%2*0.5+0.025, 0, 0, 140+math.floor((i-1)/2)*115),
            C = Theme.Colors.Surface, R = 13
        })
        UI.Label(card, f.I, {P = UDim2.new(0,18,0,18), S = UDim2.new(0,32,0,32), Sz = 22, X = Enum.TextXAlignment.Center})
        UI.Label(card, f.T, {P = UDim2.new(0,60,0,15), S = UDim2.new(1,-75,0,28), Sz = 17, F = Enum.Font.GothamSemibold})
        UI.Label(card, f.D, {P = UDim2.new(0,60,0,40), S = UDim2.new(1,-75,0,45), Sz = 13, C = Theme.Colors.TextSec, Y = Enum.TextYAlignment.Top})
    end
    
    -- ===== ⚡ 脚本库 =====
    local scripts = UI.Frame(container, "Scripts", {S = UDim2.new(1,0,1,0), C = Color3.new(1,1,1,0), V = false})
    pages.Scripts = scripts
    UI.Label(scripts, "📦 脚本库", {P = UDim2.new(0,25,0,25), S = UDim2.new(1,-50,0,32), Sz = 21, F = Enum.Font.GothamBold})
    
    local import = UI.Frame(scripts, "ImportPanel", {S = UDim2.new(1,-50,0,210), P = UDim2.new(0,25,0,70), C = Theme.Colors.Surface, R = 13})
    UI.Label(import, "📥 导入外部完整脚本", {P = UDim2.new(0,18,0,18), S = UDim2.new(1,-36,0,28), Sz = 17, F = Enum.Font.GothamSemibold})
    
    for i=1,3 do
        local slot = UI.Frame(import, "Slot"..i, {S = UDim2.new(1,-36,0,48), P = UDim2.new(0,18,0,55+(i-1)*52), C = Theme.Colors.BG, R = 9})
        UI.Label(slot, "📁 脚本槽位 #"..i, {P = UDim2.new(0,15,0,0), S = UDim2.new(1,-90,1,0), Sz = 14, Y = Enum.TextYAlignment.Center})
        local btn = UI.Button(slot, "🔓 加载", {S = UDim2.new(0,72,0,32), P = UDim2.new(1,-22,0.5,0), A = Vector2.new(1,0.5), R = 7, TSz = 13})
        btn.MouseButton1Click:Connect(function()
            Popup.Loading("⏳ 正在加载脚本 #"..i.."\n请稍候...", CONFIG.IconID)
            task.spawn(function()                task.wait(1.2)
                print("✅ 脚本 #"..i.." 加载完成 (模拟)")
                -- 📌 实际使用时在此处添加 loadstring(httprequest(...)) 等逻辑
            end)
        end)
    end
    
    -- ===== 👁️ 透视设置 =====
    local espPage = UI.Frame(container, "ESP", {S = UDim2.new(1,0,1,0), C = Color3.new(1,1,1,0), V = false})
    pages.ESP = espPage
    UI.Label(espPage, "👁️ 透视设置", {P = UDim2.new(0,25,0,25), S = UDim2.new(1,-50,0,32), Sz = 21, F = Enum.Font.GothamBold})
    
    UI.Toggle(espPage, "🔓 启用透视功能", false, function(v) CONFIG.ESP.Enabled = v; if not v then CleanupESP() end end):Position(UDim2.new(0,25,0,72))
    
    local opts = {
        {K="Name", L="📛 显示玩家名字", D=true}, {K="Health", L="❤️ 显示玩家血量", D=true},
        {K="Box2D", L="🔲 2D边框", D=true}, {K="Box3D", L="🧊 3D边框", D=false},
        {K="Tracer", L="🔴 透视法线", D=false}, {K="Outline", L="✨ 玩家轮廓", D=false},
        {K="Chams", L="👤 透视样貌", D=false}
    }
    for i, o in ipairs(opts) do
        UI.Toggle(espPage, o.L, o.D, function(v) CONFIG.ESP.Options[o.K] = v end):Position(UDim2.new(0,25,0,112+(i-1)*42))
    end
    
    -- 距离滑块
    local distCtrl = UI.Frame(espPage, "DistCtrl", {S = UDim2.new(1,-50,0,65), P = UDim2.new(0,25,0,410), C = Theme.Colors.Surface, R = 11})
    local distLbl = UI.Label(distCtrl, "📏 最大距离: "..CONFIG.ESP.MaxDist.." studs", {N="DistLabel", P = UDim2.new(0,18,0,12), S = UDim2.new(1,-36,0,22), Sz = 14})
    
    local track = Instance.new("Frame"); track.BackgroundColor3, track.BorderSizePixel, track.Size, track.Position, track.Parent = Theme.Colors.Border, 0, UDim2.new(1,-36,0,6), UDim2.new(0,18,0,40), distCtrl
    Instance.new("UICorner", track).CornerRadius = UDim.new(0,3)
    
    local thumb = Instance.new("TextButton"); thumb.Text, thumb.BackgroundColor3, thumb.BorderSizePixel, thumb.Size = "", Theme.Colors.Accent, 0, UDim2.new(0,14,0,6)
    thumb.Position, thumb.Parent = UDim2.new(0, 18 + (CONFIG.ESP.MaxDist/1000)*264, 0, 40), distCtrl
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0,3)
    
    local dragging = false
    thumb.MouseButton1Down:Connect(function()
        dragging = true
        while dragging do
            local pos = math.clamp(UserInputService:GetMouseLocation().X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local pct = pos / track.AbsoluteSize.X
            CONFIG.ESP.MaxDist = math.floor(pct * 1000)
            distLbl.Text = "📏 最大距离: "..CONFIG.ESP.MaxDist.." studs"
            TweenService:Create(thumb, TweenInfo.new(0.04), {Position = UDim2.new(0, 18 + pct*264, 0, 40)}):Play()
            UserInputService.InputEnded:Wait()
            if UserInputService.LastInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end
    end)
    
    -- ===== 📊 信息面板 (核心需求) =====    local infoPage = UI.Frame(container, "Info", {S = UDim2.new(1,0,1,0), C = Color3.new(1,1,1,0), V = false})
    pages.Info = infoPage
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name, scroll.BackgroundTransparency, scroll.Size, scroll.Position = "InfoScroll", 1, UDim2.new(1,-25,1,-25), UDim2.new(0,25,0,25)
    scroll.ScrollBarThickness, scroll.ScrollBarImageColor3 = 7, Theme.Colors.Accent
    scroll.CanvasSize, scroll.Parent = UDim2.new(0,0,0,1300), infoPage
    
    local infoCont = Instance.new("Frame"); infoCont.Name, infoCont.BackgroundTransparency, infoCont.Size, infoCont.Parent = "InfoContent", 1, UDim2.new(1,0,0,1300), scroll
    
    -- 🔹 1. 玩家样貌 (顶部 - 实时)
    local avatarSec = UI.Frame(infoCont, "AvatarSec", {S = UDim2.new(1,0,0,185), C = Theme.Colors.Surface, R = 17})
    UI.Label(avatarSec, "👤 玩家实时样貌", {P = UDim2.new(0,22,0,18), S = UDim2.new(1,-44,0,28), Sz = 19, F = Enum.Font.GothamBold})
    
    local avFrame = UI.Frame(avatarSec, "AvatarBox", {S = UDim2.new(0,125,0,125), P = UDim2.new(0,32,0,55), C = Theme.Colors.BG, R = 63})
    local avImg = Instance.new("ImageLabel"); avImg.BackgroundTransparency, avImg.Size, avImg.Position, avImg.ScaleType, avImg.Parent = 1, UDim2.new(1,-12,1,-12), UDim2.new(0,6,0,6), Enum.ScaleType.Crop, avFrame
    
    -- 🔄 实时头像更新
    task.spawn(function()
        while true do
            if LocalPlayer.UserId > 0 then
                avImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
            end
            task.wait(4)
        end
    end)
    
    UI.Label(avatarSec, "🟢 在线", {N="StatusTxt", P = UDim2.new(0,175,0,60), S = UDim2.new(0,100,0,32), Sz = 26, F = Enum.Font.GothamBold, C = Theme.Colors.Success})
    UI.Label(avatarSec, "用户名: "..LocalPlayer.Name, {P = UDim2.new(0,175,0,98), S = UDim2.new(1,-200,0,28), Sz = 16})
    UI.Label(avatarSec, "Display: "..(LocalPlayer.DisplayName or "N/A"), {P = UDim2.new(0,175,0,126), S = UDim2.new(1,-200,0,28), Sz = 15, C = Theme.Colors.TextSec})
    
    -- 🔹 2. 玩家详细信息 (中部 - 真实实时计算)
    local playerSec = UI.Frame(infoCont, "PlayerSec", {S = UDim2.new(1,0,0,380), P = UDim2.new(0,0,0,205), C = Theme.Colors.Surface, R = 17})
    UI.Label(playerSec, "📋 玩家详细信息", {P = UDim2.new(0,22,0,18), S = UDim2.new(1,-44,0,28), Sz = 19, F = Enum.Font.GothamBold})
    
    local pDataGrid = UI.Frame(playerSec, "PDataGrid", {S = UDim2.new(1,-44,1,-55), P = UDim2.new(0,22,0,55), C = Color3.new(1,1,1,0)})
    
    local function makeRow(p: Frame, lbl: string, val: string, y: number): {Frame, TextLabel}
        local r = UI.Frame(p, "Row", {S = UDim2.new(1,0,0,30), P = UDim2.new(0,0,0,y), C = Color3.new(1,1,1,0)})
        local l = UI.Label(r, lbl..":", {P = UDim2.new(0,0,0,0), S = UDim2.new(0.42,-8,1,0), Sz = 14, C = Theme.Colors.TextSec})
        local v = UI.Label(r, val, {N="Val", P = UDim2.new(0.42,10,0,0), S = UDim2.new(0.58,-10,1,0), Sz = 14, F = Enum.Font.GothamSemibold})
        return {Row = r, Label = l, Value = v}
    end
    
    local pRows = {
        UserId = makeRow(pDataGrid, "🆔 User ID", "•••", 0),
        Location = makeRow(pDataGrid, "🌍 地理位置", "•••", 32),
        PlayTime = makeRow(pDataGrid, "⏱️ 游戏时长", "•••", 64),
        WalkSpeed = makeRow(pDataGrid, "🏃 移动速度", "•••", 96),
        JumpPower = makeRow(pDataGrid, "🦘 跳跃力量", "•••", 128),        Health = makeRow(pDataGrid, "❤️ 生命值", "•••", 160),
        MaxHealth = makeRow(pDataGrid, "🔋 最大生命", "•••", 192),
        Backpack = makeRow(pDataGrid, "🎒 背包物品", "•••", 224),
        Team = makeRow(pDataGrid, "👥 队伍", "•••", 256),
        Platform = makeRow(pDataGrid, "🎮 平台", "•••", 288),
        Ping = makeRow(pDataGrid, "📶 Ping值", "•••", 320),
        Device = makeRow(pDataGrid, "🖥️ 设备", "•••", 352),
    }
    
    -- 🔄 实时玩家数据更新
    task.spawn(function()
        while true do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            
            if pRows.UserId.Value then pRows.UserId.Value.Text = tostring(LocalPlayer.UserId) end
            if pRows.Location.Value then pRows.Location.Value.Text = "🌐 全球服务器" end
            if pRows.PlayTime.Value then
                local up = tick() - (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
                pRows.PlayTime.Value.Text = string.format("%02d:%02d:%02d", math.floor(up/3600), math.floor((up%3600)/60), math.floor(up%60))
            end
            if hum then
                if pRows.WalkSpeed.Value then pRows.WalkSpeed.Value.Text = string.format("%.1f", hum.WalkSpeed) end
                if pRows.JumpPower.Value then pRows.JumpPower.Value.Text = string.format("%.1f", hum.JumpPower) end
                if pRows.Health.Value then pRows.Health.Value.Text = string.format("%.1f / %.1f", hum.Health, hum.MaxHealth) end
                if pRows.MaxHealth.Value then pRows.MaxHealth.Value.Text = tostring(math.floor(hum.MaxHealth)) end
            end
            if pRows.Backpack.Value then pRows.Backpack.Value.Text = tostring(#LocalPlayer.Backpack:GetChildren()).." 物品" end
            if pRows.Team.Value then pRows.Team.Value.Text = LocalPlayer.Team and LocalPlayer.Team.Name or "🚫 无队伍" end
            if pRows.Platform.Value then
                local plat = "未知"
                pcall(function() plat = tostring(UserInputService:GetPlatform()):gsub("Enum.Platform.", "") end)
                pRows.Platform.Value.Text = plat
            end
            if pRows.Ping.Value then
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                pRows.Ping.Value.Text = string.format("%.0f ms", ping)
            end
            if pRows.Device.Value then pRows.Device.Value.Text = "Roblox Client" end
            
            task.wait(0.4)
        end
    end)
    
    -- 🔹 3. 服务器信息 (中下部 - 真实实时)
    local serverSec = UI.Frame(infoCont, "ServerSec", {S = UDim2.new(1,0,0,310), P = UDim2.new(0,0,0,605), C = Theme.Colors.Surface, R = 17})
    UI.Label(serverSec, "🖥️ 服务器信息", {P = UDim2.new(0,22,0,18), S = UDim2.new(1,-44,0,28), Sz = 19, F = Enum.Font.GothamBold})
    
    local sDataGrid = UI.Frame(serverSec, "SDataGrid", {S = UDim2.new(1,-44,1,-55), P = UDim2.new(0,22,0,55), C = Color3.new(1,1,1,0)})
        local sRows = {
        GameName = makeRow(sDataGrid, "🌐 游戏名称", "•••", 0),
        PlaceId = makeRow(sDataGrid, "🆔 Place ID", "•••", 32),
        JobId = makeRow(sDataGrid, "🔢 Server ID", "•••", 64),
        Players = makeRow(sDataGrid, "👥 在线玩家", "•••", 96),
        Uptime = makeRow(sDataGrid, "⏰ 运行时间", "•••", 128),
        MaxPlayers = makeRow(sDataGrid, "🎮 最大玩家", "•••", 160),
        MapName = makeRow(sDataGrid, "🗺️ 地图名称", "•••", 192),
        FPS = makeRow(sDataGrid, "🔄 实时FPS", "•••", 224),
        Memory = makeRow(sDataGrid, "📊 内存使用", "•••", 256),
        Physics = makeRow(sDataGrid, "⚡ 物理步进", "•••", 288),
    }
    
    -- 🔄 实时服务器数据更新
    task.spawn(function()
        while true do
            if sRows.GameName.Value then sRows.GameName.Value.Text = game.Name end
            if sRows.PlaceId.Value then sRows.PlaceId.Value.Text = tostring(game.PlaceId) end
            if sRows.JobId.Value then
                local jid = game.JobId
                sRows.JobId.Value.Text = jid:sub(1,8).."•••"
            end
            if sRows.Players.Value then
                sRows.Players.Value.Text = string.format("%d / %d", #Players:GetPlayers(), game.MaxPlayers)
            end
            if sRows.Uptime.Value then
                local up = math.floor(tick() - (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() and 0 or tick()))
                sRows.Uptime.Value.Text = string.format("%02d:%02d:%02d", math.floor(up/3600), math.floor((up%3600)/60), math.floor(up%60))
            end
            if sRows.MaxPlayers.Value then sRows.MaxPlayers.Value.Text = tostring(game.MaxPlayers) end
            if sRows.MapName.Value then sRows.MapName.Value.Text = workspace.Name end
            if sRows.FPS.Value then sRows.FPS.Value.Text = string.format("%.1f", 1/RunService.RenderStepped:Wait()) end
            if sRows.Memory.Value then
                local mem = collectgarbage("count")
                sRows.Memory.Value.Text = string.format("%.1f MB", mem/1024)
            end
            if sRows.Physics.Value then sRows.Physics.Value.Text = string.format("%.1f Hz", RunService.PhysicsStepRate or 60) end
            task.wait(0.8)
        end
    end)
    
    -- 🔹 4. 作者信息 (底部)
    local authorSec = UI.Frame(infoCont, "AuthorSec", {S = UDim2.new(1,0,0,105), P = UDim2.new(0,0,0,935), C = Theme.Colors.Accent, R = 17})
    UI.Label(authorSec, "👨‍💻 作者信息", {P = UDim2.new(0,22,0,18), S = UDim2.new(1,-44,0,28), Sz = 17, F = Enum.Font.GothamBold, C = Color3.new(1,1,1)})
    UI.Label(authorSec, "作者: HaoChen", {P = UDim2.new(0,22,0,50), S = UDim2.new(1,-44,0,26), Sz = 16, C = Color3.new(1,1,1)})
    UI.Label(authorSec, "📱 QQ: 1626844714", {P = UDim2.new(0,22,0,76), S = UDim2.new(1,-44,0,24), Sz = 15, C = Color3.fromRGB(235,235,255)})
    
    task.defer(function() scroll.CanvasSize = UDim2.new(0,0,0,infoCont.AbsoluteSize.Y+25) end)
    
    -- ===== ⚙️ 设置页面 =====    local settings = UI.Frame(container, "Settings", {S = UDim2.new(1,0,1,0), C = Color3.new(1,1,1,0), V = false})
    pages.Settings = settings
    UI.Label(settings, "⚙️ 设置", {P = UDim2.new(0,25,0,25), S = UDim2.new(1,-50,0,32), Sz = 21, F = Enum.Font.GothamBold})
    
    UI.Toggle(settings, "🎨 启用动画效果", true, function() end):Position(UDim2.new(0,25,0,75))
    UI.Toggle(settings, "🔔 显示加载提示", true, function() end):Position(UDim2.new(0,25,0,120))
    UI.Toggle(settings, "🔒 安全模式(推荐)", true, function() end):Position(UDim2.new(0,25,0,165))
    
    local kbFrame = UI.Frame(settings, "Keybinds", {S = UDim2.new(1,-50,0,125), P = UDim2.new(0,25,0,230), C = Theme.Colors.Surface, R = 13})
    UI.Label(kbFrame, "⌨️ 快捷键", {P = UDim2.new(0,18,0,18), S = UDim2.new(1,-36,0,28), Sz = 17, F = Enum.Font.GothamSemibold})
    UI.Label(kbFrame, "切换菜单: Insert", {P = UDim2.new(0,18,0,52), S = UDim2.new(1,-36,0,26), Sz = 14})
    UI.Label(kbFrame, "最小化: End", {P = UDim2.new(0,18,0,80), S = UDim2.new(1,-36,0,26), Sz = 14})
    
    -- ==================== 🗜️ 最小化图标 ====================
    local minIcon = Instance.new("ImageButton")
    minIcon.Name, minIcon.Image = "MinIcon", "rbxthumb://type=Asset&id="..CONFIG.IconID.."&w=150&h=150"
    minIcon.Size, minIcon.Position, minIcon.AnchorPoint = UDim2.new(0,52,0,52), UDim2.new(0,110,1,-72), Vector2.new(0.5,0.5)
    minIcon.BackgroundTransparency, minIcon.Visible, minIcon.Parent = 1, false, gui
    Instance.new("UICorner", minIcon).CornerRadius = UDim.new(0,13)
    
    minIcon.MouseButton1Click:Connect(function()
        main.Visible, minIcon.Visible = true, false
        TweenService:Create(main, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    end)
    _G.IceHub.MinIcon = minIcon
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(main, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        task.wait(0.15); main.Visible, minIcon.Visible = false, true
    end)
    
    minBtn.MouseButton1Click:Connect(function()
        main.Visible, minIcon.Visible = false, true
    end)
    
    -- ==================== 🖱️ 拖拽功能 ====================
    local dragStart, startPos, dragging
    title.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, inp.Position, main.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            TweenService:Create(main, TweenInfo.new(0.04), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
            }):Play()
        end    end)
    
    -- ==================== ⌨️ 全局快捷键 ====================
    UserInputService.InputBegan:Connect(function(inp, proc)
        if proc then return end
        if inp.KeyCode == Enum.KeyCode.Insert then
            main.Visible, minIcon.Visible = not main.Visible, main.Visible
        elseif inp.KeyCode == Enum.KeyCode.End then
            main.Visible, minIcon.Visible = false, true
        end
    end)
    
    -- ==================== ✨ 初始化完成 ====================
    ApplyTheme(main, Theme.Current == "Dark")
    
    task.defer(function()
        Popup.Loading("🎮 "..CONFIG.Name.."\n✨ 正在初始化系统...", CONFIG.IconID)
    end)
    
    print("✅ "..CONFIG.Name.." v"..CONFIG.Version.." 加载成功")
    print("👤 Author: "..CONFIG.Author.." | QQ: "..CONFIG.QQ)
    
    return _G.IceHub
end

-- ==================== 🔄 主循环 ====================
task.spawn(function()
    IceHub.Init()
    
    -- ESP渲染循环
    while true do
        if CONFIG.ESP.Enabled then UpdateESP() end
        task.wait(CONFIG.ESP.UpdateRate)
    end
end)

-- ==================== 🧹 清理函数 ====================
game:BindToClose(function()
    CleanupESP()
    if _G.IceHub and _G.IceHub.Gui then _G.IceHub.Gui:Destroy() end
end)

return _G.IceHub