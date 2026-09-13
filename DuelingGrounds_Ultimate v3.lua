-- [[ Dueling Grounds: Spark Edition V3 (Auto Parry, God Mode, Weapon Unlock) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoParry = true,
    ParryDistance = 11,
    ParryCooldown = 0.35,
    WalkSpeedValue = 28,
    SpeedBoost = false,
    GodMode = false,
    UnlockWeapons = false
}

local lastParryTime = 0
local godConnection = nil

-- ฟังก์ชันจำลองการกดปุ่ม F (Parry)
local function triggerParry()
    local currentTime = tick()
    if currentTime - lastParryTime >= Settings.ParryCooldown then
        lastParryTime = currentTime
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- 1. ฟังก์ชัน God Mode (โหมดอมตะ)
local function applyGodMode(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 3)
    if humanoid then
        humanoid.SetStateEnabled(humanoid, Enum.HumanoidStateType.Dead, false)
        if godConnection then godConnection:Disconnect() end
        godConnection = humanoid.HealthChanged:Connect(function(health)
            if Settings.GodMode and health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if Settings.GodMode then
        task.wait(0.5)
        applyGodMode(char)
    end
end)

-- 2. ฟังก์ชัน ปลดล็อกอาวุธทั้งหมด (Unlock Roblox/Gamepass Weapons)
local function unlockAllWeapons()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end

    -- ค้นหาอาวุธจาก ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            if not backpack:FindFirstChild(obj.Name) and (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild(obj.Name)) then
                local clonedTool = obj:Clone()
                clonedTool.Parent = backpack
            end
        end
    end
end

-- ระบบตรวจจับจังหวะการโจมตี (Auto Parry Logic)
RunService.RenderStepped:Connect(function()
    if Settings.AutoParry and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
                                if velocity > 15 then
                                    triggerParry()
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Speed Boost
    if Settings.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
    end
    
    -- Maintain God Mode Health
    if Settings.GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

-- สร้าง Mobile GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SparkHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "⚡ Spark Hub V3"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function createToggleButton(text, posY, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
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

-- ปุ่มเปิด/ปิด ฟังก์ชันต่างๆ บนหน้าต่าง UI
createToggleButton("Auto Parry", 40, Settings.AutoParry, function(val)
    Settings.AutoParry = val
end)

createToggleButton("God Mode (พระเจ้า)", 80, Settings.GodMode, function(val)
    Settings.GodMode = val
    if val and LocalPlayer.Character then
        applyGodMode(LocalPlayer.Character)
    end
end)

createToggleButton("Unlock Weapons (ปลดอาวุธ)", 120, Settings.UnlockWeapons, function(val)
    Settings.UnlockWeapons = val
    if val then
        unlockAllWeapons()
    end
end)

createToggleButton("Speed Boost (วิ่งเร็ว)", 160, Settings.SpeedBoost, function(val)
    Settings.SpeedBoost = val
    if not val and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)
