-- [[ Steal Eggs: Light-Speed Boss & Red Egg Sniper ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    SelectedTier = "Red/Gold", -- ตัวเลือก: "All", "Red/Gold", "Boss/Bio"
    TargetBoss = "All Bosses",  -- เลือกบอสเป้าหมาย
    MyBaseCFrame = nil,
    AutoRedNight = false,      -- สวิตช์เร่งไข่แดงตอนกลางคืน/รีเซ็ต
    IsStealing = false
}

-- เซ็ตจุดฐานอ้างอิง
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันเคลื่อนที่ความเร็วแสง (Instant CFrame Teleport)
local function lightSpeedMove(targetCFrame)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetCFrame then
        hrp.CFrame = targetCFrame
    end
end

-- ค้นหาไข่ตามระดับและตามบอสที่เลือก
local function scanEggs()
    local matchedEggs = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            
            if name:find("egg") or name:find("ไข่") or name:find("pod") then
                local isTierOK = false
                local isBossOK = false
                
                -- 1. กรองระดับไข่
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
                
                -- 2. กรองตามบอส
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

-- ฟังก์ชันขโมยด้วยความเร็วแสงแล้วพา กลับฐานด่วน
local function executeInstantSteal()
    if Settings.IsStealing then return end
    local eggs = scanEggs()
    
    if #eggs > 0 then
        Settings.IsStealing = true
        local target = eggs[1]
        local targetCFrame = target:IsA("Model") and target:GetPivot() or target.CFrame
        
        -- 1. วาร์ปความเร็วแสงไปหาไข่
        lightSpeedMove(targetCFrame + Vector3.new(0, 2, 0))
        task.wait(0.05)
        
        -- 2. ดึงไข่เข้าตัว
        pcall(function()
            if target:IsA("BasePart") then
                target.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end)
        
        -- 3. วาร์ปกลับฐานด่วนทันที
        if Settings.MyBaseCFrame then
            lightSpeedMove(Settings.MyBaseCFrame + Vector3.new(0, 3, 0))
        end
        
        Settings.IsStealing = false
    end
end

-- สวิตช์ตรวจจับไข่แดงเกิด / กลางคืนรีเซ็ต
workspace.ChildAdded:Connect(function(child)
    if Settings.AutoRedNight then
        local name = child.Name:lower()
        if name:find("egg") or name:find("red") or name:find("แดง") then
            task.wait(0.05)
            executeInstantSteal()
        end
    end
end)

-- UI เมนูแบบใหม่ รองรับ Delta และป้องกันปัญหาวนลูป
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanEggHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "⚡ STEAL EGGS (DELTA EDITION)"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- [เมนูที่ 1: เลือกระดับไข่]
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

-- [เมนูที่ 2: เลือกบอสเป้าหมาย]
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

-- [สวิตช์: เร่งไข่แดงตอนกลางคืน/รีเซ็ต]
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

-- [ปุ่มบันทึกตำแหน่งฐาน]
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

-- [ปุ่มกดขโมยความเร็วแสง]
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
