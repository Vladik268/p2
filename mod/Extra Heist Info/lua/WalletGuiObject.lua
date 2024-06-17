local EHI = EHI
if EHI:CheckHook("WalletGuiObject") or not EHI:GetOption("show_remaining_xp") then
    return
end

local infamy_pool = ""
local next_level = ""
local _100_in = ""
local _xp = ""
EHI:AddCallback(EHI.CallbackMessage.LocLoaded, function(loc, loc_loaded)
    infamy_pool = loc:text("ehi_experience_infamy_pool")
    next_level = loc:text("ehi_experience_next_level")
    _100_in = loc:text("ehi_experience_100_in")
    _xp = loc:text("ehi_experience_xp")
end)
local to_100_left = EHI:GetOption("show_remaining_xp_to_100")

local refresh = WalletGuiObject.refresh
function WalletGuiObject.refresh(...)
    refresh(...)
    if Global.wallet_panel then
        local level_text = Global.wallet_panel:child("wallet_level_text") --[[@as PanelText]]
        local skillpoint_icon = Global.wallet_panel:child("wallet_skillpoint_icon") --[[@as PanelBitmap]]
        local skillpoint_text = Global.wallet_panel:child("wallet_skillpoint_text") --[[@as PanelText]]
        local xp = managers.ehi_experience
        local s = ""
        if xp:IsInfamyPoolEnabled() then -- Level is maxed, show Infamy Pool instead if possible
            if xp:IsInfamyPoolOverflowed() then
                s = ", " .. infamy_pool .. " 0 " .. _xp
            else
                s = ", " .. infamy_pool .. " " .. xp:experience_string(xp._xp.prestige_xp_remaining) .. " " .. _xp
            end
        elseif to_100_left then -- calculate total XP to 100
            local xpToNextText = xp:experience_string(xp._xp.level_xp_to_next_level)
            local xpTo100Text = xp:experience_string(xp._xp.level_xp_to_100)
            s = ", " .. next_level .. " " .. xpToNextText .. " " .. _xp .. ", " .. _100_in .. " " .. xpTo100Text .. " " .. _xp
        else
            s = ", " .. next_level .. " " .. xp:experience_string(xp._xp.level_xp_to_next_level) .. " " .. _xp
        end
        level_text:set_text(tostring(xp._xp.level) .. s)
        local _, _, w, h = level_text:text_rect()
        level_text:set_size(w, h)
        level_text:set_position(math.round(level_text:x()), math.round(level_text:y()))
        skillpoint_icon:set_leftbottom(level_text:right() + 10, Global.wallet_panel:h() - 2)
        skillpoint_text:set_left(skillpoint_icon:right() + 2)
        WalletGuiObject.refresh_blur()
    end
end