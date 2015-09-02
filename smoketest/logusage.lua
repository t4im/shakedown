-- from the lua manual:
-- "print is not intended for formatted output, but only as a quick way to show a value, typically for debugging."
-- and the minetest documentation:
-- use minetest.log() for serious output, not minetest.debug() (onto which print() is redirected)

--local collected_problems = {}

local wrapped_print = print
print = function(...)
--	local info = debug.getinfo(2, "Sl")
--	local location = string.format("%s:%d", tostring(info.source), info.currentline)
--	local problem = collected_problems[location] or { count = 0 }
--	problem.count = problem.count + 1
	wrapped_print(string.format("%s> %s", core.get_current_modname() or "?", table.concat({...})))
end
