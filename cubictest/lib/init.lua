local modpath = cubictest.modpath

-- load luassert assertions
package.path =
	modpath .. "/?/init.lua;" ..
	modpath .. "/?.lua;" ..
	package.path

cubictest.say = require("say")
cubictest.assert = require("luassert")
cubictest.match = require("luassert.match")
cubictest.stub = require("luassert.stub")
cubictest.spy = require("luassert.spy")
cubictest.mock = require("luassert.mock")

---- use the extended luassert implementation as an drop-in replacement for all asserts
assert = cubictest.assert
