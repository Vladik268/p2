local EHI = EHI
local Icons = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    --heli_escape_OFF
    [200534] = { special_function = EHI:RegisterCustomSyncedSF(function(self, ...)
        self.SyncedSFF.office_strike_escape = "Van"
    end) },
    [200148] = { id = "Escape", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        if not EHI:IsPlayingFromStart() then -- Not playing from the start, try to determine the escape vehicle
            if self:IsMissionElementDisabled(200171) then -- Heli show sequence is disabled, Van escape it is
                self.SyncedSFF.office_strike_escape = "Van"
            end
        end
        if self.SyncedSFF.office_strike_escape == "Heli" then
            local t = 50 + 25 + 6
            self._trackers:AddTracker({
                id = trigger.id,
                time = t,
                icons = Icons.HeliEscape,
                hint = Hints.LootEscape
            })
            if trigger.waypoint then
                trigger.waypoint.time = t
                trigger.waypoint.icon = Icons.Heli
                trigger.waypoint.position = self:GetElementPositionOrDefault(200179)
            end
        else -- Van
            self._trackers:AddTracker({
                id = trigger.id,
                time = 80,
                icons = Icons.CarEscape,
                hint = Hints.LootEscape
            })
            if trigger.waypoint then
                trigger.waypoint.time = 80
                trigger.waypoint.icon = Icons.Car
                trigger.waypoint.position = self:GetElementPositionOrDefault(200178)
            end
        end
        if trigger.waypoint then
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        end
    end), waypoint = {} }
}
managers.ehi_manager.SyncedSFF.office_strike_escape = "Heli"

---@type ParseAchievementTable
local achievements =
{
    os_powerup =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200134] = { status = Status.Defend, class = TT.Achievement.Status },
            [100604] = { special_function = SF.SetAchievementComplete },
            [100621] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_terroristswin =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { status = Status.Defend, class = TT.Achievement.Status },
            [100606] = { special_function = SF.SetAchievementComplete },
            [100630] = { special_function = SF.SetAchievementFailed }
        }
    },
    os_clearedout =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [200106] = { max = 18, class = TT.Achievement.Progress, special_function = SF.AddAchievementToCounter, data = {
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
                    loot_type = "money"
                }
            }}
        },
        preparse_callback = function(data)
            local trigger = { special_function = SF.DecreaseProgressMax }
            for i = 200502, 200519, 1 do
                data.elements[i] = trigger
            end
        end
    }
}
EHI:PreparseBeardlibAchievements(achievements, "os_achievements")

local other =
{
    [200018] = EHI:AddAssaultDelay({ control = 5 })
}
if EHI:IsLootCounterVisible() then
    other[200106] = EHI:AddLootCounter2(function()
        local servers = EHI:IsMayhemOrAbove() and 2 or 1
        EHI:ShowLootCounterNoChecks({ max = servers + 18 })
    end)
    for i = 200502, 200519, 1 do
        other[i] = { id = "LootCounter", special_function = SF.DecreaseProgressMax }
    end
    other[100092] = { max = 5, id = "LootCounter", special_function = SF.IncreaseProgressMax2 }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    ---@class EHISniperLoopBufferTracker : EHICountTracker, EHISniperBaseTracker
    ---@field super EHICountTracker
    EHISniperLoopBufferTracker = ehi_sniper_class(EHICountTracker)
    ---@param params EHITracker.params
    function EHISniperLoopBufferTracker:post_init(params)
        EHISniperLoopBufferTracker.super.post_init(self, params)
        self._sniper_respawn_buffer = {}
        self._sniper_respawn_buffer_size = 0
        self._sniper_respawn_element = 0
        self:SetBGSize(self._bg_box:w() / 2)
        self:SetIconX()
        local half = self._bg_box:w() / 2
        self._count_text:set_color(EHIProgressTracker._progress_bad)
        self._count_text:set_w(half)
        self._text = self:CreateText({
            w = half,
            left = self._count_text:right(),
            FitTheText = true
        })
        if self._snipers_spawned_popup then
            self._popup_title = "SNIPER!"
            self._popup_desc = managers.localization:text("ehi_popup_sniper_spawned")
        end
        if self._snipers_logic_started then
            managers.hud:custom_ingame_popup_text("SNIPER_LOGIC_START", managers.localization:text("ehi_popup_sniper_logic_started"), "EHI_Sniper")
        end
    end
    ---@param dt number
    function EHISniperLoopBufferTracker:update(dt)
        for element, t in pairs(self._sniper_respawn_buffer) do
            local new_t = t - dt
            if new_t <= 0 then
                if self:RemoveFromRespawn(element) then
                    self._sniper_respawn_element = 0
                    self:RemoveTrackerFromUpdate()
                    return
                elseif self._sniper_respawn_element == element then
                    self._time = self:GetNextSniperTime()
                end
            else
                self._sniper_respawn_buffer[element] = new_t
            end
        end
        self._time = self._time - dt
        self._text:set_text(EHISniperLoopBufferTracker.super.super.Format(self))
    end
    ---@param element_id number
    function EHISniperLoopBufferTracker:RemoveFromRespawn(element_id)
        self:IncreaseCount()
        self._sniper_respawn_buffer[element_id] = nil
        self._sniper_respawn_buffer_size = self._sniper_respawn_buffer_size - 1
        return self._sniper_respawn_buffer_size == 0
    end
    ---@param element_id number
    ---@param t number
    function EHISniperLoopBufferTracker:AddToRespawnInitial(element_id, t)
        self._sniper_respawn_buffer[element_id] = t
        self._sniper_respawn_buffer_size = self._sniper_respawn_buffer_size + 1
        if self._sniper_respawn_buffer_size >= 2 then
            return
        end
        self._sniper_respawn_element = element_id
        self._time = t
        self:AddTrackerToUpdate()
    end
    ---@param element_id number
    ---@param t number
    function EHISniperLoopBufferTracker:AddToRespawnFromDeath(element_id, t)
        self:DecreaseCount()
        self:AddToRespawnInitial(element_id, t)
    end
    function EHISniperLoopBufferTracker:GetNextSniperTime()
        local t = math.huge
        for element_id, t_respawn in pairs(self._sniper_respawn_buffer) do
            if t_respawn < t then
                t = t_respawn
                self._sniper_respawn_element = element_id
            end
        end
        return t
    end
    ---@param count number?
    function EHISniperLoopBufferTracker:IncreaseCount(count)
        if self._snipers_spawned_popup then
            managers.hud:custom_ingame_popup_text(self._popup_title, self._popup_desc, "EHI_Sniper")
        end
        EHISniperLoopBufferTracker.super.IncreaseCount(self, count)
    end
    -- ! element is Sniper ID (ElementSpawnEnemyDummy)
    local AddToRespawnFromDeath = EHI:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:CallFunction("Snipers", "AddToRespawnFromDeath", trigger.element, trigger.time or 65)
    end)
    other[200021] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._trackers:AddTracker({
            id = "Snipers",
            class = "EHISniperLoopBufferTracker"
        })
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 200051, 60)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 200061, 60)
    end), trigger_times = 1 }
    other[200053] = { element = 200051, special_function = AddToRespawnFromDeath }
    other[200062] = { element = 200061, special_function = AddToRespawnFromDeath }
    other[200588] = { count = 3, id = "Snipers", special_function = SF.IncreaseCounter } -- 3 additional snipers spawn; 0s delay
    other[200079] = { element = 200064, special_function = AddToRespawnFromDeath }
    other[200490] = { element = 200489, special_function = AddToRespawnFromDeath }
    other[200493] = { element = 200492, special_function = AddToRespawnFromDeath }
    other[200139] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 100512, 25)
        self._trackers:CallFunction("Snipers", "AddToRespawnInitial", 100515, 25)
    end), trigger_times = 1 }
    other[100513] = { time = 55, element = 100512, special_function = AddToRespawnFromDeath }
    other[100516] = { time = 55, element = 100515, special_function = AddToRespawnFromDeath }
end

local tbl =
{
    [100241] = { remove_vanilla_waypoint = 200163 },
    [102736] = { remove_vanilla_waypoint = 200175 },
    [103138] = { remove_vanilla_waypoint = 200306 },
    [102770] = { remove_vanilla_waypoint = 200307 },
    [102774] = { remove_vanilla_waypoint = 200308 },
    [102775] = { remove_vanilla_waypoint = 200309 },
    [102776] = { remove_vanilla_waypoint = 200310 }
}
EHI:UpdateUnits(tbl)

---@type MissionDoorTable
local MissionDoor =
{
    [Vector3(945.08, 3403.11, 92.4429)] = 200160
}
EHI:SetMissionDoorData(MissionDoor)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 16000
    },
    loot =
    {
        master_server = 2500,
        money = 850
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    master_server = { min_max = EHI:IsMayhemOrAbove() and 2 or 1 },
                    money = { max = 15 } -- 3 always and 3 random
                }
            }
        }
    }
})