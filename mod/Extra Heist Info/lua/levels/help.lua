EHIorange5Tracker = class(EHIAchievementProgressTracker)
function EHIorange5Tracker:Finalize()
    if self._progress < self._max then
        self:SetFailed()
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },

    [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion }

    -- C4 WP is in CoreWorldInstanceManager
}

local mayhem_and_up = EHI:IsMayhemOrAbove()
---@type ParseAchievementTable
local achievements =
{
    orange_4 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, class = TT.Achievement.Base },
            [EHI:GetInstanceElementID(100461, 21700)] = { special_function = SF.SetAchievementComplete },
        },
        sync_params = { from_start = true }
    },
    orange_5 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [100279] = { max = 15, class = "EHIorange5Tracker", status_is_overridable = true, show_finish_after_reaching_target = true },
            [EHI:GetInstanceElementID(100471, 21700)] = { special_function = SF.SetAchievementFailed },
            [EHI:GetInstanceElementID(100474, 21700)] = { special_function = SF.IncreaseProgress },
            [EHI:GetInstanceElementID(100005, 12200)] = { special_function = SF.FinalizeAchievement }
        },
        sync_params = { from_start = true }
    }
}
local other =
{
    [101315] = EHI:AddAssaultDelay({}) -- 30s
}
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({
    max_bags_for_level =
    {
        mission_xp = 8000,
        xp_per_bag_all = 850,
        objective_triggers = { 102461 }
    },
    no_max = true
})

local tbl =
{
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [400003] = { ignore = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "prison_entered" },
        { escape = 8000 }
    },
    loot_all = 850,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            max_level = true,
            max_level_bags_with_objectives = true
        }
    }
})