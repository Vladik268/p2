local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local van_delay = 47 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0), 31s before the timer gets activated; 10s before the timer is started; total 47s; Mayhem difficulty and above
local van_delay_ovk = 6 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0); OVERKILL difficulty and below
local heli_delay = 19
local anim_delay = 743/30 -- 743/30 is a animation duration; 3s is zone activation delay (never used when van is coming back)
local heli_delay_full = 13 + 19 -- 13 = Base Delay; 19 = anim delay
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@param self EHIManager
---@param trigger ElementTrigger
local function ShowFlareWP(self, trigger)
    if self.SyncedSFF.rat_flare_pos then
        self._waypoints:AddWaypoint(trigger.id, {
            time = trigger.run.time,
            icon = Icon.Methlab,
            position = self.SyncedSFF.rat_flare_pos
        })
        self.SyncedSFF.rat_flare_pos = nil
        return
    end
    self._trackers:RunTrackerIfDoesNotExist(trigger.id, trigger.run)
end
local element_sync_triggers =
{
    [100494] = { id = "CookChance", icons = { Icon.Methlab, Icon.Loop }, hook_element = 100724, set_time_when_tracker_exists = true }
}
local preload =
{
    { id = "Van", icons = Icon.CarEscape, hide_on_delete = true, hint = Hints.LootEscape },
    { id = "HeliMeth", icons = { Icon.Heli, Icon.Methlab, Icon.Goto }, hide_on_delete = true, hint = Hints.nail_ChemicalsEnRoute },
    { id = "CookingDone", icons = { Icon.Methlab, Icon.Interact }, hide_on_delete = true, hint = Hints.mia_1_MethDone },
    { id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, hide_on_delete = true, hint = Hints.Restarting }
}
---@type ParseTriggerTable
local triggers = {
    [102318] = { id = "Van", run = { time = 60 + 60 + 30 + 15 + anim_delay } },
    [102319] = { id = "Van", run = { time = 60 + 60 + 60 + 30 + 15 + anim_delay } },
    [101001] = { special_function = SF.Trigger, data = { 1010011, 1010012 } },
    [1010011] = { special_function = SF.RemoveTracker, data = { "CookChance", "VanStayDelay", "HeliMeth" } },
    [1010012] = { special_function = SF.RemoveTrigger, data = { 102220, 102219, 102229, 102235, 102236, 102237, 102238, 102197, 102175, 102167, 102168 } },

    [102383] = { time = 2 + 5, chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Timed.Chance, special_function = SF.SetChanceWhenTrackerExists, hint = Hints.CookingChance, start_opened = true },
    [100721] = { time = 1, chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Timed.Chance, special_function = SF.SetChanceWhenTrackerExists, hint = Hints.CookingChance, tracker_merge = true, start_opened = true },
    [100723] = { id = "CookChance", special_function = SF.IncreaseChanceFromElement },

    [100199] = { id = "CookingDone", run = { time = 5 + 1 } },

    [1] = { special_function = SF.RemoveTrigger, data = { 101972, 101973, 101974, 101975 } },
    [101972] = { id = "Van", run = { time = 60 + 60 + 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101973] = { id = "Van", run = { time = 60 + 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101974] = { id = "Van", run = { time = 60 + 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101975] = { id = "Van", run = { time = 30 + 15 + anim_delay }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", Icon.Goto }, class = TT.Warning, hint = Hints.ScriptedBulldozer },

    [101982] = { id = "Van", special_function = SF.SetTimeOrCreateTracker, run = { time = 589/30 } }
}
if EHI:EscapeVehicleWillReturn("rat") then
    table.insert(preload, { id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning, hide_on_delete = true, hint = Hints.LootTimed })
    triggers[102220] = { id = "VanStayDelay", run = { time = 60 + van_delay_ovk } }
    triggers[102219] = { id = "VanStayDelay", run = { time = 45 + van_delay } }
    triggers[102229] = { id = "VanStayDelay", run = { time = 90 + van_delay_ovk } }
    triggers[102235] = { id = "VanStayDelay", run = { time = 100 + van_delay_ovk } }
    triggers[102236] = { id = "VanStayDelay", run = { time = 50 + van_delay } }
    triggers[102237] = { id = "VanStayDelay", run = { time = 60 + van_delay_ovk } }
    triggers[102238] = { id = "VanStayDelay", run = { time = 70 + van_delay_ovk } }
end
if EHI:IsMayhemOrAbove() then
    triggers[102197] = { id = "HeliMeth", run = { time = 180 + heli_delay_full }, waypoint_f = ShowFlareWP }
    if EHI:MissionTrackersAndWaypointEnabled() and EHI:EscapeVehicleWillReturn("rat") then
        local VanPos = 101454 -- 101454 - Left; 101449 - Center
        local function ResetWaypoint()
            managers.hud:RestoreWaypoint(VanPos)
            VanPos = 101454 -- Reset to default position
        end
        triggers[101001].data[#triggers[101001].data + 1] = 1010013
        triggers[1010013] = { special_function = SF.CustomCode, f = ResetWaypoint }
        triggers[102320] = { special_function = SF.CustomCode, f = ResetWaypoint }
        triggers[101258] = { special_function = SF.CustomCode, f = ResetWaypoint }
        local original_trigger = triggers[101982]
        triggers[101982] = { special_function = SF.Trigger, data = { 1019821, 1019822 } }
        triggers[1019821] = original_trigger
        triggers[1019822] = { special_function = SF.CustomCode, f = function()
            VanPos = 101449
        end }
        local function DisableWaypoint()
            managers.hud:SoftRemoveWaypoint(VanPos)
            EHI._cache.IgnoreWaypoints[VanPos] = true
            EHI:DisableElementWaypoint(VanPos)
        end
        triggers[100763] = { special_function = SF.CustomCode, f = DisableWaypoint }
        triggers[101453] = { special_function = SF.CustomCode, f = DisableWaypoint }
        ---@param self EHIManager
        ---@param trigger ElementTrigger
        local function ShowWaypoint(self, trigger)
            local pos = VanPos == 101454 and Vector3(-1374, -2388, 1135) or Vector3(-1283, 1470, 1285)
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.run.time,
                icon = Icon.LootDrop,
                position = pos,
                class = EHI.Waypoints.Warning
            })
        end
        triggers[102219].waypoint_f = ShowWaypoint
        triggers[102236].waypoint_f = ShowWaypoint
    end
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    triggers[102197] = { id = "HeliMeth", run = { time = 120 + heli_delay_full }, waypoint_f = ShowFlareWP }
elseif EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    triggers[102175] = { id = "HeliMeth", run = { time = 120 + heli_delay }, waypoint_f = ShowFlareWP }
    triggers[102168] = { id = "HeliMeth", run = { time = 90 + heli_delay }, waypoint_f = ShowFlareWP }
else
    triggers[102168] = { id = "HeliMeth", run = { time = 90 + heli_delay }, waypoint_f = ShowFlareWP }
    triggers[102167] = { id = "HeliMeth", run = { time = 60 + heli_delay }, waypoint_f = ShowFlareWP }
end
if EHI:IsClient() then
    ---@class EHICookingChanceTracker : EHITimedChanceTracker
    ---@field super EHITimedChanceTracker
    EHICookingChanceTracker = class(EHITimedChanceTracker)
    EHICookingChanceTracker._tracker_type = "inaccurate"
    ---@param time number
    ---@param inaccurate boolean?
    function EHICookingChanceTracker:SetTimeNoAnim(time, inaccurate)
        EHICookingChanceTracker.super.SetTimeNoAnim(self, time)
        self._tracker_type = inaccurate and "inaccurate" or "accurate"
    end
    local SetTimeNoAnimOrCreateTrackerClient = EHI:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        local tracker = self._trackers:GetTracker(id) ---@cast tracker EHICookingChanceTracker
        if tracker then
            if tracker._tracker_type == "inaccurate" then
                tracker:SetTimeNoAnim(self:GetRandomTime(trigger), true)
            end
        else
            self:CreateTracker(trigger)
        end
    end)
    triggers[102383].class = "EHICookingChanceTracker"
    triggers[100721].class = "EHICookingChanceTracker"
    triggers[100724] = { additional_time = 20, random_time = 5, id = "CookChance", icons = { Icon.Methlab, Icon.Loop }, special_function = SetTimeNoAnimOrCreateTrackerClient, delay_only = true }
end

---@type ParseAchievementTable
local achievements =
{
    voff_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101780] = { max = 25, class = TT.Achievement.Progress },
            [101001] = { special_function = SF.SetAchievementFailed }, -- Methlab exploded
            [102611] = { special_function = SF.IncreaseProgress }
        }
    }
}

local sidejob =
{
    daily_tasty =
    {
        elements =
        {
            [101780] = { special_function = EHI:RegisterCustomSF(function(self, ...)
                local progress, max = EHI:GetSHSideJobProgressAndMax("daily_tasty")
                self._trackers:AddTracker({
                    id = "daily_tasty",
                    progress = progress,
                    max = max,
                    icons = { EHI.Icons.Trophy },
                    class = TT.SideJob.Progress
                })
            end) },
            [101382] = { special_function = SF.IncreaseProgress }
        }
    }
}

local SetFlarePos = EHI:RegisterCustomSyncedSF(function(self, trigger, ...)
    self.SyncedSFF.rat_flare_pos = self:GetElementPosition(trigger.arg)
end)
local other =
{
    [102383] = EHI:AddAssaultDelay({ control = 2 + 20 + 4 + 3 + 3 + 3 + 5 }),

    [102201] = { special_function = SetFlarePos, arg = 102154 },
    [102202] = { special_function = SetFlarePos, arg = 102153 },
    [102203] = { special_function = SetFlarePos, arg = 102152 },
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local SetRespawnTime = EHI:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        local t = trigger.time
        if self._trackers:CallFunction2(id, "SetRespawnTime", t) then
            self._trackers:AddTracker({
                id = id,
                time = t,
                count_on_refresh = 2,
                class = TT.Sniper.TimedCount
            })
        end
    end)
    other[101257] = { time = 90 + 140, id = "Snipers", count_on_refresh = 2, class = TT.Sniper.TimedCount, trigger_times = 1 }
    other[101137] = { time = 60, id = "Snipers", special_function = SetRespawnTime }
    other[101138] = { time = 90, id = "Snipers", special_function = SetRespawnTime }
    other[101141] = { time = 140, id = "Snipers", special_function = SetRespawnTime }
    other[101134] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[101982] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101281 } }
    other[101128] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101454 } }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sidejob = sidejob,
    preload = preload,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowAchievementLootCounter({
    achievement = "halloween_2",
    max = 7,
    difficulty_pass = ovk_and_up
})
EHI:ShowLootCounter({ max_bags_for_level = { xp_per_bag_all = 8000 }, no_max = true })
EHI:AddXPBreakdown({
    loot_all = 8000,
    total_xp_override =
    {
        params =
        {
            min =
            {
                loot_all = { times = 3 }
            },
            max_level = true,
            max_level_bags = true
        }
    }
})