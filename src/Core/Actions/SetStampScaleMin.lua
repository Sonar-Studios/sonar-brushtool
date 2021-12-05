local Action = require(script.Parent.Action)

return Action("StampScaleSet", function(min)
	return {
		min = min
	}
end)