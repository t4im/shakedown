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
	success = nil,
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
	add_event = function(self, event)
		table.insert(self.events, event)
		self.last_event = event
		return event
	end,
	add = function(self, child)
		table.insert(self.children, child)
	end,
	_start = function(self)
		-- lets start positive, sadness will come on its own
		self.success = true

		-- make sure we don't have stale events from the last run
		self.events = {}
		self.last_event = nil

		-- then start the event log
		self:add_event(Start(self))

		-- and set up the testable for its run
		self:_set_up()
	end,
	_end = function(self, report)
		self:_tear_down()
		self:add_event(End(self, report or {}))
	end,
	_fail = function(self, err)
		-- :'-(
		self.success = false
		self:add_event(Error(self, err))
	end,
	run = function(self)
		self:_start()
		self:_run()
	end,
	report = function(self)
		for index, event in ipairs(self.events) do
			event:report()
		end
	end,
	try = function(self, func, ...)
		if not self.success then return end
		local result, err = pcall(func, ...)
		if err then
			self:_fail(err)
		end
		return result
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
		self:add_event(step)
		self.ctx_step = step
		return step
	end,
	_set_up = function(self)
	end,
	_tear_down = function(self)
	end,
	_run = function(self)
		local result = self:try(self.func)
		-- passed steps are atm all events minus the start event, if nothing happened
		self:_end({ passed=#(self.events)-1 })
		return result
	end,
}

cubictest.Specification = Testable {
	type = "Specification",
	_set_up = function(self)
		if not self.is_set_up then
			self:try(self.func)
			self.is_set_up = true
		end
		if self.fixture_setup then self.fixture_setup() end
	end,
	_tear_down = function(self)
		if self.fixture_teardown then self.fixture_teardown() end
	end,
	_run = function(self)
		local ok, fail = 0, 0
		for _, testcase in pairs(self.children) do
			testrunner.ctx_case = testcase
			testcase:run()
			if testcase.success then
				ok = ok + 1
			else
				fail = fail + 1
			end
			self:add_event(Run(testcase))
		end
		testrunner.ctx_case = nil

		if fail > 0 then self.success = false end
		self:_end({passed = ok, failed = fail})
		self:report()
		reporter.flush(self.success and "action" or "error")
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

	local ok, fail = 0, 0
	Start({ type = "Suite" }):report()
	reporter.flush()
	for _, spec in pairs(specifications) do
		if not filter or filter(spec) then
			self.ctx_spec = spec
			spec:run()
			if spec.success then
				ok = ok + 1
			else
				fail = fail + 1
			end
		end
	end
	self.ctx_spec = nil
	End({ type = "Suite" }, {passed = ok, failed = fail}):report()
	reporter.flush()
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
		end

		return false, "Usage: " .. usage
	end,
})
