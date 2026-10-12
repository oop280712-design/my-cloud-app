-- [[ Steal Eggs: Ultra Safe UI & Light-Speed Sniper (VIP: Zorfije) ]] --

-- ตรวจสอบและรอให้เกมโหลด PlayerGui ให้เสร็จ 100%
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

if not PlayerGui then
    warn("PlayerGui Not Found!")
    return
end

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("StealEggKeyHub") then
    PlayerGui:FindFirstChild("StealEggKeyHub"):Destroy()
end

-- [[ ตั้งค่าระบบ Key & VIP ]] --
local CORRECT_KEY = "SPARK-EGGS-2026"
local KEY_LINK = "https://oop280712-design.github.io/Key-script/"

local VIP_USERS = {
    ["Zorfije"] = true
}

local Settings = {
    SelectedTier = "Red/Gold",
    TargetBoss = "All Bosses",
    MyBaseCFrame = nil,
    AutoRedNight = false,
    IsStealing = false
}

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันเคลื่อนที่ความเร็วแสง
local function lightSpeedMove(targetCFrame)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetCFrame then
        hrp.CFrame = targetCFrame
    end
end

-- ค้นหาไข่
local function scanEggs()
    local matchedEggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            
            if name:find("egg") or name:find("ไข่") or name:find("pod") then
                local isTierOK = false
                local isBossOK = false
                
                if Settings.SelectedTier == "All" then
                    isTierOK = true
                elseif Settings.SelectedTier == "Red/Gold" then
                    if name:find("red") or name:find("gold") or name:find("rare") or name:find("แดง") or name:find("ทอง") then
                        isTierOK = true
                    end
                elseif Settings.SelectedTier == "Boss/Bio" then
                    if name:find("boss") or name:find("bio") or name:find("cyber") or name:find("mythic") or name:find("event") then
                        isTierOK = true
                    end
                end
                
                if Settings.TargetBoss == "All Bosses" then
                    isBossOK = true
                else
                    if parentName:find(Settings.TargetBoss:lower()) or name:find(Settings.TargetBoss:lower()) then
                        isBossOK = true
                    end
                end
                
                if isTierOK and isBossOK then
                    table.insert(matchedEggs, obj)
                end
            end
        end
    end
    return matchedEggs
end

-- ฟังก์ชันขโมยไข่
local function executeInstantSteal()
    if Settings.IsStealing then return end
    local eggs = scanEggs()
    
    if #eggs > 0 then
        Settings.IsStealing = true
        local target = eggs[1]
        local targetCFrame = target:IsA("Model") and target:GetPivot() or target.CFrame
        
        lightSpeedMove(targetCFrame + Vector3.new(0, 2, 0))
        task.wait(0.05)
        
        pcall(function()
            if target:IsA("BasePart") then
                target.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
        
        if Settings.MyBaseCFrame then
            lightSpeedMove(Settings.MyBaseCFrame + Vector3.new(0, 3, 0))
        end
        
        Settings.IsStealing = false
    end
end

-- ตรวจจับรีเซ็ต / กลางคืน
workspace.ChildAdded:Connect(function(child)
    if Settings.AutoRedNight then
        local name = child.Name:lower()
        if name:find("egg") or name:find("red") or name:find("แดง") then
            task.wait(0.05)
            executeInstantSteal()
        end
    end
end)

-- ================================================================= --
-- [[ สร้าง ScreenGui สำหรับเมนูหน้าจอ ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEggKeyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. หน้าหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainTitle = Instance.new("TextLabel")
MainTitle.Size = UDim2.new(1, 0, 0, 35)
MainTitle.Text = "⚡ STEAL EGGS (DELTA EDITION)"
MainTitle.TextColor3 = Color3.fromRGB(241, 196, 15)
MainTitle.TextSize = 13
MainTitle.Font = Enum.Font.SourceSansBold
MainTitle.BackgroundTransparency = 1
MainTitle.Parent = MainFrame

local TierBtn = Instance.new("TextButton")
TierBtn.Size = UDim2.new(0.88, 0, 0, 32)
TierBtn.Position = UDim2.new(0.06, 0, 0, 40)
TierBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
TierBtn.Text = "1. ระดับไข่: [ไข่แดง/ทอง]"
TierBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TierBtn.Font = Enum.Font.SourceSansBold
TierBtn.TextSize = 12
TierBtn.Parent = MainFrame
Instance.new("UICorner", TierBtn).CornerRadius = UDim.new(0, 6)

TierBtn.MouseButton1Click:Connect(function()
    if Settings.SelectedTier == "Red/Gold" then
        Settings.SelectedTier = "Boss/Bio"
        TierBtn.Text = "1. ระดับไข่: [ไบโอม/บอส/Event]"
    elseif Settings.SelectedTier == "Boss/Bio" then
        Settings.SelectedTier = "All"
        TierBtn.Text = "1. ระดับไข่: [ทุกระดับ]"
    else
        Settings.SelectedTier = "Red/Gold"
        TierBtn.Text = "1. ระดับไข่: [ไข่แดง/ทอง]"
    end
end)

local BossBtn = Instance.new("TextButton")
BossBtn.Size = UDim2.new(0.88, 0, 0, 32)
BossBtn.Position = UDim2.new(0.06, 0, 0, 80)
BossBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
BossBtn.Text = "2. บอสเป้าหมาย: [บอสทั้งหมด]"
BossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossBtn.Font = Enum.Font.SourceSansBold
BossBtn.TextSize = 12
BossBtn.Parent = MainFrame
Instance.new("UICorner", BossBtn).CornerRadius = UDim.new(0, 6)

local bossList = {"All Bosses", "Dragon", "Demon", "King", "Alien", "Robot"}
local currentBossIdx = 1

BossBtn.MouseButton1Click:Connect(function()
    currentBossIdx = currentBossIdx + 1
    if currentBossIdx > #bossList then currentBossIdx = 1 end
    Settings.TargetBoss = bossList[currentBossIdx]
    BossBtn.Text = "2. บอสเป้าหมาย: [" .. Settings.TargetBoss .. "]"
end)

local RedNightBtn = Instance.new("TextButton")
RedNightBtn.Size = UDim2.new(0.88, 0, 0, 35)
RedNightBtn.Position = UDim2.new(0.06, 0, 0, 125)
RedNightBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
RedNightBtn.Text = "🚨 เร่งไข่แดง (กลางคืน/รีเซ็ต): OFF"
RedNightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedNightBtn.Font = Enum.Font.SourceSansBold
RedNightBtn.TextSize = 12
RedNightBtn.Parent = MainFrame
Instance.new("UICorner", RedNightBtn).CornerRadius = UDim.new(0, 6)

RedNightBtn.MouseButton1Click:Connect(function()
    Settings.AutoRedNight = not Settings.AutoRedNight
    RedNightBtn.BackgroundColor3 = Settings.AutoRedNight and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    RedNightBtn.Text = "🚨 เร่งไข่แดง (กลางคืน/รีเซ็ต): " .. (Settings.AutoRedNight and "ON" or "OFF")
end)

local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0.88, 0, 0, 30)
SetBaseBtn.Position = UDim2.new(0.06, 0, 0, 170)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
SetBaseBtn.Text = "📍 เซ็ตจุดฐาน (ตำแหน่งยืน)"
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Font = Enum.Font.SourceSans
SetBaseBtn.TextSize = 11
SetBaseBtn.Parent = MainFrame
Instance.new("UICorner", SetBaseBtn).CornerRadius = UDim.new(0, 6)

SetBaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetBaseBtn.Text = "✅ บันทึกจุดฐานแล้ว!"
        task.wait(1)
        SetBaseBtn.Text = "📍 เซ็ตจุดฐาน (ตำแหน่งยืน)"
    end
end)

local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.88, 0, 0, 40)
StealBtn.Position = UDim2.new(0.06, 0, 0, 215)
StealBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
StealBtn.Text = "⚡ กดขโมยไข่ (ความเร็วแสง)"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 14
StealBtn.Parent = MainFrame
Instance.new("UICorner", StealBtn).CornerRadius = UDim.new(0, 8)

StealBtn.MouseButton1Click:Connect(function()
    executeInstantSteal()
end)

-- 2. หน้าต่าง Key Frame
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 250, 0, 210)
KeyFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Visible = false
KeyFrame.Parent = ScreenGui

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.Text = "🔑 KEY SYSTEM VERIFICATION"
KeyTitle.TextColor3 = Color3.fromRGB(46, 204, 113)
KeyTitle.TextSize = 12
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.BackgroundTransparency = 1
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.88, 0, 0, 36)
KeyBox.Position = UDim2.new(0.06, 0, 0, 42)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyBox.PlaceholderText = "กรอก Key ตรงนี้..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Font = Enum.Font.SourceSans
KeyBox.TextSize = 13
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.88, 0, 0, 34)
GetKeyBtn.Position = UDim2.new(0.06, 0, 0, 88)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
GetKeyBtn.Text = "📋 คัดลอกลิงก์รับคีย์ (Get Key)"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.SourceSansBold
GetKeyBtn.TextSize = 12
GetKeyBtn.Parent = KeyFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(KEY_LINK) end)
    GetKeyBtn.Text = "✅ คัดลอกลิงก์เรียบร้อย!"
    task.wait(1.5)
    GetKeyBtn.Text = "📋 คัดลอกลิงก์รับคีย์ (Get Key)"
end)

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Size = UDim2.new(0.88, 0, 0, 38)
CheckKeyBtn.Position = UDim2.new(0.06, 0, 0, 132)
CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
CheckKeyBtn.Text = "🔓 ยืนยัน Key"
CheckKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckKeyBtn.Font = Enum.Font.SourceSansBold
CheckKeyBtn.TextSize = 14
CheckKeyBtn.Parent = KeyFrame
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 6)

CheckKeyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == CORRECT_KEY then
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        CheckKeyBtn.Text = "❌ Key ไม่ถูกต้อง!"
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        task.wait(1.5)
        CheckKeyBtn.Text = "🔓 ยืนยัน Key"
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    end
end)

-- [[ เช็ก VIP เพื่อแสดงผล ]] --
local username = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName

if VIP_USERS[username] or VIP_USERS[displayName] then
    MainFrame.Visible = true
else
    KeyFrame.Visible = true
end
