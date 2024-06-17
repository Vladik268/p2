local Color = Color
local Captain = Color(255, 255, 128, 0) / 255
local Control = Color.white
local Anticipation = Color(255, 186, 204, 28) / 255
local Build = Color.yellow
local Sustain = Color(255, 237, 127, 127) / 255
local Fade = Color(255, 0, 255, 255) / 255
local State =
{
    control = 1,
    anticipation = 2,
    build = 3,
    sustain = 4,
    fade = 5,
    endless = 6,
    captain = 7
}
local assault_values = tweak_data.group_ai[tweak_data.levels:GetGroupAIState()].assault
local tweak_values = assault_values.delay
local hostage_values = assault_values.hostage_hesitation_delay
---@class EHIAssaultTracker : EHIWarningTracker, EHIChanceTracker
---@field super EHIWarningTracker
---@field _cs_assault_extender boolean
---@field _cs_max_hostages number
---@field _cs_duration number
---@field _cs_deduction number
EHIAssaultTracker = class(EHIWarningTracker)
EHIAssaultTracker._forced_icons = { { icon = "assaultbox", color = Control } }
EHIAssaultTracker._is_client = EHI:IsClient()
EHIAssaultTracker._inaccurate_text_color = EHI:GetTWColor("inaccurate")
EHIAssaultTracker._paused_color = EHIPausableTracker._paused_color
if EHI:GetOption("show_assault_diff_in_assault_trackers") and not tweak_data.levels:IsLevelSkirmish() then
    EHIAssaultTracker._show_assault_diff = true
    EHIAssaultTracker.FormatChance = EHIChanceTracker.Format
    EHIAssaultTracker.SetChance = EHIChanceTracker.SetChance
    EHIAssaultTracker._anim_chance = EHIChanceTracker._anim_chance
end
if type(tweak_values) == "table" then
    local first_value = tweak_values[1] or 0
    local match = true
    for _, value in pairs(tweak_values) do
        if first_value ~= value then
            match = false
            break
        end
    end
    if match then -- All numbers the same, use it and avoid computation because it is expensive
        EHIAssaultTracker._assault_delay = first_value
    end
else -- If for some reason the assault delay is not a table, use the value directly
    EHIAssaultTracker._assault_delay = tonumber(tweak_values) or 30
end
if type(hostage_values) == "table"  then
    local first_value = hostage_values[1] or 0
    local match = true
    for _, value in pairs(hostage_values) do
        if first_value ~= value then
            match = false
            break
        end
    end
    if match then -- All numbers the same, use it and avoid computation because it is expensive
        EHIAssaultTracker._precomputed_hostage_delay = true
        EHIAssaultTracker._hostage_delay = first_value
    end
else -- If for some reason the hesitation delay is not a table, use the value directly
    EHIAssaultTracker._precomputed_hostage_delay = true
    EHIAssaultTracker._hostage_delay = tonumber(hostage_values) or 30
end
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIAssaultTracker:init(panel, params, parent_class)
    self._refresh_on_delete = true
    self:CalculateDifficultyRamp(params.diff or 0)
    self.update_break = self.update
    if params.assault then
        self._assault = true
        params.time = self:CalculateAssaultTime(parent_class)
        self._forced_icons[1].color = Build
        self.update = self.update_assault
    else
        self._forced_icons[1].color = Control
        if not params.time then
            params.time = self:CalculateBreakTime() + (2 * math.random())
        end
        self:ComputeHostageDelay()
        self:CheckIfHostageIsPresent()
        if self._t_diff then
            params.time = params.time + self._t_diff
            self._t_diff = nil
        end
    end
    if params.random_time and not params.assault then
        self.old_SyncAnticipationColor = self.SyncAnticipationColor
        self.SyncAnticipationColor = self.SyncAnticipationColorInaccurate
        self._text_color = self._inaccurate_text_color
    end
    EHIAssaultTracker.super.init(self, panel, params, parent_class)
    self._update = not (params.stop_counting or params.endless_assault)
    if params.endless_assault then
        self:SetEndlessAssault(true)
    end
end

---@param params EHITracker.params
function EHIAssaultTracker:post_init(params)
    if self._show_assault_diff then
        local corrected_diff = self._parent_class:RoundChanceNumber(params.diff_visual or managers.ehi_assault._diff or self._diff)
        self._anim_flash_set_chance = 0
        self._chance = corrected_diff
        self._anim_static_chance = corrected_diff
        self:SetBGSize()
        self._chance_text = self:CreateText({
            text = self:FormatChance(corrected_diff),
            left = self._text:right(),
            w = self._bg_box:w() / 2,
            color = Color.white
        })
        self:SetIconsX()
    end
end

---@param dt number
function EHIAssaultTracker:update_negative(dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

---@param dt number
function EHIAssaultTracker:update_assault(dt)
    EHIAssaultTracker.super.update(self, dt)
    if self._to_next_state_t then
        self._to_next_state_t = self._to_next_state_t - dt
        if self._to_next_state_t <= 0 then
            if self._next_state == State.sustain then
                self:SetState(State.sustain)
                if self._recalculate_on_sustain then
                    self:RecalculateAssaultTime()
                    self._recalculate_on_sustain = nil
                end
                self._next_state = State.fade
                self._to_next_state_t = self._to_next_state_t + self._next_state_t
            else -- Fade
                self._to_next_state_t = nil
                self:SetState(State.fade)
            end
        end
    end
end

---@param assault_delay_bonus boolean?
function EHIAssaultTracker:AnimateColor(assault_delay_bonus)
    EHIAssaultTracker.super.AnimateColor(self, self._check_anim_progress, (self._assault or assault_delay_bonus) and self._completion_color or self._warning_color)
    self._check_anim_progress = nil
end

---@param diff number
function EHIAssaultTracker:CalculateDifficultyRamp(diff)
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    self._diff = diff
    self._difficulty_point_index = i
    self._difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
    if self._chance_text then
        self:SetChance(self._parent_class:RoundChanceNumber(diff))
    end
end

function EHIAssaultTracker:ComputeHostageDelay()
    if self._precomputed_hostage_delay then
        return
    end
    self._hostage_delay = math.lerp(hostage_values[self._difficulty_point_index], hostage_values[self._difficulty_point_index + 1], self._difficulty_ramp) --[[@as number]]
end

function EHIAssaultTracker:SyncAnticipationColorInaccurate()
    self._text_color = Color.white
    self.SyncAnticipationColor = self.old_SyncAnticipationColor
    self.old_SyncAnticipationColor = nil
    self:SyncAnticipationColor()
end

function EHIAssaultTracker:SyncAnticipationColor()
    self:StopTextAnim()
    self:SetState(State.anticipation)
    self._time_warning = nil
    self.update = self.update_break
    self._hostage_delay_disabled = true
end

---@param t number
function EHIAssaultTracker:SyncAnticipation(t)
    self._time = t - (2 * math.random())
    self:SyncAnticipationColor()
end

function EHIAssaultTracker:CheckIfHostageIsPresent()
    local group_ai = managers.groupai:state()
    if not group_ai._hostage_headcount or group_ai._hostage_headcount == 0 then
        return
    end
    self:UpdateTime(self._hostage_delay)
    self._hostages_found = true
end

function EHIAssaultTracker:CalculateBreakTime()
    if self._assault_delay then
        return self._assault_delay + 30
    end
    local base_delay = math.lerp(tweak_values[self._difficulty_point_index], tweak_values[self._difficulty_point_index + 1], self._difficulty_ramp)
    return base_delay + 30
end

---@param has_hostages boolean?
function EHIAssaultTracker:SetHostages(has_hostages)
    if self._hostage_delay_disabled then
        return
    end
    if has_hostages and not self._hostages_found then
        self._hostages_found = true
        self:UpdateTime(self._hostage_delay)
    elseif self._hostages_found and not has_hostages then
        self._hostages_found = false
        self:UpdateTime(-self._hostage_delay)
    end
end

---@param t number
function EHIAssaultTracker:UpdateTime(t)
    if self._time then
        self._time = self._time + t
        if not self._update then
            self._text:set_text(self:Format())
        end
    else
        self._t_diff = t
    end
end

---@param t number
function EHIAssaultTracker:StartAnticipation(t)
    self:StopTextAnim()
    self._hostage_delay_disabled = true
    self._time = t
    if not self._update then
        self:AddTrackerToUpdate()
    end
end

---@param block boolean
---@param t number
function EHIAssaultTracker:SetControlStateBlock(block, t)
    if block then
        if self._state == State.control then
            self:RemoveTrackerFromUpdate()
            self._text:set_text("")
            self._control_state_block = true
        end
    elseif self._control_state_block and not block then
        self._control_state_block = nil
        self:SetTimeNoAnim(t)
        self:AddTrackerToUpdate()
    end
end

---@param time number
function EHIAssaultTracker:SetTime(time)
    if self._hostage_delay_disabled or self._assault then
        return
    end
    self._hostages_found = false
    EHIAssaultTracker.super.SetTime(self, time)
    self:CheckIfHostageIsPresent()
end

---@param diff number
function EHIAssaultTracker:UpdateDiff(diff)
    if self._diff == diff then
        return
    end
    self:CalculateDifficultyRamp(diff)
    if self._assault then
        if self._is_client and self._state == State.build then
            self._recalculate_on_sustain = true
        end
    elseif self._hostage_delay_disabled or self._precomputed_hostage_delay then
        return
    else
        self:SetHostages(false)
        self:ComputeHostageDelay()
        self:CheckIfHostageIsPresent()
    end
    --[[if diff > 0 then
        self._time = self:CalculateBreakTime(diff)
        self:AddTrackerToUpdate()
    else
        self:RemoveTrackerFromUpdate()
        self:StopTextAnim()
    end]]
end

---@param diff number
function EHIAssaultTracker:AssaultStart(diff)
    if self._diff ~= diff then
        self:CalculateDifficultyRamp(diff)
    end
    self:AnimateBG()
    self:StopTextAnim()
    self._time = self:CalculateAssaultTime()
    self._time_warning = nil
    self:SetState(State.build)
    self._assault = true
    self.update = self.update_assault
    if self._cs_assault_extender then
        self:SetHook()
    end
    if self._control_state_block then
        self._control_state_block = nil
        self:AddTrackerToUpdate()
    end
end

---@param values table
---@return number
function EHIAssaultTracker:CalculateDifficultyDependentValue(values)
    return math.lerp(values[self._difficulty_point_index], values[self._difficulty_point_index + 1], self._difficulty_ramp) --[[@as number]]
end

---@param parent_class EHITrackerManager?
---@return number
function EHIAssaultTracker:CalculateAssaultTime(parent_class)
    local build = assault_values.build_duration
    local sustain = math.lerp(self:CalculateDifficultyDependentValue(assault_values.sustain_duration_min), self:CalculateDifficultyDependentValue(assault_values.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(assault_values.sustain_duration_balance_mul)
    local fade = assault_values.fade_duration
    self._assault_t = build + sustain
    self._sustain_original_t = sustain
    if self._cs_assault_extender then
        sustain = self:CalculateCSSustainTime(sustain)
    end
    if self._is_client then
        self._to_next_state_t = build
        self._next_state = State.sustain
        self._next_state_t = sustain
        local parent = parent_class or self._parent_class
        parent:SaveInternalData("assault", "sustain_t", self._assault_t)
        parent:SaveInternalData("assault", "sustain_app_t", managers.game_play_central:get_heist_timer())
    else
        self._to_next_state_t = build + sustain
        self._next_state = State.fade
    end
    return build + sustain + fade
end

function EHIAssaultTracker:RecalculateAssaultTime()
    local t = self:CalculateAssaultTime()
    local build = assault_values.build_duration
    local fade = assault_values.fade_duration
    self._assault_t = t - build - fade
    self._to_next_state_t = t - build - fade
    self._time = t - build
end

---@param sustain number
---@param n_of_hostages number?
function EHIAssaultTracker:CalculateCSSustainTime(sustain, n_of_hostages)
    n_of_hostages = n_of_hostages or managers.groupai:state():hostage_count()
    local n_of_jokers = managers.groupai:state():get_amount_enemies_converted_to_criminals()
    local n = math.min(n_of_hostages + n_of_jokers, self._cs_max_hostages)
    local new_sustain = sustain + self._sustain_original_t * (self._cs_duration - (self._cs_deduction * n))
    return new_sustain
end

function EHIAssaultTracker:OnMinionCountChanged()
    if self._state == State.sustain then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

---@param new_sustain number
function EHIAssaultTracker:UpdateSustainTime(new_sustain)
    if new_sustain ~= self._time then
        local time_diff = new_sustain - self._time
        self._to_next_state_t = self._to_next_state_t + time_diff
        self._time = self._time + time_diff
    end
end

---@param t number
---@param sustain_t number?
---@param already_extended boolean?
function EHIAssaultTracker:OnEnterSustain(t, sustain_t, already_extended)
    if self._captain_arrived or self._endless_assault then
        return
    end
    sustain_t = sustain_t or t
    self._to_next_state_t = sustain_t
    self._assault_t = sustain_t
    self._sustain_original_t = t
    self._time = sustain_t + assault_values.fade_duration
    self:SetState(State.sustain)
    if self._cs_assault_extender and not already_extended then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
    if self.update == self.update_negative then
        self.update = self.update_assault
    end
end

function EHIAssaultTracker:SetHook()
    self._hook_f = self._hook_f or function(hud, data)
        if self._state == State.sustain then
            self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t, data.nr_hostages))
        end
    end
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_Assault_set_control_info", self._hook_f)
end

---@param diff number
function EHIAssaultTracker:AssaultEnd(diff)
    if self._diff ~= diff then
        self:CalculateDifficultyRamp(diff)
    end
    self:AnimateBG()
    self:StopTextAnim()
    self._hostage_delay_disabled = nil
    self._time = self:CalculateBreakTime() + (2 * math.random())
    self:ComputeHostageDelay()
    self:CheckIfHostageIsPresent()
    self:SetState(State.control)
    self._assault = nil
    self.update = self.update_break
    EHI:Unhook("Assault_set_control_info")
end

---@param diff number
function EHIAssaultTracker:AssaultEndWithBlock(diff)
    self:AssaultEnd(diff)
    self:SetControlStateBlock(true, 0)
end

---@param text_color Color?
function EHIAssaultTracker:StopTextAnim(text_color)
    self._text:stop()
    self:SetTextColor(text_color or Color.white)
end

---@param state number
function EHIAssaultTracker:SetState(state)
    if self._state == state then
        return
    end
    self._state = state
    if state == State.control then
        self:SetIconColor(Control)
    elseif state == State.anticipation then
        self:SetIconColor(Anticipation)
    elseif state == State.build then
        self:SetIconColor(Build)
    elseif state == State.sustain then
        self:SetIconColor(Sustain)
    elseif state == State.fade then
        self:SetIconColor(Fade)
    elseif state == State.endless then
        self:RemoveTrackerFromUpdate()
        self:StopTextAnim(Color.red)
        self:SetIconColor(Color.red)
        self:SetStatusText("endless")
        self._time_warning = nil
        self._assault = true
        self:AnimateBG()
    else
        self:SetIconColor(Captain)
        self._time_warning = nil
        self._endless_assault = nil
    end
end

function EHIAssaultTracker:CaptainArrived()
    self._captain_arrived = true
    self:RemoveTrackerFromUpdate()
    if self._endless_assault then
        self:SetAndFitTheText()
        self:SetTextColor(self._paused_color)
    else
        self:StopTextAnim(self._paused_color)
    end
    self:SetState(State.captain)
end

function EHIAssaultTracker:CaptainDefeated()
    self._captain_arrived = nil
    self._time = 5
    self:SetTextColor()
    self:SetIconColor(Fade)
    self:AddTrackerToUpdate()
end

---@param state boolean?
function EHIAssaultTracker:SetEndlessAssault(state)
    if self._endless_assault == state or self._captain_arrived then
        return
    end
    self._endless_assault = state
    if state then
        self:SetState(State.endless)
    elseif not self._is_client then
        local ai_state = managers.groupai:state()
        local assault_data = ai_state._task_data.assault or {}
        local current_state = assault_data.phase
        if current_state then
            if current_state == "build" then
                local t_correction = assault_values.build_duration - (assault_data.phase_end_t - ai_state._t)
                self._time = self:CalculateAssaultTime() - t_correction
                self._assault_t = self._assault_t - t_correction
                self._to_next_state_t = self._to_next_state_t - t_correction
                self:SetAndFitTheText()
                self:SetTextColor()
                self:SetState(State.build)
                self:AddTrackerToUpdate()
                self:AnimateBG()
            elseif current_state == "sustain" then
                local end_t = ai_state.assault_phase_end_time and ai_state:assault_phase_end_time()
                if end_t then -- Already takes Crime Spree into account
                    local t = ai_state._t
                    self:OnEnterSustain(assault_data.phase_end_t - t, end_t - t, true)
                    self:SetAndFitTheText()
                    if self._time <= 10 then
                        self._check_anim_progress = true
                        if self._time > 0 then
                            if self._time > assault_values.fade_duration then
                                self._to_next_state_t = self._time - assault_values.fade_duration
                            else
                                self._to_next_state_t = nil
                                self:SetState(State.fade)
                            end
                        else
                            self:StartNegativeUpdate()
                            self:SetState(State.fade)
                        end
                        self:AnimateColor()
                    else
                        self:SetTextColor()
                    end
                    self:AddTrackerToUpdate()
                    self:AnimateBG()
                else
                    self:PoliceActivityBlocked() -- Current phase does not have end time, refresh at the next Control state
                end
            elseif current_state == "fade" then
                self:CaptainDefeated() -- Faster than retyping it here
                self:SetAndFitTheText()
                self:AnimateBG()
            else
                self:PoliceActivityBlocked() -- Current phase is not an assault phase, refresh at the next Build state
            end
        else
            self:PoliceActivityBlocked() -- Current phase does not exist for some reason, refresh at the next Control state
        end
    else
        self:PoliceActivityBlocked() -- Refresh at the next Control state
    end
end

function EHIAssaultTracker:PoliceActivityBlocked()
    self._refresh_on_delete = nil
    self:delete()
end

function EHIAssaultTracker:StartNegativeUpdate()
    self.update = self.update_negative
    self._time = -self._time
end

function EHIAssaultTracker:Refresh()
    self:StartNegativeUpdate()
    if not self._assault then
        self:StopTextAnim()
        self:AnimateColor(true)
    end
end

--- The tracker `NEEDS TO BE DELETED` via `EHITrackerManager:ForceRemoveTracker()`!
function EHIAssaultTracker:delete()
    if self._refresh_on_delete then
        self:Refresh()
    else
        EHIAssaultTracker.super.delete(self)
    end
end