local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is 100215 and 100216
local triggers = {
    [100259] = { time = 120 + delay, hint = Hints.LootEscape },
    [100258] = { time = 100 + delay, hint = Hints.LootEscape },
    [100257] = { time = 80 + delay, hint = Hints.LootEscape },
    [100209] = { time = 60 + delay, hint = Hints.LootEscape },

    [100215] = { time = 674/30, special_function = SF.SetTimeOrCreateTracker },
    [100216] = { time = 543/30, special_function = SF.SetTimeOrCreateTracker }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOption("show_escape_chance") then
    other[104800] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 15)
    end)
end
if EHI:IsHost() and not EHI:IsPlayingCrimeSpree() then
    local trucks = { 100006, 100007, 100021, 100022, 100023, 100024, 100025, 100097, 100100, 100101, 100226, 100227 }
    ---@param count number
    local function LootCounter(count)
        EHI:ShowLootCounterSynced({ max_random = count * 9 })
        local truck = 0
        local wd = managers.worlddefinition
        local hook_function = tweak_data.ehi.functions.HookArmoredTransportUnit
        for _, truck_id in ipairs(trucks) do
            local unit = wd:get_unit(truck_id) --[[@as UnitBase?]]
            if unit and unit:damage() and unit:damage()._state and unit:damage()._state.graphic_group and unit:damage()._state.graphic_group.grp_truck then
                local state = unit:damage()._state.graphic_group.grp_truck
                if state[1] == "set_visibility" and state[2] then
                    truck = truck + 1
                    hook_function(truck_id)
                    if truck == count then
                        break
                    end
                end
            end
        end
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[104891] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[104892] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[104893] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100362] = EHI:CopyTrigger(other[100358], { single_sniper = true, sniper_count = 1 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100233 } }
    other[100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
    other[100216] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100020 } }
end
EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
local MinBags = EHI:GetValueBasedOnDifficulty({
    normal = 2,
    hard = 3,
    veryhard = 4,
    overkill_or_above = 5
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max = { loot_all = { min = MinBags, max = 16 } }
        }
    }
})