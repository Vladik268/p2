local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, ...)
return string_id == "all_2" and "Helmet Popping"
or string_id =="all_2_desc" and "Increases your headshot damage by ##25%##."
or string_id =="all_4" and "Blending In"
or string_id =="all_4_desc" and "You gain ##+1## increased concealment.\n\nWhen wearing armor, your movement speed is ##15%## less affected. \n\nYou gain ##45%## more experience when you complete days and jobs."
or string_id =="all_6" and "Walk-in Closet"
or string_id =="all_6_desc" and "Unlocks an armor bag equipment for you to use. The armor bag can be used to change your armor during a heist.\n\nIncreases your ammo pickup to ##135%## of the normal rate. "
or string_id =="all_8" and "Fast And Furious"
or string_id =="all_8_desc" and "You deal ##5%## more damage. Does not apply to melee damage, throwables, grenade launchers or rocket launchers."
or string_id == "anarchistoic'name" and "Alcoholic Anarchist"
or string_id == "anarchistoic'desc" and "Stoic AND Anarchist combined!"
or string_id == "anarchistoic'perk1n" and "Drunken Drive, When the weapon is holstered, it regains full ammo"
or string_id == "anarchistoic'perk1d" and "75% dmg to DoT & Flask, Anarchist Regen, +5% Armor Regen, 2s Invincible on Armor Break, +10% Armor"
or string_id == "anarchistoic'perk3n" and "Indestructible Edge"
or string_id == "anarchistoic'perk3d" and "+30% Armor, +15% Armor Regen, +100% Armor, -50% Health"
or string_id == "anarchistoic'perk5n" and "Immovable"
or string_id == "anarchistoic'perk5d" and "+30% Armor, +40% Armor Regen when 50% health, +110% Armor, Eliminate DoT after 4 seconds"
or string_id == "anarchistoic'perk7n" and "Rising Recovery"
or string_id == "anarchistoic'perk7d" and "+10% Armor Regen, +35% Armor Regen, +60% Armor Regen when 50% health, +120% Armor, Kills reduce flask cooldown by 2s"
or string_id == "anarchistoic'perk9n" and "Tipsy Tenacity"
or string_id == "anarchistoic'perk9d" and "+35% Armor, +45% Armor Regen, 30 Armor on attack, Half DoT heal, +10% Armor, -80% Weapon Swap Time, +120% Armor"
or text_original(self, string_id, ...)
end