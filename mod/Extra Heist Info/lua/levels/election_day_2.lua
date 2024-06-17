local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other =
{
    [100116] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:IsLootCounterVisible() then
    other[100107] = { special_function = SF.CustomCode, trigger_times = 1, f = function()
        EHI:ShowLootCounterNoChecks({
            max = 6,
            max_random = 7
        })
    end}
    other[100109] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:RandomLootDeclined(7)
    end) }
    other[107260] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:RandomLootSpawned(7)
    end) }
end

EHI:ParseTriggers({
    other = other
})
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [103064] = { remove_vanilla_waypoint = 103082 },
    [103065] = { remove_vanilla_waypoint = 103083 },
    [103066] = { remove_vanilla_waypoint = 103084 }
}
EHI:UpdateUnits(tbl)
EHI:ShowAchievementLootCounter({
    achievement = "bob_4",
    max = 6,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = "money"
    }
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 8000, stealth = true, timer = 300 },
            { amount = 14000, stealth = true },
            { amount = 18000, loud = true }
        }
    },
    loot =
    {
        money = 500,
        gold = 1000
    },
    total_xp_override =
    {
        params =
        {
            escape =
            {
                loot =
                {
                    money = { max = 6 },
                    gold = { max = 7, no_loud_xp = true }
                }
            }
        }
    }
})