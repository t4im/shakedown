local modpath = cubictest.modpath

-- load luassert assertions
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	modpath .. "/lib/?/src/init.lua;" ..
	modpath .. "/lib/luassert/src/?.lua;" ..
	modpath .. "/lib/luassert/src/?/init.lua;" ..
	package.path

table.insert(package.loaders, function(name)
	--  luassert internally calls luassert.<module>, which won't resolve with the src directory in the submodule, so we strip it off
	local smod = name:match("luassert%.(.*)")
	if not smod then return end
	-- TODO this should not assume an order despite being declared in the api:
	return package.loaders[2](smod)
end)

cubictest.say = require("say")
cubictest.assert = require("luassert")
cubictest.match = require("luassert.match")
cubictest.stub = require("luassert.stub")
cubictest.spy = require("luassert.spy")
cubictest.mock = require("luassert.mock")

---- use the extended luassert implementation as an drop-in replacement for all asserts
assert = cubictest.assert
