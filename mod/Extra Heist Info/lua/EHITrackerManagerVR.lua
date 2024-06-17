local EHI = EHI
---@class EHITrackerManager
EHITrackerManagerVR = EHITrackerManager
EHITrackerManagerVR.old_init = EHITrackerManager.init
EHITrackerManagerVR.old_PreloadTracker = EHITrackerManager.PreloadTracker
EHITrackerManagerVR.old_AddLaserTracker = EHITrackerManager.AddLaserTracker
EHITrackerManagerVR.old_RemoveLaserTracker = EHITrackerManager.RemoveLaserTracker
function EHITrackerManagerVR:init()
    self:old_init()
    self._is_loading = true
    self._load_callback = {}
end

function EHITrackerManagerVR:CreateWorkspace()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
    self._x = x
    self._y = y
    self._scale = EHI:GetOption("vr_scale") --[[@as number]]
end

function EHITrackerManagerVR:SetPanel(panel)
    self._hud_panel = panel
    self._is_loading = false
    for key, queue in pairs(self._load_callback) do
        if queue.table then
            for _, q in ipairs(queue.table) do
                q.f(key, q.data)
            end
        else
            queue.f(key, queue.data)
        end
    end
    self._load_callback = nil
end

function EHITrackerManagerVR:IsLoading()
    return self._is_loading
end

---@param params AddTrackerTable|ElementTrigger
function EHITrackerManagerVR:PreloadTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_PreloadTracker"))
        return
    end
    self:old_PreloadTracker(params)
end

---@param key string
---@param data AddTrackerTable|ElementTrigger
function EHITrackerManagerVR:_PreloadTracker(key, data)
    self:old_PreloadTracker(data)
end

---@param key string
---@param data table
---@param f function
---@param add boolean?
function EHITrackerManagerVR:AddToLoadQueue(key, data, f, add)
    local load_cbk = self._load_callback[key]
    local new_cbk = { data = data, f = f }
    if add then
        if load_cbk then
            if load_cbk.table then
                table.insert(load_cbk.table, new_cbk)
            else
                self._load_callback[key] = { table = {
                    load_cbk,
                    new_cbk
                }}
            end
        else
            self._load_callback[key] = { table = { new_cbk } }
        end
    elseif load_cbk then -- Update the existing data when it already exists
        load_cbk.data = data
        load_cbk.f = f
    else
        self._load_callback[key] = new_cbk
    end
end

---@param params AddTrackerTable|ElementTrigger
function EHITrackerManagerVR:AddLaserTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_AddLaserTracker"))
        return
    end
    self:old_AddLaserTracker(params)
end

---@param key string
---@param params table
function EHITrackerManagerVR:_AddLaserTracker(key, params)
    self:old_AddLaserTracker(params)
end

---@param id string
function EHITrackerManagerVR:RemoveLaserTracker(id)
    if self:IsLoading() then
        self._load_callback[id] = nil
        return
    end
    self:old_RemoveLaserTracker(id)
end