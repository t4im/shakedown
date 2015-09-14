local smoketest = smoketest
local sam = smoketest.sam
local positions = smoketest.testbox.positions
local initial_stack_size = 5

return function(name, def)
	if not def.after_use then return end
	describe(name .. " after_use", function()
		its("after_use will return an itemstack or nil", function()
			Given "an ItemStack()"
			local stack = ItemStack { name = name, count = initial_stack_size }
			When "being called instead of wearing out the tool"
			local returned_stack = def.after_use(stack, sam, core.get_node(positions.known_node), { wear = 1})
			Then "return an itemstack or nil"
			if returned_stack ~= nil then
				assert.is_itemstack(returned_stack)
			end
		end)
	end)
end
