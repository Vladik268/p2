---@class EHIPhalanxDamageReductionTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHIPhalanxDamageReductionTracker = class(EHITimedChanceTracker)
EHIPhalanxDamageReductionTracker._forced_icons = { "buff_shield" }
EHIPhalanxDamageReductionTracker._forced_hint_text = "damage_reduction"
EHIPhalanxDamageReductionTracker._SetChance = EHIChanceTracker.SetChance
function EHIPhalanxDamageReductionTracker:OverridePanel()
    EHIPhalanxDamageReductionTracker.super.OverridePanel(self)
    local tweak = tweak_data.group_ai.phalanx
    self._tweak_data = tweak and tweak.vip and tweak.vip.damage_reduction or {
        max = 0.5,
        increase_intervall = 5
    }
    self._refresh_on_delete = true
    self._enabled = false
end

---@param amount number
function EHIPhalanxDamageReductionTracker:SetChance(amount)
    self:_SetChance(amount)
    if amount <= 0 then
        self:ForceDelete()
    elseif amount == (self._tweak_data.max * 100) then
        if self._enabled then
            self:StopTimer()
        end
    elseif self._enabled then
        self:SetTimeNoAnim(self._tweak_data.increase_intervall + math.rand(2))
    else
        self._enabled = true
        self:StartTimer(self._tweak_data.increase_intervall + math.rand(2))
    end
end