local Action = require(script.Parent.Action)

return Action("BrushObjectScaleSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)