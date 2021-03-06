local cubictest, testrunner = cubictest, cubictest.testrunner
local sprintf = string.format
--
-- test definition language
--
local abstract_test_env = {
	assert = cubictest.assert, -- you shall have no other drop-in replacements beside me here
	match = cubictest.match,
	spy = cubictest.spy,
	stub = cubictest.stub,
	mock = cubictest.mock,
	assume = cubictest.assume,
}
cubictest.abstract_test_env = setmetatable(abstract_test_env, { __index = _G })

function string:multi_line_clean()
	return self:gsub("%s+", " "):trim()
end

local conjunctions = { "and", "but" }

local function clean_description(description)
	description = description:lower()
	for _, word in pairs(conjunctions) do
		if description:match("%s".. word .. "%s") then
			core.log("warning", sprintf("conjunction step '%s' found in %q, please split up your tests", word, description))
		end
	end
	return description:multi_line_clean()
end

local testcase_env = {
	Given = function(description) return testrunner.ctx_case:step("Given", description:multi_line_clean()) end,
	When = function(description) return testrunner.ctx_case:step("When", description:multi_line_clean()) end,
	Then = function(description) return testrunner.ctx_case:step("Then", description:multi_line_clean()) end,
	And = function(description) return testrunner.ctx_case:step("And", description:multi_line_clean()) end,
	But = function(description) return testrunner.ctx_case:step("But", description:multi_line_clean()) end,
}
cubictest.testcase_env = setmetatable(testcase_env, {
	__index = function(table, key)
		if key == "self" then
			-- return the testcase definition
			return testrunner.ctx_case
		elseif key == "this" then
			-- return the testrun
			return testrunner.ctx_case.run_state
		end
		return abstract_test_env[key]
	end
})

local spec_env = {
	it = function(description, func)
		setfenv(func, testcase_env)
		return testrunner.ctx_spec:register_testcase("it " .. clean_description(description), func)
	end,
	its = function(description, func)
		setfenv(func, testcase_env)
		return testrunner.ctx_spec:register_testcase("its " .. clean_description(description), func)
	end,
	setup = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.fixture_setup = func
	end,
	teardown = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.fixture_teardown = func
	end,
	before_each = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.fixture_before_each = func
	end,
	after_each = function(func)
		setfenv(func, testcase_env)
		testrunner.ctx_spec.fixture_after_each = func
	end,
}
spec_env.set_up = spec_env.setup
spec_env.tear_down = spec_env.teardown

cubictest.spec_env = setmetatable(spec_env, {
	__index = function(table, key)
		if key == "self" then
			return testrunner.ctx_spec
		elseif key == "this" then
			return testrunner.ctx_spec.run_state
		end
		return abstract_test_env[key]
	end,
	__newindex = function(table, key, value)
		-- alternative way to specify fixtures
		if type(table[key]) == "function" and type(value) == "function" then
			table[key](value)
		end
	end,
})

local suite_env = {
	describe = function(description, func)
		setfenv(func, cubictest.spec_env)

		local spec = cubictest.Specification:new{
			description = description,
			func = func,

			defining_mod = core.get_current_modname(),
		}
		table.insert(cubictest.specifications, spec)
		return spec
	end
}
cubictest.suite_env = setmetatable(suite_env, { __index = abstract_test_env, })

-- globalized api for ease of use
-- as unit testing framework we can defy the best practice of avoiding globals
-- to ease the creation of unit tests; we are not supposed to run in production anyway
describe = cubictest.suite_env.describe
