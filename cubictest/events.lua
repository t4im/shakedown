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
	report = function(self) reporter.formatter:event(self.parent or self, self) end,
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
		__call = function(self, err)
			return self:new { message=tostring(err), }
		end,
	},
}

events.Start = Event {
	type = "Start",
	meta = {
		__call = function(self)
			return self:new {}
		end,
	},
}

events.End = Event {
	type = "End",
	meta = {
		__call = function(self)
			return self:new {}
		end,
	},
}

events.Run = Event {
	type = "Run",
	meta = {
		__call = function(self, target)
			return self:new {
				target = target,
				events = {},
				passed = 0,
				failed = 0,
				-- lets start positive, sadness will come on its own
				success = true,
			}
		end,
	},
	add = function(self, event)
		if event.type == "Step" then
			-- every step we make, until we throw an error
			self.passed = self.passed + 1
		elseif event.type == "Run" then
			if event.success then
				self.passed = self.passed + 1
			else
				self.failed = self.failed + 1
				self.success = false
			end
		elseif event.type == "Error" then
			-- :'-(
			self.success = false
		end
		event.parent = self
		table.insert(self.events, event)
	end,
	get_verdict = function(self)
		return self.success and "OK" or "FAILED"
	end,
	get_total = function(self)
		return self.failed + self.passed
	end,
}
