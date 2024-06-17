local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local EscapeWP = { icon = Icon.Escape, position_by_element = EHI:GetInstanceElementID(100029, 21250) }
local HeliTimer = EHI:GetFreeCustomSFID()
local triggers = {
    -- Why in the flying fuck, OVK, you decided to execute the timer AFTER the dialogue has finished ?
    -- You realize how much pain this is to account for ?
    -- I'm used to bullshit, but this is next level; 10/10 for effort
    -- I hope you are super happy with what you have pulled off
    -- And I'm fucking happy I have to check EVERY FUCKING DIALOG the pilot says TO STAY ACCURATE WITH THE TIMER
    --
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3182362958583578588/
    [1] = {
        [1] = 5 + 8,
        [2] = 8
    },
    [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait }, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100075, 21250)] = { time = 60 + 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 1, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [EHI:GetInstanceElementID(100076, 21250)] = { time = 60 + 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = HeliTimer, dialog = 2, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [EHI:GetInstanceElementID(100078, 21250)] = { time = 60 + 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeOrCreateTracker, waypoint = deep_clone(EscapeWP), hint = Hints.Escape },
    [100795] = { time = 5, id = "C4", icons = { Icon.C4 }, waypoint = { position_by_element = 100804 }, hint = Hints.Explosion },

    -- C4 Drop handled in CoreWorldInstanceManager
}
if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100051, 21250)] = { time = 20, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.Escape }
end

local other =
{
    [100217] = EHI:AddAssaultDelay({ control = 30, trigger_times = 1 }) -- Starting the saw early forces the assault to start
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:RegisterCustomSF(HeliTimer, function(self, trigger, ...)
    if not managers.user:get_setting("mute_heist_vo") then
        local delay_fix = triggers[1][trigger.dialog] or 0
        trigger.time = trigger.time + delay_fix
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
    end
    if self:Exists(trigger.id) then
        self:SetTimeNoAnim(trigger.id, trigger.time)
    else
        self:CreateTracker(trigger)
    end
end)

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 16000, name = "van_open" },
        { amount = 6000, name = "c4_set_up" }, -- Wall blown up
        { escape = 6000 }
    },
    loot_all = 500,
    total_xp_override =
    {
        loot_all = { times = 4 + (2 * math.min(EHI:DifficultyIndex(), 4)) }
    }
})