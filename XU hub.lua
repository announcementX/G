--[[
    NEBULA UI INTERFACE - STARLIGHT EDITION
    UI 库来源: https://raw.githubusercontent.com/announcementX/G/main/ui.lua
    功能：仅用于加载并展示悬浮窗界面
]]

-- [ 1. 引用你的 GitHub 原始代码 ]
local LibraryURL = "https://raw.githubusercontent.com/announcementX/G/main/ui.lua"
local Success, Nebula = pcall(function()
    return loadstring(game:HttpGet(LibraryURL))()
end)

-- 如果加载失败的友好提示
if not Success or not Nebula then
    warn("无法从 GitHub 获取 UI 库，请检查您的网络或链接是否正确。")
    return
end

-- [ 2. 初始化悬浮窗主界面 ]
-- 你可以在这里修改名字，它会显示在左上角
local Window = Nebula:Init({
    Name = "NEBULA EXECUTOR", 
    ConfigFolder = "Nebula_Demo"
})

-- [ 3. 创建演示选项卡 (Tabs) ]
-- 这里的图标 ID 使用了 Roblox 官方的通用图标
local MainTab = Window:CreateTab("主控制台", "rbxassetid://6023426915")
local VisualTab = Window:CreateTab("视觉效果", "rbxassetid://6034287535")
local SettingsTab = Window:CreateTab("全局设置", "rbxassetid://6031289153")

-- [ 4. 在“主控制台”添加演示组件 ]
local GeneralSection = MainTab:CreateSection("基础开关演示")

GeneralSection:CreateToggle("启用星空粒子", "StarParticles", true, function(state)
    Window:Notify("系统", "背景粒子效果已" .. (state and "开启" or "关闭"), 2)
end)

GeneralSection:CreateSlider("UI 透明度调节", "UI_Opacity", 0, 100, 0, function(val)
    -- 这里只是演示滑动条交互
end)

local ActionSection = MainTab:CreateSection("动作触发")
ActionSection:CreateButton("发送测试通知", function()
    Window:Notify("提醒", "这是一个工业级的全屏通知效果！", 4)
end)

-- [ 5. 在“视觉效果”添加组件 ]
local ThemeSection = VisualTab:CreateSection("界面风格选择")
ThemeSection:CreateDropdown("预设主题", "UI_Theme", {"深邃星空", "极光紫", "幽灵蓝", "日落红"}, function(selected)
    Window:Notify("主题更新", "已切换至: " .. selected, 2)
end)

-- [ 6. 在“全局设置”添加退出和隐藏 ]
local SystemSection = SettingsTab:CreateSection("窗口管理")

SystemSection:CreateKeybind("隐藏/显示 菜单", "MenuBind", Enum.KeyCode.RightControl, function()
    -- 库内部通常已处理按键监听，这里可以写额外逻辑
    Window:Notify("快捷键", "您按下了切换键", 1)
end)

SystemSection:CreateButton("安全销毁 UI", function()
    Window:Notify("警告", "正在清理 UI 资源...", 2)
    task.wait(1)
    -- 查找并销毁 ScreenGui
    local core = game:GetService("CoreGui")
    for _, v in pairs(core:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:find("-") then -- 根据 GUID 特征销毁
            v:Destroy()
        end
    end
end)

-- [ 7. 加载完成后的欢迎语 ]
Window:Notify("加载成功", "欢迎使用 Project Nebula，按 RightControl 切换显示。", 5)

-- 如果之前保存过配置，自动加载
pcall(function()
    Window:LoadConfig("Nebula_Demo")
end)
