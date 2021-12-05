local Action = require(script.Parent.Action)

return Action("BrushObjectRotationSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)