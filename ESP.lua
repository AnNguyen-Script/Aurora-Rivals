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

    local boneScreenCache = {}
    local VEC3_UP_HEAD = Vector3.new(0, 0.5, 0)
    local VEC3_DOWN_LEG = Vector3.new(0, 3, 0)

local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = IDS.ChamsFolder
pcall(function() ChamsFolder.Parent = parentGui end)
if not ChamsFolder.Parent then pcall(function() ChamsFolder.Parent = Camera end) end

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

    esp.Arrow1 = Drawing.new("Line"); esp.Arrow1.Thickness = 2.5; esp.Arrow1.Color = Color3.fromRGB(255, 35, 35); esp.Arrow1.Visible = false
    esp.Arrow2 = Drawing.new("Line"); esp.Arrow2.Thickness = 2.5; esp.Arrow2.Color = Color3.fromRGB(255, 35, 35); esp.Arrow2.Visible = false
    esp.Arrow3 = Drawing.new("Line"); esp.Arrow3.Thickness = 2; esp.Arrow3.Color = Color3.fromRGB(255, 35, 35); esp.Arrow3.Visible = false

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
            if esp.Arrow1 then esp.Arrow1:Remove() end
            if esp.Arrow2 then esp.Arrow2:Remove() end
            if esp.Arrow3 then esp.Arrow3:Remove() end
        end)
        if esp.Skeleton then
            for i = 1, #esp.Skeleton do
                pcall(function() if esp.Skeleton[i] then esp.Skeleton[i]:Remove() end end)
            end
        end
        ESPTable[player] = nil
    end
end

local function hideAllESP(esp)
    if not esp then return end
    if esp.Box and esp.Box.Visible then esp.Box.Visible = false end
    if esp.Name and esp.Name.Visible then esp.Name.Visible = false end
    if esp.Info and esp.Info.Visible then esp.Info.Visible = false end
    if esp.HealthBg and esp.HealthBg.Visible then esp.HealthBg.Visible = false end
    if esp.Health and esp.Health.Visible then esp.Health.Visible = false end
    if esp.Tracer and esp.Tracer.Visible then esp.Tracer.Visible = false end
    if esp.Arrow1 and esp.Arrow1.Visible then esp.Arrow1.Visible = false end
    if esp.Arrow2 and esp.Arrow2.Visible then esp.Arrow2.Visible = false end
    if esp.Arrow3 and esp.Arrow3.Visible then esp.Arrow3.Visible = false end
    if esp.Skeleton then
        for i = 1, 14 do
            local b = esp.Skeleton[i]
            if b and b.Visible then b.Visible = false end
        end
    end
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
        espTotalInRange = 0
        espTotalOnScreen = 0

        ESPCounterBox = ESPCounterBox or (Shared.UI_Elements and Shared.UI_Elements.ESPCounterBox)
        ESPCounterLabel = ESPCounterLabel or (Shared.UI_Elements and Shared.UI_Elements.ESPCounterLabel)

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
                    local dist = (hrp.Position - camPos).Magnitude

                    if dist <= Settings.ESPDist then
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
                                esp.Box.Visible = true
                            else
                                esp.Box.Visible = false
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
                                        if not isNPC then
                                            local stats = target:FindFirstChild("leaderstats")
                                            local lvl = stats and (stats:FindFirstChild("Level")
                                                or stats:FindFirstChild("XP")
                                                or stats:FindFirstChild("Exp")
                                                or stats:FindFirstChild("Win")
                                                or stats:FindFirstChild("Wins")) or target:FindFirstChild("Level")
                                            if lvl and lvl:IsA("ValueBase") then
                                                infoText = infoText .. "[Lv " .. tostring(lvl.Value) .. "] "
                                            end
                                        else
                                            local lvl = char:GetAttribute("Level") or char:GetAttribute("Lv")
                                            if lvl then
                                                infoText = infoText .. "[Lv " .. tostring(lvl) .. "] "
                                            end
                                        end
                                    end
                                    if Settings.ESPWeapon then
                                        local tool = char:FindFirstChildOfClass("Tool")
                                        if tool then
                                            infoText = infoText .. tool.Name
                                        else
                                            infoText = infoText .. "Unarmed"
                                        end
                                    end
                                    esp._cachedInfoText = infoText
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

                            -- [VỊ TRÍ RENDER MƯỢT 60-144 FPS]: Chỉ cập nhật tọa độ hình học
                            if Settings.ESPName or Settings.ESPDistance then
                                if esp.Name.Text ~= esp._cachedNameText then
                                    esp.Name.Text = esp._cachedNameText
                                end
                                esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
                                esp.Name.Visible = true
                            else
                                esp.Name.Visible = false
                            end

                            if (Settings.ESPWeapon or Settings.ESPLevel) and esp._cachedInfoText ~= "" then
                                if esp.Info.Text ~= esp._cachedInfoText then
                                    esp.Info.Text = esp._cachedInfoText
                                end
                                esp.Info.Position = Vector2.new(rootPos.X, headPos.Y - 32)
                                esp.Info.Visible = true
                            else
                                esp.Info.Visible = false
                            end

                            if Settings.ESPHealth then
                                local dynamicThickness = math.clamp(150 / math.max(dist, 1), 1, 4)
                                local barX = rootPos.X - width / 2 - (dynamicThickness + 2)
                                esp.HealthBg.Thickness = dynamicThickness
                                esp.HealthBg.From = Vector2.new(barX, headPos.Y)
                                esp.HealthBg.To = Vector2.new(barX, legPos.Y)
                                esp.HealthBg.Visible = true

                                local yOffset = height * (esp._cachedHealthPct or 1)
                                esp.Health.Thickness = dynamicThickness
                                esp.Health.From = Vector2.new(barX, legPos.Y - yOffset)
                                esp.Health.To = Vector2.new(barX, legPos.Y)
                                esp.Health.Color = esp._cachedHealthCol or Color3.fromRGB(0, 255, 0)
                                esp.Health.Visible = true
                            else
                                esp.HealthBg.Visible = false
                                esp.Health.Visible = false
                            end

                            if Settings.ESPLine then
                                esp.Tracer.From = Vector2.new(center.X, 0)
                                esp.Tracer.To = Vector2.new(rootPos.X, headPos.Y)
                                esp.Tracer.Visible = true
                            else
                                esp.Tracer.Visible = false
                            end

                            -- [SKELETON LOD]: Tự động ẩn Skeleton khi địch > 150m (quá xa, nhìn rối mắt và tốn FPS)
                            if Settings.ESPSkeleton and dist <= 150 then
                                esp._skeletonVisible = true
                                table.clear(boneScreenCache)
                                local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                                local connections = isR15 and Const.R15_BONES or Const.R6_BONES
                                for i = 1, 14 do
                                    local boneDraw = esp.Skeleton[i]
                                    local conn = connections[i]
                                    if conn then
                                        local partA = char:FindFirstChild(conn[1])
                                        local partB = char:FindFirstChild(conn[2])
                                        if partA and partB then
                                            local ca = boneScreenCache[partA]
                                            local posA, visA
                                            if ca then
                                                posA, visA = ca[1], ca[2]
                                            else
                                                posA, visA = Camera:WorldToViewportPoint(partA.Position)
                                                boneScreenCache[partA] = {posA, visA}
                                            end

                                            local cb = boneScreenCache[partB]
                                            local posB, visB
                                            if cb then
                                                posB, visB = cb[1], cb[2]
                                            else
                                                posB, visB = Camera:WorldToViewportPoint(partB.Position)
                                                boneScreenCache[partB] = {posB, visB}
                                            end

                                            if visA or visB then
                                                boneDraw.From = Vector2.new(posA.X, posA.Y)
                                                boneDraw.To = Vector2.new(posB.X, posB.Y)
                                                boneDraw.Visible = true
                                            else
                                                boneDraw.Visible = false
                                            end
                                        else
                                            boneDraw.Visible = false
                                        end
                                    else
                                        boneDraw.Visible = false
                                    end
                                end
                            else
                                if esp._skeletonVisible then
                                    esp._skeletonVisible = false
                                    for i = 1, 14 do esp.Skeleton[i].Visible = false end
                                end
                            end

                            if esp.Arrow1 then esp.Arrow1.Visible = false; esp.Arrow2.Visible = false; esp.Arrow3.Visible = false end
                        else
                            -- Off-Screen Arrows (Khi địch ngoài màn hình)
                            if Settings.OffscreenArrows then
                                local camCFrame = Camera.CFrame
                                local relVector = hrp.Position - camCFrame.Position
                                local forward = camCFrame.LookVector
                                local right = camCFrame.RightVector
                                local x = relVector:Dot(right)
                                local z = relVector:Dot(forward)
                                local angle = math.atan2(x, z)
                                local radius = 170
                                local tip = center + Vector2.new(math.sin(angle), -math.cos(angle)) * radius
                                local base = center + Vector2.new(math.sin(angle), -math.cos(angle)) * (radius - 18)
                                local perp = Vector2.new(-math.cos(angle), -math.sin(angle)) * 9
                                esp.Arrow1.From = tip
                                esp.Arrow1.To = base + perp
                                esp.Arrow1.Visible = true

                                esp.Arrow2.From = tip
                                esp.Arrow2.To = base - perp
                                esp.Arrow2.Visible = true

                                esp.Arrow3.From = base + perp
                                esp.Arrow3.To = base - perp
                                esp.Arrow3.Visible = true
                                isVisibleNow = true
                            else
                                if esp.Arrow1 then esp.Arrow1.Visible = false; esp.Arrow2.Visible = false; esp.Arrow3.Visible = false end
                            end
                        end
                    else
                        if esp._chamsOn then
                            esp._chamsOn = false
                            esp.Chams.Enabled = false
                        end
                        if esp.Arrow1 then esp.Arrow1.Visible = false; esp.Arrow2.Visible = false; esp.Arrow3.Visible = false end
                    end
                else
                    if esp._chamsOn then
                        esp._chamsOn = false
                        esp.Chams.Enabled = false
                    end
                    if esp.Arrow1 then esp.Arrow1.Visible = false; esp.Arrow2.Visible = false; esp.Arrow3.Visible = false end
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
