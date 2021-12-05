local Action = require(script.Parent.Action)

return Action("BrushRotationSet", function(fixed)
	return {
		fixed = fixed
	}
end)