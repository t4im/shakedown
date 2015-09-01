local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
dofile(modpath .. "/strict.lua")
dofile(modpath .. "/protection.lua")
dofile(modpath .. "/inspector.lua")
dofile(modpath .. "/node_placer.lua")

core.register_on_newplayer(function(player)
	local inventory = player:get_inventory()
	inventory:add_item("main", modname .. ":inspector")
	inventory:add_item("main", "default:pick_diamond")
	inventory:add_item("main", "default:axe_diamond")
	inventory:add_item("main", "default:shovel_diamond")
end)
