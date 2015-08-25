local string, table, insert, core = string, table, table.insert, core

local tabs = {}

local fs_width, fs_height = 14, 10
local side_width = 3

insert(tabs, {
	caption = "Fields",
	formspec = function(self, pos)
		local node = core.get_node(pos)
		local meta = core.get_meta(pos)
		local fields = meta:to_table().fields

		local cells = ""
		for key, value in pairs(fields) do
			cells = string.format("%s,%s,%s", cells, core.formspec_escape(key), core.formspec_escape(value))
		end

		return "tablecolumns[text;text]" ..
			string.format("table[0,0;%f,%f;metatable;%s;]", fs_width - side_width - .3, fs_height, cells:sub(2)) ..
			("button[%f,%f;2,1;raw_metadata;Raw Table]"):format(fs_width - 2, fs_height - 0.7 * 2 - 0.3)
	end
})

insert(tabs, {
	caption = "Inventories",
	formspec = function(self, pos)
		local node = core.get_node(pos)
		local meta = core.get_meta(pos)
		local inv = meta:get_inventory()
		local inventory_lists = inv:get_lists()
		local cells = ""
		for name, list in pairs(inventory_lists) do
			cells = string.format("%s,0,%s,(Size %d),,", cells,
				core.formspec_escape(name), #list)

			for _, stack in ipairs(list) do
				local count = stack:get_count()
				if count == 0 then
					cells = cells .. ",1,-,<empty>,,"
				else
					cells = string.format("%s,1,%d,%s,%s,%s", cells,
						count, stack:get_name(), stack:get_wear(), core.formspec_escape(stack:get_metadata()))
				end
			end
		end

		return "tablecolumns[indent;text;text;text;text]" ..
			string.format("table[0,0;%f,%f;invtable;%s;]", fs_width - side_width - .3, fs_height, cells:sub(2))
	end
})

local captions = ""
for _, tab in ipairs(tabs) do
	captions = captions .. "," .. tab.caption
end
captions = captions:sub(2)

local function create_inspector_formspec(pos, def)
	local def = def or {}
	local node = core.get_node(pos)
	local formspec = { ("size[%d,%d]"):format(fs_width, fs_height) }

	if def.tmp_tab then
		insert(formspec, ("tabheader[0,0;tab;%s,%s;%s;true;true]"):format(captions, def.tmp_tab, #tabs + 1))
	elseif def.tab_index then
		insert(formspec, ("tabheader[0,0;tab;%s;%s;true;true]"):format(captions, def.tab_index))
	end

	insert(formspec, ("item_image[%f,0;1,1;%s]"):format(fs_width - side_width, node.name))
	insert(formspec, ("field[%f,0.3;2,1;position;;%d,%d,%d]"):format(fs_width - side_width + 1.3, pos.x, pos.y, pos.z))
	insert(formspec, ("label[%f,1;%s]"):format(fs_width - side_width, node.name))
	insert(formspec, ("label[%f,1.3;Raw: %d (%d, %d)]"):format(fs_width - side_width, core.get_content_id(node.name), node.param1, node.param2))

	if def.content then
		insert(formspec, def.content)
	end

	insert(formspec, ("button_exit[%f,%f;2,1;close;Close]"):format(fs_width - 2, fs_height - 0.7))

	return table.concat(formspec)
end

local function open_raw_meta_data(playername, pos)
	local node = core.get_node(pos)
	local meta = core.get_meta(pos)
	local text = core.formspec_escape(dump(meta:to_table()))

	core.show_formspec(playername, "mod_test:inspect", create_inspector_formspec(pos, {
		tmp_tab = "Raw Metadata",
		content = ("textarea[0.3,0;%f,%f;text;;%s]"):format(fs_width - side_width, fs_height, text),
	}))
end

local function switch_tab(playername, tab_index, pos, ...)
	local node = core.get_node(pos)
	core.show_formspec(playername, "mod_test:inspect", create_inspector_formspec(pos, {
		tab_index = tab_index,
		content = tabs[tab_index]:formspec(pos, ...),
	}))
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mod_test:inspect" then return end

	local playername = player:get_player_name()
	local pos = fields.position and core.string_to_pos(fields.position) or {x=0, y=0, z=0}

	local tab_index = tonumber(fields.tab)
	if tab_index and tabs[tab_index] then
		switch_tab(playername, tab_index, pos)
	elseif fields.raw_metadata then
		open_raw_meta_data(playername, pos)
	end

	return true
end)

core.register_tool("mod_test:inspector", {
	description = "metadata inspector",
	inventory_image = "mtt_magnifying_glass.png",
	range = 16,
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end -- pointed at air
		switch_tab(user:get_player_name(), 1, pos)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if not pos then return end -- pointed at air
		switch_tab(placer:get_player_name(), 1, pos)
	end,
})
core.register_alias("mod_test:metadata_inspector", "mod_test:inspector")
