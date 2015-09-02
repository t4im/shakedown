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
		object.events = {}
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
	_start = function(self)
		-- lets start positive, sadness will come on its own
		self.success = true
		self:add_event(Start(self))
	end,
	_end = function(self, report)
		self:add_event(End(self, report or {}))
	end,
	_fail = function(self, err)
		-- :'-(
		self.success = false
		self:add_event(Error(self, err))
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
	run = function(self)
		self:_start()
		local result = self:try(self.func)
		-- passed steps are atm all events minus the start event, if nothing happened
		self:_end({ passed=#(self.events)-1 })
		return result
	end,
}

cubictest.Specification = Testable {
	type = "Specification",
	new = function(self, object)
		object = cubictest.Testable.new(self, object)
		object.testcases = {}
		return object
	end,
	run = function(self)
		self:_start()
		local result = self:try(self.func)

		if self.setup then self.setup() end
		local ok, fail = 0, 0
		for _, testcase in pairs(self.testcases) do
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
		if self.teardown then self.teardown() end

		self:_end({passed = ok, failed = fail})
		self:report()
		reporter.flush(self.success and "action" or "error")
		return result
	end,
	register_testcase = function(self, description, func)
		local testcase = cubictest.TestCase:new{
			description = description,
			func = func
		}
		table.insert(self.testcases, testcase)
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
