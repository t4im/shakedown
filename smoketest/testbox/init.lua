local core, smoketest = core, smoketest
local path = smoketest.modpath .. "/testbox"
local testbox = {
	positions = {
		preset = {x=11, y=11, z=11},
		preset_top = {x=11, y=12, z=11},
		buildable_to_box = {x=12, y=3, z=3},
		buildable_to_box_top = {x=12, y=4, z=3},
		not_buildable_to_node = {x=2, y=0, z=4},
		dropspot = {x=1, y=1, z=6},
		known_node_top = {x=8, y=10, z=4},
		known_node = {x=8, y=9, z=4},
		known_node_bottom = {x=8, y=8, z=4},
		unknown_node_top = {x=3, y=10, z=3},
		unknown_node = {x=3, y=9, z=3},
		unknown_node_bottom = {x=3, y=8, z=3},
		unknown_box_top = {x=1, y=2, z=1},
		unknown_box_center = {x=1, y=1, z=1},
		unknown_box_bottom = {x=1, y=0, z=1},
		-- for a test, where we place against an unknown into another unknown
		unknown_box_bottom_side = {x=1, y=0, z=2},
		ignore_box_center =  {x=6, y=3, z=3},
	},
}
smoketest.testbox = testbox

function testbox.compile()
	local schematic_export = core.serialize_schematic(dofile(path .. "/testbox.lua"), "mts", {})
	assert(schematic_export)
	local output, err = io.open(path .. "/testbox.mts", "w")
	if not output then error(err) end
	output:write(schematic_export)
	io.close(output)
end

function testbox.replace(preset)
	core.place_schematic({x=0, y=0, z=0}, path .. "/testbox.mts", 0, {
		["testbox:placeholder_preset"] = preset or "air"
	}, true)
	core.set_node(testbox.positions.preset, { name = preset or "air"})
end

testbox.compile()
