local only_custom_interactions = false
local custom_interactions = {
    ["corpse_alarm_pager"] = 0.2,
    ["driving_drive"] = true,
    ["hold_place_sentry"] = true,
    ["sentry_gun"] = true
}
local orig_func_get_timer = BaseInteractionExt._get_timer
function BaseInteractionExt:_get_timer(...)
    local result = orig_func_get_timer(self, ...)
    local tweak = custom_interactions[self.tweak_data]
    local check = type(tweak) == "boolean" and result
    if tweak then
        return check or tonumber(tweak)
    end
    return only_custom_interactions and result or check or 0.2
end