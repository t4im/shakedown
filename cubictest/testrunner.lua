local table, string = table, string
local cubictest, reporter, events = cubictest, cubictest.reporter, cubictest.events
local Start, End, Step, Error, Run = events.Start, events.End, events.Step, events.Error, events.Run

local specifications = {}
cubictest.specifications = specifications
local testrunner = {}
cubictest.testrunner = testrunner

-- classes

local Testable = {
	description=nil,
	func= function() error("no test defined") end,
	__tostring = function (self) return self.description end,
	new = function(self, object)
		object = object or {}
		object.children = {}
		if self.__new then
			self.__new(object)
		end
		return setmetatable(object, {
			__index = self,
			__tostring = self.__tostring,
		})
	end,
	add = function(self, child)
		table.insert(self.children, child)
		child.parent = self
	end,
	run = function(self, run_state)
		local parent = self.parent
		-- make sure we don't have stale events from the last run
		-- and start the event log
		self.run_state = run_state

		-- run its test phases
		run_state:add(Start())

		if self._set_up then
			self:_set_up()
		end

		if parent and parent.fixture_before_each then
			parent.fixture_before_each()
		end
		if self.fixture_setup then
			self.fixture_setup()
		end

		-- run, but only if fixtures haven't already failed
		if run_state.success then
			self:_run(run_state)
		end

		if self.fixture_teardown then
			self.fixture_teardown()
		end
		if parent and parent.fixture_after_each then
			parent.fixture_after_each()
		end

		if self._tear_down then
			self:_tear_down()
		end

		run_state:add(End())

		return run_state
	end,
	try = function(self, func, ...)
		local succeed, err_or_result = pcall(func, ...)
		if not succeed then
			self.run_state:add(Error(err_or_result))
		end
		return err_or_result
	end
}
cubictest.Testable = setmetatable(Testable, {
	__tostring = Testable.__tostring,
	__call = function(self, object) return self:new(object) end,
})

cubictest.TestCase = Testable {
	type = "TestCase",
	step = function(self, conjunction, description)
		local step = Step(conjunction, description)
		self.run_state:add(step)
		self.ctx_step = step
		return step
	end,
	_run = function(self, run_state)
		return self:try(self.func)
	end,
}

cubictest.Specification = Testable {
	type = "Specification",
	_set_up = function(self)
		if not self.is_set_up then
			self:try(self.func)
			self.is_set_up = true
		end
	end,
	_run = function(self, run_state)
		for _, testcase in pairs(self.children) do
			testrunner.ctx_case = testcase
			local result_state = testcase:run(Run(testcase, run_state))
			run_state:add(result_state)
		end
		testrunner.ctx_case = nil
	end,
	register_testcase = function(self, description, func)
		local testcase = cubictest.TestCase:new {
			description = description,
			func = func
		}
		self:add(testcase)
		return testcase
	end
}

-- running
function cubictest.testrunner:runAll(filter)
	if type(filter) == "string" then
		filter = cubictest.match.matches(filter)
	end

	local run_state = Run({ type = "Suite" })
	run_state:add(Start())
	for _, spec in pairs(specifications) do
		if not filter or filter(spec) then
			self.ctx_spec = spec
			local result_state = spec:run(Run(spec, run_state))
			run_state:add(result_state)
		end
	end
	self.ctx_spec = nil
	run_state:add(End())
	reporter:report_event(run_state)
	reporter:print()
end

local usage = "<filter> | all"
core.register_chatcommand(core.get_current_modname() .. ":run", {
	description = "Run tests.",
	params = usage,
	privs = { server = true },
	func = function(name,  param)
		if param == "all" then
			cubictest.testrunner:runAll()
			return true
		end

		local filter = string.match(param, "([^ ]+)")
		if filter then
			cubictest.testrunner:runAll(filter)
			return true
		end

		return false, "Usage: " .. usage
	end,
})
