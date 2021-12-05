local Action = require(script.Parent.Action)

return Action("StampObjectOrientationSet", function(guid, custom)
	return {
		guid = guid,
		custom = custom
	}
end)