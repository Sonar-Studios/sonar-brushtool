local Action = require(script.Parent.Action)

return Action("BrushWobbleSet", function(min)
	return {
		min = min
	}
end)