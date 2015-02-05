local modpath = minetest.get_modpath(minetest.get_current_modname())
mtt = {
	modpath = modpath,
	notify = function(level, msg)
		minetest.log(level, msg)
		minetest.chat_send_all(level .. ": " .. msg)
	end,
}
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

dofile(modpath .. "/assert.lua")
dofile(modpath .. "/recipes.lua")

