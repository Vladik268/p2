local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100109] = { max = (ovk_and_up and 40 or 30), id = "EnemyDeathShowers", icons = { Icon.Kill }, flash_times = 1, class = TT.Progress, hint = Hints.Kills },
    [101339] = { id = "EnemyDeathShowers", special_function = SF.IncreaseProgress },

    [101221] = { time = 11, id = "Thermite1", icons = { Icon.Fire }, hint = Hints.Thermite },
    [101714] = { time = 11, id = "Thermite2", icons = { Icon.Fire }, hint = Hints.Thermite },
    [101715] = { time = 11, id = "Thermite3", icons = { Icon.Fire }, hint = Hints.Thermite },
    [101716] = { time = 11, id = "Thermite4", icons = { Icon.Fire }, hint = Hints.Thermite },

    [101815] = { time = 10, id = "MoveWalkway", icons = { Icon.Wait }, hint = Hints.Wait },

    [101137] = { max = 10, id = "EnemyDeathOutside", icons = { Icon.Kill }, flash_times = 1, class = TT.Progress, hint = Hints.Kills },
    [101412] = { id = "EnemyDeathOutside", special_function = SF.IncreaseProgress }
}

---@type ParseAchievementTable
local achievements =
{
    bph_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101742] = { max = 3, class = TT.Achievement.Progress, trigger_times = 1 },
            [101885] = { special_function = SF.SetAchievementFailed },
            [102171] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 1 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2, -- ???
        overkill_or_above = 1
    })
    other[100015] = { chance = 10, time = 1 + 15, on_fail_refresh_t = 15, on_success_refresh_t = 20 + 15, id = "Snipers", class = TT.Sniper.Loop, single_sniper = sniper_count == 1, sniper_count = sniper_count }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

-- 101399 units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer/001 (2050, -10250, 639.67)
EHI:UpdateUnits({ [101399] = { icons = { "C_Locke_H_HellsIsland_Another" }, hint = Hints.Wait } })

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    assault = {
        force_assault_start = true,
        wave_move_elements_block = { 101325, 100115 },
        fake_assault_block = true
    }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "bph_found_control_room" },
        { amount = 3000, name = "bph_opening_correct_cell" },
        { amount = 5000, name = "bph_follow_bain" },
        { amount = 1000, name = "bph_met_on_rooftop" },
        { amount = 3000, name = "bph_extended_bridge" },
        { amount = ovk_and_up and 4000 or 3000, name = "bph_helipad_is_accessible" }
    }
})