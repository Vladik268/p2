local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@param self EHIManager
---@param trigger ElementTrigger
local function TransferWP(self, trigger)
    local index = managers.game_play_central:GetMissionDisabledUnit(EHI:GetInstanceUnitID(100087, 9340)) and 9590 or 9340
    if not self._cache.TransferPosition then
        self._cache.TransferPosition = self:GetElementPositionOrDefault(EHI:GetInstanceElementID(100019, index))
    end
    self._waypoints:AddWaypoint(trigger.id, {
        time = trigger.time,
        icon = trigger.element == 102438 and Icon.Wait or Icon.Defend,
        position = self._cache.TransferPosition,
        class = self.TrackerWaypointsClass[trigger.class or ""],
        remove_vanilla_waypoint = EHI:GetInstanceElementID(100019, index)
    })
end

---@type ParseTriggerTable
local triggers =
{
    [103053] = { id = "FuelChecking", icons = { Icon.Wait }, class = TT.Pausable, special_function = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
        if not enabled then
            return
        end
        if self:Exists(trigger.id) then
            self:Unpause(trigger.id)
            return
        --[[elseif self:IsMissionElementDisabled(trigger.fix_wp) or self:IsMissionElementEnabled(trigger.success_sequence) then
            trigger.time = 5]] -- Broken for some reason
        elseif CF.IsStealth() then
            trigger.time = 40
        else
            trigger.time = 60
        end
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
        self:CreateTracker(trigger)
    end), fix_wp = EHI:GetInstanceElementID(100068, 4650), success_sequence = EHI:GetInstanceElementID(100016, 4650), waypoint = { position_by_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100067, 4650) }, hint = Hints.Wait },
    [103055] = { id = "FuelChecking", special_function = SF.PauseTracker },
    [103070] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; loud
    [103071] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; stealth

    [102454] = { id = "FuelTransferStealth", icons = { Icon.Oil }, class = TT.Pausable, condition_function = CF.IsStealth, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 102438, waypoint_f = TransferWP, hint = Hints.FuelTransfer },
    [102439] = { id = "FuelTransferStealth", special_function = SF.PauseTracker },
    [102656] = { id = "FuelTransferLoud", icons = { Icon.Oil }, class = TT.Pausable, condition_function = CF.IsLoud, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101686, waypoint_f = TransferWP, hint = Hints.FuelTransfer },
    [101684] = { id = "FuelTransferLoud", special_function = SF.PauseTracker },

    [101050] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self:Call("FuelChecking", "AddDelay", 20) -- Add 20s because stealth trigger is now disabled
        self:Remove("FuelTransferStealth") -- ElementTimer won't proceed because alarm has been raised, remove it from the screen
        self:UpdateWaypointTriggerIcon(103053, Icon.Defend) -- Cops can turn off the checking device, change the waypoint icon to reflect this
    end), trigger_times = 1 } -- Alarm
}
if EHI:IsClient() then
    triggers[102454].client = { time = 60, random_time = 20, special_function = SF.UnpauseTrackerIfExists }
    triggers[102656].client = { time = 100, random_time = 30, special_function = SF.UnpauseTrackerIfExists }
    triggers[101685] = { time = 80, id = "FuelTransferLoud", icons = { Icon.Oil }, special_function = SF.SetTrackerAccurate, hint = Hints.FuelTransfer }
    triggers[104930] = { time = 20, id = "FuelTransferLoud", icons = { Icon.Oil }, special_function = SF.SetTrackerAccurate, hint = Hints.FuelTransfer }
end

---@type ParseAchievementTable
local achievements =
{
    deep_9 =
    {
        elements =
        {
            [104591] = { max = 10, class = TT.Achievement.Progress }, -- Stealth approach (cannot be achieved in loud)
            [101704] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [104408] = { special_function = SF.IncreaseProgress },
            [104442] = { special_function = SF.IncreaseProgress },
            [104456] = { special_function = SF.IncreaseProgress }
        },
        preparse_callback = function(data)
            local trigger = data.elements[104408]
            for i = 104410, 104428, 1 do
                data.elements[i] = trigger
            end
        end
    },
    deep_12 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100610] = { max = 3, set_color_bad_when_reached = true, class = TT.Achievement.Progress, condition_function = CF.IsLoud, trigger_times = 1 },
            [EHI:GetInstanceElementID(100225, 9840)] = { special_function = SF.IncreaseProgress }, -- 1st pump used
            [EHI:GetInstanceElementID(100228, 9840)] = { special_function = SF.IncreaseProgress }, -- 2nd pump used
            [EHI:GetInstanceElementID(100229, 9840)] = { special_function = SF.IncreaseProgress }, -- 3rd pump used
            [EHI:GetInstanceElementID(100283, 9840)] = { special_function = SF.SetAchievementFailed }, -- 4th pump used
            [EHI:GetInstanceElementID(100467, 9840)] = { special_function = SF.SetAchievementComplete }
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
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ShowAchievementLootCounter({
    achievement = "deep_11",
    max = 4,
    triggers =
    {
        [101084] = { special_function = SF.CustomCode, f = function()
            managers.ehi_tracker:IncreaseTrackerProgressMax("deep_11", 4)
            managers.ehi_tracker:CallFunction("deep_11", "SetStarted")
        end },
        [102062] = { special_function = SF.CallCustomFunction, f = "SetFailed2" }
    },
    add_to_counter = true,
    start_silent = true,
    load_sync = function(self)
        if managers.preplanning:IsAssetBought(102474) then
            self:Trigger(101084)
        end
        self._loot:SyncSecuredLoot("deep_11")
    end,
    loot_counter_load_sync = function(self)
        if managers.preplanning:IsAssetBought(102474) then
            self._loot:IncreaseLootCounterProgressMax(4)
        end
        self._loot:SyncSecuredLoot()
    end,
    show_loot_counter = true
})

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:SetMissionDoorData({
    -- Arrival
    [Vector3(2308.08, 3258.11, 4092.94)] = 104170,

    -- Relax
    [Vector3(3712.11, 1893.92, 4090.94)] = 104171,

    -- Locker
    [Vector3(2358.11, 867.92, 4091.94)] = 104174
})
local total_xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                texas4_found_the_perfect_sample = { min = 0 },
                texas4_found_the_good_sample = { max = 0 }
            },
            loot_all = { max = 8 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "texas4_found_server_room" },
                { amount = 1000, name = "texas4_accessed_security_computer" },
                { amount = 1000, name = "pc_hack" },
                { amount = 1000, name = "texas4_updated_docking_schedule" },
                { amount = 3000, name = "texas4_found_the_purest_sample" },
                { amount = 2000, name = "texas4_found_the_good_sample" },
                { amount = 500, name = "texas4_entered_the_processing_area" },
                { amount = 500, name = "texas4_crane_lowered" },
                { amount = 6000, name = "texas4_pipeline_connected" },
                { amount = 6000, name = "texas4_pumping_complete" },
                { amount = 500, name = "texas4_entered_the_drilling_tower" },
                { amount = 500, name = "texas4_lasers_disabled" },
                { amount = 500, name = "texas4_fan_jammed" },
                { amount = 4000, name = "texas4_disabled_gas_can" },
                { amount = 1000, name = "texas4_disabled_blowout_preventor" },
                { amount = 4000, name = "texas4_build_pressure" },
                { amount = 500, name = "texas4_drill_activated" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "texas4_found_server_room" },
                { amount = 1000, name = "texas4_servers_destroyed" },
                { amount = 1000, name = "pc_hack" },
                { amount = 3000, name = "texas4_found_the_purest_sample" },
                { amount = 2000, name = "texas4_found_the_good_sample" },
                { amount = 500, name = "texas4_entered_the_processing_area" },
                { amount = 500, name = "texas4_crane_lowered" },
                { amount = 6000, name = "texas4_pipeline_connected" },
                { amount = 6000, name = "texas4_pumping_complete" },
                { amount = 500, name = "texas4_entered_the_drilling_tower" },
                { amount = 6000, name = "texas4_gabriel_killed" },
                { amount = 1000, name = "texas4_disabled_blowout_preventor" },
                { amount = 4000, name = "texas4_build_pressure" },
                { amount = 500, name = "texas4_drill_activated" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        }
    }
})