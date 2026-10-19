-- [[ VIP STEAL EGGS HUB: ALL ZONES & COPY KEY LINK (ZORFIJE ONLY) ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

-- ตรวจสอบสิทธิ์ VIP (เฉพาะ Zoryfje เท่านั้น)
local ALLOWED_VIP = "Zoryfje"
if LocalPlayer.Name ~= ALLOWED_VIP and LocalPlayer.DisplayName ~= ALLOWED_VIP then
    LocalPlayer:Kick("❌ สคริปต์นี้อนุญาตให้ใช้งานเฉพาะ VIP: Zorfije เท่านั้น!")
    return
end

-- ลบ UI เก่าออกก่อนป้องกันการรันซ้ำ
if PlayerGui:FindFirstChild("VIPEggAllZoneHub") then
    PlayerGui:FindFirstChild("VIPEggAllZoneHub"):Destroy()
end

-- ลิงก์หน้าเว็บ Get Key ของคุณ
local KEY_LINK = "https://oop280712-design.github.io/Key-script/"

-- รายชื่อบอสและโซนทั้งหมดตั้งแต่ Zone 1 ถึงโซนสุดท้าย
local bossList = {
    "🌐 [ทุกโซน/ทุกบอสในแมพ]",
    "🦂 [Zone 1-5] บอสแมงป่อง / Golem / Spider",
    "🐉 [Zone 6-10] บอสมังกร / Demon / King",
    "🤖 [Zone 11-15] บอส Robot / Cyber / Alien",
    "☣️ [Zone 16+] บอส Bio / Mythic / Titan",
    "✨ [Event/New] บอสใหม่ & คาแรคเตอร์ม็อด"
}
local currentBossIdx = 1

local Settings = {
    SelectedBoss = bossList[1],
    SelectedVersion = "v3.2 Standard",
    MyBaseCFrame = nil,
    AutoRedNight = false
}

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    Settings.MyBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
end

-- ฟังก์ชันสแกนหาไข่ของบอสทุกตัวทุกโซน
local function scanEggsForSelectedBoss()
    local matchedEggs = {}
    local bossCategory = Settings.SelectedBoss
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            local parent
            
