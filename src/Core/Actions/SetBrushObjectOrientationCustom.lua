local Action = require(script.Parent.Action)

return Action("BrushObjectOrientationSet", function(guid, custom)
	return {
		guid = guid,
		custom = custom
	}
end)