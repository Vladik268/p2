local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333, hint = Hints.Defend },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732, hint = Hints.Escape },
    [102324] = EHI:AddEndlessAssault(3)
}
if EHI:IsClient() then
    triggers[102368].client = { time = 120, random_time = 10 }
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[102370].client = { time = 35, random_time = 10 }
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
end

---@type ParseAchievementTable
local achievements =
{
    glace_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101732] = { status = Status.Find, class = TT.Achievement.Status },
            [105758] = { special_function = SF.SetAchievementFailed },
            [105756] = { status = Status.Ok, special_function = SF.SetAchievementStatus },
            [105759] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    },
    glace_10 =
    {
        elements =
        {
            [101732] = { max = 6, class = TT.Achievement.Progress },
            [105761] = { special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
            [105721] = { special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
        },
        sync_params = { from_start = true }
    },
    uno_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100765] = { status = Status.Destroy, class = TT.Achievement.Status },
            [103397] = { special_function = SF.SetAchievementComplete },
            [102323] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [101132] = EHI:AddAssaultDelay({ control = 59 }),
    [100487] = EHI:AddAssaultDelay({ special_function = SF.SetTimeOrCreateTracker }) -- 30s
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "green_bridge_prisoner_found" },
        { amount = 6000, name = "green_bridge_prisoner_escorted" },
        { amount = 6000, name = "green_bridge_prisoner_defended" },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 4 }
            }
        }
    }
})