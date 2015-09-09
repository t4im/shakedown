local modpath = core.get_modpath(core.get_current_modname())
cubictest = {
	modpath = modpath,
}

-- load constants and configuration
dofile(modpath .. "/config.lua")

-- load compatibility layer between lua versions
dofile(modpath .. "/compat.lua")
-- load external dependencies
dofile(modpath .. "/lib/init.lua")

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
