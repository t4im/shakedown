local core = core
local c_air = core.get_content_id("air")
local c_stone = core.get_content_id("default:stone")
local c_dirt_with_grass = core.get_content_id("default:dirt_with_grass")
local c_steelblock = core.get_content_id("default:steelblock")
local c_water = core.get_content_id("default:water_source")
local c_desert_sand = core.get_content_id("default:desert_sand")
local mapgened_chunk_lenghts = core.get_mapgen_params().chunksize
local biome_noise = {
	seed = 179424,
	octaves = 2,
	persist = 0.1,
	scale = 1,
	spread = {x=32, y=32, z=32},
}

local function select_biome_content(noise)
	if noise > 0.5 then
		return c_water
	elseif noise < -0.8 then
		return c_air
	elseif noise < -0.5 then
		return c_desert_sand
	end
	return c_dirt_with_grass
end

core.register_on_generated(function(minp, maxp, blockseed)
	local miny = minp.y
	if miny > 2 then -- don't bother with air
		return
	end
	local minx, minz, maxx, maxy, maxz = minp.x, minp.z, maxp.x, maxp.y, maxp.z
	local vm, emin, emax = core.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	if maxy < -2 then -- solid underground
		for index in area:iter(minx, miny, minz, maxx, maxy, maxz) do
			data[index] = c_stone
		end
	else -- surface
		local gen_length = maxx-minx+1
		local chunksize = gen_length/mapgened_chunk_lenghts
		local biome = core.get_perlin_map(biome_noise, {x=gen_length, y=gen_length, z=gen_length}):get2dMap_flat({x=minx, y=minz}) -- y in 2d is z in 3d
		local biome_content = select_biome_content(biome[1])

		for z = minz, maxz do
			for x = minx, maxx do
				for y = miny,-3 do -- with a bit of underground
					data[area:index(x, y, z)] = c_stone
				end
				data[area:index(x, -2, z)] = c_steelblock
				data[area:index(x, -1, z)] = c_stone

				local corner_stone =  (x % chunksize == 0 and z % chunksize == 0)
							or (x % chunksize == chunksize - 1 and z % chunksize == chunksize - 1)
							or (x % chunksize == 0 and z % chunksize == chunksize - 1)
							or (x % chunksize == chunksize - 1 and z % chunksize == 0)

				data[area:index(x, 0, z)] = corner_stone and c_steelblock or biome_content
			end
		end
	end

	vm:set_data(data)
	vm:set_lighting({day=5, night=5})
	vm:calc_lighting()
	vm:write_to_map(data)
end)

core.register_on_newplayer(function(player)
	player:setpos({x=0,y=2,z=0})
end)
