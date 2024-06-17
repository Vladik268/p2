local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    [101235] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [100214] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100215] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100216] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOption("show_escape_chance") then
    other[100677] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 10)
    end)
end
if EHI:IsHost() and not EHI:IsPlayingCrimeSpree() then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [100872] = 100007, -- 2/2
        [100874] = 100021, -- 3/3
        [101805] = 100022, -- 4/4
        [100899] = 100023, -- 5/5
        [100900] = 100024, -- 9/6
        [100907] = 100025, -- 6/7
        [100913] = 100097, -- 7/8
        [100905] = 100100 -- 8/9
    }
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
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101231] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101947] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[102037] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } }
    other[100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101268 } }
    other[100216] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
end
EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
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