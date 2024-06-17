-- This file is meant to run near the top of the stack.

--[[ Brief overview of nomenclature:
self._underscore_var 	means initialized at the start of the file or class.
self.ALL_CAPS 			means to be held constant value. Do not change any of these values.
self.standrd_name 		means standard value to be manipulated and passed around as usual
s	(single character)	means either iterator, local var, function argument, and/or I can't be bothered to give it a full name.
]]

_G = _G or {}
_G.MXTO = _G.MXTO or {}

-- Prints a line to the console or [crash]log.txt. Requires developer.
_G.MXTO.developer = _G.MXTO.developer or 0 -- 0: Unchecked 1: Standard 2: Developer

function _G.MXTO_get_dev_mode()
    -- Check for the existence of the following file. File's contents do not matter.
	-- ../steamapps/common/PAYDAY 2/MXTO_DEV.txt
	if _G.MXTO.developer == 0 then
		local DEVELOPER_FILE_NAME = "MXTO_DEV.txt", file
		local file = io.open(DEVELOPER_FILE_NAME, "r") -- File cannot be modified while PD2 is open if developer is enabled.
		if file ~= nil then
			_G.MXTO.developer = 2 -- Developer granted iff developer has not been previously granted and developer file exists.
			log("[MXTO] Developer Enabled")
		else
			_G.MXTO.developer = 1
		end
	end
    return _G.MXTO.developer
end

function _G.mx_log(s)	
	-- Output log | Skip if nondeveloper.
	if MXTO_get_dev_mode() >= 2 then
		log("[MXTO] " .. s)
	end
end

function _G.mx_log_chat(name, content)
    -- body
    if MXTO_get_dev_mode() >= 2 then
        managers.chat:_receive_message(1, tostring(name), tostring(content), Color('00ff00'))
	end
end

function _G.mx_print(node)
    if MXTO_get_dev_mode() >= 2 then
        return -- Do not use mx_print, dev mode not active
    end

    if type(node) ~= "table" then
        log(tostring(node)) -- Not table use tostring
        return
    end

    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    log(output_str)
end

function _G.Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = l
    end
    return set
end

function _G.SetBool(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

function _G.raycast_from_player_eyes() 
    local from = managers.player:player_unit():movement():m_head_pos()
    -- 50000 is 500 meters
    local to = from + managers.player:player_unit():movement():m_head_rot():y() * number_to_meters(500)
    local ray = managers.player:player_unit():raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "ignore_unit", {managers.player:player_unit()})

    return ray, from, to
end

function _G.number_to_meters(number) 
    return number * 100
end

function normalize_between_min_and_max(val, max, min) 
    return (val - min) / (max - min)
end