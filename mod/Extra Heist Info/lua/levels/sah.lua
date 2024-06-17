local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [100643] = { time = 30, id = "CrowdAlert", icons = { Icon.Alarm }, class = TT.Warning, hint = Hints.Alarm },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

    -- Heli Escape is in CoreWorldInstanceManager
}

---@type ParseAchievementTable
local achievements =
{
    sah_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { time = 300, class = TT.Achievement.Base },
            [101878] = { special_function = SF.SetAchievementComplete },
            [101400] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 1 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    -- Unused Grenade case
    [400178] = { f = "IgnoreDeployable" }
}
EHI:UpdateUnits(tbl)
local loot =
{
    black_tablet = 1000,
    mus_artifact = 1000
}
local xp_override =
{
    params =
    {
        min =
        {
            objectives = true,
            loot =
            {
                black_tablet = { times = 1 }
            }
        },
        no_max = true
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "vault_found" },
                { amount = 6000, name = "sah_entered_vault_code" },
                { amount = 4000, name = "sah_retrieved_tablet" },
                { escape = 1000 }
            },
            loot = loot,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 6000, name = "vault_found" },
                { amount = 10000, name = "sah_entered_vault_code" },
                { amount = 6000, name = "sah_retrieved_tablet" },
                { escape = 4000 }
            },
            loot = loot,
            total_xp_override = xp_override
        }
    }
})