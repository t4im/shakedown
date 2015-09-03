return cubictest.formatter:new{
	["Run"] = function(self, event)
		local target = event.target
		local skip_steps = target.success

		for index, target_event in ipairs(target.events) do
			if not skip_steps or target_event.type ~= "Step" then
				self:event(target_event)
			end
		end
	end,

	["Specification Error"] = function(self, event)
		self:write_ln("!! fails during setup:\n%s", event.message)
	end,

	["Generic Error"] = function(self, event)
		self:write_ln("!! but fails with:\n%s", event.message)
	end,

	["Step"] = function(self, event)
		self:write_ln("    + %s %s", event.conjunction, event.description)
	end,

	["TestCase Start"] = function(self, event)
		self:write_ln("  - %s", event.context.description)
	end,

	["TestCase End"] = function(self, event)
	end,

	["Specification Start"] = function(self, event)
		self:write_ln("%s:", event.context.description)
	end,

	["Specification End"] = function(self, event)
		self.cases_passed = self.cases_passed + event.passed
		self.cases_failed = self.cases_failed + event.failed
		local summary = string.format("%s (%d/%d)", event.failed == 0 and "ok" or "fail", event.passed, event.total)
		self:write_ln("[ %10s ]", summary)
	end,

	["Suite Start"] = function(self, event)
		self.cases_passed = 0
		self.cases_failed = 0
	end,

	["Suite End"] = function(self, event)
		local cases_total = self.cases_passed + self.cases_failed
		self:write_ln("***** Run %d tests (%d passed, %d failed) of %d specifications (%d passed, %d failed) *****",
			cases_total, self.cases_passed, self.cases_failed,
			event.total, event.passed, event.failed)
	end,
}
