local string, table, core, cubictest = string, table, core, cubictest
local reporter = {
	event = function(self, event)
		self.event = event
	end,
	print = function(self)
		local event = self.event

		local formatter = self.log_formatter
		if formatter then
			formatter:event(nil, event)
			core.log("action", formatter:flush())
		end
		local formatter = self.chat_formatter
		if formatter then
			formatter:event(nil, event)
			core.chat_send_all(formatter:flush())
		end
	end,
}
cubictest.reporter = reporter

local format_path = cubictest.modpath ..  "/reporter/format"
dofile(format_path .. "/init.lua")

cubictest.config:register_defaults({
	report_chat = "simple",
	report_log = "simple",
})

local report_chat = cubictest.config:get("report_chat"):match("([0-9a-zA-Z_]+)")
if report_chat and report_chat ~= "false" then
	reporter.chat_formatter = dofile(string.format("%s/%s.lua", format_path, report_chat or "simple")):new()
end

local report_log = cubictest.config:get("report_log"):match("([0-9a-zA-Z_]+)")
if report_log and report_log ~= "false" then
	reporter.log_formatter = dofile(string.format("%s/%s.lua", format_path, report_log or "simple")):new()
end
