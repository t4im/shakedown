local out = {}
local function print(text, ...)
	if (...) then
		table.insert(out, string.format(text, ...))
	else
		table.insert(out, text)
	end
end
local failed = false
local function try(msg, func, ...)
	local result, err = pcall(func, ...)
	if err then
		print(msg, tostring(err))
		failed = true
	end
	return result, err
end

local function flush()
	local level = (not failed) and "action" or "error"
	table.insert(out, "\n")
	local msg = table.concat(out, "\n")
	out = {}
	failed = false

	minetest.log(level, msg)
	minetest.chat_send_all(level .. ": " .. msg)
end

function describe(description, func)
	print("\n/==[ %70s ]===", description)
	local result, err = try("! fails during setup:\n%s", func)
	print("\\" .. string.rep("=", 66) .. "[ %6s ]===" , (not failed) and "ok" or "failed")
	flush()
	return result
end

function given(description, func)
	print("| given %s", description)
	local result, err = try("! which was not given:\n%s", func)
	return result
end

function it(description, func)
	print("| it %s", description)
	local result, err = try("! if it would not fail with:\n%s", func, mtt.luassert)
	return result
end
