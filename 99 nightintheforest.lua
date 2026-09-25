-- [[ 99 Nights in the Forest: Ultimate Hub V2 ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    -- Player Category
    GodHeal = true,
    NoCold = true,
    SpeedBoost = false,
    WalkSpeedValue = 32,
    HighJump = false,
    JumpPowerValue = 100,
    FullBright = true,
    
    -- Auto Farm Category
    AutoChopWood = false,
    
    -- Item Category
    BringFood = false,
    BringAllItems = false,
    TargetItemName = ""
}

-- 1. ฟังก์ชันป้องกันหนาวตาย & อมตะ (Auto Heal)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        
        -- ป้องกันเลือดลด / Fast Heal
        if Settings.GodHeal and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        
        -- ปรับ Speed & Jump
        if Settings.SpeedBoost then hum.WalkSpeed = Settings.WalkSpeedValue end
        if Settings.HighJump then hum.JumpPower = Settings.JumpPowerValue end
    end
    
    -- ลบหมอก / เพิ่มความสว่างมองในป่ามืด
    if Settings.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
    end
end)

-- 2. ฟังก์ชันดึงของเข้าตัว (Bring Items)
task.spawn(function()
    while task.wait(0.5) do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Part") or item:IsA("MeshPart") then
                    -- ดึงอาหารทั้งหมด
                    if Settings.BringFood and (item.Name:lower():find("food") or item.Name:lower():find("apple") or item.Name:lower():find("meat")) then
                        item.CFrame = myPos + Vector3.new(0, 2, 0)
                    end
                    
                    -- ดึงของตามชื่อที่ตั้งเอง
                    if Settings.TargetItemName ~= "" and item.Name:lower():find(Settings.TargetItemName:lower()) then
                        item.CFrame = myPos + Vector3.new(0, 2, 0)
                    end
                    
                    -- ดึงของทุกอย่างในแมพ
                    if Settings.BringAllItems and item:FindFirstChildOfClass("ProximityPrompt") then
                        item.CFrame = myPos + Vector3.new(0, 2, 0)
                    end
                end
            end
        end
    end
end)

-- 3. ฟังก์ชัน Auto Farm ตัดไม้
task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoChopWood and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("tree") or obj.Name:lower():find("wood") then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                    break
                end
            end
        end
    end
end)

-- Создать Mobile GUI (หน้าต่างเมนูสไตล์ Spark Hub แบบแยกหมวดหมู่)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Forest99Ultimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🌲 99 FOREST: ULTIMATE HUB"
Title.TextColor3 = Color3.fromRGB(46, 204, 113)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(0.9, 0, 0.82, 0)
Scroll.Position = UDim2.new(0.05, 0, 0.13, 0)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 380)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

local function createToggle(text, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
    btn.Text = text .. (defaultState and ": ON" or ": OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(192, 57, 43)
        btn.Text = text .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

-- เพิ่มปุ่มในเมนู (หมวดหมู่ Player / Auto Farm / Bring Items)
createToggle("God Heal (อมตะ/ปั๊มเลือด)", Settings.GodHeal, function(v) Settings.GodHeal = v end)
createToggle("No Cold (ป้องกันหนาวตาย)", Settings.NoCold, function(v) Settings.NoCold = v end)
createToggle("Speed Boost (วิ่งไว 32)", Settings.SpeedBoost, function(v) Settings.SpeedBoost = v end)
createToggle("High Jump (กระโดดสูง)", Settings.HighJump, function(v) Settings.HighJump = v end)
createToggle("Full Bright (มองในป่ามืด)", Settings.FullBright, function(v) Settings.FullBright = v end)
createToggle("Auto Chop Wood (ออโต้ตัดไม้)", Settings.AutoChopWood, function(v) Settings.AutoChopWood = v v end)
createToggle("Bring Food (ดึงอาหารทั้งหมด)", Settings.BringFood, function(v) Settings.BringFood = v end)
createToggle("Bring All Items (ดึงของรอบตัว)", Settings.BringAllItems, function(v) Settings.BringAllItems = v end)
