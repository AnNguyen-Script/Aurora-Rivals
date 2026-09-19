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
