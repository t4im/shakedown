local modpath = cubictest.modpath

local function load_libs(env)
	-- load luassert assertions
	env.package.path =
		modpath .. "/?/init.lua;" ..
		modpath .. "/?.lua;" ..
		modpath .. "/lib/?/src/init.lua;" ..
		modpath .. "/lib/luassert/src/?.lua;" ..
		modpath .. "/lib/luassert/src/?/init.lua;" ..
		env.package.path

	table.insert(env.package.loaders, function(name)
		--  luassert internally calls luassert.<module>, which won't resolve with the src directory in the submodule, so we strip it off
		local smod = name:match("luassert%.(.*)")
		if not smod then return end
		-- TODO this should not assume an order despite being declared in the api:
		return env.package.loaders[2](smod)
	end)

	-- leaving this in _G will obviously decrease mod
	-- security, but we lack good alternatives, with it being needed after init
	-- and decreased security is better than no security at all, as long as the
	-- user is aware of it
	require = env.require

	cubictest.say = require("say")
	cubictest.assert = require("luassert")
	cubictest.match = require("luassert.match")
	cubictest.stub = require("luassert.stub")
	cubictest.spy = require("luassert.spy")
	cubictest.mock = require("luassert.mock")

	---- use the extended luassert implementation as an drop-in replacement for all asserts
	env.assert = cubictest.assert
end

return load_libs
