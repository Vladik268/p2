local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in WankerCar
    [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = Icon.CarEscape, hint = Hints.LootEscape },
    -- Wanker car
    [EHI:GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },

    -- In CoreWorldInstanceManager:
    -- Mayan Door Open
    -- Exploding car
    -- Thermite in Front Game
    -- Thermite in Wine Cellar Door
    -- Safe Hack
    -- Heli Escape
}

EHI:ShowAchievementLootCounter({
    achievement = "fex_10",
    max = 21,
    load_sync = function(self)
        self._loot:SyncSecuredLoot("fex_10")
    end,
    show_loot_counter = true,
    loot_counter_on_fail = true,
    silent_failed_on_alarm = true
})

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, single_player = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL) }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102850] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[103046] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102725] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
local stealth_objectives =
{
    { amount = 1000, name = "mex4_found_bulucs_office" },
    { amount = 1000, name = "mex4_found_inner_sanctum" },
    { amount = 1000, name = "mex4_discover_keycard_holder_mask_list", optional = true },
    { amount = 1000, name = "mex4_found_keycard", optional = true },
    { amount = 1000, name = "mex4_inner_sanctum_open" },
    { amount = 1000, name = "mex4_codex_room_open" },
    { amount = 10000, name = "mex4_bulucs_office_open" },
    { amount = 1000, name = "mex4_interacted_with_safe" },
    { amount = 2000, name = "mex4_contact_list_stolen" }
}
local loud_objectives =
{
    { amount = 1000, name = "mex4_found_bulucs_office" },
    { amount = 2000, name = "mex4_found_inner_sanctum" },
    { amount = 2000, name = "mex4_found_all_bomb_parts_hack_start" },
    { amount = 2000, name = "mex4_inner_sanctum_open_bomb" },
    { amount = 3000, name = "mex4_saw_placed" },
    { amount = 3000, name = "saw_done" },
    { amount = 4000, name = "mex4_bulucs_office_open" },
    { amount = 1000, name = "mex4_interacted_with_safe" },
    { escape = 1000 }
}
local total_xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = 0, max = 21 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        custom =
        {
            {
                name = "stealth",
                additional_name = "mex4_car_escape",
                tactic =
                {
                    objectives = stealth_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives =
                    {
                        { amount = 2000, name = "mex4_found_car_keys" },
                        { escape = 2000 }
                    }
                }
            },
            {
                name = "stealth",
                additional_name = "mex4_boat_escape",
                tactic =
                {
                    objectives = stealth_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives =
                    {
                        { escape = 1000 }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "mex4_car_escape",
                tactic =
                {
                    objectives = loud_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives_with_pos =
                    {
                        { objective = { amount = 1000, name = "mex4_contact_list_stolen_car_escape" }, pos = 9 },
                        { objective = { amount = 1000, name = "mex4_turret_discovered_car_escape" }, pos = 10 },
                        { objective = { amount = 3000, name = "mex4_turret_destroyed_car_escape" }, pos = 11 }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "mex4_heli_escape",
                tactic =
                {
                    objectives = loud_objectives,
                    loot_all = { amount = 500 },
                    total_xp_override = total_xp_override
                },
                objectives_override =
                {
                    add_objectives_with_pos =
                    {
                        { objective = { amount = 3000, name = "mex4_flare_lit_heli_escape" }, pos = 9 }
                    }
                }
            }
        }
    }
})