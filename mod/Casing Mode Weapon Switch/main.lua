local function is_clean_state()
    return HuskPlayerMovement.clean_states[managers.player:current_state()]
end

if RequiredScript == "lib/units/weapons/weaponlaser" then
    local WeaponLaserSetOn = WeaponLaser._set_on

    function WeaponLaser:_set_on(...)
        if not is_clean_state() then
            WeaponLaserSetOn(self, ...)
        end
    end
elseif RequiredScript == "lib/units/beings/player/huskplayermovement" then
    local HuskPlayerMovementSwitch = HuskPlayerMovement._can_play_weapon_switch_anim

    function HuskPlayerMovement:_can_play_weapon_switch_anim()
        return not is_clean_state() and HuskPlayerMovementSwitch(self) or false
    end
else
    local HookClass = PlayerMaskOff or PlayerClean
    local HookClassUpdateCheckActions = HookClass._update_check_actions

    function HookClass:_update_check_actions(...)
        HookClassUpdateCheckActions(self, ...)
        self:_check_change_weapon(...)
    end

    function HookClass:_check_change_weapon(...)
        local inventory = self._ext_inventory
        local input = self:_get_input(...)

        if type(input.btn_primary_choice) == "number" then
            inventory:equip_selection(input.btn_primary_choice)
        elseif type(self._previous_equipped_selection) == "number" then
            inventory:equip_selection(self._previous_equipped_selection)
            self._previous_equipped_selection = nil
        elseif input.btn_switch_weapon_press then
            inventory:equip_next()
        else
            return
        end

        inventory:hide_equipped_unit()
    end
end