local Action = require(script.Parent.Action)

return Action("BrushObjectWobbleSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)