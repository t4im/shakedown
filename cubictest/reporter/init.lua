local string, table, core, cubictest = string, table, core, cubictest
local world_path = core.get_worldpath()
local reporter = {
	report_event = function(self, event)
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
	report_chat_verbosity = "warnings",
	report_log = "simple",
	report_log_verbosity = "warnings",
})


local report_chat = cubictest.config:get("report_chat"):match("([0-9a-zA-Z_]+)")
if report_chat and report_chat ~= "false" then
	reporter.chat_formatter = dofile(string.format("%s/%s.lua", format_path, report_chat or "simple")):new {
		verbosity = cubictest.config:get("report_chat_verbosity"),
	}
end

local report_log = cubictest.config:get("report_log"):match("([0-9a-zA-Z_]+)")
if report_log and report_log ~= "false" then
	reporter.log_formatter = dofile(string.format("%s/%s.lua", format_path, report_log or "simple")):new {
		verbosity = cubictest.config:get("report_log_verbosity"),
	}
end

function reporter.save(reportname, format, verbosity)
	local loaded, result = pcall(dofile, string.format("%s/%s.lua", format_path, format or "simple"))
	if not loaded then return false, result end
	local file_formatter = result:new {
		verbosity = verbosity or cubictest.config:get("report_file_verbosity"),
	}
	file_formatter:event(nil, reporter.event)
	local path = string.format("%s/testreport-%s-%s.%s",
		world_path, reportname, os.date("%Y%m%dT%H%M%S"), file_formatter.extension
	)

	local output, err = io.open(path, "w")
	if not output then
		return false, "Writing to file failed with: " .. err
	end
	output:write(file_formatter:flush())
	io.close(output)

	return true, "Report saved to " .. path
end

local usage = "<name> [format]"
core.register_chatcommand(core.get_current_modname() .. ":save", {
	description = "Run tests.",
	params = usage,
	privs = { server = true },
	func = function(name,  param)
		local reportname, format = string.match(param, "([^ ]+) ?([0-9a-zA-Z_]*)")
		if reportname then
			return reporter.save(reportname, format)
		end
		return false, "Usage: " .. usage
	end,
})
