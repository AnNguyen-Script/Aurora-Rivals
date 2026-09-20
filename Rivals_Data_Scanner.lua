-- ============================================================
-- RIVALS DATA SCANNER | SCAN VŨ KHÍ & CẤP ĐỘ / LEVEL
-- Tạo bởi An Nguyễn Studio - Chuyên dụng để dò tìm cấu trúc dữ liệu
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local reportLines = {}

local function log(txt)
    txt = tostring(txt)
    print(txt)
    table.insert(reportLines, txt)
end

log("============================================================")
log("🔍 BẮT ĐẦU QUÉT DỮ LIỆU RIVALS (WEAPON & LEVEL/XP SCANNER)")
log("Thời gian quét: " .. os.date("%X %d/%m/%Y"))
log("============================================================\n")

-- 1. QUÉT ATTRIBUTES CỦA LOCALPLAYER & OTHER PLAYERS
log("--- [1] ATTRIBUTES CỦA PLAYERS ---")
for _, p in ipairs(Players:GetPlayers()) do
    local isLocal = (p == LocalPlayer) and " (BẠN)" or ""
    log(string.format("Player: %s (%s)%s", p.Name, p.DisplayName, isLocal))
    
    local attrs = p:GetAttributes()
    local hasAttr = false
    for k, v in pairs(attrs) do
        hasAttr = true
        log(string.format("   • Attr: [%s] = %s (%s)", tostring(k), tostring(v), typeof(v)))
    end
    if not hasAttr then
        log("   • (Không có Attributes trên Player)")
    end
    
    -- Quét các Folder / Value con của Player
    log("   • Children của Player:")
    local children = p:GetChildren()
    for _, child in ipairs(children) do
        if child:IsA("ValueBase") then
            log(string.format("      - [%s] (%s) = %s", child.Name, child.ClassName, tostring(child.Value)))
        elseif child:IsA("Folder") or child:IsA("Configuration") then
            log(string.format("      - Folder [%s] (%s):", child.Name, child.ClassName))
            for _, subChild in ipairs(child:GetChildren()) do
                if subChild:IsA("ValueBase") then
                    log(string.format("           * [%s] (%s) = %s", subChild.Name, subChild.ClassName, tostring(subChild.Value)))
                else
                    log(string.format("           * [%s] (%s)", subChild.Name, subChild.ClassName))
                end
            end
        else
            log(string.format("      - [%s] (%s)", child.Name, child.ClassName))
        end
    end
    log("")
end

-- 2. QUÉT CHARACTER CỦA LOCALPLAYER & ENEMY
log("\n--- [2] CHARACTER & VŨ KHÍ (WEAPONS / MODELS / TOOLS) ---")
for _, p in ipairs(Players:GetPlayers()) do
    local char = p.Character
    if char then
        local isLocal = (p == LocalPlayer) and " (BẠN)" or ""
        log(string.format("Character của %s%s (Parent: %s):", p.Name, isLocal, tostring(char.Parent)))
        
        -- Attributes của Character
        local charAttrs = char:GetAttributes()
        for k, v in pairs(charAttrs) do
            log(string.format("   • Char Attr: [%s] = %s (%s)", tostring(k), tostring(v), typeof(v)))
        end
        
        -- Tìm Tools
        local tools = {}
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                table.insert(tools, obj.Name)
            end
        end
        if #tools > 0 then
            log("   • Tools tìm thấy: " .. table.concat(tools, ", "))
        else
            log("   • Không có Instance Tool truyền thống")
        end
        
        -- Tìm các Model hoặc Part nghi ngờ là Vũ khí trong Character
        log("   • Các Models/Items đặc biệt trong Character:")
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Accessory") then
                local modelAttrs = obj:GetAttributes()
                local attrStr = ""
                for ak, av in pairs(modelAttrs) do
                    attrStr = attrStr .. string.format(" [%s=%s]", tostring(ak), tostring(av))
                end
                log(string.format("      - [%s] (%s)%s", obj.Name, obj.ClassName, attrStr))
                
                -- Quét 1 cấp con của Model này
                for _, sub in ipairs(obj:GetChildren()) do
                    if sub:IsA("Model") or sub:IsA("ValueBase") or sub.Name:lower():find("gun") or sub.Name:lower():find("weapon") then
                        log(string.format("           * [%s] (%s)", sub.Name, sub.ClassName))
                    end
                end
            end
        end
        
        -- Quét Backpack
        local backpack = p:FindFirstChild("Backpack")
        if backpack then
            log("   • Items trong Backpack:")
            for _, bpItem in ipairs(backpack:GetChildren()) do
                log(string.format("      - [%s] (%s)", bpItem.Name, bpItem.ClassName))
            end
        end
        log("")
    end
end

-- 3. QUÉT THƯ MỤC DỮ LIỆU TRONG REPLICATEDSTORAGE
log("\n--- [3] QUÉT REPLICATEDSTORAGE ĐỐI VỚI DỮ LIỆU VŨ KHÍ & STATS ---")
for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
    local n = obj.Name:lower()
    if n:find("weapon") or n:find("gun") or n:find("item") or n:find("stat") or n:find("player") or n:find("data") or n:find("profile") then
        log(string.format("ReplicatedStorage -> [%s] (%s):", obj.Name, obj.ClassName))
        local subCount = 0
        for _, sub in ipairs(obj:GetChildren()) do
            subCount = subCount + 1
            if subCount <= 15 then -- Giới hạn 15 items đầu để tránh tràn log
                log(string.format("   • [%s] (%s)", sub.Name, sub.ClassName))
            end
        end
        if subCount > 15 then
            log(string.format("   • ... và %d items khác", subCount - 15))
        end
    end
end

-- 4. QUÉT WORKSPACE CHO WEAPONS HOẶC VIEWMODELS
log("\n--- [4] QUÉT WORKSPACE CHO VIEWMODELS / DROPPED ITEMS ---")
local cam = workspace.CurrentCamera
if cam then
    for _, obj in ipairs(cam:GetChildren()) do
        log(string.format("Camera Child: [%s] (%s)", obj.Name, obj.ClassName))
        for _, sub in ipairs(obj:GetChildren()) do
            log(string.format("   • [%s] (%s)", sub.Name, sub.ClassName))
        end
    end
end

log("\n============================================================")
log("✅ HOÀN THÀNH QUÉT DỮ LIỆU!")
log("============================================================")

local fullReport = table.concat(reportLines, "\n")

-- Tự động copy vào Clipboard nếu executor hỗ trợ
local copied = false
if setclipboard then
    pcall(function()
        setclipboard(fullReport)
        copied = true
    end)
elseif toclipboard then
    pcall(function()
        toclipboard(fullReport)
        copied = true
    end)
end

-- Ghi ra file nếu executor hỗ trợ
local savedFile = false
if writefile then
    pcall(function()
        writefile("Rivals_Scan_Data.txt", fullReport)
        savedFile = true
    end)
end

warn("\n[RIVALS SCANNER] ĐÃ XONG!")
if copied then
    warn(">> ĐÃ TỰ ĐỘNG COPY TOÀN BỘ KẾT QUẢ VÀO CLIPBOARD CỦA BẠN! BẠN CHỈ CẦN BẤM CTRL + V ĐỂ GỬI CHO AI.")
end
if savedFile then
    warn(">> ĐÃ LƯU KẾT QUẢ VÀO FILE: workspace/Rivals_Scan_Data.txt")
end
warn(">> Bạn cũng có thể xem kết quả trực tiếp trong bảng Console F9 của Roblox.\n")
