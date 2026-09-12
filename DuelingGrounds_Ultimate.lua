-- [[ Dueling Grounds Ultimate All-In-One Script ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ค่าเริ่มต้นของฟังก์ชัน
local Settings = {
    AutoParry = true,
    TargetLock = false,
    SpeedBoost = false,
    ParryDistance = 14,
    WalkSpeedValue = 28
}

-- 1. สร้างหน้าต่างเมนูบนหน้าจอมือถือ (Mobile UI)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ParryBtn = Instance.new("TextButton")
local LockBtn = Instance.new("TextButton")
local SpeedBtn = Instance.new("TextButton")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 160, 0, 180)
Frame.Active = true
Frame.Draggable = true -- ลากย้ายตำแหน่งบนมือถือได้

Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "⚔️ DUELING HUB ⚔️"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14

local function createButton(text, pos, parent)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    return btn
end

ParryBtn = createButton("Auto Parry: ON", UDim2.new(0.05, 0, 0.22, 0), Frame)
ParryBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)

LockBtn = createButton("Target Lock: OFF", UDim2.new(0.05, 0, 0.47, 0), Frame)
LockBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)

SpeedBtn = createButton("Speed Boost: OFF", UDim2.new(0.05, 0, 0.72, 0), Frame)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)

-- 2. ฟังก์ชันค้นหาศัตรูใกล้ตัวที่สุด
local function getClosestEnemy()
    local closest, shortestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local dist = (p.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest, shortestDist
end

-- 3. ระบบ Auto Parry (กด F บล็อกอัตโนมัติ)
local function triggerParry()
    if keypress then
        keypress(0x46) -- Virtual Key F
        task.wait(0.05)
        keyrelease(0x46)
    end
end

RunService.Heartbeat:Connect(function()
    if not Settings.AutoParry then return end
    
    local enemy, dist = getClosestEnemy()
    if enemy and dist <= Settings.ParryDistance then
        local animator = enemy.Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                -- ตรวจจับ Animation การเงื้อดาบ/โจมตี
                if track.IsPlaying and track.TimePosition < 0.35 then
                    triggerParry()
                    break
                end
            end
        end
    end
end)

-- 4. ระบบ Target Lock (หันกล้องหาศัตรู) & Speed Boost
RunService.RenderStepped:Connect(function()
    -- หันกล้อง
    if Settings.TargetLock then
        local enemy = getClosestEnemy()
        if enemy and enemy:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemy.HumanoidRootPart.Position)
        end
    end
    
    -- เพิ่มความเร็ว
    if Settings.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
    end
end)

-- 5. ระบบปุ่มกด Event Listeners
ParryBtn.MouseButton1Click:Connect(function()
    Settings.AutoParry = not Settings.AutoParry
    ParryBtn.Text = "Auto Parry: " .. (Settings.AutoParry and "ON" or "OFF")
    ParryBtn.BackgroundColor3 = Settings.AutoParry and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
end)

LockBtn.MouseButton1Click:Connect(function()
    Settings.TargetLock = not Settings.TargetLock
    LockBtn.Text = "Target Lock: " .. (Settings.TargetLock and "ON" or "OFF")
    LockBtn.BackgroundColor3 = Settings.TargetLock and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    Settings.SpeedBoost = not Settings.SpeedBoost
    SpeedBtn.Text = "Speed Boost: " .. (Settings.SpeedBoost and "ON" or "OFF")
    SpeedBtn.BackgroundColor3 = Settings.SpeedBoost and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
    if not Settings.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)
