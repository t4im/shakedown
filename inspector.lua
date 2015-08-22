local tabs = {}

local fs_width, fs_height = 14, 10
local side_width = 3

table.insert(tabs, {
	caption = "Fields",
	formspec = function(self, pos)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		local text = minetest.formspec_escape(dump(meta:to_table().fields))

		return ("textarea[0.3,0;%f,%f;text;;%s]"):format(fs_width - side_width, fs_height, text)
	end
})

table.insert(tabs, {
	caption = "Raw Metadata",
	formspec = function(self, pos)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		local text = minetest.formspec_escape(dump(meta:to_table()))

		return ("textarea[0.3,0;%f,%f;text;;%s]"):format(fs_width - side_width, fs_height, text)
	end
})

local captions = ""
for _, tab in ipairs(tabs) do
	captions = captions .. "," .. tab.caption
end
captions = captions:sub(2)

local function switch_tab(playername, tab_index, pos, ...)
	local node = minetest.get_node(pos)
	local formspec = string.format("size[%d,%d]", fs_width, fs_height) ..
		"tabheader[0,0;tab;".. captions .. ";".. tab_index .. ";true;true]" ..
		("item_image[%f,0;1,1;%s]"):format(fs_width - side_width, node.name) ..
		("field[%f,0.3;2,1;position;;%d,%d,%d]"):format(fs_width - side_width + 1.3, pos.x, pos.y, pos.z) ..
		("label[%f,1;%s]"):format(fs_width - side_width, node.name) ..
		("label[%f,1.3;Raw: %d (%d, %d)]"):format(fs_width - side_width, minetest.get_content_id(node.name), node.param1, node.param2) ..
		tabs[tab_index]:formspec(pos, ...) ..
		string.format("button_exit[%f,%f;2,1;close;Close]", fs_width - 2, fs_height - 0.7)

	minetest.show_formspec(playername, "mtt:inspect", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "mtt:inspect" then
		local tab_index = tonumber(fields.tab)
		if tab_index and tabs[tab_index] then
			local pos = fields.position and minetest.string_to_pos(fields.position) or {x=0, y=0, z=0}
			switch_tab(player:get_player_name(), tab_index, pos)
		end
		return true
	end
end)

minetest.register_tool("mod_test:metadata_inspector", {
	description = "metadata inspector",
	inventory_image = "mtt_magnifying_glass.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end -- pointed at air
		switch_tab(user:get_player_name(), 1, pos)
	end,
})
