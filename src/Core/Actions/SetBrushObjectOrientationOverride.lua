local Action = require(script.Parent.Action)

return Action("BrushObjectOrientationSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)