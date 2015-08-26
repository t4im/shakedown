local modpath = minetest.get_modpath(minetest.get_current_modname())
mtt = {
	modpath = modpath,
	print = print, -- to allow mod_test to overwrite this with a custom version
	notify = function(level, msg)
		minetest.log(level, msg)
		minetest.chat_send_all(level .. ": " .. msg)
	end,
}

-- load compatibility layer between lua versions
dofile(modpath .. "/compat.lua")
-- load external dependencies
dofile(modpath .. "/lib/init.lua")

-- the mtt engine itself
dofile(modpath .. "/reporter/init.lua")
dofile(modpath .. "/testrunner.lua")
dofile(modpath .. "/api.lua")

-- supporting components
dofile(modpath .. "/mocks/init.lua")
dofile(modpath .. "/provider/init.lua")

minetest.after(1, function ()
	mtt.testrunner:runAll()
end)
