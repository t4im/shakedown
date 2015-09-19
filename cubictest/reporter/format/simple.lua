local string = string
return cubictest.formatter:new {
	["Suite Start"] = function(self, run, event)
	end,

	["Specification Start"] = function(self, run, event)
		self:write_ln("%s:", run.target.description)
	end,

	["TestCase Start"] = function(self, run, event)
		self:write_ln("  - %s", run.target.description)
	end,

	["Step"] = function(self, run, event)
		self:write_ln("    + %s %s", event.conjunction, event.description)
	end,

	["TestCase End"] = function(self, run, event)
	end,

	["Specification End"] = function(self, run, event)
		local summary = string.format("%s (%d/%d)", run.failed == 0 and "ok" or "fail", run.passed, run:get_total())
		self:write_ln("[ %10s ]", summary)
	end,

	["Specification Error"] = function(self, run, event)
		self:write_ln("!! fails during setup:\n%s", event.message)
	end,

	["Suite End"] = function(self, run, event)
		local run_time = event.time - run.events[1].time
		self:write_ln("Run in %.2fs:", run_time/1000000)
		local specs_total = run.stats:get_total()
		self:write_ln("  %d specifications (%s) in %.2fms/spec",
			specs_total, tostring(run.stats), run_time/specs_total/1000)
		local cases_total = run.children_stats:get_total()
		self:write_ln("  %d tests (%s) in %.2fms/test",
			cases_total, tostring(run.children_stats), run_time/cases_total/1000)
	end,

	["Generic Error"] = function(self, run, event)
		self:write_ln("!! but fails with:\n%s", event.message)
	end,
}
