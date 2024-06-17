local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [100128] = { time = 38, id = "WinchDropTrainA", icons = { Icon.Train, Icon.Winch, Icon.Goto }, hint = Hints.brb_WinchDelivery },
    [100164] = { time = 38, id = "WinchDropTrainB", icons = { Icon.Train, Icon.Winch, Icon.Goto }, hint = Hints.brb_WinchDelivery },

    [100654] = { time = 120, id = "Winch", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Winch },
    [100655] = { id = "Winch", special_function = SF.PauseTracker },
    [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
    -- Cutter and C4 handled in CoreWorldInstanceManager

    [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire }, hint = Hints.Thermite },

    [100275] = { time = 20, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [100142] = { time = 5, id = "C4Vault", icons = { Icon.C4 }, hint = Hints.Explosion }
}

---@type ParseAchievementTable
local achievements =
{
    brb_8 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [101136] = { max = 12, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, special_function = SF.AddAchievementToCounter, data = {
                counter = {
                    check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
                    loot_type = "gold"
                }
            }}
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100955] = EHI:AddAssaultDelay({ control_additional_time = 45, random_time = 15, special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        if (EHI:IsHost() and element:counter_value() ~= 0) or self._trackers:TrackerExists(trigger.id) then
            return
        end
        self:CreateTracker(trigger)
    end) })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[EHI:GetInstanceElementID(100025, 16400)] = { id = "Snipers", class = TT.Sniper.Count, single_sniper = true }
    other[EHI:GetInstanceElementID(100090, 16400)] = { id = "Snipers", class = TT.Sniper.Count, single_sniper = true }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[EHI:GetInstanceElementID(100056, 16400)] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[EHI:GetInstanceElementID(100027, 16400)] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100026, 16400)] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
EHI:ShowLootCounter({ max = 24 })

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "vault_found" },
        { amount = 8000, name = "vault_open" },
        { amount = 4000, name = "brb_medallion_taken" }
    },
    loot_all = 400,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 24 } -- 3 bags in the deposit boxes (4 instances), random position, guaranteed + 12 gold in the vault
            }
        }
    }
})