local Action = require(script.Parent.Action)

return Action("StampObjectOrientationSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)