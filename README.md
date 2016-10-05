# Shakedown

> <dl><dt>shake·down /ˈʃeɪkdaʊn/ (noun):</dt>
> <dd>a period of testing undergone before being declared operational.</dd></dl>

#### [cubictest](./cubictest/)
###### The behavior driven testing framework for minetest
![](./cubictest/cubictest_logo.png)
```lua
describe("my mod's functionality", function()
	it("can calculate 1*1", function()
		Given "two numbers"
		local number, factor = 1, 1
		When "multiplying"
		local result = number * factor
		Then "calculate the right answer"
		assert.is.equal(1, result)
	end)
end)
```

#### [smoketest](./smoketest/)
###### Preliminary tests, that detects simple early failures.
```yaml
Node: default:chest_locked
 - it can be placed against an unknown node and will be removed from the ItemStack
 - it can be punched
 - it handles a null player passed to its can_dig(pos, [player])
!! but fails with:
.../default/nodes.lua:1357: attempt to index local 'player' (a nil value)
[fail (2/3)]
```

#### [sd (shakedown)](./sd/)
###### Utilities for developing, (collaborative) testing and debugging.
![](./sd/screenshot.png)

#### [testingground](./testingground/)
###### A testing oriented singlenode mapgen.
![](./testingground/screenshot.png)

Make sure to get the submodules too:
```sh
git clone --recurse-submodules https://github.com/t4im/shakedown.git
```

And to recurse submodules when updating:
```sh
git pull --recurse-submodules
```

## Related projects
* [coretest](https://github.com/t4im/coretest/): cubictest against the minetest api/core.

## License
This software is licensed under the MIT License (Expat).
See [the license file](MIT.license) for details.

