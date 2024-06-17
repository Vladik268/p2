log("[The_Overhaul_SkillFramework] Loaded")

function SkillTreeTweakData:add_new_skill(name, basic_upgrades, aced_upgrades, tier, icon_xy, texture)
	local cost_basic = tier > 1 and self.costs.default or self.costs.hightier
	local cost_aced = tier > 1 and self.costs.pro or self.costs.hightierpro

	local basic_upgrades = type(basic_upgrades) == "table" and basic_upgrades or { basic_upgrades }
	local aced_upgrades = type(aced_upgrades) == "table" and aced_upgrades or { aced_upgrades }

	self.skills[name] = {
		{
			upgrades = basic_upgrades,
			cost = cost_basic
		},
		{
			upgrades = aced_upgrades,
			cost = cost_aced
		},
		name_id = name,
		desc_id = name.."_desc",
		texture = texture,
		icon_xy = icon_xy
	}
end

function SkillTreeTweakData:_check_if_skilltree_exist(name_id)
	for index, value in ipairs(self.skill_pages_order) do
		if value == name_id then
			return true
		end
	end
	return false
end

function SkillTreeTweakData:add_skill_tree(name_id)
	local digest = function(value)
		return Application:digest_value(value, true)
	end
	if self:_check_if_skilltree_exist(name_id) then
		log('[SkillFramework]: this skill tree already exist:'..name_id)
		return
	end
	table.insert(self.unlock_tree_cost, digest(0))
	table.insert(self.skill_pages_order, name_id)
	
	self.skilltree[name_id] = {
		name_id = "st_menu_"..name_id.."",
		desc_id = "st_menu_"..name_id.."_desc",
		is_custom = true
	}
end

function SkillTreeTweakData:add_sub_skill_tree(tree_name_id, subtree_name_id, tiers)
	-- body
	local subtree = {
		skill = tree_name_id,
		name_id = subtree_name_id,
		unlocked = true,
		background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
		tiers = tiers,
		is_custom = true
	}

	table.insert(self.trees, subtree)
end

Hooks:PostHook(SkillTreeTweakData, "init", "SF_SkillTreeTweakData_init", function(self)
	self:add_new_skill("placeholder_skill", "placeholder", "placeholder", 1, { 0,0 })
end)
