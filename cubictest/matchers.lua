local cubictest, luassert = cubictest, cubictest.luassert
cubictest.match = cubictest.luassert_match

luassert:register("matcher", "in_creative_inventory", function(state, arguments, level)
	return function(item)
		if type(item) == "string" then
			item = core.registered_items[item]
		end
		return not(
			-- list of reasons, why it wouldn't be
			not item
			or not item.description
			or item.description == ""
			or item.groups.not_in_creative_inventory and item.groups.not_in_creative_inventory ~= 0
			)
	end
end)

--

describe("matcher.is_value_of(table, key)(value)", function()
	it("matches values that are set to the specified key of a table", function()
		Given "a table with a key-value pair"
		local test_table = {
			testkey = "testvalue"
		}
		When "matching against it"
		local matcher = cubictest.match.is_value_of(test_table, "testkey")

		Then "match the right value"
		assert.is.True(matcher("testvalue"))
		But "don't match any other value"
		assert.is.False(matcher("wrongtestvalue"))
	end)
	it("matches values that are set to any key of a table if no key was specified", function()
		Given "a table with multiple key-value pairs"
		local test_table = {
			testkey1 = "testvalue1",
			testkey2 = "testvalue2"
		}
		When "matching against it"
		local matcher = cubictest.match.is_value_of(test_table)

		Then "match an existing value"
		assert.is.True(matcher("testvalue2"))
		But "don't match any value, that doesn't exist"
		assert.is.False(matcher("wrongtestvalue"))
	end)
end)

luassert:register("matcher", "is_value_of", function(state, arguments, level)
	local arg_table = arguments[1]
	assert(type(arg_table) == "table")
	local arg_key = arguments[2]
	if arg_key then
		return function(match_value)
			return arg_table[arg_key] == match_value
		end
	else
		return function(match_value)
			for _, var in pairs(arg_table) do
				if var == match_value then return true end
			end
			return false
		end
	end
end)

--

describe("matcher.is_subset_of(table)(table)", function()
	it("matches tables with the property", function()
		Given "a table with multiple key-value pair"
		local test_table = {
			testkey1 = "testvalue1",
			testkey2 = "testvalue2",
			testkey3 = "testvalue3",
		}
		When "matching against it"
		local matcher = cubictest.match.is_subset_of(test_table)

		Then "match a subsets"
		assert.is.True(matcher({
			testkey1 = "testvalue1",
			testkey3 = "testvalue3",
		}))
		But "don't match a table that isn't"
		assert.is.False(matcher({ wrongkey = "testvalue"}))
		assert.is.False(matcher({
			testkey1 = "testvalue1",
			wrongkey = "testvalue",
		}))
	end)
end)

luassert:register("matcher", "is_subset_of", function(state, arguments, level)
	local arg_table = arguments[1]
	assert(type(arg_table) == "table")

	return function(subset_table)
		for key, value in pairs(subset_table) do
			if arg_table[key] ~= value then return false end
		end
		return true
	end
end)
