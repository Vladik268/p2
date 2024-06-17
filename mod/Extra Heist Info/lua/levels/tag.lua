local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local triggers = {
    [101335] = { time = 7, id = "C4BasementWall", icons = { Icon.C4 }, hint = Hints.Explosion },
    [101968] = { time = 10, id = "LureDelay", icons = { Icon.Wait }, hint = Hints.Wait }
}

---@type ParseAchievementTable
local achievements =
{
    tag_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { class = TT.Achievement.Status },
            [100609] = { special_function = SF.SetAchievementComplete },
            [100617] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    },
    tag_10 =
    {
        elements =
        {
            [100107] = { status = Status.Mark, class = TT.Achievement.Status },
        },
        preparse_callback = function(data)
            for i = 4550, 5450, 900 do
                data.elements[EHI:GetInstanceElementID(100319, i)] = { special_function = SF.SetAchievementFailed }
                data.elements[EHI:GetInstanceElementID(100321, i)] = { status = Status.Ok, special_function = SF.SetAchievementStatus }
                data.elements[EHI:GetInstanceElementID(100282, i)] = { special_function = SF.SetAchievementComplete }
            end
        end,
        sync_params = { from_start = true }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "correct_pc_hack", times = 1 },
        { amount = 2000, name = "breakin_feds_found_garret_office" },
        { amount = 4000, name = "breakin_feds_lure" },
        { amount = 1000, name = "breakin_feds_entered_office", times = 1 },
        { amount = 1000, name = "breakin_feds_safe_found" }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            no_max = true
        }
    }
})