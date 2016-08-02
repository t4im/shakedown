core.register_chatcommand("hp", {
	description = "set healthpoints",
	params = "[healthpoints]",
	privs = {interact=true},
	func = function(name,  param)
		local player = core.get_player_by_name(name)
		param = tonumber(param)
		if param then
			player:set_hp(param)
		end
		return true, string.format("%d/%d hp", player:get_hp(), cubictest.constants.PLAYER_MAX_HP)
	end
})
