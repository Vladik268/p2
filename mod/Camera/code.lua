
-- Infinite and longer camera loops
-- Author: rogerxiii / DvD
 
-- Note: Duration multiplier only works AS HOST!!
 
local infinite_concurrent_camera_loops = true	-- Set to true if you want infinite camera loops, false otherwise
local camera_loop_duration_multiplier = 1		-- Set to a multiplier higher than 1 if you want longer camera loop duration
												
--------------------------------------------------------------------------------------------------------------------------------
 
local old_start = old_start or SecurityCamera._start_tape_loop
function SecurityCamera:_start_tape_loop(tape_loop_t)
	old_start(self, tape_loop_t * camera_loop_duration_multiplier)
	if infinite_concurrent_camera_loops then SecurityCamera.active_tape_loop_unit = nil end
end

managers.chat:feed_system_message(ChatManager.GAME, "Активно")