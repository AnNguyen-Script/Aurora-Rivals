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

-- ============================================================
-- DRAWING CORE
-- ============================================================
local FOVring = Drawing.new("Circle")
FOVring.Visible = false; FOVring.Thickness = 1.5; FOVring.Color = Theme.AccentOn
FOVring.Filled = false; FOVring.Transparency = 1
FOVring.Radius = Settings.FOV; FOVring.Position = Camera.ViewportSize / 2

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



    local aimSafeCounter = 0
    local isAiming = false
    local cachedClosest = nil
    local cachedClosestValid = 0
    local ProAimLockedTarget = nil
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
        local now = tick()

        if now - cachedClosestValid > 0.05 then
        cachedClosest = getClosestPlayer()
        cachedClosestValid = now
    end
    local closestTarget = cachedClosest

    -- 1. FOV & SNAPLINE (1 VÒNG TRÒN DUY NHẤT ĐỒNG BỘ)
    FOVring.Visible = Settings.FOVVisible
    if Settings.FOVVisible then
        local mousePos = UserInputService:GetMouseLocation()
        FOVring.Position = mousePos
        FOVring.Radius = Settings.FOV
        local hasTarget = (Settings.AimEnabled and closestTarget) or (Settings.ProAimEnabled and (ProAimLockedTarget ~= nil))
        FOVring.Color = hasTarget and Color3.fromRGB(255, 50, 50) or Theme.AccentOn
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
            AimSnaplineDraw.Visible = true
        else
            AimSnaplineDraw.Visible = false
        end
    else
        AimSnaplineDraw.Visible = false
    end

    -- 2. AIM HOLD (Hard Lock + smooth + jitter)
    if isAiming and Settings.AimEnabled and Settings.AimHoldMode then
        local target = closestTarget
        if target and target.Character then
            local tPart = getTargetPart(target.Character)
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

    -- 2.5 PRO AIM (Aimlock using mousemoverel & Smoothness - Tối ưu hóa 0 ép chuỗi/closure)
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
        local mousePos = UserInputService:GetMouseLocation()
        local targetSource, targetPart, targetScreenPos = getClosestPlayerToCursor(mousePos)

        if targetPart and targetScreenPos then
            ProAimLockedTarget = targetPart
            local smoothVal = math.clamp(Settings.ProAimSmoothness or 0.75, 0.01, 1)
            local xOffset = Settings.ProAimXOffset or 0
            local yOffset = Settings.ProAimYOffset or 0
            local deltaX = (targetScreenPos.X - mousePos.X + xOffset) * smoothVal
            local deltaY = (targetScreenPos.Y - mousePos.Y + yOffset) * smoothVal
            
            mousemoverel(deltaX, deltaY)
        else
            ProAimLockedTarget = nil
        end
    else
        ProAimLockedTarget = nil
    end

    -- 2.6 AUTO FIRE & AUTO FIRE (HOLD M2) + WALL CHECK
    local shouldAutoFire = Settings.AutoFire or (Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
    if shouldAutoFire then
        local targetPart = ProAimLockedTarget
        if not targetPart then
            if closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    targetPart = getTargetPart(targetChar)
                end
            end
        end
        if not targetPart then
            targetPart = getProAimTargetCached()
        end

        if targetPart then
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local adist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                local maxFov = Settings.FOV or 100
                local delayTime = math.max(Settings.AutoFireDelay or 0, 0.05)
                if adist <= maxFov and (now - lastShotTime) >= delayTime then
                    if isAutoFireVisible(targetPart) then
                        lastShotTime = now
                        FireShot()
                    end
                end
            end
        end
    end

    -- 2.7 NO RECOIL (MOUSE AIMLOCK-BASED RECOIL STABILIZATION)
    if Settings.NoRecoil and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or (Settings.AutoFire and not Settings.AutoFireHoldM2) or (Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))) then
        local cam = Camera.CFrame
        local mouseDelta = UserInputService:GetMouseDelta()
        local mousePos = UserInputService:GetMouseLocation()

        if math.abs(mouseDelta.X) > 2.5 or math.abs(mouseDelta.Y) > 2.5 or not noRecoilTargetPoint then
            noRecoilTargetPoint = cam.Position + cam.LookVector * 1000
        else
            if ProAimLockedTarget then
                noRecoilTargetPoint = ProAimLockedTarget.Position
            else
                noRecoilTargetPoint = cam.Position + (noRecoilTargetPoint - cam.Position).Unit * 1000
            end

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
