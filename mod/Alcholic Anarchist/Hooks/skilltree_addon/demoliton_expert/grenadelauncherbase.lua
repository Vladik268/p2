function GrenadeLauncherBase:run_and_shoot_allowed()
	local allowed = GrenadeLauncherBase.super.run_and_shoot_allowed(self)

	return allowed or managers.player:has_category_upgrade("grenade_launcher", "hip_run_and_shoot")
end