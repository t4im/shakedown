---
-- constants, especially provided by the engine
-- update with the engine, but leave them otherwise intact
mtt.constants = {
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
