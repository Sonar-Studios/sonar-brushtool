local Action = require(script.Parent.Action)

return Action("StampObjectRotationSet", function(guid, override)
	return {
		guid = guid,
		override = override
	}
end)