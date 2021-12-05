local Action = require(script.Parent.Action)

return Action("BrushIgnoreInvisibleSet", function(ignoreInvisible)
	return {
		ignoreInvisible = ignoreInvisible
	}
end)