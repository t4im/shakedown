local string, round = string, math.round
return cubictest.formatter:new{
	["Specification Error"] = function(self, run, event)
		self:write_ln("[!] fails during setup:\n%s", event.message)
	end,

	["Generic Error"] = function(self, run, event)
		self:write_ln("[!] but fails with:\n%s", event.message)
	end,

	["Step"] = function(self, run, event)
		self:write_ln("  + %s %s", event.conjunction, event.description)
	end,

	["TestCase Start"] = function(self, run, event)
		self:write_ln("- %s ", run.target.description)
	end,

	["TestCase End"] = function(self, run, event)
	end,

	["Specification Start"] = function(self, run, event)
		self:write_ln("\n%s", run.target.description)
	end,

	["Specification End"] = function(self, run, event)
		self.cases_passed = self.cases_passed + event.passed
		self.cases_failed = self.cases_failed + event.failed
		local summary = string.format("%s (%d/%d)", run.success and "ok" or "fail", run.passed, run:get_total())
		self:write_ln("=========================================================[ %16s ]===", summary)
	end,

	["Suite Start"] = function(self, run, event)
		self.cases_passed = 0
		self.cases_failed = 0
	end,

	["Suite End"] = function(self, run, event)
		local cases_total = self.cases_passed + self.cases_failed
		self:write_ln(string.rep("*", 80))
		self:write_ln("*** Run %d tests (%d passed, %d failed)",
			cases_total, self.cases_passed, self.cases_failed)
		local specs_total = run:get_total()
		self:write_ln("*** of %d specifications (%d passed, %d failed)",
			specs_total, run.passed, run.failed)
		local run_time = event.time - run.events[1].time
		self:write_ln("*** in %.2fs (avg. %.2fms/test %.2fms/spec)",
			run_time/1000000, run_time/cases_total/1000, run_time/specs_total/1000)
		self:write_ln(string.rep("*", 80))
	end,
}