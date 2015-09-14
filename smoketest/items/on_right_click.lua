local smoketest = smoketest
local sam = smoketest.sam
local positions = smoketest.testbox.positions
local pos_itself = positions.preset
local pointed_at = smoketest.pointed_at

return function(name, def)
	if not def.on_right_click or def.type ~= "node" then return end

	describe(name .. " on_right_click", function()
		it("can be rightclicked without pointed_thing", function()
			Given "no pointed_thing at all"
			And "a simple ItemStack()"
			local stack = ItemStack("default:stone 1")

			When "right clicked"
			local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), sam, stack, nil)

			Then "return the leftover itemstack"
			assert.is_itemstack(left_over_stack)

		end)
		it("can be rightclicked by an empty handed player", function()
			Given "a pointed_thing"
			local pointed_thing = pointed_at.itself
			And "an empty ItemStack()"
			local stack = ItemStack()

			When "right clicked"
			local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), sam, stack, pointed_thing)

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
			local left_over_stack = def.on_right_click(pos_itself, core.get_node(pos_itself), sam, stack, pointed_thing)

			Then "return the leftover itemstack"
			assert.is_itemstack(left_over_stack)
		end)
	end)

end
