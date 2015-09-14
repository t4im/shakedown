local smoketest = smoketest
local sam = smoketest.sam
local testbox = smoketest.testbox
local positions = smoketest.testbox.positions
local pointed_at = smoketest.pointed_at
local expect_infinite_stacks = smoketest.expect_infinite_stacks
local initial_stack_size = 5

local function has_custom(def, name)
	local field = def[name]
	return field
		and field ~= core.nodedef_default[name]
		and field ~= core.craftitemdef_default[name]
		and field ~= core.tooldef_default[name]
		and field ~= core.noneitemdef_default[name]
		and field ~= core.rotate_node
end

return function(name, def)
	if not has_custom(def, "on_place") then return end
	local is_node = def.type == "node"

	describe(name .. " on_place", function()
		set_up(function()
			testbox.replace(is_node and name or "default:stone")
		end)

		for key, var in pairs({
			["on a known node"] = {
				at = def.hint and def.hint.place_on == "bottom" and pointed_at.a_known_node_from_bottom or pointed_at.a_known_node,
				succeed = true,
			},
			["on an unknown node"] = {
				at = def.hint and def.hint.place_on == "bottom" and pointed_at.an_unknown_node_from_bottom or pointed_at.an_unknown_node,
				succeed = true,
			},
			["into an already filled space"] = {
				at = pointed_at.a_filled_space,
				-- this is supposed to fail by design
				succeed = false,
			},
			["into an unknown_node filled space"] = {
				at = pointed_at.into_an_unknown_node,
				-- this is supposed to fail by design
				succeed = false,
			},
			["into a replaceable node"] = {
				at = pointed_at.a_replaceable_node,
				-- buildable_to nodes don't seem to like being placed into other buildable_to nodes
				-- and we don't support bottom places nodes yet in this scenario
				succeed = (not def.hint or def.hint.place_on ~= "bottom") and not def.buildable_to,
				replace = "default:water_source",
			},
			["into an unknown node box"] = {
				at = def.hint and def.hint.place_on == "bottom" and pointed_at.an_unknown_box_top or pointed_at.an_unknown_box_bottom,
				-- most expandable nodes won't like this
				-- some might
				succeed = nil,
			},

		}) do
			it("can be placed " .. key, function()
				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				And ("a pointed_thing, pointing " .. key)
				local pointed_thing = var.at

				When "calling its on_place"
				local left_over_stack = def.on_place(stack, sam, pointed_thing)

				if is_node then
					if var.replace and var.succeed == true then
						Then "replace the buildable_to node"
						assert.is_not_equal(var.replace, core.get_node(pointed_thing.under).name)
					else
						Then "do not replace pointed_thing.under"
						assert.is_not_equal(name, core.get_node(pointed_thing.under).name)
					end
				end

				And "return the leftover itemstack"
				assert.is_itemstack(left_over_stack)

				if is_node then
					if not expect_infinite_stacks and var.succeed == true then
						-- And "have something placed"
						-- This doesn't work well with e.g. expandable multinode objects.
						-- Or anything else, that might abort the placement.
						And "reduce the itemstack count"
						assert.is_equal(initial_stack_size - 1, left_over_stack:get_count())
					elseif not expect_infinite_stacks and var.succeed == false then -- not nil!
						But "do not reduce the itemstack count"
						assert.is_equal(initial_stack_size, left_over_stack:get_count())
					end
				end
			end)
		end
	end)
end
