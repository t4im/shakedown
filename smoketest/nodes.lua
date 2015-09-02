local pos = { x=0, y=10, z=0 }
local unknown_node_pos = { x=0, y=9, z=0 }
local testPlayer = cubictest.mocks.Player:new()
local initial_stack_size = 5

for name, def in pairs(core.registered_nodes) do
	describe("Node: " .. name, function()
		set_up(function()
			core.set_node(pos, { name = "air"})
			cubictest.provider.map_content(unknown_node_pos, cubictest.constants.CONTENT_UNKNOWN)
		end)

		if def.on_place then
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

		if def.on_punch then
			it("can be punched", function()
				def.on_punch(pos, core.get_node(pos), testPlayer, {under=pos, above={x=pos.x, y=pos.y+1, z=pos.z}, type="node"})
			end)
		end

		if def.can_dig then
			it("handles a null player passed to its can_dig(pos, [player])", function()
				def.can_dig(pos, nil)
			end)
		end
	end)
end
