local provider = cubictest.provider
local MAP_BLOCKSIZE = cubictest.constants.MAP_BLOCKSIZE
local CONTENT_UNKNOWN = cubictest.constants.CONTENT_UNKNOWN

local function to_relative(pos)
	return pos.x % MAP_BLOCKSIZE, pos.y % MAP_BLOCKSIZE, pos.z % MAP_BLOCKSIZE
end

local function to_index(x, y, z)
	return 1 + x + y * MAP_BLOCKSIZE + z * MAP_BLOCKSIZE * MAP_BLOCKSIZE
end

function provider.map_content(pos, content)
	local vm = VoxelManip(pos, pos)
	local data = vm:get_data()
	data[to_index(to_relative(pos))] = content
	vm:set_data(data)
	vm:set_lighting({day=10, night=10})
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_map()
end
