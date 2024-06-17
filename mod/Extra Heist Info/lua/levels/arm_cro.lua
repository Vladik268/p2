local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local van_delay = 674/30
local preload =
{
    { hint = Hints.LootEscape } -- Escape
}
local triggers = {
    [101880] = { run = { time = 120 + van_delay } },
    [101881] = { run = { time = 100 + van_delay } },
    [101882] = { run = { time = 80 + van_delay } },
    [101883] = { run = { time = 60 + van_delay } }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:IsHost() and not EHI:IsPlayingCrimeSpree() then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [100349] = 100006, -- 1
        [101862] = 100021, -- 3
        [101835] = 100022, -- 4
        [101834] = 100023, -- 5
        [101853] = 100025, -- 7
        [101836] = 100097, -- 8
        [101859] = 100100, -- 9
        [101860] = 100101, -- 10
        [101847] = 100226, -- 11
        [101837] = 100227 -- 12
    }
    local trucks_body = { 100007, 100024 }
    ---@param count number
    local function LootCounter(count)
        EHI:ShowLootCounterSynced({ max_random = count * 9 })
        local truck = 0
        local hook_function = tweak_data.ehi.functions.HookArmoredTransportUnit
        for enabled_unit_id, truck_id in pairs(trucks) do
            if managers.game_play_central:GetMissionEnabledUnit(enabled_unit_id) then
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
    other[102180] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[102181] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[102182] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } }
    other[100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
end
if EHI:GetOption("show_escape_chance") then
    other[100916] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 15)
    end)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100122] = { chance = 10, time = 60 + 1 + 25 + 35, on_fail_refresh_t = 35, on_success_refresh_t = 20 + 25 + 35, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100015] = EHI:CopyTrigger(other[100122], { time = 1 + 25 + 35 }, SF.AddTrackerIfDoesNotExist)
    other[100385] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100420] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[101934] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100418] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
local MinBags = EHI:GetValueBasedOnDifficulty({
    normal = 2,
    hard = 3,
    veryhard = 4,
    overkill_or_above = 5
})
EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
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