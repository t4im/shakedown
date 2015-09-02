local provider = {

	}
cubictest.provider = provider

local path = cubictest.modpath ..  "/provider"
dofile(path .. "/registrations.lua")
dofile(path .. "/voxel.lua")

describe("provider.entries(table, key_matcher, value_matcher)", function()
	it("iterates like pairs() when no matchers are set", function()
		Given "a map"
		local test_table = {
			test_1 = 1,
			test_2 = "test",
			test_3 = {},
			test_4 = function()end,
		}

		When "iterating through it without matchers set"
		local test_copy = {}
		for key, var in  provider.entries(test_table) do
			test_copy[key] = var
		end

		Then "return all the entries"
		assert.are.same(test_table, test_copy)
	end)
	it("can select entries based on matching", function()
		Given("a map")
		local test_table = {
			test_1 = 1,
			test_2 = "test",
			test_3 = {},
			test_4 = function()end,
			test_5 = "test2"
		}

		When "iterating through it with a string value matcher set"
		local test_copy = {}
		for key, var in  provider.entries(test_table, nil, cubictest.match.is_string()) do
			test_copy[key] = var
		end

		Then "return only the matched entries"
		assert.are.same({ test_2 = "test", test_5 = "test2"}, test_copy)
	end)
end)

function provider.entries(table, key_matcher, value_matcher)
	local nested_next, nested_table, nested_index = pairs(table)
	local next = function(table, index)
		local key, value = nested_next(table, index)
		while key do
			if (not key_matcher or key_matcher(key)) and
				(not value_matcher or value_matcher(value)) then
				return key, value
			end
			key, value = nested_next(table, key)
		end
	end
	return next, nested_table, nested_index
end
