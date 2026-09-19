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
    local Const = Shared.Const
    local UserInputService = Shared.UserInputService
    local WallCheckRayParams = Shared.WallCheckRayParams
    local ESPTable = Shared.ESPTable
    local createESP = function(p) if Shared.createESP then Shared.createESP(p) end end

    local cachedProTarget = nil
    local cachedProValid = 0
    local aimSafeCounter = 0

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

-- Bộ đệm & Bộ quét Bot (Tối ưu hóa: Squared Distance, 0 GC Churn)
local NPCCache = Shared.NPCCache or {}
    Shared.NPCCache = NPCCache
local lastNPCRefresh = 0
local playerCharsCache = {}
local npcAddedSet = {}

local function RefreshNPCCache()
    local now = tick()
    if now - lastNPCRefresh < 0.3 then return end
    lastNPCRefresh = now
    
    table.clear(NPCCache)
    table.clear(playerCharsCache)
    table.clear(npcAddedSet)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerCharsCache[p.Character] = true end
    end
    
    -- Lấy vị trí người chơi và giới hạn khoảng cách quét tối đa theo thanh trượt Aim Dist & ESP Dist
    local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Camera.CFrame.Position
    local maxScanDist = math.max(Settings.AimDist or 1000, Settings.ESPDist or 1000, Settings.ProAimDist or 1000)
    local maxDistSq = maxScanDist * maxScanDist

    local function checkAndAddBot(model)
        if not model or not model:IsA("Model") then return end
        if model == LocalPlayer.Character or playerCharsCache[model] then return end
        if Players:GetPlayerFromCharacter(model) then return end
        if npcAddedSet[model] then return end
        if model:GetAttribute("Dead") == true then return end
        
        local hum = model:FindFirstChildOfClass("Humanoid")
        local hrp = model:FindFirstChild("HumanoidRootPart") 
            or model:FindFirstChild("PhysicalHitbox")
            or model:FindFirstChild("HitboxBody") 
            or model:FindFirstChild("BodyHitbox") 
            or model:FindFirstChild("UpperTorso") 
            or model:FindFirstChild("Torso") 
            or model:FindFirstChild("Head") 
            or model:FindFirstChild("HeadHitbox")
            or model:FindFirstChild("HitboxHead")
            or model:FindFirstChild("PhysicalHitboxHead")
            or model.PrimaryPart
        
        local isAlive = false
        if hum then
            isAlive = (hum.Health > 0 or hum.Health == math.huge or hum.MaxHealth <= 0)
        elseif model:GetAttribute("Health") then
            isAlive = ((tonumber(model:GetAttribute("Health")) or 0) > 0)
        elseif model:GetAttribute("IsNPC") == true or model:GetAttribute("NPCCharacter") == true then
            isAlive = (model:GetAttribute("Dead") ~= true)
        else
            local mName = string.lower(model.Name)
            if string.find(mName, "dummy", 1, true) or string.find(mName, "bot", 1, true) then
                isAlive = true
            end
        end
        
        if hrp and isAlive then
            -- Tối ưu hóa: Squared Distance không qua phép tính math.sqrt
            local diff = hrp.Position - myPos
            local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
            if distSq <= maxDistSq then
                npcAddedSet[model] = true
                table.insert(NPCCache, model)
                if not ESPTable[model] then
                    createESP(model)
                end
                return
            end
        end

        -- Hỗ trợ cấu trúc bọc 2 lớp (như trong PseudoPlayers hoặc ShootingRangeEntities)
        for _, sub in ipairs(model:GetChildren()) do
            if sub:IsA("Model") and not npcAddedSet[sub] and sub:GetAttribute("Dead") ~= true then
                local sHum = sub:FindFirstChildOfClass("Humanoid")
                local sHrp = sub:FindFirstChild("HumanoidRootPart") 
                    or sub:FindFirstChild("PhysicalHitbox")
                    or sub:FindFirstChild("HitboxBody") 
                    or sub:FindFirstChild("BodyHitbox") 
                    or sub:FindFirstChild("UpperTorso") 
                    or sub:FindFirstChild("Torso") 
                    or sub:FindFirstChild("Head") 
                    or sub:FindFirstChild("HeadHitbox")
                    or sub:FindFirstChild("HitboxHead")
                    or sub:FindFirstChild("PhysicalHitboxHead")
                    or sub.PrimaryPart
                local sAlive = false
                if sHum then
                    sAlive = (sHum.Health > 0 or sHum.Health == math.huge or sHum.MaxHealth <= 0)
                elseif sub:GetAttribute("Health") then
                    sAlive = ((tonumber(sub:GetAttribute("Health")) or 0) > 0)
                elseif sub:GetAttribute("IsNPC") == true or sub:GetAttribute("NPCCharacter") == true then
                    sAlive = (sub:GetAttribute("Dead") ~= true)
                else
                    local sName = string.lower(sub.Name)
                    if string.find(sName, "dummy", 1, true) or string.find(sName, "bot", 1, true) then
                        sAlive = true
                    end
                end
                if sHrp and sAlive then
                    local sDiff = sHrp.Position - myPos
                    local sDistSq = sDiff.X * sDiff.X + sDiff.Y * sDiff.Y + sDiff.Z * sDiff.Z
                    if sDistSq <= maxDistSq then
                        npcAddedSet[sub] = true
                        table.insert(NPCCache, sub)
                        if not ESPTable[sub] then
                            createESP(sub)
                        end
                    end
                end
            end
        end
    end

    -- 1. Quét thư mục Workspace.ShootingRangeEntities (DPS Dummy phòng tập)
    local shootingFolder = Workspace:FindFirstChild("ShootingRangeEntities") or Workspace:FindFirstChild("shootingrangeentities")
    if shootingFolder then
        for _, child in ipairs(shootingFolder:GetChildren()) do
            checkAndAddBot(child)
        end
    end

    -- 2. Quét thư mục Workspace.PseudoPlayers (Rivals PVP Bots)
    local pseudoFolder = Workspace:FindFirstChild("PseudoPlayers") or Workspace:FindFirstChild("pseudoplayers")
    if pseudoFolder then
        for _, child in ipairs(pseudoFolder:GetChildren()) do
            checkAndAddBot(child)
        end
    end

    -- 3. Quét thư mục Workspace.bots (hoặc Workspace.Bots)
    local botsFolder = Workspace:FindFirstChild("bots") or Workspace:FindFirstChild("Bots")
    if botsFolder then
        for _, child in ipairs(botsFolder:GetChildren()) do
            checkAndAddBot(child)
        end
    end

    -- 4. Quét CollectionService Tags đặc thù (Entity, NPCCharacter, Dummy...)
    for i = 1, #Const.BOT_TAGS do
        local tName = Const.BOT_TAGS[i]
        local ok, tagList = pcall(function() return CollectionService:GetTagged(tName) end)
        if ok and tagList then
            for _, item in ipairs(tagList) do
                if item:IsA("Model") then
                    checkAndAddBot(item)
                end
            end
        end
    end
end

-- Hàm quét toàn bộ kẻ địch (Người chơi thật + NPC/Bot)
local function forEachEnemy(callback)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isSameTeam(player) then
            local char = player.Character
            if char then
                callback(char, player)
            end
        end
    end

    if Settings.TargetNPC then
        if tick() - lastNPCRefresh >= 0.3 then
            RefreshNPCCache()
        end
        for i = 1, #NPCCache do
            local npc = NPCCache[i]
            if npc and npc.Parent and not isSameTeam(npc) then
                callback(npc, npc)
            end
        end
    end
end

local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    if not targetPart or not targetPart.Parent then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
    Const.STATIC_RAY_FILTER[2] = targetPart.Parent
    WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
    local result = Workspace:Raycast(origin, direction, WallCheckRayParams)
    return not result
end

local function isAutoFireVisible(targetPart)
    if not Settings.AutoFireWallCheck then return true end
    if not targetPart or not targetPart.Parent then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
    Const.STATIC_RAY_FILTER[2] = targetPart.Parent
    WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
    local result = Workspace:Raycast(origin, direction, WallCheckRayParams)
    return not result
end

local function getClosestPlayer()
    local target, shortestDist = nil, Settings.FOV
    local origin = Camera.CFrame.Position
    local fovPos = (Shared.FOVring and Shared.FOVring.Position) or UserInputService:GetMouseLocation()

    forEachEnemy(function(char, source)
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HitboxHead") or char:FindFirstChild("PhysicalHitboxHead") or char:FindFirstChild("HeadHitbox")
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("PhysicalHitbox") or char:FindFirstChild("HitboxBody") or char:FindFirstChild("BodyHitbox") or char:FindFirstChild("Torso") or char.PrimaryPart
        head = head or hrp

        local isAlive = false
        if hum then
            isAlive = (hum.Health > 0 or hum.Health == math.huge or hum.MaxHealth <= 0)
        elseif char:GetAttribute("Health") then
            isAlive = ((tonumber(char:GetAttribute("Health")) or 0) > 0)
        else
            local cName = string.lower(char.Name)
            if char:GetAttribute("Dead") == false or string.find(cName, "dummy", 1, true) or string.find(cName, "bot", 1, true) then
                isAlive = true
            end
        end

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
                    if distSq < (shortestDist * shortestDist) then
                        if isVisible(head) or isVisible(hrp) then
                            target = source
                            shortestDist = math.sqrt(distSq)
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
        aimSafeCounter = aimSafeCounter + 1
        if aimSafeCounter >= 4 then
            partName = "HumanoidRootPart"
            aimSafeCounter = 0
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
        local isAlive = false
        if hum then
            isAlive = hum.Health > 0
        else
            local healthVal = char:FindFirstChild("Health") or char:FindFirstChild("health")
            if healthVal and (healthVal:IsA("NumberValue") or healthVal:IsA("IntValue")) then
                isAlive = healthVal.Value > 0
            elseif char:GetAttribute("Health") then
                isAlive = ((tonumber(char:GetAttribute("Health")) or 0) > 0)
            elseif Settings.TargetNPC then
                isAlive = true
            end
        end

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
                        if distSq < closestDistSq then
                            if isVisible(part) then
                                closestDistSq = distSq
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
    Targeting.hasShieldProtection = hasShieldProtection
    Targeting.isSafeShield = isSafeShield
    Targeting.isAutoFireVisible = isAutoFireVisible
    Targeting.WallCheck = WallCheck
    Targeting.getTargetPart = getTargetPart
    Targeting.getClosestPlayer = getClosestPlayer
    Targeting.getClosestPlayerToCursor = getClosestPlayerToCursor
    Targeting.getProAimTarget = getProAimTarget
    Targeting.getProAimTargetCached = getProAimTargetCached
    Targeting.forEachEnemy = forEachEnemy
    Targeting.botCache = botCache

    return Targeting
end
