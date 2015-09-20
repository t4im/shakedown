local smoketest = smoketest
local sam = smoketest.sam
local pointed_at = smoketest.pointed_at

return function(name, def)
	if not def.on_use then return end
	local is_node = def.type == "node"

	describe(name .. " on_use", function()
		for key, var in pairs({
			["on top of a known node"] = pointed_at.a_known_node,
			["on top of an unknown node"] = pointed_at.an_unknown_node,
			["into a filled space"] = pointed_at.a_filled_space,
			["into an unknown_node filled space"] = pointed_at.into_an_unknown_node,
			["into a replaceable node"] = pointed_at.a_replaceable_node,
			["into an unknown box"] = pointed_at.an_unknown_box_bottom,
			["at an entity"] = pointed_at.an_entity,
			["at another player"] = pointed_at.another_player,
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
					sam:set_wielded_item(ItemStack(name))

					When "using against it"
					local returned_stack = def.on_use(sam:get_wielded_item(), sam, pointed_thing)

					Then "return an itemstack or nil"
					if returned_stack ~= nil then
						assert.is_itemstack(returned_stack)
					end
				end)
			end
		end
	end)
end
