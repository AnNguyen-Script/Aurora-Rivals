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
    KeybindsOverlay = true,
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
