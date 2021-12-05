local Action = require(script.Parent.Action)

return Action("EraseIgnoreInvisibleSet", function(ignoreInvisible)
	return {
		ignoreInvisible = ignoreInvisible
	}
end)