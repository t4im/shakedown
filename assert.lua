mtt.luassert = require("luassert")
mtt.assert = {
	print = function(msg)
		minetest.log("error", msg)
		minetest.chat_send_all(msg)
	end
}

local original_assert = assert
setmetatable(mtt.assert, {
	__index = function(table, key)
		local ref = mtt.luassert[key]
		local ref_type = type(ref)
		local ref_metatable = getmetatable(ref)
		if ref_type == "function" then
			return function(...)
				return ref(...)
			end
		elseif ref_type == "table" then
			return ref
		elseif ref_type == "nil" then
			error("unknown assertion: " .. key)
		end
		error("unexpected datatype " .. tostring(type(ref)) .. " while looking for " .. key)
	end,
	__call = function(table, ...) return original_assert(...) end
})

-- convenience overwrite
assert = mtt.assert
