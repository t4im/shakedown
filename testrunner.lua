local reporter = mtt.reporter
local write = reporter.write
local report = reporter.formatter

local specifications = {}

-- classes
mtt.Testable = {
	description=nil,
	func= function() error("no test defined") end,
	success = nil,
	__tostring = function (self) return self.description end,
	new = function(self, object)
		self.__index = self
		return setmetatable(object or {}, self)
	end,
	fail = function(self, err)
		self.success = false
		report: error(tostring(err))
	end,
	try = function(self, func, ...)
		if not self.success then return end
		local result, err = pcall(func, ...)
		if err then
			self:fail(err)
		end
		return result, err
	end
}

mtt.TestCase = mtt.Testable:new{
	run = function(self)
		self.success = true
		report: testcase(self.description)
		local result, err = self:try(self.func, mtt.assert)
		return result
	end,
}

local current_case = nil
mtt.Specification = mtt.Testable:new{
	new = function(self, object)
		object = mtt.Testable.new(self, object)
		object.testcases = {}
		return object
	end,
	fail = function(self, err)
		self.success = false
		report: spec_error(tostring(err))
	end,
	run = function(self)
		self.success = true
		report: specification(self.description)
		local result, err = self:try(self.func)

		if self.before then self.before() end
		local ok, fail = 0, 0
		for _, testcase in pairs(self.testcases) do
			current_case = testcase
			testcase:run()
			if testcase.success then
				ok = ok + 1
			else
				fail = fail + 1
			end
		end
		if fail > 0 then self.success = false end
		if self.after then self.after() end

		report: spec_summary(ok, fail)
		reporter.flush(self.success and "action" or "error")
		return result
	end,
	register_testcase = function(self, description, func)
		local testcase = mtt.TestCase:new{
			description = description,
			func = func
		}
		table.insert(self.testcases, testcase)
		return testcase
	end
}

-- running
local current_spec = nil
function mtt.runAll()
	local ok, fail = 0, 0
	for _, spec in pairs(specifications) do
		current_spec = spec
		spec:run()
		if spec.success then
			ok = ok + 1
		else
			fail = fail + 1
		end
	end
	current_spec = nil
	report: summary(ok, fail)
	reporter.flush()
end

-- define function environments for more control over the dsl (and less _G pollution)
local testcase_env =
	setmetatable({
		Given = function(description) report: step("Given", description) end,
		When = function(description) report: step("When", description) end,
		Then = function(description) report: step("Then", description) end,
	}, {__index = _G})
mtt.testcase_env = testcase_env

mtt.spec_env = {
	it = function(description, func)
		setfenv(func, testcase_env)
		return current_spec:register_testcase("it " .. description, func)
	end,
	given = function(description, func)
		setfenv(func, testcase_env)
		return current_spec:register_testcase("given " .. description, func)
	end,
	before = function(func)
		setfenv(func, testcase_env)
		current_spec.before = func
	end,
	after = function(func)
		setfenv(func, testcase_env)
		current_spec.after = func
	end,
}

-- globalized api for ease of use
-- as unit testing framework we can defy the best practice of avoiding globals
-- to ease the creation of unit tests; we are not supposed to run in production anyway
function describe(description, func)
	setfenv(func, setmetatable(mtt.spec_env, {__index = _G}))

	local spec = mtt.Specification:new{
		description = description,
		func = func
	}
	table.insert(specifications, spec)
	return spec
end
