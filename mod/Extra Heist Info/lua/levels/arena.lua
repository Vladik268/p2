local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape }

    -- Pyro booth sequence is in CoreWorldInstanceManager
}

---@type ParseAchievementTable
local achievements =
{
    live_2 =
    {
        elements =
        {
            [100693] = { class = TT.Achievement.Status },
            [102704] = { special_function = SF.SetAchievementFailed },
            [100246] = { special_function = SF.SetAchievementComplete }
        }
    },
    live_3 =
    {
        elements =
        {
            [100304] = { time = 5, class = TT.Achievement.Unlock }
        }
    },
    live_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102785] = { class = TT.Achievement.Status },
            [100249] = { special_function = SF.SetAchievementComplete },
            [102694] = { special_function = SF.SetAchievementFailed },
        }
    },
    live_5 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100116, 4900)] = { class = TT.Achievement.Status },
            [102702] = { special_function = SF.SetAchievementFailed },
            [100265] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local max = 6
local required_bags = 3
local closets = 2
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    max = 12
    required_bags = 6
    closets = 3
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    max = 18
    required_bags = EHI:IsDifficulty(EHI.Difficulties.OVERKILL) and 9 or 12
    closets = 5
end
EHI:ShowLootCounter({ max = max })
local xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                alesso_find_c4 = { min_max = closets },
                loot_secured = { min = required_bags, max = max }
            }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "alesso_find_c4" },
                { amount = 2000, name = "c4_set_up" },
                { amount = 3000, times = 3, name = "alesso_pyro_set" },
                { amount = 1200, name = "loot_secured" }
            },
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 10000, name = "pc_hack" },
                { amount = 1000, name = "alesso_find_c4" },
                { amount = 2000, name = "c4_set_up" },
                { amount = 3000, times = 3, name = "alesso_pyro_set" },
                { amount = 1500, name = "loot_secured" }
            },
            total_xp_override = xp_override
        }
    }
})