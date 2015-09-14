local modpath = core.get_modpath(core.get_current_modname())
smoketest = {
	modpath = modpath,
	expect_infinite_stacks = core.setting_getbool("creative_mode"),
}
dofile(modpath .. "/testbox/init.lua")

dofile(modpath .. "/logusage.lua")
dofile(modpath .. "/items.lua")