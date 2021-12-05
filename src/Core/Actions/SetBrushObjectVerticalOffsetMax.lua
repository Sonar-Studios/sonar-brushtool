local Action = require(script.Parent.Action)

return Action("BrushObjectVerticalOffsetSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)