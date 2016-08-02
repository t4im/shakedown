local smoketest = smoketest
local sam = smoketest.sam
local testbox = smoketest.testbox
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
		and field ~= core.item_place
end

local function clear_spies(def)
	core.is_protected:clear()
	if def.after_place_node then
		def.after_place_node:clear()
	end
end

return function(name, def)
	if not has_custom(def, "on_place") then return end
	local is_node = def.type == "node"
	local hint = def.hint or {}

	describe(name .. " on_place", function()
		set_up(function()
			testbox.replace(is_node and name or "default:stone")

			spy.on(core, "is_protected")
			if def.after_place_node then
				spy.on(def, "after_place_node")
			end
		end)

		for key, var in pairs({
			["on a known node"] = {
				at = hint.place_on == "bottom" and pointed_at.a_known_node_from_bottom or pointed_at.a_known_node,
				succeed = true,
			},
			["on an unknown node"] = {
				at = hint.place_on == "bottom" and pointed_at.an_unknown_node_from_bottom or pointed_at.an_unknown_node,
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
				succeed = hint.place_on ~= "bottom" and not def.buildable_to,
				replace = true,
			},
			["into an unknown node box"] = {
				at = hint.place_on == "bottom" and pointed_at.an_unknown_box_top or pointed_at.an_unknown_box_bottom,
				-- most expandable nodes won't like this
				-- some might
				succeed = nil,
			},

		}) do
			it("can be called " .. key, function()
				local parent = this.parent

				Given "an ItemStack()"
				local stack = ItemStack { name = name, count = initial_stack_size }
				And ("a pointed_thing, pointing " .. key)
				local pointed_thing = var.at

				local before_above = core.get_node(var.at.above)
				local before_under = core.get_node(var.at.under)
				parent.changed_above = false
				parent.changed_under = false

				When "calling its on_place"
				clear_spies(def)
				local leftover_stack = def.on_place(stack, sam, pointed_thing)
				parent.leftover = leftover_stack

				local new_above = core.get_node(var.at.above)
				local new_under = core.get_node(var.at.under)
				parent.changed_above = before_above.name ~= new_above.name
				parent.changed_under = before_under.name ~= new_under.name
				parent.placed = parent.changed_above or parent.changed_under
			end)

			it("shall return the leftover itemstack when placed " .. key, function()
				assert.is_itemstack(this.parent.leftover)
			end)

			if is_node then
				it("places a node if expected " .. key, function()
					if var.succeed == true then
						When "placement is expected"
						Then "place something"
						-- We can only assume at the moment
						-- Since we have no way of knowing,
						-- if a node expects certain nodes to be placed on
						-- e.g. wheat/cotton on soil, lily on water
						assume.is_true(this.parent.placed)
						-- assert.is_true(this.parent.placed)
					elseif var.succeed == false then
						When "no placement is expected"
						Then "don't place something"
						assume.is_false(this.parent.placed)
					end
				end)

				it("returns the correct itemstack count when placed " .. key, function()
					if expect_infinite_stacks then
						When "placed in creative"
						And "a leftover Itemstack was returned"
						assume.is_truthy(this.parent.leftover)
						Then "do not reduce the itemstack count"
						assert.is_equal(initial_stack_size, this.parent.leftover:get_count())
					else
						When "placed not in creative"
						And "a leftover Itemstack was returned"
						assume.is_truthy(this.parent.leftover)
						if this.parent.placed == true then
							And "something was placed"
							Then "reduce the itemstack count"
							assert.is_equal(initial_stack_size - 1, this.parent.leftover:get_count())
						else
							And "something was not placed"
							Then "do not reduce the itemstack count"
							assert.is_equal(initial_stack_size, this.parent.leftover:get_count())
						end
					end
				end)

				it("respects buildable_to when placed " .. key, function()
					When "placed"
					if var.replace and var.succeed == true then
						assume.is_true(this.parent.placed)
						Then "replace a pointed_thing.under, that is buildable_to"
						assert.is_true(this.parent.changed_under)
					else
						Then "don't replace a pointed_thing.under, that is not buildable_to"
						assert.is_false(this.parent.changed_under)
					end
				end)

				if hint.protection_check == true
						or (var.succeed ~= false and hint.protection_check ~= false) then
					it("checks protection when placed " .. key, function()
						assume.is_true(this.parent.placed)
						assert.spy(core.is_protected).was_called_with(match.is_table(), sam:get_player_name())
					end)
				end
			end


			if def.after_place_node and var.succeed == true then
				it("calls its after_place_node after placed" .. key, function()
					assume.is_true(this.parent.placed)
					assert.spy(def.after_place_node).was_called()
				end)
			end
		end

		tear_down(function()
			clear_spies(def)
		end)
	end)
end
