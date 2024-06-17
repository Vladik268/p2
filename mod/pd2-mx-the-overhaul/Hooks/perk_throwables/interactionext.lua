local VPPP_BaseInteractionExt_get_timer = BaseInteractionExt._get_timer
function BaseInteractionExt:_get_timer()
	local timer = VPPP_BaseInteractionExt_get_timer(self)
    local multiplier = 1
    multiplier = managers.player:give_temporary_value_boost(multiplier, "adrenaline_shot", -0.4) -- 40% boost
    multiplier = managers.player:give_temporary_value_boost(multiplier, "whiff", -0.4) -- 40% boost

    return timer * multiplier
end
