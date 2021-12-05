local Action = require(script.Parent.Action)

return Action("BrushObjectScaleSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)