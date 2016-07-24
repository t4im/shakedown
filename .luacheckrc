unused_args = false
allow_defined_top = true

globals = {
	"core",
	"cubictest",
	"string",
}
read_globals = {
	"minetest",
	"DIR_DELIM",
	"ItemStack",
	"Settings",
--	"vector",
	"VoxelManip", "VoxelArea",
	"dump",
	"assert", "assume", "match",
	"spy", "stub", "mock",
	"set_up", "tear_down", "before_each", "after_each",
	"describe", "it", "its", "this",
	"Given", "When", "Then", "But", "And"
}

exclude_files = {
	"**/spec/**",
	"cubictest/lib/**",
}
