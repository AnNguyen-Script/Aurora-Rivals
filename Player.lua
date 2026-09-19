-- ============================================================
-- MODULAR RIVALS | MODULE: PLAYER EXPLOITS & PHYSICS
-- ============================================================
return function(Shared, Targeting)
    local Player = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Camera = Shared.Camera
    local Const = Shared.Const
    local UserInputService = Shared.UserInputService

    local originalHitboxes = {}
    local cachedHitboxVal = nil
    local cachedHitboxSizeVec = nil

    local undergroundSurfaceY = nil
    local originalTeleportCFrame = nil
    local originalSpeedTeleCFrame = nil
    local noClipParts = {}

    local function ResetHitboxes()
        for part, orig in pairs(originalHitboxes) do
            pcall(function()
                if part and part.Parent then
                    part.Size = orig.Size
                    part.Transparency = orig.Transparency
                    part.CanCollide = orig.CanCollide
                end
            end)
        end
        table.clear(originalHitboxes)
    end
    Player.ResetHitboxes = ResetHitboxes

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
    Player.RefreshNoClipParts = RefreshNoClipParts

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

    UserInputService.JumpRequest:Connect(function()
        if Settings.InfJump
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    -- Physics / Stepped Update (chạy trong RunService.Stepped)
    local function UpdatePhysics(step)
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

        -- 1. Hitbox Expander
        if Settings.HitboxExpander then
            local hVal = Settings.HitboxSize or 10
            if cachedHitboxVal ~= hVal then
                cachedHitboxVal = hVal
                cachedHitboxSizeVec = Vector3.new(hVal, hVal, hVal)
            end
            local targetPartName = Settings.HitboxPart or "Head"

            Targeting.forEachEnemy(function(target, char, isNPC)
                local isSafe = Targeting.isSameTeam(target) or Targeting.isSafeShield(target, char)
                if not isSafe then
                    local part = char:FindFirstChild(targetPartName)
                    if part and part:IsA("BasePart") then
                        if not originalHitboxes[part] then
                            originalHitboxes[part] = {
                                Size = part.Size,
                                Transparency = part.Transparency,
                                CanCollide = part.CanCollide
                            }
                        end
                        part.Size = cachedHitboxSizeVec
                        part.Transparency = Settings.HitboxInvisible and 1 or 0.5
                        part.CanCollide = false
                    end
                end
            end)
        else
            if next(originalHitboxes) ~= nil then
                ResetHitboxes()
            end
        end

        -- 2. Fly & Speed Hack
        if myHrp and myHum then
            if Settings.Fly then
                local cam = Camera.CFrame
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    myHrp.AssemblyLinearVelocity = moveDir.Unit * (Settings.FlySpeed or 50)
                else
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                end
            elseif Settings.SpeedHack then
                local moveDir = Vector3.zero
                local camCFrame = Camera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
                if moveDir.Magnitude > 0 then
                    myHrp.AssemblyLinearVelocity = moveDir.Unit * (Settings.WalkSpeed or 30) + Vector3.new(0, myHrp.AssemblyLinearVelocity.Y, 0)
                end
            end
        end

        -- 3. NoClip
        if Settings.Noclip or Settings.UndergroundNoclip then
            for i = 1, #noClipParts do
                local p = noClipParts[i]
                if p and p.Parent then p.CanCollide = false end
            end
        end

        -- 4. Underground Noclip
        if Settings.UndergroundNoclip and myHrp then
            if not undergroundSurfaceY then
                undergroundSurfaceY = myHrp.Position.Y
            end
            local moveDir = Vector3.zero
            local camCFrame = Camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
            moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)

            local targetY = undergroundSurfaceY - Settings.UndergroundDistance
            if moveDir.Magnitude > 0 then
                myHrp.AssemblyLinearVelocity = moveDir.Unit * (Settings.WalkSpeed or 30) + Vector3.new(0, (targetY - myHrp.Position.Y) * 10, 0)
            else
                myHrp.AssemblyLinearVelocity = Vector3.new(0, (targetY - myHrp.Position.Y) * 10, 0)
            end
            local camLx, camLz = camCFrame.LookVector.X, camCFrame.LookVector.Z
            if camLx ~= 0 or camLz ~= 0 then
                local lookAtPos = Vector3.new(myHrp.Position.X + camLx, targetY, myHrp.Position.Z + camLz)
                myHrp.CFrame = CFrame.new(Vector3.new(myHrp.Position.X, targetY, myHrp.Position.Z), lookAtPos)
            end
        else
            undergroundSurfaceY = nil
        end

        -- 5. Teleport Loop
        if Settings.AutoTeleport and myHrp then
            if not originalTeleportCFrame then
                originalTeleportCFrame = myHrp.CFrame
            end
            local closest = Targeting.getClosestPlayer()
            local targetChar = closest and (closest:IsA("Player") and closest.Character or closest)
            local targetHrp = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso"))

            if targetHrp then
                local range = Settings.TeleportRange or 1000
                if (targetHrp.Position - originalTeleportCFrame.Position).Magnitude <= range then
                    local posType = Settings.AutoTeleportPosition or "Sau Lưng"
                    local targetCFrame = targetHrp.CFrame
                    local desiredPos = targetCFrame.Position
                    if posType == "Sau Lưng" then
                        desiredPos = targetCFrame.Position - (targetCFrame.LookVector * (Settings.AutoTeleportDistance or 3))
                    elseif posType == "Trên Đầu" then
                        desiredPos = targetCFrame.Position + Vector3.new(0, Settings.AutoTeleportDistance or 3, 0)
                    elseif posType == "Trái" then
                        desiredPos = targetCFrame.Position - (targetCFrame.RightVector * (Settings.AutoTeleportDistance or 3))
                    elseif posType == "Phải" then
                        desiredPos = targetCFrame.Position + (targetCFrame.RightVector * (Settings.AutoTeleportDistance or 3))
                    end
                    myHrp.CFrame = CFrame.new(desiredPos, targetHrp.Position)
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                    if Settings.AutoTeleportCameraLock then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHrp.Position)
                    end
                elseif Settings.AutoTeleportReturn and originalTeleportCFrame then
                    myHrp.CFrame = originalTeleportCFrame
                    myHrp.AssemblyLinearVelocity = Vector3.zero
                end
            elseif Settings.AutoTeleportReturn and originalTeleportCFrame then
                myHrp.CFrame = originalTeleportCFrame
                myHrp.AssemblyLinearVelocity = Vector3.zero
            end
        else
            originalTeleportCFrame = nil
        end
    end
    Player.UpdatePhysics = UpdatePhysics

    return Player
end
