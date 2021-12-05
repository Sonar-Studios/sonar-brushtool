local Action = require(script.Parent.Action)

return Action("BrushWobbleSet", function(mode)
	return {
		mode = mode
	}
end)