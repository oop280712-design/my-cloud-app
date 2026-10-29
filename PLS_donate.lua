-- ================================================================= --
-- [[ PLS DONATE: PARADOX STEALER HUB (FIXED VERSION) ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- เลือกใช้ CoreGui ถ้าตัวรันรองรับ เพื่อป้องกัน UI หายตอนรีสัปย์
local targetParent = (pcall(function() return CoreGui:IsA("Instance") end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui", 10)

-- ลบ UI เก่าป้องกันการรันซ้ำ
if targetParent:FindFirstChild("ParadoxStealerUI") then
    targetParent:FindFirstChild("ParadoxStealerUI"):Destroy()
end

-- แจ้งเตือนเมื่อสคริปต์ทำงาน
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Paradox Stealer",
        Text = "โหลดสคริปต์สำเร็จแล้ว!",
        Duration = 3
    })
end)

-- สร้างหน้าต่าง GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParadoxStealerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.35, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- หัวข้อโปรแกรม
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Paradox Stealer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ช่องใส่ Username
local UsernameBox = Instance.new("TextBox")
UsernameBox.Size = UDim2.new(0.85, 0, 0, 35)
UsernameBox.Position = UDim2.new(0.075, 0, 0, 50)
UsernameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
UsernameBox.PlaceholderText = "Username"
UsernameBox.Text = ""
UsernameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
UsernameBox.Font = Enum.Font.SourceSans
UsernameBox.TextSize = 14
UsernameBox.Parent = MainFrame
Instance.new("UICorner", UsernameBox).CornerRadius = UDim.new(0, 6)

-- ช่องใส่จำนวน Robux
local RobuxBox = Instance.new("TextBox")
RobuxBox.Size = UDim2.new(0.85, 0, 0, 35)
RobuxBox.Position = UDim2.new(0.075, 0, 0, 95)
RobuxBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
RobuxBox.PlaceholderText = "Robux"
RobuxBox.Text = ""
RobuxBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RobuxBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
RobuxBox.Font = Enum.Font.SourceSans
RobuxBox.TextSize = 14
RobuxBox.Parent = MainFrame
Instance.new("UICorner", RobuxBox).CornerRadius = UDim.new(0, 6)

-- ปุ่ม STEAL ROBUX!
local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.85, 0, 0, 40)
StealBtn.Position = UDim2.new(0.075, 0, 0, 140)
StealBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
StealBtn.Text = "STEAL ROBUX!"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 14
StealBtn.Parent = MainFrame
Instance.new("UICorner", StealBtn).CornerRadius = UDim.new(0, 6)

-- ฟังก์ชันกดปุ่ม Steal
StealBtn.MouseButton1Click:Connect(function()
    local target = UsernameBox.Text
    local amount = RobuxBox.Text
    
    if target == "" or amount == "" then
        StealBtn.Text = "กรุณากรอกข้อมูลให้ครบ!"
        task.wait(1.5)
        StealBtn.Text = "STEAL ROBUX!"
        return
    end

    StealBtn.Text = "กำลังดำเนินการ..."
    task.wait(1)

    -- จำลองระบบแจ้งเตือนบริจาคแบบในคลิป[span_0](start_span)[span_0](end_span)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "PLS Donate",
            Text = target .. " DONATED " .. amount .. " 🎫 TO YOU!",
            Duration = 5
        })
    end)

    StealBtn.Text = "สำเร็จ!"
    task.wait(1.5)
    StealBtn.Text = "STEAL ROBUX!"
    UsernameBox.Text = ""
    RobuxBox.Text = ""
end)

print("Paradox Stealer Loaded Successfully!")
