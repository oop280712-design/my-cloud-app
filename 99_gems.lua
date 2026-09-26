-- [[ 99 Nights in the Forest: Auto Gem Magnet & Safe Server Hop ]] --

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId

-- ระบบ Auto Queue สำหรับ Delta Executor ให้รันต่อเมื่อย้ายเซิร์ฟเวอร์สำเร็จ
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

-- ฟังก์ชันย้ายเซิร์ฟเวอร์แบบปลอดภัยไม่ติด Error 773
local function safeHop()
    print("🔄 กำลังเตรียมย้ายเซิร์ฟเวอร์...")
    
    -- ดึงรายการ Public Server ล่าสุด
    local servers = {}
    local req = pcall(function()
        local res = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if res and res.data then
            for _, v in pairs(res.data) do
                if v.playing and v.maxPlayers and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end)

    if #servers > 0 then
        -- สุ่มเลือกเซิร์ฟเวอร์ที่ไม่ใช่เซิร์ฟเวอร์เดิม
        local randomServerId = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(PlaceId, randomServerId, LocalPlayer)
    else
        -- ถ้าดึงรายชื่อไม่สำเร็จ ให้ใช้ระบบวาร์ปปกติของ Roblox
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end

-- เริ่มทำงาน
task.spawn(function()
    -- รอให้ตัวละครโหลดสมบูรณ์ก่อน
    repeat task.wait(1) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    print("💎 เริ่มต้นระบบกวาดเพชร...")
    task.wait(2) -- รอไอเทมในแมพโหลดครบ
    
    -- กวาดเพชรเข้าตัว
    for i = 1, 15 do
        bringGems()
        task.wait(0.2)
    end

    print("✅ กวาดเพชรเรียบร้อย! กำลังย้ายเซิร์ฟเวอร์เพื่อฟาร์มต่อ...")
    task.wait(1)
    
    -- พยายามย้ายเซิร์ฟเวอร์แบบปลอดภัย
    local success, err = pcall(function()
        safeHop()
    end)
    
    if not success then
        warn("ย้ายแบบปกติไม่สำเร็จ กำลังวาร์ปสุ่มแทน:", err)
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end)
