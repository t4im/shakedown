--
-- configuration handling
--
-- You can use several places to set these configs.
-- However do not set them in this lua file. Only defaults belong here.
--
-- Available places for your convenience (in order of precedence):
-- * global minetest.conf (key needs to be prefixed with "cubictest_")
-- * per game minetest.conf (key needs to be prefixed with "cubictest_")
-- * cubictest.conf in your worldpath
--

local config = {
	settings = Settings(core.get_worldpath() .. DIR_DELIM .. "cubictest.conf"):to_table(),
	register_defaults = function(self, defaults)
		local settings = self.settings
		for key in pairs(defaults) do
			if not settings[key] then
				settings[key] = defaults[key]
			end
		end
	end,
	get = function(self, key)
		return core.setting_get("cubictest_" .. key) or self.settings[key]
	end,
}
cubictest.config = setmetatable(config, {
	__index = function(table, key)
		return table:get(key)
	end
})

-- register own config defaults
--config:register_defaults({})

---
-- constants, especially provided by the engine
-- update with the engine, but leave them otherwise intact
cubictest.constants = {
	-- constants.h
	MAX_MAP_GENERATION_LIMIT = 31000,
	MAP_BLOCKSIZE = 16,
	PLAYER_INVENTORY_SIZE = 8*4,
	PLAYER_MAX_HP = 20,
	PLAYER_MAX_BREATH = 11,

	-- mapnode.h
	MAX_REGISTERED_CONTENT = 0x7fff, -- 32767
	CONTENT_UNKNOWN = 125,
	CONTENT_AIR = 126,
	CONTENT_IGNORE = 127,
}
