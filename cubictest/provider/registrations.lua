local provider = cubictest.provider

function provider.craft_guide_items()
	return provider.entries(core.registered_items, nil, cubictest.match.Not.in_creative_inventory())
end

