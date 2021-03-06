cubictest:register_matcher("in_creative_inventory", function(state, arguments, level)
	return function(item)
		if type(item) == "string" then
			item = core.registered_items[item]
		end
		return not(
			-- list of reasons, why it wouldn't be
			not item
			or not item.description
			or item.description == ""
			or item.groups.not_in_creative_inventory and item.groups.not_in_creative_inventory ~= 0
			)
	end
end)
