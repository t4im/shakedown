local pos = { x=0, y=10, z=0 }
local unknown_node_pos = { x=0, y=9, z=0 }
local testPlayer = cubictest.mocks.Player:new()
local initial_stack_size = 5

for name, def in pairs(core.registered_nodes) do
	describe(name, function()
		set_up(function()
			core.set_node(pos, { name = "air"})
			cubictest.provider.map_content(unknown_node_pos, cubictest.constants.CONTENT_UNKNOWN)
		end)

		it("doesn't use any deprecated fields", function()
			assert.is.Nil(def.tile_images) -- tiles
			assert.is.Nil(def.special_materials) -- special_tiles
		end)

		if def.on_drop ~= core.nodedef_default.on_drop and def.on_drop then
			it("can be dropped", function()
				def.on_drop(ItemStack(name), testPlayer, pos)
			end)
		end

		if def.on_use then
			it("can be used", function()
				-- apples for example
				def.on_use(ItemStack(name), testPlayer, {under=unknown_node_pos, above=pos, type="node"})
			end)
		end

		if def.on_place ~= core.nodedef_default.on_place
			and def.on_place ~= core.rotate_node
			and def.on_place then
			it("can be placed against an unknown node and will be removed from the ItemStack", function()
				Given "an ItemStack(node)"
				local stack = ItemStack { name = name, count = initial_stack_size }
				And "a pointed_thing, pointing at an unknown node"
				local pointed_thing = {under=unknown_node_pos, above=pos, type="node"}

				When "placing it"
				local left_over_stack = def.on_place(stack, testPlayer, pointed_thing)

				Then "remove it from the ItemStack"
				assert.is.equal(initial_stack_size - 1, left_over_stack:get_count())
			end)
		end

		if def.on_punch ~= core.nodedef_default.on_punch and def.on_punch then
			it("can be punched by a player", function()
				def.on_punch(pos, core.get_node(pos), testPlayer, {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"})
			end)
			it("can be punched by core.punch_node(pos) (nil player)", function()
				core.punch_node(pos)
			end)
		end

		if def.on_right_click then
			it("can be rightclicked by an empty handed player", function()
				def.on_right_click(pos, core.get_node(pos), testPlayer, ItemStack(), {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"})
			end)
		end

		if def.on_receive_fields then
			it("can receive an emtpy formspec response", function()
				def.on_receive_fields(pos, name, {}, testPlayer)
			end)
		end

		if def.can_dig then
			it("handles a null player passed to its can_dig(pos, [player])", function()
				-- this is essentially what core.dig_node(pos) would do, too
				def.can_dig(pos, nil)
			end)
		end

	end)
end
