local tests = {}

-- output buffer
local out = {}
local function print(text, ...)
	if (...) then
		table.insert(out, string.format(text, ...))
	else
		table.insert(out, text)
	end
end
local function flush(success)
	local level = success and "action" or "error"
	table.insert(out, "\n")
	local msg = table.concat(out, "\n")
	out = {}

	minetest.log(level, msg)
	minetest.chat_send_all(level .. ": " .. msg)
end

-- test class
mtt.Test = {
	description=nil,
	func=function() error("no test setup defined") end,
}

function mtt.Test:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.description end
	return object
end

function mtt.Test:try(msg, func, ...)
	if not self.success then return end
	local result, err = pcall(func, ...)
	if err then
		self.success = false
		print(msg, tostring(err))
	end
	return result, err
end

function mtt.Test:run()
	self.success = true
	print("\n/==[ %70s ]===", self.description)
	local result, err = self:try("! fails during setup:\n%s", self.func)

	print("\\" .. string.rep("=", 66) .. "[ %6s ]===" , self.success and "ok" or "failed")
	flush(self.success)
	return result
end

-- running
local current = nil
function mtt.runAll()
	local ok, fail = 0, 0
	for _, test in pairs(tests) do
		current = test
		test:run()
		if test.success then
			ok = ok + 1
		else
			fail = fail + 1
		end
	end
	local summary = string.format("***** Run %d tests (%d ok, %d failed) *****", ok+fail, ok, fail)
	minetest.log("action", summary)
	minetest.chat_send_all(summary)
end

-- description api
function describe(description, func)
	local test = mtt.Test:new{
		description = description,
		func = func
	}
	table.insert(tests, test)
	return test
end

function given(description, func)
	print("| given %s", description)
	return current:try("! which was not given:\n%s", func)
end

function it(description, func)
	print("| it %s", description)
	return current:try("! if it would not fail with:\n%s", func, mtt.luassert)
end
