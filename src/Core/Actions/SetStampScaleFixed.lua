local Action = require(script.Parent.Action)

return Action("StampScaleSet", function(fixed)
	return {
		fixed = fixed
	}
end)