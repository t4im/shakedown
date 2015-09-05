local pos = { x=0, y=10, z=0 }
local unknown_node_pos = { x=0, y=9, z=0 }
local mock_player = cubictest.mocks.Player:new()
local initial_stack_size = 5

for name, def in pairs(core.registered_items) do
	local is_node = def.type == "node"

	describe(name, function()
		set_up(function()
			core.set_node(pos, { name = "air"})
			cubictest.provider.map_content(unknown_node_pos, cubictest.constants.CONTENT_UNKNOWN)
		end)

		if is_node
			and def.on_place ~= core.nodedef_default.on_place
			and def.on_place then
			it("can be placed against an unknown node and will be removed from the ItemStack", function()
				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				And "a pointed_thing, pointing at an unknown node"
				local pointed_thing = {under=unknown_node_pos, above=pos, type="node"}

				When "calling its on_place"
				local left_over_stack = def.on_place(stack, mock_player, pointed_thing)

				Then "place something"
				assert.is_not_equal("air", core.get_node(pos).name)

				And "return the leftover itemstack"
				assert.is_truthy(left_over_stack)
				-- TODO better

				And "reduce the itemstack count"
				assert.is_equal(initial_stack_size - 1, left_over_stack:get_count())
			end)
		elseif not is_node
			and	def.on_place ~= core.craftitemdef_default.on_place
			and def.on_place ~= core.tooldef_default.on_place
			and def.on_place ~= core.noneitemdef_default.on_place
			and def.on_place then
			it("can be placed against an unknown node", function()
				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				And "a pointed_thing, pointing at an unknown node"
				local pointed_thing = {under=unknown_node_pos, above=pos, type="node"}

				When "calling its on_place"
				local left_over_stack = def.on_place(stack, mock_player, pointed_thing)

				Then "return the leftover itemstack"
				assert.is_truthy(left_over_stack)
				-- TODO better
			end)
		end

		if def.on_drop ~= core.nodedef_default.on_drop
			and def.on_drop ~= core.craftitemdef_default.on_drop
			and def.on_drop ~= core.tooldef_default.on_drop
			and def.on_drop ~= core.noneitemdef_default.on_drop
			and def.on_drop then
			it("can be dropped", function()
				When "calling on_drop"
				local left_over_stack = def.on_drop(ItemStack(name), mock_player, pos)
				Then "drop the item"
				And "return the leftover itemstack"
				assert.is_truthy(left_over_stack)
				-- TODO better
			end)
		end

		if def.on_use then
			it("can be used pointing at unknown nodes", function()
				Given "a pointed_thing, pointing at an unknown node"
				local pointed_thing = {under=unknown_node_pos, above=pos, type="node"}
				And "a player wielding the item"
				mock_player:set_wielded_item(ItemStack(name))

				When "using against it"
				local returned_stack = def.on_use(mock_player:get_wielded_item(), mock_player, pointed_thing)

				Then "return either an itemstack or nil"
				-- TODO
			end)
			it("can be used pointing at nothing", function()
				Given "a pointed_thing, pointing at nothing"
				local pointed_thing = { type="nothing" }
				And "a player wielding the item"
				mock_player:set_wielded_item(ItemStack(name))

				When "using against it"
				local returned_stack = def.on_use(mock_player:get_wielded_item(), mock_player, pointed_thing)

				Then "return either an itemstack or nil"
				-- TODO
			end)
		end

		if def.after_use then
			its("after_use will return an itemstack or nil", function()
				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				When "being called instead of wearing out the tool"
				local returned_stack = def.after_use(stack, mock_player, core.get_node(pos), { wear = 1})
				Then "return an itemstack or nil"
				-- TODO
			end)
		end

		if not is_node then
			local node_specific_fields = {}
			for key, _ in pairs(core.nodedef_default) do
				if not core.craftitemdef_default[key]
					and not core.tooldef_default[key]
					and not core.noneitemdef_default[key] then
					table.insert(node_specific_fields, key)
				end
			end

			it("does not register any node specific functions without being a node", function()
				local no = assert.is_nil
				for _, field in ipairs(node_specific_fields) do
					no(def[field])
				end
			end)
		end

		if is_node then
			it("doesn't use any deprecated fields", function()
				assert.is.Nil(def.tile_images) -- tiles
				assert.is.Nil(def.special_materials) -- special_tiles
			end)

			if def.on_punch ~= core.nodedef_default.on_punch and def.on_punch then
				it("can be punched by a player", function()
					def.on_punch(pos, core.get_node(pos), mock_player, {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"})
				end)
				it("can be punched by core.punch_node(pos) (nil player)", function()
					core.punch_node(pos)
				end)
			end

			if def.on_right_click then
				it("can be rightclicked without pointed_thing", function()
					Given "no pointed_thing at all"
					And "a simple ItemStack()"
					local stack = ItemStack("default:stone 1")

					When "right clicked"
					def.on_right_click(pos, core.get_node(pos), mock_player, stack)

					Then "return the leftover itemstack"
					assert.is_truthy(left_over_stack)
					-- TODO better

				end)
				it("can be rightclicked by an empty handed player", function()
					Given "a pointed_thing"
					local pointed_thing = {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"}
					And "an empty ItemStack()"
					local stack = ItemStack("default:stone 1")

					When "right clicked"
					def.on_right_click(pos, core.get_node(pos), mock_player, stack, pointed_thing)

					Then "return the leftover itemstack"
					assert.is_truthy(left_over_stack)
					-- TODO better
				end)
				it("can be rightclicked by an undefined itemstack", function()
					Given "a pointed_thing"
					local pointed_thing = {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"}
					And "an undefined ItemStack()"
					-- from the api: _if defined_, itemstack will hold clicker's wielded item
					local stack = nil

					When "right clicked"
					def.on_right_click(pos, core.get_node(pos), mock_player, stack, pointed_thing)

					Then "return the leftover itemstack"
					assert.is_truthy(left_over_stack)
					-- TODO better
				end)
			end

			if def.on_receive_fields then
				it("can receive an emtpy formspec response", function()
					def.on_receive_fields(pos, name, {}, mock_player)
				end)
			end

			if def.can_dig then
				-- this is essentially what core.dig_node(pos) would do, too
				it("handles a null player passed to its can_dig(pos, [player])", function()
					When "being called"
					local can_be_dug = def.can_dig(pos, nil)
					Then "return true if node can be dug, or false if not"
					assert.is_boolean(can_be_dug)
				end)
			end
		end
	end)
end
