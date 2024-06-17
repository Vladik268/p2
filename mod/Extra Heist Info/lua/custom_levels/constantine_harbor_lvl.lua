local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local interact = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, hint = Hints.mia_1_NextMethIngredient }
local element_sync_triggers = {}
for i = 100169, 100172, 1 do
    local element_id = EHI:GetInstanceElementID(i, 7750)
    element_sync_triggers[element_id] = deep_clone(interact)
    element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, 7750)
end
local escape_delay = 24 + 1
local triggers = {
    [100246] = { time = 60 + escape_delay, id = "HeliEscapeSlow", icons = Icon.HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Escape },
    [100247] = { time = escape_delay, id = "HeliEscapeFast", icons = Icon.HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Escape }
}
triggers[EHI:GetInstanceElementID(100118, 7750)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, Icon.Wait }, hint = Hints.Restarting }
triggers[EHI:GetInstanceElementID(100152, 7750)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, Icon.Interact }, hint = Hints.mia_1_MethDone }
if EHI:IsClient() then
    local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 }, hint = Hints.mia_1_NextMethIngredient }
    triggers[EHI:GetInstanceElementID(100149, 7750)] = random_time
    triggers[EHI:GetInstanceElementID(100150, 7750)] = random_time
    triggers[EHI:GetInstanceElementID(100184, 7750)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
end

EHI:ParseTriggers({
    mission = triggers,
    sync_triggers = { element = element_sync_triggers }
})