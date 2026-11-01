-- ================================================================= --
-- [[ PLS DONATE: PARADOX STEALER (CUSTOM INPUT SYSTEM) ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local targetParent = (pcall(function() return CoreGui:IsA("Instance") end) and CoreGui) or LocalPlayer:WaitForChild("PlayerGui", 10)

-- ลบ UI เก่าป้องกันการรันซ้ำ
if targetParent:FindFirstChild("ParadoxStealerUI") then
    targetParent:FindFirstChild("ParadoxStealerUI"):Destroy()
end

-- แจ้งเตือนเมื่อสคริปต์ทำงาน
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Paradox Stealer",
        Text = "โหลดระบบขโมย Robux สำเร็จ!",
        Duration = 3
    })
end)

-- สร้างหน้าต่าง GUI หลัก
fn_gui = Instance.new("ScreenGui")
fn_gui.Name = "ParadoxStealerUI"
fn_gui.ResetOnSpawn = false
fn_gui.Parent = targetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 220)
MainFrame.Position = UDim2.new(0.5, -155, 0.35, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = fn_gui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- หัวข้อโปรแกรม
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Paradox Stealer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- ช่องกรอกชื่อ (Username) ด้านบน
local UsernameBox = Instance.new("TextBox")
UsernameBox.Size = UDim2.new(0.88, 0, 0, 38)
UsernameBox.Position = UDim2.new(0.06, 0, 0, 45)
UsernameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
UsernameBox.PlaceholderText = "กรอกชื่อผู้เล่น (Username)"
UsernameBox.Text = ""
UsernameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
UsernameBox.Font = Enum.Font.SourceSans
UsernameBox.TextSize = 14
UsernameBox.Parent = MainFrame
Instance.new("UICorner", UsernameBox).CornerRadius = UDim.new(0, 6)

-- ช่องกรอกจำนวน Robux อยู่ข้างล่าง พร้อมสัญลักษณ์ 🎫 Robux
local RobuxBox = Instance.new("TextBox")
RobuxBox.Size = UDim2.new(0.88, 0, 0, 38)
RobuxBox.Position = UDim2.new(0.06, 0, 0, 92)
RobuxBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
RobuxBox.PlaceholderText = "🎫 กรอกจำนวน Robux ที่ต้องการ (เช่น 1000)"
RobuxBox.Text = ""
RobuxBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RobuxBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
RobuxBox.Font = Enum.Font.SourceSans
RobuxBox.TextSize = 14
RobuxBox.Parent = MainFrame
Instance.new("UICorner", RobuxBox).CornerRadius = UDim.new(0, 6)

-- ปุ่มกดดำเนินการ (STEAL ROBUX!)
local StealBtn = Instance.new("TextButton")
StealBtn.Size = UDim2.new(0.88, 0, 0, 42)
StealBtn.Position = UDim2.new(0.06, 0, 0, 145)
StealBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
StealBtn.Text = "STEAL ROBUX!"
StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StealBtn.Font = Enum.Font.SourceSansBold
StealBtn.TextSize = 15
StealBtn.Parent = MainFrame
Instance.new("UICorner", StealBtn).CornerRadius = UDim.new(0, 6)

-- ฟังก์ชันการทำงานเมื่อกดปุ่ม
StealBtn.MouseButton1Click:Connect(function()
    local target = UsernameBox.Text
    local amount = RobuxBox.Text
    
    if target == "" or amount == "" then
        StealBtn.Text = "⚠️ กรุณากรอกข้อมูลให้ครบถ้วน!"
        task.wait(1.5)
        StealBtn.Text = "STEAL ROBUX!"
        return
    end

    StealBtn.Text = "⏳ กำลังดูด Robux จาก " .. target .."..."
    StealBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
    task.wait(2)

    -- จำลองระบบแจ้งเตือนเมื่อดึง Robux สำเร็จและเข้าตัวเราทันที
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎯 โอนเข้าตัวสำเร็จ!",
            Text = LocalPlayer.Name .. " ได้รับ " .. amount .. " Robux จาก " .. target .. " เรียบร้อยแล้ว!",
            Duration = 6
        })
    end)

    StealBtn.Text = "✅ สำเร็จ! Robux เข้าตัวแล้ว"
    StealBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    
    task.wait(2)
    StealBtn.Text = "STEAL ROBUX!"
    StealBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    UsernameBox.Text = ""
    RobuxBox.Text = ""
end)

print("Paradox Stealer Custom Hub Loaded Successfully!")
