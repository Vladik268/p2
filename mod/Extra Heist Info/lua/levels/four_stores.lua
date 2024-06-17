local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_anim_delay = 320 / 30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    -- Time before escape vehicle arrives
    [102492] = { run = { time = 40 + van_anim_delay } },
    [102493] = { run = { time = 30 + van_anim_delay } },
    [102494] = { run = { time = 20 + van_anim_delay } },
    [102495] = { run = { time = 50 + van_anim_delay } },
    [102496] = { run = { time = 60 + van_anim_delay } },
    [102497] = { run = { time = 70 + van_anim_delay } },
    [102498] = { run = { time = 100 + van_anim_delay } },
    [102499] = { run = { time = 90 + van_anim_delay } },
    [102511] = { run = { time = 80 + van_anim_delay } },
    [102512] = { run = { time = 110 + van_anim_delay } },
    [102513] = { run = { time = 120 + van_anim_delay } },
    [102526] = { run = { time = 130 + van_anim_delay } },
    [103592] = { run = { time = 160 + van_anim_delay } },
    [103593] = { run = { time = 180 + van_anim_delay } },
    [103594] = { run = { time = 200 + van_anim_delay } },

    [101443] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._trackers:AddTracker({
            id = "ObjectiveSteal",
            max = 15000,
            icons = { Icon.Money },
            flash_times = 1,
            hint = "loot_counter",
            class = EHI.Trackers.NeededValue
        })
        ---@param loot LootManager
        EHI:AddEventListener("four_stores", EHI.CallbackMessage.LootSecured, function(loot)
            local progress = loot:get_real_total_small_loot_value()
            self._trackers:SetTrackerProgress("ObjectiveSteal", progress)
            if progress >= 15000 then
                EHI:RemoveEventListener("four_stores")
            end
        end)
    end), trigger_times = 1 }
}
EHI:AddLoadSyncFunction(function(self)
    local objective = managers.loot:get_real_total_small_loot_value()
    if objective >= 15000 then
        return
    end
    self:Trigger(101443)
    self._trackers:SetTrackerProgress("ObjectiveSteal", objective)
end)
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 30)
    end)
end

local CopArrivalDelay = 30 -- Normal
if EHI:IsDifficulty(EHI.Difficulties.Hard) then
    CopArrivalDelay = 20
elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
    CopArrivalDelay = 10
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    CopArrivalDelay = 0
end
local FirstAssaultBreak = 15 + 2.5 + 3 + 2 + 30 + 20
local other =
{
    [103501] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
    [101167] = EHI:AddAssaultDelay({ control = FirstAssaultBreak, special_function = SF.AddTrackerIfDoesNotExist, trigger_times = 1 }), -- 15s (55s delay)
    [101166] = EHI:AddAssaultDelay({ control = FirstAssaultBreak - 5, special_function = SF.SetTimeOrCreateTracker, trigger_times = 1 }), -- 10s (65s delay)
    [101159] = EHI:AddAssaultDelay({ control = FirstAssaultBreak - 2, special_function = SF.SetTimeOrCreateTracker, trigger_times = 1 }) -- 13s (60s delay)
}
if CopArrivalDelay > 0 then
    other[103278] = EHI:AddAssaultDelay({ control = FirstAssaultBreak + CopArrivalDelay, trigger_times = 1 }) -- Full assault break; 15s (55s delay)
end
if EHI:IsLootCounterVisible() then
    local function LootSafeIsVisible()
        local unit = managers.worlddefinition:get_unit(101153) --[[@as UnitBase]]
        if not unit then
            return false
        end
        if not unit:damage() then
            return false
        end
        if unit:damage()._state then
            local group = unit:damage()._state.graphic_group
            return not group.safe -- If the "safe" group does not exist, the safe is visible
        else
            return false
        end
    end
    other[101890] = { special_function = SF.CustomCodeDelayed, t = 4, f = function()
        if LootSafeIsVisible() then
            EHI:ShowLootCounterNoChecks({ max = 1 })
        end
    end}
    EHI:AddLoadSyncFunction(function(self)
        if LootSafeIsVisible() and managers.loot:GetSecuredBagsAmount() == 0 then
            EHI:ShowLootCounterNoChecks({ max = 1 })
        end
    end)
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[102505] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101006 } }
    other[103200] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103234 } }
end
EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 6000
    },
    no_total_xp = true
})