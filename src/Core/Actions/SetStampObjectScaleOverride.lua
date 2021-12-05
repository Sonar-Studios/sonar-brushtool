local Action = require(script.Parent.Action)

return Action("StampObjectScaleSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)