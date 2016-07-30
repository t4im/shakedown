local original_protection = core.is_protected

local protection_states = {}

core.register_entity("sd:show_protection",{
	on_activate = function(self, staticdata, dtime_s)
		core.after(16, function()
			self.object:remove()
		end)
	end,
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		weight = 0,
		collisionbox = { 0, 0, 0, 0, 0, 0 },
		visual = "mesh",
		visual_size = { x=10.1, y=10.1 },
		mesh = "sd_cube.obj",
		textures = { "cubictest_node_frame.png^drop_btn.png" },
	}
})

core.is_protected = function(pos, name)
	local state = protection_states[name]
	if state == true or state == false then
		return state
	end
	if state == "show" then
		core.add_entity(pos, "sd:show_protection")
	end
	return original_protection(pos, name)
end

core.register_chatcommand("protect", {
	description = "set protection against actions by the calling player",
	params = "[on|off|default|show]",
	privs = {interact=true},
	func = function(name,  param)
		if param == "on" or param == "1" then
			protection_states[name] = true
		elseif param == "off" or param == "0" then
			protection_states[name] = false
		elseif param == "default" or param == "." then
			protection_states[name] = nil
		elseif param == "show" or param == "?" then
			protection_states[name] = "show"
		end

		local state = protection_states[name]
		state = state == nil and "default" or
				state == false and "off" or
				state == true and "on" or
				state
		return true, string.format("Protection set to '%s'",  tostring(state))
	end
})
