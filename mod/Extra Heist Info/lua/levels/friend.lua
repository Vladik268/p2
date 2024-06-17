---@class EHIuno7Tracker : EHIAchievementTracker
EHIuno7Tracker = class(EHIAchievementTracker)
function EHIuno7Tracker:post_init(...)
    self._obtainable = false
    self._blocked_warning = true
    self:SetTextColor()
    self:PrepareHint(...)
end

function EHIuno7Tracker:OnAlarm()
    self._obtainable = true
    self._blocked_warning = false
    self:SetTextColor()
end

function EHIuno7Tracker:SetTextColor()
    if self._obtainable then
        self._text:set_color(Color.white)
        if self._time <= 10 then
            self:AnimateColor(true)
        end
    else
        self._text:set_color(Color.red)
    end
end

function EHIuno7Tracker:AnimateColor(...)
    if self._blocked_warning then
        return
    end
    EHIuno7Tracker.super.AnimateColor(self, ...)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    [100241] = { time = 662/30, id = "EscapeBoat", icons = Icon.BoatEscape, hook_element = 100216, hint = Hints.LootEscape },
}
local random_car = { time = 18, id = "RandomCar", icons = { Icon.Heli, Icon.Goto }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" }, hint = Hints.friend_HeliRandom }
local caddilac = { time = 18, id = "Caddilac", icons = { Icon.Heli, Icon.Goto }, hint = Hints.friend_HeliCaddilac }
local triggers = {
    [100103] = { additional_time = 15 + 5, random_time = 10, id = "BileArrival", icons = { Icon.Heli }, hint = Hints.friend_Heli },

    [100238] = random_car,
    [100249] = random_car,
    [100310] = random_car,
    [100313] = random_car,
    [100314] = random_car,

    [102231] = { time = 20, id = "BileDropCar", icons = { Icon.Heli, Icon.Car, Icon.Goto }, hint = Hints.friend_HeliDropCar },

    [100718] = caddilac,
    [100720] = caddilac,
    [100732] = caddilac,
    [100733] = caddilac,
    [100734] = caddilac,

    [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, { icon = Icon.Car, color = Color.yellow }, Icon.Goto }, hint = Hints.friend_HeliDropCar },

    [100213] = { time = 450/30, id = "EscapeCar1", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [100214] = { time = 160/30, id = "EscapeCar2", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [102814] = { time = 180, id = "Safe", icons = { Icon.Winch }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable, hint = Hints.Winch },
    [102815] = { id = "Safe", special_function = SF.PauseTracker }
}
if EHI:IsClient() then
    triggers[100216] = { additional_time = 662/30, random_time = 10, id = "EscapeBoat", icons = Icon.BoatEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
end

local mayhem_and_up = EHI:IsMayhemOrAbove()
---@type ParseAchievementTable
local achievements =
{
    friend_5 =
    {
        elements =
        {
            [102291] = { max = 2, class = TT.Achievement.Progress },
            [102280] = { special_function = SF.IncreaseProgress }
        }
    },
    friend_6 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [102430] = { time = 780, class = TT.Achievement.Base },
            [100801] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    },
    uno_7 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [100107] = { time = 901, class = "EHIuno7Tracker", update_on_alarm = true }
        },
        cleanup_callback = function()
            EHIuno7Tracker = nil ---@diagnostic disable-line
        end,
        sync_params = { from_start = true }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 + 1, trigger_times = 1 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowLootCounter({ max = 16 })
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = EHI:GetValueBasedOnDifficulty({ veryhard_or_below = 4, overkill_or_above = 6 }), max = 16 }
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
                { amount = 2000, name = "scarface_got_usb" },
                { amount = 3000, name = "pc_hack" },
                { amount = 1000, name = "scarface_entered_house" },
                { amount = 1000, name = "scarface_shutters_open" },
                { amount = 2000, name = "scarface_searched_planted_yayo" },
                { amount = 1000, name = "scarface_made_a_call" },
                { amount = 2000, name = "scarface_entered_sosa_office" },
                { amount = 1000, name = "scarface_sosa_killed" },
                { amount = 8000, name = "vault_open" }
            },
            loot_all = 500,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 2000, name = "scarface_got_usb" },
                { amount = 3000, name = "pc_hack" },
                { amount = 1000, name = "scarface_entered_house" },
                { amount = 1000, name = "scarface_shutters_open" },
                { amount = 1000, name = "scarface_gathered_all_paintings" },
                { amount = 2000, name_format = { id = "all_bags_destroyed", macros = { carry = tweak_data.carry:FormatCarryNameID("painting") } } },
                { amount = 1000, name = "scarface_all_cars_hooked_up" },
                { amount = 4000, name = "scarface_defeated_security" },
                { amount = 1000, name = "scarface_sosa_killed" },
                { amount = 8000, name = "vault_open" }
            },
            loot_all = 500,
            total_xp_override = xp_override
        }
    }
})