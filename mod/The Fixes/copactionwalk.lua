-- Should fix
-- Application has crashed: C++ exception [string "lib/units/enemies/cop/actions/lower_body/copa..."]:341: attempt to index field '_nav_path' (a nil value)
-- Fix provided by an ex-developer
local original_get_husk_interrupt_desc = CopActionWalk.get_husk_interrupt_desc
function CopActionWalk:get_husk_interrupt_desc(...)
    local desc = original_get_husk_interrupt_desc(self, ...)
    desc.nav_path = desc.nav_path or self._nav_path
    return desc
end