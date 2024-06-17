local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ control = 60 + 1, trigger_times = 1 })
}

---@type ParseAchievementTable
local achievements =
{
    cac_24 =
    {
        elements =
        {
            [101282] = { time = 60, class = TT.Achievement.Base },
            [101285] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

EHI:ParseTriggers({
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1500, name = "big_oil_intel_pickup", times = 3, optional = true },
        { amount = 6000, name = "big_oil_safe_open" },
        { escape = 6000 }
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            max =
            {
                objectives = true
            }
        }
    }
})