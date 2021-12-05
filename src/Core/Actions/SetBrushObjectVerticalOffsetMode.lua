local Action = require(script.Parent.Action)

return Action("BrushObjectVerticalOffsetSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)