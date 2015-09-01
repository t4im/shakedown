local cubictest, reporter = cubictest, cubictest.reporter

local events = {}
cubictest.events = events

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
events.Event = setmetatable(Event, {
	__tostring = function(self) string.format("%s Event: %s", self.type, self.description or dump(self)) end,
	__call = function(self, object) return self:new(object) end,
})

events.Step = Event {
	type = "Step",
	meta = {
		__tostring = function (self) return string.format("%s %s", self.conjunction, self.description) end,
		__call = function(self, conjunction, description)
			return self:new { conjunction=conjunction, description=description, }
		end,
	},
}

events.Error = Event {
	type = "Error",
	meta = {
		__call = function(self, context, err)
			return self:new { context=context, message=tostring(err), }
		end,
	},
}

events.Start = Event {
	type = "Start",
	meta = {
		__call = function(self, context)
			return self:new { context=context, }
		end,
	},
}

events.End = Event {
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

events.Run = Event {
	type = "Run",
	meta = {
		__call = function(self, target)
			return self:new { target = target, }
		end,
	},
}
