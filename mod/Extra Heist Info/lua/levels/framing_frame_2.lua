local EHI = EHI
local SF = EHI.SpecialFunctions
local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [103712] = { time = 25, id = "HeliTrade", icons = Icon.HeliLootDrop, hint = EHI.Hints.Wait }
}

local other =
{
    [101705] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround, nil, nil, true),
    [102557] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104318] = { id = "Snipers", count = 2, chance_success = true, class = TT.Sniper.TimedChanceOnce }
    other[104319] = { id = "Snipers", count = 1, chance_success = true, class = TT.Sniper.TimedChanceOnce }
    other[104390] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 24)
    end)
end
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = 4, max = 9 }
            }
        }
    }
})