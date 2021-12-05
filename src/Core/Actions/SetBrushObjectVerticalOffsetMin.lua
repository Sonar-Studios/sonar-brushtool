local Action = require(script.Parent.Action)

return Action("BrushObjectVerticalOffsetSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)