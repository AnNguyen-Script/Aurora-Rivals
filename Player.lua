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

    -- Character defaults & state tracking
    local defaultWalkSpeed = 16
    local defaultJumpPower = 50
    local defaultUseJumpPower = false
    local defaultGravity = 196.2

    local wasSpeedHack = false
    local wasJumpHack = false
    local wasGravityHack = false
    local wasSpinBot = false
    local wasFly = false
    local wasNoclipActive = false

    local noClipParts = {}
    local partOriginalCollide = {}

    local function RefreshNoClipParts()
        table.clear(noClipParts)
        table.clear(partOriginalCollide)
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(noClipParts, part)
                    if partOriginalCollide[part] == nil then
                        partOriginalCollide[part] = part.CanCollide
                    end
                end
            end
        end
    end

    local function RestoreCollisions()
        for i = 1, #noClipParts do
            local part = noClipParts[i]
            if part and part.Parent then
                local orig = partOriginalCollide[part]
                if orig ~= nil then
                    part.CanCollide = orig
                else
                    local name = part.Name
                    if name == "UpperTorso" or name == "LowerTorso" or name == "Torso" or name == "Head" then
                        part.CanCollide = true
                    else
                        part.CanCollide = false
                    end
                end
            end
        end
    end

    local function ResetSpeed()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = (defaultWalkSpeed and defaultWalkSpeed > 0) and defaultWalkSpeed or 16
        end
        wasSpeedHack = false
    end

    local function ResetJump()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = (defaultJumpPower and defaultJumpPower > 0) and defaultJumpPower or 50
            hum.UseJumpPower = defaultUseJumpPower or false
        end
        wasJumpHack = false
    end

    local function ResetGravity()
        Workspace.Gravity = defaultGravity or 196.2
        wasGravityHack = false
    end

    local function ResetFly()
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp then
                local bv = hrp:FindFirstChild("FlyBodyVelocity")
                if bv then bv:Destroy() end
                local bg = hrp:FindFirstChild("FlyBodyGyro")
                if bg then bg:Destroy() end
                pcall(function() hrp.Velocity = Vector3.zero end)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
            end
            if hum then
                hum.PlatformStand = false
            end
        end
        wasFly = false
    end

    local function ResetNoclip()
        RestoreCollisions()
        wasNoclipActive = false
    end

    local function ResetSpinBot()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
        end
        wasSpinBot = false
    end

    local function SetupCharacter(char)
        task.wait(0.2)
        RefreshNoClipParts()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if not Settings.SpeedHack and hum.WalkSpeed and hum.WalkSpeed > 0 then
                defaultWalkSpeed = hum.WalkSpeed
            end
            if not Settings.JumpHack and hum.JumpPower and hum.JumpPower > 0 then
                defaultJumpPower = hum.JumpPower
                defaultUseJumpPower = hum.UseJumpPower
            end
        end
        char.DescendantAdded:Connect(function(desc)
            if desc:IsA("BasePart") then
                table.insert(noClipParts, desc)
                if partOriginalCollide[desc] == nil then
                    partOriginalCollide[desc] = desc.CanCollide
                end
            end
        end)
    end

    LocalPlayer.CharacterAdded:Connect(SetupCharacter)
    if LocalPlayer.Character then
        SetupCharacter(LocalPlayer.Character)
    end

    local cachedHitboxVal = nil
    local cachedHitboxSizeVec = nil

    local function UpdatePhysics(step)
        -- Xuyên tường, Chui đất, Bay & Speed Tele không cấp phát bộ nhớ
        local isNoclipNeeded = Settings.Noclip or (Settings.UndergroundNoclip and Shared.undergroundSurfaceY) or Settings.SpeedTele or Settings.Fly
        if isNoclipNeeded then
            for i = 1, #noClipParts do
                local part = noClipParts[i]
                if part and part.Parent and part.CanCollide then
                    part.CanCollide = false
                end
            end
            wasNoclipActive = true
        elseif wasNoclipActive then
            RestoreCollisions()
            wasNoclipActive = false
        end

        -- Slow Fall (Hãm tốc độ rơi chậm mượt mà)
        if Settings.SlowFall and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not Settings.Fly and not (Settings.UndergroundNoclip and Shared.undergroundSurfaceY) then
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
                        part.Size = sizeVal
                        part.Transparency = targetTransparency
                        part.CanCollide = false
                    end
                end
            end)
        else
            if next(originalHitboxes) then
                ResetHitboxes()
            end
        end

        -- 2. AUTO TELEPORT (Lướt Tức Thời Đến Sau Lưng Kẻ Địch Gần Nhất)
        if Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = LocalPlayer.Character.HumanoidRootPart
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then
                local closestEnemy = nil
                local shortestDistSq = math.huge
                local maxRangeSq = Settings.TeleportRange * Settings.TeleportRange

                forEachEnemy(function(char, source)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local targetHrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and targetHrp and not isSafeShield(char) then
                        local diff = targetHrp.Position - myHrp.Position
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
                elseif Settings.AutoTeleportReturn and Shared.originalTeleportCFrame then
                    myHrp.CFrame = Shared.originalTeleportCFrame
                    myHrp.Velocity = Vector3.zero
                end
            end
        end

        -- SPEED TELEPORT
        if Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = LocalPlayer.Character.HumanoidRootPart
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then
                local closestEnemy = nil
                local shortestDistSq = math.huge
                local maxRangeSq = Settings.TeleportRange * Settings.TeleportRange

                forEachEnemy(function(char, source)
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local targetHrp = char:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and targetHrp and not isSafeShield(char) then
                        local diff = targetHrp.Position - myHrp.Position
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
                elseif Settings.AutoTeleportReturn and Shared.originalSpeedTeleCFrame then
                    local diff = Shared.originalSpeedTeleCFrame.Position - myHrp.Position
                    local dist = diff.Magnitude
                    local moveSpeed = Settings.SpeedTeleSpeed or 50
                    local stepDist = moveSpeed * 0.016
                    
                    if dist <= stepDist or dist <= 0.5 then
                        myHrp.CFrame = Shared.originalSpeedTeleCFrame
                    else
                        local moveDir = diff.Unit
                        local lookAtTarget = Shared.originalSpeedTeleCFrame.Position + Shared.originalSpeedTeleCFrame.LookVector * 10
                        myHrp.CFrame = CFrame.new(myHrp.Position + (moveDir * stepDist), lookAtTarget)
                    end
                    myHrp.Velocity = Vector3.zero
                end
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
                wasSpinBot = true
                local spinSpeed = (Settings.SpinSpeed or 50) * 0.4
                local spinAngle = (now * spinSpeed * math.pi * 2) % (math.pi * 2)
                myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, spinAngle, 0)
            end
        elseif wasSpinBot then
            ResetSpinBot()
        end

        -- 3. PLAYER MODS
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = LocalPlayer.Character.Humanoid
            local hrp = LocalPlayer.Character.HumanoidRootPart

            -- SpeedHack: Bật thì áp dụng, tắt thì lập tức khôi phục về default
            if Settings.SpeedHack then
                humanoid.WalkSpeed = Settings.WalkSpeed
                wasSpeedHack = true
            elseif wasSpeedHack then
                ResetSpeed()
            end

            -- JumpHack: Bật thì áp dụng, tắt thì lập tức khôi phục về default
            if Settings.JumpHack then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Settings.JumpPower
                wasJumpHack = true
            elseif wasJumpHack then
                ResetJump()
            end

            -- GravityHack: Bật thì áp dụng, tắt thì khôi phục trọng lực Roblox 196.2
            if Settings.GravityHack then
                Workspace.Gravity = Settings.Gravity
                wasGravityHack = true
            elseif wasGravityHack then
                ResetGravity()
            end

            -- Fly: Nâng cấp Anti-Gravity Hover và điều hướng 3D mượt mà
            if Settings.Fly then
                wasFly = true
                humanoid.PlatformStand = true

                local flyBv = hrp:FindFirstChild("FlyBodyVelocity")
                if not flyBv then
                    flyBv = Instance.new("BodyVelocity")
                    flyBv.Name = "FlyBodyVelocity"
                    flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    flyBv.P = 12000
                    flyBv.Parent = hrp
                end

                local flyBg = hrp:FindFirstChild("FlyBodyGyro")
                if not flyBg then
                    flyBg = Instance.new("BodyGyro")
                    flyBg.Name = "FlyBodyGyro"
                    flyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                    flyBg.P = 12000
                    flyBg.Parent = hrp
                end

                local camCFrame = Camera.CFrame
                flyBg.CFrame = camCFrame

                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end

                if moveDir.Magnitude > 0 then
                    flyBv.Velocity = moveDir.Unit * (Settings.FlySpeed or 50)
                else
                    flyBv.Velocity = Vector3.zero
                end
            elseif Settings.UndergroundNoclip and Shared.undergroundSurfaceY then
                if wasFly then
                    ResetFly()
                end
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
                
                local targetY = Shared.undergroundSurfaceY - Settings.UndergroundDistance
                hrp.Velocity = moveDir
                
                local camLx, camLz = camCFrame.LookVector.X, camCFrame.LookVector.Z
                if math.abs(camLx) < 0.001 and math.abs(camLz) < 0.001 then
                    camLx, camLz = hrp.CFrame.LookVector.X, hrp.CFrame.LookVector.Z
                end
                
                local lookAtPos = Vector3.new(hrp.Position.X + camLx, targetY, hrp.Position.Z + camLz)
                hrp.CFrame = CFrame.new(Vector3.new(hrp.Position.X, targetY, hrp.Position.Z), lookAtPos)
            else
                if wasFly then
                    ResetFly()
                else
                    humanoid.PlatformStand = false
                end
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
    Player.RestoreCollisions = RestoreCollisions
    Player.ResetSpeed = ResetSpeed
    Player.ResetJump = ResetJump
    Player.ResetFly = ResetFly
    Player.ResetNoclip = ResetNoclip
    Player.ResetGravity = ResetGravity
    Player.ResetSpinBot = ResetSpinBot
    Player.UpdatePhysics = UpdatePhysics
    Player.UpdatePlayer = UpdatePlayer

    return Player
end
