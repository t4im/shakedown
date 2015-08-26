local core = minetest

function registered_items(max)
	local registered_items = core.registered_items
	local nested_iterator = pairs(registered_items)
	return function()
		local name, def = nested_iterator()
		if not def then return nil end
		local creative = (def.groups.not_in_creative_inventory and def.groups.not_in_creative_inventory ~= 0)
				or not def.description or def.description ~= ""
		return name, def, creative
	end, registered_items, nil
end
