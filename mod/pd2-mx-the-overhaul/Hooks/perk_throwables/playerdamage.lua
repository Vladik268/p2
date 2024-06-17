-- This code works but after many feedback I decided to make it work in manual way
-- This used to be the code for auto triggering the auto stimpack when downed
-- local VPPP_PlayerDamage_chk_cheat_death = PlayerDamage._chk_cheat_death
-- function PlayerDamage:_chk_cheat_death()
--     -- mx_print_table({
--     --     not managers.player:has_active_timer("replenish_grenades"),
--     --     managers.blackmarket:equipped_grenade() == "auto_inject_super_stimpak",
--     --     managers.blackmarket:equipped_grenade()
--     -- })
--     if not managers.player:has_active_timer("replenish_grenades") and managers.blackmarket:equipped_grenade() == "auto_inject_super_stimpak" then
--         self._auto_revive_timer = 1
--         managers.player:add_grenade_amount(-1)
--         return -- Return so it overrides the feight death skills and you don't waste it
--     end
--     VPPP_PlayerDamage_chk_cheat_death(self)
-- end

-- Hooks:PostHook(PlayerDamage, "update", "VPPP_PlayerDamage_update", function(self, unit, t, dt)
-- 	-- code
-- end)

function PlayerDamage:stealth_set_health(health)
    -- vanilla code
	self:_check_update_max_health()

	local max_health = self:_max_health() * self._max_health_reduction
	health = math.min(health, max_health)
	local prev_health = self._health and Application:digest_value(self._health, false) or health
	self._health = Application:digest_value(math.clamp(health, 0, max_health), true)

	self:_send_set_health()
	-- self:_set_health_effect() -- not needed

	if self._said_hurt and self:get_real_health() / self:_max_health() > 0.2 then
		self._said_hurt = false
	end

	if self:health_ratio() < 0.3 then
		self._heartbeat_start_t = TimerManager:game():time()
		self._heartbeat_t = self._heartbeat_start_t + tweak_data.vr.heartbeat_time
	end

    -- Replaced with set_teammate_health and HUDManager.PLAYER_PANEL
	managers.hud:set_teammate_health(HUDManager.PLAYER_PANEL, {
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	-- return prev_health ~= Application:digest_value(self._health, false)
end

Hooks:PostHook(PlayerDamage, "on_incapacitated", "MXTO_PlayerDamage_on_incapacitated", function(self)
	managers.player.redacted_boost_stacks = 0
end)