local string = string
return cubictest.formatter:new{
	["Suite Start"] = function(self, run, event)
		self.cases_passed = 0
		self.cases_failed = 0
		self.index = 0
	end,

	["Specification Error"] = function(self, run, event)
		self:write_ln("# ! it fails during setup with:")
		self:write_ln(event.message:prefix_lines("# !"))
	end,

	["Generic Error"] = function(self, run, event)
		self:write_ln("# ! it fails with:")
		self:write_ln(event.message:prefix_lines("# !"))
	end,

	["Specification Start"] = function(self, run, event)
		self.cases_passed = self.cases_passed + run.passed
		self.cases_failed = self.cases_failed + run.failed
		self:write_ln("# describe %s (%d/%d):", run.target.description, run.passed, run:get_total())
	end,

	["TestCase Start"] = function(self, run, event)
		self.index = self.index + 1
		self:write_ln("%s %d - %s", run.success and "ok" or "not ok", self.index, run.target.description)
	end,

	["Step"] = function(self, run, event)
		self:write_ln("# - %s %s", event.conjunction, event.description)
	end,

	["TestCase End"] = function(self, run, event)
	end,

	["Specification End"] = function(self, run, event)
	end,

	["Suite End"] = function(self, run, event)
		local run_time = event.time - run.events[1].time
		self:write_ln("# Run in %.2fs:", run_time/1000000)
		local specs_total = run:get_total()
		self:write_ln("# %d specifications (%d passed, %d failed) in %.2fms/spec",
			specs_total, run.passed, run.failed, run_time/specs_total/1000)
		local cases_total = self.cases_passed + self.cases_failed
		self:write_ln("# of %d tests (%d passed, %d failed) in %.2fms/test",
			cases_total, self.cases_passed, self.cases_failed, run_time/cases_total/1000)

		self:write_ln("0..%d", cases_total)
	end,
}
