-- [[ 99 Nights in the Forest: Auto Gem Magnet & Server Hop Loop (Fixed Error 773) ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId

-- ระบบ Auto Queue สำหรับ Delta Executor
if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/oop280712-design/my-cloud-app/main/99_gems.lua"))()
    ]])
end

-- ฟังก์ชันดึงเพชรเข้าตัว
local function bringGems()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local itemName = item.Name:lower()
                if itemName:find("gem") or itemName:find("diamond") or itemName:find("ruby") or itemName:find("crystal") then
                    item.CFrame = myPos + Vector3.new(0, 1, 0)
                end
            end
        end
    end
end

-- ฟังก์ชัน Hop เซิร์ฟเวอร์แบบปลอดภัย (ป้องกัน Error 773)
local function safeServerHop()
    print("กำลังสแกนหาเซิร์ฟเวอร์ใหม่...")
    
    local api = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(api))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            -- ย้ายไปเซิร์ฟที่มีคนเล่น และไม่ใช่เซิร์ฟเดิม
            if server.id ~= JobId and server.playing < server.maxPlayers and server.playing > 0 then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                end)
                task.wait(2)
            end
        end
    end
    
    -- ถ้าย้ายเจาะจงไม่ผ่าน ให้ย้ายแบบสุ่มสแตนดาร์ด
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- เริ่มทำงาน
task.spawn(function()
    -- รอให้เกมโหลดตัวละครเสร็จสมบูรณ์ก่อน
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    print("💎 เริ่มต้นกวาดเพชร...")
    
    -- หน่วงเวลาเล็กน้อยให้เพชรในเซิร์ฟเวอร์โหลดขึ้นมาครบ
    task.wait(1.5)
    
    for i = 1, 10 do
        bringGems()
        task.wait(0.2)
    end

    print("✅ กวาดเพชรเสร็จแล้ว กำลังย้ายเซิร์ฟเวอร์...")
    task.wait(1)
    safeServerHop()
end)
