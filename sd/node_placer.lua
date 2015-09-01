local format = string.format

core.register_craftitem(core.get_current_modname() .. ":unknown_node", {
	description = "Unknown Node Spawner",
	inventory_image = core.inventorycube("unknown_node.png"),
	node_placement_prediction = "unknown",
	on_place = function(itemstack, placer, pointed_thing)
		itemstack:peek_item()
		local pos, under = pointed_thing.above, pointed_thing.under
		if core.get_node_or_nil(under).buildable_to then
			pos = under
		end

		local playername = placer:get_player_name()
		if core.is_protected(pos, playername) then
			core.log("action", format("%s tried to placean unknown node at protected position %s", playername, core.pos_to_string(pos)))
			core.record_protection_violation(pos, playername)
			return itemstack
		end

		core.log("action", format("%s places unknown node at %s", playername, core.pos_to_string(pos)))
		mtt.provider.map_content(pos, mtt.constants.CONTENT_UNKNOWN)

		return itemstack
	end,
})
