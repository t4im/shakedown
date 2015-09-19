local string = string
return cubictest.formatter:new{
	["Suite Start"] = function(self, run, event)
		self.index = 0
	end,

	["Specification Error"] = function(self, run, event)
		self:write_ln("# ! it fails during setup with:")
		self:write_ln(event.message:prefix_lines("# !"))
	end,

	["Generic Error"] = function(self, run, event)
		if event.effect == "skipped" then return end
		self:write_ln("# ! it fails with:")
		self:write_ln(event.message:prefix_lines("# !"))
	end,

	["Specification Start"] = function(self, run, event)
		self:write_ln("# describe %s (%d/%d):", run.target.description, run.stats.passed, run.stats:get_total())
	end,

	["TestCase Start"] = function(self, run, event)
		self.index = self.index + 1
		local ok = run.success and "ok" or "not ok"
		local directive = ""
		if run.failure and run.failure.effect == "skipped" then
			ok = "ok"
			directive = " # SKIP failed assumption"
		end
		self:write_ln("%s %d - %s%s", ok, self.index, run.target.description, directive)
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
		local specs_total = run.stats:get_total()
		self:write_ln("# %d specifications (%s) in %.2fms/spec",
			specs_total, tostring(run.stats), run_time/specs_total/1000)
		local cases_total = run.children_stats:get_total()
		self:write_ln("# %d tests (%s) in %.2fms/test",
			cases_total, tostring(run.children_stats), run_time/cases_total/1000)

		self:write_ln("0..%d", cases_total)
	end,
}
