local search_url = "https://www.google.com/search?q=payday+2+mod+"

if RequiredScript == "lib/managers/menumanagerpd2" then

  function MenuCallbackHandler:inspect_mod(item)
    Steam:overlay_activate("url", search_url .. (item:parameters().text_id or item:parameters().mod_id or ""):lower():gsub(" ", "%+"))
  end

end

if RequiredScript == "lib/managers/menu/crimenetcontractgui" then

  function CrimeNetContractGui:mouse_pressed(o, button, x, y)
    if alive(self._briefing_len_panel) and self._briefing_len_panel:visible() and self._step > 2 and self._briefing_len_panel:child("button_text"):inside(x, y) then
      self:toggle_post_event()
    end

    if alive(self._potential_rewards_title) and self._potential_rewards_title:visible() and self._potential_rewards_title:inside(x, y) then
      self:_toggle_potential_rewards()
    end

    if self._active_page and button == Idstring("0") then
      for k, tab_item in pairs(self._tabs) do
        if not tab_item:is_active() and tab_item:inside(x, y) then
          self:set_active_page(tab_item:index())
        end
      end
    end

    if self._mod_items and self._mods_tab and self._mods_tab:is_active() and button == Idstring("0") then
      for _, item in ipairs(self._mod_items) do
        if item[1]:inside(x, y) then
          Steam:overlay_activate("url", search_url .. item[1]:text():lower():gsub(" ", "%+"))
          break
        end
      end
    end
  end

end