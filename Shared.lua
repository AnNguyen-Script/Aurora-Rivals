-- ============================================================
-- MODULAR RIVALS | MODULE: SHARED ENVIRONMENT
-- ============================================================
local Shared = {}

-- Fastcall shims (Không tốn local registers)
if not table.clear then table.clear = function(t) for k in pairs(t) do t[k] = nil end end end
if not Vector3.zero then Vector3.zero = Vector3.new(0, 0, 0) end

-- Pre-cached native inputs
Shared.mouse1click_fn = (type(mouse1click) == "function" and mouse1click) or nil
Shared.VirtualInputManager = nil
pcall(function() Shared.VirtualInputManager = game:GetService("VirtualInputManager") end)

Shared.mousemoverel = mousemoverel or (Input and Input.MouseMoveRel) or function(x, y)
    if typeof(mouse_moverel) == "function" then
        mouse_moverel(x, y)
    end
end

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
    local newCam = Shared.Workspace.CurrentCamera
    if newCam then Shared.Camera = newCam end
end)

-- Tracking Tables
Shared.UI_Elements = {}
Shared.isMenuConnected = false
Shared.SendNotification = function(title, text) end -- Sẽ được UI ghi đè khi khởi tạo
Shared.ThemeObjects = { Panels = {}, Toggles = {}, SliderFills = {}, Dropbox = {} }
Shared.SearchIndex = {}
Shared.TabActiveKeys = {}

-- Theme Presets
Shared.ThemePresets = {
    ["Midnight Purple"] = {
        Accent = Color3.fromRGB(155, 89, 235), AccentHover = Color3.fromRGB(175, 110, 255),
        AccentOn = Color3.fromRGB(165, 95, 245), AccentOff = Color3.fromRGB(45, 30, 60)
    },
    ["Emerald Forest"] = {
        Accent = Color3.fromRGB(46, 204, 113), AccentHover = Color3.fromRGB(66, 224, 133),
        AccentOn = Color3.fromRGB(46, 204, 113), AccentOff = Color3.fromRGB(20, 50, 35)
    },
    ["Sunset Blaze"] = {
        Accent = Color3.fromRGB(230, 80, 40), AccentHover = Color3.fromRGB(250, 100, 60),
        AccentOn = Color3.fromRGB(240, 90, 50), AccentOff = Color3.fromRGB(60, 30, 25)
    },
    ["Crimson Blood"] = {
        Accent = Color3.fromRGB(220, 45, 65), AccentHover = Color3.fromRGB(245, 65, 85),
        AccentOn = Color3.fromRGB(230, 55, 75), AccentOff = Color3.fromRGB(55, 22, 28)
    },
    ["Dark"] = {
        Accent = Color3.fromRGB(130, 90, 230), AccentHover = Color3.fromRGB(150, 110, 250),
        AccentOn = Color3.fromRGB(140, 100, 240), AccentOff = Color3.fromRGB(38, 30, 55)
    },
    ["Cyberpunk"] = {
        Accent = Color3.fromRGB(0, 255, 200), AccentHover = Color3.fromRGB(50, 255, 220),
        AccentOn = Color3.fromRGB(0, 255, 200), AccentOff = Color3.fromRGB(15, 50, 45)
    },
    ["Lavender Dream"] = {
        Accent = Color3.fromRGB(195, 115, 245), AccentHover = Color3.fromRGB(215, 135, 255),
        AccentOn = Color3.fromRGB(205, 125, 255), AccentOff = Color3.fromRGB(48, 34, 70)
    }
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
    STATIC_RAY_FILTER = {nil, nil}
}

-- Stealth Functions
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
end

-- Cấu hình toàn hệ thống (Settings)
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
    return Shared.ThemePresets[Shared.Settings.ThemeName] or Shared.ThemePresets["Dark"]
end

Shared.ColorList = {
    White = Color3.fromRGB(255, 255, 255),
    Red = Color3.fromRGB(255, 60, 60),
    Green = Color3.fromRGB(60, 255, 60),
    Blue = Color3.fromRGB(60, 150, 255),
    Yellow = Color3.fromRGB(255, 230, 60),
    Purple = Color3.fromRGB(180, 80, 255),
    Cyan = Color3.fromRGB(60, 240, 255)
}

local activePreset = Shared.GetActivePreset()
Shared.Theme = {
    MainBg = Color3.fromRGB(18, 18, 20),
    PanelBg = Color3.fromRGB(30, 30, 34),
    PanelHeader = Color3.fromRGB(34, 34, 42),
    Border = Color3.fromRGB(48, 48, 58),
    BorderFocus = activePreset.Accent,
    TextWhite = Color3.fromRGB(240, 240, 240),
    TextGray = Color3.fromRGB(130, 130, 148),
    TextDark = Color3.fromRGB(120, 120, 120),
    TopBarText = Color3.fromRGB(180, 180, 180),
    Accent = activePreset.Accent,
    AccentHover = activePreset.AccentHover,
    ToggleOn = activePreset.AccentOn,
    ToggleOff = Color3.fromRGB(45, 45, 50),
    AccentOn = activePreset.AccentOn or Color3.fromRGB(255, 255, 255),
    AccentOff = Color3.fromRGB(45, 45, 50),
    KnobOn = Color3.fromRGB(18, 18, 20),
    KnobOff = Color3.fromRGB(180, 180, 180),
    DotGreen = Color3.fromRGB(0, 255, 0),
    DotRed = Color3.fromRGB(255, 50, 50),
    SliderBg = Color3.fromRGB(36, 36, 46),
    SliderFill = activePreset.Accent,
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium
}

setmetatable(Shared.Theme, {
    __index = function(t, k)
        if k == "DotGreen" then return Color3.fromRGB(0, 255, 0)
        elseif k == "DotRed" then return Color3.fromRGB(255, 50, 50)
        elseif k == "KnobOn" then return Color3.fromRGB(18, 18, 20)
        elseif k == "KnobOff" then return Color3.fromRGB(180, 180, 180)
        elseif k == "AccentOn" then return Color3.fromRGB(255, 255, 255)
        elseif k == "AccentOff" then return Color3.fromRGB(45, 45, 50)
        elseif k == "ToggleOn" then return Color3.fromRGB(255, 255, 255)
        elseif k == "ToggleOff" then return Color3.fromRGB(45, 45, 50)
        elseif k == "TextDark" then return Color3.fromRGB(120, 120, 120)
        elseif k == "TextWhite" then return Color3.fromRGB(240, 240, 240)
        elseif k == "PanelBg" then return Color3.fromRGB(30, 30, 34)
        elseif k == "MainBg" then return Color3.fromRGB(18, 18, 20)
        elseif k == "TopBarText" then return Color3.fromRGB(180, 180, 180)
        elseif k == "Font" then return Enum.Font.GothamMedium
        elseif k == "FontBold" then return Enum.Font.GothamBold
        end
        return Color3.fromRGB(255, 255, 255)
    end
})

Shared.MainFrame = nil
Shared.MainStroke = nil

Shared.ApplyTheme = function()
    local p = Shared.GetActivePreset()
    Shared.Theme.Accent = p.Accent
    Shared.Theme.AccentHover = p.AccentHover
    Shared.Theme.ToggleOn = p.AccentOn
    Shared.Theme.AccentOn = p.AccentOn
    Shared.Theme.BorderFocus = p.Accent
    Shared.Theme.SliderFill = p.Accent

    if Shared.MainStroke then
        Shared.MainStroke.Color = p.Accent
    end

    for _, obj in pairs(Shared.ThemeObjects.Panels) do
        if obj and obj.Parent then obj.BorderColor3 = Shared.Theme.Border end
    end
    for _, item in pairs(Shared.ThemeObjects.Toggles) do
        if item and item.Box and item.Box.Parent then
            local isKeyActive = Shared.Settings[item.Key]
            item.Box.BackgroundColor3 = isKeyActive and p.AccentOn or Shared.Theme.ToggleOff
            if item.Dot then
                item.Dot.Position = isKeyActive and UDim2.new(1, -15, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)
                item.Dot.BackgroundColor3 = isKeyActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 115)
            end
        end
    end
    for _, fill in pairs(Shared.ThemeObjects.SliderFills) do
        if fill and fill.Parent then fill.BackgroundColor3 = p.Accent end
    end
    for _, db in pairs(Shared.ThemeObjects.Dropbox) do
        if db and db.Parent then db.BorderColor3 = p.Accent end
    end
end

return Shared
