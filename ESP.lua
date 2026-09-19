-- ============================================================
-- MODULAR RIVALS | MODULE: ESP, CHAMS, SKELETON & OFFSCREEN
-- ============================================================
return function(Shared, Targeting)
    local ESP = {}

    local Settings = Shared.Settings
    local Const = Shared.Const
    local LocalPlayer = Shared.LocalPlayer
    local Camera = Shared.Camera
    local Players = Shared.Players
    local Workspace = Shared.Workspace
    local ColorList = Shared.ColorList

    local ChamsFolder = Instance.new("Folder")
    ChamsFolder.Name = Shared.IDS.ChamsFolder
    pcall(function() ChamsFolder.Parent = Shared.parentGui end)
    if not ChamsFolder.Parent then pcall(function() ChamsFolder.Parent = Camera end) end
    ESP.ChamsFolder = ChamsFolder

    local ESPTable = {}
    ESP.ESPTable = ESPTable

    local boneScreenCache = {}

    local function createESP(player)
        if ESPTable[player] then return end
        local draw = {
            BoxOutline = Drawing.new("Square"),
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Distance = Drawing.new("Text"),
            HealthBarBg = Drawing.new("Square"),
            HealthBar = Drawing.new("Square"),
            Tracer = Drawing.new("Line"),
            Arrow1 = Drawing.new("Line"),
            Arrow2 = Drawing.new("Line"),
            Arrow3 = Drawing.new("Line"),
            Skeleton = {},
            Cham = nil
        }
        draw.BoxOutline.Thickness = 3
        draw.BoxOutline.Filled = false
        draw.BoxOutline.Color = Color3.fromRGB(0, 0, 0)

        draw.Box.Thickness = 1
        draw.Box.Filled = false

        draw.Name.Size = 13
        draw.Name.Center = true
        draw.Name.Outline = true
        draw.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
        draw.Name.Font = 2

        draw.Distance.Size = 11
        draw.Distance.Center = true
        draw.Distance.Outline = true
        draw.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
        draw.Distance.Font = 2

        draw.HealthBarBg.Thickness = 1
        draw.HealthBarBg.Filled = true
        draw.HealthBarBg.Color = Color3.fromRGB(20, 20, 20)

        draw.HealthBar.Thickness = 1
        draw.HealthBar.Filled = true

        draw.Tracer.Thickness = 1
        draw.Tracer.Transparency = 0.8

        draw.Arrow1.Thickness = 2.5
        draw.Arrow1.Color = Color3.fromRGB(255, 60, 60)
        draw.Arrow1.Visible = false

        draw.Arrow2.Thickness = 2.5
        draw.Arrow2.Color = Color3.fromRGB(255, 60, 60)
        draw.Arrow2.Visible = false

        draw.Arrow3.Thickness = 2
        draw.Arrow3.Color = Color3.fromRGB(255, 60, 60)
        draw.Arrow3.Visible = false

        for _ = 1, 15 do
            local bone = Drawing.new("Line")
            bone.Thickness = 1.5
            bone.Transparency = 0.8
            bone.Color = Color3.fromRGB(255, 255, 255)
            bone.Visible = false
            table.insert(draw.Skeleton, bone)
        end

        local h = Instance.new("Highlight")
        h.Name = "Cham_" .. tostring(player)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Enabled = false
        pcall(function() h.Parent = ChamsFolder end)
        draw.Cham = h

        ESPTable[player] = draw
    end
    ESP.createESP = createESP

    local function removeESP(player)
        local draw = ESPTable[player]
        if draw then
            pcall(function() draw.BoxOutline:Remove() end)
            pcall(function() draw.Box:Remove() end)
            pcall(function() draw.Name:Remove() end)
            pcall(function() draw.Distance:Remove() end)
            pcall(function() draw.HealthBarBg:Remove() end)
            pcall(function() draw.HealthBar:Remove() end)
            pcall(function() draw.Tracer:Remove() end)
            pcall(function() if draw.Arrow1 then draw.Arrow1:Remove() end end)
            pcall(function() if draw.Arrow2 then draw.Arrow2:Remove() end end)
            pcall(function() if draw.Arrow3 then draw.Arrow3:Remove() end end)
            for _, bone in pairs(draw.Skeleton) do
                pcall(function() bone:Remove() end)
            end
            if draw.Cham then pcall(function() draw.Cham:Destroy() end) end
            ESPTable[player] = nil
        end
    end
    ESP.removeESP = removeESP

    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then createESP(p) end
    end

    -- Update ESP logic (chạy trong RenderStepped)
    local function UpdateESP(camPos, center)
        table.clear(boneScreenCache)
        local espTotalInRange = 0
        local espTotalOnScreen = 0

        for target, esp in pairs(ESPTable) do
            local isVisibleNow = false
            local isValid = false
            local char = nil
            local targetName = ""
            local isNPC = false

            if typeof(target) == "Instance" and target:IsA("Player") then
                if target.Parent and target ~= LocalPlayer then
                    isValid = true
                    char = target.Character
                    targetName = target.DisplayName or target.Name
                end
            elseif typeof(target) == "Instance" and target:IsA("Model") then
                if target.Parent and target:IsDescendantOf(Workspace) then
                    isValid = true
                    char = target
                    local dName = target:GetAttribute("DisplayName")
                    if dName and dName ~= "" then
                        targetName = "[BOT] " .. dName
                    else
                        targetName = "[BOT] " .. target.Name
                    end
                    isNPC = true
                end
            end

            if not isValid then
                removeESP(target)
            else
                local isAlive = false
                local hrp = nil
                local head = nil
                local hum = nil
                local maxH = 100

                if char then
                    hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    head = char:FindFirstChild("Head")
                    hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("EnemyHumanoid")
                    local healthVal = char:FindFirstChild("Health") or char:FindFirstChild("health")
                    local maxHealthVal = char:FindFirstChild("MaxHealth") or char:FindFirstChild("maxhealth")

                    if hum then
                        isAlive = hum.Health > 0
                        maxH = hum.MaxHealth > 0 and hum.MaxHealth or 100
                    elseif healthVal and healthVal:IsA("NumberValue") then
                        isAlive = healthVal.Value > 0
                        local attrMaxH = char:GetAttribute("MaxHealth")
                        maxH = (maxHealthVal and maxHealthVal:IsA("NumberValue") and maxHealthVal.Value) or attrMaxH or 100
                    else
                        isAlive = hrp ~= nil and head ~= nil
                    end
                end

                local passTeamCheck = not Targeting.isSameTeam(target)
                local isTargetActive = Settings.ESPEnabled and (not isNPC or Settings.TargetNPC)

                if isTargetActive and isAlive and hrp and passTeamCheck then
                    local dist = (hrp.Position - camPos).Magnitude
                    local maxDist = Settings.ESPDist or 1000

                    if dist <= maxDist then
                        espTotalInRange = espTotalInRange + 1
                        local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                        -- Chams
                        if Settings.ESPChams and esp.Cham then
                            local col = ColorList[Settings.ChamsColor] or Color3.fromRGB(255, 0, 0)
                            esp.Cham.Adornee = char
                            esp.Cham.FillColor = col
                            esp.Cham.OutlineColor = col
                            esp.Cham.Enabled = true
                        elseif esp.Cham then
                            esp.Cham.Enabled = false
                        end

                        if onScreen and rootPos.Z > 0 then
                            espTotalOnScreen = espTotalOnScreen + 1
                            isVisibleNow = true

                            local headPos = Camera:WorldToViewportPoint(head and (head.Position + Vector3.new(0, 0.5, 0)) or (hrp.Position + Vector3.new(0, 2.5, 0)))
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2
                            local xPos = rootPos.X - (width / 2)
                            local yPos = headPos.Y

                            -- 2D Box
                            if Settings.ESPBox then
                                esp.BoxOutline.Size = Vector2.new(width, height)
                                esp.BoxOutline.Position = Vector2.new(xPos, yPos)
                                esp.BoxOutline.Visible = true

                                esp.Box.Size = Vector2.new(width, height)
                                esp.Box.Position = Vector2.new(xPos, yPos)
                                esp.Box.Color = ColorList[Settings.ChamsColor] or Color3.fromRGB(255, 255, 255)
                                esp.Box.Visible = true
                            end

                            -- Tên & Khoảng cách
                            local textString = ""
                            if Settings.ESPName then textString = targetName end
                            if Settings.ESPDistance then
                                textString = textString .. (textString ~= "" and " [" or "[") .. math.floor(dist) .. "m]"
                            end
                            if textString ~= "" then
                                esp.Name.Text = textString
                                esp.Name.Position = Vector2.new(rootPos.X, yPos - 16)
                                esp.Name.Color = Color3.fromRGB(255, 255, 255)
                                esp.Name.Visible = true
                            end

                            -- Vũ khí & Level
                            local infoText = ""
                            if Settings.ESPLevel and not isNPC then
                                local stats = target:FindFirstChild("leaderstats")
                                local lvl = stats and (stats:FindFirstChild("Level") or stats:FindFirstChild("Rank"))
                                if lvl then
                                    infoText = "Lv." .. tostring(lvl.Value)
                                else
                                    local attrLvl = char:GetAttribute("Level") or char:GetAttribute("Lv")
                                    if attrLvl then infoText = "Lv." .. tostring(attrLvl) end
                                end
                            elseif Settings.ESPLevel and isNPC then
                                local lvl = char:GetAttribute("Level") or char:GetAttribute("Lv")
                                if lvl then infoText = "Lv." .. tostring(lvl) end
                            end

                            if Settings.ESPWeapon then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    infoText = infoText .. (infoText ~= "" and " | " or "") .. tool.Name
                                end
                            end

                            if infoText ~= "" then
                                esp.Distance.Text = infoText
                                esp.Distance.Position = Vector2.new(rootPos.X, yPos + height + 2)
                                esp.Distance.Color = Color3.fromRGB(200, 200, 210)
                                esp.Distance.Visible = true
                            end

                            -- Tracers
                            if Settings.ESPLine then
                                esp.Tracer.From = Vector2.new(center.X, Camera.ViewportSize.Y)
                                esp.Tracer.To = Vector2.new(rootPos.X, yPos + height)
                                esp.Tracer.Color = ColorList[Settings.ChamsColor] or Color3.fromRGB(255, 255, 255)
                                esp.Tracer.Thickness = math.clamp(150 / math.max(dist, 1), 1, 4)
                                esp.Tracer.Visible = true
                            end

                            -- Health Bar
                            if Settings.ESPHealth then
                                local currentH = hum and hum.Health or (char:FindFirstChild("Health") and char:FindFirstChild("Health").Value) or maxH
                                local healthPct = math.clamp((tonumber(currentH) or maxH) / maxH, 0, 1)
                                local yOffset = height * healthPct

                                esp.HealthBarBg.Size = Vector2.new(4, height + 2)
                                esp.HealthBarBg.Position = Vector2.new(xPos - 7, yPos - 1)
                                esp.HealthBarBg.Visible = true

                                esp.HealthBar.Size = Vector2.new(2, yOffset)
                                esp.HealthBar.Position = Vector2.new(xPos - 6, yPos + (height - yOffset))
                                esp.HealthBar.Color = Color3.fromRGB(math.floor(255 * (1 - healthPct)), math.floor(255 * healthPct), 0)
                                esp.HealthBar.Visible = true
                            end

                            -- Skeleton
                            if Settings.ESPSkeleton then
                                local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                                local connections = isR15 and Const.R15_BONES or Const.R6_BONES
                                for i = 1, #connections do
                                    local boneDraw = esp.Skeleton[i]
                                    local conn = connections[i]
                                    if boneDraw and conn then
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

                                            if visA and visB and posA.Z > 0 and posB.Z > 0 then
                                                boneDraw.From = Vector2.new(posA.X, posA.Y)
                                                boneDraw.To = Vector2.new(posB.X, posB.Y)
                                                boneDraw.Visible = true
                                            else
                                                boneDraw.Visible = false
                                            end
                                        else
                                            boneDraw.Visible = false
                                        end
                                    end
                                end
                            end
                        else
                            -- Offscreen Arrows
                            if Settings.OffscreenArrows and (rootPos.Z <= 0 or not onScreen) then
                                local camCFrame = Camera.CFrame
                                local relVector = hrp.Position - camCFrame.Position
                                local forward = camCFrame.LookVector
                                local right = camCFrame.RightVector
                                local x = relVector:Dot(right)
                                local z = relVector:Dot(forward)
                                local angle = math.atan2(x, z)
                                local radius = 170
                                local tip = center + Vector2.new(math.sin(angle), -math.cos(angle)) * radius
                                local base = center + Vector2.new(math.sin(angle), -math.cos(angle)) * (radius - 16)
                                local perp = Vector2.new(-math.cos(angle), -math.sin(angle)) * 9
                                local arrCol = ColorList[Settings.ChamsColor] or Color3.fromRGB(255, 60, 60)

                                if esp.Arrow1 then
                                    esp.Arrow1.From = tip
                                    esp.Arrow1.To = base + perp
                                    esp.Arrow1.Color = arrCol
                                    esp.Arrow1.Visible = true
                                end
                                if esp.Arrow2 then
                                    esp.Arrow2.From = tip
                                    esp.Arrow2.To = base - perp
                                    esp.Arrow2.Color = arrCol
                                    esp.Arrow2.Visible = true
                                end
                                if esp.Arrow3 then
                                    esp.Arrow3.From = base + perp
                                    esp.Arrow3.To = base - perp
                                    esp.Arrow3.Color = arrCol
                                    esp.Arrow3.Visible = true
                                end
                            else
                                if esp.Arrow1 then esp.Arrow1.Visible = false end
                                if esp.Arrow2 then esp.Arrow2.Visible = false end
                                if esp.Arrow3 then esp.Arrow3.Visible = false end
                            end
                        end
                    end
                end
            end

            if not isVisibleNow then
                esp.BoxOutline.Visible = false
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBarBg.Visible = false
                esp.HealthBar.Visible = false
                esp.Tracer.Visible = false
                if esp.Arrow1 then esp.Arrow1.Visible = false end
                if esp.Arrow2 then esp.Arrow2.Visible = false end
                if esp.Arrow3 then esp.Arrow3.Visible = false end
                for _, bone in pairs(esp.Skeleton) do bone.Visible = false end
            end
        end

        -- Cập nhật bộ đếm ESP trên đỉnh màn hình (Top-Center HUD)
        if Shared.UI_Elements.ESPCounterBox then
            if Settings.ESPCount and Settings.ESPEnabled then
                Shared.UI_Elements.ESPCounterBox.Visible = true
                Shared.UI_Elements.ESPCounterLabel.Text = tostring(espTotalInRange)
            else
                Shared.UI_Elements.ESPCounterBox.Visible = false
            end
        end
    end
    ESP.UpdateESP = UpdateESP

    return ESP
end
