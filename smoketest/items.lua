local core, cubictest, smoketest = core, cubictest, smoketest
local positions = smoketest.testbox.positions

smoketest.pointed_at = {
	-- we test known nodes extra, because all other cases might be handled correctly and hide an error in the "common case"
	a_known_node = {under=positions.known_node, above=positions.known_node_top, type="node"},
	a_known_node_from_bottom = {under=positions.known_node, above=positions.known_node_bottom, type="node"},
	a_filled_space = {under=positions.not_buildable_to_node, above=positions.not_buildable_to_node, type="node"},
	an_unknown_node = {under=positions.unknown_node, above=positions.unknown_node_top, type="node"},
	an_unknown_node_from_bottom = {under=positions.unknown_node, above=positions.unknown_node_bottom, type="node"},
	an_unknown_box_bottom = {under=positions.unknown_box_bottom, above=positions.unknown_box_center, type="node"},
	an_unknown_box_top = {under=positions.unknown_box_top, above=positions.unknown_box_center, type="node"},
	into_an_unknown_node = {under=positions.unknown_box_bottom, above=positions.unknown_box_bottom_side, type="node"},
	a_replaceable_node = {under=positions.buildable_to_box, above=positions.buildable_to_box_top, type="node"},
	nothing = { type="nothing" },
	itself = {under=positions.preset, above=positions.preset_top, type="node"},
	an_entity = { type="object", ref=cubictest.dummies.LuaEntitySAO:new() },
	another_player = { type="object", ref=cubictest.dummies.Player:new({player_name="Simone"}) },
}

local item_spec_path = smoketest.modpath .. "/items/"
local spec_list = {}
for _, filename in ipairs(core.get_dir_list(item_spec_path, false)) do
	table.insert(spec_list, dofile(item_spec_path .. filename))
end

local function describe_item(name, def)
	for _, specf in ipairs(spec_list) do
		specf(name, def)
	end
end

-- describe anything registered so far
for name, def in pairs(core.registered_items) do
	describe_item(name, def)
end
-- describe anything registered from now on, too
local register_item = core.register_item
core.register_item = function(name, def)
	register_item(name, def)

	-- deal with escaped modnames
	if name:sub(1,1) == ":" then
		name = name:sub(2)
	end
	describe_item(name, def)
end
