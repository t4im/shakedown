return cubictest.formatter:new{
	["Specification Error"] = function(self, run, event)
		self:write_ln("!! fails during setup:\n%s", event.message)
	end,

	["Generic Error"] = function(self, run, event)
		self:write_ln("!! but fails with:\n%s", event.message)
	end,

	["Step"] = function(self, run, event)
		self:write_ln("    + %s %s", event.conjunction, event.description)
	end,

	["TestCase Start"] = function(self, run, event)
		self:write_ln("  - %s", run.target.description)
	end,

	["TestCase End"] = function(self, run, event)
	end,

	["Specification Start"] = function(self, run, event)
		self:write_ln("%s:", run.target.description)
	end,

	["Specification End"] = function(self, run, event)
		self.cases_passed = self.cases_passed + run.passed
		self.cases_failed = self.cases_failed + run.failed
		local summary = string.format("%s (%d/%d)", run.failed == 0 and "ok" or "fail", run.passed, run:get_total())
		self:write_ln("[ %10s ]", summary)
	end,

	["Suite Start"] = function(self, run, event)
		self.cases_passed = 0
		self.cases_failed = 0
	end,

	["Suite End"] = function(self, run, event)
		local cases_total = self.cases_passed + self.cases_failed
		self:write_ln("***** Run %d tests (%d passed, %d failed) of %d specifications (%d passed, %d failed) *****",
			cases_total, self.cases_passed, self.cases_failed,
			run:get_total(), run.passed, run.failed)
	end,
}
