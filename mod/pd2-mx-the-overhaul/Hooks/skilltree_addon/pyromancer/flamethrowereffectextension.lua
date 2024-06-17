Hooks:PostHook(FlamethrowerEffectExtension, "setup_default", "Pyromancer_FlamethrowerEffectExtension_setup_default", function(self)
	self._flame_max_range = managers.player:upgrade_value("flamethrower", "flame_max_range", 1000)
end)