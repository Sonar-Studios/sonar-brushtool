local Action = require(script.Parent.Action)

return Action("StampScaleSet", function(mode)
	return {
		mode = mode
	}
end)