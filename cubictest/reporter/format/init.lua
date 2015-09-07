string.prefix_lines = function(self, prefix)
	return prefix .. self:gsub("\n", "\n" .. prefix)
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
	extension = "txt",

	["Unknown Event"] = function(self, event) error("unknown event fired: " .. dump(event)) end,
	["Generic Error"] = function(self, event) self:write_ln(event.message) end,

	["Run"] = function(self, parent_run, run)
		local verbosity =self.verbosity
		for index, subevent in ipairs(run.events) do
			local type = subevent.type
			if not run.success
				or (type == "Step" and verbosity == "steps")
				or (type ~= "Step" and verbosity == "info")
			then
				self:event(run, subevent)
			end
		end
	end,

	event = function(self, run, event)
		self[event.type](self, run, event)
	end,
}

cubictest.formatter = formatter

local function add_ctx_switch(name)
	local generic_key = "Generic " .. name
	formatter[name] = function(self, run, event)
		local type = run and run.target.type or "Root"
		local subformatter = self[string.format("%s %s", type, name)]
		if subformatter then
			return subformatter(self, run, event)
		end
		self[generic_key](self, run, event)
	end

	if not formatter[generic_key] then
		formatter[generic_key] = function(self, event) end
	end
end
add_ctx_switch("Error")
add_ctx_switch("Start")
add_ctx_switch("End")
