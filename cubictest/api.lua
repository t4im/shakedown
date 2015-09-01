local mtt, testrunner = mtt, mtt.testrunner
--
-- assertions
--
mtt.assert = {
	-- for custom asserts, that aren't available in luassert
	}

local original_assert = assert
setmetatable(mtt.assert, {
	-- make all luassert assertions available
	__index = mtt.luassert,
	-- behave like the default assert if called as such
	__call = function(table, ...) return original_assert(...) end
})
-- use our assert implementation as an drop-in replacement for all asserts
assert = mtt.assert

--
-- test definition language
--
local abstract_test_env = {
	assert = mtt.assert, -- you shall have no other drop-in replacements beside me here
	match = mtt.match,
}
mtt.abstract_test_env = setmetatable(abstract_test_env, { __index = _G })

local testcase_env = {
	Given = function(description) return testrunner.ctx_case:step("Given", description) end,
	When = function(description) return testrunner.ctx_case:step("When", description) end,
	Then = function(description) return testrunner.ctx_case:step("Then", description) end,
	And = function(description) return testrunner.ctx_case:step("And", description) end,
	But = function(description) return testrunner.ctx_case:step("But", description) end,
}
mtt.testcase_env = setmetatable(testcase_env, {__index = abstract_test_env })

local spec_env = {
	it = function(description, func)
		setfenv(func, testcase_env)
		return testrunner.ctx_spec:register_testcase("it " .. description, func)
	end,
	its = function(description, func)
		setfenv(func, testcase_env)
		return testrunner.ctx_spec:register_testcase("its " .. description, func)
	end,
	set_up = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.setup = func
	end,
	tear_down = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.teardown = func
	end,
}

mtt.spec_env = setmetatable(spec_env, {
	__index = abstract_test_env,
	__newindex = function(table, key, value)
		-- alternative way to specify fixtures
		if type(table[key]) == "function" and type(value) == "function" then
			table[key](value)
		end
	end,
})

local suite_env = {
	describe = function(description, func)
		setfenv(func, mtt.spec_env)

		local spec = mtt.Specification:new{
			description = description,
			func = func
		}
		table.insert(mtt.specifications, spec)
		return spec
	end
}
mtt.suite_env = setmetatable(suite_env, { __index = abstract_test_env, })

-- globalized api for ease of use
-- as unit testing framework we can defy the best practice of avoiding globals
-- to ease the creation of unit tests; we are not supposed to run in production anyway
describe = mtt.suite_env.describe
