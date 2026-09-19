-- ============================================================
-- MODULAR RIVALS | MODULE: AIMBOT, PRO AIM, AUTOFIRE & VISUALS
-- ============================================================
return function(Shared, Targeting)
    local Aim = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Camera = Shared.Camera
    local UserInputService = Shared.UserInputService
    local ColorList = Shared.ColorList

    -- Drawing objects
    local FOVring = Drawing.new("Circle")
    FOVring.Visible = false
    FOVring.Thickness = 1.5
    FOVring.Radius = Settings.FOV
    FOVring.Transparency = 0.8
    FOVring.Color = Color3.fromRGB(155, 89, 235)
    FOVring.Filled = false
    Aim.FOVring = FOVring

    local AimSnaplineDraw = Drawing.new("Line")
    AimSnaplineDraw.Visible = false
    AimSnaplineDraw.Thickness = 1
    AimSnaplineDraw.Color = Color3.fromRGB(155, 89, 235)
    AimSnaplineDraw.Transparency = 0.8
    Aim.AimSnaplineDraw = AimSnaplineDraw

    local CrosshairDraws = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line")
    }
    Aim.CrosshairDraws = CrosshairDraws

    local AimWarnText = Drawing.new("Text")
    AimWarnText.Visible = false
    AimWarnText.Size = 20
    AimWarnText.Center = true
    AimWarnText.Outline = true
    AimWarnText.OutlineColor = Color3.fromRGB(0, 0, 0)
    Aim.AimWarnText = AimWarnText

    -- Internal state
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
                local target = Targeting.getClosestPlayer()
                local targetChar = target and (target:IsA("Player") and target.Character or target)
                if targetChar then
                    local tPart = Targeting.getTargetPart(targetChar)
                    if tPart then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, tPart.Position)
                        Camera.CFrame = Targeting.AddJitter(targetCFrame, Settings.AimJitter)
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

    local function getProAimTargetCached()
        local now = tick()
        if cachedProTarget and (now - cachedProValid) < 0.05 then
            return cachedProTarget
        end
        cachedProTarget = Targeting.getClosestPlayer()
        cachedProValid = now
        return cachedProTarget
    end

    -- Update Aim logic (chạy trong RenderStepped)
    local function UpdateAim(step, center)
        local now = tick()

        -- 1. FOV Ring
        if Settings.ProAimEnabled and Settings.ProAimFOVVisible then
            FOVring.Visible = true
            FOVring.Position = center
            FOVring.Radius = Settings.ProAimFOV or 120
            FOVring.Color = Shared.Theme.Accent
        elseif Settings.AimEnabled and Settings.FOVVisible then
            FOVring.Visible = true
            FOVring.Position = center
            FOVring.Radius = Settings.FOV or 170
            FOVring.Color = Shared.Theme.Accent
        else
            FOVring.Visible = false
        end

        -- 2. Snapline
        local mousePos = UserInputService:GetMouseLocation()
        local closestTarget = (now - cachedClosestValid < 0.05) and cachedClosest or Targeting.getClosestPlayer()
        cachedClosest = closestTarget
        cachedClosestValid = now

        local hasTarget = (Settings.AimEnabled and closestTarget) or (Settings.ProAimEnabled and ProAimLockedTarget)
        if (Settings.AimSnapline or Settings.ProAimSnapline) and hasTarget then
            local snapTarget = nil
            if Settings.ProAimEnabled and ProAimLockedTarget then
                snapTarget = ProAimLockedTarget
            elseif closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    local tPart = Targeting.getTargetPart(targetChar)
                    if tPart and (not Settings.WallCheck or Targeting.isVisible(tPart)) then
                        snapTarget = tPart
                    end
                end
            end

            if snapTarget then
                local targetPos, onScreen = Camera:WorldToViewportPoint(snapTarget.Position)
                if onScreen and targetPos.Z > 0 then
                    AimSnaplineDraw.Visible = true
                    AimSnaplineDraw.From = mousePos
                    AimSnaplineDraw.To = Vector2.new(targetPos.X, targetPos.Y)
                else
                    AimSnaplineDraw.Visible = false
                end
            else
                AimSnaplineDraw.Visible = false
            end
        else
            AimSnaplineDraw.Visible = false
        end

        -- 3. Aimbot (Camera Lerp)
        if Settings.AimEnabled and isAiming and closestTarget then
            local target = closestTarget
            local targetChar = target:IsA("Player") and target.Character or target
            if targetChar then
                local tPart = Targeting.getTargetPart(targetChar)
                if tPart and (not Settings.WallCheck or Targeting.isVisible(tPart)) then
                    local desired = CFrame.new(Camera.CFrame.Position, tPart.Position)
                    desired = Targeting.AddJitter(desired, Settings.AimJitter)
                    local t = 1 - math.pow(1 - math.clamp(Settings.AimSmoothness, 0, 1), step * 60)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(t, 0.05, 1))
                end
            end
        end

        -- 4. Pro Aim (Mouse Moverel)
        local isHolding = isProAimHolding
        if not isHolding and Settings.ProAimEnabled then
            local bind = Settings.ProAimHoldMouse
            if bind and bind.EnumType == Enum.UserInputType then
                local ok, pressed = pcall(UserInputService.IsMouseButtonPressed, UserInputService, bind)
                if ok and pressed then isHolding = true end
            elseif bind and bind.EnumType == Enum.KeyCode then
                local ok, pressed = pcall(UserInputService.IsKeyDown, UserInputService, bind)
                if ok and pressed then isHolding = true end
            end
        end

        if Settings.ProAimEnabled and isHolding then
            local mousePos = UserInputService:GetMouseLocation()
            local targetSource, targetPart, targetScreenPos = Targeting.getClosestPlayerToCursor(mousePos)
            if targetPart and targetScreenPos then
                ProAimLockedTarget = targetPart
                local smoothVal = math.clamp(Settings.ProAimSmoothness or 0.75, 0.01, 1)
                local xOffset = Settings.ProAimXOffset or 0
                local yOffset = Settings.ProAimYOffset or 0
                local deltaX = (targetScreenPos.X - mousePos.X + xOffset) * smoothVal
                local deltaY = (targetScreenPos.Y - mousePos.Y + yOffset) * smoothVal

                if (Settings.ProAimJitter or 0) > 0 then
                    deltaX = deltaX + (math.random() - 0.5) * Settings.ProAimJitter * 2
                    deltaY = deltaY + (math.random() - 0.5) * Settings.ProAimJitter * 2
                end

                Shared.mousemoverel(deltaX, deltaY)
            else
                ProAimLockedTarget = nil
            end
        else
            ProAimLockedTarget = nil
        end

        -- 5. AutoFire
        local shouldAutoFire = Settings.AutoFire or (Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if shouldAutoFire then
            local targetPart = ProAimLockedTarget
            if not targetPart and closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    targetPart = Targeting.getTargetPart(targetChar)
                end
            end
            if targetPart and (now - lastShotTime) >= (Settings.AutoFireDelay or 0) then
                local isSafe = Targeting.isSameTeam(closestTarget) or (closestTarget and Targeting.isSafeShield(closestTarget, targetPart.Parent))
                if not isSafe then
                    local isVis = not Settings.AutoFireWallCheck or Targeting.isAutoFireVisible(targetPart)
                    if isVis then
                        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and pos.Z > 0 then
                            local adist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            local maxFov = Settings.FOV or 100
                            if adist <= maxFov then
                                lastShotTime = now
                                Targeting.FireShot()
                            end
                        end
                    end
                end
            end
        end

        -- 6. No Recoil (MOUSE AIMLOCK-BASED RECOIL STABILIZATION)
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
                        Shared.mousemoverel(deltaX * s, deltaY * s)
                    end
                else
                    noRecoilTargetPoint = cam.Position + cam.LookVector * 1000
                end
            end
        else
            noRecoilTargetPoint = nil
        end

        -- 7. Slow Fall
        if Settings.SlowFall and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local currentVel = hrp.Velocity
            local maxDown = -(Settings.SlowFallSpeed or 5)
            if currentVel.Y < maxDown then
                hrp.Velocity = Vector3.new(currentVel.X, maxDown, currentVel.Z)
            end
        end

        -- 8. Spectate
        if Settings.Spectating and Settings.SpectatePlayer ~= "" then
            local targetPlayer = Players:FindFirstChild(Settings.SpectatePlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = targetPlayer.Character.Humanoid
            end
        elseif Camera.CameraSubject ~= LocalPlayer.Character then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end

        -- 9. Crosshair
        if Settings.Crosshair then
            local size, thick = Settings.CrosshairSize, Settings.CrosshairThickness
            local color = ColorList[Settings.CrosshairColor] or Color3.fromRGB(0, 255, 0)

            for _, line in pairs(CrosshairDraws) do
                line.Color = color
                line.Thickness = thick
                line.Visible = true
            end

            if Settings.CrosshairStyle == "Cross" then
                CrosshairDraws.Top.From = Vector2.new(center.X, center.Y - size)
                CrosshairDraws.Top.To = Vector2.new(center.X, center.Y)
                CrosshairDraws.Bottom.From = Vector2.new(center.X, center.Y)
                CrosshairDraws.Bottom.To = Vector2.new(center.X, center.Y + size)
                CrosshairDraws.Left.From = Vector2.new(center.X - size, center.Y)
                CrosshairDraws.Left.To = Vector2.new(center.X, center.Y)
                CrosshairDraws.Right.From = Vector2.new(center.X, center.Y)
                CrosshairDraws.Right.To = Vector2.new(center.X + size, center.Y)
            elseif Settings.CrosshairStyle == "Dot" then
                CrosshairDraws.Top.From = Vector2.new(center.X, center.Y - 2)
                CrosshairDraws.Top.To = Vector2.new(center.X, center.Y + 2)
                CrosshairDraws.Bottom.Visible = false
                CrosshairDraws.Left.From = Vector2.new(center.X - 2, center.Y)
                CrosshairDraws.Left.To = Vector2.new(center.X + 2, center.Y)
                CrosshairDraws.Right.Visible = false
            elseif Settings.CrosshairStyle == "X" then
                local offset = size * 0.707
                CrosshairDraws.Top.From = Vector2.new(center.X - offset, center.Y - offset)
                CrosshairDraws.Top.To = center
                CrosshairDraws.Bottom.From = center
                CrosshairDraws.Bottom.To = Vector2.new(center.X + offset, center.Y + offset)
                CrosshairDraws.Left.From = Vector2.new(center.X - offset, center.Y + offset)
                CrosshairDraws.Left.To = center
                CrosshairDraws.Right.From = center
                CrosshairDraws.Right.To = Vector2.new(center.X + offset, center.Y - offset)
            end
        else
            for _, line in pairs(CrosshairDraws) do line.Visible = false end
        end

        -- 10. Aim Warning
        if Settings.AimWarning then
            if now - lastWarnScan > 0.08 then
                lastWarnScan = now
                cachedWarnTarget = nil
                local myChar = LocalPlayer.Character
                local myHead = myChar and myChar:FindFirstChild("Head")
                if myHead then
                    local myHeadPos = myHead.Position
                    local maxDist = Settings.AimDist or 1000
                    local maxDistSq = maxDist * maxDist

                    Targeting.forEachEnemy(function(target, char, isNPC)
                        if cachedWarnTarget then return end
                        if Targeting.isSameTeam(target) then return end
                        local head = char:FindFirstChild("Head")
                        if head then
                            local dSq = (head.Position - myHeadPos).Magnitude ^ 2
                            if dSq <= maxDistSq then
                                local lookDir = head.CFrame.LookVector
                                local toMe = (myHeadPos - head.Position).Unit
                                if lookDir:Dot(toMe) > 0.88 then
                                    cachedWarnTarget = target
                                end
                            end
                        end
                    end)
                end
            end

            if cachedWarnTarget then
                local flash = (math.floor(now * 4) % 2 == 0)
                local nameStr = cachedWarnTarget:IsA("Player") and (cachedWarnTarget.DisplayName or cachedWarnTarget.Name) or (cachedWarnTarget:GetAttribute("DisplayName") or cachedWarnTarget.Name)
                AimWarnText.Text = "⚠ ĐANG BỊ NHẮM BỞI: " .. string.upper(nameStr) .. " ⚠"
                AimWarnText.Position = Vector2.new(center.X, center.Y - 100)
                AimWarnText.Color = flash and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)
                AimWarnText.Visible = true
            else
                AimWarnText.Visible = false
            end
        else
            AimWarnText.Visible = false
        end
    end
    Aim.UpdateAim = UpdateAim

    return Aim
end
