local Action = require(script.Parent.Action)

return Action("BrushScaleSet", function(min)
	return {
		min = min
	}
end)