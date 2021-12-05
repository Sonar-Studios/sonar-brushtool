local Action = require(script.Parent.Action)

return Action("StampRotationSet", function(fixed)
	return {
		fixed = fixed
	}
end)