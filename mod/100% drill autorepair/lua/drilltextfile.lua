local text_original = LocalizationManager.text
function LocalizationManager:text(string_id, ...)
return string_id == "menu_kick_starter_beta_desc" and "BASIC: ##3## point\nYour drills and saws gain an additional ##10%## chance to automatically restart after breaking. \n\nACE: ##6## points\nEnables the ability to reset a broken drill or saw with a melee attack. The ability has a ##100%## chance to fix the drill or saw. \n\nNote: Skill does not affect the OVE9000 saw. "
or testAllStrings == true and string_id
or text_original(self, string_id, ...)
end