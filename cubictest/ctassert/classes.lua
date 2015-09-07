local function is_same_class(expected, actual)
	return type(expected) == type(actual)
		and getmetatable(expected) == getmetatable(actual)
end

cubictest:register_assert("same_class",
	function(state, arguments, level) return is_same_class(arguments[1], arguments[2]) end,
	"Expected objects to have the same metatable.\nPassed in:\n%s\nExpected:\n%s",
	"Expected objects not to have the same metatable.\nPassed in:\n%s\nExpected:\n%s"
)

local comparison_ItemStack = ItemStack("")
cubictest:register_assert("itemstack",
	function(state, arguments, level) return is_same_class(comparison_ItemStack, arguments[1]) end,
	"Expected object to be an ItemStack:\n%s",
	"Expected object not to be an ItemStack:\n%s"
)
