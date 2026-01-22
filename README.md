# mod-level-xp-multipliers

Per-level XP multipliers for ALE (AzerothCore Lua Engine, 3.3.5a). Apply a custom XP multiplier for each level (1–80). Multipliers are multiplicative with other XP modifiers (for example the "Individual XP" module).

Install
- Place `level_xp_multipliers.lua` in your ALE scripts folder and reload the script/server.
- - Probably `/env/dist/bin/lua_scripts` in your AzerothCore folder.
- On load it prints "LevelXPMultipliers: loaded".

Configure
Edit the `perLevelMultipliers` table inside the script. Only list levels you want to change; unspecified levels default to 1.0.

Example:
```
local perLevelMultipliers = {
    [40] = 9.52,   -- 9.52x while level 40
    [58] = 4.20,   -- 4.20x while level 58
    [59] = 6.9     -- 6.90x while level 59
}
```

Behavior
- Applies the multiplier corresponding to the player's current level when XP is awarded.
- Works by handling PLAYER_EVENT_ON_GIVE_XP (event id 12) and returning a modified XP amount.
- Multiplicative with other modifiers: final XP = base_xp * other_modifiers * per_level_multiplier.

Quick safety notes
- Lua uses double precision floats; avoid producing per-award XP > ~2e9 to prevent 32‑bit overflows in server code. Typical safe multipliers are roughly 0.01–1000.
- Extremely large or near-zero multipliers can break progression or trigger many level‑up events.
- Restrict runtime changes to admins/GMs.

Runtime API (optional)
The module exposes a small global API for admin scripts:
- LevelXPMultipliers.GetLevelMultiplier(level)
- LevelXPMultipliers.SetLevelMultiplier(level, multiplier)
- LevelXPMultipliers.ClearAllMultipliers()
- LevelXPMultipliers.DumpMultipliers()

License
This project is licensed under GPL-3.0.
