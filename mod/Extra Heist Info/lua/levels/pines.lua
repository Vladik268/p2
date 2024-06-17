---@class EHIPresentChance : EHITimedWarningChanceTracker
---@field super EHITimedWarningChanceTracker
EHIPresentChance = class(EHITimedWarningChanceTracker)
---@param amount number
function EHIPresentChance:SetChance(amount)
    EHIPresentChance.super.SetChance(self, amount)
    if amount <= 20 then
        self:StopTimer()
    end
end
local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local very_hard_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local SetChanceWhenTrackerExists = EHI:RegisterCustomSF(function(self, trigger, element, ...)
    if self._trackers:TrackerExists(trigger.merge_id) then
        self._trackers:SetChance(trigger.merge_id, element._values.chance)
    elseif self._trackers:TrackerExists(trigger.id) then
        self._trackers:SetChance(trigger.id, element._values.chance)
    else
        trigger.chance = element._values.chance
        self:CreateTracker(trigger)
    end
end)
local chance = { id = "PresentDropChance", merge_id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance, special_function = SetChanceWhenTrackerExists, hint = Hints.pines_Chance }
local PresentDropTimer = { "C_Vlad_H_XMas_Impossible", Icon.Wait }
local preload = {}
---@type ParseTriggerTable
local triggers = {
    [100109] = EHI:AddEndlessAssault(25),
    [100021] = EHI:AddEndlessAssault(180, "EndlessAssault2"),
    [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up, special_function = SF.SetTimeOrCreateTracker, hint = Hints.ScriptedBulldozer },
    [101001] = { time = 1200, chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = "EHIPresentChance", start_opened = true, hint = Hints.pines_ChanceReduction },
    [101002] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = true },
    [101003] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = true },
    [101004] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = true },
    [101045] = { additional_time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Heli, Icon.Wait }, hint = Hints.Wait },
    [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry" }, trigger_times = 1, hint = Hints.pines_Santa },
    [105102] = { time = 30, id = "HeliLoot", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootEscape },

    [101005] = chance,
    [101006] = chance,
    [101007] = chance,
    [101008] = chance
}
---@type ParseAchievementTable
local achievements =
{
    uno_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101471] = { max = 40, class = TT.Achievement.Progress },
            [104385] = { special_function = SF.IncreaseProgress }
        }
    }
}
if EHI:EscapeVehicleWillReturn("pines") then
    preload[1] = { id = "HeliLootTakeOff", icons = Icon.HeliWait, class = TT.Warning, hide_on_delete = true }
    -- Hooked to 105072 instead of 105076 to track the take off accurately
    triggers[105072] = { id = "HeliLootTakeOff", run = { time = 82 } }
end

local other = {}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
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
    other = other,
    preload = preload
})
EHI:ShowLootCounter({ max_bags_for_level = { mission_xp = 8000, xp_per_bag_all = 2000 }, no_max = true })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    loot_all = 2000,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objective = true
            },
            max_level = true,
            max_level_bags_with_objective = true
        }
    }
})