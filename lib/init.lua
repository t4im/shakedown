local modpath = mtt.modpath

-- load luassert assertions
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

mtt.luassert = require("luassert")
