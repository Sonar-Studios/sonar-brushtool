local Action = require(script.Parent.Action)

return Action("StampIgnoreInvisibleSet", function(ignoreInvisible)
	return {
		ignoreInvisible = ignoreInvisible
	}
end)