local Action = require(script.Parent.Action)

return Action("BrushObjectScaleSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)