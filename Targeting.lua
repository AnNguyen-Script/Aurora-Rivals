-- ============================================================
-- MODULAR RIVALS | MODULE 3: TARGETING, BOT SCANNER & RAYCAST
-- ============================================================
return function(Shared, Shield)
    local Targeting = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local Workspace = Shared.Workspace
    local CollectionService = Shared.CollectionService or game:GetService("CollectionService")
    local Const = Shared.Const
    local UserInputService = Shared.UserInputService
    local WallCheckRayParams = Shared.WallCheckRayParams
    local ESPTable = Shared.ESPTable or {}
    Shared.ESPTable = ESPTable
    local createESP = function(p) if Shared.createESP then Shared.createESP(p) end end

    local cachedProTarget = nil
    local cachedProValid = 0
    local aimSafeCounter = 0
    local lastAimSafeTarget = nil
    local lastAimSafePart = nil
    local lastAimSafeTime = 0
    local aimSafeBurstShots = 0

    local function isSameTeam(target)
    if not target then return true end
    if target == LocalPlayer or target == LocalPlayer.Character then return true end

    -- Nếu tắt Team Check thủ công -> Coi tất cả mọi người là mục tiêu hợp lệ
    if Settings.TeamCheck == false then
        return false
    end

    if target:IsA("Player") then
        if LocalPlayer.Team and target.Team and LocalPlayer.Team == target.Team then 
            return true 
        end
        local myTeamID = LocalPlayer:GetAttribute("TeamID")
        local pTeamID = target:GetAttribute("TeamID")
        if myTeamID ~= nil and pTeamID ~= nil and myTeamID ~= "" and myTeamID == pTeamID then
            return true
        end
        for i = 1, #Const.TEAM_ATTR_NAMES do
            local name = Const.TEAM_ATTR_NAMES[i]
            local myAttr = LocalPlayer:GetAttribute(name)
            local pAttr = target:GetAttribute(name)
            if myAttr ~= nil and pAttr ~= nil and myAttr ~= "" and myAttr ~= 0 and myAttr == pAttr then 
                return true 
            end
            if LocalPlayer.Character and target.Character then
                local myCAttr = LocalPlayer.Character:GetAttribute(name)
                local pCAttr = target.Character:GetAttribute(name)
                if myCAttr ~= nil and pCAttr ~= nil and myCAttr ~= "" and myCAttr ~= 0 and myCAttr == pCAttr then 
                    return true 
                end
            end
        end
        return false
    elseif target:IsA("Model") then
        local myTeamName = LocalPlayer.Team and LocalPlayer.Team.Name
        local nTeamName = target:GetAttribute("Team") or target:GetAttribute("team")
        if myTeamName and nTeamName and myTeamName ~= "" and myTeamName == nTeamName then
            return true
        end
        local myTeamID = LocalPlayer:GetAttribute("TeamID")
        local nTeamID = target:GetAttribute("TeamID")
        if myTeamID ~= nil and nTeamID ~= nil and myTeamID ~= "" and myTeamID == nTeamID then
            return true
        end
        for i = 1, #Const.TEAM_ATTR_NAMES do
            local name = Const.TEAM_ATTR_NAMES[i]
            local myAttr = LocalPlayer:GetAttribute(name)
            local nAttr = target:GetAttribute(name)
            if myAttr ~= nil and nAttr ~= nil and myAttr ~= "" and myAttr ~= 0 and myAttr == nAttr then
                return true
            end
            if LocalPlayer.Character then
                local myCAttr = LocalPlayer.Character:GetAttribute(name)
                if myCAttr ~= nil and nAttr ~= nil and myCAttr ~= "" and myCAttr ~= 0 and myCAttr == nAttr then
                    return true
                end
            end
        end
        if target:GetAttribute("Friendly") == true or target:GetAttribute("Neutral") == true then
            return true
        end
        return false
    end
    return false
end

local function isSafeShield(target, char)
    if not Settings.SafeShieldCheck then return false end
    if not target then return false end
    char = char or (target:IsA("Player") and target.Character or target)
    if not char then return false end

    if char:FindFirstChildOfClass("ForceField") or char:FindFirstChild("ForceField") then
        return true
    end

    if char:FindFirstChild("SpawnShield")
        or char:FindFirstChild("Shield")
        or char:FindFirstChild("SpawnProtection")
        or char:FindFirstChild("Invulnerability")
        or char:FindFirstChild("Immunity")
        or char:FindFirstChild("SafeZone")
        or char:FindFirstChild("SpawnBarrier")
        or char:FindFirstChild("SpawnBubble")
        or char:FindFirstChild("Safe") then
        return true
    end

    for i = 1, #Const.SHIELD_ATTRIBUTES do
        local key = Const.SHIELD_ATTRIBUTES[i]
        local cVal = char:GetAttribute(key)
        if cVal == true or (type(cVal) == "number" and cVal > 0) then
            return true
        end
        if target:IsA("Player") then
            local pVal = target:GetAttribute(key)
            if pVal == true or (type(pVal) == "number" and pVal > 0) then
                return true
            end
        end
    end

    return false
end

-- Hàm quét toàn bộ kẻ địch (Chỉ quét Người chơi thật)
local function forEachEnemy(callback)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isSameTeam(player) then
            local char = player.Character
            if char then
                callback(char, player)
            end
        end
    end
end

local lastRaycastTick = 0
local raycastCache = {}

local function isVisible(targetPart)
    local isWallCheckActive = Settings.WallCheck or Settings.AutoFireWallCheck or Settings.ProAimWallCheck
    if not isWallCheckActive then return true end
    if not targetPart or not targetPart.Parent then return false end
    local now = tick()
    if (now - lastRaycastTick) > 0.025 then
        table.clear(raycastCache)
        lastRaycastTick = now
    else
        local cached = raycastCache[targetPart]
        if cached ~= nil then return cached end
    end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
    Const.STATIC_RAY_FILTER[2] = targetPart.Parent
    WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
    local result = Workspace:Raycast(origin, direction, WallCheckRayParams)
    local vis = (not result)
    raycastCache[targetPart] = vis
    return vis
end

local function isAutoFireVisible(targetPart)
    local isWallCheckActive = Settings.WallCheck or Settings.AutoFireWallCheck or Settings.ProAimWallCheck
    if not isWallCheckActive then return true end
    if not targetPart or not targetPart.Parent then return false end
    local now = tick()
    if (now - lastRaycastTick) > 0.025 then
        table.clear(raycastCache)
        lastRaycastTick = now
    else
        local cached = raycastCache[targetPart]
        if cached ~= nil then return cached end
    end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
    Const.STATIC_RAY_FILTER[2] = targetPart.Parent
    WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
    local result = Workspace:Raycast(origin, direction, WallCheckRayParams)
    local vis = (not result)
    raycastCache[targetPart] = vis
    return vis
end

local function getClosestPlayer()
    local target = nil
    local shortestDistSq = Settings.FOV * Settings.FOV
    local origin = Camera.CFrame.Position
    local fovPos = (Shared.FOVring and Shared.FOVring.Position) or UserInputService:GetMouseLocation()

    forEachEnemy(function(char, source)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HitboxHead") or char:FindFirstChild("PhysicalHitboxHead") or char:FindFirstChild("HeadHitbox")
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("PhysicalHitbox") or char:FindFirstChild("HitboxBody") or char:FindFirstChild("BodyHitbox") or char:FindFirstChild("Torso") or char.PrimaryPart
        head = head or hrp

        local isAlive = hum and (hum.Health > 0)

        if isAlive and head and hrp then
            local diff = head.Position - origin
            local physicalDistSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
            local maxDist = Settings.AimDist or 1000

            if physicalDistSq <= (maxDist * maxDist) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dx = pos.X - fovPos.X
                    local dy = pos.Y - fovPos.Y
                    local distSq = dx * dx + dy * dy
                    if distSq < shortestDistSq then
                        if isVisible(head) or isVisible(hrp) then
                            target = source
                            shortestDistSq = distSq
                        end
                    end
                end
            end
        end
    end)
    return target
end

local function getTargetPart(character)
    if not character then return nil end
    local partName = Settings.TargetPart
    if partName == "Safe" then
        partName = Const.SAFE_PARTS[math.random(1, #Const.SAFE_PARTS)]
    end
    if Settings.AimSafe then
        local now = tick()
        -- Cửa sổ ổn định nhịp bắn (Burst Window 0.35s):
        -- Nếu đang khóa cùng 1 mục tiêu trong vòng 0.35s thì giữ ổn định, không đổi loạn xạ giữa các frame
        if character == lastAimSafeTarget and (now - lastAimSafeTime < 0.35) and lastAimSafePart then
            partName = lastAimSafePart
            lastAimSafeTime = now
        else
            -- Bắt đầu nhịp bắn mới hoặc mục tiêu mới:
            if character ~= lastAimSafeTarget or (now - lastAimSafeTime >= 0.5) then
                aimSafeBurstShots = 1
            else
                aimSafeBurstShots = aimSafeBurstShots + 1
            end

            local headshotRate = math.clamp(Settings.AimSafeHeadshotRate or 65, 20, 100)

            -- Thuật toán Spray Burst Pattern:
            -- Viên 1 & 2 (Mở đầu loạt bắn): Tăng thêm 15% tỷ lệ Headshot để bắt nhịp flick chuẩn
            -- Viên 3+ (Xả đạn kéo dài): Ghìm tâm xuống ngực/thân mô phỏng ghìm độ giật súng
            local effectiveRate = headshotRate
            if aimSafeBurstShots <= 2 then
                effectiveRate = math.min(100, headshotRate + 15)
            else
                effectiveRate = math.max(20, headshotRate - 15)
            end

            local roll = math.random(1, 100)
            if roll <= effectiveRate then
                partName = "Head"
            else
                partName = "UpperTorso"
            end

            lastAimSafeTarget = character
            lastAimSafePart = partName
            lastAimSafeTime = now
        end
    end
    return character:FindFirstChild(partName) 
        or character:FindFirstChild("Head") 
        or character:FindFirstChild("HitboxHead")
        or character:FindFirstChild("PhysicalHitboxHead")
        or character:FindFirstChild("HeadHitbox")
        or character:FindFirstChild("HitboxHeadSmall")
        or character:FindFirstChild("HumanoidRootPart") 
        or character:FindFirstChild("PhysicalHitbox")
        or character:FindFirstChild("HitboxBody") 
        or character:FindFirstChild("BodyHitbox")
        or character:FindFirstChild("HitboxBodySmall")
        or character:FindFirstChild("UpperTorso") 
        or character:FindFirstChild("Torso") 
        or character.PrimaryPart
end

local function getClosestPlayerToCursor(mousePos)
    local maxDist = Settings.FOV or Settings.ProAimFOV or 120
    local maxDistSq = maxDist * maxDist
    local closestDistSq = maxDistSq
    local closestTarget = nil
    local closestPart = nil
    local closestScreenPos = nil

    local origin = Camera.CFrame.Position

    forEachEnemy(function(char, source)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local isAlive = hum and (hum.Health > 0)

        if isAlive and not isSafeShield(source, char) then
            local targetPartName = Settings.TargetPart or Settings.ProAimTargetPart or "Head"
            if targetPartName == "Safe" or targetPartName == "Random" then
                targetPartName = (math.random(1, 10) <= 6) and "Head" or "HumanoidRootPart"
            end
            local part = char:FindFirstChild(targetPartName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char.PrimaryPart
            
            if part then
                local diff = part.Position - origin
                local physicalDistSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                local maxPhysicalDist = Settings.AimDist or Settings.ProAimDist or 1000
                if physicalDistSq <= (maxPhysicalDist * maxPhysicalDist) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dx = screenPos.X - mousePos.X
                        local dy = screenPos.Y - mousePos.Y
                        local distSq = dx * dx + dy * dy
                        -- [STICKY HYSTERESIS]: Ưu tiên 30% cho mục tiêu đã khóa để chống đảo mục tiêu
                        local effectiveDistSq = (lastLockedProAimTarget and (source == lastLockedProAimTarget or char == lastLockedProAimTarget)) and (distSq * 0.70) or distSq
                        if effectiveDistSq < closestDistSq then
                            if isVisible(part) then
                                closestDistSq = effectiveDistSq
                                closestTarget = source
                                closestPart = part
                                closestScreenPos = screenPos
                            end
                        end
                    end
                end
            end
        end
    end)

    return closestTarget, closestPart, closestScreenPos
end

local function getProAimTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local _, bestPart = getClosestPlayerToCursor(mousePos)
    return bestPart
end

-- Cache mục tiêu Pro Aim
local function getProAimTargetCached()
    local now = tick()
    if now - cachedProValid > 0.05 then
        cachedProTarget = getProAimTarget()
        cachedProValid = now
    end
    return cachedProTarget
end



    Targeting.isSameTeam = isSameTeam
    Targeting.hasShieldProtection = isSafeShield
    Targeting.isSafeShield = isSafeShield
    Targeting.isAutoFireVisible = isAutoFireVisible
    Targeting.WallCheck = isVisible
    Targeting.isVisible = isVisible
    Targeting.getTargetPart = getTargetPart
    Targeting.getClosestPlayer = getClosestPlayer
    Targeting.getClosestPlayerToCursor = getClosestPlayerToCursor
    Targeting.getProAimTarget = getProAimTarget
    Targeting.getProAimTargetCached = getProAimTargetCached
    Targeting.forEachEnemy = forEachEnemy
    Targeting.botCache = {}
    Targeting.NPCCache = {}

    return Targeting
end
