local modpath = core.get_modpath(core.get_current_modname())
smoketest = {
	modpath = modpath
}
dofile(modpath .. "/testbox/init.lua")

dofile(modpath .. "/logusage.lua")
dofile(modpath .. "/items.lua")