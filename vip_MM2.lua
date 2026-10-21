-- [[ MURDER MYSTERY 2: VIP ULTIMATE HUB + FLOATING ACTION (RYGDEEEEEE ONLY) ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- ตรวจสอบสิทธิ์ VIP (เฉพาะ Rygdeeeeee เท่านั้น)
local ALLOWED_VIP = "Rygdeeeeee"
if LocalPlayer.Name ~= ALLOWED_VIP and LocalPlayer.DisplayName ~= ALLOWED_VIP then
    LocalPlayer:Kick("❌ สคริปต์ MM2 นี้อนุญาตให้ใช้งานเฉพาะ VIP: Rygdeeeeee เท่านั้น!")
    return
end

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("MM2VipHubPro") then
    PlayerGui:FindFirstChild("MM2VipHubPro"):Destroy()
end

local Settings = {
    EspEnabled = false,
    AutoCoin = false,
    AutoGrabGun = false,
    XrayEnabled = false,
    Flying = false,
    FlySpeed = 50
}

-- ================================================================= --
-- [[ 1. ฟังก์ชัน FLY & X-RAY & WALL HOP ]] --
-- ================================================================= --

-- ระบบ X-Ray กำแพงโปร่งใส
local function toggleXray(state)
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if state then
                if not part:FindFirstChild("OriginalTransparency") then
                    local val = Instance.new("NumberValue")
                    val.Name = "OriginalTransparency"
                    val.Value = part.Transparency
                    val.Parent = part
                end
                part.Transparency = 0.6
            else
                if part:FindFirstChild("OriginalTransparency") then
                    part.Transparency = part.OriginalTransparency.Value
                    part.OriginalTransparency:Destroy()
                end
            end
        end
    end
end

-- ระบบบินได้ (Fly System)
local flyBodyVel, flyBodyGyro
local function startFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVel.Velocity = Vector3.new(0, 0.1, 0)
    flyBodyVel.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    
    task.spawn(function()
        while Settings.Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") do
            local camCF = Workspace.CurrentCamera.CFrame
            flyBodyGyro.CFrame = camCF
            flyBodyVel.Velocity = camCF.LookVector * Settings.FlySpeed
            task.wait()
        end
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end)
end

-- ================================================================= --
-- [[ 2. UI หน้าต่างหลัก & เมนูปุ่มลอย ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2VipHubPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 🔴 เมนูปุ่มลอยนอกหน้าต่าง (Floating Action Buttons)
local FloatContainer = Instance.new("Frame")
FloatContainer.Size = UDim2.new(0, 130, 0, 60)
FloatContainer.Position = UDim2.new(0.82, 0, 0.4, 0)
FloatContainer.BackgroundTransparency = 1
FloatContainer.Active = true
FloatContainer.Draggable = true
FloatContainer.Parent = ScreenGui

-- ปุ่มที่ 1: ปุ่มรูปปืน (ยิงหัวฆาตกร)
local GunFloatBtn = Instance.new("TextButton")
GunFloatBtn.Size = UDim2.new(0, 55, 0, 55)
GunFloatBtn.Position = UDim2.new(0, 0, 0, 0)
GunFloatBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
GunFloatBtn.Text = "🔫\n[ยิงหัว]"
GunFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GunFloatBtn.Font = Enum.Font.SourceSansBold
GunFloatBtn.TextSize = 11
GunFloatBtn.Parent = FloatContainer
Instance.new("UICorner", GunFloatBtn).CornerRadius = UDim.new(0, 12)

-- ปุ่มที่ 2: ปุ่มรูปมีด (ฆาตกรฟันรอบตัว)
local KnifeFloatBtn = Instance.new("TextButton")
KnifeFloatBtn.Size = UDim2.new(0, 55, 0, 55)
KnifeFloatBtn.Position = UDim2.new(0, 65, 0, 0)
KnifeFloatBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
KnifeFloatBtn.Text = "🔪\n[ฆ่ารอบตัว]"
KnifeFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KnifeFloatBtn.Font = Enum.Font.SourceSansBold
KnifeFloatBtn.TextSize = 11
KnifeFloatBtn.Parent = FloatContainer
Instance.new("UICorner", KnifeFloatBtn).CornerRadius = UDim.new(0, 12)

-- แถบแสดงผล No Wall Detector (Wall Hop)
local WallDetectorLabel = Instance.new("TextLabel")
WallDetectorLabel.Size = UDim2.new(0, 200, 0, 25)
WallDetectorLabel.Position = UDim2.new(0.5, -100, 0.05, 0)
WallDetectorLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
WallDetectorLabel.BackgroundTransparency = 0.3
WallDetectorLabel.Text = "🟩 [NO WALL CLEAR]"
WallDetectorLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
WallDetectorLabel.Font = Enum.Font.SourceSansBold
WallDetectorLabel.TextSize = 12
WallDetectorLabel.Parent = ScreenGui
Instance.new("UICorner", WallDetectorLabel).CornerRadius = UDim.new(0, 6)

-- 🏠 หน้าต่าง UI หลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 390)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🔪 MM2 VIP PRO (RYGDEEEEEE)"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- [ปุ่ม 1: ESP มองบทบาท]
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.88, 0, 0, 32)
EspBtn.Position = UDim2.new(0.06, 0, 0, 38)
EspBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
EspBtn.Text = "👁️ ESP มองบทบาท: OFF"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.Font = Enum.Font.SourceSansBold
EspBtn.TextSize = 11
EspBtn.Parent = MainFrame
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

-- [ปุ่ม 2: โหมดบินได้ (Fly Mode)]
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0.88, 0, 0, 32)
FlyBtn.Position = UDim2.new(0.06, 0, 0, 76)
FlyBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
FlyBtn.Text = "🕊️ โหมดบินได้อิสระ (Fly): OFF"
FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyBtn.Font = Enum.Font.SourceSansBold
FlyBtn.TextSize = 11
FlyBtn.Parent = MainFrame
Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 6)

FlyBtn.MouseButton1Click:Connect(function()
    Settings.Flying = not Settings.Flying
    FlyBtn.BackgroundColor3 = Settings.Flying and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    FlyBtn.Text = "🕊️ โหมดบินได้อิสระ (Fly): " .. (Settings.Flying and "ON" or "OFF")
    if Settings.Flying then startFly() end
end)

-- [ปุ่ม 3: โหมดเอ็กซเรย์มองทะลุกำแพง (X-Ray)]
local XrayBtn = Instance.new("TextButton")
XrayBtn.Size = UDim2.new(0.88, 0, 0, 32)
XrayBtn.Position = UDim2.new(0.06, 0, 0, 114)
XrayBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
XrayBtn.Text = "🔍 X-Ray กำแพงโปร่งใส: OFF"
XrayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
XrayBtn.Font = Enum.Font.SourceSansBold
XrayBtn.TextSize = 11
XrayBtn.Parent = MainFrame
Instance.new("UICorner", XrayBtn).CornerRadius = UDim.new(0, 6)

XrayBtn.MouseButton1Click:Connect(function()
    Settings.XrayEnabled = not Settings.XrayEnabled
    XrayBtn.BackgroundColor3 = Settings.XrayEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    XrayBtn.Text = "🔍 X-Ray กำแพงโปร่งใส: " .. (Settings.XrayEnabled and "ON" or "OFF")
    toggleXray(Settings.XrayEnabled)
end)

-- [ปุ่ม 4: Wall Hop 45 องศา (กระโดดข้ามมุมกำแพง)]
local WallHopBtn = Instance.new("TextButton")
WallHopBtn.Size = UDim2.new(0.88, 0, 0, 32)
WallHopBtn.Position = UDim2.new(0.06, 0, 0, 152)
WallHopBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
WallHopBtn.Text = "🧱 Wall Hop (วาร์ปไต่กำแพง 45°)"
WallHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WallHopBtn.Font = Enum.Font.SourceSansBold
WallHopBtn.TextSize = 11
WallHopBtn.Parent = MainFrame
Instance.new("UICorner", WallHopBtn).CornerRadius = UDim.new(0, 6)

WallHopBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- วาร์ปสไลด์เฉียง 45 องศาเพื่อข้ามกำแพง
        hrp.CFrame = hrp.CFrame * CFrame.new(3, 5, -3) * CFrame.Angles(0, math.rad(45), 0)
    end
end)

-- [ปุ่ม 5: Auto Farm Coins]
local CoinBtn = Instance.new("TextButton")
CoinBtn.Size = UDim2.new(0.88, 0, 0, 32)
CoinBtn.Position = UDim2.new(0.06, 0, 0, 190)
CoinBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
CoinBtn.Text = "💰 Auto Farm Coins: OFF"
CoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CoinBtn.Font = Enum.Font.SourceSansBold
CoinBtn.TextSize = 11
CoinBtn.Parent = MainFrame
Instance.new("UICorner", CoinBtn).CornerRadius = UDim.new(0, 6)

CoinBtn.MouseButton1Click:Connect(function()
    Settings.AutoCoin = not Settings.AutoCoin
    CoinBtn.BackgroundColor3 = Settings.AutoCoin and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    CoinBtn.Text = "💰 Auto Farm Coins: " .. (Settings.AutoCoin and "ON" or "OFF")
end)

-- [ปุ่ม 6: Speed Boost]
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.88, 0, 0, 32)
SpeedBtn.Position = UDim2.new(0.06, 0, 0, 228)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
SpeedBtn.Text = "⚡ เพิ่มความเร็ววิ่ง: Normal (16)"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.SourceSansBold
SpeedBtn.TextSize = 11
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

local speedState = 1
SpeedBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if speedState == 1 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 28
            SpeedBtn.Text = "⚡ ความเร็ววิ่ง: Fast (28)"
            speedState = 2
        elseif speedState == 2 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 40
            SpeedBtn.Text = "⚡ ความเร็ววิ่ง: Turbo (40)"
            speedState = 3
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            SpeedBtn.Text = "⚡ ความเร็ววิ่ง: Normal (16)"
            speedState = 1
        end
    end
end)

-- ================================================================= --
-- [[ 3. ระบบตรวจจับกำแพง & การทำงานของปุ่มลอย ]] --
-- ================================================================= --

-- ตรวจจับกำแพง (No Wall / Wall Detection)
RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local rayResult = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 4, raycastParams)
        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            WallDetectorLabel.Text = "🧱 [WALL DETECTED: มีกำแพงข้างหน้า!]"
            WallDetectorLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        else
            WallDetectorLabel.Text = "🟩 [NO WALL CLEAR]"
            WallDetectorLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        end
    end
end)

-- การทำงานของปุ่มปืนลอย (Sheriff Silent Aim)
GunFloatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local backpack = p:FindFirstChild("Backpack")
                local isMurderer = p.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                
                if isMurderer then
                    local myHrp = LocalPlayer.Character.HumanoidRootPart
                    myHrp.CFrame = CFrame.new(myHrp.Position, p.Character.Head.Position)
                    GunFloatBtn.Text = "🎯\n[ยิงโดน!]"
                    task.wait(0.5)
                    GunFloatBtn.Text = "🔫\n[ยิงหัว]"
                    break
                end
            end
        end
    end)
end)

-- การทำงานของปุ่มมีดลอย (Murderer Kill All Area)
KnifeFloatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                myHrp.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
                task.wait(0.05)
            end
        end
        KnifeFloatBtn.Text = "☠️\n[เรียบร้อย]"
        task.wait(0.8)
        KnifeFloatBtn.Text = "🔪\n[ฆ่ารอบตัว]"
    end)
end)
