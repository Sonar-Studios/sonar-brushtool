local Action = require(script.Parent.Action)

return Action("BrushScaleSet", function(fixed)
	return {
		fixed = fixed
	}
end)