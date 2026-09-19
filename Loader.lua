-- ============================================================
-- MODULAR RIVALS | ENTRY POINT: LOADER (GITHUB & LOCAL HYBRID)
-- Tạo Bởi An Nguyễn Đẹp Trai - Im Goned
-- ============================================================

-- ============================================================
-- 1. CẤU HÌNH GITHUB (ĐỂ CHIA SẺ CHO BẠN BÈ CHỈ CẦN 1 DÒNG LỆNH)
-- ============================================================
local GITHUB_CONFIG = {
    Enabled = true,                    -- Bật true để tải trực tiếp từ link GitHub
    Username = "AnNguyen-Script", -- Thay bằng Tên tài khoản GitHub của bạn
    Repository = "Rivals",      -- Thay bằng Tên Repository GitHub
    Branch = "main",                   -- Nhánh chính (mặc định: main)
    Folder = ""                        -- Nếu để trong thư mục con trên GitHub thì điền (ví dụ: "Modular_Rivals"), để trống nếu ở gốc
}

-- 2. Hàm Import Module Tự Động (Hỗ trợ cả GitHub HTTP lẫn Local File)
local function Import(name)
    local content = nil
    local resolvedSource = nil

    -- Ưu tiên 1: Tải từ GitHub nếu đã cấu hình Username
    if GITHUB_CONFIG.Enabled and GITHUB_CONFIG.Username ~= "YOUR_GITHUB_USERNAME" then
        local folderPart = (GITHUB_CONFIG.Folder ~= "" and (GITHUB_CONFIG.Folder .. "/")) or ""
        local rawUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s%s?v=%d",
            GITHUB_CONFIG.Username,
            GITHUB_CONFIG.Repository,
            GITHUB_CONFIG.Branch,
            folderPart,
            name,
            math.floor(tick())
        )
        local ok, res = pcall(game.HttpGet, game, rawUrl)
        if ok and res and #res > 0 and not string.find(res, "404: Not Found") then
            content = res
            resolvedSource = rawUrl
        end
    end

    -- Ưu tiên 2: Nếu chưa cấu hình GitHub hoặc không có mạng -> Tự động nạp file Local trên máy tính
    if not content then
        local BASE_PATHS = {
            "Modular_Rivals/",
            "",
            "workspace/Modular_Rivals/",
        }

        if isfile then
            for _, prefix in ipairs(BASE_PATHS) do
                local testPath = prefix .. name
                if isfile(testPath) then
                    content = readfile(testPath)
                    resolvedSource = testPath
                    break
                end
            end
        end

        if not content and loadfile then
            for _, prefix in ipairs(BASE_PATHS) do
                local testPath = prefix .. name
                local ok, fn = pcall(loadfile, testPath)
                if ok and fn then
                    return fn()
                end
            end
        end
    end

    if not content then
        error("[RIVALS LOADER] Không thể tìm thấy module '" .. name .. "' trên GitHub lẫn thư mục Local workspace!")
    end

    local fn, compileErr = loadstring(content, resolvedSource or name)
    if not fn then
        error("[RIVALS LOADER] Lỗi biên dịch module '" .. name .. "': " .. tostring(compileErr))
    end

    return fn()
end

-- 3. Khởi tạo các Module tuần tự
local Shared    = Import("Shared.lua")
local Shield    = Import("Shield.lua")(Shared)
local Targeting = Import("Targeting.lua")(Shared, Shield)
local Player    = Import("Player.lua")(Shared, Targeting)
local Aim       = Import("Aim.lua")(Shared, Targeting)
local ESP       = Import("ESP.lua")(Shared, Targeting)
local UI        = Import("UI.lua")(Shared, Shield, Targeting, ESP, Aim, Player)

-- 4. Kích hoạt Anti-Cheat Shield
pcall(function()
    Shield.InitShield()
end)

-- 5. Vòng lặp Physics (Stepped)
local steppedConn = Shared.RunService.Stepped:Connect(function(step)
    Player.UpdatePhysics(step)
end)

-- 6. Vòng lặp Render (RenderStepped)
local frames = 0
local currentFPS = 60
local lastFPSUpdate = tick()
local expTime = 999 * 24 * 60 * 60

local renderConn = Shared.RunService.RenderStepped:Connect(function(step)
    local now = tick()
    local Camera = Shared.Camera
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local camPos = Camera.CFrame.Position

    -- Cập nhật FPS & Watermark
    frames = frames + 1
    if now - lastFPSUpdate >= 1 then
        currentFPS = math.floor(frames / (now - lastFPSUpdate))
        frames = 0
        lastFPSUpdate = now
        local days = math.floor(expTime / 86400)
        local hours = math.floor((expTime % 86400) / 3600)
        local mins = math.floor((expTime % 3600) / 60)
        local secs = expTime % 60
        if Shared.UI_Elements.Watermark then
            Shared.UI_Elements.Watermark.Text = string.format("RIVALS ● %d FPS ● Expire in: %02dd %02dh %02dm %02ds", currentFPS, days, hours, mins, secs)
        end
    end

    -- Cập nhật Aim & ESP
    Aim.UpdateAim(step, center)
    ESP.UpdateESP(camPos, center)
end)

-- 7. Anti-AFK tích hợp sẵn
local afkConn = Shared.LocalPlayer.Idled:Connect(function()
    if Shared.VirtualUser then
        pcall(function()
            Shared.VirtualUser:CaptureController()
            Shared.VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- 8. Dọn dẹp tài nguyên khi Menu bị đóng / destroy
UI.ScreenGui.Destroying:Connect(function()
    pcall(function() renderConn:Disconnect() end)
    pcall(function() steppedConn:Disconnect() end)
    pcall(function() afkConn:Disconnect() end)

    pcall(function() Aim.FOVring:Remove() end)
    pcall(function() Aim.AimSnaplineDraw:Remove() end)
    pcall(function() Aim.AimWarnText:Remove() end)
    for _, draw in pairs(Aim.CrosshairDraws) do
        pcall(function() draw:Remove() end)
    end
    for target, _ in pairs(ESP.ESPTable) do
        pcall(function() ESP.removeESP(target) end)
    end
    if ESP.ChamsFolder and ESP.ChamsFolder.Parent then
        pcall(function() ESP.ChamsFolder:Destroy() end)
    end
    Player.ResetHitboxes()
end)

-- 9. Hoàn tất khởi tạo
UI.UpdateTabDots()
Shared.ApplyTheme()
task.wait(0.1)
pcall(function() UI.ScreenGui.Parent = Shared.parentGui end)
Shared.SendNotification("System", "Rivals Modular Menu v2.14.0 đã sẵn sàng!")
