local modpath = minetest.get_modpath(minetest.get_current_modname())
mtt = {
	modpath = modpath,
	entry = function(msg)
		msg = string.format("running %s tests", msg)
		minetest.log("action", msg)
		minetest.chat_send_all(msg)
	end,
}
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

dofile(modpath .. "/assert.lua")
dofile(modpath .. "/inspector.lua")

