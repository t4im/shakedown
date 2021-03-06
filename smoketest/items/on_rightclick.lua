local smoketest = smoketest
local sam = smoketest.sam
local testbox = smoketest.testbox
local pos_itself = smoketest.testbox.positions.preset
local pointed_at = smoketest.pointed_at

return function(name, def)
	if not def.on_rightclick or def.type ~= "node" then return end

	describe(name .. " on_rightclick", function()
		set_up(function()
			testbox.replace(name)
		end)
		it("can be rightclicked without pointed_thing", function()
			Given "no pointed_thing at all"
			And "a simple ItemStack()"
			local stack = ItemStack("default:stone")

			When "right clicked"
			local left_over_stack = def.on_rightclick(pos_itself, core.get_node(pos_itself), sam, stack, nil)

			Then "return the leftover itemstack"
			assert.is_itemstack(left_over_stack)
		end)
		it("can be rightclicked by an empty handed player", function()
			Given "a pointed_thing"
			local pointed_thing = pointed_at.itself
			And "an empty ItemStack()"
			local stack = ItemStack(nil)

			When "right clicked"
			local left_over_stack = def.on_rightclick(pos_itself, core.get_node(pos_itself), sam, stack, pointed_thing)

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
			-- local left_over_stack =
			def.on_rightclick(pos_itself, core.get_node(pos_itself), sam, stack, pointed_thing)

			-- Well, we passed nothing in, can we really expect to get something out?
			--Then "return the leftover itemstack"
			--assert.is_itemstack(left_over_stack)
		end)
	end)
end
