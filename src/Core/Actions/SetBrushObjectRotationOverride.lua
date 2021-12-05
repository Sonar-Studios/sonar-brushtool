local Action = require(script.Parent.Action)

return Action("BrushObjectRotationSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)