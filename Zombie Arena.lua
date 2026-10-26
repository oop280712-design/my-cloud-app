-- ================================================================= --
-- [[ ZOMBIE ARENA: ULTIMATE OMEGA AUTO-KILL & DAMAGE HUB ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
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
    AutoKill = false,     -- ระบบออโต้คิลล่ากวาดล้างทุกตัว
    DamageAmount = 10000, -- ดาเมจเริ่มต้น (ปรับได้สูงสุด 1 ล้าน)
    ZombieEsp = false,
    InfAmmo = false,
    InfJump = false
}

-- ================================================================= --
-- [[ 1. ระบบออโต้คิลล่า (Auto Kill + Custom Damage สูงสุด 1 ล้าน) ]] --
-- ================================================================= --

local function processAutoKill()
    if not Settings.AutoKill then return end
    
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                -- เช็กว่าเป็นผู้เล่นจริงไหม (ถ้าไม่ใช่ผู้เล่น ถือว่าเป็นเป้าหมายทั้งหมด)
                local isPlayer = false
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character == obj then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    local humanoid = obj:FindFirstChild("Humanoid")
                    local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and humanoid.Health > 0 then
                        -- หักเลือดตามค่าดาเมจที่ตั้งไว้ (สูงสุดถึง 1 ล้าน)
                        humanoid:TakeDamage(Settings.DamageAmount)
                        if Settings.DamageAmount >= 1000000 or humanoid.Health <= 0 then
                            humanoid.Health = 0 -- ยันดาเมจสูงสุดหรือสั่งดับชีพทันที
                        end
                        
                        -- ดึงพิกัดเข้ามาใกล้ตัวแบบเบ็ดเสร็จ
                        if hrp and myHrp then
                            hrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -3)
                        end
                    end
                end
            end
        end
    end)
end

-- ================================================================= --
-- [[ 2. ระบบ ESP ตรวจจับทุกสิ่ง (เรืองแสงเตือนภัยทุกตัว) ]] --
-- ================================================================= --

local function applyEspAll()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local isPlayer = false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character == obj then
                    isPlayer = true
                    break
                end
            end
            
            if not isPlayer then
                local highlight = obj:FindFirstChild("OmegaHighlight")
                if Settings.ZombieEsp then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "OmegaHighlight"
                        highlight.Adornee = obj
                        highlight.FillColor = Color3.fromRGB(231, 76, 60) -- 🟥 สีแดงเตือนภัย
                        highlight.FillTransparency = 0.3
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Parent = obj
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Settings.ZombieEsp then
        pcall(applyEspAll)
    end
    if Settings.AutoKill then
        processAutoKill()
    end
end)

-- ================================================================= --
-- [[ 3. ระบบกระสุนไม่จำกัด (Infinite Ammo) ]] --
-- ================================================================= --

task.spawn(function()
    while true do
        task.wait(0.3)
        if Settings.InfAmmo then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, v in pairs(tool:GetDescendants()) do
                                if v:IsA("NumberValue") or v:IsA("IntValue") then
                                    if string.lower(v.Name):find("ammo") or string.lower(v.Name):find("clip") then
                                        v.Value = 999
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ================================================================= --
-- [[ 4. หน้าต่างควบคุม GUI ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZombieArenaHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 300)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🚨 AUTO KILLER & DAMAGE HUB"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function createButton(posY, bgColor, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 30)
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

-- 1. ปุ่มหลัก: เปิด/ปิด ออโต้คิลล่า
createButton(40, Color3.fromRGB(192, 57, 43), "💥 Auto Killer (ออโต้คิลล่า): OFF", function(btn)
    Settings.AutoKill = not Settings.AutoKill
    btn.BackgroundColor3 = Settings.AutoKill and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "💥 Auto Killer (ออโต้คิลล่า): " .. (Settings.AutoKill and "ON" or "OFF")
end)

-- 2. ปุ่มปรับระดับดาเมจ (วนลูป 10k -> 100k -> 500k -> 1,000,000)
local dmgState = 1
createButton(78, Color3.fromRGB(230, 126, 34), "⚡ ปรับดาเมจ: 10,000", function(btn)
    if dmgState == 1 then
        Settings.DamageAmount = 100000
        btn.Text = "⚡ ปรับดาเมจ: 100,000"
        dmgState = 2
    elseif dmgState == 2 then
        Settings.DamageAmount = 500000
        btn.Text = "⚡ ปรับดาเมจ: 500,000"
        dmgState = 3
    elseif dmgState == 3 then
        Settings.DamageAmount = 1000000
        btn.Text = "⚡ ปรับดาเมจ: 1,000,000 (MAX)"
        dmgState = 4
    else
        Settings.DamageAmount = 10000
        btn.Text = "⚡ ปรับดาเมจ: 10,000"
        dmgState = 1
    end
end)

-- 3. ปุ่ม ESP มองทะลุทุกสิ่ง
createButton(116, Color3.fromRGB(192, 57, 43), "👁️ ESP มองทะลุทุกสิ่ง: OFF", function(btn)
    Settings.ZombieEsp = not Settings.ZombieEsp
    btn.BackgroundColor3 = Settings.ZombieEsp and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "👁️ ESP มองทะลุทุกสิ่ง: " .. (Settings.ZombieEsp and "ON" or "OFF")
end)

-- 4. ปุ่มกระสุนไม่จำกัด
createButton(154, Color3.fromRGB(192, 57, 43), "🔫 กระสุนไม่จำกัด (Inf Ammo): OFF", function(btn)
    Settings.InfAmmo = not Settings.InfAmmo
    btn.BackgroundColor3 = Settings.InfAmmo and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🔫 กระสุนไม่จำกัด (Inf Ammo): " .. (Settings.InfAmmo and "ON" or "OFF")
end)

-- 5. ปุ่ม Infinity Jump
createButton(192, Color3.fromRGB(192, 57, 43), "🦘 Infinity Jump (กระโดดรัว): OFF", function(btn)
    Settings.InfJump = not Settings.InfJump
    btn.BackgroundColor3 = Settings.InfJump and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🦘 Infinity Jump (กระโดดรัว): " .. (Settings.InfJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

print("🚀 Auto Killer & Damage Hub Loaded Successfully!")
