-- ============================================================
-- MODULAR RIVALS | MODULE 6: ESP, CHAMS, SKELETON & COUNTER HUD
-- ============================================================
return function(Shared, Targeting)
    local ESP = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local Workspace = Shared.Workspace
    local ColorList = Shared.ColorList
    local Const = Shared.Const
    local RandomString = Shared.RandomString
    local IDS = Shared.IDS
    local parentGui = Shared.parentGui
    local isSameTeam = Targeting.isSameTeam

    local ESPTable = Shared.ESPTable or {}
    Shared.ESPTable = ESPTable
    ESP.ESPTable = ESPTable

    local bonePosCache = {}
    local boneVisCache = {}
    local espActive = false
    local VEC3_UP_HEAD = Vector3.new(0, 0.5, 0)
    local VEC3_DOWN_LEG = Vector3.new(0, 3, 0)

local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = IDS.ChamsFolder
pcall(function() ChamsFolder.Parent = parentGui end)
if not ChamsFolder.Parent then pcall(function() ChamsFolder.Parent = Camera end) end

local function getEquippedWeapon(target, char, isNPC)
    if not char then return "Unarmed" end

    -- 1. [FIGHTER INTERFACES]: Kiểm tra PlayerGui (Rivals HUD - Cực kỳ chuẩn xác cho LocalPlayer & các fighter có frame)
    local pgui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pgui then
        local mainGui = pgui:FindFirstChild("MainGui")
        local mainFrame = mainGui and mainGui:FindFirstChild("MainFrame")
        local fi = mainFrame and mainFrame:FindFirstChild("FighterInterfaces")
        if fi then
            local targetName = target and target.Name or (char and char.Name)
            local fighter = targetName and fi:FindFirstChild(targetName)
            if fighter then
                local bottomRight = fighter:FindFirstChild("BottomRight")
                local brContainer = bottomRight and bottomRight:FindFirstChild("Container")
                
                -- A. Tìm trong EquippedDisplay: frame Details nào đang hiển thị (Visible == true)
                local eqDisplay = brContainer and brContainer:FindFirstChild("EquippedDisplay")
                local eqContainer = eqDisplay and eqDisplay:FindFirstChild("Container")
                if eqContainer then
                    for _, child in ipairs(eqContainer:GetChildren()) do
                        if child:IsA("GuiObject") and child.Visible then
                            local nameContainer = child:FindFirstChild("NameContainer", true)
                            local title = nameContainer and nameContainer:FindFirstChild("Title")
                            if title and title:IsA("TextLabel") and title.Visible and title.Text ~= "" and not tonumber(title.Text) then
                                local txt = title.Text:gsub("^%s+", ""):gsub("%s+$", "")
                                if txt ~= "" and not txt:find("^<font") then
                                    return txt
                                end
                            end
                        end
                    end
                    -- Nếu không lấy được qua Visible (do canvas group/animation), lấy text Title hợp lệ đầu tiên
                    for _, desc in ipairs(eqContainer:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Name == "Title" and desc.Text ~= "" then
                            local txt = desc.Text:gsub("^%s+", ""):gsub("%s+$", "")
                            if not tonumber(txt) and not txt:find("^<font") and txt ~= "" then
                                return txt
                            end
                        end
                    end
                end

                -- B. Tìm trong Hotbar (Nếu có slot Selected/Active)
                local hotbar = brContainer and brContainer:FindFirstChild("Hotbar")
                local hbContainer = hotbar and hotbar:FindFirstChild("Container")
                if hbContainer then
                    for _, slot in ipairs(hbContainer:GetChildren()) do
                        if slot:IsA("GuiObject") then
                            local sel = slot:FindFirstChild("Selected") or slot:FindFirstChild("Active") or slot:FindFirstChild("Highlight")
                            if (sel and sel:IsA("GuiObject") and sel.Visible) or slot:GetAttribute("Selected") == true then
                                return slot.Name
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. [ATTRIBUTES]: Kiểm tra thuộc tính trên Character và Player
    local wAttr = char:GetAttribute("EquippedWeapon")
        or char:GetAttribute("Weapon")
        or char:GetAttribute("CurrentWeapon")
        or char:GetAttribute("Equipped")
        or char:GetAttribute("Gun")
    if not wAttr and not isNPC and target then
        wAttr = target:GetAttribute("EquippedWeapon")
            or target:GetAttribute("Weapon")
            or target:GetAttribute("CurrentWeapon")
            or target:GetAttribute("Equipped")
    end
    if wAttr and tostring(wAttr) ~= "" then
        return tostring(wAttr)
    end

    -- 3. [WELDS / MOTOR6D]: Quét khớp nối ở tay nhân vật (3rd-person models của địch)
    local limbs = {
        char:FindFirstChild("RightHand"),
        char:FindFirstChild("Right Arm"),
        char:FindFirstChild("RightLowerArm"),
        char:FindFirstChild("LeftHand"),
        char:FindFirstChild("Left Arm")
    }
    for _, limb in ipairs(limbs) do
        if limb then
            for _, joint in ipairs(limb:GetChildren()) do
                if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
                    local p0 = joint.Part0
                    local p1 = joint.Part1
                    local connectedPart = (p0 ~= limb and p0) or (p1 ~= limb and p1)
                    if connectedPart and connectedPart.Parent and connectedPart.Parent ~= char and not connectedPart.Parent:IsA("Accessory") then
                        local mName = connectedPart.Parent.Name
                        if mName ~= "Workspace" and not mName:lower():find("character") and not mName:lower():find("rig") then
                            return mName
                        end
                    end
                end
            end
        end
    end

    -- 4. [CHARACTER CHILDREN]: Quét các Model vũ khí gắn trực tiếp vào nhân vật
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and not child:IsA("Accessory") then
            local n = child.Name
            local nl = n:lower()
            if not nl:find("animate") and not nl:find("ragdoll") and not nl:find("humanoid") and not nl:find("root") and not nl:find("body") then
                return n
            end
        end
    end

    -- 5. [WORKSPACE standardweapons_bundle]: Quét bundle trong Workspace
    local swBundle = workspace:FindFirstChild("standardweapons_bundle")
    if swBundle and target then
        local pModel = swBundle:FindFirstChild(target.Name) or swBundle:FindFirstChild(char.Name)
        if pModel then
            return pModel.Name
        end
    end

    -- 6. [FALLBACK TOOL]: Kiểm tra Tool Roblox truyền thống
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        return tool.Name
    end

    return "Unarmed"
end

local function createESP(player)
    if ESPTable[player] then return end
    local esp = {}
    esp.Box = Drawing.new("Square"); esp.Box.Thickness = 1.5
    esp.Box.Color = Color3.fromRGB(255, 255, 255); esp.Box.Filled = false
    esp.Name = Drawing.new("Text"); esp.Name.Size = 14; esp.Name.Center = true
    esp.Name.Outline = true; esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.HealthBg = Drawing.new("Line"); esp.HealthBg.Thickness = 3
    esp.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    esp.Health = Drawing.new("Line"); esp.Health.Thickness = 1.5
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Tracer = Drawing.new("Line"); esp.Tracer.Thickness = 1.5
    esp.Tracer.Color = Color3.fromRGB(255, 255, 255)

    esp.Info = Drawing.new("Text")
    esp.Info.Size = 12
    esp.Info.Center = true
    esp.Info.Outline = true
    esp.Info.Color = Color3.fromRGB(255, 255, 255)

    esp.Skeleton = {}
    for i = 1, 14 do
        local bone = Drawing.new("Line")
        bone.Thickness = 1.5
        bone.Color = Color3.fromRGB(255, 255, 255)
        bone.Visible = false
        esp.Skeleton[i] = bone
    end

    esp.Chams = Instance.new("Highlight")
    esp.Chams.Name = RandomString(8)
    esp.Chams.FillTransparency = 0.5
    esp.Chams.OutlineTransparency = 0.1
    esp.Chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    esp.Chams.Enabled = false
    esp.Chams.Parent = ChamsFolder

    esp.ArrowLines = {}
    for i = 1, 18 do
        local l = Drawing.new("Line")
        l.Thickness = 2
        l.Color = Color3.fromRGB(255, 255, 255)
        l.Visible = false
        esp.ArrowLines[i] = l
    end

    esp.ArrowName = Drawing.new("Text")
    esp.ArrowName.Size = 13
    esp.ArrowName.Center = true
    esp.ArrowName.Outline = true
    esp.ArrowName.Color = Color3.fromRGB(255, 255, 255)
    esp.ArrowName.Visible = false

    esp.ArrowDist = Drawing.new("Text")
    esp.ArrowDist.Size = 12
    esp.ArrowDist.Center = true
    esp.ArrowDist.Outline = true
    esp.ArrowDist.Color = Color3.fromRGB(255, 255, 255)
    esp.ArrowDist.Visible = false

    esp.ArrowHealthBg = Drawing.new("Line")
    esp.ArrowHealthBg.Thickness = 3
    esp.ArrowHealthBg.Color = Color3.fromRGB(0, 0, 0)
    esp.ArrowHealthBg.Visible = false

    esp.ArrowHealth = Drawing.new("Line")
    esp.ArrowHealth.Thickness = 2
    esp.ArrowHealth.Color = Color3.fromRGB(0, 255, 0)
    esp.ArrowHealth.Visible = false

    esp._chamsOn = false
    esp._rendered = false
    esp._skeletonVisible = false
    esp._lastTextTick = 0
    esp._cachedNameText = ""
    esp._cachedInfoText = ""
    esp._cachedHealthPct = 1
    esp._cachedHealthCol = Color3.fromRGB(0, 255, 0)
    ESPTable[player] = esp
end

local function removeESP(player)
    local esp = ESPTable[player]
    if esp then
        pcall(function() if esp.Box then esp.Box:Remove() end end)
        pcall(function() if esp.Name then esp.Name:Remove() end end)
        pcall(function() if esp.HealthBg then esp.HealthBg:Remove() end end)
        pcall(function() if esp.Health then esp.Health:Remove() end end)
        pcall(function() if esp.Tracer then esp.Tracer:Remove() end end)
        pcall(function() if esp.Info then esp.Info:Remove() end end)
        pcall(function() if esp.Chams then esp.Chams:Destroy() end end)
        pcall(function()
            if esp.ArrowLines then
                for i = 1, #esp.ArrowLines do
                    if esp.ArrowLines[i] then esp.ArrowLines[i]:Remove() end
                end
            end
            if esp.ArrowName then esp.ArrowName:Remove() end
            if esp.ArrowDist then esp.ArrowDist:Remove() end
            if esp.ArrowHealthBg then esp.ArrowHealthBg:Remove() end
            if esp.ArrowHealth then esp.ArrowHealth:Remove() end
        end)
        if esp.Skeleton then
            for i = 1, #esp.Skeleton do
                pcall(function() if esp.Skeleton[i] then esp.Skeleton[i]:Remove() end end)
            end
        end
        ESPTable[player] = nil
    end
end

local function hideOnScreenESP(esp)
    if not esp then return end
    if esp.Box and esp.Box.Visible then esp.Box.Visible = false end
    if esp.Name and esp.Name.Visible then esp.Name.Visible = false end
    if esp.Info and esp.Info.Visible then esp.Info.Visible = false end
    if esp.HealthBg and esp.HealthBg.Visible then esp.HealthBg.Visible = false end
    if esp.Health and esp.Health.Visible then esp.Health.Visible = false end
    if esp.Tracer and esp.Tracer.Visible then esp.Tracer.Visible = false end
    if esp._skeletonVisible or esp.Skeleton then
        esp._skeletonVisible = false
        for i = 1, 14 do
            local b = esp.Skeleton[i]
            if b and b.Visible then b.Visible = false end
        end
    end
end

local function hideArrowESP(esp)
    if not esp then return end
    if esp.ArrowLines then
        for i = 1, #esp.ArrowLines do
            local l = esp.ArrowLines[i]
            if l and l.Visible then l.Visible = false end
        end
    end
    if esp.ArrowName and esp.ArrowName.Visible then esp.ArrowName.Visible = false end
    if esp.ArrowDist and esp.ArrowDist.Visible then esp.ArrowDist.Visible = false end
    if esp.ArrowHealthBg and esp.ArrowHealthBg.Visible then esp.ArrowHealthBg.Visible = false end
    if esp.ArrowHealth and esp.ArrowHealth.Visible then esp.ArrowHealth.Visible = false end
end

local function hideAllESP(esp)
    if not esp then return end
    hideOnScreenESP(esp)
    hideArrowESP(esp)
    if esp.Chams and esp.Chams.Enabled then
        esp.Chams.Enabled = false
        esp._chamsOn = false
    end
    esp._rendered = false
end
Shared.hideAllESP = hideAllESP
Shared.createESP = createESP
Shared.removeESP = removeESP

Players.PlayerAdded:Connect(createESP)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end
Players.PlayerRemoving:Connect(removeESP)



    local espTotalInRange = 0
    local espTotalOnScreen = 0

    local function UpdateESP(camPos, center, ESPCounterBox, ESPCounterLabel)
        ESPCounterBox = ESPCounterBox or (Shared.UI_Elements and Shared.UI_Elements.ESPCounterBox)
        ESPCounterLabel = ESPCounterLabel or (Shared.UI_Elements and Shared.UI_Elements.ESPCounterLabel)

        if not Settings.ESPEnabled then
            if ESPCounterBox and ESPCounterBox.Visible then ESPCounterBox.Visible = false end
            if espActive then
                for _, esp in pairs(ESPTable) do
                    hideAllESP(esp)
                end
                espActive = false
            end
            return
        end
        espActive = true

        table.clear(bonePosCache)
        table.clear(boneVisCache)
        espTotalInRange = 0
        espTotalOnScreen = 0

        for target, esp in pairs(ESPTable) do
            local isVisibleNow = false
        local isValid = false
        local char = nil
        local targetName = ""
        local isNPC = false

        if typeof(target) == "Instance" then
            if target:IsA("Player") then
                if target.Parent == Players then
                    isValid = true
                    char = target.Character
                    targetName = target.DisplayName or target.Name
                end
            elseif target:IsA("Model") or target:IsA("Actor") then
                if target.Parent ~= nil then
                    isValid = true
                    char = target
                    local dName = target:GetAttribute("DisplayName")
                    if dName and dName ~= "" then
                        targetName = dName .. " [BOT]"
                    else
                        targetName = target.Name .. " [BOT]"
                    end
                    isNPC = true
                end
            end
        end

        if not isValid or (isNPC and not Settings.TargetNPC) then
            if not isValid then
                removeESP(target)
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.HealthBg.Visible = false
                esp.Health.Visible = false
                esp.Tracer.Visible = false
                esp.Info.Visible = false
                if esp.Chams then esp.Chams.Enabled = false end
                if esp.Arrow1 then esp.Arrow1.Visible = false end
                if esp.Arrow2 then esp.Arrow2.Visible = false end
                if esp.Arrow3 then esp.Arrow3.Visible = false end
                if esp.Skeleton then
                    for i = 1, #esp.Skeleton do
                        if esp.Skeleton[i] then esp.Skeleton[i].Visible = false end
                    end
                end
            end
            continue
        end

        local isAlive = false
        local hrp = nil
        local head = nil
        local hum = nil
        local maxH = 100

        if char then
            hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char.PrimaryPart
            head = char:FindFirstChild("Head") or hrp
            hum = char:FindFirstChildOfClass("Humanoid")

            if hum then
                isAlive = hum.Health > 0
                maxH = math.max(hum.MaxHealth, 1)
            else
                local healthVal = char:FindFirstChild("Health") or char:FindFirstChild("health")
                if healthVal and (healthVal:IsA("NumberValue") or healthVal:IsA("IntValue")) then
                    isAlive = healthVal.Value > 0
                    local maxHealthVal = char:FindFirstChild("MaxHealth") or char:FindFirstChild("maxHealth")
                    if maxHealthVal and (maxHealthVal:IsA("NumberValue") or maxHealthVal:IsA("IntValue")) then
                        maxH = math.max(maxHealthVal.Value, 1)
                    end
                elseif char:GetAttribute("Health") then
                    isAlive = ((tonumber(char:GetAttribute("Health")) or 0) > 0)
                    local attrMaxH = char:GetAttribute("MaxHealth")
                    if attrMaxH then maxH = math.max(tonumber(attrMaxH) or 100, 1) end
                elseif isNPC then
                    isAlive = true
                end
            end
        end

        if Settings.ESPEnabled and hrp and head and isAlive then
                local passTeamCheck = not isSameTeam(target)

                if passTeamCheck then
                    local diff = hrp.Position - camPos
                    local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                    local maxDist = Settings.ESPDist or 1000

                    if distSq <= (maxDist * maxDist) then
                        local dist = math.sqrt(distSq)
                        espTotalInRange = espTotalInRange + 1

                        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                        if Settings.ESPChams then
                            if not esp._chamsOn then
                                esp._chamsOn = true
                                esp.Chams.Enabled = true
                            end
                            if esp.Chams.Adornee ~= char then esp.Chams.Adornee = char end
                            local col = ColorList[Settings.ChamsColor] or Color3.fromRGB(255, 0, 0)
                            if esp.Chams.FillColor ~= col then
                                esp.Chams.FillColor = col
                                esp.Chams.OutlineColor = col
                            end
                        else
                            if esp._chamsOn then
                                esp._chamsOn = false
                                esp.Chams.Enabled = false
                            end
                        end

                        if onScreen and rootPos.Z > 0 then
                            espTotalOnScreen = espTotalOnScreen + 1
                            isVisibleNow = true

                            local headPos = Camera:WorldToViewportPoint(head.Position + VEC3_UP_HEAD)
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - VEC3_DOWN_LEG)
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2

                            if Settings.ESPBox then
                                esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                                if not esp.Box.Visible then esp.Box.Visible = true end
                            else
                                if esp.Box.Visible then esp.Box.Visible = false end
                            end

                            -- [ESP THROTTLING]: Cập nhật chuỗi & dữ liệu chỉ 12-15 FPS để tiết kiệm CPU
                            local now = tick()
                            if (now - (esp._lastTextTick or 0)) >= 0.08 then
                                esp._lastTextTick = now

                                -- 1. Tên & Khoảng cách (Tránh ghép chuỗi mỗi frame)
                                if Settings.ESPName or Settings.ESPDistance then
                                    local textString = ""
                                    if Settings.ESPName then textString = targetName end
                                    if Settings.ESPDistance then
                                        textString = textString
                                            .. (Settings.ESPName and " " or "")
                                            .. "[" .. math.floor(dist) .. "m]"
                                    end
                                    esp._cachedNameText = textString
                                else
                                    esp._cachedNameText = ""
                                end

                                -- 2. Vũ khí & Cấp độ (Tránh quét con trỏ Tool/leaderstats mỗi frame)
                                if Settings.ESPWeapon or Settings.ESPLevel then
                                    local infoText = ""
                                    if Settings.ESPLevel then
                                        local lvl = nil
                                        if not isNPC then
                                            lvl = target:GetAttribute("Level")
                                            if not lvl then
                                                local customStats = target:FindFirstChild("CustomLeaderstats")
                                                if customStats then
                                                    local lVal = customStats:FindFirstChild("Level")
                                                    if lVal and lVal:IsA("ValueBase") then
                                                        lvl = lVal.Value
                                                    end
                                                end
                                            end
                                            if not lvl then
                                                local stats = target:FindFirstChild("leaderstats")
                                                local lVal = stats and (stats:FindFirstChild("Level")
                                                    or stats:FindFirstChild("XP")
                                                    or stats:FindFirstChild("Exp")
                                                    or stats:FindFirstChild("Win")
                                                    or stats:FindFirstChild("Wins")) or target:FindFirstChild("Level")
                                                if lVal and lVal:IsA("ValueBase") then
                                                    lvl = lVal.Value
                                                end
                                            end
                                        else
                                            lvl = char:GetAttribute("Level") or char:GetAttribute("Lv")
                                        end
                                        if lvl then
                                            infoText = infoText .. "[Lv " .. tostring(lvl) .. "] "
                                        end
                                    end
                                    if Settings.ESPWeapon then
                                        local wName = getEquippedWeapon(target, char, isNPC)
                                        infoText = infoText .. (wName or "Unarmed")
                                    end
                                    esp._cachedInfoText = infoText:gsub("%s+$", "")
                                else
                                    esp._cachedInfoText = ""
                                end

                                -- 3. Phần trăm máu & màu sắc
                                if Settings.ESPHealth then
                                    local currentH = hum and hum.Health or (char:FindFirstChild("Health") and char:FindFirstChild("Health"):IsA("NumberValue") and char.Health.Value or (char:GetAttribute("Health") or maxH))
                                    local healthPct = math.clamp((tonumber(currentH) or maxH) / maxH, 0, 1)
                                    esp._cachedHealthPct = healthPct
                                    esp._cachedHealthCol = Color3.fromRGB(255 - (healthPct * 255), healthPct * 255, 0)
                                end
                            end

                            -- [VỊ TRÍ RENDER MƯỢT 60-144 FPS]: Chỉ cập nhật tọa độ hình học (Chống Property Thrashing)
                            if Settings.ESPName or Settings.ESPDistance then
                                if esp.Name.Text ~= esp._cachedNameText then
                                    esp.Name.Text = esp._cachedNameText
                                end
                                esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
                                if not esp.Name.Visible then esp.Name.Visible = true end
                            else
                                if esp.Name.Visible then esp.Name.Visible = false end
                            end

                            if (Settings.ESPWeapon or Settings.ESPLevel) and esp._cachedInfoText ~= "" then
                                if esp.Info.Text ~= esp._cachedInfoText then
                                    esp.Info.Text = esp._cachedInfoText
                                end
                                -- Hiển thị Lv & Weapon ở dưới đáy Box (legPos.Y + 2) để không bị trùng tên trên đầu
                                esp.Info.Position = Vector2.new(rootPos.X, legPos.Y + 2)
                                if not esp.Info.Visible then esp.Info.Visible = true end
                            else
                                if esp.Info.Visible then esp.Info.Visible = false end
                            end

                            if Settings.ESPHealth then
                                local dynamicThickness = math.clamp(150 / math.max(dist, 1), 1, 4)
                                local barX = rootPos.X - width / 2 - (dynamicThickness + 2)
                                if esp.HealthBg.Thickness ~= dynamicThickness then esp.HealthBg.Thickness = dynamicThickness end
                                esp.HealthBg.From = Vector2.new(barX, headPos.Y)
                                esp.HealthBg.To = Vector2.new(barX, legPos.Y)
                                if not esp.HealthBg.Visible then esp.HealthBg.Visible = true end

                                local yOffset = height * (esp._cachedHealthPct or 1)
                                if esp.Health.Thickness ~= dynamicThickness then esp.Health.Thickness = dynamicThickness end
                                esp.Health.From = Vector2.new(barX, legPos.Y - yOffset)
                                esp.Health.To = Vector2.new(barX, legPos.Y)
                                local hCol = esp._cachedHealthCol or Color3.fromRGB(0, 255, 0)
                                if esp.Health.Color ~= hCol then esp.Health.Color = hCol end
                                if not esp.Health.Visible then esp.Health.Visible = true end
                            else
                                if esp.HealthBg.Visible then esp.HealthBg.Visible = false end
                                if esp.Health.Visible then esp.Health.Visible = false end
                            end

                            if Settings.ESPLine then
                                esp.Tracer.From = Vector2.new(center.X, 0)
                                esp.Tracer.To = Vector2.new(rootPos.X, headPos.Y)
                                if not esp.Tracer.Visible then esp.Tracer.Visible = true end
                            else
                                if esp.Tracer.Visible then esp.Tracer.Visible = false end
                            end

                            -- [SKELETON LOD]: Tự động ẩn Skeleton khi địch > 150m (quá xa, nhìn rối mắt và tốn FPS)
                            if Settings.ESPSkeleton and dist <= 150 then
                                esp._skeletonVisible = true
                                local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                                local connections = isR15 and Const.R15_BONES or Const.R6_BONES
                                for i = 1, 14 do
                                    local boneDraw = esp.Skeleton[i]
                                    local conn = connections[i]
                                    if conn then
                                        local partA = char:FindFirstChild(conn[1])
                                        local partB = char:FindFirstChild(conn[2])
                                        if partA and partB then
                                            local posA = bonePosCache[partA]
                                            local visA = boneVisCache[partA]
                                            if not posA then
                                                posA, visA = Camera:WorldToViewportPoint(partA.Position)
                                                bonePosCache[partA] = posA
                                                boneVisCache[partA] = visA
                                            end

                                            local posB = bonePosCache[partB]
                                            local visB = boneVisCache[partB]
                                            if not posB then
                                                posB, visB = Camera:WorldToViewportPoint(partB.Position)
                                                bonePosCache[partB] = posB
                                                boneVisCache[partB] = visB
                                            end

                                            if visA or visB then
                                                boneDraw.From = Vector2.new(posA.X, posA.Y)
                                                boneDraw.To = Vector2.new(posB.X, posB.Y)
                                                if not boneDraw.Visible then boneDraw.Visible = true end
                                            else
                                                if boneDraw.Visible then boneDraw.Visible = false end
                                            end
                                        else
                                            if boneDraw.Visible then boneDraw.Visible = false end
                                        end
                                    else
                                        if boneDraw.Visible then boneDraw.Visible = false end
                                    end
                                end
                            else
                                if esp._skeletonVisible then
                                    esp._skeletonVisible = false
                                    for i = 1, 14 do esp.Skeleton[i].Visible = false end
                                end
                            end

                            hideArrowESP(esp)
                        else
                            -- Off-Screen: Ẩn các thành phần trên màn hình (Box, Tracer, Skeleton, Name, Health) để không dính hình
                            hideOnScreenESP(esp)

                            -- Off-Screen Arrows (Khi địch ngoài màn hình)
                            if Settings.OffscreenArrows then
                                local camCFrame = Camera.CFrame
                                local relVector = hrp.Position - camCFrame.Position
                                local forward = camCFrame.LookVector
                                local right = camCFrame.RightVector
                                local x = relVector:Dot(right)
                                local z = relVector:Dot(forward)
                                local angle = math.atan2(x, z)
                                local radius = 200
                                local dir = Vector2.new(math.sin(angle), -math.cos(angle))
                                local perp = Vector2.new(-math.cos(angle), -math.sin(angle))
                                local tip = center + dir * radius
                                local base = center + dir * (radius - 22)
                                local sideWidth = 11
                                local pB = base + perp * sideWidth
                                local pC = base - perp * sideWidth
                                local arrowCenter = (tip + base) * 0.5

                                -- 1. Mũi tên tam giác trắng đặc mịn màng (Smooth Triangle Fan - 0 răng cưa)
                                if esp.ArrowLines then
                                    -- 17 tia từ đỉnh tip phủ kín toàn bộ bề mặt tam giác với cạnh biên mượt mà
                                    for i = 1, 17 do
                                        local t = (i - 1) / 16
                                        local targetPt = pB:Lerp(pC, t)
                                        local l = esp.ArrowLines[i]
                                        if l then
                                            l.From = tip
                                            l.To = targetPt
                                            if not l.Visible then l.Visible = true end
                                        end
                                    end
                                    -- Tia thứ 18 đóng kín cạnh đáy pB -> pC
                                    local baseLine = esp.ArrowLines[18]
                                    if baseLine then
                                        baseLine.From = pB
                                        baseLine.To = pC
                                        if not baseLine.Visible then baseLine.Visible = true end
                                    end
                                end

                                -- Tọa độ bounding để định vị chữ và thanh máu không bị đè vào tam giác
                                local minY = math.min(tip.Y, pB.Y, pC.Y)
                                local maxY = math.max(tip.Y, pB.Y, pC.Y)
                                local minX = math.min(tip.X, pB.X, pC.X)
                                local maxX = math.max(tip.X, pB.X, pC.X)
                                local centerX = (minX + maxX) * 0.5

                                -- 2. Tên kẻ địch (Tương ứng với ESP Name)
                                if Settings.ESPName and esp.ArrowName then
                                    if esp.ArrowName.Text ~= targetName then
                                        esp.ArrowName.Text = targetName
                                    end
                                    esp.ArrowName.Position = Vector2.new(centerX, minY - 16)
                                    if not esp.ArrowName.Visible then esp.ArrowName.Visible = true end
                                else
                                    if esp.ArrowName and esp.ArrowName.Visible then esp.ArrowName.Visible = false end
                                end

                                -- 3. Khoảng cách (Tương ứng với ESP Distance)
                                if Settings.ESPDistance and esp.ArrowDist then
                                    local distText = math.floor(dist) .. "m"
                                    if esp.ArrowDist.Text ~= distText then
                                        esp.ArrowDist.Text = distText
                                    end
                                    esp.ArrowDist.Position = Vector2.new(centerX, maxY + 4)
                                    if not esp.ArrowDist.Visible then esp.ArrowDist.Visible = true end
                                else
                                    if esp.ArrowDist and esp.ArrowDist.Visible then esp.ArrowDist.Visible = false end
                                end

                                -- 4. Thanh máu dọc (Tương ứng với ESP Health)
                                if Settings.ESPHealth and esp.ArrowHealth and esp.ArrowHealthBg then
                                    local barX = maxX + 6
                                    local barTop = minY
                                    local barBottom = maxY
                                    local barHeight = math.max(barBottom - barTop, 14)

                                    esp.ArrowHealthBg.From = Vector2.new(barX, barTop)
                                    esp.ArrowHealthBg.To = Vector2.new(barX, barBottom)
                                    if not esp.ArrowHealthBg.Visible then esp.ArrowHealthBg.Visible = true end

                                    local healthPct = esp._cachedHealthPct or 1
                                    local fillY = barBottom - (barHeight * healthPct)
                                    esp.ArrowHealth.From = Vector2.new(barX, fillY)
                                    esp.ArrowHealth.To = Vector2.new(barX, barBottom)
                                    local hCol = esp._cachedHealthCol or Color3.fromRGB(0, 255, 0)
                                    if esp.ArrowHealth.Color ~= hCol then
                                        esp.ArrowHealth.Color = hCol
                                    end
                                    if not esp.ArrowHealth.Visible then esp.ArrowHealth.Visible = true end
                                else
                                    if esp.ArrowHealthBg and esp.ArrowHealthBg.Visible then esp.ArrowHealthBg.Visible = false end
                                    if esp.ArrowHealth and esp.ArrowHealth.Visible then esp.ArrowHealth.Visible = false end
                                end

                                isVisibleNow = true
                            else
                                hideArrowESP(esp)
                            end
                        end
                    else
                        if esp._chamsOn then
                            esp._chamsOn = false
                            esp.Chams.Enabled = false
                        end
                        hideArrowESP(esp)
                    end
                else
                    if esp._chamsOn then
                        esp._chamsOn = false
                        esp.Chams.Enabled = false
                    end
                    hideArrowESP(esp)
                end
            end

        if isVisibleNow then
            esp._rendered = true
        else
            if esp._rendered or (esp.Arrow1 and esp.Arrow1.Visible) or (esp.Box and esp.Box.Visible) or (esp.Tracer and esp.Tracer.Visible) or (esp.Name and esp.Name.Visible) then
                hideAllESP(esp)
            end
        end
    end

    -- 7. CẬP NHẬT TOP-CENTER ESP COUNTER (KHUNG ĐEN VUÔNG - CHỈ HIỆN SỐ TRONG TẦM)
    if Settings.ESPEnabled and Settings.ESPCount then
        ESPCounterBox.Visible = true
        ESPCounterLabel.Text = tostring(espTotalInRange)
        if espTotalInRange > 0 then
            ESPCounterLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        else
            ESPCounterLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        ESPCounterBox.Visible = false
    end

    end

    ESP.ChamsFolder = ChamsFolder
    ESP.createESP = createESP
    ESP.removeESP = removeESP
    ESP.hideAllESP = hideAllESP
    ESP.UpdateESP = UpdateESP

    return ESP
end
