-- [[ 99 Nights in the Forest: Auto Gem Magnet & Server Hop Loop ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local JobId = game.JobId

-- ระบบ Auto Queue บน Delta Executor ให้สคริปต์รันใหม่อัตโนมัติเมื่อย้ายเซิร์ฟเวอร์
if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/oop280712-design/my-cloud-app/main/99_gems.lua"))()
    ]])
end

-- ฟังก์ชันดึงเพชรเข้าตัวละคร
local function bringGems()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Part") or item:IsA("MeshPart") then
                local itemName = item.Name:lower()
                -- ตรวจจับไอเทมเพชร/อัญมณีทุกชนิดในแมพ
                if itemName:find("gem") or itemName:find("diamond") or itemName:find("ruby") or itemName:find("crystal") then
                    item.CFrame = myPos + Vector3.new(0, 1, 0)
                end
            end
        end
    end
end

-- ฟังก์ชันวาร์ปเปลี่ยนเซิร์ฟเวอร์ (Server Hop)
local function serverHop()
    print("กำลังค้นหาเซิร์ฟเวอร์ใหม่...")
    local api = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(api))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.id ~= JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
    
    -- ถ้าค้นหาเซิร์ฟเวอร์ไม่เจอ ให้ย้ายไปเซิร์ฟเวอร์สุ่มทั่วไป
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- เริ่มการทำงานอัตโนมัติ
task.spawn(function()
    print("💎 เริ่มต้นระบบกวาดเพชรอัตโนมัติ...")
    
    -- รอดึงเพชรรอบๆ ตัวละคร 3 วินาทีเพื่อให้ดึงครบทุกชิ้น
    for i = 1, 15 do
        bringGems()
        task.wait(0.2)
    end

    print("✅ กวาดเพชรสำเร็จ! กำลังย้ายไปเซิร์ฟเวอร์ถัดไป...")
    task.wait(0.5)
    serverHop()
end)
