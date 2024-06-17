function HUDTemp:carry_weight_string( carry_id )

	if carry_id == "coke_light" then
		return "Очень легкий"
	elseif carry_id == "light" then
		return "Легкий"
	elseif carry_id == "medium" or carry_id == "being" or carry_id == "explosives" then
		return "Средний"
	elseif carry_id == "heavy" or carry_id == "slightly_very_heavy" then
		return "Тяжелый"
	elseif carry_id == "very_heavy" then
		return "Очень тяжелый"
	elseif carry_id == "mega_heavy" then
		return "Мега тяжелый"
	else
		return "???"
	end

end

function HUDTemp:carry_properties( carry_id , type )

	if type == "sprint" then
		return tweak_data.carry.types[ carry_id ].can_run and "Можно бежать" or "Нельзя бежать"
	elseif type == "move" then
		return tweak_data.carry.types[ carry_id ].move_speed_modifier and "Скорость: " .. tostring( tweak_data.carry.types[ carry_id ].move_speed_modifier * 100 ) .. "%" or "??"
	elseif type == "jump" then
		return tweak_data.carry.types[ carry_id ].jump_modifier and "Прыжок: " .. tostring( tweak_data.carry.types[ carry_id ].jump_modifier * 100 ) .. "%" or "??"
	elseif type == "throw" then
		return tweak_data.carry.types[ carry_id ].throw_distance_multiplier and "Бросок: " .. tostring( tweak_data.carry.types[ carry_id ].throw_distance_multiplier * 100 ) .. "%" or "??"
	end

end

Hooks:PostHook( HUDTemp , "show_carry_bag" , "DetailedBagsPostShowCarryBag" , function( self , carry_id , value )
	
	local bag_panel = self._temp_panel:child("bag_panel")
	
	local carry_data = tweak_data.carry[carry_id]
	local carry_type = self:carry_weight_string(carry_data.type)
	
	local monetary_value = managers.experience:cash_string(managers.money:get_secured_bonus_bag_value(carry_id, tweak_data:get_value("money_manager", "bag_value_multiplier", managers.job:has_active_job() and managers.job:current_job_and_difficulty_stars() or 1)))
	
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local carrying_text = managers.localization:text("hud_carrying")

	self._bg_box:child("bag_text"):set_left(0)
	self._bg_box:child("bag_text"):set_text(utf8.to_upper("\"" .. type_text .. "\" | " .. carry_type .. " (" .. self:carry_properties( carry_data.type , "sprint" ) .. ") | " .. monetary_value .. "\n" .. self:carry_properties( carry_data.type , "move" ) .. " | " .. self:carry_properties( carry_data.type , "jump" ) .. " | " .. self:carry_properties( carry_data.type , "throw" )))
	
	local _, _, w, _ = self._bg_box:child("bag_text"):text_rect()
	w = w + 10
	self._bg_box:child("bag_text"):set_w(w)
	
	self._bg_box:animate(callback(self, self, "_animate_carry_label"), w - bag_panel:w())

end )

function HUDTemp:_animate_carry_label( panel , width )
	
	local t = 0
	local text = self._bg_box:child("bag_text")
	
	while true do
		t = t + coroutine.yield()
		text:set_left(width * (math.sin(90 + t * 50) * 0.5 - 0.475))
	end

end