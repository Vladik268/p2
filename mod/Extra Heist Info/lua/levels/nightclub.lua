local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local AssetLootDropOff = Icon.CarLootDrop
if EHI:GetOption("show_one_icon") then
    AssetLootDropOff = { Icon.LootDrop }
end
local preload =
{
    { hint = Hints.LootEscape } -- Escape
}
---@type ParseTriggerTable
local triggers = {
    -- Time before escape is available
    [102808] = { run = { time = 65 } },
    [102811] = { run = { time = 80 } },
    [103591] = { run = { time = 126 } },
    [102813] = { run = { time = 186 } },
    [100797] = { run = { time = 240 } },
    [100832] = { run = { time = 270 } },

    -- Fire
    [101412] = { time = 300, id = "Fire", timer_id = "Fire1", icons = { Icon.Fire }, class = TT.Group.Warning, waypoint = { position_by_unit = 101758 }, hint = Hints.Fire },
    [101453] = { time = 300, id = "Fire", timer_id = "Fire2", icons = { Icon.Fire }, class = TT.Group.Warning, waypoint = { position_by_unit = 101759 }, hint = Hints.Fire },

    -- Asset
    [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = AssetLootDropOff, waypoint = { position_by_element = 103152 }, hint = Hints.Loot }
    -- 20: Base Delay
    -- 40/3: Animation finish delay
    -- Total 33.33 s
}
local BaseAssaultDelay = 3.5 + 2.5 + 3 + 2
local other =
{
    [101159] = EHI:AddAssaultDelay({ control = 12 + BaseAssaultDelay }),
    [101166] = EHI:AddAssaultDelay({ control = 10 + BaseAssaultDelay }),
    [101167] = EHI:AddAssaultDelay({ control = 15 + BaseAssaultDelay })
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        -- Civilian kills do not count towards escape chance
        -- Reported in: https://steamcommunity.com/app/218620/discussions/14/5487063042655462839/
        managers.ehi_escape:AddEscapeChanceTracker(false, 25, 0)
    end)
    other[104285] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    preload = preload
}, "Escape", Icon.CarEscape)
local min_money = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 1,
    veryhard_or_above = 2
})
local max_money = min_money * 2
local max_bags = max_money + EHI:GetValueBasedOnDifficulty({
    normal = 4,
    hard = 5,
    veryhard = 7,
    overkill_or_above = 9
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 10000, stealth = true },
            { amount = 8000, loud = true },
            { amount = 4000, loud = true, c4_used = true }
        }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            escape =
            {
                loot_all = { min = min_money, max = max_bags }
            }
        }
    }
})