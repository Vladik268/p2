Hooks:OverrideFunction(PlayerListInitiator, "get_peer_name", function(self, peer)
	if not peer then
		return "No peer"
	end

	local name = peer:name()
	local level, rank = nil

	if peer == managers.network:session():local_peer() then
		level = managers.experience:current_level() or ""
		rank = managers.experience:current_rank() or ""
	else
		level = peer:level() or ""
		rank = peer:rank() or ""
	end

	local color_range_offset = utf8.len(name) + (peer:account_type_str() == "STEAM" and 11 or 10)
	local experience, color_ranges = managers.experience:gui_string(level, rank, color_range_offset)
	name = " [" .. peer:account_type_str() .. "] " .. name .. " (" .. experience .. ")"

	return name, color_ranges
end)