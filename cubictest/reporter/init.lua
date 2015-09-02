local string, table, core, cubictest = string, table, core, cubictest
local reporter = {
	print_out = function(level, msg)
		if not msg then return end
		if level then
			core.log(level, msg)
			core.chat_send_all(level .. ": " .. msg)
		else
			core.log("action", msg)
			core.chat_send_all(msg)
		end
	end,
}
cubictest.reporter = reporter

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
			table.insert(self.out, text)
		end
	end,
	write_ln = function(self, text, ...)
		if text then
			self:write(text, ...)
		end
		table.insert(self.out, "\n")
	end,
	flush = function(self)
		table.insert(self.out, "\n")
		local text = table.concat(self.out)
		self.out = {}
		-- avoid empty lines
		if text:trim() == "" then return nil end
		return text
	end,

	["Unknown Event"] = function(self, event) error("unknown event fired: " .. dump(event)) end,
	["Generic Error"] = function(self, event) self:write_ln(event.message) end,

	event = function(self, event, ...)
		self[event.type](self, event, ...)
	end,
}
cubictest.formatter = formatter

local function add_ctx_switch(name)
	local generic_key = "Generic " .. name
	formatter[name] = function(self, event)
		local ctx = event.context
		if ctx and ctx.type then
			local subformatter = self[string.format("%s %s", ctx.type, name)]
			if subformatter then
				return subformatter(self, event)
			end
		end
		self[generic_key](self, event)
	end

	if not formatter[generic_key] then
		formatter[generic_key] = function(self, event) end
	end
end
add_ctx_switch("Error")
add_ctx_switch("Start")
add_ctx_switch("End")


cubictest.config:register_defaults({
	report_format = "simple",
})

local path = cubictest.modpath ..  "/reporter"
local report_format = cubictest.config:get("report_format"):match("([a-zA-Z_]+)")

reporter.formatter = dofile(string.format("%s/format_%s.lua", path, report_format or "simple")):new()
