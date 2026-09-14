-- [[ Dueling Grounds: Spark Edition V3 (God Parry & High Speed) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    GodParry = true,
    ParryDistance = 12,
    ParryCooldown = 0.25,
    SpeedBoost = false,
    WalkSpeedValue = 32
}

local lastParryTime = 0

local function triggerParry()
    local currentTime = tick()
    if currentTime - lastParryTime >= Settings.ParryCooldown then
        lastParryTime = currentTime
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- ระบบตรวจจับการง้างฟันระดับสูง (God Parry Logic)
RunService.RenderStepped:Connect(function()
    if not Settings.GodParry or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end

    local myHRP = LocalPlayer.Character.HumanoidRootPart

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyChar = player.Character
            local enemyHRP = enemyChar.HumanoidRootPart
            local distance = (myHRP.Position - enemyHRP.Position).Magnitude

            if distance <= Settings.ParryDistance then
                local tool = enemyChar:FindFirstChildOfClass("Tool")
                if tool then
                    for _, part in pairs(tool:GetChildren()) do
                        if part:IsA("BasePart") then
                            local velocity = part.AssemblyLinearVelocity.Magnitude
                            if velocity > 12 then -- ตรวจจับความเร็วอาวุธขณะเหวี่ยง
                                triggerParry()
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if Settings.SpeedBoost and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
    end
end)

-- Создать Mobile GUI (หน้าต่างเมนูสไตล์ Spark Hub)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SparkHubV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 190)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "⚡ SPARK HUB V3 (ULTIMATE)"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function createToggleButton(text, posY, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.Position = UDim2.new(0.075, 0, 0, posY)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = text .. (defaultState and ": ON" or ": OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
        btn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

createToggleButton("God Auto Parry", 50, Settings.GodParry, function(val)
    Settings.GodParry = val
end)

createToggleButton("Speed Boost (32)", 100, Settings.SpeedBoost, function(val)
    Settings.SpeedBoost = val
    if not val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)
