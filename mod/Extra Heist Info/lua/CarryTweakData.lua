local EHI = EHI
if EHI:CheckLoadHook("CarryTweakData") then
    return
end

---@param carry_id string
---@param default_string string?
function CarryTweakData:FormatCarryNameID(carry_id, default_string)
    if not carry_id then
        return default_string or ""
    end
    local carry = self[carry_id] or {}
    if carry.name_id then
        return managers.localization:text(carry.name_id)
    end
    return default_string or ""
end