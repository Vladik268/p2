local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local goat_pick_up = { Icon.Heli, Icon.Interact }
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@param self EHIManager
---@param trigger ElementTrigger
local function f_PilotComingInAgain(self, trigger, ...)
    self._trackers:RemoveTracker("PilotComingIn")
    if self._trackers:CallFunction3(trigger.id, "SetTrackerTime", trigger.time) then
        self:CreateTracker(trigger)
    end
end
local PilotComingInAgain = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
    if enabled then
        f_PilotComingInAgain(self, trigger)
    end
end)
local PilotComingInAgain2 = EHI:RegisterCustomSF(f_PilotComingInAgain)
---@type ParseTriggerTable
local triggers = {
    [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = Icon.HeliDropBag, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.peta2_LootZoneDelivery },
    [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain, hint = Hints.LootTimed },

    [101720] = { time = 80, id = "Bridge", icons = { Icon.Wait }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable, hint = Hints.Wait },
    [101718] = { id = "Bridge", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2, hint = Hints.LootTimed },
    [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2, hint = Hints.LootTimed }
}

---@type ParseAchievementTable
local achievements =
{
    peta_3 =
    {
        elements =
        {
            -- Formerly 5 minutes
            [101540] = { time = 240, class = TT.Achievement.Base },
            [101533] = { special_function = SF.SetAchievementComplete }
        }
    },
    peta_5 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [100002] = { max = (EHI:IsMayhemOrAbove() and 14 or 12), class = TT.Achievement.Progress, show_finish_after_reaching_target = true },
            [102095] = { special_function = EHI:RegisterCustomSF(function(self, ...)
                self._cache.IncreaseEnabled = true
            end) },
            [102098] = { special_function = EHI:RegisterCustomSF(function(self, ...)
                self._cache.IncreaseEnabled = false
            end) },
            [100716] = { special_function = EHI:RegisterCustomSF(function(self, ...)
                if self._cache.IncreaseEnabled then
                    self._trackers:IncreaseTrackerProgress("peta_5")
                end
            end) },
            [100580] = { special_function = SF.CustomCodeDelayed, t = 2, f = function()
                managers.ehi_tracker:CallFunction("peta_5", "Finalize")
            end}
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 100 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        hard_or_below = 1,
        veryhard_or_above = 2
    })
    other[100015] = { chance = 10, time = 1 + 10 + 60, on_fail_refresh_t = 60, on_success_refresh_t = 20 + 10 + 60, id = "Snipers", class = TT.Sniper.Loop, single_sniper = sniper_count == 1, sniper_count = sniper_count }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101358] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "ResetCount" }
    other[101733] = { id = "SniperHeli", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        if self._trackers:CallFunction2(id, "SniperRespawn") then
            local t = 23 + 2
            self._trackers:AddTracker({
                id = id,
                time = t,
                refresh_t = t,
                class = TT.Sniper.Heli
            })
        end
    end) }
    if EHI:IsDifficultyOrBelow(EHI.Difficulties.Hard) then
        local trigger = { id = "SniperHeli", special_function = SF.CallCustomFunction, f = "SniperKilledUpdateCount" }
        other[EHI:GetInstanceElementID(100007, 8400)] = trigger
        other[EHI:GetInstanceElementID(100007, 8550)] = trigger
    end
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:DisableWaypoints({ [101738] = true }) -- Drill waypoint on mission door
local GoatsToSecure = EHI:GetValueBasedOnDifficulty({
    normal = 5,
    hard = 7,
    veryhard = 10,
    overkill = 13,
    mayhem_or_above = 15
})
local objectives =
{
    { amount = 7000, name = "gs2_cage_drop", times = 1 },
    { amount = 500, name = "cage_assembled" },
    { amount = 500, name = "gs2_cage_grabbed" },
    { amount = 4500, name = "gs2_arrived_on_bridge" },
    { amount = 4500, name = "gs2_drilled_door" },
    { amount = 2000, name = "gs2_bridge_rotated" },
    { escape = 3000 }
}
local total_xp_override =
{
    params =
    {
        custom = {}
    }
}
local loot_all = { times = GoatsToSecure }
local min_max =
{
    type = "min_with_max",
    min =
    {
        objectives = true,
        loot_all = loot_all
    },
    max =
    {
        objectives =
        {
            gs2_cage_drop = true,
            cage_assembled = { times = GoatsToSecure },
            gs2_cage_grabbed = { times = GoatsToSecure },
            gs2_arrived_on_bridge = true,
            gs2_drilled_door = true,
            gs2_bridge_rotated = true,
            escape = true
        },
        loot_all = loot_all
    }
}
if OVKorAbove then
    table.insert(objectives, 4, { amount = 50000, name = "gs2_peta_5", optional = true }) -- Farmer Miserable
    total_xp_override.params.custom[1] = min_max
    local peta_5 = deep_clone(min_max)
    peta_5.name = "gs2_peta_5"
    peta_5.type = "max_only"
    peta_5.max.objectives = true
    total_xp_override.params.custom[2] = peta_5
else
    total_xp_override.params.custom[1] = min_max
end
EHI:AddXPBreakdown({
    objectives = objectives,
    loot_all = { amount = 500, text = "each_goat_secured" },
    total_xp_override = total_xp_override
})