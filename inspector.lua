local function show_metadata(player, node_name, metadata_table)
	local playername = player:get_player_name()
	local text =  minetest.formspec_escape(dump(metadata_table))

	local show_text_formspec = "size[9,11]" ..
		("item_image[0,0;1,1;%s]"):format(node_name) ..
		("field[1.3,0.3;8,1;nodename;;%s]"):format(node_name) ..
		("textarea[0.3,1.3;9,10;text;;%s]"):format(text) ..
		"button_exit[7,10.3;2,1;ok;Ok]" ..
		default.gui_bg..
		default.gui_bg_img

	minetest.show_formspec(playername, "mtt:show_text", show_text_formspec)
end

minetest.register_tool("mod_test:metadata_inspector", {
	description = "metadata inspector",
	inventory_image = "mtt_magnifying_glass.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end -- pointed at air
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		local metatable = meta:to_table()
		show_metadata(user, node.name, metatable)
	end,
})
