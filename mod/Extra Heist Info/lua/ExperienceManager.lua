local EHI = EHI
if EHI:CheckHook("ExperienceManager") then
    return
end

---@class ExperienceManager
---@field _cash_sign string
---@field _cash_tousand_separator string
---@field _total_levels number
---@field cash_string fun(self: self|EHIExperienceManager, cash: number, cash_string: string?): string
---@field experience_string fun(self: self|EHIExperienceManager, xp: number): string
---@field level_cap fun(self: self): number
---@field total fun(self: self): number
---@field current_level fun(self: self): number
---@field current_rank fun(self: self): number
---@field get_max_prestige_xp fun(self: self): number
---@field get_current_prestige_xp fun(self: self): number
---@field next_level_data_points fun(self: self): number
---@field next_level_data_current_points fun(self: self): number

local original =
{
    init = ExperienceManager.init,
    give_experience = ExperienceManager.give_experience,
    load = ExperienceManager.load,
    reset = ExperienceManager.reset
}

function ExperienceManager:init(...)
    original.init(self, ...)
    managers.ehi_experience:ExperienceInit(self)
end

function ExperienceManager:give_experience(...)
    local return_data = original.give_experience(self, ...)
    managers.ehi_experience:ExperienceReload(self)
    return return_data
end

function ExperienceManager:load(...)
    original.load(self, ...)
    managers.ehi_experience:ExperienceReload(self)
end

function ExperienceManager:reset(...)
    original.reset(self, ...)
	managers.ehi_experience:ExperienceReload(self)
end