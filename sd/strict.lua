-- from the lua manual:
-- "print is not intended for formatted output, but only as a quick way to show a value, typically for debugging."
-- use minetest.log() for serious output, not minetest.debug() (onto which print() is redirected)
local wrapped_print = print
print = function(...)
	local info = debug.getinfo(2, "Sl")
	-- no warning level yet
	core.log("error", string.format("Forgotten debug statement %s(%d)",
		tostring(info.source),
		info.linedefined))
	wrapped_print(string.format("-> %s", table.concat({...})))
end
