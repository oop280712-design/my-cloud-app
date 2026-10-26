-- ================================================================= --
-- [[ ZOMBIE ARENA: LIGHTWEIGHT AUTO KILLER HUB ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 20)

-- ลบ UI เก่าป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("ZombieArenaHubUI") then
    PlayerGui:FindFirstChild("ZombieArenaHubUI"):Destroy()
end

local Settings = {
    AutoKill = false,
    DamageAmount = 10000,
    InfAmmo = false
}

-- แจ้งเตือนเมื่อสคริปต์เริ่มทำงาน
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🧟 Zombie Arena Hub",
        Text = "โหลดสคริปต์สำเร็จ!",
        Duration = 3
    })
end)

-- ระบบ Auto Kill แบบปลอดภัยต่อ Executor
local function processAutoKill()
    if not Settings.AutoKill then return end
    
    pcall(function()
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- เช็กว่าไม่ใช่ผู้เล่น
                    local isPlayer = Players:GetPlayerFromCharacter(obj)
                    if not isPlayer then
                        humanoid:TakeDamage(Settings.DamageAmount)
                        if Settings.DamageAmount >= 1000000 or humanoid.Health <= 0 then
                            humanoid.Health = 0
                        end
                    end
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if Settings.AutoKill then
        processAutoKill()
    end
end)

-- ระบบกระสุนไม่จำกัด
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.InfAmmo then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, v in pairs(tool:GetDescendants()) do
                                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name:lower():find("ammo") or v.Name:lower():find("clip")) then
                                    v.Value = 999
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- สร้างหน้าต่าง GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZombieArenaHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🧟 ZOMBIE ARENA HUB"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

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

-- ปุ่ม Auto Kill
createButton(40, Color3.fromRGB(192, 57, 43), "💥 Auto Killer: OFF", function(btn)
    Settings.AutoKill = not Settings.AutoKill
    btn.BackgroundColor3 = Settings.AutoKill and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "💥 Auto Killer: " .. (Settings.AutoKill and "ON" or "OFF")
end)

-- ปุ่มปรับดาเมจ
local dmgState = 1
createButton(80, Color3.fromRGB(230, 126, 34), "⚡ ดาเมจ: 10,000", function(btn)
    if dmgState == 1 then
        Settings.DamageAmount = 100000
        btn.Text = "⚡ ดาเมจ: 100,000"
        dmgState = 2
    elseif dmgState == 2 then
        Settings.DamageAmount = 500000
        btn.Text = "⚡ ดาเมจ: 500,000"
        dmgState = 3
    elseif dmgState == 3 then
        Settings.DamageAmount = 1000000
        btn.Text = "⚡ ดาเมจ: 1,000,000 (MAX)"
        dmgState = 4
    else
        Settings.DamageAmount = 10000
        btn.Text = "⚡ ดาเมจ: 10,000"
        dmgState = 1
    end
end)

-- ปุ่ม Inf Ammo
createButton(120, Color3.fromRGB(192, 57, 43), "🔫 Inf Ammo: OFF", function(btn)
    Settings.InfAmmo = not Settings.InfAmmo
    btn.BackgroundColor3 = Settings.InfAmmo and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🔫 Inf Ammo: " .. (Settings.InfAmmo and "ON" or "OFF")
end)

print("🚀 Zombie Arena Hub Loaded Successfully!")
