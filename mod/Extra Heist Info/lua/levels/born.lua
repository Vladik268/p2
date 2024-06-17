local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
---@type ParseTriggerTable
local triggers = {
    [101034] = { id = "MikeDefendTruck", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033, waypoint = { position_by_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100483, 1350) }, hint = Hints.Defend },
    [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
    [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

    [101535] = { id = "MikeDefendGarage", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532, waypoint = { position_by_element_and_remove_vanilla_waypoint = 101445 }, hint = Hints.Defend },
    [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
    [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker },

    [101048] = { time = 12, id = "ObjectiveDelay", icons = { Icon.Wait }, hint = Hints.Wait }
}
if EHI:IsClient() then
    triggers[101034].client = { time = 80, random_time = 10, special_function = SF.UnpauseTrackerIfExists }
    triggers[101535].client = { time = 90, random_time = 30, special_function = SF.UnpauseTrackerIfExists }
end

---@type ParseAchievementTable
local achievements =
{
    born_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101048] = { status = Status.Objective, class = TT.Achievement.Status },
            [101001] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [101022] = { status = Status.Objective, special_function = SF.SetAchievementStatus },
            [100728] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Truck
            [101589] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Garage
            [101446] = { status = Status.Objective, special_function = SF.SetAchievementStatus }, -- Garage done
            [102777] = { special_function = SF.SetAchievementComplete },
            [102779] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill = 3,
        mayhem_or_above = 4
    })
    other[100015] = { chance = 20, time = 1 + 5 + 30, on_fail_refresh_t = 30, on_success_refresh_t = 20 + 5 + 30, id = "Snipers", class = TT.Sniper.Loop, sniper_count = sniper_count }
    other[100517] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 20%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +20%
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, nil, { Icon.Defend })
EHI:ShowLootCounter({ max = 9 })

local tbl =
{
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small/001 (Bunker)
    [101086] = { remove_vanilla_waypoint = 101562, child_units = { 100776, 101226, 101469, 101472, 101473 } },

    -- Inside the bunker
    -- Grenades
    [100776] = { f = "IgnoreChildDeployable" },
    [101226] = { f = "IgnoreChildDeployable" },
    [101469] = { f = "IgnoreChildDeployable" },
    -- Ammo
    [101472] = { f = "IgnoreChildDeployable" },
    [101473] = { f = "IgnoreChildDeployable" }
}
EHI:UpdateUnits(tbl)

EHI:SetMissionDoorData({
    -- Workshop
    [Vector3(-3798.92, -1094.9, -6.52779)] = 101580,

    -- Safe with a bike mask
    [Vector3(1570.02, -419.693, 185.724)] = EHI:GetInstanceElementID(100007, 4850),
    [Vector3(1570.02, -419.693, 585.724)] = EHI:GetInstanceElementID(100007, 5350)
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "biker_mike_in_the_trailer", times = 1 },
        {
            random =
            {
                seat =
                {
                    { amount = 6000, name = "biker_seat_collected" }
                },
                skull =
                {
                    { amount = 8000, name = "biker_skull_collected" }
                },
                exhaust_pipe =
                {
                    { amount = 2000, name = "biker_exhaust_pipe_collected" }
                },
                engine =
                {
                    { amount = 3000, name = "biker_engine_collected" }
                },
                tools =
                {
                    { amount = 2000, name = "biker_tools_collected" }
                },
                cola =
                {
                    { amount = 1000, name = "biker_cola_collected" },
                },
                garage =
                {
                    { amount = 3000, name = "biker_help_mike_garage" }
                }
            }
        },
        { amount = 3000, name = "biker_defend_mike" },
        { escape = 2500 }
    },
    loot_all = 500,
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
                            exhaust_pipe = true,
                            engine = true,
                            tools = true
                        },
                        max =
                        {
                            seat = true,
                            skull = true,
                            engine = true,
                            cola = true
                        }
                    },
                    biker_defend_mike = { min_max = 3 }
                },
                loot_all = { max = 9 }
            }
        }
    }
})