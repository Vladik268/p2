local EHI = EHI
if EHI:CheckLoadHook("LootManager") then
    return
end

---@class LootManager
---@field _global { secured: { carry_id: string, multiplier: number }[] }
---@field _distribution_loot { carry_id: string, multiplier: number }[]
---@field get_real_total_small_loot_value fun(self: self): number
---@field get_secured_bonus_bags_amount fun(self: self): integer
---@field get_secured_mandatory_bags_amount fun(self: self): integer

local check_types = EHI.LootCounter.CheckType
local original =
{
    sync_secure_loot = LootManager.sync_secure_loot,
    sync_load = LootManager.sync_load
}

function LootManager:sync_secure_loot(...)
    original.sync_secure_loot(self, ...)
    EHI:CallEvent(EHI.CallbackMessage.LootSecured, self)
end

function LootManager:sync_load(...)
    original.sync_load(self, ...)
    EHI:CallCallbackOnce(EHI.CallbackMessage.LootLoadSync, self)
end

---@return integer
function LootManager:GetSecuredBagsAmount()
    local mandatory = self:get_secured_mandatory_bags_amount()
    local bonus = self:get_secured_bonus_bags_amount()
    local total = mandatory + bonus
    return total
end

---@param t string|string[]?
---@return integer
function LootManager:GetSecuredBagsTypeAmount(t)
    local secured = 0
    if type(t) == "string" then
        for _, data in ipairs(self._global.secured) do
            if data.carry_id == t then
                secured = secured + 1
            end
        end
    elseif type(t) == "table" then
        for _, carry_id in ipairs(t) do
            for _, data in ipairs(self._global.secured) do
                if data.carry_id == carry_id then
                    secured = secured + 1
                end
            end
        end
    end
    return secured
end

---@return number
function LootManager:GetSecuredBagsValueAmount()
    local value = 0
    for _, data in ipairs(self._global.secured) do
        if not tweak_data.carry.small_loot[data.carry_id] then
            value = value + managers.money:get_secured_bonus_bag_value(data.carry_id, data.multiplier)
        end
    end
    return value
end

---@param check_type integer
---@param loot_type string|string[]?
---@param f fun(loot: LootManager)?
function LootManager:EHIReportProgress(check_type, loot_type, f)
    if check_type == check_types.BagsOnly then
        return self:GetSecuredBagsAmount()
    elseif check_type == check_types.ValueOfBags then
        return self:GetSecuredBagsValueAmount()
    elseif check_type == check_types.ValueOfSmallLoot then
        return self:get_real_total_small_loot_value()
    elseif check_type == check_types.CheckTypeOfLoot then
        return self:GetSecuredBagsTypeAmount(loot_type)
    elseif check_type == check_types.CustomCheck then
        if f then
            f(self)
        end
    elseif check_type == check_types.Debug then
        local tweak = tweak_data.carry
        local loot_name = "<Unknown>"
        if tweak[loot_type] then
            loot_name = tweak[loot_type].name_id and managers.localization:text(tweak[loot_type].name_id) or "<Unknown Bag>"
        elseif tweak.small_loot[loot_type] then
            loot_name = "Small Loot"
        end
        managers.chat:_receive_message(1, "[EHI]", "Secured: " .. loot_name .. "; Carry ID: " .. tostring(loot_type), Color.white)
    end
end

if EHI.debug.loot_manager_escape then
    original.init = LootManager.init
    function LootManager:init(...)
        original.init(self, ...)
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "money", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
        self._distribution_loot[#self._distribution_loot + 1] = { carry_id = "coke", multiplier = 1 }
    end
end