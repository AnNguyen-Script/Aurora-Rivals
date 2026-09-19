-- ============================================================
-- MODULAR RIVALS | MODULE 4: PLAYER MODS, HITBOX & PHYSICS
-- ============================================================
return function(Shared, Targeting)
    local Player = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Workspace = Shared.Workspace
    local Camera = Shared.Camera
    local Const = Shared.Const
    local UserInputService = Shared.UserInputService
    local RunService = Shared.RunService
    local forEachEnemy = Targeting.forEachEnemy
    local isSafeShield = Targeting.isSafeShield
    local undergroundSurfaceY = nil

-- Hitbox Expander Cache & Reset Logic
local originalHitboxes = {}
local function ResetHitboxes()
    for part, orig in pairs(originalHitboxes) do
        if part and part.Parent then
            pcall(function()
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
            end)
        end
    end
    table.clear(originalHitboxes)
end



local noClipParts = {}
local function RefreshNoClipParts()
    table.clear(noClipParts)
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(noClipParts, part)
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    RefreshNoClipParts()
    char.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            table.insert(noClipParts, desc)
        end
    end)
end)
if LocalPlayer.Character then
    RefreshNoClipParts()
    LocalPlayer.Character.DescendantAdded:Connect(function(desc)
        if desc:IsA("BasePart") then
            table.insert(noClipParts, desc)
        end
    end)
end


    local cachedHitboxVal = nil
    local cachedHitboxSizeVec = nil

    local function UpdatePhysics(step)
        -- Xuyên tường, Chui đất & Speed Tele không cấp phát bộ nhớ
    if Settings.Noclip or (Settings.UndergroundNoclip and undergroundSurfaceY) or Settings.SpeedTele then
        for i = 1, #noClipParts do
            local part = noClipParts[i]
            if part and part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Slow Fall (Hãm tốc độ rơi chậm mượt mà)
    if Settings.SlowFall and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not Settings.Fly and not (Settings.UndergroundNoclip and undergroundSurfaceY) then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local currentVel = hrp.Velocity
        local maxDown = -(Settings.SlowFallSpeed or 5)
        if currentVel.Y < maxDown then
            hrp.Velocity = Vector3.new(currentVel.X, maxDown, currentVel.Z)
        end
    end

    -- Hitbox Expander (Mở rộng Hitbox Đầu hoặc Thân - Hỗ trợ cả Người chơi & NPC/Bot)
    if Settings.HitboxExpander then
        local isHead = (Settings.HitboxPart == "Head" or Settings.HitboxPart == "Đầu")
        local targetName = isHead and "Head" or "HumanoidRootPart"
        if cachedHitboxVal ~= Settings.HitboxSize then
            cachedHitboxVal = Settings.HitboxSize
            cachedHitboxSizeVec = Vector3.new(cachedHitboxVal, cachedHitboxVal, cachedHitboxVal)
        end
        local sizeVal = cachedHitboxSizeVec
        local targetTransparency = Settings.HitboxInvisible and 1 or 0.55

        forEachEnemy(function(char, source)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = char:FindFirstChild(targetName)
                if not part and not isHead then
                    part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char.PrimaryPart
                end
                if part and part:IsA("BasePart") then
                    if not originalHitboxes[part] then
                        originalHitboxes[part] = {
                            Size = part.Size,
                            Transparency = part.Transparency,
                            CanCollide = part.CanCollide
                        }
                    end
                    if part.Size ~= sizeVal or part.Transparency ~= targetTransparency then
                        part.Size = sizeVal
                        part.Transparency = targetTransparency
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
    
    -- Auto Teleport bám địch (Hỗ trợ cả Người chơi & NPC/Bot - Tối ưu hóa Squared Distance)
    if Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character.HumanoidRootPart
        if not originalTeleportCFrame then
            originalTeleportCFrame = myHrp.CFrame
        end
        local closestEnemy = nil
        local shortestDistSq = math.huge
        local myPos = myHrp.Position
        local maxRange = Settings.TeleportRange or 1000
        local maxRangeSq = maxRange * maxRange
        
        forEachEnemy(function(char, source)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local targetHrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart
            if char and targetHrp and hum and hum.Health > 0 and not isSafeShield(source, char) then
                local diff = targetHrp.Position - myPos
                local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                if distSq <= maxRangeSq and distSq < shortestDistSq then
                    shortestDistSq = distSq
                    closestEnemy = targetHrp
                end
            end
        end)

        if closestEnemy then
            local offsetPos
            local posType = Settings.AutoTeleportPosition
            
            if posType == "Random" then
                posType = Const.TELE_TYPES[math.random(1, #Const.TELE_TYPES)]
            end
            
            if posType == "Trên Đầu" then
                offsetPos = closestEnemy.Position + Vector3.new(0, Settings.AutoTeleportDistance + 3, 0)
            elseif posType == "Trái" then
                offsetPos = closestEnemy.Position + (closestEnemy.CFrame.RightVector * -Settings.AutoTeleportDistance) + Vector3.new(0, 1.5, 0)
            elseif posType == "Phải" then
                offsetPos = closestEnemy.Position + (closestEnemy.CFrame.RightVector * Settings.AutoTeleportDistance) + Vector3.new(0, 1.5, 0)
            else -- Mặc định là Sau Lưng
                local behindOffset = closestEnemy.CFrame.LookVector * -Settings.AutoTeleportDistance
                offsetPos = closestEnemy.Position + behindOffset + Vector3.new(0, 1.5, 0)
            end
            
            myHrp.CFrame = CFrame.new(offsetPos, closestEnemy.Position)
            myHrp.Velocity = Vector3.zero
            
            if Settings.AutoTeleportCameraLock then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestEnemy.Position)
            end
        elseif Settings.AutoTeleportReturn and originalTeleportCFrame then
            -- Không còn kẻ địch nào (hoặc toàn bộ đang có khiên an toàn) -> Tự tele về vị trí ban đầu
            myHrp.CFrame = originalTeleportCFrame
            myHrp.Velocity = Vector3.zero
        end
    end

    -- Speed Tele bám địch (Tốc độ Speed + Noclip di chuyển đến kẻ địch - Tối ưu hóa Squared Distance)
    if Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character.HumanoidRootPart
        if not originalSpeedTeleCFrame then
            originalSpeedTeleCFrame = myHrp.CFrame
        end
        local closestEnemy = nil
        local shortestDistSq = math.huge
        local myPos = myHrp.Position
        local maxRange = Settings.TeleportRange or 1000
        local maxRangeSq = maxRange * maxRange
        
        forEachEnemy(function(char, source)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local targetHrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart
            if char and targetHrp and hum and hum.Health > 0 and not isSafeShield(source, char) then
                local diff = targetHrp.Position - myPos
                local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                if distSq <= maxRangeSq and distSq < shortestDistSq then
                    shortestDistSq = distSq
                    closestEnemy = targetHrp
                end
            end
        end)

        if closestEnemy then
            local offsetPos
            local posType = Settings.AutoTeleportPosition
            
            if posType == "Random" then
                posType = Const.TELE_TYPES[math.random(1, #Const.TELE_TYPES)]
            end
            
            if posType == "Trên Đầu" then
                offsetPos = closestEnemy.Position + Vector3.new(0, Settings.AutoTeleportDistance + 3, 0)
            elseif posType == "Trái" then
                offsetPos = closestEnemy.Position + (closestEnemy.CFrame.RightVector * -Settings.AutoTeleportDistance) + Vector3.new(0, 1.5, 0)
            elseif posType == "Phải" then
                offsetPos = closestEnemy.Position + (closestEnemy.CFrame.RightVector * Settings.AutoTeleportDistance) + Vector3.new(0, 1.5, 0)
            else -- Mặc định là Sau Lưng
                local behindOffset = closestEnemy.CFrame.LookVector * -Settings.AutoTeleportDistance
                offsetPos = closestEnemy.Position + behindOffset + Vector3.new(0, 1.5, 0)
            end
            
            local diff = offsetPos - myHrp.Position
            local dist = diff.Magnitude
            local moveSpeed = Settings.SpeedTeleSpeed or 50
            local stepDist = moveSpeed * 0.016
            
            if dist <= stepDist or dist <= 0.5 then
                myHrp.CFrame = CFrame.new(offsetPos, closestEnemy.Position)
            else
                local moveDir = diff.Unit
                myHrp.CFrame = CFrame.new(myHrp.Position + (moveDir * stepDist), closestEnemy.Position)
            end
            myHrp.Velocity = Vector3.zero
            
            if Settings.AutoTeleportCameraLock then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestEnemy.Position)
            end
        elseif Settings.AutoTeleportReturn and originalSpeedTeleCFrame then
            local diff = originalSpeedTeleCFrame.Position - myHrp.Position
            local dist = diff.Magnitude
            local moveSpeed = Settings.SpeedTeleSpeed or 50
            local stepDist = moveSpeed * 0.016
            
            if dist <= stepDist or dist <= 0.5 then
                myHrp.CFrame = originalSpeedTeleCFrame
            else
                local moveDir = diff.Unit
                local lookAtTarget = originalSpeedTeleCFrame.Position + originalSpeedTeleCFrame.LookVector * 10
                myHrp.CFrame = CFrame.new(myHrp.Position + (moveDir * stepDist), lookAtTarget)
            end
            myHrp.Velocity = Vector3.zero
        end
    end
    end

    local function UpdatePlayer(step)
        local now = tick()

        -- SPINBOT / ANTI-AIM
        if Settings.SpinBot and LocalPlayer.Character then
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if myHrp and myHum and myHum.Health > 0 then
                myHum.AutoRotate = false
                local spinSpeed = (Settings.SpinSpeed or 50) * 0.4
                local spinAngle = (now * spinSpeed * math.pi * 2) % (math.pi * 2)
                myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, spinAngle, 0)
            end
        end

        -- 3. PLAYER MODS
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = LocalPlayer.Character.Humanoid
            local hrp = LocalPlayer.Character.HumanoidRootPart

            if Settings.SpeedHack then humanoid.WalkSpeed = Settings.WalkSpeed end
            if Settings.JumpHack then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Settings.JumpPower
            end
            if Settings.GravityHack then
                Workspace.Gravity = Settings.Gravity
            end

            if Settings.Fly then
                humanoid.PlatformStand = true
                local moveDir = Vector3.zero
                local camCFrame = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * Settings.FlySpeed
                end
                hrp.Velocity = moveDir
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + camCFrame.LookVector)
            elseif Settings.UndergroundNoclip and undergroundSurfaceY then
                humanoid.PlatformStand = true
                local moveDir = Vector3.zero
                local camCFrame = Camera.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                
                moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * Settings.WalkSpeed
                end
                
                local targetY = undergroundSurfaceY - Settings.UndergroundDistance
                hrp.Velocity = moveDir
                
                local camLx, camLz = camCFrame.LookVector.X, camCFrame.LookVector.Z
                if math.abs(camLx) < 0.001 and math.abs(camLz) < 0.001 then
                    camLx, camLz = hrp.CFrame.LookVector.X, hrp.CFrame.LookVector.Z
                end
                
                local lookAtPos = Vector3.new(hrp.Position.X + camLx, targetY, hrp.Position.Z + camLz)
                hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, targetY, hrp.Position.Z), lookAtPos)
            else
                humanoid.PlatformStand = false
                if Settings.SlowFall then
                    local currentVel = hrp.Velocity
                    local maxDown = -(Settings.SlowFallSpeed or 5)
                    if currentVel.Y < maxDown then
                        hrp.Velocity = Vector3.new(currentVel.X, maxDown, currentVel.Z)
                    end
                end
            end
        end
    end

    UserInputService.JumpRequest:Connect(function()
        if Settings.InfJump
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    Player.originalHitboxes = originalHitboxes
    Player.appliedHitboxes = appliedHitboxes
    Player.ResetHitboxes = ResetHitboxes
    Player.RefreshNoClipParts = RefreshNoClipParts
    Player.UpdatePhysics = UpdatePhysics
    Player.UpdatePlayer = UpdatePlayer

    return Player
end
