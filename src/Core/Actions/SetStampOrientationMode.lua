local Action = require(script.Parent.Action)

return Action("StampOrientationSet", function(mode)
	return {
		mode = mode
	}
end)