local core, cubictest, smoketest = core, cubictest, smoketest
local sam = smoketest.sam

local function is_testable(name, def)
	local privs = def.privs
	if privs.server or privs.ban or privs.kick
		or privs.rollback
		or privs.password then
		return false
	end
	return true
end

local function describe_chatcommand(name, def)
	if is_testable(name, def) then
		describe("/" .. name, function()
			it("can be called from virtual players", function()
				def.func(sam:get_player_name(), "")
			end)
		end)
	end
end

-- describe anything registered so far
for name, def in pairs(core.chatcommands) do
	describe_chatcommand(name, def)
end
-- describe anything registered from now on, too
local register_chatcommand = core.register_chatcommand
core.register_chatcommand = function(cmd, def)
	register_chatcommand(cmd, def)
	describe_chatcommand(cmd, def)
end
