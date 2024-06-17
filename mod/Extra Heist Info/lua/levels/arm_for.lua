local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local truck_delay = 524/30
local boat_delay = 450/30
---@type ParseTriggerTable
local triggers = {
    [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = Icon.HeliDropDrill, hint = Hints.DrillDelivery },

    -- Boat
    [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = Icon.BoatLootDrop, hint = Hints.Loot },
    [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = Icon.BoatLootDrop, hint = Hints.Loot },

    -- Truck
    [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = Icon.CarLootDrop, hint = Hints.Loot },
    [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = Icon.CarLootDrop, hint = Hints.Loot }
}
---@type ParseAchievementTable
local achievements =
{
    armored_6 =
    {
        elements =
        {
            -- Achievement bugged, can be earned in stealth
            -- Reported in: https://steamcommunity.com/app/218620/discussions/14/3048357185566603324/
            [104716] = { class = TT.Achievement.Status },
            [103311] = { special_function = SF.SetAchievementFailed }
        },
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                self._achievements:AddAchievementStatusTracker("armored_6")
            end
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100362] = EHI:CopyTrigger(other[100358], { single_sniper = true, sniper_count = 1 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "armored_1",
    max = 20,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = "ammo"
    }
})
EHI:ShowLootCounter({ max = 23 })

local tbl = {}
for i = 0, 500, 100 do
    --levels/instances/unique/train_cam_computer
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceUnitID(100022, i)] = { icons = { Icon.Vault }, remove_on_alarm = true }
end
EHI:UpdateUnits(tbl)

---@type MissionDoorTable
local MissionDoor =
{
    -- Vaults
    [Vector3(-150, -1100, 685)] = 100835,
    [Vector3(-1750, -1200, 685)] = 100253,
    [Vector3(750, -1200, 685)] = 100838,
    [Vector3(2350, -1100, 685)] = 100840,
    [Vector3(-2650, -1100, 685)] = 102288,
    [Vector3(3250, -1200, 685)] = 102593
}
EHI:SetMissionDoorData(MissionDoor)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "vault_open", times = 3 },
        { amount = 7000, name = "turret_secured" },
        { escape = 4000 }
    },
    loot =
    {
        ammo = { amount = 800, times = 20 }
    }
})