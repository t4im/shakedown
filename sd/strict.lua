-- from the lua manual:
-- "print is not intended for formatted output, but only as a quick way to show a value, typically for debugging."
-- use minetest.log() for serious output, not minetest.debug() (onto which print() is redirected)
print = function(...)
	local info = debug.getinfo(2, "Sl")
	-- no warning level yet
	minetest.log("error", string.format("Forgotten debug statement %s(%d)",
			tostring(info.source),
			info.linedefined))
	mtt.print(string.format("-> %s", table.concat({...})))
end
