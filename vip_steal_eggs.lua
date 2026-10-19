-- [[ VIP STEAL EGGS HUB: CHAT GIFT & THAI EGG FINDER (ZORFIJE ONLY) ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- รายชื่อผู้ถือสิทธิ์ VIP ถาวร
local ALLOWED_VIP = "Zorfije"

local username = LocalPlayer.Name
local displayName = LocalPlayer.DisplayName

if username ~= ALLOWED_VIP and displayName ~= ALLOWED_VIP then
    LocalPlayer:Kick("❌ สคริปต์นี้อนุญาตให้ใช้งานเฉพาะ VIP: Zorfije เท่านั้น!")
    return
end

if PlayerGui:FindFirstChild("VIPEggHubAdvanced") then
    PlayerGui:FindFirstChild("VIPEggHubAdvanced"):Destroy()
end

local Settings = {
    MyBaseCFrame = nil,
    AutoRedNight = false,
    IsStealing = false,
    CustomSearchName = ""
}

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันวาร์ปความเร็วแสง
local function lightSpeedMove(targetCFrame)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetCFrame then
        hrp.CFrame = targetCFrame
    end
end

-- ฟังก์ชันค้นหาไข่ทั่วไป
local function scanEggs()
    local matchedEggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("ไข่") or name:find("pod") or name:find("red") then
                table.insert(matchedEggs, obj)
            end
        end
    end
    return matchedEggs
end

-- ฟังก์ชันค้นหาไข่ตามชื่อภาษาไทย/อังกฤษที่ผู้ใช้พิมพ์ในช่องค้นหา
local function searchAndCopyTargetEgg(keyword)
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local query = keyword:lower()
    
    local foundCount = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find(query) then
                foundCount = foundCount + 1
                pcall(function()
                    if obj:IsA("BasePart") then
                        obj.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        obj:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 3, 0))
                    end
                end)
            end
        end
    end
    print("🔍 ค้นหาและดึงไข่ [" .. keyword .. "] สำเร็จจำนวน: " .. foundCount .. " ชิ้น")
end

-- 🎁 ฟังก์ชันรับคำสั่งแชท: พิมพ์ "gift [ชื่อไข่]" เพื่อเสกไข่มาหาตัว
LocalPlayer.Chatted:Connect(function(message)
    local msg = message:lower()
    if msg:sub(1, 5) == "gift " then
        local targetKeyword = msg:sub(6)
        print("🎁 ตรวจพบคำสั่ง Gift ไข่: " .. targetKeyword)
        searchAndCopyTargetEgg(targetKeyword)
    end
end)

-- ฟังก์ชันดึงไข่ทั้งหมดมาที่ฐาน (VIP Magnet)
local function magnetAllEggsToBase()
    if not Settings.MyBaseCFrame then return end
    local eggs = scanEggs()
    for _, egg in pairs(eggs) do
        pcall(function()
            if egg:IsA("BasePart") then
                egg.CFrame = Settings.MyBaseCFrame + Vector3.new(0, 2, 0)
            elseif egg:IsA("Model") and egg.PrimaryPart then
                egg:SetPrimaryPartCFrame(Settings.MyBaseCFrame + Vector3.new(0, 2, 0))
            end
        end)
    end
end

-- ฟังก์ชันฉกไข่อัตโนมัติ
local function executeSteal()
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

workspace.ChildAdded:Connect(function(child)
    if Settings.AutoRedNight then
        local name = child.Name:lower()
        if name:find("egg") or name:find("red") or name:find("แดง") then
            task.wait(0.05)
            executeSteal()
        end
    end
end)

-- ================================================================= --
-- [[ VIP ADVANCED GUI ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VIPEggHubAdvanced"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "👑 VIP EGG HUB (ZORFIJE PRO)"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ช่องพิมพ์ค้นหาไข่ภาษาไทย (Search & Copy Egg Box)
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.88, 0, 0, 32)
SearchBox.Position = UDim2.new(0.06, 0, 0, 40)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SearchBox.PlaceholderText = "พิมพ์ชื่อไข่ที่ต้องการ (เช่น ไข่แดง, gold)"
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 12
SearchBox.Parent = MainFrame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

SearchBox.FocusLost:Connect(function()
    Settings.CustomSearchName = SearchBox.Text
end)

-- ปุ่มกดค้นหาและดึงไข่ที่พิมพ์
local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0.88, 0, 0, 32)
SearchBtn.Position = UDim2.new(0.06, 0, 0, 78)
SearchBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
SearchBtn.Text = "🔍 ค้นหา & ก๊อปปี้นำไข่มาหาตัว"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.Font = Enum.Font.SourceSansBold
SearchBtn.TextSize = 12
SearchBtn.Parent = MainFrame
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 6)

SearchBtn.MouseButton1Click:Connect(function()
    if Settings.CustomSearchName ~= "" then
        searchAndCopyTargetEgg(Settings.CustomSearchName)
        SearchBtn.Text = "✅ ดึงไข่ [" .. Settings.CustomSearchName .. "] แล้ว!"
        task.wait(1.5)
        SearchBtn.Text = "🔍 ค้นหา & ก๊อปปี้นำไข่มาหาตัว"
    end
end)

-- ปุ่มดึงไข่ทั้งหมดมาที่ฐาน
local MagnetBtn = Instance.new("TextButton")
MagnetBtn.Size = UDim2.new(0.88, 0, 0, 34)
MagnetBtn.Position = UDim2.new(0.06, 0, 0, 118)
MagnetBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
MagnetBtn.Text = "💥 [VIP] ดึงไข่ทั้งหมดมาที่ฐานทันที"
MagnetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MagnetBtn.Font = Enum.Font.SourceSansBold
MagnetBtn.TextSize = 12
MagnetBtn.Parent = MainFrame
Instance.new("UICorner", MagnetBtn).CornerRadius = UDim.new(0, 6)

MagnetBtn.MouseButton1Click:Connect(function()
    magnetAllEggsToBase()
    MagnetBtn.Text = "✅ ดึงไข่ทั้งหมดเรียบร้อย!"
    task.wait(1)
    MagnetBtn.Text = "💥 [VIP] ดึงไข่ทั้งหมดมาที่ฐานทันที"
end)

-- ปุ่มเซ็ตจุดฐาน
local SetBaseBtn = Instance.new("TextButton")
SetBaseBtn.Size = UDim2.new(0.88, 0, 0, 30)
SetBaseBtn.Position = UDim2.new(0.06, 0, 0, 158)
SetBaseBtn.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
SetBaseBtn.Text = "📍 เซ็ตพิกัดฐาน (ตำแหน่งยืน)"
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
        SetBaseBtn.Text = "📍 เซ็ตพิกัดฐาน (ตำแหน่งยืน)"
    end
end)

-- สวิตช์เร่งไข่แดง
local RedNightBtn = Instance.new("TextButton")
RedNightBtn.Size = UDim2.new(0.88, 0, 0, 34)
RedNightBtn.Position = UDim2.new(0.06, 0, 0, 194)
RedNightBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
RedNightBtn.Text = "🚨 เร่งฉกไข่แดง (กลางคืน/รีเซ็ต): OFF"
RedNightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedNightBtn.Font = Enum.Font.SourceSansBold
RedNightBtn.TextSize = 12
RedNightBtn.Parent = MainFrame
Instance.new("UICorner", RedNightBtn).CornerRadius = UDim.new(0, 6)

RedNightBtn.MouseButton1Click:Connect(function()
    Settings.AutoRedNight = not Settings.AutoRedNight
    RedNightBtn.BackgroundColor3 = Settings.AutoRedNight and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    RedNightBtn.Text = "🚨 เร่งฉกไข่แดง (กลางคืน/รีเซ็ต): " .. (Settings.AutoRedNight and "ON" or "OFF")
end)

-- ปุ่มความเร็ววิ่ง
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.88, 0, 0, 32)
SpeedBtn.Position = UDim2.new(0.06, 0, 0, 234)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
SpeedBtn.Text = "⚡ [VIP] ความเร็ววิ่ง: Normal (16)"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.SourceSansBold
SpeedBtn.TextSize = 12
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

local speedState = 1
SpeedBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if speedState == 1 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 60
            SpeedBtn.Text = "⚡ [VIP] ความเร็ววิ่ง: Fast (60)"
            speedState = 2
        elseif speedState == 2 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 120
            SpeedBtn.Text = "⚡ [VIP] ความเร็ววิ่ง: Ultra (120)"
            speedState = 3
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            SpeedBtn.Text = "⚡ [VIP] ความเร็ววิ่ง: Normal (16)"
            speedState = 1
        end
    end
end)

-- ปุ่มใหญ่ขโมยไข่ความเร็วแสง
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(0.88, 0, 0, 40)
ActionBtn.Position = UDim2.new(0.06, 0, 0, 272)
ActionBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
ActionBtn.Text = "🚀 กดขโมยไข่ (ความเร็วแสง)"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.TextSize = 14
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 8)

ActionBtn.MouseButton1Click:Connect(function()
    executeSteal()
end)
