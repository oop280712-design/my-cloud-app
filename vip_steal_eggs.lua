-- [[ VIP STEAL EGGS HUB: ALL ZONES & ALL BOSSES TRACKER (ZORFIJE ONLY) ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- ตรวจสอบสิทธิ์ VIP (เฉพาะ Zoryfje)
local ALLOWED_VIP = "Zoryfje"
if LocalPlayer.Name ~= ALLOWED_VIP and LocalPlayer.DisplayName ~= ALLOWED_VIP then
    LocalPlayer:Kick("❌ สคริปต์นี้อนุญาตให้ใช้งานเฉพาะ VIP: Zorfije เท่านั้น!")
    return
end

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("VIPEggAllZoneHub") then
    PlayerGui:FindFirstChild("VIPEggAllZoneHub"):Destroy()
end

-- รายชื่อบอสและโซนทั้งหมดตั้งแต่ Zone 1 ถึง โซนสุดท้าย
local bossList = {
    "🌐 [ทุกโซน/ทุกบอสในแมพ]",
    "🦂 [Zone 1-5] บอสแมงป่อง / Golem / Spider",
    "🐉 [Zone 6-10] บอสมังกร / Demon / King",
    "🤖 [Zone 11-15] บอส Robot / Cyber / Alien",
    "☣️ [Zone 16+] บอส Bio / Mythic / Titan",
    "✨ [Event/New] บอสใหม่ & คาแรคเตอร์ม็อด"
}
local currentBossIdx = 1

local Settings = {
    SelectedBoss = bossList[1],
    SelectedVersion = "v3.2 Standard",
    MyBaseCFrame = nil,
    AutoRedNight = false
}

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันสแกนหาไข่ของบอสทุกตัวทุกโซน
local function scanEggsForSelectedBoss()
    local matchedEggs = {}
    local bossCategory = Settings.SelectedBoss
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            local fullPath = obj:GetFullName():lower()
            
            -- ค้นหาออบเจกต์ที่เป็นไข่ทั้งหมด
            if name:find("egg") or name:find("ไข่") or name:find("pod") then
                local isMatch = false
                
                if bossCategory:find("ทุกโซน") then
                    isMatch = true
                elseif bossCategory:find("Zone 1-5") then
                    if name:find("scorpion") or name:find("แมงป่อง") or name:find("golem") or name:find("spider") or name:find("slime") or fullPath:find("zone1") or fullPath:find("zone2") or fullPath:find("zone3") or fullPath:find("zone4") or fullPath:find("zone5") then
                        isMatch = true
                    end
                elseif bossCategory:find("Zone 6-10") then
                    if name:find("dragon") or name:find("มังกร") or name:find("demon") or name:find("king") or fullPath:find("zone6") or fullPath:find("zone7") or fullPath:find("zone8") or fullPath:find("zone9") or fullPath:find("zone10") then
                        isMatch = true
                    end
                elseif bossCategory:find("Zone 11-15") then
                    if name:find("robot") or name:find("cyber") or name:find("alien") or fullPath:find("zone11") or fullPath:find("zone12") or fullPath:find("zone13") or fullPath:find("zone14") or fullPath:find("zone15") then
                        isMatch = true
                    end
                elseif bossCategory:find("Zone 16+") then
                    if name:find("bio") or name:find("mythic") or name:find("titan") or name:find("god") or fullPath:find("zone16") or fullPath:find("zone17") or fullPath:find("zone18") or fullPath:find("zone19") or fullPath:find("zone20") then
                        isMatch = true
                    end
                elseif bossCategory:find("Event/New") then
                    if name:find("event") or name:find("new") or name:find("mod") or name:find("char") or name:find("special") then
                        isMatch = true
                    end
                end
                
                if isMatch then
                    table.insert(matchedEggs, obj)
                end
            end
        end
    end
    return matchedEggs
end

-- ฟังก์ชันขโมยไข่ด้วยความเร็วแสง
local function executeStealAction()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local eggs = scanEggsForSelectedBoss()
    if #eggs > 0 then
        local target = eggs[1]
        local targetCFrame = target:IsA("Model") and target:GetPivot() or target.CFrame
        
        hrp.CFrame = targetCFrame + Vector3.new(0, 2, 0)
        task.wait(0.05)
        pcall(function()
            if target:IsA("BasePart") then target.CFrame = hrp.CFrame end
        end)
        if Settings.MyBaseCFrame then hrp.CFrame = Settings.MyBaseCFrame + Vector3.new(0, 3, 0) end
    end
end

-- ================================================================= --
-- [[ UI เมนูเลือกบอสทุกโซน & นับไข่ ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VIPEggAllZoneHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "👑 VIP EGGS (ZONE 1 TO END ZONE)"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- [เมนูที่ 1: เลือกบอส/โซน]
local BossSelectBtn = Instance.new("TextButton")
BossSelectBtn.Size = UDim2.new(0.88, 0, 0, 38)
BossSelectBtn.Position = UDim2.new(0.06, 0, 0, 40)
BossSelectBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
BossSelectBtn.Text = Settings.SelectedBoss
BossSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossSelectBtn.Font = Enum.Font.SourceSansBold
BossSelectBtn.TextSize = 11
BossSelectBtn.Parent = MainFrame
Instance.new("UICorner", BossSelectBtn).CornerRadius = UDim.new(0, 6)

-- [เมนูที่ 2: แสดงจำนวนไข่ของบอสในโซนที่เลือก]
local EggCountLabel = Instance.new("TextLabel")
EggCountLabel.Size = UDim2.new(0.88, 0, 0, 36)
EggCountLabel.Position = UDim2.new(0.06, 0, 0, 86)
EggCountLabel.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
EggCountLabel.Text = "📊 จำนวนไข่โซนนี้: กำลังสแกน..."
EggCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
EggCountLabel.Font = Enum.Font.SourceSansBold
EggCountLabel.TextSize = 12
EggCountLabel.Parent = MainFrame
Instance.new("UICorner", EggCountLabel).CornerRadius = UDim.new(0, 6)

local function updateEggCountDisplay()
    local eggs = scanEggsForSelectedBoss()
    EggCountLabel.Text = "📊 จำนวนไข่โซนนี้: " .. tostring(#eggs) .. " ฟอง"
end

BossSelectBtn.MouseButton1Click:Connect(function()
    currentBossIdx = currentBossIdx + 1
    if currentBossIdx > #bossList then currentBossIdx = 1 end
    Settings.SelectedBoss = bossList[currentBossIdx]
    BossSelectBtn.Text = Settings.SelectedBoss
    updateEggCountDisplay()
end)

-- [เมนูที่ 3: ปุ่มกดรีเฟรชสแกน]
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.88, 0, 0, 32)
ScanBtn.Position = UDim2.new(0.06, 0, 0, 130)
ScanBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
ScanBtn.Text = "🔄 รีเฟรชสแกนไข่ในโซนนี้ใหม่"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 11
ScanBtn.Parent = MainFrame
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)

ScanBtn.MouseButton1Click:Connect(function()
    updateEggCountDisplay()
end)

-- [เมนูที่ 4: เลือกเวอร์ชันแอป 3.2]
local VersionBtn = Instance.new("TextButton")
VersionBtn.Size = UDim2.new(0.88, 0, 0, 32)
VersionBtn.Position = UDim2.new(0.06, 0, 0, 170)
VersionBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
VersionBtn.Text = "3. เวอร์ชันแอป: [v3.2 Standard]"
VersionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionBtn.Font = Enum.Font.SourceSansBold
VersionBtn.TextSize = 11
VersionBtn.Parent = MainFrame
Instance.new("UICorner", VersionBtn).CornerRadius = UDim.new(0, 6)

VersionBtn.MouseButton1Click:Connect(function()
    if Settings.SelectedVersion == "v3.2 Standard" then
        Settings.SelectedVersion = "v3.2 Speed Engine"
        VersionBtn.Text = "3. เวอร์ชันแอป: [v3.2 Speed Engine]"
    else
        Settings.SelectedVersion = "v3.2 Standard"
        VersionBtn.Text = "3. เวอร์ชันแอป: [v3.2 Standard]"
    end
end)

-- ปุ่มเซ็ตจุดฐาน
local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0.88, 0, 0, 30)
SetBaseBtn.Position = UDim2.new(0.06, 0, 0, 210)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
SetBaseBtn.Text = "📍 เซ็ตตำแหน่งฐาน (จุดยืน)"
SetBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBaseBtn.Font = Enum.Font.SourceSans
SetBaseBtn.TextSize = 11
SetBaseBtn.Parent = MainFrame
Instance.new("UICorner", SetBaseBtn).CornerRadius = UDim.new(0, 6)

SetBaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetBaseBtn.Text = "✅ บันทึกพิกัดฐานแล้ว!"
        task.wait(1)
        SetBaseBtn.Text = "📍 เซ็ตตำแหน่งฐาน (จุดยืน)"
    end
end)

-- ปุ่มใหญ่: กดขโมยไข่ความเร็วแสง
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(0.88, 0, 0, 44)
ActionBtn.Position = UDim2.new(0.06, 0, 0, 250)
ActionBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
ActionBtn.Text = "🚀 กดขโมยไข่โซนนี้ (ความเร็วแสง)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.TextSize = 13
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 8)

ActionBtn.MouseButton1Click:Connect(function()
    executeStealAction()
end)

-- สแกนรอบแรกทันทีเมื่อเปิดใช้งาน
updateEggCountDisplay()
