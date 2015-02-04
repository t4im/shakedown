local modpath = minetest.get_modpath(minetest.get_current_modname())
mtt = { modpath = modpath }
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

dofile(modpath .. "/assert.lua")
dofile(modpath .. "/inspector.lua")

