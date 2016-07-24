return cubictest.formatter:new {
	["Suite Start"] = function(self, run, event)
	end,

	["Specification Start"] = function(self, run, event)
	end,

	["TestCase Start"] = function(self, run, event)
	end,

	["Step"] = function(self, run, event)
	end,

	["TestCase End"] = function(self, run, event)
	end,

	["Specification End"] = function(self, run, event)
	end,

	["Specification Error"] = function(self, run, event)
	end,

	["Suite End"] = function(self, run, event)
	end,

	["Generic Error"] = function(self, run, event)
	end,
}
