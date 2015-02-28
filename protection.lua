local original_protection = minetest.is_protected

local protection_states = {}

minetest.is_protected = function(pos, name)
	local state = protection_states[name]
	if state ~= nil then -- do check for nil not for false!
		return state
	end
	return original_protection(pos, name)
end

minetest.register_chatcommand("protect", {
	description = "set protection against actions by the calling player",
	params = "[on|off|default]",
	privs = {interact=true},
	func = function(name,  param)
		if param == "on" or param == "1" then
			protection_states[name] = true
		elseif param == "off" or param == "0" then
			protection_states[name] = false
		elseif param == "default" or param == "." then
			protection_states[name] = nil
		end

		local state = protection_states[name] == nil and "default"
				or protection_states[name] and "on" or "off"
		return true, string.format("Protection set to '%s'",  state)
	end
})
