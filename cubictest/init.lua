local modpath = core.get_modpath(core.get_current_modname())
cubictest = {
	modpath = modpath,
}

-- load constants and configuration
dofile(modpath .. "/config.lua")

-- load compatibility layer between lua versions
dofile(modpath .. "/compat.lua")

-- load external dependencies
local load_libs = dofile(modpath .. "/lib/init.lua")
local env = core.request_insecure_environment()
assert(env, "\n================================================================================\n"
	.. "Mod security prevents Shakedown's cubictest from loading the assertion library.\n"
	.. "You can add cubictest to 'secure.trusted_mods', but beware, that it can decrease\n"
	.. "effectivity of mod security and should not be run combined with any untrustworthy mods.\n"
	.. "================================================================================\n")
load_libs(env)

-- assumptions need to be load before the api, but after assertions
dofile(modpath .. "/assumptions.lua")

-- the test framework itself
dofile(modpath .. "/reporter/init.lua")
dofile(modpath .. "/events.lua")
dofile(modpath .. "/testrunner.lua")
dofile(modpath .. "/api.lua")

-- supporting components
dofile(modpath .. "/dummies/init.lua")
dofile(modpath .. "/ctassert/init.lua")
dofile(modpath .. "/provider/init.lua")

cubictest.config:register_defaults({
	run_on_startup = false
})

local startup_run = cubictest.config:get("run_on_startup")
if startup_run then
	core.after(1, function ()
		cubictest.testrunner:runAll(type(startup_run) == "string" and startup_run)
	end)
end
