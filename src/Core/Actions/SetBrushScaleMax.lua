local Action = require(script.Parent.Action)

return Action("BrushScaleSet", function(max)
	return {
		max = max
	}
end)