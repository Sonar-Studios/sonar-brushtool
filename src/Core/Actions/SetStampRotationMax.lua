local Action = require(script.Parent.Action)

return Action("StampRotationSet", function(max)
	return {
		max = max
	}
end)