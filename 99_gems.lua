-- [[ 99 Nights in the Forest: Instant Gem Pull & Return to Lobby ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- หมายเลข PlaceId ของหน้า Lobby หลัก (เปลี่ยนให้ตรงกับ PlaceId ของแมพ Lobby)
local LOBBY_PLACE_ID = game.PlaceId 

-- ฟังก์ชันดึงเพชรเข้าตัวละครและอัปเดตตำแหน่ง
local function collectAllGems()
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
        return 0
    end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local gemCount = 0

    -- ค้นหาไอเทมเพชร/อัญมณีทั้งหมดใน workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:find("gem") or name:find("diamond") or name:find("ruby") or name:find("crystal") then
                -- ย้ายตำแหน่งเพชรมาไว้ที่ตัวละครเพื่อให้ระบบของเกมทำการเก็บเข้าตัวอัตโนมัติ
                obj.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
                obj.CanCollide = false
                gemCount = gemCount + 1
            end
        end
    end
    
    return gemCount
end

-- เริ่มกระบวนการฟาร์มเพชร
task.spawn(function()
    -- รอให้ตัวละครโหลดสมบูรณ์
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    print("💎 กำลังสแกนและดึงเพชรทั้งหมดในแมพเข้าตัว...")
    
    -- ทำการดึงเพชรรัวๆ เพื่อให้แน่ใจว่าเก็บครบทุกชิ้น
    local totalGemsFound = 0
    for i = 1, 10 do
        totalGemsFound = collectAllGems()
        task.wait(0.15)
    end
    
    print("✅ ดึงเพชรเรียบร้อยแล้ว! จำนวนที่พบประมาณ: " .. tostring(totalGemsFound) .. " ชิ้น")
    task.wait(0.8) -- รอระบบเกมประมวลผลเพิ่มจำนวนเพชรเข้าบัญชี
    
    print("🚀 กำลังส่งตัวกลับ Lobby / ย้ายเกม...")
    
    -- วาร์ปออกจากแมพเพื่อกลับไป Lobby หรือย้ายเซิร์ฟเวอร์
    local success, err = pcall(function()
        TeleportService:Teleport(LOBBY_PLACE_ID, LocalPlayer)
    end)
    
    if not success then
        warn("ไม่สามารถวาร์ปได้ กำลังลองอีกครั้ง:", err)
        TeleportService:TeleportToPlaceInstance(LOBBY_PLACE_ID, game.JobId, LocalPlayer)
    end
end)
