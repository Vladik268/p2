local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [101176] = { time = 67 + 400/30, id = "WinchInteract", icons = { Icon.Heli, Icon.Winch }, hint = Hints.Winch },
    [106390] = { time = 6 + 30 + 25 + 15 + 2.5, id = "C4", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },
    -- 6s delay before Bile speaks
    -- 30s delay before random logic
    -- 25s delay to execute random logic
    -- Random logic has defined 2 heli fly ins
    -- First is shorter (6.5 + 76/30) 76/30 => 2.533333 (rounded to 2.5 in Mission Script)
    -- Second is longer (15 + 76/30)
    -- Second animation is counted in this trigger, the first is in trigger 100578.
    -- If the first fly-in is selected, the tracker is updated to reflect that

    [100647] = { time = 10, id = "SantaTalk", icons = { "pd2_talk" }, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Wait },
    [100159] = { time = 5 + 7 + 7.3, id = "Escape", icons = { Icon.Escape }, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Escape },

    [100578] = { time = 9, id = "C4", icons = { Icon.Heli, Icon.C4, Icon.Goto }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.C4Delivery }
}

---@type ParseAchievementTable
local achievements =
{
    moon_4 =
    {
        elements =
        {
            [100107] = { max = 2, class = TT.Achievement.Progress, trigger_times = 1 },
            [104219] = { special_function = SF.IncreaseProgress }, -- Chains
            [104220] = { special_function = SF.IncreaseProgress } -- Dallas
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 45 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 1,
        overkill_or_above = 2
    })
    other[100015] = { time = 1 + 10 + 35, on_fail_refresh_t = 35, on_success_refresh_t = 20 + 10 + 35, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, single_sniper = sniper_count == 1, sniper_count = sniper_count }
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints({
    -- Drill WP in the tech store
    [100241] = true,

    -- Fix Jewelry Store PC hack WP
    [100828] = true,

    -- Drill WP in the cage (shoe objective)
    [100664] = true
})
EHI:ShowAchievementLootCounter({
    achievement = "moon_5",
    max = 9,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = { "money", "diamonds" }
    },
    difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
})
EHI:ShowLootCounter({ max = 12 })

EHI:UpdateUnits({
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    --Jewelry Store
    [105874] = { remove_vanilla_waypoint = 100776 }
})
EHI:AddXPBreakdown({
    objectives =
    {
        {
            random =
            {
                max = 3,
                shoe_storage =
                {
                    { amount = 1000, name = "shoe_storage_enter" },
                    { amount = 500, name = "shoe_collected" }
                },
                shoe_backroom =
                {
                    { amount = 4000, name = "shoe_backroom_enter" },
                    { amount = 500, name = "shoe_collected" }
                },
                jewelry =
                {
                    { amount = 1500, name = "pc_hack" },
                    { amount = 500, name = "necklace_collected" }
                },
                toy =
                {
                    { amount = 4000, name = "toy_found" },
                    { amount = 800, name = "toy_collected" }
                },
                vr =
                {
                    { amount = 6000, name = "vault_drill_done" },
                    { amount = 500, name = "vr_collected" }
                },
                wine =
                {
                    { amount = 800, name = "wine_collected" }
                }
            }
        },
        { amount = 500, name = "flare" },
        { amount = 1000, name = "c4_drop" },
        { amount = 1000, name = "c4_set_up" },
        { amount = 1000, name = "heli_arrival" },
        { amount = 500, name = "wires_attached" }
    },
    loot =
    {
        money = 1000,
        diamonds = 1000
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    random =
                    {
                        min =
                        {
                            shoe_storage = true,
                            jewelry = true,
                            wine = true
                        },
                        max =
                        {
                            shoe_backroom = true,
                            toy = true,
                            vr = true
                        }
                    }
                },
                loot =
                {
                    money = { max = 3 },
                    diamonds = { max = 6 }
                }
            }
        }
    }
})