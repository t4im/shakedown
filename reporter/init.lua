local string, table, core, mtt = string, table, core, mtt
local reporter = {
	print_out = function(level, msg)
		if level then
			core.log(level, msg)
			core.chat_send_all(level .. ": " .. msg)
		else
			core.log("action", msg)
			core.chat_send_all(msg)
		end
	end,
}
mtt.reporter = reporter

reporter.flush = function(level)
	reporter.print_out(level, reporter.formatter:flush())
end

reporter.print = function(text, ...)
	reporter.formatter:print(text, ...)
end

local formatter = {
	new = function(self, object)
		object = object or {}
		-- output buffer
		object.out = {}
		return setmetatable(object, {
			__index = self,
			__tostring = self.to_string,
		})
	end,
	to_string = function(self)
		return table.concat(self.out, "\n")
	end,
	write = function(self, text, ...)
		if (...) then
			table.insert(self.out, string.format(text, ...))
		else
			table.insert(self.out, text or "\n")
		end
	end,
	flush = function(self)
		table.insert(self.out, "\n")
		local text = table.concat(self.out, "\n")
		self.out = {}
		return text
	end,

	summary = function() error("no report format defined") end,
	spec_error = function(self, err) error(err) end,
	error = function(self, err) error(err) end,
	specification = function(self, description) end,
	spec_summary = function(self, ok, fail) end,
	testcase = function(self, description) end,
	step = function(self, conjunction, description) end,
}

local detailed_list_formatter = formatter:new{
	summary = function(self, ok, fail)
		self:write("***** Run tests of %d specifications (%d ok, %d failed) *****", ok+fail, ok, fail)
	end,
	specification = function(self, description)
		self:write("\n===[ %70s ]===", description)
	end,
	spec_summary = function(self, ok, fail)
		local summary = string.format("%s (%d/%d)", fail == 0 and "ok" or "fail", ok, ok+fail)
		self:write("=========================================================[ %16s ]===", summary)
	end,
	spec_error = function(self, err)
		self:write("[!] fails during setup:\n%s",err)
	end,
	testcase = function(self, description)
		self:write("- %s", description)
	end,
	step = function(self, conjunction, description)
		self:write("  + %s %s", conjunction, description)
	end,
	error = function(self, err)
		self:write("[!] but fails with:\n%s", err)
	end,
}

reporter.formatter = detailed_list_formatter:new()

