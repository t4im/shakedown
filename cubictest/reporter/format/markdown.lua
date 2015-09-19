local string = string
return cubictest.formatter:new {
	["Suite Start"] = function(self, run, event)
	end,

	["Specification Start"] = function(self, run, event)
		self:write_ln("#### %s", run.target.description)
	end,

	["TestCase Start"] = function(self, run, event)
		self.step_index = 0
		self:write_ln("###### … %s", run.target.description)
	end,

	["Step"] = function(self, run, event)
		self.step_index = self.step_index + 1
		if not run.success and #(run.events)-3 <= self.step_index then
			-- intentional whitespace at the end for line break
			self:write_ln(" %d. ~~**%s** %s~~  ", self.step_index, event.conjunction, event.description)
		else
			self:write_ln(" %d. **%s** %s", self.step_index, event.conjunction, event.description)
		end
	end,

	["TestCase Error"] = function(self, run, event)
		if event.effect == "skipped" then
			self:write_ln("    Skipped: failed assumption")
			return
		end
		self:write_ln("    Fail with:\n")
		self:write_ln(event.message:prefix_lines("    > "))
	end,

	["TestCase End"] = function(self, run, event)
		self:write_ln()
	end,

	["Specification End"] = function(self, run, event)
	end,

	["Specification Error"] = function(self, run, event)
		self:write_ln("##### … Its setup fails with:")
		self:write_ln(event.message:prefix_lines("> "))
	end,

	["Suite End"] = function(self, run, event)
		self:write_ln("## Summary")
		local run_time = event.time - run.events[1].time
		self:write_ln(" * Run in %.2fs", run_time/1000000)
		local specs_total = run.stats:get_total()
		self:write_ln(" * %d specifications (%s) in %.2fms/spec",
			specs_total, tostring(run.stats), run_time/specs_total/1000)
		local cases_total = run.children_stats:get_total()
		self:write_ln(" * %d tests (%s) in %.2fms/test",
			cases_total, tostring(run.children_stats), run_time/cases_total/1000)
	end,

}
