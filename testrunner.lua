local table, string, mtt, reporter = table, string, mtt, mtt.reporter

local specifications = {}
mtt.specifications = specifications
local testrunner = {}
mtt.testrunner = testrunner

-- classes
local Event = {
	type = "Unknown",
	new = function(self, object)
		object = object or {}
		local meta = object.meta or {}
		meta.__index = self
		object.meta = nil
		return setmetatable(object, meta)
	end,
	report = function(self) reporter.formatter:event(self) end,
}
mtt.Event = setmetatable(Event, {
	__tostring = function(self) string.format("%s Event: %s", self.type, self.description or dump(self)) end,
	__call = function(self, object) return self:new(object) end,
})

local Step = Event {
	type = "Step",
	meta = {
		__tostring = function (self) return string.format("%s %s", self.conjunction, self.description) end,
		__call = function(self, conjunction, description)
			return self:new { conjunction=conjunction, description=description, }
		end,
	},
}
mtt.Step = Step

mtt.Error = Event {
	type = "Error",
	meta = {
		__call = function(self, context, err)
			return self:new { context=context, message=tostring(err), }
		end,
	},
}

mtt.Start = Event {
	type = "Start",
	meta = {
		__call = function(self, context)
			return self:new { context=context, }
		end,
	},
}

mtt.End = Event {
	type = "End",
	meta = {
		__call = function(self, context, report)
			local passed, failed = report.passed or 0, report.failed or 0
			return self:new {
				context=context,
				passed = passed,
				failed = failed,
				total = report.total or (passed + failed),
				verdict = report.verdict or (context.success and "OK" or "FAILED")
			}
		end,
	},
}

mtt.Run = Event {
	type = "Run",
	meta = {
		__call = function(self, target)
			return self:new { target = target, }
		end,
	},
}

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
		self:add_event(mtt.Start(self))
	end,
	_end = function(self, report)
		self:add_event(mtt.End(self, report or {}))
	end,
	_fail = function(self, err)
		-- :'-(
		self.success = false
		self:add_event(mtt.Error(self, err))
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
mtt.Testable = setmetatable(Testable, {
	__tostring = Testable.__tostring,
	__call = function(self, object) return self:new(object) end,
})

mtt.TestCase = Testable {
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

mtt.Specification = Testable {
	type = "Specification",
	new = function(self, object)
		object = mtt.Testable.new(self, object)
		object.testcases = {}
		return object
	end,
	run = function(self)
		self:_start()
		local result = self:try(self.func)

		if self.before then self.before() end
		local ok, fail = 0, 0
		for _, testcase in pairs(self.testcases) do
			testrunner.ctx_case = testcase
			testcase:run()
			if testcase.success then
				ok = ok + 1
			else
				fail = fail + 1
			end
			self:add_event(mtt.Run(testcase))
		end
		testrunner.ctx_case = nil

		if fail > 0 then self.success = false end
		if self.after then self.after() end

		self:_end({passed = ok, failed = fail})
		self:report()
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
function mtt.testrunner:runAll()
	local ok, fail = 0, 0
	mtt.Start({ type = "Suite" }):report()
	reporter.flush()
	for _, spec in pairs(specifications) do
		self.ctx_spec = spec
		spec:run()
		if spec.success then
			ok = ok + 1
		else
			fail = fail + 1
		end
	end
	self.ctx_spec = nil
	mtt.End({ type = "Suite" }, {passed = ok, failed = fail}):report()
	reporter.flush()
end
