local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers =
{
    [100103] = EHI:AddEndlessAssault({ 5, 10 })
}
local sync_triggers =
{
    [100558] = { id = "BileReturn", icons = Icon.HeliEscape, hint = Hints.LootEscape }
}
if EHI:IsClient() then
    triggers[100558] = { additional_time = 5, random_time = 5, id = "BileReturn", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
end

---@type ParseAchievementTable
local achievements =
{
    born_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100595] = { time = 120, class = TT.Achievement.Base },
            [101170] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("born_5", 120)
        end
    }
}

local other = {}
if EHI:IsLootCounterVisible() then
    other[100482] = EHI:AddLootCounter2(function()
        EHI:ShowLootCounterNoChecks({
            max = 9,
            offset = true,
            client_from_start = true
        })
    end)
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { base = sync_triggers }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "biker2_boss_dead" },
        { escape = 4000 }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = 1, max = 9 }
            }
        }
    }
})