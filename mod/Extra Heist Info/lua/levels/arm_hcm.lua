local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local van_delay = 363/30
local triggers = {
    [100215] = { time = 120 + van_delay, hint = Hints.LootEscape },
    [100216] = { time = 100 + van_delay, hint = Hints.LootEscape },
    [100218] = { time = 80 + van_delay, hint = Hints.LootEscape },
    [100219] = { time = 60 + van_delay, hint = Hints.LootEscape },

    -- Heli
    [102200] = { time = 23, special_function = SF.SetTimeOrCreateTracker }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOption("show_escape_chance") then
    other[101620] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement, trigger_times = 1 }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 10)
    end)
end
if EHI:IsHost() and not EHI:IsPlayingCrimeSpree() then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [100668] = 100006, -- 1
        [102552] = 100007, -- 2
        [102053] = 100097, -- 8
        [102384] = 100100, -- 9
        [102559] = 100101, -- 10
        [102261] = 100226, -- 11
        [102592] = 100227 -- 12
    }
    local trucks_body = { 100021, 100022, 100023, 100024, 100025 }
    ---@param count number
    local function LootCounter(count)
        EHI:ShowLootCounterSynced({ max_random = count * 9 })
        local truck = 0
        local hook_function = tweak_data.ehi.functions.HookArmoredTransportUnit
        for disabled_unit_id, truck_id in pairs(trucks) do
            if managers.game_play_central:GetMissionDisabledUnit(disabled_unit_id) then
                truck = truck + 1
                hook_function(truck_id)
                if truck == count then
                    break
                end
            end
        end
        if truck ~= count then
            local wd = managers.worlddefinition
            for _, truck_id in ipairs(trucks_body) do
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
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101197] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101199] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[101204] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 35 + 30, on_fail_refresh_t = 30, on_success_refresh_t = 20 + 35 + 30, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[102200] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_by_element = 102650 } }
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } }
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