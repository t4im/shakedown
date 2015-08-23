local modpath = minetest.get_modpath(minetest.get_current_modname())
mtt = {
	modpath = modpath,
	print = print, -- to allow mod_test to overwrite this with a custom version
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
dofile(modpath .. "/reporter.lua")
dofile(modpath .. "/testrunner.lua")
dofile(modpath .. "/recipes.lua")

minetest.after(1, function ()
	mtt.runAll()
end)
