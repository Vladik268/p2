Hooks:PreHook(PlayerStandard, "_start_action_unequip_weapon", "Addon_Perks_PlayerStandard__start_action_unequip_weapon", function(self, t, data)
    if managers.player:has_category_upgrade("player", "lonestar_extra_ammo_multiplier") then -- yeah I know I cant be bothered to make an upgrade just for this line here
        self._equipped_unit:base():on_reload()
        managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
    end
end)