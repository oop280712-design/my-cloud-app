-- ================================================================= --
-- [[ MURDER MYSTERY 2: ULTIMATE HUB (UPDATED VERSION) ]] --
-- ================================================================= --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- 1. เปลี่ยนตัว R เป็นตัวพิมพ์เล็ก rygdeeeeee
local ALLOWED_VIP = "rygdeeeeee"
if string.lower(LocalPlayer.Name) ~= ALLOWED_VIP and string.lower(LocalPlayer.DisplayName) ~= ALLOWED_VIP then
    LocalPlayer:Kick("❌ สคริปต์นี้อนุญาตให้ใช้งานเฉพาะ: rygdeeeeee เท่านั้น!")
    return
end

-- ลบ UI เก่าป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("MM2VipHubUltimate") then
    PlayerGui:FindFirstChild("MM2VipHubUltimate"):Destroy()
end

local Settings = {
    EspEnabled = false,
    XrayEnabled = false,
    Flying = false,
    FlySpeed = 50,
    InfJump = false
}

-- ================================================================= --
-- [[ 2. ระบบ ESP ตรวจจับไอเทมและชื่อผู้เล่นแบบใหม่ ]] --
-- ================================================================= --

local function removeESP(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local billboard = head:FindFirstChild("MM2_ESP_Tag")
            if billboard then billboard:Destroy() end
        end
        local highlight = player.Character:FindFirstChild("MM2_ESP_Highlight")
        if highlight then highlight:Destroy() end
    end
end

local function applyESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local char = player.Character
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not head or not hrp then return end

    -- ตรวจสอบไอเทมในตัว (ทั้งที่ถืออยู่และอยู่ในกระเป๋า Backpack)
    local hasKnife = false
    local hasGun = false

    local backpack = player:FindFirstChild("Backpack")
    
    -- เช็กไอเทมในกระเป๋า
    if backpack then
        if backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Slash") then hasKnife = true end
        if backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver") then hasGun = true end
    end
    
    -- เช็กไอเทมที่ถือในมือ
    if char:FindFirstChild("Knife") or char:FindFirstChild("Slash") then hasKnife = true end
    if char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then hasGun = true end

    -- กำหนดสีตามบทบาทและไอเทม
    local roleColor = Color3.fromRGB(46, 204, 113) -- 🟩 สีเขียว: Innocent (ไม่มีไอเทม)
    local roleName = "Innocent"

    if hasKnife then
        roleColor = Color3.fromRGB(231, 76, 60) -- 🟥 สีแดง: Murderer (มีมีด)
        roleName = "Murderer 🔪"
    elseif hasGun then
        roleColor = Color3.fromRGB(52, 152, 219) -- 🟦 สีฟ้า: Sheriff (มีปืน)
        roleName = "Sheriff 🔫"
    end

    -- 1. Highlight เรืองแสงตัวละคร
    local highlight = char:FindFirstChild("MM2_ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "MM2_ESP_Highlight"
        highlight.Parent = char
    end
    highlight.Adornee = char
    highlight.FillColor = roleColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0

    -- 2. BillboardGui ป้ายชื่อและบทบาทบนหัว
    local billboard = head:FindFirstChild("MM2_ESP_Tag")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "MM2_ESP_Tag"
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 13
        nameLabel.Parent = billboard

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Name = "RoleLabel"
        roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
        roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Font = Enum.Font.SourceSansBold
        roleLabel.TextSize = 12
        roleLabel.Parent = billboard
    end

    billboard.NameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    billboard.RoleLabel.Text = "[" .. roleName .. "]"
    billboard.RoleLabel.TextColor3 = roleColor
end

-- ลูปอัปเดต ESP ตลอดเวลา
RunService.RenderStepped:Connect(function()
    if Settings.EspEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                pcall(function() applyESP(p) end)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            pcall(function() removeESP(p) end)
        end
    end
end)

-- ================================================================= --
-- [[ 3. ระบบ Infinity Jump (กระโดดลอยกลางอากาศรัวๆ) ]] --
-- ================================================================= --

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ================================================================= --
-- [[ 4. ฟังก์ชัน X-Ray & Fly ]] --
-- ================================================================= --

local function toggleXray(state)
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            if state then
                if not part:FindFirstChild("OriginalTransparency") then
                    local val = Instance.new("NumberValue")
                    val.Name = "OriginalTransparency"
                    val.Value = part.Transparency
                    val.Parent = part
                end
                part.Transparency = 0.6
            else
                if part:FindFirstChild("OriginalTransparency") then
                    part.Transparency = part.OriginalTransparency.Value
                    part.OriginalTransparency:Destroy()
                end
            end
        end
    end
end

local flyBodyVel, flyBodyGyro
local function startFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVel.Velocity = Vector3.new(0, 0.1, 0)
    flyBodyVel.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    
    task.spawn(function()
        while Settings.Flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") do
            local camCF = Workspace.CurrentCamera.CFrame
            flyBodyGyro.CFrame = camCF
            flyBodyVel.Velocity = camCF.LookVector * Settings.FlySpeed
            task.wait()
        end
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end)
end

-- ================================================================= --
-- [[ 5. สร้าง GUI เมนูใช้งาน ]] --
-- ================================================================= --

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2VipHubUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ปุ่มลอย (Gun / Knife)
local FloatContainer = Instance.new("Frame")
FloatContainer.Size = UDim2.new(0, 130, 0, 60)
FloatContainer.Position = UDim2.new(0.82, 0, 0.4, 0)
FloatContainer.BackgroundTransparency = 1
FloatContainer.Active = true
FloatContainer.Draggable = true
FloatContainer.Parent = ScreenGui

local GunFloatBtn = Instance.new("TextButton")
GunFloatBtn.Size = UDim2.new(0, 55, 0, 55)
GunFloatBtn.Position = UDim2.new(0, 0, 0, 0)
GunFloatBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
GunFloatBtn.Text = "🔫\n[ยิงหัว]"
GunFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GunFloatBtn.Font = Enum.Font.SourceSansBold
GunFloatBtn.TextSize = 11
GunFloatBtn.Parent = FloatContainer
Instance.new("UICorner", GunFloatBtn).CornerRadius = UDim.new(0, 12)

local KnifeFloatBtn = Instance.new("TextButton")
KnifeFloatBtn.Size = UDim2.new(0, 55, 0, 55)
KnifeFloatBtn.Position = UDim2.new(0, 65, 0, 0)
KnifeFloatBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
KnifeFloatBtn.Text = "🔪\n[ฆ่ารอบตัว]"
KnifeFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KnifeFloatBtn.Font = Enum.Font.SourceSansBold
KnifeFloatBtn.TextSize = 11
KnifeFloatBtn.Parent = FloatContainer
Instance.new("UICorner", KnifeFloatBtn).CornerRadius = UDim.new(0, 12)

-- หน้าต่างหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🔪 MM2 ULTIMATE (rygdeeeeee)"
Title.TextColor3 = Color3.fromRGB(241, 196, 15)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local function createButton(name, posY, bgColor, text, callback)
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

createButton("EspBtn", 38, Color3.fromRGB(192, 57, 43), "👁️ ESP ตรวจไอเทม/ชื่อ: OFF", function(btn)
    Settings.EspEnabled = not Settings.EspEnabled
    btn.BackgroundColor3 = Settings.EspEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "👁️ ESP ตรวจไอเทม/ชื่อ: " .. (Settings.EspEnabled and "ON" or "OFF")
end)

createButton("InfJumpBtn", 76, Color3.fromRGB(192, 57, 43), "🦘 Infinity Jump (กระโดดรัว): OFF", function(btn)
    Settings.InfJump = not Settings.InfJump
    btn.BackgroundColor3 = Settings.InfJump and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🦘 Infinity Jump (กระโดดรัว): " .. (Settings.InfJump and "ON" or "OFF")
end)

createButton("FlyBtn", 114, Color3.fromRGB(192, 57, 43), "🕊️ โหมดบินได้ (Fly): OFF", function(btn)
    Settings.Flying = not Settings.Flying
    btn.BackgroundColor3 = Settings.Flying and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🕊️ โหมดบินได้ (Fly): " .. (Settings.Flying and "ON" or "OFF")
    if Settings.Flying then startFly() end
end)

createButton("XrayBtn", 152, Color3.fromRGB(192, 57, 43), "🔍 X-Ray กำแพงโปร่งใส: OFF", function(btn)
    Settings.XrayEnabled = not Settings.XrayEnabled
    btn.BackgroundColor3 = Settings.XrayEnabled and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = "🔍 X-Ray กำแพง: " .. (Settings.XrayEnabled and "ON" or "OFF")
    toggleXray(Settings.XrayEnabled)
end)

local speedState = 1
createButton("SpeedBtn", 190, Color3.fromRGB(230, 126, 34), "⚡ เพิ่มความเร็ววิ่ง: Normal (16)", function(btn)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if speedState == 1 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 28
            btn.Text = "⚡ ความเร็ววิ่ง: Fast (28)"
            speedState = 2
        elseif speedState == 2 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 40
            btn.Text = "⚡ ความเร็ววิ่ง: Turbo (40)"
            speedState = 3
        else
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            btn.Text = "⚡ ความเร็ววิ่ง: Normal (16)"
            speedState = 1
        end
    end
end)

-- การทำงานปุ่มลอย
GunFloatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local backpack = p:FindFirstChild("Backpack")
                local isMurderer = p.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                if isMurderer then
                    local myHrp = LocalPlayer.Character.HumanoidRootPart
                    myHrp.CFrame = CFrame.new(myHrp.Position, p.Character.Head.Position)
                    break
                end
            end
        end
    end)
end)

KnifeFloatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                myHrp.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
                task.wait(0.05)
            end
        end
    end)
end)

print("🚀 rygdeeeeee MM2 Hub Loaded Successfully!")
