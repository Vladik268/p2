local EHI, EM = EHI, managers.ehi_manager
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
EHI._cache.street_new = true
dofile(EHI.LuaPath .. "levels/run.lua")
-- Triggers
EM:UnhookTrigger(100144) -- Does not work in reworked version
EM:UnhookTrigger(102876) -- Needs to be reworked -> 1st gas can
local triggers =
{
    -- 1028762 -> Creates Fire tracker -> copy of 100144
    -- 1028761 -> Runs original trigger in run.lua
    -- 1 -> Increases Gas count (original trigger in run.lua)
    [102876] = { special_function = SF.Trigger, data = { 1028762, 1028761, 1 } },
    [1028762] = { id = "GasAmount", class = "EHIGasTracker", hint = EHI.Hints.run_Gas }
}
if EHI:MissionTrackersAndWaypointEnabled() then
    triggers[102876].data[4] = 3
end

---@type ParseAchievementTable
local achievements =
{
    run_9 =
    {
        elements =
        {
            [100145] = { special_function = SF.SetAchievementFailed }
        }
    },
    str_speedrun =
    {
        -- Difficulty is bugged, difficulty_overkill is not OVERKILL!, it is Very Hard
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [102426] = { time = 817, class = TT.Achievement.Base },
            [100553] = { special_function = SF.SetAchievementComplete }
        }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "street_new_achievements", { run_9 = true })

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})