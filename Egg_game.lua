-- [[ Steal Eggs: Auto Snipe Red Egg & Fast Return Base ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoSnipeRedEgg = true,
    TargetPlayer = "", -- ชื่อผู้เล่นเป้าหมายที่จะไปขโมย
    MyBaseCFrame = nil, -- ตำแหน่งฐานของเรา
    FlySpeed = 100, -- ความเร็วในการลอยไป-กลับ
    IsStealing = false
}

-- บันทึกตำแหน่งฐานของเราเมื่อเริ่มต้น (หรือจุดที่ยืนอยู่)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันลอยตัวแบบรวดเร็วไปยังเป้าหมาย (ป้องกันโดนบล็อก)
local function fastFlyTo(targetCFrame, speed)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ฟังก์ชันค้นหาไข่แดง (Red Egg / Rare Egg)
local function findRedEgg()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            -- เช็กว่าเป็นไข่แดง หรือไข่ระดับレア
            if (name:find("red") or name:find("gold") or name:find("rare") or name:find("แดง")) and name:find("egg") then
                -- ถ้ามีการตั้งเป้าหมายตัวละครไว้ จะเช็กว่าไข่อยู่ใกล็ผู้เล่นนั้นไหม
                if Settings.TargetPlayer ~= "" then
                    local targetChar = workspace:FindFirstChild(Settings.TargetPlayer)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local distToTarget = (obj:GetPivot().Position - targetChar.HumanoidRootPart.Position).Magnitude
                        if distToTarget < 50 then
                            return obj
                        end
                    end
                else
                    return obj
                end
            end
        end
    end
    return nil
end

-- ระบบลูปหลักสำหรับตรวจจับและฉกไข่แดง
task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoSnipeRedEgg and not Settings.IsStealing then
            local redEgg = findRedEgg()
            
            if redEgg then
                Settings.IsStealing = true
                print("🔥 พบไข่แดง! กำลังพุ่งไปฉก...")
                
                local eggCFrame = redEgg:IsA("Model") and redEgg:GetPivot() or redEgg.CFrame
                
                -- 1. บินไปที่ตำแหน่งไข่แดงแบบรวดเร็ว
                fastFlyTo(eggCFrame + Vector3.new(0, 3, 0), Settings.FlySpeed)
                task.wait(0.2)
                
                -- 2. ดึงไข่เข้าตัว/อุ้มไข่
                if redEgg:IsA("BasePart") then
                    redEgg.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
                
                print("🏃‍♂️ ฉกไข่แดงสำเร็จ! กำลังพาบินกลับฐาน...")
                
                -- 3. บินกลับฐานอย่างรวดเร็ว
                if Settings.MyBaseCFrame then
                    fastFlyTo(Settings.MyBaseCFrame + Vector3.new(0, 3, 0), Settings.FlySpeed)
                end
                
                print("✅ ถึงฐานเรียบร้อย!")
                Settings.IsStealing = false
            end
        end
    end
end)

-- Создать UI หน้าต่างควบคุมในมือถือ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggSniperGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🥚 RED EGG SNIPER V2"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ปุ่มบันทึกจุดฐาน
local BaseBtn = Instance.new("TextButton")
BaseBtn.Size = UDim2.new(0.85, 0, 0, 32)
BaseBtn.Position = UDim2.new(0.075, 0, 0, 45)
BaseBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
BaseBtn.Text = "📍 เซ็ตตำแหน่งฐาน (จุดที่ยืน)"
BaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BaseBtn.Font = Enum.Font.SourceSansBold
BaseBtn.TextSize = 12
BaseBtn.Parent = MainFrame

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 6)
Corner1.Parent = BaseBtn

BaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        BaseBtn.Text = "✅ บันทึกตำแหน่งฐานแล้ว!"
        task.wait(1.5)
        BaseBtn.Text = "📍 เซ็ตตำแหน่งฐาน (จุดที่ยืน)"
    end
end)

-- ช่องใส่ชื่อเป้าหมายที่จะขโมย
local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(0.85, 0, 0, 32)
TargetBox.Position = UDim2.new(0.075, 0, 0, 85)
TargetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetBox.PlaceholderText = "พิมพ์ชื่อคนที่จะขโมย (ถ้ามี)"
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 12
TargetBox.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 6)
Corner2.Parent = TargetBox

TargetBox.FocusLost:Connect(function()
    Settings.TargetPlayer = TargetBox.Text
end)

-- ปุ่มเปิด/ปิด Auto Snipe
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 38)
ToggleBtn.Position = UDim2.new(0.075, 0, 0, 130)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleBtn.Text = "Auto Snipe ไข่แดง: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = MainFrame

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 6)
Corner3.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.AutoSnipeRedEgg = not Settings.AutoSnipeRedEgg
    ToggleBtn.BackgroundColor3 = Settings.AutoSnipeRedEgg and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    ToggleBtn.Text = "Auto Snipe ไข่แดง: " .. (Settings.AutoSnipeRedEgg and "ON" or "OFF")
end)
