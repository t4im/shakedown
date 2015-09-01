local modpath = cubictest.modpath

-- load luassert assertions
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

cubictest.luassert = require("luassert")
cubictest.luassert_match = require("luassert.match")
