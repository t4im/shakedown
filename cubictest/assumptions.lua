local assert = cubictest.assert

local assume = {}

local assume_mt = {
	__index = function(table, key)
		return function(...)
			local success, error_or_return = pcall(assert[key], ...)
			if success then return error_or_return end

			if type(error_or_return) == "table" then
				error_or_return.effect = "skipped"
			else
				error_or_return = setmetatable({
					message = error_or_return,
					effect = "skipped",
				}, {
					__tostring = function(self) return self.message end
				})
			end
			error(error_or_return, 2)
		end
	end
}

cubictest.assume = setmetatable(assume, assume_mt)
