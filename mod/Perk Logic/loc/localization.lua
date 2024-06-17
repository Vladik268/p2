local class_name = "g_stoic_logic_and_kingpin_auto_injector_loc"

if not rawget(_G, class_name) then
	rawset(_G, class_name, {
		config = {},
		path = ModPath.."/loc/%s"
	})
else
	return
end

local c = _G[class_name]

function c:load_config()
	local file = JSON:jsonFile(string.format(self.path, "config.json"))
	local data = JSON:decode(file)
	for _, v in pairs(data) do
		if type(v) == "table" then
			self.config = v
		end
	end
end

function c:save_config()
	local file = JSON and io.open(string.format(self.path, "config.json"), "w")
	local data = {
		["config"] = self.config
	}

	if file then
		local contents = JSON:encode_pretty(data)
		file:write(contents)
		io.close(file)
	end
end

function c:init()
	dofile(string.format(self.path, "JSON.lua"))
	self:load_config()
end
c:init()