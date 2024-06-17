local EHI = EHI
---@class EHIVaultTemperatureTracker : EHITracker
EHIVaultTemperatureTracker = class(EHITracker)
EHIVaultTemperatureTracker._forced_icons = { EHI.Icons.Vault }
function EHIVaultTemperatureTracker:pre_init(params)
    params.time = 500
    self._synced_time = 0
    self._tick = 0.1
end

function EHIVaultTemperatureTracker:CheckTime(time)
    if self._synced_time == 0 then
        self._time = (50 - time) * 10
    else
        local new_tick = time - self._synced_time
        if new_tick ~= self._tick then
            self._time = ((50 - time) / (new_tick * 10)) * 10
            self._tick = new_tick
        end
    end
    self._synced_time = time
end

---@class EHIVaultTemperatureWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIVaultTemperatureWaypoint = class(EHIWaypoint)
EHIVaultTemperatureWaypoint.pre_init = EHIVaultTemperatureTracker.pre_init
EHIVaultTemperatureWaypoint.CheckTime = EHIVaultTemperatureTracker.CheckTime

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local trophy = {
    trophy_longfellow =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { time = 420, class = EHI.Trackers.Trophy }
        },
        mission_end_callback = true
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 20 + 60 })
}

EHI:ParseTriggers({
    other = other,
    trophy = trophy
})
EHI:ShowAchievementLootCounter({
    achievement = "melt_3",
    max = 8,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = { "coke", "gold", "money", "weapon", "weapons" }
    }
})

local mission_loot = ovk_and_up and 8 or 6
EHI:ShowLootCounter({ max = mission_loot + 8 }) -- 14 or 16

local tbl =
{
    --levels/instances/unique/shout_container_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100014, 2850)] = { ignore = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "vault_found" },
        { amount = 4000, name = "vault_open" },
        { escape = 4000 }
    },
    loot =
    {
        warhead = { amount = 8000, to_secure = mission_loot },
        _else = { amount = 1500 },
        xp_bonus = { amount = 2000, to_secure = mission_loot + 8 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    warhead = { min_max = 1 },
                    _else = { max = 8 },
                    xp_bonus = { max = 1 }
                }
            }
        }
    }
})