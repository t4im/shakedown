mtt.luassert = require("luassert")
mtt.assert = {
	print = function(msg)
		minetest.log("error", msg)
		minetest.chat_send_all(msg)
	end
}

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
	__call = function(table, ...) table.True(...) end
})

mtt.test = function(title, func)
	local msg = string.format("test: %s", title)
	mtt.notify("action", msg)

	local result, err = pcall(func, mtt.luassert)
	if err then mtt.assert.print(err) end
	return result
end
