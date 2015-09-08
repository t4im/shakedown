local core, cubictest, smoketest, ItemStack, table = core, cubictest, smoketest, ItemStack, table
local ipairs, pairs = ipairs, pairs
local testbox, positions = smoketest.testbox, smoketest.testbox.positions
--local pos = positions.unknown_node_top
local mock_player = cubictest.mocks.Player:new()
local initial_stack_size = 5

local pos_itself = positions.preset
local pointed_at = {
	-- we test known nodes extra, because all other cases might be handled correctly and hide an error in the "common case"
	a_known_node = {under=positions.known_node, above=positions.known_node_top, type="node"},
	an_unknown_node = {under=positions.unknown_node, above=positions.unknown_node_top, type="node"},
	an_unknown_box_center = {under=positions.unknown_box_center, above=positions.unknown_box_center, type="node"},
	a_replaceable_node = {under=positions.buildable_to_box, above=positions.buildable_to_box_top, type="node"},
	nothing = { type="nothing" },
	itself = {under=pos_itself, above=positions.preset_top, type="node"}
}

local function has_custom(def, name)
	local field = def[name]
	return field
		and field ~= core.nodedef_default[name]
		and field ~= core.craftitemdef_default[name]
		and field ~= core.tooldef_default[name]
		and field ~= core.noneitemdef_default[name]
		and field ~= core.rotate_node
end

local node_specific_fields = {}
for key, _ in pairs(core.nodedef_default) do
	if not core.craftitemdef_default[key]
		and not core.tooldef_default[key]
		and not core.noneitemdef_default[key] then
		table.insert(node_specific_fields, key)
	end
end

for name, def in pairs(core.registered_items) do
	local is_node = def.type == "node"

	describe(name, function()
		set_up(function()
			testbox.replace(is_node and name or "default:stone")
		end)

		if has_custom(def, "on_place") then
			for key, var in pairs({
				["on top of a known node"] = pointed_at.a_known_node,
				["on top of an unknown node"] = pointed_at.an_unknown_node,
				["into a replaceable node"] = pointed_at.a_replaceable_node,
				["into an unknown node"] = pointed_at.an_unknown_box_center,
			}) do
				it("can be placed " .. key, function()
					Given "an ItemStack()"
					local stack = ItemStack { name = name, count = initial_stack_size }
					And ("a pointed_thing, pointing " .. key)
					local pointed_thing = var

					When "calling its on_place"
					local left_over_stack = def.on_place(stack, mock_player, pointed_thing)

					Then "return the leftover itemstack"
					assert.is_itemstack(left_over_stack)

					if is_node
						-- most expandable nodes won't like this
						and not key =="into an unknown node"
						-- buildable_to nodes don't seem to like being placed into other buildable_to nodes
						and not (key == "into a replaceable node" and def.buildable_to) then
						-- And "have something placed"
						-- This doesn't work well with e.g. expandable multinode objects.
						-- Or anything else, that might abort the placement.
						-- assert.is_not_equal("air", core.get_node(pos).name)

						And "reduce the itemstack count"
						assert.is_equal(initial_stack_size - 1, left_over_stack:get_count())
					end
				end)
			end
		end

		if def.on_use then
			for key, var in pairs({
				["on top of a known node"] = pointed_at.a_known_node,
				["on top of an unknown node"] = pointed_at.an_unknown_node,
				["into a replaceable node"] = pointed_at.a_replaceable_node,
				["into an unknown node"] = pointed_at.an_unknown_box_center,
				["at nothing"] = pointed_at.nothing,
				["at itself"] = pointed_at.itself,
			}) do
				-- "itself" not pointing at itself, if it's not a node
				if is_node or key ~= "itself" then
					local target = key:gsub("_", " ")
					it("can be used pointing " .. target, function()
						Given("a pointed_thing, pointing " .. target)
						local pointed_thing = var
						And "a player wielding the item"
						mock_player:set_wielded_item(ItemStack(name))

						When "using against it"
						local returned_stack = def.on_use(mock_player:get_wielded_item(), mock_player, pointed_thing)

						Then "return an itemstack or nil"
						if returned_stack ~= nil then
							assert.is_itemstack(returned_stack)
						end
					end)
				end
			end
		end

		if def.after_use then
			its("after_use will return an itemstack or nil", function()
				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				When "being called instead of wearing out the tool"
				local returned_stack = def.after_use(stack, mock_player, core.get_node(positions.known_node), { wear = 1})
				Then "return an itemstack or nil"
				if returned_stack ~= nil then
					assert.is_itemstack(returned_stack)
				end
			end)
		end

		if has_custom(def, "on_drop") then
			it("can be dropped", function()
				When "calling on_drop"
				local left_over_stack = def.on_drop(ItemStack(name), mock_player, positions.dropspot)
				Then "drop the item"
				And "return the leftover itemstack"
				assert.is_itemstack(left_over_stack)

				-- cleanup the spill
				for _, object in ipairs(core.get_objects_inside_radius(positions.dropspot, 1) or {}) do
					object:remove()
				end
			end)
		end

		it("does not use any deprecated fields", function()
			assert.is.Nil(def.tile_images) -- tiles
			assert.is.Nil(def.special_materials) -- special_tiles
		end)

		if not is_node then
			it("does not register any node specific functions without being a node", function()
				local no = assert.is_nil
				for _, field in ipairs(node_specific_fields) do
					no(def[field])
				end
			end)
		end

		if is_node then
			if def.on_punch ~= core.nodedef_default.on_punch and def.on_punch then
				it("can be punched by a player", function()
					def.on_punch(pos_itself, core.get_node(pos_itself), mock_player, pointed_at.itself)
				end)
				it("can be punched by core.punch_node(pos) (nil player)", function()
					core.punch_node(pos_itself)
				end)
			end

			if def.on_right_click then
				it("can be rightclicked without pointed_thing", function()
					Given "no pointed_thing at all"
					And "a simple ItemStack()"
					local stack = ItemStack("default:stone 1")

					When "right clicked"
					local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), mock_player, stack, nil)

					Then "return the leftover itemstack"
					assert.is_itemstack(left_over_stack)

				end)
				it("can be rightclicked by an empty handed player", function()
					Given "a pointed_thing"
					local pointed_thing = pointed_at.itself
					And "an empty ItemStack()"
					local stack = ItemStack()

					When "right clicked"
					local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), mock_player, stack, pointed_thing)

					Then "return the leftover itemstack"
					assert.is_itemstack(left_over_stack)
				end)
				it("can be rightclicked by an undefined itemstack", function()
					Given "a pointed_thing"
					local pointed_thing = pointed_at.itself
					And "an undefined ItemStack()"
					-- from the api: _if defined_, itemstack will hold clicker's wielded item
					local stack = nil

					When "right clicked"
					local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), mock_player, stack, pointed_thing)

					Then "return the leftover itemstack"
					assert.is_itemstack(left_over_stack)
				end)
			end

			if def.on_receive_fields then
				it("can receive an empty formspec response", function()
					def.on_receive_fields(pos_itself, name, {}, mock_player)
				end)
			end

			if def.can_dig then
				-- this is essentially what core.dig_node(pos) would do, too
				it("handles a null player passed to its can_dig(pos, [player])", function()
					When "being called"
					local can_be_dug = def.can_dig(pos_itself, nil)
					Then "return true if node can be dug, or false if not"
					assert.is_boolean(can_be_dug)
				end)
			end
		end
	end)
end
