local provider = mtt.provider

function provider.craft_guide_items()
	return provider.entries(core.registered_items, nil, mtt.match.Not.in_creative_inventory())
end

