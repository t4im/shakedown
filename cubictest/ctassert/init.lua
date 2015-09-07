local cubictest, luassert = cubictest, cubictest.luassert
local path = cubictest.modpath ..  "/ctassert"

function cubictest:register_assert(name, func, err, err_negated)
	local key = string.format("assertion.%s.positive", name)
	local key_negated = string.format("assertion.%s.negative", name)
	self.say:set(key, err)
	self.say:set(key_negated, err_negated)
	self.assert:register("assertion", name, func, key, key_negated)
end
function cubictest:register_matcher(name, func)
	self.assert:register("matcher", name, func)
end

dofile(path .. "/tables.lua")
dofile(path .. "/classes.lua")
dofile(path .. "/item_groups.lua")
