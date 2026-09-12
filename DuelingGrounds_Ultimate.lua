-- [[ Dueling Grounds Ultimate - Weapon Proximity Parry ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ค่าเริ่มต้นของฟังก์ชัน
local Settings = {
    AutoParry = true,
    TargetLock = false,
    SpeedBoost = false,
    ParryDistance = 8, -- ระยะห่างของ "อาวุธศัตรู" ที่เข้ามาใกล้ตัวเรา (หน่วย studs)
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
Frame.Draggable = true

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
    return closest
end

-- 3. ระบบจำลองการกดปุ่ม Parry (กด F)
local lastParryTime = 0
local function triggerParry()
    -- ป้องกันการกด Parry รัวเกินไป (Cooldown 0.3 วิ)
    if tick() - lastParryTime > 0.3 then
        lastParryTime = tick()
        if keypress then
            keypress(0x46) -- Virtual Key F
            task.wait(0.05)
            keyrelease(0x46)
        end
    end
end

-- 4. ระบบตรวจจับตำแหน่งอาวุธศัตรูเข้าใกล้ (Weapon Proximity Auto Parry)
RunService.Heartbeat:Connect(function()
    if not Settings.AutoParry then return end
    
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local enemy = getClosestEnemy()
    if enemy then
        -- หาวัตถุที่เป็นอาวุธ (Tool / Weapon / Handle) ในตัวศัตรู
        local weapon = enemy:FindFirstChildOfClass("Tool") or enemy:FindFirstChild("Weapon") or enemy:FindFirstChild("Blade")
        local weaponPart = nil

        if weapon then
            weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("MeshPart") or weapon:FindFirstChildOfClass("Part")
        else
            -- ถ้าไม่พบ Tool ให้เช็กที่มือขวาของศัตรู ( Right Hand / RightArm )
            weaponPart = enemy:FindFirstChild("RightHand") or enemy:FindFirstChild("Right Arm")
        end

        -- ถ้าเจออาวุธหรือมือศัตรู ให้คำนวณระยะห่างกับตัวเรา
        if weaponPart then
            local distanceToWeapon = (weaponPart.Position - myChar.HumanoidRootPart.Position).Magnitude
            
            -- เมื่ออาวุธศัตรูเข้าใกล้ตัวเราเกินระยะที่กำหนด สั่ง Parry ทันที
            if distanceToWeapon <= Settings.ParryDistance then
                triggerParry()
            end
        end
    end
end)

-- 5. ระบบ Target Lock (หันกล้องหาศัตรู) & Speed Boost
RunService.RenderStepped:Connect(function()
    if Settings.TargetLock then
        local enemy = getClosestEnemy()
        if enemy and enemy:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemy.HumanoidRootPart.Position)
        end
    end
    
    if Settings.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeedValue
    end
end)

-- 6. ระบบปุ่มกด UI Event Listeners
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
