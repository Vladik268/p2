function NewRaycastWeaponBase:set_paint_data(paint_data)
	self._paint_data = paint_data
end

Hooks:PostHook( NewRaycastWeaponBase, "set_cosmetics_data", "WeaponPainter_SetPaintData", function(self, cosmetics)
	if cosmetics and cosmetics.paints and self.set_paint_data then
		self:set_paint_data(cosmetics.paints)
	end
end)

function NewRaycastWeaponBase:_get_mat_conf_name(part_id, unit_name, use_cc_material_config)
	local force_third_person = _G.IS_VR or self:is_npc()

	if force_third_person then
		if use_cc_material_config and tweak_data.weapon.factory.parts[part_id].cc_thq_material_config then
			return tweak_data.weapon.factory.parts[part_id].cc_thq_material_config
		end

		if tweak_data.weapon.factory.parts[part_id].thq_material_config then
			return tweak_data.weapon.factory.parts[part_id].thq_material_config
		end
	end

	if use_cc_material_config and tweak_data.weapon.factory.parts[part_id].cc_material_config then
		return tweak_data.weapon.factory.parts[part_id].cc_material_config
	end

	local cc_string = use_cc_material_config and "_cc" or ""
	local thq_string = force_third_person and "_thq" or ""

	return Idstring(unit_name .. cc_string .. thq_string)
end

function NewRaycastWeaponBase:_get_forced_mat_conf_name(base_path)
	local thq_string = (self:is_npc() or _G.IS_VR) and "_thq" or ""

	return Idstring(base_path .. thq_string)
end

local material_config_ids = Idstring("material_config")
Hooks:PostHook( NewRaycastWeaponBase, "_update_materials", "WeaponPainter_UpdateWeaponMaterials", function(self)
	if ( not self._paint_data ) or ( not self._parts ) then
		return
	end

	local factory_parts = tweak_data.weapon.factory.parts
	local force_cc = self._cosmetics_data and true or false

	self._materials = {}

	for part_id, part in pairs(self._parts) do
		if part.unit then
			local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, self._factory_id, self._blueprint)
			local part_type = factory_parts[part_id].type

			if part_type and self._paint_data[part_type] and part_data then
				local using_weapon_skin = self._paint_data[part_type].using_weapon_skin or false
				local new_material_config_ids = self:_get_mat_conf_name(part_id, part_data.unit, force_cc or using_weapon_skin)

				if not using_weapon_skin and part_data.texture_variants then
					local paint_id = self._paint_data[part_type].paint_id
					if part_data.texture_variants[paint_id] then
						local texture_var = part_data.texture_variants[paint_id]
						local mat_path = texture_var.material_config
						if mat_path then
							new_material_config_ids = self:_get_forced_mat_conf_name(mat_path)
						end
					end
				end
				
				if part.unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
					part.unit:set_material_config(new_material_config_ids, true)
				end
			end

			local materials = part.unit:get_objects_by_type(Idstring("material"))
			for _, m in ipairs(materials) do
				if m:variable_exists(Idstring("wear_tear_value")) then
					self._materials[part_id] = self._materials[part_id] or {}
					self._materials[part_id][m:key()] = m
				end
			end
		end
	end
end)


local material_variables = {
	cubemap_pattern_control = "cubemap_pattern_control",
	pattern_pos = "pattern_pos",
	uv_scale = "uv_scale",
	uv_offset_rot = "uv_offset_rot",
	pattern_tweak = "pattern_tweak",
	wear_and_tear = "wear_tear_value"
}
local material_textures = {
	pattern = "diffuse_layer0_texture",
	sticker = "diffuse_layer3_texture",
	pattern_gradient = "diffuse_layer2_texture",
	base_gradient = "diffuse_layer1_texture"
}
Hooks:PostHook( NewRaycastWeaponBase, "_apply_cosmetics", "WeaponPainter_UpdateWeaponCosmetics", function(self, async_clbk)
	if ( not self._paint_data ) or ( not self._parts ) or ( not self._materials ) then
		return
	end

	local factory_parts = tweak_data.weapon.factory.parts
	local texture_load_result_clbk = async_clbk and callback(self, self, "clbk_texture_loaded", async_clbk)
	local textures = {}
	local base_variable, base_texture, mat_variable, mat_texture, type_variable, type_texture, custom_variable, texture_key = nil

	for part_id, part in pairs(self._parts) do
		local part_type = factory_parts[part_id].type

		if part_type and self._paint_data[part_type] then
			local paint_data = self._paint_data[part_type]

			if self._materials[part_id] and paint_data.using_weapon_skin and paint_data.weapon_skin_data then
				local materials = self._materials[part_id]

				local cosmetics_data = tweak_data.blackmarket.weapon_skins[paint_data.paint_id]

				if cosmetics_data then
					for _, material in pairs(materials) do
						local wear_tear_value = tweak_data.economy.qualities[paint_data.weapon_skin_data.quality].wear_tear_value or 1
						material:set_variable(Idstring("wear_tear_value"), wear_tear_value)

						for key, variable in pairs(material_variables) do
							mat_variable = cosmetics_data.parts and cosmetics_data.parts[part_id] and cosmetics_data.parts[part_id][material:name():key()] and cosmetics_data.parts[part_id][material:name():key()][key]
							type_variable = cosmetics_data.types and cosmetics_data.types[part_type] and cosmetics_data.types[part_type][key]
							base_variable = cosmetics_data[key]

							if mat_variable or type_variable or base_variable then
								material:set_variable(Idstring(variable), mat_variable or type_variable or base_variable)
							end
						end

						for key, material_texture in pairs(material_textures) do
							mat_texture = cosmetics_data.parts and cosmetics_data.parts[part_id] and cosmetics_data.parts[part_id][material:name():key()] and cosmetics_data.parts[part_id][material:name():key()][key]
							type_texture = cosmetics_data.types and cosmetics_data.types[part_type] and cosmetics_data.types[part_type][key]
							base_texture = cosmetics_data[key]

							if mat_texture or type_texture or base_texture then
								texture_key = mat_texture and mat_texture:key() or type_texture and type_texture:key() or base_texture and base_texture:key()

								if not textures[texture_key] then
									textures[texture_key] = {
										applied = false,
										ready = false,
										name = mat_texture or type_texture or base_texture
									}
								end

								if type(textures[texture_key].name) == "string" then
									textures[texture_key].name = Idstring(textures[texture_key].name)
								end
							end
						end
					end
				end
			else
				local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, self._factory_id, self._blueprint)
				local texture_vars = part_data.texture_variants
				if texture_vars then
					local cosmetics_data = texture_vars[paint_data.paint_id]
					if cosmetics_data then
						local textures = cosmetics_data.textures

						if textures then
							for tex_id, texture in pairs(textures) do
								local texture_ids = Idstring(texture)
								local texture_key = texture_ids:key()

								if not textures[texture_key] then
									textures[texture_key] = {
										applied = false,
										ready = false,
										name = texture_ids
									}
								end
							end
						end
					end
				end
			end
		end
	end

	for k,v in pairs(textures) do self._textures[k] = v end

	self._requesting = async_clbk and true

	for tex_key, texture_data in pairs(self._textures) do
		if async_clbk then
			if not texture_data.ready then
				if DB:has(Idstring("texture"), texture_data.name) then
					TextureCache:request(texture_data.name, "normal", texture_load_result_clbk, 90)
				else
					Application:error("[NewRaycastWeaponBase:_apply_cosmetics] Weapon cosmetics tried to use no-existing texture!", "texture", texture_data.name)
				end
			end
		else
			texture_data.ready = true
		end
	end

	self._requesting = nil

	self:_chk_load_complete(async_clbk)
end)

local material_defaults = {
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
Hooks:PostHook( NewRaycastWeaponBase, "_set_material_textures", "WeaponPainter_SetWeaponCosmetics", function(self)
	if ( not self._paint_data ) or ( not self._parts ) then
		return
	end

	local factory_parts = tweak_data.weapon.factory.parts
	local base_texture, mat_texture, type_texture, new_texture = nil

	for part_id, part in pairs(self._parts) do
		local part_type = factory_parts[part_id].type

		if part_type and self._paint_data[part_type] then
			local paint_data = self._paint_data[part_type]

			if self._materials[part_id] and self._paint_data[part_type].using_weapon_skin then
				local materials = self._materials[part_id]

				for _, material in pairs(materials) do
					local cosmetics_data = tweak_data.blackmarket.weapon_skins[paint_data.paint_id] or {}

					for key, material_texture in pairs(material_textures) do
						mat_texture = cosmetics_data.parts and cosmetics_data.parts[part_id] and cosmetics_data.parts[part_id][material:name():key()] and cosmetics_data.parts[part_id][material:name():key()][key]
						type_texture = cosmetics_data.types and cosmetics_data.types[part_type] and cosmetics_data.types[part_type][key]
						base_texture = cosmetics_data[key]
						new_texture = mat_texture or type_texture or base_texture or material_defaults[material_texture]

						if type(new_texture) == "string" then
							new_texture = Idstring(new_texture)
						end

						if new_texture then
							Application:set_material_texture(material, Idstring(material_texture), new_texture, Idstring("normal"))
						end
					end
				end
			end
		end
	end

	for tex_id, texture_data in pairs(self._textures) do
		if not texture_data.applied then
			texture_data.applied = true

			TextureCache:unretrieve(texture_data.name)
		end
	end
end)