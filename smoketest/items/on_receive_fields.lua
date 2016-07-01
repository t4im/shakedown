local smoketest = smoketest
local sam = smoketest.sam
local testbox = smoketest.testbox
local pos_itself = smoketest.testbox.positions.preset

return function(name, def)
	if def.type ~= "node"
		or not def.on_receive_fields then return end

	describe(name .. " on_receive_fields", function()
		set_up(function()
			testbox.replace(name)
		end)
		it("can receive an empty formspec response", function()
			def.on_receive_fields(pos_itself, name, {}, sam)
		end)
	end)
end
