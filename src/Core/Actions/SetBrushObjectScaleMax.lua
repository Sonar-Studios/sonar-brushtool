local Action = require(script.Parent.Action)

return Action("BrushObjectScaleSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)