local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    -- Time before the tear gas is removed
    [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073, hint = Hints.Teargas }
}
local triggers = {
    [102949] = { time = 17, id = "HeliDropWait", icons = { Icon.Wait }, hint = Hints.Wait },

    [102335] = { time = 60, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = EHI:GetInstanceElementID(100029, 16950) }, hint = Hints.Thermite }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter

    [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance" }, hint = Hints.Teargas },
    [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), class = TT.Chance, hint = Hints.vit_Teargas },
    -- Disabled in the mission script
    --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
    [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
    [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },

    [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning, hint = Hints.hox_1_Car },

    [101504] = { time = 12 + 11, id = "AirlockOpenInside", icons = { Icon.Door }, hint = Hints.Wait },

    [102095] = { special_function = SF.Trigger, data = { 1020951, 1020952 } },
    [1020951] = { time = 26, id = "AirlockOpenOutside", icons = { Icon.Door }, condition_function = CF.IsStealth, hint = Hints.Wait },
    [1020952] = EHI:AddEndlessAssault(26, "AirlockOpenOutsideEndlessAssault", true),

    [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 101914 }, hint = Hints.Escape } -- 30s delay + 26s escape zone delay
}
if EHI:IsClient() then
    triggers[102073] = { additional_time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Teargas }
    triggers[103500] = EHI:ClientCopyTrigger(triggers[102104], { time = 26 })
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 1,
        overkill_or_above = 2
    })
    other[100314] = { special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        if EHI:IsHost() and element:counter_value() ~= 0 then
            return
        end
        local t = 20 + 10 + 25
        self._trackers:AddTracker({
            id = "Snipers",
            chance = 10,
            time = t,
            on_fail_refresh_t = 25,
            on_success_refresh_t = t,
            sniper_count = trigger.sniper_count,
            single_sniper = trigger.sniper_count == 1,
            class = TT.Sniper.Loop
        })
    end), sniper_count = sniper_count }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101324] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    -- Enemies killed via "ElementAIRemove" DOES NOT TRIGGER ElementEnemyDummyTrigger if "force_ragdoll" and "true_death" are set to "false" and "use_instigator" is set to "true"
    other[102596] = { id = "Snipers", special_function = SF.RemoveTracker }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})

local stealth_objectives =
{
    { amount = 1000, name = "twh_entered" },
    { amount = 2000, name = "twh_wireboxes_cut" },
    { amount = 2000, name = "twh_enter_west_wing" },
    { amount = 2000, name = "twh_enter_oval_office" },
    { amount = 8000, name = "twh_safe_open" },
    { amount = 4000, name = "twh_access_peoc" },
    { amount = 8000, name = "twh_mainframe_hacked" },
    { amount = 2000, name = "twh_pardons_stolen" },
    { amount = 2000, name = "twh_left_peoc" },
    { amount = 2000, name = "heli_arrival" }
}
local loud_objectives =
{
    { amount = 1000, name = "twh_entered" },
    { amount = 4000, name = "twh_wireboxes_hacked" },
    { amount = 2000, name = "twh_enter_west_wing" },
    { amount = 2000, name = "twh_found_thermite" },
    { amount = 1000, name = "thermite_done" },
    { amount = 2000, name = "twh_enter_oval_office" },
    { amount = 8000, name = "twh_safe_open" },
    { amount = 4000, name = "twh_access_peoc" },
    { amount = 8000, name = "twh_mainframe_hacked" },
    { amount = 2000, name = "twh_pardons_stolen" },
    { amount = 2000, name = "twh_left_peoc" },
    { amount = 4000, name = "twh_disable_aa" },
    { amount = 2000, name = "heli_arrival" }
}
local secret_objectives =
{
    stop_at_inclusive = "twh_pardons_stolen",
    mark_optional = { twh_mainframe_hacked = true, twh_pardons_stolen = true }
}
EHI:AddXPBreakdown({
    tactic =
    {
        custom =
        {
            {
                name = "stealth",
                tactic =
                {
                    objectives = stealth_objectives
                }
            },
            {
                name = "stealth",
                additional_name = "twh_secret",
                tactic =
                {
                    objectives = stealth_objectives,
                    total_xp_override = { params = { min_max = {} } }
                },
                objectives_override = secret_objectives
            },
            {
                name = "loud",
                tactic =
                {
                    objectives = loud_objectives,
                }
            },
            {
                name = "loud",
                additional_name = "twh_secret",
                tactic =
                {
                    objectives = loud_objectives,
                    total_xp_override = { params = { min_max = {} } }
                },
                objectives_override = secret_objectives
            }
        }
    }
})