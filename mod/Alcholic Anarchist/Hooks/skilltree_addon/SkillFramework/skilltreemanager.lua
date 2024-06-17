function SkillTreeManager:pack_to_string() 
	local packed_string = ""

	for tree, data in ipairs(tweak_data.skilltree.trees) do
        if not data.is_custom then
            local points, num_skills = managers.skilltree:get_tree_progress_new(tree)
            packed_string = packed_string .. tostring(points)

            if tree ~= #tweak_data.skilltree.trees then
                packed_string = packed_string .. "_"
            end
        end
		
	end

	local current_specialization = self:digest_value(self._global.specializations.current_specialization, false, 1)
	local tree_data = self._global.specializations[current_specialization]
	if tree_data then
		local tier_data = tree_data.tiers

		if tier_data then
			local current_tier = self:digest_value(tier_data.current_tier, false)
			packed_string = packed_string .. "-" .. tostring(current_specialization) .. "_" .. tostring(current_tier)
		end
	end

	return packed_string
end

-- Debug points
-- function SkillTreeManager:specialization_points()
-- 	self._global.specializations.points = self:digest_value(100000)
-- 	return self._global.specializations.points and self:digest_value(self._global.specializations.points, false) or 0
-- end
