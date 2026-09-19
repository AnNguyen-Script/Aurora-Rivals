-- ============================================================
-- MODULAR RIVALS | MODULE: TARGETING & NPC SCANNER
-- ============================================================
return function(Shared, Shield)
    local Targeting = {}

    local Settings = Shared.Settings
    local Const = Shared.Const
    local LocalPlayer = Shared.LocalPlayer
    local Camera = Shared.Camera
    local Players = Shared.Players
    local Workspace = Shared.Workspace
    local VirtualInputManager = Shared.VirtualInputManager
    local mouse1click_fn = Shared.mouse1click_fn

    -- Raycast Params kiểm tra tường
    local WallCheckRayParams = RaycastParams.new()
    WallCheckRayParams.FilterType = Enum.RaycastFilterType.Exclude
    WallCheckRayParams.IgnoreWater = true
    Targeting.WallCheckRayParams = WallCheckRayParams

    -- Cache NPC / Bot để không duyệt Workspace mỗi frame
    local NPCCache = {}
    local lastNPCRefresh = 0
    local playerCharsCache = {}
    local npcAddedSet = {}
    Targeting.NPCCache = NPCCache

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
    Targeting.FireShot = FireShot

    local function isSameTeam(target)
        if not target then return true end
        if target == LocalPlayer or target == LocalPlayer.Character then return true end

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

            local myTeamColor = LocalPlayer.TeamColor
            local pTeamColor = target.TeamColor
            if myTeamColor and pTeamColor and myTeamColor == pTeamColor and myTeamColor.Name ~= "White" then
                return true
            end

            local myChar = LocalPlayer.Character
            local tChar = target.Character
            if myChar and tChar then
                for i = 1, #Const.TEAM_ATTR_NAMES do
                    local aName = Const.TEAM_ATTR_NAMES[i]
                    local mVal = myChar:GetAttribute(aName)
                    local tVal = tChar:GetAttribute(aName)
                    if mVal ~= nil and tVal ~= nil and mVal == tVal then
                        return true
                    end
                end
            end
            return false
        end

        -- Dành cho NPC / Dummy
        if target:IsA("Model") then
            local myTeamID = LocalPlayer:GetAttribute("TeamID")
            local npcTeamID = target:GetAttribute("TeamID")
            if myTeamID ~= nil and npcTeamID ~= nil and myTeamID ~= "" and myTeamID == npcTeamID then
                return true
            end

            local myChar = LocalPlayer.Character
            if myChar then
                for i = 1, #Const.TEAM_ATTR_NAMES do
                    local aName = Const.TEAM_ATTR_NAMES[i]
                    local mVal = myChar:GetAttribute(aName)
                    local tVal = target:GetAttribute(aName)
                    if mVal ~= nil and tVal ~= nil and mVal == tVal then
                        return true
                    end
                end
            end
            return false
        end

        return false
    end
    Targeting.isSameTeam = isSameTeam

    local function isSafeShield(target, char)
        if not Settings.SafeShieldCheck then return false end
        if not char then
            char = target:IsA("Player") and target.Character or target
        end
        if not char then return false end

        for i = 1, #Const.SHIELD_ATTRIBUTES do
            local attrName = Const.SHIELD_ATTRIBUTES[i]
            if target:GetAttribute(attrName) == true or char:GetAttribute(attrName) == true then
                return true
            end
        end

        if char:FindFirstChildOfClass("ForceField") ~= nil then
            return true
        end

        local isFF = char:FindFirstChild("ForceField") or char:FindFirstChild("Shield") or char:FindFirstChild("SpawnShield")
        if isFF and (isFF:IsA("ForceField") or isFF:IsA("BillboardGui") or isFF:IsA("Highlight") or isFF:IsA("SelectionBox")) then
            return true
        end

        for i = 1, #Const.SAFE_PARTS do
            local pName = Const.SAFE_PARTS[i]
            local part = char:FindFirstChild(pName)
            if part then
                if part.Transparency > 0.65 or not part.CanCollide then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and part.Transparency > 0.75 then
                        return true
                    end
                end
            end
        end

        return false
    end
    Targeting.isSafeShield = isSafeShield

    local function RefreshNPCCache()
        local now = tick()
        if now - lastNPCRefresh < 0.5 then return end
        lastNPCRefresh = now

        table.clear(NPCCache)
        table.clear(playerCharsCache)
        table.clear(npcAddedSet)

        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then playerCharsCache[p.Character] = true end
        end

        local myChar = LocalPlayer.Character
        local myPos = (myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position)
                      or Camera.CFrame.Position

        local maxScanDist = math.max(Settings.ESPDist or 1000, Settings.AimDist or 1000)
        local maxScanDistSq = maxScanDist * maxScanDist

        local function checkModel(model)
            if not model or not model:IsA("Model") or model == myChar or playerCharsCache[model] or npcAddedSet[model] then return end

            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
            if not hrp or not hrp:IsA("BasePart") then return end

            local distSq = (hrp.Position - myPos).Magnitude ^ 2
            if distSq > maxScanDistSq then return end

            local isBot = false
            for i = 1, #Const.BOT_TAGS do
                local tag = Const.BOT_TAGS[i]
                if model:HasTag(tag) or model:GetAttribute(tag) ~= nil then
                    isBot = true
                    break
                end
            end

            if not isBot then
                local envId = model:GetAttribute("EnvironmentID")
                if envId ~= nil then isBot = true end
            end

            if not isBot then
                local parentName = model.Parent and model.Parent.Name or ""
                if string.find(parentName, "Entity") or string.find(parentName, "Bot") or string.find(parentName, "NPC") or string.find(parentName, "Dummy") or string.find(parentName, "ShootingRange") then
                    isBot = true
                end
            end

            if not isBot then
                local mName = string.lower(model.Name)
                if string.find(mName, "dummy") or string.find(mName, "bot") or string.find(mName, "npc") or string.find(mName, "target") or string.find(mName, "dps") then
                    isBot = true
                end
            end

            if not isBot then
                if model:FindFirstChild("EnemyHumanoid") or model:FindFirstChild("HitboxBody") or model:FindFirstChild("HitboxHead") then
                    isBot = true
                end
            end

            if not isBot then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and model:FindFirstChild("Head") then isBot = true end
            end

            if isBot then
                table.insert(NPCCache, model)
                npcAddedSet[model] = true
            end
        end

        local entitiesFolder = Workspace:FindFirstChild("Entities") or Workspace:FindFirstChild("NPCs") or Workspace:FindFirstChild("Bots") or Workspace:FindFirstChild("ShootingRangeEntities")
        if entitiesFolder then
            for _, child in pairs(entitiesFolder:GetChildren()) do checkModel(child) end
        end

        local mapFolder = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Game")
        if mapFolder then
            for _, sub in pairs(mapFolder:GetChildren()) do
                if sub:IsA("Model") then checkModel(sub) end
            end
        end

        for _, child in pairs(Workspace:GetChildren()) do
            if child:IsA("Model") then checkModel(child) end
        end
    end
    Targeting.RefreshNPCCache = RefreshNPCCache

    local function forEachEnemy(callback)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                callback(p, p.Character, false)
            end
        end
        if Settings.TargetNPC then
            RefreshNPCCache()
            for i = 1, #NPCCache do
                local npc = NPCCache[i]
                if npc and npc.Parent then
                    callback(npc, npc, true)
                end
            end
        end
    end
    Targeting.forEachEnemy = forEachEnemy

    local function isVisible(targetPart)
        if not Settings.WallCheck then return true end
        if not targetPart then return false end
        local origin = Camera.CFrame.Position
        local dir = targetPart.Position - origin
        Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
        Const.STATIC_RAY_FILTER[2] = targetPart.Parent
        WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
        local res = Workspace:Raycast(origin, dir, WallCheckRayParams)
        return res == nil
    end
    Targeting.isVisible = isVisible

    local function isAutoFireVisible(targetPart)
        if not Settings.AutoFireWallCheck then return true end
        if not targetPart then return false end
        local origin = Camera.CFrame.Position
        local dir = targetPart.Position - origin
        Const.STATIC_RAY_FILTER[1] = LocalPlayer.Character
        Const.STATIC_RAY_FILTER[2] = targetPart.Parent
        WallCheckRayParams.FilterDescendantsInstances = Const.STATIC_RAY_FILTER
        local res = Workspace:Raycast(origin, dir, WallCheckRayParams)
        return res == nil
    end
    Targeting.isAutoFireVisible = isAutoFireVisible

    local function getTargetPart(character)
        if not character then return nil end
        local partName = Settings.TargetPart or "Head"
        if partName == "Random" then
            local p = {"Head", "HumanoidRootPart", "UpperTorso"}
            partName = p[math.random(1, #p)]
        end
        local part = character:FindFirstChild(partName)
        if not part and partName == "UpperTorso" then
            part = character:FindFirstChild("Torso")
        end
        if not part then
            part = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        end
        return part
    end
    Targeting.getTargetPart = getTargetPart

    local function getClosestPlayer()
        local myChar = LocalPlayer.Character
        if not myChar then return nil end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end

        local closest = nil
        local minDist = Settings.AimDist or 1000

        forEachEnemy(function(target, char, isNPC)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local isAlive = (hum and hum.Health > 0) or (not hum and hrp)

            if isAlive and hrp then
                if isSameTeam(target) then return end
                if isSafeShield(target, char) then return end

                local dist = (hrp.Position - myHrp.Position).Magnitude
                if dist < minDist then
                    local tPart = getTargetPart(char)
                    if tPart and isVisible(tPart) then
                        minDist = dist
                        closest = target
                    end
                end
            end
        end)

        return closest
    end
    Targeting.getClosestPlayer = getClosestPlayer

    local function getClosestPlayerToCursor(mousePos)
        local myChar = LocalPlayer.Character
        local closestTarget = nil
        local closestPart = nil
        local closestScreenPos = nil
        local minDistance = Settings.ProAimFOV or 120
        local camPos = Camera.CFrame.Position
        local maxDist = Settings.ProAimDist or 1000

        forEachEnemy(function(target, char, isNPC)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local isAlive = (hum and hum.Health > 0) or (not hum and hrp)

            if isAlive and hrp then
                if isSameTeam(target) then return end
                if isSafeShield(target, char) then return end

                local distWorld = (hrp.Position - camPos).Magnitude
                if distWorld <= maxDist then
                    local tPartName = Settings.ProAimTargetPart or "Head"
                    local tPart = char:FindFirstChild(tPartName) or char:FindFirstChild("Head") or hrp
                    if tPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(tPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local screenV2 = Vector2.new(screenPos.X, screenPos.Y)
                            local distCursor = (screenV2 - mousePos).Magnitude
                            if distCursor < minDistance then
                                if not Settings.ProAimWallCheck or isVisible(tPart) then
                                    minDistance = distCursor
                                    closestTarget = target
                                    closestPart = tPart
                                    closestScreenPos = screenV2
                                end
                            end
                        end
                    end
                end
            end
        end)

        return closestTarget, closestPart, closestScreenPos
    end
    Targeting.getClosestPlayerToCursor = getClosestPlayerToCursor

    local function AddJitter(baseCFrame, jitterAmount)
        if jitterAmount <= 0 then return baseCFrame end
        local r = math.random
        local jx = (r() - 0.5) * jitterAmount * 2
        local jy = (r() - 0.5) * jitterAmount * 2
        local jz = (r() - 0.5) * jitterAmount * 2
        return baseCFrame * CFrame.Angles(jx, jy, jz)
    end
    Targeting.AddJitter = AddJitter

    return Targeting
end
