local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath .. "/strict.lua")
dofile(modpath .. "/protection.lua")
dofile(modpath .. "/inspector.lua")

minetest.register_on_newplayer(function(player)
	local inventory = player:get_inventory()
	inventory:add_item('main', 'mod_test:inspector')
	inventory:add_item('main', 'default:pick_diamond')
	inventory:add_item('main', 'default:axe_diamond')
	inventory:add_item('main', 'default:shovel_diamond')
end)
