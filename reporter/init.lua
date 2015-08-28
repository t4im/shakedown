local string, table, core, mtt = string, table, core, mtt
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

local detailed_list_formatter = formatter:new{
	["Run"] = function(self, event)
		local target = event.target
		local skip_steps = target.success

		for index, target_event in ipairs(target.events) do
			if not skip_steps or target_event.type ~= "Step" then
				self:event(target_event)
			end
		end
	end,

	["Specification Error"] = function(self, event)
		self:write_ln("[!] fails during setup:\n%s", event.message)
	end,

	["Generic Error"] = function(self, event)
		self:write_ln("[!] but fails with:\n%s", event.message)
	end,

	["Step"] = function(self, event)
		self:write_ln("  + %s %s", event.conjunction, event.description)
	end,

	["TestCase Start"] = function(self, event)
		self:write_ln("- %s ", event.context.description)
	end,

	["TestCase End"] = function(self, event)
	end,

	["Specification Start"] = function(self, event)
		self:write_ln("\n===[ %70s ]===", event.context.description)
	end,

	["Specification End"] = function(self, event)
		local summary = string.format("%s (%d/%d)", event.failed == 0 and "ok" or "fail", event.passed, event.total)
		self:write_ln("=========================================================[ %16s ]===", summary)
	end,

	["Suite End"] = function(self, event)
		self:write_ln("***** Run tests of %d specifications (%d passed, %d failed) *****", event.total, event.passed, event.failed)
	end,
}

reporter.formatter = detailed_list_formatter:new()

