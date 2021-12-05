local Action = require(script.Parent.Action)

return Action("StampRotationSet", function(min)
	return {
		min = min
	}
end)