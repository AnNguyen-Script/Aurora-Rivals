-- ============================================================
-- MODULAR RIVALS | MODULE 5: AIMBOT, PRO AIM, AUTOFIRE & VISUALS
-- ============================================================
return function(Shared, Targeting)
    local Aim = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local UserInputService = Shared.UserInputService
    local Theme = Shared.Theme
    local mousemoverel = Shared.mousemoverel
    local mouse1click_fn = Shared.mouse1click_fn
    local VirtualInputManager = Shared.VirtualInputManager
    local ColorList = Shared.ColorList
    local getClosestPlayer = Targeting.getClosestPlayer
    local getTargetPart = Targeting.getTargetPart
    local getClosestPlayerToCursor = Targeting.getClosestPlayerToCursor
    local isAutoFireVisible = Targeting.isAutoFireVisible
    local forEachEnemy = Targeting.forEachEnemy
    local isSameTeam = Targeting.isSameTeam
    local getProAimTargetCached = Targeting.getProAimTargetCached
    local WallCheck = Targeting.WallCheck
    local isSafeShield = Targeting.isSafeShield

-- ============================================================
-- DRAWING CORE
-- ============================================================
local FOVring = Drawing.new("Circle")
FOVring.Visible = false; FOVring.Thickness = 1.5; FOVring.Color = Theme.AccentOn
FOVring.Filled = false; FOVring.Transparency = 1
FOVring.Radius = Settings.FOV; FOVring.Position = Camera.ViewportSize / 2
Shared.FOVring = FOVring

local AimSnaplineDraw = Drawing.new("Line")
AimSnaplineDraw.Visible = false; AimSnaplineDraw.Thickness = 1.5
AimSnaplineDraw.Color = Color3.fromRGB(255, 50, 50); AimSnaplineDraw.Transparency = 1

local CrosshairDraws = {
    L = Drawing.new("Line"), R = Drawing.new("Line"),
    T = Drawing.new("Line"), B = Drawing.new("Line"),
    Circle = Drawing.new("Circle"), Dot = Drawing.new("Circle")
}

local AimWarnText = Drawing.new("Text")
AimWarnText.Visible = false
AimWarnText.Center = true
AimWarnText.Outline = true
AimWarnText.Size = 22

local ESPTable = {}



    -- =========================================================================
    -- [THUẬT TOÁN 1: SNAP-ON-FIRE (HÚT TÂM KHI ĐÈ M1 KHÔNG XUNG ĐỘT CLICK)]
    -- true: Thuật toán 1 (Đè M1 tự bắn tự nhiên + Hút tâm siêu tốc không kẹt đạn)
    -- false: Logic cũ (Đè M2 gửi click ảo FireShot)
    -- =========================================================================
    local USE_ALGO_1_SNAP_ON_FIRE = true

    local aimSafeCounter = 0
    local isAiming = false
    local cachedClosest = nil
    local cachedClosestValid = 0
    local ProAimLockedTarget = nil
    local ProAimLockedChar = nil
    local ProAimLastVisibleTime = 0
    local ProAimAccumX = 0
    local ProAimAccumY = 0
    local emaVel = Vector3.zero
    local emaLastTarget = nil
    local lastTargetSwitch = 0
    local aimAcquireTime = 0
    local lastShotTime = 0
    local noRecoilTargetPoint = nil
    local cachedProTarget = nil
    local cachedProValid = 0
    local lastWarnScan = 0
    local isProAimHolding = false
    local cachedWarnTarget = nil

    local function FireShot()
        if mouse1click_fn then
            pcall(mouse1click_fn)
        elseif VirtualInputManager then
            pcall(VirtualInputManager.SendMouseButtonEvent, VirtualInputManager, 0, 0, 0, true, game, 0)
            task.delay(0.02, function()
                pcall(VirtualInputManager.SendMouseButtonEvent, VirtualInputManager, 0, 0, 0, false, game, 0)
            end)
        end
    end

    local function AddJitter(cf, amount)
        if amount <= 0 then return cf end
        local rX = (math.random() - 0.5) * 2 * math.rad(amount)
        local rY = (math.random() - 0.5) * 2 * math.rad(amount)
        return cf * CFrame.Angles(rX, rY, 0)
    end

    local function UpdateAim(step, center)
        local needTarget = Settings.AimEnabled or Settings.ProAimEnabled or Settings.AimSnapline or Settings.AutoFire or Settings.AutoFireHoldM2 or Settings.TriggerBot or Settings.FOVVisible
        if not needTarget then
            if FOVring.Visible then FOVring.Visible = false end
            if AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = false end
            cachedClosest = nil
            return
        end

        local now = tick()
        if now - cachedClosestValid > 0.05 then
            cachedClosest = getClosestPlayer()
            cachedClosestValid = now
        end
        local closestTarget = cachedClosest

    -- 1. FOV & SNAPLINE (1 VÒNG TRÒN DUY NHẤT ĐỒNG BỘ - CHỐNG PROPERTY THRASHING)
    if FOVring.Visible ~= Settings.FOVVisible then
        FOVring.Visible = Settings.FOVVisible
    end
    if Settings.FOVVisible then
        local mousePos = UserInputService:GetMouseLocation()
        FOVring.Position = mousePos
        if FOVring.Radius ~= Settings.FOV then
            FOVring.Radius = Settings.FOV
        end
        local hasTarget = (Settings.AimEnabled and closestTarget) or (Settings.ProAimEnabled and (ProAimLockedTarget ~= nil))
        local targetColor = hasTarget and Color3.fromRGB(255, 50, 50) or Theme.AccentOn
        if FOVring.Color ~= targetColor then
            FOVring.Color = targetColor
        end
    end

    local snapTarget = nil
    if Settings.FOVVisible or Settings.AimSnapline then
        if Settings.AimEnabled and closestTarget then
            local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
            if targetChar then
                local tPart = getTargetPart(targetChar)
                if tPart then snapTarget = tPart end
            end
        elseif Settings.ProAimEnabled and ProAimLockedTarget then
            snapTarget = ProAimLockedTarget
        end
    end

    if snapTarget then
        local targetPos, onScreen = Camera:WorldToViewportPoint(snapTarget.Position)
        if onScreen then
            AimSnaplineDraw.From = center
            AimSnaplineDraw.To = Vector2.new(targetPos.X, targetPos.Y)
            if not AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = true end
        else
            if AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = false end
        end
    else
        if AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = false end
    end

    -- 2. AIM HOLD (Hard Lock + smooth + jitter)
    if isAiming and Settings.AimEnabled and Settings.AimHoldMode then
        local target = closestTarget
        local targetChar = target and (target:IsA("Player") and target.Character or target)
        if targetChar then
            local tPart = getTargetPart(targetChar)
            if tPart then
                local desired = CFrame.new(Camera.CFrame.Position, tPart.Position)
                desired = AddJitter(desired, Settings.AimJitter)
                if Settings.AimSmoothness >= 1 then
                    Camera.CFrame = desired
                else
                    local t = 1 - math.pow(1 - math.clamp(Settings.AimSmoothness, 0, 1), step * 60)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, t)
                end
            end
        end
    end

    -- Helper kiểm tra mục tiêu đã khóa còn sống và hợp lệ không (kèm 0.2s Grace Period chống mất dấu)
    local function isLockedTargetValid(part, char, currentTime)
        if not part or not part.Parent or not char or not char.Parent then
            return false
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then
            return false
        end
        local healthVal = char:FindFirstChild("Health") or char:FindFirstChild("health")
        if healthVal and (healthVal:IsA("NumberValue") or healthVal:IsA("IntValue")) and healthVal.Value <= 0 then
            return false
        end
        if char:GetAttribute("Health") and ((tonumber(char:GetAttribute("Health")) or 0) <= 0) then
            return false
        end
        if isSafeShield and isSafeShield(nil, char) then
            return false
        end
        local diff = part.Position - Camera.CFrame.Position
        local maxPhysicalDist = Settings.AimDist or Settings.ProAimDist or 1000
        if (diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z) > (maxPhysicalDist * maxPhysicalDist) then
            return false
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then
            if (currentTime - ProAimLastVisibleTime) > 0.15 then
                return false
            end
        end
        local mousePos = UserInputService:GetMouseLocation()
        local dx = screenPos.X - mousePos.X
        local dy = screenPos.Y - mousePos.Y
        local fov = (Settings.FOV or Settings.ProAimFOV or 120) * 1.8
        if (dx * dx + dy * dy) > (fov * fov) then
            return false
        end

        -- WallCheck với Bộ đệm duy trì mục tiêu 0.2s (Sticky Grace Period)
        if Settings.WallCheck and WallCheck then
            if not WallCheck(part) then
                -- Nếu vừa bị khuất sau vật cản mỏng/người khác: cho phép duy trì tối đa 0.2 giây
                if (currentTime - ProAimLastVisibleTime) > 0.2 then
                    return false
                end
            else
                ProAimLastVisibleTime = currentTime
            end
        else
            ProAimLastVisibleTime = currentTime
        end
        return true
    end

    -- 2.5 PRO AIM (Aimlock using mousemoverel - Siêu Dính & Siêu Mượt)
    -- [1] Lực hút Nam châm thích ứng (Adaptive Magnetism)
    -- [2] Bám vận tốc góc màn hình (Angular Velocity Feed-Forward)
    -- [3] Bù trừ độ nhạy chuột Roblox (Sensitivity-Aware Scaling)
    -- [4] Bộ đệm duy trì mục tiêu 0.2s (Sticky Grace Period)
    -- [5] Nội suy Hermite / Smoothstep tự nhiên, không giật khựng
    local isHolding = isProAimHolding
    if not isHolding and typeof(Settings.ProAimHoldMouse) == "EnumItem" then
        local bind = Settings.ProAimHoldMouse
        if bind.EnumType == Enum.UserInputType then
            local ok, pressed = pcall(UserInputService.IsMouseButtonPressed, UserInputService, bind)
            if ok and pressed then isHolding = true end
        elseif bind.EnumType == Enum.KeyCode then
            local ok, pressed = pcall(UserInputService.IsKeyDown, UserInputService, bind)
            if ok and pressed then isHolding = true end
        end
    end

    if Settings.ProAimEnabled and isHolding then
        -- 1. Giữ khóa dính mục tiêu (Sticky Lock): Kiểm tra mục tiêu kèm Grace Period
        if ProAimLockedTarget and not isLockedTargetValid(ProAimLockedTarget, ProAimLockedChar, now) then
            ProAimLockedTarget = nil
            ProAimLockedChar = nil
            ProAimAccumX = 0
            ProAimAccumY = 0
        end

        -- 2. Tìm mục tiêu mới nếu chưa khóa
        if not ProAimLockedTarget then
            local mousePos = UserInputService:GetMouseLocation()
            local targetSource, targetPart, targetScreenPos = getClosestPlayerToCursor(mousePos)
            if targetPart and targetScreenPos then
                ProAimLockedTarget = targetPart
                ProAimLockedChar = targetPart.Parent
                ProAimLastVisibleTime = now
                ProAimAccumX = 0
                ProAimAccumY = 0
            end
        end

        -- 3. Xử lý bám mục tiêu siêu dính & siêu mượt bằng mousemoverel
        if ProAimLockedTarget then
            local char = ProAimLockedChar or ProAimLockedTarget.Parent
            local rootPart = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
            local aimWorldPos = ProAimLockedTarget.Position

            -- Khử rung lắc do animation: Nếu aim vào Head, cố định X, Z theo HumanoidRootPart
            if rootPart and (ProAimLockedTarget.Name == "Head" or ProAimLockedTarget.Name == "HitboxHead") then
                aimWorldPos = Vector3.new(rootPart.Position.X, ProAimLockedTarget.Position.Y, rootPart.Position.Z)
            end

            -- [THUẬT TOÁN 1: BỘ LỌC VẬN TỐC EMA 2 TẦNG (EXPONENTIAL MOVING AVERAGE)]
            local rawVel = (rootPart and rootPart.AssemblyLinearVelocity) or ProAimLockedTarget.AssemblyLinearVelocity or Vector3.zero
            if rawVel.Magnitude > 120 then
                rawVel = rawVel.Unit * 120
            end

            if emaLastTarget ~= ProAimLockedTarget then
                emaVel = rawVel
                emaLastTarget = ProAimLockedTarget
            else
                -- Lọc sạch 65% xung giật do A-D spam / desync ping
                emaVel = emaVel:Lerp(rawVel, 0.35)
            end
            local targetVel = emaVel

            local dt = math.clamp(step or 0.016, 0.001, 0.05)

            -- Dự đoán trước vị trí mục tiêu (dt + bù trễ đầu vào ~0.02s)
            local predictedWorldPos = aimWorldPos + (targetVel * (dt + 0.02))

            local targetScreenPos, onScreen = Camera:WorldToViewportPoint(predictedWorldPos)
            if not onScreen then
                targetScreenPos, onScreen = Camera:WorldToViewportPoint(aimWorldPos)
            end

            if onScreen then
                -- [THUẬT TOÁN 2: TỌA ĐỘ TÂM CHUẨN XÁC ROBLOX (LOCKCENTER AWARE)]
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local mousePos = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) and center or UserInputService:GetMouseLocation()

                local xOffset = Settings.ProAimXOffset or 0
                local yOffset = Settings.ProAimYOffset or 0
                local deltaX = targetScreenPos.X - mousePos.X + xOffset
                local deltaY = targetScreenPos.Y - mousePos.Y + yOffset
                local distSq = deltaX * deltaX + deltaY * deltaY
                local dist = math.sqrt(distSq)

                -- [BÙ TRỪ ĐỘ NHẠY CHUỘT ROBLOX] Tự động cân bằng lực kéo theo MouseSensitivity
                local sensCompensation = 1.0
                pcall(function()
                    local ugs = UserSettings():GetService("UserGameSettings")
                    local sens = ugs.MouseSensitivity
                    if sens and sens > 0.01 then
                        sensCompensation = math.clamp(0.45 / sens, 0.35, 2.5)
                    end
                end)

                -- [BÁM VẬN TỐC GÓC MÀN HÌNH - FEED-FORWARD] Bám sát theo từng pixel mục tiêu dạt ngang
                local feedForwardX = 0
                local feedForwardY = 0
                if targetVel.Magnitude > 1 then
                    local curScr = Camera:WorldToViewportPoint(aimWorldPos)
                    local nextScr = Camera:WorldToViewportPoint(aimWorldPos + targetVel * dt)
                    feedForwardX = (nextScr.X - curScr.X) * 0.85
                    feedForwardY = (nextScr.Y - curScr.Y) * 0.85
                end

                -- Deadzone: nếu khoảng cách < 0.75 pixel (hoặc <= 2.5 pixel khi bật AimSafe) -> đã trúng tâm, giữ nguyên
                local deadzoneLimit = Settings.AimSafe and 2.5 or 0.75
                if dist >= deadzoneLimit then
                    local userSmooth = math.clamp(Settings.ProAimSmoothness or 0.75, 0.01, 1.0)

                    -- [THUẬT TOÁN 3: LÒ XO GIẢM CHẤN TỚI HẠN (CRITICALLY DAMPED SPRING-DAMPER PHYSICS)]
                    -- Tần số góc lò xo omega: Smooth cao -> kéo đầm tay, Smooth thấp -> bám tức thì
                    local omega = 18 + (1 - userSmooth) * 24 -- range [18, 42] rad/s

                    -- Hàm phân rã giảm chấn bậc 2 chuẩn vật lý: Không bao giờ văng lố (Zero Overshoot), không rung giật
                    local w_dt = omega * dt
                    local decay = 1 / (1 + w_dt + 0.48 * w_dt * w_dt)
                    local springFactor = math.clamp(1 - decay, 0.05, 0.95)

                    -- Lực hút nam châm thích ứng (Adaptive Magnetism): Khi chạm người đối thủ (<= 25px), tăng lực dính
                    local magnetMult = 1.0
                    if dist <= 25 then
                        magnetMult = 1.0 + (1.0 - (dist / 25)) * 0.40 -- tăng tới 1.40x
                    end

                    -- Tổng hợp lực kéo chuột lò xo mượt mà, đầm tay
                    local stepMoveX = ((deltaX * springFactor * magnetMult) + (feedForwardX * magnetMult)) * sensCompensation
                    local stepMoveY = ((deltaY * springFactor * magnetMult) + (feedForwardY * magnetMult)) * sensCompensation

                    -- Bộ tích lũy điểm ảnh phụ (Subpixel Accumulator) cho chuyển động mượt tuyệt đối
                    ProAimAccumX = ProAimAccumX + stepMoveX
                    ProAimAccumY = ProAimAccumY + stepMoveY

                    local moveX = math.round(ProAimAccumX)
                    local moveY = math.round(ProAimAccumY)

                    if moveX ~= 0 or moveY ~= 0 then
                        ProAimAccumX = ProAimAccumX - moveX
                        ProAimAccumY = ProAimAccumY - moveY
                        mousemoverel(moveX, moveY)
                    end
                else
                    ProAimAccumX = 0
                    ProAimAccumY = 0
                end
            else
                ProAimLockedTarget = nil
                ProAimLockedChar = nil
                emaVel = Vector3.zero
                emaLastTarget = nil
                ProAimAccumX = 0
                ProAimAccumY = 0
            end
        end
    else
        ProAimLockedTarget = nil
        ProAimLockedChar = nil
        ProAimAccumX = 0
        ProAimAccumY = 0
    end

    -- 2.6 AUTO FIRE & SILENT AIM (SNAP-ON-FIRE M1 / BACKUP M2 AUTOCLICK)
    if USE_ALGO_1_SNAP_ON_FIRE then
        local isHoldingM1 = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

        -- [A] THUẬT TOÁN 1: SNAP-ON-FIRE (SILENT AIM KHI ĐÈ CHUỘT TRÁI M1)
        -- Cơ chế: Người chơi đè M1 tự xả đạn bằng ngón tay -> Game bắn tự nhiên 100% không bị kẹt đạn.
        -- Script: Khi đè M1 và có địch trong FOV (kèm WallCheck nếu bật), tự động hút tâm (mousemoverel)
        -- dính thẳng vào mục tiêu mà KHÔNG gọi FireShot() -> Tuyệt đối không xung đột tín hiệu chuột!
        if Settings.AutoFireHoldM2 and isHoldingM1 then
            -- Nếu ProAim (Aimbot Safe) đang trực tiếp khóa mục tiêu này thì nhường ProAim kéo để tránh xung đột
            local isProAimHandling = Settings.ProAimEnabled and isHolding and (ProAimLockedTarget ~= nil)
            if not isProAimHandling then
                local targetPart = ProAimLockedTarget
                if not targetPart and closestTarget then
                    local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                    if targetChar then
                        targetPart = getTargetPart(targetChar)
                    end
                end
                if not targetPart then
                    targetPart = getProAimTargetCached()
                end

                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local canSnap = true
                        if Settings.AutoFireWallCheck and isAutoFireVisible then
                            canSnap = isAutoFireVisible(targetPart)
                        end

                        if canSnap then
                            local maxFov = Settings.AutoFireFOV or Settings.FOV or 100
                            local mousePos = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) and center or UserInputService:GetMouseLocation()
                            local deltaX = pos.X - mousePos.X
                            local deltaY = pos.Y - mousePos.Y
                            local distSq = deltaX * deltaX + deltaY * deltaY

                            if distSq <= (maxFov * maxFov) then
                                local dist = math.sqrt(distSq)
                                -- Bù trừ độ nhạy chuột Roblox
                                local sensCompensation = 1.0
                                pcall(function()
                                    local ugs = UserSettings():GetService("UserGameSettings")
                                    local sens = ugs.MouseSensitivity
                                    if sens and sens > 0.01 then
                                        sensCompensation = math.clamp(0.45 / sens, 0.35, 2.5)
                                    end
                                end)

                                -- Deadzone: Nếu khoảng cách < 1 pixel (hoặc <= 3 pixel khi bật AimSafe) thì giữ nguyên
                                local snapDeadzone = Settings.AimSafe and 3.0 or 1.0
                                if dist >= snapDeadzone then
                                    -- Khi AimSafe bật: Ease-out giảm tốc đàn hồi khi vào gần (dist <= 20px) để tâm lướt êm, không khựng cứng
                                    local snapFactor = 0.55
                                    if Settings.AimSafe then
                                        if dist <= 20 then
                                            snapFactor = 0.35 + (dist / 20) * 0.30
                                        else
                                            snapFactor = 0.55
                                        end
                                    else
                                        snapFactor = (dist <= 25) and 0.85 or 0.55
                                    end
                                    local moveX = math.round(deltaX * snapFactor * sensCompensation)
                                    local moveY = math.round(deltaY * snapFactor * sensCompensation)
                                    if moveX ~= 0 or moveY ~= 0 then
                                        mousemoverel(moveX, moveY)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- [B] AUTO FIRE (KILL AURA - Hands-free Auto Clicker)
        -- Chỉ kích hoạt FireShot() khi người chơi KHÔNG đè M1 (tránh xung đột với ngón tay)
        if Settings.AutoFire and not isHoldingM1 then
            local targetPart = ProAimLockedTarget
            if not targetPart and closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    targetPart = getTargetPart(targetChar)
                end
            end
            if not targetPart then
                targetPart = getProAimTargetCached()
            end

            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local maxFov = Settings.AutoFireFOV or Settings.FOV or 100
                    local dx = pos.X - center.X
                    local dy = pos.Y - center.Y
                    local delayTime = math.max(Settings.AutoFireDelay or 0, 0.05)
                    if (dx * dx + dy * dy) <= (maxFov * maxFov) and (now - lastShotTime) >= delayTime then
                        if isAutoFireVisible(targetPart) then
                            lastShotTime = now
                            FireShot()
                        end
                    end
                end
            end
        end
    else
        -- [LOGIC CŨ BACKUP: ĐÈ M2 GỬI CLICK ẢO FIRESHOT]
        local shouldAutoFire = Settings.AutoFire or (Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if shouldAutoFire then
            local targetPart = ProAimLockedTarget
            if not targetPart and closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    targetPart = getTargetPart(targetChar)
                end
            end
            if not targetPart then
                targetPart = getProAimTargetCached()
            end

            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local maxFov = Settings.FOV or 100
                    local dx = pos.X - center.X
                    local dy = pos.Y - center.Y
                    local delayTime = math.max(Settings.AutoFireDelay or 0, 0.05)
                    if (dx * dx + dy * dy) <= (maxFov * maxFov) and (now - lastShotTime) >= delayTime then
                        if isAutoFireVisible(targetPart) then
                            lastShotTime = now
                            FireShot()
                        end
                    end
                end
            end
        end
    end

    -- 2.7 NO RECOIL (MOUSE AIMLOCK-BASED RECOIL STABILIZATION)
    local isNoRecoilActive = false
    if Settings.NoRecoil then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            isNoRecoilActive = true
        elseif Settings.AutoFire then
            isNoRecoilActive = true
        elseif not USE_ALGO_1_SNAP_ON_FIRE and Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            isNoRecoilActive = true
        end
    end

    if isNoRecoilActive then
        -- NẾU ĐANG AIMLOCK KHÓA VÀO MỤC TIÊU:
        -- Aimlock đã tự động ghim chuột bám chặt mục tiêu, không can thiệp đè lên để tránh xung đột chuột gây giật rung
        if not (Settings.ProAimEnabled and isHolding and ProAimLockedTarget) then
            local cam = Camera.CFrame
            local mouseDelta = UserInputService:GetMouseDelta()
            local mousePos = UserInputService:GetMouseLocation()

            if math.abs(mouseDelta.X) > 2.5 or math.abs(mouseDelta.Y) > 2.5 or not noRecoilTargetPoint then
                noRecoilTargetPoint = cam.Position + cam.LookVector * 1000
            else
                noRecoilTargetPoint = cam.Position + (noRecoilTargetPoint - cam.Position).Unit * 1000

                local screenPos, onScreen = Camera:WorldToViewportPoint(noRecoilTargetPoint)
                if onScreen then
                    local deltaX = screenPos.X - mousePos.X
                    local deltaY = screenPos.Y - mousePos.Y
                    if math.abs(deltaX) > 0.2 or math.abs(deltaY) > 0.2 then
                        local s = math.clamp(Settings.NoRecoilStrength or 1, 0.1, 1)
                        mousemoverel(deltaX * s, deltaY * s)
                    end
                else
                    noRecoilTargetPoint = cam.Position + cam.LookVector * 1000
                end
            end
        end
    else
        noRecoilTargetPoint = nil
    end

    -- 4. SPECTATING
    if Settings.Spectating and Settings.SpectatePlayer ~= "" then
        local targetPlayer = Players:FindFirstChild(Settings.SpectatePlayer)
        if targetPlayer and targetPlayer.Character
            and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end

    -- 5. CROSSHAIR (Tối ưu hóa: chỉ render khi bật, không gọi C++ ẩn vô ích)
    if Settings.Crosshair then
        local size, thick = Settings.CrosshairSize, Settings.CrosshairThickness
        local color = ColorList[Settings.CrosshairColor] or Color3.fromRGB(0, 255, 0)
        for _, draw in pairs(CrosshairDraws) do
            draw.Color = color
            draw.Thickness = thick
        end

        if Settings.CrosshairStyle == "Cross" or Settings.CrosshairStyle == "Cross + Dot" then
            CrosshairDraws.L.Visible = true
            CrosshairDraws.L.From = Vector2.new(center.X - size, center.Y)
            CrosshairDraws.L.To = Vector2.new(center.X - 3, center.Y)
            CrosshairDraws.R.Visible = true
            CrosshairDraws.R.From = Vector2.new(center.X + 3, center.Y)
            CrosshairDraws.R.To = Vector2.new(center.X + size, center.Y)
            CrosshairDraws.T.Visible = true
            CrosshairDraws.T.From = Vector2.new(center.X, center.Y - size)
            CrosshairDraws.T.To = Vector2.new(center.X, center.Y - 3)
            CrosshairDraws.B.Visible = true
            CrosshairDraws.B.From = Vector2.new(center.X, center.Y + 3)
            CrosshairDraws.B.To = Vector2.new(center.X, center.Y + size)
        end
        if Settings.CrosshairStyle == "X" then
            local offset = size * 0.707
            CrosshairDraws.L.Visible = true
            CrosshairDraws.L.From = Vector2.new(center.X - offset, center.Y - offset)
            CrosshairDraws.L.To = Vector2.new(center.X - 2, center.Y - 2)
            CrosshairDraws.R.Visible = true
            CrosshairDraws.R.From = Vector2.new(center.X + offset, center.Y + offset)
            CrosshairDraws.R.To = Vector2.new(center.X + 2, center.Y + 2)
            CrosshairDraws.T.Visible = true
            CrosshairDraws.T.From = Vector2.new(center.X + offset, center.Y - offset)
            CrosshairDraws.T.To = Vector2.new(center.X + 2, center.Y - 2)
            CrosshairDraws.B.Visible = true
            CrosshairDraws.B.From = Vector2.new(center.X - offset, center.Y + offset)
            CrosshairDraws.B.To = Vector2.new(center.X - 2, center.Y + 2)
        end
        if Settings.CrosshairStyle == "Circle" then
            CrosshairDraws.Circle.Visible = true
            CrosshairDraws.Circle.Radius = size
            CrosshairDraws.Circle.Position = center
            CrosshairDraws.Circle.Filled = false
        end
        if Settings.CrosshairStyle == "Dot" or Settings.CrosshairStyle == "Cross + Dot" then
            CrosshairDraws.Dot.Visible = true
            CrosshairDraws.Dot.Radius = thick
            CrosshairDraws.Dot.Position = center
            CrosshairDraws.Dot.Filled = true
        end
    else
        for _, draw in pairs(CrosshairDraws) do
            if draw.Visible then draw.Visible = false end
        end
    end

    -- 5.5 CẢNH BÁO BỊ NGẮM (Tối ưu hóa: Giữ bộ đệm cachedWarnTarget, triệt tiêu lỗi chớp nháy)
    if Settings.AimWarning then
        if now - lastWarnScan > 0.12 then
            lastWarnScan = now
            cachedWarnTarget = nil
            local myChar = LocalPlayer.Character
            local myHead = myChar and myChar:FindFirstChild("Head")
            if myHead then
                local myHeadPos = myHead.Position
                local maxDist = Settings.AimDist or 1000
                local maxDistSq = maxDist * maxDist
                forEachEnemy(function(char, source)
                    local eHead = char:FindFirstChild("Head")
                    if eHead then
                        local diff = eHead.Position - myHeadPos
                        local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                        if distSq <= maxDistSq then
                            local dirToMe = (myHeadPos - eHead.Position).Unit
                            local dot = eHead.CFrame.LookVector:Dot(dirToMe)
                            if dot > 0.97 and char:FindFirstChildOfClass("Tool") then
                                cachedWarnTarget = source
                            end
                        end
                    end
                end)
            end
        end
        if cachedWarnTarget then
            local flash = (math.floor(now * 4) % 2 == 0)
            local nameStr = cachedWarnTarget:IsA("Player") and (cachedWarnTarget.DisplayName or cachedWarnTarget.Name) or (cachedWarnTarget.Name .. " [BOT]")
            AimWarnText.Visible = true
            AimWarnText.Text = "⚠ BỊ NGẮM: " .. nameStr .. " ⚠"
            AimWarnText.Color = flash and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)
            AimWarnText.Position = Vector2.new(center.X, center.Y - 120)
        else
            if AimWarnText.Visible then AimWarnText.Visible = false end
        end
    else
        if AimWarnText.Visible then AimWarnText.Visible = false end
    end

    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local bind = Settings.ProAimHoldMouse
        if bind and (input.KeyCode == bind or input.UserInputType == bind) then
            isProAimHolding = true
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Settings.AimEnabled then
            if Settings.AimHoldMode then
                isAiming = true
            else
                local target = getClosestPlayer()
                local targetChar = target and (target:IsA("Player") and target.Character or target)
                if targetChar then
                    local tPart = getTargetPart(targetChar)
                    if tPart then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, tPart.Position)
                        Camera.CFrame = AddJitter(targetCFrame, Settings.AimJitter)
                    end
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gpe)
        local bind = Settings.ProAimHoldMouse
        if bind and (input.KeyCode == bind or input.UserInputType == bind) then
            isProAimHolding = false
            ProAimLockedTarget = nil
            ProAimLockedChar = nil
            ProAimAccumX = 0
            ProAimAccumY = 0
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isAiming = false end
    end)

    Aim.FOVring = FOVring
    Aim.AimSnaplineDraw = AimSnaplineDraw
    Aim.CrosshairDraws = CrosshairDraws
    Aim.AimWarnText = AimWarnText
    Aim.UpdateAim = UpdateAim

    return Aim
end
