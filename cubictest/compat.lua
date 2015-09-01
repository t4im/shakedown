---
-- lua 5.2 requires debug retrieval via require
debug = debug or require "debug"

---
-- lua 5.2 removes setfenv in favour of _ENV
-- since we make make heavy use of setfenv, and _ENV doesn't support easy setting from the outside
-- (as done in the testing language)
-- use a quick replacement (if necessary) from
-- http://lua-users.org/lists/lua-l/2010-06/msg00314.html
--
setfenv = setfenv or function(func, environment)
	func = (type(func) == 'function' and func or debug.getinfo(func + 1, 'func').func)
	local name
	local up = 0
	repeat
		up = up + 1
		name = debug.getupvalue(func, up)
	until name == '_ENV' or name == nil
	if name then
		-- use unique upvalue, set it to func
		debug.upvaluejoin(func, up, function() return environment end, 1)
	end
end