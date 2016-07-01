local smoketest = smoketest
local sam = smoketest.sam
local testbox = smoketest.testbox
local pos_itself = smoketest.testbox.positions.preset
local pointed_at = smoketest.pointed_at

return function(name, def)
	if def.type ~= "node"
		or def.on_punch == core.nodedef_default.on_punch
		or not def.on_punch then return end

	describe(name .. " on_punch", function()
		set_up(function()
			testbox.replace(name)
		end)
		it("can be punched by a player", function()
			def.on_punch(pos_itself, core.get_node(pos_itself), sam, pointed_at.itself)
		end)
		it("can be punched by core.punch_node(pos) (nil player)", function()
			core.punch_node(pos_itself)
		end)
	end)
end
