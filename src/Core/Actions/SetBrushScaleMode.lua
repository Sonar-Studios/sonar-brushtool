local Action = require(script.Parent.Action)

return Action("BrushScaleSet", function(mode)
	return {
		mode = mode
	}
end)