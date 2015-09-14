local positions = smoketest.testbox.positions
local sam = smoketest.sam

local function has_custom(def, name)
	local field = def[name]
	return field
		and field ~= core.nodedef_default[name]
		and field ~= core.craftitemdef_default[name]
		and field ~= core.tooldef_default[name]
		and field ~= core.noneitemdef_default[name]
end

return function(name, def)
	if not has_custom(def, "on_drop") then return end

	describe(name .. " on_drop", function()
		it("can be dropped", function()
			When "calling on_drop"
			local left_over_stack = def.on_drop(ItemStack(name), sam, positions.dropspot)
			Then "drop the item"
			And "return the leftover itemstack"
			assert.is_itemstack(left_over_stack)

			-- cleanup the spill
			for _, object in ipairs(core.get_objects_inside_radius(positions.dropspot, 1) or {}) do
				object:remove()
			end
		end)
	end)

end
