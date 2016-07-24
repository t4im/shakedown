local modname = core.get_current_modname()
local dummies = cubictest.dummies
local nodes = {
	registered = {},
	default_tiles = {
		"cubictest_testnode_bg.png^cubictest_y.png",
		"cubictest_testnode_bg.png^cubictest_-y.png",
		"cubictest_testnode_bg.png^cubictest_x.png",
		"cubictest_testnode_bg.png^cubictest_-x.png",
		"cubictest_testnode_bg.png^cubictest_z.png",
		"cubictest_testnode_bg.png^cubictest_-z.png"
	},
}
dummies.nodes = setmetatable(nodes, { __index = nodes.registered })


function nodes.register(name, def)
	local node_name =  modname .. ":" .. name
	def.paramtype = def.paramtype or "light"
	def.tiles = def.tiles or nodes.default_tiles
	def.groups = def.groups or { dig_immediate=2, not_in_creative_inventory=1 }

	core.register_node(node_name, def)
	nodes.registered[name] = {
		name = node_name,
		-- use the def after defaults were set
		def = core.registered_items[node_name]
	}
end

nodes.register("undiggable", {
	description = "node that doesn't allow to be dug by players",
	can_dig = function(pos, player) return false end
})

nodes.register("facedirected", {
	description = "node with facedir parameter",
	paramtype2 = "facedir",
})

nodes.register("destructable", {
	description = "node with on_destruct/after_destructs",
	-- Node destructor; always called before removing node
	on_destruct = function()end,
	-- Node destructor; always called after removing node
	after_destruct = function()end,
})
