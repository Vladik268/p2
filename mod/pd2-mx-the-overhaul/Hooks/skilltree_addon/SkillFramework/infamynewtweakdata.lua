Hooks:RegisterHook("SF_InfamyTweakDataPostInit")

Hooks:PostHook(InfamyTweakData, "init", "mx_InfamyTweakData_init", function(self)
    Hooks:Call( "SF_InfamyTweakDataPostInit", self )
end)

function InfamyTweakData:_check_if_skilltree_exist(name_id)
	for index, value in ipairs(self.items.infamy_root.upgrades.skilltree.trees) do
		if value == name_id then
			return true
		end
	end
	return false
end

-- Allows the custom tree to use the infamy 1 skill points discount
function InfamyTweakData:add_skill_tree(skill_tree_id)
    if self:_check_if_skilltree_exist(name_id) then
		return
	end
    table.insert(self.items.infamy_root.upgrades.skilltree.trees, skill_tree_id)
end