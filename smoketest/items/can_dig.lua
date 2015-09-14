local pos_itself = smoketest.testbox.positions.preset

return function(name, def)
	if not def.can_dig or def.type ~= "node" then return end

	describe(name .. " can_dig", function()
		-- this is essentially what core.dig_node(pos) would do, too
		it("handles a null player passed to its can_dig(pos, [player])", function()
			When "being called"
			local can_be_dug = def.can_dig(pos_itself, nil)
			Then "return true if node can be dug, or false if not"
			assert.is_boolean(can_be_dug)
		end)
	end)
end
