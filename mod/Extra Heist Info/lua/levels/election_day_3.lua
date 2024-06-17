local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local drill_spawn_delay = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery }
local CrashIcons = { Icon.PCHack, Icon.Fix, "pd2_question" }
if EHI:GetOption("show_one_icon") then
    CrashIcons = { Icon.Fix }
end
local CrashChanceTime = EHI:RegisterCustomSF(function(self, trigger, ...)
    if self._trackers:CallFunction2("CrashChance", "StartTimer", trigger.time) then
        self:CreateTracker(trigger)
    end
end)
local triggers = {
    [101284] = { chance = 50, id = "CrashChance", icons = { Icon.PCHack, Icon.Fix }, class = TT.Timed.Chance, hint = Hints.election_day_3_CrashChance, stop_timer_on_end = true },
    [103570] = { id = "CrashChance", special_function = SF.DecreaseChanceFromElement }, -- -25%
    [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
    [103572] = { time = 50, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime, special_function = CrashChanceTime },
    [103573] = { time = 40, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime, special_function = CrashChanceTime },
    [103574] = { time = 30, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime, special_function = CrashChanceTime },
    [103568] = { time = 60, id = "Hack", icons = { Icon.PCHack }, hint = Hints.Hack },
    [103585] = { id = "Hack", special_function = SF.RemoveTracker },

    [103478] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [103169] = drill_spawn_delay,
    [103179] = drill_spawn_delay,
    [103190] = drill_spawn_delay,
    [103195] = drill_spawn_delay,

    [103535] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion }
}
local other =
{
    [102735] = EHI:AddAssaultDelay({ control = 5 }),
    [102736] = EHI:AddAssaultDelay({ control = 15 }),
    [102737] = EHI:AddAssaultDelay({ control = 25 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local refresh_t = EHI:GetValueBasedOnDifficulty({
        normal = 60,
        hard = 50,
        veryhard_or_above = 40
    })
    other[100356] = { time = refresh_t, special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        if element:_check_mode() then
            if self._trackers:CallFunction2("Snipers", "SniperSpawnsSuccess", 2) then
                self._trackers:AddTracker({
                    id = "Snipers",
                    time = trigger.time,
                    refresh_t = trigger.time,
                    count = 2,
                    class = TT.Sniper.Timed
                })
            end
        end
    end)}
    other[100348] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100351] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:IsLootCounterVisible() then
    other[103293] = EHI:AddLootCounter3(function(self, ...)
        local count = self:CountInteractionAvailable("money_wrap")
        if count > 0 then
            EHI:ShowLootCounterNoChecks({ max = count })
        end
    end, true)
end

EHI:SetMissionDoorData({
    -- Vault Doors
    [Vector3(2350, -2320, 59.9998)] = 104556, -- Left
    [Vector3(2250, -3121, 59.9998)] = 104611, -- Right

    -- Gate inside the vault
    [Vector3(2493.96, -2793.65, 84.8657)] = { w_id = 104645, restore = true, unit_id = 101581 }
})
EHI:ParseTriggers({ mission = triggers, other = other })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 20000
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 12 }
            }
        }
    }
})