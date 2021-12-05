local Action = require(script.Parent.Action)

return Action("BrushObjectBrushEnabledSet", function(guid, enabled)
	return {
		guid = guid,
		brushEnabled = enabled
	}
end)