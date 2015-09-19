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
			return self:new {
				time = core.get_us_time()
			}
		end,
	},
}

events.End = Event {
	type = "End",
	meta = {
		__call = function(self)
			return self:new {
				time = core.get_us_time()
			}
		end,
	},
}

local Stats = {
	new = function(self, object)
		object = object or {
			passed = 0,
			failed = 0,
		}
		return setmetatable(object, { __index = self, __tostring = self.tostring})
	end,
	get_total = function(self)
		return self.failed + self.passed
	end,
	inc = function(self, stat, count)
		self[stat] = (self[stat] or 0) + (count or 1)
	end,
	inc_all = function(self, stats)
		self:inc("passed", stats.passed or 0)
		self:inc("failed", stats.failed or 0)
	end,
	tostring = function (self)
		return string.format("%d passed, %d failed", self.passed, self.failed)
	end,
}

events.Run = Event {
	type = "Run",
	meta = {
		__call = function(self, target)
			return self:new {
				target = target,
				events = {},
				stats = Stats:new(),
				children_stats = Stats:new(),
				-- this controls whether or not children can and will be run
				-- lets start positive, sadness will come on its own
				success = true,
			}
		end,
	},
	add = function(self, event)
		local stats = self.stats
		if event.type == "Step" then
			-- every step we make, until we throw an error
			stats:inc("passed")
		elseif event.type == "Run" then
			if event.success then
				stats:inc("passed")
			else
				stats:inc("failed")
				self.success = false
			end
			self.children_stats:inc_all(event.stats)
		elseif event.type == "Error" then
			-- :'-(
			self.success = false
		end
		event.parent = self
		table.insert(self.events, event)
	end,
}
