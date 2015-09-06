local string, table, core, cubictest = string, table, core, cubictest
local reporter = {
	print_out = function(level, msg)
		if not msg then return end
		core.log(level or "action", msg)
		core.chat_send_all(msg)
	end,
	event = function(self, event)
		self.formatter:event(nil, event)
	end,
	flush = function(self, level)
		self.print_out(level, self.formatter:flush())
	end
}
cubictest.reporter = reporter

local format_path = cubictest.modpath ..  "/reporter/format"
dofile(format_path .. "/init.lua")

cubictest.config:register_defaults({
	report_format = "simple",
})

local report_format = cubictest.config:get("report_format"):match("([0-9a-zA-Z_]+)")
reporter.formatter = dofile(string.format("%s/%s.lua", format_path, report_format or "simple")):new()
