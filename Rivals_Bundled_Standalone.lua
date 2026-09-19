-- ============================================================
-- RIVALS BUNDLED STANDALONE (AUTO-GENERATED FROM MODULAR ARCHITECTURE)
-- ============================================================
local __MODULES = {}

-- [[ MODULE: Shared.lua ]]
__MODULES['Shared.lua'] = (function()
-- ============================================================
-- MODULAR RIVALS | MODULE 1: SHARED CORE, SERVICES & SETTINGS
-- Tạo Bởi An Nguyễn Đẹp Trai - Im Goned
-- ============================================================

local Shared = {}

if not table.clear then table.clear = function(t) for k in pairs(t) do t[k] = nil end end end
if not Vector3.zero then Vector3.zero = Vector3.new(0, 0, 0) end

-- Pre-cached native inputs
Shared.mouse1click_fn = (type(mouse1click) == "function" and mouse1click) or nil
Shared.VirtualInputManager = nil
pcall(function() Shared.VirtualInputManager = game:GetService("VirtualInputManager") end)

-- Mouse Movement Compatibility Helper (Cho Aimlock / Mouse Aimbot)
local mousemoverel_fn = mousemoverel or (Input and Input.MouseMoveRel) or function(x, y)
    if typeof(mouse_moverel) == "function" then
        mouse_moverel(x, y)
    end
end
Shared.mousemoverel = mousemoverel_fn

-- Core Services
Shared.CoreGui = game:GetService("CoreGui")
Shared.TweenService = game:GetService("TweenService")
Shared.Players = game:GetService("Players")
Shared.RunService = game:GetService("RunService")
Shared.UserInputService = game:GetService("UserInputService")
Shared.Workspace = game:GetService("Workspace")
Shared.Lighting = game:GetService("Lighting")
Shared.HttpService = game:GetService("HttpService")
Shared.ReplicatedStorage = game:GetService("ReplicatedStorage")
Shared.StarterGui = game:GetService("StarterGui")
Shared.TeleportService = game:GetService("TeleportService")
Shared.VirtualUser = game:GetService("VirtualUser")
Shared.CollectionService = game:GetService("CollectionService")

Shared.LocalPlayer = Shared.Players.LocalPlayer
Shared.Camera = Shared.Workspace.CurrentCamera
Shared.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Shared.Camera = Shared.Workspace.CurrentCamera
end)

Shared.UI_Elements = {}
Shared.isMenuConnected = false
Shared.SendNotification = nil

-- Registry cho theme + search + active-dot
Shared.ThemeObjects = { Panels = {}, Toggles = {}, SliderFills = {}, Dropbox = {} }
Shared.SearchIndex = {}
Shared.TabActiveKeys = {}

-- 3 bộ theme chuẩn gốc
Shared.ThemePresets = {
    Dark = {
        MainBg = Color3.fromRGB(18, 18, 20), PanelBg = Color3.fromRGB(30, 30, 34),
        Panel = Color3.fromRGB(22, 22, 25), Stroke = Color3.fromRGB(45, 45, 50),
        AccentOn = Color3.fromRGB(255, 255, 255), AccentOff = Color3.fromRGB(45, 45, 50)
    },
    Midnight = {
        MainBg = Color3.fromRGB(9, 14, 26), PanelBg = Color3.fromRGB(20, 30, 52),
        Panel = Color3.fromRGB(14, 20, 36), Stroke = Color3.fromRGB(45, 75, 140),
        AccentOn = Color3.fromRGB(90, 170, 255), AccentOff = Color3.fromRGB(28, 40, 66)
    },
    Violet = {
        MainBg = Color3.fromRGB(18, 12, 28), PanelBg = Color3.fromRGB(38, 26, 56),
        Panel = Color3.fromRGB(27, 18, 42), Stroke = Color3.fromRGB(95, 55, 145),
        AccentOn = Color3.fromRGB(205, 125, 255), AccentOff = Color3.fromRGB(48, 34, 70)
    }
}

Shared.Theme = {
    MainBg = Color3.fromRGB(18, 18, 20),
    PanelBg = Color3.fromRGB(30, 30, 34),
    TopBarText = Color3.fromRGB(180, 180, 180),
    TextWhite = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(120, 120, 120),
    AccentOn = Color3.fromRGB(255, 255, 255),
    AccentOff = Color3.fromRGB(45, 45, 50),
    KnobOn = Color3.fromRGB(18, 18, 20),
    KnobOff = Color3.fromRGB(180, 180, 180),
    DotGreen = Color3.fromRGB(0, 255, 0),
    DotRed = Color3.fromRGB(255, 50, 50),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold
}

-- Static Constant Tables
Shared.Const = {
    R15_BONES = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    },
    R6_BONES = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    },
    TEAM_ATTR_NAMES = {"Team", "team", "TeamName", "teamName"},
    SHIELD_ATTRIBUTES = {
        "SpawnShield", "Shield", "Invulnerable", "Safe", "Immune",
        "SpawnProtection", "Protected", "IsShielded", "SpawnImmunity",
        "Invincible", "SafeShield", "SpawnInvulnerable"
    },
    SAFE_PARTS = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    TELE_TYPES = {"Sau Lưng", "Trên Đầu", "Trái", "Phải"},
    BOT_TAGS = {"Entity", "NPCCharacter", "Dummy", "BotLookAt", "NPCAnimationPVPBot", "NPCPathfindingPVPBot", "NPCWeaponPVPBot"},
    STATIC_RAY_FILTER = {nil, nil},
    -- Tương thích thêm
    SkeletonPairsR15 = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    },
    SkeletonPairsR6 = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    },
    HitboxCandidateNames = {
        "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
        "LeftArm", "RightArm", "LeftLeg", "RightLeg",
        "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
        "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
        "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"
    },
    BotContainerNames = {
        "Dummies", "Bots", "NPCs", "Enemies", "Zombies", "Monsters",
        "AI", "Targets", "Spawns", "Units", "Minions", "Mobs", "Creatures",
        "BadGuys", "Guards", "Soldiers", "ShootingRange"
    }
}

-- LỚP ẨN DANH TÍNH (STEALTH LAYER)
Shared.RandomString = function(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local str = ""
    for _ = 1, length do
        local r = math.random(1, #chars)
        str = str .. string.sub(chars, r, r)
    end
    return str
end

Shared.IDS = {
    UI          = Shared.RandomString(12),
    ChamsFolder = Shared.RandomString(10),
    Folder      = Shared.RandomString(8),
    ConfigName  = "Rivals_Pro_Config.json",
    Watermark   = "SYS v" .. math.random(2, 9) .. "." .. math.random(0, 9) .. "." .. math.random(0, 9)
}

-- Lấy GUI cha an toàn nhất
Shared.GetSafeParent = function()
    local p = nil
    pcall(function()
        if gethui then p = gethui() end
    end)
    if not p then
        pcall(function()
            p = Shared.CoreGui:FindFirstChild("RobloxGui") or Shared.CoreGui
        end)
    end
    return p or Shared.CoreGui
end
Shared.parentGui = Shared.GetSafeParent()

Shared.ProtectInstance = function(inst)
    if not inst then return end
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(inst)
        elseif gethui then
            inst.Parent = gethui()
        end
    end)
    if syn and type(syn) == "table" and syn.secure_ui then
        pcall(function() syn.secure_ui(inst) end)
    end
    if protectui and type(protectui) == "function" then
        pcall(protectui, inst)
    end
end

-- CẤU HÌNH GỐC (SETTINGS)
Shared.Settings = {
    AimEnabled = false, AimHoldMode = false, AimSafe = false, AimDist = 1000,
    TargetPart = "Head", WallCheck = false, TeamCheck = true, TargetNPC = false, SafeShieldCheck = false,
    FOV = 170, FOVVisible = false, AimSnapline = false,
    AimSmoothness = 0.75, AimJitter = 0, ReactionDelay = 0,

    ProAimEnabled = false, ProAimHoldMode = false, ProAimFOV = 120,
    ProAimFOVVisible = false, ProAimSmoothness = 0.75, ProAimTargetPart = "Head",
    ProAimWallCheck = false, ProAimTeamCheck = true,
    ProAimHoldMouse = Enum.UserInputType.MouseButton2,
    ProAimSnapline = false, ProAimDist = 1000,
    ProAimJitter = 0, ProAimReaction = 0,
    AutoFire = false, AutoFireHoldM2 = false, AutoFireWallCheck = false, AutoFireDelay = 0, AutoFireFOV = 100,
    HitboxExpander = false, HitboxPart = "Head", HitboxSize = 10, HitboxInvisible = false,
    NoRecoil = false, NoRecoilStrength = 1,

    ESPEnabled = false, ESPTeamCheck = true, ESPDist = 1000,
    ESPBox = false, ESPName = false, ESPDistance = false, ESPHealth = false,
    ESPLine = false, ESPSkeleton = false,
    ESPChams = false, ChamsColor = "Red",
    ESPWeapon = false, ESPLevel = false, AimWarning = false, OffscreenArrows = false,
    ESPCount = true,

    Crosshair = false, CrosshairStyle = "Cross", CrosshairSize = 10,
    CrosshairThickness = 1.5, CrosshairColor = "Green",

    SpeedHack = false, WalkSpeed = 30,
    JumpHack = false, JumpPower = 100,
    InfJump = false, Fly = false, FlySpeed = 50, Noclip = false,
    GravityHack = false, Gravity = 50,
    SlowFall = false, SlowFallSpeed = 5,
    AutoTeleport = false, AutoTeleportDistance = 3, TeleportRange = 1000, AutoTeleportPosition = "Sau Lưng",
    AutoTeleportCameraLock = true, AutoTeleportReturn = true,
    SpeedTele = false, SpeedTeleSpeed = 50,
    UndergroundNoclip = false, UndergroundDistance = 5,
    SpinBot = false, SpinSpeed = 50,

    OptimShadows = false, OptimTextures = false, OptimFog = false,

    AntiCheatBypass = true, BypassACMove = true,
    HeartbeatReply = true, AntiScreenshot = true,

    ToggleKeybind = Enum.KeyCode.Insert,
    Spectating = false, SpectatePlayer = "",
    ThemeName = "Dark",
    AimHotkey = Enum.KeyCode.N,
    AutoFireHotkey = Enum.KeyCode.M,
    NoRecoilHotkey = Enum.KeyCode.F1,
    AutoTeleportHotkey = Enum.KeyCode.E,
    SpeedTeleHotkey = Enum.KeyCode.T,
    UndergroundHotkey = Enum.KeyCode.Q
}

Shared.GetActivePreset = function()
    Shared.ESPTable = {}
Shared.NPCCache = {}
Shared.undergroundSurfaceY = nil
Shared.originalTeleportCFrame = nil
Shared.originalSpeedTeleCFrame = nil

return Shared.ThemePresets[Shared.Settings.ThemeName] or Shared.ThemePresets.Dark
end

Shared.ColorList = {
    ["White"] = Color3.fromRGB(255, 255, 255), ["Red"] = Color3.fromRGB(255, 50, 50),
    ["Green"] = Color3.fromRGB(0, 255, 0), ["Blue"] = Color3.fromRGB(50, 150, 255),
    ["Yellow"] = Color3.fromRGB(255, 255, 0), ["Pink"] = Color3.fromRGB(255, 105, 180),
    ["Black"] = Color3.fromRGB(0, 0, 0)
}

-- Raycast Params dùng lại cho Wall Check
Shared.WallCheckRayParams = RaycastParams.new()
Shared.WallCheckRayParams.FilterType = Enum.RaycastFilterType.Exclude
Shared.WallCheckRayParams.IgnoreWater = true

return Shared

end)()

-- [[ MODULE: Shield.lua ]]
__MODULES['Shield.lua'] = (function()
-- ============================================================
-- MODULAR RIVALS | MODULE 2: SHIELD & ANTI-CHEAT BYPASS
-- ============================================================
return function(Shared)
    local Shield = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Workspace = Shared.Workspace
    local RunService = Shared.RunService
    local ReplicatedStorage = Shared.ReplicatedStorage

-- KHIÊN CHỐNG BAN (SHIELD CORE)
-- ============================================================
local Shield = {
    Blocks = 0,
    ShieldActive = false
}

local BLOCK_REMOTES = {
    "report", "ban", "kick", "punish", "crash", "log",
    "anticheat", "adonis", "hdadmin", "moderator", "admin",
    "detect", "spectate", "teleport", "tase", "exploit", "cheat"
}

local HEARTBEAT_REMOTES = {
    "heartbeat", "ping", "accheck", "verif", "security",
    "authenticate", "validation", "checkclient", "response"
}

local function ClassifyRemote(name)
    if not name then return nil end
    local n = string.lower(tostring(name))
    for i = 1, #BLOCK_REMOTES do
        if string.find(n, BLOCK_REMOTES[i], 1, true) then return "block" end
    end
    for i = 1, #HEARTBEAT_REMOTES do
        if string.find(n, HEARTBEAT_REMOTES[i], 1, true) then return "heartbeat" end
    end
    return nil
end

local hasCheckcaller = checkcaller ~= nil
local function IsExternal()
    if not hasCheckcaller then return true end
    local ok, val = pcall(checkcaller)
    if ok then return not val end
    return true
end

-- Hook Metatable: chặn gói tin độc, trả lời heartbeat, spoof thuộc tính (Tối ưu hóa cực độ, 0 closure rác)
local function InitShield()
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return end

    local hasNamecall = pcall(function() return mt.__namecall end)
    local hasIndex = pcall(function() return mt.__index end)
    if not hasNamecall and not hasIndex then return end

    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index

    if setreadonly then pcall(setreadonly, mt, false) end

    local useCClosure = newcclosure ~= nil

    if hasNamecall then
        mt.__namecall = useCClosure and newcclosure(function(self, ...)
            if not IsExternal() then
                if oldNamecall then return oldNamecall(self, ...) end
                return self
            end

            local method = nil
            if getnamecallmethod then
                local ok2, m = pcall(getnamecallmethod)
                if ok2 then method = m end
            end

            if Settings.AntiCheatBypass and (method == "FireServer" or method == "InvokeServer") then
                if typeof(self) == "Instance" then
                    local rname = self.Name
                    if rname then
                        local class = ClassifyRemote(rname)
                        if class == "block" then
                            Shield.Blocks = Shield.Blocks + 1
                            if method == "InvokeServer" then return 0 else return end
                        elseif class == "heartbeat" then
                            if method == "InvokeServer" then return true else return end
                        end
                    end
                end
            end

            if oldNamecall then return oldNamecall(self, ...) end
            return self
        end) or function(self, ...)
            if not IsExternal() or not Settings.AntiCheatBypass then
                if oldNamecall then return oldNamecall(self, ...) end
                return self
            end
            if typeof(self) == "Instance" then
                local rname = self.Name
                if rname then
                    local class = ClassifyRemote(rname)
                    if class == "block" then
                        Shield.Blocks = Shield.Blocks + 1
                        return
                    end
                end
            end
            if oldNamecall then return oldNamecall(self, ...) end
            return self
        end
    end

    if hasIndex then
        mt.__index = useCClosure and newcclosure(function(self, idx)
            if IsExternal() and Settings.AntiCheatBypass and typeof(self) == "Instance" then
                if self:IsA("Humanoid") then
                    if idx == "WalkSpeed" then return 16 end
                    if idx == "JumpPower" then return 50 end
                elseif self:IsA("BasePart") and self.Name == "HumanoidRootPart" then
                    if idx == "Velocity" or idx == "AssemblyLinearVelocity" then
                        return Vector3.zero
                    end
                end
            end
            if oldIndex then return oldIndex(self, idx) end
            return nil
        end) or function(self, idx)
            if oldIndex then return oldIndex(self, idx) end
            return nil
        end
    end

    if setreadonly then pcall(setreadonly, mt, true) end
    Shield.ShieldActive = true
end



    Shield.InitShield = InitShield
    Shield.CheckAndBypassCharacterAC = CheckAndBypassCharacterAC

    return Shield
end

end)()

-- [[ MODULE: Targeting.lua ]]
__MODULES['Targeting.lua'] = (function()
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

end)()

-- [[ MODULE: Player.lua ]]
__MODULES['Player.lua'] = (function()
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
    if Settings.Noclip or (Settings.UndergroundNoclip and Shared.undergroundSurfaceY) or Settings.SpeedTele then
        for i = 1, #noClipParts do
            local part = noClipParts[i]
            if part and part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end
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
        if not Shared.originalTeleportCFrame then
            Shared.originalTeleportCFrame = myHrp.CFrame
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
        elseif Settings.AutoTeleportReturn and Shared.originalTeleportCFrame then
            -- Không còn kẻ địch nào (hoặc toàn bộ đang có khiên an toàn) -> Tự tele về vị trí ban đầu
            myHrp.CFrame = Shared.originalTeleportCFrame
            myHrp.Velocity = Vector3.zero
        end
    end

    -- Speed Tele bám địch (Tốc độ Speed + Noclip di chuyển đến kẻ địch - Tối ưu hóa Squared Distance)
    if Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character.HumanoidRootPart
        if not Shared.originalSpeedTeleCFrame then
            Shared.originalSpeedTeleCFrame = myHrp.CFrame
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
            elseif Settings.UndergroundNoclip and Shared.undergroundSurfaceY then
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

end)()

-- [[ MODULE: Aim.lua ]]
__MODULES['Aim.lua'] = (function()
-- ============================================================
-- MODULAR RIVALS | MODULE 5: AIMBOT, PRO AIM, AUTOFIRE & VISUALS
-- ============================================================
return function(Shared, Targeting)
    local Aim = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local UserInputService = Shared.UserInputService
    local Theme = Shared.Theme
    local mousemoverel = Shared.mousemoverel
    local mouse1click_fn = Shared.mouse1click_fn
    local VirtualInputManager = Shared.VirtualInputManager
    local ColorList = Shared.ColorList
    local getClosestPlayer = Targeting.getClosestPlayer
    local getTargetPart = Targeting.getTargetPart
    local getClosestPlayerToCursor = Targeting.getClosestPlayerToCursor
    local isAutoFireVisible = Targeting.isAutoFireVisible
    local forEachEnemy = Targeting.forEachEnemy
    local isSameTeam = Targeting.isSameTeam
    local getProAimTargetCached = Targeting.getProAimTargetCached

-- ============================================================
-- DRAWING CORE
-- ============================================================
local FOVring = Drawing.new("Circle")
FOVring.Visible = false; FOVring.Thickness = 1.5; FOVring.Color = Theme.AccentOn
FOVring.Filled = false; FOVring.Transparency = 1
FOVring.Radius = Settings.FOV; FOVring.Position = Camera.ViewportSize / 2
Shared.FOVring = FOVring

local AimSnaplineDraw = Drawing.new("Line")
AimSnaplineDraw.Visible = false; AimSnaplineDraw.Thickness = 1.5
AimSnaplineDraw.Color = Color3.fromRGB(255, 50, 50); AimSnaplineDraw.Transparency = 1

local CrosshairDraws = {
    L = Drawing.new("Line"), R = Drawing.new("Line"),
    T = Drawing.new("Line"), B = Drawing.new("Line"),
    Circle = Drawing.new("Circle"), Dot = Drawing.new("Circle")
}

local AimWarnText = Drawing.new("Text")
AimWarnText.Visible = false
AimWarnText.Center = true
AimWarnText.Outline = true
AimWarnText.Size = 22

local ESPTable = {}



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

    local function AddJitter(cf, amount)
        if amount <= 0 then return cf end
        local rX = (math.random() - 0.5) * 2 * math.rad(amount)
        local rY = (math.random() - 0.5) * 2 * math.rad(amount)
        return cf * CFrame.Angles(rX, rY, 0)
    end

    local function UpdateAim(step, center)
        local now = tick()

        if now - cachedClosestValid > 0.05 then
        cachedClosest = getClosestPlayer()
        cachedClosestValid = now
    end
    local closestTarget = cachedClosest

    -- 1. FOV & SNAPLINE (1 VÒNG TRÒN DUY NHẤT ĐỒNG BỘ - CHỐNG PROPERTY THRASHING)
    if FOVring.Visible ~= Settings.FOVVisible then
        FOVring.Visible = Settings.FOVVisible
    end
    if Settings.FOVVisible then
        local mousePos = UserInputService:GetMouseLocation()
        FOVring.Position = mousePos
        if FOVring.Radius ~= Settings.FOV then
            FOVring.Radius = Settings.FOV
        end
        local hasTarget = (Settings.AimEnabled and closestTarget) or (Settings.ProAimEnabled and (ProAimLockedTarget ~= nil))
        local targetColor = hasTarget and Color3.fromRGB(255, 50, 50) or Theme.AccentOn
        if FOVring.Color ~= targetColor then
            FOVring.Color = targetColor
        end
    end

    local snapTarget = nil
    if Settings.FOVVisible or Settings.AimSnapline then
        if Settings.AimEnabled and closestTarget then
            local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
            if targetChar then
                local tPart = getTargetPart(targetChar)
                if tPart then snapTarget = tPart end
            end
        elseif Settings.ProAimEnabled and ProAimLockedTarget then
            snapTarget = ProAimLockedTarget
        end
    end

    if snapTarget then
        local targetPos, onScreen = Camera:WorldToViewportPoint(snapTarget.Position)
        if onScreen then
            AimSnaplineDraw.From = center
            AimSnaplineDraw.To = Vector2.new(targetPos.X, targetPos.Y)
            if not AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = true end
        else
            if AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = false end
        end
    else
        if AimSnaplineDraw.Visible then AimSnaplineDraw.Visible = false end
    end

    -- 2. AIM HOLD (Hard Lock + smooth + jitter)
    if isAiming and Settings.AimEnabled and Settings.AimHoldMode then
        local target = closestTarget
        if target and target.Character then
            local tPart = getTargetPart(target.Character)
            if tPart then
                local desired = CFrame.new(Camera.CFrame.Position, tPart.Position)
                desired = AddJitter(desired, Settings.AimJitter)
                if Settings.AimSmoothness >= 1 then
                    Camera.CFrame = desired
                else
                    local t = 1 - math.pow(1 - math.clamp(Settings.AimSmoothness, 0, 1), step * 60)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, t)
                end
            end
        end
    end

    -- 2.5 PRO AIM (Aimlock using mousemoverel & Smoothness - Tối ưu hóa 0 ép chuỗi/closure)
    local isHolding = isProAimHolding
    if not isHolding and typeof(Settings.ProAimHoldMouse) == "EnumItem" then
        local bind = Settings.ProAimHoldMouse
        if bind.EnumType == Enum.UserInputType then
            local ok, pressed = pcall(UserInputService.IsMouseButtonPressed, UserInputService, bind)
            if ok and pressed then isHolding = true end
        elseif bind.EnumType == Enum.KeyCode then
            local ok, pressed = pcall(UserInputService.IsKeyDown, UserInputService, bind)
            if ok and pressed then isHolding = true end
        end
    end

    if Settings.ProAimEnabled and isHolding then
        local mousePos = UserInputService:GetMouseLocation()
        local targetSource, targetPart, targetScreenPos = getClosestPlayerToCursor(mousePos)

        if targetPart and targetScreenPos then
            ProAimLockedTarget = targetPart
            local smoothVal = math.clamp(Settings.ProAimSmoothness or 0.75, 0.01, 1)
            local xOffset = Settings.ProAimXOffset or 0
            local yOffset = Settings.ProAimYOffset or 0
            local deltaX = (targetScreenPos.X - mousePos.X + xOffset) * smoothVal
            local deltaY = (targetScreenPos.Y - mousePos.Y + yOffset) * smoothVal
            
            mousemoverel(deltaX, deltaY)
        else
            ProAimLockedTarget = nil
        end
    else
        ProAimLockedTarget = nil
    end

    -- 2.6 AUTO FIRE & AUTO FIRE (HOLD M2) + WALL CHECK
    local shouldAutoFire = Settings.AutoFire or (Settings.AutoFireHoldM2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
    if shouldAutoFire then
        local targetPart = ProAimLockedTarget
        if not targetPart then
            if closestTarget then
                local targetChar = closestTarget:IsA("Player") and closestTarget.Character or closestTarget
                if targetChar then
                    targetPart = getTargetPart(targetChar)
                end
            end
        end
        if not targetPart then
            targetPart = getProAimTargetCached()
        end

        if targetPart then
            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local maxFov = Settings.FOV or 100
                local dx = pos.X - center.X
                local dy = pos.Y - center.Y
                local delayTime = math.max(Settings.AutoFireDelay or 0, 0.05)
                if (dx * dx + dy * dy) <= (maxFov * maxFov) and (now - lastShotTime) >= delayTime then
                    if isAutoFireVisible(targetPart) then
                        lastShotTime = now
                        FireShot()
                    end
                end
            end
        end
    end

    -- 2.7 NO RECOIL (MOUSE AIMLOCK-BASED RECOIL STABILIZATION)
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
                    mousemoverel(deltaX * s, deltaY * s)
                end
            else
                noRecoilTargetPoint = cam.Position + cam.LookVector * 1000
            end
        end
    else
        noRecoilTargetPoint = nil
    end

    -- 4. SPECTATING
    if Settings.Spectating and Settings.SpectatePlayer ~= "" then
        local targetPlayer = Players:FindFirstChild(Settings.SpectatePlayer)
        if targetPlayer and targetPlayer.Character
            and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end

    -- 5. CROSSHAIR (Tối ưu hóa: chỉ render khi bật, không gọi C++ ẩn vô ích)
    if Settings.Crosshair then
        local size, thick = Settings.CrosshairSize, Settings.CrosshairThickness
        local color = ColorList[Settings.CrosshairColor] or Color3.fromRGB(0, 255, 0)
        for _, draw in pairs(CrosshairDraws) do
            draw.Color = color
            draw.Thickness = thick
        end

        if Settings.CrosshairStyle == "Cross" or Settings.CrosshairStyle == "Cross + Dot" then
            CrosshairDraws.L.Visible = true
            CrosshairDraws.L.From = Vector2.new(center.X - size, center.Y)
            CrosshairDraws.L.To = Vector2.new(center.X - 3, center.Y)
            CrosshairDraws.R.Visible = true
            CrosshairDraws.R.From = Vector2.new(center.X + 3, center.Y)
            CrosshairDraws.R.To = Vector2.new(center.X + size, center.Y)
            CrosshairDraws.T.Visible = true
            CrosshairDraws.T.From = Vector2.new(center.X, center.Y - size)
            CrosshairDraws.T.To = Vector2.new(center.X, center.Y - 3)
            CrosshairDraws.B.Visible = true
            CrosshairDraws.B.From = Vector2.new(center.X, center.Y + 3)
            CrosshairDraws.B.To = Vector2.new(center.X, center.Y + size)
        end
        if Settings.CrosshairStyle == "X" then
            local offset = size * 0.707
            CrosshairDraws.L.Visible = true
            CrosshairDraws.L.From = Vector2.new(center.X - offset, center.Y - offset)
            CrosshairDraws.L.To = Vector2.new(center.X - 2, center.Y - 2)
            CrosshairDraws.R.Visible = true
            CrosshairDraws.R.From = Vector2.new(center.X + offset, center.Y + offset)
            CrosshairDraws.R.To = Vector2.new(center.X + 2, center.Y + 2)
            CrosshairDraws.T.Visible = true
            CrosshairDraws.T.From = Vector2.new(center.X + offset, center.Y - offset)
            CrosshairDraws.T.To = Vector2.new(center.X + 2, center.Y - 2)
            CrosshairDraws.B.Visible = true
            CrosshairDraws.B.From = Vector2.new(center.X - offset, center.Y + offset)
            CrosshairDraws.B.To = Vector2.new(center.X - 2, center.Y + 2)
        end
        if Settings.CrosshairStyle == "Circle" then
            CrosshairDraws.Circle.Visible = true
            CrosshairDraws.Circle.Radius = size
            CrosshairDraws.Circle.Position = center
            CrosshairDraws.Circle.Filled = false
        end
        if Settings.CrosshairStyle == "Dot" or Settings.CrosshairStyle == "Cross + Dot" then
            CrosshairDraws.Dot.Visible = true
            CrosshairDraws.Dot.Radius = thick
            CrosshairDraws.Dot.Position = center
            CrosshairDraws.Dot.Filled = true
        end
    else
        for _, draw in pairs(CrosshairDraws) do
            if draw.Visible then draw.Visible = false end
        end
    end

    -- 5.5 CẢNH BÁO BỊ NGẮM (Tối ưu hóa: Giữ bộ đệm cachedWarnTarget, triệt tiêu lỗi chớp nháy)
    if Settings.AimWarning then
        if now - lastWarnScan > 0.12 then
            lastWarnScan = now
            cachedWarnTarget = nil
            local myChar = LocalPlayer.Character
            local myHead = myChar and myChar:FindFirstChild("Head")
            if myHead then
                local myHeadPos = myHead.Position
                local maxDist = Settings.AimDist or 1000
                local maxDistSq = maxDist * maxDist
                forEachEnemy(function(char, source)
                    local eHead = char:FindFirstChild("Head")
                    if eHead then
                        local diff = eHead.Position - myHeadPos
                        local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                        if distSq <= maxDistSq then
                            local dirToMe = (myHeadPos - eHead.Position).Unit
                            local dot = eHead.CFrame.LookVector:Dot(dirToMe)
                            if dot > 0.97 and char:FindFirstChildOfClass("Tool") then
                                cachedWarnTarget = source
                            end
                        end
                    end
                end)
            end
        end
        if cachedWarnTarget then
            local flash = (math.floor(now * 4) % 2 == 0)
            local nameStr = cachedWarnTarget:IsA("Player") and (cachedWarnTarget.DisplayName or cachedWarnTarget.Name) or (cachedWarnTarget.Name .. " [BOT]")
            AimWarnText.Visible = true
            AimWarnText.Text = "⚠ BỊ NGẮM: " .. nameStr .. " ⚠"
            AimWarnText.Color = flash and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 0)
            AimWarnText.Position = Vector2.new(center.X, center.Y - 120)
        else
            if AimWarnText.Visible then AimWarnText.Visible = false end
        end
    else
        if AimWarnText.Visible then AimWarnText.Visible = false end
    end

    end

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
                local target = getClosestPlayer()
                local targetChar = target and (target:IsA("Player") and target.Character or target)
                if targetChar then
                    local tPart = getTargetPart(targetChar)
                    if tPart then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, tPart.Position)
                        Camera.CFrame = AddJitter(targetCFrame, Settings.AimJitter)
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

    Aim.FOVring = FOVring
    Aim.AimSnaplineDraw = AimSnaplineDraw
    Aim.CrosshairDraws = CrosshairDraws
    Aim.AimWarnText = AimWarnText
    Aim.UpdateAim = UpdateAim

    return Aim
end

end)()

-- [[ MODULE: ESP.lua ]]
__MODULES['ESP.lua'] = (function()
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

    esp.ArrowLines = {}
    for i = 1, 7 do
        local l = Drawing.new("Line")
        l.Thickness = 3.5
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
        table.clear(boneScreenCache)
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
                                esp.Info.Position = Vector2.new(rootPos.X, headPos.Y - 32)
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

                                -- 1. Mũi tên tam giác trắng đặc bằng 7 đường Line xếp lớp (100% tương thích mọi executor)
                                if esp.ArrowLines then
                                    for i = 1, 7 do
                                        local t = (i - 1) / 6
                                        local currentCenter = base:Lerp(tip, t)
                                        local currentWidth = sideWidth * (1 - t)
                                        local l = esp.ArrowLines[i]
                                        if l then
                                            l.From = currentCenter + perp * currentWidth
                                            l.To = currentCenter - perp * currentWidth
                                            if not l.Visible then l.Visible = true end
                                        end
                                    end
                                end

                                -- 2. Tên kẻ địch (Tương ứng với ESP Name)
                                if Settings.ESPName and esp.ArrowName then
                                    if esp.ArrowName.Text ~= targetName then
                                        esp.ArrowName.Text = targetName
                                    end
                                    esp.ArrowName.Position = Vector2.new(arrowCenter.X, arrowCenter.Y - 26)
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
                                    esp.ArrowDist.Position = Vector2.new(arrowCenter.X, arrowCenter.Y + 14)
                                    if not esp.ArrowDist.Visible then esp.ArrowDist.Visible = true end
                                else
                                    if esp.ArrowDist and esp.ArrowDist.Visible then esp.ArrowDist.Visible = false end
                                end

                                -- 4. Thanh máu dọc (Tương ứng với ESP Health)
                                if Settings.ESPHealth and esp.ArrowHealth and esp.ArrowHealthBg then
                                    local barX = arrowCenter.X + (sideWidth + 8)
                                    local barTop = arrowCenter.Y - 14
                                    local barBottom = arrowCenter.Y + 14
                                    local barHeight = 28

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

end)()

-- [[ MODULE: UI.lua ]]
__MODULES['UI.lua'] = (function()
-- ============================================================
-- MODULAR RIVALS | MODULE 7: USER INTERFACE, TABS & CONTROLS
-- ============================================================
return function(Shared, Shield, Targeting, ESP, Aim, Player)
    local UI = {}

    local Settings = Shared.Settings
    local LocalPlayer = Shared.LocalPlayer
    local Players = Shared.Players
    local Camera = Shared.Camera
    local TweenService = Shared.TweenService
    local UserInputService = Shared.UserInputService
    local HttpService = Shared.HttpService
    local CoreGui = Shared.CoreGui
    local Workspace = Shared.Workspace
    local Lighting = Shared.Lighting
    local TeleportService = Shared.TeleportService
    local RandomString = Shared.RandomString
    local isMenuConnected = true
    local SendNotification = nil
    local GetActivePreset = Shared.GetActivePreset
    local Theme = Shared.Theme
    local ThemePresets = Shared.ThemePresets
    local MainFrame = nil
    local MainStroke = nil
    local FOVring = (Aim and Aim.FOVring) or Shared.FOVring
    local ThemeObjects = Shared.ThemeObjects
    local SearchIndex = Shared.SearchIndex
    local TabActiveKeys = Shared.TabActiveKeys
    local UI_Elements = Shared.UI_Elements
    local IDS = Shared.IDS
    local parentGui = Shared.parentGui
    local ProtectInstance = Shared.ProtectInstance
    local CheckAndBypassCharacterAC = Shield.CheckAndBypassCharacterAC
    local originalHitboxes = Player.originalHitboxes
    local ResetHitboxes = Player.ResetHitboxes

-- UI CHÍNH
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = IDS.UI
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui
ProtectInstance(ScreenGui)

MainFrame = Instance.new("Frame")
MainFrame.Name = RandomString(8)
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

do local c = Instance.new("UICorner", MainFrame); c.CornerRadius = UDim.new(0, 10) end

-- ============================================================
-- TOP-CENTER ESP TARGET COUNTER (KHUNG ĐEN VUÔNG - SỐ PHÓNG TO)
-- ============================================================
local ESPCounterBox = Instance.new("Frame")
ESPCounterBox.Name = "ESPCounterBox"
ESPCounterBox.AnchorPoint = Vector2.new(0.5, 0)
ESPCounterBox.Position = UDim2.new(0.5, 0, 0, 15)
ESPCounterBox.Size = UDim2.new(0, 60, 0, 56)
ESPCounterBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ESPCounterBox.BackgroundTransparency = 0.15
ESPCounterBox.BorderSizePixel = 0
ESPCounterBox.Visible = false
ESPCounterBox.Parent = ScreenGui
Instance.new("UICorner", ESPCounterBox).CornerRadius = UDim.new(0, 8)

do local s = Instance.new("UIStroke", ESPCounterBox); s.Color = Color3.fromRGB(50, 50, 55); s.Thickness = 1.5; s.Transparency = 0.3 end

local ESPCounterLabel = Instance.new("TextLabel")
ESPCounterLabel.Name = "ESPCounterLabel"
ESPCounterLabel.Size = UDim2.new(1, 0, 1, 0)
ESPCounterLabel.Position = UDim2.new(0, 0, 0, 0)
ESPCounterLabel.BackgroundTransparency = 1
ESPCounterLabel.BorderSizePixel = 0
ESPCounterLabel.Text = "0"
ESPCounterLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
ESPCounterLabel.Font = Enum.Font.GothamBold
ESPCounterLabel.TextSize = 36
ESPCounterLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ESPCounterLabel.TextStrokeTransparency = 0.4
ESPCounterLabel.TextXAlignment = Enum.TextXAlignment.Center
ESPCounterLabel.TextYAlignment = Enum.TextYAlignment.Center
ESPCounterLabel.Parent = ESPCounterBox

-- Watermark
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 300, 0, 20)
WatermarkFrame.Position = UDim2.new(1, -310, 1, -30)
WatermarkFrame.BackgroundTransparency = 1
WatermarkFrame.Parent = ScreenGui

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 1, 0)
Watermark.BackgroundTransparency = 1
Watermark.RichText = true
Watermark.Text = "✨ ĐẶC QUYỀN ✨ " .. IDS.Watermark .. " | <font color=\"#FFD700\">An Nguyễn Studio</font>"
Watermark.TextColor3 = Color3.fromRGB(255, 215, 0)
Watermark.Font = Theme.FontBold
Watermark.TextSize = 14
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.TextStrokeTransparency = 0.5
Watermark.Parent = WatermarkFrame

local function UpdateWatermarkColor(color)
    pcall(function() Watermark.TextColor3 = color end)
end

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Name = RandomString(6)
NotifyFrame.Size = UDim2.new(0, 250, 1, -50)
NotifyFrame.Position = UDim2.new(1, -260, 0, 10)
NotifyFrame.BackgroundTransparency = 1
NotifyFrame.Parent = ScreenGui

do local l = Instance.new("UIListLayout", NotifyFrame); l.SortOrder = Enum.SortOrder.LayoutOrder; l.VerticalAlignment = Enum.VerticalAlignment.Bottom; l.Padding = UDim.new(0, 5) end

-- Tooltip theo chuột
local Tooltip = Instance.new("TextLabel")
Tooltip.Text = ""
Tooltip.Size = UDim2.new(0, 190, 0, 26)
Tooltip.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.TextColor3 = Color3.fromRGB(230, 230, 230)
Tooltip.Font = Enum.Font.Gotham
Tooltip.TextSize = 11
Tooltip.TextXAlignment = Enum.TextXAlignment.Center
Tooltip.Visible = false
Tooltip.ZIndex = 50
Tooltip.Parent = ScreenGui
Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 6)

local function ShowTooltip(text)
    -- Disabled hover tooltip to prevent stray text artifacts on screen
    if Tooltip then Tooltip.Visible = false end
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and Tooltip.Visible then
        local pos = UserInputService:GetMouseLocation()
        Tooltip.Position = UDim2.new(0, pos.X + 14, 0, pos.Y + 14)
    end
end)

SendNotification = function(title, text)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Theme.PanelBg
    Notif.BackgroundTransparency = 1
    Notif.Parent = NotifyFrame

    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = Color3.fromRGB(45, 45, 50)
    Stroke.Transparency = 1

    local Title = Instance.new("TextLabel", Notif)
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.TextWhite
    Title.TextTransparency = 1
    Title.Font = Theme.FontBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Notif)
    Desc.Size = UDim2.new(1, -20, 0, 20)
    Desc.Position = UDim2.new(0, 10, 0, 30)
    Desc.BackgroundTransparency = 1
    Desc.Text = text
    Desc.TextColor3 = Theme.TextDark
    Desc.TextTransparency = 1
    Desc.Font = Theme.Font
    Desc.TextSize = 12
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(3, function()
        TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(Desc, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        Notif:Destroy()
    end)
end

local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(WatermarkFrame, WatermarkFrame)

-- ============================================================
-- TOP BAR
-- ============================================================
local TopBar = Instance.new("Frame")
TopBar.Name = RandomString(6)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame
MakeDraggable(TopBar, MainFrame)

do local l = Instance.new("Frame", TopBar); l.Size = UDim2.new(1, 0, 0, 1); l.Position = UDim2.new(0, 0, 1, -1); l.BackgroundColor3 = Color3.fromRGB(35, 35, 40); l.BorderSizePixel = 0 end

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 400, 1, 0)
StatusText.Position = UDim2.new(0, 15, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.RichText = true
StatusText.Text = "<font color=\"#ffffff\">● Rivals Menu</font>   <font color=\"#666677\">/</font>   <font color=\"#aaaaaa\">Main</font>"
StatusText.TextColor3 = Theme.TopBarText
StatusText.Font = Theme.Font
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Visible = true
StatusText.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextDark
CloseBtn.Font = Theme.Font
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- SIDEBAR & TABS
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 50, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundTransparency = 1
Sidebar.Visible = true
Sidebar.Parent = MainFrame

do local l = Instance.new("Frame", Sidebar); l.Size = UDim2.new(0, 1, 1, 0); l.Position = UDim2.new(1, -1, 0, 0); l.BackgroundColor3 = Color3.fromRGB(35, 35, 40); l.BorderSizePixel = 0 end

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -60, 1, -50)
ContentArea.Position = UDim2.new(0, 50, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.Visible = true
ContentArea.Parent = MainFrame

-- [ĐÃ BỎ CHECK KEY VÀ SET PROSERS THEO YÊU CẦU: MENU TỰ ĐỘNG MỞ TRỰC TIẾP]
task.spawn(function()
    task.wait(0.5)
    if SendNotification then
        SendNotification("System", "Rivals Pro Menu đã kích hoạt thành công!")
    end
end)

local Tabs = {}
local SidebarButtons = {}
local activeTab = nil

-- Chấm trạng thái trên icon tab: sáng khi tab có feature đang bật
local function UpdateTabDots()
    for tabName, _ in pairs(Tabs) do
        local anyOn = false
        for key, _ in pairs(TabActiveKeys[tabName] or {}) do
            if Settings[key] then
                anyOn = true
                break
            end
        end
        local btn = SidebarButtons[tabName]
        if btn and btn.Indicator then
            btn.Indicator.Visible = anyOn
        end
    end
end

local function CreateSidebarIcon(tabName, iconChar, yPos)
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentArea
    Tabs[tabName] = TabContent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 30, 0, 30)
    Btn.Position = UDim2.new(0.5, -15, 0, yPos)
    Btn.BackgroundTransparency = 1
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = ""
    Btn.Parent = Sidebar
    SidebarButtons[tabName] = Btn
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local Icon
    if iconChar:match("rbxasset") then
        Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 16, 0, 16)
        Icon.Position = UDim2.new(0.5, -8, 0.5, -8)
        Icon.BackgroundTransparency = 1
        Icon.Image = iconChar
        Icon.ImageColor3 = Theme.TextDark
        Icon.Parent = Btn
    else
        Icon = Instance.new("TextLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.BackgroundTransparency = 1
        Icon.Text = iconChar
        Icon.TextColor3 = Theme.TextDark
        Icon.Font = Enum.Font.Gotham
        Icon.TextSize = 18
        Icon.Parent = Btn
    end

    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0, 16)
    Indicator.Position = UDim2.new(0, -10, 0.5, -8)
    Indicator.BackgroundColor3 = Theme.DotGreen
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = Btn
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        if activeTab == tabName then return end
        if activeTab then
            Tabs[activeTab].Visible = false
            SidebarButtons[activeTab].BackgroundTransparency = 1
            local oldIcon = SidebarButtons[activeTab]:FindFirstChild("Icon")
            if oldIcon then
                if oldIcon:IsA("ImageLabel") then
                    oldIcon.ImageColor3 = Theme.TextDark
                else
                    oldIcon.TextColor3 = Theme.TextDark
                end
            end
            SidebarButtons[activeTab].Indicator.Visible = false
        end
        activeTab = tabName
        Tabs[activeTab].Visible = true
        SidebarButtons[activeTab].BackgroundTransparency = 0.9
        local newIcon = SidebarButtons[activeTab]:FindFirstChild("Icon")
        if newIcon then
            if newIcon:IsA("ImageLabel") then
                newIcon.ImageColor3 = Theme.TextWhite
            else
                newIcon.TextColor3 = Theme.TextWhite
            end
        end
        SidebarButtons[activeTab].Indicator.Visible = true
        -- Animation chuyển tab: slide nhẹ
        ContentArea.Position = UDim2.new(0, 32, 0, 40)
        TweenService:Create(ContentArea,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 50, 0, 40)}):Play()
    end)

    Btn.MouseEnter:Connect(function()
        if activeTab ~= tabName then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
        end
    end)
    Btn.MouseLeave:Connect(function()
        if activeTab ~= tabName then
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)

    return TabContent
end

local TabAimbot = CreateSidebarIcon("Aimbot", "rbxassetid://7733917120", 10)
local TabESP = CreateSidebarIcon("ESP", "rbxassetid://7733774602", 55)
local TabPlayer = CreateSidebarIcon("Player", "rbxassetid://7733920644", 100)
local TabSecurity = CreateSidebarIcon("Security", "🛡", 145)

Tabs["Aimbot"].Visible = true
SidebarButtons["Aimbot"].BackgroundTransparency = 0.9
if SidebarButtons["Aimbot"]:FindFirstChild("Icon") then
    SidebarButtons["Aimbot"].Icon.ImageColor3 = Theme.TextWhite
end
SidebarButtons["Aimbot"].Indicator.Visible = true
activeTab = "Aimbot"

-- ============================================================
-- CONFIG SYSTEM (CHỐNG LỖI / TỰ ĐỘNG TẢI & LƯU CHUẨN XÁC)
-- ============================================================
local hasLoadedConfig = false

local function SaveConfig(isSilent)
    local isExplicitSilent = (isSilent == true)
    local ok, err = pcall(function()
        if not writefile then
            if not isExplicitSilent then
                SendNotification("Lỗi Lưu", "Executor không hỗ trợ writefile")
            end
            return
        end

        local sanitized = {}
        for k, v in pairs(Settings) do
            local valType = typeof(v)
            if valType == "EnumItem" then
                sanitized[k] = "Enum." .. tostring(v.EnumType) .. "." .. tostring(v.Name)
            elseif valType == "boolean" or valType == "number" or valType == "string" then
                sanitized[k] = v
            end
        end

        local encodeOk, encoded = pcall(function()
            return HttpService:JSONEncode(sanitized)
        end)

        if encodeOk and encoded and encoded ~= "" then
            writefile(IDS.ConfigName, encoded)
            hasLoadedConfig = true
            if not isExplicitSilent then
                SendNotification("Cấu Hình", "Đã lưu cài đặt thành công! ✓")
            end
        end
    end)
    if not ok then warn("SaveConfig error:", err) end
end

local function LoadConfig(isSilent)
    local isExplicitSilent = (isSilent == true)
    local ok, err = pcall(function()
        if not (readfile and isfile) then
            if not isExplicitSilent then
                SendNotification("Lỗi Tải", "Executor không hỗ trợ đọc file")
            end
            return
        end

        local targetFile = nil
        if isfile(IDS.ConfigName) then
            targetFile = IDS.ConfigName
        elseif isfile("FF_Pro_Config.json") then
            targetFile = "FF_Pro_Config.json"
        end

        if not targetFile then
            hasLoadedConfig = true
            if not isExplicitSilent then
                SendNotification("Thông Báo", "Chưa có file cấu hình để tải")
            end
            return
        end

        local rawContent = readfile(targetFile)
        if not rawContent or rawContent == "" then return end

        local decodeOk, data = pcall(function()
            return HttpService:JSONDecode(rawContent)
        end)

        if not decodeOk or type(data) ~= "table" then
            if not isExplicitSilent then
                SendNotification("Lỗi Cấu Hình", "File cấu hình bị lỗi cú pháp")
            end
            return
        end

        -- Áp dụng dữ liệu cấu hình vào Settings với bảo vệ kiểu dữ liệu
        for k, v in pairs(data) do
            if Settings[k] ~= nil then
                if type(v) == "string" and v:sub(1, 5) == "Enum." then
                    local parts = v:split(".")
                    if #parts >= 3 then
                        local enumType, enumName = parts[2], parts[3]
                        if Enum[enumType] and Enum[enumType][enumName] then
                            Settings[k] = Enum[enumType][enumName]
                        end
                    end
                elseif type(v) == type(Settings[k]) then
                    Settings[k] = v
                end
            end
        end

        -- Cập nhật đồng bộ toàn bộ giao diện UI Elements
        for key, ui in pairs(UI_Elements) do
            if Settings[key] ~= nil and ui and ui.SetValue then
                pcall(function() ui.SetValue(Settings[key]) end)
            end
        end

        hasLoadedConfig = true
        if not isExplicitSilent then
            SendNotification("Cấu Hình", "Đã tải cài đặt thành công! ✓")
        end
    end)
    if not ok then warn("LoadConfig error:", err) end
end

-- Tự động lưu định kỳ an toàn (Chỉ lưu khi đã tải xong cấu hình, không bao giờ ghi đè mặc định)
task.spawn(function()
    while task.wait(30) do
        if hasLoadedConfig then
            pcall(function() SaveConfig(true) end)
        end
    end
end)

-- ============================================================
-- UI BUILDERS
-- ============================================================
local function CreatePanel(parent, name, iconChar, posX, posY, sizeX, sizeY)
    local Panel = Instance.new("Frame")
    Panel.Name = name
    Panel.Size = UDim2.new(sizeX, -14, sizeY, -14)
    Panel.Position = UDim2.new(posX, 7, posY, 7)
    Panel.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    Panel.Parent = parent
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)

    local HeaderBg = Instance.new("Frame")
    HeaderBg.Size = UDim2.new(1, 0, 0, 45)
    HeaderBg.BackgroundColor3 = Theme.PanelBg
    HeaderBg.BorderSizePixel = 0
    HeaderBg.Parent = Panel
    Instance.new("UICorner", HeaderBg).CornerRadius = UDim.new(0, 8)

    local HeaderSquare = Instance.new("Frame")
    HeaderSquare.Size = UDim2.new(1, 0, 0, 10)
    HeaderSquare.Position = UDim2.new(0, 0, 1, -10)
    HeaderSquare.BackgroundColor3 = Theme.PanelBg
    HeaderSquare.BorderSizePixel = 0
    HeaderSquare.Parent = HeaderBg

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, 0)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = HeaderBg

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 45)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = (iconChar ~= "" and (iconChar .. "  ") or "") .. name
    Title.TextColor3 = Theme.TextWhite
    Title.Font = Theme.FontBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = HeaderBg

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, 0, 1, -50)
    Container.Position = UDim2.new(0, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 0
    Container.Parent = Panel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(45, 45, 50)
    PanelStroke.Thickness = 1
    PanelStroke.Parent = Panel

    table.insert(ThemeObjects.Panels, {
        Bg = Panel,
        Header = HeaderBg,
        HeaderSquare = HeaderSquare,
        Stroke = PanelStroke
    })

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Container

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)
    Padding.Parent = Container

    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    return Container
end

local function CreateSectionLabel(parent, text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, 0, 0, 24)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = "— " .. text .. " —"
    Lbl.TextColor3 = Theme.TextDark
    Lbl.Font = Theme.FontBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = parent
    return Lbl
end

local function CreateToggle(parent, text, dotColor, settingKey, callback)
    local isToggled = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][settingKey] = true
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end

    local reg = { State = isToggled }
    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]

    UI_Elements[settingKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", text)
        else
            SendNotification("Đã Tắt", text)
        end
        UpdateTabDots()
        if callback then callback(state) end
    end)
end

local function CreateSafeToggle(parent, text, dotColor, settingKey, callback)
    local isToggled = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 50, 50)
    Label.Font = Theme.FontBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][settingKey] = true
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end

    local reg = { State = isToggled }
    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]

    UI_Elements[settingKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    local warnState = 0
    ToggleBtn.MouseButton1Click:Connect(function()
        if state == true then
            if warnState == 0 then
                warnState = 1
                SendNotification("Nguy Hiểm", "Tắt chế độ bảo vệ có thể bị Ban! Bấm lần nữa để TẮT.")
                ToggleBtn.BackgroundColor3 = Theme.DotRed
                task.delay(3, function()
                    if warnState == 1 then
                        warnState = 0
                        ToggleBtn.BackgroundColor3 = Theme.AccentOn
                    end
                end)
                return
            end
        end
        warnState = 0
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("An Toàn", "Hệ thống bảo vệ đã BẬT!")
        else
            SendNotification("Nguy Hiểm", "Hệ thống tự vệ đã tắt, cẩn thận!")
        end
        UpdateTabDots()
        if callback then callback(state) end
    end)
end

local function CreateToggleWithDropdown(parent, toggleText, dotColor, toggleKey, dropKey, options, toggleCb, dropCb)
    local isToggled = Settings[toggleKey]
    local currentVal = Settings[dropKey]
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    -- Dot
    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    -- Toggle Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -145, 0, 35)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = toggleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    -- Dropdown Button in the middle
    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 75, 0, 24)
    Dropbox.Position = UDim2.new(1, -125, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -20, 1, 0)
    ValLabel.Position = UDim2.new(0, 6, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 16, 1, 0)
    Arrow.Position = UDim2.new(1, -16, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 11
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 75, 0, #options * 25)
    ListFrame.Position = UDim2.new(1, -125, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.TextColor3 = Theme.TextWhite
        OptBtn.Font = Theme.Font
        OptBtn.TextSize = 12
        OptBtn.Parent = ListFrame

        OptBtn.MouseButton1Click:Connect(function()
            ValLabel.Text = opt
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
            if dropCb then dropCb(opt) end
        end)
    end

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + (#options * 25))
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)

    -- Toggle Button on the right
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][toggleKey] = true
        SearchIndex[toggleKey] = { Label = toggleText, Frame = Frame, Tab = tabName }
        SearchIndex[dropKey] = { Label = "Target Part", Frame = Frame, Tab = tabName }
    end

    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    local reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[toggleKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if toggleCb then toggleCb(val) end
        end
    }

    UI_Elements[dropKey] = {
        SetValue = function(val)
            ValLabel.Text = val
            if dropCb then dropCb(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(toggleText) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", toggleText)
        else
            SendNotification("Đã Tắt", toggleText)
        end
        UpdateTabDots()
        if toggleCb then toggleCb(state) end
    end)
end

local function CreateToggleWithKeybind(parent, toggleText, dotColor, toggleKey, keyKey, toggleCb, keyCb)
    local isToggled = Settings[toggleKey]
    local currentVal = Settings[keyKey]
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    -- Dot
    if dotColor then
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 6, 0, 6)
        Dot.Position = UDim2.new(0, 0, 0.5, -3)
        Dot.BackgroundColor3 = dotColor
        Dot.Parent = Frame
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
    end

    -- Toggle Label
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -145, 0, 35)
    Label.Position = UDim2.new(0, dotColor and 15 or 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = toggleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    -- Keybind Button in the middle
    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 75, 0, 24)
    KeyBtn.Position = UDim2.new(1, -125, 0, 5)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)

    local function FormatKeyName(key)
        if not key then return "None" end
        local name = (typeof(key) == "EnumItem") and key.Name or tostring(key)
        if name == "MouseButton1" then return "LClick" end
        if name == "MouseButton2" then return "RClick" end
        if name == "MouseButton3" then return "MClick" end
        return name
    end

    KeyBtn.Text = FormatKeyName(currentVal)
    KeyBtn.TextColor3 = Theme.TextWhite
    KeyBtn.Font = Theme.Font
    KeyBtn.TextSize = 12
    KeyBtn.Parent = Frame
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

    local isBinding = false
    local connection

    KeyBtn.MouseButton1Click:Connect(function()
        if isBinding then return end
        KeyBtn.Text = "..."
        task.wait(0.1)
        isBinding = true

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType.Name:match("MouseButton") then
                local newKey = (input.KeyCode == Enum.KeyCode.Unknown)
                    and input.UserInputType or input.KeyCode
                if newKey.Name == "Unknown" then return end

                isBinding = false
                KeyBtn.Text = FormatKeyName(newKey)
                Settings[keyKey] = newKey
                if keyCb then keyCb(newKey) end

                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)

    -- Toggle Button on the right
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    ToggleBtn.BackgroundColor3 = isToggled and Theme.AccentOn or Theme.AccentOff
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = isToggled and Theme.KnobOn or Theme.KnobOff
    Knob.Parent = ToggleBtn
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = isToggled

    local function SetVisual(val)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = val and Theme.AccentOn or Theme.AccentOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {
            Position = val and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = val and Theme.KnobOn or Theme.KnobOff
        }):Play()
    end

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        if not TabActiveKeys[tabName] then TabActiveKeys[tabName] = {} end
        TabActiveKeys[tabName][toggleKey] = true
        SearchIndex[toggleKey] = { Label = toggleText, Frame = Frame, Tab = tabName }
        SearchIndex[keyKey] = { Label = "Aim Key", Frame = Frame, Tab = tabName }
    end

    table.insert(ThemeObjects.Toggles, {
        Btn = ToggleBtn, Knob = Knob,
        State = isToggled
    })
    local reg = ThemeObjects.Toggles[#ThemeObjects.Toggles]
    table.insert(ThemeObjects.Dropbox, { Box = KeyBtn })

    UI_Elements[toggleKey] = {
        SetValue = function(val)
            state = val
            reg.State = val
            SetVisual(val)
            UpdateTabDots()
            if toggleCb then toggleCb(val) end
        end
    }

    UI_Elements[keyKey] = {
        SetValue = function(val)
            KeyBtn.Text = FormatKeyName(val)
            if keyCb then keyCb(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(toggleText) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        reg.State = state
        SetVisual(state)
        if state then
            SendNotification("Đã Bật", toggleText)
        else
            SendNotification("Đã Tắt", toggleText)
        end
        UpdateTabDots()
        if toggleCb then toggleCb(state) end
    end)
end

local function CreateDropdown(parent, text, settingKey, options, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 100, 0, 24)
    Dropbox.Position = UDim2.new(1, -100, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -25, 1, 0)
    ValLabel.Position = UDim2.new(0, 10, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 12
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Size = UDim2.new(0, 100, 0, #options * 25)
    ListFrame.Position = UDim2.new(1, -100, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[settingKey] = {
        SetValue = function(val)
            ValLabel.Text = val
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    for _, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 25)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.TextColor3 = Theme.TextWhite
        OptBtn.Font = Theme.Font
        OptBtn.TextSize = 12
        OptBtn.Parent = ListFrame

        OptBtn.MouseButton1Click:Connect(function()
            ValLabel.Text = opt
            isOpen = false
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
            if callback then callback(opt) end
        end)
    end

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + (#options * 25))
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)
end

local function CreateKeybind(parent, text, settingKey, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local KeyBtn = Instance.new("TextButton")
    KeyBtn.Size = UDim2.new(0, 80, 0, 24)
    KeyBtn.Position = UDim2.new(1, -80, 0, 5)
    KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 38)

    local function FormatKeyName(key)
        if not key then return "None" end
        local name = key.Name
        if name == "MouseButton1" then return "LClick" end
        if name == "MouseButton2" then return "RClick" end
        if name == "MouseButton3" then return "MClick" end
        return name
    end

    KeyBtn.Text = FormatKeyName(currentVal)
    KeyBtn.TextColor3 = Theme.TextWhite
    KeyBtn.Font = Theme.Font
    KeyBtn.TextSize = 12
    KeyBtn.Parent = Frame
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 6)

    local isBinding = false
    local connection

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = KeyBtn })

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    KeyBtn.MouseButton1Click:Connect(function()
        if isBinding then return end
        KeyBtn.Text = "..."
        task.wait(0.1)
        isBinding = true

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType.Name:match("MouseButton") then
                local newKey = (input.KeyCode == Enum.KeyCode.Unknown)
                    and input.UserInputType or input.KeyCode
                if newKey.Name == "Unknown" then return end

                isBinding = false
                KeyBtn.Text = FormatKeyName(newKey)
                Settings[settingKey] = newKey
                if callback then callback(newKey) end

                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)
end

local function CreatePlayerDropdown(parent, text, settingKey, callback)
    local currentVal = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 0, 35)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Dropbox = Instance.new("TextButton")
    Dropbox.Size = UDim2.new(0, 100, 0, 24)
    Dropbox.Position = UDim2.new(1, -100, 0, 5)
    Dropbox.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    Dropbox.Text = ""
    Dropbox.Parent = Frame
    Instance.new("UICorner", Dropbox).CornerRadius = UDim.new(0, 6)

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(1, -25, 1, 0)
    ValLabel.Position = UDim2.new(0, 10, 0, 0)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = (currentVal == "" or currentVal == nil) and "Chọn Người" or currentVal
    ValLabel.TextColor3 = Theme.TextWhite
    ValLabel.Font = Theme.Font
    ValLabel.TextSize = 12
    ValLabel.TextXAlignment = Enum.TextXAlignment.Left
    ValLabel.Parent = Dropbox

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -20, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "v"
    Arrow.TextColor3 = Theme.TextDark
    Arrow.Font = Theme.Font
    Arrow.TextSize = 12
    Arrow.Parent = Dropbox

    local ListFrame = Instance.new("Frame")
    ListFrame.Position = UDim2.new(1, -100, 0, 32)
    ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Frame
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local isOpen = false

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.Dropbox, { Box = Dropbox })

    UI_Elements[settingKey] = {
        SetValue = function(val)
            ValLabel.Text = (val == "" or val == nil) and "Chọn Người" or val
            if callback then callback(val) end
        end
    }

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    Dropbox.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            for _, child in pairs(ListFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end

            local players = Players:GetPlayers()
            local listSize = math.min(#players, 6) * 25
            ListFrame.Size = UDim2.new(0, 100, 0, listSize)

            for _, player in ipairs(players) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = player.Name
                OptBtn.TextColor3 = Theme.TextWhite
                OptBtn.Font = Theme.Font
                OptBtn.TextSize = 12
                OptBtn.Parent = ListFrame

                OptBtn.MouseButton1Click:Connect(function()
                    ValLabel.Text = player.Name
                    isOpen = false
                    TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    Arrow.Text = "v"
                    if callback then callback(player.Name) end
                end)
            end

            TweenService:Create(Frame, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 35 + listSize)
            }):Play()
            Arrow.Text = "^"
        else
            TweenService:Create(Frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            Arrow.Text = "v"
        end
    end)
end

local function CreateSlider(parent, text, settingKey, min, max, suffix, callback)
    local value = Settings[settingKey]
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.BackgroundTransparency = 1
    Label.RichText = true
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Theme.Font
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local hasSuffix = suffix and suffix ~= ""
    local inputOffset = hasSuffix and -60 or -40

    local ValInput = Instance.new("TextBox")
    ValInput.Size = UDim2.new(0, 35, 0, 20)
    ValInput.Position = UDim2.new(1, inputOffset, 0.5, -10)
    ValInput.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
    ValInput.TextColor3 = Theme.TextWhite
    ValInput.Font = Theme.Font
    ValInput.TextSize = 12
    ValInput.Text = tostring(value)
    ValInput.Parent = Frame
    Instance.new("UICorner", ValInput).CornerRadius = UDim.new(0, 4)

    if hasSuffix then
        local SuffixLbl = Instance.new("TextLabel")
        SuffixLbl.Size = UDim2.new(0, 20, 1, 0)
        SuffixLbl.Position = UDim2.new(1, -20, 0, 0)
        SuffixLbl.BackgroundTransparency = 1
        SuffixLbl.Text = suffix:gsub(" ", "")
        SuffixLbl.TextColor3 = Theme.TextDark
        SuffixLbl.Font = Theme.Font
        SuffixLbl.TextSize = 12
        SuffixLbl.TextXAlignment = Enum.TextXAlignment.Left
        SuffixLbl.Parent = Frame
    end

    local SliderBg = Instance.new("TextButton")
    SliderBg.Size = UDim2.new(1, -190, 0, 4)
    SliderBg.Position = UDim2.new(0, 125, 0.5, -2)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
    SliderBg.BorderSizePixel = 0
    SliderBg.Text = ""
    SliderBg.AutoButtonColor = false
    SliderBg.Parent = Frame
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((value - min) / (max - min), 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.TextWhite
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new(1, -5, 0.5, -5)
    Knob.BackgroundColor3 = Theme.TextWhite
    Knob.Parent = SliderFill
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateSlider(pos)
        pos = math.clamp(pos, 0, 1)
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local newVal = min + (max - min) * pos
        if max <= 1 then
            newVal = math.floor(newVal * 100) / 100
        else
            newVal = math.floor(newVal * 10) / 10
        end
        ValInput.Text = tostring(newVal)
        if callback then callback(newVal) end
    end

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
            updateSlider(pos)
        end
    end)
    SliderBg.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
            updateSlider(pos)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UI_Elements[settingKey] = {
        SetValue = function(val)
            local pos = (val - min) / (max - min)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            ValInput.Text = tostring(val)
            if callback then callback(val) end
        end
    }

    local tabName = nil
    for name, tab in pairs(Tabs) do
        if tab == parent then
            tabName = name
            break
        end
    end
    if tabName then
        SearchIndex[settingKey] = { Label = text, Frame = Frame, Tab = tabName }
    end
    table.insert(ThemeObjects.SliderFills, { Fill = SliderFill })

    Frame.MouseEnter:Connect(function() ShowTooltip(text) end)
    Frame.MouseLeave:Connect(function() ShowTooltip(nil) end)

    ValInput.FocusLost:Connect(function()
        local num = tonumber(ValInput.Text)
        if num then
            num = math.clamp(num, min, max)
            local pos = (num - min) / (max - min)
            updateSlider(pos)
        else
            local currentPos = SliderFill.Size.X.Scale
            updateSlider(currentPos)
        end
    end)
end

local function CreateButtonWithConfirm(parent, text, warningText, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -30, 1, -10)
    Btn.Position = UDim2.new(0, 15, 0, 5)
    Btn.BackgroundColor3 = Theme.AccentOff
    Btn.TextColor3 = Theme.TextWhite
    Btn.Font = Theme.FontBold
    Btn.TextSize = 13
    Btn.Text = text
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local state = 0
    Btn.MouseButton1Click:Connect(function()
        if state == 0 then
            state = 1
            Btn.Text = "BẤM LẦN NỮA ĐỂ XÁC NHẬN"
            Btn.BackgroundColor3 = Theme.DotRed
            SendNotification("Nguy Hiểm", warningText)
            task.delay(3, function()
                if state == 1 then
                    state = 0
                    Btn.Text = text
                    Btn.BackgroundColor3 = Theme.AccentOff
                end
            end)
        elseif state == 1 then
            state = 2
            Btn.Text = "ĐÃ KÍCH HOẠT"
            Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            if callback then callback() end
        end
    end)
end

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

-- ============================================================
-- XÂY DỰNG TABS
-- ============================================================
local PanelAimbot = CreatePanel(TabAimbot, "Aimbot", "", 0, 0, 0.5, 1)
CreateToggleWithDropdown(PanelAimbot, "Enable Aimbot", Theme.DotGreen, "AimEnabled", "TargetPart", {"Head", "HumanoidRootPart", "Safe"}, function(v) 
    Settings.AimEnabled = v 
end, function(v) 
    Settings.TargetPart = v
    Settings.ProAimTargetPart = v
end)
CreateSlider(PanelAimbot, "FOV Size", "FOV", 10, 500, " px", function(v)
    Settings.FOV = v
    Settings.ProAimFOV = v
    FOVring.Radius = v
end)
CreateToggle(PanelAimbot, "Aim Safe", Theme.DotGreen, "AimSafe", function(v) Settings.AimSafe = v end)
CreateToggle(PanelAimbot, "Draw FOV", Theme.DotGreen, "FOVVisible", function(v)
    Settings.FOVVisible = v
    Settings.ProAimFOVVisible = v
    Settings.AimSnapline = v
    Settings.ProAimSnapline = v
    FOVring.Visible = v
end)
CreateToggleWithDropdown(PanelAimbot, "Hitbox Expander", Theme.DotGreen, "HitboxExpander", "HitboxPart", {"Head", "Torso"}, function(v)
    Settings.HitboxExpander = v
    if not v then ResetHitboxes() end
end, function(v)
    Settings.HitboxPart = v
    ResetHitboxes()
end)
CreateSlider(PanelAimbot, "Hitbox Size", "HitboxSize", 2, 500, " studs", function(v)
    Settings.HitboxSize = v
end)
CreateToggle(PanelAimbot, "Hide Hitbox (Ẩn Khung)", Theme.DotGreen, "HitboxInvisible", function(v)
    Settings.HitboxInvisible = v
    for part, orig in pairs(originalHitboxes) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = v and 1 or 0.55
            end)
        end
    end
end)

local PanelAimbotSet = CreatePanel(TabAimbot, "Exploits", "", 0.5, 0, 0.5, 1)
CreateToggle(PanelAimbotSet, "Kill Aura", Theme.DotRed, "AutoFire", function(v) Settings.AutoFire = v end)
CreateToggle(PanelAimbotSet, "Wall Check ", Theme.DotRed, "AutoFireWallCheck", function(v) Settings.AutoFireWallCheck = v end)
CreateToggle(PanelAimbotSet, 'Slient Aim <font color="#ff3333">[BETA]</font>', Theme.DotRed, "AutoFireHoldM2", function(v) Settings.AutoFireHoldM2 = v end)
CreateToggleWithKeybind(PanelAimbotSet, 'NO RECOIL <font color="#ff3333">[BETA]</font>', Theme.DotRed, "NoRecoil", "NoRecoilHotkey", function(v) Settings.NoRecoil = v end, function(v) Settings.NoRecoilHotkey = v end)
CreateToggleWithKeybind(PanelAimbotSet, "Aimlock", Theme.DotRed, "ProAimEnabled", "ProAimHoldMouse", function(v) Settings.ProAimEnabled = v end, function(v) Settings.ProAimHoldMouse = v end)
CreateSlider(PanelAimbotSet, "Aimlock Smooth", "ProAimSmoothness", 0.01, 1, "", function(v)
    Settings.ProAimSmoothness = v
    Settings.AimSmoothness = v
end)

local PanelESP = CreatePanel(TabESP, "ESP", "", 0, 0, 0.5, 1)
CreateToggle(PanelESP, "Enable ESP", Theme.DotGreen, "ESPEnabled", function(v)
    Settings.ESPEnabled = v
    if not v and Shared.ESPTable then
        for _, esp in pairs(Shared.ESPTable) do
            if Shared.hideAllESP then
                Shared.hideAllESP(esp)
            elseif ESP and ESP.hideAllESP then
                ESP.hideAllESP(esp)
            end
        end
    end
    if ESPCounterBox then
        ESPCounterBox.Visible = v and Settings.ESPCount
    end
end)
CreateToggleWithDropdown(PanelESP, "Chams", Theme.DotGreen, "ESPChams", "ChamsColor", {"Red", "Green", "White", "Blue", "Yellow", "Pink"}, function(v) Settings.ESPChams = v end, function(v) Settings.ChamsColor = v end)
CreateToggle(PanelESP, "Skeleton", Theme.DotGreen, "ESPSkeleton", function(v) Settings.ESPSkeleton = v end)
CreateToggle(PanelESP, "Box", Theme.DotGreen, "ESPBox", function(v) Settings.ESPBox = v end)
CreateToggle(PanelESP, "Name", Theme.DotGreen, "ESPName", function(v) Settings.ESPName = v end)
CreateToggle(PanelESP, "Health", Theme.DotGreen, "ESPHealth", function(v) Settings.ESPHealth = v end)
CreateToggle(PanelESP, "Distance", Theme.DotGreen, "ESPDistance", function(v) Settings.ESPDistance = v end)
CreateToggle(PanelESP, "Look Line", Theme.DotGreen, "ESPLine", function(v) Settings.ESPLine = v end)
CreateToggle(PanelESP, "Weapon", Theme.DotGreen, "ESPWeapon", function(v) Settings.ESPWeapon = v end)
CreateToggle(PanelESP, "Level/XP", Theme.DotGreen, "ESPLevel", function(v) Settings.ESPLevel = v end)
CreateToggle(PanelESP, "Player Count (Top)", Theme.DotGreen, "ESPCount", function(v)
    Settings.ESPCount = v
    if ESPCounterBox then
        ESPCounterBox.Visible = Settings.ESPEnabled and v
    end
end)
CreateToggle(PanelESP, "Aim Warning", Theme.DotGreen, "AimWarning", function(v) Settings.AimWarning = v end)
CreateToggle(PanelESP, 'Arrows <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "OffscreenArrows", function(v)
    Settings.OffscreenArrows = v
    if not v and Shared.ESPTable then
        for _, esp in pairs(Shared.ESPTable) do
            if esp.Arrow1 then esp.Arrow1.Visible = false end
            if esp.Arrow2 then esp.Arrow2.Visible = false end
            if esp.Arrow3 then esp.Arrow3.Visible = false end
        end
    end
end)

local PanelESPSet = CreatePanel(TabESP, "Settings", "⚙", 0.5, 0, 0.5, 1)
CreateToggle(PanelESPSet, "Team Check", Theme.DotGreen, "TeamCheck", function(v)
    Settings.TeamCheck = v
    Settings.ESPTeamCheck = v
    Settings.ProAimTeamCheck = v
end)
CreateToggle(PanelESPSet, "Bot [BETA]", Theme.DotGreen, "TargetNPC", function(v)
    Settings.TargetNPC = v
    if not v then
        if Shared.NPCCache then table.clear(Shared.NPCCache) end
        if Shared.ESPTable then
            for target, esp in pairs(Shared.ESPTable) do
                if typeof(target) == "Instance" and not target:IsA("Player") then
                    if Shared.removeESP then
                        Shared.removeESP(target)
                    elseif ESP and ESP.removeESP then
                        ESP.removeESP(target)
                    end
                end
            end
        end
    end
end)
CreateSlider(PanelESPSet, "Max Aim Dist", "AimDist", 1, 2000, " m", function(v) 
    Settings.AimDist = v
    Settings.ProAimDist = v
end)
CreateSlider(PanelESPSet, "Max ESP Dist", "ESPDist", 1, 2000, " m", function(v) Settings.ESPDist = v end)

local PanelPlayer = CreatePanel(TabPlayer, "Exploits", "", 0, 0, 0.5, 1)
local function CheckAndBypassCharacterAC(featureName)
    if not Settings.BypassACMove then
        SendNotification("⚠️ NGUY HIỂM ⚠️", "Nguy cơ BAN khi dùng " .. featureName .. ". Bật lại an toàn!")
        return false
    end

    local disconnected = 0
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            local connections = {}
            if getconnections then
                for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("JumpPower"))) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(hum.StateChanged)) do
                    table.insert(connections, conn)
                end
                for _, conn in pairs(getconnections(Workspace:GetPropertyChangedSignal("Gravity"))) do
                    table.insert(connections, conn)
                end
            end
            for _, conn in ipairs(connections) do
                if conn.Disable then
                    conn:Disable()
                    disconnected = disconnected + 1
                end
            end
        end
    end)
    if disconnected > 0 then
        SendNotification("🛡 Bypass", "Vô hiệu hóa " .. disconnected .. " bẫy theo dõi cho " .. featureName)
    end
    return true
end

CreateToggle(PanelPlayer, "Speed Buff", Theme.DotGreen, "SpeedHack", function(v)
    if v and not CheckAndBypassCharacterAC("SpeedHack") then
        Settings.SpeedHack = false
        if UI_Elements.SpeedHack then UI_Elements.SpeedHack.SetValue(false) end
        return
    end
    Settings.SpeedHack = v
end)
CreateToggle(PanelPlayer, "Jump Buff", Theme.DotGreen, "JumpHack", function(v)
    if v and not CheckAndBypassCharacterAC("JumpHack") then
        Settings.JumpHack = false
        if UI_Elements.JumpHack then UI_Elements.JumpHack.SetValue(false) end
        return
    end
    Settings.JumpHack = v
end)
CreateToggle(PanelPlayer, "Inf Jump", Theme.DotGreen, "InfJump", function(v)
    if v and not CheckAndBypassCharacterAC("Inf Jump") then
        Settings.InfJump = false
        if UI_Elements.InfJump then UI_Elements.InfJump.SetValue(false) end
        return
    end
    Settings.InfJump = v
end)
CreateToggle(PanelPlayer, "Fly", Theme.DotGreen, "Fly", function(v)
    if v and not CheckAndBypassCharacterAC("Fly") then
        Settings.Fly = false
        if UI_Elements.Fly then UI_Elements.Fly.SetValue(false) end
        return
    end
    Settings.Fly = v
end)
CreateToggle(PanelPlayer, "Noclip", Theme.DotGreen, "Noclip", function(v)
    if v and not CheckAndBypassCharacterAC("Noclip") then
        Settings.Noclip = false
        if UI_Elements.Noclip then UI_Elements.Noclip.SetValue(false) end
        return
    end
    Settings.Noclip = v
end)
CreateToggle(PanelPlayer, "Gravity", Theme.DotGreen, "GravityHack", function(v)
    if v and not CheckAndBypassCharacterAC("Gravity") then
        Settings.GravityHack = false
        if UI_Elements.GravityHack then UI_Elements.GravityHack.SetValue(false) end
        return
    end
    Settings.GravityHack = v
    if v then
        Workspace.Gravity = Settings.Gravity
    else
        Workspace.Gravity = 196.2
    end
end)
CreateToggle(PanelPlayer, "Slow Fall", Theme.DotGreen, "SlowFall", function(v)
    if v and not CheckAndBypassCharacterAC("Slow Fall") then
        Settings.SlowFall = false
        if UI_Elements.SlowFall then UI_Elements.SlowFall.SetValue(false) end
        return
    end
    Settings.SlowFall = v
end)

CreateToggleWithKeybind(PanelPlayer, "Chui Đất", Theme.DotGreen, "UndergroundNoclip", "UndergroundHotkey", function(v)
    Settings.UndergroundNoclip = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.undergroundSurfaceY = LocalPlayer.Character.HumanoidRootPart.Position.Y
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.undergroundSurfaceY then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame + Vector3.new(0, Shared.undergroundSurfaceY - hrp.Position.Y, 0)
        Shared.undergroundSurfaceY = nil
    end
end, function(v)
    Settings.UndergroundHotkey = v
end)

CreateToggleWithKeybind(PanelPlayer, "Tele", Theme.DotGreen, "AutoTeleport", "AutoTeleportHotkey", function(v)
    if v and not CheckAndBypassCharacterAC("Auto Teleport") then
        Settings.AutoTeleport = false
        if UI_Elements.AutoTeleport then UI_Elements.AutoTeleport.SetValue(false) end
        return
    end
    Settings.AutoTeleport = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.originalTeleportCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalTeleportCFrame then
        if Settings.AutoTeleportReturn then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalTeleportCFrame
        end
        Shared.originalTeleportCFrame = nil
    end
end, function(v)
    Settings.AutoTeleportHotkey = v
end)
CreateToggleWithKeybind(PanelPlayer, 'Speed Tele <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "SpeedTele", "SpeedTeleHotkey", function(v)
    if v and not CheckAndBypassCharacterAC("Speed Tele") then
        Settings.SpeedTele = false
        if UI_Elements.SpeedTele then UI_Elements.SpeedTele.SetValue(false) end
        return
    end
    Settings.SpeedTele = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Shared.originalSpeedTeleCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    elseif not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalSpeedTeleCFrame then
        if Settings.AutoTeleportReturn then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalSpeedTeleCFrame
        end
        Shared.originalSpeedTeleCFrame = nil
    end
end, function(v)
    Settings.SpeedTeleHotkey = v
end)
CreateToggle(PanelPlayer, 'SpinBot <font color="#ff3333">[BETA]</font>', Theme.DotGreen, "SpinBot", function(v)
    Settings.SpinBot = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.AutoRotate = true
    end
end)

local PanelPlayerSet = CreatePanel(TabPlayer, "Settings", "⚙", 0.5, 0, 0.5, 1)
CreateSlider(PanelPlayerSet, "Tốc Độ", "WalkSpeed", 16, 300, "", function(v) Settings.WalkSpeed = v end)
CreateSlider(PanelPlayerSet, "Lực Nhảy", "JumpPower", 50, 500, "", function(v) Settings.JumpPower = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Bay", "FlySpeed", 10, 300, "", function(v) Settings.FlySpeed = v end)
CreateSlider(PanelPlayerSet, "Trọng Lực (Gravity)", "Gravity", 0, 500, "", function(v)
    Settings.Gravity = v
    if Settings.GravityHack then
        Workspace.Gravity = v
    end
end)
CreateSlider(PanelPlayerSet, "Tốc Độ Rơi (Slow Fall)", "SlowFallSpeed", 1, 50, "", function(v)
    Settings.SlowFallSpeed = v
end)
CreateSlider(PanelPlayerSet, "Độ Sâu Chui", "UndergroundDistance", 1, 50, " m", function(v) Settings.UndergroundDistance = v end)
CreateSlider(PanelPlayerSet, "Phạm Vi Tele", "TeleportRange", 10, 2000, " m", function(v) Settings.TeleportRange = v end)
CreateSlider(PanelPlayerSet, "Cự Ly Bám Địch", "AutoTeleportDistance", 0, 100, " m", function(v) Settings.AutoTeleportDistance = v end)
CreateDropdown(PanelPlayerSet, "Vị Trí Tele", "AutoTeleportPosition", {"Sau Lưng", "Trên Đầu", "Random"}, function(v) Settings.AutoTeleportPosition = v end)
CreateToggle(PanelPlayerSet, "Tự Tele Về", Theme.DotGreen, "AutoTeleportReturn", function(v) Settings.AutoTeleportReturn = v end)
CreateToggle(PanelPlayerSet, "Kiểm Tra Khiên An Toàn", Theme.DotGreen, "SafeShieldCheck", function(v) Settings.SafeShieldCheck = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Speed Tele", "SpeedTeleSpeed", 10, 300, "", function(v) Settings.SpeedTeleSpeed = v end)
CreateSlider(PanelPlayerSet, "Tốc Độ Xoay", "SpinSpeed", 10, 100, "", function(v) Settings.SpinSpeed = v end)

local PanelOptim = CreatePanel(TabSecurity, "Tối Ưu Hóa Máy Yếu", "🚀", 0, 0, 0.5, 1)
CreateToggle(PanelOptim, "Tắt Đổ Bóng", Theme.DotGreen, "OptimShadows", function(v)
    Settings.OptimShadows = v
    Lighting.GlobalShadows = not v
end)
CreateToggle(PanelOptim, "Plastic Mode", Theme.DotGreen, "OptimTextures", function(v)
    Settings.OptimTextures = v
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = v and Enum.Material.SmoothPlastic or Enum.Material.Plastic
        end
    end
end)
CreateToggle(PanelOptim, "Xóa Sương Mù", Theme.DotGreen, "OptimFog", function(v)
    Settings.OptimFog = v
    if v then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = 10000
    end
end)

CreateButtonWithConfirm(PanelOptim, "POTATO MODE", "Cảnh báo: Không thể hoàn tác! Hình ảnh game bị xóa sạch để buff FPS.", function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.ClockTime = 12

    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterColor = Color3.fromRGB(0, 0, 0)
        pcall(function() sethiddenproperty(Terrain, "Decoration", false) end)
    end

    task.spawn(function()
        local descendants = game:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect")
                or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect")
                or obj:IsA("DepthOfFieldEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("BasePart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                end)
            elseif obj:IsA("MeshPart") then
                pcall(function()
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                    obj.TextureID = ""
                end)
            elseif obj:IsA("SpecialMesh") then
                if obj.MeshType == Enum.MeshType.FileMesh then
                    pcall(function() obj.TextureID = "" end)
                    pcall(function() obj.TextureId = "" end)
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                pcall(function() obj:Destroy() end)
            end
            if i % 250 == 0 then
                task.wait()
            end
        end
        SendNotification("Potato Mode", "Đã dọn dẹp đồ họa để buff FPS!")
    end)
end)

local PanelSettings = CreatePanel(TabSecurity, "Bảo Mật", "", 0.5, 0, 0.5, 1)
CreateKeybind(PanelSettings, "Phím Ẩn/Hiện Menu", "ToggleKeybind", function(key) Settings.ToggleKeybind = key end)

local function RejoinServer()
    SendNotification("🔄 Set Prosers", "Đang kết nối lại Server...")
    task.spawn(function()
        pcall(function()
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\n[Rejoin] Đang kết nối lại Server...")
                task.wait(0.5)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
    end)
end



do
    local BtnSave = Instance.new("TextButton")
    BtnSave.Size = UDim2.new(1, 0, 0, 30)
    BtnSave.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    BtnSave.TextColor3 = Color3.fromRGB(175, 175, 185)
    BtnSave.Font = Theme.Font
    BtnSave.TextSize = 12
    BtnSave.Text = "Lưu Cài Đặt (Save)"
    BtnSave.Parent = PanelSettings
    Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0, 6)
    BtnSave.MouseButton1Click:Connect(function() SaveConfig(false) end)

    local BtnLoad = Instance.new("TextButton")
    BtnLoad.Size = UDim2.new(1, 0, 0, 32)
    BtnLoad.BackgroundColor3 = Color3.fromRGB(0, 210, 110)
    BtnLoad.TextColor3 = Color3.fromRGB(10, 25, 18)
    BtnLoad.Font = Theme.FontBold
    BtnLoad.TextSize = 13
    BtnLoad.Text = "⚡ Tải Cài Đặt (Load)"
    BtnLoad.Parent = PanelSettings
    Instance.new("UICorner", BtnLoad).CornerRadius = UDim.new(0, 6)
    BtnLoad.MouseButton1Click:Connect(function() LoadConfig(false) end)

    local BtnRejoin = Instance.new("TextButton")
    BtnRejoin.Size = UDim2.new(1, 0, 0, 30)
    BtnRejoin.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    BtnRejoin.TextColor3 = Theme.TextWhite
    BtnRejoin.Font = Theme.FontBold
    BtnRejoin.TextSize = 13
    BtnRejoin.Text = "Set Prosers"
    BtnRejoin.Parent = PanelSettings
    Instance.new("UICorner", BtnRejoin).CornerRadius = UDim.new(0, 6)
    BtnRejoin.MouseButton1Click:Connect(RejoinServer)
end

-- Toggle UI với slide animation (Chặn mở Menu khi chưa check key/kết nối)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Settings.ToggleKeybind then


        if MainFrame.Visible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, -325, 1.5, 0)}):Play()
            task.delay(0.3, function() MainFrame.Visible = false end)
        else
            MainFrame.Position = UDim2.new(0.5, -325, 1.5, 0)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, -325, 0.5, -210)}):Play()
        end
    end
end)

-- Phím tắt nhanh bật/tắt
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Settings.NoRecoilHotkey and Settings.NoRecoilHotkey ~= Enum.KeyCode.None then
        Settings.NoRecoil = not Settings.NoRecoil
        if UI_Elements.NoRecoil then UI_Elements.NoRecoil.SetValue(Settings.NoRecoil) end
        UpdateTabDots()
        SendNotification("Hotkey", "No Recoil: " .. (Settings.NoRecoil and "BẬT" or "TẮT"))
        return
    end
    if gpe then return end
    if input.KeyCode == Settings.AimHotkey and Settings.AimHotkey ~= Enum.KeyCode.None then
        Settings.AimEnabled = not Settings.AimEnabled
        if UI_Elements.AimEnabled then UI_Elements.AimEnabled.SetValue(Settings.AimEnabled) end
        UpdateTabDots()
        SendNotification("Hotkey", "Aim: " .. (Settings.AimEnabled and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.AutoFireHotkey and Settings.AutoFireHotkey ~= Enum.KeyCode.None then
        Settings.AutoFire = not Settings.AutoFire
        if UI_Elements.AutoFire then UI_Elements.AutoFire.SetValue(Settings.AutoFire) end
        UpdateTabDots()
        SendNotification("Hotkey", "Auto Fire: " .. (Settings.AutoFire and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.AutoTeleportHotkey and Settings.AutoTeleportHotkey ~= Enum.KeyCode.None then
        if not Settings.AutoTeleport and not CheckAndBypassCharacterAC("Auto Teleport") then
            return
        end
        Settings.AutoTeleport = not Settings.AutoTeleport
        if UI_Elements.AutoTeleport then UI_Elements.AutoTeleport.SetValue(Settings.AutoTeleport) end
        
        if Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.originalTeleportCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        elseif not Settings.AutoTeleport and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalTeleportCFrame then
            if Settings.AutoTeleportReturn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalTeleportCFrame
            end
            Shared.originalTeleportCFrame = nil
        end
        
        UpdateTabDots()
        SendNotification("Hotkey", "Tele: " .. (Settings.AutoTeleport and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.SpeedTeleHotkey and Settings.SpeedTeleHotkey ~= Enum.KeyCode.None then
        if not Settings.SpeedTele and not CheckAndBypassCharacterAC("Speed Tele") then
            return
        end
        Settings.SpeedTele = not Settings.SpeedTele
        if UI_Elements.SpeedTele then UI_Elements.SpeedTele.SetValue(Settings.SpeedTele) end
        
        if Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.originalSpeedTeleCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        elseif not Settings.SpeedTele and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.originalSpeedTeleCFrame then
            if Settings.AutoTeleportReturn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Shared.originalSpeedTeleCFrame
            end
            Shared.originalSpeedTeleCFrame = nil
        end
        
        UpdateTabDots()
        SendNotification("Hotkey", "Speed Tele [BETA]: " .. (Settings.SpeedTele and "BẬT" or "TẮT"))
    elseif input.KeyCode == Settings.UndergroundHotkey and Settings.UndergroundHotkey ~= Enum.KeyCode.None then
        Settings.UndergroundNoclip = not Settings.UndergroundNoclip
        if UI_Elements.UndergroundNoclip then UI_Elements.UndergroundNoclip.SetValue(Settings.UndergroundNoclip) end
        
        if Settings.UndergroundNoclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Shared.undergroundSurfaceY = LocalPlayer.Character.HumanoidRootPart.Position.Y
        elseif not Settings.UndergroundNoclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Shared.undergroundSurfaceY then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame + Vector3.new(0, Shared.undergroundSurfaceY - hrp.Position.Y, 0)
            Shared.undergroundSurfaceY = nil
        end
        UpdateTabDots()
        SendNotification("Hotkey", "Chui Đất: " .. (Settings.UndergroundNoclip and "BẬT" or "TẮT"))
    end
end)



    local function ApplyTheme()
        local p = GetActivePreset()
        Theme.MainBg = p.MainBg
        Theme.PanelBg = p.PanelBg
        Theme.AccentOn = p.AccentOn
        Theme.AccentOff = p.AccentOff

        if MainFrame then
            pcall(function() MainFrame.BackgroundColor3 = p.MainBg end)
        end
        if MainStroke then
            pcall(function() MainStroke.Color = p.Stroke end)
        end

        for _, o in pairs(ThemeObjects.Panels) do
            pcall(function()
                o.Bg.BackgroundColor3 = p.Panel
                o.Header.BackgroundColor3 = p.PanelBg
                o.HeaderSquare.BackgroundColor3 = p.PanelBg
                o.Stroke.Color = p.Stroke
            end)
        end
        for _, o in pairs(ThemeObjects.Toggles) do
            pcall(function()
                o.Btn.BackgroundColor3 = o.State and p.AccentOn or p.AccentOff
                o.Knob.BackgroundColor3 = o.State and Theme.KnobOn or Theme.KnobOff
            end)
        end
        for _, o in pairs(ThemeObjects.SliderFills) do
            pcall(function() o.Fill.BackgroundColor3 = p.AccentOn end)
        end
        for _, o in pairs(ThemeObjects.Dropbox) do
            pcall(function() o.Box.BackgroundColor3 = Color3.fromRGB(35, 35, 38) end)
        end
    end

    UI.ScreenGui = ScreenGui
    UI.MainFrame = MainFrame
    UI.StatusText = StatusText
    UI.UpdateWatermarkColor = UpdateWatermarkColor
    UI.GetMenuConnected = function() return isMenuConnected end
    UI.ESPCounterBox = ESPCounterBox
    UI.WatermarkFrame = WatermarkFrame
    UI.NotifyFrame = NotifyFrame
    UI.UpdateTabDots = UpdateTabDots
    UI.ApplyTheme = ApplyTheme

    Shared.SendNotification = SendNotification
    Shared.ApplyTheme = ApplyTheme
    Shared.UI_Elements.ESPCounterBox = ESPCounterBox
    Shared.UI_Elements.ESPCounterLabel = ESPCounterLabel

    return UI
end

end)()

-- [[ ENTRY POINT LOADER ]]
-- ============================================================
-- MODULAR RIVALS | ENTRY POINT: LOADER (GITHUB & LOCAL HYBRID)
-- Tạo Bởi An Nguyễn Đẹp Trai - Im Goned
-- ============================================================

local GITHUB_CONFIG = {
    Enabled = true,                    -- Tải trực tiếp từ GitHub
    Username = "AnNguyen-Script",       -- GitHub Username
    Repository = "Aurora-Rivals",      -- GitHub Repository
    Branch = "main",                   -- Nhánh chính
    Folder = ""                        -- Thư mục gốc repo
}

-- Hàm Import Module Tự Động
local function Import(name)
    local content = nil
    local resolvedSource = nil

    if GITHUB_CONFIG.Enabled and GITHUB_CONFIG.Username ~= "YOUR_GITHUB_USERNAME" then
        local folderPart = (GITHUB_CONFIG.Folder ~= "" and (GITHUB_CONFIG.Folder .. "/")) or ""
        local rawUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s%s?v=%d",
            GITHUB_CONFIG.Username,
            GITHUB_CONFIG.Repository,
            GITHUB_CONFIG.Branch,
            folderPart,
            name,
            math.floor(tick())
        )
        local ok, res = pcall(game.HttpGet, game, rawUrl)
        if ok and res and #res > 0 and not string.find(res, "404: Not Found") then
            content = res
            resolvedSource = rawUrl
        end
    end

    if not content then
        local BASE_PATHS = {
            "Modular_Rivals/",
            "",
            "workspace/Modular_Rivals/",
        }

        if isfile then
            for _, prefix in ipairs(BASE_PATHS) do
                local testPath = prefix .. name
                if isfile(testPath) then
                    content = readfile(testPath)
                    resolvedSource = testPath
                    break
                end
            end
        end

        if not content and loadfile then
            for _, prefix in ipairs(BASE_PATHS) do
                local testPath = prefix .. name
                local ok, fn = pcall(loadfile, testPath)
                if ok and fn then
                    return fn()
                end
            end
        end
    end

    if not content then
        error("[RIVALS LOADER] Không thể tìm thấy module '" .. name .. "' trên GitHub lẫn Local!")
    end

    local fn, compileErr = loadstring(content, resolvedSource or name)
    if not fn then
        error("[RIVALS LOADER] Lỗi biên dịch module '" .. name .. "': " .. tostring(compileErr))
    end

    return fn()
end

-- 1. Khởi tạo Modules theo thứ tự phụ thuộc
local Shared    = Import("Shared.lua")
local Shield    = Import("Shield.lua")(Shared)
local Targeting = Import("Targeting.lua")(Shared, Shield)
local Player    = Import("Player.lua")(Shared, Targeting)
local Aim       = Import("Aim.lua")(Shared, Targeting)
local ESP       = Import("ESP.lua")(Shared, Targeting)
local UI        = Import("UI.lua")(Shared, Shield, Targeting, ESP, Aim, Player)

-- 2. Kích hoạt Anti-Cheat Shield
pcall(function()
    Shield.InitShield()
end)

-- 3. Vòng lặp Physics (Stepped)
local steppedConn = Shared.RunService.Stepped:Connect(function(step)
    Player.UpdatePhysics(step)
end)

-- 4. Vòng lặp Render (RenderStepped)
local frames = 0
local currentFPS = 60
local lastFPSUpdate = tick()
local expTime = 999 * 24 * 60 * 60

local renderConn = Shared.RunService.RenderStepped:Connect(function(step)
    local now = tick()
    local Camera = Shared.Camera
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local camPos = Camera.CFrame.Position

    -- Cập nhật FPS & Watermark
    frames = frames + 1
    if now - lastFPSUpdate >= 1 then
        currentFPS = math.floor(frames / (now - lastFPSUpdate))
        frames = 0
        lastFPSUpdate = now
        local days = math.floor(expTime / 86400)
        local hours = math.floor((expTime % 86400) / 3600)
        local mins = math.floor((expTime % 3600) / 60)
        local secs = expTime % 60
        if Shared.UI_Elements.Watermark then
            Shared.UI_Elements.Watermark.Text = string.format("RIVALS ● %d FPS ● Expire in: %02dd %02dh %02dm %02ds", currentFPS, days, hours, mins, secs)
        end
        if UI.GetMenuConnected and UI.GetMenuConnected() then
            if UI.StatusText then
                UI.StatusText.Text = string.format(
                    "<font color=\"#00ff00\">● CONNECTED</font>   -   EXP %dd %dh %dm %ds   -   FPS %d"
                        .. "   -   BLOCKED %d",
                    days, hours, mins, secs, currentFPS, (Shield and Shield.Blocks) or 0)
            end
            if UI.UpdateWatermarkColor then
                UI.UpdateWatermarkColor(Color3.fromRGB(0, 255, 0))
            end
        else
            if UI.StatusText then
                UI.StatusText.Text = "<font color=\"#ffffff\">● Rivals Menu</font>   <font color=\"#666677\">/</font>   <font color=\"#aaaaaa\">Login</font>"
            end
            if UI.UpdateWatermarkColor then
                UI.UpdateWatermarkColor(Color3.fromRGB(255, 215, 0))
            end
        end
    end

    -- Cập nhật Player Mods (Speed, Jump, Fly, SpinBot, Underground)
    Player.UpdatePlayer(step)

    -- Cập nhật Aim & ESP
    Aim.UpdateAim(step, center)
    ESP.UpdateESP(camPos, center)
end)

-- 5. Anti-AFK
local afkConn = Shared.LocalPlayer.Idled:Connect(function()
    if Shared.VirtualUser then
        pcall(function()
            Shared.VirtualUser:CaptureController()
            Shared.VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- 6. Dọn dẹp tài nguyên
UI.ScreenGui.Destroying:Connect(function()
    pcall(function() renderConn:Disconnect() end)
    pcall(function() steppedConn:Disconnect() end)
    pcall(function() afkConn:Disconnect() end)

    pcall(function() Aim.FOVring:Remove() end)
    pcall(function() Aim.AimSnaplineDraw:Remove() end)
    pcall(function() Aim.AimWarnText:Remove() end)
    for _, draw in pairs(Aim.CrosshairDraws) do
        pcall(function() draw:Remove() end)
    end
    for target, _ in pairs(ESP.ESPTable) do
        pcall(function() ESP.removeESP(target) end)
    end
    if ESP.ChamsFolder and ESP.ChamsFolder.Parent then
        pcall(function() ESP.ChamsFolder:Destroy() end)
    end
    Player.ResetHitboxes()
end)

-- 7. Hoàn tất khởi tạo
UI.UpdateTabDots()
UI.ApplyTheme()
task.wait(0.1)
pcall(function() UI.ScreenGui.Parent = Shared.parentGui end)
Shared.SendNotification("System", "Rivals Pro Menu v2.14.0 đã sẵn sàng!")
