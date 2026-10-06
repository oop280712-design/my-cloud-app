-- [[ Steal Eggs: Red & Bio Egg Sniper Hub ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    SelectedTier = "Red/Gold", -- ตัวเลือก: "All", "Red/Gold", "Bio/NewZone"
    TargetPlayer = "",
    MyBaseCFrame = nil,
    FlySpeed = 120,
    IsStealing = false,
    SnipeOnReset = true -- สวิตช์เล็งไข่ตอนรีเซ็ตแมพ
}

-- บันทึกตำแหน่งฐานเริ่มต้น
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันบินไป-กลับรวดเร็ว
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

-- ฟังก์ชันค้นหาไข่ตามระดับที่เลือก (รวมถึงโซนไบโอใหม่)
local function findEggByTier()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("egg") or name:find("ไข่") then
                local isMatch = false
                
                if Settings.SelectedTier == "All" then
                    isMatch = true
                elseif Settings.SelectedTier == "Red/Gold" then
                    if name:find("red") or name:find("gold") or name:find("rare") or name:find("แดง") or name:find("ทอง") then
                        isMatch = true
                    end
                elseif Settings.SelectedTier == "Bio/NewZone" then
                    -- ตรวจจับไข่โซนไบโอใหม่ / Bio / Cyber / Mutant / Alien / Event
                    if name:find("bio") or name:find("biome") or name:find("mutant") or name:find("cyber") or name:find("alien") or name:find("toxic") then
                        isMatch = true
                    end
                end

                if isMatch then
                    if Settings.TargetPlayer ~= "" then
                        local targetChar = workspace:FindFirstChild(Settings.TargetPlayer)
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            local dist = (obj:GetPivot().Position - targetChar.HumanoidRootPart.Position).Magnitude
                            if dist < 60 then return obj end
                        end
                    else
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

-- ฟังก์ชันรันการขโมยไข่ 1 รอบ
local function executeSteal()
    if Settings.IsStealing then return end
    local targetEgg = findEggByTier()
    
    if targetEgg then
        Settings.IsStealing = true
        print("🚀 พุ่งไปฉกไข่เป้าหมาย...")
        
        local eggCFrame = targetEgg:IsA("Model") and targetEgg:GetPivot() or targetEgg.CFrame
        
        -- 1. ลอยไปชนและเก็บไข่
        fastFlyTo(eggCFrame + Vector3.new(0, 2, 0), Settings.FlySpeed)
        task.wait(0.15)
        
        if targetEgg:IsA("BasePart") then
            targetEgg.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        
        -- 2. พาไข่บินกลับฐานด่วน
        if Settings.MyBaseCFrame then
            print("🏃‍♂️ บินพาไข่กลับฐานด่วน!")
            fastFlyTo(Settings.MyBaseCFrame + Vector3.new(0, 3, 0), Settings.FlySpeed)
        end
        
        Settings.IsStealing = false
    end
end

-- ตรวจจับการรีเซ็ตแมพ / ไข่เกิดใหม่
workspace.ChildAdded:Connect(function(child)
    if Settings.SnipeOnReset then
        local name = child.Name:lower()
        if name:find("egg") or name:find("ไข่") then
            task.wait(0.1)
            executeSteal()
        end
    end
end)

-- UI หน้าต่างควบคุมในมือถือ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggSniperProGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 310)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🥚 ULTRA EGG SNIPER V3"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- 1. ปุ่มเซ็ตฐาน
local BaseBtn = Instance.new("TextButton")
BaseBtn.Size = UDim2.new(0.88, 0, 0, 32)
BaseBtn.Position = UDim2.new(0.06, 0, 0, 40)
BaseBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
BaseBtn.Text = "📍 เซ็ตตำแหน่งฐานด่วน"
BaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BaseBtn.Font = Enum.Font.SourceSansBold
BaseBtn.TextSize = 12
BaseBtn.Parent = MainFrame
Instance.new("UICorner", BaseBtn).CornerRadius = UDim.new(0, 6)

BaseBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        BaseBtn.Text = "✅ บันทึกฐานเรียบร้อย!"
        task.wait(1)
        BaseBtn.Text = "📍 เซ็ตตำแหน่งฐานด่วน"
    end
end)

-- 2. ปุ่มเปลี่ยนระดับไข่ที่จะขโมย (Tier Switcher)
local TierBtn = Instance.new("TextButton")
TierBtn.Size = UDim2.new(0.88, 0, 0, 32)
TierBtn.Position = UDim2.new(0.06, 0, 0, 80)
TierBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
TierBtn.Text = "🎯 ระดับไข่: [ไข่แดง/ทอง]"
TierBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TierBtn.Font = Enum.Font.SourceSansBold
TierBtn.TextSize = 12
TierBtn.Parent = MainFrame
Instance.new("UICorner", TierBtn).CornerRadius = UDim.new(0, 6)

TierBtn.MouseButton1Click:Connect(function()
    if Settings.SelectedTier == "Red/Gold" then
        Settings.SelectedTier = "Bio/NewZone"
        TierBtn.Text = "🎯 ระดับไข่: [โซนไบโอใหม่/Bio]"
    elseif Settings.SelectedTier == "Bio/NewZone" then
        Settings.SelectedTier = "All"
        TierBtn.Text = "🎯 ระดับไข่: [ทุกประเภท]"
    else
        Settings.SelectedTier = "Red/Gold"
        TierBtn.Text = "🎯 ระดับไข่: [ไข่แดง/ทอง]"
    end
end)

-- 3. ช่องกรอกชื่อเป้าหมาย
local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(0.88, 0, 0, 30)
TargetBox.Position = UDim2.new(0.06, 0, 0, 120)
TargetBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TargetBox.PlaceholderText = "พิมพ์ชื่อคนที่จะไปขโมย (ถ้ามี)"
TargetBox.Text = ""
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 12
TargetBox.Parent = MainFrame
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 6)

TargetBox.FocusLost:Connect(function()
    Settings.TargetPlayer = TargetBox.Text
end)

-- 4. สวิตช์เล็งไข่ตอนรีเซ็ต (Snipe On Reset Toggle)
local ResetToggle = Instance.new("TextButton")
ResetToggle.Size = UDim2.new(0.88, 0, 0, 34)
ResetToggle.Position = UDim2.new(0.06, 0, 0, 160)
ResetToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ResetToggle.Text = "🔄 เล็งฉกไข่ตอนรีเซ็ตแมพ: ON"
ResetToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetToggle.Font = Enum.Font.SourceSansBold
ResetToggle.TextSize = 12
ResetToggle.Parent = MainFrame
Instance.new("UICorner", ResetToggle).CornerRadius = UDim.new(0, 6)

ResetToggle.MouseButton1Click:Connect(function()
    Settings.SnipeOnReset = not Settings.SnipeOnReset
    ResetToggle.BackgroundColor3 = Settings.SnipeOnReset and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    ResetToggle.Text = "🔄 เล็งฉกไข่ตอนรีเซ็ตแมพ: " .. (Settings.SnipeOnReset and "ON" or "OFF")
end)

-- 5. 🔥 ปุ่มใหญ่: กดขโมยไข่ทันที (Instant Steal)
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(0.88, 0, 0, 42)
ActionBtn.Position = UDim2.new(0.06, 0, 0, 205)
ActionBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
ActionBtn.Text = "⚡ กดขโมยไข่ทันที!"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.SourceSansBold
ActionBtn.TextSize = 15
ActionBtn.Parent = MainFrame
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 8)

ActionBtn.MouseButton1Click:Connect(function()
    executeSteal()
end)
