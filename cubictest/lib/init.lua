local modpath = cubictest.modpath

-- load luassert assertions
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

cubictest.say = require("say")
cubictest.assert = require("luassert")
cubictest.match = require("luassert.match")

---- use the extended luassert implementation as an drop-in replacement for all asserts
assert = cubictest.assert
