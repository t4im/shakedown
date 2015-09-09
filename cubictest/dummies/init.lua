local dummies = {
	fixed = function(x) return function() return x end end,
	nop = function() end,
}

function dummies.setter(name, ...)
	if (...) then
		local sub_names = { ... }
		return function(self, value, ...)
			self[name] = {}
			for i, val in ipairs({ ... }) do
				self[name][sub_names[i]] = val
			end
		end
	else
		return function(self, value) self[name] = value end
	end
end

function dummies.getter(name, default)
	return function(self) return self[name] or default end
end

function dummies.multi_setter(name)
	return function(self, ...)
		self[name] = self[name] or {}
		for i, val in ipairs({ ... }) do
			self[name][i] = val
		end
	end
end

function dummies.multi_getter(name, ...)
	local defaults = { ... }
	return function(self)
		local return_values = table.copy(self[name] or {})
		for i, default_value in ipairs(defaults) do
			return_values[i] = return_values[i] or default_value
		end
		return table.unpack(return_values)
	end
end

cubictest.dummies = dummies

local path = cubictest.modpath ..  "/dummies"
dofile(path .. "/ObjectRef.lua")
