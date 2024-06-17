-- Fixes [string "lib/modifiers/modifierlessconcealment.lua"]:21: attempt to index field 'groupai' (a nil value)
local original = ModifierLessConcealment.modify_value
function ModifierLessConcealment:modify_value(id, value, ...)
    if not managers.groupai then
        return value
    end
    return original(self, id, value, ...)
end