local Action = require(script.Parent.Action)

return Action("StampRotationSet", function(mode)
	return {
		mode = mode
	}
end)