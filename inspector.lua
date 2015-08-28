local format, table, insert, core = string.format, table, table.insert, core

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
			cells = format("%s,%s,%s", cells, core.formspec_escape(key), core.formspec_escape(value))
		end

		return "tablecolumns[text;text]" ..
			format("table[0,0;%f,%f;metatable;%s;]", fs_width - side_width - .3, fs_height, cells:sub(2)) ..
			format("button[%f,%f;2,1;raw_metadata;Raw Table]", fs_width - 2, fs_height - 0.7 * 2 - 0.3)
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
			cells = format("%s,0,%s,(Size %d),,", cells, core.formspec_escape(name), #list)

			for _, stack in ipairs(list) do
				local count = stack:get_count()
				if count == 0 then
					cells = cells .. ",1,-,<empty>,,"
				else
					cells = format("%s,1,%d,%s,%s,%s", cells,
						count, stack:get_name(), stack:get_wear(), core.formspec_escape(stack:get_metadata()))
				end
			end
		end

		return "tablecolumns[indent;text;text;text;text]" ..
			format("table[0,0;%f,%f;invtable;%s;]", fs_width - side_width - .3, fs_height, cells:sub(2))
	end
})

local function concat_kv_row(cells, level, key, value)
	local type = type(value)
	if type == "string" then
		value = format("%q", value)
	elseif type == "table" then
		cells = format("%s,%d,%s,%s", cells, level, key, core.formspec_escape(tostring(value)))
		for key, value in pairs(value) do
			cells = concat_kv_row(cells,level + 1,key,value)
		end
		return cells
	end

	return format("%s,%d,%s,%s", cells, level, key, core.formspec_escape(tostring(value)))
end

insert(tabs, {
	caption = "Node Definition",
	formspec = function(self, pos)
		local node = core.get_node(pos)
		local definition = core.registered_nodes[node.name]
		if not definition then
			return "label[1,1;This node has no definition.]"
		end

		local cells = ""
		for key, value in pairs(definition) do
			cells = concat_kv_row(cells, 0,key,value)
		end

		return "tablecolumns[indent;text;text]" ..
			format("table[0,0;%f,%f;metatable;%s;]", fs_width - side_width - .3, fs_height, cells:sub(2)) ..
			format("button[%f,%f;2,1;raw_nodedef;Raw Table]", fs_width - 2, fs_height - 0.7 * 2 - 0.3)
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
	local formspec = { format("size[%d,%d]", fs_width, fs_height) }

	if def.tmp_tab then
		insert(formspec, format("tabheader[0,0;tab;%s,%s;%s;true;true]", captions, def.tmp_tab, #tabs + 1))
	elseif def.tab_index then
		insert(formspec, format("tabheader[0,0;tab;%s;%s;true;true]", captions, def.tab_index))
	end

	insert(formspec, format("item_image[%f,0;1,1;%s]", fs_width - side_width, node.name))
	insert(formspec, format("field[%f,0.3;2,1;position;;%d,%d,%d]", fs_width - side_width + 1.3, pos.x, pos.y, pos.z))
	insert(formspec, format("label[%f,1;%s]", fs_width - side_width, node.name))
	insert(formspec, format("label[%f,1.3;Raw: %d (%d, %d)]", fs_width - side_width, core.get_content_id(node.name), node.param1, node.param2))

	if def.content then
		insert(formspec, def.content)
	end

	insert(formspec, format("button_exit[%f,%f;2,1;close;Close]", fs_width - 2, fs_height - 0.7))

	return table.concat(formspec)
end

local function show_raw_table_data(playername, pos, table)
	local text = core.formspec_escape(dump(table or {}))
	core.show_formspec(playername, "mod_test:inspect", create_inspector_formspec(pos, {
		tmp_tab = "Raw Metadata",
		content = format("textarea[0.3,0;%f,%f;text;;%s]", fs_width - side_width, fs_height, text),
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
		return true
	end

	local meta = core.get_meta(pos)
	local node = core.get_node(pos)

	if fields.raw_metadata then
		show_raw_table_data(playername, pos, meta:to_table())
	elseif fields.raw_nodedef then
		show_raw_table_data(playername, pos, core.registered_nodes[node.name])
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
