---@class EHIDeployableManager
---@field IsLoading fun(self: self): boolean VR only (EHIDeployableManagerVR)
---@field AddToLoadQueue fun(self: self, key: string, data: table, f: function, add: boolean?) VR only (EHIDeployableManagerVR)
EHIDeployableManager = {}
---@param ehi_tracker EHITrackerManager
function EHIDeployableManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._equipment_map =
    {
        doctor = "doctor_bag",
        ammo = "ammo_bag",
        fak = "first_aid_kit",
        grenade = "grenade_crate",
        bodybag = "bodybags_bag"
    }
    self._deployables = {}
    return self
end

function EHIDeployableManager:SwitchToLoudMode()
    self:AddEquipmentToIgnore(self._equipment_map.bodybag)
end

function EHIDeployableManager:DisableGrenades()
    if EHI:GetOption("grenadecases_block_on_abilities_or_no_throwable") and not managers.blackmarket:equipped_grenade_allows_pickups() then
        self:AddEquipmentToIgnore(self._equipment_map.grenade)
        self._trackers:RemoveTracker("GrenadeCases")
    end
end

---@param type string
function EHIDeployableManager:AddEquipmentToIgnore(type)
    self:CallFunction("Deployables", "AddToIgnore", type)
    self._deployables_ignore = self._deployables_ignore or {}
    self._deployables_ignore[type] = true
end

---@param tracker_type string?
---@return boolean
function EHIDeployableManager:IsDeployableAllowed(tracker_type)
    if not (tracker_type and self._deployables_ignore) then
        return true
    end
    return not self._deployables_ignore[tracker_type]
end

---@param id string
---@return EHIAggregatedEquipmentTracker|EHIAggregatedHealthEquipmentTracker|EHIEquipmentTracker?
function EHIDeployableManager:GetTracker(id)
    return self._trackers:GetTracker(id) --[[@as EHIAggregatedEquipmentTracker|EHIAggregatedHealthEquipmentTracker|EHIEquipmentTracker]]
end

---@param id string
function EHIDeployableManager:TrackerDoesNotExist(id)
    return self._trackers:TrackerDoesNotExist(id)
end

---@param type string
---@param key string
---@param unit Unit
---@param tracker_type string?
function EHIDeployableManager:AddToDeployableCache(type, key, unit, tracker_type)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    self._deployables[type][key] = { unit = unit, tracker_type = tracker_type }
    local tracker = self:GetTracker(type)
    if tracker then
        if tracker_type then
             ---@cast tracker -EHIEquipmentTracker
            tracker:UpdateAmount(tracker_type, unit, key, 0)
        else
            ---@cast tracker EHIEquipmentTracker
            tracker:UpdateAmount(unit, key, 0)
        end
    end
end

---@param type string
---@param key string
function EHIDeployableManager:LoadFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    local deployable = self._deployables[type][key]
    if deployable then
        if self:IsDeployableAllowed(deployable.tracker_type) then
            if self:TrackerDoesNotExist(type) then
                self:CreateDeployableTracker(type)
            end
            local unit = deployable.unit
            local tracker = self:GetTracker(type)
            if tracker then
                if deployable.tracker_type then
                    tracker:UpdateAmount(deployable.tracker_type, unit, key, unit:base():GetRealAmount())
                else
                    tracker:UpdateAmount(unit, key, unit:base():GetRealAmount())
                end
            end
        end
        self._deployables[type][key] = nil
    end
end

---@param type string
---@param key string
function EHIDeployableManager:RemoveFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployables[type] = self._deployables[type] or {}
    self._deployables[type][key] = nil
end

---@param type string
function EHIDeployableManager:CreateDeployableTracker(type)
    if type == "Deployables" then
        self:AddAggregatedDeployablesTracker()
    elseif type == "Health" then
        self:AddAggregatedHealthTracker()
    elseif type == "DoctorBags" then
        self._trackers:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            hint = "doctor_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self._trackers:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            hint = "ammo_bag",
            class = "EHIEquipmentTracker"
        })
    elseif type == "BodyBags" and self:IsDeployableAllowed(self._equipment_map.bodybag) then
        self._trackers:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            hint = "bodybags_bag",
            remove_on_alarm = true,
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        self._trackers:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            hint = "fak",
            class = "EHIEquipmentTracker"
        })
    elseif type == "GrenadeCases" and self:IsDeployableAllowed(self._equipment_map.grenade) then
        self._trackers:AddTracker({
            id = "GrenadeCases",
            icons = { "frag_grenade" },
            class = "EHIEquipmentTracker"
        })
    end
end

---@param tracker_type string?
function EHIDeployableManager:AddAggregatedDeployablesTracker(tracker_type)
    if self:IsDeployableAllowed(tracker_type) then
        self._trackers:AddTracker({
            id = "Deployables",
            icons = { "deployables" },
            ignore = self._deployables_ignore,
            format = { ammo_bag = "percent" },
            hint = "deployables",
            class = "EHIAggregatedEquipmentTracker"
        })
    end
end

function EHIDeployableManager:AddAggregatedHealthTracker()
    self._trackers:AddTracker({
        id = "Health",
        format = {},
        hint = "doctor_fak",
        class = "EHIAggregatedHealthEquipmentTracker"
    })
end

---@param id string
---@param f string
---@param ... any
function EHIDeployableManager:CallFunction(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
end