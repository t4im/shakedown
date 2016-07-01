local format = string.format

local node_specific_fields = {}
for key, _ in pairs(core.nodedef_default) do
	if not core.craftitemdef_default[key]
		and not core.tooldef_default[key]
		and not core.noneitemdef_default[key] then
		table.insert(node_specific_fields, key)
	end
end

local no = assert.is.Nil
local are_not_equal = assert.are_not_equal

return function(name, def)
	local is_node = def.type == "node"

	describe(name .. " definition table", function()
		it("does not use any deprecated fields", function()
			no(def.tile_images) -- tiles
			no(def.special_materials) -- special_tiles
		end)
		if not is_node then
			it("does not register any node specific functions without being a node", function()
				for _, field in ipairs(node_specific_fields) do
					no(def[field])
				end
			end)
		end
		--TODO ~1s (5s before localization) loop, perhaps we avoid back and forth testing later?
		it("does not share its definition table with another item", function()
			for item_name, item_def in pairs(core.registered_items) do
				if item_name ~= name then -- skip us self
					are_not_equal(item_def, def, format("Item %s has the same table as %s", item_name, name))
				end
			end
		end)
	end)
end
