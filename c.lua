-- 这是一个极简调试脚本，用于验证GUI是否能被创建
local DebugGui = Instance.new("ScreenGui")
DebugGui.Name = "DebugGUI"
DebugGui.Parent = game:GetService("CoreGui") -- 直接放在CoreGui下，跳过PlayerGui加载逻辑
DebugGui.ResetOnSpawn = false

local DebugFrame = Instance.new("Frame")
DebugFrame.Size = UDim2.new(0, 300, 0, 200)
DebugFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
DebugFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
DebugFrame.Parent = DebugGui

local DebugText = Instance.new("TextLabel")
DebugText.Size = UDim2.new(1, 0, 1, 0)
DebugText.BackgroundTransparency = 1
DebugText.Text = "如果你能看到这个红框，说明脚本执行环境正常"
DebugText.TextColor3 = Color3.fromRGB(255, 255, 255)
DebugText.Parent = DebugFrame

print("调试脚本已执行，GUI应该已经显示。")