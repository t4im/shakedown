local modpath = core.get_modpath(core.get_current_modname())
smoketest = {
	modpath = modpath,
	expect_infinite_stacks = core.setting_getbool("creative_mode"),
	sam = cubictest.dummies.Player:new()
}
local sam = smoketest.sam

local orig_get_player_by_name = core.get_player_by_name
core.get_player_by_name = function(name)
	if name == sam:get_player_name() then
		return sam
	end
	return orig_get_player_by_name(name)
end

dofile(modpath .. "/testbox/init.lua")

dofile(modpath .. "/logusage.lua")
dofile(modpath .. "/items.lua")

dofile(modpath .. "/chatcommands.lua")
