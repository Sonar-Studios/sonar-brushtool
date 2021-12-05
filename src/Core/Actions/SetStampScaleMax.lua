local Action = require(script.Parent.Action)

return Action("StampScaleSet", function(max)
	return {
		max = max
	}
end)