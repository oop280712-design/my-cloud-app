-- ================================================================= --
-- [[ PLS DONATE: LEADERBOARD STEALER HUB ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 20)

-- ลบ UI เก่าป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("StealRobuxHubUI") then
    PlayerGui:FindFirstChild("StealRobuxHubUI"):Destroy()
end

-- แจ้งเตือนเมื่อสคริปต์ทำงาน
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "💸 Leaderboard Stealer Hub",
        Text = "ระบบขโมย Robux ผ่านหน้าจัดอันดับพร้อมใช้งาน!",
        Duration = 3
    })
end)

-- ================================================================= --
-- [[ 1. หน้าต่าง GUI หลักเมนูขโมย Robux ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealRobuxHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 290)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🎯 LEADERBOARD STEALER HUB"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- กล่องแสดงชื่อเหยื่อที่เลือก
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.88, 0, 0, 35)
TargetLabel.Position = UDim2.new(0.06, 0, 0, 45)
TargetLabel.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
TargetLabel.Text = "เป้าหมาย: ยังไม่ได้เลือก (กดที่ชื่อในจัดอันดับ)"
TargetLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
TargetLabel.Font = Enum.Font.SourceSansBold
TargetLabel.TextSize = 11
TargetLabel.Parent = MainFrame
Instance.new("UICorner", TargetLabel).CornerRadius = UDim.new(0, 6)

-- ช่องพิมพ์จำนวน Robux ที่ต้องการดูด
local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.88, 0, 0, 35)
AmountBox.Position = UDim2.new(0.06, 0, 0, 90)
AmountBox.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
AmountBox.PlaceholderText = "พิมพ์จำนวน Robux ที่จะเอา (เช่น 1000)"
AmountBox.Text = ""
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
AmountBox.Font = Enum.Font.SourceSansBold
AmountBox.TextSize = 12
AmountBox.Parent = MainFrame
Instance.new("UICorner", AmountBox).CornerRadius = UDim.new(0, 6)

-- ตัวแปรเก็บชื่อเหยื่อ
local selectedTarget = nil

-- ฟังก์ชันสร้างปุ่ม
local function createButton(posY, bgColor, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, posY)
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- ================================================================= --
-- [[ 2. ระบบดักคลิกชื่อคนในหน้าจัดอันดับ (Leaderboard) ]] --
-- ================================================================= --

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- ค้นหาป้ายหรือบอร์ดจัดอันดับในเกม
            for _, guiObj in pairs(workspace:GetDescendants()) do
                if guiObj:IsA("TextButton") or guiObj:IsA("TextLabel") then
                    local textLower = string.lower(guiObj.Text or "")
                    -- เช็กปุ่มที่เป็นรายชื่อคนใน Leaderboard
                    if guiObj.Parent and (guiObj.Parent.Name:lower():find("leaderboard") or guiObj.Parent.Name:lower():find("rank") or guiObj.Parent.Name:lower():find("donate")) then
                        -- ดักจับการกดคลิกที่ชื่อคนในจัดอันดับ
                        if not guiObj:FindFirstChild("StealConnected") then
                            local conn = Instance.new("BoolValue")
                            conn.Name = "StealConnected"
                            conn.Parent = guiObj
                            
                            -- ถ้ามีการกดที่ชื่อคนนั้น
                            guiObj.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    selectedTarget = guiObj.Text
                                    TargetLabel.Text = "เป้าหมาย: " .. selectedTarget
                                    TargetLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- ================================================================= --
-- [[ 3. ปุ่มกด "โดน" (ดูด Robux ตามจำนวนที่พิมพ์) ]] --
-- ================================================================= --

createButton(135, Color3.fromRGB(192, 57, 43), "💥 โดน (ดูด Robux เป้าหมายทันที)", function(btn)
    local amount = tonumber(AmountBox.Text)
    if not selectedTarget or selectedTarget == "" then
        TargetLabel.Text = "⚠️ กรุณาไปกดเลือกชื่อคนในหน้าจัดอันดับก่อน!"
        TargetLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end
    if not amount or amount <= 0 then
        AmountBox.Text = "กรุณาใส่ตัวเลขให้ถูกต้อง!"
        return
    end

    btn.Text = "⏳ กำลังดูด " .. amount .. " Robux..."
    btn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)

    -- จำลองระบบหนีบ/ดูดสำเร็จ
    task.wait(1.5)
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🎯 สำเร็จ!",
            Text = "ดูด " .. amount .. " Robux จาก " .. selectedTarget .. " เรียบร้อยแล้ว!",
            Duration = 5
        })
    end)

    btn.Text = "✅ ดูด Robux สำเร็จแล้ว!"
    btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    
    task.wait(2)
    btn.Text = "💥 โดน (ดูด Robux เป้าหมายทันที)"
    btn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
    AmountBox.Text = ""
end)

-- ================================================================= --
-- [[ 4. ปุ่มเสริม: สลับเซิร์ฟเวอร์หาเป้าหมายใหม่ ]] --
-- ================================================================= --

createButton(175, Color3.fromRGB(41, 128, 185), "🔄 สลับเซิร์ฟเวอร์หาเป้าหมายอื่น", function(btn)
    btn.Text = "🔄 กำลังสลับเซิร์ฟ..."
    pcall(function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)

-- ================================================================= --
-- [[ 5. ปุ่มเปิดโหมด AFK (กันหลุดระหว่างหาเป้าหมาย) ]] --
-- ================================================================= --

local afkActive = false
createButton(215, Color3.fromRGB(52, 152, 219), "🛡️ เปิดโหมด AFK (กันหลุด): OFF", function(btn)
    afkActive = not afkActive
    btn.BackgroundColor3 = afkActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(52, 152, 219)
    btn.Text = "🛡️ เปิดโหมด AFK (กันหลุด): " .. (afkActive and "ON" or "OFF")
    
    if afkActive then
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            LocalPlayer.Idled:Connect(function()
                if afkActive then
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        end)
    end
end)

print("🚀 Leaderboard Stealer Hub Loaded Successfully!")
