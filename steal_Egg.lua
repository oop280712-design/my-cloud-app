-- ================================================================= --
-- [[ COMMUNE EGG: ULTRA STABLE FAST SNIPER ]] --
-- ================================================================= --

pcall(function()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
end)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

if not PlayerGui then return end

-- ลบ UI เก่าป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("SimpleEggHub") then
    PlayerGui:FindFirstChild("SimpleEggHub"):Destroy()
end

-- แจ้งเตือนเมื่อโหลดสำเร็จ
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Egg Hub",
        Text = "โหลดสคริปต์สำเร็จ!",
        Duration = 2
    })
end)

-- ตัวแปรตั้งค่า
local autoSteal = false

-- สร้างหน้าต่าง UI แบบเรียบง่าย (ไม่กินสเปคตัวรัน)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleEggHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🥚 EGG SNIPER HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- ปุ่มเปิด/ปิด Auto Steal
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.06, 0, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
ToggleBtn.Text = "AUTO STEAL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 13
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    autoSteal = not autoSteal
    if autoSteal then
        ToggleBtn.Text = "AUTO STEAL: ON ✅"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        ToggleBtn.Text = "AUTO STEAL: OFF ❌"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    end
end)

-- ปุ่มเทเลพอร์ต/ดึงไข่ด่วน
local InstantBtn = Instance.new("TextButton")
InstantBtn.Size = UDim2.new(0.88, 0, 0, 40)
InstantBtn.Position = UDim2.new(0.06, 0, 0, 92)
InstantBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
InstantBtn.Text = "⚡ ขโมยไข่ใกล้ตัวทันที"
InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantBtn.Font = Enum.Font.SourceSansBold
InstantBtn.TextSize = 13
InstantBtn.Parent = Frame
Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 6)

InstantBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ไข่")) then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end)
end)

-- ลูปการทำงาน Auto Steal
task.spawn(function()
    while true do
        task.wait(0.3)
        if autoSteal then
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ไข่")) then
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

print("Simple Egg Hub Loaded!")
