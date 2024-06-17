local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Methlab = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop } }
local element_sync_triggers = {}
local MethlabIndex = { 7800, 8200, 8600 }
local Heli = 30 + 23 + 5
local Truck = 40
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    Heli = 3 + 60 + 23 + 5
    Truck = 60
end
local client = EHI:IsClient()
for _, index in ipairs(MethlabIndex) do
    -- Cooking restart
    for i = 100120, 100122, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = deep_clone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100119, index)
        element_sync_triggers[element_id].hint = Hints.Restarting
    end
    -- Cooking continuation
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = deep_clone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
        element_sync_triggers[element_id].hint = Hints.mia_1_NextMethIngredient
    end
end
local triggers = {
    [102177] = { time = Heli, id = "Heli", icons = Icon.HeliDropBag, hint = Hints.Winch }, -- Time before Bile arrives

    [106013] = { time = Truck, id = "Truck", icons = { Icon.Car }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Defend },
    [106017] = { id = "Truck", special_function = SF.PauseTracker },

    [104299] = { time = 5, id = "C4GasStation", icons = { Icon.C4 }, hint = Hints.Explosion },

    -- Calls with Commissar
    [101388] = { time = 8.5 + 6, id = "FirstCall", icons = { Icon.Phone }, hint = Hints.Wait },
    [101389] = { time = 10.5 + 8, id = "SecondCall", icons = { Icon.Phone }, hint = Hints.Wait },
    [103385] = { time = 8.5 + 5, id = "LastCall", icons = { Icon.Phone }, hint = Hints.Wait }
}
local random_time = { id = Methlab.id, icons = Methlab.icons, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 }, hint = Hints.mia_1_NextMethIngredient }
for _, index in ipairs(MethlabIndex) do
    triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, Icon.Interact }, hint = Hints.mia_1_MethDone }
    if client then
        triggers[EHI:GetInstanceElementID(100118, index)] = { id = Methlab.id, icons = Methlab.icons, special_function = SF.SetRandomTime, data = { 5, 25, 40 }, hint = Hints.Restarting }
        triggers[EHI:GetInstanceElementID(100149, index)] = random_time
        triggers[EHI:GetInstanceElementID(100150, index)] = random_time
        triggers[EHI:GetInstanceElementID(100184, index)] = { id = Methlab.id, special_function = SF.RemoveTracker }
    end
end
if client then
    triggers[104955] = EHI:ClientCopyTrigger(triggers[106013], { time = 30 })
end

local other =
{
    [101937] = EHI:AddAssaultDelay({ control = 10 + 1 + 40, special_function = SF.AddTimeByPreplanning, data = { id = 100191, yes = 75, no = 45 } })
}
if EHI:IsLootCounterVisible() then
    local money = 5
    if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
        money = 4
    elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
        money = 3
    elseif EHI:IsMayhemOrAbove() then
        money = 2
    end
    local function GetNumberOfMethBags()
        for _, index in ipairs(MethlabIndex) do
            local unit_id = EHI:GetInstanceUnitID(100068, index) -- Acid 3
            if managers.game_play_central:GetMissionEnabledUnit(unit_id) then
                return 3
            end
        end
        for _, index in ipairs(MethlabIndex) do
            local unit_id = EHI:GetInstanceUnitID(100067, index) -- Acid 2
            if managers.game_play_central:GetMissionEnabledUnit(unit_id) then
                return 2
            end
        end
        -- If third or second acid is not found in either methlab instance, return one possible bag
        -- No need to check Caustic Soda and Hydrogen Chloride, they spawn with Muriatic Acid
        return 1
    end
    local Methbags = 0
    local MethbagsCooked = 0
    local MethbagsPossibleToSpawn = 19
    local MethlabExploded = false
    other[101218] = { special_function = EHI:RegisterCustomSF(function(...)
        Methbags = GetNumberOfMethBags()
        EHI:ShowLootCounterNoChecks({
            max = money + Methbags,
             -- 19 + 2 // 19 boxes of contrabant, that can spawn chemicals (up to 4); 2 cars with possible loot
            max_random = 19 + 2,
            unknown_random = true
        })
    end)}
    -- Basement
    local IncreaseMaximumTrigger = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:IncreaseLootCounterProgressMax()
    end) }
    -- Coke
    for i = 102832, 102841, 1 do
        other[i] = IncreaseMaximumTrigger
    end
    -- Weapons
    for i = 104498, 104506, 1 do
        other[i] = IncreaseMaximumTrigger
    end
    other[101204] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:SetUnknownRandomLoot()
    end) }
    -- Meth
    local IncreaseMaximumTrigger2 = { special_function = SF.CustomCode, f = function()
        if MethlabExploded then
            return
        end
        Methbags = Methbags + 1
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        managers.ehi_loot:RandomLootSpawned()
    end }
    local DecreaseMaximumTrigger = { special_function = SF.CustomCode, f = function()
        if MethlabExploded then
            return
        end
        MethbagsPossibleToSpawn = MethbagsPossibleToSpawn - 1
        managers.ehi_loot:RandomLootDeclined()
    end }
    for i = 9000, 16200, 400 do
        other[EHI:GetInstanceElementID(100007, i)] = DecreaseMaximumTrigger -- Empty
        other[EHI:GetInstanceElementID(100011, i)] = DecreaseMaximumTrigger -- Missiles
        other[EHI:GetInstanceElementID(100012, i)] = DecreaseMaximumTrigger -- Vodka
        other[EHI:GetInstanceElementID(100013, i)] = DecreaseMaximumTrigger -- Coats
        other[EHI:GetInstanceElementID(100014, i)] = DecreaseMaximumTrigger -- Cigars
        other[EHI:GetInstanceElementID(100015, i)] = IncreaseMaximumTrigger2 -- Chemicals for meth
    end
    -- Methlab exploded
    local function BlockMeth()
        if Methbags == 0 then -- Dropin; impossible to tell how many bags were cooked
            return
        end
        managers.ehi_loot:DecreaseLootCounterProgressMax(Methbags - MethbagsCooked)
        managers.ehi_loot:DecreaseLootCounterMaxRandom(MethbagsPossibleToSpawn)
        MethlabExploded = true
    end
    local function CookingDone()
        MethbagsCooked = MethbagsCooked + 1
    end
    for _, index in ipairs(MethlabIndex) do
        other[EHI:GetInstanceElementID(100158, index)] = { special_function = SF.CustomCode, f = BlockMeth }
        other[EHI:GetInstanceElementID(100159, index)] = { special_function = SF.CustomCode, f = CookingDone }
    end
    -- Cars
    local CarLootBlocked = false
    local CarLootNumber = 2
    other[100724] = { special_function = SF.CustomCode, f = function()
        CarLootBlocked = true
        managers.ehi_loot:DecreaseLootCounterMaxRandom(CarLootNumber)
    end }
    local DecreaseMaximumTrigger2 = { special_function = SF.CustomCode, f = function()
        if CarLootBlocked then
            return
        end
        CarLootNumber = CarLootNumber - 1
        managers.ehi_loot:RandomLootDeclined()
    end }
    -- All cars; does not get triggered when maximum has been reached
    other[100721] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:RandomLootSpawned()
    end) }
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/001
    other[100523] = DecreaseMaximumTrigger2 -- Empty money bundle, taken weapons or body spawned
    other[100550] = DecreaseMaximumTrigger2 -- Car set on fire -- 103846
    other[106837] = DecreaseMaximumTrigger2 -- Nothing spawned
    -- units/payday2/vehicles/str_vehicle_car_crossover_burned/str_vehicle_car_crossover_burned/001
    other[100849] = DecreaseMaximumTrigger2 -- Money should spawn, but ElementEnableUnit does not have any unit to spawn and bag counter goes up by 1
    -- units/payday2/vehicles/str_vehicle_car_sedan_2_burned/str_vehicle_car_sedan_2_burned/006
    other[100918] = DecreaseMaximumTrigger2 -- Nothing spawned
    other[100912] = DecreaseMaximumTrigger2 -- Empty money bundle, taken weapons or body spawned
    other[100553] = DecreaseMaximumTrigger2 -- Car set on fire
    -- Loot removal (Fire)
    -- coke, meth, money, weapon
    EHI:HookLootRemovalElement({ 104475, 106825, 106826, 106827 })
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100159] = { chance = 100, time = 30 + 20, recheck_t = 20 + 20, id = "Snipers", class = TT.Sniper.TimedChance }
    other[104026] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[105008] = { id = "Snipers", special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        local id = trigger.id
        local chance = element._values.chance
        if self._trackers:TrackerExists(id) then
            self._trackers:SetChance(id, chance)
            self._trackers:CallFunction(id, "SnipersKilled")
        else
            local t = 20 + 20
            self._trackers:AddTracker({
                id = id,
                time = t,
                recheck_t = t,
                chance = chance,
                class = TT.Sniper.TimedChance
            })
        end
    end) } -- 20%
    other[105024] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[104289] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[104303] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
local money = EHI:GetValueBasedOnDifficulty({
    normal = 5,
    hard = 4,
    veryhard = 4,
    overkill = 3,
    mayhem_or_above = 2
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "hm1_mobsters_killed" },
        { amount = 4000, name = "hm1_cars_destroyed" },
        { amount = 4000, name = "hm1_gas_station_destroyed" },
        { amount = 4000, name = "hm1_hatch_open" },
        { amount = 6000, name = "hm1_correct_barcode_scanned" },
        { amount = 500, name = "hm1_meth_cooked", optional = true },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    hm1_meth_cooked = { min = 0, max = 7 }
                },
                loot_all = { max = money + 7 + 3 + 2 } -- Money + 7 meth bags (3 (max; random) in methlab, up to 4 in basement) + 3 coke/weapons + 2 random loot from cars
            }
        }
    }
})