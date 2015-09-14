local node_specific_fields = {}
for key, _ in pairs(core.nodedef_default) do
	if not core.craftitemdef_default[key]
		and not core.tooldef_default[key]
		and not core.noneitemdef_default[key] then
		table.insert(node_specific_fields, key)
	end
end

return function(name, def)
	local is_node = def.type == "node"

	describe(name .. " definition table", function()
		it("does not use any deprecated fields", function()
			assert.is.Nil(def.tile_images) -- tiles
			assert.is.Nil(def.special_materials) -- special_tiles
		end)
		if not is_node then
			it("does not register any node specific functions without being a node", function()
				local no = assert.is_nil
				for _, field in ipairs(node_specific_fields) do
					no(def[field])
				end
			end)
		end
	end)
end
