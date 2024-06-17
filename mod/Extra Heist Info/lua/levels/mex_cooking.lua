local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local MethlabStart = { Icon.Methlab, Icon.Wait }
local MethlabRestart = { Icon.Methlab, Icon.Loop }
local MethlabPickup = { Icon.Methlab, Icon.Interact }
local element_sync_triggers =
{
    [103575] = { id = "CookingStartDelay", icons = MethlabStart, hook_element = 103573, hint = Hints.Restarting },
    [103576] = { id = "CookingStartDelay", icons = MethlabStart, hook_element = 103574, hint = Hints.Restarting },
    [EHI:GetInstanceElementID(100078, 55850)] = { id = "NextIngredient", icons = MethlabRestart, hook_element = EHI:GetInstanceElementID(100173, 55850), hint = Hints.mia_1_NextMethIngredient },
    [EHI:GetInstanceElementID(100078, 56850)] = { id = "NextIngredient", icons = MethlabRestart, hook_element = EHI:GetInstanceElementID(100173, 56850), hint = Hints.mia_1_NextMethIngredient },
    [EHI:GetInstanceElementID(100157, 55850)] = { id = "MethReady", icons = MethlabPickup, hook_element = EHI:GetInstanceElementID(100174, 55850), hint = Hints.mia_1_MethDone },
    [EHI:GetInstanceElementID(100157, 56850)] = { id = "MethReady", icons = MethlabPickup, hook_element = EHI:GetInstanceElementID(100174, 56850), hint = Hints.mia_1_MethDone }
}
local triggers =
{
    -- Also handles next ingredient when meth is picked up
    [EHI:GetInstanceElementID(100056, 55850)] = { time = 15, id = "NextIngredient", icons = MethlabRestart, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.mia_1_NextMethIngredient },
    [EHI:GetInstanceElementID(100056, 56850)] = { time = 15, id = "NextIngredient", icons = MethlabRestart, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.mia_1_NextMethIngredient }
}
if EHI:IsClient() then
    local cooking_start = { additional_time = 30, random_time = 10, id = "CookingStartDelay", icons = MethlabStart, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Restarting }
    local meth_ready = { additional_time = 10, random_time = 5, id = "MethReady", icons = MethlabPickup, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.mia_1_MethDone }
    local next_ingredient = { additional_time = 40, random_time = 5, id = "NextIngredient", icons = MethlabRestart, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.mia_1_NextMethIngredient }
    triggers[103573] = cooking_start
    triggers[103574] = cooking_start
    triggers[EHI:GetInstanceElementID(100173, 55850)] = next_ingredient
    triggers[EHI:GetInstanceElementID(100173, 56850)] = next_ingredient
    triggers[EHI:GetInstanceElementID(100174, 55850)] = meth_ready
    triggers[EHI:GetInstanceElementID(100174, 56850)] = meth_ready
end

local other =
{
    [101374] = EHI:AddAssaultDelay({ control = 3 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102495] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, single_sniper = EHI:IsDifficulty(EHI.Difficulties.Normal) }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102473] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[102485] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102480] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowAchievementLootCounter({
    achievement = "mex2_9",
    max = 25,
    show_finish_after_reaching_target = true,
    difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
})
EHI:ShowLootCounter({ max = 50 })
EHI:AddXPBreakdown({
    objectives =
    {
        { escape = 1000 }
    },
    loot_all = { amount = 6000, times = 50 },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = 3, max = 50 }
            }
        }
    }
})