local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers =
{
    [100975] = { time = 5, id = "C4Pipeline", icons = { Icon.C4 }, hint = Hints.Explosion },

    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite },

    [101098] = { time = 5 + 7 + 2, id = "WalkieTalkie", icons = { Icon.Door }, hint = Hints.Wait },
    [100109] = { id = "WalkieTalkie", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100209, 10450)] = { time = 3, id = "KeygenHack", icons = { Icon.Tablet }, hint = Hints.Hack },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Oil }, hint = Hints.FuelTransfer }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 50 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

local required_bags = 6
local bag_multiplier = 2
if EHI:IsMayhemOrAbove() then
    required_bags = 9
    bag_multiplier = 3
end
local max_bags = required_bags + ((6 * bag_multiplier) + 8) -- (4 secondary wagons with 2 money bags); total 5 wagons, one is disabled
EHI:ShowLootCounter({ max = max_bags })
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "texas2_used_walkie_talkie" },
                { amount = 1000, name = "texas2_enter_rail_yard" },
                { amount = 1000, name = "texas2_got_inside_office" },
                { amount = 1000, name = "pc_hack" },
                { amount = 2000, name = "texas2_found_motion_sensor" },
                { amount = 3000, name = "texas2_motion_sensor_disabled" },
                { amount = 2000, name = "texas2_found_correct_wagon" },
                { amount = 5000, name = "fs_secured_required_bags" },
                { amount = 1000, name = "texas2_use_pa_system" },
                { amount = 2000, name = "texas2_loco_prepared" },
                { amount = 2000, name = "diamond_heist_found_keycard" },
                { amount = 3000, name = "texas2_rotated_the_turntable" },
                { escape = 1000 }
            },
            loot_all = 250,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        objectives =
                        {
                            texas2_found_correct_wagon = { min_max = 3 }
                        },
                        loot_all = { min = required_bags, max = max_bags }
                    }
                }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "texas2_used_thermite" },
                { amount = 1000, name = "ggc_c4_taken" },
                { amount = 3000, name = "texas2_blocked_train_tracks" },
                { amount = 1000, name = "texas2_got_inside_office" },
                { amount = 1000, name = "pc_hack" },
                { amount = 1000, name = "texas2_found_correct_wagon" },
                { amount = 5000, name = "fs_secured_required_bags" },
                { amount = 2000, name = "texas2_loco_prepared" },
                { amount = 1000, name = "texas2_crane_moved" },
                { amount = 2000, name = "texas2_crane_attached" },
                { amount = 5000, name = "texas2_loco_moved" },
                { amount = 1000, name = "texas2_loco_started" },
                { escape = 1000 }
            },
            loot_all = 250,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        objectives =
                        {
                            texas2_found_correct_wagon = { min_max = 3 }
                        },
                        loot_all = { min = required_bags, max = max_bags }
                    }
                }
            }
        }
    }
})