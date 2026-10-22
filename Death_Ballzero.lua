-- ================================================================= --
-- [[ DEATH BALL: ULTIMATE ADVANCED PARRY HUB ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 20)

-- ลบ UI เก่าป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("DeathBallAdvancedUI") then
    PlayerGui:FindFirstChild("DeathBallAdvancedUI"):Destroy()
end

local Settings = {
    AutoParry = false,
    ParryRange = 100,
    ShowZoneCircle = true,
    ClutchSpeed = 0.01,
    InfJump = false
}

-- ================================================================= --
-- [[ 1. วาดวงกลมโซน 3D ล้อมรอบตัวผู้เล่น (Parry Zone Circle) ]] --
-- ================================================================= --

local ZonePart = Instance.new("Part")
ZonePart.Name = "ParryZoneVisual"
ZonePart.Shape = Enum.PartType.Cylinder
ZonePart.Material = Enum.Material.Neon
ZonePart.Color = Color3.fromRGB(52, 152, 219)
ZonePart.Transparency = 0.7
ZonePart.Anchored = true
ZonePart.CanCollide = false
ZonePart.CastShadow = false

local function updateZoneVisual()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and Settings.ShowZoneCircle and Settings.AutoParry then
        ZonePart.Parent = Workspace
        ZonePart.Size = Vector3.new(0.2, Settings.ParryRange * 2, Settings.ParryRange * 2)
        ZonePart.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90))
    else
        ZonePart.Parent = nil
    end
end

-- ================================================================= --
-- [[ 2. ระบบ AUTO PARRY + ล่องหนเช็ก 1 LIFE CLUTCH (0.01s) ]] --
-- ================================================================= --

local function getBall()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "DeathBall" or obj:FindFirstChild("Velocity")) then
            return obj
        end
    end
    return nil
end

local function triggerParry()
    pcall(function()
        VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.F, false)
        task.wait(0.005)
        VirtualInputManager:SendKeyReleaseEvent(Enum.KeyCode.F, false)
    end)
end

local function getPlayerLives()
    local lives = 3
    local char = LocalPlayer.Character
    if char then
        local livesObj = char:FindFirstChild("Lives") or LocalPlayer:FindFirstChild("Lives")
        if livesObj then
            lives = tonumber(livesObj.Value) or lives
        end
    end
    return lives
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        updateZoneVisual()

        if Settings.AutoParry then
            local ball = getBall()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if ball and hrp then
                local distance = (ball.Position - hrp.Position).Magnitude
                local currentLives = getPlayerLives()

                -- 🛑 ระบบล่องหนทำงานอัตโนมัติ: ถ้าชีวิตเหลือ 1 จะตีสวนทันทีใน 0.01s
                if currentLives <= 1 then
                    ZonePart.Color = Color3.fromRGB(231, 76, 60)
                    if distance <= (Settings.ParryRange + 15) then
                        task.spawn(function()
                            task.wait(Settings.ClutchSpeed)
                            triggerParry()
                        end)
                    end
                else
                    ZonePart.Color = Color3.fromRGB(52, 152, 219)
                    if distance <= Settings.ParryRange then
                        triggerParry()
                    end
                end
            end
        end
    end)
end)

-- ================================================================= --
-- [[ 3. ฟังก์ชันปลดล็อกสกินดาบทั้งหมด + กิจกรรม Halloween ]] --
-- ================================================================= --

local function unlockAllSwords()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local swordData = ReplicatedStorage:FindFirstChild("Swords") or ReplicatedStorage:FindFirstChild("Skins")
        if swordData then
            for _, sword in pairs(swordData:GetChildren()) do
                local val = Instance.new("BoolValue")
                val.Name = "Unlocked"
                val.Value = true
                val.Parent = sword
            end
        end
    end)
end

-- ================================================================= --
-- [[ 4. หน้าต่างควบคุม GUI ในเมนู ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeathBallAdvancedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "⚽ DEATH BALL HUB"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function createButton(posY, bgColor, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- 1. ปุ่มเปิด/ปิด Auto Parry
createButton(40, Color3.fromRGB(192, 57, 43), "⚡ Auto Parry + Circle Zone: OFF", function(btn)
    Settings.AutoParry = not Settings.AutoParry
    btn.BackgroundColor3 = Settings.AutoParry and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "⚡ Auto Parry + Circle Zone: " .. (Settings.AutoParry and "ON" or "OFF")
end)

-- 2. ปุ่มปรับขนาดวงกลมโซน (50 -> 100 -> 150 -> 200)
local currentRangeState = 2
createButton(80, Color3.fromRGB(52, 152, 219), "🎯 ปรับขนาดโซน Parry: 100", function(btn)
    if currentRangeState == 1 then
        Settings.ParryRange = 100
        btn.Text = "🎯 ปรับขนาดโซน Parry: 100"
        currentRangeState = 2
    elseif currentRangeState == 2 then
        Settings.ParryRange = 150
        btn.Text = "🎯 ปรับขนาดโซน Parry: 150"
        currentRangeState = 3
    elseif currentRangeState == 3 then
        Settings.ParryRange = 200
        btn.Text = "🎯 ปรับขนาดโซน Parry: 200 (MAX)"
        currentRangeState = 4
    else
        Settings.ParryRange = 50
        btn.Text = "🎯 ปรับขนาดโซน Parry: 50 (MIN)"
        currentRangeState = 1
    end
end)

-- 3. ปุ่มปลดล็อกสกินดาบทั้งหมด
createButton(120, Color3.fromRGB(155, 89, 182), "🎃 ปลดล็อกสกินดาบทั้งหมด + Halloween", function(btn)
    unlockAllSwords()
    btn.Text = "✅ ปลดล็อกสกินดาบทั้งหมดเรียบร้อย!"
end)

-- 4. ปุ่ม Infinity Jump
createButton(160, Color3.fromRGB(230, 126, 34), "🦘 Infinity Jump (กระโดดรัว): OFF", function(btn)
    Settings.InfJump = not Settings.InfJump
    btn.BackgroundColor3 = Settings.InfJump and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(230, 126, 34)
    btn.Text = "🦘 Infinity Jump (กระโดดรัว): " .. (Settings.InfJump and "ON" or "OFF")
end)

-- ระบบ Infinity Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("🚀 Death Ball Hub Loaded Successfully!")
