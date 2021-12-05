local Action = require(script.Parent.Action)

return Action("BrushWobbleSet", function(max)
	return {
		max = max
	}
end)