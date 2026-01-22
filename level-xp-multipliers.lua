-- level_xp_multipliers.lua
-- Per-level XP multipliers module for ALE / AzerothCore Lua
-- Multiplicative with other XP modifiers (applies on XP gain).

local MODULE_NAME = "LevelXPMultipliers"

-- Table of per-level multipliers. Keys are current level (integer).
-- Example: if you want XP gained at level 40 to 41 to be 9.52x, set [40] = 9.52
-- Any level not present defaults to 1.0
local perLevelMultipliers = {
    -- [40] = 9.52,
    -- [56] = 0.02,
}

-- Public API for runtime changes:
local function GetLevelMultiplier(level)
    if not level or type(level) ~= "number" then return 1.0 end
    return perLevelMultipliers[level] or 1.0
end

local function SetLevelMultiplier(level, multiplier)
    if not level or type(level) ~= "number" then
        error("SetLevelMultiplier: level must be a number")
    end
    multiplier = tonumber(multiplier) or 1.0
    if multiplier == 1.0 then
        perLevelMultipliers[level] = nil
    else
        perLevelMultipliers[level] = multiplier
    end
end

local function ClearAllMultipliers()
    perLevelMultipliers = {}
end

local function DumpMultipliers()
    local t = {}
    for lvl, mult in pairs(perLevelMultipliers) do
        t[#t+1] = string.format("%d -> %.6g", lvl, mult)
    end
    table.sort(t)
    return t
end

-- Hooking XP gain:
-- Signature: function(event, player, amount, victim)
-- Return a number to override the final XP amount.
local PLAYER_EVENT_ON_GAIN_XP = 12

local function OnPlayerGainXP(event, player, amount, victim)
    -- basic defensive checks
    if not player or type(amount) ~= "number" then
        return amount
    end

    -- Safely get level from player object
    local level
    if type(player.GetLevel) == "function" then
        level = player:GetLevel()
    else
        -- If GetLevel not present, try direct field access (unlikely)
        level = player.level or player.Level
    end

    if type(level) ~= "number" then
        return amount
    end

    -- clamp to 1..80
    if level < 1 then level = 1 end
    if level > 80 then level = 80 end

    local mult = GetLevelMultiplier(level) or 1.0
    if mult == 1.0 then
        return amount
    end

    -- Multiply and round to nearest integer
    local newAmount = math.floor(amount * mult + 0.5)
    return newAmount
end

-- Register the event (try common RegisterPlayerEvent)
if RegisterPlayerEvent and type(RegisterPlayerEvent) == "function" then
    RegisterPlayerEvent(PLAYER_EVENT_ON_GAIN_XP, OnPlayerGainXP)
else
    -- fallback to global table lookup
    local reg = _G and _G.RegisterPlayerEvent
    if reg and type(reg) == "function" then
        reg(PLAYER_EVENT_ON_GAIN_XP, OnPlayerGainXP)
    else
        print(MODULE_NAME .. ": Could not register player XP event — RegisterPlayerEvent missing")
    end
end

-- Expose API in global table so admins / other modules can call
_G.LevelXPMultipliers = _G.LevelXPMultipliers or {}
_G.LevelXPMultipliers.GetLevelMultiplier = GetLevelMultiplier
_G.LevelXPMultipliers.SetLevelMultiplier = SetLevelMultiplier
_G.LevelXPMultipliers.ClearAllMultipliers = ClearAllMultipliers
_G.LevelXPMultipliers.DumpMultipliers = DumpMultipliers
_G.LevelXPMultipliers._internal_table = perLevelMultipliers -- debug only

-- Debug: Print that the module loaded
-- print(MODULE_NAME .. ": loaded")
