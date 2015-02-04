minetest.register_on_newplayer(function(player)
	local inventory = player:get_inventory()
	inventory:add_item('main', 'mtt:metadata_inspector')
	inventory:add_item('main', 'default:pick_diamond')
	inventory:add_item('main', 'default:axe_diamond')
	inventory:add_item('main', 'default:shovel_diamond')
end)



