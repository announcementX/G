-- 星空风格模型替换脚本
-- 功能：输入模型ID和大小，切换角色模型（所有人可见）
-- 使用方法：执行脚本后出现悬浮窗，输入ID和大小，点击切换即可变身

-- 创建主界面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModelSwapperGUI"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- 圆角处理
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- 星空效果：动态粒子
local starField = Instance.new("Frame")
starField.Name = "StarField"
starField.Size = UDim2.new(1, 0, 1, 0)
starField.BackgroundTransparency = 1
starField.Parent = mainFrame

-- 创建星星粒子
for i = 1, 100 do
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(1, 3), 0, math.random(1, 3))
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    star.BackgroundTransparency = math.random(30, 80) / 100
    star.BorderSizePixel = 0
    star.Parent = starField
    
    -- 闪烁动画
    local twinkle = game:GetService("TweenService"):Create(
        star,
        TweenInfo.new(math.random(2, 5), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = math.random(50, 95) / 100}
    )
    twinkle:Play()
end

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ 模型变身器 ✨"
title.TextColor3 = Color3.fromRGB(200, 180, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextScaled = false
title.Parent = mainFrame

-- 模型ID输入框标签
local idLabel = Instance.new("TextLabel")
idLabel.Size = UDim2.new(0.9, 0, 0, 25)
idLabel.Position = UDim2.new(0.05, 0, 0, 50)
idLabel.BackgroundTransparency = 1
idLabel.Text = "🎨 模型ID (Asset ID):"
idLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
idLabel.TextSize = 14
idLabel.Font = Enum.Font.Gotham
idLabel.TextXAlignment = Enum.TextXAlignment.Left
idLabel.Parent = mainFrame

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(0.9, 0, 0, 35)
idBox.Position = UDim2.new(0.05, 0, 0, 75)
idBox.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
idBox.BackgroundTransparency = 0.3
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.TextSize = 14
idBox.Font = Enum.Font.Gotham
idBox.PlaceholderText = "例如: 1234567890"
idBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
idBox.Text = ""
idBox.ClearTextOnFocus = false
idBox.Parent = mainFrame

local idCorner = Instance.new("UICorner")
idCorner.CornerRadius = UDim.new(0, 8)
idCorner.Parent = idBox

-- 大小输入框标签
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(0.9, 0, 0, 25)
sizeLabel.Position = UDim2.new(0.05, 0, 0, 115)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "📏 模型大小:"
sizeLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
sizeLabel.TextSize = 14
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.Parent = mainFrame

local sizeBox = Instance.new("TextBox")
sizeBox.Size = UDim2.new(0.9, 0, 0, 35)
sizeBox.Position = UDim2.new(0.05, 0, 0, 140)
sizeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
sizeBox.BackgroundTransparency = 0.3
sizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeBox.TextSize = 14
sizeBox.Font = Enum.Font.Gotham
sizeBox.PlaceholderText = "例如: 1 (1=原始大小)"
sizeBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
sizeBox.Text = "1"
sizeBox.ClearTextOnFocus = false
sizeBox.Parent = mainFrame

local sizeCorner = Instance.new("UICorner")
sizeCorner.CornerRadius = UDim.new(0, 8)
sizeCorner.Parent = sizeBox

-- 按钮容器
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(0.9, 0, 0, 40)
buttonFrame.Position = UDim2.new(0.05, 0, 0, 185)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- 切换按钮
local swapBtn = Instance.new("TextButton")
swapBtn.Size = UDim2.new(0.45, -5, 1, 0)
swapBtn.Position = UDim2.new(0, 0, 0, 0)
swapBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
swapBtn.Text = "✨ 切换模型"
swapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
swapBtn.TextSize = 14
swapBtn.Font = Enum.Font.GothamBold
swapBtn.Parent = buttonFrame

local swapCorner = Instance.new("UICorner")
swapCorner.CornerRadius = UDim.new(0, 8)
swapCorner.Parent = swapBtn

-- 重置按钮
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.45, -5, 1, 0)
resetBtn.Position = UDim2.new(0.55, 0, 0, 0)
resetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
resetBtn.Text = "🔄 重置模型"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 14
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Parent = buttonFrame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetBtn

-- 状态标签
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 230)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ 就绪"
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = mainFrame

-- 使窗口可拖动
local dragging = false
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 核心功能：替换模型
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = nil
local originalModel = nil
local currentModel = nil
local isSwapped = false

-- 获取角色
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- 保存原始模型
local function saveOriginalModel(character)
    if originalModel then
        originalModel:Destroy()
        originalModel = nil
    end
    originalModel = character:Clone()
    originalModel.Name = "OriginalModelBackup"
    originalModel.Parent = nil
end

-- 重置模型
local function resetModel()
    if not isSwapped then
        statusLabel.Text = "⚠️ 当前已是原始模型"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.wait(1.5)
        statusLabel.Text = "⚡ 就绪"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        return
    end
    
    local char = getCharacter()
    if not char then
        statusLabel.Text = "❌ 无法获取角色"
        return
    end
    
    -- 移除当前模型
    if currentModel then
        pcall(function()
            currentModel:Destroy()
        end)
        currentModel = nil
    end
    
    -- 恢复原始模型
    if originalModel then
        local newModel = originalModel:Clone()
        newModel.Name = char.Name
        newModel.Parent = char.Parent
        
        -- 复制位置和朝向
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local newRoot = newModel:FindFirstChild("HumanoidRootPart")
            if newRoot then
                newRoot.CFrame = rootPart.CFrame
            end
        end
        
        char:Destroy()
        character = newModel
        isSwapped = false
        
        statusLabel.Text = "✅ 已重置为原始模型"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(2)
        statusLabel.Text = "⚡ 就绪"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    else
        statusLabel.Text = "⚠️ 无原始模型备份"
    end
end

-- 切换模型
local function swapModel(modelId, scaleValue)
    if not modelId or modelId == "" then
        statusLabel.Text = "❌ 请输入模型ID"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        statusLabel.Text = "⚡ 就绪"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        return
    end
    
    -- 验证ID是否为数字
    local idNum = tonumber(modelId)
    if not idNum then
        statusLabel.Text = "❌ 模型ID必须是数字"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1.5)
        statusLabel.Text = "⚡ 就绪"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        return
    end
    
    local scale = tonumber(scaleValue) or 1
    if scale <= 0 then scale = 1 end
    
    statusLabel.Text = "🔄 正在加载模型..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local char = getCharacter()
    if not char then
        statusLabel.Text = "❌ 无法获取角色"
        return
    end
    
    -- 保存原始模型（如果还没保存）
    if not originalModel then
        saveOriginalModel(char)
    end
    
    -- 加载新模型
    local modelUrl = "rbxassetid://" .. idNum
    local newModel = game:GetService("InsertService"):LoadAsset(idNum)
    
    if not newModel or not newModel:IsA("Model") then
        statusLabel.Text = "❌ 加载失败，请检查ID"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(2)
        statusLabel.Text = "⚡ 就绪"
        statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        return
    end
    
    -- 处理模型层级
    local mainModel = newModel
    if newModel:FindFirstChildWhichIsA("Model") then
        mainModel = newModel:FindFirstChildWhichIsA("Model")
    end
    
    mainModel.Parent = nil
    newModel:Destroy()
    
    -- 设置模型缩放
    if scale ~= 1 then
        for _, part in ipairs(mainModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = part.Size * scale
                local attachment = part:FindFirstChildWhichIsA("Attachment")
                if attachment then
                    -- 调整附件位置
                end
            end
        end
    end
    
    -- 复制位置
    local oldRoot = char:FindFirstChild("HumanoidRootPart")
    if oldRoot then
        local newRoot = mainModel:FindFirstChild("HumanoidRootPart") or mainModel:FindFirstChildWhichIsA("BasePart")
        if newRoot then
            newRoot.CFrame = oldRoot.CFrame
        end
    end
    
    -- 复制Humanoid属性（保持生命值等）
    local oldHumanoid = char:FindFirstChild("Humanoid")
    local newHumanoid = mainModel:FindFirstChild("Humanoid")
    if oldHumanoid and newHumanoid then
        newHumanoid.Health = oldHumanoid.Health
        newHumanoid.MaxHealth = oldHumanoid.MaxHealth
        newHumanoid.WalkSpeed = oldHumanoid.WalkSpeed
        newHumanoid.JumpPower = oldHumanoid.JumpPower
    end
    
    -- 替换角色
    mainModel.Name = char.Name
    mainModel.Parent = char.Parent
    
    -- 清理旧角色
    if currentModel then
        pcall(function()
            currentModel:Destroy()
        end)
    end
    
    char:Destroy()
    character = mainModel
    currentModel = mainModel
    isSwapped = true
    
    statusLabel.Text = "✅ 变身成功！"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    task.wait(2)
    statusLabel.Text = "⚡ 就绪"
    statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
end

-- 按钮事件
swapBtn.MouseButton1Click:Connect(function()
    local modelId = idBox.Text
    local size = sizeBox.Text
    swapModel(modelId, size)
end)

resetBtn.MouseButton1Click:Connect(function()
    resetModel()
end)

-- 处理角色重生
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    
    -- 如果当前是替换状态，重新应用模型
    if isSwapped and currentModel then
        task.wait(0.5)  -- 等待角色完全加载
        local oldRoot = newChar:FindFirstChild("HumanoidRootPart")
        if oldRoot and currentModel:FindFirstChild("HumanoidRootPart") then
            currentModel:FindFirstChild("HumanoidRootPart").CFrame = oldRoot.CFrame
        end
        
        -- 复制生命值
        local oldHumanoid = newChar:FindFirstChild("Humanoid")
        local newHumanoid = currentModel:FindFirstChild("Humanoid")
        if oldHumanoid and newHumanoid then
            newHumanoid.Health = oldHumanoid.Health
        end
        
        newChar:Destroy()
        currentModel.Parent = currentModel.Parent
        character = currentModel
    end
end)

-- 显示启动提示
statusLabel.Text = "✨ 模型变身器已加载"
statusLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
task.wait(2)
statusLabel.Text = "⚡ 就绪"
statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)

print("星空模型变身器已加载 - 输入模型ID和大小即可变身")