local pos_itself = smoketest.testbox.positions.preset

return function(name, def)
	if not def.on_blast or def.type ~= "node" then return end

	describe(name .. " on_blast", function()
		it("can be blasted", function()
			def.on_blast(pos_itself, 1)
		end)
	end)
end
